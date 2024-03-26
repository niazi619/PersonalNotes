//
//  Note.swift
//  PersonalNotes
//
//  Created by Wahab on 24/03/2024.
//

import Foundation
import SwiftData

@Model
class Note {
  var transcript: String!
    var date: Date!

  init(transcript: String, date: Date) {
    self.transcript = transcript
    self.date = date
  }
}
