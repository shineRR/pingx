// MARK: - ICMPPackage

struct ICMPPackage {
    
    // MARK: Properties
    private var ipHeader: IPHeader
    private var icmpHeader: ICMPHeader
    private let data: Data
}
