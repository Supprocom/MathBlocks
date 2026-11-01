using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

// CoreCLR/CUDA parity for results that overflow: CoreCLR returns an invalid value, so CUDA must mark the slot
// invalid on the device. A non-finite payload in a slot marked valid made the host read throw, and a device
// consumer of a non-finite scalar computed a valid result from it.
public sealed partial class MathBlockCudaWorkerTests
{
    private static readonly Dictionary<string, OverflowCase> OverflowCases = new(StringComparer.Ordinal)
    {
        ["complex-vector.magnitude"] = Single(
            "complex-vector.magnitude",
            [ComplexValues(new Complex(3d, 4d), new Complex(1d, 2d))],
            [ComplexValues(new Complex(1.7e308d, 1.7e308d), new Complex(1d, 2d))]),
        ["vector.linspace"] = new(
            builder =>
            {
                var start = builder.Input("input-0", MathBlockType.Scalar());
                var end = builder.Input("input-1", MathBlockType.Scalar());
                return builder.Apply("vector.linspace", 1, start, end, builder.Constant(MathBlockValue.Scalar(3d)));
            },
            [MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d)],
            [MathBlockValue.Scalar(-1.7e308d), MathBlockValue.Scalar(1.7e308d)]),
        ["matrix.maximal-minors"] = Single(
            "matrix.maximal-minors",
            [MatrixValue(2, 3, 1d, 2d, 3d, 4d, 5d, 6d)],
            [MatrixValue(2, 3, 1e200d, 0d, 1d, 0d, 1e200d, 1d)]),
        ["matrix.perron-vector"] = Single(
            "matrix.perron-vector",
            [MatrixValue(2, 2, 0.5d, 0.5d, 0.2d, 0.8d), MathBlockValue.Scalar(3d)],
            [MatrixValue(2, 2, 1.7e308d, 1.7e308d, 1.7e308d, 1.7e308d), MathBlockValue.Scalar(3d)]),
        ["matrix.principal-minors"] = Single(
            "matrix.principal-minors",
            [MatrixValue(2, 2, 2d, 1d, 1d, 2d)],
            [MatrixValue(2, 2, 1e200d, 0d, 0d, 1e200d)]),
        ["statistics.covariance-matrix"] = Single(
            "statistics.covariance-matrix",
            [MatrixValue(2, 2, 1d, 2d, 3d, 5d)],
            [MatrixValue(2, 2, 1.7e308d, 0d, -1.7e308d, 0d)]),
        ["sequence.difference"] = WithConstant("sequence.difference", 1d, [1d, 2d, 4d], [1.7e308d, -1.7e308d, 1d]),
        ["sequence.rolling-sum"] = WithConstant("sequence.rolling-sum", 2d, [1d, 2d, 3d], [1.7e308d, 1.7e308d, 1d]),
        ["sequence.rolling-mean"] = WithConstant("sequence.rolling-mean", 2d, [1d, 2d, 3d], [1.7e308d, 1.7e308d, 1d]),
        ["transform.haar"] = Single("transform.haar", [MathBlockValue.Vector([1d, 2d])], [MathBlockValue.Vector([1.7e308d, 1.7e308d])]),
        ["transform.walsh-hadamard"] = Single(
            "transform.walsh-hadamard",
            [MathBlockValue.Vector([1d, 2d])],
            [MathBlockValue.Vector([1.7e308d, 1.7e308d])]),
        ["path.signature-level-one"] = Single(
            "path.signature-level-one",
            [MatrixValue(2, 1, 1d, 2d)],
            [MatrixValue(2, 1, -1.7e308d, 1.7e308d)]),
        ["path.signature-level-two"] = Single(
            "path.signature-level-two",
            [MatrixValue(2, 1, 1d, 2d)],
            [MatrixValue(2, 1, -1.7e308d, 1.7e308d)]),
        ["path.signature-level-three"] = Single(
            "path.signature-level-three",
            [MatrixValue(2, 1, 1d, 2d)],
            [MatrixValue(2, 1, -1.7e308d, 1.7e308d)]),
        ["geometry.centroid"] = Single(
            "geometry.centroid",
            [PointValues((0d, 0d), (1d, 1d))],
            [PointValues((1.7e308d, 0d), (1.7e308d, 0d))]),
        ["geometry.delaunay-graph"] = Single(
            "geometry.delaunay-graph",
            [PointValues((0d, 0d), (1d, 0d), (0d, 1d))],
            [PointValues((0d, 0d), (1e200d, 0d), (0d, 1e200d))]),
        ["geometry.gabriel-graph"] = Single(
            "geometry.gabriel-graph",
            [PointValues((0d, 0d), (1d, 0d), (0d, 1d))],
            [PointValues((0d, 0d), (1e200d, 0d), (0d, 1e200d))]),
        ["topology.zero-dimensional-persistence"] = Single(
            "topology.zero-dimensional-persistence",
            [PointValues((0d, 0d), (1d, 0d), (0d, 1d))],
            [PointValues((0d, 0d), (1e200d, 0d), (0d, 1e200d))]),
        // complex.magnitude is a scalar, which the host read invalidates; a device consumer saw a valid infinity.
        ["complex.magnitude/consumed"] = new(
            builder =>
            {
                var value = builder.Input("input-0", MathBlockType.Complex());
                var magnitude = builder.Apply("complex.magnitude", 1, value);
                return builder.Apply("scalar.greater-than", 1, magnitude, builder.Constant(MathBlockValue.Scalar(1d)));
            },
            [MathBlockValue.Complex(new Complex(3d, 4d))],
            [MathBlockValue.Complex(new Complex(1.7e308d, 1.7e308d))])
    };

    /// <summary>Gets the overflow case names.</summary>
    public static TheoryData<string> OverflowCaseNames => [.. OverflowCases.Keys.Order(StringComparer.Ordinal)];

    /// <summary>
    /// Verifies an overflowing result is invalid on CUDA as on CoreCLR, after a finite case on the same compiled
    /// program matches bit for bit.
    /// </summary>
    [Theory]
    [MemberData(nameof(OverflowCaseNames))]
    public void CUDAOverflowGivesTheCoreCLRInvalidValue(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        VerifyOverflowCase(name, OverflowCases[name]);
    }

    /// <summary>
    /// Verifies the matrix exponential of a matrix whose row-sum norm overflows is invalid on CUDA as on CoreCLR.
    /// Before the fix the kernel squared int.MaxValue times, so this case is kept out of the overflow theory.
    /// </summary>
    [Fact]
    public void CUDAMatrixExponentialOfAnOverflowingNormIsInvalid()
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        VerifyOverflowCase(
            "matrix.exponential",
            Single(
                "matrix.exponential",
                [MatrixValue(2, 2, 0d, 0d, 0d, Math.Log(2d))],
                [MatrixValue(2, 2, 1.7e308d, 1.7e308d, 0d, 0d)]));
    }

    /// <summary>Gets the point-set operations with a non-scalar result, whose invalid result carries a shape.</summary>
    public static TheoryData<string> EmptyPointSetOperations =>
    [
        "geometry.centroid", "geometry.convex-hull", "geometry.delaunay-graph", "geometry.gabriel-graph",
        "geometry.barycentric-coordinates", "topology.zero-dimensional-persistence", "point-set.to-matrix"
    ];

    /// <summary>
    /// Verifies an empty point set gives the CoreCLR result on CUDA, invalid value and type included. The program is
    /// compiled from the empty inputs themselves, so the CUDA result type comes from their shapes.
    /// </summary>
    [Theory]
    [MemberData(nameof(EmptyPointSetOperations))]
    public void CUDAEmptyPointSetGivesTheCoreCLRResult(string identifier)
    {
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var inputs = operation.RegressionCases[0].Inputs
            .Select(input => input.Type.Kind == MathBlockValueKind.PointSet
                ? MathBlockValue.PointSet(new MathBlockPointSet([]), input.Type.Unit)
                : input)
            .ToArray();
        var named = inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
            .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = inputs.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        var coreclr = program.Evaluate(named)["result"];
        using var compiled = new MathBlocksCUDAWorker().Compile(program, named);
        compiled.UploadInputs(named);
        compiled.ExecuteResident();
        var cuda = compiled.ReadOutputs()["result"];

        Assert.True(
            IsExact(coreclr, cuda),
            $"{identifier}: CoreCLR={DescribeBits(coreclr)} ({coreclr.Type}), CUDA={DescribeBits(cuda)} ({cuda.Type})");
    }

    private static void VerifyOverflowCase(string name, OverflowCase overflow)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var program = builder.Output("result", overflow.Build(builder)).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program, Named(overflow.Finite));
        var failures = new List<string>();
        foreach (var (label, inputs) in new[] { ("finite", overflow.Finite), ("overflow", overflow.Overflowing) })
        {
            var coreclr = program.Evaluate(Named(inputs))["result"];
            if (string.Equals(label, "finite", StringComparison.Ordinal) != coreclr.IsValid)
                failures.Add($"{label}: CoreCLR gave {DescribeBits(coreclr)}");
            compiled.UploadInputs(Named(inputs));
            compiled.ExecuteResident();
            var cuda = compiled.ReadOutputs()["result"];
            if (!IsExact(coreclr, cuda))
                failures.Add($"{label}: CoreCLR={DescribeBits(coreclr)} ({coreclr.Type}), CUDA={DescribeBits(cuda)} ({cuda.Type})");
        }
        Assert.True(failures.Count == 0, $"{name}: {string.Join("; ", failures)}");

        static Dictionary<string, MathBlockValue> Named(MathBlockValue[] inputs) =>
            inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
                .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
    }

    private static OverflowCase Single(string identifier, MathBlockValue[] finite, MathBlockValue[] overflowing) =>
        new(
            builder => builder.Apply(
                identifier,
                1,
                finite.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray()),
            finite,
            overflowing);

    // The width or lag is a program constant, so CUDA sizes the output from it.
    private static OverflowCase WithConstant(string identifier, double parameter, double[] finite, double[] overflowing) =>
        new(
            builder => builder.Apply(
                identifier,
                1,
                builder.Input("input-0", MathBlockType.Vector(length: finite.Length)),
                builder.Constant(MathBlockValue.Scalar(parameter))),
            [MathBlockValue.Vector(finite)],
            [MathBlockValue.Vector(overflowing)]);

    private static MathBlockValue ComplexValues(params Complex[] values) => MathBlockValue.ComplexVector(values);

    private static MathBlockValue MatrixValue(int rows, int columns, params double[] values) =>
        MathBlockValue.Matrix(new MathBlockMatrix(rows, columns, values));

    private static MathBlockValue PointValues(params (double X, double Y)[] points) =>
        MathBlockValue.PointSet(new MathBlockPointSet(points.Select(point => new MathBlockPoint(point.X, point.Y))));

    private sealed record OverflowCase(
        Func<MathBlockProgramBuilder, int> Build,
        MathBlockValue[] Finite,
        MathBlockValue[] Overflowing);
}
