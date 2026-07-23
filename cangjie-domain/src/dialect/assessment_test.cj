package dialect_domain.dialect

@Test
func acceptsPercentageBoundaries() {
    @Expect(createPercentage(0).isSome())
    @Expect(createPercentage(100).isSome())
}

@Test
func rejectsPercentageOutsideBoundaries() {
    @Expect(createPercentage(-1).isNone())
    @Expect(createPercentage(101).isNone())
}

@Test
func rejectsAssessmentWithInvalidRetention() {
    let assessment = createAssessment("四川", "四川话", 87, 101)
    @Expect(assessment.isNone())
}

