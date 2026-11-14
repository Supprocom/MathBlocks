using System.Globalization;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the type signatures against the resolver delegates they replace, and the table and CUDA source that publish them.</summary>
public sealed class MathBlockTypeSignatureTests
{
    // The pins move with the operation order of the standard catalog and with any signature; update them with the catalog.
    private const string StandardTableFingerprint = "95BC6A09B5F747ED1AB354B808D49511C54FB4EEA2BCEDDD93FF7B1781FBF5D5";
    private const string TypeRuleSourceFingerprint = "8962F39B2728D87760C7CEA3B9FE2AB50B0AD8EFA9D2D96415CD797D0D4B33FE";

    private static readonly MathBlockCausality[] RowCausal = [MathBlockCausality.Pointwise, MathBlockCausality.Trailing, MathBlockCausality.Expanding];

    private static readonly PropertyInfo LegacyResolverProperty =
        typeof(MathBlockOperation).GetProperty("LegacyTypeResolver", BindingFlags.NonPublic | BindingFlags.Instance)!;

    internal static MathBlockTypeResolver Legacy(MathBlockOperation operation) =>
        (MathBlockTypeResolver)LegacyResolverProperty.GetValue(operation)!;

    /// <summary>
    /// Verifies the 329 operations of the scope list (every row-causal operation of the catalog the list was taken from, plus the scalar-kind
    /// operations that have no vector input) have a type signature.
    /// </summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void EveryOperationOfTheScopeListHasATypeSignature()
    {
        var scope = ReadScope();
        var unsigned = scope.Where(identity => MathBlockCatalog.Standard.Get(identity.Split('@')[0], 1).TypeSignature is null).ToList();

        Assert.Equal(329, scope.Count);
        Assert.Equal(scope.Count, scope.Distinct(StringComparer.Ordinal).Count());
        Assert.True(unsigned.Count == 0, $"{unsigned.Count} of {scope.Count} scope operations have no signature: {string.Join(", ", unsigned)}");
        Assert.All(scope, identity => Assert.Equal(identity, MathBlockCatalog.Standard.Get(identity.Split('@')[0], 1).TypeSignature!.Identity));
    }

    /// <summary>Verifies every row-causal operation of the registry, including any lift added later, has a type signature.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void EveryRowCausalOperationOfTheRegistryHasATypeSignature()
    {
        var rowCausal = MathBlockCatalog.Standard.Operations.Where(operation => RowCausal.Contains(operation.Causality.Kind)).ToList();
        var unsigned = rowCausal.Where(operation => operation.TypeSignature is null).Select(operation => operation.Identity).ToList();

        Assert.True(unsigned.Count == 0, $"{unsigned.Count} of {rowCausal.Count} row-causal operations have no signature: {string.Join(", ", unsigned)}");
        Assert.All(rowCausal, operation => Assert.Equal(operation.Identity, operation.TypeSignature!.Identity));
    }

    /// <summary>
    /// Verifies the operations outside the scope list are signed only when their rule fits one of the three rule kinds, which the grid test checks
    /// against the legacy delegate: 148 of the 208 do (105 WholeSeries, 2 Forward, 41 NotSeries), and the other 60 stay unsigned.
    /// </summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void OperationsOutsideTheScopeAreSignedOnlyWhenTheirRuleFits()
    {
        var scope = ReadScope().ToHashSet(StringComparer.Ordinal);
        var outside = MathBlockCatalog.Standard.Operations
            .Where(operation => !scope.Contains(operation.Identity) && !RowCausal.Contains(operation.Causality.Kind))
            .ToList();
        var unsigned = outside.Where(operation => operation.TypeSignature is null).ToList();

        Assert.Equal(208, outside.Count);
        Assert.Equal(60, unsigned.Count);
        Assert.Equal(148, outside.Count - unsigned.Count);
    }

