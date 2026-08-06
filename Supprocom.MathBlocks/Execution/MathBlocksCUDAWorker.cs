using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

internal readonly record struct MathBlockCudaShapeAuthority(int Rows, int Columns);

internal readonly record struct MathBlockCudaPayloadLayout(
    int[] Capacities,
    int[] ShapeRows,
    int[] ShapeColumns,
    MathBlockValue?[] ExactValues,
    MathBlockType[] ResolvedTypes);

public readonly record struct MathBlockRollingOrderStatisticWorkPlan(
    int InputCount,
    int WindowWidth,
    int OutputCount,
    double Probability,
    bool UsesLinearExtremeDeque,
    bool UsesParallelRadixPreparation,
    int RadixPassCount,
    long ParallelKeyVisitCount,
    long HeapOperationBound,
    long SelectionOperationBound,
    long TotalOperationBound);

public sealed class MathBlocksCUDAWorker
{
    public static bool IsAvailable => MathBlocksCudaNative.IsAvailable();
    public static IReadOnlyCollection<string> SupportedBlockIdentities =>
        MathBlocksCudaKernelModule.SupportedBlockIdentities;
    public static IReadOnlyCollection<string> SupportedPopulationOperationIdentities =>
        MathBlockProgramPopulationCudaOperations.SupportedIdentities;
    public static IReadOnlyCollection<string> SupportedPopulationSearchOperationIdentities =>
        MathBlockCudaFeatureIndex.SupportedIdentities;

    public MathBlocksCUDAProgram Compile(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs = null)
    {
        ArgumentNullException.ThrowIfNull(program);
        return MathBlocksCUDAProgram.Create(program, prototypeInputs);
    }

    public MathBlocksCUDAProgramPopulation CompilePopulation(
        MathBlockProgramPopulationDefinition definition)
    {
        ArgumentNullException.ThrowIfNull(definition);
        return MathBlocksCUDAProgramPopulation.Create(definition);
    }

    public MathBlocksCUDAProgramPopulationSearch CompilePopulationSearch(
        MathBlockProgramPopulationSearchDefinition definition)
    {
        return CompilePopulationSearch(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
    }

    public MathBlocksCUDAProgramPopulationSearch CompilePopulationSearch(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationExecutionOptions executionOptions)
    {
        ArgumentNullException.ThrowIfNull(definition);
        ArgumentNullException.ThrowIfNull(executionOptions);
        return MathBlocksCUDAProgramPopulationSearch.Create(definition, executionOptions);
    }

    public MathBlockProgramPopulationStaticFeasibilityPlan PlanPopulationSearchStaticFeasibility(
        MathBlockProgramPopulationSearchDefinition definition)
    {
        ArgumentNullException.ThrowIfNull(definition);
        return MathBlockProgramPopulationCatalogCapacityPlanner.CreateFeasibilityPlan(definition);
    }

    public MathBlockRollingOrderStatisticWorkPlan PlanRollingOrderStatisticWork(
        int inputCount,
        int windowWidth,
        double probability)
    {
        if (inputCount <= 0)
            throw new ArgumentOutOfRangeException(nameof(inputCount));
        if (windowWidth <= 0 || windowWidth > inputCount)
            throw new ArgumentOutOfRangeException(nameof(windowWidth));
        if (!double.IsFinite(probability) || probability is < 0d or > 1d)
            throw new ArgumentOutOfRangeException(nameof(probability));
        var outputCount = checked(inputCount - windowWidth + 1);
        if (windowWidth == 1)
        {
            return new MathBlockRollingOrderStatisticWorkPlan(
                inputCount,
                windowWidth,
                outputCount,
                probability,
                false,
                false,
                0,
                inputCount,
                0,
                0,
                inputCount);
        }
        if (probability is 0d or 1d)
        {
            var linearBound = checked((long)inputCount * 3);
            return new MathBlockRollingOrderStatisticWorkPlan(
                inputCount,
                windowWidth,
                outputCount,
                probability,
                true,
                false,
                0,
                linearBound,
                0,
                outputCount,
                checked(linearBound + outputCount));
        }
        var heapHeight = 1;
        for (var value = windowWidth; value > 1; value = (value + 1) >> 1)
            heapHeight++;
        var radixVisits = checked((long)inputCount * 64);
        var heapOperations = outputCount == 1
            ? 0
            : checked(
                ((long)windowWidth + checked(2L * (inputCount - windowWidth))) * heapHeight);
        var selectionOperations = checked((long)outputCount * 2);
        return new MathBlockRollingOrderStatisticWorkPlan(
            inputCount,
            windowWidth,
            outputCount,
            probability,
            false,
            true,
            64,
            radixVisits,
            heapOperations,
            selectionOperations,
            checked(radixVisits + heapOperations + selectionOperations));
    }

    public IReadOnlyList<MathBlockProgramPopulationResourceBand>
        PlanPopulationEnumerationCatalogResourceBands(
            MathBlockProgramPopulationDefinition population,
            MathBlockProgramPopulationEnumerationCatalog catalog)
    {
        ArgumentNullException.ThrowIfNull(population);
        ArgumentNullException.ThrowIfNull(catalog);
        return MathBlockProgramPopulationCatalogCapacityPlanner.Plan(population, catalog);
    }

    public MathBlockProgramPopulationSearchCapacity MeasurePopulationSearchCapacity(
        MathBlockProgramPopulationSearchDefinition definition)
    {
        return MeasurePopulationSearchCapacity(
            definition,
            MathBlockProgramPopulationExecutionOptions.SerialResident);
    }

    public MathBlockProgramPopulationSearchCapacity MeasurePopulationSearchCapacity(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramPopulationExecutionOptions executionOptions)
    {
        ArgumentNullException.ThrowIfNull(definition);
        ArgumentNullException.ThrowIfNull(executionOptions);
        executionOptions.ValidateResidentExecution(nameof(executionOptions));
        return PopulationSearchLayout.Create(
            definition,
            executionOptions.CandidateLaneCount,
            enforceEnvelope: false).Capacity;
    }
}

internal static class MathBlockProgramPopulationCatalogCapacityPlanner
{
    public static MathBlockProgramPopulationStaticFeasibilityPlan CreateFeasibilityPlan(
        MathBlockProgramPopulationSearchDefinition definition)
    {
        var catalog = definition.EnumerationCatalog ??
            throw new ArgumentException("Static catalog feasibility requires an enumeration catalog.", nameof(definition));
        var feasible = new List<MathBlockProgramStructure>();
        var rejected = new List<MathBlockProgramPopulationStaticRejection>();
        var requiredByOperationCount = new Dictionary<int, int>();
        var inspectedNodes = 0;
        var liveNodes = 0;
        var constantFolds = 0;
        var commonSubexpressions = 0;
        var expressions = new HashSet<string>(StringComparer.Ordinal);
        foreach (var structure in catalog.Programs)
        {
            inspectedNodes = checked(
                inspectedNodes +
                structure.Nodes.Count +
                definition.ObjectiveBinding.Program.PlanNodes.Count);
            CountProgramAuthorities(
                definition,
                structure,
                ref liveNodes,
                ref constantFolds,
                ref commonSubexpressions,
                expressions);
            if (TryAnalyzeProgram(definition, structure, out var requiredElements, out var reason))
            {
                feasible.Add(structure);
                var operationCount = checked(
                    structure.Nodes.Count - definition.Population.AllTerminals.Count);
                if (!requiredByOperationCount.TryGetValue(operationCount, out var current) ||
                    requiredElements > current)
                {
                    requiredByOperationCount[operationCount] = requiredElements;
                }
            }
            else
            {
                rejected.Add(new MathBlockProgramPopulationStaticRejection(
                    structure.ProposalCursor!.Value,
                    structure.StructuralFingerprint,
                    reason ?? "Static CUDA feasibility failed."));
            }
        }
        var bands = new MathBlockProgramPopulationResourceBand[requiredByOperationCount.Count];
        var bandIndex = 0;
        foreach (var requirement in requiredByOperationCount)
        {
            bands[bandIndex++] = new MathBlockProgramPopulationResourceBand(
                requirement.Key,
                requirement.Value);
        }
        MathBlockCollectionPrimitives.StableMergeSort(
            bands,
            (left, right) => left.OperationCount.CompareTo(right.OperationCount));
        return new MathBlockProgramPopulationStaticFeasibilityPlan(
            feasible,
            rejected,
            bands,
            new MathBlockProgramPopulationStaticInstrumentation(
                catalog.Programs.Count,
                feasible.Count,
                rejected.Count,
                inspectedNodes,
                liveNodes,
                checked(inspectedNodes - liveNodes),
                constantFolds,
                commonSubexpressions,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0));
    }

