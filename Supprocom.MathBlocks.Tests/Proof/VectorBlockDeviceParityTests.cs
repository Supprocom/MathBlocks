using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// Compares window.vector.standardize@1, vector.scale@1 and vector.subtract@1 on PatternResearcher's device route with CoreCLR, bit for bit in value and in validity: every input class and the
/// real market columns at 262,144 rows and at the short series (one row, the rows before a window is full, a full window), for every window width and scale factor of the proof. Each
/// dispatch of the route (the whole-vector contract, or the elementwise twin and its validity sibling, or the window form and its validity sibling) is compared with its CoreCLR evaluation.
/// </summary>
public sealed class VectorBlockDeviceParityTests
{
    private const int MaximumFailures = 20;

    /// <summary>Verifies vector.subtract@1 on the whole-vector route and on the lifted route.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForSubtract() => Compare(VectorBlockCalls.Subtract);

    /// <summary>Verifies vector.scale@1 for every scale factor on the whole-vector route and on the lifted route.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForScale() => Compare(VectorBlockCalls.Scale);

    /// <summary>Verifies window.vector.standardize@1 and its validity sibling for every window width.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForStandardize() => Compare(VectorBlockCalls.Standardize);

    /// <summary>
    /// Verifies the three identities plan no scratch at any window width and scale factor: PatternResearcher's in-kernel route gives a dispatch no scratch pointer and holds out a form that needs
    /// scratch (the layered general plan's ScratchFree check plans on a prototype). A form that plans scratch would not exist on that route.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void TheRouteNeedsNoScratch()
    {
        var failures = new List<string>();
        var calls = VectorBlockCalls.All(includeLifted: true);
        var first = ProofSets.ForRows(VectorBlockCalls.ParityRows, includeReal: false)[0];
        for (var callIndex = 0; callIndex < calls.Count; callIndex++)
        {
            for (var step = 0; step < calls[callIndex].Contracts.Length; step++)
            {
                var inputs = VectorBlockCalls.Inputs(calls[callIndex], step, VectorBlockCalls.Clean(first.First), VectorBlockCalls.Clean(first.Second));
                var scratch = MathBlockCudaDeviceModule.GetOperation(calls[callIndex].Contracts[step]).PlanCUDA(inputs).ScratchBytes;
                Console.WriteLine(string.Create(CultureInfo.InvariantCulture, $"{calls[callIndex].Contracts[step]} {calls[callIndex].Parameter}: planned scratch {scratch} bytes"));
                if (scratch != 0)
                    failures.Add(string.Create(CultureInfo.InvariantCulture, $"{calls[callIndex].Contracts[step]} {calls[callIndex].Parameter}: planned scratch is {scratch} bytes"));
            }
        }

        ProofBar.Fail("Scratch of the route", failures);
    }

    private static void Compare(string identity)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        if (ProofRealData.Get() is null)
            Console.WriteLine(string.Create(CultureInfo.InvariantCulture, $"Real market class skipped: {ProofRealData.SkipReason}"));
        var failures = new List<string>();
        using var device = new VectorBlockDevice();
        var calls = VectorBlockCalls.All(includeLifted: true);
        for (var callIndex = 0; callIndex < calls.Count; callIndex++)
        {
            var call = calls[callIndex];
            if (!string.Equals(call.Identity, identity, StringComparison.Ordinal))
                continue;
            int[] lengths = [VectorBlockCalls.ParityRows, .. VectorBlockCalls.ShortRows(call)];
            for (var lengthIndex = 0; lengthIndex < lengths.Length; lengthIndex++)
                CompareCall(device, call, lengths[lengthIndex], failures);
        }

        ProofBar.Fail(identity, failures);
    }

    private static void CompareCall(VectorBlockDevice device, VectorBlockCall call, int rows, List<string> failures)
    {
        var sets = ProofSets.ForRows(rows, includeReal: true);
        for (var setIndex = 0; setIndex < sets.Length; setIndex++)
        {
            var first = VectorBlockCalls.Clean(sets[setIndex].First);
            var second = VectorBlockCalls.Clean(sets[setIndex].Second);
            using var run = device.Prepare(call, first, second);
            var actual = run.Execute();
            for (var step = 0; step < actual.Length && failures.Count < MaximumFailures; step++)
            {
                var expected = MathBlockCudaDeviceModule.GetOperation(call.Contracts[step]).EvaluateCoreCLR(VectorBlockCalls.Inputs(call, step, first, second));
                var difference = VectorBlockReference.Difference(expected, actual[step]);
                if (difference is not null)
                    failures.Add(string.Create(CultureInfo.InvariantCulture, $"{call.Contracts[step]} {call.Route} {call.Parameter} class {sets[setIndex].Name} rows {rows}: {difference}"));
            }
        }
    }
}
