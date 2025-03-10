import SwiftUI

struct ContentView: View {
    @State var isRunning: Bool
    @State var isKilling = false
    
    var body: some View {
        VStack {
            Text("Macinate")
                .font(.largeTitle)
                .padding()
            VStack {
                if !isRunning {
                    Button(action: {
                        let executableURL = URL(fileURLWithPath: "/usr/bin/caffeinate")
                        self.isRunning = true
                        try! Process.run(executableURL,
                                         arguments: ["-di"],
                                         terminationHandler: { _ in self.isRunning = false })
                    }) {
                        HStack {
                            Image(systemName: "sun.max")
                            Text("Caffeinate")
                        }
                    }.disabled(isRunning)
                        .padding(.trailing)
                    Text("Your Mac is currently decaffeinated. Your Mac will sleep automatically unless you caffeinate it.")
                } else {
                    Button(action: {
                        let executableURL = URL(fileURLWithPath: "/usr/bin/killall")
                        self.isRunning = true
                        try! Process.run(executableURL,
                                         arguments: ["caffeinate"],
                                         terminationHandler: { _ in self.isKilling = false })
                    }) {
                        HStack {
                            Image(systemName: "moon.zzz.fill")
                            Text("Decaffeinate")
                        }
                    }.disabled(!isRunning)
                    .padding(.trailing)
                    Text("Your Mac is currently caffeinated. Your Mac won't sleep automatically until you decaffeinate it.")
                }
            }
        }.frame(minWidth: 150, minHeight: 150)
    }
}
