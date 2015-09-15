//
//  AppDelegate.swift
//  BuildersApprentice
//
//  Created by Steve Baker on 9/13/15.
//  Copyright © 2015 Steve Baker. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

  @IBOutlet weak var window: NSWindow!

  var masterCardListWindowController: MasterCardListWindowController? = nil

  func applicationDidFinishLaunching(aNotification: NSNotification) {

  }

  func applicationWillTerminate(aNotification: NSNotification) {

  }

  @IBAction func showMasterCardList(sender: AnyObject?) {
    if masterCardListWindowController == nil {
      let masterCardListWindowController = MasterCardListWindowController()
      self.masterCardListWindowController = masterCardListWindowController
    }
    self.masterCardListWindowController!.showWindow(self)
  }

}

