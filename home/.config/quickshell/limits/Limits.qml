import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

// The plugin draws both foreground widgets and their backdrops in the same render pass.
PanelWindow {
    id: limits
    required property var modelData
    readonly property var bounds: WidgetReveal.proctreeBounds[modelData.name]
    readonly property bool positioned: WidgetReveal.valid && WidgetReveal.ready && bounds !== undefined
    readonly property real padding: WidgetReveal.valid ? WidgetReveal.backdrop.padding : 0

    screen: modelData
    visible: positioned
    anchors { left: true; top: true }
    // Bounds already include the compositor's bar offset, so do not add an exclusive zone again.
    margins {
        left: limits.positioned ? Math.round(limits.bounds.x + limits.bounds.width + limits.padding - limits.width) : 0
        top: limits.positioned ? Math.round(limits.bounds.y + limits.bounds.height + limits.padding + WidgetReveal.config.gap) : 0
    }
    implicitWidth: 420 + padding * 2
    implicitHeight: content.implicitHeight + padding * 2
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    color: "transparent"
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-ai-limits"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Column {
        id: content

        x: limits.padding
        y: limits.padding
        width: parent.width - limits.padding * 2
        spacing: 6

        StyledText {
            text: "AI Limits"
            font.pixelSize: Theme.fontSize + 2
            font.weight: Font.DemiBold
        }

        Repeater {
            model: AiLimits.providers

            Column {
                id: provider
                required property var modelData
                width: content.width
                spacing: 6

                StyledText {
                    text: provider.modelData.name
                    color: Theme.primary
                    font.weight: Font.DemiBold
                }

                Repeater {
                    model: provider.modelData.accounts

                    Column {
                        id: account
                        required property var modelData
                        readonly property bool stale: AiLimits.stale(modelData.updated_at)
                            && modelData.windows.some(w => w.used_percent !== null)
                        readonly property string accountState: AiLimits.state(modelData)
                        readonly property string notice: accountState !== "Active" ? accountState : stale ? "Stale" : ""
                        width: provider.width
                        spacing: 2

                        Row {
                            width: parent.width
                            StyledText {
                                width: parent.width - state.implicitWidth
                                text: account.modelData.name
                                font.weight: Font.DemiBold
                                textFormat: Text.PlainText
                                wrapMode: Text.Wrap
                            }
                            StyledText {
                                id: state
                                text: account.notice
                                color: Theme.tertiary
                                font.pixelSize: Theme.fontSize - 1
                            }
                        }

                        Repeater {
                            model: account.modelData.windows
                            QuotaRow {
                                required property var modelData
                                width: account.width
                                quota: modelData
                                stale: account.stale || account.accountState !== "Active" || AiLimits.error !== ""
                            }
                        }

                        StyledText {
                            width: parent.width
                            text: "Last invoked: " + AiLimits.age(account.modelData.last_used_at)
                                + "   Cache miss: " + AiLimits.tokens(account.modelData.cache_miss_tokens)
                                + "   Cache hit: " + AiLimits.tokens(account.modelData.cache_hit_tokens) + " tokens"
                            color: Theme.textVariant
                            font.pixelSize: Theme.fontSize - 2
                            wrapMode: Text.Wrap
                        }
                    }
                }

                StyledText {
                    visible: provider.modelData.accounts.length === 0
                    text: AiLimits.loaded ? "No accounts" : "Loading..."
                    color: Theme.textVariant
                }
            }
        }

        StyledText {
            width: parent.width
            visible: AiLimits.error !== ""
            text: AiLimits.error
            textFormat: Text.PlainText
            color: Theme.error
            font.pixelSize: Theme.fontSize - 1
            wrapMode: Text.Wrap
        }

        StyledText {
            text: AiLimits.fetching ? "Fetching..." : "Fetch in: " + AiLimits.fetchInSeconds + "s"
            color: Theme.textVariant
            font.pixelSize: Theme.fontSize - 1
        }
    }

    component QuotaRow: Row {
        id: row
        required property var quota
        required property bool stale
        readonly property bool known: quota.used_percent !== null
        readonly property bool expired: quota.reset_at !== null && quota.reset_at <= AiLimits.now
        readonly property color tint: !known || stale || expired ? Theme.textVariant
            : quota.used_percent >= 90 ? Theme.error
            : quota.used_percent >= 75 ? Theme.tertiary : Theme.text

        StyledText {
            width: parent.width / 2
            text: row.quota.label + " used: " + (row.known ? Number(row.quota.used_percent.toFixed(1)) + "%" : "N/A")
            color: row.tint
            font.family: Theme.monoFont
        }
        StyledText {
            width: parent.width / 2
            text: "Reset in: " + AiLimits.reset(row.quota.reset_at)
            color: Theme.textVariant
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Theme.fontSize - 1
        }
    }
}
