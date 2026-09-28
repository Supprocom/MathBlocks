using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Blocks CUDAProgram contract.</summary>
public sealed class MathBlocksCUDAProgram : IDisposable
{
    private const int SlotSize = 48;

    private readonly Lock stateLock = new();
    private readonly MathBlockProgram program;
    private readonly int[] slotOffsets;
    private readonly int[] payloadOffsets;
    private readonly int[] payloadCapacities;
    private readonly MathBlockType[] resolvedTypes;
    private readonly int[] inputPointerOffsets;
    private readonly IntPtr[] graphNodes;
    private readonly List<KernelArgumentStorage> kernelArguments;
    private readonly int arenaSize;
    private readonly int downloadArenaOffset;
    private readonly int downloadArenaSize;
    private ulong deviceArena;
    private IntPtr uploadArena;
    private IntPtr downloadArena;
    private IntPtr stream;
    private IntPtr graph;
    private IntPtr executable;
    private bool inputsUploaded;
    private bool executionInFlight;
    private bool disposed;

    private MathBlocksCUDAProgram(
        MathBlockProgram program,
        int[] slotOffsets,
        int[] payloadOffsets,
        int[] payloadCapacities,
        MathBlockType[] resolvedTypes,
        int[] inputPointerOffsets,
        IntPtr[] graphNodes,
        List<KernelArgumentStorage> kernelArguments,
        int arenaSize,
        int downloadArenaOffset,
        int downloadArenaSize,
        ulong deviceArena,
        IntPtr uploadArena,
        IntPtr downloadArena,
        IntPtr stream,
        IntPtr graph,
        IntPtr executable,
        bool inputsUploaded)
    {
        this.program = program;
        this.slotOffsets = slotOffsets;
        this.payloadOffsets = payloadOffsets;
        this.payloadCapacities = payloadCapacities;
        this.resolvedTypes = resolvedTypes;
        this.inputPointerOffsets = inputPointerOffsets;
        this.graphNodes = graphNodes;
        this.kernelArguments = kernelArguments;
        this.arenaSize = arenaSize;
        this.downloadArenaOffset = downloadArenaOffset;
        this.downloadArenaSize = downloadArenaSize;
        this.deviceArena = deviceArena;
        this.uploadArena = uploadArena;
        this.downloadArena = downloadArena;
        this.stream = stream;
        this.graph = graph;
        this.executable = executable;
        this.inputsUploaded = inputsUploaded;
        OperationNodeCount = CountOperationNodes(program.PlanNodes);
        MaximumParallelWidth = CalculateMaximumParallelWidth(program.PlanNodes);
    }

    /// <summary>Gets the program fingerprint value.</summary>
    public string ProgramFingerprint => program.Fingerprint;
    /// <summary>Gets the operation node count value.</summary>
    public int OperationNodeCount { get; }
    /// <summary>Gets the maximum parallel width value.</summary>
    public int MaximumParallelWidth { get; }
    /// <summary>Gets the graph instantiation count value.</summary>
    public int GraphInstantiationCount => 1;
    /// <summary>Gets the graph launch count value.</summary>
    public int GraphLaunchCount { get; private set; }
    /// <summary>Gets the synchronization count value.</summary>
    public int SynchronizationCount { get; private set; }
    /// <summary>Gets the host input write count value.</summary>
    public int HostInputWriteCount { get; private set; }
    /// <summary>Gets the host output read count value.</summary>
    public int HostOutputReadCount { get; private set; }
    /// <summary>Gets the host to device transfer count value.</summary>
    public int HostToDeviceTransferCount { get; private set; }
    /// <summary>Gets the device to host transfer count value.</summary>
    public int DeviceToHostTransferCount { get; private set; }
    /// <summary>Gets the host to device bytes per execution value.</summary>
    public int HostToDeviceBytesPerExecution => arenaSize;
    /// <summary>Gets the device to host bytes per execution value.</summary>
    public int DeviceToHostBytesPerExecution => downloadArenaSize;
    /// <summary>Gets the cpu node dispatch count value.</summary>
    public int CpuNodeDispatchCount => 0;

