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
    /// <summary>Gets the default threads per block of the dispatcher, the value the ABI fingerprint and <see cref="MathBlockCudaOperationContract.PlanCUDA(IReadOnlyList{MathBlockValue})"/> use.</summary>
    /// <remarks>The dispatcher accepts any block size from 1 up to the CUDA device maximum with the same results; plan the scratch with <see cref="MathBlockCudaOperationContract.PlanCUDA(IReadOnlyList{MathBlockValue}, MathBlockDomainOptions, int)"/> when launching another size.</remarks>
    public const int DispatcherBlockSize = 128;
    /// <summary>Gets the number of virtual lanes of the cooperative kernels whose result or scratch layout would otherwise depend on the block size.</summary>
    /// <remarks>
    /// The rank radix sort of <c>sequence.rolling-median@1</c> and <c>sequence.rolling-quantile@1</c> splits its keys into this many
    /// chunks whatever the block size: a thread of a block of B threads takes the lanes t, t + B, ... below this count, and a block
    /// larger than this count leaves its extra threads idle in those phases. The scratch of that sort holds this many counters, so
    /// its size does not depend on the block size.
    /// </remarks>
    public const int VirtualLaneCount = 128;
    /// <summary>The name of the module-global array of non-converged evaluation counts, one <c>unsigned long long</c> per entry of <see cref="Operations"/>, in that order.</summary>
    /// <remarks>
    /// The incomplete-beta continued fraction and the Jacobi eigenvalue iteration add one to their operation's entry, with <c>atomicAdd</c>, when they stop at their
    /// iteration budget without converging, under both <see cref="MathBlockNonConvergencePolicy"/> values. A consumer's own kernel that calls them adds to the
    /// same array. Read it with <c>cuModuleGetGlobal</c> after a launch, and zero it before.
    /// </remarks>
    public const string NonConvergenceCountsSymbol = "mathblocks_nonconvergence_counts";
    /// <summary>The name of the module-global table of binomial coefficients, <see cref="BinomialTableEntryCount"/> doubles.</summary>
    /// <remarks>
    /// The table holds <c>C(n, k)</c> for <c>0 &lt;= k &lt;= n &lt;= 1023</c> on the symmetric half <c>k &lt;= n / 2</c>: row <c>n</c> starts at entry
    /// <c>(n / 2) * ((n - 1) / 2) + n</c> and has <c>n / 2 + 1</c> entries. An entry is 0 until a device thread evaluates its pair, which stores the result of the
    /// same loop that evaluates a pair outside the table, so a lookup returns the bits the loop returns. The module zero-initializes it. A consumer's own kernel
    /// that calls the ballot-count or binomial-coefficient operations fills the same table.
    /// </remarks>
    public const string BinomialTableSymbol = "mathblocks_binomial_table";
    /// <summary>The number of doubles in the module-global table named by <see cref="BinomialTableSymbol"/>: the sum of <c>n / 2 + 1</c> over <c>n</c> from 0 to 1023, which is 2,101,248 bytes.</summary>
    public const int BinomialTableEntryCount = 262656;
    /// <summary>Gets the byte stride of one row of the values form <c>elementwise.&lt;source&gt;</c>: a double, written at <c>data_pointer</c>.</summary>
    /// <remarks>
    /// The elementwise device layout, as <c>mathblocks_elementwise_run</c> in the generated source implements it:
    /// <list type="bullet">
    /// <item>The values form <c>elementwise.&lt;source&gt;</c> writes one double per row at an 8-byte stride from the output slot's <c>data_pointer</c>; a row that is not computed holds the fill.</item>
    /// <item>The validity form <c>elementwise-valid.&lt;source&gt;</c> writes one int32, 0 or 1, per row at a 4-byte stride from <c>data_pointer</c>.</item>
    /// <item>Both set <c>rows</c> and <c>count</c> of the output slot to the row count, and to 0 when the whole result is invalid; <c>columns</c> is 0.</item>
    /// <item>The opcode is <c>2 * source + sibling</c>, plus <c>128 * mask</c> for a source below 64 (<c>1024 + 2 * source + sibling + 65536 * mask</c> above), when the consumer passes the vector-argument mask (bit i set when argument i is a vector); without a mask the device derives it from the input slots, a slot with <c>count</c> above 0 being a vector.</item>
    /// <item>The inputs are the source's arguments; the values form has one more input, the fill, at <c>inputs[arity]</c>. CUDA reads only the fill slot's <c>scalar_value</c>; the host gives the slot the unit of the source result. The validity form has no fill input.</item>
    /// </list>
    /// </remarks>
    public const int ElementwiseValueElementBytes = 8;
    /// <summary>Gets the byte stride of one row of the validity form <c>elementwise-valid.&lt;source&gt;</c>: an int32, written at <c>data_pointer</c>; see <see cref="ElementwiseValueElementBytes"/>.</summary>
    public const int ElementwiseValidityElementBytes = 4;
    /// <summary>Gets the signature of <c>mathblocks_row_add</c>: a + b; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowAddSignature =
        "static __device__ __forceinline__ bool mathblocks_row_add(double a, double b, double fill, double* result)";
    /// <summary>Gets the signature of <c>mathblocks_row_subtract</c>: a - b; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowSubtractSignature =
        "static __device__ __forceinline__ bool mathblocks_row_subtract(double a, double b, double fill, double* result)";
    /// <summary>Gets the signature of <c>mathblocks_row_multiply</c>: a * b; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowMultiplySignature =
        "static __device__ __forceinline__ bool mathblocks_row_multiply(double a, double b, double fill, double* result)";
    /// <summary>Gets the signature of <c>mathblocks_row_divide</c>: a / b; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowDivideSignature =
        "static __device__ __forceinline__ bool mathblocks_row_divide(double a, double b, double fill, double* result)";
    /// <summary>Gets the signature of <c>mathblocks_row_absolute</c>: |a|; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowAbsoluteSignature =
        "static __device__ __forceinline__ bool mathblocks_row_absolute(double a, double fill, double* result)";
    /// <summary>Gets the signature of <c>mathblocks_row_square_root</c>: the square root of a; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowSquareRootSignature =
        "static __device__ __forceinline__ bool mathblocks_row_square_root(double a, double fill, double* result)";
    /// <summary>Gets the signature of <c>mathblocks_row_sum</c>: the sum of <c>values[0..count)</c> added left to right from 0.0 with the rule of <see cref="RowAddSignature"/>; it stops at the first invalid step, and a count of 0 gives 0.0; see <see cref="RowFunctionSignatures"/>.</summary>
    public const string RowSumSignature =
        "static __device__ __forceinline__ bool mathblocks_row_sum(const double* values, int count, double fill, double* result)";
    /// <summary>Gets the signatures of the per-row functions <c>mathblocks_row_&lt;operation&gt;</c> of <see cref="Source"/>, separated by semicolons, in the order of the <c>Row...Signature</c> constants.</summary>
    /// <remarks>
    /// Each function evaluates one row of a simple scalar operation with the bits of the dispatch's scalar case, in the same inline device function the case calls:
    /// <list type="bullet">
    /// <item>The return value is whether the row is valid: every argument is finite and the value is finite. <c>*result</c> receives the value, or <c>fill</c> when the row is invalid.</item>
    /// <item>The value is the plain IEEE operation: <c>|a|</c>, <c>a + b</c>, <c>a - b</c>, <c>a * b</c>, <c>a / b</c> or <c>sqrt(a)</c>, with no fused multiply-add and no flushing.</item>
    /// <item><c>mathblocks_row_sum</c> adds <c>values[0..count)</c> left to right from 0.0 and stops at the first invalid step; a count of 0 gives 0.0 and true.</item>
    /// <item>The functions read no slot and use no synchronization.</item>
    /// </list>
    /// </remarks>
    public const string RowFunctionSignatures =
        RowAddSignature + ";" +
        RowSubtractSignature + ";" +
        RowMultiplySignature + ";" +
        RowDivideSignature + ";" +
        RowAbsoluteSignature + ";" +
        RowSquareRootSignature + ";" +
        RowSumSignature;
    /// <summary>Gets the dispatch function name value.</summary>
    public const string DispatchFunctionName = "mathblocks_operation_dispatch";
    /// <summary>Gets the dispatch signature value.</summary>
    public const string DispatchSignature =
        "__device__ void mathblocks_operation_dispatch(int family, int opcode, " +
        "const MathBlockSlot* const* inputs, int input_count, MathBlockSlot* output)";
    /// <summary>Gets the signature of the single-row elementwise function <c>mathblocks_elementwise_row</c>, as declared in <see cref="Source"/>.</summary>
    /// <remarks>
    /// Evaluates one row of an elementwise source with the semantics of <c>mathblocks_operation_dispatch</c> for family 12, in the same device function the dispatch's row loop calls:
    /// <list type="bullet">
    /// <item><c>opcode</c> is the elementwise opcode a consumer passes to the dispatch, narrow or wide, values form (even) or validity form (odd); its mask bits are ignored, and a broadcast scalar is passed as a plain value.</item>
    /// <item><c>a</c>, <c>b</c> and <c>c</c> are the row's arguments; those beyond the source's arity read 0.</item>
    /// <item>The return value is whether the row is valid: every argument the source takes is finite and the source's result is valid. <c>*result</c> receives the row's value, or <c>fill</c> when the row is invalid.</item>
    /// <item>A negative opcode or a source index at or past the source count writes <c>fill</c> and returns false without evaluating.</item>
    /// <item>A row whose source does not converge is counted in <see cref="NonConvergenceCountsSymbol"/> under the opcode's form, as the dispatch counts it.</item>
    /// </list>
    /// </remarks>
    public const string ElementwiseRowSignature =
        "__device__ bool mathblocks_elementwise_row(int opcode, double a, double b, double c, double fill, double* result)";

    // CA1721: GetSource(MathBlockDomainOptions) and GetSourceFingerprint(MathBlockDomainOptions) are the names the 0.7.0 interface fixes, and Source and
    // SourceFingerprint are the shipped properties of the default options.
