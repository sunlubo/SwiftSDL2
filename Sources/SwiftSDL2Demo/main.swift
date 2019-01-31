import SwiftSDL2
import Darwin

try SDL.initialize(flags: [.video])

let window = try Window(title: "Hello", width: 640, height: 480, flags: .resizable)
let renderer = try Renderer(window: window)

while let event = Events.wait(), event.type != EventType.quit.rawValue {
  let x = arc4random() % 640
  let y = arc4random() % 480
  let rect = Rect(x: Int(x), y: Int(y), w: 100, h: 50)

  try renderer.setDrawColor(.white)
  try renderer.clear()
  try renderer.drawRect(rect)
  try renderer.setDrawColor(.random)
  try renderer.fillRect(rect)
  renderer.present()
}

SDL.quit()
