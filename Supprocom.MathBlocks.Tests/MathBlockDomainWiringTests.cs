using System.Globalization;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the CoreCLR tests of <see cref="MathBlockDomainOptions"/> reaching the operations, and of the device source and plans built from them.</summary>
public sealed class MathBlockDomainWiringTests
{
    /// <summary>One operation evaluated on the same inputs under the default options and under another option set.</summary>
    /// <param name="Identity">The operation identity.</param>
    /// <param name="Inputs">The inputs.</param>
    /// <param name="Other">The option set that changes the outcome.</param>
    internal sealed record Case(string Identity, MathBlockValue[] Inputs, MathBlockDomainOptions Other)
    {
        public override string ToString() => Identity;
    }

    internal static MathBlockOperation Operation(string identity)
    {
        var separator = identity.LastIndexOf('@');
        return MathBlockCatalog.Standard.Get(identity[..separator], int.Parse(identity[(separator + 1)..], CultureInfo.InvariantCulture));
    }

    private static MathBlockValue[] Ones(int count) => [MathBlockValue.Vector(Enumerable.Repeat(1d, count))];

    private static MathBlockMatrix Square(int size, double value) =>
        new(size, size, Enumerable.Repeat(value, size * size).ToArray());

    private static MathBlockValue[] Iterations(string identity, double iterations) => identity switch
    {
        "matrix.perron-vector@1" or "matrix.perron-value@1" or "matrix.spectral-norm@1" =>
            [MathBlockValue.Matrix(Square(2, 1d)), MathBlockValue.Scalar(iterations)],
        "markov.stationary-distribution@1" =>
            [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.9d, 0.1d, 0.2d, 0.8d])), MathBlockValue.Scalar(iterations)],
        "graph.page-rank@1" =>
            [MathBlockValue.Graph(new MathBlockGraph(2, [new(0, 1, 1d), new(1, 0, 1d)])), MathBlockValue.Scalar(0.85d), MathBlockValue.Scalar(iterations)],
        "transport.sinkhorn-coupling@1" =>
            [
                MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0d, 1d, 1d, 0d])),
                MathBlockValue.Vector([0.5d, 0.5d]),
                MathBlockValue.Vector([0.5d, 0.5d]),
                MathBlockValue.Scalar(1d),
                MathBlockValue.Scalar(iterations)
            ],
        _ => throw new ArgumentOutOfRangeException(nameof(identity))
    };

    private static readonly string[] IterationIdentities =
    [
        "matrix.perron-vector@1",
        "matrix.perron-value@1",
        "matrix.spectral-norm@1",
        "markov.stationary-distribution@1",
        "graph.page-rank@1",
        "transport.sinkhorn-coupling@1"
    ];

    // Inputs outside the default domain and the options that accept them: the default evaluation is invalid, the raised one is valid.
    internal static IEnumerable<Case> RaisedCases()
    {
        yield return new("vector.repeat@1", [MathBlockValue.Scalar(1.5d), MathBlockValue.Scalar(1_000_001d)], new() { MaximumGeneratedVectorLength = 2_000_000 });
        yield return new("vector.linspace@1", [MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(1_000_001d)], new() { MaximumGeneratedVectorLength = 2_000_000 });
        yield return new("combinatorics.nonempty-subset-sums@1", [MathBlockValue.Vector(Enumerable.Range(1, 21).Select(value => (double)value))], new() { MaximumExplicitSubsetSize = 21 });
        yield return new("capacity.is-submodular@1", [MathBlockValue.Vector(Enumerable.Range(0, 1 << 13).Select(mask => Math.Sqrt(int.PopCount(mask))))], new() { MaximumSubmodularSetFunctionValues = 1 << 13 });
        yield return new("cooperative.shapley-values@1", [MathBlockValue.Vector(Enumerable.Range(0, 1 << 21).Select(mask => (double)int.PopCount(mask)))], new() { MaximumShapleyCoalitionValues = 1 << 21 });
        yield return new("matrix.maximal-minors@1", [MathBlockValue.Matrix(new MathBlockMatrix(1, 21, Enumerable.Range(1, 21).Select(value => (double)value).ToArray()))], new() { MaximumMaximalMinorColumns = 21 });
        yield return new("matrix.is-totally-nonnegative@1", [MathBlockValue.Matrix(Square(9, 1d))], new() { MaximumTotallyNonnegativeSize = 9 });
        yield return new("matrix.identity@1", [MathBlockValue.Scalar(4_097d)], new() { MaximumMatrixSize = 4_097 });
        yield return new("state.transition-counts@1", [MathBlockValue.Vector([0d, 1d, 2d, 1d]), MathBlockValue.Scalar(4_097d)], new() { MaximumStateCount = 4_097 });
        foreach (var identity in IterationIdentities)
            yield return new(identity, Iterations(identity, 10_001d), new() { MaximumIterationCount = 20_000 });
    }

    // Inputs inside the default domain and the options that reject them: the default evaluation is valid, the lowered one is invalid.
    internal static IEnumerable<Case> LoweredCases()
    {
        yield return new("vector.repeat@1", [MathBlockValue.Scalar(1.5d), MathBlockValue.Scalar(11d)], new() { MaximumGeneratedVectorLength = 10 });
        yield return new("vector.linspace@1", [MathBlockValue.Scalar(0d), MathBlockValue.Scalar(1d), MathBlockValue.Scalar(11d)], new() { MaximumGeneratedVectorLength = 10 });
        yield return new("combinatorics.nonempty-subset-sums@1", Ones(5), new() { MaximumExplicitSubsetSize = 4 });
        yield return new("matrix.principal-minors@1", [MathBlockValue.Matrix(Square(4, 1d))], new() { MaximumExplicitSubsetSize = 3 });
        yield return new("transport.minimum-assignment@1", [MathBlockValue.Matrix(Square(4, 1d))], new() { MaximumExplicitSubsetSize = 3 });
        yield return new("capacity.is-submodular@1", [MathBlockValue.Vector(Enumerable.Range(0, 16).Select(mask => Math.Sqrt(int.PopCount(mask))))], new() { MaximumSubmodularSetFunctionValues = 8 });
        yield return new("cooperative.shapley-values@1", [MathBlockValue.Vector(Enumerable.Range(0, 16).Select(mask => (double)int.PopCount(mask)))], new() { MaximumShapleyCoalitionValues = 8 });
        yield return new("capacity.choquet-integral@1", [MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Vector(Enumerable.Range(0, 8).Select(mask => int.PopCount(mask) / 3d))], new() { MaximumChoquetPlayerCount = 2 });
        yield return new("matrix.maximal-minors@1", [MathBlockValue.Matrix(new MathBlockMatrix(1, 3, [1d, 2d, 3d]))], new() { MaximumMaximalMinorColumns = 2 });
        yield return new("matrix.is-totally-nonnegative@1", [MathBlockValue.Matrix(Square(3, 1d))], new() { MaximumTotallyNonnegativeSize = 2 });
        yield return new("matrix.identity@1", [MathBlockValue.Scalar(5d)], new() { MaximumMatrixSize = 4 });
        yield return new("state.transition-counts@1", [MathBlockValue.Vector([0d, 1d, 2d, 1d]), MathBlockValue.Scalar(4d)], new() { MaximumStateCount = 3 });
        foreach (var identity in IterationIdentities)
            yield return new(identity, Iterations(identity, 11d), new() { MaximumIterationCount = 10 });
    }

    /// <summary>Gets the names of the cases that an option raises.</summary>
    public static TheoryData<string> RaisedNames() => Names(RaisedCases());

    /// <summary>Gets the names of the cases that an option lowers.</summary>
    public static TheoryData<string> LoweredNames() => Names(LoweredCases());

    private static TheoryData<string> Names(IEnumerable<Case> cases)
    {
        var data = new TheoryData<string>();
        foreach (var item in cases)
            data.Add(item.Identity);
        return data;
    }

    /// <summary>Verifies a raised option makes an input valid that the default domain rejects, with the default's own values below it.</summary>
    [Theory]
    [MemberData(nameof(RaisedNames))]
    public void ARaisedOptionAcceptsWhatTheDefaultRejects(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var item = RaisedCases().First(candidate => string.Equals(candidate.Identity, identity, StringComparison.Ordinal));
        var operation = Operation(identity);

        var rejected = operation.Evaluate(item.Inputs);
        var accepted = operation.Evaluate(item.Inputs, item.Other);

        Assert.False(rejected.IsValid, identity + " at the defaults");
        Assert.True(accepted.IsValid, identity + " raised");
        Assert.Equal(rejected.Type.Kind, accepted.Type.Kind);
        Assert.False(operation.Evaluate(item.Inputs, MathBlockDomainOptions.Default).IsValid);
    }

    /// <summary>Verifies a lowered option rejects an input the default domain accepts.</summary>
    [Theory]
    [MemberData(nameof(LoweredNames))]
    public void ALoweredOptionRejectsWhatTheDefaultAccepts(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var item = LoweredCases().First(candidate => string.Equals(candidate.Identity, identity, StringComparison.Ordinal));
        var operation = Operation(identity);

        var accepted = operation.Evaluate(item.Inputs);
        var rejected = operation.Evaluate(item.Inputs, item.Other);

        Assert.True(accepted.IsValid, identity + " at the defaults");
        Assert.False(rejected.IsValid, identity + " lowered");
        Assert.Equal(accepted.Type.Kind, rejected.Type.Kind);
        Assert.True(Same(accepted, operation.Evaluate(item.Inputs, MathBlockDomainOptions.Default)));
    }

    /// <summary>Verifies the default options give every operation's regression inputs the bits of the evaluation without options.</summary>
    [Fact]
    public void TheDefaultOptionsGiveTheEvaluationWithoutOptionsBitForBit()
    {
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            foreach (var regression in operation.RegressionCases)
            {
                Assert.True(
                    Same(operation.Evaluate(regression.Inputs), operation.Evaluate(regression.Inputs, MathBlockDomainOptions.Default)),
                    operation.Identity);
            }
        }
    }

    /// <summary>Verifies an option outside its range throws at the evaluation, naming the option and its real limit.</summary>
    [Fact]
    public void AnOptionOutsideItsRangeThrowsNamingTheLimit()
    {
        var operation = Operation("vector.repeat@1");
        MathBlockValue[] inputs = [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(3d)];

        var thrown = Assert.Throws<ArgumentOutOfRangeException>(() => operation.Evaluate(inputs, new MathBlockDomainOptions { MaximumGeneratedVectorLength = 268_435_456 }));
        Assert.Contains("MaximumGeneratedVectorLength", thrown.Message, StringComparison.Ordinal);
        Assert.Contains("268,435,455", thrown.Message, StringComparison.Ordinal);
        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlocksCoreCLRWorker.Create(new MathBlockDomainOptions { MaximumExplicitSubsetSize = 27 }));
        Assert.Throws<ArgumentNullException>(() => MathBlocksCoreCLRWorker.Create(null!));
    }

    /// <summary>Verifies a CoreCLR worker applies its options to every node of a program.</summary>
    [Fact]
    public void ACoreCLRWorkerAppliesItsDomainOptions()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var program = builder.Output(
            "result",
            builder.Apply("vector.repeat", 1, builder.Input("value", MathBlockType.Scalar()), builder.Input("count", MathBlockType.Scalar()))).Build();
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["value"] = MathBlockValue.Scalar(2d),
            ["count"] = MathBlockValue.Scalar(1_500_000d)
        };
        var worker = MathBlocksCoreCLRWorker.Create(new MathBlockDomainOptions { MaximumGeneratedVectorLength = 2_000_000 });

        Assert.False(MathBlocksCoreCLRWorker.Shared.Execute(program, inputs)["result"].IsValid);
        Assert.Equal(1_500_000, worker.Execute(program, inputs)["result"].AsVector().Count);
        Assert.Equal(2_000_000, worker.DomainOptions.MaximumGeneratedVectorLength);
        Assert.Same(MathBlockDomainOptions.Default, MathBlocksCoreCLRWorker.Shared.DomainOptions);
    }

    /// <summary>Verifies the device source of the default options is <see cref="MathBlockCudaDeviceModule.Source"/> and that each option reaches it.</summary>
    [Fact]
    public void TheDeviceSourceCarriesEveryDomainOption()
    {
        var defaults = MathBlockCudaDeviceModule.GetSource(MathBlockDomainOptions.Default);
        Assert.Equal(MathBlockCudaDeviceModule.Source, defaults);
        Assert.Equal(MathBlockCudaDeviceModule.SourceFingerprint, MathBlockCudaDeviceModule.GetSourceFingerprint(MathBlockDomainOptions.Default));
        Assert.Contains("mathblocks_limit_state_count() { return 4096; }", defaults, StringComparison.Ordinal);
        Assert.Contains("mathblocks_limit_generated_vector_length() { return 1000000; }", defaults, StringComparison.Ordinal);
        Assert.Contains("mathblocks_limit_incomplete_beta_tolerance() { return 3E-14; }", defaults, StringComparison.Ordinal);
        Assert.Contains("mathblocks_limit_jacobi_rotation_budget(int size) { return (long long)64 * size * size; }", defaults, StringComparison.Ordinal);

        var changes = new (string Fragment, MathBlockDomainOptions Options)[]
        {
            ("mathblocks_limit_explicit_subset_size() { return 24; }", new() { MaximumExplicitSubsetSize = 24 }),
            ("mathblocks_limit_state_count() { return 8192; }", new() { MaximumStateCount = 8192 }),
            ("mathblocks_limit_generated_vector_length() { return 2000000; }", new() { MaximumGeneratedVectorLength = 2_000_000 }),
            ("mathblocks_limit_submodular_set_function_values() { return 8192; }", new() { MaximumSubmodularSetFunctionValues = 8192 }),
            ("mathblocks_limit_shapley_coalition_values() { return 2097152; }", new() { MaximumShapleyCoalitionValues = 1 << 21 }),
            ("mathblocks_limit_choquet_player_count() { return 12; }", new() { MaximumChoquetPlayerCount = 12 }),
            ("mathblocks_limit_maximal_minor_columns() { return 22; }", new() { MaximumMaximalMinorColumns = 22 }),
            ("mathblocks_limit_totally_nonnegative_size() { return 9; }", new() { MaximumTotallyNonnegativeSize = 9 }),
            ("mathblocks_limit_matrix_size() { return 5000; }", new() { MaximumMatrixSize = 5000 }),
            ("mathblocks_limit_iteration_count() { return 20000; }", new() { MaximumIterationCount = 20_000 }),
            ("mathblocks_limit_incomplete_beta_maximum_iterations() { return 1024; }", new() { IncompleteBetaMaximumIterations = 1024 }),
            ("mathblocks_limit_incomplete_beta_tolerance() { return 1E-10; }", new() { IncompleteBetaTolerance = 1e-10 }),
            ("mathblocks_limit_incomplete_beta_policy() { return 1; }", new() { IncompleteBetaNonConvergence = MathBlockNonConvergencePolicy.Invalid }),
            ("mathblocks_limit_jacobi_policy() { return 1; }", new() { JacobiNonConvergence = MathBlockNonConvergencePolicy.Invalid }),
            ("(long long)512 * size * size", new() { JacobiRotationMultiplier = 512 })
        };
        var generated = defaults[defaults.IndexOf("#ifndef CSHARP2CUDA_INTEGER_SEMANTICS_0_1", StringComparison.Ordinal)..];
        foreach (var (fragment, options) in changes)
        {
            var source = MathBlockCudaDeviceModule.GetSource(options);
            Assert.Contains(fragment, source, StringComparison.Ordinal);
            Assert.NotEqual(defaults, source, StringComparer.Ordinal);
            Assert.NotEqual(MathBlockCudaDeviceModule.SourceFingerprint, MathBlockCudaDeviceModule.GetSourceFingerprint(options), StringComparer.Ordinal);
            // Only the prelude differs: the generated units are the same text at every option value.
            Assert.EndsWith(generated, source, StringComparison.Ordinal);
        }

        Assert.StartsWith("// MathBlocks domain limits", MathBlockCudaDeviceModule.ComposeSource("// consumer", changes[1].Options), StringComparison.Ordinal);
        Assert.EndsWith("\n// consumer", MathBlockCudaDeviceModule.ComposeSource("// consumer", changes[1].Options), StringComparison.Ordinal);
        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockCudaDeviceModule.GetSource(new MathBlockDomainOptions { MaximumStateCount = 0 }));
        Assert.Throws<ArgumentNullException>(() => MathBlockCudaDeviceModule.GetSource(null!));
    }

    /// <summary>Verifies the counter slots of the device source name the operations they count, by position in <see cref="MathBlockCudaDeviceModule.Operations"/>.</summary>
    [Fact]
    public void TheNonConvergenceCountersAreIndexedByOperationPosition()
    {
        var source = MathBlockCudaDeviceModule.Source;
        var operations = MathBlockCudaDeviceModule.Operations;
        var expected = new (string Identity, string Recorder)[]
        {
            ("special.regularized-incomplete-beta@1", "probability"),
            ("elementwise.special.regularized-incomplete-beta@1", "elementwise"),
            ("elementwise-valid.special.regularized-incomplete-beta@1", "elementwise"),
            ("matrix.symmetric-eigenvalues@1", "matrix"),
            ("matrix.largest-symmetric-eigenvalue@1", "matrix"),
            ("matrix.smallest-symmetric-eigenvalue@1", "matrix"),
            ("matrix.spectral-norm@1", "matrix"),
            ("graph.algebraic-connectivity@1", "graph")
        };
        Assert.Contains(
            $"__device__ unsigned long long {MathBlockCudaDeviceModule.NonConvergenceCountsSymbol}[{operations.Count}];",
            source,
            StringComparison.Ordinal);
        foreach (var (identity, recorder) in expected)
        {
            var contract = MathBlockCudaDeviceModule.GetOperation(identity);
            var index = operations.ToList().FindIndex(candidate => string.Equals(candidate.Identity, identity, StringComparison.Ordinal));
            var start = source.IndexOf($"mathblocks_nonconvergence_record_{recorder}(int opcode)", StringComparison.Ordinal);
            var end = source.IndexOf("default: break;", start, StringComparison.Ordinal);
            Assert.True(index >= 0, identity);
            Assert.Contains(
                string.Create(CultureInfo.InvariantCulture, $"case {contract.Opcode}: mathblocks_nonconvergence_add({index}); break;"),
                source[start..end],
                StringComparison.Ordinal);
        }
    }

    /// <summary>Verifies the CUDA plan applies the domain options: the shapes and scratch of subset size 24, 8192 states and 2,000,000 elements.</summary>
    [Fact]
    public void ThePlanAppliesTheDomainOptionsWithoutADevice()
    {
        var subsets = MathBlockCudaDeviceModule.GetOperation("combinatorics.nonempty-subset-sums@1");
        MathBlockValue[] elements = [MathBlockValue.Vector(Enumerable.Repeat(1d, 24))];
        var raisedSubsets = new MathBlockDomainOptions { MaximumExplicitSubsetSize = 24 };
        var plan = subsets.PlanCUDA(elements, raisedSubsets, 128);
        Assert.Equal((1 << 24) - 1, plan.OutputCapacity);
        Assert.Equal(0, subsets.PlanCUDA(elements, MathBlockDomainOptions.Default, 128).OutputCapacity);

        var states = MathBlockCudaDeviceModule.GetOperation("state.transition-counts@1");
        MathBlockValue[] transitions = [MathBlockValue.Vector([0d, 1d, 8191d]), MathBlockValue.Scalar(8192d)];
        Assert.Equal(8192 * 8192, states.PlanCUDA(transitions, new MathBlockDomainOptions { MaximumStateCount = 8192 }, 128).OutputCapacity);

        var repeat = MathBlockCudaDeviceModule.GetOperation("vector.repeat@1");
        MathBlockValue[] repeated = [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2_000_000d)];
        Assert.Equal(2_000_000, repeat.PlanCUDA(repeated, new MathBlockDomainOptions { MaximumGeneratedVectorLength = 2_000_000 }, 128).OutputCapacity);
        Assert.Equal(0, repeat.PlanCUDA(repeated, MathBlockDomainOptions.Default, 128).OutputCapacity);

        var identity = MathBlockCudaDeviceModule.GetOperation("matrix.identity@1");
        MathBlockValue[] size = [MathBlockValue.Scalar(5000d)];
        Assert.Equal(5000 * 5000, identity.PlanCUDA(size, new MathBlockDomainOptions { MaximumMatrixSize = 5000 }, 128).OutputCapacity);

        var assignment = MathBlockCudaDeviceModule.GetOperation("transport.minimum-assignment@1");
        MathBlockValue[] costs = [MathBlockValue.Matrix(Square(21, 1d))];
        Assert.Equal(2 * (1 << 21) * sizeof(double), assignment.PlanCUDA(costs, new MathBlockDomainOptions { MaximumExplicitSubsetSize = 21 }, 128).ScratchBytes);
        Assert.Equal(0, assignment.PlanCUDA(costs, MathBlockDomainOptions.Default, 128).ScratchBytes);
    }

    /// <summary>Verifies the operation contract evaluates on CoreCLR under the domain options the device source is built with.</summary>
    [Fact]
    public void TheContractEvaluatesUnderTheDomainOptions()
    {
        var repeat = MathBlockCudaDeviceModule.GetOperation("vector.repeat@1");
        MathBlockValue[] inputs = [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(1_500_000d)];

        Assert.False(repeat.EvaluateCoreCLR(inputs).IsValid);
        Assert.True(repeat.EvaluateCoreCLR(inputs, new MathBlockDomainOptions { MaximumGeneratedVectorLength = 2_000_000 }).IsValid);
    }

    /// <summary>Verifies CoreCLR's elementwise row is invalid when any argument is non-finite, before the source is evaluated, and computed otherwise.</summary>
    [Fact]
    public void AnElementwiseRowWithANonFiniteArgumentIsInvalid()
    {
        var infinity = double.PositiveInfinity;
        var finiteRow = MathBlockElementwiseRowReference.Row("scalar.maximum", 1d, 2d);
        Assert.Equal((true, 2d), finiteRow);
        // maximum(1, -Inf) is the finite 1, so only the input check can make this row invalid.
        foreach (var arguments in new[]
                 {
                     new[] { 1d, -infinity }, new[] { 1d, infinity }, new[] { -infinity, 1d }, new[] { infinity, 1d },
                     new[] { 1d, double.NaN }, new[] { double.NaN, 1d }, new[] { infinity, double.NaN }
                 })
        {
            Assert.False(MathBlockElementwiseRowReference.Row("scalar.maximum", arguments).Computed, string.Join(',', arguments));
        }

        Assert.False(MathBlockElementwiseRowReference.Row("scalar.negate", infinity).Computed);
        Assert.False(MathBlockElementwiseRowReference.Row("scalar.negate", double.NaN).Computed);
        Assert.True(MathBlockElementwiseRowReference.Row("scalar.negate", 3d).Computed);
    }

    internal static bool Same(MathBlockValue left, MathBlockValue right)
    {
        if (left.Type != right.Type || left.IsValid != right.IsValid)
            return false;
        if (!left.IsValid)
            return true;
        return left.Type.Kind switch
        {
            MathBlockValueKind.Scalar => BitConverter.DoubleToInt64Bits(left.AsScalar()) == BitConverter.DoubleToInt64Bits(right.AsScalar()),
            MathBlockValueKind.Boolean => left.AsBoolean() == right.AsBoolean(),
            MathBlockValueKind.Vector => Bits(left.AsVector()).SequenceEqual(Bits(right.AsVector())),
            MathBlockValueKind.Matrix => Bits(left.AsMatrix().ToArray()).SequenceEqual(Bits(right.AsMatrix().ToArray())),
            _ => string.Equals(left.Type.ToString(), right.Type.ToString(), StringComparison.Ordinal)
        };
    }

    private static IEnumerable<long> Bits(IReadOnlyList<double> values) => values.Select(BitConverter.DoubleToInt64Bits);
}