    private static List<string> ReadScope()
    {
        using var stream = typeof(MathBlockTypeSignatureTests).Assembly.GetManifestResourceStream("TypeSignatureScope.txt")!;
        using var reader = new StreamReader(stream);
        var identities = new List<string>();
        while (reader.ReadLine() is { Length: > 0 } line)
            identities.Add(line);
        return identities;
    }

    /// <summary>Verifies the new resolver equals the legacy delegate on every contract case and on the generated grid, for validity, type and exception.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void SignatureResolverEqualsTheLegacyDelegateOnTheGrid()
    {
        var failures = new List<string>();
        var signed = 0;
        var cases = 0L;
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            if (operation.TypeSignature is null)
                continue;
            signed++;
            var mismatch = FindMismatch(operation, operation.TypeSignature, out var count);
            cases += count;
            if (mismatch is not null)
                failures.Add($"{operation.Identity}: {mismatch}");
        }

        Assert.True(failures.Count == 0, $"{failures.Count} of {signed} signed operations differ. {string.Join(Environment.NewLine, failures.Take(30))}");
        Assert.True(cases >= signed * MathBlockTypeSignatureGrid.GeneratedCases, $"Only {cases} cases ran for {signed} operations.");
    }

    /// <summary>Verifies the comparison fails for a signature whose unit rule is broken, so the grid test discriminates.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void GridComparisonDetectsABrokenSignature()
    {
        var operation = MathBlockCatalog.Standard.Get("scalar.square", 1);
        var signature = Assert.IsType<MathBlockTypeSignature>(operation.TypeSignature);
        Assert.Equal(MathBlockTypeRuleKind.Composed, signature.RuleKind);
        Assert.Null(FindMismatch(operation, signature, out _));

        // Composed parameters: outputKind, shapeMode, shapeA, shapeB, unitMode, unitA, unitB, exponentNumerator, exponentDenominator.
        var parameters = signature.Parameters.ToArray();
        parameters[7] = 3;
        var broken = new MathBlockTypeSignature(signature.Identity, signature.RuleKind, parameters, signature.Operands);

        Assert.NotNull(FindMismatch(operation, broken, out _));
    }

    /// <summary>Verifies the row layout, the offsets and the fingerprint of the table.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void TableOffsetsRowsAndFingerprintFollowTheCatalogOrder()
    {
        MathBlockTypeSignatures.WriteTable(out var offsets, out var rows);
        var operations = MathBlockCatalog.Standard.Operations;
        var deviceOperations = MathBlockCudaDeviceModule.Operations;

        Assert.Equal(operations.Count, offsets.Length);
        Assert.Equal(deviceOperations.Count, offsets.Length);
        for (var index = 0; index < offsets.Length; index++)
        {
            Assert.Equal(deviceOperations[index].Identity, operations[index].Identity);
            Assert.Equal(index, MathBlockTypeSignatures.IndexOf(operations[index].Identity));
            var signature = operations[index].TypeSignature;
            if (signature is null)
            {
                Assert.Equal(-1, offsets[index]);
                continue;
            }

            var row = signature.ToRow();
            Assert.Equal(row.Count, 3 + signature.Parameters.Count + signature.Operands.Count * 3);
            Assert.Equal((int)signature.RuleKind, rows[offsets[index]]);
            Assert.Equal(signature.Parameters.Count, rows[offsets[index] + 1]);
            Assert.Equal(row, rows.AsSpan(offsets[index], row.Count).ToArray());
            Assert.Equal(signature.Operands.Count, rows[offsets[index] + 2 + signature.Parameters.Count]);
        }

        var bytes = new byte[(offsets.Length + rows.Length) * sizeof(int)];
        var position = 0;
        foreach (var value in offsets.Concat(rows))
        {
            BitConverter.TryWriteBytes(bytes.AsSpan(position), value);
            position += sizeof(int);
        }

        Assert.Equal(Convert.ToHexString(SHA256.HashData(bytes)), MathBlockTypeSignatures.TableFingerprint);
        Assert.Matches("^[0-9A-F]{64}$", MathBlockTypeSignatures.TableFingerprint);
        Assert.True(
            string.Equals(StandardTableFingerprint, MathBlockTypeSignatures.TableFingerprint, StringComparison.Ordinal),
            "The type-signature table fingerprint is " + MathBlockTypeSignatures.TableFingerprint);
    }

    /// <summary>Verifies the JSON form parses, lists every signature and carries the table fingerprint.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void JsonListsEverySignatureAndTheFingerprint()
    {
        using var stream = new MemoryStream();
        using (var writer = new Utf8JsonWriter(stream))
            MathBlockTypeSignatures.WriteJson(writer);
        using var document = JsonDocument.Parse(stream.ToArray());
        var root = document.RootElement;

        Assert.Equal(MathBlockTypeSignatures.TableFingerprint, root.GetProperty("tableFingerprint").GetString());
        Assert.Equal(44, root.GetProperty("deviceTypeSize").GetInt32());
        Assert.Equal(MathBlockTypeSignatures.All.Count, root.GetProperty("signatures").GetArrayLength());
        Assert.Equal(Enum.GetValues<MathBlockValueKind>().Length, root.GetProperty("kinds").GetArrayLength());
    }

    /// <summary>Verifies the device type is 44 bytes of eleven int32 fields in the agreed order, and that the CUDA source asserts the same.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void DeviceTypeIs44BytesOnTheHostAndInTheCUDASource()
    {
        var type = typeof(MathBlockTypeSignatures).Assembly.GetType("MathBlockTypeRuleModule+MathBlockDeviceType", throwOnError: true)!;
        string[] expected =
        [
            "kind", "rows", "columns",
            "unit_numerator0", "unit_numerator1", "unit_numerator2", "unit_numerator3",
            "unit_denominator0", "unit_denominator1", "unit_denominator2", "unit_denominator3"
        ];
        var fields = type.GetFields(BindingFlags.Public | BindingFlags.Instance);

        Assert.Equal(MathBlockTypeSignatures.DeviceTypeSize, Marshal.SizeOf(type));
        Assert.Equal(44, Marshal.SizeOf(type));
        Assert.Equal(expected, fields.Select(field => field.Name), StringComparer.Ordinal);
        Assert.All(fields, field => Assert.Equal(typeof(int), field.FieldType));
        Assert.Equal(expected.Select((name, index) => index * sizeof(int)), fields.Select(field => (int)Marshal.OffsetOf(type, field.Name)));
        Assert.Contains("static_assert(sizeof(MathBlockDeviceType) == 44", MathBlockCudaTypeRuleModule.Source, StringComparison.Ordinal);
    }

    /// <summary>Verifies the CUDA source and its fingerprint are deterministic, and independent of the device module.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void CUDASourceFingerprintIsTheHashOfTheSource()
    {
        var source = MathBlockCudaTypeRuleModule.Source;

        Assert.Equal(Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(source))), MathBlockCudaTypeRuleModule.SourceFingerprint);
        Assert.Equal(TypeRuleSourceFingerprint, MathBlockCudaTypeRuleModule.SourceFingerprint);
        Assert.Contains("__device__ void mathblocks_type_resolve(", source, StringComparison.Ordinal);
        Assert.NotEqual(MathBlockCudaDeviceModule.SourceFingerprint, MathBlockCudaTypeRuleModule.SourceFingerprint, StringComparer.Ordinal);
        Assert.DoesNotContain("mathblocks_type_resolve", MathBlockCudaDeviceModule.Source, StringComparison.Ordinal);
    }

    /// <summary>Verifies the type-rule source compiles with NVRTC for compute_86 (no device is used), together with a kernel that calls the resolver.</summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void CUDATypeRuleSourceCompilesWithNVRTC()
    {
        var kernel = string.Join(
            "\n",
            "",
            "extern \"C\" __global__ void mathblocks_type_resolve_probe(",
            "    const int* rows, const int* offsets, const MathBlockDeviceType* inputs, const int* counts, MathBlockDeviceType* outputs, int operation)",
            "{",
            "    mathblocks_type_resolve(rows + offsets[operation], inputs, counts[operation], outputs);",
            "}",
            "");
        var compile = typeof(MathBlockCatalog).Assembly
            .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
            .GetMethod("CompilePtxWithoutDevice", BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public, [typeof(string), typeof(string), typeof(string)])!;

        var bytes = (byte[])compile.Invoke(null, [MathBlockCudaTypeRuleModule.Source + kernel, "mathblocks-type-rule.cu", "compute_86"])!;
        var ptx = Encoding.UTF8.GetString(bytes).TrimEnd('\0');

        Assert.Contains(".entry mathblocks_type_resolve_probe", ptx, StringComparison.Ordinal);
    }

    // Compares the signature's resolution with the legacy delegate on the contract cases and the grid of one operation.
    private static string? FindMismatch(MathBlockOperation operation, MathBlockTypeSignature signature, out int cases)
    {
        cases = 0;
        var legacy = Legacy(operation);
        foreach (var types in MathBlockTypeSignatureGrid.Cases(operation))
        {
            cases++;
            var expected = Run(() => legacy(types));
            var actual = Run(() => MathBlockTypeSignatures.Resolve(signature, types));
            var described = string.Join(" ; ", types.Select(type => type.ToString()));
            if ((expected.Type is null) != (actual.Type is null))
                return $"legacy {(expected.Type is null ? expected.Failure : "accepts")}, signature {(actual.Type is null ? actual.Failure : "accepts")} for {described}";
            if (expected.Type is { } expectedType && actual.Type is { } actualType && expectedType != actualType)
                return $"legacy {expectedType}, signature {actualType} for {described}";
        }

        return null;
    }

    private static (MathBlockType? Type, string Failure) Run(Func<MathBlockType> resolve)
    {
        try
        {
            return (resolve(), string.Empty);
        }
        catch (Exception exception) when (exception is InvalidOperationException or OverflowException or ArgumentException or ArithmeticException)
        {
            return (null, exception.GetType().Name);
        }
    }

    /// <summary>Verifies ResolveOutputType raises exactly the exception the legacy delegate raises, with the same message, and returns the same type otherwise.</summary>
    [Fact]
    [Trait("Category", "TypeSignature")]
    public void ResolveOutputTypeKeepsTheLegacyExceptionTypeAndMessage()
    {
        var failures = new List<string>();
        var rejected = 0;
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            if (operation.TypeSignature is null)
                continue;
            var legacy = Legacy(operation);
            var taken = 0;
            foreach (var types in MathBlockTypeSignatureGrid.Cases(operation))
            {
                if (taken++ > 600)
                    break;
                var expected = Capture(() => legacy(types));
                var actual = Capture(() => operation.ResolveOutputType(types));
                if (expected.Exception is not null)
                    rejected++;
                if (expected.Type != actual.Type || expected.Exception?.GetType() != actual.Exception?.GetType() ||
                    !string.Equals(expected.Exception?.Message, actual.Exception?.Message, StringComparison.Ordinal))
                {
                    failures.Add($"{operation.Identity}: legacy {expected.Type}/{expected.Exception?.GetType().Name}, now {actual.Type}/{actual.Exception?.GetType().Name}");
                    break;
                }
            }
        }

        Assert.True(failures.Count == 0, string.Join(Environment.NewLine, failures.Take(30)));
        Assert.True(rejected > 1_000, $"Only {rejected} rejected cases ran.");
    }

    private static (MathBlockType? Type, Exception? Exception) Capture(Func<MathBlockType> resolve)
    {
        try
        {
            return (resolve(), null);
        }
        catch (Exception exception) when (exception is InvalidOperationException or OverflowException or ArgumentException or ArithmeticException)
        {
            return (null, exception);
        }
    }

    internal static string Describe(int value) => value.ToString(CultureInfo.InvariantCulture);
}
