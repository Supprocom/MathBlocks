using System.Buffers.Binary;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

public sealed class MathBlockProgramPopulationOperation
{
    public MathBlockProgramPopulationOperation(
        string identifier,
        int version,
        IEnumerable<MathBlockType> inputTypes,
        MathBlockType outputType,
        long deterministicCost = 1)
    {
        Identifier = MathBlockProgramPopulationValidation.RequireIdentifier(identifier, nameof(identifier));
        if (version <= 0)
            throw new ArgumentOutOfRangeException(nameof(version));
        ArgumentNullException.ThrowIfNull(inputTypes);
        InputTypes = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(inputTypes));
        foreach (var type in InputTypes)
            MathBlockProgramPopulationValidation.RequireType(type, nameof(inputTypes));
        MathBlockProgramPopulationValidation.RequireType(outputType, nameof(outputType));
        if (deterministicCost <= 0)
            throw new ArgumentOutOfRangeException(nameof(deterministicCost));
        Version = version;
        OutputType = outputType;
        DeterministicCost = deterministicCost;
    }

    public string Identifier { get; }
    public int Version { get; }
    public string Identity => $"{Identifier}@{Version}";
    public IReadOnlyList<MathBlockType> InputTypes { get; }
    public MathBlockType OutputType { get; }
    public long DeterministicCost { get; }
}

public sealed class MathBlockProgramPopulationGrammar
{
    public MathBlockProgramPopulationGrammar(
        IEnumerable<MathBlockProgramPopulationOperation> operations,
        MathBlockType outputType)
    {
        ArgumentNullException.ThrowIfNull(operations);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(operations);
        if (copied.Length == 0)
            throw new ArgumentException("A population grammar requires an operation.", nameof(operations));
        var signatures = new HashSet<string>(StringComparer.Ordinal);
        foreach (var operation in copied)
        {
            ArgumentNullException.ThrowIfNull(operation);
            var signature = MathBlockProgramPopulationValidation.CreateOperationSignature(operation);
            if (!signatures.Add(signature))
                throw new ArgumentException("A population grammar contains a duplicate operation signature.", nameof(operations));
        }
        MathBlockProgramPopulationValidation.RequireType(outputType, nameof(outputType));
        Operations = Array.AsReadOnly(copied);
        OutputType = outputType;
    }

    public IReadOnlyList<MathBlockProgramPopulationOperation> Operations { get; }
    public MathBlockType OutputType { get; }
}

public sealed class MathBlockProgramPopulationTerminal
{
    public MathBlockProgramPopulationTerminal(
        string identifier,
        MathBlockType type,
        MathBlockValue value,
        int lookback = 0)
    {
        Identifier = MathBlockProgramPopulationValidation.RequireName(identifier, nameof(identifier));
        MathBlockProgramPopulationValidation.RequireType(type, nameof(type));
        if (!value.IsValid)
            throw new ArgumentException("A population terminal must be valid.", nameof(value));
        if (!type.Accepts(value.Type))
            throw new ArgumentException("A population terminal value does not match its declared type.", nameof(value));
        MathBlockProgramPopulationValidation.RequireFiniteValue(value, nameof(value));
        if (lookback < 0)
            throw new ArgumentOutOfRangeException(nameof(lookback));
        Type = type;
        Value = value;
        Lookback = lookback;
    }

    public string Identifier { get; }
    public MathBlockType Type { get; }
    public MathBlockValue Value { get; }
    public int Lookback { get; }
}

public readonly record struct MathBlockProgramPopulationConstant
{
    public MathBlockProgramPopulationConstant(long bits, MathBlockUnit unit = default)
    {
        var value = Math.FromBits(unchecked((ulong)bits));
        if (!Math.IsFinite(value))
            throw new ArgumentOutOfRangeException(nameof(bits), "A population constant must be finite.");
        Bits = bits;
        Unit = unit;
    }

    public long Bits { get; }
    public MathBlockUnit Unit { get; }
    public double Value => Math.FromBits(unchecked((ulong)Bits));
}

public readonly record struct MathBlockProgramPopulationResourceBand
{
    public MathBlockProgramPopulationResourceBand(int operationCount, int maximumOutputElements)
    {
        if (operationCount <= 0)
            throw new ArgumentOutOfRangeException(nameof(operationCount));
        if (maximumOutputElements <= 0)
            throw new ArgumentOutOfRangeException(nameof(maximumOutputElements));
        OperationCount = operationCount;
        MaximumOutputElements = maximumOutputElements;
    }

    public int OperationCount { get; }
    public int MaximumOutputElements { get; }
}

public sealed partial class MathBlockProgramPopulationDefinition
{
    private readonly MathBlockProgramPopulationTerminal[] allTerminals;
    private readonly ReadOnlyCollection<ulong> proposalBandStarts;
    private readonly ReadOnlyCollection<ulong> proposalBandCounts;

