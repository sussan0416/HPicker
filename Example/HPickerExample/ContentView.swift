//
//  ContentView.swift
//  HPickerExample
//
//  Created by 鈴木孝宏 on 2023/07/12.
//
import HPicker
import SwiftUI

enum Modes: String, CaseIterable, Identifiable, HPickerItem {
    case a = "First"
    case b = "Second"
    case c = "Third"
    case d = "Fourth"
    case f = "Fifth"
    case g = "Sixth"

    var title: String {
        self.rawValue
    }

    var id: String {
        self.rawValue
    }
}

struct ContentView: View {
    @State var selected: Modes = .c

    var body: some View {
        HPicker(items: Modes.allCases, selection: $selected)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
