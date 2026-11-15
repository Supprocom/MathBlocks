using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Compares the CUDA kernels of the lead and lag forms with their CoreCLR evaluation, bit for bit.</summary>
public sealed class MathBlockSequenceShiftDeviceTests
{
    private static readonly double[] Series = [1d, 2d, -0d, 4d, 5d, 6d, 7d, 8d, 9d];
    private static readonly double[] Counts = [0d, 1d, 2d, 0d, 1d, 0d, 1d, 2d, 3d];
    private static readonly bool[] Available = [true, true, true, true, true, true, true, false, true];

    /// <summary>Gets the case names, one per input combination.</summary>
    public static TheoryData<string> CaseNames => [.. Cases().Keys.Order(StringComparer.Ordinal)];

    /// <summary>
    /// Verifies every form gives the CoreCLR result on the device for a chained series, a gap, a series start, the tail, an unavailable row,
    /// offsets 1, 2, the series length and far beyond it, and for every whole-call invalid input.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(CaseNames))]
    public void CUDAMatchesCoreCLR(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var inputs = Cases()[name];
        foreach (var identifier in new[] { "sequence.lead", "sequence.lead-valid", "sequence.lag", "sequence.lag-valid" })
        {
            var operation = MathBlockCatalog.Standard.Get(identifier, 1);
            var used = operation.Arity == 5 ? inputs : inputs[..4];
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var nodes = used.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
            var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
            var named = used.Select((input, index) => (Name: $"input-{index}", Input: input))
                .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
            var coreclr = program.Evaluate(named)["result"];
            using var compiled = new MathBlocksCUDAWorker().Compile(program, named);
            compiled.UploadInputs(named);
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];

            Assert.True(IsExact(coreclr, cuda), $"{identifier} {name}: CoreCLR {coreclr.IsValid} {coreclr.Type}, CUDA {cuda.IsValid} {cuda.Type}");
        }
    }

    private static Dictionary<string, MathBlockValue[]> Cases()
    {
        var cases = new Dictionary<string, MathBlockValue[]>(StringComparer.Ordinal);
        foreach (var offset in new[] { 1d, 2d, 3d, 8d, 9d, 10d, 1e300d, 0d, -1d, 0.5d, 1.5d })
            cases["offset-" + offset.ToString("R", CultureInfo.InvariantCulture)] = Make(Series, Available, Counts, offset);
        cases["bad-count-negative"] = Make(Series, Available, [0d, 1d, 2d, 0d, 1d, 0d, 1d, 2d, -1d], 1d);
        cases["bad-count-fraction"] = Make(Series, Available, [0d, 1d, 2d, 0d, 1d, 0.5d, 1d, 2d, 3d], 1d);
        cases["short-counts"] = Make(Series, Available, Counts[..8], 1d);
        cases["short-availability"] = Make(Series, Available[..8], Counts, 1d);
        cases["inconsistent-counts"] = Make(Series, Available, [5d, 5d, 5d, 0d, 5d, 5d, 0d, 5d, 5d], 2d);
        var random = new Random(0x1ead);
        for (var trial = 0; trial < 12; trial++)
        {
            var length = random.Next(1, 300);
            var values = new double[length];
            var flags = new bool[length];
            var counts = new double[length];
            for (var index = 0; index < length; index++)
            {
                values[index] = random.Next(-50, 50) * 0.25d;
                flags[index] = random.Next(5) != 0;
                counts[index] = index > 0 && random.Next(6) != 0 ? counts[index - 1] + 1d : 0d;
            }
            cases[$"random-{trial}"] = Make(values, flags, counts, random.Next(1, 6));
        }
        return cases;
    }

    private static MathBlockValue[] Make(double[] x, bool[] available, double[] counts, double offset) =>
    [
        MathBlockValue.Vector(x),
        MathBlockValue.BooleanVector(available),
        MathBlockValue.Vector(counts),
        MathBlockValue.Scalar(offset),
        MathBlockValue.Scalar(-99d)
    ];

    private static bool IsExact(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.IsValid != actual.IsValid || expected.Type.Kind != actual.Type.Kind)
            return false;
        if (!expected.IsValid)
            return true;
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
            return expected.AsBooleanVector().SequenceEqual(actual.AsBooleanVector());
        return expected.AsVector().Select(BitConverter.DoubleToInt64Bits)
            .SequenceEqual(actual.AsVector().Select(BitConverter.DoubleToInt64Bits));
    }
}
