
import Foundation

class Note {
  var contents: String
  let timestamp: Date
  
  // an automatically generated note title, based on the first line of the note
  var title: String {
    // split into lines
    let lines = contents.components(separatedBy: .newlines) 
    // return the first
    return lines[0]
  }
  
  init(text: String) {
    contents = text
    timestamp = Date()
  }
  
}




