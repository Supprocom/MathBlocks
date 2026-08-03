using Supprocom.MathBlocks.Gpu;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockProgramPopulationTests
{
    [Fact]
    public void GPU_population_completely_enumerates_a_known_typed_grammar()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var definition = CreateScalarDefinition(proposalsPerCycle: 3);
        using var population = new MathBlocksGPUWorker().CompilePopulation(definition);
        var candidates = new List<MathBlockProgramCandidate>();
        MathBlockProgramPopulationCycleResult cycle;
        do
        {
            cycle = population.ExecuteCycle();
            candidates.AddRange(cycle.Candidates);
        }
        while (!cycle.IsComplete);

        Assert.Equal(8ul, definition.TotalProposalCount);
        Assert.Equal(8ul, cycle.AcceptedState.AcceptedCursor);
        Assert.Equal(8ul, cycle.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(0ul, cycle.AcceptedState.StructuralDuplicateCount);
        Assert.Equal(4ul, cycle.AcceptedState.SemanticDuplicateCount);
        Assert.Equal(8, cycle.AcceptedState.StructuralFingerprints.Count);
        Assert.Equal(4, cycle.AcceptedState.SemanticFingerprints.Count);
        Assert.Equal([4d, 5d, 6d, 9d], candidates.Select(candidate => candidate.Output.AsScalar()));
        Assert.Equal([0ul, 1ul, 3ul, 7ul], candidates.Select(candidate => candidate.ProposalCursor));

        foreach (var candidate in candidates)
        {
            Assert.Equal(3, candidate.Nodes.Count);
            Assert.Equal(MathBlockProgramCandidateNodeKind.Operation, candidate.Nodes[^1].Kind);
            Assert.Equal(1, candidate.Nodes[^1].OperationVersion);
            Assert.All(candidate.Nodes[^1].OperandIndexes, operand => Assert.InRange(operand, 0, 1));
            AssertExact(definition.Evaluate(candidate), candidate.Output);
        }

        Assert.Equal(1, population.GraphInstanceCount);
        Assert.Equal(1, population.UploadCount);
        Assert.Equal(3, population.GraphLaunchCount);
        Assert.Equal(3, population.SynchronizationCount);
        Assert.Equal(3, population.DownloadCount);
        Assert.Equal(0, population.CpuNodeDispatchCount);
        Assert.True(population.ResidentBytes > population.DeviceToHostBytesPerCycle);
    }

    [Fact]
    public void GPU_population_cycle_uses_one_upload_launch_synchronization_and_download()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var definition = CreateScalarDefinition(proposalsPerCycle: 8);
        using var population = new MathBlocksGPUWorker().CompilePopulation(definition);

        var cycle = population.ExecuteCycle();

        Assert.True(cycle.IsComplete);
        Assert.Equal(1, cycle.Instrumentation.GraphInstanceCount);
        Assert.Equal(1, cycle.Instrumentation.UploadCount);
        Assert.Equal(1, cycle.Instrumentation.GraphLaunchCount);
        Assert.Equal(1, cycle.Instrumentation.SynchronizationCount);
        Assert.Equal(1, cycle.Instrumentation.DownloadCount);
        Assert.Equal(0, cycle.Instrumentation.CpuNodeDispatchCount);
        Assert.Equal(8ul, cycle.Instrumentation.AcceptedCursor);
        Assert.Equal(8ul, cycle.Instrumentation.EvaluatedProgramCount);
        Assert.Equal(4ul, cycle.Instrumentation.SemanticDuplicateCount);
    }

    [Fact]
    public void GPU_population_resume_reproduces_the_exact_next_proposal()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var initial = CreateScalarDefinition(proposalsPerCycle: 3);
        using var firstPopulation = new MathBlocksGPUWorker().CompilePopulation(initial);
        var firstCycle = firstPopulation.ExecuteCycle();
        var restoredState = MathBlockProgramPopulationState.Import(firstCycle.AcceptedState.Export());

        var expected = firstPopulation.ExecuteCycle();
        var resumedDefinition = CreateScalarDefinition(proposalsPerCycle: 3, acceptedState: restoredState);
        using var resumedPopulation = new MathBlocksGPUWorker().CompilePopulation(resumedDefinition);
        var actual = resumedPopulation.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.AcceptedCursor, actual.AcceptedState.AcceptedCursor);
        Assert.Equal(expected.AcceptedState.EvaluatedProgramCount, actual.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(expected.AcceptedState.StructuralFingerprints, actual.AcceptedState.StructuralFingerprints);
        Assert.Equal(expected.AcceptedState.SemanticFingerprints, actual.AcceptedState.SemanticFingerprints);
        AssertCandidatesEqual(expected.Candidates, actual.Candidates);
        Assert.Equal(1, resumedPopulation.UploadCount);
        Assert.Equal(1, resumedPopulation.GraphLaunchCount);
        Assert.Equal(1, resumedPopulation.SynchronizationCount);
        Assert.Equal(1, resumedPopulation.DownloadCount);

        Assert.Throws<InvalidOperationException>(() => CreateScalarDefinition(
            proposalsPerCycle: 3,
            acceptedState: restoredState,
            firstTerminal: 2.5d));
    }

    [Fact]
    public void GPU_population_resolves_dynamic_output_capacity_and_matches_CPU()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var dynamicVector = MathBlockType.Vector(length: 0);
        var scalar = MathBlockType.Scalar();
        var grammar = new MathBlockProgramPopulationGrammar(
            [new MathBlockProgramPopulationOperation(
                "vector.add-scalar",
                1,
                [dynamicVector, scalar],
                dynamicVector)],
            dynamicVector);
        var definition = new MathBlockProgramPopulationDefinition(
            grammar,
            [new MathBlockProgramPopulationTerminal(
                "samples",
                dynamicVector,
                MathBlockValue.Vector([1d, 2d, 4d]))],
            [new MathBlockProgramPopulationConstant(BitConverter.DoubleToInt64Bits(3d))],
            [new MathBlockProgramPopulationResourceBand(1, 3)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 4);
        using var population = new MathBlocksGPUWorker().CompilePopulation(definition);

        var cycle = population.ExecuteCycle();

        var candidate = Assert.Single(cycle.Candidates);
        Assert.Equal(3, candidate.Output.Type.Rows);
        Assert.Equal([4d, 5d, 7d], candidate.Output.AsVector());
        AssertExact(definition.Evaluate(candidate), candidate.Output);
        Assert.True(cycle.IsComplete);
        Assert.Equal(1, cycle.Instrumentation.UploadCount);
        Assert.Equal(1, cycle.Instrumentation.DownloadCount);
        Assert.Equal(1, cycle.Instrumentation.GraphLaunchCount);
        Assert.Equal(1, cycle.Instrumentation.SynchronizationCount);
        Assert.Equal(0, cycle.Instrumentation.CpuNodeDispatchCount);
    }

    [Fact]
    public void GPU_population_serializes_concurrent_cycles_without_proposal_loss()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var definition = CreateScalarDefinition(proposalsPerCycle: 1);
        using var population = new MathBlocksGPUWorker().CompilePopulation(definition);
        var cursors = new ulong[8];

        Parallel.For(0, cursors.Length, index =>
        {
            cursors[index] = population.ExecuteCycle().AcceptedState.AcceptedCursor;
        });

        Array.Sort(cursors);
        Assert.Equal(Enumerable.Range(1, 8).Select(value => (ulong)value), cursors);
        Assert.Equal(8ul, population.AcceptedCursor);
        Assert.Equal(8ul, population.EvaluatedProgramCount);
        Assert.Equal(1, population.UploadCount);
        Assert.Equal(8, population.GraphLaunchCount);
        Assert.Equal(8, population.SynchronizationCount);
        Assert.Equal(8, population.DownloadCount);
        Assert.Equal(0, population.CpuNodeDispatchCount);
    }

    [Fact]
    public void GPU_population_failed_cycle_does_not_replace_accepted_state()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        var dynamicVector = MathBlockType.Vector(length: 0);
        var grammar = new MathBlockProgramPopulationGrammar(
            [new MathBlockProgramPopulationOperation(
                "vector.concatenate",
                1,
                [dynamicVector, dynamicVector],
                dynamicVector)],
            dynamicVector);
        var definition = new MathBlockProgramPopulationDefinition(
            grammar,
            [
                new MathBlockProgramPopulationTerminal(
                    "left",
                    dynamicVector,
                    MathBlockValue.Vector([1d, 2d])),
                new MathBlockProgramPopulationTerminal(
                    "right",
                    dynamicVector,
                    MathBlockValue.Vector([3d, 4d]))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 2)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 4);
        using var population = new MathBlocksGPUWorker().CompilePopulation(definition);

        Assert.Throws<InvalidOperationException>(() => population.ExecuteCycle());
        Assert.Equal(0ul, population.AcceptedCursor);
        Assert.Equal(0ul, population.EvaluatedProgramCount);
        Assert.Empty(population.AcceptedState.StructuralFingerprints);
        Assert.Empty(population.AcceptedState.SemanticFingerprints);

        Assert.Throws<InvalidOperationException>(() => population.ExecuteCycle());
        Assert.Equal(0ul, population.AcceptedCursor);
        Assert.Equal(2, population.GraphLaunchCount);
        Assert.Equal(2, population.SynchronizationCount);
        Assert.Equal(2, population.DownloadCount);
        Assert.Equal(1, population.UploadCount);
    }

    [Fact]
    public void Every_supported_population_operation_matches_its_CPU_reference()
    {
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
        foreach (var identity in MathBlocksGPUWorker.SupportedPopulationOperationIdentities)
        {
            var separator = identity.LastIndexOf('@');
            var operation = MathBlockCatalog.Standard.Get(
                identity[..separator],
                int.Parse(
                    identity[(separator + 1)..],
                    System.Globalization.CultureInfo.InvariantCulture));
            var inputs = operation.RegressionCases[0].Inputs;
            var inputTypes = inputs.Select(input => input.Type).ToArray();
            var outputType = operation.ResolveOutputType(inputTypes);
            var grammar = new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    operation.Identifier,
                    operation.Version,
                    inputTypes,
                    outputType)],
                outputType);
            var terminals = inputs.Select((input, index) =>
                new MathBlockProgramPopulationTerminal($"input-{index}", input.Type, input)).ToArray();
            var maximumOutputElements = inputs
                .Append(operation.RegressionCases[0].Expected)
                .Max(ValueCount);
            var total = 1;
            for (var inputIndex = 0; inputIndex < operation.Arity; inputIndex++)
                total = checked(total * terminals.Length);
            var definition = new MathBlockProgramPopulationDefinition(
                grammar,
                terminals,
                [],
                [new MathBlockProgramPopulationResourceBand(1, maximumOutputElements)],
                proposalsPerCycle: total,
                fingerprintCapacity: total);
            using var population = new MathBlocksGPUWorker().CompilePopulation(definition);

            var cycle = population.ExecuteCycle();

            Assert.True(cycle.IsComplete, identity);
            Assert.NotEmpty(cycle.Candidates);
            Assert.True(cycle.Instrumentation.EvaluatedProgramCount > 0, identity);
            foreach (var candidate in cycle.Candidates)
                AssertExact(definition.Evaluate(candidate), candidate.Output);
            Assert.Equal(1, cycle.Instrumentation.UploadCount);
            Assert.Equal(1, cycle.Instrumentation.GraphLaunchCount);
            Assert.Equal(1, cycle.Instrumentation.SynchronizationCount);
            Assert.Equal(1, cycle.Instrumentation.DownloadCount);
            Assert.Equal(0, cycle.Instrumentation.CpuNodeDispatchCount);
        }
    }

    [Fact]
    public void Population_contracts_fail_closed_for_invalid_inputs()
    {
        var negativeZeroBits = BitConverter.DoubleToInt64Bits(-0d);
        var exactConstant = new MathBlockProgramPopulationConstant(negativeZeroBits);
        Assert.Equal(negativeZeroBits, exactConstant.Bits);
        Assert.Equal(negativeZeroBits, BitConverter.DoubleToInt64Bits(exactConstant.Value));
        Assert.Throws<ArgumentOutOfRangeException>(() =>
            new MathBlockProgramPopulationConstant(BitConverter.DoubleToInt64Bits(double.NaN)));
        Assert.Throws<ArgumentException>(() => new MathBlockProgramCandidate(
            0,
            [
                MathBlockProgramCandidateNode.Terminal(0, "value", MathBlockType.Scalar()),
                MathBlockProgramCandidateNode.Operation(
                    "scalar.add",
                    1,
                    MathBlockType.Scalar(),
                    0,
                    2)
            ],
            MathBlockValue.Scalar(1d)));
        Assert.Throws<ArgumentOutOfRangeException>(() => CreateScalarDefinition(
            proposalsPerCycle: 8,
            fingerprintCapacity: 7));

        var boolean = MathBlockType.Boolean;
        var invalidGrammar = new MathBlockProgramPopulationGrammar(
            [new MathBlockProgramPopulationOperation("scalar.add", 1, [boolean, boolean], boolean)],
            boolean);
        var invalidDefinition = new MathBlockProgramPopulationDefinition(
            invalidGrammar,
            [new MathBlockProgramPopulationTerminal("value", boolean, MathBlockValue.Boolean(true))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 1);
        Assert.Throws<InvalidOperationException>(() =>
            new MathBlocksGPUWorker().CompilePopulation(invalidDefinition));

        var scalar = MathBlockType.Scalar();
        var unsupportedGrammar = new MathBlockProgramPopulationGrammar(
            [new MathBlockProgramPopulationOperation("scalar.sine", 1, [scalar], scalar)],
            scalar);
        var unsupportedDefinition = new MathBlockProgramPopulationDefinition(
            unsupportedGrammar,
            [new MathBlockProgramPopulationTerminal("value", scalar, MathBlockValue.Scalar(1d))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 1);
        Assert.Throws<NotSupportedException>(() =>
            new MathBlocksGPUWorker().CompilePopulation(unsupportedDefinition));
    }

    private static MathBlockProgramPopulationDefinition CreateScalarDefinition(
        int proposalsPerCycle,
        MathBlockProgramPopulationState? acceptedState = null,
        double firstTerminal = 2d,
        int fingerprintCapacity = 8)
    {
        var scalar = MathBlockType.Scalar();
        var grammar = new MathBlockProgramPopulationGrammar(
            [
                new MathBlockProgramPopulationOperation("scalar.add", 1, [scalar, scalar], scalar),
                new MathBlockProgramPopulationOperation("scalar.multiply", 1, [scalar, scalar], scalar)
            ],
            scalar);
        return new MathBlockProgramPopulationDefinition(
            grammar,
            [new MathBlockProgramPopulationTerminal("input", scalar, MathBlockValue.Scalar(firstTerminal))],
            [new MathBlockProgramPopulationConstant(BitConverter.DoubleToInt64Bits(3d))],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle,
            fingerprintCapacity,
            acceptedState);
    }

    private static void AssertCandidatesEqual(
        IReadOnlyList<MathBlockProgramCandidate> expected,
        IReadOnlyList<MathBlockProgramCandidate> actual)
    {
        Assert.Equal(expected.Count, actual.Count);
        for (var index = 0; index < expected.Count; index++)
        {
            Assert.Equal(expected[index].ProposalCursor, actual[index].ProposalCursor);
            Assert.Equal(expected[index].StructuralFingerprint, actual[index].StructuralFingerprint);
            Assert.Equal(expected[index].SemanticFingerprint, actual[index].SemanticFingerprint);
            AssertExact(expected[index].Output, actual[index].Output);
        }
    }

    private static void AssertExact(MathBlockValue expected, MathBlockValue actual)
    {
        Assert.True(expected.IsValid);
        Assert.True(actual.IsValid);
        Assert.Equal(expected.Type, actual.Type);
        switch (expected.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                Assert.Equal(
                    BitConverter.DoubleToInt64Bits(expected.AsScalar()),
                    BitConverter.DoubleToInt64Bits(actual.AsScalar()));
                break;
            case MathBlockValueKind.Vector:
                Assert.Equal(
                    expected.AsVector().Select(BitConverter.DoubleToInt64Bits),
                    actual.AsVector().Select(BitConverter.DoubleToInt64Bits));
                break;
            case MathBlockValueKind.Boolean:
                Assert.Equal(expected.AsBoolean(), actual.AsBoolean());
                break;
            case MathBlockValueKind.BooleanVector:
                Assert.Equal(expected.AsBooleanVector(), actual.AsBooleanVector());
                break;
            default:
                throw new InvalidOperationException("The test value kind is unsupported.");
        }
    }

    private static int ValueCount(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 1,
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        _ => throw new InvalidOperationException("The population test value kind is unsupported.")
    };
}
