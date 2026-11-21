using System.Globalization;
using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The safety proof of the per-row device functions on a CUDA device: for each of the six functions and for the row sum, over the input-class matrix (typical market values, counts,
/// extreme magnitudes, near-overflow pairs, subnormals, NaN and infinities, domain edges, Mixed and the real market columns), the value bits and the validity equal the elementwise
/// row function for the same source (in both opcode encodings), the elementwise forms that the worker dispatches, and the CoreCLR scalar operations.
/// </summary>
public sealed class RowFunctionParityTests
{
    private const int Rows = 8192;
    private const int SumRows = 4096;
    private const int MaximumFailures = 20;

    /// <summary>Verifies each row function against the elementwise row function in both encodings and against the CoreCLR scalar operation, row by row.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void EveryRowFunctionMatchesTheElementwiseRowAndTheScalarOperationOverTheClassMatrix()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var sets = ProofSets.ForRows(Rows, includeReal: true);
        ReportRealSkip();
        using var harness = new RowFunctionHarness(Rows);
        var failures = new List<string>();
        for (var functionIndex = 0; functionIndex < RowFunctionOp.All.Length; functionIndex++)
        {
            var function = RowFunctionOp.All[functionIndex];
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
                CompareRows(function, sets[setIndex], harness.Run(function, sets[setIndex].First, sets[setIndex].Second), failures);
        }

        ProofBar.Fail("Row functions", failures);
    }

    /// <summary>Verifies the row sum against a CoreCLR left-to-right chain of the add operation under the add rule, for counts of 0, 1, 2, 7, 8 and 33 values per row.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void TheRowSumMatchesACoreCLRAddChainOverTheClassMatrix()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var sets = ProofSets.ForRows(SumRows, includeReal: true);
        using var harness = new RowFunctionHarness(SumRows);
        var failures = new List<string>();
        int[] counts = [0, 1, 2, 7, 8, RowFunctionHarness.MaximumSumCount];
        for (var countIndex = 0; countIndex < counts.Length; countIndex++)
        {
            var count = counts[countIndex];
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
            {
                var values = RowFunctionForms.SumValues(sets[setIndex], count);
                var result = harness.RunSum(values, count);
                CompareSums(sets[setIndex].Name, count, values, result, failures);
            }
        }

        ProofBar.Fail("Row sum", failures);
    }

    /// <summary>
    /// Verifies the row functions against the elementwise form and sibling that the worker dispatches as graph nodes, on every class whose values a vector can hold
    /// (the classes without NaN and infinities).
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void EveryRowFunctionMatchesTheWorkerElementwiseForms()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var sets = ProofSets.ForRows(Rows, includeReal: true);
        using var harness = new RowFunctionHarness(Rows);
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        for (var functionIndex = 0; functionIndex < RowFunctionOp.All.Length; functionIndex++)
        {
            var function = RowFunctionOp.All[functionIndex];
            var formPrototype = RowFunctionForms.FormInputs(function, sets[0]);
            var validityPrototype = RowFunctionForms.ValidityInputs(function, sets[0]);
            using var form = worker.Compile(ProofPrograms.Build(Form(function.ScalarIdentifier), formPrototype), ProofPrograms.Named(formPrototype));
            using var validity = worker.Compile(ProofPrograms.Build(Validity(function.ScalarIdentifier), validityPrototype), ProofPrograms.Named(validityPrototype));
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
            {
                var set = sets[setIndex];
                if (!IsFinite(set.First) || !IsFinite(set.Second))
                    continue;
                var rows = harness.Run(function, set.First, set.Second);
                form.UploadInputs(ProofPrograms.Named(RowFunctionForms.FormInputs(function, set)));
                form.ExecuteResident();
                validity.UploadInputs(ProofPrograms.Named(RowFunctionForms.ValidityInputs(function, set)));
                validity.ExecuteResident();
                CompareWorker(function.Name + " " + set.Name, rows, form.ReadOutputs()["result"].AsVector().ToArray(), validity.ReadOutputs()["result"].AsBooleanVector().ToArray(), failures);
            }
        }

        ProofBar.Fail("Worker elementwise forms", failures);
    }

    private static void ReportRealSkip()
    {
        if (ProofRealData.Get() is null)
            Console.WriteLine($"Real market class skipped: {ProofRealData.SkipReason}");
    }

    private static bool IsFinite(float[] values)
    {
        for (var index = 0; index < values.Length; index++)
        {
            if (!float.IsFinite(values[index]))
                return false;
        }

        return true;
    }

    private static void CompareRows(RowFunctionOp function, ProofSet set, ParityResult result, List<string> failures)
    {
        var fillBits = BitConverter.SingleToInt32Bits(RowFunctionHarness.Fill);
        for (var row = 0; row < set.First.Length && failures.Count < MaximumFailures; row++)
        {
            var valid = ProofScalarReference.Apply(function, set.First[row], set.Second[row], out var value);
            var expectedBits = valid ? BitConverter.SingleToInt32Bits(value) : fillBits;
            var expectedFlag = valid ? 1 : 0;
            if (result.RowValid[row] != expectedFlag || result.RowBits[row] != expectedBits ||
                result.NarrowValid[row] != expectedFlag || result.NarrowBits[row] != expectedBits ||
                result.WideValid[row] != expectedFlag || result.WideBits[row] != expectedBits)
            {
                failures.Add(string.Create(
                    CultureInfo.InvariantCulture,
                    $"{function.Name} class {set.Name} row {row} ({set.First[row]:R}, {set.Second[row]:R}): CoreCLR {BitConverter.Int32BitsToSingle((int)expectedBits):R}/{expectedFlag}, row function {BitConverter.Int32BitsToSingle((int)result.RowBits[row]):R}/{result.RowValid[row]}, elementwise row {BitConverter.Int32BitsToSingle((int)result.NarrowBits[row]):R}/{result.NarrowValid[row]}, wide {BitConverter.Int32BitsToSingle((int)result.WideBits[row]):R}/{result.WideValid[row]}"));
            }
        }
    }

    private static void CompareSums(string setName, int count, float[] values, (long[] Bits, int[] Valid) result, List<string> failures)
    {
        var fillBits = BitConverter.SingleToInt32Bits(RowFunctionHarness.Fill);
        for (var row = 0; row < result.Bits.Length && failures.Count < MaximumFailures; row++)
        {
            var valid = ProofScalarReference.Sum(values, row * count, count, out var sum);
            var expectedBits = valid ? BitConverter.SingleToInt32Bits(sum) : fillBits;
            if (result.Valid[row] != (valid ? 1 : 0) || result.Bits[row] != expectedBits)
            {
                failures.Add(string.Create(
                    CultureInfo.InvariantCulture,
                    $"row sum class {setName} count {count} row {row}: CoreCLR {BitConverter.Int32BitsToSingle((int)expectedBits):R}/{valid}, device {BitConverter.Int32BitsToSingle((int)result.Bits[row]):R}/{result.Valid[row]}"));
            }
        }
    }

    private static void CompareWorker(string label, ParityResult device, float[] formValues, bool[] validity, List<string> failures)
    {
        for (var row = 0; row < formValues.Length && failures.Count < MaximumFailures; row++)
        {
            if (BitConverter.SingleToInt32Bits(formValues[row]) != device.RowBits[row] || validity[row] != (device.RowValid[row] != 0))
            {
                failures.Add(string.Create(
                    CultureInfo.InvariantCulture,
                    $"{label} row {row}: worker {formValues[row]:R}/{validity[row]}, row function {BitConverter.Int32BitsToSingle((int)device.RowBits[row]):R}/{device.RowValid[row]}"));
            }
        }
    }
}
