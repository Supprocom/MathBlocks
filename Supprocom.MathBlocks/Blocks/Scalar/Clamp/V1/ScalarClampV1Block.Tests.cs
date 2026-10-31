namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the <c>scalar.clamp@1</c> operation contract.</summary>
public sealed class ScalarClampV1BlockTests
{
    /// <summary>Checks the <c>scalar.clamp@1</c> operation contract.</summary>
    [Fact]
    [Trait("Category", "BlockContract")]
    public void ContractIsValid() => MathBlockFeatureContractAssertions.Verify("scalar.clamp@1");

    /// <summary>
    /// Verifies a lower limit above the upper limit gives an invalid scalar of the value's unit instead of an
    /// exception, and equal limits (including -0 and +0, which compare equal) are valid.
    /// </summary>
    [Fact]
    public void LowerLimitAboveTheUpperLimitIsInvalid()
    {
        var clamp = MathBlockCatalog.Standard.Get("scalar.clamp");
        var unit = MathBlockUnit.Basis0;

        var result = clamp.Evaluate(
            MathBlockValue.Scalar(1d, unit),
            MathBlockValue.Scalar(3d, unit),
            MathBlockValue.Scalar(2d, unit));

        Assert.False(result.IsValid);
        Assert.Equal(MathBlockType.Scalar(unit), result.Type);
        Assert.False(clamp.Evaluate(MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(-1d)).IsValid);
        Assert.True(clamp.Evaluate(MathBlockValue.Scalar(5d), MathBlockValue.Scalar(2d), MathBlockValue.Scalar(2d)).IsValid);
        Assert.True(clamp.Evaluate(MathBlockValue.Scalar(1d), MathBlockValue.Scalar(0d), MathBlockValue.Scalar(-0d)).IsValid);
    }

    /// <summary>Gets (value, lower, upper, expected) cases at signed zeros.</summary>
    public static TheoryData<double, double, double, double> SignedZeroCases => new()
    {
        { -0d, 0d, 0d, -0d },
        { -0d, 0d, 1d, -0d },
        { -0d, 0d, 0.5d, -0d },
        { 0d, 0d, -0d, 0d },
        { 0d, -0d, -0d, 0d },
        { 0d, -1d, -0d, 0d },
        { -1d, 0d, -0d, 0d },
        { -1d, -0d, 0d, -0d },
        { 5d, -0d, 0d, 0d },
    };

    /// <summary>
    /// Verifies the Math.Clamp rule at signed zeros: the value is returned unless it compares below the lower
    /// limit or above the upper limit, so a zero keeps its own sign against zero limits.
    /// </summary>
    [Theory]
    [MemberData(nameof(SignedZeroCases))]
    public void SignedZerosFollowTheMathClampRule(double value, double lower, double upper, double expected)
    {
        var result = MathBlockCatalog.Standard.Get("scalar.clamp").Evaluate(
            MathBlockValue.Scalar(value),
            MathBlockValue.Scalar(lower),
            MathBlockValue.Scalar(upper));

        Assert.True(result.IsValid);
        Assert.Equal(BitConverter.DoubleToInt64Bits(expected), BitConverter.DoubleToInt64Bits(result.AsScalar()));
    }
}
