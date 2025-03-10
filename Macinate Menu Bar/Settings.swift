import SwiftUI
import ServiceManagement


struct SettingsView: View {
    @State private var isToggled = false
    
    init() {
        let isRegistered = SMAppService.mainApp.status == .enabled
        _isToggled = State(initialValue: isRegistered)
    }
    
    var body: some View {
        VStack {
            Text("Settings")
                .font(.largeTitle)
                .padding()
            
            Divider().frame(
                        maxWidth: 100
                    )
            
            Toggle("Open at login", isOn: $isToggled)
                .onChange(of: isToggled) { newValue in
                    handleToggleChange(to: newValue)
                }
                .padding()
        }.frame(minWidth: 150, minHeight: 150)
    }
    
    func handleToggleChange(to newValue: Bool) -> Void {
        if newValue {
           do {
               try SMAppService.mainApp.register()
               print("Successfully registered the app as a login item.")
           } catch {
               print("Failed to register as a login item: \(error)")
           }
       } else {
           do {
               try SMAppService.mainApp.unregister()
               print("Successfully unregistered the app as a login item.")
           } catch {
               print("Failed to unregister as a login item: \(error)")
           }
       }
    }
}
