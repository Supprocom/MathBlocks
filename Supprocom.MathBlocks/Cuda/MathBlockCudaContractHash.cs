using System.Buffers.Binary;
using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlockCudaContractHash
{
    public static string Create(string value) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value)));

    public static string CreateValue(MathBlockValue value) =>
        Convert.ToHexString(SHA256.HashData(EncodeValue(
            value,
            value.IsValid ? MathBlockCudaValueCodec.GetElementCount(value) : 0,
            0ul,
            0ul)));

    /// <summary>Writes a value into a zeroed slot and payload with the codec's write path and returns every byte.</summary>
    public static unsafe byte[] EncodeValue(MathBlockValue value, int capacity, ulong dataPointer, ulong scratchPointer)
    {
        var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
        var byteCount = checked(MathBlockCudaSlotLayout.Size + payloadBytes);
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            new Span<byte>((void*)arena, byteCount).Clear();
            MathBlockCudaValueCodec.WriteValue(
                arena,
                0,
                payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                dataPointer,
                scratchPointer,
                capacity,
                value);
            return Copy(arena, byteCount);
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }

    /// <summary>Writes a slot header with the codec's header path and returns its bytes.</summary>
    public static unsafe byte[] EncodeHeader(
        MathBlockType type,
        int capacity,
        bool valid,
        ulong dataPointer,
        ulong scratchPointer)
    {
        var arena = Marshal.AllocHGlobal(MathBlockCudaSlotLayout.Size);
        try
        {
            new Span<byte>((void*)arena, MathBlockCudaSlotLayout.Size).Clear();
            MathBlockCudaValueCodec.WriteHeader(arena, 0, dataPointer, scratchPointer, capacity, type, valid);
            return Copy(arena, MathBlockCudaSlotLayout.Size);
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }

    /// <summary>
    /// Writes a value, reads it back with the codec's read path and writes the result again; returns both byte
    /// sequences, or the name of the exception type where the codec rejects the case.
    /// </summary>
    public static unsafe (byte[] Written, byte[] ReadBack) EncodeValueAndReadBack(
        MathBlockValue value,
        int capacity,
        ulong dataPointer,
        ulong scratchPointer)
    {
        var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
        var byteCount = checked(MathBlockCudaSlotLayout.Size + payloadBytes);
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            new Span<byte>((void*)arena, byteCount).Clear();
            var payloadOffset = payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size;
            MathBlockCudaValueCodec.WriteValue(arena, 0, payloadOffset, dataPointer, scratchPointer, capacity, value);
            var written = Copy(arena, byteCount);
            var read = MathBlockCudaValueCodec.ReadValue(arena, 0, payloadOffset, value.Type);
            return (written, EncodeValue(read, capacity, dataPointer, scratchPointer));
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }

    /// <summary>Places a device-style slot and payload in an arena, reads it with the codec and writes the result.</summary>
    public static unsafe byte[] EncodeRead(
        MathBlockType type,
        MathBlockCudaSlotDescriptor slot,
        double[] payload,
        ulong dataPointer,
        ulong scratchPointer)
    {
        var byteCount = checked(MathBlockCudaSlotLayout.Size + (payload.Length * sizeof(double)));
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            new Span<byte>((void*)arena, byteCount).Clear();
            *(MathBlockCudaSlotDescriptor*)arena = slot;
            if (payload.Length != 0)
                Marshal.Copy(payload, 0, arena + MathBlockCudaSlotLayout.Size, payload.Length);
            var read = MathBlockCudaValueCodec.ReadValue(
                arena,
                0,
                payload.Length == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                type);
            return EncodeValue(
                read,
                read.IsValid ? MathBlockCudaValueCodec.GetElementCount(read) : 0,
                dataPointer,
                scratchPointer);
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }

    /// <summary>
    /// Runs every case of the corpus through the codec's real write, header and read paths and returns the bytes per
    /// entry, in the order of the corpus. A case the codec rejects is recorded as the exception type's name.
    /// </summary>
    public static List<EncodedEntry> EncodeCorpus()
    {
        var entries = new List<EncodedEntry>(
            (MathBlockCudaValueCodecCorpus.Values.Length * 2) +
            MathBlockCudaValueCodecCorpus.Headers.Length +
            MathBlockCudaValueCodecCorpus.Reads.Length);
        foreach (var item in MathBlockCudaValueCodecCorpus.Values)
        {
            var count = item.Value.IsValid ? MathBlockCudaValueCodec.GetElementCount(item.Value) : 0;
            try
            {
                var (written, readBack) = EncodeValueAndReadBack(
                    item.Value,
                    count + item.SpareCapacity,
                    MathBlockCudaValueCodecCorpus.DataPointer,
                    MathBlockCudaValueCodecCorpus.ScratchPointer);
                entries.Add(new EncodedEntry(item.Name, written));
                entries.Add(new EncodedEntry(item.Name + "#read", readBack));
            }
            catch (ArgumentException exception)
            {
                entries.Add(new EncodedEntry(item.Name, Rejected(exception)));
            }
        }

        foreach (var item in MathBlockCudaValueCodecCorpus.Headers)
        {
            entries.Add(new EncodedEntry(
                item.Name,
                EncodeHeader(
                    item.Type,
                    item.Capacity,
                    item.Valid,
                    MathBlockCudaValueCodecCorpus.DataPointer,
                    MathBlockCudaValueCodecCorpus.ScratchPointer)));
        }

        foreach (var item in MathBlockCudaValueCodecCorpus.Reads)
        {
            try
            {
                entries.Add(new EncodedEntry(
                    item.Name,
                    EncodeRead(
                        item.Type,
                        item.Slot,
                        item.Payload,
                        MathBlockCudaValueCodecCorpus.DataPointer,
                        MathBlockCudaValueCodecCorpus.ScratchPointer)));
            }
            catch (ArgumentException exception)
            {
                entries.Add(new EncodedEntry(item.Name, Rejected(exception)));
            }
            catch (InvalidOperationException exception)
            {
                entries.Add(new EncodedEntry(item.Name, Rejected(exception)));
            }
        }

        return entries;
    }

    /// <summary>
    /// Hashes the codec implementation: SHA-256 over the corpus version, the codec schema fingerprint and, for every
    /// entry in order, its name and its bytes. Every text and byte sequence is preceded by its length as a
    /// little-endian 32-bit integer.
    /// </summary>
    public static string CreateCodecImplementation(
        string corpusVersion,
        string schemaFingerprint,
        List<EncodedEntry> entries)
    {
        ArgumentNullException.ThrowIfNull(entries);
        using var hash = IncrementalHash.CreateHash(HashAlgorithmName.SHA256);
        AppendBytes(hash, Encoding.UTF8.GetBytes(corpusVersion));
        AppendBytes(hash, Encoding.UTF8.GetBytes(schemaFingerprint));
        for (var index = 0; index < entries.Count; index++)
        {
            AppendBytes(hash, Encoding.UTF8.GetBytes(entries[index].Name));
            AppendBytes(hash, entries[index].Bytes);
        }

        return Convert.ToHexString(hash.GetHashAndReset());
    }

    private static void AppendBytes(IncrementalHash hash, byte[] bytes)
    {
        var prefix = new byte[sizeof(int)];
        BinaryPrimitives.WriteInt32LittleEndian(prefix, bytes.Length);
        hash.AppendData(prefix);
        hash.AppendData(bytes);
    }

    private static byte[] Rejected(Exception exception) =>
        Encoding.UTF8.GetBytes("rejected:" + exception.GetType().FullName);

    private static byte[] Copy(IntPtr arena, int byteCount)
    {
        var bytes = new byte[byteCount];
        Marshal.Copy(arena, bytes, 0, byteCount);
        return bytes;
    }

    /// <summary>The bytes the codec produced for one corpus entry.</summary>
    /// <param name="Name">The entry name.</param>
    /// <param name="Bytes">The bytes.</param>
    internal sealed record EncodedEntry(string Name, byte[] Bytes);
}