    // Keep allocation, graph construction, and rollback in one auditable transaction.
#pragma warning disable MA0051
    internal static MathBlocksCUDAProgram Create(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        MathBlocksCudaNative.EnsureContext();
        ValidateProgram(program);

        var plannedSlotOffsets = new int[program.PlanNodes.Count];
        var plannedPayloadOffsets = CreateFilledIntArray(program.PlanNodes.Count, -1);
        var payloadLayout = ResolvePayloadLayout(program.PlanNodes, prototypeInputs);
        var plannedPayloadCapacities = payloadLayout.Capacities;
        var plannedInputPointerOffsets = CreateFilledIntArray(program.PlanNodes.Count, -1);
        var scratchOffsets = CreateFilledIntArray(program.PlanNodes.Count, -1);
        var plannedGraphNodes = new IntPtr[program.PlanNodes.Count];
        var arguments = new List<KernelArgumentStorage>();

        var outputNodeIndexes = new bool[program.PlanNodes.Count];
        foreach (var outputNodeIndex in program.OutputNodeIndexes.Values)
            outputNodeIndexes[outputNodeIndex] = true;
        var plannedArenaSize = 0;
        void AllocateNode(MathBlockProgramNode node)
        {
            plannedSlotOffsets[node.Index] = AlignArenaOffset(plannedArenaSize);
            plannedArenaSize = checked(plannedSlotOffsets[node.Index] + SlotSize);
            var payloadBytes = ResolvePayloadBytes(
                payloadLayout.ResolvedTypes[node.Index].Kind,
                plannedPayloadCapacities[node.Index]);
            if (payloadBytes == 0)
                return;
            plannedPayloadOffsets[node.Index] = AlignArenaOffset(plannedArenaSize);
            plannedArenaSize = checked(plannedPayloadOffsets[node.Index] + payloadBytes);
        }

        foreach (var node in program.PlanNodes)
            if (!outputNodeIndexes[node.Index])
                AllocateNode(node);
        foreach (var node in program.PlanNodes)
        {
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                continue;
            plannedInputPointerOffsets[node.Index] = AlignArenaOffset(plannedArenaSize);
            plannedArenaSize = checked(plannedInputPointerOffsets[node.Index] + node.Inputs.Count * sizeof(ulong));
        }
        foreach (var node in program.PlanNodes)
        {
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                continue;
            var scratchBytes = ResolveScratchBytes(
                node,
                program.PlanNodes,
                payloadLayout);
            if (scratchBytes == 0)
                continue;
            scratchOffsets[node.Index] = AlignArenaOffset(plannedArenaSize);
            plannedArenaSize = checked(scratchOffsets[node.Index] + scratchBytes);
        }
        var plannedDownloadArenaOffset = AlignArenaOffset(plannedArenaSize);
        plannedArenaSize = plannedDownloadArenaOffset;
        foreach (var node in program.PlanNodes)
            if (outputNodeIndexes[node.Index])
                AllocateNode(node);
        plannedArenaSize = AlignArenaOffset(plannedArenaSize);
        var plannedDownloadArenaSize = checked(plannedArenaSize - plannedDownloadArenaOffset);

        var allocatedDeviceArena = 0ul;
        var allocatedUploadArena = IntPtr.Zero;
        var allocatedDownloadArena = IntPtr.Zero;
        var createdStream = IntPtr.Zero;
        var createdGraph = IntPtr.Zero;
        var createdExecutable = IntPtr.Zero;
        try
        {
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAlloc(out allocatedDeviceArena, new UIntPtr(checked((uint)plannedArenaSize))),
                "cuMemAlloc(mathblocks arena)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(out allocatedUploadArena, new UIntPtr(checked((uint)plannedArenaSize))),
                "cuMemAllocHost(mathblocks upload arena)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(
                    out allocatedDownloadArena,
                    new UIntPtr(checked((uint)plannedDownloadArenaSize))),
                "cuMemAllocHost(mathblocks download arena)");
            ClearArena(allocatedUploadArena, plannedArenaSize);
            ClearArena(allocatedDownloadArena, plannedDownloadArenaSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamCreate(out createdStream, 1),
                "cuStreamCreate(mathblocks)");
            foreach (var node in program.PlanNodes)
            {
                var payloadPointer = plannedPayloadOffsets[node.Index] < 0
                    ? 0ul
                    : checked(allocatedDeviceArena + (ulong)plannedPayloadOffsets[node.Index]);
                var scratchPointer = scratchOffsets[node.Index] < 0
                    ? 0ul
                    : checked(allocatedDeviceArena + (ulong)scratchOffsets[node.Index]);
                MathBlockCudaValueCodec.WriteHeader(
                    allocatedUploadArena,
                    plannedSlotOffsets[node.Index],
                    payloadPointer,
                    scratchPointer,
                    plannedPayloadCapacities[node.Index],
                    payloadLayout.ResolvedTypes[node.Index],
                    valid: false);
                if (node.Kind == MathBlockProgramNodeKind.Constant)
                {
                    MathBlockCudaValueCodec.WriteValue(
                        allocatedUploadArena,
                        plannedSlotOffsets[node.Index],
                        plannedPayloadOffsets[node.Index],
                        payloadPointer,
                        scratchPointer,
                        plannedPayloadCapacities[node.Index],
                        node.Value);
                }
                else if (node.Kind == MathBlockProgramNodeKind.Input &&
                         prototypeInputs is not null &&
                         prototypeInputs.TryGetValue(node.Name!, out var prototype))
                {
                    MathBlockCudaValueCodec.WriteValue(
                        allocatedUploadArena,
                        plannedSlotOffsets[node.Index],
                        plannedPayloadOffsets[node.Index],
                        payloadPointer,
                        scratchPointer,
                        plannedPayloadCapacities[node.Index],
                        prototype);
                }
            }
            foreach (var node in program.PlanNodes)
            {
                if (node.Kind != MathBlockProgramNodeKind.Operation)
                    continue;
                WriteInputPointers(
                    allocatedUploadArena,
                    plannedInputPointerOffsets[node.Index],
                    allocatedDeviceArena,
                    plannedSlotOffsets,
                    node.Inputs);
            }

            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphCreate(out createdGraph, 0),
                "cuGraphCreate(mathblocks)");
            var uploadCopy = MathBlocksCudaNative.MemoryCopy3D.HostToDevice(
                allocatedUploadArena,
                allocatedDeviceArena,
                plannedArenaSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddMemcpyNode(
                    out var uploadNode,
                    createdGraph,
                    null,
                    UIntPtr.Zero,
                    ref uploadCopy,
                    MathBlocksCudaNative.CurrentContext),
                "cuGraphAddMemcpyNode(mathblocks upload)");
            foreach (var node in program.PlanNodes)
            {
                if (node.Kind != MathBlockProgramNodeKind.Operation)
                    continue;
                var kernel = MathBlocksCudaKernelModule.Resolve(node.OperationIdentity!);
                var inputPointers = checked(allocatedDeviceArena + (ulong)plannedInputPointerOffsets[node.Index]);
                var output = checked(allocatedDeviceArena + (ulong)plannedSlotOffsets[node.Index]);
                var storage = new KernelArgumentStorage(
                    kernel.Opcode,
                    inputPointers,
                    node.Inputs.Count,
                    output);
                arguments.Add(storage);
                var dependencies = CreateKernelDependencies(node.Inputs, plannedGraphNodes, uploadNode);
                var parameters = new MathBlocksCudaNative.KernelNodeParameters
                {
                    Function = kernel.Function,
                    GridX = 1,
                    GridY = 1,
                    GridZ = 1,
                    BlockX = kernel.BlockX,
                    BlockY = 1,
                    BlockZ = 1,
                    KernelParameters = storage.PointerArray
                };
                MathBlocksCudaNative.ThrowIfFailed(
                    MathBlocksCudaNative.cuGraphAddKernelNode(
                        out plannedGraphNodes[node.Index],
                        createdGraph,
                        dependencies.Length == 0 ? null : dependencies,
                        new UIntPtr((uint)dependencies.Length),
                        ref parameters),
                    $"cuGraphAddKernelNode({node.OperationIdentity})");
            }

            var terminalDependencies = CreateTerminalDependencies(plannedGraphNodes, uploadNode);
            var downloadCopy = MathBlocksCudaNative.MemoryCopy3D.DeviceToHost(
                checked(allocatedDeviceArena + (ulong)plannedDownloadArenaOffset),
                allocatedDownloadArena,
                plannedDownloadArenaSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddMemcpyNode(
                    out _,
                    createdGraph,
                    terminalDependencies,
                    new UIntPtr((uint)terminalDependencies.Length),
                    ref downloadCopy,
                    MathBlocksCudaNative.CurrentContext),
                "cuGraphAddMemcpyNode(mathblocks download)");

            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphInstantiateWithFlags(out createdExecutable, createdGraph, 0),
                "cuGraphInstantiate(mathblocks)");
            return new MathBlocksCUDAProgram(
                program,
                plannedSlotOffsets,
                plannedPayloadOffsets,
                plannedPayloadCapacities,
                payloadLayout.ResolvedTypes,
                plannedInputPointerOffsets,
                plannedGraphNodes,
                arguments,
                plannedArenaSize,
                plannedDownloadArenaOffset,
                plannedDownloadArenaSize,
                allocatedDeviceArena,
                allocatedUploadArena,
                allocatedDownloadArena,
                createdStream,
                createdGraph,
                createdExecutable,
                InputsAreStaged(program, prototypeInputs));
        }
        catch
        {
            if (createdExecutable != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphExecDestroy(createdExecutable);
            if (createdGraph != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphDestroy(createdGraph);
            if (createdStream != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuStreamDestroy(createdStream);
            foreach (ref readonly var storage in CollectionsMarshal.AsSpan(arguments))
                storage.Dispose();
            if (allocatedDeviceArena != 0ul)
                _ = MathBlocksCudaNative.cuMemFree(allocatedDeviceArena);
            if (allocatedUploadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(allocatedUploadArena);
            if (allocatedDownloadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(allocatedDownloadArena);
            throw;
        }
    }

#pragma warning restore MA0051
    /// <summary>Copies named inputs into the resident CUDA staging buffers.</summary>
    public void UploadInputs(IReadOnlyDictionary<string, MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        lock (stateLock)
        {
            ThrowIfDisposed();
            if (executionInFlight)
                throw new InvalidOperationException("CUDA input cannot change during execution.");
            foreach (var node in program.PlanNodes)
            {
                if (node.Kind != MathBlockProgramNodeKind.Input)
                    continue;
                if (!inputs.TryGetValue(node.Name!, out var value))
                    throw new KeyNotFoundException($"Program input '{node.Name}' is missing.");
                if (!node.Type.Accepts(value.Type))
                {
                    throw new InvalidOperationException(
                        $"Program input '{node.Name}' requires '{node.Type}', but received '{value.Type}'.");
                }
                var payloadPointer = payloadOffsets[node.Index] < 0
                    ? 0ul
                    : checked(deviceArena + (ulong)payloadOffsets[node.Index]);
                MathBlockCudaValueCodec.WriteValue(
                    uploadArena,
                    slotOffsets[node.Index],
                    payloadOffsets[node.Index],
                    payloadPointer,
                    0ul,
                    payloadCapacities[node.Index],
                    value);
                HostInputWriteCount++;
            }
            inputsUploaded = true;
        }
    }

    /// <summary>Runs the resident graph and downloads named outputs.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Execute(
        IReadOnlyDictionary<string, MathBlockValue> inputs)
    {
        ArgumentNullException.ThrowIfNull(inputs);
        lock (stateLock)
        {
            UploadInputs(inputs);
            ExecuteResident();
            return ReadOutputs();
        }
    }

    /// <summary>Launches the resident graph without downloading outputs.</summary>
    public void ExecuteResident()
    {
        lock (stateLock)
        {
            ThrowIfDisposed();
            if (!inputsUploaded)
                throw new InvalidOperationException("CUDA inputs are not available.");
            MathBlocksCudaNative.EnsureContext();
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphLaunch(executable, stream),
                "cuGraphLaunch(mathblocks)");
            executionInFlight = true;
            GraphLaunchCount++;
            HostToDeviceTransferCount++;
            DeviceToHostTransferCount++;
        }
    }

    /// <summary>Waits for an in-flight resident graph execution.</summary>
    public void Synchronize()
    {
        lock (stateLock)
        {
            ThrowIfDisposed();
            if (!executionInFlight)
                return;
            MathBlocksCudaNative.EnsureContext();
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamSynchronize(stream),
                "cuStreamSynchronize(mathblocks)");
            executionInFlight = false;
            SynchronizationCount++;
        }
    }

    /// <summary>Reads a formula or typed MathBlocks program from the supplied document.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> ReadOutputs()
    {
        lock (stateLock)
        {
            ThrowIfDisposed();
            if (executionInFlight)
                SynchronizeCore();
            var outputs = new Dictionary<string, MathBlockValue>(StringComparer.Ordinal);
            foreach (var output in program.OutputNodeIndexes)
            {
                outputs.Add(
                    output.Key,
                    MathBlockCudaValueCodec.ReadValue(
                        downloadArena,
                        checked(slotOffsets[output.Value] - downloadArenaOffset),
                        payloadOffsets[output.Value] < 0
                            ? -1
                            : checked(payloadOffsets[output.Value] - downloadArenaOffset),
                        resolvedTypes[output.Value]));
                HostOutputReadCount++;
            }
            return outputs;
        }
    }

    /// <summary>Releases CUDA graph, stream, and memory resources.</summary>
    public void Dispose()
    {
        lock (stateLock)
        {
            if (disposed)
                return;
            MathBlocksCudaNative.EnsureContext();
            if (executionInFlight)
            {
                _ = MathBlocksCudaNative.cuStreamSynchronize(stream);
                executionInFlight = false;
            }
            disposed = true;
            if (executable != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphExecDestroy(executable);
            if (graph != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphDestroy(graph);
            if (stream != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuStreamDestroy(stream);
            foreach (ref readonly var storage in CollectionsMarshal.AsSpan(kernelArguments))
                storage.Dispose();
            if (deviceArena != 0ul)
                _ = MathBlocksCudaNative.cuMemFree(deviceArena);
            if (uploadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(uploadArena);
            if (downloadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(downloadArena);
            deviceArena = 0ul;
            uploadArena = IntPtr.Zero;
            downloadArena = IntPtr.Zero;
            executable = IntPtr.Zero;
            graph = IntPtr.Zero;
            stream = IntPtr.Zero;
        }
    }

    private void SynchronizeCore()
    {
        MathBlocksCudaNative.EnsureContext();
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuStreamSynchronize(stream),
            "cuStreamSynchronize(mathblocks)");
        executionInFlight = false;
        SynchronizationCount++;
    }

    private static int[] CreateFilledIntArray(int count, int value)
    {
        var result = new int[count];
        for (var index = 0; index < count; index++)
            result[index] = value;
        return result;
    }

    private static int CountOperationNodes(IReadOnlyList<MathBlockProgramNode> nodes)
    {
        var result = 0;
        for (var index = 0; index < nodes.Count; index++)
            if (nodes[index].Kind == MathBlockProgramNodeKind.Operation)
                result++;
        return result;
    }

    internal static int[] ResolvePayloadCapacities(
        IReadOnlyList<MathBlockProgramNode> nodes,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs,
        IReadOnlyDictionary<string, int>? inputCapacityOverrides = null,
        IReadOnlyDictionary<string, MathBlockCudaShapeAuthority>? inputShapeOverrides = null) =>
        ResolvePayloadLayout(
            nodes,
            prototypeInputs,
            inputCapacityOverrides,
            inputShapeOverrides).Capacities;

    // Resolve every node against one shared shape authority and publication pass.
#pragma warning disable MA0051
    internal static MathBlockCudaPayloadLayout ResolvePayloadLayout(
        IReadOnlyList<MathBlockProgramNode> nodes,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs,
        IReadOnlyDictionary<string, int>? inputCapacityOverrides = null,
        IReadOnlyDictionary<string, MathBlockCudaShapeAuthority>? inputShapeOverrides = null,
        IReadOnlyList<bool>? activeNodes = null)
    {
        var capacities = new int[nodes.Count];
        var shapeRows = new int[nodes.Count];
        var shapeColumns = new int[nodes.Count];
        var exactValues = new MathBlockValue?[nodes.Count];
        var candidateTypes = new MathBlockType[nodes.Count];
        var published = new bool[nodes.Count];
        if (activeNodes is not null && activeNodes.Count != nodes.Count)
            throw new ArgumentException("The CUDA active-node count is inconsistent.", nameof(activeNodes));
        foreach (var node in nodes)
        {
            if ((uint)node.Index >= (uint)nodes.Count || published[node.Index])
                throw new InvalidOperationException($"CUDA payload node index {node.Index} is invalid.");

            if (activeNodes is not null && !activeNodes[node.Index])
            {
                candidateTypes[node.Index] = node.Type;
                published[node.Index] = true;
                continue;
            }

            var inputCapacities = new int[node.Inputs.Count];
            var inputShapeRows = new int[node.Inputs.Count];
            var inputShapeColumns = new int[node.Inputs.Count];
            var inputExactValues = new MathBlockValue?[node.Inputs.Count];
            var inputTypes = new MathBlockType[node.Inputs.Count];
            for (var inputIndex = 0; inputIndex < node.Inputs.Count; inputIndex++)
            {
                var producerIndex = node.Inputs[inputIndex];
                if ((uint)producerIndex >= (uint)nodes.Count || !published[producerIndex])
                {
                    throw new InvalidOperationException(
                        $"CUDA payload capacity for producer node {producerIndex} is unavailable for node {node.Index}.");
                }
                inputCapacities[inputIndex] = capacities[producerIndex];
                inputShapeRows[inputIndex] = shapeRows[producerIndex];
                inputShapeColumns[inputIndex] = shapeColumns[producerIndex];
                inputExactValues[inputIndex] = exactValues[producerIndex];
                inputTypes[inputIndex] = candidateTypes[producerIndex];
            }

            MathBlockType resolvedType;
            if (node.Kind == MathBlockProgramNodeKind.Operation)
            {
                var operation = ResolveOperation(node.OperationIdentity!);
                resolvedType = operation.ResolveOutputType(inputTypes);
                ValidateStaticOperation(
                    node,
                    inputCapacities,
                    inputShapeRows,
                    inputExactValues);
            }
            else
            {
                resolvedType = node.Type;
            }

            var capacity = ResolvePayloadCapacity(
                node,
                nodes,
                inputCapacities,
                inputShapeRows,
                inputShapeColumns,
                prototypeInputs,
                inputCapacityOverrides,
                inputExactValues);
            if (capacity < 0)
                throw new InvalidOperationException($"CUDA payload capacity for node {node.Index} is negative.");
            var shape = ResolveShapeAuthority(
                node,
                capacity,
                inputCapacities,
                inputShapeRows,
                inputShapeColumns,
                prototypeInputs,
                inputShapeOverrides,
                inputExactValues);
            resolvedType = new MathBlockType(
                resolvedType.Kind,
                resolvedType.Unit,
                shape.Rows,
                shape.Columns);
            if (!node.Type.Accepts(resolvedType) &&
                !(HasRuntimeShape(node.OperationIdentity) &&
                    node.Type.Kind == resolvedType.Kind &&
                    node.Type.Unit == resolvedType.Unit))
            {
                throw new InvalidOperationException(
                    $"CUDA resolved type authority for node {node.Index} is incompatible with its declared type.");
            }
            capacities[node.Index] = capacity;
            shapeRows[node.Index] = shape.Rows;
            shapeColumns[node.Index] = shape.Columns;
            candidateTypes[node.Index] = resolvedType;
            exactValues[node.Index] = ResolveExactValue(
                node,
                prototypeInputs,
                inputExactValues);
            published[node.Index] = true;
        }

        for (var nodeIndex = 0; nodeIndex < published.Length; nodeIndex++)
            if (!published[nodeIndex])
                throw new InvalidOperationException($"CUDA payload capacity for node {nodeIndex} is unavailable.");
        return new MathBlockCudaPayloadLayout(
            capacities,
            shapeRows,
            shapeColumns,
            exactValues,
            candidateTypes);
    }

#pragma warning restore MA0051
    private static IntPtr[] CreateKernelDependencies(
        IReadOnlyList<int> inputs,
        nint[] graphNodes,
        IntPtr uploadNode)
    {
        var values = new IntPtr[inputs.Count + 1];
        var count = 0;
        for (var index = 0; index < inputs.Count; index++)
            AddUniqueDependency(values, ref count, graphNodes[inputs[index]]);
        AddUniqueDependency(values, ref count, uploadNode);
        return CopyDependencies(values, count);
    }

    private static IntPtr[] CreateTerminalDependencies(
        nint[] graphNodes,
        IntPtr uploadNode)
    {
        var values = new IntPtr[graphNodes.Length + 1];
        var count = 0;
        for (var index = 0; index < graphNodes.Length; index++)
            AddUniqueDependency(values, ref count, graphNodes[index]);
        AddUniqueDependency(values, ref count, uploadNode);
        return CopyDependencies(values, count);
    }

    private static void AddUniqueDependency(IntPtr[] values, ref int count, IntPtr value)
    {
        if (value == IntPtr.Zero)
            return;
        for (var index = 0; index < count; index++)
            if (values[index] == value)
                return;
        values[count++] = value;
    }

    private static IntPtr[] CopyDependencies(IntPtr[] values, int count)
    {
        var result = new IntPtr[count];
        for (var index = 0; index < count; index++)
            result[index] = values[index];
        return result;
    }

    internal static void ValidateProgram(MathBlockProgram program) =>
        ValidateProgram(program.PlanNodes);

    internal static void ValidateProgram(IReadOnlyList<MathBlockProgramNode> nodes)
    {
        var unsupportedKindList = new List<MathBlockValueKind>();
        for (var nodeIndex = 0; nodeIndex < nodes.Count; nodeIndex++)
        {
            var kind = nodes[nodeIndex].Type.Kind;
            if (!IsSupportedKind(kind) && !ContainsKind(unsupportedKindList, kind))
                unsupportedKindList.Add(kind);
        }
        var unsupportedKinds = MathBlockCollectionPrimitives.Copy(unsupportedKindList);
        if (unsupportedKinds.Length != 0)
        {
            throw new NotSupportedException(
                $"The CUDA program does not support: {string.Join(", ", unsupportedKinds)}.");
        }

        var missingList = new List<string>();
        for (var nodeIndex = 0; nodeIndex < nodes.Count; nodeIndex++)
        {
            var node = nodes[nodeIndex];
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                continue;
            var identity = node.OperationIdentity!;
            if (!ContainsIdentity(MathBlocksCudaKernelModule.SupportedBlockIdentities, identity) &&
                !ContainsIdentity(missingList, identity))
            {
                missingList.Add(identity);
            }
        }
        var missing = MathBlockCollectionPrimitives.Copy(missingList);
        MathBlockCollectionPrimitives.StableMergeSort(
            missing,
            (left, right) => StringComparer.Ordinal.Compare(left, right));
        if (missing.Length != 0)
            throw new NotSupportedException($"CUDA implementations are missing: {string.Join(", ", missing)}.");
    }

    private static bool IsSupportedKind(MathBlockValueKind kind) =>
        kind is >= MathBlockValueKind.Scalar and <= MathBlockValueKind.BooleanVector;

    private static bool ContainsKind(System.Collections.Generic.List<Supprocom.MathBlocks.MathBlockValueKind> values, MathBlockValueKind value)
    {
        for (var index = 0; index < values.Count; index++)
            if (values[index] == value)
                return true;
        return false;
    }

    private static bool ContainsIdentity(IReadOnlyCollection<string> values, string value)
    {
        foreach (var candidate in values)
            if (string.Equals(candidate, value, StringComparison.Ordinal))
                return true;
        return false;
    }

    private static int CalculateMaximumParallelWidth(IReadOnlyList<MathBlockProgramNode> nodes)
    {
        var depths = new int[nodes.Count];
        var widths = new int[nodes.Count + 1];
        var maximumWidth = 0;
        foreach (var node in nodes)
        {
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                continue;
            var depth = 1;
            for (var inputIndex = 0; inputIndex < node.Inputs.Count; inputIndex++)
            {
                var candidateDepth = depths[node.Inputs[inputIndex]] + 1;
                if (candidateDepth > depth)
                    depth = candidateDepth;
            }
            depths[node.Index] = depth;
            widths[depth]++;
            if (widths[depth] > maximumWidth)
                maximumWidth = widths[depth];
        }
        return maximumWidth;
    }

    private static MathBlockOperation ResolveOperation(string identity)
    {
        var separator = identity.LastIndexOf('@');
        if (separator <= 0 || separator == identity.Length - 1 ||
            !int.TryParse(
                identity.AsSpan(separator + 1),
                System.Globalization.NumberStyles.None,
                System.Globalization.CultureInfo.InvariantCulture,
                out var version))
        {
            throw new InvalidOperationException($"CUDA operation identity '{identity}' is invalid.");
        }
        return MathBlockCatalog.Standard.Get(identity[..separator], version);
    }

    // Keep all static-domain checks together to compare every family consistently.
#pragma warning disable MA0051
    private static void ValidateStaticOperation(
        MathBlockProgramNode node,
        int[] inputCapacities,
        IReadOnlyList<int> inputShapeRows,
        IReadOnlyList<MathBlockValue?> inputExactValues)
    {
        var identity = node.OperationIdentity!;
        if (string.Equals(identity, "sequence.difference@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var lag))
        {
            var count = RequireInputShapeRows(node, 0, inputShapeRows);
            RequireDomain(lag > 0 && lag < count, node, "lag");
        }
        if (IsRollingIdentity(identity) &&
            TryGetExactInteger(inputExactValues, 1, out var width))
        {
            var count = RequireInputShapeRows(node, 0, inputShapeRows);
            RequireDomain(width > 0 && width <= count, node, "rolling window");
        }
        if (string.Equals(identity, "sequence.rolling-quantile@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 2, out var rollingProbability))
        {
            RequireDomain(
                rollingProbability is >= 0d and <= 1d,
                node,
                "rolling probability");
        }
        if (string.Equals(identity, "sequence.exponential-moving-average@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 1, out var alpha))
        {
            RequireDomain(alpha is > 0d and <= 1d, node, "smoothing input");
        }
        if (string.Equals(identity, "vector.quantile@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 1, out var probability))
        {
            RequireDomain(probability is >= 0d and <= 1d, node, "probability");
            RequireDomain(inputCapacities[0] > 0, node, "vector length");
        }
        if ((string.Equals(identity, "vector.repeat@1", StringComparison.Ordinal) || string.Equals(identity, "vector.linspace@1", StringComparison.Ordinal)))
        {
            var countInput = string.Equals(identity, "vector.repeat@1", StringComparison.Ordinal) ? 1 : 2;
            if (TryGetExactInteger(inputExactValues, countInput, out var count))
            {
                var minimum = string.Equals(identity, "vector.repeat@1", StringComparison.Ordinal) ? 0 : 1;
                RequireDomain(count >= minimum && count <= 1_000_000, node, "output length");
            }
        }
        if (string.Equals(identity, "vector.slice@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var start) &&
            TryGetExactInteger(inputExactValues, 2, out var length))
        {
            var count = RequireInputShapeRows(node, 0, inputShapeRows);
            RequireDomain(start >= 0 && length >= 0 && start <= count && length <= count - start,
                node,
                "slice");
        }
        if (string.Equals(identity, "matrix.identity@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 0, out var matrixSize))
        {
            RequireDomain(matrixSize > 0 && matrixSize <= 4096, node, "matrix size");
        }
        if (string.Equals(identity, "matrix.reshape@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var rows) &&
            TryGetExactInteger(inputExactValues, 2, out var columns))
        {
            RequireDomain(
                rows > 0 && columns > 0 && checked((long)rows * columns) == inputCapacities[0],
                node,
                "matrix shape");
        }
        if (string.Equals(identity, "matrix.schur-complement@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var retained))
        {
            var matrixRows = RequireInputShapeRows(node, 0, inputShapeRows);
            RequireDomain(retained > 0 && retained < matrixRows, node, "retained size");
        }
        if (string.Equals(identity, "statistics.autocorrelation@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var correlationLag))
        {
            RequireDomain(
                correlationLag > 0 && correlationLag < inputCapacities[0],
                node,
                "correlation lag");
        }
        if (string.Equals(identity, "state.transition-counts@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var stateCount))
        {
            RequireDomain(stateCount > 0, node, "state count");
        }
        if (string.Equals(identity, "information.conditional-mutual-information@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var firstStateCount) &&
            TryGetExactInteger(inputExactValues, 2, out var secondStateCount) &&
            TryGetExactInteger(inputExactValues, 3, out var conditionStateCount))
        {
            RequireDomain(
                firstStateCount > 0 &&
                secondStateCount > 0 &&
                conditionStateCount > 0 &&
                checked((long)firstStateCount * secondStateCount * conditionStateCount) == inputCapacities[0],
                node,
                "conditional information shape");
        }
        if (string.Equals(identity, "graph.undirected-shortest-paths@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var source))
        {
            RequireDomain(
                source >= 0 && source < RequireInputShapeRows(node, 0, inputShapeRows),
                node,
                "graph source");
        }
        if (string.Equals(identity, "path.recurrence-rate@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 1, out var threshold))
        {
            RequireDomain(inputCapacities[0] > 0 && threshold >= 0d, node, "recurrence threshold");
        }
        if (string.Equals(identity, "path.hysteresis@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 1, out var lower) &&
            TryGetExactScalar(inputExactValues, 2, out var upper))
        {
            RequireDomain(lower < upper, node, "hysteresis thresholds");
        }
        if (string.Equals(identity, "polynomial.bernstein-evaluate@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 1, out var bernsteinInput))
        {
            RequireDomain(
                inputCapacities[0] > 0 && bernsteinInput is >= 0d and <= 1d,
                node,
                "Bernstein input");
        }
        if (string.Equals(identity, "polynomial.elementary-symmetric@1", StringComparison.Ordinal) &&
            TryGetExactInteger(inputExactValues, 1, out var order))
        {
            RequireDomain(order >= 0 && order <= inputCapacities[0], node, "polynomial order");
        }
        if (string.Equals(identity, "transport.uniform-wasserstein@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 2, out var transportOrder))
        {
            RequireDomain(inputCapacities[0] > 0 && transportOrder >= 1d, node, "transport order");
        }
        if (string.Equals(identity, "special.regularized-incomplete-beta@1", StringComparison.Ordinal) &&
            TryGetExactScalar(inputExactValues, 0, out var betaInput) &&
            TryGetExactScalar(inputExactValues, 1, out var betaLeft) &&
            TryGetExactScalar(inputExactValues, 2, out var betaRight))
        {
            RequireDomain(
                betaInput is >= 0d and <= 1d && betaLeft > 0d && betaRight > 0d,
                node,
                "beta inputs");
        }
    }

#pragma warning restore MA0051
    private static MathBlockValue? ResolveExactValue(
        MathBlockProgramNode node,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs,
        Supprocom.MathBlocks.MathBlockValue?[] inputExactValues)
    {
        if (node.Kind == MathBlockProgramNodeKind.Constant)
            return IsCompileTimeValue(node.Value) ? node.Value : null;
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            prototypeInputs is not null &&
            prototypeInputs.TryGetValue(node.Name!, out var prototype))
        {
            return IsCompileTimeValue(prototype) ? prototype : null;
        }
        if (node.Kind != MathBlockProgramNodeKind.Operation ||
            node.Type.Kind is not (
                MathBlockValueKind.Scalar or
                MathBlockValueKind.Boolean or
                MathBlockValueKind.Complex))
        {
            return null;
        }
        var inputs = new MathBlockValue[inputExactValues.Length];
        for (var index = 0; index < inputs.Length; index++)
        {
            if (!inputExactValues[index].HasValue)
                return null;
            inputs[index] = inputExactValues[index]!.Value;
            if (!IsCompileTimeValue(inputs[index]))
                return null;
        }
        var result = ResolveOperation(node.OperationIdentity!).Evaluate(inputs);
        if (!result.IsValid)
        {
            throw new InvalidOperationException(
                $"CUDA constant folding rejected node {node.Index}: {result.InvalidReason}");
        }
        return IsCompileTimeValue(result) ? result : null;
    }

    private static bool IsCompileTimeValue(MathBlockValue value) => value.Type.Kind is
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean or MathBlockValueKind.Complex;

    private static bool IsRollingIdentity(string identity) => (string.Equals(identity, "sequence.rolling-maximum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-mean@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-median@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-minimum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-quantile@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-standard-deviation@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-sum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-variance@1", StringComparison.Ordinal));

    private static bool HasRuntimeShape(string? identity) => (string.Equals(identity, "sequence.difference@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-maximum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-mean@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-median@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-minimum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-quantile@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-standard-deviation@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-sum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-variance@1", StringComparison.Ordinal) || string.Equals(identity, "vector.linspace@1", StringComparison.Ordinal) || string.Equals(identity, "vector.repeat@1", StringComparison.Ordinal) || string.Equals(identity, "vector.slice@1", StringComparison.Ordinal) || string.Equals(identity, "vector.concatenate@1", StringComparison.Ordinal));

    private static bool TryGetExactScalar(
        IReadOnlyList<MathBlockValue?> values,
        int index,
        out double result)
    {
        if ((uint)index < (uint)values.Count &&
            values[index] is { } value &&
            value.Type.Kind == MathBlockValueKind.Scalar)
        {
            result = value.AsScalar();
            return true;
        }
        result = 0d;
        return false;
    }

    private static bool TryGetExactInteger(
        IReadOnlyList<MathBlockValue?> values,
        int index,
        out int result)
    {
        if (TryGetExactScalar(values, index, out var scalar) &&
            scalar >= int.MinValue && scalar <= int.MaxValue &&
            scalar == Math.Truncate(scalar))
        {
            result = (int)scalar;
            return true;
        }
        result = 0;
        return false;
    }

    private static bool TryGetExactNonnegativeInteger(
        IReadOnlyList<MathBlockValue?> values,
        int index,
        out int result) =>
        TryGetExactInteger(values, index, out result) && result >= 0;

    private static int ResolveExactCount(
        MathBlockProgramNode node,
        int inputIndex,
        IReadOnlyList<MathBlockValue?> inputExactValues,
        IReadOnlyList<MathBlockProgramNode> nodes,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        if (TryGetExactNonnegativeInteger(inputExactValues, inputIndex, out var count))
            return count;
        return ResolvePrototypeCount(nodes[node.Inputs[inputIndex]], prototypeInputs);
    }

    private static void RequireDomain(bool condition, MathBlockProgramNode node, string domain)
    {
        if (!condition)
            throw new InvalidOperationException($"CUDA static {domain} authority rejected node {node.Index}.");
    }

    // The capacity decision table is intentionally exhaustive and contiguous.
#pragma warning disable MA0051
    private static int ResolvePayloadCapacity(
        MathBlockProgramNode node,
        IReadOnlyList<MathBlockProgramNode> nodes,
        int[] inputCapacities,
        IReadOnlyList<int> inputShapeRows,
        IReadOnlyList<int> inputShapeColumns,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs,
        IReadOnlyDictionary<string, int>? inputCapacityOverrides,
        IReadOnlyList<MathBlockValue?> inputExactValues)
    {
        if (node.Type.Kind is MathBlockValueKind.Scalar or MathBlockValueKind.Boolean)
            return 0;
        if (node.Type.Kind == MathBlockValueKind.Complex)
            return 1;
        if (node.Kind == MathBlockProgramNodeKind.Constant)
            return MathBlockCudaValueCodec.GetElementCount(node.Value);
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            inputCapacityOverrides is not null &&
            inputCapacityOverrides.TryGetValue(node.Name!, out var overrideCapacity))
        {
            if (overrideCapacity < 0)
                throw new InvalidOperationException($"CUDA payload capacity override for node {node.Index} is negative.");
            return overrideCapacity;
        }
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            prototypeInputs is not null &&
            prototypeInputs.TryGetValue(node.Name!, out var prototype))
        {
            return MathBlockCudaValueCodec.GetElementCount(prototype);
        }
        if (node.Type.Kind is MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix &&
            node.Type.Rows > 0 &&
            node.Type.Columns > 0)
            return checked(node.Type.Rows * node.Type.Columns);
        if (node.Type.Kind is not (
                MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix or MathBlockValueKind.Graph) &&
            node.Type.Rows > 0)
            return node.Type.Rows;
        if (node.Kind == MathBlockProgramNodeKind.Operation)
        {
            var identity = node.OperationIdentity!;
            if (string.Equals(identity, "matrix.identity@1", StringComparison.Ordinal))
            {
                var size = ResolvePrototypeCount(nodes[node.Inputs[0]], prototypeInputs);
                return checked(size * size);
            }
            if (string.Equals(identity, "matrix.append-row@1", StringComparison.Ordinal))
            {
                return checked(
                    inputCapacities[0] +
                    inputCapacities[1]);
            }
            if (string.Equals(identity, "matrix.diagonal-from-vector@1", StringComparison.Ordinal))
            {
                var size = inputCapacities[0];
                return checked(size * size);
            }
            if (string.Equals(identity, "matrix.gram@1", StringComparison.Ordinal))
            {
                var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(columns * columns);
            }
            if ((string.Equals(identity, "matrix.hankel@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.toeplitz@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.outer-product@1", StringComparison.Ordinal)))
            {
                return checked(
                    inputCapacities[0] *
                    inputCapacities[1]);
            }
            if (string.Equals(identity, "matrix.stack-rows@1", StringComparison.Ordinal))
                return checked(inputCapacities[0] + inputCapacities[1]);
            if (string.Equals(identity, "complex-matrix.pick@1", StringComparison.Ordinal))
                return checked(inputCapacities[0] * inputCapacities[1]);
            if (string.Equals(identity, "matrix.kronecker-product@1", StringComparison.Ordinal))
            {
                return checked(
                    inputCapacities[0] *
                    inputCapacities[1]);
            }
            if ((string.Equals(identity, "matrix.multiply@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.commutator@1", StringComparison.Ordinal)))
            {
                return checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) *
                    RequireInputShapeColumns(node, 1, inputShapeColumns));
            }
            if (string.Equals(identity, "matrix.reshape@1", StringComparison.Ordinal))
                return inputCapacities[0];
            if (string.Equals(identity, "matrix.principal-minors@1", StringComparison.Ordinal))
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                if (rows < 0 || rows > 20)
                    throw new InvalidOperationException("CUDA principal-minor shape is outside the operation domain.");
                return checked((1 << rows) - 1);
            }
            if (string.Equals(identity, "matrix.maximal-minors@1", StringComparison.Ordinal))
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return BinomialCoefficient(columns, Math.Min(rows, columns / 2));
            }
            if (string.Equals(identity, "matrix.schur-complement@1", StringComparison.Ordinal))
            {
                var retained = ResolvePrototypeCount(nodes[node.Inputs[1]], prototypeInputs);
                return checked(retained * retained);
            }
            if (string.Equals(identity, "combinatorics.nonempty-subset-sums@1", StringComparison.Ordinal))
            {
                var count = inputCapacities[0];
                if (count < 0 || count > 20)
                    throw new InvalidOperationException("CUDA subset-sum shape is outside the operation domain.");
                return checked((1 << count) - 1);
            }
            if (string.Equals(identity, "sequence.convolution@1", StringComparison.Ordinal))
            {
                var left = inputCapacities[0];
                var right = inputCapacities[1];
                return left == 0 || right == 0 ? 0 : checked(left + right - 1);
            }
            if ((string.Equals(identity, "sequence.difference@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-maximum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-mean@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-median@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-minimum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-quantile@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-standard-deviation@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-sum@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-variance@1", StringComparison.Ordinal)))
            {
                if (TryGetExactNonnegativeInteger(inputExactValues, 1, out var parameter))
                {
                    var inputCount = RequireInputShapeRows(node, 0, inputShapeRows);
                    return string.Equals(identity, "sequence.difference@1"
, StringComparison.Ordinal) ? checked(inputCount - parameter)
                        : checked(inputCount - parameter + 1);
                }
                return inputCapacities[0];
            }
            if (string.Equals(identity, "path.lead-lag-transform@1", StringComparison.Ordinal))
            {
                var count = inputCapacities[0];
                return count == 0 ? 0 : checked((2 * count - 1) * 2);
            }
            if (string.Equals(identity, "path.run-length-encode@1", StringComparison.Ordinal))
                return inputCapacities[0];
            if (string.Equals(identity, "path.signature-level-one@1", StringComparison.Ordinal))
                return RequireInputShapeColumns(node, 0, inputShapeColumns);
            if (string.Equals(identity, "path.signature-level-two@1", StringComparison.Ordinal))
            {
                var dimension = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(dimension * dimension);
            }
            if (string.Equals(identity, "path.signature-level-three@1", StringComparison.Ordinal))
            {
                var dimension = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(dimension * dimension * dimension);
            }
            if (string.Equals(identity, "state.transition-counts@1", StringComparison.Ordinal))
            {
                var count = ResolvePrototypeCount(nodes[node.Inputs[1]], prototypeInputs);
                return checked(count * count);
            }
            if (string.Equals(identity, "statistics.covariance-matrix@1", StringComparison.Ordinal))
            {
                var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(columns * columns);
            }
            if (string.Equals(identity, "statistics.histogram@1", StringComparison.Ordinal))
                return checked(inputCapacities[1] + 1);
            if (string.Equals(identity, "geometry.barycentric-coordinates@1", StringComparison.Ordinal))
                return 3;
            if (string.Equals(identity, "geometry.centroid@1", StringComparison.Ordinal))
                return 1;
            if (string.Equals(identity, "geometry.convex-hull@1", StringComparison.Ordinal))
                return inputCapacities[0];
            if ((string.Equals(identity, "geometry.delaunay-graph@1", StringComparison.Ordinal) || string.Equals(identity, "geometry.gabriel-graph@1", StringComparison.Ordinal)))
            {
                var count = inputCapacities[0];
                return checked(count * (count - 1) / 2);
            }
            if (string.Equals(identity, "topology.zero-dimensional-persistence@1", StringComparison.Ordinal))
            {
                var count = inputCapacities[0];
                return count == 0 ? 0 : count - 1;
            }
            if (string.Equals(identity, "point-set.from-matrix@1", StringComparison.Ordinal))
                return RequireInputShapeRows(node, 0, inputShapeRows);
            if (string.Equals(identity, "point-set.to-matrix@1", StringComparison.Ordinal))
                return checked(inputCapacities[0] * 2);
            if (string.Equals(identity, "graph.from-directed-adjacency@1", StringComparison.Ordinal))
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                return checked(rows * (rows - 1));
            }
            if (string.Equals(identity, "graph.minimum-spanning-forest@1", StringComparison.Ordinal))
                return inputCapacities[0];
            if ((string.Equals(identity, "graph.degree@1", StringComparison.Ordinal) || string.Equals(identity, "graph.hodge-potential@1", StringComparison.Ordinal) || string.Equals(identity, "graph.page-rank@1", StringComparison.Ordinal) || string.Equals(identity, "graph.undirected-shortest-paths@1", StringComparison.Ordinal) || string.Equals(identity, "graph.weighted-degree@1", StringComparison.Ordinal)))
            {
                return RequireInputShapeRows(node, 0, inputShapeRows);
            }
            if ((string.Equals(identity, "graph.to-directed-adjacency@1", StringComparison.Ordinal) || string.Equals(identity, "graph.undirected-adjacency-matrix@1", StringComparison.Ordinal) || string.Equals(identity, "graph.undirected-laplacian@1", StringComparison.Ordinal)))
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                return checked(rows * rows);
            }
            if (string.Equals(identity, "cooperative.shapley-values@1", StringComparison.Ordinal))
            {
                var count = inputCapacities[0];
                if (count <= 0 || (count & (count - 1)) != 0)
                    throw new InvalidOperationException("CUDA Shapley shape is outside the operation domain.");
                var players = 0;
                while (count > 1)
                {
                    count >>= 1;
                    players++;
                }
                return players;
            }
            if ((string.Equals(identity, "extension.mcshane@1", StringComparison.Ordinal) || string.Equals(identity, "extension.whitney@1", StringComparison.Ordinal)))
                return inputCapacities[2];
            if (string.Equals(identity, "inequality.lorenz-curve@1", StringComparison.Ordinal))
                return checked(inputCapacities[0] + 1);
            if (string.Equals(identity, "markov.stationary-distribution@1", StringComparison.Ordinal))
                return RequireInputShapeRows(node, 0, inputShapeRows);
            if (string.Equals(identity, "transport.minimum-assignment@1", StringComparison.Ordinal))
                return RequireInputShapeRows(node, 0, inputShapeRows);
            if (string.Equals(identity, "transport.monotone-coupling@1", StringComparison.Ordinal))
            {
                return checked(
                    inputCapacities[0] *
                    inputCapacities[1]);
            }
            if (string.Equals(identity, "transport.sinkhorn-coupling@1", StringComparison.Ordinal))
                return inputCapacities[0];
            if ((string.Equals(identity, "tropical.max-plus-multiply@1", StringComparison.Ordinal) || string.Equals(identity, "tropical.min-plus-multiply@1", StringComparison.Ordinal)))
            {
                return checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) *
                    RequireInputShapeColumns(node, 1, inputShapeColumns));
            }
            if (string.Equals(identity, "vector.pair@1", StringComparison.Ordinal))
                return 2;
            if ((string.Equals(identity, "vector.append@1", StringComparison.Ordinal) || string.Equals(identity, "vector.prepend@1", StringComparison.Ordinal)))
                return checked(inputCapacities[0] + 1);
            if (string.Equals(identity, "vector.concatenate@1", StringComparison.Ordinal))
            {
                return checked(
                    inputCapacities[0] +
                    inputCapacities[1]);
            }
            if (string.Equals(identity, "vector.linspace@1", StringComparison.Ordinal))
                return ResolveExactCount(node, 2, inputExactValues, nodes, prototypeInputs);
            if (string.Equals(identity, "vector.repeat@1", StringComparison.Ordinal))
                return ResolveExactCount(node, 1, inputExactValues, nodes, prototypeInputs);
            if (string.Equals(identity, "vector.slice@1", StringComparison.Ordinal))
                return ResolveExactCount(node, 2, inputExactValues, nodes, prototypeInputs);
            if (string.Equals(identity, "vector.gather@1", StringComparison.Ordinal))
                return inputCapacities[1];
            if (node.Inputs.Count != 0)
            {
                var maximum = 0;
                for (var inputIndex = 0; inputIndex < node.Inputs.Count; inputIndex++)
                {
                    var capacity = inputCapacities[inputIndex];
                    if (capacity > maximum)
                        maximum = capacity;
                }
                return maximum;
            }
        }
        throw new InvalidOperationException($"CUDA payload capacity is unknown for node {node.Index}.");
    }

#pragma warning restore MA0051
    private static MathBlockCudaShapeAuthority ResolveShapeAuthority(
        MathBlockProgramNode node,
        int capacity,
        IReadOnlyList<int> inputCapacities,
        IReadOnlyList<int> inputShapeRows,
        IReadOnlyList<int> inputShapeColumns,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs,
        IReadOnlyDictionary<string, MathBlockCudaShapeAuthority>? inputShapeOverrides,
        IReadOnlyList<MathBlockValue?> inputExactValues)
    {
        if (node.Kind == MathBlockProgramNodeKind.Constant)
        {
            return CompleteShapeAuthority(
                node,
                capacity,
                ValueShapeRows(node.Value),
                ValueShapeColumns(node.Value));
        }
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            inputShapeOverrides is not null &&
            inputShapeOverrides.TryGetValue(node.Name!, out var inputShape))
        {
            return CompleteShapeAuthority(node, capacity, inputShape.Rows, inputShape.Columns);
        }
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            prototypeInputs is not null &&
            prototypeInputs.TryGetValue(node.Name!, out var prototype))
        {
            return CompleteShapeAuthority(
                node,
                capacity,
                ValueShapeRows(prototype),
                ValueShapeColumns(prototype));
        }

        var rows = node.Type.Rows;
        var columns = node.Type.Columns;
        if (node.Kind == MathBlockProgramNodeKind.Operation && (rows == 0 || columns == 0))
        {
            var inferred = ResolveOperationShapeAuthority(
                node,
                inputCapacities,
                inputShapeRows,
                inputShapeColumns,
                inputExactValues);
            if (rows == 0)
                rows = inferred.Rows;
            if (columns == 0)
                columns = inferred.Columns;
        }
        return CompleteShapeAuthority(node, capacity, rows, columns);
    }

    private static MathBlockCudaShapeAuthority ResolveOperationShapeAuthority(
        MathBlockProgramNode node,
        IReadOnlyList<int> inputCapacities,
        IReadOnlyList<int> inputShapeRows,
        IReadOnlyList<int> inputShapeColumns,
        IReadOnlyList<MathBlockValue?> inputExactValues)
    {
        var identity = node.OperationIdentity!;
        if ((string.Equals(identity, "matrix.gram@1", StringComparison.Ordinal) || string.Equals(identity, "statistics.covariance-matrix@1", StringComparison.Ordinal)))
        {
            var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
            return new MathBlockCudaShapeAuthority(columns, columns);
        }
        if (string.Equals(identity, "matrix.transpose@1", StringComparison.Ordinal))
        {
            return new MathBlockCudaShapeAuthority(
                RequireInputShapeColumns(node, 0, inputShapeColumns),
                RequireInputShapeRows(node, 0, inputShapeRows));
        }
        if ((string.Equals(identity, "matrix.multiply@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.commutator@1", StringComparison.Ordinal) || string.Equals(identity, "tropical.max-plus-multiply@1", StringComparison.Ordinal) || string.Equals(identity, "tropical.min-plus-multiply@1", StringComparison.Ordinal)))
        {
            return new MathBlockCudaShapeAuthority(
                RequireInputShapeRows(node, 0, inputShapeRows),
                RequireInputShapeColumns(node, 1, inputShapeColumns));
        }
        if (string.Equals(identity, "matrix.append-row@1", StringComparison.Ordinal))
        {
            return new MathBlockCudaShapeAuthority(
                checked(RequireInputShapeRows(node, 0, inputShapeRows) + 1),
                RequireInputShapeColumns(node, 0, inputShapeColumns));
        }
        if (string.Equals(identity, "matrix.diagonal-from-vector@1", StringComparison.Ordinal))
            return new MathBlockCudaShapeAuthority(inputCapacities[0], inputCapacities[0]);
        if ((string.Equals(identity, "matrix.hankel@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.toeplitz@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.outer-product@1", StringComparison.Ordinal)))
            return new MathBlockCudaShapeAuthority(inputCapacities[0], inputCapacities[1]);
        if (string.Equals(identity, "matrix.stack-rows@1", StringComparison.Ordinal))
            return new MathBlockCudaShapeAuthority(2, Math.Max(inputCapacities[0], inputCapacities[1]));
        if (string.Equals(identity, "complex-matrix.pick@1", StringComparison.Ordinal))
        {
            var dimension = Math.Min(inputCapacities[0], inputCapacities[1]);
            return new MathBlockCudaShapeAuthority(dimension, dimension);
        }
        if (string.Equals(identity, "matrix.kronecker-product@1", StringComparison.Ordinal))
        {
            return new MathBlockCudaShapeAuthority(
                checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) *
                    RequireInputShapeRows(node, 1, inputShapeRows)),
                checked(
                    RequireInputShapeColumns(node, 0, inputShapeColumns) *
                    RequireInputShapeColumns(node, 1, inputShapeColumns)));
        }
        if (string.Equals(identity, "path.lead-lag-transform@1", StringComparison.Ordinal))
        {
            var count = inputCapacities[0];
            return new MathBlockCudaShapeAuthority(count == 0 ? 0 : checked(2 * count - 1), 2);
        }
        if (string.Equals(identity, "sequence.difference@1", StringComparison.Ordinal) &&
            TryGetExactNonnegativeInteger(inputExactValues, 1, out var lag))
        {
            return new MathBlockCudaShapeAuthority(
                checked(RequireInputShapeRows(node, 0, inputShapeRows) - lag),
                0);
        }
        if (IsRollingIdentity(identity) &&
            TryGetExactNonnegativeInteger(inputExactValues, 1, out var width))
        {
            return new MathBlockCudaShapeAuthority(
                checked(RequireInputShapeRows(node, 0, inputShapeRows) - width + 1),
                0);
        }
        if (string.Equals(identity, "vector.concatenate@1", StringComparison.Ordinal))
        {
            return new MathBlockCudaShapeAuthority(
                checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) +
                    RequireInputShapeRows(node, 1, inputShapeRows)),
                0);
        }
        if ((string.Equals(identity, "vector.linspace@1", StringComparison.Ordinal) || string.Equals(identity, "vector.repeat@1", StringComparison.Ordinal)))
        {
            var countInput = string.Equals(identity, "vector.linspace@1", StringComparison.Ordinal) ? 2 : 1;
            if (TryGetExactNonnegativeInteger(inputExactValues, countInput, out var count))
                return new MathBlockCudaShapeAuthority(count, 0);
        }
        if (string.Equals(identity, "vector.slice@1", StringComparison.Ordinal) &&
            TryGetExactNonnegativeInteger(inputExactValues, 2, out var length))
        {
            return new MathBlockCudaShapeAuthority(length, 0);
        }
        if (string.Equals(identity, "point-set.to-matrix@1", StringComparison.Ordinal))
            return new MathBlockCudaShapeAuthority(inputCapacities[0], 2);
        if ((string.Equals(identity, "graph.to-directed-adjacency@1", StringComparison.Ordinal) || string.Equals(identity, "graph.undirected-adjacency-matrix@1", StringComparison.Ordinal) || string.Equals(identity, "graph.undirected-laplacian@1", StringComparison.Ordinal)))
        {
            var rows = RequireInputShapeRows(node, 0, inputShapeRows);
            return new MathBlockCudaShapeAuthority(rows, rows);
        }
        return default;
    }

    private static MathBlockCudaShapeAuthority CompleteShapeAuthority(
        MathBlockProgramNode node,
        int capacity,
        int rows,
        int columns)
    {
        if (rows < 0 || columns < 0)
            throw new InvalidOperationException($"CUDA shape authority for node {node.Index} is negative.");
        switch (node.Type.Kind)
        {
            case MathBlockValueKind.Vector:
            case MathBlockValueKind.ComplexVector:
            case MathBlockValueKind.BooleanVector:
            case MathBlockValueKind.PointSet:
            case MathBlockValueKind.RunSet:
                return new MathBlockCudaShapeAuthority(rows == 0 ? capacity : rows, columns);
            case MathBlockValueKind.Matrix:
            case MathBlockValueKind.ComplexMatrix:
                if (rows == 0 && columns == 0)
                    return new MathBlockCudaShapeAuthority(capacity, capacity);
                if (rows == 0)
                    rows = DivideRoundUp(capacity, columns);
                if (columns == 0)
                    columns = DivideRoundUp(capacity, rows);
                return new MathBlockCudaShapeAuthority(rows, columns);
            default:
                return new MathBlockCudaShapeAuthority(rows, columns);
        }
    }

    private static int DivideRoundUp(int value, int divisor)
    {
        if (value == 0)
            return 0;
        if (divisor <= 0)
            throw new InvalidOperationException("CUDA shape authority is unavailable.");
        return checked(1 + (value - 1) / divisor);
    }

    private static int RequireInputShapeRows(
        MathBlockProgramNode node,
        int inputIndex,
        IReadOnlyList<int> inputShapeRows)
    {
        var rows = inputShapeRows[inputIndex];
        if (rows <= 0)
        {
            throw new InvalidOperationException(
                $"CUDA row authority for input {inputIndex} of node {node.Index} is unavailable.");
        }
        return rows;
    }

    private static int RequireInputShapeColumns(
        MathBlockProgramNode node,
        int inputIndex,
        IReadOnlyList<int> inputShapeColumns)
    {
        var columns = inputShapeColumns[inputIndex];
        if (columns <= 0)
        {
            throw new InvalidOperationException(
                $"CUDA column authority for input {inputIndex} of node {node.Index} is unavailable.");
        }
        return columns;
    }

    private static int ResolveShapeRows(
        MathBlockProgramNode node,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        if (node.Kind == MathBlockProgramNodeKind.Constant)
            return ValueShapeRows(node.Value);
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            prototypeInputs is not null &&
            prototypeInputs.TryGetValue(node.Name!, out var prototype))
        {
            return ValueShapeRows(prototype);
        }
        return node.Type.Rows;
    }

    private static int ResolveShapeColumns(
        MathBlockProgramNode node,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        if (node.Kind == MathBlockProgramNodeKind.Constant)
            return ValueShapeColumns(node.Value);
        if (node.Kind == MathBlockProgramNodeKind.Input &&
            prototypeInputs is not null &&
            prototypeInputs.TryGetValue(node.Name!, out var prototype))
        {
            return ValueShapeColumns(prototype);
        }
        return node.Type.Columns;
    }

    private static int ValueShapeRows(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Matrix => value.AsMatrix().Rows,
        MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Rows,
        MathBlockValueKind.Graph => value.AsGraph().VertexCount,
        _ => value.Type.Rows
    };

    private static int ValueShapeColumns(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Matrix => value.AsMatrix().Columns,
        MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Columns,
        _ => value.Type.Columns
    };

    private static int ResolvePrototypeCount(
        MathBlockProgramNode node,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        MathBlockValue value;
        if (node.Kind == MathBlockProgramNodeKind.Constant)
            value = node.Value;
        else if (node.Kind == MathBlockProgramNodeKind.Input &&
                 prototypeInputs is not null &&
                 prototypeInputs.TryGetValue(node.Name!, out var prototype))
            value = prototype;
        else
            throw new InvalidOperationException($"CUDA shape input for node {node.Index} is unavailable.");

        var scalar = value.AsScalar();
        if (scalar < 0d || scalar > int.MaxValue || scalar != Math.Truncate(scalar))
            throw new InvalidOperationException($"CUDA shape input for node {node.Index} is not a nonnegative integer.");
        return (int)scalar;
    }

    private static int ResolvePayloadBytes(MathBlockValueKind kind, int capacity) =>
        MathBlockCudaValueCodec.GetPayloadByteCount(kind, capacity);

    internal static int ResolveScratchBytes(
        MathBlockProgramNode node,
        IReadOnlyList<MathBlockProgramNode> nodes,
        MathBlockCudaPayloadLayout payloadLayout)
    {
        if (node.Kind != MathBlockProgramNodeKind.Operation)
            return 0;
        var inputTypes = new MathBlockType[node.Inputs.Count];
        var inputCapacities = new int[node.Inputs.Count];
        var inputShapeRows = new int[node.Inputs.Count];
        var inputShapeColumns = new int[node.Inputs.Count];
        for (var index = 0; index < node.Inputs.Count; index++)
        {
            var input = node.Inputs[index];
            inputTypes[index] = nodes[input].Type;
            inputCapacities[index] = payloadLayout.Capacities[input];
            inputShapeRows[index] = payloadLayout.ShapeRows[input];
            inputShapeColumns[index] = payloadLayout.ShapeColumns[input];
        }
        if (((string.Equals(node.OperationIdentity, "sequence.rolling-median@1", StringComparison.Ordinal) || string.Equals(node.OperationIdentity, "sequence.rolling-quantile@1", StringComparison.Ordinal))) &&
            node.Inputs.Count is >= 2 &&
            payloadLayout.ExactValues[node.Inputs[1]] is { } widthValue &&
            widthValue.Type.Kind == MathBlockValueKind.Scalar)
        {
            var width = widthValue.AsScalar();
            if (width > 0d && width <= int.MaxValue && width == Math.Truncate(width))
            {
                var inputCount = payloadLayout.Capacities[node.Inputs[0]];
                if ((int)width == 1)
                    return 0;
                if (string.Equals(node.OperationIdentity, "sequence.rolling-quantile@1", StringComparison.Ordinal) &&
                    node.Inputs.Count is >= 3 &&
                    payloadLayout.ExactValues[node.Inputs[2]] is { } probabilityValue &&
                    probabilityValue.Type.Kind == MathBlockValueKind.Scalar &&
                    probabilityValue.AsScalar() is 0d or 1d)
                {
                    return checked(inputCount * sizeof(int));
                }
                return ResolveRollingOrderStatisticScratchBytes(inputCount, (int)width);
            }
        }
        return ResolveScratchBytes(
            node.OperationIdentity!,
            node.Type,
            inputTypes,
            inputCapacities,
            inputShapeRows,
            inputShapeColumns);
    }

    internal static int ResolveScratchBytes(
        string identity,
        MathBlockType outputType,
        Supprocom.MathBlocks.MathBlockType[] inputTypes,
        int[] inputCapacities,
        int[] inputShapeRows,
        int[] inputShapeColumns)
    {
        if (inputTypes.Length != inputCapacities.Length ||
            inputTypes.Length != inputShapeRows.Length ||
            inputTypes.Length != inputShapeColumns.Length)
        {
            throw new ArgumentException("CUDA scratch input metadata is inconsistent.");
        }
        if ((string.Equals(identity, "sequence.rolling-median@1", StringComparison.Ordinal) || string.Equals(identity, "sequence.rolling-quantile@1", StringComparison.Ordinal)))
        {
            return inputCapacities.Length == 0
                ? 0
                : ResolveRollingOrderStatisticScratchBytes(
                    inputCapacities[0],
                    inputCapacities[0]);
        }
        if (inputTypes.Length != 0)
        {
            var firstCount = inputCapacities[0];
            var rows = inputShapeRows[0];
            var columns = inputShapeColumns[0];
            if (RequiresScratchRows(identity) && rows <= 0)
                throw new InvalidOperationException($"CUDA scratch row authority is unavailable for '{identity}'.");
            if (RequiresScratchColumns(identity) && columns <= 0)
                throw new InvalidOperationException($"CUDA scratch column authority is unavailable for '{identity}'.");
            var doubleCount = identity switch
            {
                "matrix.determinant@1" or "matrix.rank@1" or
                    "matrix.is-positive-definite@1" => firstCount,
                "matrix.solve@1" or "matrix.inverse@1" => checked(firstCount + rows * 2),
                "matrix.symmetric-eigenvalues@1" or
                    "matrix.smallest-symmetric-eigenvalue@1" or
                    "matrix.largest-symmetric-eigenvalue@1" => checked(firstCount + rows),
                "matrix.integer-power@1" => checked(firstCount * 2),
                "matrix.exponential@1" => checked(firstCount * 3),
                "matrix.is-totally-nonnegative@1" or
                    "matrix.principal-minors@1" => checked(firstCount * 2),
                "matrix.maximal-minors@1" => checked(firstCount * 3),
                "matrix.perron-vector@1" or "matrix.perron-value@1" => checked(rows * 3),
                "matrix.spectral-norm@1" => checked(columns * columns * 2 + columns),
                "matrix.schur-complement@1" => checked(firstCount * 10),
                "polynomial.elementary-symmetric@1" => checked(firstCount + 1),
                "information.jensen-shannon@1" => firstCount,
                "information.mutual-information@1" => checked(rows + columns),
                "information.conditional-mutual-information@1" => checked(firstCount * 3),
                "sequence.rolling-maximum@1" or
                    "sequence.rolling-minimum@1" or
                    "transform.haar@1" => firstCount,
                "path.dynamic-time-warping@1" => checked(
                    2 * (inputCapacities[1] + 1)),
                "path.signature-level-two@1" => checked(columns * 2),
                "path.signature-level-three@1" => checked(columns * columns + columns * 2),
                "statistics.covariance-matrix@1" => columns,
                "statistics.distance-correlation@1" => checked(firstCount * firstCount * 2 + firstCount),
                "statistics.median-absolute-deviation@1" => checked(firstCount * 2),
                "statistics.pseudomedian@1" => checked(firstCount * (firstCount + 1) / 2),
                "statistics.spearman-correlation@1" => checked(firstCount * 2),
                "statistics.theil-sen-slope@1" => checked(firstCount * (firstCount - 1) / 2),
                "geometry.convex-hull@1" => checked(firstCount * 6),
                "geometry.delaunay-graph@1" => checked(firstCount * firstCount + firstCount),
                "geometry.discrete-frechet-distance@1" => checked(
                    firstCount * inputCapacities[1]),
                "topology.zero-dimensional-persistence@1" => checked(
                    firstCount * (firstCount - 1) + firstCount * 2),
                "graph.algebraic-connectivity@1" => checked(rows * rows * 2 + rows),
                "graph.connected-component-count@1" or "graph.is-connected@1" => checked(rows * 2),
                "graph.hodge-potential@1" => checked(
                    2 * (rows - 1) * (rows - 1) + 2 * (rows - 1)),
                "graph.minimum-spanning-forest@1" => checked(firstCount * 2 + rows * 2),
                "graph.page-rank@1" => checked(rows * 2),
                "graph.triangle-count@1" => checked(rows * rows),
                "graph.undirected-shortest-paths@1" => rows,
                "capacity.choquet-integral@1" => firstCount,
                "markov.stationary-distribution@1" => rows,
                "order.isotonic-regression@1" => checked(firstCount * 3),
                "order.majorizes@1" => checked(firstCount * 2),
                "shape.greatest-convex-minorant@1" or
                    "shape.is-completely-monotone@1" or
                    "shape.least-concave-majorant@1" => firstCount,
                "transport.minimum-assignment@1" => ResolveAssignmentScratch(rows),
                "transport.sinkhorn-coupling@1" => checked(firstCount + rows + columns),
                "transport.uniform-wasserstein@1" => checked(firstCount * 2),
                "transport.weighted-wasserstein-1@1" => checked(
                    firstCount + inputCapacities[2]),
                _ => 0
            };
            if (doubleCount != 0)
                return checked(doubleCount * sizeof(double));
        }
        if (outputType.Kind is not MathBlockValueKind.Scalar and not MathBlockValueKind.Boolean)
            return 0;
        var bytes = 0;
        for (var index = 0; index < inputTypes.Length; index++)
        {
            var inputBytes = ResolvePayloadBytes(inputTypes[index].Kind, inputCapacities[index]);
            if (inputBytes > bytes)
                bytes = inputBytes;
        }
        return bytes;
    }

    private static bool RequiresScratchRows(string identity) => (string.Equals(identity, "matrix.solve@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.inverse@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.symmetric-eigenvalues@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.smallest-symmetric-eigenvalue@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.largest-symmetric-eigenvalue@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.perron-vector@1", StringComparison.Ordinal) || string.Equals(identity, "matrix.perron-value@1", StringComparison.Ordinal) || string.Equals(identity, "information.mutual-information@1", StringComparison.Ordinal) || string.Equals(identity, "graph.algebraic-connectivity@1", StringComparison.Ordinal) || string.Equals(identity, "graph.connected-component-count@1", StringComparison.Ordinal) || string.Equals(identity, "graph.is-connected@1", StringComparison.Ordinal) || string.Equals(identity, "graph.hodge-potential@1", StringComparison.Ordinal) || string.Equals(identity, "graph.minimum-spanning-forest@1", StringComparison.Ordinal) || string.Equals(identity, "graph.page-rank@1", StringComparison.Ordinal) || string.Equals(identity, "graph.triangle-count@1", StringComparison.Ordinal) || string.Equals(identity, "graph.undirected-shortest-paths@1", StringComparison.Ordinal) || string.Equals(identity, "markov.stationary-distribution@1", StringComparison.Ordinal) || string.Equals(identity, "transport.minimum-assignment@1", StringComparison.Ordinal) || string.Equals(identity, "transport.sinkhorn-coupling@1", StringComparison.Ordinal));

    private static bool RequiresScratchColumns(string identity) => (string.Equals(identity, "matrix.spectral-norm@1", StringComparison.Ordinal) || string.Equals(identity, "information.mutual-information@1", StringComparison.Ordinal) || string.Equals(identity, "path.signature-level-two@1", StringComparison.Ordinal) || string.Equals(identity, "path.signature-level-three@1", StringComparison.Ordinal) || string.Equals(identity, "statistics.covariance-matrix@1", StringComparison.Ordinal) || string.Equals(identity, "transport.sinkhorn-coupling@1", StringComparison.Ordinal));

    private static int BinomialCoefficient(int count, int selected)
    {
        if (selected < 0 || count < 0 || selected > count)
            return 0;
        if (selected > count - selected)
            selected = count - selected;
        var result = 1L;
        for (var index = 1; index <= selected; index++)
            result = checked(result * (count - selected + index) / index);
        return checked((int)result);
    }

    private static int ResolveAssignmentScratch(int size)
    {
        if (size < 0 || size > 20)
            throw new InvalidOperationException("CUDA assignment shape is outside the operation domain.");
        return checked(2 * (1 << size));
    }

    internal static int ResolveRollingOrderStatisticScratchBytes(int inputCount, int windowWidth)
    {
        if (inputCount <= 0 || windowWidth <= 1)
            return 0;
        if (windowWidth > inputCount)
        {
            throw new InvalidOperationException(
                "CUDA rolling window shape exceeds its input.");
        }
        var bytes = checked(
            checked((long)inputCount * 36) +
            checked((long)windowWidth * 8) +
            checked((long)(int)SequencePathCudaBlockCatalog.BlockSize * sizeof(int) * 2));
        if (bytes > int.MaxValue)
        {
            throw new InvalidOperationException(
                "CUDA rolling order-statistic scratch exceeds the supported resource range.");
        }
        return (int)bytes;
    }

    private static int AlignArenaOffset(int offset) => checked((offset + 7) & ~7);

    private static bool InputsAreStaged(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        if (program.Inputs.Count == 0)
            return true;
        if (prototypeInputs is null)
            return false;
        foreach (var input in program.Inputs.Keys)
            if (!prototypeInputs.ContainsKey(input))
                return false;
        return true;
    }

    private static unsafe void ClearArena(IntPtr arena, int size) =>
        new Span<byte>((void*)arena, size).Clear();

    private static unsafe void WriteInputPointers(
        IntPtr arena,
        int offset,
        ulong deviceArena,
        int[] slotOffsets,
        IReadOnlyList<int> inputs)
    {
        var destination = (ulong*)((byte*)arena + offset);
        for (var index = 0; index < inputs.Count; index++)
            destination[index] = checked(deviceArena + (ulong)slotOffsets[inputs[index]]);
    }

    private void ThrowIfDisposed()
    {
        ObjectDisposedException.ThrowIf(disposed, this);
    }

    private sealed class KernelArgumentStorage : IDisposable
    {
        private readonly IntPtr[] values;
        private bool disposed;

        public KernelArgumentStorage(int opcode, ulong inputs, int inputCount, ulong output)
        {
            values =
            [
                AllocateInt32(opcode),
                AllocatePointer(inputs),
                AllocateInt32(inputCount),
                AllocatePointer(output)
            ];
            PointerArray = Marshal.AllocHGlobal(IntPtr.Size * values.Length);
            for (var index = 0; index < values.Length; index++)
                Marshal.WriteIntPtr(PointerArray, index * IntPtr.Size, values[index]);
        }

        public IntPtr PointerArray { get; private set; }

        public void Dispose()
        {
            if (disposed)
                return;
            disposed = true;
            if (PointerArray != IntPtr.Zero)
                Marshal.FreeHGlobal(PointerArray);
            PointerArray = IntPtr.Zero;
            foreach (var value in values)
                Marshal.FreeHGlobal(value);
        }

        private static IntPtr AllocateInt32(int value)
        {
            var pointer = Marshal.AllocHGlobal(sizeof(int));
            Marshal.WriteInt32(pointer, value);
            return pointer;
        }

        private static IntPtr AllocatePointer(ulong value)
        {
            var pointer = Marshal.AllocHGlobal(sizeof(long));
            Marshal.WriteInt64(pointer, unchecked((long)value));
            return pointer;
        }
    }
}
