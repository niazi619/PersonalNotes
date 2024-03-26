//
//  PersonalNotesApp.swift
//  PersonalNotes
//
//  Created by Wahab on 24/03/2024.
//

import SwiftUI
import SwiftData

@main
struct PersonalNotesApp: App {
    
    let modelContainer: ModelContainer
        
        init() {
            do {
                modelContainer = try ModelContainer(for: Note.self)
            } catch {
                fatalError("Could not initialize ModelContainer")
            }
        }
    
    var body: some Scene {
        WindowGroup {
          ContentView().environmentObject(SpeechToText())
        }
        .modelContainer(modelContainer)
    }
}
