using System.Buffers.Binary;
using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

public sealed class MathBlocksCUDAProgramPopulationSearch : IDisposable
{
    private readonly object stateLock = new();
    private readonly MathBlockProgramPopulationSearchDefinition definition;
    private readonly MathBlockProgramPopulationExecutionOptions executionOptions;
    private readonly PopulationSearchLayout layout;
    private readonly SearchKernelArgumentSet kernelArguments;
    private ulong deviceArena;
    private IntPtr downloadArena;
    private IntPtr stream;
    private IntPtr graph;
    private IntPtr executable;
    private MathBlockProgramPopulationSearchState acceptedState;
    private long candidateChunkCount;
    private long serialCandidateExecutionCount;
    private long parallelCandidateExecutionCount;
    private int maximumConcurrentCandidates;
    private bool disposed;

    private MathBlocksCUDAProgramPopulationSearch(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationExecutionOptions executionOptions,
        PopulationSearchLayout layout,
        SearchKernelArgumentSet kernelArguments,
        ulong deviceArena,
        IntPtr downloadArena,
        IntPtr stream,
        IntPtr graph,
        IntPtr executable,
        MathBlockProgramPopulationSearchState acceptedState)
    {
        this.definition = definition;
        this.executionOptions = executionOptions;
        this.layout = layout;
        this.kernelArguments = kernelArguments;
        this.deviceArena = deviceArena;
        this.downloadArena = downloadArena;
        this.stream = stream;
        this.graph = graph;
        this.executable = executable;
        this.acceptedState = acceptedState;
        GraphInstanceCount = 1;
        ImmutableUploadCount = 1;
    }

    public string SearchIdentity => definition.Identity;
    public MathBlockProgramPopulationExecutionMode ExecutionMode => executionOptions.Mode;
    public int RequestedCandidateLaneCount => executionOptions.CandidateLaneCount;
    public int ActiveCandidateLaneCount => Math.Min(
        executionOptions.CandidateLaneCount,
        definition.WavePolicy.ProposalWaveSize);
    public MathBlockProgramPopulationSearchCapacity Capacity => layout.Capacity;
    public int GraphInstanceCount { get; }
    public int ImmutableUploadCount { get; }
    public int LaterImmutableUploadCount => 0;
    public int GraphLaunchCount { get; private set; }
    public int SynchronizationCount { get; private set; }
    public int DownloadCount { get; private set; }
    public long ResidentBytes => layout.ArenaSize;
    public int CompactDownloadBytesPerCycle => layout.CompactSize;
    public long DownloadedBytes => checked((long)DownloadCount * layout.CompactSize);
    public long FullCandidateOutputDownloadCount => 0;
    public long FullCandidateOutputBytes => 0;
    public int CpuNodeDispatchCount => 0;
    public long ProposalWaveCount => checked((long)acceptedState.WaveCursor);
    public long CandidateChunkCount => candidateChunkCount;
    public int MaximumConcurrentCandidates => maximumConcurrentCandidates;
    public long SerialCandidateExecutionCount => serialCandidateExecutionCount;
    public long ParallelCandidateExecutionCount => parallelCandidateExecutionCount;
    public ulong EnumerationCursor => acceptedState.EnumerationCursor;
    public ulong EnumerationTrialCount => acceptedState.EnumerationTrialCount;
    public ulong InvalidEnumerationProposalCount => acceptedState.InvalidEnumerationProposalCount;
    public ulong TrialCursor => acceptedState.TrialCursor;
    public MathBlockProgramPopulationSearchState AcceptedState => acceptedState;

    internal static MathBlocksCUDAProgramPopulationSearch Create(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationExecutionOptions executionOptions)
    {
        ArgumentNullException.ThrowIfNull(definition);
        ArgumentNullException.ThrowIfNull(executionOptions);
        executionOptions.ValidateResidentExecution(nameof(executionOptions));
        var layout = PopulationSearchLayout.Create(
            definition,
            executionOptions.CandidateLaneCount,
            enforceEnvelope: true);
        MathBlocksCudaNative.EnsureContext();
        var initialTrialCursor = definition.InitialTrialCursor;
        var proposalWaveSize = checked((ulong)definition.WavePolicy.ProposalWaveSize);
        var initialWaveCursor = initialTrialCursor / proposalWaveSize +
            (initialTrialCursor % proposalWaveSize == 0 ? 0ul : 1ul);
        var initialState = definition.AcceptedState ?? new MathBlockProgramPopulationSearchState(
            definition.Identity,
            0,
            0,
            initialTrialCursor,
            0,
            initialWaveCursor,
            0,
            0,
            MathBlockProgramPopulationSearchSerialization.CreateInitialRandomState(definition.Evolution),
            0,
            0,
            0,
            0,
            [],
            [],
            [],
            [],
            definition.InitialPrograms);
        var deviceArena = 0ul;
        var uploadArena = IntPtr.Zero;
        var downloadArena = IntPtr.Zero;
        var stream = IntPtr.Zero;
        var graph = IntPtr.Zero;
        var executable = IntPtr.Zero;
        SearchKernelArgumentSet? arguments = null;
        try
        {
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAlloc(out deviceArena, new UIntPtr(checked((ulong)layout.ArenaSize))),
                "cuMemAlloc(mathblocks population search arena)");
            var initial = layout.CreateInitialArena(definition, initialState, deviceArena);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(out uploadArena, new UIntPtr(checked((ulong)layout.ArenaSize))),
                "cuMemAllocHost(mathblocks population search upload)");
            Marshal.Copy(initial, 0, uploadArena, initial.Length);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemcpyHtoD(
                    deviceArena,
                    uploadArena,
                    new UIntPtr(checked((ulong)layout.ArenaSize))),
                "cuMemcpyHtoD(mathblocks population search)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemFreeHost(uploadArena),
                "cuMemFreeHost(mathblocks population search upload)");
            uploadArena = IntPtr.Zero;

            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(
                    out downloadArena,
                    new UIntPtr(checked((ulong)layout.CompactSize))),
                "cuMemAllocHost(mathblocks population search download)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamCreate(out stream, 1),
                "cuStreamCreate(mathblocks population search)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphCreate(out graph, 0),
                "cuGraphCreate(mathblocks population search)");

            arguments = new SearchKernelArgumentSet();
            var arenaArguments = arguments.Add(deviceArena);
            var blockSize = executionOptions.Mode == MathBlockProgramPopulationExecutionMode.ParallelResident
                ? VectorCudaBlockCatalog.BlockSize
                : 1;

            IntPtr AddKernelNode(
                IntPtr function,
                SearchKernelArguments nodeArguments,
                IReadOnlyList<IntPtr> dependencies,
                string stage)
            {
                var parameters = new MathBlocksCudaNative.KernelNodeParameters
                {
                    Function = function,
                    GridX = 1,
                    GridY = 1,
                    GridZ = 1,
                    BlockX = blockSize,
                    BlockY = 1,
                    BlockZ = 1,
                    KernelParameters = nodeArguments.PointerArray
                };
                IntPtr[]? dependencyArray = null;
                if (dependencies.Count != 0)
                {
                    dependencyArray = new IntPtr[dependencies.Count];
                    for (var index = 0; index < dependencyArray.Length; index++)
                        dependencyArray[index] = dependencies[index];
                }
                MathBlocksCudaNative.ThrowIfFailed(
                    MathBlocksCudaNative.cuGraphAddKernelNode(
                        out var node,
                        graph,
                        dependencyArray,
                        new UIntPtr(checked((uint)dependencies.Count)),
                        ref parameters),
                    $"cuGraphAddKernelNode(mathblocks population search {stage})");
                return node;
            }

            var beginNode = AddKernelNode(
                MathBlockProgramPopulationSearchCudaKernel.BeginFunction,
                arenaArguments,
                [],
                "begin");
            var predecessor = AddKernelNode(
                MathBlockProgramPopulationSearchCudaKernel.SetupFunction,
                arenaArguments,
                [beginNode],
                "setup");
            for (var wave = 0; wave < definition.WavePolicy.WavesPerCycle; wave++)
            {
                var prepareNode = AddKernelNode(
                    MathBlockProgramPopulationSearchCudaKernel.PrepareFunction,
                    arenaArguments,
                    [predecessor],
                    "prepare");
                var evaluationNodes = new IntPtr[definition.WavePolicy.ProposalWaveSize];
                IReadOnlyList<IntPtr> priorChunk = [prepareNode];
                for (var chunkStart = 0;
                    chunkStart < evaluationNodes.Length;
                    chunkStart += executionOptions.CandidateLaneCount)
                {
                    var chunkEnd = Math.Min(
                        evaluationNodes.Length,
                        chunkStart + executionOptions.CandidateLaneCount);
                    var currentChunk = new IntPtr[chunkEnd - chunkStart];
                    for (var slot = chunkStart; slot < chunkEnd; slot++)
                    {
                        var lane = slot - chunkStart;
                        var evaluationArguments = arguments.Add(deviceArena, slot, lane);
                        evaluationNodes[slot] = AddKernelNode(
                            MathBlockProgramPopulationSearchCudaKernel.EvaluateFunction,
                            evaluationArguments,
                            priorChunk,
                            "evaluate");
                        currentChunk[slot - chunkStart] = evaluationNodes[slot];
                    }
                    priorChunk = currentChunk;
                }
                predecessor = AddKernelNode(
                    MathBlockProgramPopulationSearchCudaKernel.CommitFunction,
                    arenaArguments,
                    priorChunk,
                    "commit");
            }
            var finalizeNode = AddKernelNode(
                MathBlockProgramPopulationSearchCudaKernel.FinalizeFunction,
                arenaArguments,
                [predecessor],
                "finalize");
            var publishNode = AddKernelNode(
                MathBlockProgramPopulationSearchCudaKernel.PublishFunction,
                arenaArguments,
                [finalizeNode],
                "publish");
            var copy = MathBlocksCudaNative.MemoryCopy3D.DeviceToHost(
                checked(deviceArena + (ulong)layout.CompactOffset),
                downloadArena,
                layout.CompactSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddMemcpyNode(
                    out _,
                    graph,
                    [publishNode],
                    new UIntPtr(1),
                    ref copy,
                    MathBlocksCudaNative.CurrentContext),
                "cuGraphAddMemcpyNode(mathblocks population search download)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphInstantiateWithFlags(out executable, graph, 0),
                "cuGraphInstantiate(mathblocks population search)");
            return new MathBlocksCUDAProgramPopulationSearch(
                definition,
                executionOptions,
                layout,
                arguments,
                deviceArena,
                downloadArena,
                stream,
                graph,
                executable,
                initialState);
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

    public MathBlockProgramPopulationSearchCycleResult ExecuteCycle()
    {
        lock (stateLock)
        {
            ThrowIfDisposed();
            MathBlocksCudaNative.EnsureContext();
            var previousEvaluatedProgramCount = acceptedState.EvaluatedProgramCount;
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphLaunch(executable, stream),
                "cuGraphLaunch(mathblocks population search)");
            GraphLaunchCount++;
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamSynchronize(stream),
                "cuStreamSynchronize(mathblocks population search)");
            SynchronizationCount++;
            DownloadCount++;
            var bytes = new byte[layout.CompactSize];
            Marshal.Copy(downloadArena, bytes, 0, bytes.Length);
            var parsed = layout.ParseCycle(definition, acceptedState, bytes);
            if (parsed.Status != PopulationSearchCycleStatus.Success)
            {
                throw new InvalidOperationException(parsed.Status switch
                {
                    PopulationSearchCycleStatus.StructuralCapacityOverflow =>
                        "The resident structural fingerprint capacity is exhausted.",
                    PopulationSearchCycleStatus.SemanticCapacityOverflow =>
                        "The resident semantic fingerprint capacity is exhausted.",
                    PopulationSearchCycleStatus.OutputCapacityOverflow =>
                        "A resident value exceeds the active resource envelope.",
                    PopulationSearchCycleStatus.ArchiveCapacityOverflow =>
                        "The resident archive cannot preserve the accepted state.",
                    _ => "The resident population search cycle failed closed."
                });
            }
            acceptedState = parsed.State!;
            var evaluatedDelta = checked((long)(
                acceptedState.EvaluatedProgramCount - previousEvaluatedProgramCount));
            candidateChunkCount = checked(candidateChunkCount + parsed.CandidateChunkCount);
            maximumConcurrentCandidates = Math.Max(
                maximumConcurrentCandidates,
                parsed.MaximumConcurrentCandidates);
            if (executionOptions.Mode == MathBlockProgramPopulationExecutionMode.SerialResident)
                serialCandidateExecutionCount = checked(serialCandidateExecutionCount + evaluatedDelta);
            else
                parallelCandidateExecutionCount = checked(parallelCandidateExecutionCount + evaluatedDelta);
            var instrumentation = new MathBlockProgramPopulationSearchInstrumentation(
                GraphInstanceCount,
                ImmutableUploadCount,
                LaterImmutableUploadCount,
                GraphLaunchCount,
                SynchronizationCount,
                DownloadCount,
                ResidentBytes,
                CompactDownloadBytesPerCycle,
                DownloadedBytes,
                FullCandidateOutputDownloadCount,
                FullCandidateOutputBytes,
                CpuNodeDispatchCount,
                acceptedState.StructuralDuplicateCount,
                acceptedState.SemanticDuplicateCount,
                acceptedState.EvaluatedProgramCount,
                acceptedState.AcceptedProgramCount,
                acceptedState.EnumerationCursor,
                acceptedState.EnumerationTrialCount,
                acceptedState.InvalidEnumerationProposalCount,
                acceptedState.TrialCursor,
                acceptedState.CycleCount,
                acceptedState.SelectionEntries.Count,
                acceptedState.QualityDiversityEntries.Count,
                acceptedState.RandomState,
                ExecutionMode,
                RequestedCandidateLaneCount,
                ActiveCandidateLaneCount,
                ProposalWaveCount,
                CandidateChunkCount,
                MaximumConcurrentCandidates,
                SerialCandidateExecutionCount,
                ParallelCandidateExecutionCount);
            var enumerationComplete =
                acceptedState.EnumerationTrialCount == definition.Evolution.EnumerationProposalCount ||
                acceptedState.EnumerationCursor == definition.EnumerationCursorLimit;
            var searchComplete =
                acceptedState.TrialCursor == definition.Evolution.MaximumTrialCount ||
                enumerationComplete && definition.Evolution.EvolutionPatternLength == 0;
            return new MathBlockProgramPopulationSearchCycleResult(
                parsed.Trials,
                acceptedState,
                instrumentation,
                enumerationComplete,
                searchComplete);
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

    private sealed class SearchKernelArgumentSet : IDisposable
    {
        private readonly List<SearchKernelArguments> arguments = [];

        public SearchKernelArguments Add(ulong arena, params int[] values)
        {
            var result = new SearchKernelArguments(arena, values);
            arguments.Add(result);
            return result;
        }

        public void Dispose()
        {
            foreach (var item in arguments)
                item.Dispose();
            arguments.Clear();
        }
    }

    private sealed class SearchKernelArguments : IDisposable
    {
        private readonly List<IntPtr> valueArguments = [];

        public SearchKernelArguments(ulong arena, IReadOnlyList<int> values)
        {
            var arenaArgument = Marshal.AllocHGlobal(sizeof(long));
            valueArguments.Add(arenaArgument);
            Marshal.WriteInt64(arenaArgument, unchecked((long)arena));
            foreach (var value in values)
            {
                var argument = Marshal.AllocHGlobal(sizeof(int));
                valueArguments.Add(argument);
                Marshal.WriteInt32(argument, value);
            }
            PointerArray = Marshal.AllocHGlobal(checked(IntPtr.Size * valueArguments.Count));
            for (var index = 0; index < valueArguments.Count; index++)
                Marshal.WriteIntPtr(PointerArray, index * IntPtr.Size, valueArguments[index]);
        }

        public IntPtr PointerArray { get; private set; }

        public void Dispose()
        {
            if (PointerArray != IntPtr.Zero)
                Marshal.FreeHGlobal(PointerArray);
            foreach (var argument in valueArguments)
                Marshal.FreeHGlobal(argument);
            valueArguments.Clear();
            PointerArray = IntPtr.Zero;
        }
    }
}

