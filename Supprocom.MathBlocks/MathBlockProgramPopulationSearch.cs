using System.Buffers.Binary;
using System.Collections.ObjectModel;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

public enum MathBlockProgramPopulationObjectiveDirection
{
    Minimize,
    Maximize
}

public enum MathBlockProgramPopulationObjectiveSourceKind
{
    ProgramOutput,
    ExpandedOperationCount,
    MaximumLookback,
    DeterministicExecutionCost,
    Age
}

public static class MathBlockProgramPopulationIntrinsicObjectiveIdentities
{
    public const string ExpandedOperationCount = "program.expanded-operation-count@1";
    public const string MaximumLookback = "program.maximum-lookback@1";
    public const string DeterministicExecutionCost = "program.deterministic-execution-cost@1";
    public const string Age = "program.age@1";
}

public enum MathBlockProgramPopulationTrialSource
{
    Enumeration,
    Mutation,
    Crossover,
    RandomImmigrant
}

public enum MathBlockProgramPopulationTrialStatus
{
    Accepted,
    RejectedBySelection,
    StructuralDuplicate,
    SemanticDuplicate,
    InvalidType,
    InvalidValue,
    InsufficientParents
}

public enum MathBlockProgramPopulationExecutionMode
{
    SerialResident,
    ParallelResident
}

public sealed record MathBlockProgramPopulationExecutionOptions
{
    public MathBlockProgramPopulationExecutionOptions(
        MathBlockProgramPopulationExecutionMode mode,
        int candidateLaneCount)
    {
        if (!Enum.IsDefined(mode))
            throw new ArgumentOutOfRangeException(nameof(mode));
        if (candidateLaneCount <= 0)
            throw new ArgumentOutOfRangeException(nameof(candidateLaneCount));
        Mode = mode;
        CandidateLaneCount = candidateLaneCount;
    }

    public MathBlockProgramPopulationExecutionMode Mode { get; }
    public int CandidateLaneCount { get; }

    public static MathBlockProgramPopulationExecutionOptions SerialResident { get; } =
        new(MathBlockProgramPopulationExecutionMode.SerialResident, 1);

    internal void ValidateResidentExecution(string parameterName)
    {
        if (Mode == MathBlockProgramPopulationExecutionMode.SerialResident && CandidateLaneCount != 1)
        {
            throw new ArgumentOutOfRangeException(
                parameterName,
                "Serial resident execution requires one candidate lane.");
        }
    }
}

public sealed record MathBlockProgramPopulationWavePolicy
{
    public MathBlockProgramPopulationWavePolicy(int proposalWaveSize, int wavesPerCycle)
    {
        if (proposalWaveSize <= 0)
            throw new ArgumentOutOfRangeException(nameof(proposalWaveSize));
        if (wavesPerCycle <= 0)
            throw new ArgumentOutOfRangeException(nameof(wavesPerCycle));
        ProposalWaveSize = proposalWaveSize;
        WavesPerCycle = wavesPerCycle;
        MaximumTrialResultsPerCycle = checked(proposalWaveSize * wavesPerCycle);
    }

    public int ProposalWaveSize { get; }
    public int WavesPerCycle { get; }
    public int MaximumTrialResultsPerCycle { get; }
}

public readonly record struct MathBlockProgramPopulationObjective
{
    public MathBlockProgramPopulationObjective(
        string name,
        string programOutput,
        MathBlockProgramPopulationObjectiveDirection direction)
    {
        Name = MathBlockProgramPopulationValidation.RequireName(name, nameof(name));
        ProgramOutput = MathBlockProgramPopulationValidation.RequireName(programOutput, nameof(programOutput));
        if (!Enum.IsDefined(direction))
            throw new ArgumentOutOfRangeException(nameof(direction));
        Direction = direction;
        SourceKind = MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput;
        SourceIdentity = $"program.output.{ProgramOutput}@1";
    }

    private MathBlockProgramPopulationObjective(
        string name,
        MathBlockProgramPopulationObjectiveSourceKind sourceKind,
        string sourceIdentity,
        MathBlockProgramPopulationObjectiveDirection direction)
    {
        Name = MathBlockProgramPopulationValidation.RequireName(name, nameof(name));
        if (sourceKind == MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput || !Enum.IsDefined(sourceKind))
            throw new ArgumentOutOfRangeException(nameof(sourceKind));
        SourceIdentity = RequireIntrinsicIdentity(sourceKind, sourceIdentity);
        if (!Enum.IsDefined(direction))
            throw new ArgumentOutOfRangeException(nameof(direction));
        SourceKind = sourceKind;
        ProgramOutput = null;
        Direction = direction;
    }

    public string Name { get; }
    public string? ProgramOutput { get; }
    public MathBlockProgramPopulationObjectiveSourceKind SourceKind { get; }
    public string SourceIdentity { get; }
    public MathBlockProgramPopulationObjectiveDirection Direction { get; }

    public static MathBlockProgramPopulationObjective Intrinsic(
        string name,
        string sourceIdentity,
        MathBlockProgramPopulationObjectiveDirection direction)
    {
        var sourceKind = sourceIdentity switch
        {
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount =>
                MathBlockProgramPopulationObjectiveSourceKind.ExpandedOperationCount,
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.MaximumLookback =>
                MathBlockProgramPopulationObjectiveSourceKind.MaximumLookback,
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.DeterministicExecutionCost =>
                MathBlockProgramPopulationObjectiveSourceKind.DeterministicExecutionCost,
            MathBlockProgramPopulationIntrinsicObjectiveIdentities.Age =>
                MathBlockProgramPopulationObjectiveSourceKind.Age,
            _ => throw new ArgumentException("The intrinsic objective identity is unsupported.", nameof(sourceIdentity))
        };
        return new MathBlockProgramPopulationObjective(name, sourceKind, sourceIdentity, direction);
    }

    private static string RequireIntrinsicIdentity(
        MathBlockProgramPopulationObjectiveSourceKind sourceKind,
        string sourceIdentity)
    {
        var expected = sourceKind switch
        {
            MathBlockProgramPopulationObjectiveSourceKind.ExpandedOperationCount =>
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.ExpandedOperationCount,
            MathBlockProgramPopulationObjectiveSourceKind.MaximumLookback =>
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.MaximumLookback,
            MathBlockProgramPopulationObjectiveSourceKind.DeterministicExecutionCost =>
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.DeterministicExecutionCost,
            MathBlockProgramPopulationObjectiveSourceKind.Age =>
                MathBlockProgramPopulationIntrinsicObjectiveIdentities.Age,
            _ => throw new ArgumentOutOfRangeException(nameof(sourceKind))
        };
        return string.Equals(sourceIdentity, expected, StringComparison.Ordinal)
            ? expected
            : throw new ArgumentException("The intrinsic objective identity is incompatible.", nameof(sourceIdentity));
    }
}

public sealed class MathBlockProgramPopulationObjectiveBinding
{
    private readonly IReadOnlyDictionary<string, MathBlockValue> residentInputs;

    public MathBlockProgramPopulationObjectiveBinding(
        MathBlockProgram program,
        string candidateInput,
        IReadOnlyDictionary<string, MathBlockValue> residentInputs,
        IEnumerable<MathBlockProgramPopulationObjective> objectives,
        string? candidateValidityMaskInput = null)
    {
        Program = program ?? throw new ArgumentNullException(nameof(program));
        CandidateInput = MathBlockProgramPopulationValidation.RequireName(candidateInput, nameof(candidateInput));
        ArgumentNullException.ThrowIfNull(residentInputs);
        ArgumentNullException.ThrowIfNull(objectives);
        if (!program.Inputs.ContainsKey(CandidateInput))
            throw new ArgumentException("The objective program has no candidate input.", nameof(candidateInput));
        if (candidateValidityMaskInput is not null)
        {
            candidateValidityMaskInput = MathBlockProgramPopulationValidation.RequireName(
                candidateValidityMaskInput,
                nameof(candidateValidityMaskInput));
            if (string.Equals(candidateValidityMaskInput, CandidateInput, StringComparison.Ordinal) ||
                !program.Inputs.TryGetValue(candidateValidityMaskInput, out var maskType) ||
                maskType.Kind != MathBlockValueKind.BooleanVector)
            {
                throw new ArgumentException("The candidate validity-mask input is incompatible.", nameof(candidateValidityMaskInput));
            }
        }

        var copiedInputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
        foreach (var input in residentInputs)
        {
            if (string.Equals(input.Key, CandidateInput, StringComparison.Ordinal))
                throw new ArgumentException("The candidate input cannot have a resident binding.", nameof(residentInputs));
            if (string.Equals(input.Key, candidateValidityMaskInput, StringComparison.Ordinal))
                throw new ArgumentException("The validity-mask input cannot have a resident binding.", nameof(residentInputs));
            if (!program.Inputs.TryGetValue(input.Key, out var requiredType))
                throw new ArgumentException("A resident binding is not a program input.", nameof(residentInputs));
            if (!input.Value.IsValid || !requiredType.Accepts(input.Value.Type))
                throw new ArgumentException("A resident binding has an incompatible value.", nameof(residentInputs));
            MathBlockProgramPopulationValidation.RequireFiniteValue(input.Value, nameof(residentInputs));
            copiedInputs.Add(input.Key, input.Value);
        }
        foreach (var input in program.Inputs)
        {
            if (string.Equals(input.Key, CandidateInput, StringComparison.Ordinal))
                continue;
            if (string.Equals(input.Key, candidateValidityMaskInput, StringComparison.Ordinal))
                continue;
            if (!copiedInputs.ContainsKey(input.Key))
                throw new ArgumentException("An objective program input has no resident binding.", nameof(residentInputs));
        }

        var copiedObjectives = MathBlockCollectionPrimitives.CopyEnumerable(objectives);
        if (copiedObjectives.Length == 0)
            throw new ArgumentException("An objective binding requires an objective.", nameof(objectives));
        var names = new HashSet<string>(StringComparer.Ordinal);
        foreach (var objective in copiedObjectives)
        {
            if (!names.Add(objective.Name))
                throw new ArgumentException("An objective name is duplicated.", nameof(objectives));
            if (objective.SourceKind != MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput)
                continue;
            if (!program.Outputs.TryGetValue(objective.ProgramOutput!, out var outputType))
                throw new ArgumentException("An objective output is not a program output.", nameof(objectives));
            if (outputType.Kind != MathBlockValueKind.Scalar)
                throw new ArgumentException("An objective output must be a numeric scalar.", nameof(objectives));
        }

        this.residentInputs = new ReadOnlyDictionary<string, MathBlockValue>(copiedInputs);
        Objectives = Array.AsReadOnly(copiedObjectives);
        CandidateValidityMaskInput = candidateValidityMaskInput;
    }

    public MathBlockProgram Program { get; }
    public string CandidateInput { get; }
    public string? CandidateValidityMaskInput { get; }
    public IReadOnlyDictionary<string, MathBlockValue> ResidentInputs => residentInputs;
    public IReadOnlyList<MathBlockProgramPopulationObjective> Objectives { get; }

    internal double[] EvaluateProgramOutputs(
        MathBlockValue candidateOutput,
        MathBlockValue? candidateValidityMask)
    {
        if (!candidateOutput.IsValid)
            throw new ArgumentException("The candidate output must be valid.", nameof(candidateOutput));
        var candidateType = Program.Inputs[CandidateInput];
        if (!candidateType.Accepts(candidateOutput.Type))
            throw new ArgumentException("The candidate output has an incompatible type.", nameof(candidateOutput));
        var inputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal)
        {
            [CandidateInput] = candidateOutput
        };
        if (CandidateValidityMaskInput is not null)
        {
            if (!candidateValidityMask.HasValue || !candidateValidityMask.Value.IsValid)
                throw new ArgumentException("The candidate validity mask is required.", nameof(candidateValidityMask));
            inputs.Add(CandidateValidityMaskInput, candidateValidityMask.Value);
        }
        foreach (var input in residentInputs)
            inputs.Add(input.Key, input.Value);
        var outputs = Program.Evaluate(inputs);
        var values = new double[Objectives.Count];
        for (var index = 0; index < values.Length; index++)
        {
            if (Objectives[index].SourceKind != MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput)
                continue;
            values[index] = outputs[Objectives[index].ProgramOutput!].AsScalar();
            if (!Math.IsFinite(values[index]))
                throw new InvalidOperationException("An objective program produced a nonfinite value.");
        }
        return values;
    }
}

