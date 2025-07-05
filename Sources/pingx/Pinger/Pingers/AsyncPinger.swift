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
public protocol AsyncPingerProtocol: AnyObject, Sendable {
    func ping(request: Request) -> AnyPingSequence
}

public final class AsyncPinger: AsyncPingerProtocol, @unchecked Sendable {

    // MARK: Properties

    @Atomic private var pingxSocket: (any PingxSocketProtocol)!
    @Atomic private var completions = [Request.Identifier: (AsyncPingerResult) -> Void]()
    private let configuration: PingConfiguration
    private let icmpHeaderFactory: ICMPHeaderFactoryProtocol
    private let icmpPacketExtractor: ICMPPacketExtractorProtocol
    private let socketFactory: SocketFactoryProtocol

    // MARK: Initializer

    init(
        configuration: PingConfiguration,
        icmpHeaderFactory: ICMPHeaderFactoryProtocol,
        icmpPacketExtractor: ICMPPacketExtractorProtocol,
        socketFactory: SocketFactoryProtocol
    ) {
        self.configuration = configuration
        self.icmpHeaderFactory = icmpHeaderFactory
        self.icmpPacketExtractor = icmpPacketExtractor
        self.socketFactory = socketFactory
    }

    public convenience init(
        configuration: PingConfiguration = .default
    ) {
        self.init(
            configuration: configuration,
            icmpHeaderFactory: ICMPHeaderFactory(),
            icmpPacketExtractor: ICMPPacketExtractor(),
            socketFactory: SocketFactory()
        )
    }

    public func ping(request: Request) -> AnyPingSequence {
        AnyPingSequence(
            sequence: PingSequence(
                configuration: configuration,
                pinger: self,
                request: request
            )
        )
    }
}

// MARK: - Internal API

extension AsyncPinger {
    func ping(
        request: Request,
        completion: @escaping (AsyncPingerResult) -> Void
    ) {
        completions[request.identifier] = completion

        do {
            try checkSocketCreation()
        } catch {
            invokeCompletion(identifier: request.identifier, result: .failure(.socketCreationError))
            return
        }

        guard let icmpHeader = try? icmpHeaderFactory.make(from: request) else {
            invokeCompletion(identifier: request.identifier, result: .failure(.unableToCreatePacket))
            return
        }

        let cfSocketError = pingxSocket.send(
            address: request.destination.socketAddress as CFData,
            data: icmpHeader.data as CFData,
            timeout: request.timeoutInterval.milliseconds
        )

        if let error = cfSocketError.mapToPingerError() {
            invokeCompletion(identifier: request.identifier, result: .failure(error))
        }
    }

    func cancel(requestId: Request.Identifier) {
        invokeCompletion(identifier: requestId, result: .failure(.cancelled))
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

    func invokeCompletion(identifier: Request.Identifier, result: AsyncPingerResult) {
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
    var identifier: Request.Identifier? {
        switch self {
        case .success(let icmpPacket):
            return icmpPacket.icmpHeader.toRequestIdentifier()
        case .failure(.responseStructureInconsistent(let validationError)):
            return validationError.icmpHeader.map { icmpHeader in
                icmpHeader.toRequestIdentifier()
            }
        case .failure:
            return nil
        }
    }
}

private extension ICMPHeader {
    func toRequestIdentifier() -> Request.Identifier {
        Request.Identifier(
            id: identifier,
            uniqueToken: UUID(uuid: payload.rawUniqueToken)
        )
    }
}
