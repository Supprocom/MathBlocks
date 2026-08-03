using System.Buffers.Binary;
using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Gpu;

public sealed class MathBlocksGPUProgramPopulation : IDisposable
{
    private readonly object stateLock = new();
    private readonly MathBlockProgramPopulationDefinition definition;
    private readonly PopulationLayout layout;
    private readonly PopulationKernelArguments kernelArguments;
    private ulong deviceArena;
    private IntPtr downloadArena;
    private IntPtr stream;
    private IntPtr graph;
    private IntPtr executable;
    private MathBlockProgramPopulationState acceptedState;
    private bool disposed;

    private MathBlocksGPUProgramPopulation(
        MathBlockProgramPopulationDefinition definition,
        PopulationLayout layout,
        PopulationKernelArguments kernelArguments,
        ulong deviceArena,
        IntPtr downloadArena,
        IntPtr stream,
        IntPtr graph,
        IntPtr executable,
        MathBlockProgramPopulationState acceptedState)
    {
        this.definition = definition;
        this.layout = layout;
        this.kernelArguments = kernelArguments;
        this.deviceArena = deviceArena;
        this.downloadArena = downloadArena;
        this.stream = stream;
        this.graph = graph;
        this.executable = executable;
        this.acceptedState = acceptedState;
        GraphInstanceCount = 1;
        UploadCount = 1;
    }

    public string PopulationIdentity => definition.Identity;
    public ulong TotalProposalCount => definition.TotalProposalCount;
    public int GraphInstanceCount { get; }
    public int UploadCount { get; }
    public int GraphLaunchCount { get; private set; }
    public int SynchronizationCount { get; private set; }
    public int DownloadCount { get; private set; }
    public long ResidentBytes => layout.ArenaSize;
    public int DeviceToHostBytesPerCycle => layout.StateSize;
    public int CpuNodeDispatchCount => 0;
    public ulong StructuralDuplicateCount => acceptedState.StructuralDuplicateCount;
    public ulong SemanticDuplicateCount => acceptedState.SemanticDuplicateCount;
    public ulong EvaluatedProgramCount => acceptedState.EvaluatedProgramCount;
    public ulong AcceptedCursor => acceptedState.AcceptedCursor;
    public MathBlockProgramPopulationState AcceptedState => acceptedState;

