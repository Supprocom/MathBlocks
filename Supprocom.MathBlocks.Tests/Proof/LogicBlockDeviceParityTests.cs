using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>
/// Compares the logic blocks on the plain device route (the whole-vector contract that the dispatch kernel runs, one dispatch per case) with CoreCLR, bit for bit in value and in
/// validity. The cases hold NaN, both infinities, signed zeros, subnormals and the largest magnitudes as scalars (a scalar that is not finite is an invalid value), Boolean operands that
/// are true, false and invalid, and vector operands where one operand, or all, are invalid. <c>boolean-vector.any@1</c> and <c>boolean-vector.all@1</c> are whole-vector reducers with no
/// window form: their parity here is the whole-vector route's only.
/// </summary>
public sealed class LogicBlockDeviceParityTests
{
    private const int MaximumFailures = 20;

    /// <summary>Verifies the scalar comparisons, including not-equal, greater-or-equal and less-or-equal that exist in the catalog.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheScalarComparisons() => Compare(LogicBlocks.ScalarComparisons);

    /// <summary>Verifies the scalar select over every condition (true, false, invalid) and every pair of the grid.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheScalarSelect() => Compare([LogicBlocks.ScalarSelect]);

    /// <summary>Verifies the Boolean and, or, xor and not over true, false and invalid operands.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheBooleanBlocks() => Compare([.. LogicBlocks.BooleanBinary, LogicBlocks.BooleanNot]);

    /// <summary>Verifies boolean-vector.any and boolean-vector.all, which are whole-vector reducers (no window form exists), including the empty vector and an invalid operand.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheWholeVectorReducersAnyAndAll() => Compare(LogicBlocks.WholeVectorReducers);

    /// <summary>Verifies the vector comparisons and the vector select.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheVectorComparisonsAndSelect() => Compare([.. LogicBlocks.VectorComparisons, LogicBlocks.VectorSelect]);

    /// <summary>Verifies the Boolean-vector and, or, xor and not.</summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatchesCoreCLRForTheBooleanVectorBlocks() => Compare([.. LogicBlocks.BooleanVectorBinary, LogicBlocks.BooleanVectorNot]);

    private static void Compare(string[] identities)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var failures = new List<string>();
        using var device = new VectorBlockDevice();
        for (var identityIndex = 0; identityIndex < identities.Length; identityIndex++)
        {
            var identity = identities[identityIndex];
            var contract = MathBlockCudaDeviceModule.GetOperation(identity);
            var cases = LogicBlocks.ParityCases(identity);
            var call = new VectorBlockCall(identity, "plain", "-", 1f, 0f, [.. Enumerable.Repeat(identity, cases.Count)], cases.Count);
            using var run = new VectorBlockRun(device, call, [.. cases]);
            var actual = run.Execute();
            var invalid = 0;
            var valid = 0;
            for (var index = 0; index < cases.Count; index++)
            {
                var expected = contract.EvaluateCoreCLR(cases[index]);
                if (expected.IsValid)
                    valid++;
                else
                    invalid++;
                var difference = LogicBlocks.Difference(expected, actual[index]);
                if (difference is not null && failures.Count < MaximumFailures)
                    failures.Add(string.Create(CultureInfo.InvariantCulture, $"{identity} case {index} ({LogicBlocks.Describe(cases[index])}): {difference}"));
            }

            Console.WriteLine(string.Create(CultureInfo.InvariantCulture, $"{identity}: {cases.Count} cases, {valid} valid and {invalid} invalid on CoreCLR"));
            Assert.True(valid > 0 && invalid > 0, $"{identity}: the cases must cover valid and invalid results");
        }

        ProofBar.Fail("Logic block parity", failures);
    }
}
