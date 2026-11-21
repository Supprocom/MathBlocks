namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains regression tests for Math Block Primitive Tests.</summary>
public sealed class MathBlockPrimitiveTests
{
    /// <summary>Verifies square root has the correctly rounded bits.</summary>
    [Theory]
    [InlineData(0.125f, 0x3fd6a09e667f3bcdL)]
    [InlineData(0.5f, 0x3fe6a09e667f3bcdL)]
    [InlineData(1f, 0x3ff0000000000000L)]
    [InlineData(2.5f, 0x3ff94c583ada5b53L)]
    public void SquareRootHasStableOwnedBits(float input, long expectedBits) =>
        Assert.Equal(expectedBits, BitConverter.SingleToInt32Bits(MathBlockScalar.SquareRoot(input)));

    /// <summary>Verifies round uses stable ties to even.</summary>
    [Theory]
    [InlineData(2.5f, 2f)]
    [InlineData(3.5f, 4f)]
    [InlineData(-2.5f, -2f)]
    [InlineData(-3.5f, -4f)]
    public void RoundUsesStableTiesToEven(float input, float expected) =>
        Assert.Equal(
            BitConverter.SingleToInt32Bits(expected),
            BitConverter.SingleToInt32Bits(MathBlockScalar.Round(input)));

    /// <summary>Verifies signed zero behavior is stable.</summary>
    [Fact]
    public void SignedZeroBehaviorIsStable()
    {
        var negativeZero = BitConverter.Int32BitsToSingle(unchecked((int)0x80000000u));

        Assert.Equal(unchecked((long)0x8000000000000000ul),
            BitConverter.SingleToInt32Bits(MathBlockScalar.Minimum(0f, negativeZero)));
        Assert.Equal(0L, BitConverter.SingleToInt32Bits(MathBlockScalar.Maximum(0f, negativeZero)));
        Assert.Equal(unchecked((long)0x8000000000000000ul),
            BitConverter.SingleToInt32Bits(MathBlockScalar.Truncate(-0.75f)));
    }
}
