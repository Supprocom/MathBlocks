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
