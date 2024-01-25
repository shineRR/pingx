// MARK: - PingerDelegate

public protocol PingerDelegate: AnyObject {
    func pinger(_ pinger: Pinger, request: Request, didReceive response: Response)
    func pinger(_ pinger: Pinger, request: Request, didCompleteWithError error: PingerError)
}