public sealed class MathBlockProgramPopulationEvolutionPolicy
{
    public MathBlockProgramPopulationEvolutionPolicy(
        ulong maximumTrialCount,
        ulong enumerationProposalCount,
        int mutationTrials,
        int crossoverTrials,
        int randomImmigrantTrials,
        ulong randomSeed,
        ulong randomSequence = 0)
    {
        if (maximumTrialCount == 0)
            throw new ArgumentOutOfRangeException(nameof(maximumTrialCount));
        if (enumerationProposalCount > maximumTrialCount)
            throw new ArgumentOutOfRangeException(nameof(enumerationProposalCount));
        if (mutationTrials < 0 || crossoverTrials < 0 || randomImmigrantTrials < 0)
            throw new ArgumentOutOfRangeException(nameof(mutationTrials));
        _ = checked(mutationTrials + crossoverTrials + randomImmigrantTrials);
        MaximumTrialCount = maximumTrialCount;
        EnumerationProposalCount = enumerationProposalCount;
        MutationTrials = mutationTrials;
        CrossoverTrials = crossoverTrials;
        RandomImmigrantTrials = randomImmigrantTrials;
        RandomSeed = randomSeed;
        RandomSequence = randomSequence;
    }

    public ulong MaximumTrialCount { get; }
    public ulong EnumerationProposalCount { get; }
    public int MutationTrials { get; }
    public int CrossoverTrials { get; }
    public int RandomImmigrantTrials { get; }
    public ulong RandomSeed { get; }
    public ulong RandomSequence { get; }
    public int EvolutionPatternLength => checked(MutationTrials + CrossoverTrials + RandomImmigrantTrials);
}

public sealed class MathBlockProgramPopulationSelectionPolicy
{
    public MathBlockProgramPopulationSelectionPolicy(int paretoCapacity, int maximumAge)
    {
        if (paretoCapacity <= 0)
            throw new ArgumentOutOfRangeException(nameof(paretoCapacity));
        if (maximumAge <= 0)
            throw new ArgumentOutOfRangeException(nameof(maximumAge));
        ParetoCapacity = paretoCapacity;
        MaximumAge = maximumAge;
    }

    public int ParetoCapacity { get; }
    public int MaximumAge { get; }
}

public readonly record struct MathBlockProgramPopulationQualityDiversityDimension
{
    public MathBlockProgramPopulationQualityDiversityDimension(
        string objective,
        double minimum,
        double maximum,
        int binCount)
    {
        Objective = MathBlockProgramPopulationValidation.RequireName(objective, nameof(objective));
        if (!Math.IsFinite(minimum) || !Math.IsFinite(maximum) || minimum >= maximum)
            throw new ArgumentOutOfRangeException(nameof(minimum));
        if (binCount <= 1)
            throw new ArgumentOutOfRangeException(nameof(binCount));
        Minimum = minimum;
        Maximum = maximum;
        BinCount = binCount;
    }

    public string Objective { get; }
    public double Minimum { get; }
    public double Maximum { get; }
    public int BinCount { get; }
}

public sealed class MathBlockProgramPopulationQualityDiversityPolicy
{
    public MathBlockProgramPopulationQualityDiversityPolicy(
        string qualityObjective,
        IEnumerable<MathBlockProgramPopulationQualityDiversityDimension> dimensions)
    {
        QualityObjective = MathBlockProgramPopulationValidation.RequireName(
            qualityObjective,
            nameof(qualityObjective));
        ArgumentNullException.ThrowIfNull(dimensions);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(dimensions);
        if (copied.Length == 0)
            throw new ArgumentException("A quality-diversity policy requires a dimension.", nameof(dimensions));
        var names = new HashSet<string>(StringComparer.Ordinal);
        var cellCount = 1;
        foreach (var dimension in copied)
        {
            if (!names.Add(dimension.Objective))
                throw new ArgumentException("A quality-diversity dimension is duplicated.", nameof(dimensions));
            cellCount = checked(cellCount * dimension.BinCount);
        }
        Dimensions = Array.AsReadOnly(copied);
        CellCount = cellCount;
    }

    public string QualityObjective { get; }
    public IReadOnlyList<MathBlockProgramPopulationQualityDiversityDimension> Dimensions { get; }
    public int CellCount { get; }
}

public sealed class MathBlockProgramPopulationCompactResultPolicy
{
    public MathBlockProgramPopulationCompactResultPolicy(bool includeRejectedTrials = true) =>
        IncludeRejectedTrials = includeRejectedTrials;

    public bool IncludeRejectedTrials { get; }
}

public sealed class MathBlockProgramPopulationSearchEnvelope
{
    public MathBlockProgramPopulationSearchEnvelope(
        long maximumResidentBytes,
        int maximumCompactDownloadBytes)
    {
        if (maximumResidentBytes <= 0)
            throw new ArgumentOutOfRangeException(nameof(maximumResidentBytes));
        if (maximumCompactDownloadBytes <= 0)
            throw new ArgumentOutOfRangeException(nameof(maximumCompactDownloadBytes));
        MaximumResidentBytes = maximumResidentBytes;
        MaximumCompactDownloadBytes = maximumCompactDownloadBytes;
    }

    public long MaximumResidentBytes { get; }
    public int MaximumCompactDownloadBytes { get; }
}

public sealed class MathBlockProgramPopulationEnumerationCatalog
{
    public MathBlockProgramPopulationEnumerationCatalog(
        ulong cursorStart,
        IEnumerable<MathBlockProgramStructure> programs)
    {
        ArgumentNullException.ThrowIfNull(programs);
        var supplied = MathBlockCollectionPrimitives.CopyEnumerable(programs);
        if (supplied.Length == 0)
            throw new ArgumentException("An enumeration catalog requires a program.", nameof(programs));
        var normalized = new MathBlockProgramStructure[supplied.Length];
        var fingerprints = new HashSet<string>(StringComparer.Ordinal);
        for (var index = 0; index < supplied.Length; index++)
        {
            var program = supplied[index] ??
                throw new ArgumentException("An enumeration catalog program is null.", nameof(programs));
            if (program.Source != MathBlockProgramPopulationTrialSource.Enumeration)
                throw new ArgumentException("An enumeration catalog program has an invalid source.", nameof(programs));
            var proposalCursor = checked(cursorStart + (ulong)index);
            if (program.ProposalCursor.HasValue && program.ProposalCursor.Value != proposalCursor)
            {
                throw new ArgumentException(
                    "An enumeration catalog program has an incompatible proposal cursor.",
                    nameof(programs));
            }
            normalized[index] = new MathBlockProgramStructure(
                0,
                proposalCursor,
                MathBlockProgramPopulationTrialSource.Enumeration,
                program.Nodes);
            if (!fingerprints.Add(normalized[index].StructuralFingerprint))
            {
                throw new ArgumentException(
                    "An enumeration catalog contains a duplicate program structure.",
                    nameof(programs));
            }
        }
        CursorStart = cursorStart;
        CursorEndExclusive = checked(cursorStart + (ulong)normalized.Length);
        Programs = Array.AsReadOnly(normalized);
        Identity = MathBlockProgramPopulationSearchSerialization.CreateEnumerationCatalogIdentity(this);
    }

    public ulong CursorStart { get; }
    public ulong CursorEndExclusive { get; }
    public IReadOnlyList<MathBlockProgramStructure> Programs { get; }
    public string Identity { get; }
}

public sealed class MathBlockProgramPopulationValidityPolicy
{
    private readonly int[] historyCounts;

    public MathBlockProgramPopulationValidityPolicy(IEnumerable<int> historyCounts)
    {
        ArgumentNullException.ThrowIfNull(historyCounts);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(historyCounts);
        if (copied.Length == 0)
            throw new ArgumentException("A validity policy requires history counts.", nameof(historyCounts));
        for (var index = 0; index < copied.Length; index++)
            if (copied[index] < 0)
                throw new ArgumentOutOfRangeException(nameof(historyCounts));
        this.historyCounts = copied;
        HistoryCounts = Array.AsReadOnly(copied);
    }

    public IReadOnlyList<int> HistoryCounts { get; }

    public IReadOnlyList<bool> CreateMask(int rowCount, int maximumLookback)
    {
        if (rowCount < 0 || rowCount > historyCounts.Length)
            throw new ArgumentOutOfRangeException(nameof(rowCount));
        if (maximumLookback < 0)
            throw new ArgumentOutOfRangeException(nameof(maximumLookback));
        var result = new bool[rowCount];
        for (var index = 0; index < result.Length; index++)
            result[index] = historyCounts[index] >= maximumLookback;
        return Array.AsReadOnly(result);
    }
}

public readonly record struct MathBlockProgramPopulationSearchCapacity(
    int GrammarOperationCount,
    int TerminalCount,
    int MaximumArity,
    int MaximumExpandedOperationCount,
    int MaximumValueElements,
    int ObjectiveCount,
    int ObjectiveProgramNodeCount,
    int ParetoCapacity,
    int QualityDiversityCellCount,
    long SharedResidentBytes,
    int LaneStrideBytes,
    int CandidateLaneCount,
    long WorkingResidentBytes,
    int ProposalWaveSlotCount,
    long ProposalWaveSlotBytes,
    long PeakResidentBytes,
    long ResidentBytes,
    int CompactDownloadBytes);

