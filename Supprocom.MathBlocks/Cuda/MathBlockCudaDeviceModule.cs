using System.Globalization;
using System.Runtime.InteropServices;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Device Module contract.</summary>
public static class MathBlockCudaDeviceModule
{
    private static readonly Lazy<ModuleState> state = new(
        CreateState,
        LazyThreadSafetyMode.ExecutionAndPublication);

    /// <summary>Gets the abi version value.</summary>
    public const int AbiVersion = 2;
    /// <summary>Gets the dispatcher block size value.</summary>
    public const int DispatcherBlockSize = 128;
    /// <summary>Gets the byte stride of one row of the values form <c>elementwise.&lt;source&gt;</c>: a double, written at <c>data_pointer</c>.</summary>
    /// <remarks>
    /// The elementwise device layout, as <c>mathblocks_elementwise_run</c> in the generated source implements it:
    /// <list type="bullet">
    /// <item>The values form <c>elementwise.&lt;source&gt;</c> writes one double per row at an 8-byte stride from the output slot's <c>data_pointer</c>; a row that is not computed holds the fill.</item>
    /// <item>The validity form <c>elementwise-valid.&lt;source&gt;</c> writes one int32, 0 or 1, per row at a 4-byte stride from <c>data_pointer</c>.</item>
    /// <item>Both set <c>rows</c> and <c>count</c> of the output slot to the row count, and to 0 when the whole result is invalid; <c>columns</c> is 0.</item>
    /// <item>The opcode is <c>2 * source + sibling</c>, plus <c>128 * mask</c> when the consumer passes the vector-argument mask (bit i set when argument i is a vector); without a mask the device derives it from the input slots, a slot with <c>count</c> above 0 being a vector.</item>
    /// <item>The inputs are the source's arguments; the values form has one more input, the fill, at <c>inputs[arity]</c>. CUDA reads only the fill slot's <c>scalar_value</c>; the host gives the slot the unit of the source result. The validity form has no fill input.</item>
    /// </list>
    /// </remarks>
    public const int ElementwiseValueElementBytes = 8;
    /// <summary>Gets the byte stride of one row of the validity form <c>elementwise-valid.&lt;source&gt;</c>: an int32, written at <c>data_pointer</c>; see <see cref="ElementwiseValueElementBytes"/>.</summary>
    public const int ElementwiseValidityElementBytes = 4;
    /// <summary>Gets the dispatch function name value.</summary>
    public const string DispatchFunctionName = "mathblocks_operation_dispatch";
    /// <summary>Gets the dispatch signature value.</summary>
    public const string DispatchSignature =
        "__device__ void mathblocks_operation_dispatch(int family, int opcode, " +
        "const MathBlockSlot* const* inputs, int input_count, MathBlockSlot* output)";

    /// <summary>Gets the source value.</summary>
    public static string Source => state.Value.Source;
    /// <summary>Gets the source fingerprint value.</summary>
    public static string SourceFingerprint => state.Value.SourceFingerprint;
    /// <summary>Gets the abi value.</summary>
    public static MathBlockCudaDeviceAbi Abi => state.Value.Abi;
    /// <summary>Gets the abi fingerprint value.</summary>
    public static string AbiFingerprint => state.Value.Abi.Fingerprint;
    /// <summary>Gets the operations value.</summary>
    public static IReadOnlyList<MathBlockCudaOperationContract> Operations => state.Value.Operations;
    /// <summary>Gets the supported operation identities value.</summary>
    public static IReadOnlyCollection<string> SupportedOperationIdentities =>
        state.Value.SupportedOperationIdentities;

