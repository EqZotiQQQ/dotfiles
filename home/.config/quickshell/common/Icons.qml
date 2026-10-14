pragma Singleton

import Quickshell

// Nerd Font (Material Design) glyphs, drawn with Theme.iconFont
Singleton {
    readonly property string cpu: String.fromCodePoint(0xF0EE0)
    readonly property string thermometer: String.fromCodePoint(0xF050F)
    readonly property string memory: String.fromCodePoint(0xF035B)
    readonly property string volumeHigh: String.fromCodePoint(0xF057E)
    readonly property string volumeMedium: String.fromCodePoint(0xF0580)
    readonly property string volumeLow: String.fromCodePoint(0xF057F)
    readonly property string volumeMute: String.fromCodePoint(0xF075F)
    readonly property string ethernet: String.fromCodePoint(0xF0200)
    readonly property string wifi: String.fromCodePoint(0xF0928)
    readonly property string wifiOff: String.fromCodePoint(0xF05AA)
    // signal, 0–4 bars; with a lock for a network that takes a password
    readonly property var wifiStrength: [0xF092F, 0xF091F, 0xF0922, 0xF0925, 0xF0928].map(c => String.fromCodePoint(c))
    readonly property var wifiStrengthLock: [0xF092C, 0xF0921, 0xF0924, 0xF0927, 0xF092A].map(c => String.fromCodePoint(c))
    readonly property string offline: String.fromCodePoint(0xF0319)
    readonly property string bell: String.fromCodePoint(0xF009A)
    readonly property string bellOff: String.fromCodePoint(0xF009B)
    readonly property string history: String.fromCodePoint(0xF02DA)
    readonly property string close: String.fromCodePoint(0xF0156)
    readonly property string power: String.fromCodePoint(0xF0425)
    readonly property string lock: String.fromCodePoint(0xF033E)
    readonly property string sleep: String.fromCodePoint(0xF04B2)
    readonly property string logout: String.fromCodePoint(0xF0343)
    readonly property string restart: String.fromCodePoint(0xF0709)
    readonly property string chevronLeft: String.fromCodePoint(0xF0141)
    readonly property string chevronRight: String.fromCodePoint(0xF0142)
    readonly property string music: String.fromCodePoint(0xF075A)
    readonly property string play: String.fromCodePoint(0xF040A)
    readonly property string pause: String.fromCodePoint(0xF03E4)
    readonly property string skipNext: String.fromCodePoint(0xF04AD)
    readonly property string skipPrevious: String.fromCodePoint(0xF04AE)
    readonly property string shuffle: String.fromCodePoint(0xF049D)
    readonly property string repeat: String.fromCodePoint(0xF0456)
    readonly property string repeatOnce: String.fromCodePoint(0xF0458)
    readonly property string checkboxOn: String.fromCodePoint(0xF0132)
    readonly property string checkboxOff: String.fromCodePoint(0xF0131)
    readonly property string radioOn: String.fromCodePoint(0xF043E)
    readonly property string radioOff: String.fromCodePoint(0xF043D)
}
