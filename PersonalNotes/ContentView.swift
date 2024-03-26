//
//  ContentView.swift
//  PersonalNotes
//
//  Created by Wahab on 24/03/2024.
//

import SwiftUI
import MediaPlayer

struct ContentView: View {
    
    
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var volObserver = VolumeObserver()
    @EnvironmentObject var speechToTxt:SpeechToText
    @State private var isRecording = false
    @State private var isShowSuccess = false
    @Environment(\.modelContext) var modelContext
    @State private var sortOrder = SortDescriptor(\Note.date, order: .reverse)
    
    
    var body: some View {
        NavigationStack {
            VStack {
                if isRecording {
                    Text("Recording....")
                        .foregroundColor(.red)
                    Text(speechToTxt.outputText)
                        .padding()
                    Spacer()
                    Button {
                        stopRecording()
                    } label: {
                        Text("Save")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 40)
                            .background(Color.green)
                            .cornerRadius(15)
                            .padding()
                    }.frame(width: 200, height: 40)
                    
                } else {
                    Text("Press Volume to start recording")
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: 300, height: 40)
                        .background(isRecording ? Color.blue : Color.red)
                        .cornerRadius(15)
                        .padding()
                        .onTapGesture {
                            startRecording()
                        }
                }
            }
            .navigationTitle("Personal Notes")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    //NavigationLink("All Notes", destination: AllNotesView(sort: sortOrder ,searchString: ""))
                    NavigationLink("All Notes", destination: AllNotesView())
                    
                }
            }
            .alert("Your note saved successfully!", isPresented: $isShowSuccess) {
            }

        }
        .onAppear{
            volObserver.subscribe()
        }
        .onChange(of: volObserver.pressVolume) { _, newValue in
            if newValue{
                if isRecording == false{
                    startRecording()
                }
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                print("Active")
                volObserver.subscribe()
            } else if newPhase == .inactive {
                print("Inactive")
                volObserver.unsubscribe()
            } else if newPhase == .background {
                print("Background")
                //self.speechToTxt.stopRecording()
                //isRecording = false
                volObserver.unsubscribe()
            }
        }
    }
    

}


#Preview {
    ContentView().environmentObject(SpeechToText())
}

//MARK: - Recordings
extension ContentView{
    
    func startRecording(){
        print("startRecording")
        volObserver.unsubscribe()
        isRecording = true
        self.speechToTxt.startRecording()
    }
    
    func stopRecording(){
        if speechToTxt.outputText.isEmpty == false{
            let newNote = Note(transcript: speechToTxt.outputText, date: Date())
            modelContext.insert(newNote)
            try? modelContext.save()
        }
        self.speechToTxt.stopRecording()
        isRecording = false
        isShowSuccess = true
        /// again subscribe for volume button pressed
        volObserver.subscribe()
    }
}
