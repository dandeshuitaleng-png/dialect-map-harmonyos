package dialect_domain.dialect

public struct DialectAssessment {
    public let regionName: String
    public let dialectName: String
    public let confidence: Int64
    public let retention: Int64
    public let isSimulated: Bool

    public init(
        regionName: String,
        dialectName: String,
        confidence: Int64,
        retention: Int64,
        isSimulated: Bool
    ) {
        this.regionName = regionName
        this.dialectName = dialectName
        this.confidence = confidence
        this.retention = retention
        this.isSimulated = isSimulated
    }
}

public func createAssessment(
    regionName: String,
    dialectName: String,
    confidence: Int64,
    retention: Int64
): ?DialectAssessment {
    if (!isPercentage(confidence) || !isPercentage(retention)) {
        return None
    }

    return DialectAssessment(
        regionName,
        dialectName,
        confidence,
        retention,
        true
    )
}

public func createPercentage(value: Int64): ?Int64 {
    if (isPercentage(value)) {
        return value
    }

    return None
}

private func isPercentage(value: Int64): Bool {
    return value >= 0 && value <= 100
}

