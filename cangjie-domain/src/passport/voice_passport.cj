package dialect_domain.passport

import dialect_domain.dialect.DialectAssessment

public struct VoicePassport {
    public let userId: String
    public let nickname: String
    public let location: String
    public let dialectName: String
    public let confidence: Int64
    public let retention: Int64
    public let representativeVoiceTitle: String
    public let litRegions: Array<String>

    public init(
        userId: String,
        nickname: String,
        location: String,
        dialectName: String,
        confidence: Int64,
        retention: Int64,
        representativeVoiceTitle: String,
        litRegions: Array<String>
    ) {
        this.userId = userId
        this.nickname = nickname
        this.location = location
        this.dialectName = dialectName
        this.confidence = confidence
        this.retention = retention
        this.representativeVoiceTitle = representativeVoiceTitle
        this.litRegions = litRegions
    }
}

public func createPassportFromAssessment(
    assessment: DialectAssessment
): VoicePassport {
    return VoicePassport(
        "current-user",
        "我的乡音",
        assessment.regionName,
        assessment.dialectName,
        assessment.confidence,
        assessment.retention,
        "我的第一段乡音",
        [assessment.regionName]
    )
}

