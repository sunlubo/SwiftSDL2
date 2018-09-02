import SwiftSDL2

let queue = BlockingQueue<Int>(capacity: 5)
var stop = false

let producerFn = { _ in
    for i in 0..<100 {
        queue.put(i)
    }
    stop = true
    return 100
} as ThreadFunction
let producer = Thread(fn: producerFn, name: "thread_1", data: nil)
producer.start()

let consumerFn = { _ in
    var count = 0
    while !stop {
        let v = queue.take()
        print(v)
        count += 1
    }
    return Int32(count)
} as ThreadFunction
let consumer = Thread(fn: consumerFn, name: "thread_2", data: nil)
consumer.start()

print("producer: \(producer.wait())")
