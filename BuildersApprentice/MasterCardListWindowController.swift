//
//  MasterCardListWindowController.swift
//  BuildersApprentice
//
//  Created by Steve Baker on 9/13/15.
//  Copyright © 2015 Steve Baker. All rights reserved.
//

import Cocoa
import GRDB

class MasterCardListWindowController: NSWindowController {

  // List Display
  dynamic var displayText: NSAttributedString = NSAttributedString(string: "")
  @IBOutlet var textView: NSTextView!

  // List Data
  var cardLists = [String:[String:Bool]]()

  override var windowNibName: String? {
    return "MasterCardListWindowController"
  }

  // Generate a type name based on the type components we care about
  private func getNormalizedCardType(type: String) -> String {
    var typeName = ""
    let typeComponents = type.componentsSeparatedByString(" ")
    var hyphen = false
    for component in typeComponents {
      if component == "" {
        continue
      }
      if component == "-" {
        hyphen = true
        continue
      }
      var validComponent: String? = nil
      if hyphen {
        // Use only these subtypes
        if component == "Aura" || component == "Equipment" {
          validComponent = component
        }
      }
      else {
        if component == "Summon" {
          validComponent = "Creature"
        }
        else if component == "Interrupt" {
          validComponent = "Instant"
        }
        // Ignore these supertypes
        else if component == "Legendary" || component == "Snow" || component == "World" || component == "Ongoing" {
        }
        else {
          validComponent = component
        }
      }
      if let name = validComponent {
        typeName += " \(name)"
      }
    }
    return typeName
  }

  private func getNormalizedCardColor(row: Row) -> String {
    var cardColor: String? = nil

    for color in ["Black", "Blue", "Green", "Red", "White"] {
      let c: Bool = row.value(named: "is\(color.lowercaseString)")!
      if c {
        if cardColor == nil {
          cardColor = color
        }
        else {
          cardColor = "Multicolor"
          break
        }
      }
    }
    if cardColor == nil {
      cardColor = "Colorless"
    }

    return cardColor!
  }

  private func getListAndCardNames(row: Row) -> (listName: String, cardName: String) {
    let cardName: String = row.value(named: "cardname")!
    let cardType: String = getNormalizedCardType(row.value(named: "cardtype")!)
    let cardColor: String = getNormalizedCardColor(row)
    let listName = "\(cardColor)\(cardType)"
    return (listName, cardName)
  }

  private func getDbPath() -> String {
      return "/Users/steve/Library/Containers/com.deckedbuilder.deckedbuilder/Data/Library/com.deckedbuilder.deckedbuilder/dbdir-54/cards.sqlite"
  }

  private func generateCardLists() -> [String:[String:Bool]] {
    do {
      let dbq = try DatabaseQueue(path: getDbPath())
      let rows = dbq.inDatabase { db in
        return Row.fetchAll(db, "SELECT cardname, cardtype, isblue, isblack, iswhite, isgreen, isred FROM card ORDER BY cardname COLLATE NOCASE")
      }
      for row in rows {
        let listAndCardNames = getListAndCardNames(row)
        if cardLists[listAndCardNames.listName] == nil {
          cardLists[listAndCardNames.listName] = [String: Bool]()
        }
        cardLists[listAndCardNames.listName]![listAndCardNames.cardName] = true
      }
    }
    catch {
      print("Database error:")
      return cardLists
    }

    return cardLists
  }

  private func clearCardListView() {
    displayText = NSAttributedString(string: "")
  }

  private func appendToCardListView(textToAdd: String) {
    let mutableText = displayText.mutableCopy() as! NSMutableAttributedString
    mutableText.appendAttributedString(NSAttributedString(string: textToAdd))
    displayText = mutableText.copy() as! NSAttributedString
  }

  private func displayCardLists() {
    clearCardListView()
    let listNames = Array(cardLists.keys).sort(<)
    for listName in listNames {
      var textToAdd = "\n[\(listName)]\n"
      let cardNames = Array(cardLists[listName]!.keys).sort(<)
      for cardName in cardNames {
        textToAdd += "\(cardName)\n"
      }
      appendToCardListView(textToAdd)
    }
  }

  override func windowDidLoad() {
    super.windowDidLoad()

    generateCardLists()
    displayCardLists()
  }

  private func writeMasterCardListsToFiles(directoryUrl: NSURL) {
    let listNames = Array(self.cardLists.keys).sort(<)
    for listName in listNames {
      let fileUrl = directoryUrl.URLByAppendingPathComponent("mtglist \(listName).txt")
      let cardNames = Array(self.cardLists[listName]!.keys).sort(<)
      do {
        try (cardNames.joinWithSeparator("\n") + "\n").writeToURL(fileUrl, atomically: true, encoding: NSUTF8StringEncoding)
      }
      catch let error as NSError {
        let alert = NSAlert()
        alert.messageText = "Error writing file: \(error)"
        alert.addButtonWithTitle("OK")
        alert.runModal()
        return
      }
    }
  }

  @IBAction func saveMasterCardLists(sender: NSMenuItem) {
    let savePanel = NSOpenPanel()
    savePanel.canCreateDirectories = true
    savePanel.canChooseDirectories = true
    savePanel.canChooseFiles = false
    savePanel.allowsMultipleSelection = false
    savePanel.prompt = "Save"
    savePanel.beginSheetModalForWindow(window!, completionHandler: {
      [unowned savePanel] (result) in
      if result == NSModalResponseOK {
        if savePanel.URLs.count != 1 {
          let alert = NSAlert()
          alert.messageText = "No Directory Chosen"
          alert.addButtonWithTitle("OK")
          alert.runModal()
          return
        }
        let directoryUrl = savePanel.URLs[0]
        self.writeMasterCardListsToFiles(directoryUrl)
      }
    })
  }
}