public sealed class MathBlockProgramPopulationSearchDefinition
{
    public MathBlockProgramPopulationSearchDefinition(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramPopulationObjectiveBinding objectiveBinding,
        MathBlockProgramPopulationEvolutionPolicy evolution,
        MathBlockProgramPopulationSelectionPolicy selection,
        MathBlockProgramPopulationQualityDiversityPolicy qualityDiversity,
        MathBlockProgramPopulationSearchEnvelope envelope,
        MathBlockProgramPopulationValidityPolicy validity,
        MathBlockProgramPopulationCompactResultPolicy? compactResults = null,
        IEnumerable<MathBlockProgramStructure>? initialPrograms = null,
        MathBlockProgramPopulationSearchState? acceptedState = null,
        MathBlockProgramPopulationWavePolicy? wavePolicy = null,
        MathBlockProgramPopulationEnumerationCatalog? enumerationCatalog = null)
    {
        Population = population ?? throw new ArgumentNullException(nameof(population));
        ObjectiveBinding = objectiveBinding ?? throw new ArgumentNullException(nameof(objectiveBinding));
        Evolution = evolution ?? throw new ArgumentNullException(nameof(evolution));
        Selection = selection ?? throw new ArgumentNullException(nameof(selection));
        QualityDiversity = qualityDiversity ?? throw new ArgumentNullException(nameof(qualityDiversity));
        Envelope = envelope ?? throw new ArgumentNullException(nameof(envelope));
        Validity = validity ?? throw new ArgumentNullException(nameof(validity));
        CompactResults = compactResults ?? new MathBlockProgramPopulationCompactResultPolicy();
        WavePolicy = wavePolicy ?? new MathBlockProgramPopulationWavePolicy(
            1,
            population.ProposalsPerCycle);
        EnumerationCatalog = enumerationCatalog;
        if (population.AcceptedState is not null)
            throw new ArgumentException("A search definition cannot use an enumeration checkpoint.", nameof(population));
        var candidateType = objectiveBinding.Program.Inputs[objectiveBinding.CandidateInput];
        if (!candidateType.Accepts(population.Grammar.OutputType))
            throw new ArgumentException("The objective candidate input has an incompatible type.", nameof(objectiveBinding));
        if (evolution.EnumerationProposalCount > EnumerationCursorLimit)
            throw new ArgumentOutOfRangeException(nameof(evolution));
        if (enumerationCatalog is not null &&
            evolution.EnumerationProposalCount != (ulong)enumerationCatalog.Programs.Count)
        {
            throw new ArgumentException(
                "The enumeration proposal count must equal the explicit catalog count.",
                nameof(evolution));
        }
        if (enumerationCatalog is not null &&
            evolution.MaximumTrialCount < enumerationCatalog.CursorEndExclusive)
        {
            throw new ArgumentOutOfRangeException(
                nameof(evolution),
                "The maximum trial cursor does not contain the enumeration catalog range.");
        }
        if (enumerationCatalog is not null &&
            evolution.EvolutionPatternLength == 0 &&
            evolution.MaximumTrialCount != enumerationCatalog.CursorEndExclusive)
        {
            throw new ArgumentException(
                "Enumeration-only search must end at the catalog cursor boundary.",
                nameof(evolution));
        }
        if (enumerationCatalog is null &&
            evolution.MaximumTrialCount > evolution.EnumerationProposalCount &&
            evolution.EvolutionPatternLength == 0)
        {
            throw new ArgumentException("Evolution trials require an enabled proposal source.", nameof(evolution));
        }
        var qualityIndex = FindObjective(objectiveBinding.Objectives, qualityDiversity.QualityObjective);
        if (qualityIndex < 0)
            throw new ArgumentException("The quality objective is not defined.", nameof(qualityDiversity));
        var dimensionIndexes = new int[qualityDiversity.Dimensions.Count];
        for (var index = 0; index < dimensionIndexes.Length; index++)
        {
            dimensionIndexes[index] = FindObjective(
                objectiveBinding.Objectives,
                qualityDiversity.Dimensions[index].Objective);
            if (dimensionIndexes[index] < 0)
                throw new ArgumentException("A quality-diversity objective is not defined.", nameof(qualityDiversity));
        }
        QualityObjectiveIndex = qualityIndex;
        QualityDiversityObjectiveIndexes = Array.AsReadOnly(dimensionIndexes);
        var initial = initialPrograms is null
            ? []
            : MathBlockCollectionPrimitives.CopyEnumerable(initialPrograms);
        for (var index = 0; index < initial.Length; index++)
        {
            ArgumentNullException.ThrowIfNull(initial[index]);
            RequireProgramCapacity(initial[index]);
            _ = Population.Evaluate(initial[index]);
        }
        InitialPrograms = Array.AsReadOnly(initial);
        if (enumerationCatalog is not null)
        {
            var initialFingerprints = new HashSet<string>(StringComparer.Ordinal);
            foreach (var program in initial)
                initialFingerprints.Add(program.StructuralFingerprint);
            foreach (var program in enumerationCatalog.Programs)
            {
                RequireProgramCapacity(program);
                Population.ValidateResidentStructure(program);
                if (initialFingerprints.Contains(program.StructuralFingerprint))
                {
                    throw new ArgumentException(
                        "The enumeration catalog overlaps an initial program.",
                        nameof(enumerationCatalog));
                }
            }
        }
        Identity = MathBlockProgramPopulationSearchSerialization.CreateIdentity(this);
        if (acceptedState is not null)
            ValidateState(acceptedState);
        RequireFingerprintCapacity(acceptedState);
        AcceptedState = acceptedState;
    }

    public MathBlockProgramPopulationDefinition Population { get; }
    public MathBlockProgramPopulationObjectiveBinding ObjectiveBinding { get; }
    public MathBlockProgramPopulationEvolutionPolicy Evolution { get; }
    public MathBlockProgramPopulationSelectionPolicy Selection { get; }
    public MathBlockProgramPopulationQualityDiversityPolicy QualityDiversity { get; }
    public MathBlockProgramPopulationSearchEnvelope Envelope { get; }
    public MathBlockProgramPopulationValidityPolicy Validity { get; }
    public MathBlockProgramPopulationCompactResultPolicy CompactResults { get; }
    public MathBlockProgramPopulationWavePolicy WavePolicy { get; }
    public MathBlockProgramPopulationEnumerationCatalog? EnumerationCatalog { get; }
    public IReadOnlyList<MathBlockProgramStructure> InitialPrograms { get; }
    public string Identity { get; }
    public MathBlockProgramPopulationSearchState? AcceptedState { get; }
    internal int QualityObjectiveIndex { get; }
    internal IReadOnlyList<int> QualityDiversityObjectiveIndexes { get; }
    internal ulong EnumerationCursorLimit => EnumerationCatalog is null
        ? Population.TotalProposalCount
        : (ulong)EnumerationCatalog.Programs.Count;
    internal ulong InitialTrialCursor => EnumerationCatalog?.CursorStart ?? 0;

