// MARK: - IPHeader

public struct IPHeader {
    
    // MARK: Properties
    
    public let versionAndHeaderLength: UInt8
    public let serviceType: UInt8
    public let totalLength: UInt16 // Total length of the header and data portion of the packet, counted in octets.
    public let identifier: UInt16
    public let flagsAndFragmentOffset: UInt16 // Ripped from the IP protocol.
    public let timeToLive: UInt8
    public let `protocol`: UInt8
    public let headerChecksum: UInt16
    public let sourceAddress: IPv4Address
    public let destinationAddress: IPv4Address
    
    // MARK: Initializer
    
    init(
        versionAndHeaderLength: UInt8 = 4,
        serviceType: UInt8 = .zero,
        totalLength: UInt16,
        identifier: UInt16 = .zero,
        flagsAndFragmentOffset: UInt16 = .zero,
        timeToLive: UInt8 = 64,
        protocol: UInt8 = 1,
        headerChecksum: UInt16,
        sourceAddress: IPv4Address,
        destinationAddress: IPv4Address
    ) {
        self.versionAndHeaderLength = versionAndHeaderLength
        self.serviceType = serviceType
        self.totalLength = totalLength
        self.identifier = identifier
        self.flagsAndFragmentOffset = flagsAndFragmentOffset
        self.timeToLive = timeToLive
        self.protocol = `protocol`
        self.headerChecksum = headerChecksum
        self.sourceAddress = sourceAddress
        self.destinationAddress = destinationAddress
    }
}