#pragma warning disable CA1721
    /// <summary>Gets the source value.</summary>
    public static string Source => state.Value.Source;
    /// <summary>Gets the source fingerprint value.</summary>
    public static string SourceFingerprint => state.Value.SourceFingerprint;
#pragma warning restore CA1721

    /// <summary>Gets the device source for the given domain options.</summary>
    /// <remarks>The generated operation text is the same at every option value; each limit is the value of a small function that comes before it. <see cref="Source"/> is this text for <see cref="MathBlockDomainOptions.Default"/>.</remarks>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range its limit allows.</exception>
    public static string GetSource(MathBlockDomainOptions domainOptions)
    {
        ArgumentNullException.ThrowIfNull(domainOptions);
        domainOptions.Validate();
        return MathBlockCudaDevicePrelude.Create(domainOptions, state.Value.OperationIdentities) + CreateSource();
    }

    /// <summary>Gets the fingerprint of <see cref="GetSource(MathBlockDomainOptions)"/>, the SHA-256 of the source in upper-case hexadecimal.</summary>
    public static string GetSourceFingerprint(MathBlockDomainOptions domainOptions) =>
        MathBlockCudaContractHash.Create(GetSource(domainOptions));
    /// <summary>Gets the abi value.</summary>
    public static MathBlockCudaDeviceAbi Abi => state.Value.Abi;
    /// <summary>Gets the abi fingerprint value.</summary>
    public static string AbiFingerprint => state.Value.Abi.Fingerprint;
    /// <summary>Gets the operations value.</summary>
    public static IReadOnlyList<MathBlockCudaOperationContract> Operations => state.Value.Operations;

    // The operation identities in the order of Operations, which index the non-convergence counters.
    internal static IReadOnlyList<string> OperationIdentities => state.Value.OperationIdentities;
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

    /// <summary>Appends a consumer's source to the device source for the given domain options.</summary>
    public static string ComposeSource(string consumerSource, MathBlockDomainOptions domainOptions)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(consumerSource);
        return GetSource(domainOptions) + "\n" + consumerSource;
    }

    /// <summary>Compiles the composed CUDA source to PTX with NVRTC.</summary>
    // RS0027: the shipped overload has an optional parameter and fewer parameters than the domain-options overload, whose signature the 0.7.0 interface fixes.
