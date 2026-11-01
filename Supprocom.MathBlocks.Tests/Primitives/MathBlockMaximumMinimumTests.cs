namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the owned maximum and minimum follow IEEE 754-2019: a NaN operand gives NaN, and -0 is less than +0.</summary>
public sealed class MathBlockMaximumMinimumTests
{
    /// <summary>Gets operand pairs with a NaN on either side.</summary>
    public static TheoryData<double, double> NaNPairs => new()
    {
        { double.NaN, 1d },
        { 1d, double.NaN },
        { double.NaN, double.NaN },
        { double.NaN, 0d },
        { 0d, double.NaN },
        { -0d, double.NaN },
        { double.NaN, -0d },
        { double.NaN, double.PositiveInfinity },
        { double.NegativeInfinity, double.NaN }
    };

    /// <summary>Verifies a NaN operand on either side gives NaN.</summary>
    [Theory]
    [MemberData(nameof(NaNPairs))]
    public void ANaNOperandGivesNaN(double left, double right)
    {
        Assert.True(double.IsNaN(MathBlockScalar.Maximum(left, right)), $"Maximum({left}, {right})");
        Assert.True(double.IsNaN(MathBlockScalar.Minimum(left, right)), $"Minimum({left}, {right})");
    }

    /// <summary>Verifies the order, the equal operands and the signed zeros are unchanged.</summary>
    [Fact]
    public void OrderAndSignedZerosAreUnchanged()
    {
        Assert.Equal(2d, MathBlockScalar.Maximum(1d, 2d));
        Assert.Equal(2d, MathBlockScalar.Maximum(2d, 1d));
        Assert.Equal(1d, MathBlockScalar.Minimum(1d, 2d));
        Assert.Equal(1d, MathBlockScalar.Minimum(2d, 1d));
        Assert.Equal(double.PositiveInfinity, MathBlockScalar.Maximum(double.PositiveInfinity, 1d));
        Assert.Equal(double.NegativeInfinity, MathBlockScalar.Minimum(1d, double.NegativeInfinity));
        Assert.Equal(0L, BitConverter.DoubleToInt64Bits(MathBlockScalar.Maximum(-0d, 0d)));
        Assert.Equal(0L, BitConverter.DoubleToInt64Bits(MathBlockScalar.Maximum(0d, -0d)));
        Assert.Equal(long.MinValue, BitConverter.DoubleToInt64Bits(MathBlockScalar.Minimum(-0d, 0d)));
        Assert.Equal(long.MinValue, BitConverter.DoubleToInt64Bits(MathBlockScalar.Minimum(0d, -0d)));
    }
}
