using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// CoreCLR/CUDA parity of sequence.prefix-difference-over-offsets@1 and its validity sibling: the bits of every row, the
// type, the shape and the whole-call invalid state of the CUDA output equal the CoreCLR evaluation on the same inputs.
public sealed partial class MathBlockCudaWorkerTests
{
    /// <summary>
    /// Verifies the form and the sibling on the shared contract cases, on the whole-call invalid cases, and on seeded series of
    /// 1, 2, 7, 127, 128, 129 and 1,000 rows with random segments, unavailable rows and windows.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAPrefixDifferenceMatchesTheCoreCLROnContractCasesAndSeededSeries()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var worker = new MathBlocksCUDAWorker();
        var failures = new List<string>();
        var cases = new List<(string Name, MathBlockValue[] Inputs)>();
        foreach (var (name, inputs) in PrefixDifferenceCases.Valid())
            if (!string.Equals(name, "empty", StringComparison.Ordinal))
                cases.Add((name, inputs));
        cases.AddRange(PrefixDifferenceCases.WholeCallInvalid());
        foreach (var length in new[] { 1, 2, 7, 127, 128, 129, 1_000 })
            for (var seed = 0; seed < 4; seed++)
                cases.Add(($"seeded-{length}-{seed}", SeededInputs(length, seed)));
        for (var index = 0; index < cases.Count; index++)
        {
            var (name, inputs) = cases[index];
            foreach (var identity in new[] { PrefixDifferenceCases.Form, PrefixDifferenceCases.Validity })
            {
                var operation = PrefixDifferenceCases.Operation(identity);
                var operationInputs = string.Equals(identity, PrefixDifferenceCases.Validity, StringComparison.Ordinal)
                    ? PrefixDifferenceCases.ValidityInputs(inputs)
                    : inputs;
                var coreclr = operation.Evaluate(operationInputs);
                var cuda = ExecuteElementwiseCase(worker, operation, operationInputs, operationInputs);
                if (DescribeWindowDifference(coreclr, cuda) is { } difference)
                    failures.Add($"{identity}/{name}: {difference}");
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(60)));
    }

    // Values of both signs and magnitudes, about one row in six unavailable, a segment break about one row in twenty, and
    // a window that is random but bounded by the series length.
    private static MathBlockValue[] SeededInputs(int length, int seed)
    {
        var random = new Random(7_100 + length * 31 + seed);
        var values = new float[length];
        var available = new bool[length];
        var counts = new float[length];
        var run = 0f;
        for (var row = 0; row < length; row++)
        {
            values[row] = (random.NextSingle() - 0.5f) * MathF.Pow(10f, random.Next(-3, 6));
            available[row] = random.Next(6) != 0;
            run = row == 0 || random.Next(20) == 0 ? 0f : run + 1f;
            counts[row] = run;
        }

        var start = random.Next(-5, 3);
        var end = start + random.Next(0, 6);
        return PrefixDifferenceCases.FormInputs(values, available, counts, start, end);
    }
}
