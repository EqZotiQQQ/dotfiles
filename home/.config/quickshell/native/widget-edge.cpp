#include <hyprland/src/plugins/PluginAPI.hpp>
#include <hyprland/src/managers/EventManager.hpp>
#include <hyprland/src/managers/eventLoop/EventLoopManager.hpp>
#include <hyprland/src/managers/input/InputManager.hpp>
#include <hyprland/src/output/Monitor.hpp>
#include <hyprland/src/pointer/PointerManager.hpp>
#include <hyprland/src/state/MonitorState.hpp>
#include <hyprland/src/desktop/state/LayerState.hpp>
#include <hyprland/src/desktop/view/LayerSurface.hpp>
#include <hyprland/src/protocols/core/Compositor.hpp>
#include <hyprland/src/render/Renderer.hpp>

extern "C" {
#include <lua.h>
#include <lauxlib.h>
}

#include <algorithm>
#include <chrono>
#include <cmath>
#include <format>
#include <optional>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

namespace {
struct PointerListener {
    WP<IPointer> pointer;
    CHyprSignalListener motion;
};

std::vector<PointerListener> pointers;
SP<CEventLoopTimer> timer;
std::string edge;
double upward = 0;
CHyprSignalListener renderListener;

struct Reveal {
    float progress;
    CHyprColor backdrop;
    double padding;
    double radius;
    bool blur;
    double blurOpacity;
    double gap;
    std::chrono::steady_clock::time_point updated;
};
std::unordered_map<std::string, Reveal> reveals;

void damageOutput(const std::string& name) {
    for (const auto& monitor : State::monitorState()->monitors()) {
        if (monitor->m_name == name)
            g_pHyprRenderer->damageMonitor(monitor);
    }
}

int setReveal(lua_State* lua) {
    const char* monitor = luaL_checkstring(lua, 1);
    const double progress = luaL_checknumber(lua, 2);
    if (!std::isfinite(progress) || progress < 0 || progress > 1)
        return luaL_error(lua, "widget-edge: reveal progress must be between 0 and 1");
    if (progress == 0) {
        reveals.erase(monitor);
    } else {
        const double red = luaL_checknumber(lua, 3);
        const double green = luaL_checknumber(lua, 4);
        const double blue = luaL_checknumber(lua, 5);
        const double alpha = luaL_checknumber(lua, 6);
        const double padding = luaL_checknumber(lua, 7);
        const double radius = luaL_checknumber(lua, 8);
        luaL_checktype(lua, 9, LUA_TBOOLEAN);
        const bool blur = lua_toboolean(lua, 9);
        const double blurOpacity = luaL_checknumber(lua, 10);
        const double gap = luaL_checknumber(lua, 11);
        for (const double channel : {red, green, blue, alpha, blurOpacity}) {
            if (!std::isfinite(channel) || channel < 0 || channel > 1)
                return luaL_error(lua, "widget-edge: backdrop channels must be between 0 and 1");
        }
        if (!std::isfinite(padding) || padding < 0 || padding > 4096 || !std::isfinite(radius) || radius < 0 || radius > 4096
            || !std::isfinite(gap) || gap < 0 || gap > 4096)
            return luaL_error(lua, "widget-edge: padding, radius and gap must be between 0 and 4096");
        reveals[monitor] = {static_cast<float>(progress), CHyprColor(red, green, blue, alpha),
                           padding, radius, blur, blurOpacity, gap,
                           std::chrono::steady_clock::now()};
    }
    damageOutput(monitor);
    return 0;
}

PHLLS findLayer(PHLMONITOR monitor, const std::string& name) {
    for (const auto& layer : Desktop::layerState()->layers()) {
        if (layer->m_namespace == name && layer->m_monitor == monitor && layer->aliveAndVisible())
            return layer;
    }
    return nullptr;
}

std::optional<CBox> proctreeContent(PHLLS layer, PHLMONITOR monitor) {
    if (!layer || !layer->wlSurface()->resource())
        return std::nullopt;
    const auto bufferSize = layer->wlSurface()->resource()->m_current.bufferSize;
    auto visible = layer->wlSurface()->m_visibleRegion.copy();
    visible.intersect(CBox{{0, 0}, bufferSize});
    if (visible.empty() || bufferSize.x <= 0 || bufferSize.y <= 0)
        return std::nullopt;
    // Publish logical monitor coordinates, including the bar's reserved area exactly once.
    return visible.getExtents().scale(layer->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT) / bufferSize)
        .translate(layer->position(Desktop::View::IGeometric::GEOMETRIC_CURRENT) - monitor->m_position);
}

