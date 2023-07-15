import SwiftUI

public protocol HPickerItem {
    var title: String { get }
}

public struct HPicker<PickerItem>: View
    where PickerItem: HPickerItem & Identifiable & Hashable {

    // MARK: - init
    @Binding var selection: PickerItem
    let items: [PickerItem]

    public init(
        items: [PickerItem], selection: Binding<PickerItem>,
        @ViewBuilder content: ((PickerItem) -> some View)) {
        self.items = items
        self._selection = selection
    }

    // MARK: - metrics

    @State private var itemXOffsets = [PickerItem: CGFloat]()
    @State private var itemWidths = [PickerItem: CGFloat]()
    private let itemGap = CGFloat(35)

    private func xPosition(of item: PickerItem) -> CGFloat {
        let itemXOffset = itemXOffsets[item] ?? .zero
        let selectionItemXOffset = itemXOffsets[selection] ?? .zero

        return itemXOffset - selectionItemXOffset
    }

    private func calculateItemPositions() {
        items.forEach { item in
            guard let itemIndex = items.firstIndex(of: item) else {
                itemXOffsets.updateValue(.zero, forKey: item)
                return
            }

            let itemsFromFirst = items[0...itemIndex]
            var distanceFromItemToThisItem =
            itemsFromFirst.enumerated()
                .map {
                    if itemsFromFirst.count == 1 {
                        return CGFloat(0)
                    }

                    // itemWidthsには、各ItemViewによってサイズが格納されている
                    guard let itemWidth = itemWidths[$0.element] else {
                        return CGFloat(0)
                    }

                    let indices = itemsFromFirst.indices
                    if $0.offset == indices.first! || $0.offset == indices.last! {
                        return itemWidth / 2
                    }

                    return itemWidth
                }
                .reduce(CGFloat(0)) { partialResult, itemWidth in
                    partialResult + itemWidth
                }
            distanceFromItemToThisItem += itemGap * CGFloat(itemsFromFirst.count - 1)

            itemXOffsets.updateValue(
                distanceFromItemToThisItem, forKey: item
            )
        }
    }

    // MARK: - view

    @State private var isModeChangeEventFired = false

    public var body: some View {
        GeometryReader { proxy in
            ForEach(items) { item in
                HPickerItemView(
                    item: item,
                    isSelected: item == selection,
                    itemWidths: $itemWidths
                )
                .position(.init(
                    x: xPosition(of: item),
                    y: proxy.size.height / 2
                ))
                .onTapGesture {
                    updateSelection(to: item)
                }
            }
            .offset(x: proxy.size.width / 2)
            .onChange(of: itemWidths) { _ in
                calculateItemPositions()
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard !isModeChangeEventFired else {
                        return
                    }

                    if value.translation.width > 100 {
                        selectPreviousItem()
                        isModeChangeEventFired = true
                    }

                    if value.translation.width < -100 {
                        selectNextItem()
                        isModeChangeEventFired = true
                    }
                }
                .onEnded { _ in
                    isModeChangeEventFired = false
                }
        )
    }

    private func updateSelection(to item: PickerItem) {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()

        withAnimation {
            selection = item
        }
    }

    private func selectPreviousItem() {
        if let index = items.firstIndex(of: selection),
            index != items.indices.first!
        {
            updateSelection(to: items[index - 1])
        }
    }

    private func selectNextItem() {
        if let index = items.firstIndex(of: selection),
            index != items.indices.last!
        {
            updateSelection(to: items[index + 1])
        }
    }
}

struct HPickerItemView<PickerItem>: View
    where PickerItem: HPickerItem & Identifiable & Hashable {

    let item: PickerItem
    let isSelected: Bool
    @Binding var itemWidths: [PickerItem: CGFloat]

    var body: some View {
        Text(item.title)
            .background {
                GeometryReader { proxy in
                    Rectangle()
                        .fill(.clear)
                        .onAppear {
                            itemWidths.updateValue(proxy.size.width, forKey: item)
                        }
                }
            }
            .foregroundColor(isSelected ? .accentColor : .primary)
            .font(.system(size: 15).bold())
    }
}
