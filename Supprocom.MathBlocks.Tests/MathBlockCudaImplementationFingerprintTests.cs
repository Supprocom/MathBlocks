using System.Buffers.Binary;
using System.Collections;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains regression tests for the value codec implementation fingerprint: SHA-256 over the codec schema fingerprint and
/// the bytes that the codec's own write, header and read paths produce for a fixed corpus. The internal corpus and hash
/// types are reached by name through reflection, because the library exposes no internals.
/// </summary>
public sealed class MathBlockCudaImplementationFingerprintTests
{
    // The pins of this library. Both values are hashes of bytes the codec writes, so they are the same in a Debug and a
    // Release build, with any compiler and for any assembly version, and they move only when the codec or the corpus does.
    private const string CodecImplementationFingerprint =
        "5F0FB495A844D087E764092BD2375535443378A79884441051ADEBAE958AE760";
    private const string DeviceAbiFingerprint =
        "A474D9DE5B08D66611455EEB0AB8F196C95E3E4630856ED7C229DEFEE59D9F5D";

    // The SHA-256 of the full generated CUDA source (the generator checks the same value when it runs).
    private const string FullGeneratedSourceSha256 =
        "A5E77D01A3EA431268A83687F16C052C48B44A2901604F7E8C15F563341C93D7";

    private const string CorpusVersion = "mathblocks-value-codec-corpus-v1";

    private const BindingFlags PublicStatic = BindingFlags.Public | BindingFlags.Static;

    private static readonly Type CorpusType = typeof(MathBlockCudaValueCodec).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaValueCodecCorpus", throwOnError: true)!;

    private static readonly Type ContractHashType = typeof(MathBlockCudaValueCodec).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaContractHash", throwOnError: true)!;

    private static readonly string[] NonKindSchemaKeys =
        ["byte-order", "slot", "invalid", "header-count", "read-validity", "capacity"];

    /// <summary>Verifies the corpus holds every value kind of the codec's table, in every state that the codec writes.</summary>
    [Fact]
    public void CorpusCoversEveryValueKindAndEveryInvalidState()
    {
        var values = ValueCases();
        var headers = HeaderCases();
        var reads = ReadCases();
        var schemaKeys = new HashSet<string>(
            MathBlockCudaValueCodec.SchemaDefinition.Split('\n')
                .Select(line => line[..line.IndexOf('=', StringComparison.Ordinal)]),
            StringComparer.Ordinal);
        var schemaKinds = new HashSet<string>(
            schemaKeys.Where(key => !NonKindSchemaKeys.Contains(key, StringComparer.Ordinal)),
            StringComparer.Ordinal);
        var enumKinds = Enum.GetValues<MathBlockValueKind>().ToDictionary(Kebab, kind => kind, StringComparer.Ordinal);

        // The codec's own table (its schema) and its enum name the same kinds, and the corpus covers each of them.
        Assert.True(schemaKinds.SetEquals(enumKinds.Keys), "The schema kinds are " + string.Join(',', schemaKinds));
        Assert.Contains("invalid", schemaKeys);
        foreach (var (name, kind) in enumKinds)
        {
            var valid = values.Where(item => item.Value.IsValid && item.Value.Type.Kind == kind).ToArray();
            Assert.True(valid.Length >= 3, "The corpus has too few valid " + name + " values.");
            Assert.True(
                values.Any(item => !item.Value.IsValid && item.Value.Type.Kind == kind &&
                    item.Name.StartsWith("invalid/" + name, StringComparison.Ordinal)),
                "The corpus has no invalid " + name + " value.");
            Assert.True(
                headers.Any(item => item.Type.Kind == kind && item.Valid &&
                    item.Name.StartsWith("header/" + name, StringComparison.Ordinal)),
                "The corpus has no " + name + " header.");
            if (kind is not (MathBlockValueKind.Boolean or MathBlockValueKind.BooleanVector))
            {
                Assert.True(
                    valid.Any(item => !item.Value.Type.Unit.IsDimensionless),
                    "The corpus has no " + name + " value with a unit.");
            }

            if (kind is MathBlockValueKind.Scalar or MathBlockValueKind.Boolean or MathBlockValueKind.Complex)
                continue;
            var counts = valid.Select(item => MathBlockCudaValueCodec.GetElementCount(item.Value)).ToHashSet();
            Assert.Contains(1, counts);
            if (kind is MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix)
                Assert.Contains(valid, item => item.Value.Type.Rows != item.Value.Type.Columns && item.Value.Type.Rows > 1);
            else
                Assert.Contains(0, counts);
        }

        // Every invalid state: each kind, no shape, the non-finite inputs that make a value invalid, spare capacity.
        var names = new HashSet<string>(values.Select(item => item.Name), StringComparer.Ordinal);
        foreach (var required in new[]
        {
            "invalid/vector-no-shape", "invalid/scalar-not-a-number", "invalid/scalar-positive-infinity",
            "invalid/scalar-negative-infinity", "invalid/complex-not-a-number", "invalid/complex-infinite-imaginary",
            "invalid/scalar-spare-capacity", "invalid/vector-spare-capacity", "invalid/scalar-unit"
        })
        {
            Assert.Contains(required, names);
        }

        Assert.Contains(headers, item => !item.Valid);
        Assert.Contains(reads, item => item.Slot.Valid == 0);

        // The edge values the codec must keep: both zeros, subnormals, the extremes; spare capacity above and below the count.
        var scalars = values.Where(item => item.Value.IsValid && item.Value.Type.Kind == MathBlockValueKind.Scalar)
            .Select(item => item.Value.AsScalar()).ToArray();
        Assert.Contains(scalars, value => value == 0d && double.IsNegative(value));
        Assert.Contains(scalars, value => value == 0d && !double.IsNegative(value));
        Assert.Contains(scalars, value => double.IsSubnormal(value));
        Assert.Contains(scalars, value => value == double.MaxValue);
        Assert.Contains(scalars, value => value == double.MinValue);
        Assert.Contains(values, item => item.Spare > 0);
        Assert.Contains(values, item => item.Spare < 0);
        Assert.Contains(headers, item => item.Type.Kind == MathBlockValueKind.Matrix && item.Type.Rows * (long)item.Type.Columns > item.Capacity);
        Assert.Equal(CorpusVersion, (string)CorpusType.GetField("Version")!.GetRawConstantValue()!);
    }

