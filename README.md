# SwiftSDL2

A Swift wrapper for the SDL2 API

## Installation

You should install [SDL2](https://www.libsdl.org/) before use this library, on macOS, you can:

```bash
brew install sdl2
```

### Swift Package Manager

SwiftSDL2 primarily uses [SwiftPM](https://swift.org/package-manager/) as its build tool, so we recommend using that as well. If you want to depend on SwiftFFmpeg in your own project, it's as simple as adding a `dependencies` clause to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/sunlubo/SwiftSDL2.git", from: "0.0.1")
]
```

## Usage

```swift
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
```