    public static bool TryAnalyzeProgram(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramStructure structure,
        out int requiredElements,
        out string? rejectionReason)
    {
        ArgumentNullException.ThrowIfNull(definition);
        ArgumentNullException.ThrowIfNull(structure);
        try
        {
            var population = definition.Population;
            population.ValidateResidentStructure(structure);
            var candidatePlan = BuildPlan(population, structure);
            MathBlocksCUDAProgram.ValidateProgram(candidatePlan);
            var candidateLayout = MathBlocksCUDAProgram.ResolvePayloadLayout(
                candidatePlan,
                null);
            requiredElements = 1;
            for (var nodeIndex = population.AllTerminals.Count;
                nodeIndex < candidatePlan.Count;
                nodeIndex++)
            {
                if (!structure.Nodes[nodeIndex].Type.Accepts(
                        candidateLayout.ResolvedTypes[nodeIndex]))
                {
                    throw new InvalidOperationException(
                        $"Enumeration catalog node {nodeIndex} has incompatible resolved CUDA type authority.");
                }
                requiredElements = Math.Max(
                    requiredElements,
                    candidateLayout.Capacities[nodeIndex]);
            }

            var outputIndex = candidatePlan.Count - 1;
            ValidateObjective(
                definition,
                candidateLayout.ResolvedTypes[outputIndex],
                candidateLayout.Capacities[outputIndex],
                new MathBlockCudaShapeAuthority(
                    candidateLayout.ShapeRows[outputIndex],
                    candidateLayout.ShapeColumns[outputIndex]));
            rejectionReason = null;
            return true;
        }
        catch (Exception exception) when (exception is
            InvalidOperationException or OverflowException or NotSupportedException)
        {
            requiredElements = 0;
            rejectionReason = exception.Message;
            return false;
        }
    }

    public static IReadOnlyList<MathBlockProgramPopulationResourceBand> Plan(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramPopulationEnumerationCatalog catalog)
    {
        var requiredByOperationCount = new Dictionary<int, int>();
        for (var programIndex = 0; programIndex < catalog.Programs.Count; programIndex++)
        {
            var structure = catalog.Programs[programIndex];
            population.ValidateResidentStructure(structure);
            var plan = BuildPlan(population, structure);
            MathBlocksCUDAProgram.ValidateProgram(plan);
            var layout = MathBlocksCUDAProgram.ResolvePayloadLayout(plan, null);
            var operationCount = checked(structure.Nodes.Count - population.AllTerminals.Count);
            var requiredElements = 1;
            for (var nodeIndex = population.AllTerminals.Count;
                nodeIndex < plan.Count;
                nodeIndex++)
            {
                if (!structure.Nodes[nodeIndex].Type.Accepts(plan[nodeIndex].Type))
                {
                    throw new InvalidOperationException(
                        $"Enumeration catalog program {programIndex} has incompatible resolved CUDA type authority at node {nodeIndex}.");
                }
                requiredElements = Math.Max(requiredElements, layout.Capacities[nodeIndex]);
            }
            if (!requiredByOperationCount.TryGetValue(operationCount, out var current) ||
                requiredElements > current)
            {
                requiredByOperationCount[operationCount] = requiredElements;
            }
        }

        var result = new MathBlockProgramPopulationResourceBand[requiredByOperationCount.Count];
        var resultIndex = 0;
        foreach (var requirement in requiredByOperationCount)
        {
            result[resultIndex++] = new MathBlockProgramPopulationResourceBand(
                requirement.Key,
                requirement.Value);
        }
        MathBlockCollectionPrimitives.StableMergeSort(
            result,
            (left, right) => left.OperationCount.CompareTo(right.OperationCount));
        return Array.AsReadOnly(result);
    }

    public static void RequireResourceBands(
        MathBlockProgramPopulationSearchDefinition definition)
    {
        var population = definition.Population;
        var catalog = definition.EnumerationCatalog ??
            throw new ArgumentException("A catalog is required.", nameof(definition));
        var requiredByOperationCount = new Dictionary<int, int>();
        foreach (var structure in catalog.Programs)
        {
            if (!TryAnalyzeProgram(definition, structure, out var requiredElements, out _))
                continue;
            var operationCount = checked(structure.Nodes.Count - population.AllTerminals.Count);
            if (!requiredByOperationCount.TryGetValue(operationCount, out var current) ||
                requiredElements > current)
            {
                requiredByOperationCount[operationCount] = requiredElements;
            }
        }
        foreach (var requirementPair in requiredByOperationCount)
        {
            var requirement = new MathBlockProgramPopulationResourceBand(
                requirementPair.Key,
                requirementPair.Value);
            MathBlockProgramPopulationResourceBand? active = null;
            for (var bandIndex = 0; bandIndex < population.ActiveResourceBands.Count; bandIndex++)
            {
                var band = population.ActiveResourceBands[bandIndex];
                if (band.OperationCount == requirement.OperationCount)
                {
                    active = band;
                    break;
                }
            }
            if (!active.HasValue ||
                active.Value.MaximumOutputElements < requirement.MaximumOutputElements)
            {
                throw new InvalidOperationException(
                    $"The enumeration catalog requires at least {requirement.MaximumOutputElements} output elements for operation count {requirement.OperationCount}.");
            }
        }
    }

    private static void ValidateObjective(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockType candidateType,
        int candidateCapacity,
        MathBlockCudaShapeAuthority candidateShape)
    {
        var binding = definition.ObjectiveBinding;
        if (!binding.Program.Inputs[binding.CandidateInput].Accepts(candidateType))
            throw new InvalidOperationException("The resolved candidate type is incompatible with the objective input.");
        var capacities = new Dictionary<string, int>(StringComparer.Ordinal)
        {
            [binding.CandidateInput] = candidateCapacity
        };
        var shapes = new Dictionary<string, MathBlockCudaShapeAuthority>(StringComparer.Ordinal)
        {
            [binding.CandidateInput] = candidateShape
        };
        if (binding.CandidateValidityMaskInput is not null)
        {
            capacities.Add(binding.CandidateValidityMaskInput, definition.Validity.HistoryCounts.Count);
            shapes.Add(
                binding.CandidateValidityMaskInput,
                new MathBlockCudaShapeAuthority(definition.Validity.HistoryCounts.Count, 0));
        }
        _ = MathBlocksCUDAProgram.ResolvePayloadLayout(
            binding.Program.PlanNodes,
            binding.ResidentInputs,
            capacities,
            shapes,
            CreateObjectiveActiveNodes(binding));
    }

    private static bool[] CreateObjectiveActiveNodes(
        MathBlockProgramPopulationObjectiveBinding binding)
    {
        var plan = binding.Program.PlanNodes;
        var active = new bool[plan.Count];
        var stack = new Stack<int>();
        foreach (var objective in binding.Objectives)
        {
            if (objective.SourceKind == MathBlockProgramPopulationObjectiveSourceKind.ProgramOutput)
                stack.Push(binding.Program.OutputNodeIndexes[objective.ProgramOutput!]);
        }
        while (stack.Count != 0)
        {
            var nodeIndex = stack.Pop();
            if (active[nodeIndex])
                continue;
            active[nodeIndex] = true;
            foreach (var input in plan[nodeIndex].Inputs)
                stack.Push(input);
        }
        for (var nodeIndex = 0; nodeIndex < plan.Count; nodeIndex++)
        {
            var node = plan[nodeIndex];
            if (node.Kind == MathBlockProgramNodeKind.Input &&
                string.Equals(node.Name, binding.CandidateInput, StringComparison.Ordinal))
            {
                active[nodeIndex] = true;
                break;
            }
        }
        return active;
    }

