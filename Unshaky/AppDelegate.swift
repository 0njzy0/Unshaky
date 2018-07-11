//
//  AppDelegate.swift
//  Unshaky
//
//  Created by Xinhong LIU on 2018-06-21.
//  Copyright © 2018 Nested Error. All rights reserved.
//

import Cocoa
import ServiceManagement

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    let defaults = UserDefaults.standard
    @IBOutlet weak var menu: NSMenu!
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    @IBOutlet weak var window: NSWindow!
    private var shakyPressPreventer : ShakyPressPreventer
    @IBOutlet weak var dismissShakyPressCountMenuItem: NSMenuItem!
    @IBOutlet weak var preferenceMenuItem: NSMenuItem!
    
    private var dismissCount = 0
    
    override init() {
        shakyPressPreventer = ShakyPressPreventer.sharedInstance()
        super.init()
        if (!shakyPressPreventer.setupInputDeviceListener()) {
            let alert = NSAlert()
            alert.messageText = "You have to go to: System Preferences -> Security & Privacy -> Privacy (Tab) -> Accessibility (Left panel) and then add the Unshaky.app."
            alert.runModal()
            NSApplication.shared.terminate(self)
        }
        shakyPressPreventer.shakyPressDismissed {
            self.dismissCount += 1
            OperationQueue.main.addOperation {
                self.updateDismissCountLabel()
            }
        }
    }
    
    @IBAction func quitClicked(_ sender: Any) {
        NSApplication.shared.terminate(self)
    }
    
    func updateDismissCountLabel() {
        dismissShakyPressCountMenuItem.title = "Dismiss shaky key \(dismissCount) times"
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let icon = NSImage(named: NSImage.Name(rawValue: "UnshakyTemplate"))
        statusItem.image = icon
        
        statusItem.menu = menu
        
        dismissCount = defaults.integer(forKey: "DISMISS_COUNT")
        updateDismissCountLabel()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        defaults.set(dismissCount, forKey: "DISMISS_COUNT")
        defaults.synchronize()
    }
    
    //
    // DEBUG Function
    //

    @IBAction func debugClicked(_ sender: Any) {
        let windowStyleMaskRawValue = NSWindow.StyleMask.closable.rawValue | NSWindow.StyleMask.titled.rawValue | NSWindow.StyleMask.resizable.rawValue
        let windowFrame = NSMakeRect(100, 100, 400, 400)
        let window = NSWindow(contentRect: windowFrame, styleMask: .init(rawValue: windowStyleMaskRawValue), backing: .buffered, defer: false)
        _ = NSWindowController(window: window)
        
        // scroll view
        let scrollView = NSScrollView(frame: windowFrame)
        scrollView.hasVerticalScroller = true
        let scrollViewContentSize = scrollView.contentSize
        
        // text vieww
        let textView = NSTextView(frame: NSMakeRect(0, 0, scrollViewContentSize.width, scrollViewContentSize.height))
        textView.isEditable = false
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        
        scrollView.documentView = textView
        window.contentView = scrollView
        window.orderFrontRegardless()
        shakyPressPreventer.debugTextView = textView
    }
    
    //
    // Preference
    //
    @IBAction func preferenceClicked(_ sender: Any) {
        // prevent multiple preference windows
        for window in NSApplication.shared.windows {
            if window.title == "Unshaky Preference" {
                NSApp.activate(ignoringOtherApps: true)
                return
            }
        }
        
        let preferencePanelStoryboard = NSStoryboard(name: NSStoryboard.Name(rawValue: "Preference"), bundle: nil)
        let preferenceWindowController = preferencePanelStoryboard.instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "Preference")) as! NSWindowController
        preferenceWindowController.showWindow(self)
        NSApp.activate(ignoringOtherApps: true)
    }
    
}
