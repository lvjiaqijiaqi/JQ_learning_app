//
//  JQ_learningToolApp.swift
//  JQ_learningTool
//
//  Created by lvjiaqi on 10/15/24.
//

import SwiftUI
import SwiftData

@main
struct JQ_learningToolApp: App {
    var body: some Scene {
        WindowGroup {
            JQ_ContentView()
        }
        .modelContainer(for: JQ_Note.self)
    }
}
