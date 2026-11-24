using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CUDA device tests of the sine, cosine, tangent, hyperbolic sine, cosine and tangent and log-gamma that 0.8.0 changes: the device gives the CoreCLR bits,
/// and the CoreCLR validity, over the class matrix (typical, huge, around the bound 2^24, edges, subnormal, the largest floats, a mixed warp) and
/// a dense sample of the domain. They need a CUDA device and are excluded from the device-free runs.
/// </summary>
public sealed class MathBlockTrigonometricDeviceTests
{
    private const float Limit = 16_777_216f;

    /// <summary>
    /// Verifies the elementwise form (rows outside the domain take the fill) and its validity sibling give the CoreCLR bits and flags on the class matrix
    /// followed by a dense sample of about 2^22 values: for the trigonometric functions an even grid and random floats over [-2^24, 2^24]; for the
    /// hyperbolic tangent a grid over [-110, 110]; for the hyperbolic sine and cosine a grid over [-90, 90] and random floats of +-[80, 90]; for the log-gamma a grid over [-1000, 1000] and random floats of every exponent.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [InlineData("scalar.sine")]
    [InlineData("scalar.cosine")]
    [InlineData("scalar.tangent")]
    [InlineData("scalar.hyperbolic-tangent")]
    [InlineData("scalar.hyperbolic-sine")]
    [InlineData("scalar.hyperbolic-cosine")]
    [InlineData("special.log-gamma")]
    public void CUDAMatchesCoreCLROnTheClassMatrixAndADenseSample(string source)
    {
        ArgumentException.ThrowIfNullOrEmpty(source);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var rows = ClassMatrix();
        AddDenseSample(source, rows);
        Assert.True(rows.Count > 4_000_000);

        var (formCpu, formCuda) = Evaluate($"elementwise.{source}@1", [MathBlockValue.Vector(rows), MathBlockValue.Scalar(-777f)]);
        Assert.True(formCpu.IsValid);
        Assert.True(MathBlockDomainWiringTests.Same(formCpu, formCuda), $"{source}: the device values differ from CoreCLR.");
        var (validityCpu, validityCuda) = Evaluate($"elementwise-valid.{source}@1", [MathBlockValue.Vector(rows)]);
        Assert.True(MathBlockDomainWiringTests.Same(validityCpu, validityCuda), $"{source}: the device validity differs from CoreCLR.");
    }

    private static List<float> ClassMatrix()
    {
        var random = new Random(20_261_127);
        var rows = new List<float>();
        // Typical.
        for (var index = 0; index < 4_096; index++)
            rows.Add((float)(random.NextDouble() * 20 - 10));
        // Huge: 1e7 to 1e38, both signs.
        for (var index = 0; index < 4_096; index++)
            rows.Add((float)(Math.Pow(10, 7 + random.NextDouble() * 31) * (random.Next(2) == 0 ? 1 : -1)));
        // Around the bound 2^24, 64 floats each way, both signs, and around 2^23 and 20, 88.72, -103.97.
        foreach (var centre in new[] { Limit, 8_388_608f, 20f, 88.72284f, 89.415f, 103.97208f })
        {
            var up = centre;
            var down = centre;
            for (var index = 0; index < 64; index++)
            {
                foreach (var value in new[] { up, down })
                {
                    rows.Add(value);
                    rows.Add(-value);
                }

                up = float.BitIncrement(up);
                down = float.BitDecrement(down);
            }
        }

        // Edges and subnormals. A valid vector holds finite values only, so NaN and the infinities cannot be rows; the largest floats stand for the
        // far side of the domain.
        rows.AddRange(
        [
            0f, float.NegativeZero, float.Epsilon, -float.Epsilon, 1.17549435e-38f, 1.17549421e-38f, 1e-30f, 1e-20f, 1e-10f, 0.5f, -0.5f, 1f, -1f,
            MathF.PI, -MathF.PI, MathF.PI / 2f, -MathF.PI / 2f, 3f, -3f, -2.5f, -1.5f, -0.5f, -2f, -1f, 16_777_215f, float.MaxValue, -float.MaxValue,
            1e38f, -1e38f
        ]);
        // Multiples of pi/2 up to the bound, where the quadrant changes and the reduced argument is near zero.
        for (var count = 1; count <= 10_000_000; count += 1_009)
        {
            var multiple = (float)(count * (Math.PI / 2));
            rows.Add(multiple);
            rows.Add(-multiple);
        }

        // A mixed warp: a value of every class in each lane group, repeated.
        float[] warp = [0.3f, 1e7f, Limit, float.MaxValue, -2.5f, 1e30f, float.Epsilon, -Limit, 8_388_609f, -float.MaxValue, 50f, -3f];
        for (var index = 0; index < 2_048; index++)
            rows.Add(warp[index % warp.Length]);
        return rows;
    }

    private static void AddDenseSample(string source, List<float> rows)
    {
        var random = new Random(20_261_128);
        const int count = 1 << 22;
        switch (source)
        {
            case "scalar.hyperbolic-tangent":
                for (var index = 0; index < count / 2; index++)
                    rows.Add(-110f + index * (220f / (count / 2)));
                for (var index = 0; index < count / 2; index++)
                    rows.Add((float)(random.NextDouble() * 220 - 110));
                break;
            case "scalar.hyperbolic-sine":
            case "scalar.hyperbolic-cosine":
                // A grid over [-90, 90] and random floats of [-90, -80] and [80, 90], across the old overflow at 88.72 and the new one at 89.415.
                for (var index = 0; index < count / 2; index++)
                    rows.Add(-90f + index * (180f / (count / 2)));
                for (var index = 0; index < count / 2; index++)
                    rows.Add((float)((80 + random.NextDouble() * 10) * (random.Next(2) == 0 ? 1 : -1)));
                break;
            case "special.log-gamma":
                for (var index = 0; index < count / 2; index++)
                    rows.Add(-1_000f + index * (2_000f / (count / 2)));
                for (var index = 0; index < count / 2; index++)
                    rows.Add(BitConverter.Int32BitsToSingle(random.Next(1, 0x7f80_0000)) * (random.Next(2) == 0 ? 1f : -1f));
                break;
            default:
                // A grid of step 16 over [-2^24, 2^24] (exact floats), then random floats of every exponent up to 2^24.
                for (var index = 0; index < count / 2; index++)
                    rows.Add(-Limit + index * 16f);
                for (var index = 0; index < count / 2; index++)
                {
                    var x = BitConverter.Int32BitsToSingle((random.Next(1, 152) << 23) | random.Next(0, 1 << 23));
                    rows.Add(random.Next(2) == 0 ? Math.Min(x, Limit) : -Math.Min(x, Limit));
                }

                break;
        }
    }

    private static (MathBlockValue CoreCLR, MathBlockValue Cuda) Evaluate(string identity, IReadOnlyList<MathBlockValue> values)
    {
        var (program, inputs) = MathBlockCudaDomainDeviceTests.Build(identity, values);
        var coreclr = MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"];
        using var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs);
        return (coreclr, compiled.Execute(inputs)["result"]);
    }
}