    /// <summary>Verifies the corpus is encoded through the codec: bytes match an independent write, and a read gives back what was written.</summary>
    [Fact]
    public void CorpusIsEncodedByTheCodecWritePathHeaderPathAndReadPath()
    {
        var entries = EncodedEntries().ToDictionary(entry => entry.Name, entry => entry.Bytes, StringComparer.Ordinal);
        var dataPointer = (ulong)CorpusType.GetField("DataPointer")!.GetRawConstantValue()!;
        var scratchPointer = (ulong)CorpusType.GetField("ScratchPointer")!.GetRawConstantValue()!;
        Assert.NotEqual(dataPointer, scratchPointer);
        var rejected = new List<string>();

        foreach (var (name, value, spare) in ValueCases())
        {
            if (Encoding.UTF8.GetString(entries[name]).StartsWith("rejected:", StringComparison.Ordinal))
            {
                rejected.Add(name);
                Assert.False(entries.ContainsKey(name + "#read"));
                continue;
            }

            var capacity = (value.IsValid ? MathBlockCudaValueCodec.GetElementCount(value) : 0) + spare;
            Assert.Equal(WriteThroughThePublicCodec(value, capacity, dataPointer, scratchPointer), entries[name]);
            Assert.Equal(entries[name], entries[name + "#read"]);
            Assert.Equal(
                MathBlockCudaSlotLayout.Size + MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity),
                entries[name].Length);
        }

        foreach (var (name, type, capacity, valid) in HeaderCases())
        {
            var arena = Marshal.AllocHGlobal(MathBlockCudaSlotLayout.Size);
            try
            {
                Marshal.Copy(new byte[MathBlockCudaSlotLayout.Size], 0, arena, MathBlockCudaSlotLayout.Size);
                MathBlockCudaValueCodec.WriteHeader(arena, 0, dataPointer, scratchPointer, capacity, type, valid);
                var bytes = new byte[MathBlockCudaSlotLayout.Size];
                Marshal.Copy(arena, bytes, 0, bytes.Length);
                Assert.Equal(bytes, entries[name]);
            }
            finally
            {
                Marshal.FreeHGlobal(arena);
            }
        }

        foreach (var (name, _, _, _) in ReadCases())
        {
            if (Encoding.UTF8.GetString(entries[name]).StartsWith("rejected:", StringComparison.Ordinal))
                rejected.Add(name);
        }