    public IReadOnlyList<double> EvaluateObjectives(MathBlockProgramStructure program, int age = 0)
    {
        ArgumentNullException.ThrowIfNull(program);
        if (age < 0)
            throw new ArgumentOutOfRangeException(nameof(age));
        var operationCount = 0;
        long deterministicCost = 0;
        var lookbacks = new int[program.Nodes.Count];
        for (var nodeIndex = 0; nodeIndex < program.Nodes.Count; nodeIndex++)
        {
            var node = program.Nodes[nodeIndex];
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                if ((uint)node.TerminalIndex >= (uint)Population.AllTerminals.Count)
                    throw new InvalidOperationException("A program terminal is outside the population.");
                lookbacks[nodeIndex] = Population.AllTerminals[node.TerminalIndex].Lookback;
                continue;
            }
            operationCount++;
            var maximumLookback = 0;
            foreach (var operand in node.OperandIndexes)
                if (lookbacks[operand] > maximumLookback)
                    maximumLookback = lookbacks[operand];
            lookbacks[nodeIndex] = maximumLookback;
            deterministicCost = checked(
                deterministicCost + FindOperation(node, program.Nodes).DeterministicCost);
        }
        var output = Population.Evaluate(program);
        MathBlockValue? validityMask = null;
        if (ObjectiveBinding.CandidateValidityMaskInput is not null)
        {
            var rowCount = GetValidityRowCount(output);
            var mask = Validity.CreateMask(rowCount, lookbacks[^1]);
            validityMask = MathBlockValue.BooleanVector(mask);
        }
        var values = ObjectiveBinding.EvaluateProgramOutputs(output, validityMask);
        for (var index = 0; index < ObjectiveBinding.Objectives.Count; index++)
        {
            values[index] = ObjectiveBinding.Objectives[index].SourceKind switch
            {
                MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput => values[index],
                MathBlockProgramPopulationObjectiveSourceKind.ExpandedOperationCount => operationCount,
                MathBlockProgramPopulationObjectiveSourceKind.MaximumLookback => lookbacks[^1],
                MathBlockProgramPopulationObjectiveSourceKind.DeterministicExecutionCost => deterministicCost,
                MathBlockProgramPopulationObjectiveSourceKind.Age => age,
                _ => throw new InvalidOperationException("An objective source is unsupported.")
            };
        }
        return Array.AsReadOnly(values);
    }

    public string CreateSemanticFingerprint(MathBlockProgramStructure program)
    {
        ArgumentNullException.ThrowIfNull(program);
        var lookbacks = new int[program.Nodes.Count];
        for (var nodeIndex = 0; nodeIndex < program.Nodes.Count; nodeIndex++)
        {
            var node = program.Nodes[nodeIndex];
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                if ((uint)node.TerminalIndex >= (uint)Population.AllTerminals.Count)
                    throw new InvalidOperationException("A program terminal is outside the population.");
                lookbacks[nodeIndex] = Population.AllTerminals[node.TerminalIndex].Lookback;
                continue;
            }
            var maximum = 0;
            foreach (var operand in node.OperandIndexes)
                maximum = Math.Max(maximum, lookbacks[operand]);
            lookbacks[nodeIndex] = maximum;
        }
        var output = Population.Evaluate(program);
        var mask = Validity.CreateMask(GetValidityRowCount(output), lookbacks[^1]);
        return MathBlockProgramPopulationFingerprint.CreateSemantic(output, mask, lookbacks[^1]);
    }

    public MathBlockProgramPopulationSearchState CreateTransitionState(
        MathBlockProgramPopulationSearchDefinition previousDefinition,
        MathBlockProgramPopulationSearchState previousState)
    {
        ArgumentNullException.ThrowIfNull(previousDefinition);
        ArgumentNullException.ThrowIfNull(previousState);
        if (!string.Equals(previousState.Identity, previousDefinition.Identity, StringComparison.Ordinal))
            throw new InvalidOperationException("The previous state does not match its search definition.");
        ValidateTransition(previousDefinition, previousState);

        if (previousDefinition.EnumerationCatalog is not null && EnumerationCatalog is not null)
            return CreateCatalogTransitionState(previousDefinition, previousState);

        var refreshPrograms = new Dictionary<string, MathBlockProgramStructure>(StringComparer.Ordinal);
        foreach (var entry in previousState.SelectionEntries)
            AddRefreshProgram(refreshPrograms, previousDefinition.Population, entry.Program);
        foreach (var entry in previousState.QualityDiversityEntries)
            AddRefreshProgram(refreshPrograms, previousDefinition.Population, entry.Program);
        foreach (var program in previousState.RefreshPrograms)
            AddRefreshProgram(refreshPrograms, previousDefinition.Population, program);
        foreach (var program in InitialPrograms)
            refreshPrograms.TryAdd(program.StructuralFingerprint, program);

        var preserveEnumerationCursor = HasStableEnumerationPrefix(previousDefinition, this);
        var preserveSemanticFingerprints = preserveEnumerationCursor &&
            HaveEqualHistoryCounts(
                previousDefinition.Validity.HistoryCounts,
                Validity.HistoryCounts);
        var transition = new MathBlockProgramPopulationSearchState(
            Identity,
            preserveEnumerationCursor ? previousState.EnumerationCursor : 0,
            preserveEnumerationCursor ? previousState.EnumerationTrialCount : 0,
            previousState.TrialCursor,
            previousState.CycleCount,
            previousState.WaveCursor,
            checked(previousState.EnvelopeGeneration + 1),
            0,
            previousState.RandomState,
            previousState.StructuralDuplicateCount,
            previousState.SemanticDuplicateCount,
            previousState.EvaluatedProgramCount,
            previousState.AcceptedProgramCount,
            preserveEnumerationCursor ? previousState.StructuralFingerprints : [],
            preserveSemanticFingerprints ? previousState.SemanticFingerprints : [],
            [],
            [],
            refreshPrograms.Values);
        RequireCatalogDoesNotOverlap(refreshPrograms.Values);
        ValidateState(transition);
        RequireFingerprintCapacity(transition);
        return transition;
    }

    private MathBlockProgramPopulationSearchState CreateCatalogTransitionState(
        MathBlockProgramPopulationSearchDefinition previousDefinition,
        MathBlockProgramPopulationSearchState previousState)
    {
        var previousCatalog = previousDefinition.EnumerationCatalog!;
        var currentCatalog = EnumerationCatalog!;
        if (previousState.TrialCursor != currentCatalog.CursorStart ||
            previousState.TrialCursor != previousCatalog.CursorEndExclusive ||
            previousState.TrialCursor != previousDefinition.Evolution.MaximumTrialCount ||
            previousState.EnumerationCursor != previousDefinition.EnumerationCursorLimit ||
            previousState.EnumerationTrialCount != previousDefinition.Evolution.EnumerationProposalCount ||
            previousState.RefreshCursor != previousState.RefreshPrograms.Count)
        {
            throw new InvalidOperationException("The prior enumeration catalog is not complete at the transition cursor.");
        }
        RequireArchivePreservationCompatibility(previousDefinition, previousState);
        var preservedSelection = NormalizeArchiveEntries(
            previousDefinition.Population,
            previousState.SelectionEntries);
        var preservedQuality = NormalizeArchiveEntries(
            previousDefinition.Population,
            previousState.QualityDiversityEntries);
        var preservedFingerprints = new HashSet<string>(StringComparer.Ordinal);
        var preservedSemanticFingerprints = new HashSet<string>(StringComparer.Ordinal);
        foreach (var entry in preservedSelection)
        {
            preservedFingerprints.Add(entry.Program.StructuralFingerprint);
            preservedSemanticFingerprints.Add(entry.SemanticFingerprint);
        }
        foreach (var entry in preservedQuality)
        {
            preservedFingerprints.Add(entry.Program.StructuralFingerprint);
            preservedSemanticFingerprints.Add(entry.SemanticFingerprint);
        }
        foreach (var program in currentCatalog.Programs)
        {
            if (preservedFingerprints.Contains(program.StructuralFingerprint))
            {
                throw new InvalidOperationException(
                    "The enumeration catalog overlaps a preserved archive program.");
            }
        }
        var refreshPrograms = new Dictionary<string, MathBlockProgramStructure>(StringComparer.Ordinal);
        foreach (var program in InitialPrograms)
        {
            if (preservedFingerprints.Contains(program.StructuralFingerprint))
            {
                throw new InvalidOperationException(
                    "An initial program overlaps a preserved archive program.");
            }
            refreshPrograms.TryAdd(program.StructuralFingerprint, program);
        }
        RequireCatalogDoesNotOverlap(refreshPrograms.Values);
        var transition = new MathBlockProgramPopulationSearchState(
            Identity,
            0,
            0,
            previousState.TrialCursor,
            previousState.CycleCount,
            previousState.WaveCursor,
            checked(previousState.EnvelopeGeneration + 1),
            0,
            previousState.RandomState,
            previousState.StructuralDuplicateCount,
            previousState.SemanticDuplicateCount,
            previousState.EvaluatedProgramCount,
            previousState.AcceptedProgramCount,
            preservedFingerprints,
            preservedSemanticFingerprints,
            preservedSelection,
            preservedQuality,
            refreshPrograms.Values);
        ValidateState(transition);
        RequireFingerprintCapacity(transition);
        return transition;
    }

    private MathBlockProgramPopulationArchiveEntry[] NormalizeArchiveEntries(
        MathBlockProgramPopulationDefinition previousPopulation,
        IReadOnlyList<MathBlockProgramPopulationArchiveEntry> entries)
    {
        var result = new MathBlockProgramPopulationArchiveEntry[entries.Count];
        for (var index = 0; index < entries.Count; index++)
        {
            var entry = entries[index];
            var program = NormalizeProgram(previousPopulation, Population, entry.Program);
            result[index] = new MathBlockProgramPopulationArchiveEntry(
                program,
                entry.Objectives,
                entry.Age,
                entry.SemanticFingerprint,
                entry.QualityDiversityCell);
        }
        return result;
    }

    private void AddRefreshProgram(
        Dictionary<string, MathBlockProgramStructure> destination,
        MathBlockProgramPopulationDefinition previousPopulation,
        MathBlockProgramStructure program)
    {
        var normalized = NormalizeProgram(previousPopulation, Population, program);
        destination.TryAdd(normalized.StructuralFingerprint, normalized);
    }

    private static MathBlockProgramStructure NormalizeProgram(
        MathBlockProgramPopulationDefinition previous,
        MathBlockProgramPopulationDefinition current,
        MathBlockProgramStructure program)
    {
        var previousTerminalCount = previous.AllTerminals.Count;
        var currentTerminalCount = current.AllTerminals.Count;
        if (program.Nodes.Count <= previousTerminalCount)
            throw new InvalidOperationException("An accepted program has no operation node.");
        var nodes = new List<MathBlockProgramCandidateNode>(
            checked(currentTerminalCount + program.Nodes.Count - previousTerminalCount));
        for (var terminal = 0; terminal < currentTerminalCount; terminal++)
        {
            var descriptor = current.AllTerminals[terminal];
            nodes.Add(MathBlockProgramCandidateNode.Terminal(terminal, descriptor.Identifier, descriptor.Type));
        }
        var operationShift = currentTerminalCount - previousTerminalCount;
        for (var index = previousTerminalCount; index < program.Nodes.Count; index++)
        {
            var node = program.Nodes[index];
            if (node.Kind != MathBlockProgramCandidateNodeKind.Operation)
                throw new InvalidOperationException("An accepted program operation is invalid.");
            var operands = new int[node.OperandIndexes.Count];
            for (var operand = 0; operand < operands.Length; operand++)
            {
                var value = node.OperandIndexes[operand];
                operands[operand] = value < previousTerminalCount ? value : checked(value + operationShift);
            }
            nodes.Add(MathBlockProgramCandidateNode.Operation(
                node.OperationIdentifier!,
                node.OperationVersion,
                node.Type,
                operands));
        }
        return new MathBlockProgramStructure(
            program.TrialCursor,
            program.ProposalCursor,
            program.Source,
            nodes);
    }

    public MathBlockProgramPopulationSearchDefinition WithAcceptedState(
        MathBlockProgramPopulationSearchState acceptedState) =>
        new(
            Population,
            ObjectiveBinding,
            Evolution,
            Selection,
            QualityDiversity,
            Envelope,
            Validity,
            CompactResults,
            [],
            acceptedState,
            WavePolicy,
            EnumerationCatalog);

    private static int GetValidityRowCount(MathBlockValue value) => value.Type.Kind switch
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
        _ => throw new NotSupportedException("The candidate output kind has no validity-row contract.")
    };

    private void ValidateTransition(
        MathBlockProgramPopulationSearchDefinition previousDefinition,
        MathBlockProgramPopulationSearchState previousState)
    {
        if (previousDefinition.WavePolicy != WavePolicy)
            throw new InvalidOperationException("The expanded search cannot change proposal-wave policy.");
        if (Evolution.MaximumTrialCount < previousState.TrialCursor)
            throw new InvalidOperationException("The expanded search cannot reduce the accepted trial range.");
        if (Population.FingerprintCapacity < previousState.StructuralFingerprints.Count ||
            Population.FingerprintCapacity < previousState.SemanticFingerprints.Count)
        {
            throw new InvalidOperationException("The expanded search cannot reduce accepted fingerprint capacity.");
        }
        if (!TypesAreCompatible(previousDefinition.Population.Grammar.OutputType, Population.Grammar.OutputType))
            throw new InvalidOperationException("The expanded search output type is incompatible.");
        RequireOperationPrefix(previousDefinition.Population.Grammar.Operations, Population.Grammar.Operations);
        RequireTerminalPrefix(previousDefinition.Population.AllTerminals, Population.AllTerminals);
        RequireResourceBandPrefix(
            previousDefinition.Population.ActiveResourceBands,
            Population.ActiveResourceBands);
        foreach (var entry in previousState.SelectionEntries)
            RequireProgramCapacity(entry.Program, previousDefinition.Population.AllTerminals.Count);
        foreach (var entry in previousState.QualityDiversityEntries)
            RequireProgramCapacity(entry.Program, previousDefinition.Population.AllTerminals.Count);
        foreach (var program in previousState.RefreshPrograms)
            RequireProgramCapacity(program, previousDefinition.Population.AllTerminals.Count);
    }

    private void RequireArchivePreservationCompatibility(
        MathBlockProgramPopulationSearchDefinition previousDefinition,
        MathBlockProgramPopulationSearchState previousState)
    {
        if (!HaveOperationPrefix(
                previousDefinition.Population.Grammar.Operations,
                Population.Grammar.Operations) ||
            !HaveResourceBandPrefix(
                previousDefinition.Population.ActiveResourceBands,
                Population.ActiveResourceBands) ||
            previousDefinition.Population.Grammar.OutputType != Population.Grammar.OutputType ||
            !HaveTerminalPrefix(
                previousDefinition.Population.AllTerminals,
                Population.AllTerminals) ||
            !HaveEqualHistoryCounts(
                previousDefinition.Validity.HistoryCounts,
                Validity.HistoryCounts) ||
            !string.Equals(
                MathBlockProgramPopulationSearchSerialization.CreateObjectiveBindingIdentity(
                    previousDefinition.ObjectiveBinding),
                MathBlockProgramPopulationSearchSerialization.CreateObjectiveBindingIdentity(ObjectiveBinding),
                StringComparison.Ordinal) ||
            previousDefinition.Selection.ParetoCapacity != Selection.ParetoCapacity ||
            previousDefinition.Selection.MaximumAge != Selection.MaximumAge ||
            !HaveEqualQualityPolicy(
                previousDefinition.QualityDiversity,
                QualityDiversity))
        {
            throw new InvalidOperationException(
                "The enumeration catalog transition cannot preserve incompatible archive evidence.");
        }
        foreach (var entry in previousState.SelectionEntries)
        {
            var normalized = NormalizeProgram(
                previousDefinition.Population,
                Population,
                entry.Program);
            RequireProgramCapacity(normalized);
            Population.ValidateResidentStructure(normalized);
            ValidateEntry(entry);
        }
        foreach (var entry in previousState.QualityDiversityEntries)
        {
            var normalized = NormalizeProgram(
                previousDefinition.Population,
                Population,
                entry.Program);
            RequireProgramCapacity(normalized);
            Population.ValidateResidentStructure(normalized);
            ValidateEntry(entry);
        }
    }

    private static bool HaveOperationPrefix(
        IReadOnlyList<MathBlockProgramPopulationOperation> previous,
        IReadOnlyList<MathBlockProgramPopulationOperation> current)
    {
        if (previous.Count > current.Count)
            return false;
        for (var index = 0; index < previous.Count; index++)
        {
            if (!string.Equals(
                    MathBlockProgramPopulationValidation.CreateOperationSignature(previous[index]),
                    MathBlockProgramPopulationValidation.CreateOperationSignature(current[index]),
                    StringComparison.Ordinal) ||
                previous[index].DeterministicCost != current[index].DeterministicCost)
            {
                return false;
            }
        }
        return true;
    }

    private static bool HaveTerminalPrefix(
        IReadOnlyList<MathBlockProgramPopulationTerminal> previous,
        IReadOnlyList<MathBlockProgramPopulationTerminal> current)
    {
        if (previous.Count > current.Count)
            return false;
        for (var index = 0; index < previous.Count; index++)
        {
            var left = previous[index];
            var right = current[index];
            if (!string.Equals(left.Identifier, right.Identifier, StringComparison.Ordinal) ||
                left.Type != right.Type ||
                left.Lookback != right.Lookback ||
                !MathBlockProgramPopulationValidation.ValuesAreBitwiseEqual(left.Value, right.Value))
            {
                return false;
            }
        }
        return true;
    }

    private static bool HaveEqualQualityPolicy(
        MathBlockProgramPopulationQualityDiversityPolicy previous,
        MathBlockProgramPopulationQualityDiversityPolicy current)
    {
        if (!string.Equals(previous.QualityObjective, current.QualityObjective, StringComparison.Ordinal) ||
            previous.Dimensions.Count != current.Dimensions.Count)
        {
            return false;
        }
        for (var index = 0; index < previous.Dimensions.Count; index++)
            if (previous.Dimensions[index] != current.Dimensions[index])
                return false;
        return true;
    }

    private void RequireProgramCapacity(MathBlockProgramStructure program) =>
        RequireProgramCapacity(program, Population.AllTerminals.Count);

    private void RequireProgramCapacity(MathBlockProgramStructure program, int terminalCount)
    {
        var operationCount = program.Nodes.Count - terminalCount;
        var maximum = 0;
        var supported = false;
        foreach (var band in Population.ActiveResourceBands)
        {
            maximum = Math.Max(maximum, band.OperationCount);
            supported |= band.OperationCount == operationCount;
        }
        if (operationCount <= 0 || operationCount > maximum || !supported)
            throw new InvalidOperationException("An accepted program exceeds the expanded graph-size envelope.");
    }

    private static bool HaveEqualHistoryCounts(
        IReadOnlyList<int> first,
        IReadOnlyList<int> second)
    {
        if (first.Count != second.Count)
            return false;
        for (var index = 0; index < first.Count; index++)
            if (first[index] != second[index])
                return false;
        return true;
    }

    private static void RequireOperationPrefix(
        IReadOnlyList<MathBlockProgramPopulationOperation> previous,
        IReadOnlyList<MathBlockProgramPopulationOperation> current)
    {
        if (current.Count < previous.Count)
            throw new InvalidOperationException("The expanded grammar removed an operation.");
        for (var index = 0; index < previous.Count; index++)
            if (!string.Equals(
                    MathBlockProgramPopulationValidation.CreateOperationSignature(previous[index]),
                    MathBlockProgramPopulationValidation.CreateOperationSignature(current[index]),
                    StringComparison.Ordinal) ||
                previous[index].DeterministicCost != current[index].DeterministicCost)
            {
                throw new InvalidOperationException("The expanded grammar changed an accepted operation.");
            }
    }

    private static void RequireTerminalPrefix(
        IReadOnlyList<MathBlockProgramPopulationTerminal> previous,
        IReadOnlyList<MathBlockProgramPopulationTerminal> current)
    {
        if (current.Count < previous.Count)
            throw new InvalidOperationException("The expanded grammar removed a terminal.");
        for (var index = 0; index < previous.Count; index++)
        {
            var left = previous[index];
            var right = current[index];
            if (!string.Equals(left.Identifier, right.Identifier, StringComparison.Ordinal) ||
                left.Type != right.Type ||
                left.Lookback != right.Lookback ||
                !MathBlockProgramPopulationValidation.ValuesAreBitwiseEqual(left.Value, right.Value))
            {
                throw new InvalidOperationException("The expanded grammar changed an accepted terminal.");
            }
        }
    }

    private static bool HaveResourceBandPrefix(
        IReadOnlyList<MathBlockProgramPopulationResourceBand> previous,
        IReadOnlyList<MathBlockProgramPopulationResourceBand> current)
    {
        if (previous.Count > current.Count)
            return false;
        for (var index = 0; index < previous.Count; index++)
            if (previous[index] != current[index])
                return false;
        return true;
    }

    private static void RequireResourceBandPrefix(
        IReadOnlyList<MathBlockProgramPopulationResourceBand> previous,
        IReadOnlyList<MathBlockProgramPopulationResourceBand> current)
    {
        if (current.Count < previous.Count)
            throw new InvalidOperationException("The expanded search removed a resource band.");
        for (var index = 0; index < previous.Count; index++)
            if (previous[index] != current[index])
                throw new InvalidOperationException("The expanded search changed an accepted resource band.");
    }

    private static bool HasStableEnumerationPrefix(
        MathBlockProgramPopulationSearchDefinition previousDefinition,
        MathBlockProgramPopulationSearchDefinition currentDefinition)
    {
        var previousCatalog = previousDefinition.EnumerationCatalog;
        var currentCatalog = currentDefinition.EnumerationCatalog;
        if (previousCatalog is null != (currentCatalog is null) ||
            previousCatalog is not null && !string.Equals(
                previousCatalog.Identity,
                currentCatalog!.Identity,
                StringComparison.Ordinal))
        {
            return false;
        }
        var previous = previousDefinition.Population;
        var current = currentDefinition.Population;
        if (previous.Grammar.Operations.Count != current.Grammar.Operations.Count ||
            previous.AllTerminals.Count != current.AllTerminals.Count ||
            previous.ActiveResourceBands.Count > current.ActiveResourceBands.Count)
        {
            return false;
        }
        for (var index = 0; index < previous.ActiveResourceBands.Count; index++)
            if (previous.ActiveResourceBands[index] != current.ActiveResourceBands[index])
                return false;
        return true;
    }

    private void RequireCatalogDoesNotOverlap(IEnumerable<MathBlockProgramStructure> programs)
    {
        if (EnumerationCatalog is null)
            return;
        var catalogFingerprints = new HashSet<string>(StringComparer.Ordinal);
        foreach (var program in EnumerationCatalog.Programs)
            catalogFingerprints.Add(program.StructuralFingerprint);
        foreach (var program in programs)
        {
            if (catalogFingerprints.Contains(program.StructuralFingerprint))
            {
                throw new InvalidOperationException(
                    "The enumeration catalog overlaps a refresh program.");
            }
        }
    }

    private static bool TypesAreCompatible(MathBlockType previous, MathBlockType current) =>
        current.Accepts(previous) || previous.Accepts(current);

    private MathBlockProgramPopulationOperation FindOperation(
        MathBlockProgramCandidateNode node,
        IReadOnlyList<MathBlockProgramCandidateNode> programNodes)
    {
        MathBlockProgramPopulationOperation? match = null;
        foreach (var operation in Population.Grammar.Operations)
        {
            if (!string.Equals(operation.Identifier, node.OperationIdentifier, StringComparison.Ordinal) ||
                operation.Version != node.OperationVersion ||
                operation.OutputType != node.Type ||
                operation.InputTypes.Count != node.OperandIndexes.Count)
            {
                continue;
            }
            var inputTypesMatch = true;
            for (var input = 0; input < operation.InputTypes.Count; input++)
            {
                if (operation.InputTypes[input] ==
                    programNodes[node.OperandIndexes[input]].Type)
                {
                    continue;
                }
                inputTypesMatch = false;
                break;
            }
            if (!inputTypesMatch)
                continue;
            if (match is not null)
                throw new InvalidOperationException("A program operation is ambiguous.");
            match = operation;
        }
        return match ?? throw new InvalidOperationException("A program operation is outside the grammar.");
    }

    private void ValidateState(MathBlockProgramPopulationSearchState state)
    {
        if (!string.Equals(state.Identity, Identity, StringComparison.Ordinal))
            throw new InvalidOperationException("The accepted search state has an incompatible identity.");
        var proposalWaveSize = checked((ulong)WavePolicy.ProposalWaveSize);
        var minimumWaveCursor = state.TrialCursor / proposalWaveSize +
            (state.TrialCursor % proposalWaveSize == 0 ? 0ul : 1ul);
        if (state.TrialCursor > Evolution.MaximumTrialCount ||
            state.TrialCursor < InitialTrialCursor ||
            state.WaveCursor > state.TrialCursor ||
            state.WaveCursor < minimumWaveCursor ||
            state.EnumerationCursor > EnumerationCursorLimit ||
            state.EnumerationTrialCount > Evolution.EnumerationProposalCount ||
            state.EnumerationTrialCount > state.TrialCursor - InitialTrialCursor ||
            state.EnumerationTrialCount > state.EnumerationCursor)
        {
            throw new InvalidOperationException("The accepted search cursor is outside its range.");
        }
        if (state.StructuralFingerprints.Count > Population.FingerprintCapacity ||
            state.SemanticFingerprints.Count > Population.FingerprintCapacity ||
            state.SelectionEntries.Count > Selection.ParetoCapacity ||
            state.QualityDiversityEntries.Count > QualityDiversity.CellCount ||
            state.RefreshPrograms.Count > Selection.ParetoCapacity + QualityDiversity.CellCount)
        {
            throw new InvalidOperationException("The accepted search state exceeds its capacity.");
        }
        foreach (var entry in state.SelectionEntries)
            ValidateEntry(entry);
        foreach (var entry in state.QualityDiversityEntries)
            ValidateEntry(entry);
        foreach (var program in state.RefreshPrograms)
            RequireProgramCapacity(program);
    }

    private void RequireFingerprintCapacity(MathBlockProgramPopulationSearchState? state)
    {
        var structuralCount = state?.StructuralFingerprints.Count ?? 0;
        var semanticCount = state?.SemanticFingerprints.Count ?? 0;
        var trialCursor = state?.TrialCursor ?? InitialTrialCursor;
        var refreshPrograms = state?.RefreshPrograms ?? InitialPrograms;
        var refreshCursor = state?.RefreshCursor ?? 0;
        var pendingRefreshCount = CountUniqueRefreshPrograms(refreshPrograms, refreshCursor);
        var remainingTrialCount = Evolution.MaximumTrialCount - trialCursor;

        RequireFingerprintCapacity(structuralCount, pendingRefreshCount, remainingTrialCount);
        RequireFingerprintCapacity(semanticCount, pendingRefreshCount, remainingTrialCount);
    }

    private void RequireFingerprintCapacity(
        int existingCount,
        int pendingRefreshCount,
        ulong remainingTrialCount)
    {
        var available = Population.FingerprintCapacity;
        if (existingCount > available)
            ThrowInsufficientFingerprintCapacity();
        available -= existingCount;
        if (pendingRefreshCount > available)
            ThrowInsufficientFingerprintCapacity();
        available -= pendingRefreshCount;
        if (remainingTrialCount > (ulong)available)
            ThrowInsufficientFingerprintCapacity();
    }

    private static int CountUniqueRefreshPrograms(
        IReadOnlyList<MathBlockProgramStructure> programs,
        int startIndex)
    {
        var fingerprints = new HashSet<string>(StringComparer.Ordinal);
        for (var index = startIndex; index < programs.Count; index++)
            fingerprints.Add(programs[index].StructuralFingerprint);
        return fingerprints.Count;
    }

    private static void ThrowInsufficientFingerprintCapacity() =>
        throw new ArgumentOutOfRangeException(
            "population",
            "The fingerprint capacity must contain existing fingerprints, pending refresh programs, and all remaining search trials.");

    private void ValidateEntry(MathBlockProgramPopulationArchiveEntry entry)
    {
        if (entry.Objectives.Count != ObjectiveBinding.Objectives.Count)
            throw new InvalidOperationException("An accepted archive entry has an incompatible objective count.");
        if (entry.Age > Selection.MaximumAge)
            throw new InvalidOperationException("An accepted archive entry exceeds the maximum age.");
    }

    private static int FindObjective(
        IReadOnlyList<MathBlockProgramPopulationObjective> objectives,
        string name)
    {
        for (var index = 0; index < objectives.Count; index++)
            if (string.Equals(objectives[index].Name, name, StringComparison.Ordinal))
                return index;
        return -1;
    }
}

