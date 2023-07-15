# HPicker

Horizontal picker for SwiftUI. The selected item is centered.

![cover.gif](cover.gif)

# Feature

- Tap to select specific item.
- Swipe to select next/previous item.
- Haptic feedback

# Usage

```swift
// Struct which is passed to HPicker must conform to HPickeritem and Identifiable protocol.
enum Modes: String, CaseIterable, Identifiable, HPickerItem {
    case first = "First"
    case second = "Second"
    case third = "Third"

    var title: String {
        self.rawValue
    }

    var id: String {
        self.rawValue
    }
}

struct ContentView: View {
    @State var selected: Modes = .second

    var body: some View {
        // Initializer
        HPicker(items: Modes.allCases, selection: $selected)
    }
}
```