    public MathBlockProgramPopulationDefinition(
        MathBlockProgramPopulationGrammar grammar,
        IEnumerable<MathBlockProgramPopulationTerminal> terminals,
        IEnumerable<MathBlockProgramPopulationConstant> scalarConstants,
        IEnumerable<MathBlockProgramPopulationResourceBand> activeResourceBands,
        int proposalsPerCycle,
        int fingerprintCapacity,
        MathBlockProgramPopulationState? acceptedState = null)
    {
        Grammar = grammar ?? throw new ArgumentNullException(nameof(grammar));
        ArgumentNullException.ThrowIfNull(terminals);
        ArgumentNullException.ThrowIfNull(scalarConstants);
        ArgumentNullException.ThrowIfNull(activeResourceBands);

        var terminalCopy = MathBlockCollectionPrimitives.CopyEnumerable(terminals);
        var names = new HashSet<string>(StringComparer.Ordinal);
        foreach (var terminal in terminalCopy)
        {
            ArgumentNullException.ThrowIfNull(terminal);
            if (!names.Add(terminal.Identifier))
                throw new ArgumentException("A population terminal identifier is duplicated.", nameof(terminals));
        }
        var constantCopy = MathBlockCollectionPrimitives.CopyEnumerable(scalarConstants);
        var totalTerminalCount = checked(terminalCopy.Length + constantCopy.Length);
        if (totalTerminalCount == 0)
            throw new ArgumentException("A population definition requires a terminal or scalar constant.", nameof(terminals));

        var bandCopy = MathBlockCollectionPrimitives.CopyEnumerable(activeResourceBands);
        if (bandCopy.Length == 0)
            throw new ArgumentException("A population definition requires an active resource band.", nameof(activeResourceBands));
        var operationCounts = new HashSet<int>();
        foreach (var band in bandCopy)
            if (!operationCounts.Add(band.OperationCount))
                throw new ArgumentException("An active resource-band operation count is duplicated.", nameof(activeResourceBands));
        if (proposalsPerCycle <= 0)
            throw new ArgumentOutOfRangeException(nameof(proposalsPerCycle));
        if (fingerprintCapacity <= 0)
            throw new ArgumentOutOfRangeException(nameof(fingerprintCapacity));

        Terminals = Array.AsReadOnly(terminalCopy);
        ScalarConstants = Array.AsReadOnly(constantCopy);
        ActiveResourceBands = Array.AsReadOnly(bandCopy);
        ProposalsPerCycle = proposalsPerCycle;
        FingerprintCapacity = fingerprintCapacity;

        allTerminals = new MathBlockProgramPopulationTerminal[totalTerminalCount];
        for (var index = 0; index < terminalCopy.Length; index++)
            allTerminals[index] = terminalCopy[index];
        for (var index = 0; index < constantCopy.Length; index++)
        {
            var constant = constantCopy[index];
            var identifier = $"constant-{index}";
            if (!names.Add(identifier))
                throw new ArgumentException("A population terminal uses a reserved constant identifier.", nameof(terminals));
            allTerminals[terminalCopy.Length + index] = new MathBlockProgramPopulationTerminal(
                identifier,
                MathBlockType.Scalar(constant.Unit),
                MathBlockValue.Scalar(constant.Value, constant.Unit));
        }

        var proposalSpace = MathBlockProgramPopulationValidation.CalculateProposalSpace(
            Grammar.Operations,
            allTerminals.Length,
            ActiveResourceBands);
        TotalProposalCount = proposalSpace.TotalCount;
        IsTotalProposalCountExact = proposalSpace.IsExact;
        proposalBandStarts = Array.AsReadOnly(proposalSpace.BandStarts);
        proposalBandCounts = Array.AsReadOnly(proposalSpace.BandCounts);

        Identity = MathBlockProgramPopulationValidation.CreateDefinitionIdentity(
            Grammar,
            Terminals,
            ScalarConstants,
            ActiveResourceBands,
            proposalsPerCycle,
            fingerprintCapacity);
        if (acceptedState is not null)
        {
            if (!string.Equals(acceptedState.Identity, Identity, StringComparison.Ordinal))
                throw new InvalidOperationException("The accepted population state has an incompatible identity.");
            if (acceptedState.AcceptedCursor > TotalProposalCount)
                throw new InvalidOperationException("The accepted population cursor is outside the proposal range.");
            if (acceptedState.StructuralFingerprints.Count > fingerprintCapacity ||
                acceptedState.SemanticFingerprints.Count > fingerprintCapacity)
            {
                throw new InvalidOperationException("The accepted population state exceeds fingerprint capacity.");
            }
        }
        AcceptedState = acceptedState;
    }

    public MathBlockProgramPopulationGrammar Grammar { get; }
    public IReadOnlyList<MathBlockProgramPopulationTerminal> Terminals { get; }
    public IReadOnlyList<MathBlockProgramPopulationConstant> ScalarConstants { get; }
    public IReadOnlyList<MathBlockProgramPopulationResourceBand> ActiveResourceBands { get; }
    public int ProposalsPerCycle { get; }
    public int FingerprintCapacity { get; }
    public ulong TotalProposalCount { get; }
    public bool IsTotalProposalCountExact { get; }
    public string Identity { get; }
    public MathBlockProgramPopulationState? AcceptedState { get; }

    internal IReadOnlyList<MathBlockProgramPopulationTerminal> AllTerminals => allTerminals;
    internal IReadOnlyList<ulong> ProposalBandStarts => proposalBandStarts;
    internal IReadOnlyList<ulong> ProposalBandCounts => proposalBandCounts;

