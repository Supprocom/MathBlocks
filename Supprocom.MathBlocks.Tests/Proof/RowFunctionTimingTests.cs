using System.Globalization;
using Supprocom.MathBlocks.Cuda;
using static Supprocom.MathBlocks.Tests.MathBlockElementwiseTestSupport;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// The speed proof of the per-row device functions: one kernel per function and input class over a million rows, timed as the median of five batches after a warm-up batch, in
/// nanoseconds per row, next to a kernel that does the same plain arithmetic inline and, for the typical class, next to the per-node elementwise dispatch route that the main era
/// ran (the elementwise form and its sibling as two graph nodes, which also move the operands and results through the host). The numbers go to l2-device-timing.tsv.
/// </summary>
public sealed class RowFunctionTimingTests
{
    private const int Rows = 1_000_000;
    private const int Batch = 8;
    private const float WorstClassFactor = 2f;
    private const float InlineFactor = 2f;
    private const string SumName = "sum";

    /// <summary>
    /// Verifies bars (i) and (ii): the worst class, and the class that interleaves all classes inside each 32-row warp, cost at most twice the median class; and bar (iv): each row
    /// function costs at most twice the inline arithmetic and no more than the per-node dispatch.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "Performance")]
    public void RowFunctionsAreConsistentlyFastAndNoSlowerThanInlineArithmeticOrTheDispatch()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var sets = ProofSets.ForRows(Rows, includeReal: true);
        if (ProofRealData.Get() is null)
            Console.WriteLine($"Real market class skipped: {ProofRealData.SkipReason}");
        var dispatch = DispatchNanoseconds(sets[0]);
        var cells = new List<ProofCell>();
        using (var session = new ProofDeviceSession(RowFunctionKernels.Source(), "proof-row-timing.cu"))
        {
            var rig = new Rig(session);
            for (var setIndex = 0; setIndex < sets.Length; setIndex++)
            {
                rig.Upload(sets[setIndex]);
                for (var functionIndex = 0; functionIndex < RowFunctionOp.All.Length; functionIndex++)
                {
                    var function = RowFunctionOp.All[functionIndex];
                    var (row, baseline) = rig.Measure(function.Name, rig.OperandArguments);
                    cells.Add(new ProofCell(function.Name, sets[setIndex].Name, "-", "rows=1000000", 1f, row, baseline, setIndex == 0 ? dispatch[functionIndex] : 0f));
                }

                var (sumRow, sumBaseline) = rig.Measure(SumName, rig.SumArguments);
                cells.Add(new ProofCell(SumName, sets[setIndex].Name, "-", "rows=1000000", 1f, sumRow, sumBaseline, 0f));
            }
        }

        ProofBar.Annotate(cells);
        _ = ProofReport.WriteText("l2-device-timing.tsv", ProofBar.Render(cells));
        ProofBar.AssertWorstClassWithinTwiceMedian(cells, _ => true);
        AssertMixedWarp(cells);
        AssertAbsolute(cells);
    }

    // Bar (ii) on its own, so the failure names the class.
    private static void AssertMixedWarp(List<ProofCell> cells)
    {
        var failures = new List<string>();
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (string.Equals(cell.ClassName, nameof(ProofClass.Mixed), StringComparison.Ordinal) && cell.MedianRatio > WorstClassFactor)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{cell.Operation}: the mixed warp costs {cell.MedianRatio:F2} times the median class"));
        }

        ProofBar.Fail("Bar (ii), mixed warp against the median class", failures);
    }

    // Bar (iv): at most twice the inline arithmetic in every class, and no slower than the per-node dispatch in the typical class.
    private static void AssertAbsolute(List<ProofCell> cells)
    {
        var failures = new List<string>();
        for (var index = 0; index < cells.Count; index++)
        {
            var cell = cells[index];
            if (cell.ReferenceRatio > InlineFactor)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{cell.Operation} class {cell.ClassName}: {cell.ReferenceRatio:F2} times the inline arithmetic (limit {InlineFactor:F2})"));
            if (cell.SecondReferenceNanosecondsPerRow > 0f && cell.SecondReferenceRatio > 1f)
                failures.Add(string.Create(CultureInfo.InvariantCulture, $"{cell.Operation} class {cell.ClassName}: {cell.SecondReferenceRatio:F2} times the per-node dispatch (limit 1)"));
        }

        ProofBar.Fail("Bar (iv), absolute budget", failures);
    }

    // The main-era route: the elementwise form and its sibling as two graph nodes, run back to back in batches, per function on the typical class.
    private static float[] DispatchNanoseconds(ProofSet typical)
    {
        var worker = new MathBlocksCUDAWorker();
        var result = new float[RowFunctionOp.All.Length];
        for (var index = 0; index < result.Length; index++)
        {
            var function = RowFunctionOp.All[index];
            var formInputs = RowFunctionForms.FormInputs(function, typical);
            var validityInputs = RowFunctionForms.ValidityInputs(function, typical);
            using var form = worker.Compile(ProofPrograms.Build(Form(function.ScalarIdentifier), formInputs), ProofPrograms.Named(formInputs));
            using var validity = worker.Compile(ProofPrograms.Build(Validity(function.ScalarIdentifier), validityInputs), ProofPrograms.Named(validityInputs));
            form.UploadInputs(ProofPrograms.Named(formInputs));
            validity.UploadInputs(ProofPrograms.Named(validityInputs));
            result[index] = ProofTiming.NanosecondsPerRow(
                () =>
                {
                    for (var repeat = 0; repeat < Batch; repeat++)
                    {
                        form.ExecuteResident();
                        validity.ExecuteResident();
                    }

                    form.Synchronize();
                    validity.Synchronize();
                },
                (long)Rows * Batch);
        }

        return result;
    }

    // The device buffers and the prepared argument blocks of the timing kernels.
    private sealed class Rig
    {
        private readonly ProofDeviceSession session;
        private readonly ulong first;
        private readonly ulong second;
        private readonly ulong sumValues;

        internal Rig(ProofDeviceSession session)
        {
            this.session = session;
            first = session.Allocate(Rows * (long)sizeof(float));
            second = session.Allocate(Rows * (long)sizeof(float));
            sumValues = session.Allocate(Rows * (long)RowFunctionKernels.SumCount * sizeof(float));
            var values = session.Allocate(Rows * (long)sizeof(float));
            var valid = session.Allocate(Rows * (long)sizeof(int));
            OperandArguments = session.Arguments(Rows, RowFunctionHarness.Fill, first, second, values, valid);
            SumArguments = session.Arguments(Rows, RowFunctionKernels.SumCount, RowFunctionHarness.Fill, sumValues, values, valid);
        }

        internal IntPtr OperandArguments { get; }

        internal IntPtr SumArguments { get; }

        // Uploads the operands, and the row-sum values built from them.
        internal void Upload(ProofSet set)
        {
            ProofDeviceSession.Upload(first, set.First);
            ProofDeviceSession.Upload(second, set.Second);
            ProofDeviceSession.Upload(sumValues, RowFunctionForms.SumValues(set, RowFunctionKernels.SumCount));
        }

        // The time per row of the row function and of the inline baseline, in that order.
        internal (float Row, float Baseline) Measure(string name, IntPtr arguments)
        {
            var row = session.Function("proof_row_" + name);
            var baseline = session.Function("proof_base_" + name);
            return (Time(row, arguments), Time(baseline, arguments));
        }

        private static float Time(IntPtr function, IntPtr arguments) =>
            ProofTiming.NanosecondsPerRow(() => ProofDeviceSession.LaunchBatch(function, arguments, Rows, Batch), (long)Rows * Batch);
    }
}
