//
//  VolumeObserver.swift
//  PersonalNotes
//
//  Created by Wahab on 24/03/2024.
//

import Foundation
import MediaPlayer

final class VolumeObserver: ObservableObject {

    @Published var pressVolume: Bool = false
    // Audio session object
    private let session = AVAudioSession.sharedInstance()

    // Observer
    private var progressObserver: NSKeyValueObservation!

    func subscribe() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("cannot activate session")
        }
        var initialObservation = true
        progressObserver = session.observe(\.outputVolume) { [self] (session, value) in
            if initialObservation {
                initialObservation = false
                return
            }
            DispatchQueue.main.async {
                self.pressVolume = true
                print("outputVolume")
            }
        }
    }

    func unsubscribe() {
      do {
          //try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
          try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.record)
          self.progressObserver.invalidate()
          self.pressVolume = false
      } catch {
          print("cannot activate session")
      }

    }

    init() {
        subscribe()
    }
}
