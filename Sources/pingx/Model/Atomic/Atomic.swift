import Foundation

// MARK: - Atomic

@propertyWrapper
final class Atomic<T> {
    
    // MARK: Properties
    
    private let queue = DispatchQueue(label: UUID().uuidString)
    private var value: T
    
    var wrappedValue: T {
        get { queue.sync { value } }
        set { queue.sync { value = newValue } }
    }
    
    // MARK: Initializer
    
    init(wrappedValue: T) {
        self.value = wrappedValue
    }
}
