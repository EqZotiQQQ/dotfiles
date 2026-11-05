#include <hyprutils/math/Box.hpp>
#include <cassert>
#include <cmath>
#include <iostream>
#include <memory>
#include <vector>

using Hyprutils::Math::CBox;
using Hyprutils::Math::Vector2D;
template <typename T> using SP = std::shared_ptr<T>;
template <typename T> using UP = std::unique_ptr<T>;
template <typename T, typename... Args> auto makeUnique(Args&&... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}

struct ReservedArea {
    CBox area;
    CBox apply(const CBox&) const { return area; }
};
struct Monitor {
    Vector2D m_size;
    double m_scale;
    ReservedArea m_reservedArea;
};
using PHLMONITOR = SP<Monitor>;

struct Color {
    float a = 1;
    Color modifyA(float alpha) const { return {alpha}; }
};
struct Reveal {
    float progress = 0.5;
    Color backdrop;
    double radius = 18;
    bool blur = true;
    double blurOpacity = 0.35;
};

struct CWLSurfaceResource {
    struct {
        bool texture = true;
        Vector2D size = {1920, 1080};
    } m_current;
    SP<CWLSurfaceResource> resource() { return SP<CWLSurfaceResource>(this, [](auto*) {}); }
    template <typename Callback> void breadthfirst(Callback callback, void* data) {
        callback(resource(), Vector2D{}, data);
    }
};
namespace Desktop::View {
struct IGeometric { enum { GEOMETRIC_CURRENT }; };
enum { LS_ALPHA_FADE };
}
struct Fade {
    float value() const { return 1; }
};
struct Layer {
    SP<CWLSurfaceResource> surface = std::make_shared<CWLSurfaceResource>();
    std::vector<SP<Fade>> fades = {std::make_shared<Fade>()};
    auto wlSurface() { return surface; }
    auto size(int) { return surface->m_current.size; }
    auto& alpha() { return fades; }
};
using PHLLS = SP<Layer>;

struct CRectPassElement {
    struct SRectData {
        CBox box, clipBox;
        Color color;
        int round = 0;
        bool blur = false;
        float blurA = 0;
    };
    SRectData data;
    explicit CRectPassElement(const SRectData& value) : data(value) {}
};
struct CSurfacePassElement {
    struct SRenderData {
        PHLMONITOR pMonitor;
        Vector2D pos, localPos;
        double w = 0, h = 0;
        PHLLS pLS;
        float alpha = 1, fadeAlpha = 1;
        CBox clipBox;
        SP<CWLSurfaceResource> surface;
        bool texture = false, mainSurface = true;
        int surfaceCounter = 0;
    };
    SRenderData data;
    explicit CSurfacePassElement(const SRenderData& value) : data(value) {}
};
struct Renderer {
    std::vector<CBox> clips;
    void addPassElement(UP<CRectPassElement> pass) {
        assert(pass->data.blur);
        clips.push_back(pass->data.clipBox);
    }
    void addPassElement(UP<CSurfacePassElement> pass) {
        assert(pass->data.pos == Vector2D(1920, 200));
        clips.push_back(pass->data.clipBox);
    }
};
auto g_pHyprRenderer = std::make_unique<Renderer>();

// WIDGET_EDGE_DRAW_FUNCTIONS

void checkClip(Vector2D size, double scale, CBox available, CBox expected) {
    auto monitor = std::make_shared<Monitor>(Monitor{size, scale, {available}});
    auto layer = std::make_shared<Layer>();
    g_pHyprRenderer->clips.clear();
    drawBackdrop(CBox{0, 0, size.x, size.y}, monitor, Reveal{}, 1);
    drawWidget(layer, monitor, Vector2D{1920, 200}, 0.5);
    if (expected.empty()) {
        assert(g_pHyprRenderer->clips.empty());
        return;
    }
    assert(g_pHyprRenderer->clips.size() == 2);
    for (const auto& clip : g_pHyprRenderer->clips) {
        // An empty clip disables clipping in Hyprland.
        assert(!clip.empty());
        assert(clip == expected);
    }
}

void checkBackdropClip(double scale, CBox available, CBox widget, CBox expected) {
    auto monitor = std::make_shared<Monitor>(Monitor{{1920, 1080}, scale, {available}});
    g_pHyprRenderer->clips.clear();
    drawBackdrop(widget, monitor, Reveal{}, 1);
    if (expected.empty()) {
        assert(g_pHyprRenderer->clips.empty());
        return;
    }
    assert(g_pHyprRenderer->clips.size() == 1);
    // Hyprland scissors its full-monitor blur texture to this region, including undamaged pixels.
    assert(g_pHyprRenderer->clips[0] == expected);
}

int main() {
    checkClip({1920, 1080}, 1, {0, 40, 1920, 1040}, {0, 40, 1920, 1040});
    checkClip({1920, 1080}, 1.5, {0, 0, 1920, 1040}, {0, 0, 2880, 1560});
    checkClip({1280, 720}, 2, {48, 0, 1232, 720}, {96, 0, 2464, 1440});
    checkClip({1920, 1080}, 1.25, {0, 0, 1880, 1080}, {0, 0, 2350, 1350});
    checkClip({1920, 1080}, 1.5, {0, 0, 1920, 1080}, {0, 0, 2880, 1620});
    checkClip({1920, 40}, 1, {0, 40, 1920, 0}, {});
    checkBackdropClip(1, {0, 40, 1920, 1040}, {1200, 60, 600, 500}, {1200, 60, 600, 500});
    checkBackdropClip(1, {0, 40, 1920, 1040}, {1460, 580, 440, 400}, {1460, 580, 440, 400});
    checkBackdropClip(1.5, {0, 40, 1920, 1040}, {900, 20, 300, 180}, {1350, 60, 450, 240});
    checkBackdropClip(2, {48, 0, 1872, 1080}, {20, 100, 200, 150}, {96, 200, 344, 300});
    checkBackdropClip(1, {0, 40, 1920, 1040}, {0, 0, 300, 30}, {});
    checkBackdropClip(1, {0, 40, 1920, 1040}, {2000, 200, 100, 100}, {});
    std::cout << "WIDGET_CLIP_CHECK_PASSED\n";
}