    private static void CountProgramAuthorities(
        MathBlockProgramPopulationSearchDefinition definition,
        MathBlockProgramStructure structure,
        ref int liveNodes,
        ref int constantFolds,
        ref int commonSubexpressions,
        HashSet<string> expressions)
    {
        liveNodes = checked(liveNodes + structure.Nodes.Count);
        foreach (var node in structure.Nodes)
        {
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
                continue;
            var key = string.Concat(
                node.OperationIdentifier,
                "@",
                node.OperationVersion.ToString(System.Globalization.CultureInfo.InvariantCulture),
                ":",
                string.Join(",", node.OperandIndexes));
            if (!expressions.Add(key))
                commonSubexpressions++;
        }
        var objectiveActive = CreateObjectiveActiveNodes(definition.ObjectiveBinding);
        var objectivePlan = definition.ObjectiveBinding.Program.PlanNodes;
        var objectiveSources = new int[objectivePlan.Count];
        var objectiveFolded = new bool[objectivePlan.Count];
        var objectiveExpressions = new Dictionary<string, int>(StringComparer.Ordinal);
        for (var nodeIndex = 0; nodeIndex < objectiveActive.Length; nodeIndex++)
        {
            objectiveSources[nodeIndex] = nodeIndex;
            if (!objectiveActive[nodeIndex])
                continue;
            liveNodes++;
            var node = objectivePlan[nodeIndex];
            if (node.Kind == MathBlockProgramNodeKind.Operation &&
                node.Type.Kind is MathBlockValueKind.Scalar or
                    MathBlockValueKind.Boolean or
                    MathBlockValueKind.Complex)
            {
                var allConstants = true;
                foreach (var input in node.Inputs)
                {
                    var producer = objectivePlan[input];
                    if (producer.Kind != MathBlockProgramNodeKind.Constant &&
                        !objectiveFolded[input])
                    {
                        allConstants = false;
                        break;
                    }
                }
                if (allConstants)
                {
                    constantFolds++;
                    objectiveFolded[nodeIndex] = true;
                    continue;
                }
            }
            if (node.Kind == MathBlockProgramNodeKind.Operation)
            {
                var builder = new System.Text.StringBuilder(node.OperationIdentity);
                builder.Append(':');
                for (var inputIndex = 0; inputIndex < node.Inputs.Count; inputIndex++)
                {
                    if (inputIndex != 0)
                        builder.Append(',');
                    builder.Append(objectiveSources[node.Inputs[inputIndex]]);
                }
                var key = builder.ToString();
                if (objectiveExpressions.TryGetValue(key, out var source))
                {
                    commonSubexpressions++;
                    objectiveSources[nodeIndex] = source;
                }
                else
                {
                    objectiveExpressions.Add(key, nodeIndex);
                }
            }
        }
    }

    internal static IReadOnlyList<MathBlockProgramNode> BuildPlan(
        MathBlockProgramPopulationDefinition population,
        MathBlockProgramStructure structure)
    {
        var registry = MathBlockCatalog.Standard;
        var plan = new MathBlockProgramNode[structure.Nodes.Count];
        for (var nodeIndex = 0; nodeIndex < structure.Nodes.Count; nodeIndex++)
        {
            var node = structure.Nodes[nodeIndex];
            if (node.Kind == MathBlockProgramCandidateNodeKind.Terminal)
            {
                var terminal = population.AllTerminals[node.TerminalIndex];
                plan[nodeIndex] = new MathBlockProgramNode(
                    nodeIndex,
                    new MathBlockProgram.Node(
                        MathBlockProgramBuilder.NodeDefinition.Constant(terminal.Value)));
                continue;
            }

            var operands = new int[node.OperandIndexes.Count];
            var inputTypes = new MathBlockType[node.OperandIndexes.Count];
            for (var operandIndex = 0; operandIndex < operands.Length; operandIndex++)
            {
                var producerIndex = node.OperandIndexes[operandIndex];
                operands[operandIndex] = producerIndex;
                inputTypes[operandIndex] = plan[producerIndex].Type;
            }
            var operation = registry.Get(node.OperationIdentifier!, node.OperationVersion);
            var outputType = operation.ResolveOutputType(inputTypes);
            if (!node.Type.Accepts(outputType))
            {
                throw new InvalidOperationException(
                    $"Enumeration catalog node {nodeIndex} has an incompatible declared type.");
            }
            plan[nodeIndex] = new MathBlockProgramNode(
                nodeIndex,
                new MathBlockProgram.Node(
                    MathBlockProgramBuilder.NodeDefinition.CreateOperation(
                        operation,
                        operands,
                        node.Type)));
        }
        return Array.AsReadOnly(plan);
    }
}

public sealed class MathBlocksCUDAProgram : IDisposable
{
    private const int SlotSize = 48;

    private readonly object stateLock = new();
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

    public string ProgramFingerprint => program.Fingerprint;
    public int OperationNodeCount { get; }
    public int MaximumParallelWidth { get; }
    public int GraphInstantiationCount => 1;
    public int GraphLaunchCount { get; private set; }
    public int SynchronizationCount { get; private set; }
    public int HostInputWriteCount { get; private set; }
    public int HostOutputReadCount { get; private set; }
    public int HostToDeviceTransferCount { get; private set; }
    public int DeviceToHostTransferCount { get; private set; }
    public int HostToDeviceBytesPerExecution => arenaSize;
    public int DeviceToHostBytesPerExecution => downloadArenaSize;
    public int CpuNodeDispatchCount => 0;

