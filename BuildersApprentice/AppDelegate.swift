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

  var masterCardListWindowController: MasterCardListWindowController?

  func applicationDidFinishLaunching(aNotification: NSNotification) {
    let masterCardListWindowController = MasterCardListWindowController()
    self.masterCardListWindowController = masterCardListWindowController
    self.masterCardListWindowController!.showWindow(self)
  }

  func applicationWillTerminate(aNotification: NSNotification) {
    // Insert code here to tear down your application
  }


}