internal enum PopulationSearchCycleStatus
{
    Success = 0,
    StructuralCapacityOverflow = 1,
    SemanticCapacityOverflow = 2,
    OutputCapacityOverflow = 3,
    InvalidResidentState = 4,
    ArchiveCapacityOverflow = 5
}

internal sealed record PopulationSearchCycleParseResult(
    PopulationSearchCycleStatus Status,
    MathBlockProgramPopulationSearchState? State,
    IReadOnlyList<MathBlockProgramPopulationTrialResult> Trials,
    int CandidateChunkCount,
    int MaximumConcurrentCandidates);

internal sealed class PopulationSearchLayout
{
    private const int HeaderSize = 384;
    private const int ProposalWaveControlSize = 32;
    private const int TypeSize = 48;
    private const int OperationSize = 48;
    private const int TerminalSize = 32;
    private const int BandSize = 24;
    private const int ObjectiveNodeSize = 40;
    private const int ObjectiveSourceSize = 16;
    private const int QualityDimensionSize = 32;
    private const int SlotSize = 48;
    private const int StateHeaderSize = 144;
    private const int CompactHeaderSize = 144;
    private const int EntryHeaderSize = 80;

    private readonly MathBlockType[] types;
    private readonly CudaOperationDescriptor[] operations;
    private readonly int[] operationInputTypes;
    private readonly CudaTerminalDescriptor[] terminals;
    private readonly MathBlockValue[] immutableValues;
    private readonly int[] immutablePayloadOffsets;
    private readonly ulong[] bandStarts;
    private readonly ulong[] bandCounts;
    private readonly ObjectiveNodeDescriptor[] objectiveNodes;
    private readonly int[] objectiveInputs;
    private readonly ObjectiveSourceDescriptor[] objectiveSources;
    private readonly QualityDimensionDescriptor[] qualityDimensions;

    private PopulationSearchLayout(
        MathBlockType[] types,
        CudaOperationDescriptor[] operations,
        int[] operationInputTypes,
        CudaTerminalDescriptor[] terminals,
        MathBlockValue[] immutableValues,
        int[] immutablePayloadOffsets,
        ulong[] bandStarts,
        ulong[] bandCounts,
        ObjectiveNodeDescriptor[] objectiveNodes,
        int[] objectiveInputs,
        ObjectiveSourceDescriptor[] objectiveSources,
        QualityDimensionDescriptor[] qualityDimensions)
    {
        this.types = types;
        this.operations = operations;
        this.operationInputTypes = operationInputTypes;
        this.terminals = terminals;
        this.immutableValues = immutableValues;
        this.immutablePayloadOffsets = immutablePayloadOffsets;
        this.bandStarts = bandStarts;
        this.bandCounts = bandCounts;
        this.objectiveNodes = objectiveNodes;
        this.objectiveInputs = objectiveInputs;
        this.objectiveSources = objectiveSources;
        this.qualityDimensions = qualityDimensions;
    }

    public MathBlockProgramPopulationSearchCapacity Capacity { get; private set; }
    public int MaximumOperationCount { get; private set; }
    public int MaximumBandElements { get; private set; }
    public int MaximumValueElements { get; private set; }
    public int MaximumArity { get; private set; }
    public int CandidateLaneCount { get; private set; }
    public int LaneStrideBytes { get; private set; }
    public int ScratchBytesPerNode { get; private set; }
    public int PayloadStride { get; private set; }
    public int ObjectivePayloadBytes { get; private set; }
    public int ProgramOperationSize { get; private set; }
    public int ArchiveEntrySize { get; private set; }
    public int TrialEntrySize { get; private set; }
    public int ArenaSize { get; private set; }
    public int CompactSize { get; private set; }
    public int CompactOffset { get; private set; }
    public int OperationOffset { get; private set; }
    public int OperationInputTypeOffset { get; private set; }
    public int TerminalOffset { get; private set; }
    public int TypeOffset { get; private set; }
    public int BandOffset { get; private set; }
    public int ImmutableSlotOffset { get; private set; }
    public int ImmutablePayloadOffset { get; private set; }
    public int ObjectiveNodeOffset { get; private set; }
    public int ObjectiveInputOffset { get; private set; }
    public int ObjectiveSourceOffset { get; private set; }
    public int QualityDimensionOffset { get; private set; }
    public int HistoryOffset { get; private set; }
    public int EnumerationCatalogOffset { get; private set; }
    public int CandidateSlotOffset { get; private set; }
    public int ObjectiveSlotOffset { get; private set; }
    public int MaskSlotOffset { get; private set; }
    public int CandidatePayloadOffset { get; private set; }
    public int ObjectivePayloadOffset { get; private set; }
    public int MaskPayloadOffset { get; private set; }
    public int ScratchOffset { get; private set; }
    public int InputPointerOffset { get; private set; }
    public int SelectedOperationOffset { get; private set; }
    public int SelectedOperandOffset { get; private set; }
    public int SelectedLookbackOffset { get; private set; }
    public int ProposalWaveSlotOffset { get; private set; }
    public int ProposalWaveSlotBytes { get; private set; }
    public int ProposalWaveSnapshotParetoOffset { get; private set; }
    public int ProposalWaveSnapshotQualityOffset { get; private set; }
    public int ProposalWaveControlOffset { get; private set; }
    public int AcceptedStateOffset { get; private set; }
    public int AcceptedStructuralOffset { get; private set; }
    public int AcceptedSemanticOffset { get; private set; }
    public int AcceptedParetoOffset { get; private set; }
    public int AcceptedQualityOffset { get; private set; }
    public int WorkingStateOffset { get; private set; }
    public int WorkingStructuralOffset { get; private set; }
    public int WorkingSemanticOffset { get; private set; }
    public int WorkingParetoOffset { get; private set; }
    public int WorkingQualityOffset { get; private set; }
    public int RefreshOffset { get; private set; }
    public int CompactStructuralOffset { get; private set; }
    public int CompactSemanticOffset { get; private set; }
    public int CompactParetoOffset { get; private set; }
    public int CompactQualityOffset { get; private set; }
    public int CompactTrialOffset { get; private set; }

    public static PopulationSearchLayout Create(
        MathBlockProgramPopulationSearchDefinition definition,
        int candidateLaneCount = 1,
        bool enforceEnvelope = true)
    {
        ArgumentNullException.ThrowIfNull(definition);
        if (candidateLaneCount <= 0)
            throw new ArgumentOutOfRangeException(nameof(candidateLaneCount));
        var typeList = new List<MathBlockType>();
        int AddType(MathBlockType type)
        {
            var existing = typeList.IndexOf(type);
            if (existing >= 0)
                return existing;
            typeList.Add(type);
            return typeList.Count - 1;
        }

        var population = definition.Population;
        if (definition.EnumerationCatalog is not null)
        {
            MathBlockProgramPopulationCatalogCapacityPlanner.RequireResourceBands(
                population,
                definition.EnumerationCatalog);
        }
        var flatInputTypes = new List<int>();
        var operations = new CudaOperationDescriptor[population.Grammar.Operations.Count];
        var maximumArity = 0;
        for (var index = 0; index < operations.Length; index++)
        {
            var descriptor = population.Grammar.Operations[index];
            ValidateOperation(descriptor);
            var feature = MathBlockCudaFeatureIndex.Resolve(descriptor.Identity);
            var inputBase = flatInputTypes.Count;
            foreach (var inputType in descriptor.InputTypes)
                flatInputTypes.Add(AddType(inputType));
            maximumArity = Math.Max(maximumArity, descriptor.InputTypes.Count);
            var key = MathBlockProgramPopulationFingerprint.CreateOperationKey(descriptor.Identity);
            operations[index] = new CudaOperationDescriptor(
                (int)feature.Family,
                feature.Opcode,
                descriptor.InputTypes.Count,
                AddType(descriptor.OutputType),
                inputBase,
                descriptor.DeterministicCost,
                key.First,
                key.Second);
        }
        _ = AddType(population.Grammar.OutputType);

        var immutableValues = new List<MathBlockValue>();
        var terminalDescriptors = new CudaTerminalDescriptor[population.AllTerminals.Count];
        var maximumValueElements = definition.Validity.HistoryCounts.Count;
        for (var index = 0; index < terminalDescriptors.Length; index++)
        {
            var terminal = population.AllTerminals[index];
            var valueIndex = immutableValues.Count;
            immutableValues.Add(terminal.Value);
            maximumValueElements = Math.Max(maximumValueElements, MathBlockCudaValueLayout.GetElementCount(terminal.Value));
            terminalDescriptors[index] = new CudaTerminalDescriptor(
                AddType(terminal.Type),
                valueIndex,
                terminal.Lookback);
        }

        var maximumOperationCount = 0;
        var maximumBandElements = 0;
        foreach (var band in population.ActiveResourceBands)
        {
            maximumOperationCount = Math.Max(maximumOperationCount, band.OperationCount);
            maximumBandElements = Math.Max(maximumBandElements, band.MaximumOutputElements);
        }
        maximumValueElements = Math.Max(maximumValueElements, maximumBandElements);
        if (maximumOperationCount <= 0 || maximumBandElements <= 0 || maximumValueElements <= 0)
            throw new InvalidOperationException("The population search resource envelope is empty.");
        var maximumCandidateValueElements = maximumValueElements;

        var compiledObjective = CompileObjective(
            definition,
            AddType,
            immutableValues,
            maximumBandElements,
            ref maximumArity,
            ref maximumValueElements);

        var bandStarts = new ulong[population.ActiveResourceBands.Count];
        var bandCounts = new ulong[population.ActiveResourceBands.Count];
        for (var index = 0; index < bandCounts.Length; index++)
        {
            bandStarts[index] = population.ProposalBandStarts[index];
            bandCounts[index] = population.ProposalBandCounts[index];
        }

        var payloadOffsets = new int[immutableValues.Count];
        var immutablePayloadBytes = 0;
        for (var index = 0; index < immutableValues.Count; index++)
        {
            payloadOffsets[index] = immutablePayloadBytes;
            immutablePayloadBytes = AdvanceLayout(
                immutablePayloadBytes,
                1,
                MathBlockCudaValueLayout.GetPayloadBytes(immutableValues[index]),
                "immutable payload");
        }

        var candidateScratchStride = CalculateCandidateScratchBytes(
            definition,
            maximumCandidateValueElements);
        var layout = new PopulationSearchLayout(
            typeList.ToArray(),
            operations,
            flatInputTypes.ToArray(),
            terminalDescriptors,
            immutableValues.ToArray(),
            payloadOffsets,
            bandStarts,
            bandCounts,
            compiledObjective.Nodes,
            compiledObjective.Inputs,
            compiledObjective.Sources,
            compiledObjective.QualityDimensions)
        {
            MaximumOperationCount = maximumOperationCount,
            MaximumBandElements = maximumBandElements,
            MaximumValueElements = maximumValueElements,
            MaximumArity = maximumArity,
            CandidateLaneCount = candidateLaneCount,
            PayloadStride = CalculateCandidatePayloadStride(definition, maximumCandidateValueElements),
            ScratchBytesPerNode = Math.Max(
                candidateScratchStride,
                compiledObjective.MaximumScratchBytes),
            ObjectivePayloadBytes = compiledObjective.PayloadBytes,
            ProgramOperationSize = MeasureLayout(
                "program operation",
                (1, 8),
                (maximumArity, sizeof(int)))
        };
        layout.CalculateOffsets(definition, immutablePayloadBytes, enforceEnvelope);
        return layout;
    }

