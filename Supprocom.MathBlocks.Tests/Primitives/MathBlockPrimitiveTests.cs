namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Primitive Tests.</summary>
public sealed class MathBlockPrimitiveTests
{
    /// <summary>Verifies square root has stable owned bits.</summary>
    [Theory]
    [InlineData(0.125d, 0x3fd6a09e667f3bccL)]
    [InlineData(0.5d, 0x3fe6a09e667f3bccL)]
    [InlineData(1d, 0x3ff0000000000000L)]
    [InlineData(2.5d, 0x3ff94c583ada5b52L)]
    public void SquareRootHasStableOwnedBits(double input, long expectedBits) =>
        Assert.Equal(expectedBits, BitConverter.DoubleToInt64Bits(MathBlockScalar.SquareRoot(input)));

    /// <summary>Verifies round uses stable ties to even.</summary>
    [Theory]
    [InlineData(2.5d, 2d)]
    [InlineData(3.5d, 4d)]
    [InlineData(-2.5d, -2d)]
    [InlineData(-3.5d, -4d)]
    public void RoundUsesStableTiesToEven(double input, double expected) =>
        Assert.Equal(
            BitConverter.DoubleToInt64Bits(expected),
            BitConverter.DoubleToInt64Bits(MathBlockScalar.Round(input)));

    /// <summary>Verifies signed zero behavior is stable.</summary>
    [Fact]
    public void SignedZeroBehaviorIsStable()
    {
        var negativeZero = BitConverter.Int64BitsToDouble(unchecked((long)0x8000000000000000ul));

        Assert.Equal(unchecked((long)0x8000000000000000ul),
            BitConverter.DoubleToInt64Bits(MathBlockScalar.Minimum(0d, negativeZero)));
        Assert.Equal(0L, BitConverter.DoubleToInt64Bits(MathBlockScalar.Maximum(0d, negativeZero)));
        Assert.Equal(unchecked((long)0x8000000000000000ul),
            BitConverter.DoubleToInt64Bits(MathBlockScalar.Truncate(-0.75d)));
    }
}
