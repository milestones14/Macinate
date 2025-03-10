import Cocoa
import SwiftUI
import ServiceManagement
import Combine

@main
struct MenuBarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Your usual scenes (e.g. a Settings window if needed)
        Settings {
            Text("Macinate Settings")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject, NSWindowDelegate {
    var statusItem: NSStatusItem?
    @Published var isRunning: Bool = false  // Tracks the caffeination status
    
    // Retain the process if caffeinate is running
    private var caffeinateProcess: Process?
    private var cancellables = Set<AnyCancellable>()
    var windowController: NSWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set the app to open at login if possible.
        setAppToOpenAtLoginIfNeeded()
        print((self as (any ObservableObject)).objectWillChange)
        print(self)
        // Create the menu bar item as usual …
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: isRunning ? "cup.and.saucer.fill" : "cup.and.saucer", accessibilityDescription: "Macinate")
            button.image?.isTemplate = true
        }
        
        let menu = NSMenu()
        
        // A single status item at the top
        let statusMenuItem = NSMenuItem(title: "Decaffeinated", action: nil, keyEquivalent: "")
        statusMenuItem.image = NSImage(systemSymbolName: "moon.zzz", accessibilityDescription: "Decaffeinated")
        statusMenuItem.isEnabled = false
        menu.addItem(statusMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Action item that toggles caffeination
        let actionMenuItem = NSMenuItem(title: "Caffeinate", action: #selector(toggleCaffeinate), keyEquivalent: "t")
        menu.addItem(actionMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Preferences", action: #selector(openSettingsWindow), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q"))
        statusItem?.menu = menu
        
        // Update the dynamic items when isRunning changes.
        $isRunning
            .receive(on: RunLoop.main)
            .sink { running in
                statusMenuItem.title = running ? "Caffeinated" : "Decaffeinated"
                statusMenuItem.image = NSImage(
                    systemSymbolName: running ? "sun.max" : "moon.zzz",
                    accessibilityDescription: running ? "Caffeinated" : "Decaffeinated"
                )
                actionMenuItem.title = running ? "Decaffeinate" : "Caffeinate"
                if let button = self.statusItem?.button {
                    button.image = NSImage(systemSymbolName: running ? "cup.and.saucer.fill" : "cup.and.saucer", accessibilityDescription: "Macinate")
                    button.image?.isTemplate = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func setAppToOpenAtLoginIfNeeded() {
        if #available(macOS 13.0, *) {
            do {
                // SMAppService.mainApp represents your main app as a login item.
                try SMAppService.mainApp.register()
                print("Successfully registered the app as a login item.")
            } catch {
                print("Failed to register as a login item: \(error)")
            }
        }
    }
    
    // MARK: - Menu Actions
    
    @objc func openSettingsWindow() {
            if windowController == nil {
                // Create the SwiftUI view, passing bindings for "Yes/No" text and icon type
                let contentView = SettingsView()

                let window = NSWindow(
                    contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                    styleMask: [.titled, .closable, .resizable],
                    backing: .buffered,
                    defer: false
                )
                window.title = "Settings"
                window.center()
                window.contentViewController = NSHostingController(rootView: contentView)
                window.delegate = self

                windowController = NSWindowController(window: window)
            }
            windowController?.showWindow(nil)
        }
    @objc func toggleCaffeinate() {
        if isRunning {
            decaffeinate()
        } else {
            caffeinate()
        }
    }
    
    private func caffeinate() {
        guard !isRunning else { return }
        let executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
        do {
            isRunning = true
            let process = Process()
            process.executableURL = executableURL
            process.arguments = ["-di"]
            try process.run()
            caffeinateProcess = process
        } catch {
            print("Failed to start caffeinate: \(error)")
            isRunning = false
        }
    }
    
    private func decaffeinate() {
        guard isRunning, let process = caffeinateProcess else { return }
        process.terminate()
        caffeinateProcess = nil
        isRunning = false
    }
    
    @objc func quitApp() {
        if isRunning {
            decaffeinate()
        }
        NSApplication.shared.terminate(nil)
    }
}