public sealed class MathBlockProgramStructure
{
    public MathBlockProgramStructure(
        ulong trialCursor,
        ulong? proposalCursor,
        MathBlockProgramPopulationTrialSource source,
        IEnumerable<MathBlockProgramCandidateNode> nodes)
    {
        if (!Enum.IsDefined(source))
            throw new ArgumentOutOfRangeException(nameof(source));
        ArgumentNullException.ThrowIfNull(nodes);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(nodes);
        if (copied.Length == 0)
            throw new ArgumentException("A program structure requires a node.", nameof(nodes));
        for (var nodeIndex = 0; nodeIndex < copied.Length; nodeIndex++)
        {
            var node = copied[nodeIndex] ?? throw new ArgumentException("A program structure node is null.", nameof(nodes));
            if (node.Kind != MathBlockProgramCandidateNodeKind.Operation)
                continue;
            foreach (var operandIndex in node.OperandIndexes)
                if (operandIndex < 0 || operandIndex >= nodeIndex)
                    throw new ArgumentException("A program operand must reference an earlier node.", nameof(nodes));
        }
        TrialCursor = trialCursor;
        ProposalCursor = proposalCursor;
        Source = source;
        Nodes = Array.AsReadOnly(copied);
        StructuralFingerprint = MathBlockProgramPopulationFingerprint.CreateStructural(copied);
    }

    public ulong TrialCursor { get; }
    public ulong? ProposalCursor { get; }
    public MathBlockProgramPopulationTrialSource Source { get; }
    public IReadOnlyList<MathBlockProgramCandidateNode> Nodes { get; }
    public string StructuralFingerprint { get; }
}

public sealed class MathBlockProgramPopulationArchiveEntry
{
    internal MathBlockProgramPopulationArchiveEntry(
        MathBlockProgramStructure program,
        IEnumerable<double> objectives,
        int age,
        string semanticFingerprint,
        int qualityDiversityCell)
    {
        Program = program ?? throw new ArgumentNullException(nameof(program));
        ArgumentNullException.ThrowIfNull(objectives);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(objectives);
        if (copied.Length == 0)
            throw new ArgumentOutOfRangeException(nameof(objectives));
        for (var index = 0; index < copied.Length; index++)
            if (!Math.IsFinite(copied[index]))
                throw new ArgumentOutOfRangeException(nameof(objectives));
        if (age < 0)
            throw new ArgumentOutOfRangeException(nameof(age));
        SemanticFingerprint = MathBlockProgramPopulationValidation.RequireFingerprint(
            semanticFingerprint,
            nameof(semanticFingerprint),
            32);
        if (qualityDiversityCell < -1)
            throw new ArgumentOutOfRangeException(nameof(qualityDiversityCell));
        Objectives = Array.AsReadOnly(copied);
        Age = age;
        QualityDiversityCell = qualityDiversityCell;
    }

    public MathBlockProgramStructure Program { get; }
    public IReadOnlyList<double> Objectives { get; }
    public int Age { get; }
    public string StructuralFingerprint => Program.StructuralFingerprint;
    public string SemanticFingerprint { get; }
    public int QualityDiversityCell { get; }
}

