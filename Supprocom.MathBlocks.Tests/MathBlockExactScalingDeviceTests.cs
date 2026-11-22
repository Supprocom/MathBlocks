using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CUDA device tests of the two scalar routines the device computes without a library call: the remainder, and the scaling by a
/// power of two inside the exponential and the logarithm. Each gives the CoreCLR bits over operands that reach every branch of the routine.
/// They need a CUDA device and are excluded from the device-free runs.
/// </summary>
public sealed class MathBlockExactScalingDeviceTests
{
    private static readonly float[] Edges =
    [
        0f, -0f, 1f, -1f, 3f, -3f, 6f, -6f, 0.75f, 1.5f, 16_777_215f, 16_777_216f, float.Epsilon, -float.Epsilon, 1.17549435e-38f,
        1.17549421e-38f, 2.3509887e-38f, 1e-30f, 1e-20f, 1e-10f, 1e10f, 1e20f, 1e30f, float.MaxValue, -float.MaxValue, 3.4028233e38f
    ];

    /// <summary>Verifies the device gives the CoreCLR remainder for every pair of the edge operands and for random finite bit patterns of both operands.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAModuloMatchesCoreCLROnEdgeAndRandomOperands()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var first = new List<float>();
        var second = new List<float>();
        foreach (var left in Edges)
        {
            foreach (var right in Edges)
            {
                first.Add(left);
                second.Add(right);
            }
        }

        var random = new Random(20_240_611);
        while (first.Count < 16_384)
        {
            var left = BitConverter.Int32BitsToSingle(random.Next(int.MinValue, int.MaxValue));
            var right = BitConverter.Int32BitsToSingle(random.Next(int.MinValue, int.MaxValue));
            if (!float.IsFinite(left) || !float.IsFinite(right))
                continue;
            first.Add(left);
            second.Add(right);
        }

        var (coreclr, cuda) = Evaluate(
            "elementwise.scalar.modulo@1",
            [MathBlockValue.Vector(first), MathBlockValue.Vector(second), MathBlockValue.Scalar(-1f)]);
        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cuda), "The device remainder differs from CoreCLR.");
        var values = coreclr.AsVector();
        var finite = 0;
        for (var row = 0; row < values.Count; row++)
        {
            if (second[row] != 0f)
            {
                Assert.Equal(BitConverter.SingleToInt32Bits(first[row] % second[row]), BitConverter.SingleToInt32Bits(values[row]));
                finite++;
            }
        }

        Assert.True(finite > 16_000);
    }

    /// <summary>
    /// Verifies the device gives the CoreCLR exponential where its result is subnormal, near the smallest normal and near the largest value, and the
    /// CoreCLR logarithm of subnormal, small, large and ordinary arguments.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [InlineData("elementwise.scalar.exponential@1")]
    [InlineData("elementwise.scalar.natural-logarithm@1")]
    public void CUDAExponentialAndLogarithmMatchCoreCLRAcrossTheScalingBranches(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var arguments = new List<float>();
        if (identity.Contains("exponential", StringComparison.Ordinal))
        {
            // From below the underflow limit to above the overflow limit in steps of 1/64, then the neighbours of the two limits.
            for (var step = -6_720; step <= 5_696; step++)
                arguments.Add(step / 64f);
            foreach (var limit in new[] { -103.97208f, -87.33655f, 88.72284f })
            {
                var value = limit;
                for (var index = 0; index < 64; index++)
                {
                    arguments.Add(value);
                    value = float.BitDecrement(value);
                }

                value = limit;
                for (var index = 0; index < 64; index++)
                {
                    value = float.BitIncrement(value);
                    arguments.Add(value);
                }
            }
        }
        else
        {
            // Every power of two from the smallest subnormal to the largest, with the value just below and above it, then ordinary arguments.
            for (var exponent = -149; exponent <= 127; exponent++)
            {
                var power = MathF.ScaleB(1f, exponent);
                arguments.Add(power);
                arguments.Add(float.BitIncrement(power));
                if (exponent > -149)
                    arguments.Add(float.BitDecrement(power));
            }

            var random = new Random(20_240_612);
            for (var index = 0; index < 8_192; index++)
                arguments.Add(BitConverter.Int32BitsToSingle(random.Next(1, 0x7f80_0000)));
        }

        var (coreclr, cuda) = Evaluate(identity, [MathBlockValue.Vector(arguments), MathBlockValue.Scalar(-1f)]);
        Assert.True(MathBlockDomainWiringTests.Same(coreclr, cuda), $"{identity}: the device differs from CoreCLR.");
        Assert.True(coreclr.IsValid);
    }

    private static (MathBlockValue CoreCLR, MathBlockValue Cuda) Evaluate(string identity, IReadOnlyList<MathBlockValue> values)
    {
        var (program, inputs) = MathBlockCudaDomainDeviceTests.Build(identity, values);
        var coreclr = MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs);
        return (coreclr, compiled.Execute(inputs)["result"]);
    }
}