    internal static MathBlocksGPUProgramPopulation Create(MathBlockProgramPopulationDefinition definition)
    {
        MathBlocksCudaNative.EnsureContext();
        var layout = PopulationLayout.Create(definition);
        var initial = layout.CreateInitialArena(definition);
        var deviceArena = 0ul;
        var uploadArena = IntPtr.Zero;
        var downloadArena = IntPtr.Zero;
        var stream = IntPtr.Zero;
        var graph = IntPtr.Zero;
        var executable = IntPtr.Zero;
        PopulationKernelArguments? arguments = null;
        try
        {
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAlloc(out deviceArena, new UIntPtr(checked((uint)layout.ArenaSize))),
                "cuMemAlloc(mathblocks population arena)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(out uploadArena, new UIntPtr(checked((uint)layout.ArenaSize))),
                "cuMemAllocHost(mathblocks population upload)");
            Marshal.Copy(initial, 0, uploadArena, initial.Length);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemcpyHtoD(deviceArena, uploadArena, new UIntPtr(checked((uint)layout.ArenaSize))),
                "cuMemcpyHtoD(mathblocks population)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemFreeHost(uploadArena),
                "cuMemFreeHost(mathblocks population upload)");
            uploadArena = IntPtr.Zero;

            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(out downloadArena, new UIntPtr(checked((uint)layout.StateSize))),
                "cuMemAllocHost(mathblocks population download)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamCreate(out stream, 1),
                "cuStreamCreate(mathblocks population)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphCreate(out graph, 0),
                "cuGraphCreate(mathblocks population)");

            arguments = new PopulationKernelArguments(deviceArena);
            var parameters = new MathBlocksCudaNative.KernelNodeParameters
            {
                Function = MathBlockProgramPopulationGpuKernel.Function,
                GridX = 1,
                GridY = 1,
                GridZ = 1,
                BlockX = 1,
                BlockY = 1,
                BlockZ = 1,
                KernelParameters = arguments.PointerArray
            };
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddKernelNode(
                    out var kernelNode,
                    graph,
                    null,
                    UIntPtr.Zero,
                    ref parameters),
                "cuGraphAddKernelNode(mathblocks population)");

            var copy = MathBlocksCudaNative.MemoryCopy3D.DeviceToHost(
                checked(deviceArena + (ulong)layout.StateOffset),
                downloadArena,
                layout.StateSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddMemcpyNode(
                    out _,
                    graph,
                    [kernelNode],
                    new UIntPtr(1),
                    ref copy,
                    MathBlocksCudaNative.CurrentContext),
                "cuGraphAddMemcpyNode(mathblocks population download)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphInstantiateWithFlags(out executable, graph, 0),
                "cuGraphInstantiate(mathblocks population)");

            var state = definition.AcceptedState ?? new MathBlockProgramPopulationState(
                definition.Identity,
                0,
                0,
                0,
                0,
                [],
                []);
            return new MathBlocksGPUProgramPopulation(
                definition,
                layout,
                arguments,
                deviceArena,
                downloadArena,
                stream,
                graph,
                executable,
                state);
        }
        catch
        {
            if (executable != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphExecDestroy(executable);
            if (graph != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphDestroy(graph);
            if (stream != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuStreamDestroy(stream);
            arguments?.Dispose();
            if (deviceArena != 0)
                _ = MathBlocksCudaNative.cuMemFree(deviceArena);
            if (uploadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(uploadArena);
            if (downloadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(downloadArena);
            throw;
        }
    }

    public MathBlockProgramPopulationCycleResult ExecuteCycle()
    {
        lock (stateLock)
        {
            ThrowIfDisposed();
            MathBlocksCudaNative.EnsureContext();
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphLaunch(executable, stream),
                "cuGraphLaunch(mathblocks population)");
            GraphLaunchCount++;
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamSynchronize(stream),
                "cuStreamSynchronize(mathblocks population)");
            SynchronizationCount++;
            DownloadCount++;

            var bytes = new byte[layout.StateSize];
            Marshal.Copy(downloadArena, bytes, 0, bytes.Length);
            var parsed = layout.ParseCycle(definition, bytes);
            if (parsed.Status != PopulationCycleStatus.Success)
            {
                throw new InvalidOperationException(parsed.Status switch
                {
                    PopulationCycleStatus.StructuralCapacityOverflow =>
                        "The resident structural fingerprint capacity is exhausted.",
                    PopulationCycleStatus.SemanticCapacityOverflow =>
                        "The resident semantic fingerprint capacity is exhausted.",
                    PopulationCycleStatus.OutputCapacityOverflow =>
                        "A resident candidate output exceeds its active resource band.",
                    _ => "The resident population cycle failed closed."
                });
            }

            acceptedState = parsed.State;
            var instrumentation = new MathBlockProgramPopulationInstrumentation(
                GraphInstanceCount,
                UploadCount,
                GraphLaunchCount,
                SynchronizationCount,
                DownloadCount,
                ResidentBytes,
                StructuralDuplicateCount,
                SemanticDuplicateCount,
                EvaluatedProgramCount,
                AcceptedCursor,
                CpuNodeDispatchCount);
            return new MathBlockProgramPopulationCycleResult(
                parsed.Candidates,
                acceptedState,
                instrumentation,
                AcceptedCursor == TotalProposalCount);
        }
    }

    public void Dispose()
    {
        lock (stateLock)
        {
            if (disposed)
                return;
            MathBlocksCudaNative.EnsureContext();
            disposed = true;
            if (executable != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphExecDestroy(executable);
            if (graph != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphDestroy(graph);
            if (stream != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuStreamDestroy(stream);
            kernelArguments.Dispose();
            if (deviceArena != 0)
                _ = MathBlocksCudaNative.cuMemFree(deviceArena);
            if (downloadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(downloadArena);
            executable = IntPtr.Zero;
            graph = IntPtr.Zero;
            stream = IntPtr.Zero;
            deviceArena = 0;
            downloadArena = IntPtr.Zero;
        }
    }

    private void ThrowIfDisposed() => ObjectDisposedException.ThrowIf(disposed, this);

    private sealed class PopulationKernelArguments : IDisposable
    {
        private IntPtr arenaArgument;

        public PopulationKernelArguments(ulong arena)
        {
            arenaArgument = Marshal.AllocHGlobal(sizeof(long));
            PointerArray = Marshal.AllocHGlobal(IntPtr.Size);
            Marshal.WriteInt64(arenaArgument, unchecked((long)arena));
            Marshal.WriteIntPtr(PointerArray, arenaArgument);
        }

        public IntPtr PointerArray { get; private set; }

        public void Dispose()
        {
            if (PointerArray != IntPtr.Zero)
                Marshal.FreeHGlobal(PointerArray);
            if (arenaArgument != IntPtr.Zero)
                Marshal.FreeHGlobal(arenaArgument);
            PointerArray = IntPtr.Zero;
            arenaArgument = IntPtr.Zero;
        }
    }
}

internal enum PopulationCycleStatus
{
    Success = 0,
    StructuralCapacityOverflow = 1,
    SemanticCapacityOverflow = 2,
    OutputCapacityOverflow = 3,
    InvalidResidentState = 4
}

internal sealed class PopulationCycleParseResult
{
    public PopulationCycleParseResult(
        PopulationCycleStatus status,
        MathBlockProgramPopulationState state,
        IReadOnlyList<MathBlockProgramCandidate> candidates)
    {
        Status = status;
        State = state;
        Candidates = candidates;
    }

    public PopulationCycleStatus Status { get; }
    public MathBlockProgramPopulationState State { get; }
    public IReadOnlyList<MathBlockProgramCandidate> Candidates { get; }
}

internal sealed class PopulationLayout
{
    private const int LegacyMaximumArity = 4;
    private const int LegacyMaximumOperationCount = 8;
    private const int HeaderSize = 128;
    private const int TypeSize = 48;
    private const int OperationSize = 64;
    private const int TerminalSize = 16;
    private const int BandSize = 24;
    private const int StateHeaderSize = 64;
    private const int OperationResultSize = 20;
    private const int ResultHeaderSize = 56;

    private readonly MathBlockType[] types;
    private readonly int[] terminalTypeIds;
    private readonly int[] operationOutputTypeIds;
    private readonly int[][] operationInputTypeIds;
    private readonly int[] operationOpcodes;
    private readonly (ulong First, ulong Second)[] operationKeys;
    private readonly ulong[] bandStarts;
    private readonly ulong[] bandCounts;

    private PopulationLayout(
        MathBlockType[] types,
        int[] terminalTypeIds,
        int[] operationOutputTypeIds,
        int[][] operationInputTypeIds,
        int[] operationOpcodes,
        (ulong First, ulong Second)[] operationKeys,
        ulong[] bandStarts,
        ulong[] bandCounts,
        int maximumOperationCount,
        int maximumOutputElements,
        int operationOffset,
        int terminalOffset,
        int typeOffset,
        int bandOffset,
        int valueOffset,
        int workspaceTypeOffset,
        int workspaceCountOffset,
        int workspaceValueOffset,
        int stateOffset,
        int structuralOffset,
        int semanticOffset,
        int resultOffset,
        int resultEntrySize,
        int stateSize,
        int arenaSize,
        int totalNodeCount)
    {
        this.types = types;
        this.terminalTypeIds = terminalTypeIds;
        this.operationOutputTypeIds = operationOutputTypeIds;
        this.operationInputTypeIds = operationInputTypeIds;
        this.operationOpcodes = operationOpcodes;
        this.operationKeys = operationKeys;
        this.bandStarts = bandStarts;
        this.bandCounts = bandCounts;
        MaximumOperationCount = maximumOperationCount;
        MaximumOutputElements = maximumOutputElements;
        OperationOffset = operationOffset;
        TerminalOffset = terminalOffset;
        TypeOffset = typeOffset;
        BandOffset = bandOffset;
        ValueOffset = valueOffset;
        WorkspaceTypeOffset = workspaceTypeOffset;
        WorkspaceCountOffset = workspaceCountOffset;
        WorkspaceValueOffset = workspaceValueOffset;
        StateOffset = stateOffset;
        StructuralOffset = structuralOffset;
        SemanticOffset = semanticOffset;
        ResultOffset = resultOffset;
        ResultEntrySize = resultEntrySize;
        StateSize = stateSize;
        ArenaSize = arenaSize;
        TotalNodeCount = totalNodeCount;
    }

    public int MaximumOperationCount { get; }
    public int MaximumOutputElements { get; }
    public int OperationOffset { get; }
    public int TerminalOffset { get; }
    public int TypeOffset { get; }
    public int BandOffset { get; }
    public int ValueOffset { get; }
    public int WorkspaceTypeOffset { get; }
    public int WorkspaceCountOffset { get; }
    public int WorkspaceValueOffset { get; }
    public int StateOffset { get; }
    public int StructuralOffset { get; }
    public int SemanticOffset { get; }
    public int ResultOffset { get; }
    public int ResultEntrySize { get; }
    public int StateSize { get; }
    public int ArenaSize { get; }
    public int TotalNodeCount { get; }

    public static PopulationLayout Create(MathBlockProgramPopulationDefinition definition)
    {
        foreach (var operation in definition.Grammar.Operations)
            if (operation.InputTypes.Count > LegacyMaximumArity)
                throw new NotSupportedException("The enumeration primitive supports an arity of four in this build.");
        foreach (var band in definition.ActiveResourceBands)
            if (band.OperationCount > LegacyMaximumOperationCount)
                throw new NotSupportedException("The enumeration primitive supports eight operation nodes in this build.");
        ValidateOperations(definition);
        var types = new List<MathBlockType>();
        int AddType(MathBlockType type)
        {
            var index = types.IndexOf(type);
            if (index >= 0)
                return index;
            types.Add(type);
            return types.Count - 1;
        }

        var terminalTypeIds = new int[definition.AllTerminals.Count];
        for (var index = 0; index < definition.AllTerminals.Count; index++)
            terminalTypeIds[index] = AddType(definition.AllTerminals[index].Type);
        var operationInputTypeIds = new int[definition.Grammar.Operations.Count][];
        var operationOutputTypeIds = new int[definition.Grammar.Operations.Count];
        var operationOpcodes = new int[definition.Grammar.Operations.Count];
        var operationKeys = new (ulong, ulong)[definition.Grammar.Operations.Count];
        for (var index = 0; index < definition.Grammar.Operations.Count; index++)
        {
            var operation = definition.Grammar.Operations[index];
            operationInputTypeIds[index] = new int[operation.InputTypes.Count];
            for (var inputIndex = 0; inputIndex < operation.InputTypes.Count; inputIndex++)
                operationInputTypeIds[index][inputIndex] = AddType(operation.InputTypes[inputIndex]);
            operationOutputTypeIds[index] = AddType(operation.OutputType);
            operationOpcodes[index] = MathBlockProgramPopulationGpuOperations.Resolve(operation.Identity);
            operationKeys[index] = MathBlockProgramPopulationFingerprint.CreateOperationKey(operation.Identity);
        }
        _ = AddType(definition.Grammar.OutputType);
        var maximumOperationCount = 0;
        var maximumOutputElements = 0;
        foreach (var band in definition.ActiveResourceBands)
        {
            if (band.OperationCount > maximumOperationCount)
                maximumOperationCount = band.OperationCount;
            if (band.MaximumOutputElements > maximumOutputElements)
                maximumOutputElements = band.MaximumOutputElements;
        }
        foreach (var terminal in definition.AllTerminals)
            if (GetValueCount(terminal.Value) > maximumOutputElements)
                throw new ArgumentOutOfRangeException(nameof(definition), "A terminal exceeds every active output capacity.");

        var bandStarts = new ulong[definition.ActiveResourceBands.Count];
        var bandCounts = new ulong[definition.ActiveResourceBands.Count];
        ulong cursor = 0;
        for (var index = 0; index < definition.ActiveResourceBands.Count; index++)
        {
            bandStarts[index] = cursor;
            bandCounts[index] = CalculateBandCount(
                definition.Grammar.Operations,
                definition.AllTerminals.Count,
                definition.ActiveResourceBands[index].OperationCount);
            cursor = checked(cursor + bandCounts[index]);
        }
        if (cursor != definition.TotalProposalCount)
            throw new InvalidOperationException("The population proposal count is inconsistent.");

        var operationOffset = HeaderSize;
        var terminalOffset = Align(operationOffset + checked(definition.Grammar.Operations.Count * OperationSize));
        var typeOffset = Align(terminalOffset + checked(definition.AllTerminals.Count * TerminalSize));
        var bandOffset = Align(typeOffset + checked(types.Count * TypeSize));
        var valueOffset = Align(bandOffset + checked(definition.ActiveResourceBands.Count * BandSize));
        var terminalValueCount = 0;
        checked
        {
            foreach (var terminal in definition.AllTerminals)
                terminalValueCount += GetValueCount(terminal.Value);
        }
        var workspaceTypeOffset = Align(valueOffset + checked(terminalValueCount * sizeof(ulong)));
        var totalNodeCount = checked(definition.AllTerminals.Count + maximumOperationCount);
        var workspaceCountOffset = Align(workspaceTypeOffset + checked(totalNodeCount * sizeof(int)));
        var workspaceValueOffset = Align(workspaceCountOffset + checked(totalNodeCount * sizeof(int)));
        var stateOffset = Align(workspaceValueOffset + checked(totalNodeCount * maximumOutputElements * sizeof(ulong)));
        var structuralOffset = Align(stateOffset + StateHeaderSize);
        var semanticOffset = Align(structuralOffset + checked(definition.FingerprintCapacity * 2 * sizeof(ulong)));
        var resultOffset = Align(semanticOffset + checked(definition.FingerprintCapacity * 2 * sizeof(ulong)));
        var resultEntrySize = Align(ResultHeaderSize +
            checked(maximumOperationCount * OperationResultSize) +
            checked(maximumOutputElements * sizeof(ulong)));
        var arenaSize = Align(resultOffset + checked(definition.ProposalsPerCycle * resultEntrySize));
        var stateSize = checked(arenaSize - stateOffset);
        return new PopulationLayout(
            types.ToArray(),
            terminalTypeIds,
            operationOutputTypeIds,
            operationInputTypeIds,
            operationOpcodes,
            operationKeys,
            bandStarts,
            bandCounts,
            maximumOperationCount,
            maximumOutputElements,
            operationOffset,
            terminalOffset,
            typeOffset,
            bandOffset,
            valueOffset,
            workspaceTypeOffset,
            workspaceCountOffset,
            workspaceValueOffset,
            stateOffset,
            structuralOffset,
            semanticOffset,
            resultOffset,
            resultEntrySize,
            stateSize,
            arenaSize,
            totalNodeCount);
    }

    public byte[] CreateInitialArena(MathBlockProgramPopulationDefinition definition)
    {
        var bytes = new byte[ArenaSize];
        WriteInt32(bytes, 0, unchecked((int)0x4d425050));
        WriteInt32(bytes, 4, 1);
        WriteInt32(bytes, 8, definition.Grammar.Operations.Count);
        WriteInt32(bytes, 12, definition.AllTerminals.Count);
        WriteInt32(bytes, 16, types.Length);
        WriteInt32(bytes, 20, definition.ActiveResourceBands.Count);
        WriteInt32(bytes, 24, MaximumOperationCount);
        WriteInt32(bytes, 28, MaximumOutputElements);
        WriteInt32(bytes, 32, definition.ProposalsPerCycle);
        WriteInt32(bytes, 36, definition.FingerprintCapacity);
        WriteInt32(bytes, 40, Array.IndexOf(types, definition.Grammar.OutputType));
        WriteInt32(bytes, 44, StateOffset);
        WriteInt32(bytes, 48, StateSize);
        WriteInt32(bytes, 52, ResultEntrySize);
        WriteInt32(bytes, 56, OperationOffset);
        WriteInt32(bytes, 60, TerminalOffset);
        WriteInt32(bytes, 64, TypeOffset);
        WriteInt32(bytes, 68, BandOffset);
        WriteInt32(bytes, 72, ValueOffset);
        WriteInt32(bytes, 76, WorkspaceTypeOffset);
        WriteInt32(bytes, 80, WorkspaceCountOffset);
        WriteInt32(bytes, 84, WorkspaceValueOffset);
        WriteInt32(bytes, 88, StructuralOffset);
        WriteInt32(bytes, 92, SemanticOffset);
        WriteInt32(bytes, 96, ResultOffset);
        WriteInt32(bytes, 100, TotalNodeCount);
        WriteUInt64(bytes, 104, definition.TotalProposalCount);

        for (var index = 0; index < definition.Grammar.Operations.Count; index++)
        {
            var offset = OperationOffset + index * OperationSize;
            WriteInt32(bytes, offset, operationOpcodes[index]);
            WriteInt32(bytes, offset + 4, operationInputTypeIds[index].Length);
            WriteInt32(bytes, offset + 8, operationOutputTypeIds[index]);
            for (var inputIndex = 0; inputIndex < LegacyMaximumArity; inputIndex++)
            {
                WriteInt32(
                    bytes,
                    offset + 12 + inputIndex * sizeof(int),
                    inputIndex < operationInputTypeIds[index].Length
                        ? operationInputTypeIds[index][inputIndex]
                        : -1);
            }
            WriteUInt64(bytes, offset + 32, operationKeys[index].First);
            WriteUInt64(bytes, offset + 40, operationKeys[index].Second);
        }

        var valueIndex = 0;
        for (var index = 0; index < definition.AllTerminals.Count; index++)
        {
            var terminal = definition.AllTerminals[index];
            var count = GetValueCount(terminal.Value);
            var offset = TerminalOffset + index * TerminalSize;
            WriteInt32(bytes, offset, terminalTypeIds[index]);
            WriteInt32(bytes, offset + 4, (int)terminal.Type.Kind);
            WriteInt32(bytes, offset + 8, count);
            WriteInt32(bytes, offset + 12, valueIndex);
            foreach (var value in GetValueBits(terminal.Value))
            {
                WriteUInt64(bytes, ValueOffset + valueIndex * sizeof(ulong), value);
                valueIndex++;
            }
        }

        for (var index = 0; index < types.Length; index++)
            WriteType(bytes, TypeOffset + index * TypeSize, types[index]);
        for (var index = 0; index < definition.ActiveResourceBands.Count; index++)
        {
            var offset = BandOffset + index * BandSize;
            WriteInt32(bytes, offset, definition.ActiveResourceBands[index].OperationCount);
            WriteInt32(bytes, offset + 4, definition.ActiveResourceBands[index].MaximumOutputElements);
            WriteUInt64(bytes, offset + 8, bandStarts[index]);
            WriteUInt64(bytes, offset + 16, bandCounts[index]);
        }

        var state = definition.AcceptedState;
        if (state is not null)
        {
            WriteInt32(bytes, StateOffset + 8, state.StructuralFingerprints.Count);
            WriteInt32(bytes, StateOffset + 12, state.SemanticFingerprints.Count);
            WriteUInt64(bytes, StateOffset + 16, state.AcceptedCursor);
            WriteUInt64(bytes, StateOffset + 24, state.StructuralDuplicateCount);
            WriteUInt64(bytes, StateOffset + 32, state.SemanticDuplicateCount);
            WriteUInt64(bytes, StateOffset + 40, state.EvaluatedProgramCount);
            WriteFingerprints(bytes, StructuralOffset, state.StructuralFingerprints);
            WriteFingerprints(bytes, SemanticOffset, state.SemanticFingerprints);
        }
        return bytes;
    }

    public PopulationCycleParseResult ParseCycle(
        MathBlockProgramPopulationDefinition definition,
        ReadOnlySpan<byte> downloaded)
    {
        if (downloaded.Length != StateSize)
            throw new InvalidDataException("The resident population download length is invalid.");
        var status = (PopulationCycleStatus)ReadInt32(downloaded, 0);
        var resultCount = ReadInt32(downloaded, 4);
        var structuralCount = ReadInt32(downloaded, 8);
        var semanticCount = ReadInt32(downloaded, 12);
        var cursor = ReadUInt64(downloaded, 16);
        var structuralDuplicates = ReadUInt64(downloaded, 24);
        var semanticDuplicates = ReadUInt64(downloaded, 32);
        var evaluated = ReadUInt64(downloaded, 40);
        if (!Enum.IsDefined(status) || resultCount < 0 || resultCount > definition.ProposalsPerCycle ||
            structuralCount < 0 || structuralCount > definition.FingerprintCapacity ||
            semanticCount < 0 || semanticCount > definition.FingerprintCapacity ||
            cursor > definition.TotalProposalCount)
        {
            throw new InvalidDataException("The resident population state is invalid.");
        }
        var structural = ReadFingerprints(
            downloaded,
            StructuralOffset - StateOffset,
            structuralCount);
        var semantic = ReadFingerprints(
            downloaded,
            SemanticOffset - StateOffset,
            semanticCount);
        var state = new MathBlockProgramPopulationState(
            definition.Identity,
            cursor,
            structuralDuplicates,
            semanticDuplicates,
            evaluated,
            structural,
            semantic);
        if (status != PopulationCycleStatus.Success)
            return new PopulationCycleParseResult(status, state, []);

        var candidates = new MathBlockProgramCandidate[resultCount];
        for (var resultIndex = 0; resultIndex < resultCount; resultIndex++)
        {
            var entry = ResultOffset - StateOffset + resultIndex * ResultEntrySize;
            var proposalCursor = ReadUInt64(downloaded, entry);
            var operationCount = ReadInt32(downloaded, entry + 8);
            var outputTypeId = ReadInt32(downloaded, entry + 12);
            var outputCount = ReadInt32(downloaded, entry + 16);
            if (operationCount <= 0 || operationCount > MaximumOperationCount ||
                (uint)outputTypeId >= (uint)types.Length ||
                outputCount <= 0 || outputCount > MaximumOutputElements)
            {
                throw new InvalidDataException("A resident candidate result is invalid.");
            }
            var structuralFingerprint = MathBlockProgramPopulationFingerprint.Format(
                ReadUInt64(downloaded, entry + 24),
                ReadUInt64(downloaded, entry + 32));
            var semanticFingerprint = MathBlockProgramPopulationFingerprint.Format(
                ReadUInt64(downloaded, entry + 40),
                ReadUInt64(downloaded, entry + 48));
            var nodes = new List<MathBlockProgramCandidateNode>(definition.AllTerminals.Count + operationCount);
            for (var terminalIndex = 0; terminalIndex < definition.AllTerminals.Count; terminalIndex++)
            {
                var terminal = definition.AllTerminals[terminalIndex];
                nodes.Add(MathBlockProgramCandidateNode.Terminal(terminalIndex, terminal.Identifier, terminal.Type));
            }
            for (var operationNodeIndex = 0; operationNodeIndex < operationCount; operationNodeIndex++)
            {
                var operationEntry = entry + ResultHeaderSize + operationNodeIndex * OperationResultSize;
                var operationIndex = ReadInt32(downloaded, operationEntry);
                if ((uint)operationIndex >= (uint)definition.Grammar.Operations.Count)
                    throw new InvalidDataException("A resident candidate operation index is invalid.");
                var operation = definition.Grammar.Operations[operationIndex];
                var operands = new int[operation.InputTypes.Count];
                for (var inputIndex = 0; inputIndex < operands.Length; inputIndex++)
                    operands[inputIndex] = ReadInt32(downloaded, operationEntry + 4 + inputIndex * sizeof(int));
                nodes.Add(MathBlockProgramCandidateNode.Operation(
                    operation.Identifier,
                    operation.Version,
                    operation.OutputType,
                    operands));
            }
            var outputOffset = entry + Align(ResultHeaderSize + MaximumOperationCount * OperationResultSize);
            var output = ReadValue(downloaded, outputOffset, types[outputTypeId], outputCount);
            var candidate = new MathBlockProgramCandidate(proposalCursor, nodes, output);
            if (!string.Equals(candidate.StructuralFingerprint, structuralFingerprint, StringComparison.Ordinal) ||
                !string.Equals(candidate.SemanticFingerprint, semanticFingerprint, StringComparison.Ordinal))
            {
                throw new InvalidDataException("A resident candidate fingerprint is invalid.");
            }
            candidates[resultIndex] = candidate;
        }
        return new PopulationCycleParseResult(status, state, candidates);
    }

    private static void ValidateOperations(MathBlockProgramPopulationDefinition definition)
    {
        foreach (var descriptor in definition.Grammar.Operations)
        {
            MathBlockOperation operation;
            try
            {
                operation = MathBlockCatalog.Standard.Get(descriptor.Identifier, descriptor.Version);
            }
            catch (KeyNotFoundException exception)
            {
                throw new NotSupportedException($"Population operation '{descriptor.Identity}' is unsupported.", exception);
            }
            if (!ContainsIdentity(MathBlocksGPUWorker.SupportedBlockIdentities, descriptor.Identity))
                throw new NotSupportedException($"Population operation '{descriptor.Identity}' has no CUDA implementation.");
            if (operation.Arity != descriptor.InputTypes.Count)
                throw new InvalidOperationException("A population operation arity does not match its registered operation.");
            MathBlockType resolved;
            try
            {
                resolved = operation.ResolveOutputType(descriptor.InputTypes);
            }
            catch (Exception exception) when (exception is InvalidOperationException or ArgumentException)
            {
                throw new InvalidOperationException("A population operation has invalid input types.", exception);
            }
            if (resolved != descriptor.OutputType)
                throw new InvalidOperationException("A population operation output type does not match its registered operation.");
            _ = MathBlockProgramPopulationGpuOperations.Resolve(descriptor.Identity);
        }
    }

    private static bool ContainsIdentity(IReadOnlyCollection<string> values, string identity)
    {
        foreach (var value in values)
            if (string.Equals(value, identity, StringComparison.Ordinal))
                return true;
        return false;
    }

    private static ulong CalculateBandCount(
        IReadOnlyList<MathBlockProgramPopulationOperation> operations,
        int terminalCount,
        int operationCount)
    {
        ulong result = 1;
        checked
        {
            for (var nodeIndex = 0; nodeIndex < operationCount; nodeIndex++)
            {
                var available = checked((ulong)(terminalCount + nodeIndex));
                ulong choices = 0;
                foreach (var operation in operations)
                {
                    ulong operationChoices = 1;
                    for (var inputIndex = 0; inputIndex < operation.InputTypes.Count; inputIndex++)
                        operationChoices *= available;
                    choices += operationChoices;
                }
                result *= choices;
            }
        }
        return result;
    }

    private static MathBlockValue ReadValue(
        ReadOnlySpan<byte> bytes,
        int offset,
        MathBlockType declaredType,
        int count)
    {
        switch (declaredType.Kind)
        {
            case MathBlockValueKind.Scalar when count == 1:
                return MathBlockValue.Scalar(
                    Math.FromBits(ReadUInt64(bytes, offset)),
                    declaredType.Unit);
            case MathBlockValueKind.Boolean when count == 1:
                return MathBlockValue.Boolean(ReadUInt64(bytes, offset) != 0);
            case MathBlockValueKind.Vector:
                var vector = new double[count];
                for (var index = 0; index < count; index++)
                {
                    vector[index] = Math.FromBits(ReadUInt64(bytes, offset + index * sizeof(ulong)));
                }
                return MathBlockValue.Vector(vector, declaredType.Unit);
            case MathBlockValueKind.BooleanVector:
                var booleanVector = new bool[count];
                for (var index = 0; index < count; index++)
                    booleanVector[index] = ReadUInt64(bytes, offset + index * sizeof(ulong)) != 0;
                return MathBlockValue.BooleanVector(booleanVector);
            default:
                throw new InvalidDataException("A resident candidate output type is unsupported.");
        }
    }

    private static ulong[] GetValueBits(MathBlockValue value)
    {
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                return [Math.ToBits(value.AsScalar())];
            case MathBlockValueKind.Boolean:
                return [value.AsBoolean() ? 1ul : 0ul];
            case MathBlockValueKind.Vector:
                var vector = value.AsVector();
                var vectorBits = new ulong[vector.Count];
                for (var index = 0; index < vector.Count; index++)
                    vectorBits[index] = Math.ToBits(vector[index]);
                return vectorBits;
            case MathBlockValueKind.BooleanVector:
                var booleanVector = value.AsBooleanVector();
                var booleanBits = new ulong[booleanVector.Count];
                for (var index = 0; index < booleanVector.Count; index++)
                    booleanBits[index] = booleanVector[index] ? 1ul : 0ul;
                return booleanBits;
            default:
                throw new NotSupportedException("A resident population terminal type is unsupported.");
        }
    }

    private static int GetValueCount(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 1,
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        _ => throw new NotSupportedException("A resident population terminal type is unsupported.")
    };

    private static string[] ReadFingerprints(ReadOnlySpan<byte> bytes, int offset, int count)
    {
        var result = new string[count];
        for (var index = 0; index < count; index++)
        {
            result[index] = MathBlockProgramPopulationFingerprint.Format(
                ReadUInt64(bytes, offset + index * 16),
                ReadUInt64(bytes, offset + index * 16 + 8));
        }
        return result;
    }

    private static void WriteFingerprints(byte[] bytes, int offset, IReadOnlyList<string> fingerprints)
    {
        for (var index = 0; index < fingerprints.Count; index++)
        {
            var parsed = MathBlockProgramPopulationFingerprint.Parse(fingerprints[index]);
            WriteUInt64(bytes, offset + index * 16, parsed.First);
            WriteUInt64(bytes, offset + index * 16 + 8, parsed.Second);
        }
    }

    private static void WriteType(byte[] bytes, int offset, MathBlockType type)
    {
        WriteInt32(bytes, offset, (int)type.Kind);
        WriteInt32(bytes, offset + 4, type.Rows);
        WriteInt32(bytes, offset + 8, type.Columns);
        WriteRational(bytes, offset + 12, type.Unit.Dimension0);
        WriteRational(bytes, offset + 20, type.Unit.Dimension1);
        WriteRational(bytes, offset + 28, type.Unit.Dimension2);
        WriteRational(bytes, offset + 36, type.Unit.Dimension3);
    }

    private static void WriteRational(byte[] bytes, int offset, MathRational value)
    {
        WriteInt32(bytes, offset, value.Numerator);
        WriteInt32(bytes, offset + 4, value.Denominator);
    }

    private static int Align(int value) => checked((value + 7) & ~7);
    private static int ReadInt32(ReadOnlySpan<byte> bytes, int offset) =>
        BinaryPrimitives.ReadInt32LittleEndian(bytes[offset..]);
    private static ulong ReadUInt64(ReadOnlySpan<byte> bytes, int offset) =>
        BinaryPrimitives.ReadUInt64LittleEndian(bytes[offset..]);
    private static void WriteInt32(Span<byte> bytes, int offset, int value) =>
        BinaryPrimitives.WriteInt32LittleEndian(bytes[offset..], value);
    private static void WriteUInt64(Span<byte> bytes, int offset, ulong value) =>
        BinaryPrimitives.WriteUInt64LittleEndian(bytes[offset..], value);
}

internal static class MathBlockProgramPopulationGpuOperations
{
    private static readonly IReadOnlyDictionary<string, int> opcodes = new Dictionary<string, int>(StringComparer.Ordinal)
    {
        ["scalar.add@1"] = 1,
        ["scalar.subtract@1"] = 2,
        ["scalar.multiply@1"] = 3,
        ["scalar.divide@1"] = 4,
        ["scalar.negate@1"] = 5,
        ["scalar.absolute@1"] = 6,
        ["scalar.minimum@1"] = 7,
        ["scalar.maximum@1"] = 8,
        ["scalar.equal@1"] = 9,
        ["scalar.not-equal@1"] = 10,
        ["scalar.greater-than@1"] = 11,
        ["scalar.greater-or-equal@1"] = 12,
        ["scalar.less-than@1"] = 13,
        ["scalar.less-or-equal@1"] = 14,
        ["vector.add@1"] = 20,
        ["vector.subtract@1"] = 21,
        ["vector.multiply@1"] = 22,
        ["vector.divide@1"] = 23,
        ["vector.absolute@1"] = 24,
        ["vector.add-scalar@1"] = 25,
        ["vector.sum@1"] = 26,
        ["vector.mean@1"] = 27,
        ["vector.equal@1"] = 28,
        ["vector.concatenate@1"] = 29,
        ["boolean.and@1"] = 40,
        ["boolean.or@1"] = 41,
        ["boolean.xor@1"] = 42,
        ["boolean.not@1"] = 43,
        ["boolean-vector.and@1"] = 50,
        ["boolean-vector.or@1"] = 51,
        ["boolean-vector.xor@1"] = 52,
        ["boolean-vector.not@1"] = 53,
        ["boolean-vector.true-count@1"] = 54
    };
    private static readonly IReadOnlyCollection<string> supportedIdentities =
        Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(opcodes.Keys));

    public static int Resolve(string identity) => opcodes.TryGetValue(identity, out var opcode)
        ? opcode
        : throw new NotSupportedException($"Population operation '{identity}' is unsupported.");

    public static IReadOnlyCollection<string> SupportedIdentities => supportedIdentities;
}