    public MathBlockValue Evaluate(MathBlockProgramCandidate candidate, MathBlockRegistry? registry = null)
    {
        ArgumentNullException.ThrowIfNull(candidate);
        registry ??= MathBlockCatalog.Standard;
        var values = new MathBlockValue[candidate.Nodes.Count];
        for (var nodeIndex = 0; nodeIndex < candidate.Nodes.Count; nodeIndex++)
        {
            var node = candidate.Nodes[nodeIndex];
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                if ((uint)node.TerminalIndex >= (uint)allTerminals.Length)
                    throw new InvalidOperationException("A candidate terminal index is outside the definition.");
                var terminal = allTerminals[node.TerminalIndex];
                if (terminal.Type != node.Type)
                    throw new InvalidOperationException("A candidate terminal type does not match the definition.");
                values[nodeIndex] = terminal.Value;
                continue;
            }

            MathBlockProgramPopulationOperation? descriptor = null;
            foreach (var candidateOperation in Grammar.Operations)
            {
                if (!string.Equals(
                        candidateOperation.Identifier,
                        node.OperationIdentifier,
                        StringComparison.Ordinal) ||
                    candidateOperation.Version != node.OperationVersion ||
                    candidateOperation.OutputType != node.Type ||
                    candidateOperation.InputTypes.Count != node.OperandIndexes.Count)
                {
                    continue;
                }
                var inputTypesMatch = true;
                for (var inputIndex = 0; inputIndex < candidateOperation.InputTypes.Count; inputIndex++)
                {
                    if (candidateOperation.InputTypes[inputIndex] ==
                        candidate.Nodes[node.OperandIndexes[inputIndex]].Type)
                    {
                        continue;
                    }
                    inputTypesMatch = false;
                    break;
                }
                if (!inputTypesMatch)
                    continue;
                if (descriptor is not null)
                    throw new InvalidOperationException("A candidate operation matches more than one grammar entry.");
                descriptor = candidateOperation;
            }
            if (descriptor is null)
                throw new InvalidOperationException("A candidate operation is outside the typed grammar.");
            var operation = registry.Get(node.OperationIdentifier!, node.OperationVersion);
            var inputs = new MathBlockValue[node.OperandIndexes.Count];
            for (var inputIndex = 0; inputIndex < inputs.Length; inputIndex++)
                inputs[inputIndex] = values[node.OperandIndexes[inputIndex]];
            values[nodeIndex] = operation.Evaluate(inputs);
            if (!values[nodeIndex].IsValid)
                throw new InvalidOperationException("CPU reference execution produced an invalid value.");
            if (!node.Type.Accepts(values[nodeIndex].Type))
                throw new InvalidOperationException("A candidate operation output does not match its declared type.");
        }
        return values[^1];
    }
}

public enum MathBlockProgramCandidateNodeKind
{
    Terminal,
    Operation
}

public sealed class MathBlockProgramCandidateNode
{
    private MathBlockProgramCandidateNode(
        MathBlockProgramCandidateNodeKind kind,
        MathBlockType type,
        int terminalIndex,
        string? terminalIdentifier,
        string? operationIdentifier,
        int operationVersion,
        int[] operandIndexes)
    {
        MathBlockProgramPopulationValidation.RequireType(type, nameof(type));
        Kind = kind;
        Type = type;
        TerminalIndex = terminalIndex;
        TerminalIdentifier = terminalIdentifier;
        OperationIdentifier = operationIdentifier;
        OperationVersion = operationVersion;
        OperandIndexes = Array.AsReadOnly(operandIndexes);
    }

    public MathBlockProgramCandidateNodeKind Kind { get; }
    public MathBlockType Type { get; }
    public int TerminalIndex { get; }
    public string? TerminalIdentifier { get; }
    public string? OperationIdentifier { get; }
    public int OperationVersion { get; }
    public IReadOnlyList<int> OperandIndexes { get; }
    public string? OperationIdentity => Kind == MathBlockProgramCandidateNodeKind.Operation
        ? $"{OperationIdentifier}@{OperationVersion}"
        : null;

    public static MathBlockProgramCandidateNode Terminal(int terminalIndex, string identifier, MathBlockType type)
    {
        if (terminalIndex < 0)
            throw new ArgumentOutOfRangeException(nameof(terminalIndex));
        return new MathBlockProgramCandidateNode(
            MathBlockProgramCandidateNodeKind.Terminal,
            type,
            terminalIndex,
            MathBlockProgramPopulationValidation.RequireName(identifier, nameof(identifier)),
            null,
            0,
            []);
    }

    public static MathBlockProgramCandidateNode Operation(
        string identifier,
        int version,
        MathBlockType type,
        params int[] operandIndexes)
    {
        if (version <= 0)
            throw new ArgumentOutOfRangeException(nameof(version));
        ArgumentNullException.ThrowIfNull(operandIndexes);
        return new MathBlockProgramCandidateNode(
            MathBlockProgramCandidateNodeKind.Operation,
            type,
            -1,
            null,
            MathBlockProgramPopulationValidation.RequireIdentifier(identifier, nameof(identifier)),
            version,
            MathBlockCollectionPrimitives.Copy(operandIndexes));
    }
}

