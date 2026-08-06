using Supprocom.MathBlocks.Cuda;
using System.Diagnostics;
using System.Reflection;
using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockCudaProgramPopulationSearchTests
{
    [Fact]
    public void Explicit_program_catalog_binds_order_cursor_range_and_typed_structures()
    {
        var definition = CreateExplicitMixedUnitCatalogSearch();
        var catalog = Assert.IsType<MathBlockProgramPopulationEnumerationCatalog>(
            definition.EnumerationCatalog);
        var first = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            catalog.Programs[0].Nodes);
        var second = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            catalog.Programs[1].Nodes);
        var reordered = new MathBlockProgramPopulationEnumerationCatalog(
            catalog.CursorStart,
            [second, first, .. catalog.Programs.Skip(2).Select(program =>
                new MathBlockProgramStructure(
                    0,
                    null,
                    MathBlockProgramPopulationTrialSource.Enumeration,
                    program.Nodes))]);
        var shifted = new MathBlockProgramPopulationEnumerationCatalog(
            catalog.CursorStart + 1,
            catalog.Programs.Select(program => new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                program.Nodes)));

        Assert.Equal(4096ul, catalog.CursorStart);
        Assert.Equal(4104ul, catalog.CursorEndExclusive);
        Assert.Equal(
            Enumerable.Range(0, catalog.Programs.Count).Select(index => 4096ul + (ulong)index),
            catalog.Programs.Select(program => program.ProposalCursor!.Value));
        Assert.NotEqual(catalog.Identity, reordered.Identity);
        Assert.NotEqual(catalog.Identity, shifted.Identity);
        Assert.Throws<ArgumentException>(() =>
            new MathBlockProgramPopulationEnumerationCatalog(0, [first, first]));

        var invalidNodes = catalog.Programs[0].Nodes.Take(catalog.Programs[0].Nodes.Count - 1).ToList();
        invalidNodes.Add(MathBlockProgramCandidateNode.Operation(
            "vector.greater-than",
            1,
            MathBlockType.BooleanVector(3),
            0,
            2));
        var invalidCatalog = new MathBlockProgramPopulationEnumerationCatalog(
            9000,
            [new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                invalidNodes)]);
        Assert.Throws<InvalidOperationException>(() =>
            new MathBlockProgramPopulationSearchDefinition(
                definition.Population,
                definition.ObjectiveBinding,
                new MathBlockProgramPopulationEvolutionPolicy(9001, 1, 0, 0, 0, 41),
                definition.Selection,
                definition.QualityDiversity,
                definition.Envelope,
                definition.Validity,
                enumerationCatalog: invalidCatalog));
    }

    [Fact]
    public void Resident_search_enumerates_explicit_typed_catalog_once_with_exact_resume()
    {
        RequireCuda();
        var definition = CreateExplicitMixedUnitCatalogSearch();
        var options = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            2);
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, options);
        var trials = new List<MathBlockProgramPopulationTrialResult>();

        var first = uninterrupted.ExecuteCycle();
        trials.AddRange(first.Trials);
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());
        var expected = uninterrupted.ExecuteCycle();
        trials.AddRange(expected.Trials);
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint),
            options);
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        var current = expected;
        while (!current.IsSearchComplete)
        {
            current = uninterrupted.ExecuteCycle();
            trials.AddRange(current.Trials);
        }

        var catalog = Assert.IsType<MathBlockProgramPopulationEnumerationCatalog>(
            definition.EnumerationCatalog);
        Assert.Equal(catalog.Programs.Count, trials.Count);
        Assert.Equal(
            catalog.Programs.Select(program => program.StructuralFingerprint),
            trials.Select(trial => trial.StructuralFingerprint));
        Assert.Equal(
            Enumerable.Range(0, catalog.Programs.Count).Select(index => catalog.CursorStart + (ulong)index),
            trials.Select(trial => trial.Program.ProposalCursor!.Value));
        Assert.All(trials, trial =>
        {
            Assert.Equal(MathBlockProgramPopulationTrialSource.Enumeration, trial.Program.Source);
            Assert.NotEqual(MathBlockProgramPopulationTrialStatus.InvalidType, trial.Status);
            Assert.NotEqual(MathBlockProgramPopulationTrialStatus.StructuralDuplicate, trial.Status);
            Assert.Equal(
                definition.EvaluateObjectives(trial.Program).Select(BitConverter.DoubleToInt64Bits),
                trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
        });
        Assert.True(current.IsEnumerationComplete);
        Assert.True(current.IsSearchComplete);
        Assert.Equal((ulong)catalog.Programs.Count, current.AcceptedState.EnumerationCursor);
        Assert.Equal((ulong)catalog.Programs.Count, current.AcceptedState.EnumerationTrialCount);
        Assert.Equal(catalog.CursorEndExclusive, current.AcceptedState.TrialCursor);
        Assert.Equal((ulong)catalog.Programs.Count, current.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(0ul, current.AcceptedState.InvalidEnumerationProposalCount);
        Assert.Equal(0ul, current.AcceptedState.StructuralDuplicateCount);
        Assert.Equal(1, uninterrupted.GraphInstanceCount);
        Assert.Equal(1, uninterrupted.ImmutableUploadCount);
        Assert.Equal(0, uninterrupted.LaterImmutableUploadCount);
        Assert.Equal(4, uninterrupted.GraphLaunchCount);
        Assert.Equal(4, uninterrupted.SynchronizationCount);
        Assert.Equal(4, uninterrupted.DownloadCount);
        Assert.Equal(
            4L * uninterrupted.CompactDownloadBytesPerCycle,
            uninterrupted.DownloadedBytes);
        Assert.Equal(0, uninterrupted.FullCandidateOutputDownloadCount);
        Assert.Equal(0, uninterrupted.FullCandidateOutputBytes);
        Assert.Equal(0, uninterrupted.CpuNodeDispatchCount);
        Assert.Equal(2, uninterrupted.ActiveCandidateLaneCount);
        Assert.Equal(0, uninterrupted.SerialCandidateExecutionCount);
        Assert.Equal((long)catalog.Programs.Count, uninterrupted.ParallelCandidateExecutionCount);
        AssertResidentCycleContract(resumed);
    }

    [Fact]
    public void Resident_catalog_transition_preserves_compatible_archives_without_refresh()
    {
        RequireCuda();
        var firstDefinition = CreateExplicitMixedUnitCatalogSearch(
            catalogOffset: 0,
            catalogCount: 4,
            cursorStart: 0);
        var options = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            2);
        using var firstCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            firstDefinition,
            options);
        var first = firstCompiled.ExecuteCycle();
        first = firstCompiled.ExecuteCycle();
        Assert.True(first.IsSearchComplete);
        Assert.NotEmpty(first.AcceptedState.SelectionEntries);
        Assert.NotEmpty(first.AcceptedState.QualityDiversityEntries);

        var secondDefinition = CreateExplicitMixedUnitCatalogSearch(
            catalogOffset: 4,
            catalogCount: 4,
            cursorStart: 4);
        var transition = secondDefinition.CreateTransitionState(
            firstDefinition,
            first.AcceptedState);

        Assert.Equal(4ul, transition.TrialCursor);
        Assert.Equal(0ul, transition.EnumerationCursor);
        Assert.Equal(0ul, transition.EnumerationTrialCount);
        Assert.Empty(transition.RefreshPrograms);
        AssertArchiveFingerprintAuthority(transition);
        Assert.Equal(
            first.AcceptedState.SelectionEntries.Select(ArchiveIdentity),
            transition.SelectionEntries.Select(ArchiveIdentity));
        Assert.Equal(
            first.AcceptedState.QualityDiversityEntries.Select(ArchiveIdentity),
            transition.QualityDiversityEntries.Select(ArchiveIdentity));

        var incompatible = CreateExplicitMixedUnitCatalogSearch(
            catalogOffset: 4,
            catalogCount: 4,
            cursorStart: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 1]));
        Assert.Throws<InvalidOperationException>(() =>
            incompatible.CreateTransitionState(firstDefinition, first.AcceptedState));

        using var secondCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            secondDefinition.WithAcceptedState(transition),
            options);
        var result = secondCompiled.ExecuteCycle();

        Assert.Equal(2, result.Trials.Count);
        Assert.Equal([4ul, 5ul], result.Trials.Select(trial => trial.Program.ProposalCursor!.Value));
        Assert.Equal(
            2ul,
            result.AcceptedState.EvaluatedProgramCount - transition.EvaluatedProgramCount);
        Assert.All(result.Trials, trial => Assert.Equal(
            secondDefinition.EvaluateObjectives(trial.Program).Select(BitConverter.DoubleToInt64Bits),
            trial.Objectives.Select(BitConverter.DoubleToInt64Bits)));
        AssertResidentCycleContract(secondCompiled);
    }

    [Fact]
    public void Resident_catalog_transition_normalizes_archive_programs_for_terminal_prefix_growth()
    {
        RequireCuda();
        var firstDefinition = CreateExplicitMixedUnitCatalogSearch(
            catalogOffset: 0,
            catalogCount: 4,
            cursorStart: 0);
        var options = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            2);
        using var firstCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            firstDefinition,
            options);
        _ = firstCompiled.ExecuteCycle();
        var first = firstCompiled.ExecuteCycle();
        Assert.True(first.IsSearchComplete);
        Assert.NotEmpty(first.AcceptedState.SelectionEntries);

        var secondDefinition = CreateExplicitMixedUnitCatalogSearch(
            catalogOffset: 4,
            catalogCount: 4,
            cursorStart: 4,
            includeAdditionalTerminal: true,
            includeExpandedGrammar: true);
        var transition = secondDefinition.CreateTransitionState(
            firstDefinition,
            first.AcceptedState);

        AssertArchiveFingerprintAuthority(transition);
        Assert.Empty(transition.RefreshPrograms);
        Assert.Equal(first.AcceptedState.SelectionEntries.Count, transition.SelectionEntries.Count);
        Assert.Equal(
            first.AcceptedState.QualityDiversityEntries.Count,
            transition.QualityDiversityEntries.Count);
        for (var index = 0; index < transition.SelectionEntries.Count; index++)
        {
            var previous = first.AcceptedState.SelectionEntries[index];
            var current = transition.SelectionEntries[index];
            Assert.Equal(previous.Program.Nodes.Count + 1, current.Program.Nodes.Count);
            Assert.Equal("first-c", current.Program.Nodes[4].TerminalIdentifier);
            Assert.Equal(previous.Objectives.Select(BitConverter.DoubleToInt64Bits),
                current.Objectives.Select(BitConverter.DoubleToInt64Bits));
            Assert.Equal(previous.SemanticFingerprint, current.SemanticFingerprint);
        }

        var overlapProgram = transition.SelectionEntries[0].Program;
        var overlapCatalog = new MathBlockProgramPopulationEnumerationCatalog(
            4,
            [new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                overlapProgram.Nodes)]);
        var overlapDefinition = new MathBlockProgramPopulationSearchDefinition(
            secondDefinition.Population,
            secondDefinition.ObjectiveBinding,
            new MathBlockProgramPopulationEvolutionPolicy(5, 1, 0, 0, 0, 71),
            secondDefinition.Selection,
            secondDefinition.QualityDiversity,
            secondDefinition.Envelope,
            secondDefinition.Validity,
            wavePolicy: secondDefinition.WavePolicy,
            enumerationCatalog: overlapCatalog);
        Assert.Throws<InvalidOperationException>(() =>
            overlapDefinition.CreateTransitionState(firstDefinition, first.AcceptedState));

        var restored = MathBlockProgramPopulationSearchState.Import(transition.Export());
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(
            secondDefinition.WithAcceptedState(transition),
            options);
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            secondDefinition.WithAcceptedState(restored),
            options);
        var expected = uninterrupted.ExecuteCycle();
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Equal([4ul, 5ul], actual.Trials.Select(trial => trial.Program.ProposalCursor!.Value));
        AssertResidentCycleContract(uninterrupted);
        AssertResidentCycleContract(resumed);
    }

    [Fact]
    public void Resident_catalog_transition_preserves_archive_duplicate_authority_and_exact_resume()
    {
        RequireCuda();
        var firstDefinition = CreateScalarDuplicateCatalogSearch(
            useAbsolute: true,
            cursorStart: 0,
            maximumTrialCount: 1,
            immigrantTrials: 0);
        var options = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            2);
        using var firstCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            firstDefinition,
            options);
        var first = firstCompiled.ExecuteCycle();
        var preservedPareto = Assert.Single(first.AcceptedState.SelectionEntries);
        var preservedQuality = Assert.Single(first.AcceptedState.QualityDiversityEntries);

        var secondDefinition = CreateScalarDuplicateCatalogSearch(
            useAbsolute: false,
            cursorStart: 1,
            maximumTrialCount: 10,
            immigrantTrials: 1);
        var transition = secondDefinition.CreateTransitionState(
            firstDefinition,
            first.AcceptedState);
        AssertArchiveFingerprintAuthority(transition);
        Assert.Single(transition.StructuralFingerprints);
        Assert.Single(transition.SemanticFingerprints);
        Assert.Empty(transition.RefreshPrograms);

        var restored = MathBlockProgramPopulationSearchState.Import(transition.Export());
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(
            secondDefinition.WithAcceptedState(transition),
            options);
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            secondDefinition.WithAcceptedState(restored),
            options);
        var expected = uninterrupted.ExecuteCycle();
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        AssertResidentCycleContract(resumed);

        var trials = new List<MathBlockProgramPopulationTrialResult>(expected.Trials);
        var current = expected;
        var cycleCount = 1;
        while (!current.IsSearchComplete)
        {
            current = uninterrupted.ExecuteCycle();
            trials.AddRange(current.Trials);
            cycleCount++;
        }

        var semanticDuplicate = Assert.Single(
            trials,
            trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Enumeration);
        Assert.Equal(MathBlockProgramPopulationTrialStatus.SemanticDuplicate, semanticDuplicate.Status);
        Assert.Equal(preservedPareto.SemanticFingerprint, semanticDuplicate.SemanticFingerprint);
        Assert.Equal(
            preservedPareto.Objectives.Select(BitConverter.DoubleToInt64Bits),
            semanticDuplicate.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(
            transition.SemanticDuplicateCount + 1,
            current.AcceptedState.SemanticDuplicateCount);
        Assert.Contains(trials, trial =>
            trial.Program.Source == MathBlockProgramPopulationTrialSource.RandomImmigrant &&
            trial.StructuralFingerprint == preservedPareto.StructuralFingerprint &&
            trial.Status == MathBlockProgramPopulationTrialStatus.StructuralDuplicate);
        var finalPareto = Assert.Single(current.AcceptedState.SelectionEntries);
        var finalQuality = Assert.Single(current.AcceptedState.QualityDiversityEntries);
        Assert.Equal(preservedPareto.StructuralFingerprint, finalPareto.StructuralFingerprint);
        Assert.Equal(preservedQuality.StructuralFingerprint, finalQuality.StructuralFingerprint);
        Assert.Equal(preservedPareto.SemanticFingerprint, finalPareto.SemanticFingerprint);
        Assert.Equal(preservedQuality.SemanticFingerprint, finalQuality.SemanticFingerprint);
        Assert.Equal(
            preservedPareto.Objectives.Select(BitConverter.DoubleToInt64Bits),
            finalPareto.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(
            preservedQuality.Objectives.Select(BitConverter.DoubleToInt64Bits),
            finalQuality.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Contains(finalPareto.StructuralFingerprint, current.AcceptedState.StructuralFingerprints);
        Assert.Contains(finalPareto.SemanticFingerprint, current.AcceptedState.SemanticFingerprints);
        Assert.Equal(1, uninterrupted.GraphInstanceCount);
        Assert.Equal(1, uninterrupted.ImmutableUploadCount);
        Assert.Equal(0, uninterrupted.LaterImmutableUploadCount);
        Assert.Equal(cycleCount, uninterrupted.GraphLaunchCount);
        Assert.Equal(cycleCount, uninterrupted.SynchronizationCount);
        Assert.Equal(cycleCount, uninterrupted.DownloadCount);
        Assert.Equal(
            (long)cycleCount * uninterrupted.CompactDownloadBytesPerCycle,
            uninterrupted.DownloadedBytes);
        Assert.Equal(0, uninterrupted.FullCandidateOutputDownloadCount);
        Assert.Equal(0, uninterrupted.FullCandidateOutputBytes);
        Assert.Equal(0, uninterrupted.CpuNodeDispatchCount);
    }

    [Fact]
    public void Enumeration_catalog_capacity_planner_proves_exact_expanding_formula_bound()
    {
        RequireCuda();
        var underBound = CreateExpandingCatalogCapacitySearch(8);
        var catalog = Assert.IsType<MathBlockProgramPopulationEnumerationCatalog>(
            underBound.EnumerationCatalog);
        var worker = new MathBlocksCUDAWorker();

        var planned = worker.PlanPopulationEnumerationCatalogResourceBands(
            underBound.Population,
            catalog);

        var requirement = Assert.Single(planned);
        Assert.Equal(2, requirement.OperationCount);
        Assert.Equal(9, requirement.MaximumOutputElements);
        var exception = Assert.Throws<InvalidOperationException>(
            () => worker.CompilePopulationSearch(underBound));
        Assert.Contains(
            "requires at least 9 output elements for operation count 2",
            exception.Message,
            StringComparison.Ordinal);

        var exact = CreateExpandingCatalogCapacitySearch(requirement.MaximumOutputElements);
        var expectedProgram = Assert.Single(exact.EnumerationCatalog!.Programs);
        var expectedObjectives = exact.EvaluateObjectives(expectedProgram);
        var expectedSemantic = exact.CreateSemanticFingerprint(expectedProgram);
        Assert.Equal(
            BitConverter.DoubleToInt64Bits(14d),
            BitConverter.DoubleToInt64Bits(Assert.Single(expectedObjectives)));
        using var compiled = worker.CompilePopulationSearch(
            exact,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));

        var result = compiled.ExecuteCycle();

        var accepted = Assert.Single(result.Trials);
        Assert.Equal(MathBlockProgramPopulationTrialStatus.Accepted, accepted.Status);
        Assert.Equal(expectedProgram.StructuralFingerprint, accepted.StructuralFingerprint);
        Assert.Equal(expectedSemantic, accepted.SemanticFingerprint);
        Assert.Equal(
            expectedObjectives.Select(BitConverter.DoubleToInt64Bits),
            accepted.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(1ul, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(1ul, result.AcceptedState.AcceptedProgramCount);
        Assert.True(result.IsSearchComplete);
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
    public void Static_feasibility_rejects_all_large_rolling_shape_mismatches_before_CUDA_setup()
    {
        var definition = CreateLargeRollingStaticFeasibilitySearch(includeValidProgram: false);
        var worker = new MathBlocksCUDAWorker();

        var plan = worker.PlanPopulationSearchStaticFeasibility(definition);

        Assert.False(plan.HasFeasiblePrograms);
        Assert.Empty(plan.FeasiblePrograms);
        Assert.Equal(4, plan.Rejections.Count);
        Assert.All(plan.Rejections, rejection => Assert.Contains(
            "row counts must be equal",
            rejection.Reason,
            StringComparison.Ordinal));
        Assert.Equal(4, plan.Instrumentation.CandidateCount);
        Assert.Equal(0, plan.Instrumentation.FeasibleCandidateCount);
        Assert.Equal(4, plan.Instrumentation.RejectedCandidateCount);
        Assert.Equal(0, plan.Instrumentation.CudaNodeDispatchCount);
        Assert.Equal(0, plan.Instrumentation.CandidateLaneAllocationCount);
        Assert.Equal(0, plan.Instrumentation.DescriptorAllocationCount);
        Assert.Equal(0, plan.Instrumentation.ScratchAllocationCount);
        Assert.Equal(0, plan.Instrumentation.UploadCount);
        Assert.Equal(0, plan.Instrumentation.LaunchCount);
        Assert.Equal(0, plan.Instrumentation.SynchronizationCount);
        Assert.Equal(0, plan.Instrumentation.DownloadCount);
        Assert.Equal(0, plan.Instrumentation.CpuNodeDispatchCount);
        var exception = Assert.Throws<InvalidOperationException>(
            () => worker.CompilePopulationSearch(definition));
        Assert.Contains("before CUDA setup", exception.Message, StringComparison.Ordinal);

    }

    [Fact]
    public void Mixed_static_feasibility_executes_only_the_valid_large_shape_candidate()
    {
        RequireCuda();
        var definition = CreateLargeRollingStaticFeasibilitySearch(includeValidProgram: true);
        var worker = new MathBlocksCUDAWorker();
        var plan = worker.PlanPopulationSearchStaticFeasibility(definition);

        Assert.True(
            plan.FeasiblePrograms.Count == 1,
            string.Join(" | ", plan.Rejections.Select(rejection => rejection.Reason)));
        Assert.Equal(4, plan.Rejections.Count);
        using var compiled = worker.CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                4));

        var result = compiled.ExecuteCycle();

        Assert.Equal(5, result.Trials.Count);
        Assert.Equal(
            4,
            result.Trials.Count(trial =>
                trial.Status == MathBlockProgramPopulationTrialStatus.StaticallyRejected));
        var executed = Assert.Single(
            result.Trials,
            trial => trial.Status != MathBlockProgramPopulationTrialStatus.StaticallyRejected);
        Assert.NotEqual(MathBlockProgramPopulationTrialStatus.InvalidValue, executed.Status);
        Assert.Equal(1ul, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(1, compiled.ParallelCandidateExecutionCount);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(2, compiled.CudaNodeDispatchCount);
        Assert.Equal(1, compiled.CudaCandidateDispatchCount);
        Assert.Equal(4, compiled.StaticallyRejectedProgramCount);
        Assert.Equal(2, result.Instrumentation.CudaNodeDispatchCount);
        Assert.Equal(1, result.Instrumentation.CudaCandidateDispatchCount);
        Assert.Equal(4, result.Instrumentation.StaticallyRejectedProgramCount);
    }

    [Fact]
    public void Static_rejection_resume_preserves_state_and_reaches_the_valid_candidate_exactly()
    {
        RequireCuda();
        var definition = CreateLargeRollingStaticFeasibilitySearch(
            includeValidProgram: true,
            proposalWaveSize: 2);
        var options = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            2);
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            options);
        var first = uninterrupted.ExecuteCycle();
        Assert.All(first.Trials, trial => Assert.Equal(
            MathBlockProgramPopulationTrialStatus.StaticallyRejected,
            trial.Status));
        Assert.Empty(first.AcceptedState.StructuralFingerprints);
        Assert.Empty(first.AcceptedState.SemanticFingerprints);
        Assert.Equal(0ul, first.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(0, uninterrupted.CudaNodeDispatchCount);
        Assert.Equal(0, uninterrupted.CudaCandidateDispatchCount);
        Assert.Equal(2, uninterrupted.StaticallyRejectedProgramCount);
        var checkpoint = MathBlockProgramPopulationSearchState.Import(
            first.AcceptedState.Export());
        var expected = uninterrupted.ExecuteCycle();
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint),
            options);
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.All(actual.Trials, trial => Assert.Equal(
            MathBlockProgramPopulationTrialStatus.StaticallyRejected,
            trial.Status));
        var final = uninterrupted.ExecuteCycle();
        Assert.Single(final.Trials);
        Assert.NotEqual(
            MathBlockProgramPopulationTrialStatus.StaticallyRejected,
            final.Trials[0].Status);
        Assert.Equal(1ul, final.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(1, uninterrupted.ParallelCandidateExecutionCount);
        Assert.Equal(0, resumed.ParallelCandidateExecutionCount);
        Assert.Equal(2, uninterrupted.CudaNodeDispatchCount);
        Assert.Equal(1, uninterrupted.CudaCandidateDispatchCount);
        Assert.Equal(4, uninterrupted.StaticallyRejectedProgramCount);
        Assert.Equal(0, resumed.CudaNodeDispatchCount);
        Assert.Equal(0, resumed.CudaCandidateDispatchCount);
        Assert.Equal(2, resumed.StaticallyRejectedProgramCount);
        AssertResidentCycleContract(resumed);
    }

    [Fact]
    [Trait("Category", "Performance")]
    public void Mixed_cycle_skips_incompatible_full_history_work_and_executes_valid_full_history_work()
    {
        RequireCuda();
        var definition = CreateCombinedFullHistoryRollingSearch();
        var worker = new MathBlocksCUDAWorker();
        var plan = worker.PlanPopulationSearchStaticFeasibility(definition);
        Assert.True(
            plan.FeasiblePrograms.Count == 1,
            string.Join(" | ", plan.Rejections.Select(rejection => rejection.Reason)));
        Assert.Single(plan.Rejections);
        Assert.Contains(
            "row counts must be equal",
            plan.Rejections[0].Reason,
            StringComparison.Ordinal);

        WarmFullHistoryRolling(definition.Population.Terminals[0].Value);
        using var compiled = worker.CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));
        var started = Stopwatch.GetTimestamp();
        var cycle = compiled.ExecuteCycle();
        var elapsed = Stopwatch.GetElapsedTime(started);

        Assert.Equal(2, cycle.Trials.Count);
        Assert.Equal(
            MathBlockProgramPopulationTrialStatus.StaticallyRejected,
            cycle.Trials[0].Status);
        Assert.NotEqual(MathBlockProgramPopulationTrialStatus.InvalidValue, cycle.Trials[1].Status);
        var expected = MathBlockVectorMath.RollingMedian(
            definition.Population.Terminals[0].Value.AsVector(),
            305_581)[0];
        Assert.Equal(
            BitConverter.DoubleToInt64Bits(expected),
            BitConverter.DoubleToInt64Bits(Assert.Single(cycle.Trials[1].Objectives)));
        Assert.True(elapsed.TotalMilliseconds < 1_000d, $"The mixed resident cycle took {elapsed.TotalMilliseconds:F3} ms.");
        Assert.Equal(2, compiled.CudaNodeDispatchCount);
        Assert.Equal(1, compiled.CudaCandidateDispatchCount);
        Assert.Equal(1, compiled.StaticallyRejectedProgramCount);
        Assert.Equal(1, compiled.MaximumConcurrentCandidates);
        Assert.Equal(1, compiled.ParallelCandidateExecutionCount);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        var constrained = new MathBlockProgramPopulationSearchDefinition(
            definition.Population,
            definition.ObjectiveBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            new MathBlockProgramPopulationSearchEnvelope(
                compiled.ResidentBytes - 1,
                definition.Envelope.MaximumCompactDownloadBytes),
            definition.Validity,
            definition.CompactResults,
            definition.InitialPrograms,
            wavePolicy: definition.WavePolicy,
            enumerationCatalog: definition.EnumerationCatalog);
        var capacityException = Assert.Throws<ArgumentOutOfRangeException>(
            () => worker.CompilePopulationSearch(
                constrained,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.ParallelResident,
                    2)));
        Assert.Contains("measured resident arena", capacityException.Message, StringComparison.Ordinal);
        Console.WriteLine(
            $"Mixed 305581-row resident cycle: {elapsed.TotalMilliseconds:F3} ms; " +
            $"static-rejections={compiled.StaticallyRejectedProgramCount}; " +
            $"CUDA-node-dispatches={compiled.CudaNodeDispatchCount}.");
    }

    [Fact]
    public void Objective_compilation_eliminates_dead_folded_and_common_work_before_CUDA_dispatch()
    {
        RequireCuda();
        var definition = CreateObjectiveOptimizationSearch();
        var worker = new MathBlocksCUDAWorker();
        var plan = worker.PlanPopulationSearchStaticFeasibility(definition);
        Assert.True(plan.HasFeasiblePrograms);
        Assert.True(plan.Instrumentation.DeadNodeCount >= 3);
        Assert.True(plan.Instrumentation.ConstantFoldCount >= 1);
        Assert.True(plan.Instrumentation.CommonSubexpressionCount >= 1);
        using var compiled = worker.CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                1));

        var cycle = compiled.ExecuteCycle();

        var trial = Assert.Single(cycle.Trials);
        Assert.Equal(MathBlockProgramPopulationTrialStatus.Accepted, trial.Status);
        Assert.Equal(
            new[] { 4_096d, 4_096d, 5d }.Select(BitConverter.DoubleToInt64Bits),
            trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.Equal(2, compiled.CudaNodeDispatchCount);
        Assert.Equal(1, compiled.CudaCandidateDispatchCount);
        Assert.Equal(0, compiled.StaticallyRejectedProgramCount);
        AssertResidentCycleContract(compiled);
    }

    [Fact]
    public void Enumeration_catalog_removes_dead_and_common_candidate_nodes_before_CUDA_dispatch()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var terminalNodes = new[]
        {
            MathBlockProgramCandidateNode.Terminal(0, "left", scalar),
            MathBlockProgramCandidateNode.Terminal(1, "right", scalar)
        };
        var supplied = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                .. terminalNodes,
                MathBlockProgramCandidateNode.Operation("scalar.add", 1, scalar, 0, 1),
                MathBlockProgramCandidateNode.Operation("scalar.multiply", 1, scalar, 0, 1),
                MathBlockProgramCandidateNode.Operation("scalar.multiply", 1, scalar, 0, 1),
                MathBlockProgramCandidateNode.Operation("scalar.add", 1, scalar, 3, 4)
            ]);
        var expected = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                .. terminalNodes,
                MathBlockProgramCandidateNode.Operation("scalar.multiply", 1, scalar, 0, 1),
                MathBlockProgramCandidateNode.Operation("scalar.add", 1, scalar, 2, 2)
            ]);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(0, [supplied]);
        var optimized = Assert.Single(catalog.Programs);
        Assert.Equal(4, optimized.Nodes.Count);
        Assert.Equal(expected.StructuralFingerprint, optimized.StructuralFingerprint);
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "scalar.add", 1, [scalar, scalar], scalar),
                    new MathBlockProgramPopulationOperation(
                        "scalar.multiply", 1, [scalar, scalar], scalar)
                ],
                scalar),
            [
                new MathBlockProgramPopulationTerminal("left", scalar, MathBlockValue.Scalar(2d)),
                new MathBlockProgramPopulationTerminal("right", scalar, MathBlockValue.Scalar(3d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(2, 1)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            new MathBlockProgramPopulationObjectiveBinding(
                objectiveBuilder.Output("value", candidate).Build(),
                "candidate",
                new Dictionary<string, MathBlockValue>(),
                [new MathBlockProgramPopulationObjective(
                    "value", "value", MathBlockProgramPopulationObjectiveDirection.Maximize)]),
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 2309),
            new MathBlockProgramPopulationSelectionPolicy(1, 1),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension("value", 0d, 10d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(
                64L * 1024 * 1024,
                8 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([int.MaxValue]),
            enumerationCatalog: catalog);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                1));

        var cycle = compiled.ExecuteCycle();

        Assert.Equal(12d, Assert.Single(Assert.Single(cycle.Trials).Objectives));
        Assert.Equal(2, compiled.CudaNodeDispatchCount);
        Assert.Equal(1, compiled.CudaCandidateDispatchCount);
    }

    [Fact]
    public void Data_dependent_invalidity_stops_every_dependent_CUDA_node_immediately()
    {
        RequireCuda();
        var definition = CreateRuntimeInvalidShortCircuitSearch();
        var plan = new MathBlocksCUDAWorker().PlanPopulationSearchStaticFeasibility(definition);
        Assert.True(plan.HasFeasiblePrograms);
        Assert.Empty(plan.Rejections);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                1));

        var cycle = compiled.ExecuteCycle();

        var trial = Assert.Single(cycle.Trials);
        Assert.Equal(MathBlockProgramPopulationTrialStatus.InvalidValue, trial.Status);
        Assert.Equal(1, compiled.CudaNodeDispatchCount);
        Assert.Equal(1, compiled.CudaCandidateDispatchCount);
        Assert.Equal(0ul, cycle.AcceptedState.EvaluatedProgramCount);
        Assert.Empty(cycle.AcceptedState.SelectionEntries);
        Assert.Empty(cycle.AcceptedState.QualityDiversityEntries);
        AssertResidentCycleContract(compiled);
    }

    [Fact]
    public void Enumeration_catalog_capacity_planner_folds_exact_shape_authority()
    {
        var scalar = MathBlockType.Scalar();
        var vector = MathBlockType.Vector();
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "value",
                scalar,
                MathBlockValue.Scalar(5d)),
            new MathBlockProgramPopulationTerminal(
                "first-count",
                scalar,
                MathBlockValue.Scalar(1d)),
            new MathBlockProgramPopulationTerminal(
                "second-count",
                scalar,
                MathBlockValue.Scalar(2d))
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "scalar.add",
                        1,
                        [scalar, scalar],
                        scalar),
                    new MathBlockProgramPopulationOperation(
                        "vector.repeat",
                        1,
                        [scalar, scalar],
                        vector)
                ],
                vector),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(2, 16)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 8);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(
            0,
            [new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [
                    MathBlockProgramCandidateNode.Terminal(0, "value", scalar),
                    MathBlockProgramCandidateNode.Terminal(1, "first-count", scalar),
                    MathBlockProgramCandidateNode.Terminal(2, "second-count", scalar),
                    MathBlockProgramCandidateNode.Operation("scalar.add", 1, scalar, 1, 2),
                    MathBlockProgramCandidateNode.Operation("vector.repeat", 1, vector, 0, 3)
                ])]);

        var band = Assert.Single(
            new MathBlocksCUDAWorker().PlanPopulationEnumerationCatalogResourceBands(
                population,
                catalog));

        Assert.Equal(2, band.OperationCount);
        Assert.Equal(3, band.MaximumOutputElements);
    }

    [Fact]
    public void Resident_search_reserves_fingerprints_for_initial_programs_and_remaining_trials()
    {
        RequireCuda();
        var exception = Assert.Throws<ArgumentOutOfRangeException>(
            () => CreateFingerprintCapacitySearch(2, 1, includeInitialPrograms: true));
        Assert.Equal("population", exception.ParamName);

        var definition = CreateFingerprintCapacitySearch(3, 1, includeInitialPrograms: true);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(3, definition.Population.FingerprintCapacity);
        Assert.Equal(2, result.AcceptedState.StructuralFingerprints.Count);
        Assert.Equal(2, result.AcceptedState.SemanticFingerprints.Count);
        Assert.Equal(1ul, result.AcceptedState.TrialCursor);
        AssertResidentCycleContract(compiled);
    }

    [Fact]
    public void Resident_search_reserves_fingerprints_for_transition_refresh_and_remaining_trials()
    {
        RequireCuda();
        var initialDefinition = CreateFingerprintCapacitySearch(
            3,
            1,
            includeInitialPrograms: true);
        using var initialCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(initialDefinition);
        var initial = initialCompiled.ExecuteCycle();

        var insufficient = CreateFingerprintCapacitySearch(
            4,
            2,
            includeInitialPrograms: false);
        var exception = Assert.Throws<ArgumentOutOfRangeException>(
            () => insufficient.CreateTransitionState(initialDefinition, initial.AcceptedState));
        Assert.Equal("population", exception.ParamName);

        var expanded = CreateFingerprintCapacitySearch(
            5,
            2,
            includeInitialPrograms: false);
        var transition = expanded.CreateTransitionState(initialDefinition, initial.AcceptedState);
        Assert.Equal(2, transition.StructuralFingerprints.Count);
        Assert.Equal(2, transition.SemanticFingerprints.Count);
        Assert.Equal(2, transition.RefreshPrograms.Count);
        Assert.Equal(0, transition.RefreshCursor);

        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            expanded.WithAcceptedState(transition));
        var result = resumed.ExecuteCycle();

        Assert.Equal(5, expanded.Population.FingerprintCapacity);
        Assert.Equal(2ul, result.AcceptedState.TrialCursor);
        AssertResidentCycleContract(resumed);
    }

    [Fact]
    public void Resident_search_execution_options_require_a_valid_mode_and_lane_count()
    {
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlockProgramPopulationExecutionOptions(
                (MathBlockProgramPopulationExecutionMode)int.MaxValue,
                1));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                0));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlockProgramPopulationWavePolicy(0, 1));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlockProgramPopulationWavePolicy(1, 0));
        Assert.Throws<OverflowException>(
            () => new MathBlockProgramPopulationWavePolicy(int.MaxValue, 2));

        var options = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            4);

        Assert.Equal(MathBlockProgramPopulationExecutionMode.ParallelResident, options.Mode);
        Assert.Equal(4, options.CandidateLaneCount);

        var definition = CreateScalarSearch(proposalsPerCycle: 4);
        var worker = new MathBlocksCUDAWorker();
        var singleLane = worker.MeasurePopulationSearchCapacity(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        var defaultCapacity = worker.MeasurePopulationSearchCapacity(definition);
        var fourLanes = worker.MeasurePopulationSearchCapacity(definition, options);

        Assert.Equal(singleLane, defaultCapacity);
        Assert.Equal(1, singleLane.CandidateLaneCount);
        Assert.Equal(4, fourLanes.CandidateLaneCount);
        Assert.Equal(1, singleLane.ProposalWaveSlotCount);
        Assert.True(singleLane.ProposalWaveSlotBytes > 0);
        Assert.Equal(singleLane.SharedResidentBytes, fourLanes.SharedResidentBytes);
        Assert.Equal(singleLane.LaneStrideBytes, fourLanes.LaneStrideBytes);
        Assert.Equal(
            checked((long)fourLanes.LaneStrideBytes * fourLanes.CandidateLaneCount),
            fourLanes.WorkingResidentBytes);
        Assert.Equal(
            fourLanes.SharedResidentBytes + fourLanes.WorkingResidentBytes,
            fourLanes.PeakResidentBytes);
        Assert.True(fourLanes.PeakResidentBytes > singleLane.PeakResidentBytes);
        var constrained = new MathBlockProgramPopulationSearchDefinition(
            definition.Population,
            definition.ObjectiveBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            new MathBlockProgramPopulationSearchEnvelope(
                singleLane.PeakResidentBytes - 1,
                definition.Envelope.MaximumCompactDownloadBytes),
            definition.Validity,
            definition.CompactResults,
            definition.InitialPrograms,
            wavePolicy: definition.WavePolicy);
        var constrainedMeasurement = worker.MeasurePopulationSearchCapacity(
            constrained,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        Assert.Equal(singleLane, constrainedMeasurement);
        var widerCycle = new MathBlockProgramPopulationSearchDefinition(
            definition.Population,
            definition.ObjectiveBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            definition.Envelope,
            definition.Validity,
            definition.CompactResults,
            definition.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 8));
        var widerCapacity = worker.MeasurePopulationSearchCapacity(
            widerCycle,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        Assert.Equal(singleLane.LaneStrideBytes, widerCapacity.LaneStrideBytes);
        Assert.Equal(1, widerCapacity.ProposalWaveSlotCount);
        Assert.Equal(singleLane.ProposalWaveSlotBytes, widerCapacity.ProposalWaveSlotBytes);
        Assert.True(widerCapacity.CompactDownloadBytes > singleLane.CompactDownloadBytes);
        Assert.True(widerCapacity.SharedResidentBytes > singleLane.SharedResidentBytes);
        var widerWave = new MathBlockProgramPopulationSearchDefinition(
            definition.Population,
            definition.ObjectiveBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            definition.Envelope,
            definition.Validity,
            definition.CompactResults,
            definition.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 2));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => worker.CompilePopulationSearch(
                constrained,
                MathBlockProgramPopulationExecutionOptions.SerialResident));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => worker.MeasurePopulationSearchCapacity(
                definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.ParallelResident,
                    int.MaxValue)));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => worker.CompilePopulationSearch(
                definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.SerialResident,
                    4)));
        Assert.Throws<ArgumentOutOfRangeException>(
            () => worker.MeasurePopulationSearchCapacity(
                definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.SerialResident,
                    4)));
        var widerParallelCapacity = worker.MeasurePopulationSearchCapacity(
            widerWave,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));
        Assert.Equal(2, widerParallelCapacity.CandidateLaneCount);
        Assert.Equal(2, widerParallelCapacity.ProposalWaveSlotCount);
    }

    [Fact]
    public void Resident_search_enumerates_a_known_grammar_without_output_materialization()
    {
        RequireCuda();
        var definition = CreateScalarSearch(proposalsPerCycle: 4);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
        var parallelOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            4);
        var serialOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.SerialResident,
            1);
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            parallelOptions);
        var first = uninterrupted.ExecuteCycle();
        Assert.Equal(4, uninterrupted.RequestedCandidateLaneCount);
        Assert.Equal(1, uninterrupted.ActiveCandidateLaneCount);
        Assert.Equal(4, uninterrupted.Capacity.CandidateLaneCount);
        Assert.Equal(
            checked((long)uninterrupted.Capacity.LaneStrideBytes * 4),
            uninterrupted.Capacity.WorkingResidentBytes);
        Assert.Equal(4, first.Instrumentation.RequestedCandidateLaneCount);
        Assert.Equal(1, first.Instrumentation.ActiveCandidateLaneCount);
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());

        var expected = uninterrupted.ExecuteCycle();
        var resumedDefinition = definition.WithAcceptedState(checkpoint);
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            resumedDefinition,
            serialOptions);
        var actual = resumed.ExecuteCycle();

        Assert.Equal(uninterrupted.SearchIdentity, resumed.SearchIdentity);
        Assert.Equal(MathBlockProgramPopulationExecutionMode.ParallelResident, uninterrupted.ExecutionMode);
        Assert.Equal(MathBlockProgramPopulationExecutionMode.SerialResident, resumed.ExecutionMode);
        Assert.Equal(MathBlockProgramPopulationExecutionMode.SerialResident, actual.Instrumentation.ExecutionMode);
        Assert.Equal(1, actual.Instrumentation.RequestedCandidateLaneCount);
        Assert.Equal(1, actual.Instrumentation.ActiveCandidateLaneCount);
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
        Assert.Equal(actual.AcceptedState.WaveCursor, checked((ulong)actual.Instrumentation.ProposalWaveCount));
    }

    [Fact]
    public void Resident_search_binds_single_proposal_waves_to_identity_capacity_and_resume()
    {
        RequireCuda();
        var baseline = CreateScalarSearch(proposalsPerCycle: 4);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 1));
        var parallelOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            1);
        Assert.NotEqual(baseline.Identity, definition.Identity);
        Assert.Equal(1, definition.WavePolicy.ProposalWaveSize);
        Assert.Equal(1, definition.WavePolicy.WavesPerCycle);
        Assert.Equal(1, definition.WavePolicy.MaximumTrialResultsPerCycle);

        MathBlockProgramPopulationSearchState checkpoint;
        MathBlockProgramPopulationSearchCycleResult expectedNext;
        using (var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            parallelOptions))
        {
            var first = uninterrupted.ExecuteCycle();
            Assert.Single(first.Trials);
            Assert.Equal(1ul, first.AcceptedState.TrialCursor);
            Assert.Equal(1ul, first.AcceptedState.WaveCursor);
            Assert.Equal(1, first.Instrumentation.ProposalWaveCount);
            Assert.Equal(1, uninterrupted.Capacity.CandidateLaneCount);
            Assert.Equal(uninterrupted.Capacity.LaneStrideBytes, uninterrupted.Capacity.WorkingResidentBytes);
            Assert.Equal(
                uninterrupted.Capacity.SharedResidentBytes + uninterrupted.Capacity.WorkingResidentBytes,
                uninterrupted.Capacity.PeakResidentBytes);
            Assert.Equal(uninterrupted.ResidentBytes, uninterrupted.Capacity.PeakResidentBytes);
            var changedPolicy = new MathBlockProgramPopulationSearchDefinition(
                definition.Population,
                definition.ObjectiveBinding,
                definition.Evolution,
                definition.Selection,
                definition.QualityDiversity,
                definition.Envelope,
                definition.Validity,
                definition.CompactResults,
                definition.InitialPrograms,
                wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 2));
            Assert.Throws<InvalidOperationException>(
                () => changedPolicy.CreateTransitionState(definition, first.AcceptedState));
            checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());
            Assert.Equal(first.AcceptedState.WaveCursor, checkpoint.WaveCursor);
            expectedNext = uninterrupted.ExecuteCycle();
        }

        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint),
            parallelOptions);
        var actualNext = resumed.ExecuteCycle();

        Assert.Equal(2ul, actualNext.AcceptedState.WaveCursor);
        Assert.Equal(2, actualNext.Instrumentation.ProposalWaveCount);
        Assert.Equal(expectedNext.AcceptedState.Export(), actualNext.AcceptedState.Export());
        Assert.Equal(expectedNext.Trials.Select(TrialIdentity), actualNext.Trials.Select(TrialIdentity));
    }

    [Fact]
    public void Resident_serial_search_commits_fixed_wider_proposal_waves()
    {
        RequireCuda();
        var baseline = CreateScalarSearch(proposalsPerCycle: 4);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 2));
        var worker = new MathBlocksCUDAWorker();
        var baselineCapacity = worker.MeasurePopulationSearchCapacity(
            baseline,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        var capacity = worker.MeasurePopulationSearchCapacity(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        Assert.Equal(2, capacity.ProposalWaveSlotCount);
        Assert.Equal(
            checked(baselineCapacity.ProposalWaveSlotBytes * 2),
            capacity.ProposalWaveSlotBytes);

        MathBlockProgramPopulationSearchState checkpoint;
        MathBlockProgramPopulationSearchCycleResult expectedNext;
        using (var uninterrupted = worker.CompilePopulationSearch(definition))
        {
            var first = uninterrupted.ExecuteCycle();
            Assert.Equal(4, first.Trials.Count);
            Assert.Equal([0ul, 1ul, 2ul, 3ul],
                first.Trials.Select(trial => trial.Program.ProposalCursor!.Value));
            Assert.Equal(4ul, first.AcceptedState.TrialCursor);
            Assert.Equal(2ul, first.AcceptedState.WaveCursor);
            Assert.Equal(2, first.Instrumentation.ProposalWaveCount);
            Assert.Equal(1, first.Instrumentation.ActiveCandidateLaneCount);
            Assert.All(first.Trials.Where(trial => trial.Objectives.Count != 0), trial =>
            {
                Assert.Equal(definition.EvaluateObjectives(trial.Program), trial.Objectives);
                Assert.Equal(definition.CreateSemanticFingerprint(trial.Program), trial.SemanticFingerprint);
            });
            checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());
            expectedNext = uninterrupted.ExecuteCycle();
        }

        using var resumed = worker.CompilePopulationSearch(definition.WithAcceptedState(checkpoint));
        var actualNext = resumed.ExecuteCycle();
        Assert.Equal(expectedNext.AcceptedState.Export(), actualNext.AcceptedState.Export());
        Assert.Equal(expectedNext.Trials.Select(TrialIdentity), actualNext.Trials.Select(TrialIdentity));
        Assert.Equal(2ul, actualNext.AcceptedState.WaveCursor);
        Assert.Equal(1, resumed.GraphInstanceCount);
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputBytes);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
        Assert.Equal((long)resumed.CompactDownloadBytesPerCycle, resumed.DownloadedBytes);
    }

    [Fact]
    public void Resident_serial_wave_commit_matches_size_one_ordinal_results()
    {
        RequireCuda();
        var referenceDefinition = CreateScalarSearch(proposalsPerCycle: 4);
        var waveDefinition = new MathBlockProgramPopulationSearchDefinition(
            referenceDefinition.Population,
            referenceDefinition.ObjectiveBinding,
            referenceDefinition.Evolution,
            referenceDefinition.Selection,
            referenceDefinition.QualityDiversity,
            referenceDefinition.Envelope,
            referenceDefinition.Validity,
            referenceDefinition.CompactResults,
            referenceDefinition.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(4, 1));
        var worker = new MathBlocksCUDAWorker();

        using var reference = worker.CompilePopulationSearch(referenceDefinition);
        using var wave = worker.CompilePopulationSearch(waveDefinition);
        var expected = reference.ExecuteCycle();
        var actual = wave.ExecuteCycle();

        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Equal(
            MathBlockProgramPopulationTrialStatus.SemanticDuplicate,
            actual.Trials.Single(trial => trial.Program.ProposalCursor == 2).Status);
        Assert.Equal(expected.AcceptedState.EnumerationCursor, actual.AcceptedState.EnumerationCursor);
        Assert.Equal(expected.AcceptedState.EnumerationTrialCount, actual.AcceptedState.EnumerationTrialCount);
        Assert.Equal(expected.AcceptedState.TrialCursor, actual.AcceptedState.TrialCursor);
        Assert.Equal(expected.AcceptedState.CycleCount, actual.AcceptedState.CycleCount);
        Assert.Equal(4ul, expected.AcceptedState.WaveCursor);
        Assert.Equal(1ul, actual.AcceptedState.WaveCursor);
        Assert.Equal(expected.AcceptedState.RandomState, actual.AcceptedState.RandomState);
        Assert.Equal(
            expected.AcceptedState.StructuralDuplicateCount,
            actual.AcceptedState.StructuralDuplicateCount);
        Assert.Equal(
            expected.AcceptedState.SemanticDuplicateCount,
            actual.AcceptedState.SemanticDuplicateCount);
        Assert.Equal(expected.AcceptedState.EvaluatedProgramCount, actual.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(expected.AcceptedState.AcceptedProgramCount, actual.AcceptedState.AcceptedProgramCount);
        Assert.Equal(
            expected.AcceptedState.StructuralFingerprints,
            actual.AcceptedState.StructuralFingerprints);
        Assert.Equal(expected.AcceptedState.SemanticFingerprints, actual.AcceptedState.SemanticFingerprints);
        Assert.Equal(
            expected.AcceptedState.SelectionEntries.Select(ArchiveIdentity),
            actual.AcceptedState.SelectionEntries.Select(ArchiveIdentity));
        Assert.Equal(
            expected.AcceptedState.QualityDiversityEntries.Select(ArchiveIdentity),
            actual.AcceptedState.QualityDiversityEntries.Select(ArchiveIdentity));
        Assert.Equal(1, actual.Instrumentation.ProposalWaveCount);
        Assert.Equal(1, wave.GraphLaunchCount);
        Assert.Equal(1, wave.SynchronizationCount);
        Assert.Equal(1, wave.DownloadCount);
        Assert.Equal(0, wave.FullCandidateOutputDownloadCount);
        Assert.Equal(0, wave.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_parallel_waves_match_serial_commit_and_resume_across_lane_counts()
    {
        RequireCuda();
        var baseline = CreateScalarSearch(
            proposalsPerCycle: 4,
            maximumTrials: 8,
            enumerationTrials: 4,
            immigrantTrials: 4);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(4, 1));
        var worker = new MathBlocksCUDAWorker();

        MathBlockProgramPopulationSearchCycleResult expectedFirst;
        MathBlockProgramPopulationSearchCycleResult expectedNext;
        MathBlockProgramPopulationSearchState checkpoint;
        using (var serial = worker.CompilePopulationSearch(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident))
        {
            expectedFirst = serial.ExecuteCycle();
            checkpoint = MathBlockProgramPopulationSearchState.Import(
                expectedFirst.AcceptedState.Export());
            expectedNext = serial.ExecuteCycle();
            Assert.Equal(4, expectedFirst.Instrumentation.CandidateChunkCount);
            Assert.Equal(1, expectedFirst.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(4, expectedFirst.Instrumentation.SerialCandidateExecutionCount);
            Assert.Equal(0, expectedFirst.Instrumentation.ParallelCandidateExecutionCount);
        }

        foreach (var laneCount in new[] { 1, 2, 4 })
        {
            var options = new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                laneCount);
            using var parallel = worker.CompilePopulationSearch(definition, options);
            var actualFirst = parallel.ExecuteCycle();

            Assert.Equal(expectedFirst.AcceptedState.Export(), actualFirst.AcceptedState.Export());
            Assert.Equal(
                expectedFirst.Trials.Select(TrialIdentity),
                actualFirst.Trials.Select(TrialIdentity));
            Assert.Equal(laneCount, actualFirst.Instrumentation.RequestedCandidateLaneCount);
            Assert.Equal(laneCount, actualFirst.Instrumentation.ActiveCandidateLaneCount);
            Assert.Equal(4 / laneCount, actualFirst.Instrumentation.CandidateChunkCount);
            Assert.Equal(laneCount, actualFirst.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(0, actualFirst.Instrumentation.SerialCandidateExecutionCount);
            Assert.Equal(4, actualFirst.Instrumentation.ParallelCandidateExecutionCount);
            Assert.Equal(1, parallel.GraphInstanceCount);
            Assert.Equal(1, parallel.ImmutableUploadCount);
            Assert.Equal(0, parallel.LaterImmutableUploadCount);
            Assert.Equal(1, parallel.GraphLaunchCount);
            Assert.Equal(1, parallel.SynchronizationCount);
            Assert.Equal(1, parallel.DownloadCount);
            Assert.Equal(0, parallel.FullCandidateOutputDownloadCount);
            Assert.Equal(0, parallel.FullCandidateOutputBytes);
            Assert.Equal(0, parallel.CpuNodeDispatchCount);

            using var resumed = worker.CompilePopulationSearch(
                definition.WithAcceptedState(checkpoint),
                options);
            var actualNext = resumed.ExecuteCycle();
            Assert.Equal(expectedNext.AcceptedState.Export(), actualNext.AcceptedState.Export());
            Assert.Equal(
                expectedNext.Trials.Select(TrialIdentity),
                actualNext.Trials.Select(TrialIdentity));
        }
    }

    [Fact]
    public void Resident_parallel_wave_resolves_overload_duplicates_across_chunk_boundaries()
    {
        RequireCuda();
        var dynamicVector = MathBlockType.Vector();
        var staticVector = MathBlockType.Vector(length: 3);
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "vector.absolute",
                        1,
                        [dynamicVector],
                        dynamicVector,
                        deterministicCost: 1),
                    new MathBlockProgramPopulationOperation(
                        "vector.absolute",
                        1,
                        [staticVector],
                        staticVector,
                        deterministicCost: 2)
                ],
                dynamicVector),
            [
                new MathBlockProgramPopulationTerminal(
                    "first",
                    staticVector,
                    MathBlockValue.Vector([-1d, -2d, -3d])),
                new MathBlockProgramPopulationTerminal(
                    "second",
                    staticVector,
                    MathBlockValue.Vector([-4d, -5d, -6d]))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 3)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", dynamicVector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var objectiveProgram = builder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var baseline = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2]));
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(4, 1));
        var worker = new MathBlocksCUDAWorker();

        using var serial = worker.CompilePopulationSearch(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        using var parallel = worker.CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));
        var expected = serial.ExecuteCycle();
        var actual = parallel.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Equal(2ul, actual.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(2ul, actual.AcceptedState.StructuralDuplicateCount);
        Assert.Equal(
            [2ul, 3ul],
            actual.Trials
                .Where(trial =>
                    trial.Status == MathBlockProgramPopulationTrialStatus.StructuralDuplicate)
                .Select(trial => trial.Program.ProposalCursor!.Value));
        Assert.Equal(1, actual.Instrumentation.CandidateChunkCount);
        Assert.Equal(2, actual.Instrumentation.MaximumConcurrentCandidates);
        Assert.Equal(2, actual.Instrumentation.ParallelCandidateExecutionCount);
    }

    [Fact]
    public void Resident_parallel_wave_measures_wide_long_vector_candidate_throughput()
    {
        RequireCuda();
        const int rowCount = 305_581;
        var staticVector = MathBlockType.Vector(length: rowCount);
        var dynamicVector = MathBlockType.Vector();
        var terminals = Enumerable.Range(0, 4)
            .Select(terminal => new MathBlockProgramPopulationTerminal(
                $"series-{terminal}",
                staticVector,
                MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(
                    row => -(double)(((row + terminal * 31) % 257) + 1)))))
            .ToArray();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.absolute",
                    1,
                    [staticVector],
                    staticVector)],
                dynamicVector),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", dynamicVector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var objectiveProgram = builder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var baseline = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy(
                Enumerable.Repeat(int.MaxValue, rowCount)));
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(4, 1));
        var worker = new MathBlocksCUDAWorker();
        var singleLaneOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            1);
        var fourLaneOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            4);

        using var serial = worker.CompilePopulationSearch(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
        using var singleLane = worker.CompilePopulationSearch(definition, singleLaneOptions);
        using var fourLane = worker.CompilePopulationSearch(definition, fourLaneOptions);

        var serialTimer = Stopwatch.StartNew();
        var serialResult = serial.ExecuteCycle();
        serialTimer.Stop();
        var singleLaneTimer = Stopwatch.StartNew();
        var singleLaneResult = singleLane.ExecuteCycle();
        singleLaneTimer.Stop();
        var fourLaneTimer = Stopwatch.StartNew();
        var fourLaneResult = fourLane.ExecuteCycle();
        fourLaneTimer.Stop();

        Console.WriteLine(
            $"The serial wide-vector cycle took {serialTimer.Elapsed.TotalSeconds:R} seconds.");
        Console.WriteLine(
            $"The one-lane cooperative cycle took {singleLaneTimer.Elapsed.TotalSeconds:R} seconds.");
        Console.WriteLine(
            $"The four-lane cooperative cycle took {fourLaneTimer.Elapsed.TotalSeconds:R} seconds.");

        Assert.Equal(serialResult.AcceptedState.Export(), singleLaneResult.AcceptedState.Export());
        Assert.Equal(serialResult.AcceptedState.Export(), fourLaneResult.AcceptedState.Export());
        Assert.Equal(
            serialResult.Trials.Select(TrialIdentity),
            singleLaneResult.Trials.Select(TrialIdentity));
        Assert.Equal(
            serialResult.Trials.Select(TrialIdentity),
            fourLaneResult.Trials.Select(TrialIdentity));
        Assert.Equal(4, serialResult.Instrumentation.CandidateChunkCount);
        Assert.Equal(4, singleLaneResult.Instrumentation.CandidateChunkCount);
        Assert.Equal(1, fourLaneResult.Instrumentation.CandidateChunkCount);
        Assert.Equal(1, serialResult.Instrumentation.MaximumConcurrentCandidates);
        Assert.Equal(1, singleLaneResult.Instrumentation.MaximumConcurrentCandidates);
        Assert.Equal(4, fourLaneResult.Instrumentation.MaximumConcurrentCandidates);
        Assert.Equal(4, serialResult.Instrumentation.SerialCandidateExecutionCount);
        Assert.Equal(4, singleLaneResult.Instrumentation.ParallelCandidateExecutionCount);
        Assert.Equal(4, fourLaneResult.Instrumentation.ParallelCandidateExecutionCount);
        Assert.True(fourLane.ResidentBytes > singleLane.ResidentBytes);
        Assert.All(new[] { serial, singleLane, fourLane }, compiled =>
        {
            Assert.Equal(1, compiled.GraphInstanceCount);
            Assert.Equal(1, compiled.ImmutableUploadCount);
            Assert.Equal(0, compiled.LaterImmutableUploadCount);
            Assert.Equal(1, compiled.GraphLaunchCount);
            Assert.Equal(1, compiled.SynchronizationCount);
            Assert.Equal(1, compiled.DownloadCount);
            Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
            Assert.Equal(0, compiled.FullCandidateOutputBytes);
            Assert.Equal(0, compiled.CpuNodeDispatchCount);
        });
    }

    [Fact]
    public void Resident_parallel_wave_measures_package_owned_workload_matrix()
    {
        RequireCuda();
        const int rowCount = 32_768;
        var cases = new[]
        {
            (
                Name: "reduction-heavy",
                Definition: CreateReductionHeavyPerformanceSearch(rowCount),
                ExpectedSemanticDuplicates: 0ul),
            (
                Name: "duplicate-heavy",
                Definition: CreateDuplicateHeavyPerformanceSearch(rowCount),
                ExpectedSemanticDuplicates: 3ul),
            (
                Name: "dynamic-shape",
                Definition: CreateDynamicShapePerformanceSearch(rowCount),
                ExpectedSemanticDuplicates: 0ul),
            (
                Name: "chronological",
                Definition: CreateChronologicalPerformanceSearch(rowCount),
                ExpectedSemanticDuplicates: 0ul)
        };
        var worker = new MathBlocksCUDAWorker();

        foreach (var performanceCase in cases)
        {
            using var serial = worker.CompilePopulationSearch(
                performanceCase.Definition,
                MathBlockProgramPopulationExecutionOptions.SerialResident);
            using var singleLane = worker.CompilePopulationSearch(
                performanceCase.Definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.ParallelResident,
                    1));
            using var fourLane = worker.CompilePopulationSearch(
                performanceCase.Definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.ParallelResident,
                    4));

            var (serialResult, serialElapsed) = ExecuteMeasuredCycle(serial);
            var (singleLaneResult, singleLaneElapsed) = ExecuteMeasuredCycle(singleLane);
            var (fourLaneResult, fourLaneElapsed) = ExecuteMeasuredCycle(fourLane);

            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} serial cycle took {serialElapsed.TotalSeconds:R} seconds."));
            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} one-lane cycle took {singleLaneElapsed.TotalSeconds:R} seconds."));
            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} four-lane cycle took {fourLaneElapsed.TotalSeconds:R} seconds."));
            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} four-lane runtime used {fourLane.ResidentBytes} resident bytes and {fourLane.CompactDownloadBytesPerCycle} compact bytes."));

            Assert.Equal(
                serialResult.AcceptedState.Export(),
                singleLaneResult.AcceptedState.Export());
            Assert.Equal(
                serialResult.AcceptedState.Export(),
                fourLaneResult.AcceptedState.Export());
            Assert.Equal(
                serialResult.Trials.Select(TrialIdentity),
                singleLaneResult.Trials.Select(TrialIdentity));
            Assert.Equal(
                serialResult.Trials.Select(TrialIdentity),
                fourLaneResult.Trials.Select(TrialIdentity));
            Assert.Equal(4ul, serialResult.AcceptedState.EvaluatedProgramCount);
            Assert.Equal(4ul, singleLaneResult.AcceptedState.EvaluatedProgramCount);
            Assert.Equal(4ul, fourLaneResult.AcceptedState.EvaluatedProgramCount);
            Assert.Equal(
                performanceCase.ExpectedSemanticDuplicates,
                fourLaneResult.AcceptedState.SemanticDuplicateCount);
            var evaluatedTrials = fourLaneResult.Trials
                .Where(trial => trial.Objectives.Count != 0)
                .ToArray();
            Assert.Equal(4, evaluatedTrials.Length);
            Assert.All(evaluatedTrials, trial =>
            {
                Assert.Equal(
                    performanceCase.Definition.EvaluateObjectives(trial.Program)
                        .Select(BitConverter.DoubleToInt64Bits),
                    trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
                Assert.Equal(
                    performanceCase.Definition.CreateSemanticFingerprint(trial.Program),
                    trial.SemanticFingerprint);
            });
            if (performanceCase.Name == "reduction-heavy")
                Assert.All(evaluatedTrials, trial => Assert.Equal(4, trial.Objectives.Count));
            if (performanceCase.Name == "dynamic-shape")
            {
                Assert.Equal(0, performanceCase.Definition.Population.Grammar.OutputType.Rows);
                var runtimeSized = Assert.Single(evaluatedTrials, trial =>
                {
                    var operation = trial.Program.Nodes[^1];
                    return trial.Program.Nodes[operation.OperandIndexes[0]].TerminalIdentifier == "one" &&
                        trial.Program.Nodes[operation.OperandIndexes[1]].TerminalIdentifier == "long-count";
                });
                var runtimeOperation = runtimeSized.Program.Nodes[^1];
                Assert.Equal(
                    ["one", "long-count"],
                    runtimeOperation.OperandIndexes
                        .Select(index => runtimeSized.Program.Nodes[index].TerminalIdentifier));
                Assert.Equal([rowCount / 2d, rowCount / 2d], runtimeSized.Objectives);
            }
            if (performanceCase.Name == "chronological")
            {
                Assert.All(evaluatedTrials, trial => Assert.Equal(
                    "vector.cumulative-sum@1",
                    trial.Program.Nodes[^1].OperationIdentity));
            }

            Assert.Equal(4, serialResult.Instrumentation.CandidateChunkCount);
            Assert.Equal(4, singleLaneResult.Instrumentation.CandidateChunkCount);
            Assert.Equal(1, fourLaneResult.Instrumentation.CandidateChunkCount);
            Assert.Equal(1, serialResult.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(1, singleLaneResult.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(4, fourLaneResult.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(4, serialResult.Instrumentation.SerialCandidateExecutionCount);
            Assert.Equal(4, singleLaneResult.Instrumentation.ParallelCandidateExecutionCount);
            Assert.Equal(4, fourLaneResult.Instrumentation.ParallelCandidateExecutionCount);
            Assert.True(fourLane.ResidentBytes > singleLane.ResidentBytes);
            AssertResidentCycleContract(serial);
            AssertResidentCycleContract(singleLane);
            AssertResidentCycleContract(fourLane);
        }
    }

    [Fact]
    public void Resident_parallel_wave_measures_small_and_mixed_operation_workloads()
    {
        RequireCuda();
        const int rowCount = 32_768;
        var cases = new[]
        {
            (
                Name: "small-population",
                Definition: CreateSmallPopulationPerformanceSearch(),
                EvaluatedCount: 2,
                ActiveLanes: 2),
            (
                Name: "mixed-operation",
                Definition: CreateMixedOperationPerformanceSearch(rowCount),
                EvaluatedCount: 4,
                ActiveLanes: 4)
        };
        var worker = new MathBlocksCUDAWorker();

        foreach (var performanceCase in cases)
        {
            using var serial = worker.CompilePopulationSearch(
                performanceCase.Definition,
                MathBlockProgramPopulationExecutionOptions.SerialResident);
            using var singleLane = worker.CompilePopulationSearch(
                performanceCase.Definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.ParallelResident,
                    1));
            using var fourLane = worker.CompilePopulationSearch(
                performanceCase.Definition,
                new MathBlockProgramPopulationExecutionOptions(
                    MathBlockProgramPopulationExecutionMode.ParallelResident,
                    4));

            var (serialResult, serialElapsed) = ExecuteMeasuredCycle(serial);
            var (singleLaneResult, singleLaneElapsed) = ExecuteMeasuredCycle(singleLane);
            var (fourLaneResult, fourLaneElapsed) = ExecuteMeasuredCycle(fourLane);

            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} serial cycle took {serialElapsed.TotalSeconds:R} seconds."));
            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} one-lane cycle took {singleLaneElapsed.TotalSeconds:R} seconds."));
            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} four-lane cycle took {fourLaneElapsed.TotalSeconds:R} seconds."));
            Console.WriteLine(FormattableString.Invariant(
                $"The {performanceCase.Name} four-lane runtime used {fourLane.ResidentBytes} resident bytes and {fourLane.CompactDownloadBytesPerCycle} compact bytes."));

            Assert.Equal(
                serialResult.AcceptedState.Export(),
                singleLaneResult.AcceptedState.Export());
            Assert.Equal(
                serialResult.AcceptedState.Export(),
                fourLaneResult.AcceptedState.Export());
            Assert.Equal(
                serialResult.Trials.Select(TrialIdentity),
                singleLaneResult.Trials.Select(TrialIdentity));
            Assert.Equal(
                serialResult.Trials.Select(TrialIdentity),
                fourLaneResult.Trials.Select(TrialIdentity));
            Assert.Equal(
                (ulong)performanceCase.EvaluatedCount,
                fourLaneResult.AcceptedState.EvaluatedProgramCount);
            Assert.Equal(performanceCase.EvaluatedCount, fourLaneResult.Trials.Count);
            Assert.All(fourLaneResult.Trials, trial =>
            {
                Assert.Equal(
                    performanceCase.Definition.EvaluateObjectives(trial.Program)
                        .Select(BitConverter.DoubleToInt64Bits),
                    trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
                Assert.Equal(
                    performanceCase.Definition.CreateSemanticFingerprint(trial.Program),
                    trial.SemanticFingerprint);
            });
            if (performanceCase.Name == "mixed-operation")
            {
                Assert.Equal(
                    ["vector.absolute@1", "vector.square@1"],
                    fourLaneResult.Trials
                        .Select(trial => trial.Program.Nodes[^1].OperationIdentity!)
                        .Distinct(StringComparer.Ordinal)
                        .Order(StringComparer.Ordinal));
            }

            Assert.Equal(
                performanceCase.EvaluatedCount,
                serialResult.Instrumentation.CandidateChunkCount);
            Assert.Equal(
                performanceCase.EvaluatedCount,
                singleLaneResult.Instrumentation.CandidateChunkCount);
            Assert.Equal(1, fourLaneResult.Instrumentation.CandidateChunkCount);
            Assert.Equal(1, serialResult.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(1, singleLaneResult.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(
                performanceCase.ActiveLanes,
                fourLaneResult.Instrumentation.MaximumConcurrentCandidates);
            Assert.Equal(
                performanceCase.EvaluatedCount,
                serialResult.Instrumentation.SerialCandidateExecutionCount);
            Assert.Equal(
                performanceCase.EvaluatedCount,
                singleLaneResult.Instrumentation.ParallelCandidateExecutionCount);
            Assert.Equal(
                performanceCase.EvaluatedCount,
                fourLaneResult.Instrumentation.ParallelCandidateExecutionCount);
            Assert.True(fourLane.ResidentBytes > singleLane.ResidentBytes);
            AssertResidentCycleContract(serial);
            AssertResidentCycleContract(singleLane);
            AssertResidentCycleContract(fourLane);
        }
    }

    [Fact]
    public async Task Resident_search_serializes_concurrent_cycles()
    {
        RequireCuda();
        var baseline = CreateScalarSearch(proposalsPerCycle: 2);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 1));
        var parallelOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            2);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, parallelOptions);

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
        Assert.Equal(MathBlockProgramPopulationExecutionMode.ParallelResident, compiled.ExecutionMode);
        Assert.Equal(2, compiled.ActiveCandidateLaneCount);
        Assert.Equal(2, compiled.CandidateChunkCount);
        Assert.Equal(2, compiled.MaximumConcurrentCandidates);
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
        var baseline = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2, 3]));
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(4, 1));
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));

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
        Assert.Equal(2, result.Instrumentation.CandidateChunkCount);
        Assert.Equal(2, result.Instrumentation.MaximumConcurrentCandidates);
    }

    [Fact]
    public void Resident_search_rejects_invalid_dynamic_values_without_reporting_capacity_overflow()
    {
        RequireCuda();
        var staticVector = MathBlockType.Vector(length: 4);
        var dynamicVector = MathBlockType.Vector();
        var staticBooleanVector = MathBlockType.BooleanVector(4);
        var scalar = MathBlockType.Scalar();
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "source",
                staticVector,
                MathBlockValue.Vector([1d, 2d, 3d, 4d])),
            new MathBlockProgramPopulationTerminal(
                "lag-source",
                staticVector,
                MathBlockValue.Vector([1d, 1d, 1d, 1d]))
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "vector.sum",
                        1,
                        [staticVector],
                        scalar),
                    new MathBlockProgramPopulationOperation(
                        "sequence.difference",
                        1,
                        [staticVector, scalar],
                        dynamicVector),
                    new MathBlockProgramPopulationOperation(
                        "vector.equal",
                        1,
                        [dynamicVector, staticVector],
                        staticBooleanVector)
                ],
                staticBooleanVector),
            terminals,
            [],
            [
                new MathBlockProgramPopulationResourceBand(1, 4),
                new MathBlockProgramPopulationResourceBand(2, 4),
                new MathBlockProgramPopulationResourceBand(3, 4)
            ],
            proposalsPerCycle: 1,
            fingerprintCapacity: 2);
        var terminalNodes = terminals
            .Select((terminal, index) => MathBlockProgramCandidateNode.Terminal(
                index,
                terminal.Identifier,
                terminal.Type))
            .ToArray();
        var program = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                .. terminalNodes,
                MathBlockProgramCandidateNode.Operation(
                    "vector.sum",
                    1,
                    scalar,
                    1),
                MathBlockProgramCandidateNode.Operation(
                    "sequence.difference",
                    1,
                    dynamicVector,
                    0,
                    2),
                MathBlockProgramCandidateNode.Operation(
                    "vector.equal",
                    1,
                    staticBooleanVector,
                    3,
                    0)
            ]);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(0, [program]);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", staticBooleanVector);
        var trueCount = builder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            builder.Output("true-count", trueCount).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "true-count",
                "true-count",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 17),
            new MathBlockProgramPopulationSelectionPolicy(2, 4),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "true-count",
                [new MathBlockProgramPopulationQualityDiversityDimension("true-count", -1, 5, 3)]),
            new MathBlockProgramPopulationSearchEnvelope(128L * 1024 * 1024, 32 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1, 1, 1, 1]),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 1),
            enumerationCatalog: catalog);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                1));

        var result = compiled.ExecuteCycle();

        var trial = Assert.Single(result.Trials);
        Assert.Equal(MathBlockProgramPopulationTrialStatus.InvalidValue, trial.Status);
        Assert.Empty(trial.Objectives);
        Assert.True(result.IsSearchComplete);
        AssertResidentCycleContract(compiled);
        Assert.Equal(1, compiled.ActiveCandidateLaneCount);
    }

    [Fact]
    public void Resident_search_fails_closed_when_convex_hull_exceeds_the_resource_band()
    {
        RequireCuda();
        var staticPointSet = MathBlockType.PointSet(count: 4);
        var dynamicPointSet = MathBlockType.PointSet();
        var terminal = new MathBlockProgramPopulationTerminal(
            "points",
            staticPointSet,
            MathBlockValue.PointSet(new MathBlockPointSet([
                new MathBlockPoint(0d, 0d),
                new MathBlockPoint(1d, 0d),
                new MathBlockPoint(1d, 1d),
                new MathBlockPoint(0d, 1d)
            ])));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "geometry.convex-hull",
                    1,
                    [staticPointSet],
                    dynamicPointSet)],
                dynamicPointSet),
            [terminal],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 4)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 1);
        var terminalNode = MathBlockProgramCandidateNode.Terminal(
            0,
            terminal.Identifier,
            terminal.Type);
        var program = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                terminalNode,
                MathBlockProgramCandidateNode.Operation(
                    "geometry.convex-hull",
                    1,
                    dynamicPointSet,
                    0)
            ]);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(0, [program]);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", dynamicPointSet);
        var diameter = builder.Apply("geometry.diameter", inputs: [candidate]);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            builder.Output("diameter", diameter).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "diameter",
                "diameter",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 19),
            new MathBlockProgramPopulationSelectionPolicy(2, 4),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "diameter",
                [new MathBlockProgramPopulationQualityDiversityDimension("diameter", -1, 5, 3)]),
            new MathBlockProgramPopulationSearchEnvelope(128L * 1024 * 1024, 32 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 1),
            enumerationCatalog: catalog);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                1));
        SetDeviceFirstResourceBandMaximumForFailureTest(compiled, 3);
        var before = compiled.AcceptedState.Export();

        for (var attempt = 0; attempt < 2; attempt++)
        {
            var exception = Assert.Throws<InvalidOperationException>(compiled.ExecuteCycle);
            Assert.Equal(
                "A resident value exceeds the active resource envelope.",
                exception.Message);
            Assert.Equal(before, compiled.AcceptedState.Export());
            Assert.Equal(0ul, compiled.TrialCursor);
            Assert.Empty(compiled.AcceptedState.StructuralFingerprints);
            Assert.Empty(compiled.AcceptedState.SemanticFingerprints);
            Assert.Empty(compiled.AcceptedState.SelectionEntries);
            Assert.Empty(compiled.AcceptedState.QualityDiversityEntries);
        }

        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(2, compiled.GraphLaunchCount);
        Assert.Equal(2, compiled.SynchronizationCount);
        Assert.Equal(2, compiled.DownloadCount);
        Assert.Equal(
            checked(2L * compiled.CompactDownloadBytesPerCycle),
            compiled.DownloadedBytes);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
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
        var baseline = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1]));
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(4, 1));
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                4));
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
    public void Failed_parallel_commit_discards_partial_working_fingerprints_before_retry()
    {
        RequireCuda();
        var scalar = MathBlockType.Scalar();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "scalar.add",
                    1,
                    [scalar, scalar],
                    scalar)],
                scalar),
            [
                new MathBlockProgramPopulationTerminal(
                    "one",
                    scalar,
                    MathBlockValue.Scalar(1d)),
                new MathBlockProgramPopulationTerminal(
                    "two",
                    scalar,
                    MathBlockValue.Scalar(2d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 2,
            fingerprintCapacity: 4);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", scalar);
        var objectiveProgram = builder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var baseline = CreateDefinition(
            population,
            binding,
            maximumTrials: 2,
            enumerationTrials: 2,
            validity: new MathBlockProgramPopulationValidityPolicy([1]));
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 1));
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));
        SetDeviceFingerprintCapacityForFailureTest(compiled, 1);
        var acceptedBefore = compiled.AcceptedState.Export();

        for (var attempt = 0; attempt < 2; attempt++)
        {
            var exception = Assert.Throws<InvalidOperationException>(compiled.ExecuteCycle);
            Assert.Equal(
                "The resident structural fingerprint capacity is exhausted.",
                exception.Message);
            Assert.Equal(acceptedBefore, compiled.AcceptedState.Export());
            Assert.Equal(0ul, compiled.AcceptedState.TrialCursor);
            Assert.Empty(compiled.AcceptedState.StructuralFingerprints);
            Assert.Empty(compiled.AcceptedState.SemanticFingerprints);
            Assert.Empty(compiled.AcceptedState.SelectionEntries);
            Assert.Empty(compiled.AcceptedState.QualityDiversityEntries);
        }

        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(2, compiled.GraphLaunchCount);
        Assert.Equal(2, compiled.SynchronizationCount);
        Assert.Equal(2, compiled.DownloadCount);
        Assert.Equal(
            checked(2L * compiled.CompactDownloadBytesPerCycle),
            compiled.DownloadedBytes);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(0, compiled.CandidateChunkCount);
        Assert.Equal(0, compiled.ParallelCandidateExecutionCount);
    }

    [Fact]
    public void Failed_parallel_prepare_preserves_the_checkpoint_before_evaluation_and_retry()
    {
        RequireCuda();
        var baseline = CreateScalarSearch(
            proposalsPerCycle: 2,
            maximumTrials: 2,
            enumerationTrials: 2);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 1));
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition,
            new MathBlockProgramPopulationExecutionOptions(
                MathBlockProgramPopulationExecutionMode.ParallelResident,
                2));
        SetDeviceCandidateLaneCountForFailureTest(compiled, 0);
        var acceptedBefore = compiled.AcceptedState.Export();

        for (var attempt = 0; attempt < 2; attempt++)
        {
            var exception = Assert.Throws<InvalidOperationException>(compiled.ExecuteCycle);
            Assert.Equal("The resident population search cycle failed closed.", exception.Message);
            Assert.Equal(acceptedBefore, compiled.AcceptedState.Export());
            Assert.Equal(0ul, compiled.AcceptedState.EnumerationCursor);
            Assert.Equal(0ul, compiled.AcceptedState.TrialCursor);
            Assert.Equal(0ul, compiled.AcceptedState.CycleCount);
            Assert.Equal(0ul, compiled.AcceptedState.WaveCursor);
            Assert.Empty(compiled.AcceptedState.StructuralFingerprints);
            Assert.Empty(compiled.AcceptedState.SemanticFingerprints);
            Assert.Empty(compiled.AcceptedState.SelectionEntries);
            Assert.Empty(compiled.AcceptedState.QualityDiversityEntries);
        }

        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(2, compiled.GraphLaunchCount);
        Assert.Equal(2, compiled.SynchronizationCount);
        Assert.Equal(2, compiled.DownloadCount);
        Assert.Equal(
            checked(2L * compiled.CompactDownloadBytesPerCycle),
            compiled.DownloadedBytes);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(0, compiled.CandidateChunkCount);
        Assert.Equal(0, compiled.ParallelCandidateExecutionCount);
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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);
        AssertObjectivePayloadLifetimes(compiled);
        Assert.Equal(33, compiled.Capacity.MaximumValueElements);

        var result = compiled.ExecuteCycle();

        Assert.Single(result.Trials);
        Assert.DoesNotContain(
            result.Trials,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.InvalidType);
        var accepted = result.Trials.SingleOrDefault(
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.Accepted);
        Assert.True(
            accepted is not null,
            $"The resident trial status is {result.Trials[0].Status}.");
        Assert.Equal(expectedProgram.StructuralFingerprint, accepted.StructuralFingerprint);
        Assert.Equal(
            expectedObjectives.Select(BitConverter.DoubleToInt64Bits),
            accepted.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.All(accepted.Objectives, value => Assert.True(double.IsFinite(value)));
        Assert.Equal(expectedSemantic, accepted.SemanticFingerprint);
        Assert.Equal((ulong)1, result.AcceptedState.EvaluatedProgramCount);
        Assert.Equal((ulong)1, result.AcceptedState.AcceptedProgramCount);
        Assert.Equal(14ul, result.AcceptedState.EnumerationCursor);
        Assert.Equal(1ul, result.AcceptedState.EnumerationTrialCount);
        Assert.Equal(13ul, result.AcceptedState.InvalidEnumerationProposalCount);
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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
    public void Resident_search_resolves_graph_edge_capacity_separately_from_vertices()
    {
        RequireCuda();
        var matrixType = MathBlockType.Matrix(rows: 4, columns: 4);
        var adjacency = MathBlockValue.Matrix(new MathBlockMatrix(
            4,
            4,
            [
                0d, 1d, 1d, 1d,
                1d, 0d, 1d, 1d,
                1d, 1d, 0d, 1d,
                1d, 1d, 1d, 0d
            ]));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "matrix.transpose",
                    1,
                    [matrixType],
                    matrixType)],
                matrixType),
            [new MathBlockProgramPopulationTerminal(
                "directed-adjacency",
                matrixType,
                adjacency)],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 16)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", matrixType);
        var graph = objectiveBuilder.Apply("graph.from-directed-adjacency", inputs: [candidate]);
        var triangles = objectiveBuilder.Apply("graph.triangle-count", inputs: [graph]);
        var objectiveProgram = objectiveBuilder.Output("triangle-count", triangles).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "triangle-count",
                "triangle-count",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 1,
            enumerationTrials: 1,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2, 3]));
        var expectedProgram = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "directed-adjacency", matrixType),
                MathBlockProgramCandidateNode.Operation(
                    "matrix.transpose",
                    1,
                    matrixType,
                    0)
            ]);
        var candidateOutput = population.Evaluate(expectedProgram);
        var expectedGraph = MathBlockCatalog.Standard
            .Get("graph.from-directed-adjacency", 1)
            .Evaluate(candidateOutput);
        Assert.Equal(12, expectedGraph.AsGraph().Count);
        var expectedObjectives = definition.EvaluateObjectives(expectedProgram);
        var expectedSemantic = definition.CreateSemanticFingerprint(expectedProgram);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

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
    public void Resident_search_removes_unused_complex_matrix_pick_from_dynamic_objectives()
    {
        RequireCuda();
        var staticVector = MathBlockType.Vector(length: 2);
        var staticComplexVector = MathBlockType.ComplexVector(length: 2);
        var dynamicComplexVector = MathBlockType.ComplexVector();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "transform.discrete-fourier",
                    1,
                    [staticVector],
                    staticComplexVector)],
                dynamicComplexVector),
            [new MathBlockProgramPopulationTerminal(
                "spectral-source",
                staticVector,
                MathBlockValue.Vector([0.25d, 0.25d]))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 2)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicComplexVector);
        _ = objectiveBuilder.Apply("complex-matrix.pick", inputs: [candidate, candidate]);
        var magnitudes = objectiveBuilder.Apply("complex-vector.magnitude", inputs: [candidate]);
        var sum = objectiveBuilder.Apply("vector.sum", inputs: [magnitudes]);
        var objectiveProgram = objectiveBuilder.Output("magnitude-sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "magnitude-sum",
                "magnitude-sum",
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
                MathBlockProgramCandidateNode.Terminal(0, "spectral-source", staticVector),
                MathBlockProgramCandidateNode.Operation(
                    "transform.discrete-fourier",
                    1,
                    staticComplexVector,
                    0)
            ]);
        var candidateOutput = population.Evaluate(expectedProgram);
        var expectedPick = MathBlockCatalog.Standard
            .Get("complex-matrix.pick", 1)
            .Evaluate(candidateOutput, candidateOutput);
        Assert.Equal(4, expectedPick.AsComplexMatrix().ToArray().Length);
        var expectedObjectives = definition.EvaluateObjectives(expectedProgram);
        var expectedSemantic = definition.CreateSemanticFingerprint(expectedProgram);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(2, compiled.Capacity.MaximumValueElements);
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
        Assert.Equal(3, compiled.CudaNodeDispatchCount);
        Assert.Equal((long)compiled.CompactDownloadBytesPerCycle, compiled.DownloadedBytes);
    }

    [Fact]
    public void Resident_search_resolves_dynamic_graph_candidate_vertex_authority()
    {
        RequireCuda();
        var staticGraph = MathBlockType.Graph(vertexCount: 4);
        var dynamicGraph = MathBlockType.Graph();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "graph.minimum-spanning-forest",
                    1,
                    [staticGraph],
                    staticGraph)],
                dynamicGraph),
            [new MathBlockProgramPopulationTerminal(
                "weighted-network",
                staticGraph,
                MathBlockValue.Graph(new MathBlockGraph(
                    4,
                    [
                        new(0, 1, 1d),
                        new(1, 2, 1d),
                        new(2, 3, 1d),
                        new(0, 2, 4d),
                        new(0, 3, 5d)
                    ])))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 5)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicGraph);
        var degree = objectiveBuilder.Apply("graph.degree", inputs: [candidate]);
        var degreeSum = objectiveBuilder.Apply("vector.sum", inputs: [degree]);
        var objectiveProgram = objectiveBuilder.Output("degree-sum", degreeSum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "degree-sum",
                "degree-sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 1,
            enumerationTrials: 1,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2, 3]));
        var expectedProgram = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "weighted-network", staticGraph),
                MathBlockProgramCandidateNode.Operation(
                    "graph.minimum-spanning-forest",
                    1,
                    staticGraph,
                    0)
            ]);
        var candidateOutput = population.Evaluate(expectedProgram);
        Assert.Equal(4, candidateOutput.AsGraph().VertexCount);
        Assert.Equal(3, candidateOutput.AsGraph().Count);
        var expectedObjectives = definition.EvaluateObjectives(expectedProgram);
        var expectedSemantic = definition.CreateSemanticFingerprint(expectedProgram);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

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
    public void Resident_search_rejects_mixed_known_and_unknown_graph_vertex_authority()
    {
        RequireCuda();
        var staticGraph = MathBlockType.Graph(vertexCount: 4);
        var dynamicGraph = MathBlockType.Graph();
        var eightVertexGraph = MathBlockValue.Graph(new MathBlockGraph(
            8,
            [
                new(0, 1, 1d),
                new(1, 2, 1d),
                new(2, 3, 1d),
                new(3, 4, 1d),
                new(4, 5, 1d),
                new(5, 6, 1d),
                new(6, 7, 1d)
            ]));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "graph.minimum-spanning-forest",
                        1,
                        [staticGraph],
                        staticGraph),
                    new MathBlockProgramPopulationOperation(
                        "graph.minimum-spanning-forest",
                        1,
                        [dynamicGraph],
                        dynamicGraph)
                ],
                dynamicGraph),
            [
                new MathBlockProgramPopulationTerminal(
                    "four-vertex-network",
                    staticGraph,
                    MathBlockValue.Graph(new MathBlockGraph(
                        4,
                        [
                            new(0, 1, 1d),
                            new(1, 2, 1d),
                            new(2, 3, 1d)
                        ]))),
                new MathBlockProgramPopulationTerminal(
                    "eight-vertex-network",
                    dynamicGraph,
                    eightVertexGraph)
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 7)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 16);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicGraph);
        var degree = objectiveBuilder.Apply("graph.degree", inputs: [candidate]);
        var degreeSum = objectiveBuilder.Apply("vector.sum", inputs: [degree]);
        var objectiveProgram = objectiveBuilder.Output("degree-sum", degreeSum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "degree-sum",
                "degree-sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = CreateDefinition(
            population,
            binding,
            maximumTrials: 4,
            enumerationTrials: 4,
            validity: new MathBlockProgramPopulationValidityPolicy([0, 1, 2, 3, 4, 5, 6, 7]));
        var dynamicProgram = new MathBlockProgramStructure(
            0,
            0,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(1, "eight-vertex-network", dynamicGraph),
                MathBlockProgramCandidateNode.Operation(
                    "graph.minimum-spanning-forest",
                    1,
                    dynamicGraph,
                    0)
            ]);

        var candidateOutput = population.Evaluate(dynamicProgram);
        var objectiveValues = definition.EvaluateObjectives(dynamicProgram);

        Assert.Equal(8, candidateOutput.AsGraph().VertexCount);
        Assert.Equal(7, candidateOutput.AsGraph().Count);
        Assert.Equal([14d], objectiveValues);
        var exception = Assert.Throws<InvalidOperationException>(
            () => new MathBlocksCUDAWorker().CompilePopulationSearch(definition));
        Assert.Equal("The candidate graph vertex authority is unavailable.", exception.Message);
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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(13, compiled.Capacity.ObjectiveCount);
        Assert.Equal(512, compiled.Capacity.QualityDiversityCellCount);
        Assert.Equal(13, result.Trials.Single().Objectives.Count);
        Assert.Equal(definition.EvaluateObjectives(result.Trials.Single().Program), result.Trials.Single().Objectives);
    }

    [Fact]
    public void Resident_search_resolves_typed_overloads_for_CPU_and_CUDA_objectives()
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

        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);
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
    public void Resident_search_skips_invalid_overload_proposals_before_trial_budget()
    {
        RequireCuda();
        var definition = CreateVectorOverloadSearch(
            proposalsPerCycle: 784,
            maximumTrials: 55,
            enumerationTrials: 55,
            mutationTrials: 1,
            crossoverTrials: 1,
            immigrantTrials: 1);
        var reference = CreateVectorOverloadCpuReference(definition);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
        Assert.Equal(reference.Count, enumeration.Length);
        Assert.DoesNotContain(
            enumeration,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.InvalidType);
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
        Assert.Equal(784ul, result.AcceptedState.EnumerationCursor);
        Assert.Equal((ulong)reference.Count, result.AcceptedState.EnumerationTrialCount);
        Assert.Equal(732ul, result.AcceptedState.InvalidEnumerationProposalCount);
        Assert.True(result.IsEnumerationComplete);
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
    public void Resident_typed_enumeration_bootstraps_below_the_raw_cartesian_budget()
    {
        RequireCuda();
        var definition = CreateMixedUnitComparisonBootstrapSearch();
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var first = compiled.ExecuteCycle();
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());
        var expectedSecond = compiled.ExecuteCycle();
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint));
        var actualSecond = resumed.ExecuteCycle();
        var third = compiled.ExecuteCycle();
        var enumeration = expectedSecond.Trials
            .Concat(third.Trials)
            .Where(trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Enumeration)
            .ToArray();
        var mutation = Assert.Single(
            third.Trials,
            trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Mutation);

        Assert.Equal(64ul, definition.Population.TotalProposalCount);
        Assert.Empty(first.Trials);
        Assert.Equal(6ul, first.AcceptedState.EnumerationCursor);
        Assert.Equal(0ul, first.AcceptedState.EnumerationTrialCount);
        Assert.Equal(6ul, first.AcceptedState.InvalidEnumerationProposalCount);
        Assert.Equal(expectedSecond.AcceptedState.Export(), actualSecond.AcceptedState.Export());
        Assert.Equal(expectedSecond.Trials.Select(TrialIdentity), actualSecond.Trials.Select(TrialIdentity));
        Assert.NotEmpty(expectedSecond.Trials);
        Assert.Equal(12ul, expectedSecond.AcceptedState.EnumerationCursor);
        Assert.Equal(
            [10ul, 11ul],
            expectedSecond.Trials.Select(trial => trial.Program.ProposalCursor!.Value));
        Assert.Equal(4, enumeration.Length);
        Assert.DoesNotContain(
            enumeration,
            trial => trial.Status == MathBlockProgramPopulationTrialStatus.InvalidType);
        Assert.All(enumeration, trial => Assert.Equal(
            definition.EvaluateObjectives(trial.Program).Select(BitConverter.DoubleToInt64Bits),
            trial.Objectives.Select(BitConverter.DoubleToInt64Bits)));
        Assert.NotEmpty(third.AcceptedState.SelectionEntries);
        Assert.NotEqual(MathBlockProgramPopulationTrialStatus.InsufficientParents, mutation.Status);
        Assert.Equal(16ul, third.AcceptedState.EnumerationCursor);
        Assert.Equal(4ul, third.AcceptedState.EnumerationTrialCount);
        Assert.Equal(12ul, third.AcceptedState.InvalidEnumerationProposalCount);
        Assert.True(third.IsEnumerationComplete);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(3, compiled.GraphLaunchCount);
        Assert.Equal(3, compiled.SynchronizationCount);
        Assert.Equal(3, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(1, resumed.GraphInstanceCount);
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_evolution_after_raw_exhaustion_keeps_null_lineage_after_resume()
    {
        RequireCuda();
        var definition = CreateMixedUnitComparisonBootstrapSearch(
            proposalsPerCycle: 32,
            maximumTrials: 17,
            enumerationTrials: 17,
            mutationTrials: 1,
            immigrantTrials: 0);
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);
        var first = uninterrupted.ExecuteCycle();
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());

        var expected = uninterrupted.ExecuteCycle();
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint));
        var actual = resumed.ExecuteCycle();
        var evolved = Assert.Single(
            actual.Trials,
            trial => trial.Program.Source != MathBlockProgramPopulationTrialSource.Enumeration);

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Null(evolved.Program.ProposalCursor);
        Assert.All(
            actual.Trials.Where(trial => trial.Program.Source != MathBlockProgramPopulationTrialSource.Enumeration),
            trial => Assert.Null(trial.Program.ProposalCursor));
        Assert.Equal(64ul, actual.AcceptedState.EnumerationCursor);
        Assert.Equal(16ul, actual.AcceptedState.EnumerationTrialCount);
        Assert.Equal(48ul, actual.AcceptedState.InvalidEnumerationProposalCount);
        Assert.Equal(17ul, actual.AcceptedState.TrialCursor);
        Assert.True(actual.IsEnumerationComplete);
        Assert.True(actual.IsSearchComplete);
        Assert.Equal(1, resumed.GraphInstanceCount);
        Assert.Equal(1, resumed.ImmutableUploadCount);
        Assert.Equal(0, resumed.LaterImmutableUploadCount);
        Assert.Equal(1, resumed.GraphLaunchCount);
        Assert.Equal(1, resumed.SynchronizationCount);
        Assert.Equal(1, resumed.DownloadCount);
        Assert.Equal(0, resumed.FullCandidateOutputDownloadCount);
        Assert.Equal(0, resumed.CpuNodeDispatchCount);
    }

    [Fact]
    public void Resident_overload_search_resume_reproduces_the_exact_next_cycle()
    {
        RequireCuda();
        var definition = CreateVectorOverloadSearch(
            proposalsPerCycle: 392,
            maximumTrials: 52,
            enumerationTrials: 52);
        var reference = CreateVectorOverloadCpuReference(definition);
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);
        var first = uninterrupted.ExecuteCycle();
        var checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());

        var expected = uninterrupted.ExecuteCycle();
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint));
        var actual = resumed.ExecuteCycle();

        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Equal((ulong)reference.Count, actual.AcceptedState.EvaluatedProgramCount);
        Assert.Equal(784ul, actual.AcceptedState.EnumerationCursor);
        Assert.Equal(52ul, actual.AcceptedState.EnumerationTrialCount);
        Assert.Equal(732ul, actual.AcceptedState.InvalidEnumerationProposalCount);
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
            validity,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 3));
        using var initialCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(initialDefinition);
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
            validity,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 3));
        var transition = expandedDefinition.CreateTransitionState(
            initialDefinition,
            initial.AcceptedState);
        var refreshedFingerprint = transition.RefreshPrograms.Single().StructuralFingerprint;
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
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
    public void Resident_search_grows_above_the_Int32_proposal_range_with_bounded_fingerprints_and_exact_resume()
    {
        RequireCuda();
        var initialDefinition = CreateNegationBandSearch(
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            maximumTrials: 2,
            fingerprintCapacity: 4);
        using var initialCompiled = new MathBlocksCUDAWorker().CompilePopulationSearch(initialDefinition);
        var initial = initialCompiled.ExecuteCycle();
        var initialTrialCursor = initial.AcceptedState.TrialCursor;

        var expandedDefinition = CreateNegationBandSearch(
            [
                new MathBlockProgramPopulationResourceBand(1, 1),
                new MathBlockProgramPopulationResourceBand(20, 1)
            ],
            maximumTrials: 7,
            fingerprintCapacity: 10,
            enumerationTrials: 4,
            mutationTrials: 1,
            crossoverTrials: 1,
            immigrantTrials: 1);
        var transition = expandedDefinition.CreateTransitionState(initialDefinition, initial.AcceptedState);
        var restored = MathBlockProgramPopulationSearchState.Import(transition.Export());
        using var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(
            expandedDefinition.WithAcceptedState(transition));
        var expected = uninterrupted.ExecuteCycle();
        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            expandedDefinition.WithAcceptedState(restored));
        var actual = resumed.ExecuteCycle();

        Assert.Equal(ulong.MaxValue, expandedDefinition.Population.TotalProposalCount);
        Assert.False(expandedDefinition.Population.IsTotalProposalCountExact);
        Assert.True(expandedDefinition.Population.TotalProposalCount > int.MaxValue);
        Assert.Equal(10, expandedDefinition.Population.FingerprintCapacity);
        Assert.True(
            expandedDefinition.Population.TotalProposalCount >
            (ulong)expandedDefinition.Population.FingerprintCapacity);
        Assert.Equal(
            initial.AcceptedState.StructuralFingerprints,
            transition.StructuralFingerprints);
        Assert.Equal(expected.AcceptedState.Export(), actual.AcceptedState.Export());
        Assert.Equal(expected.Trials.Select(TrialIdentity), actual.Trials.Select(TrialIdentity));
        Assert.Equal(1ul, actual.AcceptedState.EnvelopeGeneration);
        Assert.True(actual.AcceptedState.TrialCursor > initialTrialCursor);
        Assert.Contains(
            actual.Trials,
            trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Mutation);
        Assert.Contains(
            actual.Trials,
            trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.Crossover);
        Assert.Contains(
            actual.Trials,
            trial => trial.Program.Source == MathBlockProgramPopulationTrialSource.RandomImmigrant);
        Assert.Contains(actual.Trials, trial =>
            trial.Program.Nodes.Count -
                (expandedDefinition.Population.Terminals.Count +
                    expandedDefinition.Population.ScalarConstants.Count) == 20);
        Assert.Contains(actual.Trials, trial => trial.Objectives.Count != 0);
        Assert.All(actual.Trials.Where(trial => trial.Objectives.Count != 0), trial =>
        {
            Assert.Equal(
                expandedDefinition.EvaluateObjectives(trial.Program)
                    .Select(BitConverter.DoubleToInt64Bits),
                trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
        });
        Assert.All(initial.AcceptedState.StructuralFingerprints, fingerprint =>
            Assert.Contains(fingerprint, actual.AcceptedState.StructuralFingerprints));
        Assert.Equal(1, uninterrupted.GraphInstanceCount);
        Assert.Equal(1, uninterrupted.ImmutableUploadCount);
        Assert.Equal(0, uninterrupted.LaterImmutableUploadCount);
        Assert.Equal(1, uninterrupted.GraphLaunchCount);
        Assert.Equal(1, uninterrupted.SynchronizationCount);
        Assert.Equal(1, uninterrupted.DownloadCount);
        Assert.Equal(0, uninterrupted.FullCandidateOutputDownloadCount);
        Assert.Equal(0, uninterrupted.FullCandidateOutputBytes);
        Assert.Equal(0, uninterrupted.CpuNodeDispatchCount);
        Assert.Equal(1, resumed.GraphInstanceCount);
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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

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
    public void Resident_search_bounds_conditional_mutual_information_scratch_from_the_joint_capacity()
    {
        RequireCuda();
        var scalarType = MathBlockType.Scalar();
        var jointType = MathBlockType.Vector(length: 4);
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "scalar.absolute",
                    1,
                    [scalarType],
                    scalarType)],
                scalarType),
            [new MathBlockProgramPopulationTerminal("negative-one", scalarType, MathBlockValue.Scalar(-1d))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 2);
        var catalogProgram = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "negative-one", scalarType),
                MathBlockProgramCandidateNode.Operation(
                    "scalar.absolute",
                    1,
                    scalarType,
                    0)
            ]);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(0, [catalogProgram]);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", scalarType);
        var joint = builder.Input("joint", jointType);
        var firstCount = builder.Input("first-count", scalarType);
        var secondCount = builder.Input("second-count", scalarType);
        var conditionCount = builder.Input("condition-count", scalarType);
        var information = builder.Apply(
            "information.conditional-mutual-information",
            inputs: [joint, firstCount, secondCount, conditionCount]);
        var objectiveProgram = builder
            .Output("information", information)
            .Output("candidate", candidate)
            .Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>
            {
                ["joint"] = MathBlockValue.Vector([0.5d, 0d, 0d, 0.5d]),
                ["first-count"] = MathBlockValue.Scalar(2d),
                ["second-count"] = MathBlockValue.Scalar(2d),
                ["condition-count"] = MathBlockValue.Scalar(1d)
            },
            [
                new MathBlockProgramPopulationObjective(
                    "information",
                    "information",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "candidate",
                    "candidate",
                    MathBlockProgramPopulationObjectiveDirection.Maximize)
            ]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 397),
            new MathBlockProgramPopulationSelectionPolicy(2, 2),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "information",
                [new MathBlockProgramPopulationQualityDiversityDimension("information", 0, 2, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(64L * 1024 * 1024, 16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([int.MaxValue]),
            enumerationCatalog: catalog);
        var invalidBinding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>
            {
                ["joint"] = MathBlockValue.Vector([0.5d, 0d, 0d, 0.5d]),
                ["first-count"] = MathBlockValue.Scalar(2d),
                ["second-count"] = MathBlockValue.Scalar(2d),
                ["condition-count"] = MathBlockValue.Scalar(2d)
            },
            binding.Objectives);
        var invalidDefinition = new MathBlockProgramPopulationSearchDefinition(
            population,
            invalidBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            definition.Envelope,
            definition.Validity,
            enumerationCatalog: catalog);
        var invalidPlan = new MathBlocksCUDAWorker()
            .PlanPopulationSearchStaticFeasibility(invalidDefinition);
        Assert.Empty(invalidPlan.FeasiblePrograms);
        var rejection = Assert.Single(invalidPlan.Rejections);
        Assert.Contains("conditional information shape", rejection.Reason, StringComparison.Ordinal);
        var invalidException = Assert.Throws<InvalidOperationException>(
            () => new MathBlocksCUDAWorker().CompilePopulationSearch(invalidDefinition));
        Assert.Contains("before CUDA setup", invalidException.Message, StringComparison.Ordinal);
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);

        var result = compiled.ExecuteCycle();

        Assert.Equal(3 * 4 * sizeof(double), ReadScratchBytesPerNode(compiled));
        var trial = Assert.Single(result.Trials);
        Assert.Equal(
            definition.EvaluateObjectives(trial.Program).Select(BitConverter.DoubleToInt64Bits),
            trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
        Assert.True(trial.Objectives[0] > 0d);
        Assert.Equal(definition.CreateSemanticFingerprint(trial.Program), trial.SemanticFingerprint);
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        var constrained = new MathBlockProgramPopulationSearchDefinition(
            definition.Population,
            definition.ObjectiveBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            new MathBlockProgramPopulationSearchEnvelope(
                compiled.ResidentBytes - 1,
                definition.Envelope.MaximumCompactDownloadBytes),
            definition.Validity,
            definition.CompactResults,
            definition.InitialPrograms,
            enumerationCatalog: catalog);
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlocksCUDAWorker().CompilePopulationSearch(constrained));
    }

    [Fact]
    public void Resident_search_executes_large_pointwise_vectors_without_quadratic_scratch()
    {
        RequireCuda();
        const int rowCount = 305_581;
        var vectorType = MathBlockType.Vector(length: rowCount);
        var resultType = MathBlockType.BooleanVector(rowCount);
        var firstValue = MathBlockValue.Vector(
            Enumerable.Range(0, rowCount).Select(index => (double)(index % 97)));
        var secondValue = MathBlockValue.Vector(
            Enumerable.Range(0, rowCount).Select(index => (double)((rowCount - index) % 89)));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "vector.greater-than",
                        1,
                        [vectorType, vectorType],
                        resultType),
                    new MathBlockProgramPopulationOperation(
                        "vector.less-than",
                        1,
                        [vectorType, vectorType],
                        resultType)
                ],
                resultType),
            [
                new MathBlockProgramPopulationTerminal("first", vectorType, firstValue),
                new MathBlockProgramPopulationTerminal("second", vectorType, secondValue)
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 8,
            fingerprintCapacity: 16);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", resultType);
        var values = builder.Input("values", vectorType);
        var zeros = builder.Input("zeros", vectorType);
        var trueCount = builder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var selected = builder.Apply("vector.select", inputs: [candidate, values, zeros]);
        var selectedSum = builder.Apply("vector.sum", inputs: [selected]);
        var objectiveProgram = builder
            .Output("true-count", trueCount)
            .Output("selected-sum", selectedSum)
            .Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>
            {
                ["values"] = firstValue,
                ["zeros"] = MathBlockValue.Vector(Enumerable.Repeat(0d, rowCount))
            },
            [
                new MathBlockProgramPopulationObjective(
                    "true-count",
                    "true-count",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "selected-sum",
                    "selected-sum",
                    MathBlockProgramPopulationObjectiveDirection.Maximize)
            ]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(8, 8, 0, 0, 0, 401),
            new MathBlockProgramPopulationSelectionPolicy(8, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "true-count",
                [new MathBlockProgramPopulationQualityDiversityDimension(
                    "true-count",
                    0,
                    rowCount,
                    4)]),
            new MathBlockProgramPopulationSearchEnvelope(512L * 1024 * 1024, 64 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(Enumerable.Repeat(int.MaxValue, rowCount)));
        var serialOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.SerialResident,
            1);
        var parallelOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            1);
        MathBlockProgramPopulationSearchCycleResult serialResult;
        TimeSpan serialElapsed;
        using (var serial = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, serialOptions))
        {
            var serialTimer = Stopwatch.StartNew();
            serialResult = serial.ExecuteCycle();
            serialTimer.Stop();
            serialElapsed = serialTimer.Elapsed;
        }
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, parallelOptions);
        var parallelTimer = Stopwatch.StartNew();
        var result = compiled.ExecuteCycle();
        parallelTimer.Stop();

        Console.WriteLine($"The serial pointwise cycle took {serialElapsed.TotalSeconds:R} seconds.");
        Console.WriteLine($"The parallel pointwise cycle took {parallelTimer.Elapsed.TotalSeconds:R} seconds.");
        Assert.Equal(serialResult.AcceptedState.Export(), result.AcceptedState.Export());
        Assert.Equal(serialResult.Trials.Select(TrialIdentity), result.Trials.Select(TrialIdentity));
        Assert.True(
            parallelTimer.Elapsed.TotalSeconds < serialElapsed.TotalSeconds * 0.8d,
            $"The parallel cycle took {parallelTimer.Elapsed.TotalSeconds:R} seconds. " +
            $"The serial cycle took {serialElapsed.TotalSeconds:R} seconds.");

        Assert.Equal(checked(rowCount * sizeof(double)), ReadScratchBytesPerNode(compiled));
        Assert.Contains(result.Trials, trial => trial.Objectives.Count != 0);
        foreach (var trial in result.Trials.Where(trial => trial.Objectives.Count != 0))
        {
            Assert.Equal(
                definition.EvaluateObjectives(trial.Program).Select(BitConverter.DoubleToInt64Bits),
                trial.Objectives.Select(BitConverter.DoubleToInt64Bits));
            Assert.Equal(definition.CreateSemanticFingerprint(trial.Program), trial.SemanticFingerprint);
        }
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
        Assert.Equal(MathBlockProgramPopulationExecutionMode.ParallelResident, compiled.ExecutionMode);
        Assert.Equal(1, compiled.RequestedCandidateLaneCount);
        Assert.Equal(1, compiled.ActiveCandidateLaneCount);
        Assert.Equal(
            checked((long)result.AcceptedState.TrialCursor),
            result.Instrumentation.ProposalWaveCount);
        Assert.Equal(
            checked((long)result.AcceptedState.EvaluatedProgramCount),
            result.Instrumentation.CandidateChunkCount);
        Assert.Equal(1, result.Instrumentation.MaximumConcurrentCandidates);
        Assert.Equal(0, result.Instrumentation.SerialCandidateExecutionCount);
        Assert.Equal(
            checked((long)result.AcceptedState.EvaluatedProgramCount),
            result.Instrumentation.ParallelCandidateExecutionCount);
        Assert.True(serialResult.Instrumentation.SerialCandidateExecutionCount > 0);
        Assert.Equal(0, serialResult.Instrumentation.ParallelCandidateExecutionCount);
    }

    [Fact]
    public void Resident_search_executes_production_scale_binary_event_objectives_with_exact_node_layout()
    {
        RequireCuda();
        var definition = CreateProductionScaleBinaryEventSearch();
        var parallelOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            1);
        MathBlockProgramPopulationSearchState checkpoint;
        MathBlockProgramPopulationSearchCycleResult expectedNext;
        long residentBytes;
        using (var uninterrupted = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, parallelOptions))
        {
            Assert.Equal(23, definition.Population.Terminals.Count);
            Assert.Empty(definition.Population.ScalarConstants);
            Assert.Equal(8, definition.Population.Grammar.Operations.Count);
            Assert.Equal(4_232ul, definition.Population.TotalProposalCount);
            Assert.Equal(8_071, definition.ObjectiveBinding.Program.PlanNodes.Count);
            var layout = ReadLayout(uninterrupted);
            var nodes = (Array)layout.GetType()
                .GetField("objectiveNodes", BindingFlags.Instance | BindingFlags.NonPublic)!
                .GetValue(layout)!;
            var types = (MathBlockType[])layout.GetType()
                .GetField("types", BindingFlags.Instance | BindingFlags.NonPublic)!
                .GetValue(layout)!;
            var pooledPayloadBytes = (int)layout.GetType()
                .GetProperty("ObjectivePayloadBytes", BindingFlags.Instance | BindingFlags.Public)!
                .GetValue(layout)!;
            long unpooledPayloadBytes = 0;
            foreach (var descriptor in nodes)
            {
                var descriptorType = descriptor!.GetType();
                if ((int)descriptorType.GetProperty("Kind")!.GetValue(descriptor)! != 3)
                    continue;
                var typeId = (int)descriptorType.GetProperty("TypeId")!.GetValue(descriptor)!;
                var capacity = (int)descriptorType.GetProperty("PayloadCapacity")!.GetValue(descriptor)!;
                unpooledPayloadBytes = checked(
                    unpooledPayloadBytes + PayloadBytes(types[typeId].Kind, capacity));
            }
            Assert.True(unpooledPayloadBytes > pooledPayloadBytes);
            Assert.InRange(pooledPayloadBytes, 1, int.MaxValue);
            residentBytes = uninterrupted.ResidentBytes;
            Console.WriteLine(
                $"The measured resident size is {residentBytes} bytes. " +
                $"The objective payload pool is {pooledPayloadBytes} bytes. " +
                $"The unpooled objective payload is {unpooledPayloadBytes} bytes.");
            var firstTimer = Stopwatch.StartNew();
            var first = uninterrupted.ExecuteCycle();
            firstTimer.Stop();
            Console.WriteLine($"The first production-scale cycle took {firstTimer.Elapsed.TotalSeconds:R} seconds.");
            checkpoint = MathBlockProgramPopulationSearchState.Import(first.AcceptedState.Export());
            var evaluatedTrials = first.Trials.Where(trial => trial.Objectives.Count != 0).ToArray();
            Console.WriteLine($"The first production-scale cycle evaluated {evaluatedTrials.Length} programs.");
            Assert.NotEmpty(evaluatedTrials);
            var evaluated = evaluatedTrials[0];

            Assert.Equal(
                definition.EvaluateObjectives(evaluated.Program).Select(BitConverter.DoubleToInt64Bits),
                evaluated.Objectives.Select(BitConverter.DoubleToInt64Bits));
            Assert.Equal(definition.CreateSemanticFingerprint(evaluated.Program), evaluated.SemanticFingerprint);
            Assert.Equal(1, uninterrupted.GraphInstanceCount);
            Assert.Equal(1, uninterrupted.ImmutableUploadCount);
            Assert.Equal(0, uninterrupted.LaterImmutableUploadCount);
            Assert.Equal(1, uninterrupted.GraphLaunchCount);
            Assert.Equal(1, uninterrupted.SynchronizationCount);
            Assert.Equal(1, uninterrupted.DownloadCount);
            Assert.Equal(0, uninterrupted.FullCandidateOutputDownloadCount);
            Assert.Equal(0, uninterrupted.FullCandidateOutputBytes);
            Assert.Equal(0, uninterrupted.CpuNodeDispatchCount);
            Assert.Equal((long)uninterrupted.CompactDownloadBytesPerCycle, uninterrupted.DownloadedBytes);
            Assert.Equal(MathBlockProgramPopulationExecutionMode.ParallelResident, uninterrupted.ExecutionMode);
            Assert.Equal(1, uninterrupted.RequestedCandidateLaneCount);
            Assert.Equal(1, uninterrupted.ActiveCandidateLaneCount);
            Assert.Equal(1, first.Instrumentation.MaximumConcurrentCandidates);
            Assert.True(first.Instrumentation.ParallelCandidateExecutionCount > 0);
            Assert.Equal(0, first.Instrumentation.SerialCandidateExecutionCount);

            var constrained = new MathBlockProgramPopulationSearchDefinition(
                definition.Population,
                definition.ObjectiveBinding,
                definition.Evolution,
                definition.Selection,
                definition.QualityDiversity,
                new MathBlockProgramPopulationSearchEnvelope(
                    residentBytes - 1,
                    definition.Envelope.MaximumCompactDownloadBytes),
                definition.Validity,
                definition.CompactResults,
                definition.InitialPrograms);
            var exception = Assert.Throws<ArgumentOutOfRangeException>(
                () => new MathBlocksCUDAWorker().CompilePopulationSearch(constrained));
            Assert.Contains($"requires {residentBytes} bytes", exception.Message, StringComparison.Ordinal);

            expectedNext = uninterrupted.ExecuteCycle();
        }

        using var resumed = new MathBlocksCUDAWorker().CompilePopulationSearch(
            definition.WithAcceptedState(checkpoint),
            parallelOptions);
        var actualNext = resumed.ExecuteCycle();

        Assert.Equal(expectedNext.AcceptedState.Export(), actualNext.AcceptedState.Export());
        Assert.Equal(expectedNext.Trials.Select(TrialIdentity), actualNext.Trials.Select(TrialIdentity));
        Assert.Equal(residentBytes, resumed.ResidentBytes);
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
    public void Resident_search_reserves_exact_quadratic_scratch_and_enforces_the_resident_envelope()
    {
        RequireCuda();
        const int rowCount = 32;
        var vectorType = MathBlockType.Vector(length: rowCount);
        var scalarType = MathBlockType.Scalar();
        var firstValue = MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index => (double)index));
        var secondValue = MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index => (double)(index * 2)));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "statistics.distance-correlation",
                    1,
                    [vectorType, vectorType],
                    scalarType)],
                scalarType),
            [
                new MathBlockProgramPopulationTerminal("first", vectorType, firstValue),
                new MathBlockProgramPopulationTerminal("second", vectorType, secondValue)
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", scalarType);
        var objectiveProgram = builder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        var definition = new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 409),
            new MathBlockProgramPopulationSelectionPolicy(2, 2),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension("value", 0, 2, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(64L * 1024 * 1024, 16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(Enumerable.Repeat(int.MaxValue, rowCount)));
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);
        var expectedScratch = checked((rowCount * rowCount * 2 + rowCount) * sizeof(double));

        Assert.Equal(expectedScratch, ReadScratchBytesPerNode(compiled));
        var constrained = new MathBlockProgramPopulationSearchDefinition(
            definition.Population,
            definition.ObjectiveBinding,
            definition.Evolution,
            definition.Selection,
            definition.QualityDiversity,
            new MathBlockProgramPopulationSearchEnvelope(
                compiled.ResidentBytes - 1,
                definition.Envelope.MaximumCompactDownloadBytes),
            definition.Validity,
            definition.CompactResults,
            definition.InitialPrograms);
        Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlocksCUDAWorker().CompilePopulationSearch(constrained));
    }

    [Fact]
    public void Resident_search_catalog_covers_every_public_CUDA_operation_identity()
    {
        RequireCuda();
        Assert.Equal(
            MathBlocksCUDAWorker.SupportedBlockIdentities.OrderBy(identity => identity),
            MathBlocksCUDAWorker.SupportedPopulationSearchOperationIdentities.OrderBy(identity => identity));
        var serialOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.SerialResident,
            1);
        var parallelOptions = new MathBlockProgramPopulationExecutionOptions(
            MathBlockProgramPopulationExecutionMode.ParallelResident,
            1);

        foreach (var identity in MathBlocksCUDAWorker.SupportedPopulationSearchOperationIdentities)
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
                fingerprintCapacity: checked(proposalCount + 1));
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
                enumerationCatalog: new MathBlockProgramPopulationEnumerationCatalog(0, [program]));

            var staticPlan = new MathBlocksCUDAWorker().PlanPopulationSearchStaticFeasibility(definition);
            Assert.Single(staticPlan.FeasiblePrograms);
            Assert.Empty(staticPlan.Rejections);

            using var serial = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, serialOptions);
            MathBlockProgramPopulationSearchCycleResult serialResult;
            try
            {
                serialResult = serial.ExecuteCycle();
            }
            catch (Exception exception)
            {
                throw new InvalidOperationException(
                    $"Serial resident execution failed for '{identity}'.",
                    exception);
            }
            using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition, parallelOptions);
            Assert.InRange(ReadScratchBytesPerNode(compiled), 0, int.MaxValue);
            var result = compiled.ExecuteCycle();
            Assert.Equal(serialResult.AcceptedState.Export(), result.AcceptedState.Export());
            Assert.Equal(serialResult.Trials.Select(TrialIdentity), result.Trials.Select(TrialIdentity));
            var archived = result.AcceptedState.SelectionEntries
                .Concat(result.AcceptedState.QualityDiversityEntries)
                .FirstOrDefault(entry => entry.StructuralFingerprint == program.StructuralFingerprint);
            Assert.True(archived is not null, $"Resident execution did not accept '{identity}'.");
            var expectedSemantic = definition.CreateSemanticFingerprint(program);
            Assert.True(
                string.Equals(expectedSemantic, archived!.SemanticFingerprint, StringComparison.Ordinal),
                $"Resident semantic parity failed for '{identity}'. Expected {expectedSemantic}, actual {archived.SemanticFingerprint}.");
            Assert.Equal(1, compiled.ImmutableUploadCount);
            Assert.Equal(1, compiled.GraphLaunchCount);
            Assert.Equal(1, compiled.SynchronizationCount);
            Assert.Equal(1, compiled.DownloadCount);
            Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
            Assert.Equal(0, compiled.CpuNodeDispatchCount);
        }
    }

    [Fact]
    public void Resident_objective_layout_covers_every_public_CUDA_identity_with_safe_lifetime_reuse()
    {
        RequireCuda();
        var definition = CreateAllIdentityObjectiveLayoutSearch();
        using var compiled = new MathBlocksCUDAWorker().CompilePopulationSearch(definition);
        var layout = ReadLayout(compiled);
        var nodes = (Array)layout.GetType()
            .GetField("objectiveNodes", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(layout)!;
        var types = (MathBlockType[])layout.GetType()
            .GetField("types", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(layout)!;
        var objectivePayloadBytes = (int)layout.GetType()
            .GetProperty("ObjectivePayloadBytes", BindingFlags.Instance | BindingFlags.Public)!
            .GetValue(layout)!;
        var scratchBytes = (int)layout.GetType()
            .GetProperty("ScratchBytesPerNode", BindingFlags.Instance | BindingFlags.Public)!
            .GetValue(layout)!;
        var plan = definition.ObjectiveBinding.Program.PlanNodes;
        var lastUses = Enumerable.Range(0, plan.Count).ToArray();
        for (var nodeIndex = 0; nodeIndex < plan.Count; nodeIndex++)
        {
            foreach (var inputIndex in plan[nodeIndex].Inputs)
                lastUses[inputIndex] = Math.Max(lastUses[inputIndex], nodeIndex);
        }
        foreach (var objective in definition.ObjectiveBinding.Objectives)
        {
            if (objective.SourceKind != MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput)
                continue;
            lastUses[definition.ObjectiveBinding.Program.OutputNodeIndexes[objective.ProgramOutput!]] = plan.Count;
        }
        var payloadRanges = new List<(int Node, int LastUse, int Start, int End)>();
        var operationNodeCount = plan.Count(node => node.Kind == MathBlockProgramNodeKind.Operation);
        Assert.Single(nodes);
        for (var nodeIndex = 0; nodeIndex < nodes.Length; nodeIndex++)
        {
            var descriptor = nodes.GetValue(nodeIndex)!;
            var descriptorType = descriptor!.GetType();
            var kind = (int)descriptorType.GetProperty("Kind")!.GetValue(descriptor)!;
            Assert.Equal(0, kind);
            if (kind != 3)
                continue;
            var typeId = (int)descriptorType.GetProperty("TypeId")!.GetValue(descriptor)!;
            var capacity = (int)descriptorType.GetProperty("PayloadCapacity")!.GetValue(descriptor)!;
            var offset = (int)descriptorType.GetProperty("PayloadOffset")!.GetValue(descriptor)!;
            var requiredScratch = (int)descriptorType.GetProperty("ScratchBytes")!.GetValue(descriptor)!;
            var requiredPayload = PayloadBytes(types[typeId].Kind, capacity);
            Assert.InRange(requiredScratch, 0, scratchBytes);
            Assert.InRange(offset, 0, objectivePayloadBytes);
            Assert.InRange(checked(offset + requiredPayload), 0, objectivePayloadBytes);
            if (requiredPayload > 0)
                payloadRanges.Add((nodeIndex, lastUses[nodeIndex], offset, checked(offset + requiredPayload)));
        }
        Assert.Equal(337, MathBlocksCUDAWorker.SupportedBlockIdentities.Count);
        Assert.Equal(MathBlocksCUDAWorker.SupportedBlockIdentities.Count, operationNodeCount);
        Assert.Equal(0, objectivePayloadBytes);
        Assert.Equal(0, scratchBytes);
        for (var leftIndex = 0; leftIndex < payloadRanges.Count; leftIndex++)
        {
            var left = payloadRanges[leftIndex];
            for (var rightIndex = leftIndex + 1; rightIndex < payloadRanges.Count; rightIndex++)
            {
                var right = payloadRanges[rightIndex];
                if (left.LastUse < right.Node)
                    continue;
                Assert.True(left.End <= right.Start || right.End <= left.Start);
            }
        }
        Assert.Empty(payloadRanges);

        var cycle = compiled.ExecuteCycle();
        Assert.Single(cycle.Trials);
        Assert.Equal(1, compiled.CudaNodeDispatchCount);
        Assert.Equal(1, compiled.CudaCandidateDispatchCount);

        var overflow = CreateUnrepresentableLayoutSearch();
        var exception = Assert.Throws<ArgumentOutOfRangeException>(
            () => new MathBlocksCUDAWorker().CompilePopulationSearch(overflow));
        Assert.Contains("candidate payload for 'vector.absolute@1'", exception.Message, StringComparison.Ordinal);
        Assert.Contains("exceeds the supported CUDA arena range", exception.Message, StringComparison.Ordinal);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateProductionScaleBinaryEventSearch()
    {
        const int rowCount = 305_581;
        const int framesPerEra = 30 * 24 * 4;
        const int bootstrapSamples = 257;
        const int bootstrapBlockEras = 2;
        var eraCount = checked((rowCount + framesPerEra - 1) / framesPerEra);
        var candidateType = MathBlockType.BooleanVector(rowCount);
        var units = new[]
        {
            MathBlockUnit.Basis0,
            MathBlockUnit.Basis1,
            MathBlockUnit.Basis2,
            MathBlockUnit.Basis3
        };
        var terminalCounts = new[] { 6, 6, 6, 5 };
        var vectorTypes = units.Select(unit => MathBlockType.Vector(unit, rowCount)).ToArray();
        var operations = units.SelectMany((unit, unitIndex) => new[]
        {
            new MathBlockProgramPopulationOperation(
                "vector.greater-than",
                1,
                [vectorTypes[unitIndex], vectorTypes[unitIndex]],
                candidateType),
            new MathBlockProgramPopulationOperation(
                "vector.less-than",
                1,
                [vectorTypes[unitIndex], vectorTypes[unitIndex]],
                candidateType)
        }).ToArray();
        var terminals = new List<MathBlockProgramPopulationTerminal>();
        for (var unitIndex = 0; unitIndex < units.Length; unitIndex++)
        {
            for (var terminalIndex = 0; terminalIndex < terminalCounts[unitIndex]; terminalIndex++)
            {
                var valueOffset = checked(unitIndex * 10 + terminalIndex);
                terminals.Add(new MathBlockProgramPopulationTerminal(
                    $"telemetry-{unitIndex:D2}-{terminalIndex:D2}",
                    vectorTypes[unitIndex],
                    MathBlockValue.Vector(
                        Enumerable.Range(0, rowCount).Select(row =>
                            (double)((row * (valueOffset + 3) + valueOffset * 11) % 101)),
                        units[unitIndex]),
                    lookback: 1));
            }
        }
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, candidateType),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 64,
            fingerprintCapacity: 8192);
        Assert.Equal(4_232ul, population.TotalProposalCount);

        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var nodeCount = 0;
        int Input(string name, MathBlockType type)
        {
            nodeCount++;
            return builder.Input(name, type);
        }
        int Constant(MathBlockValue value)
        {
            nodeCount++;
            return builder.Constant(value);
        }
        int Apply(string identity, params int[] inputs)
        {
            nodeCount++;
            return builder.Apply(identity, inputs: inputs);
        }
        int Scalar(double value) => Constant(MathBlockValue.Scalar(value));

        var candidate = Input("candidate", MathBlockType.BooleanVector());
        var candidateValidity = Input("candidate-validity", MathBlockType.BooleanVector());
        var eligibility = Input("eligibility", candidateType);
        var positive = Input("positive", candidateType);
        var eraInputs = Enumerable.Range(0, eraCount)
            .Select(era => Input($"era-{era:D3}", candidateType))
            .ToArray();
        int And(int left, int right) => Apply("boolean-vector.and", left, right);
        int Not(int value) => Apply("boolean-vector.not", value);
        int Count(int value) => Apply("boolean-vector.true-count", value);
        int Add(int left, int right) => Apply("scalar.add", left, right);
        int Subtract(int left, int right) => Apply("scalar.subtract", left, right);
        int Multiply(int left, int right) => Apply("scalar.multiply", left, right);
        int Divide(int left, int right) => Apply("scalar.divide", left, right);
        int Maximum(int left, int right) => Apply("scalar.maximum", left, right);
        int Square(int value) => Multiply(value, value);
        int RepeatOne(int value) => Apply("vector.repeat", value, Scalar(1d));
        int VectorFromScalars(IReadOnlyList<int> values)
        {
            var vectors = values.Select(RepeatOne).ToArray();
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

        var notCandidate = Not(candidate);
        var validEvidence = And(eligibility, candidateValidity);
        (int Eligible, int Active, int Inactive, int ActivePositive, int InactivePositive) Counts(int mask)
        {
            var activeMask = And(mask, candidate);
            var inactiveMask = And(mask, notCandidate);
            var activePositiveMask = And(activeMask, positive);
            var inactivePositiveMask = And(inactiveMask, positive);
            var active = Count(activeMask);
            var inactive = Count(inactiveMask);
            _ = Count(mask);
            for (var evidence = 0; evidence < 7; evidence++)
                _ = Count(And(mask, positive));
            return (
                Add(active, inactive),
                active,
                inactive,
                Count(activePositiveMask),
                Count(inactivePositiveMask));
        }

        var aggregateCounts = Counts(validEvidence);
        var one = Scalar(1d);
        var aggregatePositive = Add(aggregateCounts.ActivePositive, aggregateCounts.InactivePositive);
        var baselineProbability = Divide(aggregatePositive, Maximum(aggregateCounts.Eligible, one));
        var activeProbability = Divide(
            aggregateCounts.ActivePositive,
            Maximum(aggregateCounts.Active, one));
        var inactiveProbability = Divide(
            aggregateCounts.InactivePositive,
            Maximum(aggregateCounts.Inactive, one));
        int BrierScore((int Eligible, int Active, int Inactive, int ActivePositive, int InactivePositive) counts)
        {
            var activeNegative = Subtract(counts.Active, counts.ActivePositive);
            var inactiveNegative = Subtract(counts.Inactive, counts.InactivePositive);
            var positiveCount = Add(counts.ActivePositive, counts.InactivePositive);
            var negativeCount = Subtract(counts.Eligible, positiveCount);
            var candidateError = Add(
                Add(
                    Multiply(counts.ActivePositive, Square(Subtract(activeProbability, one))),
                    Multiply(activeNegative, Square(activeProbability))),
                Add(
                    Multiply(counts.InactivePositive, Square(Subtract(inactiveProbability, one))),
                    Multiply(inactiveNegative, Square(inactiveProbability))));
            var baselineError = Add(
                Multiply(positiveCount, Square(Subtract(baselineProbability, one))),
                Multiply(negativeCount, Square(baselineProbability)));
            return Subtract(
                one,
                Divide(candidateError, Maximum(baselineError, Scalar(double.Epsilon))));
        }

        var aggregateScore = BrierScore(aggregateCounts);
        var eraScores = eraInputs
            .Select(era => BrierScore(Counts(And(And(era, eligibility), candidateValidity))))
            .ToArray();
        var eraVector = VectorFromScalars(eraScores);
        var sampleMedians = new int[bootstrapSamples];
        for (var sample = 0; sample < sampleMedians.Length; sample++)
        {
            var indexes = new double[eraCount];
            var position = 0;
            var block = 0;
            while (position < indexes.Length)
            {
                var start = (sample * 17 + block * 29) % eraCount;
                for (var offset = 0; offset < bootstrapBlockEras && position < indexes.Length; offset++)
                    indexes[position++] = (start + offset) % eraCount;
                block++;
            }
            var gathered = Apply(
                "vector.gather",
                eraVector,
                Constant(MathBlockValue.Vector(indexes)));
            sampleMedians[sample] = Apply("vector.median", gathered);
        }
        var sampleMedianVector = VectorFromScalars(sampleMedians);
        var lowerConfidence = Apply("vector.quantile", sampleMedianVector, Scalar(0.05d));
        var lowerEra = Apply("vector.quantile", eraVector, Scalar(0.25d));

        var payloadProbe = Input("payload-probe", vectorTypes[0]);
        var compactPayloadProbe = Apply("vector.unique", payloadProbe);
        for (var probe = 0; probe < 359; probe++)
            Apply("vector.absolute", compactPayloadProbe);
        var filler = Scalar(-1d);
        while (nodeCount < 8_070)
            Apply("scalar.absolute", filler);
        Assert.Equal(8_070, nodeCount);
        Apply("vector.absolute", compactPayloadProbe);
        Assert.Equal(8_071, nodeCount);

        var objectiveProgram = builder
            .Output("lower-confidence", lowerConfidence)
            .Output("aggregate", aggregateScore)
            .Output("lower-era", lowerEra)
            .Build();

        var residentInputs = new Dictionary<string, MathBlockValue>
        {
            ["eligibility"] = MathBlockValue.BooleanVector(Enumerable.Repeat(true, rowCount)),
            ["positive"] = MathBlockValue.BooleanVector(
                Enumerable.Range(0, rowCount).Select(row => row % 3 == 0 || row % 11 == 0)),
            ["payload-probe"] = MathBlockValue.Vector(
                Enumerable.Repeat(1d, rowCount),
                units[0])
        };
        for (var era = 0; era < eraCount; era++)
        {
            var start = checked(era * framesPerEra);
            var end = Math.Min(rowCount, checked(start + framesPerEra));
            residentInputs.Add(
                $"era-{era:D3}",
                MathBlockValue.BooleanVector(
                    Enumerable.Range(0, rowCount).Select(row => row >= start && row < end)));
        }
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            residentInputs,
            [
                new MathBlockProgramPopulationObjective(
                    "lower-confidence",
                    "lower-confidence",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "aggregate",
                    "aggregate",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "lower-era",
                    "lower-era",
                    MathBlockProgramPopulationObjectiveDirection.Maximize)
            ],
            "candidate-validity");
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(512, 256, 1, 1, 1, 1701),
            new MathBlockProgramPopulationSelectionPolicy(128, 128),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "lower-confidence",
                [new MathBlockProgramPopulationQualityDiversityDimension("aggregate", -2d, 2d, 16)]),
            new MathBlockProgramPopulationSearchEnvelope(6L * 1024 * 1024 * 1024, 64 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(Enumerable.Repeat(int.MaxValue, rowCount)));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateAllIdentityObjectiveLayoutSearch()
    {
        var scalarType = MathBlockType.Scalar();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "scalar.absolute",
                    1,
                    [scalarType],
                    scalarType)],
                scalarType),
            [new MathBlockProgramPopulationTerminal("seed", scalarType, MathBlockValue.Scalar(-1d))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", scalarType);
        var residentInputs = new Dictionary<string, MathBlockValue>();
        var operationIndex = 0;
        foreach (var identity in MathBlocksCUDAWorker.SupportedBlockIdentities.OrderBy(value => value))
        {
            var operation = MathBlockCatalog.Standard.Operations.Single(value => value.Identity == identity);
            var regression = operation.RegressionCases[0];
            var inputs = new int[regression.Inputs.Count];
            for (var input = 0; input < inputs.Length; input++)
            {
                var name = $"operation-{operationIndex:D3}-input-{input:D2}";
                inputs[input] = builder.Input(name, regression.Inputs[input].Type);
                residentInputs.Add(name, regression.Inputs[input]);
            }
            var output = builder.Apply(operation.Identifier, operation.Version, inputs);
            builder.Output($"operation-{operationIndex:D3}", output);
            operationIndex++;
        }
        var program = builder.Output("candidate", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            residentInputs,
            [new MathBlockProgramPopulationObjective(
                "candidate",
                "candidate",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 1703),
            new MathBlockProgramPopulationSelectionPolicy(2, 2),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "candidate",
                [new MathBlockProgramPopulationQualityDiversityDimension("candidate", -2d, 2d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(512L * 1024 * 1024, 64 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([int.MaxValue]));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateUnrepresentableLayoutSearch()
    {
        var dynamicVector = MathBlockType.Vector();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.absolute",
                    1,
                    [dynamicVector],
                    dynamicVector)],
                dynamicVector),
            [new MathBlockProgramPopulationTerminal(
                "seed",
                MathBlockType.Vector(length: 1),
                MathBlockValue.Vector([1d]))],
            [],
            [new MathBlockProgramPopulationResourceBand(1, int.MaxValue)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 2);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", dynamicVector);
        var program = builder.Output("candidate", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [MathBlockProgramPopulationObjective.Intrinsic(
                "complexity",
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount,
                MathBlockProgramPopulationObjectiveDirection.Minimize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 1709),
            new MathBlockProgramPopulationSelectionPolicy(1, 1),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "complexity",
                [new MathBlockProgramPopulationQualityDiversityDimension("complexity", 0d, 2d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(long.MaxValue, 64 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([int.MaxValue]));
    }

    private static object ReadLayout(MathBlocksCUDAProgramPopulationSearch compiled) =>
        typeof(MathBlocksCUDAProgramPopulationSearch)
            .GetField("layout", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(compiled)!;

    private static void AssertObjectivePayloadLifetimes(
        MathBlocksCUDAProgramPopulationSearch compiled)
    {
        var layout = ReadLayout(compiled);
        var nodes = (Array)layout.GetType()
            .GetField("objectiveNodes", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(layout)!;
        var types = (MathBlockType[])layout.GetType()
            .GetField("types", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(layout)!;
        var inputs = (int[])layout.GetType()
            .GetField("objectiveInputs", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(layout)!;
        var sources = (Array)layout.GetType()
            .GetField("objectiveSources", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(layout)!;
        var payloadBytes = (int)layout.GetType()
            .GetProperty("ObjectivePayloadBytes", BindingFlags.Instance | BindingFlags.Public)!
            .GetValue(layout)!;
        var lastUses = Enumerable.Range(0, nodes.Length).ToArray();
        for (var nodeIndex = 0; nodeIndex < nodes.Length; nodeIndex++)
        {
            var descriptor = nodes.GetValue(nodeIndex)!;
            var descriptorType = descriptor.GetType();
            var arity = (int)descriptorType.GetProperty("Arity")!.GetValue(descriptor)!;
            var inputBase = (int)descriptorType.GetProperty("InputBase")!.GetValue(descriptor)!;
            for (var inputOffset = 0; inputOffset < arity; inputOffset++)
            {
                var inputIndex = inputs[inputBase + inputOffset];
                lastUses[inputIndex] = Math.Max(lastUses[inputIndex], nodeIndex);
            }
        }
        foreach (var source in sources)
        {
            var sourceType = source!.GetType();
            var programNodeIndex = (int)sourceType.GetProperty("ProgramNodeIndex")!.GetValue(source)!;
            if (programNodeIndex < 0)
                continue;
            lastUses[programNodeIndex] = nodes.Length;
        }

        var ranges = new List<(int Node, int LastUse, int Start, int End)>();
        for (var nodeIndex = 0; nodeIndex < nodes.Length; nodeIndex++)
        {
            var descriptor = nodes.GetValue(nodeIndex)!;
            var descriptorType = descriptor.GetType();
            if ((int)descriptorType.GetProperty("Kind")!.GetValue(descriptor)! != 3)
                continue;
            var typeId = (int)descriptorType.GetProperty("TypeId")!.GetValue(descriptor)!;
            var capacity = (int)descriptorType.GetProperty("PayloadCapacity")!.GetValue(descriptor)!;
            var offset = (int)descriptorType.GetProperty("PayloadOffset")!.GetValue(descriptor)!;
            var requiredBytes = PayloadBytes(types[typeId].Kind, capacity);
            Assert.InRange(offset, 0, payloadBytes);
            Assert.InRange(checked(offset + requiredBytes), 0, payloadBytes);
            if (requiredBytes > 0)
                ranges.Add((nodeIndex, lastUses[nodeIndex], offset, checked(offset + requiredBytes)));
        }
        for (var leftIndex = 0; leftIndex < ranges.Count; leftIndex++)
        {
            var left = ranges[leftIndex];
            for (var rightIndex = leftIndex + 1; rightIndex < ranges.Count; rightIndex++)
            {
                var right = ranges[rightIndex];
                if (left.LastUse < right.Node)
                    continue;
                Assert.True(
                    left.End <= right.Start || right.End <= left.Start,
                    $"Objective nodes {left.Node} and {right.Node} have overlapping live payloads.");
            }
        }
    }

    private static int PayloadBytes(MathBlockValueKind kind, int capacity) => kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
        MathBlockValueKind.Vector or MathBlockValueKind.Matrix => checked(capacity * sizeof(double)),
        MathBlockValueKind.BooleanVector => checked(capacity * sizeof(int)),
        MathBlockValueKind.Complex or MathBlockValueKind.ComplexVector or
            MathBlockValueKind.ComplexMatrix or MathBlockValueKind.PointSet or
            MathBlockValueKind.Graph or MathBlockValueKind.RunSet => checked(capacity * 16),
        _ => throw new NotSupportedException()
    };

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

    private static MathBlockProgramPopulationSearchDefinition CreateMixedUnitComparisonBootstrapSearch(
        int proposalsPerCycle = 6,
        ulong maximumTrials = 6,
        ulong enumerationTrials = 4,
        int mutationTrials = 1,
        int immigrantTrials = 1)
    {
        var firstUnit = MathBlockUnit.Basis0;
        var secondUnit = MathBlockUnit.Basis1;
        var firstType = MathBlockType.Vector(firstUnit, 3);
        var secondType = MathBlockType.Vector(secondUnit, 3);
        var outputType = MathBlockType.BooleanVector(3);
        var operations = new[]
        {
            new MathBlockProgramPopulationOperation(
                "vector.greater-than", 1, [secondType, secondType], outputType),
            new MathBlockProgramPopulationOperation(
                "vector.less-than", 1, [secondType, secondType], outputType),
            new MathBlockProgramPopulationOperation(
                "vector.greater-than", 1, [firstType, firstType], outputType),
            new MathBlockProgramPopulationOperation(
                "vector.less-than", 1, [firstType, firstType], outputType)
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, outputType),
            [
                new MathBlockProgramPopulationTerminal(
                    "first-a", firstType, MathBlockValue.Vector([4d, 1d, 3d], firstUnit)),
                new MathBlockProgramPopulationTerminal(
                    "first-b", firstType, MathBlockValue.Vector([2d, 5d, 0d], firstUnit)),
                new MathBlockProgramPopulationTerminal(
                    "second-a", secondType, MathBlockValue.Vector([7d, 2d, 6d], secondUnit)),
                new MathBlockProgramPopulationTerminal(
                    "second-b", secondType, MathBlockValue.Vector([1d, 8d, 3d], secondUnit))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 3)],
            proposalsPerCycle,
            fingerprintCapacity: 64);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", outputType);
        var trueCount = builder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            builder.Output("true-count", trueCount).Build(),
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
                0,
                immigrantTrials,
                8675309),
            new MathBlockProgramPopulationSelectionPolicy(8, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "true-count",
                [new MathBlockProgramPopulationQualityDiversityDimension("true-count", 0, 4, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(128L * 1024 * 1024, 32 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1, 1, 1]));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateLargeRollingStaticFeasibilitySearch(
        bool includeValidProgram,
        int? proposalWaveSize = null)
    {
        const int rowCount = 305_581;
        var unit = MathBlockUnit.Basis0;
        var vector = MathBlockType.Vector(unit, rowCount);
        var dynamicVector = MathBlockType.Vector(unit);
        var scalar = MathBlockType.Scalar();
        var dynamicBooleanVector = MathBlockType.BooleanVector();
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "values",
                vector,
                MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index => (double)(index % 997)), unit)),
            new MathBlockProgramPopulationTerminal(
                "row-count",
                scalar,
                MathBlockValue.Scalar(rowCount)),
            new MathBlockProgramPopulationTerminal(
                "probability",
                scalar,
                MathBlockValue.Scalar(1d))
        };
        var operations = new[]
        {
            new MathBlockProgramPopulationOperation(
                "sequence.rolling-median", 1, [vector, scalar], dynamicVector),
            new MathBlockProgramPopulationOperation(
                "sequence.rolling-quantile", 1, [vector, scalar, scalar], dynamicVector),
            new MathBlockProgramPopulationOperation(
                "vector.equal", 1, [dynamicVector, vector], dynamicBooleanVector),
            new MathBlockProgramPopulationOperation(
                "vector.equal", 1, [vector, dynamicVector], dynamicBooleanVector),
            new MathBlockProgramPopulationOperation(
                "vector.equal", 1, [vector, vector], dynamicBooleanVector)
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, dynamicBooleanVector),
            terminals,
            [],
            [
                new MathBlockProgramPopulationResourceBand(1, rowCount),
                new MathBlockProgramPopulationResourceBand(2, rowCount)
            ],
            proposalsPerCycle: 5,
            fingerprintCapacity: 32);
        var terminalNodes = terminals.Select((terminal, index) =>
            MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type)).ToArray();
        var programs = new List<MathBlockProgramStructure>();
        void AddRolling(string identity, bool reverse)
        {
            var rollingInputs = identity == "sequence.rolling-median"
                ? new[] { 0, 1 }
                : new[] { 0, 1, 2 };
            var rollingIndex = terminalNodes.Length;
            programs.Add(new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [
                    .. terminalNodes,
                    MathBlockProgramCandidateNode.Operation(identity, 1, dynamicVector, rollingInputs),
                    MathBlockProgramCandidateNode.Operation(
                        "vector.equal",
                        1,
                        dynamicBooleanVector,
                        reverse ? 0 : rollingIndex,
                        reverse ? rollingIndex : 0)
                ]));
        }
        AddRolling("sequence.rolling-median", reverse: false);
        AddRolling("sequence.rolling-quantile", reverse: false);
        AddRolling("sequence.rolling-median", reverse: true);
        AddRolling("sequence.rolling-quantile", reverse: true);
        if (includeValidProgram)
        {
            programs.Add(new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [
                    .. terminalNodes,
                    MathBlockProgramCandidateNode.Operation(
                        "vector.equal",
                        1,
                        dynamicBooleanVector,
                        0,
                        0)
                ]));
        }
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(0, programs);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicBooleanVector);
        var count = objectiveBuilder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveBuilder.Output("count", count).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "count",
                "count",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(
                (ulong)programs.Count,
                (ulong)programs.Count,
                0,
                0,
                0,
                2305),
            new MathBlockProgramPopulationSelectionPolicy(4, 4),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "count",
                [new MathBlockProgramPopulationQualityDiversityDimension(
                    "count", 0, rowCount + 1d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(
                512L * 1024 * 1024,
                16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(
                Enumerable.Repeat(int.MaxValue, rowCount)),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(
                proposalWaveSize ?? programs.Count,
                1),
            enumerationCatalog: catalog);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateCombinedFullHistoryRollingSearch()
    {
        const int rowCount = 305_581;
        var unit = MathBlockUnit.Basis0;
        var vector = MathBlockType.Vector(unit, rowCount);
        var dynamicVector = MathBlockType.Vector(unit);
        var dynamicBooleanVector = MathBlockType.BooleanVector();
        var scalar = MathBlockType.Scalar();
        var unitScalar = MathBlockType.Scalar(unit);
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "values",
                vector,
                MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index =>
                    (index * 104_729L + 17) % 1_000_003 - 500_001d), unit)),
            new MathBlockProgramPopulationTerminal(
                "width",
                scalar,
                MathBlockValue.Scalar(rowCount)),
            new MathBlockProgramPopulationTerminal(
                "unit-scale",
                unitScalar,
                MathBlockValue.Scalar(1d, unit))
        };
        var operations = new[]
        {
            new MathBlockProgramPopulationOperation(
                "sequence.rolling-median", 1, [vector, scalar], dynamicVector),
            new MathBlockProgramPopulationOperation(
                "vector.equal", 1, [dynamicVector, vector], dynamicBooleanVector),
            new MathBlockProgramPopulationOperation(
                "boolean-vector.true-count", 1, [dynamicBooleanVector], scalar),
            new MathBlockProgramPopulationOperation(
                "vector.sum", 1, [dynamicVector], unitScalar),
            new MathBlockProgramPopulationOperation(
                "scalar.multiply", 1, [scalar, unitScalar], unitScalar)
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, unitScalar),
            terminals,
            [],
            [
                new MathBlockProgramPopulationResourceBand(2, rowCount),
                new MathBlockProgramPopulationResourceBand(4, rowCount)
            ],
            proposalsPerCycle: 2,
            fingerprintCapacity: 8);
        var terminalNodes = terminals.Select((terminal, index) =>
            MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type)).ToArray();
        var rollingIndex = terminalNodes.Length;
        var incompatibleComparisonIndex = rollingIndex + 1;
        var trueCountIndex = rollingIndex + 2;
        var programs = new[]
        {
            new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [
                    .. terminalNodes,
                    MathBlockProgramCandidateNode.Operation(
                        "sequence.rolling-median", 1, dynamicVector, 0, 1),
                    MathBlockProgramCandidateNode.Operation(
                        "vector.equal", 1, dynamicBooleanVector, rollingIndex, 0),
                    MathBlockProgramCandidateNode.Operation(
                        "boolean-vector.true-count", 1, scalar, incompatibleComparisonIndex),
                    MathBlockProgramCandidateNode.Operation(
                        "scalar.multiply", 1, unitScalar, trueCountIndex, 2)
                ]),
            new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [
                    .. terminalNodes,
                    MathBlockProgramCandidateNode.Operation(
                        "sequence.rolling-median", 1, dynamicVector, 0, 1),
                    MathBlockProgramCandidateNode.Operation(
                        "vector.sum", 1, unitScalar, rollingIndex)
                ])
        };
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", unitScalar);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveBuilder.Output("value", candidate).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(2, 2, 0, 0, 0, 2306),
            new MathBlockProgramPopulationSelectionPolicy(2, 2),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension(
                    "value", -1_000_000d, 1_000_000d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(
                1024L * 1024 * 1024,
                16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(
                Enumerable.Repeat(int.MaxValue, rowCount)),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 1),
            enumerationCatalog: new MathBlockProgramPopulationEnumerationCatalog(0, programs));
    }

    private static void WarmFullHistoryRolling(MathBlockValue values)
    {
        var width = MathBlockValue.Scalar(values.AsVector().Count);
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            ["values"] = values,
            ["width"] = width
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var valueNode = builder.Input("values", values.Type);
        var widthNode = builder.Input("width", width.Type);
        var median = builder.Apply(
            "sequence.rolling-median",
            inputs: [valueNode, widthNode]);
        using var compiled = new MathBlocksCUDAWorker().Compile(
            builder.Output("median", median).Build(),
            inputs);
        compiled.UploadInputs(inputs);
        for (var index = 0; index < 2; index++)
        {
            compiled.ExecuteResident();
            compiled.Synchronize();
        }
    }

    private static MathBlockProgramPopulationSearchDefinition CreateObjectiveOptimizationSearch()
    {
        const int rowCount = 4_096;
        var unit = MathBlockUnit.Basis0;
        var vector = MathBlockType.Vector(unit, rowCount);
        var dynamicBooleanVector = MathBlockType.BooleanVector();
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "left",
                vector,
                MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index => (double)index), unit)),
            new MathBlockProgramPopulationTerminal(
                "right",
                vector,
                MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index => (double)index), unit))
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.equal", 1, [vector, vector], dynamicBooleanVector)],
                dynamicBooleanVector),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var program = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "left", vector),
                MathBlockProgramCandidateNode.Terminal(1, "right", vector),
                MathBlockProgramCandidateNode.Operation(
                    "vector.equal", 1, dynamicBooleanVector, 0, 1)
            ]);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", dynamicBooleanVector);
        var resident = objectiveBuilder.Input("resident", vector);
        var width = objectiveBuilder.Constant(MathBlockValue.Scalar(rowCount));
        var count = objectiveBuilder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var duplicate = objectiveBuilder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var two = objectiveBuilder.Constant(MathBlockValue.Scalar(2d));
        var three = objectiveBuilder.Constant(MathBlockValue.Scalar(3d));
        var folded = objectiveBuilder.Apply("scalar.add", inputs: [two, three]);
        var dead = objectiveBuilder.Apply("sequence.rolling-median", inputs: [resident, width]);
        var objectiveProgram = objectiveBuilder
            .Output("count", count)
            .Output("duplicate", duplicate)
            .Output("folded", folded)
            .Output("dead", dead)
            .Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveProgram,
            "candidate",
            new Dictionary<string, MathBlockValue>
            {
                ["resident"] = terminals[0].Value
            },
            [
                new MathBlockProgramPopulationObjective(
                    "count", "count", MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "duplicate", "duplicate", MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "folded", "folded", MathBlockProgramPopulationObjectiveDirection.Maximize)
            ]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 2307),
            new MathBlockProgramPopulationSelectionPolicy(2, 2),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "count",
                [new MathBlockProgramPopulationQualityDiversityDimension(
                    "count", 0d, rowCount + 1d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(
                256L * 1024 * 1024,
                16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy(
                Enumerable.Repeat(int.MaxValue, rowCount)),
            enumerationCatalog: new MathBlockProgramPopulationEnumerationCatalog(0, [program]));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateRuntimeInvalidShortCircuitSearch()
    {
        var unit = MathBlockUnit.Basis0;
        var vector = MathBlockType.Vector(unit, 3);
        var scalar = MathBlockType.Scalar(unit);
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal(
                "numerator",
                vector,
                MathBlockValue.Vector([1d, 2d, 3d], unit)),
            new MathBlockProgramPopulationTerminal(
                "denominator",
                MathBlockType.Vector(),
                MathBlockValue.Vector([0d, 0d, 0d]))
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "vector.divide", 1, [vector, MathBlockType.Vector()], vector),
                    new MathBlockProgramPopulationOperation(
                        "vector.sum", 1, [vector], scalar)
                ],
                scalar),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(2, 3)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 4);
        var program = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, "numerator", vector),
                MathBlockProgramCandidateNode.Terminal(1, "denominator", MathBlockType.Vector()),
                MathBlockProgramCandidateNode.Operation("vector.divide", 1, vector, 0, 1),
                MathBlockProgramCandidateNode.Operation("vector.sum", 1, scalar, 2)
            ]);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveBuilder.Output("value", candidate).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value", "value", MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 2308),
            new MathBlockProgramPopulationSelectionPolicy(1, 1),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension(
                    "value", -10d, 10d, 2)]),
            new MathBlockProgramPopulationSearchEnvelope(
                64L * 1024 * 1024,
                8 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([int.MaxValue, int.MaxValue, int.MaxValue]),
            enumerationCatalog: new MathBlockProgramPopulationEnumerationCatalog(0, [program]));
    }

    private static MathBlockProgramPopulationSearchDefinition CreateExplicitMixedUnitCatalogSearch(
        int catalogOffset = 0,
        int catalogCount = 8,
        ulong cursorStart = 4096,
        MathBlockProgramPopulationValidityPolicy? validity = null,
        bool includeAdditionalTerminal = false,
        bool includeExpandedGrammar = false)
    {
        if (catalogOffset < 0 || catalogCount <= 0 || catalogOffset + catalogCount > 8)
            throw new ArgumentOutOfRangeException(nameof(catalogOffset));
        var firstUnit = MathBlockUnit.Basis0;
        var secondUnit = MathBlockUnit.Basis1;
        var firstType = MathBlockType.Vector(firstUnit, 3);
        var secondType = MathBlockType.Vector(secondUnit, 3);
        var outputType = MathBlockType.BooleanVector(3);
        var operations = new List<MathBlockProgramPopulationOperation>
        {
            new MathBlockProgramPopulationOperation(
                "vector.greater-than", 1, [secondType, secondType], outputType),
            new MathBlockProgramPopulationOperation(
                "vector.less-than", 1, [secondType, secondType], outputType),
            new MathBlockProgramPopulationOperation(
                "vector.greater-than", 1, [firstType, firstType], outputType),
            new MathBlockProgramPopulationOperation(
                "vector.less-than", 1, [firstType, firstType], outputType)
        };
        if (includeExpandedGrammar)
        {
            operations.Add(new MathBlockProgramPopulationOperation(
                "boolean-vector.and", 1, [outputType, outputType], outputType));
        }
        var terminals = new List<MathBlockProgramPopulationTerminal>
        {
            new MathBlockProgramPopulationTerminal(
                "first-a", firstType, MathBlockValue.Vector([4d, 1d, 3d], firstUnit)),
            new MathBlockProgramPopulationTerminal(
                "first-b", firstType, MathBlockValue.Vector([2d, 5d, 0d], firstUnit)),
            new MathBlockProgramPopulationTerminal(
                "second-a", secondType, MathBlockValue.Vector([7d, 2d, 6d], secondUnit)),
            new MathBlockProgramPopulationTerminal(
                "second-b", secondType, MathBlockValue.Vector([1d, 8d, 3d], secondUnit))
        };
        if (includeAdditionalTerminal)
        {
            terminals.Add(new MathBlockProgramPopulationTerminal(
                "first-c",
                firstType,
                MathBlockValue.Vector([9d, 4d, 2d], firstUnit)));
        }
        var resourceBands = new List<MathBlockProgramPopulationResourceBand>
        {
            new(1, 3)
        };
        if (includeExpandedGrammar)
            resourceBands.Add(new MathBlockProgramPopulationResourceBand(2, 3));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, outputType),
            terminals,
            [],
            resourceBands,
            proposalsPerCycle: 2,
            fingerprintCapacity: 32);
        var terminalNodes = terminals
            .Select((terminal, index) =>
                MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type))
            .ToArray();
        var programs = new List<MathBlockProgramStructure>();
        void AddPrograms(string operation, int first, int second)
        {
            programs.Add(new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [.. terminalNodes, MathBlockProgramCandidateNode.Operation(
                    operation, 1, outputType, first, second)]));
            programs.Add(new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [.. terminalNodes, MathBlockProgramCandidateNode.Operation(
                    operation, 1, outputType, second, first)]));
        }
        AddPrograms("vector.greater-than", 0, 1);
        AddPrograms("vector.less-than", 0, 1);
        AddPrograms("vector.greater-than", 2, 3);
        AddPrograms("vector.less-than", 2, 3);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(
            cursorStart,
            programs.Skip(catalogOffset).Take(catalogCount));
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", outputType);
        var trueCount = builder.Apply("boolean-vector.true-count", inputs: [candidate]);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            builder.Output("true-count", trueCount).Build(),
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
                catalog.CursorEndExclusive,
                (ulong)catalog.Programs.Count,
                0,
                0,
                0,
                8675309),
            new MathBlockProgramPopulationSelectionPolicy(16, 16),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "true-count",
                [new MathBlockProgramPopulationQualityDiversityDimension("true-count", 0, 4, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(128L * 1024 * 1024, 32 * 1024 * 1024),
            validity ?? new MathBlockProgramPopulationValidityPolicy([1, 1, 1]),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 1),
            enumerationCatalog: catalog);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateScalarDuplicateCatalogSearch(
        bool useAbsolute,
        ulong cursorStart,
        ulong maximumTrialCount,
        int immigrantTrials)
    {
        var scalar = MathBlockType.Scalar();
        var operations = new[]
        {
            new MathBlockProgramPopulationOperation(
                "scalar.absolute", 1, [scalar], scalar),
            new MathBlockProgramPopulationOperation(
                "scalar.negate", 1, [scalar], scalar)
        };
        var terminal = new MathBlockProgramPopulationTerminal(
            "negative-two",
            scalar,
            MathBlockValue.Scalar(-2d));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(operations, scalar),
            [terminal],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 8,
            fingerprintCapacity: 64);
        var program = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, terminal.Identifier, terminal.Type),
                MathBlockProgramCandidateNode.Operation(
                    useAbsolute ? "scalar.absolute" : "scalar.negate",
                    1,
                    scalar,
                    0)
            ]);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(cursorStart, [program]);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", scalar);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            builder.Output("value", candidate).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(
                maximumTrialCount,
                1,
                0,
                0,
                immigrantTrials,
                randomSeed: 123,
                randomSequence: 9),
            new MathBlockProgramPopulationSelectionPolicy(4, 64),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension("value", 0, 4, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(64L * 1024 * 1024, 16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(2, 2),
            enumerationCatalog: catalog);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateExpandingCatalogCapacitySearch(
        int maximumOutputElements)
    {
        var vector = MathBlockType.Vector();
        var matrix = MathBlockType.Matrix();
        var scalar = MathBlockType.Scalar();
        var terminal = new MathBlockProgramPopulationTerminal(
            "coordinates",
            vector,
            MathBlockValue.Vector([1d, 2d, 3d]));
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "matrix.outer-product",
                        1,
                        [vector, vector],
                        matrix),
                    new MathBlockProgramPopulationOperation(
                        "matrix.frobenius-norm",
                        1,
                        [matrix],
                        scalar)
                ],
                scalar),
            [terminal],
            [],
            [new MathBlockProgramPopulationResourceBand(2, maximumOutputElements)],
            proposalsPerCycle: 1,
            fingerprintCapacity: 8);
        var program = new MathBlockProgramStructure(
            0,
            null,
            MathBlockProgramPopulationTrialSource.Enumeration,
            [
                MathBlockProgramCandidateNode.Terminal(0, terminal.Identifier, terminal.Type),
                MathBlockProgramCandidateNode.Operation(
                    "matrix.outer-product",
                    1,
                    matrix,
                    0,
                    0),
                MathBlockProgramCandidateNode.Operation(
                    "matrix.frobenius-norm",
                    1,
                    scalar,
                    1)
            ]);
        var catalog = new MathBlockProgramPopulationEnumerationCatalog(0, [program]);
        var objectiveBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = objectiveBuilder.Input("candidate", scalar);
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            objectiveBuilder.Output("value", candidate).Build(),
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(1, 1, 0, 0, 0, 53),
            new MathBlockProgramPopulationSelectionPolicy(2, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension("value", 0, 20, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(64L * 1024 * 1024, 16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]),
            wavePolicy: new MathBlockProgramPopulationWavePolicy(1, 1),
            enumerationCatalog: catalog);
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

    private static MathBlockProgramPopulationSearchDefinition CreateSmallPopulationPerformanceSearch()
    {
        var scalar = MathBlockType.Scalar();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "scalar.add",
                    1,
                    [scalar, scalar],
                    scalar)],
                scalar),
            [
                new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d)),
                new MathBlockProgramPopulationTerminal("two", scalar, MathBlockValue.Scalar(2d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 2,
            fingerprintCapacity: 4);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", scalar);
        var program = builder.Output("value", candidate).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "value",
                "value",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return CreatePerformanceWaveDefinition(
            population,
            binding,
            rowCount: 1,
            trialCount: 2,
            waveSize: 2);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateMixedOperationPerformanceSearch(
        int rowCount)
    {
        var vector = MathBlockType.Vector(length: rowCount);
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [
                    new MathBlockProgramPopulationOperation(
                        "vector.absolute",
                        1,
                        [vector],
                        vector),
                    new MathBlockProgramPopulationOperation(
                        "vector.square",
                        1,
                        [vector],
                        vector)
                ],
                vector),
            [
                new MathBlockProgramPopulationTerminal(
                    "mixed-series-one",
                    vector,
                    CreatePositivePerformanceVector(rowCount, 3)),
                new MathBlockProgramPopulationTerminal(
                    "mixed-series-two",
                    vector,
                    CreatePositivePerformanceVector(rowCount, 11))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", vector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var norm = builder.Apply("vector.l2-norm", inputs: [candidate]);
        var program = builder.Output("sum", sum).Output("norm", norm).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [
                new MathBlockProgramPopulationObjective(
                    "sum",
                    "sum",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "norm",
                    "norm",
                    MathBlockProgramPopulationObjectiveDirection.Minimize)
            ]);
        return CreatePerformanceWaveDefinition(population, binding, rowCount);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateReductionHeavyPerformanceSearch(
        int rowCount)
    {
        var vector = MathBlockType.Vector(length: rowCount);
        var terminals = Enumerable.Range(0, 4)
            .Select(index => new MathBlockProgramPopulationTerminal(
                $"reduction-series-{index}",
                vector,
                CreatePerformanceVector(rowCount, index)))
            .ToArray();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("vector.absolute", 1, [vector], vector)],
                vector),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", vector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var mean = builder.Apply("vector.mean", inputs: [candidate]);
        var norm = builder.Apply("vector.l2-norm", inputs: [candidate]);
        var maximum = builder.Apply("vector.maximum", inputs: [candidate]);
        var program = builder
            .Output("sum", sum)
            .Output("mean", mean)
            .Output("norm", norm)
            .Output("maximum", maximum)
            .Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [
                new MathBlockProgramPopulationObjective(
                    "sum",
                    "sum",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "mean",
                    "mean",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "norm",
                    "norm",
                    MathBlockProgramPopulationObjectiveDirection.Minimize),
                new MathBlockProgramPopulationObjective(
                    "maximum",
                    "maximum",
                    MathBlockProgramPopulationObjectiveDirection.Minimize)
            ]);
        return CreatePerformanceWaveDefinition(population, binding, rowCount);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateDuplicateHeavyPerformanceSearch(
        int rowCount)
    {
        var vector = MathBlockType.Vector(length: rowCount);
        var value = CreatePerformanceVector(rowCount, 17);
        var terminals = Enumerable.Range(0, 4)
            .Select(index => new MathBlockProgramPopulationTerminal(
                $"duplicate-series-{index}",
                vector,
                value))
            .ToArray();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("vector.absolute", 1, [vector], vector)],
                vector),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", vector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var program = builder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return CreatePerformanceWaveDefinition(population, binding, rowCount);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateDynamicShapePerformanceSearch(
        int rowCount)
    {
        var scalar = MathBlockType.Scalar();
        var dynamicVector = MathBlockType.Vector();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.repeat",
                    1,
                    [scalar, scalar],
                    dynamicVector)],
                dynamicVector),
            [
                new MathBlockProgramPopulationTerminal(
                    "long-count",
                    scalar,
                    MathBlockValue.Scalar(rowCount / 2d)),
                new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d)),
                new MathBlockProgramPopulationTerminal("two", scalar, MathBlockValue.Scalar(2d)),
                new MathBlockProgramPopulationTerminal(
                    "short-count",
                    scalar,
                    MathBlockValue.Scalar(rowCount / 4d))
            ],
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 32);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", dynamicVector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var length = builder.Apply("vector.length", inputs: [candidate]);
        var program = builder.Output("sum", sum).Output("length", length).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [
                new MathBlockProgramPopulationObjective(
                    "sum",
                    "sum",
                    MathBlockProgramPopulationObjectiveDirection.Maximize),
                new MathBlockProgramPopulationObjective(
                    "length",
                    "length",
                    MathBlockProgramPopulationObjectiveDirection.Maximize)
            ]);
        return CreatePerformanceWaveDefinition(population, binding, rowCount);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateChronologicalPerformanceSearch(
        int rowCount)
    {
        var vector = MathBlockType.Vector(length: rowCount);
        var terminals = Enumerable.Range(0, 4)
            .Select(index => new MathBlockProgramPopulationTerminal(
                $"chronological-series-{index}",
                vector,
                CreatePerformanceVector(rowCount, index + 29)))
            .ToArray();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation(
                    "vector.cumulative-sum",
                    1,
                    [vector],
                    vector)],
                vector),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, rowCount)],
            proposalsPerCycle: 4,
            fingerprintCapacity: 8);
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var candidate = builder.Input("candidate", vector);
        var sum = builder.Apply("vector.sum", inputs: [candidate]);
        var program = builder.Output("sum", sum).Build();
        var binding = new MathBlockProgramPopulationObjectiveBinding(
            program,
            "candidate",
            new Dictionary<string, MathBlockValue>(),
            [new MathBlockProgramPopulationObjective(
                "sum",
                "sum",
                MathBlockProgramPopulationObjectiveDirection.Maximize)]);
        return CreatePerformanceWaveDefinition(population, binding, rowCount);
    }

    private static MathBlockProgramPopulationSearchDefinition CreatePerformanceWaveDefinition(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramPopulationObjectiveBinding binding,
        int rowCount,
        int trialCount = 4,
        int waveSize = 4)
    {
        var baseline = CreateDefinition(
            population,
            binding,
            maximumTrials: checked((ulong)trialCount),
            enumerationTrials: checked((ulong)trialCount),
            validity: new MathBlockProgramPopulationValidityPolicy(
                Enumerable.Repeat(int.MaxValue, rowCount)));
        return new MathBlockProgramPopulationSearchDefinition(
            baseline.Population,
            baseline.ObjectiveBinding,
            baseline.Evolution,
            baseline.Selection,
            baseline.QualityDiversity,
            baseline.Envelope,
            baseline.Validity,
            baseline.CompactResults,
            baseline.InitialPrograms,
            wavePolicy: new MathBlockProgramPopulationWavePolicy(waveSize, 1));
    }

    private static MathBlockValue CreatePerformanceVector(int rowCount, int seed) =>
        MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index =>
        {
            var magnitude = (double)(((index * 17 + seed * 43) % 251) + 1);
            return ((index + seed) & 1) == 0 ? magnitude : -magnitude;
        }));

    private static MathBlockValue CreatePositivePerformanceVector(int rowCount, int seed) =>
        MathBlockValue.Vector(Enumerable.Range(0, rowCount).Select(index =>
            (double)(((index * 19 + seed * 47) % 251) + 1)));

    private static (MathBlockProgramPopulationSearchCycleResult Result, TimeSpan Elapsed)
        ExecuteMeasuredCycle(MathBlocksCUDAProgramPopulationSearch compiled)
    {
        var timer = Stopwatch.StartNew();
        var result = compiled.ExecuteCycle();
        timer.Stop();
        return (result, timer.Elapsed);
    }

    private static void AssertResidentCycleContract(MathBlocksCUDAProgramPopulationSearch compiled)
    {
        Assert.Equal(1, compiled.GraphInstanceCount);
        Assert.Equal(1, compiled.ImmutableUploadCount);
        Assert.Equal(0, compiled.LaterImmutableUploadCount);
        Assert.Equal(1, compiled.GraphLaunchCount);
        Assert.Equal(1, compiled.SynchronizationCount);
        Assert.Equal(1, compiled.DownloadCount);
        Assert.Equal((long)compiled.CompactDownloadBytesPerCycle, compiled.DownloadedBytes);
        Assert.Equal(0, compiled.FullCandidateOutputDownloadCount);
        Assert.Equal(0, compiled.FullCandidateOutputBytes);
        Assert.Equal(0, compiled.CpuNodeDispatchCount);
    }

    private static void AssertArchiveFingerprintAuthority(
        MathBlockProgramPopulationSearchState state)
    {
        var structural = new HashSet<string>(StringComparer.Ordinal);
        var semantic = new HashSet<string>(StringComparer.Ordinal);
        foreach (var entry in state.SelectionEntries)
        {
            structural.Add(entry.StructuralFingerprint);
            semantic.Add(entry.SemanticFingerprint);
        }
        foreach (var entry in state.QualityDiversityEntries)
        {
            structural.Add(entry.StructuralFingerprint);
            semantic.Add(entry.SemanticFingerprint);
        }
        Assert.True(structural.SetEquals(state.StructuralFingerprints));
        Assert.True(semantic.SetEquals(state.SemanticFingerprints));
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
        ulong maximumTrials,
        int fingerprintCapacity,
        ulong? enumerationTrials = null,
        int mutationTrials = 0,
        int crossoverTrials = 0,
        int immigrantTrials = 0)
    {
        var scalar = MathBlockType.Scalar();
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("scalar.negate", 1, [scalar], scalar)],
                scalar),
            [
                new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d)),
                new MathBlockProgramPopulationTerminal("two", scalar, MathBlockValue.Scalar(2d))
            ],
            [],
            bands,
            proposalsPerCycle: 8,
            fingerprintCapacity);
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
            enumerationTrials ?? maximumTrials,
            new MathBlockProgramPopulationValidityPolicy([1]),
            mutationTrials: mutationTrials,
            crossoverTrials: crossoverTrials,
            immigrantTrials: immigrantTrials);
    }

    private static MathBlockProgramPopulationSearchDefinition CreateFingerprintCapacitySearch(
        int fingerprintCapacity,
        ulong maximumTrials,
        bool includeInitialPrograms)
    {
        var scalar = MathBlockType.Scalar();
        var terminals = new[]
        {
            new MathBlockProgramPopulationTerminal("one", scalar, MathBlockValue.Scalar(1d)),
            new MathBlockProgramPopulationTerminal("two", scalar, MathBlockValue.Scalar(2d))
        };
        var population = new MathBlockProgramPopulationDefinition(
            new MathBlockProgramPopulationGrammar(
                [new MathBlockProgramPopulationOperation("scalar.negate", 1, [scalar], scalar)],
                scalar),
            terminals,
            [],
            [new MathBlockProgramPopulationResourceBand(1, 1)],
            proposalsPerCycle: 3,
            fingerprintCapacity);
        var terminalNodes = terminals
            .Select((terminal, index) =>
                MathBlockProgramCandidateNode.Terminal(index, terminal.Identifier, terminal.Type))
            .ToArray();
        var initialPrograms = new[]
        {
            new MathBlockProgramStructure(
                0,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [.. terminalNodes, MathBlockProgramCandidateNode.Operation("scalar.negate", 1, scalar, 0)]),
            new MathBlockProgramStructure(
                1,
                null,
                MathBlockProgramPopulationTrialSource.Enumeration,
                [.. terminalNodes, MathBlockProgramCandidateNode.Operation("scalar.negate", 1, scalar, 1)])
        };
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
        return new MathBlockProgramPopulationSearchDefinition(
            population,
            binding,
            new MathBlockProgramPopulationEvolutionPolicy(
                maximumTrials,
                maximumTrials,
                0,
                0,
                0,
                149),
            new MathBlockProgramPopulationSelectionPolicy(4, 8),
            new MathBlockProgramPopulationQualityDiversityPolicy(
                "value",
                [new MathBlockProgramPopulationQualityDiversityDimension("value", -4, 4, 4)]),
            new MathBlockProgramPopulationSearchEnvelope(
                64 * 1024 * 1024,
                16 * 1024 * 1024),
            new MathBlockProgramPopulationValidityPolicy([1]),
            initialPrograms: includeInitialPrograms ? initialPrograms : []);
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

    private static string ArchiveIdentity(MathBlockProgramPopulationArchiveEntry entry) =>
        $"{entry.Program.TrialCursor}|{entry.Program.ProposalCursor}|{entry.Program.Source}|{entry.Age}|" +
        $"{entry.StructuralFingerprint}|{entry.SemanticFingerprint}|{entry.QualityDiversityCell}|" +
        string.Join(',', entry.Objectives.Select(BitConverter.DoubleToInt64Bits));

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

    private static int ReadScratchBytesPerNode(MathBlocksCUDAProgramPopulationSearch compiled)
    {
        var layout = typeof(MathBlocksCUDAProgramPopulationSearch)
            .GetField("layout", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(compiled)!;
        return (int)layout.GetType()
            .GetProperty("ScratchBytesPerNode", BindingFlags.Instance | BindingFlags.Public)!
            .GetValue(layout)!;
    }

    private static void SetDeviceFingerprintCapacityForFailureTest(
        MathBlocksCUDAProgramPopulationSearch compiled,
        int capacity) =>
        SetDeviceArenaInt32ForFailureTest(compiled, 40, capacity);

    private static void SetDeviceCandidateLaneCountForFailureTest(
        MathBlocksCUDAProgramPopulationSearch compiled,
        int candidateLaneCount) =>
        SetDeviceArenaInt32ForFailureTest(compiled, 352, candidateLaneCount);

    private static void SetDeviceFirstResourceBandMaximumForFailureTest(
        MathBlocksCUDAProgramPopulationSearch compiled,
        int maximumOutputElements)
    {
        var layout = typeof(MathBlocksCUDAProgramPopulationSearch)
            .GetField("layout", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(compiled)!;
        var bandOffset = (int)layout.GetType()
            .GetProperty("BandOffset", BindingFlags.Instance | BindingFlags.Public)!
            .GetValue(layout)!;
        SetDeviceArenaInt32ForFailureTest(
            compiled,
            checked(bandOffset + sizeof(int)),
            maximumOutputElements);
    }

    private static void SetDeviceArenaInt32ForFailureTest(
        MathBlocksCUDAProgramPopulationSearch compiled,
        int offset,
        int value)
    {
        var deviceArena = (ulong)typeof(MathBlocksCUDAProgramPopulationSearch)
            .GetField("deviceArena", BindingFlags.Instance | BindingFlags.NonPublic)!
            .GetValue(compiled)!;
        var cudaNative = typeof(MathBlocksCUDAProgramPopulationSearch).Assembly.GetType(
            "Supprocom.MathBlocks.Cuda.MathBlocksCudaNative",
            throwOnError: true)!;
        var copyMethod = cudaNative.GetMethod(
            "cuMemcpyHtoD",
            BindingFlags.Static | BindingFlags.NonPublic)!;
        var source = Marshal.AllocHGlobal(sizeof(int));
        try
        {
            Marshal.WriteInt32(source, value);
            var result = (int)copyMethod.Invoke(
                null,
                [
                    checked(deviceArena + (ulong)offset),
                    source,
                    new UIntPtr(sizeof(int))
                ])!;
            Assert.Equal(0, result);
        }
        finally
        {
            Marshal.FreeHGlobal(source);
        }
    }

    private static void RequireCuda() =>
        Assert.True(MathBlocksCUDAWorker.IsAvailable, "A CUDA device is required.");
}