    private void CalculateOffsets(
        MathBlockProgramPopulationSearchDefinition definition,
        int immutablePayloadBytes,
        bool enforceEnvelope)
    {
        var population = definition.Population;
        var compactTrialCapacity = definition.WavePolicy.MaximumTrialResultsPerCycle;
        ArchiveEntrySize = MeasureLayout(
            "archive entry",
            (1, EntryHeaderSize),
            (objectiveSources.Length, sizeof(ulong)),
            (MaximumOperationCount, ProgramOperationSize));
        TrialEntrySize = ArchiveEntrySize;
        OperationOffset = HeaderSize;
        OperationInputTypeOffset = AdvanceLayout(
            OperationOffset, operations.Length, OperationSize, "operation descriptors");
        TerminalOffset = AdvanceLayout(
            OperationInputTypeOffset, operationInputTypes.Length, sizeof(int), "operation input types");
        TypeOffset = AdvanceLayout(TerminalOffset, terminals.Length, TerminalSize, "terminal descriptors");
        BandOffset = AdvanceLayout(TypeOffset, types.Length, TypeSize, "type descriptors");
        ImmutableSlotOffset = AdvanceLayout(BandOffset, bandStarts.Length, BandSize, "resource bands");
        ImmutablePayloadOffset = AdvanceLayout(
            ImmutableSlotOffset, immutableValues.Length, SlotSize, "immutable slots");
        ObjectiveNodeOffset = AdvanceLayout(
            ImmutablePayloadOffset, 1, immutablePayloadBytes, "immutable payload");
        ObjectiveInputOffset = AdvanceLayout(
            ObjectiveNodeOffset, objectiveNodes.Length, ObjectiveNodeSize, "objective nodes");
        ObjectiveSourceOffset = AdvanceLayout(
            ObjectiveInputOffset, objectiveInputs.Length, sizeof(int), "objective inputs");
        QualityDimensionOffset = AdvanceLayout(
            ObjectiveSourceOffset, objectiveSources.Length, ObjectiveSourceSize, "objective sources");
        HistoryOffset = AdvanceLayout(
            QualityDimensionOffset, qualityDimensions.Length, QualityDimensionSize, "quality dimensions");
        EnumerationCatalogOffset = AdvanceLayout(
            HistoryOffset, definition.Validity.HistoryCounts.Count, sizeof(int), "history counts");
        CandidateSlotOffset = AdvanceLayout(
            EnumerationCatalogOffset,
            definition.EnumerationCatalog?.Programs.Count ?? 0,
            ArchiveEntrySize,
            "enumeration catalog");
        ObjectiveSlotOffset = AdvanceLayout(
            CandidateSlotOffset,
            checked(terminals.Length + MaximumOperationCount),
            SlotSize,
            "candidate slots");
        MaskSlotOffset = AdvanceLayout(
            ObjectiveSlotOffset, objectiveNodes.Length, SlotSize, "objective slots");
        CandidatePayloadOffset = AdvanceLayout(MaskSlotOffset, 1, SlotSize, "validity-mask slot");
        ObjectivePayloadOffset = AdvanceLayout(
            CandidatePayloadOffset,
            MaximumOperationCount,
            PayloadStride,
            "candidate payload");
        MaskPayloadOffset = AdvanceLayout(
            ObjectivePayloadOffset, 1, ObjectivePayloadBytes, "objective payload");
        ScratchOffset = AdvanceLayout(
            MaskPayloadOffset,
            definition.Validity.HistoryCounts.Count,
            sizeof(int),
            "validity-mask payload");
        InputPointerOffset = AdvanceLayout(
            ScratchOffset,
            1,
            ScratchBytesPerNode,
            "resident scratch");
        SelectedOperationOffset = AdvanceLayout(
            InputPointerOffset, MaximumArity, sizeof(ulong), "input pointers");
        SelectedOperandOffset = AdvanceLayout(
            SelectedOperationOffset, MaximumOperationCount, sizeof(int), "selected operations");
        SelectedLookbackOffset = AdvanceLayout(
            SelectedOperandOffset,
            checked(MaximumOperationCount * MaximumArity),
            sizeof(int),
            "selected operands");
        var laneEnd = AdvanceLayout(
            SelectedLookbackOffset,
            checked((terminals.Length + MaximumOperationCount) * 2),
            sizeof(int),
            "selected types and lookbacks");
        LaneStrideBytes = checked(laneEnd - CandidateSlotOffset);
        ProposalWaveSlotOffset = AlignLayout(
            checked((long)CandidateSlotOffset + (long)LaneStrideBytes * CandidateLaneCount),
            "candidate lanes");
        ProposalWaveSnapshotParetoOffset = AdvanceLayout(
            ProposalWaveSlotOffset,
            definition.WavePolicy.ProposalWaveSize,
            TrialEntrySize,
            "proposal-wave slots");
        ProposalWaveSlotBytes = checked(ProposalWaveSnapshotParetoOffset - ProposalWaveSlotOffset);
        ProposalWaveSnapshotQualityOffset = AdvanceLayout(
            ProposalWaveSnapshotParetoOffset,
            definition.Selection.ParetoCapacity,
            ArchiveEntrySize,
            "proposal-wave Pareto snapshot");
        ProposalWaveControlOffset = AdvanceLayout(
            ProposalWaveSnapshotQualityOffset,
            definition.QualityDiversity.CellCount,
            ArchiveEntrySize,
            "proposal-wave quality-diversity snapshot");
        AcceptedStateOffset = AdvanceLayout(
            ProposalWaveControlOffset,
            1,
            ProposalWaveControlSize,
            "proposal-wave control");
        AcceptedStructuralOffset = AdvanceLayout(AcceptedStateOffset, 1, StateHeaderSize, "accepted state");
        AcceptedSemanticOffset = AdvanceLayout(
            AcceptedStructuralOffset, population.FingerprintCapacity, 16, "accepted structural fingerprints");
        AcceptedParetoOffset = AdvanceLayout(
            AcceptedSemanticOffset, population.FingerprintCapacity, 16, "accepted semantic fingerprints");
        AcceptedQualityOffset = AdvanceLayout(
            AcceptedParetoOffset,
            definition.Selection.ParetoCapacity,
            ArchiveEntrySize,
            "accepted Pareto entries");
        WorkingStateOffset = AdvanceLayout(
            AcceptedQualityOffset,
            definition.QualityDiversity.CellCount,
            ArchiveEntrySize,
            "accepted quality-diversity entries");
        WorkingStructuralOffset = AdvanceLayout(WorkingStateOffset, 1, StateHeaderSize, "working state");
        WorkingSemanticOffset = AdvanceLayout(
            WorkingStructuralOffset, population.FingerprintCapacity, 16, "working structural fingerprints");
        WorkingParetoOffset = AdvanceLayout(
            WorkingSemanticOffset, population.FingerprintCapacity, 16, "working semantic fingerprints");
        WorkingQualityOffset = AdvanceLayout(
            WorkingParetoOffset,
            definition.Selection.ParetoCapacity,
            ArchiveEntrySize,
            "working Pareto entries");
        RefreshOffset = AdvanceLayout(
            WorkingQualityOffset,
            definition.QualityDiversity.CellCount,
            ArchiveEntrySize,
            "working quality-diversity entries");
        var refreshCapacity = definition.AcceptedState?.RefreshPrograms.Count ?? definition.InitialPrograms.Count;
        CompactOffset = AdvanceLayout(RefreshOffset, refreshCapacity, ArchiveEntrySize, "refresh entries");
        CompactStructuralOffset = AdvanceLayout(CompactOffset, 1, CompactHeaderSize, "compact header");
        CompactSemanticOffset = AdvanceLayout(
            CompactStructuralOffset, compactTrialCapacity, 16, "compact structural fingerprints");
        CompactParetoOffset = AdvanceLayout(
            CompactSemanticOffset, compactTrialCapacity, 16, "compact semantic fingerprints");
        CompactQualityOffset = AdvanceLayout(
            CompactParetoOffset,
            definition.Selection.ParetoCapacity,
            ArchiveEntrySize,
            "compact Pareto entries");
        CompactTrialOffset = AdvanceLayout(
            CompactQualityOffset,
            definition.QualityDiversity.CellCount,
            ArchiveEntrySize,
            "compact quality-diversity entries");
        ArenaSize = AdvanceLayout(
            CompactTrialOffset, compactTrialCapacity, TrialEntrySize, "compact trial entries");
        CompactSize = checked(ArenaSize - CompactOffset);
        if (enforceEnvelope && ArenaSize > definition.Envelope.MaximumResidentBytes)
        {
            throw new ArgumentOutOfRangeException(
                nameof(definition),
                $"The measured resident arena requires {ArenaSize} bytes.");
        }
        if (enforceEnvelope && CompactSize > definition.Envelope.MaximumCompactDownloadBytes)
        {
            throw new ArgumentOutOfRangeException(
                nameof(definition),
                $"The measured compact result requires {CompactSize} bytes.");
        }
        Capacity = new MathBlockProgramPopulationSearchCapacity(
            operations.Length,
            terminals.Length,
            MaximumArity,
            MaximumOperationCount,
            MaximumValueElements,
            objectiveSources.Length,
            objectiveNodes.Length,
            definition.Selection.ParetoCapacity,
            definition.QualityDiversity.CellCount,
            checked(ArenaSize - (long)LaneStrideBytes * CandidateLaneCount),
            LaneStrideBytes,
            CandidateLaneCount,
            checked((long)LaneStrideBytes * CandidateLaneCount),
            definition.WavePolicy.ProposalWaveSize,
            ProposalWaveSlotBytes,
            ArenaSize,
            ArenaSize,
            CompactSize);
    }

