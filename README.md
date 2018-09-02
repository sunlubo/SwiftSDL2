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

try initSDL(flags: [.video, .audio])

let window = Window(title: "hello", width: 640, height: 480, flags: .resizable)
let renderer = Renderer(window: window)
let texture = Texture(renderer: renderer, format: .rgba8888, access: .target, width: 640, height: 480)

while true {
    if let event = Events.poll(), event.type == .quit {
        break
    }

    let x = arc4random() % 540
    let y = arc4random() % 430
    let rect = Rect(x: Int(x), y: Int(y), w: 100, h: 50)

    try renderer.setTarget(texture)
    try renderer.setDrawColor(Color(r: 0x00, g: 0x00, b: 0x00, a: 0x00))
    try renderer.clear()
    try renderer.drawRect(rect)
    try renderer.setDrawColor(Color(r: 0xFF, g: 0x00, b: 0x00, a: 0x00))
    try renderer.fillRect(rect)
    try renderer.setTarget(nil)
    try renderer.copy(texture: texture, srcRect: nil, dstRect: nil)
    renderer.present()
}

quitSDL()
```
