// Generated using Sourcery 2.2.5 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT
// swiftlint:disable all

import UIKit
@testable import pingx

class PacketFactoryMock: PacketFactory {

    //MARK: - create

    var createTypeThrowableError: Error?
    var createTypeCallsCount = 0
    var createTypeCalled: Bool {
        return createTypeCallsCount > 0
    }
    var createTypeReceivedType: PacketType?
    var createTypeReceivedInvocations: [PacketType] = []
    var createTypeReturnValue: Packet!
    var createTypeClosure: ((PacketType) throws -> Packet)?

    func create(type: PacketType) throws -> Packet {
        if let error = createTypeThrowableError {
            throw error
        }
        createTypeCallsCount += 1
        createTypeReceivedType = type
        createTypeReceivedInvocations.append(type)
        return try createTypeClosure.map({ try $0(type) }) ?? createTypeReturnValue
    }

}