public sealed class MathBlockProgramCandidate
{
    public MathBlockProgramCandidate(
        ulong proposalCursor,
        IEnumerable<MathBlockProgramCandidateNode> nodes,
        MathBlockValue output)
    {
        ArgumentNullException.ThrowIfNull(nodes);
        var copied = MathBlockCollectionPrimitives.CopyEnumerable(nodes);
        if (copied.Length == 0)
            throw new ArgumentException("A candidate requires a node.", nameof(nodes));
        for (var nodeIndex = 0; nodeIndex < copied.Length; nodeIndex++)
        {
            var node = copied[nodeIndex] ?? throw new ArgumentException("A candidate node is null.", nameof(nodes));
            if (node.Kind != MathBlockProgramCandidateNodeKind.Operation)
                continue;
            foreach (var operandIndex in node.OperandIndexes)
                if (operandIndex < 0 || operandIndex >= nodeIndex)
                    throw new ArgumentException("A candidate operand must reference an earlier node.", nameof(nodes));
        }
        if (!output.IsValid)
            throw new ArgumentException("A candidate output must be valid.", nameof(output));
        if (!copied[^1].Type.Accepts(output.Type))
            throw new ArgumentException("A candidate output does not match its final node type.", nameof(output));
        MathBlockProgramPopulationValidation.RequireFiniteValue(output, nameof(output));

        ProposalCursor = proposalCursor;
        Nodes = Array.AsReadOnly(copied);
        Output = output;
        StructuralFingerprint = MathBlockProgramPopulationFingerprint.CreateStructural(copied);
        SemanticFingerprint = MathBlockProgramPopulationFingerprint.CreateSemantic(output);
    }

    public ulong ProposalCursor { get; }
    public IReadOnlyList<MathBlockProgramCandidateNode> Nodes { get; }
    public MathBlockValue Output { get; }
    public string StructuralFingerprint { get; }
    public string SemanticFingerprint { get; }
}

public sealed class MathBlockProgramPopulationState
{
    internal MathBlockProgramPopulationState(
        string identity,
        ulong acceptedCursor,
        ulong structuralDuplicateCount,
        ulong semanticDuplicateCount,
        ulong evaluatedProgramCount,
        IEnumerable<string> structuralFingerprints,
        IEnumerable<string> semanticFingerprints)
    {
        Identity = MathBlockProgramPopulationValidation.RequireFingerprint(identity, nameof(identity), 64);
        ArgumentNullException.ThrowIfNull(structuralFingerprints);
        ArgumentNullException.ThrowIfNull(semanticFingerprints);
        var structuralCopy = MathBlockCollectionPrimitives.CopyEnumerable(structuralFingerprints);
        for (var index = 0; index < structuralCopy.Length; index++)
        {
            structuralCopy[index] = MathBlockProgramPopulationValidation.RequireFingerprint(
                structuralCopy[index],
                nameof(structuralFingerprints),
                32);
        }
        var semanticCopy = MathBlockCollectionPrimitives.CopyEnumerable(semanticFingerprints);
        for (var index = 0; index < semanticCopy.Length; index++)
        {
            semanticCopy[index] = MathBlockProgramPopulationValidation.RequireFingerprint(
                semanticCopy[index],
                nameof(semanticFingerprints),
                32);
        }
        StructuralFingerprints = Array.AsReadOnly(structuralCopy);
        SemanticFingerprints = Array.AsReadOnly(semanticCopy);
        AcceptedCursor = acceptedCursor;
        StructuralDuplicateCount = structuralDuplicateCount;
        SemanticDuplicateCount = semanticDuplicateCount;
        EvaluatedProgramCount = evaluatedProgramCount;
    }

    public string Identity { get; }
    public ulong AcceptedCursor { get; }
    public ulong StructuralDuplicateCount { get; }
    public ulong SemanticDuplicateCount { get; }
    public ulong EvaluatedProgramCount { get; }
    public IReadOnlyList<string> StructuralFingerprints { get; }
    public IReadOnlyList<string> SemanticFingerprints { get; }

    public byte[] Export()
    {
        using var stream = new MemoryStream();
        using (var writer = new BinaryWriter(stream, Encoding.UTF8, leaveOpen: true))
        {
            writer.Write("mathblocks-population-state-v1");
            writer.Write(Identity);
            writer.Write(AcceptedCursor);
            writer.Write(StructuralDuplicateCount);
            writer.Write(SemanticDuplicateCount);
            writer.Write(EvaluatedProgramCount);
            writer.Write(StructuralFingerprints.Count);
            foreach (var fingerprint in StructuralFingerprints)
                writer.Write(fingerprint);
            writer.Write(SemanticFingerprints.Count);
            foreach (var fingerprint in SemanticFingerprints)
                writer.Write(fingerprint);
        }
        var payload = stream.ToArray();
        var hash = SHA256.HashData(payload);
        var result = new byte[checked(payload.Length + hash.Length)];
        payload.CopyTo(result, 0);
        hash.CopyTo(result, payload.Length);
        return result;
    }

    public static MathBlockProgramPopulationState Import(ReadOnlySpan<byte> data)
    {
        if (data.Length <= 32 || data.Length > 128 * 1024 * 1024)
            throw new InvalidDataException("The population state length is invalid.");
        var payload = data[..^32];
        var expectedHash = data[^32..];
        var actualHash = SHA256.HashData(payload);
        if (!CryptographicOperations.FixedTimeEquals(actualHash, expectedHash))
            throw new InvalidDataException("The population state checksum is invalid.");
        using var stream = new MemoryStream(payload.ToArray(), writable: false);
        using var reader = new BinaryReader(stream, Encoding.UTF8, leaveOpen: false);
        if (!string.Equals(reader.ReadString(), "mathblocks-population-state-v1", StringComparison.Ordinal))
            throw new InvalidDataException("The population state schema is unsupported.");
        var identity = reader.ReadString();
        var cursor = reader.ReadUInt64();
        var structuralDuplicates = reader.ReadUInt64();
        var semanticDuplicates = reader.ReadUInt64();
        var evaluated = reader.ReadUInt64();
        var structural = ReadFingerprints(reader);
        var semantic = ReadFingerprints(reader);
        if (stream.Position != stream.Length)
            throw new InvalidDataException("The population state has trailing data.");
        return new MathBlockProgramPopulationState(
            identity,
            cursor,
            structuralDuplicates,
            semanticDuplicates,
            evaluated,
            structural,
            semantic);
    }

