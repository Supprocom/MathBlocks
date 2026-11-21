using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Compares the CUDA kernels of the lead and lag forms with their CoreCLR evaluation, bit for bit.</summary>
public sealed class MathBlockSequenceShiftDeviceTests
{
    private static readonly float[] Series = [1f, 2f, -0f, 4f, 5f, 6f, 7f, 8f, 9f];
    private static readonly float[] Counts = [0f, 1f, 2f, 0f, 1f, 0f, 1f, 2f, 3f];
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
        foreach (var offset in new[] { 1f, 2f, 3f, 8f, 9f, 10f, 3.16e37f, 0f, -1f, 0.5f, 1.5f })
            cases["offset-" + offset.ToString("R", CultureInfo.InvariantCulture)] = Make(Series, Available, Counts, offset);
        cases["bad-count-negative"] = Make(Series, Available, [0f, 1f, 2f, 0f, 1f, 0f, 1f, 2f, -1f], 1f);
        cases["bad-count-fraction"] = Make(Series, Available, [0f, 1f, 2f, 0f, 1f, 0.5f, 1f, 2f, 3f], 1f);
        cases["short-counts"] = Make(Series, Available, Counts[..8], 1f);
        cases["short-availability"] = Make(Series, Available[..8], Counts, 1f);
        cases["inconsistent-counts"] = Make(Series, Available, [5f, 5f, 5f, 0f, 5f, 5f, 0f, 5f, 5f], 2f);
        var random = new Random(0x1ead);
        for (var trial = 0; trial < 12; trial++)
        {
            var length = random.Next(1, 300);
            var values = new float[length];
            var flags = new bool[length];
            var counts = new float[length];
            for (var index = 0; index < length; index++)
            {
                values[index] = random.Next(-50, 50) * 0.25f;
                flags[index] = random.Next(5) != 0;
                counts[index] = index > 0 && random.Next(6) != 0 ? counts[index - 1] + 1f : 0f;
            }
            cases[$"random-{trial}"] = Make(values, flags, counts, random.Next(1, 6));
        }
        return cases;
    }

    private static MathBlockValue[] Make(float[] x, bool[] available, float[] counts, float offset) =>
    [
        MathBlockValue.Vector(x),
        MathBlockValue.BooleanVector(available),
        MathBlockValue.Vector(counts),
        MathBlockValue.Scalar(offset),
        MathBlockValue.Scalar(-99f)
    ];

    private static bool IsExact(MathBlockValue expected, MathBlockValue actual)
    {
        if (expected.IsValid != actual.IsValid || expected.Type.Kind != actual.Type.Kind)
            return false;
        if (!expected.IsValid)
            return true;
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
            return expected.AsBooleanVector().SequenceEqual(actual.AsBooleanVector());
        return expected.AsVector().Select(BitConverter.SingleToInt32Bits)
            .SequenceEqual(actual.AsVector().Select(BitConverter.SingleToInt32Bits));
    }
}