public sealed class MathBlockProgramPopulationTrialResult
{
    internal MathBlockProgramPopulationTrialResult(
        MathBlockProgramStructure program,
        MathBlockProgramPopulationTrialStatus status,
        IEnumerable<double> objectives,
        string? semanticFingerprint,
        bool acceptedByPareto,
        bool acceptedByQualityDiversity,
        int qualityDiversityCell)
    {
        Program = program ?? throw new ArgumentNullException(nameof(program));
        if (!Enum.IsDefined(status))
            throw new ArgumentOutOfRangeException(nameof(status));
        ArgumentNullException.ThrowIfNull(objectives);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(objectives);
        for (var index = 0; index < copied.Length; index++)
            if (!Math.IsFinite(copied[index]))
                throw new ArgumentOutOfRangeException(nameof(objectives));
        if (semanticFingerprint is not null)
        {
            semanticFingerprint = MathBlockProgramPopulationValidation.RequireFingerprint(
                semanticFingerprint,
                nameof(semanticFingerprint),
                32);
        }
        if (qualityDiversityCell < -1)
            throw new ArgumentOutOfRangeException(nameof(qualityDiversityCell));
        Status = status;
        Objectives = Array.AsReadOnly(copied);
        SemanticFingerprint = semanticFingerprint;
        AcceptedByPareto = acceptedByPareto;
        AcceptedByQualityDiversity = acceptedByQualityDiversity;
        QualityDiversityCell = qualityDiversityCell;
    }

    public MathBlockProgramStructure Program { get; }
    public MathBlockProgramPopulationTrialStatus Status { get; }
    public IReadOnlyList<double> Objectives { get; }
    public string StructuralFingerprint => Program.StructuralFingerprint;
    public string? SemanticFingerprint { get; }
    public bool AcceptedByPareto { get; }
    public bool AcceptedByQualityDiversity { get; }
    public int QualityDiversityCell { get; }
}

public readonly record struct MathBlockProgramPopulationRandomState
{
    public MathBlockProgramPopulationRandomState(ulong first, ulong second)
    {
        if (first == 0 && second == 0)
            throw new ArgumentException("A random state cannot contain two zero words.");
        First = first;
        Second = second;
    }

    public ulong First { get; }
    public ulong Second { get; }
}

public sealed class MathBlockProgramPopulationSearchState
{
    internal MathBlockProgramPopulationSearchState(
        string identity,
        ulong enumerationCursor,
        ulong enumerationTrialCount,
        ulong trialCursor,
        ulong cycleCount,
        ulong waveCursor,
        ulong envelopeGeneration,
        int refreshCursor,
        MathBlockProgramPopulationRandomState randomState,
        ulong structuralDuplicateCount,
        ulong semanticDuplicateCount,
        ulong evaluatedProgramCount,
        ulong acceptedProgramCount,
        IEnumerable<string> structuralFingerprints,
        IEnumerable<string> semanticFingerprints,
        IEnumerable<MathBlockProgramPopulationArchiveEntry> selectionEntries,
        IEnumerable<MathBlockProgramPopulationArchiveEntry> qualityDiversityEntries,
        IEnumerable<MathBlockProgramStructure> refreshPrograms)
    {
        Identity = MathBlockProgramPopulationValidation.RequireFingerprint(identity, nameof(identity), 64);
        ArgumentNullException.ThrowIfNull(structuralFingerprints);
        ArgumentNullException.ThrowIfNull(semanticFingerprints);
        ArgumentNullException.ThrowIfNull(selectionEntries);
        ArgumentNullException.ThrowIfNull(qualityDiversityEntries);
        ArgumentNullException.ThrowIfNull(refreshPrograms);
        var structural = MathBlockCollectionPrimitives.CopyEnumerable(structuralFingerprints);
        var semantic = MathBlockCollectionPrimitives.CopyEnumerable(semanticFingerprints);
        for (var index = 0; index < structural.Length; index++)
        {
            structural[index] = MathBlockProgramPopulationValidation.RequireFingerprint(
                structural[index],
                nameof(structuralFingerprints),
                32);
        }
        for (var index = 0; index < semantic.Length; index++)
        {
            semantic[index] = MathBlockProgramPopulationValidation.RequireFingerprint(
                semantic[index],
                nameof(semanticFingerprints),
                32);
        }
        var selected = MathBlockCollectionPrimitives.CopyEnumerable(selectionEntries);
        var quality = MathBlockCollectionPrimitives.CopyEnumerable(qualityDiversityEntries);
        var refresh = MathBlockCollectionPrimitives.CopyEnumerable(refreshPrograms);
        if (refreshCursor < 0 || refreshCursor > refresh.Length)
            throw new ArgumentOutOfRangeException(nameof(refreshCursor));
        for (var index = 0; index < selected.Length; index++)
            ArgumentNullException.ThrowIfNull(selected[index]);
        for (var index = 0; index < quality.Length; index++)
            ArgumentNullException.ThrowIfNull(quality[index]);
        for (var index = 0; index < refresh.Length; index++)
            ArgumentNullException.ThrowIfNull(refresh[index]);
        if (enumerationTrialCount > enumerationCursor)
            throw new ArgumentOutOfRangeException(nameof(enumerationTrialCount));
        EnumerationCursor = enumerationCursor;
        EnumerationTrialCount = enumerationTrialCount;
        TrialCursor = trialCursor;
        CycleCount = cycleCount;
        WaveCursor = waveCursor;
        EnvelopeGeneration = envelopeGeneration;
        RefreshCursor = refreshCursor;
        RandomState = randomState;
        StructuralDuplicateCount = structuralDuplicateCount;
        SemanticDuplicateCount = semanticDuplicateCount;
        EvaluatedProgramCount = evaluatedProgramCount;
        AcceptedProgramCount = acceptedProgramCount;
        StructuralFingerprints = Array.AsReadOnly(structural);
        SemanticFingerprints = Array.AsReadOnly(semantic);
        SelectionEntries = Array.AsReadOnly(selected);
        QualityDiversityEntries = Array.AsReadOnly(quality);
        RefreshPrograms = Array.AsReadOnly(refresh);
    }

    public string Identity { get; }
    public ulong EnumerationCursor { get; }
    public ulong EnumerationTrialCount { get; }
    public ulong InvalidEnumerationProposalCount => EnumerationCursor - EnumerationTrialCount;
    public ulong TrialCursor { get; }
    public ulong CycleCount { get; }
    public ulong WaveCursor { get; }
    public ulong EnvelopeGeneration { get; }
    public int RefreshCursor { get; }
    public MathBlockProgramPopulationRandomState RandomState { get; }
    public ulong StructuralDuplicateCount { get; }
    public ulong SemanticDuplicateCount { get; }
    public ulong EvaluatedProgramCount { get; }
    public ulong AcceptedProgramCount { get; }
    public IReadOnlyList<string> StructuralFingerprints { get; }
    public IReadOnlyList<string> SemanticFingerprints { get; }
    public IReadOnlyList<MathBlockProgramPopulationArchiveEntry> SelectionEntries { get; }
    public IReadOnlyList<MathBlockProgramPopulationArchiveEntry> QualityDiversityEntries { get; }
    public IReadOnlyList<MathBlockProgramStructure> RefreshPrograms { get; }

    public byte[] Export() => MathBlockProgramPopulationSearchSerialization.ExportState(this);

    public static MathBlockProgramPopulationSearchState Import(ReadOnlySpan<byte> data) =>
        MathBlockProgramPopulationSearchSerialization.ImportState(data);
}

public readonly record struct MathBlockProgramPopulationSearchInstrumentation(
    long GraphInstanceCount,
    long ImmutableUploadCount,
    long LaterImmutableUploadCount,
    long GraphLaunchCount,
    long SynchronizationCount,
    long DownloadCount,
    long ResidentBytes,
    int CompactDownloadBytesPerCycle,
    long DownloadedBytes,
    long FullCandidateOutputDownloadCount,
    long FullCandidateOutputBytes,
    int CpuNodeDispatchCount,
    ulong StructuralDuplicateCount,
    ulong SemanticDuplicateCount,
    ulong EvaluatedProgramCount,
    ulong AcceptedProgramCount,
    ulong EnumerationCursor,
    ulong EnumerationTrialCount,
    ulong InvalidEnumerationProposalCount,
    ulong TrialCursor,
    ulong CycleCount,
    int SelectionCount,
    int QualityDiversityCount,
    MathBlockProgramPopulationRandomState RandomState,
    MathBlockProgramPopulationExecutionMode ExecutionMode,
    int RequestedCandidateLaneCount,
    int ActiveCandidateLaneCount,
    long ProposalWaveCount,
    long CandidateChunkCount,
    int MaximumConcurrentCandidates,
    long SerialCandidateExecutionCount,
    long ParallelCandidateExecutionCount);

public sealed class MathBlockProgramPopulationSearchCycleResult
{
    internal MathBlockProgramPopulationSearchCycleResult(
        IEnumerable<MathBlockProgramPopulationTrialResult> trials,
        MathBlockProgramPopulationSearchState acceptedState,
        MathBlockProgramPopulationSearchInstrumentation instrumentation,
        bool isEnumerationComplete,
        bool isSearchComplete)
    {
        ArgumentNullException.ThrowIfNull(trials);
        Trials = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(trials));
        AcceptedState = acceptedState ?? throw new ArgumentNullException(nameof(acceptedState));
        Instrumentation = instrumentation;
        IsEnumerationComplete = isEnumerationComplete;
        IsSearchComplete = isSearchComplete;
    }

    public IReadOnlyList<MathBlockProgramPopulationTrialResult> Trials { get; }
    public MathBlockProgramPopulationSearchState AcceptedState { get; }
    public MathBlockProgramPopulationSearchInstrumentation Instrumentation { get; }
    public bool IsEnumerationComplete { get; }
    public bool IsSearchComplete { get; }
}

internal static class MathBlockProgramPopulationSearchSerialization
{
    private const string StateSchema = "mathblocks-population-search-state-v5";

    public static string CreateIdentity(MathBlockProgramPopulationSearchDefinition definition)
    {
        using var stream = new MemoryStream();
        using var writer = new BinaryWriter(stream, Encoding.UTF8, leaveOpen: true);
        writer.Write("mathblocks-population-search-v5");
        writer.Write(definition.Population.Identity);
        writer.Write(definition.EnumerationCatalog is not null);
        if (definition.EnumerationCatalog is not null)
            writer.Write(definition.EnumerationCatalog.Identity);
        var binding = definition.ObjectiveBinding;
        writer.Write(binding.Program.Fingerprint);
        writer.Write(binding.CandidateInput);
        writer.Write(binding.CandidateValidityMaskInput is not null);
        if (binding.CandidateValidityMaskInput is not null)
            writer.Write(binding.CandidateValidityMaskInput);
        var boundInputCount = 0;
        foreach (var node in binding.Program.PlanNodes)
        {
            if (node.Kind == MathBlockProgramNodeKind.Input &&
                !string.Equals(node.Name, binding.CandidateInput, StringComparison.Ordinal) &&
                !string.Equals(node.Name, binding.CandidateValidityMaskInput, StringComparison.Ordinal))
            {
                boundInputCount++;
            }
        }
        writer.Write(boundInputCount);
        foreach (var node in binding.Program.PlanNodes)
        {
            if (node.Kind != MathBlockProgramNodeKind.Input ||
                string.Equals(node.Name, binding.CandidateInput, StringComparison.Ordinal) ||
                string.Equals(node.Name, binding.CandidateValidityMaskInput, StringComparison.Ordinal))
            {
                continue;
            }
            writer.Write(node.Name!);
            WriteValue(writer, binding.ResidentInputs[node.Name!]);
        }
        writer.Write(binding.Objectives.Count);
        foreach (var objective in binding.Objectives)
        {
            writer.Write(objective.Name);
            writer.Write((int)objective.SourceKind);
            writer.Write(objective.SourceIdentity);
            writer.Write(objective.ProgramOutput is not null);
            if (objective.ProgramOutput is not null)
                writer.Write(objective.ProgramOutput);
            writer.Write((int)objective.Direction);
        }
        writer.Write(definition.WavePolicy.ProposalWaveSize);
        writer.Write(definition.WavePolicy.WavesPerCycle);
        var evolution = definition.Evolution;
        writer.Write(evolution.MaximumTrialCount);
        writer.Write(evolution.EnumerationProposalCount);
        writer.Write(evolution.MutationTrials);
        writer.Write(evolution.CrossoverTrials);
        writer.Write(evolution.RandomImmigrantTrials);
        writer.Write(evolution.RandomSeed);
        writer.Write(evolution.RandomSequence);
        writer.Write(definition.Selection.ParetoCapacity);
        writer.Write(definition.Selection.MaximumAge);
        writer.Write(definition.QualityDiversity.QualityObjective);
        writer.Write(definition.QualityDiversity.Dimensions.Count);
        foreach (var dimension in definition.QualityDiversity.Dimensions)
        {
            writer.Write(dimension.Objective);
            writer.Write(unchecked((long)Math.ToBits(dimension.Minimum)));
            writer.Write(unchecked((long)Math.ToBits(dimension.Maximum)));
            writer.Write(dimension.BinCount);
        }
        writer.Write(definition.CompactResults.IncludeRejectedTrials);
        writer.Write(definition.Envelope.MaximumResidentBytes);
        writer.Write(definition.Envelope.MaximumCompactDownloadBytes);
        writer.Write(definition.Validity.HistoryCounts.Count);
        foreach (var historyCount in definition.Validity.HistoryCounts)
            writer.Write(historyCount);
        writer.Write(definition.InitialPrograms.Count);
        foreach (var program in definition.InitialPrograms)
            WriteStructure(writer, program);
        return Convert.ToHexString(SHA256.HashData(stream.ToArray())).ToLowerInvariant();
    }