    public byte[] CreateInitialArena(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationSearchState state,
        ulong deviceArena)
    {
        var bytes = new byte[ArenaSize];
        WriteHeader(bytes, definition);
        for (var index = 0; index < operations.Length; index++)
        {
            var operation = operations[index];
            var offset = OperationOffset + index * OperationSize;
            WriteInt32(bytes, offset, operation.Family);
            WriteInt32(bytes, offset + 4, operation.Opcode);
            WriteInt32(bytes, offset + 8, operation.Arity);
            WriteInt32(bytes, offset + 12, operation.OutputTypeId);
            WriteInt32(bytes, offset + 16, operation.InputTypeBase);
            WriteUInt64(bytes, offset + 24, checked((ulong)operation.DeterministicCost));
            WriteUInt64(bytes, offset + 32, operation.KeyFirst);
            WriteUInt64(bytes, offset + 40, operation.KeySecond);
        }
        for (var index = 0; index < operationInputTypes.Length; index++)
            WriteInt32(bytes, OperationInputTypeOffset + index * sizeof(int), operationInputTypes[index]);
        for (var index = 0; index < terminals.Length; index++)
        {
            var terminal = terminals[index];
            var offset = TerminalOffset + index * TerminalSize;
            WriteInt32(bytes, offset, terminal.TypeId);
            WriteInt32(bytes, offset + 4, terminal.ImmutableSlotIndex);
            WriteInt32(bytes, offset + 8, terminal.Lookback);
        }
        for (var index = 0; index < types.Length; index++)
            WriteType(bytes, TypeOffset + index * TypeSize, types[index]);
        for (var index = 0; index < bandStarts.Length; index++)
        {
            var band = definition.Population.ActiveResourceBands[index];
            var offset = BandOffset + index * BandSize;
            WriteInt32(bytes, offset, band.OperationCount);
            WriteInt32(bytes, offset + 4, band.MaximumOutputElements);
            WriteUInt64(bytes, offset + 8, bandStarts[index]);
            WriteUInt64(bytes, offset + 16, bandCounts[index]);
        }
        for (var index = 0; index < immutableValues.Length; index++)
        {
            var payloadOffset = ImmutablePayloadOffset + immutablePayloadOffsets[index];
            MathBlockCudaValueLayout.WriteValue(
                bytes,
                ImmutableSlotOffset + index * SlotSize,
                payloadOffset,
                checked(deviceArena + (ulong)payloadOffset),
                immutableValues[index]);
        }
        for (var index = 0; index < objectiveNodes.Length; index++)
        {
            var node = objectiveNodes[index];
            var offset = ObjectiveNodeOffset + index * ObjectiveNodeSize;
            WriteInt32(bytes, offset, node.Kind);
            WriteInt32(bytes, offset + 4, node.TypeId);
            WriteInt32(bytes, offset + 8, node.Family);
            WriteInt32(bytes, offset + 12, node.Opcode);
            WriteInt32(bytes, offset + 16, node.Arity);
            WriteInt32(bytes, offset + 20, node.InputBase);
            WriteInt32(bytes, offset + 24, node.ImmutableSlotIndex);
            WriteInt32(bytes, offset + 28, node.PayloadCapacity);
            WriteInt32(bytes, offset + 32, node.PayloadOffset);
            WriteInt32(bytes, offset + 36, node.ScratchBytes);
        }
        for (var index = 0; index < objectiveInputs.Length; index++)
            WriteInt32(bytes, ObjectiveInputOffset + index * sizeof(int), objectiveInputs[index]);
        for (var index = 0; index < objectiveSources.Length; index++)
        {
            var source = objectiveSources[index];
            var offset = ObjectiveSourceOffset + index * ObjectiveSourceSize;
            WriteInt32(bytes, offset, source.SourceKind);
            WriteInt32(bytes, offset + 4, source.ProgramNodeIndex);
            WriteInt32(bytes, offset + 8, source.Direction);
        }
        for (var index = 0; index < qualityDimensions.Length; index++)
        {
            var dimension = qualityDimensions[index];
            var offset = QualityDimensionOffset + index * QualityDimensionSize;
            WriteInt32(bytes, offset, dimension.ObjectiveIndex);
            WriteInt32(bytes, offset + 4, dimension.BinCount);
            WriteInt32(bytes, offset + 8, dimension.Multiplier);
            WriteUInt64(bytes, offset + 16, dimension.MinimumBits);
            WriteUInt64(bytes, offset + 24, dimension.MaximumBits);
        }
        for (var index = 0; index < definition.Validity.HistoryCounts.Count; index++)
            WriteInt32(bytes, HistoryOffset + index * sizeof(int), definition.Validity.HistoryCounts[index]);
        if (definition.EnumerationCatalog is not null)
        {
            for (var index = 0; index < definition.EnumerationCatalog.Programs.Count; index++)
            {
                WriteProgramEntry(
                    bytes,
                    EnumerationCatalogOffset + index * ArchiveEntrySize,
                    definition,
                    definition.EnumerationCatalog.Programs[index],
                    0,
                    -1,
                    null,
                    null);
            }
        }
        WriteAcceptedState(bytes, definition, state);
        return bytes;
    }

    public PopulationSearchCycleParseResult ParseCycle(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationSearchState previous,
        ReadOnlySpan<byte> downloaded)
    {
        if (downloaded.Length != CompactSize)
            throw new InvalidDataException("The resident search download length is invalid.");
        var status = (PopulationSearchCycleStatus)ReadInt32(downloaded, 0);
        if (!Enum.IsDefined(status))
            throw new InvalidDataException("The resident search status is invalid.");
        if (status != PopulationSearchCycleStatus.Success)
            return new PopulationSearchCycleParseResult(status, null, [], 0, 0);
        var trialCount = ReadInt32(downloaded, 4);
        var newStructuralCount = ReadInt32(downloaded, 8);
        var newSemanticCount = ReadInt32(downloaded, 12);
        var paretoCount = ReadInt32(downloaded, 16);
        var qualityCount = ReadInt32(downloaded, 20);
        var enumerationCursor = ReadUInt64(downloaded, 24);
        var trialCursor = ReadUInt64(downloaded, 32);
        var cycleCount = ReadUInt64(downloaded, 40);
        var randomState = new MathBlockProgramPopulationRandomState(
            ReadUInt64(downloaded, 48),
            ReadUInt64(downloaded, 56));
        var structuralDuplicates = ReadUInt64(downloaded, 64);
        var semanticDuplicates = ReadUInt64(downloaded, 72);
        var evaluated = ReadUInt64(downloaded, 80);
        var accepted = ReadUInt64(downloaded, 88);
        var totalStructuralCount = ReadInt32(downloaded, 96);
        var totalSemanticCount = ReadInt32(downloaded, 100);
        var generation = ReadUInt64(downloaded, 104);
        var refreshCursor = ReadInt32(downloaded, 112);
        var refreshCount = ReadInt32(downloaded, 116);
        var enumerationTrialCount = ReadUInt64(downloaded, 120);
        var waveCursor = ReadUInt64(downloaded, 128);
        var candidateChunkCount = ReadInt32(downloaded, 136);
        var maximumConcurrentCandidates = ReadInt32(downloaded, 140);
        var trialDelta = trialCursor >= previous.TrialCursor
            ? trialCursor - previous.TrialCursor
            : ulong.MaxValue;
        var proposalWaveSize = checked((ulong)definition.WavePolicy.ProposalWaveSize);
        var expectedWaveDelta = trialDelta / proposalWaveSize +
            (trialDelta % proposalWaveSize == 0 ? 0ul : 1ul);
        var maximumCandidateChunks = checked(
            definition.WavePolicy.WavesPerCycle *
            ((definition.WavePolicy.ProposalWaveSize + CandidateLaneCount - 1) /
                CandidateLaneCount));
        if (trialCount < 0 || trialCount > definition.WavePolicy.MaximumTrialResultsPerCycle ||
            newStructuralCount < 0 ||
            newStructuralCount > definition.WavePolicy.MaximumTrialResultsPerCycle ||
            newSemanticCount < 0 ||
            newSemanticCount > definition.WavePolicy.MaximumTrialResultsPerCycle ||
            paretoCount < 0 || paretoCount > definition.Selection.ParetoCapacity ||
            qualityCount < 0 || qualityCount > definition.QualityDiversity.CellCount ||
            totalStructuralCount != checked(previous.StructuralFingerprints.Count + newStructuralCount) ||
            totalSemanticCount != checked(previous.SemanticFingerprints.Count + newSemanticCount) ||
            totalStructuralCount > definition.Population.FingerprintCapacity ||
            totalSemanticCount > definition.Population.FingerprintCapacity ||
            enumerationCursor > definition.EnumerationCursorLimit ||
            enumerationTrialCount > definition.Evolution.EnumerationProposalCount ||
            enumerationTrialCount > enumerationCursor ||
            enumerationTrialCount > trialCursor ||
            enumerationCursor < previous.EnumerationCursor ||
            enumerationTrialCount < previous.EnumerationTrialCount ||
            trialCursor < previous.TrialCursor ||
            waveCursor < previous.WaveCursor ||
            waveCursor - previous.WaveCursor != expectedWaveDelta ||
            waveCursor > trialCursor ||
            enumerationTrialCount - previous.EnumerationTrialCount >
                trialCursor - previous.TrialCursor ||
            trialCursor > definition.Evolution.MaximumTrialCount ||
            cycleCount != checked(previous.CycleCount + 1) ||
            generation != previous.EnvelopeGeneration ||
            refreshCount != previous.RefreshPrograms.Count ||
            refreshCursor < previous.RefreshCursor ||
            refreshCursor > refreshCount ||
            candidateChunkCount < 0 || candidateChunkCount > maximumCandidateChunks ||
            maximumConcurrentCandidates < 0 ||
            maximumConcurrentCandidates > Math.Min(
                CandidateLaneCount,
                definition.WavePolicy.ProposalWaveSize) ||
            (candidateChunkCount == 0) != (maximumConcurrentCandidates == 0))
        {
            throw new InvalidDataException("The resident search state is invalid.");
        }

        var structural = AppendFingerprints(
            previous.StructuralFingerprints,
            downloaded,
            CompactStructuralOffset - CompactOffset,
            newStructuralCount);
        var semantic = AppendFingerprints(
            previous.SemanticFingerprints,
            downloaded,
            CompactSemanticOffset - CompactOffset,
            newSemanticCount);
        var selection = new MathBlockProgramPopulationArchiveEntry[paretoCount];
        for (var index = 0; index < selection.Length; index++)
        {
            selection[index] = ReadArchiveEntry(
                downloaded,
                CompactParetoOffset - CompactOffset + index * ArchiveEntrySize,
                definition,
                null);
        }
        var quality = new MathBlockProgramPopulationArchiveEntry[qualityCount];
        var qualityIndex = 0;
        for (var cell = 0; cell < definition.QualityDiversity.CellCount; cell++)
        {
            var offset = CompactQualityOffset - CompactOffset + cell * ArchiveEntrySize;
            if (ReadInt32(downloaded, offset) == 0)
                continue;
            if (qualityIndex >= quality.Length)
                throw new InvalidDataException("The resident quality-diversity count is invalid.");
            quality[qualityIndex++] = ReadArchiveEntry(downloaded, offset, definition, cell);
        }
        if (qualityIndex != quality.Length)
            throw new InvalidDataException("The resident quality-diversity count is invalid.");
        var trials = new MathBlockProgramPopulationTrialResult[trialCount];
        for (var index = 0; index < trials.Length; index++)
        {
            trials[index] = ReadTrial(
                downloaded,
                CompactTrialOffset - CompactOffset + index * TrialEntrySize,
                definition);
        }
        var state = new MathBlockProgramPopulationSearchState(
            definition.Identity,
            enumerationCursor,
            enumerationTrialCount,
            trialCursor,
            cycleCount,
            waveCursor,
            generation,
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
            previous.RefreshPrograms);
        return new PopulationSearchCycleParseResult(
            status,
            state,
            trials,
            candidateChunkCount,
            maximumConcurrentCandidates);
    }

