// MARK: - CommandBlock

public final class CommandBlock<T> {
    
    // MARK: Properties
    
    public let closure: (T) -> Void
    
    // MARK: Initializer
    
    init(closure: @escaping (T) -> Void) {
        self.closure = closure
    }
}
