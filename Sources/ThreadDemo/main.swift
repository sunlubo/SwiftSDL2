import SwiftSDL2

let fn: ThreadFunction = { ptr in
    for i in 0..<10 {
        print(i)
    }
    return 100
}
let thread = Thread(fn: fn, name: "hello", data: nil)
thread.start()

let status = thread.wait()
print(status)

print("done.")
