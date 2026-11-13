using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text.Json;

namespace Supprocom.MathBlocks;

/// <summary>Resolves operation output types from <see cref="MathBlockTypeSignature"/> data and publishes the signature table that the CUDA type-rule module reads.</summary>
/// <remarks>
/// The resolver is one body of code, <c>TypeRuleUnit.cs</c> in the CUDA source generator, that this class calls on the host and that the generator
/// transpiles into <see cref="Cuda.MathBlockCudaTypeRuleModule"/>. Host and CUDA therefore agree by construction.
/// </remarks>
public static class MathBlockTypeSignatures
{
    /// <summary>The size in bytes of the CUDA <c>MathBlockDeviceType</c>: eleven int32 values with no padding.</summary>
    public const int DeviceTypeSize = 44;
    /// <summary>The kind value of an invalid type on CUDA.</summary>
    public const int InvalidKind = -1;

    private static readonly Lazy<SignatureTable> table = new(CreateTable, LazyThreadSafetyMode.ExecutionAndPublication);

    /// <summary>Gets the signatures of the standard operations that have one, in the order of the standard catalog.</summary>
    public static IReadOnlyList<MathBlockTypeSignature> All => table.Value.Signatures;

    /// <summary>Gets the SHA-256 of the table: the little-endian int32 offsets, then the little-endian int32 rows, as uppercase hex.</summary>
    public static string TableFingerprint => table.Value.Fingerprint;