    private void WriteHeader(Span<byte> bytes, MathBlockProgramPopulationSearchDefinition definition)
    {
        WriteInt32(bytes, 0, unchecked((int)0x4d425334));
        WriteInt32(bytes, 4, 11);
        WriteInt32(bytes, 8, operations.Length);
        WriteInt32(bytes, 12, terminals.Length);
        WriteInt32(bytes, 16, types.Length);
        WriteInt32(bytes, 20, bandStarts.Length);
        WriteInt32(bytes, 24, MaximumOperationCount);
        WriteInt32(bytes, 28, MaximumBandElements);
        WriteInt32(bytes, 32, MaximumValueElements);
        WriteInt32(bytes, 36, definition.Population.ProposalsPerCycle);
        WriteInt32(bytes, 40, definition.Population.FingerprintCapacity);
        WriteInt32(bytes, 44, FindType(definition.Population.Grammar.OutputType));
        WriteInt32(bytes, 48, objectiveNodes.Length);
        WriteInt32(bytes, 52, objectiveSources.Length);
        WriteInt32(bytes, 56, definition.Selection.ParetoCapacity);
        WriteInt32(bytes, 60, definition.QualityDiversity.CellCount);
        WriteInt32(bytes, 64, qualityDimensions.Length);
        WriteInt32(bytes, 68, definition.Selection.MaximumAge);
        WriteInt32(bytes, 72, definition.CompactResults.IncludeRejectedTrials ? 1 : 0);
        WriteInt32(bytes, 76, definition.Evolution.MutationTrials);
        WriteInt32(bytes, 80, definition.Evolution.CrossoverTrials);
        WriteInt32(bytes, 84, definition.Evolution.RandomImmigrantTrials);
        WriteInt32(bytes, 88, definition.Evolution.EvolutionPatternLength);
        WriteInt32(bytes, 92, definition.QualityObjectiveIndex);
        WriteInt32(bytes, 96, MaximumArity);
        WriteInt32(bytes, 100, ScratchBytesPerNode);
        WriteInt32(bytes, 104, PayloadStride);
        WriteInt32(bytes, 108, ProgramOperationSize);
        WriteInt32(bytes, 112, ArchiveEntrySize);
        WriteInt32(bytes, 116, TrialEntrySize);
        WriteInt32(bytes, 120, definition.Validity.HistoryCounts.Count);
        WriteInt32(bytes, 124,
            definition.AcceptedState?.RefreshPrograms.Count ?? definition.InitialPrograms.Count);
        var offsets = new[]
        {
            OperationOffset, OperationInputTypeOffset, TerminalOffset, TypeOffset, BandOffset,
            ImmutableSlotOffset, ImmutablePayloadOffset, ObjectiveNodeOffset, ObjectiveInputOffset,
            ObjectiveSourceOffset, QualityDimensionOffset, HistoryOffset, CandidateSlotOffset,
            ObjectiveSlotOffset, MaskSlotOffset, CandidatePayloadOffset, ObjectivePayloadOffset,
            MaskPayloadOffset, ScratchOffset, InputPointerOffset, SelectedOperationOffset,
            SelectedOperandOffset, SelectedLookbackOffset, AcceptedStateOffset, AcceptedStructuralOffset,
            AcceptedSemanticOffset, AcceptedParetoOffset, AcceptedQualityOffset, WorkingStateOffset,
            WorkingStructuralOffset, WorkingSemanticOffset, WorkingParetoOffset, WorkingQualityOffset,
            RefreshOffset, CompactOffset, CompactSize, CompactStructuralOffset, CompactSemanticOffset,
            CompactParetoOffset, CompactQualityOffset, CompactTrialOffset, ArenaSize
        };
        for (var index = 0; index < offsets.Length; index++)
            WriteInt32(bytes, 128 + index * sizeof(int), offsets[index]);
        WriteUInt64(bytes, 296, definition.EnumerationCursorLimit);
        WriteUInt64(bytes, 304, definition.Evolution.EnumerationProposalCount);
        WriteUInt64(bytes, 312, definition.Evolution.MaximumTrialCount);
        WriteInt32(bytes, 320, definition.WavePolicy.MaximumTrialResultsPerCycle);
        WriteInt32(bytes, 324, definition.WavePolicy.ProposalWaveSize);
        WriteInt32(bytes, 328, definition.WavePolicy.WavesPerCycle);
        WriteInt32(bytes, 332, ProposalWaveSlotOffset);
        WriteInt32(bytes, 336, ProposalWaveSlotBytes);
        WriteInt32(bytes, 340, ProposalWaveSnapshotParetoOffset);
        WriteInt32(bytes, 344, ProposalWaveSnapshotQualityOffset);
        WriteInt32(bytes, 348, ProposalWaveControlOffset);
        WriteInt32(bytes, 352, CandidateLaneCount);
        WriteInt32(bytes, 356, LaneStrideBytes);
        WriteUInt64(bytes, 360, definition.EnumerationCatalog?.CursorStart ?? 0);
        WriteInt32(bytes, 368, EnumerationCatalogOffset);
        WriteInt32(bytes, 372, definition.EnumerationCatalog?.Programs.Count ?? 0);
    }

    private void WriteAcceptedState(
        Span<byte> bytes,
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationSearchState state)
    {
        WriteInt32(bytes, AcceptedStateOffset, state.StructuralFingerprints.Count);
        WriteInt32(bytes, AcceptedStateOffset + 4, state.SemanticFingerprints.Count);
        WriteInt32(bytes, AcceptedStateOffset + 8, state.SelectionEntries.Count);
        WriteInt32(bytes, AcceptedStateOffset + 12, state.QualityDiversityEntries.Count);
        WriteUInt64(bytes, AcceptedStateOffset + 16, state.EnumerationCursor);
        WriteUInt64(bytes, AcceptedStateOffset + 24, state.TrialCursor);
        WriteUInt64(bytes, AcceptedStateOffset + 32, state.CycleCount);
        WriteUInt64(bytes, AcceptedStateOffset + 40, state.RandomState.First);
        WriteUInt64(bytes, AcceptedStateOffset + 48, state.RandomState.Second);
        WriteUInt64(bytes, AcceptedStateOffset + 56, state.StructuralDuplicateCount);
        WriteUInt64(bytes, AcceptedStateOffset + 64, state.SemanticDuplicateCount);
        WriteUInt64(bytes, AcceptedStateOffset + 72, state.EvaluatedProgramCount);
        WriteUInt64(bytes, AcceptedStateOffset + 80, state.AcceptedProgramCount);
        WriteUInt64(bytes, AcceptedStateOffset + 88, state.EnvelopeGeneration);
        WriteInt32(bytes, AcceptedStateOffset + 96, state.RefreshCursor);
        WriteInt32(bytes, AcceptedStateOffset + 100, state.RefreshPrograms.Count);
        WriteUInt64(bytes, AcceptedStateOffset + 104, state.EnumerationTrialCount);
        WriteUInt64(bytes, AcceptedStateOffset + 112, state.WaveCursor);
        WriteFingerprints(bytes, AcceptedStructuralOffset, state.StructuralFingerprints);
        WriteFingerprints(bytes, AcceptedSemanticOffset, state.SemanticFingerprints);
        for (var index = 0; index < state.SelectionEntries.Count; index++)
            WriteArchiveEntry(bytes, AcceptedParetoOffset + index * ArchiveEntrySize, definition, state.SelectionEntries[index]);
        foreach (var entry in state.QualityDiversityEntries)
        {
            if ((uint)entry.QualityDiversityCell >= (uint)definition.QualityDiversity.CellCount)
                throw new InvalidOperationException("An accepted quality-diversity cell is invalid.");
            WriteArchiveEntry(
                bytes,
                AcceptedQualityOffset + entry.QualityDiversityCell * ArchiveEntrySize,
                definition,
                entry);
        }
        for (var index = 0; index < state.RefreshPrograms.Count; index++)
            WriteRefreshEntry(bytes, RefreshOffset + index * ArchiveEntrySize, definition, state.RefreshPrograms[index]);
    }

    private void WriteArchiveEntry(
        Span<byte> bytes,
        int offset,
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationArchiveEntry entry)
    {
        WriteProgramEntry(
            bytes,
            offset,
            definition,
            entry.Program,
            entry.Age,
            entry.QualityDiversityCell,
            entry.SemanticFingerprint,
            entry.Objectives);
    }

    private void WriteRefreshEntry(
        Span<byte> bytes,
        int offset,
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramStructure program) =>
        WriteProgramEntry(bytes, offset, definition, program, 0, -1, null, null);

    private void WriteProgramEntry(
        Span<byte> bytes,
        int offset,
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramStructure program,
        int age,
        int cell,
        string? semanticFingerprint,
        IReadOnlyList<double>? objectives)
    {
        var operationIndexes = GetOperationIndexes(definition.Population, program);
        WriteInt32(bytes, offset, 1);
        WriteInt32(bytes, offset + 4, (int)program.Source);
        WriteInt32(bytes, offset + 8, age);
        WriteInt32(bytes, offset + 12, operationIndexes.Length);
        WriteInt32(bytes, offset + 16, cell);
        WriteUInt64(bytes, offset + 32, program.TrialCursor);
        WriteUInt64(bytes, offset + 40, program.ProposalCursor ?? ulong.MaxValue);
        var structural = MathBlockProgramPopulationFingerprint.Parse(program.StructuralFingerprint);
        WriteUInt64(bytes, offset + 48, structural.First);
        WriteUInt64(bytes, offset + 56, structural.Second);
        if (semanticFingerprint is not null)
        {
            var semantic = MathBlockProgramPopulationFingerprint.Parse(semanticFingerprint);
            WriteUInt64(bytes, offset + 64, semantic.First);
            WriteUInt64(bytes, offset + 72, semantic.Second);
        }
        if (objectives is not null)
        {
            if (objectives.Count != objectiveSources.Length)
                throw new InvalidOperationException("An archive objective count is incompatible.");
            for (var index = 0; index < objectives.Count; index++)
                WriteUInt64(bytes, offset + EntryHeaderSize + index * sizeof(ulong), Math.ToBits(objectives[index]));
        }
        var operationOffset = offset + GetEntryOperationOffset();
        var terminalCount = definition.Population.AllTerminals.Count;
        for (var operation = 0; operation < operationIndexes.Length; operation++)
        {
            var node = program.Nodes[terminalCount + operation];
            var entry = operationOffset + operation * ProgramOperationSize;
            WriteInt32(bytes, entry, operationIndexes[operation]);
            WriteInt32(bytes, entry + 4, node.OperandIndexes.Count);
            for (var input = 0; input < node.OperandIndexes.Count; input++)
                WriteInt32(bytes, entry + 8 + input * sizeof(int), node.OperandIndexes[input]);
        }
    }

    private MathBlockProgramPopulationArchiveEntry ReadArchiveEntry(
        ReadOnlySpan<byte> bytes,
        int offset,
        MathBlockProgramPopulationSearchDefinition definition,
        int? requiredCell)
    {
        if (ReadInt32(bytes, offset) != 1)
            throw new InvalidDataException("A resident archive entry is invalid.");
        var source = ReadTrialSource(bytes, offset + 4);
        var age = ReadInt32(bytes, offset + 8);
        var operationCount = ReadInt32(bytes, offset + 12);
        var cell = ReadInt32(bytes, offset + 16);
        if (age < 0 || age > definition.Selection.MaximumAge ||
            operationCount <= 0 || operationCount > MaximumOperationCount ||
            cell < -1 || cell >= definition.QualityDiversity.CellCount ||
            requiredCell.HasValue && cell != requiredCell.Value)
        {
            throw new InvalidDataException("A resident archive entry is outside its bounds.");
        }
        var program = ReadProgram(
            bytes,
            offset,
            definition,
            source,
            operationCount,
            ReadUInt64(bytes, offset + 32),
            ReadProposalCursor(bytes, offset + 40));
        var expectedStructural = MathBlockProgramPopulationFingerprint.Format(
            ReadUInt64(bytes, offset + 48),
            ReadUInt64(bytes, offset + 56));
        if (!string.Equals(program.StructuralFingerprint, expectedStructural, StringComparison.Ordinal))
            throw new InvalidDataException("A resident archive structural fingerprint is invalid.");
        var semantic = MathBlockProgramPopulationFingerprint.Format(
            ReadUInt64(bytes, offset + 64),
            ReadUInt64(bytes, offset + 72));
        return new MathBlockProgramPopulationArchiveEntry(
            program,
            ReadObjectives(bytes, offset + EntryHeaderSize),
            age,
            semantic,
            cell);
    }

    private MathBlockProgramPopulationTrialResult ReadTrial(
        ReadOnlySpan<byte> bytes,
        int offset,
        MathBlockProgramPopulationSearchDefinition definition)
    {
        var status = (MathBlockProgramPopulationTrialStatus)ReadInt32(bytes, offset);
        if (!Enum.IsDefined(status))
            throw new InvalidDataException("A resident trial status is invalid.");
        var source = ReadTrialSource(bytes, offset + 4);
        var flags = ReadInt32(bytes, offset + 24);
        var operationCount = ReadInt32(bytes, offset + 12);
        var cell = ReadInt32(bytes, offset + 16);
        if (operationCount < 0 || operationCount > MaximumOperationCount ||
            cell < -1 || cell >= definition.QualityDiversity.CellCount ||
            (flags & ~15) != 0)
        {
            throw new InvalidDataException("A resident trial entry is outside its bounds.");
        }
        var program = ReadProgram(
            bytes,
            offset,
            definition,
            source,
            operationCount,
            ReadUInt64(bytes, offset + 32),
            ReadProposalCursor(bytes, offset + 40));
        var expectedStructural = MathBlockProgramPopulationFingerprint.Format(
            ReadUInt64(bytes, offset + 48),
            ReadUInt64(bytes, offset + 56));
        if (!string.Equals(program.StructuralFingerprint, expectedStructural, StringComparison.Ordinal))
            throw new InvalidDataException("A resident trial structural fingerprint is invalid.");
        string? semantic = null;
        if ((flags & 8) != 0)
        {
            semantic = MathBlockProgramPopulationFingerprint.Format(
                ReadUInt64(bytes, offset + 64),
                ReadUInt64(bytes, offset + 72));
        }
        var objectives = (flags & 4) != 0
            ? ReadObjectives(bytes, offset + EntryHeaderSize)
            : [];
        return new MathBlockProgramPopulationTrialResult(
            program,
            status,
            objectives,
            semantic,
            (flags & 1) != 0,
            (flags & 2) != 0,
            cell);
    }