    /// <summary>Gets a CUDA operation contract by its identity.</summary>
    public static MathBlockCudaOperationContract GetOperation(string identity)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(identity);
        return state.Value.ContractsByIdentity.TryGetValue(identity, out var contract)
            ? contract
            : throw new KeyNotFoundException($"CUDA operation '{identity}' is not registered.");
    }

    /// <summary>Appends consumer CUDA source to the checked device module.</summary>
    public static string ComposeSource(string consumerSource)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(consumerSource);
        return Source + "\n" + consumerSource;
    }

    /// <summary>Compiles the composed CUDA source to PTX with NVRTC.</summary>
    public static byte[] CompilePtx(string consumerSource, string sourceName = "mathblocks-consumer.cu")
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sourceName);
        return MathBlocksCudaNative.CompilePtx(ComposeSource(consumerSource), sourceName);
    }

    private static ModuleState CreateState()
    {
        var source = CreateSource();
        var sourceFingerprint = MathBlockCudaContractHash.Create(source);
        var registryOperations = MathBlockCatalog.Standard.Operations;
        var contracts = new MathBlockCudaOperationContract[registryOperations.Count];
        var contractsByIdentity = new Dictionary<string, MathBlockCudaOperationContract>(
            registryOperations.Count,
            StringComparer.Ordinal);
        var identities = new string[registryOperations.Count];
        for (var index = 0; index < registryOperations.Count; index++)
        {
            var operation = registryOperations[index];
            var feature = MathBlockCudaFeatureIndex.Resolve(operation.Identity);
            var family = (MathBlockCudaOperationFamily)(int)feature.Family;
            var contract = new MathBlockCudaOperationContract(
                operation,
                family,
                feature.Opcode,
                ResolveBlockSize(feature.Family),
                sourceFingerprint);
            contracts[index] = contract;
            contractsByIdentity.Add(contract.Identity, contract);
            identities[index] = contract.Identity;
        }

        var operationTable = new StringBuilder("mathblocks-cuda-operation-table-v1\n");
        for (var index = 0; index < contracts.Length; index++)
        {
            operationTable.Append(contracts[index].Identity).Append('\n')
                .Append(contracts[index].Family).Append('\n')
                .Append(((int)contracts[index].Family).ToString(CultureInfo.InvariantCulture))
                .Append('\n')
                .Append(contracts[index].Opcode.ToString(CultureInfo.InvariantCulture))
                .Append('\n')
                .Append(contracts[index].Fingerprint).Append('\n');
        }
        var operationTableFingerprint = MathBlockCudaContractHash.Create(
            operationTable.ToString());
        var abi = new MathBlockCudaDeviceAbi(
            AbiVersion,
            DispatcherBlockSize,
            DispatchFunctionName,
            DispatchSignature,
            new MathBlockCudaSlotAbi(
                Marshal.SizeOf<MathBlockCudaSlotDescriptor>(),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.ScalarValue)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.DataPointer)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.ScratchPointer)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.BooleanValue)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Valid)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Rows)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Columns)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Count)),
                OffsetOf<MathBlockCudaSlotDescriptor>(nameof(MathBlockCudaSlotDescriptor.Capacity))),
            new MathBlockCudaGraphEdgeAbi(
                Marshal.SizeOf<MathBlockCudaGraphEdgeDescriptor>(),
                OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.From)),
                OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.To)),
                OffsetOf<MathBlockCudaGraphEdgeDescriptor>(nameof(MathBlockCudaGraphEdgeDescriptor.Weight))),
            new MathBlockCudaRunAbi(
                Marshal.SizeOf<MathBlockCudaRunDescriptor>(),
                OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Start)),
                OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Length)),
                OffsetOf<MathBlockCudaRunDescriptor>(nameof(MathBlockCudaRunDescriptor.Value))),
            MathBlockCudaValueCodec.Schema,
            MathBlockCudaValueCodec.ImplementationFingerprint,
            sourceFingerprint,
            operationTableFingerprint);

        return new ModuleState(
            source,
            sourceFingerprint,
            abi,
            Array.AsReadOnly(contracts),
            contractsByIdentity,
            Array.AsReadOnly(identities));
    }

    private static int OffsetOf<T>(string fieldName) where T : struct =>
        Marshal.OffsetOf<T>(fieldName).ToInt32();

    private static string CreateSource()
    {
        return MathBlockCudaGeneratedSource.Source;
    }

    private static uint ResolveBlockSize(MathBlockCudaFamily family) => family switch
    {
        MathBlockCudaFamily.Scalar => 1,
        MathBlockCudaFamily.Vector => 128,
        MathBlockCudaFamily.Complex => 128,
        MathBlockCudaFamily.Matrix => 128,
        MathBlockCudaFamily.Probability => 128,
        MathBlockCudaFamily.SequencePath => 128,
        MathBlockCudaFamily.Statistics => 128,
        MathBlockCudaFamily.Geometry => 128,
        MathBlockCudaFamily.Graph => 128,
        MathBlockCudaFamily.Advanced => 128,
        MathBlockCudaFamily.Transport => 128,
        MathBlockCudaFamily.Window => 128,
        MathBlockCudaFamily.Elementwise => 128,
        _ => throw new InvalidOperationException($"CUDA family '{family}' is not supported.")
    };


    private sealed record ModuleState(
        string Source,
        string SourceFingerprint,
        MathBlockCudaDeviceAbi Abi,
        IReadOnlyList<MathBlockCudaOperationContract> Operations,
        IReadOnlyDictionary<string, MathBlockCudaOperationContract> ContractsByIdentity,
        IReadOnlyCollection<string> SupportedOperationIdentities);
}
