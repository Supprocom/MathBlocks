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
            [ComplexValues(new Complex(3f, 4f), new Complex(1f, 2f))],
            [ComplexValues(new Complex(3.38e38f, 3.38e38f), new Complex(1f, 2f))]),
        ["vector.linspace"] = new(
            builder =>
            {
                var start = builder.Input("input-0", MathBlockType.Scalar());
                var end = builder.Input("input-1", MathBlockType.Scalar());
                return builder.Apply("vector.linspace", 1, start, end, builder.Constant(MathBlockValue.Scalar(3f)));
            },
            [MathBlockValue.Scalar(0f), MathBlockValue.Scalar(1f)],
            [MathBlockValue.Scalar(-3.38e38f), MathBlockValue.Scalar(3.38e38f)]),
        ["matrix.maximal-minors"] = Single(
            "matrix.maximal-minors",
            [MatrixValue(2, 3, 1f, 2f, 3f, 4f, 5f, 6f)],
            [MatrixValue(2, 3, 1e25f, 0f, 1f, 0f, 1e25f, 1f)]),
        ["matrix.perron-vector"] = Single(
            "matrix.perron-vector",
            [MatrixValue(2, 2, 0.5f, 0.5f, 0.2f, 0.8f), MathBlockValue.Scalar(3f)],
            [MatrixValue(2, 2, 3.38e38f, 3.38e38f, 3.38e38f, 3.38e38f), MathBlockValue.Scalar(3f)]),
        ["matrix.principal-minors"] = Single(
            "matrix.principal-minors",
            [MatrixValue(2, 2, 2f, 1f, 1f, 2f)],
            [MatrixValue(2, 2, 1e25f, 0f, 0f, 1e25f)]),
        ["statistics.covariance-matrix"] = Single(
            "statistics.covariance-matrix",
            [MatrixValue(2, 2, 1f, 2f, 3f, 5f)],
            [MatrixValue(2, 2, 3.38e38f, 0f, -3.38e38f, 0f)]),
        ["sequence.difference"] = WithConstant("sequence.difference", 1f, [1f, 2f, 4f], [3.38e38f, -3.38e38f, 1f]),
        ["sequence.rolling-sum"] = WithConstant("sequence.rolling-sum", 2f, [1f, 2f, 3f], [3.38e38f, 3.38e38f, 1f]),
        ["sequence.rolling-mean"] = WithConstant("sequence.rolling-mean", 2f, [1f, 2f, 3f], [3.38e38f, 3.38e38f, 1f]),
        ["transform.haar"] = Single("transform.haar", [MathBlockValue.Vector([1f, 2f])], [MathBlockValue.Vector([3.38e38f, 3.38e38f])]),
        ["transform.walsh-hadamard"] = Single(
            "transform.walsh-hadamard",
            [MathBlockValue.Vector([1f, 2f])],
            [MathBlockValue.Vector([3.38e38f, 3.38e38f])]),
        ["path.signature-level-one"] = Single(
            "path.signature-level-one",
            [MatrixValue(2, 1, 1f, 2f)],
            [MatrixValue(2, 1, -3.38e38f, 3.38e38f)]),
        ["path.signature-level-two"] = Single(
            "path.signature-level-two",
            [MatrixValue(2, 1, 1f, 2f)],
            [MatrixValue(2, 1, -3.38e38f, 3.38e38f)]),
        ["path.signature-level-three"] = Single(
            "path.signature-level-three",
            [MatrixValue(2, 1, 1f, 2f)],
            [MatrixValue(2, 1, -3.38e38f, 3.38e38f)]),
        ["geometry.centroid"] = Single(
            "geometry.centroid",
            [PointValues((0f, 0f), (1f, 1f))],
            [PointValues((3.38e38f, 0f), (3.38e38f, 0f))]),
        ["geometry.delaunay-graph"] = Single(
            "geometry.delaunay-graph",
            [PointValues((0f, 0f), (1f, 0f), (0f, 1f))],
            [PointValues((0f, 0f), (1e25f, 0f), (0f, 1e25f))]),
        ["geometry.gabriel-graph"] = Single(
            "geometry.gabriel-graph",
            [PointValues((0f, 0f), (1f, 0f), (0f, 1f))],
            [PointValues((0f, 0f), (1e25f, 0f), (0f, 1e25f))]),
        ["topology.zero-dimensional-persistence"] = Single(
            "topology.zero-dimensional-persistence",
            [PointValues((0f, 0f), (1f, 0f), (0f, 1f))],
            [PointValues((0f, 0f), (1e25f, 0f), (0f, 1e25f))]),
        ["combinatorics.nonempty-subset-sums"] = Single(
            "combinatorics.nonempty-subset-sums",
            [MathBlockValue.Vector([1f, 2f])],
            [MathBlockValue.Vector([3.38e38f, 3.38e38f])]),
        ["polynomial.derivative"] = Single(
            "polynomial.derivative",
            [MathBlockValue.Vector([1f, 2f, 3f])],
            [MathBlockValue.Vector([1f, 3.38e38f, 3.38e38f])]),
        // A scalar result, which the host read invalidates; a device consumer saw a valid infinity.
        ["polynomial.elementary-symmetric/consumed"] = new(
            builder =>
            {
                var values = builder.Input("input-0", MathBlockType.Vector(length: 2));
                var order = builder.Input("input-1", MathBlockType.Scalar());
                var symmetric = builder.Apply("polynomial.elementary-symmetric", 1, values, order);
                return builder.Apply("scalar.greater-than", 1, symmetric, builder.Constant(MathBlockValue.Scalar(1f)));
            },
            [MathBlockValue.Vector([1f, 2f]), MathBlockValue.Scalar(2f)],
            [MathBlockValue.Vector([1e25f, 1e25f]), MathBlockValue.Scalar(2f)]),
        // complex.magnitude is a scalar, which the host read invalidates; a device consumer saw a valid infinity.
        ["complex.magnitude/consumed"] = new(
            builder =>
            {
                var value = builder.Input("input-0", MathBlockType.Complex());
                var magnitude = builder.Apply("complex.magnitude", 1, value);
                return builder.Apply("scalar.greater-than", 1, magnitude, builder.Constant(MathBlockValue.Scalar(1f)));
            },
            [MathBlockValue.Complex(new Complex(3f, 4f))],
            [MathBlockValue.Complex(new Complex(3.38e38f, 3.38e38f))])
    };

    /// <summary>Gets the overflow case names.</summary>
    public static TheoryData<string> OverflowCaseNames => [.. OverflowCases.Keys.Order(StringComparer.Ordinal)];

    /// <summary>
    /// Verifies an overflowing result is invalid on CUDA as on CoreCLR, after a finite case on the same compiled
    /// program matches bit for bit.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(OverflowCaseNames))]
    public void CUDAOverflowGivesTheCoreCLRInvalidValue(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        VerifyOverflowCase(name, OverflowCases[name]);
    }

    /// <summary>
    /// Verifies the matrix exponential of a matrix whose row-sum norm overflows is invalid on CUDA as on CoreCLR.
    /// Before the fix the kernel squared int.MaxValue times, so this case is kept out of the overflow theory.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAMatrixExponentialOfAnOverflowingNormIsInvalid()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        VerifyOverflowCase(
            "matrix.exponential",
            Single(
                "matrix.exponential",
                [MatrixValue(2, 2, 0f, 0f, 0f, MathF.Log(2f))],
                [MatrixValue(2, 2, 3.38e38f, 3.38e38f, 0f, 0f)]));
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
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(EmptyPointSetOperations))]
    public void CUDAEmptyPointSetGivesTheCoreCLRResult(string identifier)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
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

    /// <summary>
    /// Gets the operations whose declared type has less shape than their valid results (the shape depends on input
    /// values), where the CUDA slot shape is a capacity.
    /// </summary>
    public static TheoryData<string> ValueDependentShapeOperations =>
    [
        "boolean-vector.true-indices", "combinatorics.nonempty-subset-sums", "cooperative.shapley-values",
        "geometry.centroid", "geometry.convex-hull", "matrix.identity", "matrix.maximal-minors",
        "matrix.principal-minors", "matrix.reshape", "matrix.schur-complement", "path.lead-lag-transform",
        "path.run-length-encode", "sequence.convolution", "sequence.difference", "sequence.exponential-moving-average",
        "sequence.rolling-maximum", "sequence.rolling-mean", "sequence.rolling-median", "sequence.rolling-minimum",
        "sequence.rolling-quantile", "sequence.rolling-standard-deviation", "sequence.rolling-sum",
        "sequence.rolling-variance", "state.transition-counts", "statistics.histogram",
        "topology.zero-dimensional-persistence", "vector.linspace", "vector.repeat", "vector.slice", "vector.unique"
    ];

    /// <summary>
    /// Verifies an invalid result has the CoreCLR type on CUDA, the type the operation resolves for its inputs: the
    /// program is compiled from the operation's valid sample and then given the first input of the same types
    /// (one input replaced) that CoreCLR rejects. An operation with no such input is reported in the output.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(ValueDependentShapeOperations))]
    public void CUDAInvalidResultHasTheCoreCLRType(string identifier)
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var operation = MathBlockCatalog.Standard.Get(identifier);
        var sample = operation.RegressionCases[0].Inputs.ToArray();
        Assert.True(operation.Evaluate(sample).IsValid, $"{identifier}: the sample is not valid.");
        var invalid = SameTypeVariants(sample).FirstOrDefault(inputs => !operation.Evaluate(inputs).IsValid);
        if (invalid is null)
        {
            testOutput.WriteLine($"{identifier}: no input of the sample's types is invalid on CoreCLR.");
            return;
        }
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodes = sample.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        var program = builder.Output("result", builder.Apply(operation.Identifier, operation.Version, nodes)).Build();
        using var compiled = new MathBlocksCUDAWorker().Compile(program, Named(sample));
        var coreclr = program.Evaluate(Named(invalid))["result"];
        compiled.UploadInputs(Named(invalid));
        compiled.ExecuteResident();
        var cuda = compiled.ReadOutputs()["result"];
        testOutput.WriteLine($"{identifier}: CoreCLR {DescribeBits(coreclr)} {coreclr.Type}, CUDA {DescribeBits(cuda)} {cuda.Type}");

        Assert.True(
            IsExact(coreclr, cuda),
            $"{identifier}: CoreCLR={DescribeBits(coreclr)} ({coreclr.Type}), CUDA={DescribeBits(cuda)} ({cuda.Type})");

        static Dictionary<string, MathBlockValue> Named(MathBlockValue[] inputs) =>
            inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
                .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
    }

    // The sample with one input replaced by a value of exactly the same type: other scalars, and vectors, matrices,
    // Boolean vectors and point sets of the same shape with other entries.
    private static IEnumerable<MathBlockValue[]> SameTypeVariants(MathBlockValue[] sample)
    {
        float[] scalars = [21f, 0f, -1f, 0.5f, 1_000_001f, 4097f, 3.16e38f, -0.5f, 3f];
        for (var input = 0; input < sample.Length; input++)
        {
            var value = sample[input];
            var unit = value.Type.Unit;
            var alternatives = new List<MathBlockValue>();
            switch (value.Type.Kind)
            {
                case MathBlockValueKind.Scalar:
                    alternatives.AddRange(scalars.Select(item => MathBlockValue.Scalar(item, unit)));
                    break;
                case MathBlockValueKind.Vector:
                    var count = value.AsVector().Count;
                    alternatives.Add(MathBlockValue.Vector(Enumerable.Range(0, count).Select(index => index % 2 == 0 ? 3.38e38f : -3.38e38f), unit));
                    alternatives.Add(MathBlockValue.Vector(Enumerable.Repeat(1e25f, count), unit));
                    alternatives.Add(MathBlockValue.Vector(Enumerable.Repeat(3.38e38f, count), unit));
                    alternatives.Add(MathBlockValue.Vector(Enumerable.Range(0, count).Select(index => -1f - index), unit));
                    alternatives.Add(MathBlockValue.Vector(Enumerable.Range(0, count).Select(index => 0.5f + index), unit));
                    alternatives.Add(MathBlockValue.Vector(new float[count], unit));
                    break;
                case MathBlockValueKind.Matrix:
                    var matrix = value.AsMatrix();
                    alternatives.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Repeat(1e25f, matrix.Rows * matrix.Columns)), unit));
                    alternatives.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Range(0, matrix.Rows * matrix.Columns).Select(index => (index * 7 % 3 - 1) * 1e25f + index)), unit));
                    alternatives.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Range(0, matrix.Rows * matrix.Columns).Select(index => index / matrix.Columns == index % matrix.Columns ? 1e25f : 0f)), unit));
                    alternatives.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Range(0, matrix.Rows * matrix.Columns).Select(index => -1f - index)), unit));
                    alternatives.Add(MathBlockValue.Matrix(new MathBlockMatrix(matrix.Rows, matrix.Columns, Enumerable.Range(0, matrix.Rows * matrix.Columns).Select(index => 0.5f + index)), unit));
                    break;
                case MathBlockValueKind.PointSet:
                    var points = value.AsPointSet().Count;
                    alternatives.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Range(0, points).Select(index => new MathBlockPoint(index % 2 == 0 ? 3.38e38f : -3.38e38f, index * 1e25f))), unit));
                    alternatives.Add(MathBlockValue.PointSet(new MathBlockPointSet(Enumerable.Repeat(new MathBlockPoint(3.38e38f, 3.38e38f), points)), unit));
                    break;
            }
            for (var variant = 0; variant < alternatives.Count; variant++)
            {
                var alternative = alternatives[variant];
                if (alternative.Type != value.Type)
                    continue;
                var inputs = (MathBlockValue[])sample.Clone();
                inputs[input] = alternative;
                yield return inputs;
            }
        }
    }

    /// <summary>
    /// Verifies an invalid output of a multi-node program has the CoreCLR type on CUDA, its planned type, where the
    /// intermediate rolling sum has a run-time length the plan does not know.
    /// </summary>
    [Fact]
    [Trait("Category", "CudaDevice")]
    public void CUDAInvalidProgramOutputHasItsPlannedType()
    {
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var program = MathBlockProgramTests.BuildRollingLogarithmProgram();
        var inputs = MathBlockProgramTests.RollingLogarithmInputs();
        var prototype = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["values"] = MathBlockValue.Vector([1f, 2f, 3f, 4f]),
            ["width"] = MathBlockValue.Scalar(2f)
        };
        var coreclr = program.Evaluate(inputs)["logarithm"];
        using var compiled = new MathBlocksCUDAWorker().Compile(program, prototype);
        Assert.True(IsExact(program.Evaluate(prototype)["logarithm"], compiled.Execute(prototype)["logarithm"]), "The finite case differs.");
        var cuda = compiled.Execute(inputs)["logarithm"];

        Assert.False(coreclr.IsValid);
        Assert.True(IsExact(coreclr, cuda), $"CoreCLR={DescribeBits(coreclr)} ({coreclr.Type}), CUDA={DescribeBits(cuda)} ({cuda.Type})");
    }

    // Programs compiled from their own inputs (so the CUDA plan has those exact shapes and values), where CoreCLR and
    // CUDA disagreed: domain checks that one side lacked, the sign of a zero from the maximum, and inputs that CUDA
    // rejected at compile time while CoreCLR returns an invalid value at run time.
    internal static readonly Dictionary<string, Func<(MathBlockProgram Program, MathBlockValue[] Inputs)>> SelfCompiledCases =
        new(StringComparer.Ordinal)
        {
            ["transform.haar/length-3"] = () => Standalone("transform.haar", Values(1f, 2f, 3f)),
            ["transport.assignment-cost/non-integer-index"] = () => Standalone(
                "transport.assignment-cost", MatrixValue(2, 2, 3f, 1f, 1f, 3f), Values(0.5f, 1f)),
            ["geometry.fisher-rao-distance/not-distributions"] = () => Standalone(
                "geometry.fisher-rao-distance", Values(-0.5f, -0.5f), Values(-0f, -1f)),
            // A running peak of 0 followed by 0 is 0 / 0, which the owned maximum now propagates: invalid on both sides.
            ["path.maximum-relative-decline/zero-peak-then-zero"] = () => Standalone("path.maximum-relative-decline", Values(0f, -0f, 0.5f)),
            ["path.maximum-relative-decline/zero-peak-then-later-decline"] = () => Standalone("path.maximum-relative-decline", Values(0f, 0f, 3f, 1f)),
            // A zero Lipschitz constant times an overflowing distance is 0 * infinity, a NaN term: invalid on both sides.
            ["extension.mcshane/zero-lipschitz-overflowing-distance"] = () => Standalone(
                "extension.mcshane", Values(-3.38e38f, 0f), Values(-5f, 3f), Values(3.38e38f), MathBlockValue.Scalar(0f)),
            ["extension.whitney/zero-lipschitz-overflowing-distance"] = () => Standalone(
                "extension.whitney", Values(-3.38e38f, 0f), Values(5f, -3f), Values(3.38e38f), MathBlockValue.Scalar(0f)),
            // The remaining overflow victims, invalid on both sides.
            ["complex.divide/divisor-overflow"] = () => Standalone(
                "complex.divide", MathBlockValue.Complex(new Complex(1f, 1f)), MathBlockValue.Complex(new Complex(1e25f, 1e25f))),
            ["geometry.contains-point/crossing-overflow"] = () => Standalone(
                "geometry.contains-point",
                PointValues((-1e25f, -1e25f), (1e25f, -1e25f), (1e25f, 1e25f)), PointValues((8.18e24f, 7.5e24f))),
            ["geometry.convex-hull/nan-cross-product"] = () => Standalone(
                "geometry.convex-hull", PointValues((0f, 0f), (1e25f, 1e25f), (1.09e25f, 1.09e25f))),
            ["statistics.theil-sen-slope/difference-overflow"] = () => Standalone(
                "statistics.theil-sen-slope", Values(-3.38e38f, 3.38e38f), Values(1f, 2f)),
            ["matrix.exponential/trace-overflow"] = () => Standalone(
                "matrix.exponential",
                MatrixValue(2, 2, 1.56e25f, -4.8e12f, 5.52e37f, -1.0737128770591469f)),
            // A NaN inside the owned maximum (inf - inf from overflowing pairwise means) is invalid on both sides, and the sign of a zero tie
            // in a max-plus or min-plus product is the owned maximum's and minimum's.
            ["transport.energy-distance/nan-squared"] = () => Standalone(
                "transport.energy-distance", Values(-3.38e38f, 3.38e38f), Values(0f, 0f)),
            ["tropical.max-plus-multiply/zero-tie-sign"] = () => Standalone(
                "tropical.max-plus-multiply", MatrixValue(1, 2, 0f, -0f), MatrixValue(2, 1, 0f, -0f)),
            ["tropical.min-plus-multiply/zero-tie-sign"] = () => Standalone(
                "tropical.min-plus-multiply", MatrixValue(1, 2, -0f, 0f), MatrixValue(2, 1, -0f, 0f)),
            ["path.maximum-relative-decline/signed-zero"] = () => Standalone("path.maximum-relative-decline", Values(-1f, -1f, -2f)),
            // The windows whose running peak is 0 followed by 0 (rows 4 and 5) are invalid on both sides.
            ["window-valid.path.maximum-relative-decline/zero-maximum"] = () => WindowFormCase(
                "window-valid.path.maximum-relative-decline", Values(-0f, 2f, 0f, -0f, 0f, 1.25f)),
            ["window.path.maximum-relative-decline/zero-maximum"] = () => WindowFormCase(
                "window.path.maximum-relative-decline", Values(-0f, 2f, 0f, -0f, 0f, 1.25f)),
            // An intermediate that overflows makes the result invalid on both sides (a variance, a standard-deviation product or a
            // distance moment that is an infinity used to divide a finite value and give a valid zero on both).
            ["statistics.pearson-correlation/variance-overflow"] = () => Standalone(
                "statistics.pearson-correlation", Values(1f, 2f, 3f, 4f),
                Values(-7.143571252424402f, 3.4e38f, 7.274205695928337f, -9.877113669855383f)),
            ["statistics.distance-correlation/moment-overflow"] = () => Standalone(
                "statistics.distance-correlation",
                Values(-6.21e37f, -6.343768537094183f, -5.8364683556946435f),
                Values(-5.71e-37f, 36.84280271658108f, 0.9048608060071095f)),
            ["statistics.linear-slope/variance-overflow"] = () => Standalone(
                "statistics.linear-slope",
                Values(7.114245152862294f, -6.21e37f, -728.0038665276926f, 4.224291341469105f),
                Values(0.4953195529423522f, 0.7783700051634825f, 118f, -720.3804674671959f)),
            ["statistics.linear-intercept/variance-overflow"] = () => Standalone(
                "statistics.linear-intercept",
                Values(7.114245152862294f, -6.21e37f, -728.0038665276926f, 4.224291341469105f),
                Values(0.4953195529423522f, 0.7783700051634825f, 118f, -720.3804674671959f)),
            ["statistics.linear-r-squared/variance-overflow"] = () => Standalone(
                "statistics.linear-r-squared",
                Values(1.4e-45f, -1.58e-37f, -17.27875959474386f, -0.8325065752238905f),
                Values(-3.496470870518605f, -11.96980468906019f, 9.27e37f, -729.5969940812662f)),
            ["statistics.autocorrelation/variance-overflow"] = () => Standalone(
                "statistics.autocorrelation",
                Values(1.2e38f, -4.440892098500626e-16f, -22.450293565523026f, 0.0037950201825623286f),
                MathBlockValue.Scalar(2f)),
            ["vector.standardize/variance-overflow"] = () => Standalone(
                "vector.standardize", Values(3.4e38f, -9.05e29f, 710.0904103212077f)),
            ["geometry.simplicial-depth/coordinate-overflow"] = () => Standalone(
                "geometry.simplicial-depth",
                PointValues((698.0421626654253f, 0.7817012842080717f), (-22.194671885609296f, 3.4e38f), (-3.80572792044629f, -708.0863943344233f)),
                PointValues((-0.9999999999999934f, 7.274205695928337f))),
            ["geometry.barycentric-coordinates/denominator-overflow"] = () => Standalone(
                "geometry.barycentric-coordinates",
                PointValues((1f, 1f)), PointValues((1e25f, 0f), (0f, 1e25f), (0f, 0f))),
            ["geometry.halfspace-depth/nan-cross-product"] = () => Standalone(
                "geometry.halfspace-depth", PointValues((1e25f, 1e25f), (1.09e25f, 1.09e25f)), PointValues((0f, 0f))),
            // The window forms apply the same rule to every window (the first window with an overflowing variance is invalid).
            ["window.statistics.pearson-correlation/variance-overflow"] = () => WindowSeriesCase(
                "window.statistics.pearson-correlation",
                Values(1f, 2f, 3f, 4f, 5f, 6f), Values(-7.143571252424402f, 3.4e38f, 7.274205695928337f, -9.877113669855383f, 2f, 3f)),
            ["window-valid.statistics.distance-correlation/moment-overflow"] = () => WindowSeriesCase(
                "window-valid.statistics.distance-correlation",
                Values(-6.21e37f, -6.343768537094183f, -5.8364683556946435f, 1f, 2f, 3f),
                Values(-5.71e-37f, 36.84280271658108f, 0.9048608060071095f, 5f, 6f, 8f)),
            ["window.statistics.linear-slope/variance-overflow"] = () => WindowSeriesCase(
                "window.statistics.linear-slope",
                Values(7.114245152862294f, -6.21e37f, -728.0038665276926f, 4.224291341469105f, 1f, 2f),
                Values(0.4953195529423522f, 0.7783700051634825f, 118f, -720.3804674671959f, 3f, 4f)),
            ["window-valid.statistics.linear-r-squared/variance-overflow"] = () => WindowSeriesCase(
                "window-valid.statistics.linear-r-squared",
                Values(1.4e-45f, -1.58e-37f, -17.27875959474386f, -0.8325065752238905f, 1f, 2f),
                Values(-3.496470870518605f, -11.96980468906019f, 9.27e37f, -729.5969940812662f, 3f, 4f)),
            ["window.statistics.autocorrelation/variance-overflow"] = () => WindowSeriesCase(
                "window.statistics.autocorrelation",
                Values(1.2e38f, -4.440892098500626e-16f, -22.450293565523026f, 0.0037950201825623286f, 1f, 2f)),
            ["window.vector.standardize/variance-overflow"] = () => WindowSeriesCase(
                "window.vector.standardize", Values(3.4e38f, -9.05e29f, 710.0904103212077f, 1f, 2f, 4f)),
            ["combinatorics.nonempty-subset-sums/21-values"] = () => Standalone(
                "combinatorics.nonempty-subset-sums", Values([.. Enumerable.Range(1, 21).Select(value => (float)value)])),
            ["cooperative.shapley-values/length-3"] = () => Standalone("cooperative.shapley-values", Values(1f, 2f, 3f)),
            ["information.conditional-mutual-information/state-counts"] = () => SampleWithScalarIncremented("information.conditional-mutual-information", 1),
            ["matrix.reshape/shape"] = () => SampleWithScalarIncremented("matrix.reshape", 1),
            ["matrix.principal-minors/21-rows"] = () => Standalone("matrix.principal-minors", Diagonal(21)),
            ["transport.minimum-assignment/21-rows"] = () => Standalone("transport.minimum-assignment", Diagonal(21)),
            // An iteration count is capped at 10,000, as for graph.page-rank and transport.sinkhorn-coupling.
            ["markov.stationary-distribution/10000-iterations"] = () => SampleWithIterations("markov.stationary-distribution", 10_000f),
            ["markov.stationary-distribution/10001-iterations"] = () => SampleWithIterations("markov.stationary-distribution", 10_001f),
            ["matrix.perron-value/10000-iterations"] = () => SampleWithIterations("matrix.perron-value", 10_000f),
            ["matrix.perron-value/10001-iterations"] = () => SampleWithIterations("matrix.perron-value", 10_001f),
            ["matrix.perron-vector/10000-iterations"] = () => SampleWithIterations("matrix.perron-vector", 10_000f),
            ["matrix.perron-vector/10001-iterations"] = () => SampleWithIterations("matrix.perron-vector", 10_001f),
            ["matrix.spectral-norm/10000-iterations"] = () => SampleWithIterations("matrix.spectral-norm", 10_000f),
            ["matrix.spectral-norm/10001-iterations"] = () => SampleWithIterations("matrix.spectral-norm", 10_001f),
            // A square in the Gram matrix overflows, so both sides give an invalid scalar (CoreCLR gave a valid 0).
            ["matrix.spectral-norm/gram-overflow-2x2"] = () => Standalone(
                "matrix.spectral-norm", MatrixValue(2, 2, 21.808109993025802f, -1E-16f, 2.0261677264706863f, 3.4e38f), MathBlockValue.Scalar(32f)),
            ["matrix.spectral-norm/gram-overflow-5x5"] = () => Standalone(
                "matrix.spectral-norm", MatrixValue(5, 5, -1.4934540366773823f, -724.1384810885675f, -110f, -2.03e31f, -736.1104387680798f, -4.29484363142549f, 8.33e27f, 4.722841828411625f, 0.09556606759165165f, -39f, 0.04059996335593041f, -0.5318688056945957f, 8.84e21f, -740.769435392698f, -20.097659664810053f, -739.8147664805746f, 0.9999956274522844f, 2.7099982004438914f, 4.192299232855897f, -4.39e22f, 3.6241968239171687f, 3.82e27f, -750.0798031522245f, 59.5f, -5.7572465458520234f), MathBlockValue.Scalar(32f)),
            // An operation that consumes an always-invalid node is invalid too.
            ["combinatorics.nonempty-subset-sums/consumed"] = () =>
            {
                var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
                var values = builder.Input("input-0", MathBlockType.Vector(length: 21));
                var sums = builder.Apply("combinatorics.nonempty-subset-sums", 1, values);
                var program = builder.Output("result", builder.Apply("vector.sum", 1, sums)).Build();
                return (program, [Values([.. Enumerable.Range(1, 21).Select(value => (float)value)])]);
            }
        };

    /// <summary>Gets the self-compiled case names.</summary>
    public static TheoryData<string> SelfCompiledCaseNames => [.. SelfCompiledCases.Keys.Order(StringComparer.Ordinal)];

    /// <summary>
    /// Verifies a program compiled from its own inputs gives the CoreCLR result on CUDA, bit for bit, with the same
    /// validity and type.
    /// </summary>
    [Theory]
    [Trait("Category", "CudaDevice")]
    [MemberData(nameof(SelfCompiledCaseNames))]
    public void CUDAProgramCompiledFromItsInputsGivesTheCoreCLRResult(string name)
    {
        ArgumentException.ThrowIfNullOrEmpty(name);
        Assert.True(CudaTestDevice.Available, "A CUDA device is required.");
        var (program, inputs) = SelfCompiledCases[name]();
        var named = inputs.Select((input, index) => (Name: $"input-{index}", Input: input))
            .ToDictionary(item => item.Name, item => item.Input, StringComparer.Ordinal);
        var coreclr = program.Evaluate(named)["result"];
        using var compiled = new MathBlocksCUDAWorker().Compile(program, named);
        var cuda = compiled.Execute(named)["result"];

        Assert.True(
            IsExact(coreclr, cuda),
            $"{name}: CoreCLR={DescribeBits(coreclr)} ({coreclr.Type}), CUDA={DescribeBits(cuda)} ({cuda.Type})");
    }

    private static (MathBlockProgram Program, MathBlockValue[] Inputs) Standalone(string identifier, params MathBlockValue[] inputs) =>
        Single(MathBlockCatalog.Standard, identifier, inputs);

    // A window form over the vector with its sample's other arguments (the width, and the fill for a form).
    private static (MathBlockProgram Program, MathBlockValue[] Inputs) WindowFormCase(string identifier, MathBlockValue vector)
    {
        var operation = MathBlockWindowTestSupport.Windowed.Get(identifier);
        var inputs = operation.RegressionCases[0].Inputs.ToArray();
        inputs[0] = vector;
        inputs[1] = MathBlockValue.Scalar(3f, inputs[1].Type.Unit);
        return Single(MathBlockWindowTestSupport.Windowed, identifier, inputs);
    }

    // A window form over series that replace the leading inputs of its sample (the sample's other arguments are kept).
    private static (MathBlockProgram Program, MathBlockValue[] Inputs) WindowSeriesCase(string identifier, params MathBlockValue[] series)
    {
        var operation = MathBlockWindowTestSupport.Windowed.Get(identifier);
        var inputs = operation.RegressionCases[0].Inputs.ToArray();
        for (var index = 0; index < series.Length; index++)
            inputs[index] = series[index];
        return Single(MathBlockWindowTestSupport.Windowed, identifier, inputs);
    }

    // The operation's sample with one scalar input one larger, which no longer matches the vector's shape.
    private static (MathBlockProgram Program, MathBlockValue[] Inputs) SampleWithScalarIncremented(string identifier, int input)
    {
        var inputs = MathBlockCatalog.Standard.Get(identifier).RegressionCases[0].Inputs.ToArray();
        inputs[input] = MathBlockValue.Scalar(inputs[input].AsScalar() + 1f, inputs[input].Type.Unit);
        return Standalone(identifier, inputs);
    }

    // The operation's sample with its iteration count (the second input) replaced.
    private static (MathBlockProgram Program, MathBlockValue[] Inputs) SampleWithIterations(string identifier, float iterations)
    {
        var inputs = MathBlockCatalog.Standard.Get(identifier).RegressionCases[0].Inputs.ToArray();
        inputs[1] = MathBlockValue.Scalar(iterations, inputs[1].Type.Unit);
        return Standalone(identifier, inputs);
    }

    private static (MathBlockProgram Program, MathBlockValue[] Inputs) Single(MathBlockRegistry registry, string identifier, MathBlockValue[] inputs)
    {
        var builder = new MathBlockProgramBuilder(registry);
        var nodes = inputs.Select((input, index) => builder.Input($"input-{index}", input.Type)).ToArray();
        return (builder.Output("result", builder.Apply(identifier, 1, nodes)).Build(), inputs);
    }

    private static MathBlockValue Values(params float[] values) => MathBlockValue.Vector(values);

    private static MathBlockValue Diagonal(int size) =>
        MathBlockValue.Matrix(new MathBlockMatrix(size, size, Enumerable.Range(0, size * size).Select(index => index % (size + 1) == 0 ? 2f : 1f / size)));

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
    private static OverflowCase WithConstant(string identifier, float parameter, float[] finite, float[] overflowing) =>
        new(
            builder => builder.Apply(
                identifier,
                1,
                builder.Input("input-0", MathBlockType.Vector(length: finite.Length)),
                builder.Constant(MathBlockValue.Scalar(parameter))),
            [MathBlockValue.Vector(finite)],
            [MathBlockValue.Vector(overflowing)]);

    private static MathBlockValue ComplexValues(params Complex[] values) => MathBlockValue.ComplexVector(values);

    private static MathBlockValue MatrixValue(int rows, int columns, params float[] values) =>
        MathBlockValue.Matrix(new MathBlockMatrix(rows, columns, values));

    private static MathBlockValue PointValues(params (float X, float Y)[] points) =>
        MathBlockValue.PointSet(new MathBlockPointSet(points.Select(point => new MathBlockPoint(point.X, point.Y))));

    private sealed record OverflowCase(
        Func<MathBlockProgramBuilder, int> Build,
        MathBlockValue[] Finite,
        MathBlockValue[] Overflowing);
}