    private MathBlockProgramStructure ReadProgram(
        ReadOnlySpan<byte> bytes,
        int entryOffset,
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationTrialSource source,
        int operationCount,
        ulong trialCursor,
        ulong? proposalCursor)
    {
        var population = definition.Population;
        var nodes = new List<MathBlockProgramCandidateNode>(terminals.Length + operationCount);
        for (var terminal = 0; terminal < terminals.Length; terminal++)
        {
            var descriptor = population.AllTerminals[terminal];
            nodes.Add(MathBlockProgramCandidateNode.Terminal(terminal, descriptor.Identifier, descriptor.Type));
        }
        var operationOffset = entryOffset + GetEntryOperationOffset();
        for (var operationNode = 0; operationNode < operationCount; operationNode++)
        {
            var sourceOffset = operationOffset + operationNode * ProgramOperationSize;
            var operationIndex = ReadInt32(bytes, sourceOffset);
            if ((uint)operationIndex >= (uint)population.Grammar.Operations.Count)
                throw new InvalidDataException("A resident program operation index is invalid.");
            var descriptor = population.Grammar.Operations[operationIndex];
            if (ReadInt32(bytes, sourceOffset + 4) != descriptor.InputTypes.Count)
                throw new InvalidDataException("A resident program operation arity is invalid.");
            var operands = new int[descriptor.InputTypes.Count];
            for (var input = 0; input < operands.Length; input++)
            {
                operands[input] = ReadInt32(bytes, sourceOffset + 8 + input * sizeof(int));
                if (operands[input] < 0 || operands[input] >= terminals.Length + operationNode)
                    throw new InvalidDataException("A resident program operand index is invalid.");
            }
            nodes.Add(MathBlockProgramCandidateNode.Operation(
                descriptor.Identifier,
                descriptor.Version,
                descriptor.OutputType,
                operands));
        }
        return new MathBlockProgramStructure(trialCursor, proposalCursor, source, nodes);
    }

    private int[] GetOperationIndexes(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramStructure program)
    {
        var terminalCount = population.AllTerminals.Count;
        if (program.Nodes.Count <= terminalCount ||
            program.Nodes.Count - terminalCount > MaximumOperationCount)
        {
            throw new InvalidOperationException("An archive program has an invalid operation count.");
        }
        for (var terminal = 0; terminal < terminalCount; terminal++)
        {
            var node = program.Nodes[terminal];
            var descriptor = population.AllTerminals[terminal];
            if (node.Kind != MathBlockProgramCandidateNodeKind.Terminal ||
                node.TerminalIndex != terminal ||
                node.Type != descriptor.Type ||
                !string.Equals(node.TerminalIdentifier, descriptor.Identifier, StringComparison.Ordinal))
            {
                throw new InvalidOperationException("An archive program terminal is incompatible.");
            }
        }
        var result = new int[program.Nodes.Count - terminalCount];
        for (var operationNode = 0; operationNode < result.Length; operationNode++)
        {
            var node = program.Nodes[terminalCount + operationNode];
            var match = -1;
            for (var operationIndex = 0; operationIndex < population.Grammar.Operations.Count; operationIndex++)
            {
                var descriptor = population.Grammar.Operations[operationIndex];
                if (!string.Equals(descriptor.Identifier, node.OperationIdentifier, StringComparison.Ordinal) ||
                    descriptor.Version != node.OperationVersion ||
                    descriptor.OutputType != node.Type ||
                    descriptor.InputTypes.Count != node.OperandIndexes.Count)
                {
                    continue;
                }
                var valid = true;
                for (var input = 0; input < descriptor.InputTypes.Count; input++)
                {
                    if (descriptor.InputTypes[input] != program.Nodes[node.OperandIndexes[input]].Type)
                    {
                        valid = false;
                        break;
                    }
                }
                if (!valid)
                    continue;
                if (match >= 0)
                    throw new InvalidOperationException("An archive operation is ambiguous.");
                match = operationIndex;
            }
            if (match < 0)
                throw new InvalidOperationException("An archive operation is incompatible.");
            result[operationNode] = match;
        }
        return result;
    }

    private double[] ReadObjectives(ReadOnlySpan<byte> bytes, int offset)
    {
        var result = new double[objectiveSources.Length];
        for (var index = 0; index < result.Length; index++)
        {
            result[index] = Math.FromBits(ReadUInt64(bytes, offset + index * sizeof(ulong)));
            if (!Math.IsFinite(result[index]))
                throw new InvalidDataException("A resident objective value is nonfinite.");
        }
        return result;
    }

    private static CompiledObjective CompileObjective(
        MathBlockProgramPopulationSearchDefinition definition,
        Func<MathBlockType, int> addType,
        List<MathBlockValue> immutableValues,
        int maximumCandidateElements,
        ref int maximumArity,
        ref int maximumValueElements)
    {
        var binding = definition.ObjectiveBinding;
        var plan = binding.Program.PlanNodes;
        var capacityOverrides = new Dictionary<string, int>(StringComparer.Ordinal)
        {
            [binding.CandidateInput] = maximumCandidateElements
        };
        if (binding.CandidateValidityMaskInput is not null)
        {
            capacityOverrides.Add(
                binding.CandidateValidityMaskInput,
                definition.Validity.HistoryCounts.Count);
        }
        var shapeOverrides = new Dictionary<string, MathBlockCudaShapeAuthority>(StringComparer.Ordinal);
        var candidateType = binding.Program.Inputs[binding.CandidateInput];
        if (candidateType.Kind is MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix)
        {
            shapeOverrides.Add(
                binding.CandidateInput,
                ResolveMatrixCandidateShapeAuthority(
                    definition.Population,
                    candidateType,
                    maximumCandidateElements));
        }
        else if (candidateType.Kind == MathBlockValueKind.Graph)
        {
            var graphShape = ResolveGraphCandidateShapeAuthority(definition.Population, candidateType);
            if (graphShape.Rows > 0)
                shapeOverrides.Add(binding.CandidateInput, graphShape);
        }
        var payloadLayout = MathBlocksCUDAProgram.ResolvePayloadLayout(
            plan,
            binding.ResidentInputs,
            capacityOverrides,
            shapeOverrides);
        var payloadCapacities = payloadLayout.Capacities;
        for (var index = 0; index < payloadCapacities.Length; index++)
            maximumValueElements = Math.Max(maximumValueElements, payloadCapacities[index]);
        var objectivePayloadLayout = CreateObjectivePayloadLayout(binding, payloadCapacities);
        var nodes = new ObjectiveNodeDescriptor[plan.Count];
        var inputs = new List<int>();
        var candidateCount = 0;
        var maskCount = 0;
        var maximumScratchBytes = 0;
        for (var index = 0; index < plan.Count; index++)
        {
            var node = plan[index];
            if (node.Kind == MathBlockProgramNodeKind.Input &&
                string.Equals(node.Name, binding.CandidateInput, StringComparison.Ordinal))
            {
                nodes[index] = new ObjectiveNodeDescriptor(
                    0,
                    addType(node.Type),
                    -1,
                    -1,
                    0,
                    inputs.Count,
                    -1,
                    payloadCapacities[index],
                    -1,
                    -1);
                candidateCount++;
                continue;
            }
            if (node.Kind == MathBlockProgramNodeKind.Input &&
                string.Equals(node.Name, binding.CandidateValidityMaskInput, StringComparison.Ordinal))
            {
                nodes[index] = new ObjectiveNodeDescriptor(
                    1,
                    addType(node.Type),
                    -1,
                    -1,
                    0,
                    inputs.Count,
                    -1,
                    payloadCapacities[index],
                    -1,
                    -1);
                maskCount++;
                continue;
            }
            if (node.Kind is MathBlockProgramNodeKind.Input or MathBlockProgramNodeKind.Constant)
            {
                var value = node.Kind == MathBlockProgramNodeKind.Constant
                    ? node.Value
                    : binding.ResidentInputs[node.Name!];
                var immutableIndex = immutableValues.Count;
                immutableValues.Add(value);
                maximumValueElements = Math.Max(maximumValueElements, MathBlockCudaValueLayout.GetElementCount(value));
                nodes[index] = new ObjectiveNodeDescriptor(
                    2,
                    addType(node.Type),
                    -1,
                    -1,
                    0,
                    inputs.Count,
                    immutableIndex,
                    payloadCapacities[index],
                    -1,
                    -1);
                continue;
            }
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                throw new NotSupportedException("An objective program node kind is unsupported.");
            var feature = MathBlockCudaFeatureIndex.Resolve(node.OperationIdentity!);
            var inputBase = inputs.Count;
            foreach (var input in node.Inputs)
                inputs.Add(input);
            maximumArity = Math.Max(maximumArity, node.Inputs.Count);
            var nodeScratchBytes = MathBlocksCUDAProgram.ResolveScratchBytes(node, plan, payloadLayout);
            maximumScratchBytes = Math.Max(maximumScratchBytes, nodeScratchBytes);
            nodes[index] = new ObjectiveNodeDescriptor(
                3,
                addType(node.Type),
                (int)feature.Family,
                feature.Opcode,
                node.Inputs.Count,
                inputBase,
                -1,
                payloadCapacities[index],
                objectivePayloadLayout.Offsets[index],
                nodeScratchBytes);
        }
        if (candidateCount != 1)
            throw new ArgumentException("The objective program requires one candidate input.", nameof(definition));
        if ((binding.CandidateValidityMaskInput is null ? 0 : 1) != maskCount)
            throw new ArgumentException("The objective validity-mask binding is inconsistent.", nameof(definition));

        var sources = new ObjectiveSourceDescriptor[binding.Objectives.Count];
        for (var index = 0; index < sources.Length; index++)
        {
            var objective = binding.Objectives[index];
            var programNode = objective.SourceKind == MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput
                ? binding.Program.OutputNodeIndexes[objective.ProgramOutput!]
                : -1;
            sources[index] = new ObjectiveSourceDescriptor(
                (int)objective.SourceKind,
                programNode,
                (int)objective.Direction);
        }
        var dimensions = new QualityDimensionDescriptor[definition.QualityDiversity.Dimensions.Count];
        var multiplier = 1;
        for (var index = 0; index < dimensions.Length; index++)
        {
            var source = definition.QualityDiversity.Dimensions[index];
            dimensions[index] = new QualityDimensionDescriptor(
                definition.QualityDiversityObjectiveIndexes[index],
                source.BinCount,
                multiplier,
                Math.ToBits(source.Minimum),
                Math.ToBits(source.Maximum));
            multiplier = checked(multiplier * source.BinCount);
        }
        if (multiplier != definition.QualityDiversity.CellCount)
            throw new InvalidOperationException("The quality-diversity cell count is inconsistent.");
        return new CompiledObjective(
            nodes,
            inputs.ToArray(),
            sources,
            dimensions,
            objectivePayloadLayout.PayloadBytes,
            maximumScratchBytes);
    }

    private static ObjectivePayloadLayout CreateObjectivePayloadLayout(
        MathBlockProgramPopulationObjectiveBinding binding,
        IReadOnlyList<int> payloadCapacities)
    {
        var plan = binding.Program.PlanNodes;
        if (payloadCapacities.Count != plan.Count)
            throw new InvalidOperationException("The objective payload-capacity count is inconsistent.");

        var lastUses = new int[plan.Count];
        for (var nodeIndex = 0; nodeIndex < plan.Count; nodeIndex++)
        {
            lastUses[nodeIndex] = nodeIndex;
            foreach (var inputIndex in plan[nodeIndex].Inputs)
            {
                if (inputIndex < 0 || inputIndex >= nodeIndex)
                    throw new ArgumentException("An objective input must reference an earlier node.", "definition");
                lastUses[inputIndex] = Math.Max(lastUses[inputIndex], nodeIndex);
            }
        }
        foreach (var objective in binding.Objectives)
        {
            if (objective.SourceKind != MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput)
                continue;
            if (!binding.Program.OutputNodeIndexes.TryGetValue(objective.ProgramOutput!, out var sourceIndex))
                throw new ArgumentException("An objective output source is absent.", "definition");
            lastUses[sourceIndex] = plan.Count;
        }

        var offsets = new int[plan.Count];
        for (var nodeIndex = 0; nodeIndex < offsets.Length; nodeIndex++)
            offsets[nodeIndex] = -1;
        var releases = new List<ObjectivePayloadRange>?[plan.Count];
        var freeRanges = new List<ObjectivePayloadRange>();
        var highWater = 0;
        var peakBytes = 0;
        for (var nodeIndex = 0; nodeIndex < plan.Count; nodeIndex++)
        {
            if (releases[nodeIndex] is { } releasedRanges)
            {
                foreach (var range in releasedRanges)
                    ReleaseObjectivePayloadRange(freeRanges, range, ref highWater);
            }

            var node = plan[nodeIndex];
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                continue;
            var payloadBytes = MeasurePayloadBytes(
                node.Type.Kind,
                payloadCapacities[nodeIndex],
                $"objective node {nodeIndex} payload");
            if (payloadBytes == 0)
            {
                offsets[nodeIndex] = 0;
                continue;
            }

            var offset = AllocateObjectivePayloadRange(
                freeRanges,
                payloadBytes,
                nodeIndex,
                ref highWater,
                ref peakBytes);
            offsets[nodeIndex] = offset;
            var releaseIndex = checked(lastUses[nodeIndex] + 1);
            if (releaseIndex < plan.Count)
            {
                releases[releaseIndex] ??= [];
                releases[releaseIndex]!.Add(new ObjectivePayloadRange(offset, payloadBytes));
            }
        }
        return new ObjectivePayloadLayout(offsets, peakBytes);
    }

