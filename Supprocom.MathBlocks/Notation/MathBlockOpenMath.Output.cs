using System.Buffers;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

public static partial class MathBlockOpenMath
{
    private static readonly Encoding StrictUtf8 = new UTF8Encoding(false, true);

    /// <summary>Exports a typed program as canonical UTF-8 bytes in its lowest covering profile.</summary>
    public static byte[] ExportUtf8(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);
        return ExportUtf8Core(program, SelectProfile(program, PublishedProfiles));
    }

    /// <summary>Exports a typed program as canonical UTF-8 bytes in the specified profile.</summary>
    public static byte[] ExportUtf8(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        RequireExportProfile(program, profile);
        return ExportUtf8Core(program, profile);
    }

    /// <summary>Gets the exact canonical UTF-8 byte count in the program's lowest covering profile.</summary>
    public static int GetUtf8ByteCount(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);
        return GetUtf8ByteCountCore(program, SelectProfile(program, PublishedProfiles));
    }

    /// <summary>Gets the exact canonical UTF-8 byte count in the specified profile.</summary>
    public static int GetUtf8ByteCount(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        RequireExportProfile(program, profile);
        return GetUtf8ByteCountCore(program, profile);
    }

    /// <summary>Tries to write canonical UTF-8 into a supplied destination.</summary>
    public static bool TryWriteUtf8(
        MathBlockProgram program,
        Span<byte> destination,
        out int bytesWritten)
    {
        ArgumentNullException.ThrowIfNull(program);
        return TryWriteUtf8Core(
            program,
            SelectProfile(program, PublishedProfiles),
            destination,
            out bytesWritten);
    }

    /// <summary>Tries to write canonical UTF-8 in the specified profile into a supplied destination.</summary>
    public static bool TryWriteUtf8(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        Span<byte> destination,
        out int bytesWritten)
    {
        RequireExportProfile(program, profile);
        return TryWriteUtf8Core(program, profile, destination, out bytesWritten);
    }

    /// <summary>Writes canonical UTF-8 through a caller-owned buffer writer.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        IBufferWriter<byte> destination)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);
        WriteUtf8Core(program, SelectProfile(program, PublishedProfiles), destination);
    }

    /// <summary>Writes canonical UTF-8 in the specified profile through a caller-owned buffer writer.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        IBufferWriter<byte> destination)
    {
        RequireExportProfile(program, profile);
        ArgumentNullException.ThrowIfNull(destination);
        WriteUtf8Core(program, profile, destination);
    }

    /// <summary>Writes canonical UTF-8 to a caller-owned stream.</summary>
    public static void WriteUtf8(MathBlockProgram program, Stream destination)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream is not writable.", nameof(destination));
        WriteUtf8Core(program, SelectProfile(program, PublishedProfiles), destination);
    }

    /// <summary>Writes canonical UTF-8 in the specified profile to a caller-owned stream.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        Stream destination)
    {
        RequireExportProfile(program, profile);
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream is not writable.", nameof(destination));
        WriteUtf8Core(program, profile, destination);
    }

    /// <summary>Writes canonical characters to a caller-owned text writer.</summary>
    public static void Write(MathBlockProgram program, TextWriter destination)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);
        WriteCore(program, SelectProfile(program, PublishedProfiles), destination);
    }

    /// <summary>Writes canonical characters in the specified profile to a caller-owned text writer.</summary>
    public static void Write(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        TextWriter destination)
    {
        RequireExportProfile(program, profile);
        ArgumentNullException.ThrowIfNull(destination);
        WriteCore(program, profile, destination);
    }

    private static void RequireExportProfile(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(profile);
        RequireProfileOperations(program, profile);
    }

    private static byte[] ExportUtf8Core(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        var byteCount = GetUtf8ByteCountCore(program, profile);
        var result = new byte[byteCount];
        using var stream = new MemoryStream(result, 0, result.Length, true, true);
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program, profile);
        writer.Flush();
        return result;
    }

    private static int GetUtf8ByteCountCore(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        using var stream = new CountingWriteStream();
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program, profile);
        writer.Flush();
        return stream.ByteCount;
    }

    private static unsafe bool TryWriteUtf8Core(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        Span<byte> destination,
        out int bytesWritten)
    {
        var byteCount = GetUtf8ByteCountCore(program, profile);
        if (destination.Length < byteCount)
        {
            bytesWritten = 0;
            return false;
        }

        fixed (byte* pointer = destination)
        {
            using var stream = new UnmanagedMemoryStream(
                pointer,
                0,
                byteCount,
                FileAccess.Write);
            using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
            WriteDocument(writer, program, profile);
            writer.Flush();
        }

        bytesWritten = byteCount;
        return true;
    }

    private static void WriteUtf8Core(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        IBufferWriter<byte> destination)
    {
        _ = GetUtf8ByteCountCore(program, profile);
        using var stream = new BufferWriterStream(destination);
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program, profile);
        writer.Flush();
    }

    private static void WriteUtf8Core(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        Stream destination)
    {
        _ = GetUtf8ByteCountCore(program, profile);
        using var writer = XmlWriter.Create(destination, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program, profile);
        writer.Flush();
    }

    private static void WriteCore(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile,
        TextWriter destination)
    {
        _ = GetUtf8ByteCountCore(program, profile);
        using var writer = XmlWriter.Create(destination, CreateWriterSettings());
        WriteDocument(writer, program, profile);
        writer.Flush();
    }

    private sealed class CountingWriteStream : Stream
    {
        public int ByteCount { get; private set; }

        public override bool CanRead => false;
        public override bool CanSeek => false;
        public override bool CanWrite => true;
        public override long Length => ByteCount;
        public override long Position
        {
            get => ByteCount;
            set => throw new NotSupportedException();
        }

        public override void Flush()
        {
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            ArgumentNullException.ThrowIfNull(buffer);
            ArgumentOutOfRangeException.ThrowIfNegative(offset);
            ArgumentOutOfRangeException.ThrowIfNegative(count);
            if (offset > buffer.Length - count)
                throw new ArgumentException("The buffer range is invalid.", nameof(buffer));
            ByteCount = checked(ByteCount + count);
        }

        public override void Write(ReadOnlySpan<byte> buffer) =>
            ByteCount = checked(ByteCount + buffer.Length);

        public override void WriteByte(byte value) => ByteCount = checked(ByteCount + 1);

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();

        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();

        public override void SetLength(long value) => throw new NotSupportedException();
    }

    private sealed class BufferWriterStream(IBufferWriter<byte> destination) : Stream
    {
        public override bool CanRead => false;
        public override bool CanSeek => false;
        public override bool CanWrite => true;
        public override long Length => throw new NotSupportedException();
        public override long Position
        {
            get => throw new NotSupportedException();
            set => throw new NotSupportedException();
        }

        public override void Flush()
        {
        }

        public override void Write(byte[] buffer, int offset, int count)
        {
            ArgumentNullException.ThrowIfNull(buffer);
            ArgumentOutOfRangeException.ThrowIfNegative(offset);
            ArgumentOutOfRangeException.ThrowIfNegative(count);
            if (offset > buffer.Length - count)
                throw new ArgumentException("The buffer range is invalid.", nameof(buffer));
            Write(buffer.AsSpan(offset, count));
        }

        public override void Write(ReadOnlySpan<byte> buffer)
        {
            while (!buffer.IsEmpty)
            {
                var target = destination.GetSpan(buffer.Length);
                if (target.IsEmpty)
                    throw new InvalidOperationException("The buffer writer returned an empty span.");
                var count = Math.Min(target.Length, buffer.Length);
                buffer[..count].CopyTo(target);
                destination.Advance(count);
                buffer = buffer[count..];
            }
        }

        public override void WriteByte(byte value)
        {
            var target = destination.GetSpan(1);
            if (target.IsEmpty)
                throw new InvalidOperationException("The buffer writer returned an empty span.");
            target[0] = value;
            destination.Advance(1);
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();

        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();

        public override void SetLength(long value) => throw new NotSupportedException();
    }
}