    /// <summary>Gets the signature of a standard operation, or null when the operation has none.</summary>
    public static MathBlockTypeSignature? Get(string identity)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(identity);
        return table.Value.ByIdentity.TryGetValue(identity, out var signature) ? signature : null;
    }

    /// <summary>Gets the position of a standard operation in the table, which is its position in the standard catalog and in <see cref="Cuda.MathBlockCudaDeviceModule.Operations"/>, or -1.</summary>
    public static int IndexOf(string identity)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(identity);
        return table.Value.IndexByIdentity.TryGetValue(identity, out var index) ? index : -1;
    }

    /// <summary>Writes the table as an offset array and a row array.</summary>
    /// <param name="offsets">One entry per standard operation: the index of its row in <paramref name="rows"/>, or -1 when it has no signature.</param>
    /// <param name="rows">The signature rows one after another: rule, parameter count, parameters, operand count, then the accepted kind mask, unit constraint and constant flag of each operand.</param>
    public static void WriteTable(out int[] offsets, out int[] rows)
    {
        var state = table.Value;
        offsets = (int[])state.Offsets.Clone();
        rows = (int[])state.Rows.Clone();
    }

    /// <summary>Resolves an output type, throwing for inputs the signature does not accept.</summary>
    /// <exception cref="ArgumentException">The number of inputs differs from the signature's operand count.</exception>
    /// <exception cref="OverflowException">A unit exponent leaves the int32 range.</exception>
    /// <exception cref="InvalidOperationException">An input kind, unit or shape is not accepted.</exception>
    public static MathBlockType Resolve(MathBlockTypeSignature signature, ReadOnlySpan<MathBlockType> inputs)
    {
        ArgumentNullException.ThrowIfNull(signature);
        var status = ResolveStatus(signature, inputs, out var output);
        return status == MathBlockTypeRuleStatus.Ok ? output : throw CreateException(status, signature.Identity);
    }

    /// <summary>Resolves an output type and reports whether the inputs are accepted.</summary>
    public static bool TryResolve(MathBlockTypeSignature signature, ReadOnlySpan<MathBlockType> inputs, out MathBlockType output)
    {
        ArgumentNullException.ThrowIfNull(signature);
        return ResolveStatus(signature, inputs, out output) == MathBlockTypeRuleStatus.Ok;
    }

    /// <summary>Writes the signatures and the table fingerprint as JSON.</summary>
    public static void WriteJson(Utf8JsonWriter writer)
    {
        ArgumentNullException.ThrowIfNull(writer);
        var state = table.Value;
        writer.WriteStartObject();
        writer.WriteNumber("deviceTypeSize", DeviceTypeSize);
        writer.WriteNumber("invalidKind", InvalidKind);
        writer.WriteString("tableFingerprint", state.Fingerprint);
        writer.WriteNumber("operationCount", state.Offsets.Length);
        writer.WriteStartArray("kinds");
        foreach (var kind in Enum.GetValues<MathBlockValueKind>())
        {
            writer.WriteStartObject();
            writer.WriteNumber("value", (int)kind);
            writer.WriteString("name", kind.ToString());
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
        writer.WriteStartArray("signatures");
        foreach (var signature in state.Signatures)
        {
            writer.WriteStartObject();
            writer.WriteString("identity", signature.Identity);
            writer.WriteNumber("index", state.IndexByIdentity[signature.Identity]);
            writer.WriteNumber("offset", state.Offsets[state.IndexByIdentity[signature.Identity]]);
            writer.WriteNumber("rule", (int)signature.RuleKind);
            writer.WriteString("ruleKind", signature.RuleKind.ToString());
            writer.WriteStartArray("parameters");
            foreach (var parameter in signature.Parameters)
                writer.WriteNumberValue(parameter);
            writer.WriteEndArray();
            writer.WriteStartArray("operands");
            foreach (var operand in signature.Operands)
            {
                writer.WriteStartObject();
                writer.WriteNumber("kindMask", operand.AcceptedKindMask);
                writer.WriteStartArray("kinds");
                foreach (var kind in Enum.GetValues<MathBlockValueKind>())
                {
                    if (operand.Accepts(kind))
                        writer.WriteStringValue(kind.ToString());
                }
                writer.WriteEndArray();
                writer.WriteNumber("unitConstraint", operand.UnitConstraint);
                writer.WriteBoolean("constant", operand.IsConstant);
                writer.WriteEndObject();
            }
            writer.WriteEndArray();
            writer.WriteEndObject();
        }
        writer.WriteEndArray();
        writer.WriteEndObject();
    }

    // Runs the shared resolver over the device-layout copies of the input types.
    internal static unsafe MathBlockTypeRuleStatus ResolveStatus(
        MathBlockTypeSignature signature,
        ReadOnlySpan<MathBlockType> inputs,
        out MathBlockType output)
    {
        var count = inputs.Length;
        Span<MathBlockTypeRuleModule.MathBlockDeviceType> buffer = count <= 8
            ? stackalloc MathBlockTypeRuleModule.MathBlockDeviceType[8]
            : new MathBlockTypeRuleModule.MathBlockDeviceType[count];
        for (var index = 0; index < count; index++)
            buffer[index] = ToDevice(inputs[index]);
        MathBlockTypeRuleModule.MathBlockDeviceType result = default;
        int status;
        fixed (int* row = signature.RowSpan)
        fixed (MathBlockTypeRuleModule.MathBlockDeviceType* device = buffer)
            status = MathBlockTypeRuleModule.ResolveStatus(row, device, count, &result);
        output = status == 0 ? FromDevice(result) : default;
        return (MathBlockTypeRuleStatus)status;
    }

    internal static MathBlockTypeRuleStatus ResolveListStatus(
        MathBlockTypeSignature signature,
        IReadOnlyList<MathBlockType> inputs,
        out MathBlockType output)
    {
        var buffer = new MathBlockType[inputs.Count];
        for (var index = 0; index < buffer.Length; index++)
            buffer[index] = inputs[index];
        return ResolveStatus(signature, buffer, out output);
    }

    internal static Exception CreateException(MathBlockTypeRuleStatus status, string identity) => status switch
    {
        MathBlockTypeRuleStatus.Arity => new ArgumentException($"The operand count does not match the signature of '{identity}'."),
        MathBlockTypeRuleStatus.Overflow => new OverflowException("The rational operation exceeded the supported range."),
        _ => new InvalidOperationException($"The input types are not accepted by '{identity}' ({status}).")
    };

    private static MathBlockTypeRuleModule.MathBlockDeviceType ToDevice(MathBlockType type)
    {
        var unit = type.Unit;
        return new MathBlockTypeRuleModule.MathBlockDeviceType
        {
            kind = (int)type.Kind,
            rows = type.Rows,
            columns = type.Columns,
            unit_numerator0 = unit.Dimension0.Numerator,
            unit_numerator1 = unit.Dimension1.Numerator,
            unit_numerator2 = unit.Dimension2.Numerator,
            unit_numerator3 = unit.Dimension3.Numerator,
            unit_denominator0 = unit.Dimension0.Denominator,
            unit_denominator1 = unit.Dimension1.Denominator,
            unit_denominator2 = unit.Dimension2.Denominator,
            unit_denominator3 = unit.Dimension3.Denominator
        };
    }

    private static MathBlockType FromDevice(MathBlockTypeRuleModule.MathBlockDeviceType value) => new(
        (MathBlockValueKind)value.kind,
        new MathBlockUnit(
            new MathRational(value.unit_numerator0, value.unit_denominator0),
            new MathRational(value.unit_numerator1, value.unit_denominator1),
            new MathRational(value.unit_numerator2, value.unit_denominator2),
            new MathRational(value.unit_numerator3, value.unit_denominator3)),
        value.rows,
        value.columns);

    private static SignatureTable CreateTable()
    {
        var operations = MathBlockCatalog.Standard.Operations;
        var offsets = new int[operations.Count];
        var rows = new List<int>();
        var signatures = new List<MathBlockTypeSignature>();
        var byIdentity = new Dictionary<string, MathBlockTypeSignature>(StringComparer.Ordinal);
        var indexByIdentity = new Dictionary<string, int>(operations.Count, StringComparer.Ordinal);
        for (var index = 0; index < operations.Count; index++)
        {
            var operation = operations[index];
            indexByIdentity.Add(operation.Identity, index);
            var signature = operation.TypeSignature;
            if (signature is null)
            {
                offsets[index] = -1;
                continue;
            }
            offsets[index] = rows.Count;
            rows.AddRange(signature.ToRow());
            signatures.Add(signature);
            byIdentity.Add(operation.Identity, signature);
        }
        var rowArray = rows.ToArray();
        return new SignatureTable(
            offsets,
            rowArray,
            Array.AsReadOnly(signatures.ToArray()),
            byIdentity,
            indexByIdentity,
            Fingerprint(offsets, rowArray));
    }

    private static string Fingerprint(int[] offsets, int[] rows)
    {
        var bytes = new byte[(offsets.Length + rows.Length) * sizeof(int)];
        MemoryMarshal.AsBytes<int>(offsets).CopyTo(bytes);
        MemoryMarshal.AsBytes<int>(rows).CopyTo(bytes.AsSpan(offsets.Length * sizeof(int)));
        if (!BitConverter.IsLittleEndian)
        {
            for (var index = 0; index < bytes.Length; index += sizeof(int))
                Array.Reverse(bytes, index, sizeof(int));
        }
        return Convert.ToHexString(SHA256.HashData(bytes));
    }

    private sealed record SignatureTable(
        int[] Offsets,
        int[] Rows,
        IReadOnlyList<MathBlockTypeSignature> Signatures,
        Dictionary<string, MathBlockTypeSignature> ByIdentity,
        Dictionary<string, int> IndexByIdentity,
        string Fingerprint);
}