        // The codec rejects exactly these: a capacity below the element count, a slot count above its capacity, and a
        // matrix slot whose count does not match its shape.
        Assert.Equal(
            new[] { "read/count-exceeds-capacity", "read/matrix-count-mismatch", "vector/capacity-below-count" },
            rejected.Order(StringComparer.Ordinal).ToArray());
        Assert.Equal(
            "rejected:System.ArgumentException",
            Encoding.UTF8.GetString(entries["vector/capacity-below-count"]));
        Assert.Equal(
            "rejected:System.InvalidOperationException",
            Encoding.UTF8.GetString(entries["read/count-exceeds-capacity"]));
    }

    /// <summary>Verifies the fingerprint is the SHA-256 over the version, the schema fingerprint and every entry's name and bytes.</summary>
    [Fact]
    public void ImplementationFingerprintIsTheHashOfTheEncodedCorpus()
    {
        var entries = EncodedEntries();
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        AppendWithLength(hash, Encoding.UTF8.GetBytes(CorpusVersion));
        AppendWithLength(hash, Encoding.UTF8.GetBytes(MathBlockCudaValueCodec.SchemaFingerprint));
        foreach (var (name, bytes) in entries)
        {
            AppendWithLength(hash, Encoding.UTF8.GetBytes(name));
            AppendWithLength(hash, bytes);
        }

        var expected = Convert.ToHexString(hash.GetHashAndReset());

        Assert.Equal(64, expected.Length);
        Assert.Equal(expected, MathBlockCudaValueCodec.ImplementationFingerprint);
        Assert.Equal(expected, LibraryHash(CorpusVersion, MathBlockCudaValueCodec.SchemaFingerprint, entries));
        Assert.Equal(MathBlockCudaValueCodec.ImplementationFingerprint, MathBlockCudaDeviceModule.Abi.ValueCodecImplementationFingerprint);
    }

    /// <summary>Verifies a codec that wrote one byte differently, one entry fewer, another order or another schema gives another hash.</summary>
    [Fact]
    public void ImplementationFingerprintFollowsEveryByteTheCodecWrites()
    {
        var entries = EncodedEntries();
        var schema = MathBlockCudaValueCodec.SchemaFingerprint;
        var baseline = LibraryHash(CorpusVersion, schema, entries);
        Assert.Equal(baseline, MathBlockCudaValueCodec.ImplementationFingerprint);

        // One byte of any one entry written differently: the first byte, a middle byte and the last byte of each entry.
        for (var index = 0; index < entries.Length; index++)
        {
            foreach (var position in new[] { 0, entries[index].Bytes.Length / 2, entries[index].Bytes.Length - 1 })
            {
                var perturbed = entries.ToArray();
                var bytes = (byte[])perturbed[index].Bytes.Clone();
                bytes[position] ^= 0x01;
                perturbed[index] = (perturbed[index].Name, bytes);
                Assert.NotEqual(baseline, LibraryHash(CorpusVersion, schema, perturbed), StringComparer.Ordinal);
            }
        }

        var shortened = entries.Take(entries.Length - 1).ToArray();
        var swapped = entries.ToArray();
        (swapped[0], swapped[1]) = (swapped[1], swapped[0]);
        var renamed = entries.ToArray();
        renamed[0] = (renamed[0].Name + "-renamed", renamed[0].Bytes);
        Assert.NotEqual(baseline, LibraryHash(CorpusVersion, schema, shortened), StringComparer.Ordinal);
        Assert.NotEqual(baseline, LibraryHash(CorpusVersion, schema, swapped), StringComparer.Ordinal);
        Assert.NotEqual(baseline, LibraryHash(CorpusVersion, schema, renamed), StringComparer.Ordinal);
        Assert.NotEqual(baseline, LibraryHash("mathblocks-value-codec-corpus-v2", schema, entries), StringComparer.Ordinal);
        Assert.NotEqual(baseline, LibraryHash(CorpusVersion, schema + "0", entries), StringComparer.Ordinal);
    }

    /// <summary>Verifies the codec implementation fingerprint and the device ABI fingerprint against their pins.</summary>
    [Fact]
    public void ImplementationAndDeviceAbiFingerprintsMatchThePins()
    {
        Assert.True(
            string.Equals(
                CodecImplementationFingerprint,
                MathBlockCudaValueCodec.ImplementationFingerprint,
                StringComparison.Ordinal),
            "The value codec implementation fingerprint is " + MathBlockCudaValueCodec.ImplementationFingerprint);
        Assert.True(
            string.Equals(
                DeviceAbiFingerprint,
                MathBlockCudaDeviceModule.AbiFingerprint,
                StringComparison.Ordinal),
            "The device ABI fingerprint is " + MathBlockCudaDeviceModule.AbiFingerprint);
        Assert.Equal(MathBlockCudaDeviceModule.AbiFingerprint, MathBlockCudaDeviceModule.Abi.Fingerprint);
    }

    /// <summary>Verifies the full generated CUDA source against its pin.</summary>
    [Fact]
    public void FullGeneratedSourceMatchesItsPin()
    {
        var generated = (string)typeof(MathBlockCudaValueCodec).Assembly
            .GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaGeneratedSource", throwOnError: true)!
            .GetField("Source")!.GetRawConstantValue()!;
        var actual = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(generated)));

        Assert.True(
            string.Equals(FullGeneratedSourceSha256, actual, StringComparison.Ordinal),
            "The full generated CUDA source hash is " + actual);
    }

    private static string Kebab(MathBlockValueKind kind)
    {
        var name = kind.ToString();
        var builder = new StringBuilder(name.Length + 2);
        for (var index = 0; index < name.Length; index++)
        {
            if (index != 0 && char.IsUpper(name[index]))
                builder.Append('-');
            builder.Append(char.ToLowerInvariant(name[index]));
        }

        return builder.ToString();
    }

    private static void AppendWithLength(IncrementalHash hash, byte[] bytes)
    {
        var prefix = new byte[sizeof(int)];
        BinaryPrimitives.WriteInt32LittleEndian(prefix, bytes.Length);
        hash.AppendData(prefix);
        hash.AppendData(bytes);
    }

    private static T Read<T>(object item, string property) =>
        (T)item.GetType().GetProperty(property)!.GetValue(item)!;

    private static IEnumerable CorpusTable(string property) =>
        (IEnumerable)CorpusType.GetProperty(property, PublicStatic)!.GetValue(null)!;

    private static (string Name, MathBlockValue Value, int Spare)[] ValueCases() =>
        CorpusTable("Values").Cast<object>()
            .Select(item => (Read<string>(item, "Name"), Read<MathBlockValue>(item, "Value"), Read<int>(item, "SpareCapacity")))
            .ToArray();

    private static (string Name, MathBlockType Type, int Capacity, bool Valid)[] HeaderCases() =>
        CorpusTable("Headers").Cast<object>()
            .Select(item => (Read<string>(item, "Name"), Read<MathBlockType>(item, "Type"), Read<int>(item, "Capacity"), Read<bool>(item, "Valid")))
            .ToArray();

    private static (string Name, MathBlockType Type, MathBlockCudaSlotDescriptor Slot, double[] Payload)[] ReadCases() =>
        CorpusTable("Reads").Cast<object>()
            .Select(item => (Read<string>(item, "Name"), Read<MathBlockType>(item, "Type"), Read<MathBlockCudaSlotDescriptor>(item, "Slot"), Read<double[]>(item, "Payload")))
            .ToArray();

    private static (string Name, byte[] Bytes)[] EncodedEntries() =>
        ((IEnumerable)ContractHashType.GetMethod("EncodeCorpus", PublicStatic)!.Invoke(null, null)!).Cast<object>()
            .Select(item => (Read<string>(item, "Name"), Read<byte[]>(item, "Bytes")))
            .ToArray();

    private static string LibraryHash(string version, string schemaFingerprint, (string Name, byte[] Bytes)[] entries)
    {
        var entryType = ContractHashType.GetNestedType("EncodedEntry", BindingFlags.Public | BindingFlags.NonPublic)!;
        var list = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(entryType))!;
        foreach (var (name, bytes) in entries)
            list.Add(Activator.CreateInstance(entryType, name, bytes)!);
        return (string)ContractHashType.GetMethod("CreateCodecImplementation", PublicStatic)!
            .Invoke(null, [version, schemaFingerprint, list])!;
    }

    private static byte[] WriteThroughThePublicCodec(MathBlockValue value, int capacity, ulong dataPointer, ulong scratchPointer)
    {
        var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
        var byteCount = MathBlockCudaSlotLayout.Size + payloadBytes;
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            Marshal.Copy(new byte[byteCount], 0, arena, byteCount);
            MathBlockCudaValueCodec.WriteValue(
                arena,
                0,
                payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                dataPointer,
                scratchPointer,
                capacity,
                value);
            var bytes = new byte[byteCount];
            Marshal.Copy(arena, bytes, 0, byteCount);
            return bytes;
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }
}