#pragma warning disable RS0027
    public static byte[] CompilePtx(string consumerSource, string sourceName = "mathblocks-consumer.cu")
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sourceName);
        return MathBlocksCudaNative.CompilePtx(ComposeSource(consumerSource), sourceName);
    }
#pragma warning restore RS0027

    /// <summary>Compiles a consumer's source after the device source for the given domain options.</summary>
    public static byte[] CompilePtx(string consumerSource, string sourceName, MathBlockDomainOptions domainOptions)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(sourceName);
        return MathBlocksCudaNative.CompilePtx(ComposeSource(consumerSource, domainOptions), sourceName);
    }

    private static ModuleState CreateState()
    {
        var registryOperations = MathBlockCatalog.Standard.Operations;
        var operationIdentities = new string[registryOperations.Count];
        for (var index = 0; index < operationIdentities.Length; index++)
            operationIdentities[index] = registryOperations[index].Identity;
        var source = MathBlockCudaDevicePrelude.Create(MathBlockDomainOptions.Default, operationIdentities) + CreateSource();
        var sourceFingerprint = MathBlockCudaContractHash.Create(source);
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
            Array.AsReadOnly(identities),
            operationIdentities);
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
        IReadOnlyCollection<string> SupportedOperationIdentities,
        IReadOnlyList<string> OperationIdentities);
}
