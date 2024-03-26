//
//  AllNotesView.swift
//  PersonalNotes
//
//  Created by Wahab on 24/03/2024.
//

import SwiftUI
import SwiftData

struct AllNotesView: View {

    @Environment(\.modelContext) var modelContext
    @State private var searchText = ""
    @Query(sort: \Note.date, order: .reverse) var notes: [Note]
    @State var gptResponse:String = ""
    
     /*
     @Query(filter: #Predicate<Note>{ note in
         note.transcript.localizedStandardContains("hello j")
     }, sort: \Note.date, order: .reverse) var notes: [Note]
     */
    
    //@Query private var notes: [Note]
    
    /*
    init(sort: SortDescriptor<Note>, searchString: String) {
        _notes = Query(filter: #Predicate<Note>{ note in
            note.transcript.contains(searchString)
        }, sort: [sort])
    }
    */
    
  var dateFormatter: DateFormatter {
      let formatter = DateFormatter()
      formatter.dateStyle = .full
      formatter.timeStyle = .medium
      return formatter
  }
    /*
    var filtered:[Note]?{
        try? notes.filter(#Predicate {
            if searchText.isEmpty {
                return true
            } else {
                return $0.transcript.localizedStandardContains(searchText)
            }
        })
    }*/
    
    var filtered: [Note]? {
        if searchText.isEmpty {
            return notes
        } else if gptResponse.isEmpty {
            return notes.filter { $0.transcript.localizedStandardContains(searchText) }
        }else {
            var matchedNotes = [Note]()
            let lines = gptResponse.components(separatedBy: "\n")
            for item in lines{
                let sblist = notes.filter { $0.transcript.localizedStandardContains(item) }
                matchedNotes.append(contentsOf: sblist)
            }
            
            return matchedNotes
        }
    }

    var body: some View {
      NavigationStack {
        List {
          ForEach(filtered ?? []) { note in
            VStack(alignment: .leading, spacing: 12) {
              Text(note.transcript)
                .font(.headline)
              Text("Created at: \(dateFormatter.string(from: note.date))")
                .font(.subheadline)
            }
            .padding()
          }
        }
        .listStyle(.plain)
        .navigationTitle("Notes")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "Search notes")
        .overlay{
            if filtered?.isEmpty == true{
                ContentUnavailableView.search
            }
        }
        .onChange(of: searchText) { _ , newValue in
            Task{
                var textNotes = [String]()
                for item in notes{
                    textNotes.append(item.transcript)
                }
                let prompt = "\(textNotes.joined(separator: "\n"))\nSearch: \(newValue)"
                //hamaad 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
                let api = ChatGPTAPI(apiKey: "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")
                let stream = try await api.sendMessage(prompt)
                self.gptResponse = stream
                print("stream=", stream)
            }
        }
        
      }
     
    }
}
