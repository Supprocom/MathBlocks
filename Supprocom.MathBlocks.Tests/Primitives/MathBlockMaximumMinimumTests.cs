namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the owned maximum and minimum follow IEEE 754-2019: a NaN operand gives NaN, and -0 is less than +0.</summary>
public sealed class MathBlockMaximumMinimumTests
{
    /// <summary>Gets operand pairs with a NaN on either side.</summary>
    public static TheoryData<float, float> NaNPairs => new()
    {
        { float.NaN, 1f },
        { 1f, float.NaN },
        { float.NaN, float.NaN },
        { float.NaN, 0f },
        { 0f, float.NaN },
        { -0f, float.NaN },
        { float.NaN, -0f },
        { float.NaN, float.PositiveInfinity },
        { float.NegativeInfinity, float.NaN }
    };

    /// <summary>Verifies a NaN operand on either side gives NaN.</summary>
    [Theory]
    [MemberData(nameof(NaNPairs))]
    public void ANaNOperandGivesNaN(float left, float right)
    {
        Assert.True(float.IsNaN(MathBlockScalar.Maximum(left, right)), $"Maximum({left}, {right})");
        Assert.True(float.IsNaN(MathBlockScalar.Minimum(left, right)), $"Minimum({left}, {right})");
    }

    /// <summary>Verifies the order, the equal operands and the signed zeros are unchanged.</summary>
    [Fact]
    public void OrderAndSignedZerosAreUnchanged()
    {
        Assert.Equal(2f, MathBlockScalar.Maximum(1f, 2f));
        Assert.Equal(2f, MathBlockScalar.Maximum(2f, 1f));
        Assert.Equal(1f, MathBlockScalar.Minimum(1f, 2f));
        Assert.Equal(1f, MathBlockScalar.Minimum(2f, 1f));
        Assert.Equal(float.PositiveInfinity, MathBlockScalar.Maximum(float.PositiveInfinity, 1f));
        Assert.Equal(float.NegativeInfinity, MathBlockScalar.Minimum(1f, float.NegativeInfinity));
        Assert.Equal(0L, BitConverter.SingleToInt32Bits(MathBlockScalar.Maximum(-0f, 0f)));
        Assert.Equal(0L, BitConverter.SingleToInt32Bits(MathBlockScalar.Maximum(0f, -0f)));
        Assert.Equal(long.MinValue, BitConverter.SingleToInt32Bits(MathBlockScalar.Minimum(-0f, 0f)));
        Assert.Equal(long.MinValue, BitConverter.SingleToInt32Bits(MathBlockScalar.Minimum(0f, -0f)));
    }
}
