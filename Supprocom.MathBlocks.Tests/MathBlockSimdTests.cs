namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies that the block loops give the bits of the scalar functions.</summary>
public sealed class MathBlockSimdTests
{
    private static readonly float[] Pool =
    [
        0f, -0f, float.Epsilon, -float.Epsilon, 1.1754943e-38f, -1.1754943e-38f,
        1f, -1f, 0.5f, -0.5f, float.MaxValue, -float.MaxValue, 1.03e-37f, -1.03e-37f, 3f, 3f, 1.5f,
    ];

    /// <summary>Verifies the elementwise minimum and maximum equal the per-row operation for signed zeros and ties.</summary>
    [Theory]
    [InlineData("minimum")]
    [InlineData("maximum")]
    public void ElementwiseMinimumAndMaximumMatchTheScalarOperationBitForBit(string name)
    {
        var form = MathBlockCatalog.Standard.Get($"elementwise.scalar.{name}", 1);
        var source = MathBlockCatalog.Standard.Get($"scalar.{name}", 1);
        var random = new Random(7);
        for (var length = 1; length <= 41; length++)
        {
            foreach (var shape in new[] { 0, 1, 2 })
            {
                var left = Enumerable.Range(0, length).Select(_ => Pool[random.Next(Pool.Length)]).ToArray();
                var right = Enumerable.Range(0, length).Select(_ => Pool[random.Next(Pool.Length)]).ToArray();
                var fill = MathBlockValue.Scalar(-77f);
                var leftValue = shape == 1 ? MathBlockValue.Scalar(Pool[random.Next(Pool.Length)]) : MathBlockValue.Vector(left);
                var rightValue = shape == 2 ? MathBlockValue.Scalar(Pool[random.Next(Pool.Length)]) : MathBlockValue.Vector(right);
                if (shape == 1)
                    rightValue = MathBlockValue.Vector(right);
                var result = form.Evaluate(leftValue, rightValue, fill);
                Assert.True(result.IsValid);
                var actual = result.AsVector();
                Assert.Equal(length, actual.Count);
                for (var row = 0; row < length; row++)
                {
                    var expected = source.Evaluate(
                        leftValue.Type.Kind == MathBlockValueKind.Vector ? MathBlockValue.Scalar(leftValue.AsVector()[row]) : leftValue,
                        rightValue.Type.Kind == MathBlockValueKind.Vector ? MathBlockValue.Scalar(rightValue.AsVector()[row]) : rightValue);
                    var expectedBits = expected.IsValid ? expected.AsScalar() : -77f;
                    Assert.Equal(BitConverter.SingleToInt32Bits(expectedBits), BitConverter.SingleToInt32Bits(actual[row]));
                }
            }
        }
    }

    /// <summary>Verifies the vector arithmetic equals the scalar loop bit for bit, including overflowing rows.</summary>
    [Fact]
    public void VectorArithmeticMatchesTheScalarLoopBitForBit()
    {
        var random = new Random(11);
        for (var length = 0; length <= 37; length++)
        {
            var left = new MathBlockVector(Enumerable.Range(0, length).Select(_ => Pool[random.Next(Pool.Length)] * (0.5f + 0.5f * random.NextSingle())));
            var right = new MathBlockVector(Enumerable.Range(0, length).Select(_ => Pool[random.Next(Pool.Length)] * (0.5f + 0.5f * random.NextSingle())));
            var scalar = Pool[random.Next(Pool.Length)];
            var cases = new (float[] Actual, Func<float, float, float> Function)[]
            {
                (MathBlockVectorMath.Add(left, right), (a, b) => a + b),
                (MathBlockVectorMath.Subtract(left, right), (a, b) => a - b),
                (MathBlockVectorMath.Multiply(left, right), (a, b) => a * b),
                (MathBlockVectorMath.Divide(left, right), (a, b) => a / b),
            };
            foreach (var (actual, function) in cases)
            {
                Assert.Equal(length, actual.Length);
                for (var row = 0; row < length; row++)
                    Assert.True(IsSameResult(function(left[row], right[row]), actual[row]));
            }
            var scaled = MathBlockVectorMath.Scale(left, scalar);
            for (var row = 0; row < length; row++)
                Assert.True(IsSameResult(left[row] * scalar, scaled[row]));
        }
    }

    /// <summary>Verifies a right list that is too short still throws the indexer's exception.</summary>
    [Fact]
    public void ShortRightVectorStillThrowsIndexOutOfRange()
    {
        var left = new MathBlockVector([1f, 2f, 3f, 4f, 5f]);
        var right = new MathBlockVector([1f, 2f]);
        Assert.Throws<IndexOutOfRangeException>(() => MathBlockVectorMath.Add(left, right));
        Assert.Equal([2f, 4f], MathBlockVectorMath.Add(new MathBlockVector([1f, 2f]), new MathBlockVector([1f, 2f, 3f])));
    }

    /// <summary>Verifies the finiteness pass of a vector result finds a nonfinite value at every position and length.</summary>
    [Fact]
    public void VectorResultFinitenessFindsEveryNonfiniteValue()
    {
        var divide = MathBlockCatalog.Standard.Get("vector.divide", 1);
        float[] numerators = [1f, -1f, 0f];
        for (var length = 1; length <= 37; length++)
        {
            var ones = Enumerable.Repeat(1f, length).ToArray();
            Assert.True(divide.Evaluate(MathBlockValue.Vector(ones), MathBlockValue.Vector(ones)).IsValid);
            for (var position = 0; position < length; position++)
                foreach (var numerator in numerators)
                {
                    var top = (float[])ones.Clone();
                    top[position] = numerator;
                    var bottom = (float[])ones.Clone();
                    bottom[position] = 0f;
                    Assert.False(divide.Evaluate(MathBlockValue.Vector(top), MathBlockValue.Vector(bottom)).IsValid);
                }
            var huge = Enumerable.Repeat(float.MaxValue, length).ToArray();
            var scale = MathBlockCatalog.Standard.Get("vector.scale", 1);
            Assert.False(scale.Evaluate(MathBlockValue.Vector(huge), MathBlockValue.Scalar(2f)).IsValid);
        }
    }

    // Equal bits, or both NaN: a NaN result is an invalid row and its payload is never read.
    private static bool IsSameResult(float expected, float actual) =>
        float.IsNaN(expected) ? float.IsNaN(actual) : BitConverter.SingleToInt32Bits(expected) == BitConverter.SingleToInt32Bits(actual);
}
