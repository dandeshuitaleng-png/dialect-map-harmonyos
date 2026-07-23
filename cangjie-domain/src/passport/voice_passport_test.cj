package dialect_domain.passport

import dialect_domain.dialect.createAssessment

@Test
func lightsAssessedRegionInPassport() {
    if (let Some(assessment) <- createAssessment("四川", "四川话", 87, 76)) {
        let passport = createPassportFromAssessment(assessment)
        @Expect(passport.litRegions.size, 1)
        @Expect(passport.litRegions[0], "四川")
        @Expect(passport.dialectName, "四川话")
    } else {
        @Fail("有效鉴定结果不应为空")
    }
}