    private static string[] ReadFingerprints(BinaryReader reader)
    {
        var count = reader.ReadInt32();
        if (count < 0 || count > reader.BaseStream.Length)
            throw new InvalidDataException("The population fingerprint count is invalid.");
        var values = new string[count];
        for (var index = 0; index < count; index++)
            values[index] = reader.ReadString();
        return values;
    }
}

public readonly record struct MathBlockProgramPopulationInstrumentation(
    long GraphInstanceCount,
    long UploadCount,
    long GraphLaunchCount,
    long SynchronizationCount,
    long DownloadCount,
    long ResidentBytes,
    ulong StructuralDuplicateCount,
    ulong SemanticDuplicateCount,
    ulong EvaluatedProgramCount,
    ulong AcceptedCursor,
    int CpuNodeDispatchCount);

public sealed class MathBlockProgramPopulationCycleResult
{
    internal MathBlockProgramPopulationCycleResult(
        IEnumerable<MathBlockProgramCandidate> candidates,
        MathBlockProgramPopulationState acceptedState,
        MathBlockProgramPopulationInstrumentation instrumentation,
        bool isComplete)
    {
        Candidates = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(candidates));
        AcceptedState = acceptedState;
        Instrumentation = instrumentation;
        IsComplete = isComplete;
    }

    public IReadOnlyList<MathBlockProgramCandidate> Candidates { get; }
    public MathBlockProgramPopulationState AcceptedState { get; }
    public MathBlockProgramPopulationInstrumentation Instrumentation { get; }
    public bool IsComplete { get; }
}

internal static class MathBlockProgramPopulationFingerprint
{
    private const ulong OffsetA = 14695981039346656037ul;
    private const ulong PrimeA = 1099511628211ul;
    private const ulong OffsetB = 7809847782465536322ul;
    private const ulong PrimeB = 14029467366897019727ul;

    public static string CreateStructural(IReadOnlyList<MathBlockProgramCandidateNode> nodes)
    {
        var state = new FingerprintState();
        var operationCount = 0;
        for (var index = 0; index < nodes.Count; index++)
            if (nodes[index].Kind == MathBlockProgramCandidateNodeKind.Operation)
                operationCount++;
        state.Add(unchecked((ulong)operationCount));
        foreach (var node in nodes)
        {
            if (node.Kind != MathBlockProgramCandidateNodeKind.Operation)
                continue;
            var operationKey = CreateOperationKey(node.OperationIdentity!);
            state.Add(operationKey.First);
            state.Add(operationKey.Second);
            state.Add(unchecked((ulong)node.OperandIndexes.Count));
            foreach (var operandIndex in node.OperandIndexes)
                state.Add(unchecked((ulong)operandIndex));
        }
        return state.ToString();
    }