    internal static MathBlocksCUDAProgram Create(
        MathBlockProgram program,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs)
    {
        MathBlocksCudaNative.EnsureContext();
        ValidateProgram(program);

        var slotOffsets = new int[program.PlanNodes.Count];
        var payloadOffsets = CreateFilledIntArray(program.PlanNodes.Count, -1);
        var payloadLayout = ResolvePayloadLayout(program.PlanNodes, prototypeInputs);
        var payloadCapacities = payloadLayout.Capacities;
        var inputPointerOffsets = CreateFilledIntArray(program.PlanNodes.Count, -1);
        var scratchOffsets = CreateFilledIntArray(program.PlanNodes.Count, -1);
        var graphNodes = new IntPtr[program.PlanNodes.Count];
        var arguments = new List<KernelArgumentStorage>();

        var outputNodeIndexes = new bool[program.PlanNodes.Count];
        foreach (var outputNodeIndex in program.OutputNodeIndexes.Values)
            outputNodeIndexes[outputNodeIndex] = true;
        var arenaSize = 0;
        void AllocateNode(MathBlockProgramNode node)
        {
            slotOffsets[node.Index] = AlignArenaOffset(arenaSize);
            arenaSize = checked(slotOffsets[node.Index] + SlotSize);
            var payloadBytes = ResolvePayloadBytes(
                payloadLayout.ResolvedTypes[node.Index].Kind,
                payloadCapacities[node.Index]);
            if (payloadBytes == 0)
                return;
            payloadOffsets[node.Index] = AlignArenaOffset(arenaSize);
            arenaSize = checked(payloadOffsets[node.Index] + payloadBytes);
        }

        foreach (var node in program.PlanNodes)
            if (!outputNodeIndexes[node.Index])
                AllocateNode(node);
        foreach (var node in program.PlanNodes)
        {
            if (node.Kind != MathBlockProgramNodeKind.Operation)
                continue;
            inputPointerOffsets[node.Index] = AlignArenaOffset(arenaSize);
            arenaSize = checked(inputPointerOffsets[node.Index] + node.Inputs.Count * sizeof(ulong));
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
            scratchOffsets[node.Index] = AlignArenaOffset(arenaSize);
            arenaSize = checked(scratchOffsets[node.Index] + scratchBytes);
        }
        var downloadArenaOffset = AlignArenaOffset(arenaSize);
        arenaSize = downloadArenaOffset;
        foreach (var node in program.PlanNodes)
            if (outputNodeIndexes[node.Index])
                AllocateNode(node);
        arenaSize = AlignArenaOffset(arenaSize);
        var downloadArenaSize = checked(arenaSize - downloadArenaOffset);

        var deviceArena = 0ul;
        var uploadArena = IntPtr.Zero;
        var downloadArena = IntPtr.Zero;
        var stream = IntPtr.Zero;
        var graph = IntPtr.Zero;
        var executable = IntPtr.Zero;
        try
        {
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAlloc(out deviceArena, new UIntPtr(checked((uint)arenaSize))),
                "cuMemAlloc(mathblocks arena)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(out uploadArena, new UIntPtr(checked((uint)arenaSize))),
                "cuMemAllocHost(mathblocks upload arena)");
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuMemAllocHost(
                    out downloadArena,
                    new UIntPtr(checked((uint)downloadArenaSize))),
                "cuMemAllocHost(mathblocks download arena)");
            ClearArena(uploadArena, arenaSize);
            ClearArena(downloadArena, downloadArenaSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuStreamCreate(out stream, 1),
                "cuStreamCreate(mathblocks)");
            foreach (var node in program.PlanNodes)
            {
                var payloadPointer = payloadOffsets[node.Index] < 0
                    ? 0ul
                    : checked(deviceArena + (ulong)payloadOffsets[node.Index]);
                var scratchPointer = scratchOffsets[node.Index] < 0
                    ? 0ul
                    : checked(deviceArena + (ulong)scratchOffsets[node.Index]);
                WriteHeader(
                    uploadArena,
                    slotOffsets[node.Index],
                    payloadPointer,
                    scratchPointer,
                    payloadCapacities[node.Index],
                    payloadLayout.ResolvedTypes[node.Index],
                    valid: false);
                if (node.Kind == MathBlockProgramNodeKind.Constant)
                {
                    WriteValue(
                        uploadArena,
                        slotOffsets[node.Index],
                        payloadOffsets[node.Index],
                        payloadPointer,
                        scratchPointer,
                        payloadCapacities[node.Index],
                        node.Value);
                }
                else if (node.Kind == MathBlockProgramNodeKind.Input &&
                         prototypeInputs is not null &&
                         prototypeInputs.TryGetValue(node.Name!, out var prototype))
                {
                    WriteValue(
                        uploadArena,
                        slotOffsets[node.Index],
                        payloadOffsets[node.Index],
                        payloadPointer,
                        scratchPointer,
                        payloadCapacities[node.Index],
                        prototype);
                }
            }
            foreach (var node in program.PlanNodes)
            {
                if (node.Kind != MathBlockProgramNodeKind.Operation)
                    continue;
                WriteInputPointers(
                    uploadArena,
                    inputPointerOffsets[node.Index],
                    deviceArena,
                    slotOffsets,
                    node.Inputs);
            }

            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphCreate(out graph, 0),
                "cuGraphCreate(mathblocks)");
            var uploadCopy = MathBlocksCudaNative.MemoryCopy3D.HostToDevice(
                uploadArena,
                deviceArena,
                arenaSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddMemcpyNode(
                    out var uploadNode,
                    graph,
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
                var inputPointers = checked(deviceArena + (ulong)inputPointerOffsets[node.Index]);
                var output = checked(deviceArena + (ulong)slotOffsets[node.Index]);
                var storage = new KernelArgumentStorage(
                    kernel.Opcode,
                    inputPointers,
                    node.Inputs.Count,
                    output);
                arguments.Add(storage);
                var dependencies = CreateKernelDependencies(node.Inputs, graphNodes, uploadNode);
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
                        out graphNodes[node.Index],
                        graph,
                        dependencies.Length == 0 ? null : dependencies,
                        new UIntPtr((uint)dependencies.Length),
                        ref parameters),
                    $"cuGraphAddKernelNode({node.OperationIdentity})");
            }

            var terminalDependencies = CreateTerminalDependencies(graphNodes, uploadNode);
            var downloadCopy = MathBlocksCudaNative.MemoryCopy3D.DeviceToHost(
                checked(deviceArena + (ulong)downloadArenaOffset),
                downloadArena,
                downloadArenaSize);
            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphAddMemcpyNode(
                    out _,
                    graph,
                    terminalDependencies,
                    new UIntPtr((uint)terminalDependencies.Length),
                    ref downloadCopy,
                    MathBlocksCudaNative.CurrentContext),
                "cuGraphAddMemcpyNode(mathblocks download)");

            MathBlocksCudaNative.ThrowIfFailed(
                MathBlocksCudaNative.cuGraphInstantiateWithFlags(out executable, graph, 0),
                "cuGraphInstantiate(mathblocks)");
            return new MathBlocksCUDAProgram(
                program,
                slotOffsets,
                payloadOffsets,
                payloadCapacities,
                payloadLayout.ResolvedTypes,
                inputPointerOffsets,
                graphNodes,
                arguments,
                arenaSize,
                downloadArenaOffset,
                downloadArenaSize,
                deviceArena,
                uploadArena,
                downloadArena,
                stream,
                graph,
                executable,
                InputsAreStaged(program, prototypeInputs));
        }
        catch
        {
            if (executable != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphExecDestroy(executable);
            if (graph != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuGraphDestroy(graph);
            if (stream != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuStreamDestroy(stream);
            foreach (var storage in arguments)
                storage.Dispose();
            if (deviceArena != 0ul)
                _ = MathBlocksCudaNative.cuMemFree(deviceArena);
            if (uploadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(uploadArena);
            if (downloadArena != IntPtr.Zero)
                _ = MathBlocksCudaNative.cuMemFreeHost(downloadArena);
            throw;
        }
    }

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
                WriteValue(
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
                    ReadValue(
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
            foreach (var storage in kernelArguments)
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
        var resolvedTypes = new MathBlockType[nodes.Count];
        var published = new bool[nodes.Count];
        if (activeNodes is not null && activeNodes.Count != nodes.Count)
            throw new ArgumentException("The CUDA active-node count is inconsistent.", nameof(activeNodes));
        foreach (var node in nodes)
        {
            if ((uint)node.Index >= (uint)nodes.Count || published[node.Index])
                throw new InvalidOperationException($"CUDA payload node index {node.Index} is invalid.");

            if (activeNodes is not null && !activeNodes[node.Index])
            {
                resolvedTypes[node.Index] = node.Type;
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
                inputTypes[inputIndex] = resolvedTypes[producerIndex];
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
                    inputShapeColumns,
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
            resolvedTypes[node.Index] = resolvedType;
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
            resolvedTypes);
    }

    private static IntPtr[] CreateKernelDependencies(
        IReadOnlyList<int> inputs,
        IReadOnlyList<IntPtr> graphNodes,
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
        IReadOnlyList<IntPtr> graphNodes,
        IntPtr uploadNode)
    {
        var values = new IntPtr[graphNodes.Count + 1];
        var count = 0;
        for (var index = 0; index < graphNodes.Count; index++)
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

    private static bool ContainsKind(IReadOnlyList<MathBlockValueKind> values, MathBlockValueKind value)
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

    private static void ValidateStaticOperation(
        MathBlockProgramNode node,
        IReadOnlyList<int> inputCapacities,
        IReadOnlyList<int> inputShapeRows,
        IReadOnlyList<int> inputShapeColumns,
        IReadOnlyList<MathBlockValue?> inputExactValues)
    {
        var identity = node.OperationIdentity!;
        if (identity == "sequence.difference@1" &&
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
        if (identity == "sequence.rolling-quantile@1" &&
            TryGetExactScalar(inputExactValues, 2, out var rollingProbability))
        {
            RequireDomain(
                rollingProbability is >= 0d and <= 1d,
                node,
                "rolling probability");
        }
        if (identity == "sequence.exponential-moving-average@1" &&
            TryGetExactScalar(inputExactValues, 1, out var alpha))
        {
            RequireDomain(alpha is > 0d and <= 1d, node, "smoothing input");
        }
        if (identity == "vector.quantile@1" &&
            TryGetExactScalar(inputExactValues, 1, out var probability))
        {
            RequireDomain(probability is >= 0d and <= 1d, node, "probability");
            RequireDomain(inputCapacities[0] > 0, node, "vector length");
        }
        if (identity is "vector.repeat@1" or "vector.linspace@1")
        {
            var countInput = identity == "vector.repeat@1" ? 1 : 2;
            if (TryGetExactInteger(inputExactValues, countInput, out var count))
            {
                var minimum = identity == "vector.repeat@1" ? 0 : 1;
                RequireDomain(count >= minimum && count <= 1_000_000, node, "output length");
            }
        }
        if (identity == "vector.slice@1" &&
            TryGetExactInteger(inputExactValues, 1, out var start) &&
            TryGetExactInteger(inputExactValues, 2, out var length))
        {
            var count = RequireInputShapeRows(node, 0, inputShapeRows);
            RequireDomain(start >= 0 && length >= 0 && start <= count && length <= count - start,
                node,
                "slice");
        }
        if (identity == "matrix.identity@1" &&
            TryGetExactInteger(inputExactValues, 0, out var matrixSize))
        {
            RequireDomain(matrixSize > 0 && matrixSize <= 4096, node, "matrix size");
        }
        if (identity == "matrix.reshape@1" &&
            TryGetExactInteger(inputExactValues, 1, out var rows) &&
            TryGetExactInteger(inputExactValues, 2, out var columns))
        {
            RequireDomain(
                rows > 0 && columns > 0 && checked((long)rows * columns) == inputCapacities[0],
                node,
                "matrix shape");
        }
        if (identity == "matrix.schur-complement@1" &&
            TryGetExactInteger(inputExactValues, 1, out var retained))
        {
            var matrixRows = RequireInputShapeRows(node, 0, inputShapeRows);
            RequireDomain(retained > 0 && retained < matrixRows, node, "retained size");
        }
        if (identity == "statistics.autocorrelation@1" &&
            TryGetExactInteger(inputExactValues, 1, out var correlationLag))
        {
            RequireDomain(
                correlationLag > 0 && correlationLag < inputCapacities[0],
                node,
                "correlation lag");
        }
        if (identity == "state.transition-counts@1" &&
            TryGetExactInteger(inputExactValues, 1, out var stateCount))
        {
            RequireDomain(stateCount > 0, node, "state count");
        }
        if (identity == "information.conditional-mutual-information@1" &&
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
        if (identity == "graph.undirected-shortest-paths@1" &&
            TryGetExactInteger(inputExactValues, 1, out var source))
        {
            RequireDomain(
                source >= 0 && source < RequireInputShapeRows(node, 0, inputShapeRows),
                node,
                "graph source");
        }
        if (identity == "path.recurrence-rate@1" &&
            TryGetExactScalar(inputExactValues, 1, out var threshold))
        {
            RequireDomain(inputCapacities[0] > 0 && threshold >= 0d, node, "recurrence threshold");
        }
        if (identity == "path.hysteresis@1" &&
            TryGetExactScalar(inputExactValues, 1, out var lower) &&
            TryGetExactScalar(inputExactValues, 2, out var upper))
        {
            RequireDomain(lower < upper, node, "hysteresis thresholds");
        }
        if (identity == "polynomial.bernstein-evaluate@1" &&
            TryGetExactScalar(inputExactValues, 1, out var bernsteinInput))
        {
            RequireDomain(
                inputCapacities[0] > 0 && bernsteinInput is >= 0d and <= 1d,
                node,
                "Bernstein input");
        }
        if (identity == "polynomial.elementary-symmetric@1" &&
            TryGetExactInteger(inputExactValues, 1, out var order))
        {
            RequireDomain(order >= 0 && order <= inputCapacities[0], node, "polynomial order");
        }
        if (identity == "transport.uniform-wasserstein@1" &&
            TryGetExactScalar(inputExactValues, 2, out var transportOrder))
        {
            RequireDomain(inputCapacities[0] > 0 && transportOrder >= 1d, node, "transport order");
        }
        if (identity == "special.regularized-incomplete-beta@1" &&
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

    private static MathBlockValue? ResolveExactValue(
        MathBlockProgramNode node,
        IReadOnlyDictionary<string, MathBlockValue>? prototypeInputs,
        IReadOnlyList<MathBlockValue?> inputExactValues)
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
        var inputs = new MathBlockValue[inputExactValues.Count];
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

    private static bool IsRollingIdentity(string identity) => identity is
        "sequence.rolling-maximum@1" or
        "sequence.rolling-mean@1" or
        "sequence.rolling-median@1" or
        "sequence.rolling-minimum@1" or
        "sequence.rolling-quantile@1" or
        "sequence.rolling-standard-deviation@1" or
        "sequence.rolling-sum@1" or
        "sequence.rolling-variance@1";

    private static bool HasRuntimeShape(string? identity) => identity is
        "sequence.difference@1" or
        "sequence.rolling-maximum@1" or
        "sequence.rolling-mean@1" or
        "sequence.rolling-median@1" or
        "sequence.rolling-minimum@1" or
        "sequence.rolling-quantile@1" or
        "sequence.rolling-standard-deviation@1" or
        "sequence.rolling-sum@1" or
        "sequence.rolling-variance@1" or
        "vector.linspace@1" or
        "vector.repeat@1" or
        "vector.slice@1" or
        "vector.concatenate@1";

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

    private static int ResolvePayloadCapacity(
        MathBlockProgramNode node,
        IReadOnlyList<MathBlockProgramNode> nodes,
        IReadOnlyList<int> inputCapacities,
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
            return ValueElementCount(node.Value);
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
            return ValueElementCount(prototype);
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
            if (identity == "matrix.identity@1")
            {
                var size = ResolvePrototypeCount(nodes[node.Inputs[0]], prototypeInputs);
                return checked(size * size);
            }
            if (identity == "matrix.append-row@1")
            {
                return checked(
                    inputCapacities[0] +
                    inputCapacities[1]);
            }
            if (identity is "matrix.diagonal-from-vector@1")
            {
                var size = inputCapacities[0];
                return checked(size * size);
            }
            if (identity is "matrix.gram@1")
            {
                var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(columns * columns);
            }
            if (identity is "matrix.hankel@1" or "matrix.toeplitz@1" or
                "matrix.outer-product@1")
            {
                return checked(
                    inputCapacities[0] *
                    inputCapacities[1]);
            }
            if (identity == "matrix.stack-rows@1")
                return checked(inputCapacities[0] + inputCapacities[1]);
            if (identity == "complex-matrix.pick@1")
                return checked(inputCapacities[0] * inputCapacities[1]);
            if (identity == "matrix.kronecker-product@1")
            {
                return checked(
                    inputCapacities[0] *
                    inputCapacities[1]);
            }
            if (identity is "matrix.multiply@1" or "matrix.commutator@1")
            {
                return checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) *
                    RequireInputShapeColumns(node, 1, inputShapeColumns));
            }
            if (identity == "matrix.reshape@1")
                return inputCapacities[0];
            if (identity == "matrix.principal-minors@1")
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                if (rows < 0 || rows > 20)
                    throw new InvalidOperationException("CUDA principal-minor shape is outside the operation domain.");
                return checked((1 << rows) - 1);
            }
            if (identity == "matrix.maximal-minors@1")
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return BinomialCoefficient(columns, Math.Min(rows, columns / 2));
            }
            if (identity == "matrix.schur-complement@1")
            {
                var retained = ResolvePrototypeCount(nodes[node.Inputs[1]], prototypeInputs);
                return checked(retained * retained);
            }
            if (identity == "combinatorics.nonempty-subset-sums@1")
            {
                var count = inputCapacities[0];
                if (count < 0 || count > 20)
                    throw new InvalidOperationException("CUDA subset-sum shape is outside the operation domain.");
                return checked((1 << count) - 1);
            }
            if (identity == "sequence.convolution@1")
            {
                var left = inputCapacities[0];
                var right = inputCapacities[1];
                return left == 0 || right == 0 ? 0 : checked(left + right - 1);
            }
            if (identity is "sequence.difference@1" or
                "sequence.rolling-maximum@1" or
                "sequence.rolling-mean@1" or
                "sequence.rolling-median@1" or
                "sequence.rolling-minimum@1" or
                "sequence.rolling-quantile@1" or
                "sequence.rolling-standard-deviation@1" or
                "sequence.rolling-sum@1" or
                "sequence.rolling-variance@1")
            {
                if (TryGetExactNonnegativeInteger(inputExactValues, 1, out var parameter))
                {
                    var inputCount = RequireInputShapeRows(node, 0, inputShapeRows);
                    return identity == "sequence.difference@1"
                        ? checked(inputCount - parameter)
                        : checked(inputCount - parameter + 1);
                }
                return inputCapacities[0];
            }
            if (identity == "path.lead-lag-transform@1")
            {
                var count = inputCapacities[0];
                return count == 0 ? 0 : checked((2 * count - 1) * 2);
            }
            if (identity == "path.run-length-encode@1")
                return inputCapacities[0];
            if (identity == "path.signature-level-one@1")
                return RequireInputShapeColumns(node, 0, inputShapeColumns);
            if (identity == "path.signature-level-two@1")
            {
                var dimension = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(dimension * dimension);
            }
            if (identity == "path.signature-level-three@1")
            {
                var dimension = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(dimension * dimension * dimension);
            }
            if (identity == "state.transition-counts@1")
            {
                var count = ResolvePrototypeCount(nodes[node.Inputs[1]], prototypeInputs);
                return checked(count * count);
            }
            if (identity == "statistics.covariance-matrix@1")
            {
                var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
                return checked(columns * columns);
            }
            if (identity == "statistics.histogram@1")
                return checked(inputCapacities[1] + 1);
            if (identity == "geometry.barycentric-coordinates@1")
                return 3;
            if (identity == "geometry.centroid@1")
                return 1;
            if (identity == "geometry.convex-hull@1")
                return inputCapacities[0];
            if (identity is "geometry.delaunay-graph@1" or "geometry.gabriel-graph@1")
            {
                var count = inputCapacities[0];
                return checked(count * (count - 1) / 2);
            }
            if (identity == "topology.zero-dimensional-persistence@1")
            {
                var count = inputCapacities[0];
                return count == 0 ? 0 : count - 1;
            }
            if (identity == "point-set.from-matrix@1")
                return RequireInputShapeRows(node, 0, inputShapeRows);
            if (identity == "point-set.to-matrix@1")
                return checked(inputCapacities[0] * 2);
            if (identity == "graph.from-directed-adjacency@1")
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                return checked(rows * (rows - 1));
            }
            if (identity == "graph.minimum-spanning-forest@1")
                return inputCapacities[0];
            if (identity is "graph.degree@1" or
                "graph.hodge-potential@1" or
                "graph.page-rank@1" or
                "graph.undirected-shortest-paths@1" or
                "graph.weighted-degree@1")
            {
                return RequireInputShapeRows(node, 0, inputShapeRows);
            }
            if (identity is "graph.to-directed-adjacency@1" or
                "graph.undirected-adjacency-matrix@1" or
                "graph.undirected-laplacian@1")
            {
                var rows = RequireInputShapeRows(node, 0, inputShapeRows);
                return checked(rows * rows);
            }
            if (identity == "cooperative.shapley-values@1")
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
            if (identity is "extension.mcshane@1" or "extension.whitney@1")
                return inputCapacities[2];
            if (identity == "inequality.lorenz-curve@1")
                return checked(inputCapacities[0] + 1);
            if (identity == "markov.stationary-distribution@1")
                return RequireInputShapeRows(node, 0, inputShapeRows);
            if (identity == "transport.minimum-assignment@1")
                return RequireInputShapeRows(node, 0, inputShapeRows);
            if (identity == "transport.monotone-coupling@1")
            {
                return checked(
                    inputCapacities[0] *
                    inputCapacities[1]);
            }
            if (identity == "transport.sinkhorn-coupling@1")
                return inputCapacities[0];
            if (identity is "tropical.max-plus-multiply@1" or "tropical.min-plus-multiply@1")
            {
                return checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) *
                    RequireInputShapeColumns(node, 1, inputShapeColumns));
            }
            if (identity == "vector.pair@1")
                return 2;
            if (identity is "vector.append@1" or "vector.prepend@1")
                return checked(inputCapacities[0] + 1);
            if (identity == "vector.concatenate@1")
            {
                return checked(
                    inputCapacities[0] +
                    inputCapacities[1]);
            }
            if (identity == "vector.linspace@1")
                return ResolveExactCount(node, 2, inputExactValues, nodes, prototypeInputs);
            if (identity == "vector.repeat@1")
                return ResolveExactCount(node, 1, inputExactValues, nodes, prototypeInputs);
            if (identity == "vector.slice@1")
                return ResolveExactCount(node, 2, inputExactValues, nodes, prototypeInputs);
            if (identity == "vector.gather@1")
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
        if (identity is "matrix.gram@1" or "statistics.covariance-matrix@1")
        {
            var columns = RequireInputShapeColumns(node, 0, inputShapeColumns);
            return new MathBlockCudaShapeAuthority(columns, columns);
        }
        if (identity == "matrix.transpose@1")
        {
            return new MathBlockCudaShapeAuthority(
                RequireInputShapeColumns(node, 0, inputShapeColumns),
                RequireInputShapeRows(node, 0, inputShapeRows));
        }
        if (identity is "matrix.multiply@1" or "matrix.commutator@1" or
            "tropical.max-plus-multiply@1" or "tropical.min-plus-multiply@1")
        {
            return new MathBlockCudaShapeAuthority(
                RequireInputShapeRows(node, 0, inputShapeRows),
                RequireInputShapeColumns(node, 1, inputShapeColumns));
        }
        if (identity == "matrix.append-row@1")
        {
            return new MathBlockCudaShapeAuthority(
                checked(RequireInputShapeRows(node, 0, inputShapeRows) + 1),
                RequireInputShapeColumns(node, 0, inputShapeColumns));
        }
        if (identity == "matrix.diagonal-from-vector@1")
            return new MathBlockCudaShapeAuthority(inputCapacities[0], inputCapacities[0]);
        if (identity is "matrix.hankel@1" or "matrix.toeplitz@1" or "matrix.outer-product@1")
            return new MathBlockCudaShapeAuthority(inputCapacities[0], inputCapacities[1]);
        if (identity == "matrix.stack-rows@1")
            return new MathBlockCudaShapeAuthority(2, Math.Max(inputCapacities[0], inputCapacities[1]));
        if (identity == "complex-matrix.pick@1")
        {
            var dimension = Math.Min(inputCapacities[0], inputCapacities[1]);
            return new MathBlockCudaShapeAuthority(dimension, dimension);
        }
        if (identity == "matrix.kronecker-product@1")
        {
            return new MathBlockCudaShapeAuthority(
                checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) *
                    RequireInputShapeRows(node, 1, inputShapeRows)),
                checked(
                    RequireInputShapeColumns(node, 0, inputShapeColumns) *
                    RequireInputShapeColumns(node, 1, inputShapeColumns)));
        }
        if (identity == "path.lead-lag-transform@1")
        {
            var count = inputCapacities[0];
            return new MathBlockCudaShapeAuthority(count == 0 ? 0 : checked(2 * count - 1), 2);
        }
        if (identity == "sequence.difference@1" &&
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
        if (identity == "vector.concatenate@1")
        {
            return new MathBlockCudaShapeAuthority(
                checked(
                    RequireInputShapeRows(node, 0, inputShapeRows) +
                    RequireInputShapeRows(node, 1, inputShapeRows)),
                0);
        }
        if (identity is "vector.linspace@1" or "vector.repeat@1")
        {
            var countInput = identity == "vector.linspace@1" ? 2 : 1;
            if (TryGetExactNonnegativeInteger(inputExactValues, countInput, out var count))
                return new MathBlockCudaShapeAuthority(count, 0);
        }
        if (identity == "vector.slice@1" &&
            TryGetExactNonnegativeInteger(inputExactValues, 2, out var length))
        {
            return new MathBlockCudaShapeAuthority(length, 0);
        }
        if (identity == "point-set.to-matrix@1")
            return new MathBlockCudaShapeAuthority(inputCapacities[0], 2);
        if (identity is "graph.to-directed-adjacency@1" or
            "graph.undirected-adjacency-matrix@1" or "graph.undirected-laplacian@1")
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

    private static unsafe int ResolvePayloadBytes(MathBlockValueKind kind, int capacity)
    {
        if (capacity == 0)
            return 0;
        return kind switch
        {
            MathBlockValueKind.Scalar or MathBlockValueKind.Boolean or MathBlockValueKind.Vector or
                MathBlockValueKind.Matrix => checked(capacity * sizeof(double)),
            MathBlockValueKind.BooleanVector => checked(capacity * sizeof(int)),
            MathBlockValueKind.Complex or MathBlockValueKind.ComplexVector or
                MathBlockValueKind.ComplexMatrix or MathBlockValueKind.PointSet =>
                checked(capacity * 2 * sizeof(double)),
            MathBlockValueKind.Graph => checked(capacity * sizeof(MathBlockCudaGraphEdge)),
            MathBlockValueKind.RunSet => checked(capacity * sizeof(MathBlockCudaRun)),
            _ => throw new NotSupportedException($"The CUDA value ABI does not support '{kind}'.")
        };
    }

    private static int ValueElementCount(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
        MathBlockValueKind.Complex => 1,
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        MathBlockValueKind.Matrix => checked(value.AsMatrix().Rows * value.AsMatrix().Columns),
        MathBlockValueKind.ComplexVector => value.AsComplexVector().Count,
        MathBlockValueKind.ComplexMatrix => checked(
            value.AsComplexMatrix().Rows * value.AsComplexMatrix().Columns),
        MathBlockValueKind.PointSet => value.AsPointSet().Count,
        MathBlockValueKind.Graph => value.AsGraph().Count,
        MathBlockValueKind.RunSet => value.AsRunSet().Count,
        _ => throw new NotSupportedException($"The CUDA value ABI does not support '{value.Type.Kind}'.")
    };

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
        if ((node.OperationIdentity is
                "sequence.rolling-median@1" or
                "sequence.rolling-quantile@1") &&
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
                if (node.OperationIdentity == "sequence.rolling-quantile@1" &&
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
        IReadOnlyList<MathBlockType> inputTypes,
        IReadOnlyList<int> inputCapacities,
        IReadOnlyList<int> inputShapeRows,
        IReadOnlyList<int> inputShapeColumns)
    {
        if (inputTypes.Count != inputCapacities.Count ||
            inputTypes.Count != inputShapeRows.Count ||
            inputTypes.Count != inputShapeColumns.Count)
        {
            throw new ArgumentException("CUDA scratch input metadata is inconsistent.");
        }
        if (identity is "sequence.rolling-median@1" or "sequence.rolling-quantile@1")
        {
            return inputCapacities.Count == 0
                ? 0
                : ResolveRollingOrderStatisticScratchBytes(
                    inputCapacities[0],
                    inputCapacities[0]);
        }
        if (inputTypes.Count != 0)
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
        for (var index = 0; index < inputTypes.Count; index++)
        {
            var inputBytes = ResolvePayloadBytes(inputTypes[index].Kind, inputCapacities[index]);
            if (inputBytes > bytes)
                bytes = inputBytes;
        }
        return bytes;
    }

    private static bool RequiresScratchRows(string identity) => identity is
        "matrix.solve@1" or
        "matrix.inverse@1" or
        "matrix.symmetric-eigenvalues@1" or
        "matrix.smallest-symmetric-eigenvalue@1" or
        "matrix.largest-symmetric-eigenvalue@1" or
        "matrix.perron-vector@1" or
        "matrix.perron-value@1" or
        "information.mutual-information@1" or
        "graph.algebraic-connectivity@1" or
        "graph.connected-component-count@1" or
        "graph.is-connected@1" or
        "graph.hodge-potential@1" or
        "graph.minimum-spanning-forest@1" or
        "graph.page-rank@1" or
        "graph.triangle-count@1" or
        "graph.undirected-shortest-paths@1" or
        "markov.stationary-distribution@1" or
        "transport.minimum-assignment@1" or
        "transport.sinkhorn-coupling@1";

    private static bool RequiresScratchColumns(string identity) => identity is
        "matrix.spectral-norm@1" or
        "information.mutual-information@1" or
        "path.signature-level-two@1" or
        "path.signature-level-three@1" or
        "statistics.covariance-matrix@1" or
        "transport.sinkhorn-coupling@1";

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
        IReadOnlyList<int> slotOffsets,
        IReadOnlyList<int> inputs)
    {
        var destination = (ulong*)((byte*)arena + offset);
        for (var index = 0; index < inputs.Count; index++)
            destination[index] = checked(deviceArena + (ulong)slotOffsets[inputs[index]]);
    }

    private static unsafe void WriteHeader(
        IntPtr arena,
        int slotOffset,
        ulong payloadPointer,
        ulong scratchPointer,
        int capacity,
        MathBlockType type,
        bool valid)
    {
        var slot = new MathBlockCudaSlot
        {
            DataPointer = payloadPointer,
            ScratchPointer = scratchPointer,
            Valid = valid ? 1 : 0,
            Rows = type.Rows,
            Columns = type.Columns,
            Count = type.Kind is MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix &&
                    type.Rows > 0 &&
                    type.Columns > 0
                ? checked(type.Rows * type.Columns)
                : type.Kind == MathBlockValueKind.Complex
                    ? 1
                    : capacity,
            Capacity = capacity
        };
        *(MathBlockCudaSlot*)((byte*)arena + slotOffset) = slot;
    }

    private static unsafe void WriteValue(
        IntPtr arena,
        int slotOffset,
        int payloadOffset,
        ulong payloadPointer,
        ulong scratchPointer,
        int capacity,
        MathBlockValue value)
    {
        var count = value.IsValid ? ValueElementCount(value) : 0;
        if (count > capacity)
            throw new ArgumentException($"The CUDA input requires {count} elements, but its capacity is {capacity}.");
        var slot = new MathBlockCudaSlot
        {
            ScalarValue = value.IsValid && value.Type.Kind == MathBlockValueKind.Scalar ? value.AsScalar() : 0d,
            DataPointer = payloadPointer,
            ScratchPointer = scratchPointer,
            BooleanValue = value.IsValid && value.Type.Kind == MathBlockValueKind.Boolean && value.AsBoolean() ? 1 : 0,
            Valid = value.IsValid ? 1 : 0,
            Rows = ValueRows(value, count),
            Columns = ValueColumns(value),
            Count = count,
            Capacity = capacity
        };
        if (value.IsValid && count != 0)
        {
            if (payloadOffset < 0)
                throw new InvalidOperationException("The CUDA value has no payload allocation.");
            if (value.Type.Kind is MathBlockValueKind.Vector or MathBlockValueKind.Matrix)
            {
                var destination = (double*)((byte*)arena + payloadOffset);
                if (value.Type.Kind == MathBlockValueKind.Vector)
                {
                    var source = value.AsVector();
                    for (var index = 0; index < count; index++)
                        destination[index] = source[index];
                }
                else
                {
                    var source = value.AsMatrix();
                    var index = 0;
                    for (var row = 0; row < source.Rows; row++)
                    for (var column = 0; column < source.Columns; column++)
                        destination[index++] = source[row, column];
                }
            }
            else if (value.Type.Kind == MathBlockValueKind.BooleanVector)
            {
                var source = value.AsBooleanVector();
                var destination = (int*)((byte*)arena + payloadOffset);
                for (var index = 0; index < count; index++)
                    destination[index] = source[index] ? 1 : 0;
            }
            else if (value.Type.Kind == MathBlockValueKind.Complex)
            {
                var source = value.AsComplex();
                var destination = (double*)((byte*)arena + payloadOffset);
                destination[0] = source.Real;
                destination[1] = source.Imaginary;
            }
            else if (value.Type.Kind is MathBlockValueKind.ComplexVector or MathBlockValueKind.ComplexMatrix)
            {
                var destination = (double*)((byte*)arena + payloadOffset);
                if (value.Type.Kind == MathBlockValueKind.ComplexVector)
                {
                    var source = value.AsComplexVector();
                    for (var index = 0; index < count; index++)
                    {
                        destination[index * 2] = source[index].Real;
                        destination[index * 2 + 1] = source[index].Imaginary;
                    }
                }
                else
                {
                    var source = value.AsComplexMatrix();
                    var index = 0;
                    for (var row = 0; row < source.Rows; row++)
                    for (var column = 0; column < source.Columns; column++)
                    {
                        var item = source[row, column];
                        destination[index * 2] = item.Real;
                        destination[index * 2 + 1] = item.Imaginary;
                        index++;
                    }
                }
            }
            else if (value.Type.Kind == MathBlockValueKind.PointSet)
            {
                var source = value.AsPointSet();
                var destination = (double*)((byte*)arena + payloadOffset);
                for (var index = 0; index < count; index++)
                {
                    destination[index * 2] = source[index].X;
                    destination[index * 2 + 1] = source[index].Y;
                }
            }
            else if (value.Type.Kind == MathBlockValueKind.Graph)
            {
                var source = value.AsGraph();
                var destination = (MathBlockCudaGraphEdge*)((byte*)arena + payloadOffset);
                for (var index = 0; index < count; index++)
                {
                    destination[index] = new MathBlockCudaGraphEdge
                    {
                        From = source[index].From,
                        To = source[index].To,
                        Weight = source[index].Weight
                    };
                }
            }
            else if (value.Type.Kind == MathBlockValueKind.RunSet)
            {
                var source = value.AsRunSet();
                var destination = (MathBlockCudaRun*)((byte*)arena + payloadOffset);
                for (var index = 0; index < count; index++)
                {
                    destination[index] = new MathBlockCudaRun
                    {
                        Start = source[index].Start,
                        Length = source[index].Length,
                        Value = source[index].Value
                    };
                }
            }
        }
        *(MathBlockCudaSlot*)((byte*)arena + slotOffset) = slot;
    }

    private static unsafe MathBlockValue ReadValue(
        IntPtr arena,
        int slotOffset,
        int payloadOffset,
        MathBlockType type)
    {
        var slot = *(MathBlockCudaSlot*)((byte*)arena + slotOffset);
        if (slot.Valid == 0)
            return MathBlockValue.Invalid(type, "The CUDA result is invalid.");
        if (slot.Count < 0 || slot.Count > slot.Capacity)
            throw new InvalidOperationException("The CUDA result count exceeds its arena capacity.");
        return type.Kind switch
        {
            MathBlockValueKind.Scalar => MathBlockValue.Scalar(slot.ScalarValue, type.Unit),
            MathBlockValueKind.Boolean => MathBlockValue.Boolean(slot.BooleanValue != 0),
            MathBlockValueKind.Complex => MathBlockValue.Complex(
                ReadComplex(arena, payloadOffset),
                type.Unit),
            MathBlockValueKind.Vector => MathBlockValue.Vector(ReadDoubles(arena, payloadOffset, slot.Count), type.Unit),
            MathBlockValueKind.BooleanVector => MathBlockValue.BooleanVector(
                ReadBooleans(arena, payloadOffset, slot.Count)),
            MathBlockValueKind.Matrix => MathBlockValue.Matrix(
                new MathBlockMatrix(slot.Rows, slot.Columns, ReadDoubles(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.ComplexVector => MathBlockValue.ComplexVector(
                ReadComplexValues(arena, payloadOffset, slot.Count),
                type.Unit),
            MathBlockValueKind.ComplexMatrix => MathBlockValue.ComplexMatrix(
                new MathBlockComplexMatrix(
                    slot.Rows,
                    slot.Columns,
                    ReadComplexValues(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.PointSet => MathBlockValue.PointSet(
                new MathBlockPointSet(ReadPoints(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.Graph => MathBlockValue.Graph(
                new MathBlockGraph(slot.Rows, ReadGraphEdges(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.RunSet => MathBlockValue.RunSet(
                new MathBlockRunSet(ReadRuns(arena, payloadOffset, slot.Count)),
                type.Unit),
            _ => throw new InvalidOperationException($"Unsupported CUDA output kind '{type.Kind}'.")
        };
    }

    private static int ValueRows(MathBlockValue value, int count)
    {
        if (!value.IsValid)
            return value.Type.Rows;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Matrix => value.AsMatrix().Rows,
            MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Rows,
            MathBlockValueKind.Graph => value.AsGraph().VertexCount,
            MathBlockValueKind.Scalar or MathBlockValueKind.Boolean or MathBlockValueKind.Complex => 0,
            _ => count
        };
    }

    private static int ValueColumns(MathBlockValue value)
    {
        if (!value.IsValid)
            return value.Type.Columns;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Matrix => value.AsMatrix().Columns,
            MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Columns,
            _ => 0
        };
    }

    private static unsafe Complex ReadComplex(IntPtr arena, int payloadOffset)
    {
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        return new Complex(source[0], source[1]);
    }

    private static unsafe Complex[] ReadComplexValues(IntPtr arena, int payloadOffset, int count)
    {
        var values = new Complex[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new Complex(source[index * 2], source[index * 2 + 1]);
        return values;
    }

    private static unsafe MathBlockPoint[] ReadPoints(IntPtr arena, int payloadOffset, int count)
    {
        var values = new MathBlockPoint[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new MathBlockPoint(source[index * 2], source[index * 2 + 1]);
        return values;
    }

    private static unsafe MathBlockGraphEdge[] ReadGraphEdges(IntPtr arena, int payloadOffset, int count)
    {
        var values = new MathBlockGraphEdge[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (MathBlockCudaGraphEdge*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new MathBlockGraphEdge(source[index].From, source[index].To, source[index].Weight);
        return values;
    }

    private static unsafe MathBlockRun[] ReadRuns(IntPtr arena, int payloadOffset, int count)
    {
        var values = new MathBlockRun[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (MathBlockCudaRun*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new MathBlockRun(source[index].Start, source[index].Length, source[index].Value);
        return values;
    }

    private static void RequirePayload(int payloadOffset)
    {
        if (payloadOffset < 0)
            throw new InvalidOperationException("The CUDA result has no payload allocation.");
    }

    private static unsafe double[] ReadDoubles(IntPtr arena, int payloadOffset, int count)
    {
        var values = new double[count];
        if (count == 0)
            return values;
        if (payloadOffset < 0)
            throw new InvalidOperationException("The CUDA result has no payload allocation.");
        var source = (double*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = source[index];
        return values;
    }

    private static unsafe bool[] ReadBooleans(IntPtr arena, int payloadOffset, int count)
    {
        var values = new bool[count];
        if (count == 0)
            return values;
        if (payloadOffset < 0)
            throw new InvalidOperationException("The CUDA result has no payload allocation.");
        var source = (int*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = source[index] != 0;
        return values;
    }

    private void ThrowIfDisposed()
    {
        if (disposed)
            throw new ObjectDisposedException(nameof(MathBlocksCUDAProgram));
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MathBlockCudaSlot
    {
        public double ScalarValue;
        public ulong DataPointer;
        public ulong ScratchPointer;
        public int BooleanValue;
        public int Valid;
        public int Rows;
        public int Columns;
        public int Count;
        public int Capacity;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MathBlockCudaGraphEdge
    {
        public int From;
        public int To;
        public double Weight;
    }

    [StructLayout(LayoutKind.Sequential)]
    private struct MathBlockCudaRun
    {
        public int Start;
        public int Length;
        public double Value;
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

internal static class MathBlocksCudaKernelModule
{
    private static readonly Lazy<ModuleState> state = new(Load, LazyThreadSafetyMode.ExecutionAndPublication);

    public static IReadOnlyCollection<string> SupportedBlockIdentities { get; } =
        MathBlockCudaFeatureIndex.SupportedIdentities;

    public static KernelBinding Resolve(string identity)
    {
        var feature = MathBlockCudaFeatureIndex.Resolve(identity);
        return feature.Family switch
        {
            MathBlockCudaFamily.Scalar => new KernelBinding(state.Value.ScalarFunction, feature.Opcode, 1),
            MathBlockCudaFamily.Vector => new KernelBinding(
                state.Value.VectorFunction, feature.Opcode, VectorCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Complex => new KernelBinding(
                state.Value.ComplexFunction, feature.Opcode, ComplexCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Matrix => new KernelBinding(
                state.Value.MatrixFunction, feature.Opcode, MatrixCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Probability => new KernelBinding(
                state.Value.ProbabilityFunction, feature.Opcode, ProbabilityCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.SequencePath => new KernelBinding(
                state.Value.SequencePathFunction, feature.Opcode, SequencePathCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Statistics => new KernelBinding(
                state.Value.StatisticsFunction, feature.Opcode, StatisticsCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Geometry => new KernelBinding(
                state.Value.GeometryFunction, feature.Opcode, GeometryCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Graph => new KernelBinding(
                state.Value.GraphFunction, feature.Opcode, GraphCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Advanced => new KernelBinding(
                state.Value.AdvancedFunction, feature.Opcode, AdvancedCudaBlockCatalog.BlockSize),
            MathBlockCudaFamily.Transport => new KernelBinding(
                state.Value.TransportFunction, feature.Opcode, TransportCudaBlockCatalog.BlockSize),
            _ => throw new InvalidOperationException($"CUDA family '{feature.Family}' is not supported.")
        };
    }

    private static ModuleState Load()
    {
        var source = ScalarCudaBlockCatalog.KernelSource + "\n" +
                     VectorCudaBlockCatalog.KernelSource + "\n" +
                     ComplexCudaBlockCatalog.KernelSource + "\n" +
                     MatrixCudaBlockCatalog.KernelSource + "\n" +
                     ProbabilityCudaBlockCatalog.KernelSource + "\n" +
                     SequencePathCudaBlockCatalog.KernelSource + "\n" +
                     StatisticsCudaBlockCatalog.KernelSource + "\n" +
                     GeometryCudaBlockCatalog.KernelSource + "\n" +
                     GraphCudaBlockCatalog.KernelSource + "\n" +
                     AdvancedCudaBlockCatalog.KernelSource + "\n" +
                     TransportCudaBlockCatalog.KernelSource;
        var ptx = MathBlocksCudaNative.CompilePtx(source, "mathblocks.cu");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleLoadData(out var module, ptx),
            "cuModuleLoadData(mathblocks)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var scalarFunction,
                module,
                ScalarCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_scalar)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var vectorFunction,
                module,
                VectorCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_vector)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var complexFunction,
                module,
                ComplexCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_complex)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var matrixFunction,
                module,
                MatrixCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_matrix)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var probabilityFunction,
                module,
                ProbabilityCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_probability)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var sequencePathFunction,
                module,
                SequencePathCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_sequence_path)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var statisticsFunction,
                module,
                StatisticsCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_statistics)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var geometryFunction,
                module,
                GeometryCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_geometry)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var graphFunction,
                module,
                GraphCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_graph)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var advancedFunction,
                module,
                AdvancedCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_advanced)");
        MathBlocksCudaNative.ThrowIfFailed(
            MathBlocksCudaNative.cuModuleGetFunction(
                out var transportFunction,
                module,
                TransportCudaBlockCatalog.KernelEntryPoint),
            "cuModuleGetFunction(mathblocks_transport)");
        return new ModuleState(
            module,
            scalarFunction,
            vectorFunction,
            complexFunction,
            matrixFunction,
            probabilityFunction,
            sequencePathFunction,
            statisticsFunction,
            geometryFunction,
            graphFunction,
            advancedFunction,
            transportFunction);
    }

    public readonly record struct KernelBinding(IntPtr Function, int Opcode, uint BlockX);
    private sealed record ModuleState(
        IntPtr Module,
        IntPtr ScalarFunction,
        IntPtr VectorFunction,
        IntPtr ComplexFunction,
        IntPtr MatrixFunction,
        IntPtr ProbabilityFunction,
        IntPtr SequencePathFunction,
        IntPtr StatisticsFunction,
        IntPtr GeometryFunction,
        IntPtr GraphFunction,
        IntPtr AdvancedFunction,
        IntPtr TransportFunction);
}
