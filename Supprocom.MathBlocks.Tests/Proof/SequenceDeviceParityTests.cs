using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// Compares the six new sequence operations and their -valid siblings on CUDA with CoreCLR, bit for bit, over the same input-class matrix, counts classes and parameter range
/// as the CoreCLR safety sweep, including parameter settings that make the whole call invalid. Each operation is compiled once and run on every case.
/// </summary>
public sealed class SequenceDeviceParityTests
{
    private const int Rows = 1200;
    private const int GapPeriod = 7;
    private const int SeriesPeriod = 101;
    private const int MaximumFailures = 20;

    /// <summary>Verifies lead and lag with their siblings.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForLeadAndLag()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        Compare("lead");
        Compare(SequenceOps.Lag);
    }

    /// <summary>Verifies first-true-offset, sum-over-offsets and maximum-over-offsets with their siblings.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheOffsetOperations()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        Compare(SequenceOps.FirstTrue);
        Compare("sum-over-offsets");
        Compare("maximum-over-offsets");
    }

    /// <summary>
    /// Verifies maximum-over-offsets and its sibling over the spans of the timing tests and of the CoreCLR safety sweep (which reach 700 either side of a row) and over series of positive and negative zeros, so the bits of a zero
    /// maximum and the validity of every row are those of CoreCLR for each class, counts class and span the timing bars measure.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForMaximumOverOffsetsAtTheTimingSpansAndSignedZeros()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var sets = ProofSets.ForSequences(Rows, includeReal: true, includeAllFalse: true);
        var zeros = new float[Rows];
        var zeroAvailable = new bool[Rows];
        var random = new Random(20261120);
        for (var row = 0; row < Rows; row++)
        {
            zeros[row] = random.Next(0, 6) switch { 0 => 0f, 1 => -0f, 2 => -0f, 3 => 0f, 4 => -1.5f, _ => 2.5f };
            zeroAvailable[row] = random.NextSingle() >= 0.05f;
        }

        ProofSet[] all = [.. sets, new ProofSet("SignedZeros", zeros, [], zeros, zeroAvailable)];
        ProofParameter[] spans = [.. SequenceOps.SpanTiming, .. SequenceOps.SpanSafety];
        Compare("maximum-over-offsets", all, spans);
    }

    /// <summary>Verifies the prefix difference over offsets with its sibling.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForThePrefixDifference()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        Compare("prefix-difference-over-offsets");
    }

    private static void Compare(string name) =>
        Compare(name, ProofSets.ForSequences(Rows, includeReal: true, includeAllFalse: true), SequenceOps.Parameters(name, SequenceOps.ShiftDevice, SequenceOps.SpanDevice));

    private static void Compare(string name, ProofSet[] sets, ProofParameter[] parameters)
    {
        var failures = new List<string>();
        var worker = new MathBlocksCUDAWorker();
        for (var sibling = 0; sibling < 2; sibling++)
        {
            var operation = SequenceOps.Operation(name, sibling == 1);
            var prototype = Case(name, sibling == 1, sets[0], 0, parameters[0]);
            using var compiled = worker.Compile(ProofPrograms.Build(operation, prototype), ProofPrograms.Named(prototype));
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
            {
                for (var kind = 0; kind < ProofCounts.SafetyKinds; kind++)
                {
                    for (var parameterIndex = 0; parameterIndex < parameters.Length; parameterIndex++)
                    {
                        var inputs = Case(name, sibling == 1, sets[setIndex], kind, parameters[parameterIndex]);
                        var label = $"{operation.Identity} class {sets[setIndex].Name} counts {ProofCounts.Name(kind, GapPeriod, SeriesPeriod)} parameter {parameters[parameterIndex].Label}";
                        var coreclr = operation.Evaluate(inputs);
                        compiled.UploadInputs(ProofPrograms.Named(inputs));
                        compiled.ExecuteResident();
                        var cuda = compiled.ReadOutputs()["result"];
                        Difference(label, coreclr, cuda, failures);
                    }
                }
            }
        }

        ProofBar.Fail(name, failures);
    }

    private static MathBlockValue[] Case(string name, bool sibling, ProofSet set, int kind, ProofParameter parameter)
    {
        var series = MathBlockValue.Vector(SequenceOps.Series(name, set));
        var availability = MathBlockValue.BooleanVector(set.Available);
        var counts = MathBlockValue.Vector(ProofCounts.Build(kind, Rows, GapPeriod, SeriesPeriod));
        return SequenceOps.Inputs(name, sibling, series, availability, counts, parameter.First, parameter.Second);
    }

    private static void Difference(string label, MathBlockValue expected, MathBlockValue actual, List<string> failures)
    {
        if (failures.Count >= MaximumFailures)
            return;
        if (expected.Type != actual.Type || expected.IsValid != actual.IsValid)
        {
            failures.Add($"{label}: CoreCLR {expected.Type} valid {expected.IsValid}, CUDA {actual.Type} valid {actual.IsValid}");
            return;
        }

        if (!expected.IsValid)
            return;
        if (expected.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            if (!expected.AsBooleanVector().ToArray().AsSpan().SequenceEqual(actual.AsBooleanVector().ToArray()))
                failures.Add(label + ": the row validity differs.");
            return;
        }

        var left = expected.AsVector().ToArray();
        var right = actual.AsVector().ToArray();
        for (var row = 0; row < left.Length && failures.Count < MaximumFailures; row++)
        {
            if (BitConverter.SingleToInt32Bits(left[row]) != BitConverter.SingleToInt32Bits(right[row]))
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{label} row {row}: CoreCLR {left[row]:R}, CUDA {right[row]:R}"));
        }
    }
}