    public static string CreateSemantic(MathBlockValue value)
    {
        var state = new FingerprintState();
        AddType(ref state, value.Type);
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                state.Add(Math.ToBits(value.AsScalar()));
                break;
            case MathBlockValueKind.Boolean:
                state.Add(value.AsBoolean() ? 1ul : 0ul);
                break;
            case MathBlockValueKind.Vector:
                foreach (var item in value.AsVector())
                    state.Add(Math.ToBits(item));
                break;
            case MathBlockValueKind.BooleanVector:
                foreach (var item in value.AsBooleanVector())
                    state.Add(item ? 1ul : 0ul);
                break;
            default:
                throw new NotSupportedException("The population fingerprint does not support this value kind.");
        }
        return state.ToString();
    }

    public static string CreateSemantic(
        MathBlockValue value,
        IReadOnlyList<bool> validityMask,
        int maximumLookback)
    {
        ArgumentNullException.ThrowIfNull(validityMask);
        if (maximumLookback < 0)
            throw new ArgumentOutOfRangeException(nameof(maximumLookback));
        var rowCount = value.Type.Kind switch
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
            _ => throw new NotSupportedException("The population fingerprint does not support this value kind.")
        };
        if (validityMask.Count != rowCount)
            throw new ArgumentException("The semantic validity mask has an incompatible row count.", nameof(validityMask));

        var state = new FingerprintState();
        state.Add(unchecked((ulong)(int)value.Type.Kind));
        var actualRows = value.Type.Kind switch
        {
            MathBlockValueKind.Matrix => value.AsMatrix().Rows,
            MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Rows,
            MathBlockValueKind.Graph => value.AsGraph().VertexCount,
            _ => value.Type.Rows
        };
        state.Add(unchecked((ulong)actualRows));
        var columns = value.Type.Kind switch
        {
            MathBlockValueKind.Matrix => value.AsMatrix().Columns,
            MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Columns,
            _ => value.Type.Columns
        };
        state.Add(unchecked((ulong)columns));
        AddUnit(ref state, value.Type.Unit);
        state.Add(unchecked((ulong)maximumLookback));
        var validRows = 0;
        for (var row = 0; row < validityMask.Count; row++)
            if (validityMask[row])
                validRows++;
        state.Add(unchecked((ulong)validRows));
        AddMaskedValue(ref state, value, validityMask);
        return state.ToString();
    }

    public static (ulong First, ulong Second) CreateOperationKey(string identity)
    {
        var state = new FingerprintState();
        foreach (var value in Encoding.UTF8.GetBytes(identity))
            state.AddByte(value);
        return (state.First, state.Second);
    }

    public static (ulong First, ulong Second) Parse(string value)
    {
        MathBlockProgramPopulationValidation.RequireFingerprint(value, nameof(value), 32);
        return (
            ulong.Parse(value.AsSpan(0, 16), NumberStyles.HexNumber, CultureInfo.InvariantCulture),
            ulong.Parse(value.AsSpan(16, 16), NumberStyles.HexNumber, CultureInfo.InvariantCulture));
    }

    public static string Format(ulong first, ulong second) => $"{first:x16}{second:x16}";

    private static void AddType(ref FingerprintState state, MathBlockType type)
    {
        state.Add(unchecked((ulong)(int)type.Kind));
        state.Add(unchecked((ulong)type.Rows));
        state.Add(unchecked((ulong)type.Columns));
        AddRational(ref state, type.Unit.Dimension0);
        AddRational(ref state, type.Unit.Dimension1);
        AddRational(ref state, type.Unit.Dimension2);
        AddRational(ref state, type.Unit.Dimension3);
    }

    private static void AddUnit(ref FingerprintState state, MathBlockUnit unit)
    {
        AddRational(ref state, unit.Dimension0);
        AddRational(ref state, unit.Dimension1);
        AddRational(ref state, unit.Dimension2);
        AddRational(ref state, unit.Dimension3);
    }

    private static void AddMaskedValue(
        ref FingerprintState state,
        MathBlockValue value,
        IReadOnlyList<bool> mask)
    {
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                if (mask[0])
                    state.Add(Math.ToBits(value.AsScalar()));
                return;
            case MathBlockValueKind.Boolean:
                if (mask[0])
                    state.Add(value.AsBoolean() ? 1ul : 0ul);
                return;
            case MathBlockValueKind.Complex:
                if (mask[0])
                {
                    state.Add(Math.ToBits(value.AsComplex().Real));
                    state.Add(Math.ToBits(value.AsComplex().Imaginary));
                }
                return;
            case MathBlockValueKind.Vector:
                for (var row = 0; row < mask.Count; row++)
                {
                    if (!mask[row])
                        continue;
                    state.Add(unchecked((ulong)row));
                    state.Add(Math.ToBits(value.AsVector()[row]));
                }
                return;
            case MathBlockValueKind.BooleanVector:
                for (var row = 0; row < mask.Count; row++)
                {
                    if (!mask[row])
                        continue;
                    state.Add(unchecked((ulong)row));
                    state.Add(value.AsBooleanVector()[row] ? 1ul : 0ul);
                }
                return;
            case MathBlockValueKind.ComplexVector:
                for (var row = 0; row < mask.Count; row++)
                {
                    if (!mask[row])
                        continue;
                    var item = value.AsComplexVector()[row];
                    state.Add(unchecked((ulong)row));
                    state.Add(Math.ToBits(item.Real));
                    state.Add(Math.ToBits(item.Imaginary));
                }
                return;
            case MathBlockValueKind.PointSet:
                for (var row = 0; row < mask.Count; row++)
                {
                    if (!mask[row])
                        continue;
                    var item = value.AsPointSet()[row];
                    state.Add(unchecked((ulong)row));
                    state.Add(Math.ToBits(item.X));
                    state.Add(Math.ToBits(item.Y));
                }
                return;
            case MathBlockValueKind.Matrix:
                var matrix = value.AsMatrix();
                for (var row = 0; row < mask.Count; row++)
                {
                    if (!mask[row])
                        continue;
                    state.Add(unchecked((ulong)row));
                    for (var column = 0; column < matrix.Columns; column++)
                        state.Add(Math.ToBits(matrix[row, column]));
                }
                return;
            case MathBlockValueKind.ComplexMatrix:
                var complexMatrix = value.AsComplexMatrix();
                for (var row = 0; row < mask.Count; row++)
                {
                    if (!mask[row])
                        continue;
                    state.Add(unchecked((ulong)row));
                    for (var column = 0; column < complexMatrix.Columns; column++)
                    {
                        var item = complexMatrix[row, column];
                        state.Add(Math.ToBits(item.Real));
                        state.Add(Math.ToBits(item.Imaginary));
                    }
                }
                return;
            case MathBlockValueKind.Graph:
                if (HasValidRow(mask))
                {
                    foreach (var edge in value.AsGraph())
                    {
                        state.Add(unchecked((uint)edge.From) | (unchecked((ulong)(uint)edge.To) << 32));
                        state.Add(Math.ToBits(edge.Weight));
                    }
                }
                return;
            case MathBlockValueKind.RunSet:
                if (HasValidRow(mask))
                {
                    foreach (var run in value.AsRunSet())
                    {
                        state.Add(unchecked((uint)run.Start) | (unchecked((ulong)(uint)run.Length) << 32));
                        state.Add(Math.ToBits(run.Value));
                    }
                }
                return;
            default:
                throw new NotSupportedException("The population fingerprint does not support this value kind.");
        }
    }

    private static bool HasValidRow(IReadOnlyList<bool> mask)
    {
        for (var index = 0; index < mask.Count; index++)
            if (mask[index])
                return true;
        return false;
    }

    private static void AddRational(ref FingerprintState state, MathRational value)
    {
        state.Add(unchecked((ulong)value.Numerator));
        state.Add(unchecked((ulong)value.Denominator));
    }

    private struct FingerprintState
    {
        public ulong First = OffsetA;
        public ulong Second = OffsetB;

        public FingerprintState()
        {
        }

        public void Add(ulong value)
        {
            Span<byte> bytes = stackalloc byte[sizeof(ulong)];
            BinaryPrimitives.WriteUInt64LittleEndian(bytes, value);
            foreach (var item in bytes)
                AddByte(item);
        }

        public void AddByte(byte value)
        {
            First = unchecked((First ^ value) * PrimeA);
            Second = unchecked((Second ^ value) * PrimeB);
        }

        public override readonly string ToString() => Format(First, Second);
    }
}