    public static string CreateEnumerationCatalogIdentity(
        MathBlockProgramPopulationEnumerationCatalog catalog)
    {
        ArgumentNullException.ThrowIfNull(catalog);
        using var stream = new MemoryStream();
        using var writer = new BinaryWriter(stream, Encoding.UTF8, leaveOpen: true);
        writer.Write("mathblocks-population-enumeration-catalog-v1");
        writer.Write(catalog.CursorStart);
        writer.Write(catalog.CursorEndExclusive);
        writer.Write(catalog.Programs.Count);
        foreach (var program in catalog.Programs)
            WriteStructure(writer, program);
        return Convert.ToHexString(SHA256.HashData(stream.ToArray())).ToLowerInvariant();
    }

    public static string CreateObjectiveBindingIdentity(
        MathBlockProgramPopulationObjectiveBinding binding)
    {
        ArgumentNullException.ThrowIfNull(binding);
        using var stream = new MemoryStream();
        using var writer = new BinaryWriter(stream, Encoding.UTF8, leaveOpen: true);
        writer.Write("mathblocks-population-objective-binding-v1");
        writer.Write(binding.Program.Fingerprint);
        writer.Write(binding.CandidateInput);
        writer.Write(binding.CandidateValidityMaskInput is not null);
        if (binding.CandidateValidityMaskInput is not null)
            writer.Write(binding.CandidateValidityMaskInput);
        var residentNames = new string[binding.ResidentInputs.Count];
        var residentIndex = 0;
        foreach (var name in binding.ResidentInputs.Keys)
            residentNames[residentIndex++] = name;
        for (var index = 1; index < residentNames.Length; index++)
        {
            var name = residentNames[index];
            var destination = index;
            while (destination > 0 &&
                string.CompareOrdinal(residentNames[destination - 1], name) > 0)
            {
                residentNames[destination] = residentNames[destination - 1];
                destination--;
            }
            residentNames[destination] = name;
        }
        writer.Write(residentNames.Length);
        foreach (var name in residentNames)
        {
            writer.Write(name);
            WriteValue(writer, binding.ResidentInputs[name]);
        }
        writer.Write(binding.Objectives.Count);
        foreach (var objective in binding.Objectives)
        {
            writer.Write(objective.Name);
            writer.Write((int)objective.SourceKind);
            writer.Write(objective.SourceIdentity);
            writer.Write(objective.ProgramOutput is not null);
            if (objective.ProgramOutput is not null)
                writer.Write(objective.ProgramOutput);
            writer.Write((int)objective.Direction);
        }
        return Convert.ToHexString(SHA256.HashData(stream.ToArray())).ToLowerInvariant();
    }

    public static MathBlockProgramPopulationRandomState CreateInitialRandomState(
        MathBlockProgramPopulationEvolutionPolicy evolution)
    {
        var mixer = unchecked(evolution.RandomSeed + 0x9e3779b97f4a7c15ul +
            evolution.RandomSequence * 0xbf58476d1ce4e5b9ul);
        var first = SplitMix64(ref mixer);
        var second = SplitMix64(ref mixer);
        if (first == 0 && second == 0)
            second = 1;
        return new MathBlockProgramPopulationRandomState(first, second);
    }

    public static byte[] ExportState(MathBlockProgramPopulationSearchState state)
    {
        using var stream = new MemoryStream();
        using (var writer = new BinaryWriter(stream, Encoding.UTF8, leaveOpen: true))
        {
            writer.Write(StateSchema);
            writer.Write(state.Identity);
            writer.Write(state.EnumerationCursor);
            writer.Write(state.EnumerationTrialCount);
            writer.Write(state.TrialCursor);
            writer.Write(state.CycleCount);
            writer.Write(state.WaveCursor);
            writer.Write(state.EnvelopeGeneration);
            writer.Write(state.RefreshCursor);
            writer.Write(state.RandomState.First);
            writer.Write(state.RandomState.Second);
            writer.Write(state.StructuralDuplicateCount);
            writer.Write(state.SemanticDuplicateCount);
            writer.Write(state.EvaluatedProgramCount);
            writer.Write(state.AcceptedProgramCount);
            WriteFingerprints(writer, state.StructuralFingerprints);
            WriteFingerprints(writer, state.SemanticFingerprints);
            WriteArchive(writer, state.SelectionEntries);
            WriteArchive(writer, state.QualityDiversityEntries);
            writer.Write(state.RefreshPrograms.Count);
            foreach (var program in state.RefreshPrograms)
                WriteStructure(writer, program);
        }
        var payload = stream.ToArray();
        var hash = SHA256.HashData(payload);
        var result = new byte[checked(payload.Length + hash.Length)];
        payload.CopyTo(result, 0);
        hash.CopyTo(result, payload.Length);
        return result;
    }

    public static MathBlockProgramPopulationSearchState ImportState(ReadOnlySpan<byte> data)
    {
        if (data.Length <= 32)
            throw new InvalidDataException("The population search state length is invalid.");
        var payload = data[..^32];
        var expectedHash = data[^32..];
        var actualHash = SHA256.HashData(payload);
        if (!CryptographicOperations.FixedTimeEquals(actualHash, expectedHash))
            throw new InvalidDataException("The population search state checksum is invalid.");
        using var stream = new MemoryStream(payload.ToArray(), writable: false);
        using var reader = new BinaryReader(stream, Encoding.UTF8, leaveOpen: false);
        if (!string.Equals(reader.ReadString(), StateSchema, StringComparison.Ordinal))
            throw new InvalidDataException("The population search state schema is unsupported.");
        var identity = reader.ReadString();
        var enumerationCursor = reader.ReadUInt64();
        var enumerationTrialCount = reader.ReadUInt64();
        var trialCursor = reader.ReadUInt64();
        var cycleCount = reader.ReadUInt64();
        var waveCursor = reader.ReadUInt64();
        var envelopeGeneration = reader.ReadUInt64();
        var refreshCursor = reader.ReadInt32();
        var randomState = new MathBlockProgramPopulationRandomState(reader.ReadUInt64(), reader.ReadUInt64());
        var structuralDuplicates = reader.ReadUInt64();
        var semanticDuplicates = reader.ReadUInt64();
        var evaluated = reader.ReadUInt64();
        var accepted = reader.ReadUInt64();
        var structural = ReadFingerprints(reader);
        var semantic = ReadFingerprints(reader);
        var selection = ReadArchive(reader);
        var quality = ReadArchive(reader);
        var refreshCount = reader.ReadInt32();
        if (refreshCount < 0 || refreshCount > reader.BaseStream.Length)
            throw new InvalidDataException("The population refresh count is invalid.");
        var refresh = new MathBlockProgramStructure[refreshCount];
        for (var index = 0; index < refresh.Length; index++)
            refresh[index] = ReadStructure(reader);
        if (stream.Position != stream.Length)
            throw new InvalidDataException("The population search state has trailing data.");
        return new MathBlockProgramPopulationSearchState(
            identity,
            enumerationCursor,
            enumerationTrialCount,
            trialCursor,
            cycleCount,
            waveCursor,
            envelopeGeneration,
            refreshCursor,
            randomState,
            structuralDuplicates,
            semanticDuplicates,
            evaluated,
            accepted,
            structural,
            semantic,
            selection,
            quality,
            refresh);
    }

    private static ulong SplitMix64(ref ulong value)
    {
        value = unchecked(value + 0x9e3779b97f4a7c15ul);
        var result = value;
        result = unchecked((result ^ (result >> 30)) * 0xbf58476d1ce4e5b9ul);
        result = unchecked((result ^ (result >> 27)) * 0x94d049bb133111ebul);
        return result ^ (result >> 31);
    }

    private static void WriteFingerprints(BinaryWriter writer, IReadOnlyList<string> fingerprints)
    {
        writer.Write(fingerprints.Count);
        foreach (var fingerprint in fingerprints)
            writer.Write(fingerprint);
    }