    private static int AllocateObjectivePayloadRange(
        List<ObjectivePayloadRange> freeRanges,
        int payloadBytes,
        int nodeIndex,
        ref int highWater,
        ref int peakBytes)
    {
        for (var rangeIndex = 0; rangeIndex < freeRanges.Count; rangeIndex++)
        {
            var range = freeRanges[rangeIndex];
            if (range.Bytes < payloadBytes)
                continue;
            if (range.Bytes == payloadBytes)
                freeRanges.RemoveAt(rangeIndex);
            else
                freeRanges[rangeIndex] = new ObjectivePayloadRange(
                    checked(range.Offset + payloadBytes),
                    checked(range.Bytes - payloadBytes));
            return range.Offset;
        }

        var offset = highWater;
        highWater = AdvanceLayout(
            highWater,
            1,
            payloadBytes,
            $"objective node {nodeIndex} payload");
        peakBytes = Math.Max(peakBytes, highWater);
        return offset;
    }

    private static void ReleaseObjectivePayloadRange(
        List<ObjectivePayloadRange> freeRanges,
        ObjectivePayloadRange released,
        ref int highWater)
    {
        var insertIndex = 0;
        while (insertIndex < freeRanges.Count && freeRanges[insertIndex].Offset < released.Offset)
            insertIndex++;

        var start = released.Offset;
        var end = checked(released.Offset + released.Bytes);
        if (insertIndex > 0)
        {
            var previous = freeRanges[insertIndex - 1];
            var previousEnd = checked(previous.Offset + previous.Bytes);
            if (previousEnd > start)
                throw new InvalidOperationException("Objective payload lifetimes overlap in the free pool.");
            if (previousEnd == start)
            {
                start = previous.Offset;
                freeRanges.RemoveAt(--insertIndex);
            }
        }
        if (insertIndex < freeRanges.Count)
        {
            var next = freeRanges[insertIndex];
            if (next.Offset < end)
                throw new InvalidOperationException("Objective payload lifetimes overlap in the free pool.");
            if (next.Offset == end)
            {
                end = checked(next.Offset + next.Bytes);
                freeRanges.RemoveAt(insertIndex);
            }
        }
        freeRanges.Insert(insertIndex, new ObjectivePayloadRange(start, checked(end - start)));

        while (freeRanges.Count > 0)
        {
            var last = freeRanges[^1];
            if (checked(last.Offset + last.Bytes) != highWater)
                break;
            highWater = last.Offset;
            freeRanges.RemoveAt(freeRanges.Count - 1);
        }
    }

    private static MathBlockCudaShapeAuthority ResolveMatrixCandidateShapeAuthority(
        MathBlockProgramPopulationDefinition population,
        MathBlockType candidateType,
        int maximumCandidateElements)
    {
        var maximumRows = 0;
        var maximumColumns = 0;
        foreach (var operation in population.Grammar.Operations)
        {
            var outputType = operation.OutputType;
            if (!candidateType.Accepts(outputType) || !population.Grammar.OutputType.Accepts(outputType))
                continue;
            var shape = ResolveMatrixShapeAuthority(outputType, maximumCandidateElements);
            maximumRows = Math.Max(maximumRows, shape.Rows);
            maximumColumns = Math.Max(maximumColumns, shape.Columns);
        }
        if (maximumRows == 0 || maximumColumns == 0)
        {
            var shape = ResolveMatrixShapeAuthority(candidateType, maximumCandidateElements);
            maximumRows = Math.Max(maximumRows, shape.Rows);
            maximumColumns = Math.Max(maximumColumns, shape.Columns);
        }
        if (maximumRows <= 0 || maximumColumns <= 0)
            throw new InvalidOperationException("The candidate matrix shape authority is unavailable.");
        return new MathBlockCudaShapeAuthority(maximumRows, maximumColumns);
    }

    private static MathBlockCudaShapeAuthority ResolveGraphCandidateShapeAuthority(
        MathBlockProgramPopulationDefinition population,
        MathBlockType candidateType)
    {
        var maximumVertices = 0;
        foreach (var operation in population.Grammar.Operations)
        {
            var outputType = operation.OutputType;
            if (!candidateType.Accepts(outputType) || !population.Grammar.OutputType.Accepts(outputType))
                continue;
            if (outputType.Rows <= 0)
                throw new InvalidOperationException("The candidate graph vertex authority is unavailable.");
            maximumVertices = Math.Max(maximumVertices, outputType.Rows);
        }
        if (maximumVertices == 0 && candidateType.Accepts(population.Grammar.OutputType))
            maximumVertices = population.Grammar.OutputType.Rows;
        return new MathBlockCudaShapeAuthority(maximumVertices, 0);
    }

    private static MathBlockCudaShapeAuthority ResolveMatrixShapeAuthority(
        MathBlockType type,
        int maximumElements)
    {
        if (type.Kind is not (MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix))
            return default;
        if (type.Rows > 0 && type.Columns > 0)
        {
            return checked(type.Rows * type.Columns) <= maximumElements
                ? new MathBlockCudaShapeAuthority(type.Rows, type.Columns)
                : default;
        }
        if (type.Rows > 0)
        {
            return type.Rows <= maximumElements
                ? new MathBlockCudaShapeAuthority(type.Rows, maximumElements / type.Rows)
                : default;
        }
        if (type.Columns > 0)
        {
            return type.Columns <= maximumElements
                ? new MathBlockCudaShapeAuthority(maximumElements / type.Columns, type.Columns)
                : default;
        }
        return new MathBlockCudaShapeAuthority(maximumElements, maximumElements);
    }

