namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the CUDA type-rule module: the output-type resolver that PatternResearcher's CUDA search and any other consumer compile next to its own kernels.</summary>
/// <remarks>
/// <para>
/// The source is transpiled from <c>TypeRuleUnit.cs</c>, the same C# that <see cref="MathBlockTypeSignatures.Resolve"/> runs on the host, so host and CUDA
/// agree by construction. It is independent of <see cref="MathBlockCudaDeviceModule.Source"/>: it can be compiled alone or appended to it, and it changes
/// no pin of the device module.
/// </para>
/// <para>
/// <c>MathBlockDeviceType</c> is 44 bytes, eleven int32 values with no padding: kind, rows, columns, unit_numerator0 to unit_numerator3, then
/// unit_denominator0 to unit_denominator3. A kind of -1 is invalid; there is no separate valid field. The kind values are those of
/// <see cref="MathBlockValueKind"/>. The row pointer addresses one signature row of <see cref="MathBlockTypeSignatures.WriteTable(out int[], out int[])"/>.
/// </para>
/// </remarks>
public static class MathBlockCudaTypeRuleModule
{
    private static readonly Lazy<(string Source, string Fingerprint)> state = new(
        CreateState,
        LazyThreadSafetyMode.ExecutionAndPublication);

    /// <summary>Gets the name of the CUDA resolver function.</summary>
    public const string FunctionName = "mathblocks_type_resolve";
    /// <summary>Gets the name of the CUDA type structure.</summary>
    public const string TypeName = "MathBlockDeviceType";
    /// <summary>Gets the CUDA resolver signature: it writes kind -1 for an arity mismatch, a rejected kind, a unit-constraint violation or int32 unit overflow.</summary>
    public const string Signature =
        "__device__ void mathblocks_type_resolve(const int* signature_row, const MathBlockDeviceType* inputs, int count, MathBlockDeviceType* output)";
    /// <summary>Gets the size in bytes of <c>MathBlockDeviceType</c>.</summary>
    public const int DeviceTypeSize = MathBlockTypeSignatures.DeviceTypeSize;

    /// <summary>Gets the CUDA source of the module.</summary>
    public static string Source => state.Value.Source;
    /// <summary>Gets the SHA-256 of <see cref="Source"/> as uppercase hex.</summary>
    public static string SourceFingerprint => state.Value.Fingerprint;

    private static (string Source, string Fingerprint) CreateState()
    {
        var source = MathBlockCudaTypeRuleGeneratedSource.Source +
            "\nstatic_assert(sizeof(MathBlockDeviceType) == 44, \"MathBlockDeviceType is eleven int32 values.\");\n";
        return (source, MathBlockCudaContractHash.Create(source));
    }
}
