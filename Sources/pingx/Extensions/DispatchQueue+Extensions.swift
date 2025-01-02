import Foundation

func performAfter<T>(
    deadline: DispatchTime,
    _ function: @escaping (T) -> Void,
    value: T,
    on queue: DispatchQueue
) {
    queue.asyncAfter(deadline: deadline) {
        function(value)
    }
}

func perform<T>(_ function: @escaping (T) -> Void, value: T, on queue: DispatchQueue) {
    queue.async {
        function(value)
    }
}

func perform(_ function: @escaping () -> Void, on queue: DispatchQueue) {
    queue.async(execute: function)
}
