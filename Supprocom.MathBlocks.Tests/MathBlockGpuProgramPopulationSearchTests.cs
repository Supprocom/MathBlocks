using Supprocom.MathBlocks.Gpu;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockGpuProgramPopulationSearchTests
{
    [Fact]
    public void Resident_search_enumerates_a_known_grammar_without_output_materialization()
    {
        RequireCuda();
        var definition = CreateScalarSearch(proposalsPerCycle: 4);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(4, result.Trials.Count);
        Assert.Equal([0ul, 1ul, 2ul, 3ul], result.Trials.Select(trial => trial.Program.ProposalCursor!.Value));
        Assert.All(result.Trials.Where(trial => trial.Objectives.Count != 0), trial =>
        {
            Assert.Equal(definition.EvaluateObjectives(trial.Program), trial.Objectives);
            Assert.Equal(definition.CreateSemanticFingerprint(trial.Program), trial.SemanticFingerprint);
        });
        Assert.True(result.AcceptedState.SemanticDuplicateCount > 0);
        Assert.Contains(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.SemanticDuplicate);
        Assert.Equal(
            result.AcceptedState.SelectionEntries.Count,
            result.AcceptedState.SelectionEntries
                .Select(entry => (entry.SemanticFingerprint, Objectives: string.Join(",", entry.Objectives.Select(BitConverter.DoubleToInt64Bits))))
                .Distinct()
                .Count());
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal((long)compiled.CompactDownloadBytesPerCycle, compiled.DownloadedBytes);
    }

    [Fact]
    public void Resident_search_resume_reproduces_the_exact_next_cycle()
    {
        RequireCuda();
        var definition = CreateScalarSearch(proposalsPerCycle: 2);
        using var uninterrupted = new MathBlocksGPUWorker().CompilePopulationSearch(definition);
        var first = uninterrupted.ExecuteCycle();
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());

        var expected = uninterrupted.ExecuteCycle();
        var resumedDefinition = definition.WithAcceptedState(checkpoint);
        using var resumed = new MathBlocksGPUWorker().CompilePopulationSearch(resumedDefinition);
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(
            expected.Trials.Select(TrialIdentity),
            actual.Trials.Select(TrialIdentity));
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
    }

    [Fact]
    public async Task Resident_search_serializes_concurrent_cycles()
    {
        RequireCuda();
        var definition = CreateScalarSearch(proposalsPerCycle: 2);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var results = await Task.WhenAll(
            Task.Run(compiled.ExecuteCycle),
            Task.Run(compiled.ExecuteCycle));

        Assert.Equal(4ul, compiled.TrialCursor);
        Assert.Equal(2, compiled.GraphLaunchCount);
        Assert.Equal(2, compiled.SynchronizationCount);
        Assert.Equal(2, compiled.DownloadCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(
            [0ul, 1ul, 2ul, 3ul],
            results.SelectMany(result => result.Trials)
                .Select(trial => trial.Program.TrialCursor)
                .OrderBy(cursor => cursor));
    }

    [Fact]
    public void Resident_search_supports_dynamic_output_capacity_and_valid_row_objectives()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var dynamicVector = MathBlockType.Vector();
        var grammar = new MathBlockProgramPopulationGrammar(
            [new MathBlockProgramPopulationOperation(
                "vector.repeat",
                1,
                [scalar, scalar],
                dynamicVector)],
            dynamicVector);
        var population = new MathBlockProgramPopulationDefinition(
            grammar,
            [
                new MathBlockProgramPopulationTerminal("two", scalar, MathBlockValue.Scalar(2d)),
                new MathBlockProgramPopulationTerminal("four", scalar, MathBlockValue.Scalar(4d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 4)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicVector);
        var sum = objectiveBuilder.Apply("vector.sum", inputs: [candidate]);
        var objectiveProgram = objectiveBuilder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2, 3]));
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(4, result.Trials.Count);
        Assert.Contains(result.Trials, trial =>
            trial.Objectives.Count != 0 && trial.Objectives[0] == 16d);
        Assert.All(result.Trials.Where(trial => trial.Objectives.Count != 0), trial =>
        {
            Assert.Equal(definition.EvaluateObjectives(trial.Program), trial.Objectives);
            Assert.Equal(definition.CreateSemanticFingerprint(trial.Program), trial.SemanticFingerprint);
        });
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    [Fact]
    public void Failed_resident_cycle_preserves_the_previous_accepted_checkpoint()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var vector = MathBlockType.Vector();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("vector.repeat", 1, [scalar, scalar], vector)],
                vector),
            [
                new MathBlockProgramPopulationTerminal("value", scalar, MathBlockValue.Scalar(2d)),
                new MathBlockProgramPopulationTerminal("count", scalar, MathBlockValue.Scalar(4d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 2)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", vector);
        var sum = objectiveBuilder.Apply("vector.sum", inputs: [candidate]);
        var objectiveProgram = objectiveBuilder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1]));
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);
        var before = compiled.AcceptedState.Export();

        Assert.Throws<InvalidOperationException>(compiled.ExecuteCycle);

        Assert.Equal(before, compiled.AcceptedState.Export());
        Assert.Equal(0ul, compiled.TrialCursor);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_search_masks_warmup_rows_for_objectives_and_semantic_fingerprints()
    {
        RequireCuda();
        var vector = MathBlockType.Vector(length: 4);
        var grammar = new MathBlockProgramPopulationGrammar(
            [new MathBlockProgramPopulationOperation("vector.absolute", 1, [vector], vector)],
            vector);
        var population = new MathBlockProgramPopulationDefinition(
            grammar,
            [
                new MathBlockProgramPopulationTerminal(
                    "short-lookback",
                    vector,
                    MathBlockValue.Vector([777d, 5d, 3d, 4d]),
                    lookback: 1),
                new MathBlockProgramPopulationTerminal(
                    "long-lookback",
                    vector,
                    MathBlockValue.Vector([888d, 999d, 3d, 4d]),
                    lookback: 2)
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 4)],
            proposalsPerCycle: 2,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", vector);
        var mask = objectiveBuilder.Input("valid", MathBlockType.BooleanVector(4));
        var zero = objectiveBuilder.Input("zero", vector);
        var selected = objectiveBuilder.Apply("vector.select", inputs: [mask, candidate, zero]);
        var sum = objectiveBuilder.Apply("vector.sum", inputs: [selected]);
        var objectiveProgram = objectiveBuilder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>
            {
                ["zero"] = MathBlockValue.Vector([0d, 0d, 0d, 0d])
            },
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)],
            candidateValidityMaskInput: "valid");
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 2,
            enumerationTrials: 2,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2, 3]));
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal([12d, 7d], result.Trials.Select(trial => trial.Objectives.Single()));
        Assert.All(result.Trials, trial =>
        {
            Assert.Equal(definition.EvaluateObjectives(trial.Program), trial.Objectives);
            Assert.Equal(definition.CreateSemanticFingerprint(trial.Program), trial.SemanticFingerprint);
        });
        Assert.NotEqual(result.Trials[0].SemanticFingerprint, result.Trials[1].SemanticFingerprint);
    }

    [Fact]
    public void Resident_search_binds_candidate_and_validity_mask_through_rank_objectives()
    {
        RequireCuda();
        var definition = CreateRankObjectiveSearch();
        var terminalNodes = definition.Population.Terminals
            .Select((terminal, index) => MathBlockProgramCandidateNode.Terminal(
                index,
                terminal.Identifier,
                terminal.Type))
            .ToList();
        terminalNodes.AddRange(definition.Population.ScalarConstants.Select((constant, index) =>
            MathBlockProgramCandidateNode.Terminal(
                definition.Population.Terminals.Count + index,
                $"constant-{index}",
                MathBlockType.Scalar(constant.Unit))));
        terminalNodes.Add(MathBlockProgramCandidateNode.Operation(
            "vector.absolute",
            1,
            definition.Population.Grammar.Operations.Single().OutputType,
            0));
        var expectedProgram = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            terminalNodes);
        var expectedObjectives = definition.EvaluateObjectives(expectedProgram);
        var expectedSemantic = definition.CreateSemanticFingerprint(expectedProgram);
        Assert.All(expectedObjectives, value => Assert.True(double.IsFinite(value)));
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);
        Assert.Equal(33, compiled.Capacity.MaximumValueElements);

        var result = compiled.ExecuteCycle();

        Assert.Equal(14, result.Trials.Count);
        Assert.Equal(
            13,
            result.Trials.Count(trial => trial.Status == MathBlockProgramPopulationTrialStatus.InvalidType));
        var accepted = Assert.Single(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.Accepted);
        Assert.Equal(expectedProgram.StructuralFingerprint, accepted.StructuralFingerprint);
        Assert.Equal(
            expectedObjectives.Select(BitConverter.DoubleToInt64Bits),
            accepted.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.All(accepted.Objectives, value => Assert.True(double.IsFinite(value)));
        Assert.Equal(expectedSemantic, accepted.SemanticFingerprint);
        Assert.Equal((ulong)1, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal((ulong)1, result.AcceptedState.AcceptedProgramCount);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_search_resolves_dynamic_matrix_candidate_shape_for_objectives()
    {
        RequireCuda();
        var sourceType = MathBlockType.Matrix(rows: 3, columns: 2);
        var candidateType = MathBlockType.Matrix(rows: 2, columns: 3);
        var dynamicMatrix = MathBlockType.Matrix();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "matrix.transpose",
                    1,
                    [sourceType],
                    candidateType)],
                dynamicMatrix),
            [new MathBlockProgramPopulationTerminal(
                "telemetry-grid",
                sourceType,
                MathBlockValue.Matrix(new MathBlockMatrix(
                    3,
                    2,
                    [1d, 2d, 3d, 4d, 5d, 6d])))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 6)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicMatrix);
        var gram = objectiveBuilder.Apply("matrix.gram", inputs: [candidate]);
        var norm = objectiveBuilder.Apply("matrix.frobenius-norm", inputs: [gram]);
        var objectiveProgram = objectiveBuilder.Output("gram-norm", norm).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "gram-norm",
                "gram-norm",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 1,
            enumerationTrials: 1,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1]));
        var expectedProgram = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "telemetry-grid", sourceType),
                MathBlockProgramCandidateNode.Operation(
                    "matrix.transpose",
                    1,
                    candidateType,
                    0)
            ]);
        var expectedObjectives = definition.EvaluateObjectives(expectedProgram);
        var expectedSemantic = definition.CreateSemanticFingerprint(expectedProgram);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(9, compiled.Capacity.MaximumValueElements);
        Assert.Single(result.Trials);
        var accepted = Assert.Single(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.Accepted);
        Assert.Equal(expectedProgram.StructuralFingerprint, accepted.StructuralFingerprint);
        Assert.Equal(
            expectedObjectives.Select(BitConverter.DoubleToInt64Bits),
            accepted.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(expectedSemantic, accepted.SemanticFingerprint);
        Assert.Equal(1ul, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(1ul, result.AcceptedState.AcceptedProgramCount);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal((long)compiled.CompactDownloadBytesPerCycle, compiled.DownloadedBytes);
    }

    [Fact]
    public void Resident_search_resolves_partial_matrix_capacity_from_dynamic_vector_shape()
    {
        RequireCuda();
        var staticVector = MathBlockType.Vector(length: 3);
        var dynamicVector = MathBlockType.Vector();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.absolute",
                    1,
                    [staticVector],
                    staticVector)],
                dynamicVector),
            [new MathBlockProgramPopulationTerminal(
                "telemetry-vector",
                staticVector,
                MathBlockValue.Vector([-1d, 2d, -3d]))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 3)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicVector);
        var stacked = objectiveBuilder.Apply("matrix.stack-rows", inputs: [candidate, candidate]);
        var flattened = objectiveBuilder.Apply("matrix.flatten", inputs: [stacked]);
        var sum = objectiveBuilder.Apply("vector.sum", inputs: [flattened]);
        var objectiveProgram = objectiveBuilder.Output("stacked-sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "stacked-sum",
                "stacked-sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 1,
            enumerationTrials: 1,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2]));
        var expectedProgram = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "telemetry-vector", staticVector),
                MathBlockProgramCandidateNode.Operation(
                    "vector.absolute",
                    1,
                    staticVector,
                    0)
            ]);
        var expectedObjectives = definition.EvaluateObjectives(expectedProgram);
        var expectedSemantic = definition.CreateSemanticFingerprint(expectedProgram);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(6, compiled.Capacity.MaximumValueElements);
        Assert.Single(result.Trials);
        var accepted = Assert.Single(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.Accepted);
        Assert.Equal(expectedProgram.StructuralFingerprint, accepted.StructuralFingerprint);
        Assert.Equal(
            expectedObjectives.Select(BitConverter.DoubleToInt64Bits),
            accepted.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(expectedSemantic, accepted.SemanticFingerprint);
        Assert.Equal(1ul, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(1ul, result.AcceptedState.AcceptedProgramCount);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal((long)compiled.CompactDownloadBytesPerCycle, compiled.DownloadedBytes);
    }

    [Fact]
    public void Resident_search_accepts_more_than_eight_objectives_and_intrinsic_sources()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var population = CreateScalarPopulation(proposalsPerCycle: 1);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var objectiveProgram = objectiveBuilder.Output("value", candidate).Build();
        var objectives = new List<MathBlockProgramPopulationObjective>();
        for (var index = 0; index < 9; index++)
        {
            objectives.Add(new MathBlockProgramPopulationObjective(
                $"value-{index}",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize));
        }
        objectives.Add(MathBlockProgramPopulationObjective.Intrinsic(
            "complexity",
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount,
            MathBlockProgramPopulationObjectiveDirection.Minimize));
        objectives.Add(MathBlockProgramPopulationObjective.Intrinsic(
            "lookback",
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.MaximumLookback,
            MathBlockProgramPopulationObjectiveDirection.Minimize));
        objectives.Add(MathBlockProgramPopulationObjective.Intrinsic(
            "cost",
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.DeterministicExecutionCost,
            MathBlockProgramPopulationObjectiveDirection.Minimize));
        objectives.Add(MathBlockProgramPopulationObjective.Intrinsic(
            "age",
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.Age,
            MathBlockProgramPopulationObjectiveDirection.Minimize));
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            objectives);
        var gridDimensions = Enumerable.Range(0, 9)
            .Select(index => new MathBlockProgramPopulationQualityDiversityDimension(
                $"value-{index}",
                0,
                10,
                2))
            .ToArray();
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 123),
            new MathBlockProgramPopulationSelectionPolicy(16, 12),
            new MathBlockProgramPopulationQualityDiversityPolicy("value-0", gridDimensions),
            new MathBlockProgramPopulationSearchEnvelope(256L * 1024 * 1024, 64 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]));
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(13, compiled.Capacity.ObjectiveCount);
        Assert.Equal(512, compiled.Capacity.QualityDiversityCellCount);
        Assert.Equal(13, result.Trials.Single().Objectives.Count);
        Assert.Equal(definition.EvaluateObjectives(result.Trials.Single().Program), result.Trials.Single().Objectives);
    }

    [Fact]
    public void Resident_search_resolves_typed_overloads_for_CPU_and_GPU_objectives()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var length = MathBlockType.Scalar(MathBlockUnit.Basis0);
        var operations = new[]
        {
            new MathBlockProgramPopulationOperation(
                "scalar.multiply",
                1,
                [scalar, length],
                length,
                deterministicCost: 2),
            new MathBlockProgramPopulationOperation(
                "scalar.multiply",
                1,
                [length, scalar],
                length,
                deterministicCost: 11)
        };
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "coefficient",
                scalar,
                MathBlockValue.Scalar(2d)),
            new MathBlockProgramPopulationTerminal(
                "short-length",
                length,
                MathBlockValue.Scalar(3d, MathBlockUnit.Basis0)),
            new MathBlockProgramPopulationTerminal(
                "long-length",
                length,
                MathBlockValue.Scalar(4d, MathBlockUnit.Basis0))
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, length),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 2,
            fingerprintCapacity: 32);
        var terminalNodes = terminals
            .Select((terminal, index) =>
                MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type))
            .ToArray();
        var coefficientFirst = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                .. terminalNodes,
                MathBlockProgramCandidateNode.Operation("scalar.multiply", 1, length, 0, 1)
            ]);
        var lengthFirst = new MathBlockProgramStructure(
            1,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                .. terminalNodes,
                MathBlockProgramCandidateNode.Operation("scalar.multiply", 1, length, 2, 0)
            ]);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", length);
        var objectiveProgram = objectiveBuilder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [
                new MathBlockProgramPopulationObjective(
                    "value",
                    "value",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                MathBlockProgramPopulationObjective.Intrinsic(
                    "cost",
                    MathBlockProgramPopulationIntrinsicObjectiveIdentities.DeterministicExecutionCost,
                    MathBlockProgramPopulationObjectiveDirection.Minimize)
            ]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 53),
            new MathBlockProgramPopulationSelectionPolicy(4, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension("cost", 0, 20, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(64 * 1024 * 1024, 16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]),
            initialPrograms: [coefficientFirst, lengthFirst]);

        Assert.Equal([6d, 2d], definition.EvaluateObjectives(coefficientFirst));
        Assert.Equal([8d, 11d], definition.EvaluateObjectives(lengthFirst));

        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);
        var result = compiled.ExecuteCycle();
        var selected = result.AcceptedState.SelectionEntries.ToDictionary(
            entry => entry.StructuralFingerprint,
            StringComparer.Ordinal);

        Assert.Equal(2, selected.Count);
        Assert.Equal([6d, 2d], selected[coefficientFirst.StructuralFingerprint].Objectives);
        Assert.Equal([8d, 11d], selected[lengthFirst.StructuralFingerprint].Objectives);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_search_types_overload_proposals_before_structural_deduplication()
    {
        RequireCuda();
        var definition = CreateVectorOverloadSearch(
            proposalsPerCycle: 787,
            maximumTrials: 787,
            enumerationTrials: 784,
            mutationTrials: 1,
            crossoverTrials: 1,
            immigrantTrials: 1);
        var reference = CreateVectorOverloadCpuReference(definition);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();
        var enumeration = result.Trials
            .Where(trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Enumeration)
            .ToArray();
        var evaluated = enumeration.Where(trial => trial.Objectives.Count != 0).ToArray();
        var evolved = result.Trials
            .Where(trial => trial.Program.Source != MathBlockProgramPopulationTrialSource.Enumeration)
            .ToArray();

        Assert.Equal(784ul, definition.Population.TotalProposalCount);
        Assert.Equal(52, reference.Count);
        Assert.Equal(784, enumeration.Length);
        Assert.Equal(732, enumeration.Count(
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.InvalidType));
        Assert.DoesNotContain(
            enumeration,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.StructuralDuplicate);
        Assert.Equal(reference.Count, evaluated.Length);
        Assert.Equal(
            reference.Keys.Order(StringComparer.Ordinal),
            evaluated.Select(trial => trial.StructuralFingerprint).Order(StringComparer.Ordinal));
        Assert.All(evaluated, trial =>
        {
            var expected = reference[trial.StructuralFingerprint];
            Assert.Equal(expected.Objective, trial.Objectives.Single());
            Assert.Equal(expected.SemanticFingerprint, trial.SemanticFingerprint);
            Assert.Equal(definition.EvaluateObjectives(trial.Program), trial.Objectives);
        });
        Assert.Equal(
            [
                MathBlockProgramPopulationTrialSource.Mutation,
                MathBlockProgramPopulationTrialSource.Crossover,
                MathBlockProgramPopulationTrialSource.RandomImmigrant
            ],
            evolved.Select(trial => trial.Program.Source).OrderBy(source => source));
        Assert.All(evolved, trial => Assert.True(
            trial.Status is MathBlockProgramPopulationTrialStatus.StructuralDuplicate or
                MathBlockProgramPopulationTrialStatus.InvalidType or
                MathBlockProgramPopulationTrialStatus.InsufficientParents));
        Assert.Equal((ulong)reference.Count, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(
            reference.Keys.Order(StringComparer.Ordinal),
            result.AcceptedState.StructuralFingerprints.Order(StringComparer.Ordinal));
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_overload_search_resume_reproduces_the_exact_next_cycle()
    {
        RequireCuda();
        var definition = CreateVectorOverloadSearch(
            proposalsPerCycle: 392,
            maximumTrials: 784,
            enumerationTrials: 784);
        var reference = CreateVectorOverloadCpuReference(definition);
        using var uninterrupted = new MathBlocksGPUWorker().CompilePopulationSearch(definition);
        var first = uninterrupted.ExecuteCycle();
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());

        var expected = uninterrupted.ExecuteCycle();
        using var resumed = new MathBlocksGPUWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint));
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Equal((ulong)reference.Count, actual.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(
            reference.Keys.Order(StringComparer.Ordinal),
            actual.AcceptedState.StructuralFingerprints.Order(StringComparer.Ordinal));
        Assert.All(actual.Trials.Where(trial => trial.Objectives.Count != 0), trial =>
        {
            var cpu = reference[trial.StructuralFingerprint];
            Assert.Equal(cpu.Objective, trial.Objectives.Single());
            Assert.Equal(cpu.SemanticFingerprint, trial.SemanticFingerprint);
        });
        Assert.Equal(1, uninterrupted.ImmutableUploadCount);
        Assert.Equal(0, uninterrupted.LaterImmutableUploadCount);
        Assert.Equal(2, uninterrupted.GraphLaunchCount);
        Assert.Equal(2, uninterrupted.SynchronizationCount);
        Assert.Equal(2, uninterrupted.DownloadCount);
        Assert.Equal(0, uninterrupted.FullCandidateOutputDownloadCount);
        Assert.Equal(0, uninterrupted.CpuNodeDispatchCount);
        Assert.Equal(1, resumed.GraphInstanceCount);
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputBytes);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
    }

    [Fact]
    public void Expanded_terminal_refresh_restores_structural_and_semantic_deduplication()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var operation = new MathBlockProgramPopulationOperation(
            "scalar.absolute",
            1,
            [scalar],
            scalar);
        var initialPopulation = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar([operation], scalar),
            [new MathBlockProgramPopulationTerminal("first", scalar, MathBlockValue.Scalar(-2d))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var objectiveProgram = objectiveBuilder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var selection = new MathBlockProgramPopulationSelectionPolicy(4, 8);
        var quality = new MathBlockProgramPopulationQualityDiversityPolicy(
            "value",
            [new MathBlockProgramPopulationQualityDiversityDimension("value", 0, 4, 4)]);
        var envelope = new MathBlockProgramPopulationSearchEnvelope(
            64 * 1024 * 1024,
            16 * 1024 * 1024);
        var validity = new MathBlockProgramPopulationValidityPolicy([1]);
        var initialDefinition = new MathBlockProgramPopulationSearchDefinition(
            initialPopulation,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 61),
            selection,
            quality,
            envelope,
            validity);
        using var initialCompiled = new MathBlocksGPUWorker().CompilePopulationSearch(initialDefinition);
        var initial = initialCompiled.ExecuteCycle();

        var expandedPopulation = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar([operation], scalar),
            [
                new MathBlockProgramPopulationTerminal("first", scalar, MathBlockValue.Scalar(-2d)),
                new MathBlockProgramPopulationTerminal("second", scalar, MathBlockValue.Scalar(-2d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 3,
            fingerprintCapacity: 8);
        var expandedDefinition = new MathBlockProgramPopulationSearchDefinition(
            expandedPopulation,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(3, 2, 0, 0, 1, 61),
            selection,
            quality,
            envelope,
            validity);
        var transition = expandedDefinition.CreateTransitionState(
            initialDefinition,
            initial.AcceptedState);
        var refreshedFingerprint = transition.RefreshPrograms.Single().StructuralFingerprint;
        using var resumed = new MathBlocksGPUWorker().CompilePopulationSearch(
            expandedDefinition.WithAcceptedState(transition));

        var result = resumed.ExecuteCycle();

        Assert.Equal(2, result.Trials.Count);
        Assert.Contains(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.StructuralDuplicate);
        Assert.Contains(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.SemanticDuplicate);
        Assert.Equal(
            initial.AcceptedState.StructuralDuplicateCount + 1,
            result.AcceptedState.StructuralDuplicateCount);
        Assert.Equal(
            initial.AcceptedState.SemanticDuplicateCount + 1,
            result.AcceptedState.SemanticDuplicateCount);
        Assert.Equal(2, result.AcceptedState.StructuralFingerprints.Count);
        Assert.Single(result.AcceptedState.SemanticFingerprints);
        Assert.Contains(refreshedFingerprint, result.AcceptedState.StructuralFingerprints);
        Assert.Single(result.AcceptedState.SelectionEntries);
        Assert.Single(result.AcceptedState.QualityDiversityEntries);
        Assert.Equal(
            refreshedFingerprint,
            result.AcceptedState.SelectionEntries.Single().StructuralFingerprint);
        Assert.Equal(
            refreshedFingerprint,
            result.AcceptedState.QualityDiversityEntries.Single().StructuralFingerprint);
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_search_dovetails_into_an_expanded_graph_band()
    {
        RequireCuda();
        var initialDefinition = CreateNegationBandSearch([new MathBlockProgramPopulationResourceBand(1, 1)], 1);
        using var initialCompiled = new MathBlocksGPUWorker().CompilePopulationSearch(initialDefinition);
        var initial = initialCompiled.ExecuteCycle();
        var initialTrialCursor = initial.AcceptedState.TrialCursor;

        var expandedDefinition = CreateNegationBandSearch(
            [
                new MathBlockProgramPopulationResourceBand(1, 1),
                new MathBlockProgramPopulationResourceBand(9, 1)
            ],
            3);
        var transition = expandedDefinition.CreateTransitionState(initialDefinition, initial.AcceptedState);
        var resumedDefinition = expandedDefinition.WithAcceptedState(transition);
        using var resumed = new MathBlocksGPUWorker().CompilePopulationSearch(resumedDefinition);
        var result = resumed.ExecuteCycle();

        Assert.Equal(1ul, result.AcceptedState.EnvelopeGeneration);
        Assert.True(result.AcceptedState.TrialCursor > initialTrialCursor);
        Assert.Contains(result.Trials, trial =>
            trial.Program.Nodes.Count -
                (resumedDefinition.Population.Terminals.Count + resumedDefinition.Population.ScalarConstants.Count) == 9);
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_search_executes_mutation_crossover_and_random_immigrants()
    {
        RequireCuda();
        var definition = CreateScalarSearch(
            proposalsPerCycle: 7,
            maximumTrials: 7,
            enumerationTrials: 4,
            mutationTrials: 1,
            crossoverTrials: 1,
            immigrantTrials: 1);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Contains(result.Trials, trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Mutation);
        Assert.Contains(result.Trials, trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Crossover);
        Assert.Contains(result.Trials, trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.RandomImmigrant);
        Assert.Equal(7ul, result.AcceptedState.TrialCursor);
        Assert.False(
            result.AcceptedState.RandomState.First == 0 &&
            result.AcceptedState.RandomState.Second == 0);
    }

    [Fact]
    public void Intrinsic_complexity_selects_the_simpler_equal_output_program_on_CUDA()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var operation = new MathBlockProgramPopulationOperation(
            "scalar.absolute",
            1,
            [scalar],
            scalar,
            deterministicCost: 3);
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar([operation], scalar),
            [new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d))],
            [],
            [
                new MathBlockProgramPopulationResourceBand(1, 1),
                new MathBlockProgramPopulationResourceBand(2, 1)
            ],
            proposalsPerCycle: 2,
            fingerprintCapacity: 3);
        var terminal = MathBlockProgramCandidateNode.Terminal(0, "one", scalar);
        var complex = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                terminal,
                MathBlockProgramCandidateNode.Operation("scalar.absolute", 1, scalar, 0),
                MathBlockProgramCandidateNode.Operation("scalar.absolute", 1, scalar, 1)
            ]);
        var simple = new MathBlockProgramStructure(
            1,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [terminal, MathBlockProgramCandidateNode.Operation("scalar.absolute", 1, scalar, 0)]);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var objectiveProgram = objectiveBuilder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [
                new MathBlockProgramPopulationObjective(
                    "value",
                    "value",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                MathBlockProgramPopulationObjective.Intrinsic(
                    "complexity",
                    MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount,
                    MathBlockProgramPopulationObjectiveDirection.Minimize),
                MathBlockProgramPopulationObjective.Intrinsic(
                    "cost",
                    MathBlockProgramPopulationIntrinsicObjectiveIdentities.DeterministicExecutionCost,
                    MathBlockProgramPopulationObjectiveDirection.Minimize)
            ]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 29),
            new MathBlockProgramPopulationSelectionPolicy(2, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "complexity",
                [new MathBlockProgramPopulationQualityDiversityDimension("value", 0, 2, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(64 * 1024 * 1024, 16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]),
            initialPrograms: [complex, simple]);
        using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.NotEmpty(result.AcceptedState.SelectionEntries);
        Assert.All(
            result.AcceptedState.SelectionEntries,
            entry => Assert.Equal(1, entry.Program.Nodes.Count - population.Terminals.Count));
        Assert.Contains(
            result.AcceptedState.QualityDiversityEntries,
            entry => entry.Program.StructuralFingerprint == simple.StructuralFingerprint);
        Assert.DoesNotContain(
            result.AcceptedState.SelectionEntries.Concat(result.AcceptedState.QualityDiversityEntries),
            entry => entry.Program.StructuralFingerprint == complex.StructuralFingerprint);
        Assert.Equal([1d, 1d, 3d], definition.EvaluateObjectives(simple));
        Assert.Equal(definition.CreateSemanticFingerprint(simple), definition.CreateSemanticFingerprint(complex));
    }

    [Fact]
    public void Resident_search_catalog_covers_every_public_GPU_operation_identity()
    {
        RequireCuda();
        Assert.Equal(
            MathBlocksGPUWorker.SupportedBlockIdentities.OrderBy(identity => identity),
            MathBlocksGPUWorker.SupportedPopulationSearchOperationIdentities.OrderBy(identity => identity));

        foreach (var identity in MathBlocksGPUWorker.SupportedPopulationSearchOperationIdentities)
        {
            var operation = MathBlockCatalog.Standard.Operations.Single(operation => operation.Identity == identity);
            var regression = operation.RegressionCases[0];
            var inputTypes = regression.Inputs.Select(input => input.Type).ToArray();
            var outputType = operation.ResolveOutputType(inputTypes);
            var descriptor = new MathBlockProgramPopulationOperation(
                operation.Identifier,
                operation.Version,
                inputTypes,
                outputType);
            var grammar = new MathBlockProgramPopulationGrammar([descriptor], outputType);
            var terminals = regression.Inputs
                .Select((value, index) => new MathBlockProgramPopulationTerminal($"input-{index}", value.Type, value))
                .ToList();
            if (terminals.Count == 0)
                terminals.Add(new MathBlockProgramPopulationTerminal("seed", MathBlockType.Scalar(), MathBlockValue.Scalar(0d)));
            var nodes = terminals
                .Select((terminal, index) => MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type))
                .ToList();
            nodes.Add(MathBlockProgramCandidateNode.Operation(
                operation.Identifier,
                operation.Version,
                outputType,
                Enumerable.Range(0, operation.Arity).ToArray()));
            var program = new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                nodes);
            var terminalCount = terminals.Count;
            var proposalCount = 1;
            for (var input = 0; input < operation.Arity; input++)
                proposalCount = checked(proposalCount * terminalCount);
            var maximumElements = Math.Max(
                1,
                Math.Max(
                    ValueElementCount(regression.Expected),
                    regression.Inputs.Count == 0 ? 0 : regression.Inputs.Max(ValueElementCount)));
            var population = new MathBlockProgramPopulationDefinition(
                grammar,
                terminals,
                [],
                [new MathBlockProgramPopulationResourceBand(1, maximumElements)],
                proposalsPerCycle: 1,
                fingerprintCapacity: proposalCount);
            var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var candidate = objectiveBuilder.Input("candidate", outputType);
            var objectiveProgram = objectiveBuilder.Output("candidate", candidate).Build();
            var binding = new MathBlockProgramPopulationObjectiveBinding(
                objectiveProgram,
                "candidate",
                new Dictionary<string, MathBlockValue>(),
                [MathBlockProgramPopulationObjective.Intrinsic(
                    "complexity",
                    MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount,
                    MathBlockProgramPopulationObjectiveDirection.Minimize)]);
            var validityRows = Math.Max(1, ValidityRowCount(regression.Expected));
            var definition = new MathBlockProgramPopulationSearchDefinition(
                population,
                binding,
                new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 17),
                new MathBlockProgramPopulationSelectionPolicy(2, 4),
                new MathBlockProgramPopulationQualityDiversityPolicy(
                    "complexity",
                    [new MathBlockProgramPopulationQualityDiversityDimension("complexity", 0, 4, 2)]),
                new MathBlockProgramPopulationSearchEnvelope(512L * 1024 * 1024, 64 * 1024 * 1024),
                new MathBlockProgramPopulationValidityPolicy(Enumerable.Repeat(int.MaxValue, validityRows)),
                initialPrograms: [program]);

            using var compiled = new MathBlocksGPUWorker().CompilePopulationSearch(definition);
            var result = compiled.ExecuteCycle();
            var archived = result.AcceptedState.SelectionEntries
                .Concat(result.AcceptedState.QualityDiversityEntries)
                .FirstOrDefault(entry => entry.StructuralFingerprint == program.StructuralFingerprint);
            Assert.True(archived is not null, $"Resident execution did not accept '{identity}'.");
            Assert.Equal(definition.CreateSemanticFingerprint(program), archived!.SemanticFingerprint);
            Assert.Equal(1, compiled.ImmutableUploadCount);
            Assert.Equal(1, compiled.GraphLaunchCount);
            Assert.Equal(1, compiled.SynchronizationCount);
            Assert.Equal(1, compiled.DownloadCount);
            Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
            Assert.Equal(0, compiled.CpuNodeDispatchCount);
        }
    }

    private static MathBlockProgramPopulationSearchDefinition CreateScalarSearch(
        int proposalsPerCycle,
        ulong maximumTrials = 4,
        ulong enumerationTrials = 4,
        int mutationTrials = 0,
        int crossoverTrials = 0,
        int immigrantTrials = 0)
    {
        var scalar = MathBlockType.Scalar();
        var population = CreateScalarPopulation(proposalsPerCycle);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var objectiveProgram = objectiveBuilder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return CreateDefinition(
            population,
            binding,
            maximumTrials,
            enumerationTrials,
            new MathBlockProgramPopulationValidityPolicy([1]),
            mutationTrials: mutationTrials,
            crossoverTrials: crossoverTrials,
            immigrantTrials: immigrantTrials);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateRankObjectiveSearch()
    {
        const int rowCount = 18;
        var staticVector = MathBlockType.Vector(length: rowCount);
        var dynamicVector = MathBlockType.Vector();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.absolute",
                    1,
                    [staticVector],
                    staticVector)],
                dynamicVector),
            [new MathBlockProgramPopulationTerminal(
                "telemetry-count",
                staticVector,
                MathBlockValue.Vector(Enumerable.Range(1, rowCount).Select(value => -(double)value)))],
            Enumerable.Range(0, 13).Select(value => new MathBlockProgramPopulationConstant(
                BitConverter.DoubleToInt64Bits(value + 0.25))),
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 14,
            fingerprintCapacity: 14);

        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", dynamicVector);
        var candidateValidity = builder.Input("candidate-validity", MathBlockType.BooleanVector());
        var baseline = builder.Input("baseline", staticVector);
        var upper = builder.Input("upper", staticVector);
        var lower = builder.Input("lower", staticVector);
        var eligibility = builder.Input("eligibility", MathBlockType.BooleanVector(rowCount));
        var firstSegment = builder.Input("first-segment", MathBlockType.BooleanVector(rowCount));
        var secondSegment = builder.Input("second-segment", MathBlockType.BooleanVector(rowCount));

        int Scalar(double value) => builder.Constant(MathBlockValue.Scalar(value));
        int Apply(string identity, params int[] inputs) => builder.Apply(identity, inputs: inputs);
        int And(int left, int right) => Apply("boolean-vector.and", left, right);
        int Or(int left, int right) => Apply("boolean-vector.or", left, right);
        int Not(int value) => Apply("boolean-vector.not", value);
        int VectorSelect(int mask, int whenTrue, int whenFalse) =>
            Apply("vector.select", mask, whenTrue, whenFalse);
        int ScalarSelect(int condition, int whenTrue, int whenFalse) =>
            Apply("scalar.select", condition, whenTrue, whenFalse);
        int RepeatNode(int value, int count) => Apply("vector.repeat", value, Scalar(count));
        int RepeatValue(double value, int count) => RepeatNode(Scalar(value), count);
        int AtLeast(int value, int minimum) =>
            Apply("scalar.greater-than", value, Scalar(minimum - 1d));
        int BooleanAsScalar(int value) => ScalarSelect(value, Scalar(1d), Scalar(0d));
        int VectorFromScalars(params int[] values)
        {
            var vectors = values.Select(value => RepeatNode(value, 1)).ToArray();
            while (vectors.Length > 1)
            {
                var combined = new List<int>((vectors.Length + 1) / 2);
                for (var index = 0; index < vectors.Length; index += 2)
                {
                    combined.Add(index + 1 < vectors.Length
                        ? Apply("vector.concatenate", vectors[index], vectors[index + 1])
                        : vectors[index]);
                }
                vectors = combined.ToArray();
            }
            return vectors[0];
        }

        var zeroVector = RepeatValue(0d, rowCount);
        var trueVector = Apply("vector.equal", zeroVector, zeroVector);
        var falseVector = Not(trueVector);
        int ShiftForward(int source)
        {
            var head = Apply("vector.slice", source, Scalar(1d), Scalar(rowCount - 1d));
            return Apply("vector.concatenate", head, RepeatValue(0d, 1));
        }
        int Movement(int source, double scale)
        {
            var ratio = Apply("vector.divide", ShiftForward(source), baseline);
            var change = Apply("vector.add-scalar", ratio, Scalar(-1d));
            return Apply("vector.positive-part", Apply("vector.scale", change, Scalar(scale)));
        }

        var favorable = Movement(upper, 10_000d);
        var adverse = Movement(lower, -10_000d);
        var adverseThreshold = RepeatValue(20d, rowCount);
        var adverseReached = And(
            eligibility,
            Or(
                Apply("vector.greater-than", adverse, adverseThreshold),
                Apply("vector.equal", adverse, adverseThreshold)));
        var improves = Apply("vector.greater-than", favorable, zeroVector);
        var ambiguous = Or(falseVector, And(adverseReached, improves));
        var continues = And(eligibility, Not(adverseReached));
        var reachable = VectorSelect(
            continues,
            VectorSelect(improves, favorable, zeroVector),
            zeroVector);
        var targetValidity = And(eligibility, Not(ambiguous));

        (int Raw, int Feasible) SafeSpearman(int segment, int minimumRows)
        {
            var eligible = And(And(segment, targetValidity), candidateValidity);
            var count = Apply("boolean-vector.true-count", eligible);
            var enoughForCorrelation = AtLeast(count, 2);
            var selector = Apply(
                "vector.greater-than",
                RepeatNode(BooleanAsScalar(enoughForCorrelation), rowCount),
                zeroVector);
            var fallback = builder.Constant(MathBlockValue.BooleanVector(
                Enumerable.Range(0, rowCount).Select(index => index < 2)));
            var safeMask = Or(And(eligible, selector), And(fallback, Not(selector)));
            var indexes = Apply("boolean-vector.true-indices", safeMask);
            var selectedCandidate = Apply("vector.gather", candidate, indexes);
            var selectedTarget = Apply("vector.gather", reachable, indexes);
            var candidateMinimum = Apply("vector.minimum", selectedCandidate);
            var candidateMaximum = Apply("vector.maximum", selectedCandidate);
            var targetMinimum = Apply("vector.minimum", selectedTarget);
            var targetMaximum = Apply("vector.maximum", selectedTarget);
            var candidateVariable = Apply("scalar.not-equal", candidateMinimum, candidateMaximum);
            var targetVariable = Apply("scalar.not-equal", targetMinimum, targetMaximum);
            int RepairConstant(int values, int variable)
            {
                var useOriginal = ScalarSelect(variable, Scalar(1d), Scalar(0d));
                var useIndexes = ScalarSelect(variable, Scalar(0d), Scalar(1d));
                return Apply(
                    "vector.add",
                    Apply("vector.scale", values, useOriginal),
                    Apply("vector.scale", indexes, useIndexes));
            }
            var raw = Apply(
                "statistics.spearman-correlation",
                RepairConstant(selectedCandidate, candidateVariable),
                RepairConstant(selectedTarget, targetVariable));
            var feasible = Apply(
                "boolean.and",
                AtLeast(count, minimumRows),
                Apply("boolean.and", candidateVariable, targetVariable));
            return (raw, feasible);
        }

        var aggregate = SafeSpearman(eligibility, 2);
        var orientation = Apply("scalar.sign", aggregate.Raw);
        var orientationFeasible = Apply("scalar.not-equal", orientation, Scalar(0d));
        var aggregateFeasible = Apply("boolean.and", aggregate.Feasible, orientationFeasible);
        var orientedAggregate = Apply("scalar.multiply", aggregate.Raw, orientation);
        var first = SafeSpearman(firstSegment, 2);
        var second = SafeSpearman(secondSegment, 2);
        var firstFeasible = Apply("boolean.and", first.Feasible, orientationFeasible);
        var secondFeasible = Apply("boolean.and", second.Feasible, orientationFeasible);
        var firstScore = ScalarSelect(
            firstFeasible,
            Apply("scalar.multiply", first.Raw, orientation),
            Scalar(-2d));
        var secondScore = ScalarSelect(
            secondFeasible,
            Apply("scalar.multiply", second.Raw, orientation),
            Scalar(-2d));
        var segmentVector = VectorFromScalars(firstScore, secondScore);
        builder.Output("bootstrap-median", Apply("vector.median", segmentVector));
        builder.Output("bootstrap-lower-segment", Apply("vector.quantile", segmentVector, Scalar(0.25d)));
        var sampleMedianNodes = Enumerable.Range(0, 33)
            .Select(sample => Apply(
                "vector.median",
                Apply(
                    "vector.gather",
                    segmentVector,
                    builder.Constant(MathBlockValue.Vector(
                        [sample % 2, (sample / 2) % 2])))))
            .ToArray();
        var sampleMedians = VectorFromScalars(sampleMedianNodes);
        builder.Output("bootstrap-ci-lower", Apply("vector.quantile", sampleMedians, Scalar(0.05d)));
        builder.Output("bootstrap-ci-upper", Apply("vector.quantile", sampleMedians, Scalar(0.95d)));
        var lowerConfidence = Apply("vector.quantile", sampleMedians, Scalar(0.10d));
        builder.Output("bootstrap-lower-confidence", lowerConfidence);
        var finiteSegmentCount = Apply(
            "scalar.add",
            BooleanAsScalar(firstFeasible),
            BooleanAsScalar(secondFeasible));
        var enoughSegments = AtLeast(finiteSegmentCount, 2);
        var feasible = Apply("boolean.and", aggregateFeasible, enoughSegments);
        var resilient = ScalarSelect(feasible, lowerConfidence, Scalar(-2d));
        var aggregateScore = ScalarSelect(feasible, orientedAggregate, Scalar(-2d));
        var lowerSegment = ScalarSelect(
            feasible,
            Apply("vector.quantile", segmentVector, Scalar(0.25d)),
            Scalar(-2d));
        var feasibleScalar = BooleanAsScalar(feasible);
        var gate = Apply("scalar.divide", feasibleScalar, feasibleScalar);
        var objectiveProgram = builder
            .Output("resilient", resilient)
            .Output("aggregate", aggregateScore)
            .Output("lower-segment", lowerSegment)
            .Output("best-resilient", resilient)
            .Output("feasibility-gate", gate)
            .Build();
        var residentInputs = new Dictionary<string, MathBlockValue>
        {
            ["baseline"] = MathBlockValue.Vector(Enumerable.Repeat(100d, rowCount)),
            ["upper"] = MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index =>
                index % 6 == 0 ? 100d : 100d + (index % 6) * 0.1d)),
            ["lower"] = MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index =>
                index % 6 == 3 ? 99.7d : 100d)),
            ["eligibility"] = MathBlockValue.BooleanVector(
                Enumerable.Range(0, rowCount).Select(index => index < rowCount - 1)),
            ["first-segment"] = MathBlockValue.BooleanVector(
                Enumerable.Range(0, rowCount).Select(index => index < 3)),
            ["second-segment"] = MathBlockValue.BooleanVector(
                Enumerable.Range(0, rowCount).Select(index => index >= 3 && index < 6))
        };
        var objectives = new[]
        {
            new MathBlockProgramPopulationObjective(
                "resilient",
                "resilient",
                MathBlockProgramPopulationObjectiveDirection.Maximize),
            new MathBlockProgramPopulationObjective(
                "aggregate",
                "aggregate",
                MathBlockProgramPopulationObjectiveDirection.Maximize),
            new MathBlockProgramPopulationObjective(
                "lower-segment",
                "lower-segment",
                MathBlockProgramPopulationObjectiveDirection.Maximize),
            new MathBlockProgramPopulationObjective(
                "best-resilient",
                "best-resilient",
                MathBlockProgramPopulationObjectiveDirection.Maximize),
            new MathBlockProgramPopulationObjective(
                "feasibility-gate",
                "feasibility-gate",
                MathBlockProgramPopulationObjectiveDirection.Maximize),
            MathBlockProgramPopulationObjective.Intrinsic(
                "expanded-operations",
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount,
                MathBlockProgramPopulationObjectiveDirection.Minimize),
            MathBlockProgramPopulationObjective.Intrinsic(
                "maximum-lookback",
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.MaximumLookback,
                MathBlockProgramPopulationObjectiveDirection.Minimize),
            MathBlockProgramPopulationObjective.Intrinsic(
                "execution-cost",
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.DeterministicExecutionCost,
                MathBlockProgramPopulationObjectiveDirection.Minimize),
            MathBlockProgramPopulationObjective.Intrinsic(
                "age",
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.Age,
                MathBlockProgramPopulationObjectiveDirection.Minimize)
        };
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            residentInputs,
            objectives,
            "candidate-validity");
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(14, 14, 0, 0, 0, 1234, 0),
            new MathBlockProgramPopulationSelectionPolicy(16, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "best-resilient",
                [new MathBlockProgramPopulationQualityDiversityDimension(
                    "expanded-operations",
                    0d,
                    2d,
                    2)]),
            new MathBlockProgramPopulationSearchEnvelope(256L * 1024 * 1024, 32 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(Enumerable.Range(0, rowCount)));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateVectorOverloadSearch(
        int proposalsPerCycle,
        ulong maximumTrials,
        ulong enumerationTrials,
        int mutationTrials = 0,
        int crossoverTrials = 0,
        int immigrantTrials = 0)
    {
        var units = new[]
        {
            MathBlockUnit.Basis0,
            MathBlockUnit.Basis1,
            MathBlockUnit.Basis2,
            MathBlockUnit.Basis3
        };
        var terminalCounts = new[] { 2, 4, 4, 4 };
        var outputType = MathBlockType.BooleanVector(3);
        var operations = units
            .Select(unit =>
            {
                var vector = MathBlockType.Vector(unit, 3);
                return new MathBlockProgramPopulationOperation(
                    "vector.greater-than",
                    1,
                    [vector, vector],
                    outputType);
            })
            .ToArray();
        var terminals = new List<MathBlockProgramPopulationTerminal>();
        for (var unitIndex = 0; unitIndex < units.Length; unitIndex++)
        {
            for (var terminalIndex = 0; terminalIndex < terminalCounts[unitIndex]; terminalIndex++)
            {
                var value = checked(unitIndex * 10 + terminalIndex);
                terminals.Add(new MathBlockProgramPopulationTerminal(
                    $"unit-{unitIndex}-vector-{terminalIndex}",
                    MathBlockType.Vector(units[unitIndex], 3),
                    MathBlockValue.Vector([value + 2d, value, value + 1d], units[unitIndex])));
            }
        }
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, outputType),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, 3)],
            proposalsPerCycle,
            fingerprintCapacity: 1024);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", outputType);
        var trueCount = objectiveBuilder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var objectiveProgram = objectiveBuilder.Output("true-count", trueCount).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "true-count",
                "true-count",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(
                maximumTrials,
                enumerationTrials,
                mutationTrials,
                crossoverTrials,
                immigrantTrials,
                randomSeed: 7919,
                randomSequence: 17),
            new MathBlockProgramPopulationSelectionPolicy(128, 64),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "true-count",
                [new MathBlockProgramPopulationQualityDiversityDimension("true-count", 0, 4, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(256L * 1024 * 1024, 64 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1, 1, 1]));
    }

    private static IReadOnlyDictionary<string, (double Objective, string SemanticFingerprint)>
        CreateVectorOverloadCpuReference(MathBlockProgramPopulationSearchDefinition definition)
    {
        var terminalNodes = definition.Population.Terminals
            .Select((terminal, index) =>
                MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type))
            .ToArray();
        var result = new Dictionary<string, (double Objective, string SemanticFingerprint)>(StringComparer.Ordinal);
        foreach (var group in definition.Population.Terminals
                     .Select((terminal, index) => (Terminal: terminal, Index: index))
                     .GroupBy(item => item.Terminal.Type))
        {
            foreach (var left in group)
            {
                foreach (var right in group)
                {
                    var program = new MathBlockProgramStructure(
                        0,
                        null,
                        MathBlockProgramPopulationTrialSource.Enumeration,
                        [
                            .. terminalNodes,
                            MathBlockProgramCandidateNode.Operation(
                                "vector.greater-than",
                                1,
                                definition.Population.Grammar.OutputType,
                                left.Index,
                                right.Index)
                        ]);
                    Assert.True(result.TryAdd(
                        program.StructuralFingerprint,
                        (
                            definition.EvaluateObjectives(program).Single(),
                            definition.CreateSemanticFingerprint(program))));
                }
            }
        }
        return result;
    }

    private static MathBlockProgramPopulationDefinition CreateScalarPopulation(int proposalsPerCycle)
    {
        var scalar = MathBlockType.Scalar();
        return new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("scalar.add", 1, [scalar, scalar], scalar)],
                scalar),
            [
                new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d)),
                new MathBlockProgramPopulationTerminal("two", scalar, MathBlockValue.Scalar(2d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle,
            fingerprintCapacity: 16);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateNegationBandSearch(
        IEnumerable<MathBlockProgramPopulationResourceBand> bands,
        ulong maximumTrials)
    {
        var scalar = MathBlockType.Scalar();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("scalar.negate", 1, [scalar], scalar)],
                scalar),
            [new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d))],
            [],
            bands,
            proposalsPerCycle: 4,
            fingerprintCapacity: 400_000);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var objectiveProgram = objectiveBuilder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return CreateDefinition(
            population,
            binding,
            maximumTrials,
            maximumTrials,
            new MathBlockProgramPopulationValidityPolicy([1]));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateDefinition(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramPopulationObjectiveBinding binding,
        ulong maximumTrials,
        ulong enumerationTrials,
        MathBlockProgramPopulationValidityPolicy validity,
        string? qualityObjective = null,
        int mutationTrials = 0,
        int crossoverTrials = 0,
        int immigrantTrials = 0)
    {
        qualityObjective ??= binding.Objectives[0].Name;
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(
                maximumTrials,
                enumerationTrials,
                mutationTrials,
                crossoverTrials,
                immigrantTrials,
                randomSeed: 123,
                randomSequence: 9),
            new MathBlockProgramPopulationSelectionPolicy(16, 12),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                qualityObjective,
                [new MathBlockProgramPopulationQualityDiversityDimension(qualityObjective, -1000, 1000, 8)]),
            new MathBlockProgramPopulationSearchEnvelope(256L * 1024 * 1024, 64 * 1024 * 1024),
            validity);
    }

    private static string TrialIdentity(MathBlockProgramPopulationTrialResult trial) =>
        $"{trial.Program.TrialCursor}|{trial.Program.ProposalCursor}|{trial.Program.Source}|{trial.Status}|" +
        $"{trial.StructuralFingerprint}|{trial.SemanticFingerprint}|{string.Join(',', trial.Objectives)}";

    private static int ValueElementCount(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
        MathBlockValueKind.Complex => 1,
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        MathBlockValueKind.Matrix => checked(value.AsMatrix().Rows * value.AsMatrix().Columns),
        MathBlockValueKind.ComplexVector => value.AsComplexVector().Count,
        MathBlockValueKind.ComplexMatrix => checked(value.AsComplexMatrix().Rows * value.AsComplexMatrix().Columns),
        MathBlockValueKind.PointSet => value.AsPointSet().Count,
        MathBlockValueKind.Graph => value.AsGraph().Count,
        MathBlockValueKind.RunSet => value.AsRunSet().Count,
        _ => throw new NotSupportedException()
    };

    private static int ValidityRowCount(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean or MathBlockValueKind.Complex => 1,
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        MathBlockValueKind.Matrix => value.AsMatrix().Rows,
        MathBlockValueKind.ComplexVector => value.AsComplexVector().Count,
        MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Rows,
        MathBlockValueKind.PointSet => value.AsPointSet().Count,
        MathBlockValueKind.Graph => value.AsGraph().VertexCount,
        MathBlockValueKind.RunSet => value.AsRunSet().Count,
        _ => throw new NotSupportedException()
    };

    private static void RequireCuda() =>
        Assert.True(MathBlocksGPUWorker.IsAvailable, "A CUDA device is required.");
}