    private static string[] ReadFingerprints(BinaryReader reader)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > reader.BaseStream.Length)
            throw new InvalidDataException("The population fingerprint count is invalid.");
        var result = new string[count];
        for (var index = 0; index < count; index++)
            result[index] = reader.ReadString();
        return result;
    }

    private static void WriteArchive(
        BinaryWriter writer,
        IReadOnlyList<MathBlockProgramPopulationArchiveEntry> entries)
    {
        writer.Write(entries.Count);
        foreach (var entry in entries)
        {
            WriteStructure(writer, entry.Program);
            writer.Write(entry.Objectives.Count);
            foreach (var objective in entry.Objectives)
                writer.Write(unchecked((long)Math.ToBits(objective)));
            writer.Write(entry.Age);
            writer.Write(entry.SemanticFingerprint);
            writer.Write(entry.QualityDiversityCell);
        }
    }

    private static MathBlockProgramPopulationArchiveEntry[] ReadArchive(BinaryReader reader)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > reader.BaseStream.Length)
            throw new InvalidDataException("The population archive count is invalid.");
        var result = new MathBlockProgramPopulationArchiveEntry[count];
        for (var index = 0; index < result.Length; index++)
        {
            var program = ReadStructure(reader);
            var objectiveCount = reader.ReadInt32();
            if (objectiveCount <= 0 || objectiveCount > reader.BaseStream.Length)
                throw new InvalidDataException("The population objective count is invalid.");
            var objectives = new double[objectiveCount];
            for (var objective = 0; objective < objectives.Length; objective++)
                objectives[objective] = Math.FromBits(unchecked((ulong)reader.ReadInt64()));
            result[index] = new MathBlockProgramPopulationArchiveEntry(
                program,
                objectives,
                reader.ReadInt32(),
                reader.ReadString(),
                reader.ReadInt32());
        }
        return result;
    }

    private static void WriteStructure(BinaryWriter writer, MathBlockProgramStructure program)
    {
        writer.Write(program.TrialCursor);
        writer.Write(program.ProposalCursor.HasValue);
        if (program.ProposalCursor.HasValue)
            writer.Write(program.ProposalCursor.Value);
        writer.Write((int)program.Source);
        writer.Write(program.StructuralFingerprint);
        writer.Write(program.Nodes.Count);
        foreach (var node in program.Nodes)
        {
            writer.Write((int)node.Kind);
            WriteType(writer, node.Type);
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                writer.Write(node.TerminalIndex);
                writer.Write(node.TerminalIdentifier!);
            }
            else
            {
                writer.Write(node.OperationIdentifier!);
                writer.Write(node.OperationVersion);
                writer.Write(node.OperandIndexes.Count);
                foreach (var operand in node.OperandIndexes)
                    writer.Write(operand);
            }
        }
    }

    private static MathBlockProgramStructure ReadStructure(BinaryReader reader)
    {
        var trialCursor = reader.ReadUInt64();
        ulong? proposalCursor = reader.ReadBoolean() ? reader.ReadUInt64() : null;
        var source = (MathBlockProgramPopulationTrialSource)reader.ReadInt32();
        var expectedFingerprint = reader.ReadString();
        var nodeCount = reader.ReadInt32();
        if (nodeCount <= 0 || nodeCount > reader.BaseStream.Length)
        {
            throw new InvalidDataException("The population program node count is invalid.");
        }
        var nodes = new MathBlockProgramCandidateNode[nodeCount];
        for (var index = 0; index < nodes.Length; index++)
        {
            var kind = (MathBlockProgramCandidateNodeKind)reader.ReadInt32();
            var type = ReadType(reader);
            if (kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                nodes[index] = MathBlockProgramCandidateNode.Terminal(
                    reader.ReadInt32(),
                    reader.ReadString(),
                    type);
            }
            else if (kind == MathBlockProgramCandidateNodeKind.Operation)
            {
                var identifier = reader.ReadString();
                var version = reader.ReadInt32();
                var operandCount = reader.ReadInt32();
                if (operandCount < 0 || operandCount > reader.BaseStream.Length / sizeof(int))
                    throw new InvalidDataException("The population program operand count is invalid.");
                var operands = new int[operandCount];
                for (var operand = 0; operand < operands.Length; operand++)
                    operands[operand] = reader.ReadInt32();
                nodes[index] = MathBlockProgramCandidateNode.Operation(identifier, version, type, operands);
            }
            else
            {
                throw new InvalidDataException("The population program node kind is invalid.");
            }
        }
        var result = new MathBlockProgramStructure(trialCursor, proposalCursor, source, nodes);
        if (!string.Equals(result.StructuralFingerprint, expectedFingerprint, StringComparison.Ordinal))
            throw new InvalidDataException("The population program fingerprint is invalid.");
        return result;
    }

    private static void WriteValue(BinaryWriter writer, MathBlockValue value)
    {
        WriteType(writer, value.Type);
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                writer.Write(unchecked((long)Math.ToBits(value.AsScalar())));
                break;
            case MathBlockValueKind.Boolean:
                writer.Write(value.AsBoolean());
                break;
            case MathBlockValueKind.Vector:
                writer.Write(value.AsVector().Count);
                foreach (var item in value.AsVector())
                    writer.Write(unchecked((long)Math.ToBits(item)));
                break;
            case MathBlockValueKind.BooleanVector:
                writer.Write(value.AsBooleanVector().Count);
                foreach (var item in value.AsBooleanVector())
                    writer.Write(item);
                break;
            case MathBlockValueKind.Matrix:
                var matrix = value.AsMatrix();
                writer.Write(matrix.Rows);
                writer.Write(matrix.Columns);
                for (var row = 0; row < matrix.Rows; row++)
                for (var column = 0; column < matrix.Columns; column++)
                    writer.Write(unchecked((long)Math.ToBits(matrix[row, column])));
                break;
            case MathBlockValueKind.Complex:
                WriteComplex(writer, value.AsComplex());
                break;
            case MathBlockValueKind.ComplexVector:
                writer.Write(value.AsComplexVector().Count);
                foreach (var item in value.AsComplexVector())
                    WriteComplex(writer, item);
                break;
            case MathBlockValueKind.ComplexMatrix:
                var complexMatrix = value.AsComplexMatrix();
                writer.Write(complexMatrix.Rows);
                writer.Write(complexMatrix.Columns);
                for (var row = 0; row < complexMatrix.Rows; row++)
                for (var column = 0; column < complexMatrix.Columns; column++)
                    WriteComplex(writer, complexMatrix[row, column]);
                break;
            case MathBlockValueKind.PointSet:
                writer.Write(value.AsPointSet().Count);
                foreach (var item in value.AsPointSet())
                {
                    writer.Write(unchecked((long)Math.ToBits(item.X)));
                    writer.Write(unchecked((long)Math.ToBits(item.Y)));
                }
                break;
            case MathBlockValueKind.Graph:
                writer.Write(value.AsGraph().VertexCount);
                writer.Write(value.AsGraph().Count);
                foreach (var item in value.AsGraph())
                {
                    writer.Write(item.From);
                    writer.Write(item.To);
                    writer.Write(unchecked((long)Math.ToBits(item.Weight)));
                }
                break;
            case MathBlockValueKind.RunSet:
                writer.Write(value.AsRunSet().Count);
                foreach (var item in value.AsRunSet())
                {
                    writer.Write(item.Start);
                    writer.Write(item.Length);
                    writer.Write(unchecked((long)Math.ToBits(item.Value)));
                }
                break;
            default:
                throw new NotSupportedException("An objective binding value kind is unsupported.");
        }
    }

    private static void WriteComplex(BinaryWriter writer, Complex value)
    {
        writer.Write(unchecked((long)Math.ToBits(value.Real)));
        writer.Write(unchecked((long)Math.ToBits(value.Imaginary)));
    }

    private static void WriteType(BinaryWriter writer, MathBlockType type)
    {
        writer.Write((int)type.Kind);
        writer.Write(type.Rows);
        writer.Write(type.Columns);
        WriteRational(writer, type.Unit.Dimension0);
        WriteRational(writer, type.Unit.Dimension1);
        WriteRational(writer, type.Unit.Dimension2);
        WriteRational(writer, type.Unit.Dimension3);
    }

    private static MathBlockType ReadType(BinaryReader reader)
    {
        var kind = (MathBlockValueKind)reader.ReadInt32();
        var rows = reader.ReadInt32();
        var columns = reader.ReadInt32();
        var unit = new MathBlockUnit(
            ReadRational(reader),
            ReadRational(reader),
            ReadRational(reader),
            ReadRational(reader));
        return new MathBlockType(kind, unit, rows, columns);
    }

    private static void WriteRational(BinaryWriter writer, MathRational value)
    {
        writer.Write(value.Numerator);
        writer.Write(value.Denominator);
    }

    private static MathRational ReadRational(BinaryReader reader) =>
        new(reader.ReadInt32(), reader.ReadInt32());
}

public sealed partial class MathBlockProgramPopulationDefinition
{
    public void ValidateStructure(MathBlockProgramStructure program)
    {
        ArgumentNullException.ThrowIfNull(program);
        for (var nodeIndex = 0; nodeIndex < program.Nodes.Count; nodeIndex++)
        {
            var node = program.Nodes[nodeIndex];
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                if ((uint)node.TerminalIndex >= (uint)allTerminals.Length)
                    throw new InvalidOperationException("A program terminal index is outside the definition.");
                var terminal = allTerminals[node.TerminalIndex];
                if (terminal.Type != node.Type ||
                    !string.Equals(terminal.Identifier, node.TerminalIdentifier, StringComparison.Ordinal))
                {
                    throw new InvalidOperationException("A program terminal does not match the definition.");
                }
                continue;
            }
            MathBlockProgramPopulationOperation? descriptor = null;
            foreach (var candidateOperation in Grammar.Operations)
            {
                if (!string.Equals(candidateOperation.Identifier, node.OperationIdentifier, StringComparison.Ordinal) ||
                    candidateOperation.Version != node.OperationVersion ||
                    candidateOperation.OutputType != node.Type ||
                    candidateOperation.InputTypes.Count != node.OperandIndexes.Count)
                {
                    continue;
                }
                var matches = true;
                for (var inputIndex = 0; inputIndex < candidateOperation.InputTypes.Count; inputIndex++)
                {
                    if (candidateOperation.InputTypes[inputIndex] !=
                        program.Nodes[node.OperandIndexes[inputIndex]].Type)
                    {
                        matches = false;
                        break;
                    }
                }
                if (!matches)
                    continue;
                if (descriptor is not null)
                    throw new InvalidOperationException("A program operation matches multiple grammar entries.");
                descriptor = candidateOperation;
            }
            if (descriptor is null)
                throw new InvalidOperationException("A program operation is outside the typed grammar.");
        }
        if (!Grammar.OutputType.Accepts(program.Nodes[^1].Type))
            throw new InvalidOperationException("The program output type does not match the grammar.");
    }

    internal void ValidateResidentStructure(MathBlockProgramStructure program)
    {
        ValidateStructure(program);
        if (program.Nodes.Count <= allTerminals.Length)
            throw new InvalidOperationException("A resident program structure requires an operation node.");
        for (var terminalIndex = 0; terminalIndex < allTerminals.Length; terminalIndex++)
        {
            var node = program.Nodes[terminalIndex];
            var terminal = allTerminals[terminalIndex];
            if (node.Kind != MathBlockProgramCandidateNodeKind.Terminal ||
                node.TerminalIndex != terminalIndex ||
                node.Type != terminal.Type ||
                !string.Equals(node.TerminalIdentifier, terminal.Identifier, StringComparison.Ordinal))
            {
                throw new InvalidOperationException("A resident program terminal does not match the population.");
            }
        }
        for (var nodeIndex = allTerminals.Length; nodeIndex < program.Nodes.Count; nodeIndex++)
            if (program.Nodes[nodeIndex].Kind != MathBlockProgramCandidateNodeKind.Operation)
                throw new InvalidOperationException("A resident program operation node is invalid.");
    }

    public MathBlockValue Evaluate(MathBlockProgramStructure program, MathBlockRegistry? registry = null)
    {
        ArgumentNullException.ThrowIfNull(program);
        ValidateStructure(program);
        registry ??= MathBlockCatalog.Standard;
        var values = new MathBlockValue[program.Nodes.Count];
        for (var nodeIndex = 0; nodeIndex < program.Nodes.Count; nodeIndex++)
        {
            var node = program.Nodes[nodeIndex];
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                if ((uint)node.TerminalIndex >= (uint)allTerminals.Length)
                    throw new InvalidOperationException("A program terminal index is outside the definition.");
                var terminal = allTerminals[node.TerminalIndex];
                if (terminal.Type != node.Type ||
                    !string.Equals(terminal.Identifier, node.TerminalIdentifier, StringComparison.Ordinal))
                {
                    throw new InvalidOperationException("A program terminal does not match the definition.");
                }
                values[nodeIndex] = terminal.Value;
                continue;
            }

            MathBlockProgramPopulationOperation? descriptor = null;
            foreach (var candidateOperation in Grammar.Operations)
            {
                if (!string.Equals(candidateOperation.Identifier, node.OperationIdentifier, StringComparison.Ordinal) ||
                    candidateOperation.Version != node.OperationVersion ||
                    candidateOperation.OutputType != node.Type ||
                    candidateOperation.InputTypes.Count != node.OperandIndexes.Count)
                {
                    continue;
                }
                var matches = true;
                for (var inputIndex = 0; inputIndex < candidateOperation.InputTypes.Count; inputIndex++)
                {
                    if (candidateOperation.InputTypes[inputIndex] !=
                        program.Nodes[node.OperandIndexes[inputIndex]].Type)
                    {
                        matches = false;
                        break;
                    }
                }
                if (!matches)
                    continue;
                if (descriptor is not null)
                    throw new InvalidOperationException("A program operation matches multiple grammar entries.");
                descriptor = candidateOperation;
            }
            if (descriptor is null)
                throw new InvalidOperationException("A program operation is outside the typed grammar.");
            var operation = registry.Get(node.OperationIdentifier!, node.OperationVersion);
            var inputs = new MathBlockValue[node.OperandIndexes.Count];
            for (var inputIndex = 0; inputIndex < inputs.Length; inputIndex++)
                inputs[inputIndex] = values[node.OperandIndexes[inputIndex]];
            values[nodeIndex] = operation.Evaluate(inputs);
            if (!values[nodeIndex].IsValid || !node.Type.Accepts(values[nodeIndex].Type))
                throw new InvalidOperationException("A program operation produced an invalid value.");
        }
        var output = values[^1];
        if (!Grammar.OutputType.Accepts(output.Type))
            throw new InvalidOperationException("The program output type does not match the grammar.");
        return output;
    }
}
