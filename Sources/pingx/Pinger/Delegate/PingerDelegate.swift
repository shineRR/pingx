// MARK: - PingerDelegate

public protocol PingerDelegate: AnyObject {
    
    /// Called when a ping request is successful.
    func pinger(_ pinger: Pinger, request: Request, didReceive response: Response)
    
    /// Called when an error occurs during a ping request.
    func pinger(_ pinger: Pinger, request: Request, didCompleteWithError error: PingerError)
}
