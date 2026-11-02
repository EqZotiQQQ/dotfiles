import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

// Desktop layer: no reserved space, no focus, all clicks pass through.
PanelWindow {
    required property var modelData

    screen: modelData
    anchors { right: true; top: true }
    // Proctree's panels end at y=550; leave 20px below and match their right inset.
    margins { right: 20; top: 570 }
    implicitWidth: 320
    implicitHeight: content.implicitHeight + 28
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    color: "transparent"
    mask: Region {}
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "quickshell-ai-limits"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    Rectangle {
        anchors.fill: parent
        radius: Theme.tileRadius
        color: Theme.panel
        border.width: 1
        border.color: Theme.alpha(Theme.outlineVariant, 0.5)
    }

    Column {
        id: content

        x: 14
        y: 14
        width: parent.width - 28
        spacing: 12

        Row {
            width: parent.width

            StyledText {
                width: parent.width - provider.implicitWidth
                text: "Лимиты ИИ"
                font.pixelSize: Theme.fontSize + 2
                font.weight: Font.DemiBold
            }
            StyledText {
                id: provider

                text: "Codex · осталось"
                color: Theme.textVariant
            }
        }

        Repeater {
            model: AiLimits.accounts

            Column {
                id: account

                required property var modelData
                readonly property bool stale: AiLimits.stale(modelData.updated_at)
                readonly property bool unavailable: modelData.status !== "active" || !modelData.schedulable

                width: content.width
                spacing: 6

                Row {
                    width: parent.width

                    StyledText {
                        width: parent.width - state.implicitWidth - 8
                        text: account.modelData.name
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        font.weight: Font.DemiBold
                    }
                    StyledText {
                        id: state

                        text: account.unavailable ? "недоступен" : "#" + account.modelData.id
                        color: account.unavailable ? Theme.error : Theme.textVariant
                    }
                }

                Repeater {
                    model: account.modelData.windows

                    QuotaRow {
                        required property var modelData

                        width: account.width
                        quota: modelData
                        stale: account.stale || account.unavailable || AiLimits.error !== ""
                    }
                }

                StyledText {
                    width: parent.width
                    text: (account.stale ? "Устарело · " : "Снимок · ") + AiLimits.age(account.modelData.updated_at)
                    color: account.stale ? Theme.tertiary : Theme.textVariant
                    font.pixelSize: Theme.fontSize - 1
                    elide: Text.ElideRight
                }
            }
        }

        StyledText {
            width: parent.width
            visible: AiLimits.error !== "" || AiLimits.accounts.length === 0
            text: AiLimits.error !== "" ? AiLimits.error
                : AiLimits.loaded ? "Нет аккаунтов Codex" : "Получаем квоты…"
            textFormat: Text.PlainText
            color: AiLimits.error !== "" ? Theme.error : Theme.textVariant
            wrapMode: Text.Wrap
        }
    }

    component QuotaRow: Column {
        id: row

        required property var quota
        required property bool stale
        readonly property bool known: quota.remaining_percent !== null
        readonly property bool expired: quota.reset_at !== null && quota.reset_at <= AiLimits.now
        readonly property color tint: !known || stale || expired ? Theme.textVariant
            : quota.remaining_percent <= 10 ? Theme.error
            : quota.remaining_percent <= 25 ? Theme.tertiary : Theme.primary

        spacing: 3

        Row {
            width: parent.width

            StyledText {
                width: 34
                text: row.quota.label
                color: Theme.textVariant
            }
            StyledText {
                width: 58
                text: row.known ? Number(row.quota.remaining_percent.toFixed(1)) + "%" : "—"
                color: row.tint
                font.family: Theme.monoFont
            }
            StyledText {
                width: parent.width - 92
                text: row.known ? AiLimits.reset(row.quota.reset_at) : "нет данных"
                color: Theme.textVariant
                horizontalAlignment: Text.AlignRight
                font.pixelSize: Theme.fontSize - 1
                elide: Text.ElideRight
            }
        }

        Rectangle {
            width: parent.width
            height: 3
            radius: 1.5
            color: Theme.surfaceHigh

            Rectangle {
                width: parent.width * (row.known ? row.quota.remaining_percent / 100 : 0)
                height: parent.height
                radius: parent.radius
                color: row.tint
                opacity: row.stale || row.expired ? 0.45 : 1
            }
        }
    }
}