    private static void ValidateOperation(MathBlockProgramPopulationOperation descriptor)
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
        if (operation.Arity != descriptor.InputTypes.Count)
            throw new InvalidOperationException("A population operation arity is incompatible.");
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
            throw new InvalidOperationException("A population operation output type is incompatible.");
        _ = MathBlockCudaFeatureIndex.Resolve(descriptor.Identity);
    }

    private static int CalculateCandidatePayloadStride(
        MathBlockProgramPopulationSearchDefinition definition,
        int maximumElements)
    {
        var result = 0;
        foreach (var operation in definition.Population.Grammar.Operations)
        {
            result = Math.Max(
                result,
                MeasurePayloadBytes(
                    operation.OutputType.Kind,
                    operation.OutputType.Kind switch
                    {
                        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
                        MathBlockValueKind.Complex => 1,
                        _ => maximumElements
                    },
                    $"candidate payload for '{operation.Identity}'"));
        }
        return result;
    }

    private static int CalculateCandidateScratchBytes(
        MathBlockProgramPopulationSearchDefinition definition,
        int maximumElements)
    {
        var result = 0;
        foreach (var operation in definition.Population.Grammar.Operations)
            result = Math.Max(
                result,
                ResolveCandidateScratchBytes(definition.Population, operation, maximumElements));
        return Align(result);
    }

    private static int ResolveCandidateScratchBytes(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramPopulationOperation operation,
        int maximumElements)
    {
        var inputCapacities = new int[operation.InputTypes.Count];
        var inputShapeRows = new int[operation.InputTypes.Count];
        var inputShapeColumns = new int[operation.InputTypes.Count];
        for (var index = 0; index < operation.InputTypes.Count; index++)
        {
            var type = operation.InputTypes[index];
            var capacity = ResolveCandidateInputCapacity(type, maximumElements);
            var shape = ResolveCandidateInputShape(population, type, capacity, maximumElements);
            inputCapacities[index] = capacity;
            inputShapeRows[index] = shape.Rows;
            inputShapeColumns[index] = shape.Columns;
        }
        return MathBlocksCUDAProgram.ResolveScratchBytes(
            operation.Identity,
            operation.OutputType,
            operation.InputTypes,
            inputCapacities,
            inputShapeRows,
            inputShapeColumns);
    }

    private static int ResolveCandidateInputCapacity(MathBlockType type, int maximumElements) => type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
        MathBlockValueKind.Complex => 1,
        MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix
            when type.Rows > 0 && type.Columns > 0 => checked(type.Rows * type.Columns),
        MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector or
            MathBlockValueKind.ComplexVector or MathBlockValueKind.PointSet or MathBlockValueKind.RunSet
            when type.Rows > 0 => type.Rows,
        MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector or MathBlockValueKind.Matrix or
            MathBlockValueKind.ComplexVector or MathBlockValueKind.ComplexMatrix or
            MathBlockValueKind.PointSet or MathBlockValueKind.Graph or MathBlockValueKind.RunSet => maximumElements,
        _ => throw new NotSupportedException($"The CUDA value ABI does not support '{type.Kind}'.")
    };

    private static MathBlockCudaShapeAuthority ResolveCandidateInputShape(
        MathBlockProgramPopulationDefinition population,
        MathBlockType type,
        int capacity,
        int maximumElements)
    {
        if (type.Kind == MathBlockValueKind.Graph)
            return new MathBlockCudaShapeAuthority(ResolveCandidateGraphRows(population, type), 0);
        if (type.Kind is MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix)
        {
            if (type.Rows > 0 && type.Columns > 0)
                return new MathBlockCudaShapeAuthority(type.Rows, type.Columns);
            if (type.Rows > 0)
                return new MathBlockCudaShapeAuthority(type.Rows, maximumElements / type.Rows);
            if (type.Columns > 0)
                return new MathBlockCudaShapeAuthority(maximumElements / type.Columns, type.Columns);
            return new MathBlockCudaShapeAuthority(maximumElements, maximumElements);
        }
        if (type.Kind == MathBlockValueKind.PointSet)
            return new MathBlockCudaShapeAuthority(type.Rows > 0 ? type.Rows : capacity, 2);
        if (type.Kind is MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector or
            MathBlockValueKind.ComplexVector or MathBlockValueKind.RunSet)
        {
            return new MathBlockCudaShapeAuthority(type.Rows > 0 ? type.Rows : capacity, type.Columns);
        }
        return new MathBlockCudaShapeAuthority(type.Rows, type.Columns);
    }

    private static int ResolveCandidateGraphRows(
        MathBlockProgramPopulationDefinition population,
        MathBlockType expectedType)
    {
        if (expectedType.Rows > 0)
            return expectedType.Rows;
        var rows = 0;
        foreach (var terminal in population.AllTerminals)
        {
            if (TypesCanBind(expectedType, terminal.Type))
                rows = Math.Max(rows, terminal.Value.Type.Rows);
        }
        foreach (var operation in population.Grammar.Operations)
        {
            if (!TypesCanBind(expectedType, operation.OutputType))
                continue;
            if (operation.OutputType.Rows <= 0)
                return 0;
            rows = Math.Max(rows, operation.OutputType.Rows);
        }
        return rows;
    }

    private static bool TypesCanBind(MathBlockType expected, MathBlockType actual) =>
        expected.Kind == actual.Kind &&
        expected.Unit == actual.Unit &&
        (expected.Rows == 0 || actual.Rows == 0 || expected.Rows == actual.Rows) &&
        (expected.Columns == 0 || actual.Columns == 0 || expected.Columns == actual.Columns);

    private int FindType(MathBlockType type)
    {
        for (var index = 0; index < types.Length; index++)
            if (types[index] == type)
                return index;
        throw new InvalidOperationException("A resident search type is missing.");
    }

    private int GetEntryOperationOffset() => Align(EntryHeaderSize + objectiveSources.Length * sizeof(ulong));

    private static string[] AppendFingerprints(
        IReadOnlyList<string> previous,
        ReadOnlySpan<byte> bytes,
        int offset,
        int count)
    {
        var result = new string[checked(previous.Count + count)];
        for (var index = 0; index < previous.Count; index++)
            result[index] = previous[index];
        for (var index = 0; index < count; index++)
        {
            result[previous.Count + index] = MathBlockProgramPopulationFingerprint.Format(
                ReadUInt64(bytes, offset + index * 16),
                ReadUInt64(bytes, offset + index * 16 + 8));
        }
        return result;
    }

    private static void WriteFingerprints(Span<byte> bytes, int offset, IReadOnlyList<string> fingerprints)
    {
        for (var index = 0; index < fingerprints.Count; index++)
        {
            var value = MathBlockProgramPopulationFingerprint.Parse(fingerprints[index]);
            WriteUInt64(bytes, offset + index * 16, value.First);
            WriteUInt64(bytes, offset + index * 16 + 8, value.Second);
        }
    }

    private static MathBlockProgramPopulationTrialSource ReadTrialSource(ReadOnlySpan<byte> bytes, int offset)
    {
        var source = (MathBlockProgramPopulationTrialSource)ReadInt32(bytes, offset);
        if (!Enum.IsDefined(source))
            throw new InvalidDataException("A resident trial source is invalid.");
        return source;
    }

    private static ulong? ReadProposalCursor(ReadOnlySpan<byte> bytes, int offset)
    {
        var value = ReadUInt64(bytes, offset);
        return value == ulong.MaxValue ? null : value;
    }

    private static void WriteType(Span<byte> bytes, int offset, MathBlockType type)
    {
        WriteInt32(bytes, offset, (int)type.Kind);
        WriteInt32(bytes, offset + 4, type.Rows);
        WriteInt32(bytes, offset + 8, type.Columns);
        WriteRational(bytes, offset + 12, type.Unit.Dimension0);
        WriteRational(bytes, offset + 20, type.Unit.Dimension1);
        WriteRational(bytes, offset + 28, type.Unit.Dimension2);
        WriteRational(bytes, offset + 36, type.Unit.Dimension3);
    }

    private static void WriteRational(Span<byte> bytes, int offset, MathRational value)
    {
        WriteInt32(bytes, offset, value.Numerator);
        WriteInt32(bytes, offset + 4, value.Denominator);
    }

    private static int MeasurePayloadBytes(MathBlockValueKind kind, int capacity, string region)
    {
        var elementBytes = kind switch
        {
            MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
            MathBlockValueKind.Vector or MathBlockValueKind.Matrix => sizeof(double),
            MathBlockValueKind.BooleanVector => sizeof(int),
            MathBlockValueKind.Complex or MathBlockValueKind.ComplexVector or
                MathBlockValueKind.ComplexMatrix or MathBlockValueKind.PointSet or
                MathBlockValueKind.Graph or MathBlockValueKind.RunSet => 16,
            _ => throw new NotSupportedException($"The CUDA value ABI does not support '{kind}'.")
        };
        return MeasureLayout(region, (capacity, elementBytes));
    }

    private static int MeasureLayout(string region, params (int Count, int Size)[] parts)
    {
        long result = 0;
        try
        {
            checked
            {
                foreach (var part in parts)
                {
                    if (part.Count < 0 || part.Size < 0)
                        throw new ArgumentOutOfRangeException(nameof(parts));
                    result += (long)part.Count * part.Size;
                }
            }
        }
        catch (OverflowException)
        {
            throw new ArgumentOutOfRangeException(
                "definition",
                $"The {region} layout exceeds the supported CUDA arena range.");
        }
        return AlignLayout(result, region);
    }

    private static int AdvanceLayout(int offset, int count, int size, string region)
    {
        if (offset < 0 || count < 0 || size < 0)
            throw new ArgumentOutOfRangeException("definition", $"The {region} layout contains a negative size.");
        long result;
        try
        {
            result = checked((long)offset + checked((long)count * size));
        }
        catch (OverflowException)
        {
            throw new ArgumentOutOfRangeException(
                "definition",
                $"The {region} layout exceeds the supported CUDA arena range.");
        }
        return AlignLayout(result, region);
    }

    private static int AlignLayout(long value, string region)
    {
        if (value < 0 || value > int.MaxValue - 7L)
        {
            throw new ArgumentOutOfRangeException(
                "definition",
                $"The {region} layout requires {value} bytes and exceeds the supported CUDA arena range.");
        }
        return checked(((int)value + 7) & ~7);
    }

    private static int Align(int value) => AlignLayout(value, "resident");
    private static int ReadInt32(ReadOnlySpan<byte> bytes, int offset) =>
        BinaryPrimitives.ReadInt32LittleEndian(bytes[offset..]);
    private static ulong ReadUInt64(ReadOnlySpan<byte> bytes, int offset) =>
        BinaryPrimitives.ReadUInt64LittleEndian(bytes[offset..]);
    private static void WriteInt32(Span<byte> bytes, int offset, int value) =>
        BinaryPrimitives.WriteInt32LittleEndian(bytes[offset..], value);
    private static void WriteUInt64(Span<byte> bytes, int offset, ulong value) =>
        BinaryPrimitives.WriteUInt64LittleEndian(bytes[offset..], value);

    private readonly record struct CudaOperationDescriptor(
        int Family,
        int Opcode,
        int Arity,
        int OutputTypeId,
        int InputTypeBase,
        long DeterministicCost,
        ulong KeyFirst,
        ulong KeySecond);

    private readonly record struct CudaTerminalDescriptor(int TypeId, int ImmutableSlotIndex, int Lookback);

    private readonly record struct ObjectiveNodeDescriptor(
        int Kind,
        int TypeId,
        int Family,
        int Opcode,
        int Arity,
        int InputBase,
        int ImmutableSlotIndex,
        int PayloadCapacity,
        int PayloadOffset,
        int ScratchBytes);

    private readonly record struct ObjectiveSourceDescriptor(int SourceKind, int ProgramNodeIndex, int Direction);

    private readonly record struct ObjectivePayloadRange(int Offset, int Bytes);

    private sealed record ObjectivePayloadLayout(int[] Offsets, int PayloadBytes);

    private readonly record struct QualityDimensionDescriptor(
        int ObjectiveIndex,
        int BinCount,
        int Multiplier,
        ulong MinimumBits,
        ulong MaximumBits);

    private sealed record CompiledObjective(
        ObjectiveNodeDescriptor[] Nodes,
        int[] Inputs,
        ObjectiveSourceDescriptor[] Sources,
        QualityDimensionDescriptor[] QualityDimensions,
        int PayloadBytes,
        int MaximumScratchBytes);
}

internal static class MathBlockCudaValueLayout
{
    private const int SlotSize = 48;

    public static int GetElementCount(MathBlockValue value) => value.Type.Kind switch
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
        _ => throw new NotSupportedException($"The CUDA value ABI does not support '{value.Type.Kind}'.")
    };

    public static int GetPayloadBytes(MathBlockValue value)
    {
        var count = GetElementCount(value);
        return value.Type.Kind switch
        {
            MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
            MathBlockValueKind.Vector or MathBlockValueKind.Matrix => checked(count * sizeof(double)),
            MathBlockValueKind.BooleanVector => checked(count * sizeof(int)),
            MathBlockValueKind.Complex or MathBlockValueKind.ComplexVector or
                MathBlockValueKind.ComplexMatrix or MathBlockValueKind.PointSet =>
                checked(count * 2 * sizeof(double)),
            MathBlockValueKind.Graph or MathBlockValueKind.RunSet => checked(count * 16),
            _ => throw new NotSupportedException($"The CUDA value ABI does not support '{value.Type.Kind}'.")
        };
    }

    public static void WriteValue(
        Span<byte> bytes,
        int slotOffset,
        int payloadOffset,
        ulong payloadPointer,
        MathBlockValue value)
    {
        if (bytes.Length - slotOffset < SlotSize)
            throw new ArgumentOutOfRangeException(nameof(slotOffset));
        var count = GetElementCount(value);
        WriteUInt64(bytes, slotOffset, value.Type.Kind == MathBlockValueKind.Scalar
            ? Math.ToBits(value.AsScalar())
            : 0);
        WriteUInt64(bytes, slotOffset + 8, GetPayloadBytes(value) == 0 ? 0 : payloadPointer);
        WriteUInt64(bytes, slotOffset + 16, 0);
        WriteInt32(bytes, slotOffset + 24,
            value.Type.Kind == MathBlockValueKind.Boolean && value.AsBoolean() ? 1 : 0);
        WriteInt32(bytes, slotOffset + 28, value.IsValid ? 1 : 0);
        WriteInt32(bytes, slotOffset + 32, GetRows(value));
        WriteInt32(bytes, slotOffset + 36, GetColumns(value));
        WriteInt32(bytes, slotOffset + 40, count);
        WriteInt32(bytes, slotOffset + 44, count);
        if (count == 0)
            return;

        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Vector:
                for (var index = 0; index < count; index++)
                    WriteUInt64(bytes, payloadOffset + index * sizeof(ulong), Math.ToBits(value.AsVector()[index]));
                return;
            case MathBlockValueKind.BooleanVector:
                for (var index = 0; index < count; index++)
                    WriteInt32(bytes, payloadOffset + index * sizeof(int), value.AsBooleanVector()[index] ? 1 : 0);
                return;
            case MathBlockValueKind.Matrix:
                var matrix = value.AsMatrix();
                var matrixIndex = 0;
                for (var row = 0; row < matrix.Rows; row++)
                for (var column = 0; column < matrix.Columns; column++)
                    WriteUInt64(bytes, payloadOffset + matrixIndex++ * sizeof(ulong), Math.ToBits(matrix[row, column]));
                return;
            case MathBlockValueKind.Complex:
                WriteComplex(bytes, payloadOffset, value.AsComplex());
                return;
            case MathBlockValueKind.ComplexVector:
                for (var index = 0; index < count; index++)
                    WriteComplex(bytes, payloadOffset + index * 16, value.AsComplexVector()[index]);
                return;
            case MathBlockValueKind.ComplexMatrix:
                var complexMatrix = value.AsComplexMatrix();
                var complexIndex = 0;
                for (var row = 0; row < complexMatrix.Rows; row++)
                for (var column = 0; column < complexMatrix.Columns; column++)
                    WriteComplex(bytes, payloadOffset + complexIndex++ * 16, complexMatrix[row, column]);
                return;
            case MathBlockValueKind.PointSet:
                for (var index = 0; index < count; index++)
                {
                    var point = value.AsPointSet()[index];
                    WriteUInt64(bytes, payloadOffset + index * 16, Math.ToBits(point.X));
                    WriteUInt64(bytes, payloadOffset + index * 16 + 8, Math.ToBits(point.Y));
                }
                return;
            case MathBlockValueKind.Graph:
                for (var index = 0; index < count; index++)
                {
                    var edge = value.AsGraph()[index];
                    WriteInt32(bytes, payloadOffset + index * 16, edge.From);
                    WriteInt32(bytes, payloadOffset + index * 16 + 4, edge.To);
                    WriteUInt64(bytes, payloadOffset + index * 16 + 8, Math.ToBits(edge.Weight));
                }
                return;
            case MathBlockValueKind.RunSet:
                for (var index = 0; index < count; index++)
                {
                    var run = value.AsRunSet()[index];
                    WriteInt32(bytes, payloadOffset + index * 16, run.Start);
                    WriteInt32(bytes, payloadOffset + index * 16 + 4, run.Length);
                    WriteUInt64(bytes, payloadOffset + index * 16 + 8, Math.ToBits(run.Value));
                }
                return;
            default:
                throw new NotSupportedException($"The CUDA value ABI does not support '{value.Type.Kind}'.");
        }
    }

    private static int GetRows(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Matrix => value.AsMatrix().Rows,
        MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Rows,
        MathBlockValueKind.Graph => value.AsGraph().VertexCount,
        _ => value.Type.Rows
    };

    private static int GetColumns(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Matrix => value.AsMatrix().Columns,
        MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Columns,
        _ => value.Type.Columns
    };

    private static void WriteComplex(Span<byte> bytes, int offset, Complex value)
    {
        WriteUInt64(bytes, offset, Math.ToBits(value.Real));
        WriteUInt64(bytes, offset + 8, Math.ToBits(value.Imaginary));
    }

    private static void WriteInt32(Span<byte> bytes, int offset, int value) =>
        BinaryPrimitives.WriteInt32LittleEndian(bytes[offset..], value);
    private static void WriteUInt64(Span<byte> bytes, int offset, ulong value) =>
        BinaryPrimitives.WriteUInt64LittleEndian(bytes[offset..], value);
}