void publishBounds() {
    for (const auto& monitor : State::monitorState()->monitors()) {
        const auto bounds = proctreeContent(findLayer(monitor, "proctree"), monitor);
        const auto data = bounds ? std::format("{},{},{},{},{}", monitor->m_name, bounds->x, bounds->y, bounds->w, bounds->h)
                                 : monitor->m_name;
        g_pEventManager->postEvent({"widgetbounds", data});
    }
}

void drawBackdrop(const CBox& box, PHLMONITOR monitor, const Reveal& reveal, float fade) {
    const auto pixelBox = box.copy().scale(monitor->m_scale).round();
    const auto available = monitor->m_reservedArea.apply(CBox{0, 0, monitor->m_size.x, monitor->m_size.y}).scale(monitor->m_scale).round();
    // Rectangle blur paints a full-monitor texture using clipBox as its final scissor.
    // Restrict it to this widget while keeping translucent bars outside.
    const auto clip = pixelBox.intersection(available);
    if (clip.empty())
        return;
    CRectPassElement::SRectData backdrop;
    backdrop.box = pixelBox;
    backdrop.clipBox = clip;
    backdrop.color = reveal.backdrop.modifyA(reveal.backdrop.a * reveal.progress * fade);
    backdrop.round = std::lround(reveal.radius * monitor->m_scale);
    backdrop.blur = reveal.blur;
    backdrop.blurA = reveal.blurOpacity * reveal.progress * fade;
    g_pHyprRenderer->addPassElement(makeUnique<CRectPassElement>(backdrop));
}

void drawWidget(PHLLS layer, PHLMONITOR monitor, const Vector2D& position, float progress) {
    const auto surface = layer->wlSurface()->resource();
    if (!surface)
        return;
    const auto size = layer->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    CSurfacePassElement::SRenderData data;
    data.pMonitor = monitor;
    data.pos = position;
    data.w = size.x;
    data.h = size.y;
    data.pLS = layer;
    data.alpha = progress;
    data.fadeAlpha = layer->alpha()[Desktop::View::LS_ALPHA_FADE]->value();
    data.clipBox = monitor->m_reservedArea.apply(CBox{0, 0, monitor->m_size.x, monitor->m_size.y}).scale(monitor->m_scale).round();
    if (data.clipBox.empty())
        return;
    surface->breadthfirst([&](SP<CWLSurfaceResource> child, const Vector2D& offset, void*) {
        if (!child->m_current.texture || child->m_current.size.x < 1 || child->m_current.size.y < 1)
            return;
        data.surface = child;
        data.texture = child->m_current.texture;
        data.localPos = offset;
        data.mainSurface = child == surface;
        g_pHyprRenderer->addPassElement(makeUnique<CSurfacePassElement>(data));
        ++data.surfaceCounter;
    }, nullptr);
}

void renderWidgets(eRenderStage stage) {
    if (stage != RENDER_POST_WINDOWS || g_pSessionLockManager->isSessionLocked() || g_pHyprRenderer->m_bRenderingSnapshot)
        return;
    const auto monitor = g_pHyprRenderer->renderData().pMonitor.lock();
    if (!monitor)
        return;
    const auto reveal = reveals.find(monitor->m_name);
    if (reveal == reveals.end())
        return;
    const auto proctree = findLayer(monitor, "proctree");
    const auto content = proctreeContent(proctree, monitor);
    if (!content)
        return;
    const auto box = content->copy().expand(reveal->second.padding);
    drawBackdrop(box, monitor, reveal->second, proctree->alpha()[Desktop::View::LS_ALPHA_FADE]->value());
    drawWidget(proctree, monitor, proctree->position(Desktop::View::IGeometric::GEOMETRIC_CURRENT), reveal->second.progress);

    const auto limits = findLayer(monitor, "quickshell-ai-limits");
    if (!limits)
        return;
    const auto size = limits->size(Desktop::View::IGeometric::GEOMETRIC_CURRENT);
    // Place from this frame's proctree box, without waiting for the QML/Wayland geometry round trip.
    const CBox limitsBox{{box.x + box.w - size.x, box.y + box.h + reveal->second.gap}, size};
    drawBackdrop(limitsBox, monitor, reveal->second, limits->alpha()[Desktop::View::LS_ALPHA_FADE]->value());
    drawWidget(limits, monitor, limitsBox.pos() + monitor->m_position, reveal->second.progress);
}

