using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the CUDA device tests of the operations whose output is a square matrix of a runtime size, at a raised size and at the option's maximum:
/// state.transition-counts@1 and matrix.identity@1. The matrices hold 8,192 x 8,192 and 16,383 x 16,383 doubles (537 MB and 2.1 GB), so these tests
/// are kept apart from the device tests that fit a 4 GB cap, in the category CudaDeviceLarge. Each compares the CUDA result with the CoreCLR result by a checksum of
/// every element and by sampled rows, and holds one matrix at a time instead of two.
/// </summary>
public sealed class MathBlockCudaDomainLargeDeviceTests
{
    // The option maximum for both options: floor(sqrt((2^31 - 1) / 8)).
    private const int Maximum = 16_383;
    private const int Raised = 8_192;

    /// <summary>Gets the cases, each named <c>size:identity</c>: a raised size and the option's maximum for each operation.</summary>
    internal static IEnumerable<(string Name, MathBlockDomainWiringTests.Case Case)> Cases()
    {
        foreach (var (label, size) in new[] { ("raised", Raised), ("maximum", Maximum) })
        {
            yield return (
                $"{label}:state.transition-counts@1",
                new("state.transition-counts@1", [MathBlockValue.Vector([0d, 1d, size - 1d, 1d, 2d, 0d]), MathBlockValue.Scalar(size)], new() { MaximumStateCount = size }));
            yield return (
                $"{label}:matrix.identity@1",
                new("matrix.identity@1", [MathBlockValue.Scalar(size)], new() { MaximumMatrixSize = size }));
        }
    }

    /// <summary>Gets the case names.</summary>
    public static TheoryData<string> CaseNames()
    {
        var data = new TheoryData<string>();
        foreach (var (name, _) in Cases())
            data.Add(name);
        return data;
    }

    // The checksum of every element, the element sum, and the bits of the sampled rows.
    private sealed record Summary(bool Valid, int Rows, int Columns, ulong Checksum, double Sum, ulong[][] SampledRows);

    private static Summary Summarize(MathBlockValue value, int[] sampledRows)
    {
        if (!value.IsValid)
            return new Summary(false, 0, 0, 0ul, 0d, []);
        var matrix = value.AsMatrix();
        var checksum = 14695981039346656037ul;
        var sum = 0d;
        for (var row = 0; row < matrix.Rows; row++)
        {
            for (var column = 0; column < matrix.Columns; column++)
            {
                var element = matrix[row, column];
                checksum = (checksum ^ BitConverter.DoubleToUInt64Bits(element)) * 1099511628211ul;
                sum += element;
            }
        }

        var sampled = new ulong[sampledRows.Length][];
        for (var index = 0; index < sampled.Length; index++)
        {
            sampled[index] = new ulong[matrix.Columns];
            for (var column = 0; column < matrix.Columns; column++)
                sampled[index][column] = BitConverter.DoubleToUInt64Bits(matrix[sampledRows[index], column]);
        }

        return new Summary(true, matrix.Rows, matrix.Columns, checksum, sum, sampled);
    }

    /// <summary>Verifies the CUDA result has the CoreCLR shape, element checksum, element sum and sampled rows, at a raised size and at the option's maximum.</summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [Trait("Category", "CudaDeviceLarge")]
    [MemberData(nameof(CaseNames))]
    public void CUDAMatchesCoreCLRAtLargeSquareMatrixSizes(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var item = Cases().First(candidate => string.Equals(candidate.Name, name, StringComparison.Ordinal)).Case;
        var (program, inputs) = MathBlockCudaDomainDeviceTests.Build(item.Identity, item.Inputs);
        var size = (int)item.Inputs[^1].AsScalar();
        int[] sampledRows = [0, 1, 2, size / 2, size - 2, size - 1];

        // The CoreCLR matrix is summarized and released before the CUDA run starts, so the two matrices are never held together.
        var reference = Summarize(MathBlocksCoreCLRWorker.Create(item.Other).Execute(program, inputs)["result"], sampledRows);
        GC.Collect();
        GC.WaitForPendingFinalizers();
        Assert.True(reference.Valid, $"{name}: the CoreCLR result is invalid.");
        Assert.Equal(size, reference.Rows);
        Assert.Equal(size, reference.Columns);

        Summary actual;
        using (var compiled = new MathBlocksCUDAWorker().CompileWithOptions(program, MathBlocksCudaOptions.Default, inputs, item.Other))
            actual = Summarize(compiled.Execute(inputs)["result"], sampledRows);

        Assert.True(actual.Valid, $"{name}: the CUDA result is invalid.");
        Assert.Equal(reference.Rows, actual.Rows);
        Assert.Equal(reference.Columns, actual.Columns);
        Assert.Equal(reference.Checksum, actual.Checksum);
        Assert.Equal(BitConverter.DoubleToUInt64Bits(reference.Sum), BitConverter.DoubleToUInt64Bits(actual.Sum));
        for (var index = 0; index < sampledRows.Length; index++)
            Assert.True(reference.SampledRows[index].AsSpan().SequenceEqual(actual.SampledRows[index]), $"{name}: row {sampledRows[index]} differs.");
    }
}