internal static class MathBlockProgramPopulationValidation
{
    public static string RequireIdentifier(string value, string parameterName)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("An operation identifier is required.", parameterName);
        value = value.Trim();
        foreach (var character in value)
            if (!(character is >= 'a' and <= 'z' || character is >= '0' and <= '9' || character is '.' or '-'))
                throw new ArgumentException("An operation identifier contains an unsupported character.", parameterName);
        return value;
    }

    public static string RequireName(string value, string parameterName)
    {
        if (string.IsNullOrWhiteSpace(value))
            throw new ArgumentException("A nonempty name is required.", parameterName);
        return value.Trim();
    }

    public static void RequireType(MathBlockType type, string parameterName)
    {
        if (!Enum.IsDefined(type.Kind) || type.Rows < 0 || type.Columns < 0)
            throw new ArgumentOutOfRangeException(parameterName);
    }

    public static string RequireFingerprint(string value, string parameterName, int length)
    {
        if (value is null || value.Length != length)
            throw new ArgumentException("A fingerprint is invalid.", parameterName);
        foreach (var character in value)
            if (!Uri.IsHexDigit(character))
                throw new ArgumentException("A fingerprint is invalid.", parameterName);
        return value.ToLowerInvariant();
    }

    public static string CreateOperationSignature(MathBlockProgramPopulationOperation operation)
    {
        var builder = new StringBuilder(operation.Identity);
        foreach (var type in operation.InputTypes)
            builder.Append('|').Append(type);
        return builder.Append("->").Append(operation.OutputType).ToString();
    }

    public static (
        ulong TotalCount,
        bool IsExact,
        ulong[] BandStarts,
        ulong[] BandCounts) CalculateProposalSpace(
        IReadOnlyList<MathBlockProgramPopulationOperation> operations,
        int terminalCount,
        IReadOnlyList<MathBlockProgramPopulationResourceBand> bands)
    {
        var bandStarts = new ulong[bands.Count];
        var bandCounts = new ulong[bands.Count];
        ulong total = 0;
        var exact = true;
        for (var bandIndex = 0; bandIndex < bands.Count; bandIndex++)
        {
            bandStarts[bandIndex] = total;
            var bandExact = true;
            ulong bandCount = 1;
            var band = bands[bandIndex];
            for (var nodeIndex = 0; nodeIndex < band.OperationCount; nodeIndex++)
            {
                var available = checked((ulong)(terminalCount + nodeIndex));
                ulong choices = 0;
                foreach (var operation in operations)
                    choices = SaturatingAdd(
                        choices,
                        SaturatingPow(available, operation.InputTypes.Count, ref bandExact),
                        ref bandExact);
                bandCount = SaturatingMultiply(bandCount, choices, ref bandExact);
            }

            var remaining = ulong.MaxValue - total;
            if (!bandExact || bandCount > remaining)
                exact = false;
            bandCounts[bandIndex] = bandCount > remaining ? remaining : bandCount;
            total += bandCounts[bandIndex];
        }
        return (total, exact, bandStarts, bandCounts);
    }

    public static string CreateDefinitionIdentity(
        MathBlockProgramPopulationGrammar grammar,
        IReadOnlyList<MathBlockProgramPopulationTerminal> terminals,
        IReadOnlyList<MathBlockProgramPopulationConstant> constants,
        IReadOnlyList<MathBlockProgramPopulationResourceBand> bands,
        int proposalsPerCycle,
        int fingerprintCapacity)
    {
        using var stream = new MemoryStream();
        using var writer = new BinaryWriter(stream, Encoding.UTF8, leaveOpen: true);
        writer.Write("mathblocks-program-population-v1");
        WriteType(writer, grammar.OutputType);
        writer.Write(grammar.Operations.Count);
        foreach (var operation in grammar.Operations)
        {
            writer.Write(operation.Identifier);
            writer.Write(operation.Version);
            writer.Write(operation.DeterministicCost);
            writer.Write(operation.InputTypes.Count);
            foreach (var type in operation.InputTypes)
                WriteType(writer, type);
            WriteType(writer, operation.OutputType);
        }
        writer.Write(terminals.Count);
        foreach (var terminal in terminals)
        {
            writer.Write(terminal.Identifier);
            writer.Write(terminal.Lookback);
            WriteType(writer, terminal.Type);
            WriteValue(writer, terminal.Value);
        }
        writer.Write(constants.Count);
        foreach (var constant in constants)
        {
            writer.Write(constant.Bits);
            WriteUnit(writer, constant.Unit);
        }
        writer.Write(bands.Count);
        foreach (var band in bands)
        {
            writer.Write(band.OperationCount);
            writer.Write(band.MaximumOutputElements);
        }
        writer.Write(proposalsPerCycle);
        writer.Write(fingerprintCapacity);
        return Convert.ToHexString(SHA256.HashData(stream.ToArray())).ToLowerInvariant();
    }

    public static bool ValuesAreBitwiseEqual(MathBlockValue left, MathBlockValue right)
    {
        if (left.Type != right.Type || left.IsValid != right.IsValid)
            return false;
        if (!left.IsValid)
            return string.Equals(left.InvalidReason, right.InvalidReason, StringComparison.Ordinal);
        using var leftStream = new MemoryStream();
        using var leftWriter = new BinaryWriter(leftStream, Encoding.UTF8, leaveOpen: true);
        WriteValue(leftWriter, left);
        using var rightStream = new MemoryStream();
        using var rightWriter = new BinaryWriter(rightStream, Encoding.UTF8, leaveOpen: true);
        WriteValue(rightWriter, right);
        return leftStream.GetBuffer().AsSpan(0, checked((int)leftStream.Length)).SequenceEqual(
            rightStream.GetBuffer().AsSpan(0, checked((int)rightStream.Length)));
    }

    public static void RequireFiniteValue(MathBlockValue value, string parameterName)
    {
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                if (!Math.IsFinite(value.AsScalar()))
                    throw new ArgumentOutOfRangeException(parameterName, "A population value must be finite.");
                return;
            case MathBlockValueKind.Boolean:
            case MathBlockValueKind.BooleanVector:
                return;
            case MathBlockValueKind.Vector:
                foreach (var item in value.AsVector())
                    if (!Math.IsFinite(item))
                        throw new ArgumentOutOfRangeException(parameterName, "A population value must be finite.");
                return;
            case MathBlockValueKind.Matrix:
                var matrix = value.AsMatrix();
                for (var row = 0; row < matrix.Rows; row++)
                for (var column = 0; column < matrix.Columns; column++)
                    RequireFinite(matrix[row, column], parameterName);
                return;
            case MathBlockValueKind.Complex:
                RequireFinite(value.AsComplex().Real, parameterName);
                RequireFinite(value.AsComplex().Imaginary, parameterName);
                return;
            case MathBlockValueKind.ComplexVector:
                foreach (var item in value.AsComplexVector())
                {
                    RequireFinite(item.Real, parameterName);
                    RequireFinite(item.Imaginary, parameterName);
                }
                return;
            case MathBlockValueKind.ComplexMatrix:
                var complexMatrix = value.AsComplexMatrix();
                for (var row = 0; row < complexMatrix.Rows; row++)
                for (var column = 0; column < complexMatrix.Columns; column++)
                {
                    var item = complexMatrix[row, column];
                    RequireFinite(item.Real, parameterName);
                    RequireFinite(item.Imaginary, parameterName);
                }
                return;
            case MathBlockValueKind.PointSet:
                foreach (var item in value.AsPointSet())
                {
                    RequireFinite(item.X, parameterName);
                    RequireFinite(item.Y, parameterName);
                }
                return;
            case MathBlockValueKind.Graph:
                foreach (var item in value.AsGraph())
                    RequireFinite(item.Weight, parameterName);
                return;
            case MathBlockValueKind.RunSet:
                foreach (var item in value.AsRunSet())
                    RequireFinite(item.Value, parameterName);
                return;
            default:
                throw new NotSupportedException("A population terminal has an unsupported value kind.");
        }
    }

    private static void RequireFinite(double value, string parameterName)
    {
        if (!Math.IsFinite(value))
            throw new ArgumentOutOfRangeException(parameterName, "A population value must be finite.");
    }

    private static ulong SaturatingPow(ulong value, int exponent, ref bool exact)
    {
        ulong result = 1;
        for (var index = 0; index < exponent; index++)
            result = SaturatingMultiply(result, value, ref exact);
        return result;
    }

    private static ulong SaturatingAdd(ulong first, ulong second, ref bool exact)
    {
        if (ulong.MaxValue - first >= second)
            return first + second;
        exact = false;
        return ulong.MaxValue;
    }

    private static ulong SaturatingMultiply(ulong first, ulong second, ref bool exact)
    {
        if (first == 0 || second <= ulong.MaxValue / first)
            return first * second;
        exact = false;
        return ulong.MaxValue;
    }

    private static void WriteType(BinaryWriter writer, MathBlockType type)
    {
        writer.Write((int)type.Kind);
        writer.Write(type.Rows);
        writer.Write(type.Columns);
        WriteUnit(writer, type.Unit);
    }

    private static void WriteUnit(BinaryWriter writer, MathBlockUnit unit)
    {
        WriteRational(writer, unit.Dimension0);
        WriteRational(writer, unit.Dimension1);
        WriteRational(writer, unit.Dimension2);
        WriteRational(writer, unit.Dimension3);
    }

    private static void WriteRational(BinaryWriter writer, MathRational value)
    {
        writer.Write(value.Numerator);
        writer.Write(value.Denominator);
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
                throw new NotSupportedException("A population value kind is unsupported.");
        }
    }

    private static void WriteComplex(BinaryWriter writer, Complex value)
    {
        writer.Write(unchecked((long)Math.ToBits(value.Real)));
        writer.Write(unchecked((long)Math.ToBits(value.Imaginary)));
    }
}
