//
// The MIT License (MIT)
//
// Copyright © 2025 Ilya Baryka. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation

// sourcery: AutoMockable
public protocol AsyncPingerProtocol: AnyObject {
    func ping(request: Request) -> PingSequence
    func cancel(requestId: Request.ID)
}

public final class AsyncPinger: AsyncPingerProtocol {
    
    // MARK: Properties
    
    @Atomic private var pingxSocket: (any PingxSocketProtocol)!
    @Atomic private var completions = [UInt16: (AsyncPingerResult) -> Void]()
    private let icmpHeaderFactory: ICMPHeaderFactoryProtocol
    private let icmpPacketExtractor: ICMPPacketExtractorProtocol
    private let socketFactory: SocketFactoryProtocol
    
    // MARK: Initializer
    
    init(
        icmpHeaderFactory: ICMPHeaderFactoryProtocol,
        icmpPacketExtractor: ICMPPacketExtractorProtocol,
        socketFactory: SocketFactoryProtocol
    ) {
        self.icmpHeaderFactory = icmpHeaderFactory
        self.icmpPacketExtractor = icmpPacketExtractor
        self.socketFactory = socketFactory
    }
    
    public convenience init() {
        self.init(
            icmpHeaderFactory: ICMPHeaderFactory(),
            icmpPacketExtractor: ICMPPacketExtractor(),
            socketFactory: SocketFactory()
        )
    }
    
    public func ping(request: Request) -> PingSequence {
        PingSequence(request: request, pinger: self)
    }
    
    public func cancel(requestId: Request.ID) {
        invokeCompletion(identifier: requestId, result: .failure(.cancelled))
    }
}

// MARK: - Internal API

extension AsyncPinger {
    func ping(
        _ request: Request,
        completion: @escaping (AsyncPingerResult) -> Void
    ) {
        completions[request.id] = completion
        
        do {
            try checkSocketCreation()
        } catch {
            invokeCompletion(identifier: request.id, result: .failure(.socketCreationError))
            return
        }

        let packet = try? icmpHeaderFactory.make(
            type: request.type,
            identifier: request.id,
            sequenceNumber: request.sequenceNumber
        )

        guard let packet else {
            invokeCompletion(identifier: request.id, result: .failure(.unableToCreatePacket))
            return
        }
        
        let cfSocketError = pingxSocket.send(
            address: request.destination.socketAddress as CFData,
            data: packet.data as CFData,
            timeout: request.timeoutInterval
        )
        
        if let error = cfSocketError.mapToPingerError() {
            invokeCompletion(identifier: request.id, result: .failure(error))
        }
    }
}

// MARK: - Private API

private extension AsyncPinger {
    func checkSocketCreation() throws {
        guard pingxSocket == nil else { return }
        
        let command: CommandBlock<Data> = CommandBlock { [weak self] data in
            guard let self else { return }

            let result: AsyncPingerResult = { [icmpPacketExtractor] in
                do {
                    let icmpPacket = try icmpPacketExtractor.extract(from: data)
                    return .success(icmpPacket)
                } catch let error as ICMPResponseValidationError {
                    return .failure(.responseStructureInconsistent(error))
                } catch {
                    return .failure(.unknown)
                }
            }()
            
            if let identifier = result.identifier {
                invokeCompletion(identifier: identifier, result: result)
            }
        }
        
        pingxSocket = try socketFactory.make(command: command)
    }
    
    func invokeCompletion(identifier: Request.ID, result: AsyncPingerResult) {
        let completion = completions.removeValue(forKey: identifier)
        completion?(result)
    }
}

private extension CFSocketError {
    func mapToPingerError() -> AsyncPingerError? {
        switch self {
        case .error:
            return .unknown
        case .timeout:
            return .timeout
        default:
            return nil
        }
    }
}

private extension Result<ICMPPacket, AsyncPingerError> {
    var identifier: Request.ID? {
        switch self {
        case .success(let icmpPacket):
            return icmpPacket.icmpHeader.identifier
        case .failure(.responseStructureInconsistent(let validationError)):
            return validationError.icmpHeader?.identifier
        case .failure:
            return nil
        }
    }
}