std::string edgeMonitor() {
    if (g_pSessionLockManager->isSessionLocked() || g_pInputManager->isConstrained() || g_pInputManager->hasHeldButtons())
        return "";
    const auto pos = Pointer::mgr()->position();
    for (const auto& monitor : State::monitorState()->monitors()) {
        const auto origin = monitor->m_position;
        if (pos.x >= origin.x && pos.x < origin.x + monitor->m_size.x && pos.y >= origin.y && pos.y < origin.y + 1)
            return monitor->m_name;
    }
    return "";
}

bool updateEdge() {
    const auto next = edgeMonitor();
    if (edge == next)
        return false;
    edge = next;
    upward = 0;
    return true;
}

void syncPointers() {
    std::erase_if(pointers, [](const auto& entry) { return entry.pointer.expired(); });
    for (const auto& pointer : g_pInputManager->m_pointers) {
        if (std::ranges::any_of(pointers, [&](const auto& entry) { return entry.pointer.lock() == pointer; }))
            continue;
        pointers.push_back({pointer, pointer->m_pointerEvents.motion.listen([](const IPointer::SMotionEvent& event) {
            // The motion that reaches the edge is not pressure against it.
            if (!updateEdge() && !edge.empty())
                upward += -event.unaccel.y;
        })});
    }
}
}

APICALL EXPORT std::string PLUGIN_API_VERSION() {
    return HYPRLAND_API_VERSION;
}

APICALL EXPORT PLUGIN_DESCRIPTION_INFO PLUGIN_INIT(HANDLE handle) {
    if (std::string(__hyprland_api_get_hash()) != __hyprland_api_get_client_hash())
        throw std::runtime_error("widget-edge: Hyprland headers do not match the running compositor; rebuild after restarting Hyprland");

    if (!HyprlandAPI::addLuaFunction(handle, "widget_edge", "reveal", setReveal))
        throw std::runtime_error("widget-edge: could not register the reveal command");
    renderListener = Event::bus()->m_events.render.stage.listen(renderWidgets);
    syncPointers();
    timer = makeShared<CEventLoopTimer>(std::chrono::milliseconds(50), [](SP<CEventLoopTimer> self, void*) {
        syncPointers();
        updateEdge();
        publishBounds();
        const auto now = std::chrono::steady_clock::now();
        std::erase_if(reveals, [&](const auto& entry) {
            if (now - entry.second.updated < std::chrono::milliseconds(1500) && !g_pSessionLockManager->isSessionLocked())
                return false;
            damageOutput(entry.first);
            return true;
        });
        // A heartbeat also resets Quickshell after an unload, lock or monitor removal.
        g_pEventManager->postEvent({"widgetedge", edge + "," + std::to_string(upward)});
        upward = 0;
        self->updateTimeout(std::chrono::milliseconds(50));
    }, nullptr);
    g_pEventLoopManager->addTimer(timer);
    return {"widget-edge", "Top-edge gestures and aligned desktop widgets", "dotfiles", WIDGET_EDGE_BUILD};
}

APICALL EXPORT void PLUGIN_EXIT() {
    renderListener.reset();
    for (const auto& [monitor, reveal] : reveals)
        damageOutput(monitor);
    reveals.clear();
    for (const auto& monitor : State::monitorState()->monitors())
        g_pEventManager->postEvent({"widgetbounds", monitor->m_name});
    g_pEventLoopManager->removeTimer(timer);
    timer.reset();
    pointers.clear();
    edge.clear();
    upward = 0;
    g_pEventManager->postEvent({"widgetedge", ",0"});
}
