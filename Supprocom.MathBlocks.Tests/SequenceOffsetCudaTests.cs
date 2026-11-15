using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Compares the offset operations on CUDA with CoreCLR, bit for bit, on cases that cover the reachability, validity and zero rules.</summary>
public sealed class SequenceOffsetCudaTests
{
    private static readonly double[] Counts8 = [0d, 1d, 2d, 3d, 4d, 5d, 6d, 7d];
    private static readonly double[] GapCounts8 = [0d, 1d, 2d, 0d, 1d, 2d, 3d, 0d];
    private static readonly bool[] AllValid8 = [true, true, true, true, true, true, true, true];
    private static readonly bool[] SomeInvalid8 = [true, true, false, true, true, true, false, true];

    /// <summary>Gets the operations of the offset family: each value operation and its sibling.</summary>
    public static TheoryData<string> Identifiers =>
    [
        "sequence.first-true-offset", "sequence.first-true-offset-valid",
        "sequence.sum-over-offsets", "sequence.sum-over-offsets-valid",
        "sequence.maximum-over-offsets", "sequence.maximum-over-offsets-valid"
    ];

    /// <summary>Verifies the device result equals CoreCLR for every case, including the whole-call invalid ones.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(Identifiers))]
    public void CUDAEqualsCoreCLRBitForBit(string identifier)
    {
        ArgumentException.ThrowIfNullOrEmpty(identifier);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var series = new double[][]
        {
            [0d, 0d, 1d, 0d, 0d, 1d, 0d, 0d],
            [-0d, 0d, -0d, 0d, -0d, -0d, 0d, -0d],
            [1d, -2d, 3.5d, 1.7e308d, 1.7e308d, -4d, 0.25d, 8d],
            [-0d, -0d, -0d, -0d, -0d, -0d, -0d, -0d]
        };
        double[][] counts = [Counts8, GapCounts8, [0d, 1d, 2d, 3d, 4d, 5d, 6d, 0.5d], [0d, 1d, 2d, 3d, 4d, 5d, 6d, -1d]];
        bool[][] flags = [AllValid8, SomeInvalid8];
        (double Start, double End)[] ranges = [(0d, 0d), (0d, 2d), (-1d, 1d), (-2d, -1d), (1d, 3d), (2d, 1d), (0.5d, 1d), (-3d, 3d)];
        foreach (var rowSeries in series)
            foreach (var rowCounts in counts)
                foreach (var rowFlags in flags)
                    foreach (var (start, end) in ranges)
                        AssertSame(identifier, rowSeries, rowFlags, rowCounts, start, end);
    }

    private static void AssertSame(string identifier, double[] series, bool[] flags, double[] counts, double start, double end)
    {
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var firstTrue = identifier.StartsWith("sequence.first-true-offset", StringComparison.Ordinal);
        var validity = identifier.EndsWith("-valid", StringComparison.Ordinal);
        List<MathBlockValue> inputs =
        [
            MathBlockValue.Vector(series), MathBlockValue.BooleanVector(flags), MathBlockValue.Vector(counts),
            MathBlockValue.Scalar(start), MathBlockValue.Scalar(end)
        ];
        if (!validity)
        {
            if (firstTrue)
                inputs.Add(MathBlockValue.Scalar(77d));
            inputs.Add(MathBlockValue.Scalar(-9d));
        }
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = new int[inputs.Count];
        var named = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        for (var index = 0; index < nodes.Length; index++)
        {
            nodes[index] = builder.Input($"input-{index}", inputs[index].Type);
            named[$"input-{index}"] = inputs[index];
        }
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        var coreclr = program.Evaluate(named)["result"];
        using var compiled = new MathBlocksCUDAWorker().Compile(program, named);
        compiled.UploadInputs(named);
        compiled.ExecuteResident();
        var cuda = compiled.ReadOutputs()["result"];
        var description = $"{identifier} start={start} end={end}";
        Assert.True(coreclr.Type == cuda.Type, $"{description}: CoreCLR {coreclr.Type}, CUDA {cuda.Type}");
        Assert.True(coreclr.IsValid == cuda.IsValid, $"{description}: validity differs");
        if (!coreclr.IsValid)
            return;
        if (validity)
        {
            Assert.True(
                coreclr.AsBooleanVector().ToArray().AsSpan().SequenceEqual(cuda.AsBooleanVector().ToArray()),
                $"{description}: the row validity differs");
            return;
        }
        var expected = coreclr.AsVector();
        var actual = cuda.AsVector();
        Assert.Equal(expected.Count, actual.Count);
        for (var row = 0; row < expected.Count; row++)
        {
            Assert.True(
                BitConverter.DoubleToInt64Bits(expected[row]) == BitConverter.DoubleToInt64Bits(actual[row]),
                $"{description}: row {row} CoreCLR {expected[row]}, CUDA {actual[row]}");
        }
    }
}
