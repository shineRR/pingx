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
@testable import pingx

final class PacketSenderDelegateMock: PacketSenderDelegate {
    typealias ResponseInvocation = (packetSender: PacketSender, data: Data)
    typealias ErrorInvocation = (packetSender: PacketSender, request: Request, error: PacketSenderError)

    private(set) var didReceiveDataCalledCount: Int = 0
    private(set) var didReceiveDataInvocations: [ResponseInvocation] = []
    private(set) var didCompleteWithErrorCalledCount: Int = 0
    private(set) var didCompleteWithErrorInvocations: [ErrorInvocation] = []
    
    func packetSender(packetSender: PacketSender, didReceive data: Data) {
        didReceiveDataCalledCount += 1
        didReceiveDataInvocations.append((packetSender, data))
    }
    
    func packetSender(packetSender: PacketSender, request: Request, didCompleteWithError error: PacketSenderError) {
        didCompleteWithErrorCalledCount += 1
        didCompleteWithErrorInvocations.append((packetSender, request, error))
    }
}
