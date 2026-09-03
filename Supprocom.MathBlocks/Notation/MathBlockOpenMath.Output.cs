using System.Buffers;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

public static partial class MathBlockOpenMath
{
    private static readonly Encoding StrictUtf8 = new UTF8Encoding(false, true);

    public static byte[] ExportUtf8(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);

        var byteCount = GetUtf8ByteCount(program);
        var result = new byte[byteCount];
        using var stream = new MemoryStream(result, 0, result.Length, true, true);
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program);
        writer.Flush();
        return result;
    }

    public static int GetUtf8ByteCount(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);

        using var stream = new CountingWriteStream();
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program);
        writer.Flush();
        return stream.ByteCount;
    }

    public static unsafe bool TryWriteUtf8(
        MathBlockProgram program,
        Span<byte> destination,
        out int bytesWritten)
    {
        ArgumentNullException.ThrowIfNull(program);

        var byteCount = GetUtf8ByteCount(program);
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
            WriteDocument(writer, program);
            writer.Flush();
        }

        bytesWritten = byteCount;
        return true;
    }

    public static void WriteUtf8(
        MathBlockProgram program,
        IBufferWriter<byte> destination)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);

        _ = GetUtf8ByteCount(program);
        using var stream = new BufferWriterStream(destination);
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program);
        writer.Flush();
    }

    public static void WriteUtf8(MathBlockProgram program, Stream destination)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream is not writable.", nameof(destination));

        _ = GetUtf8ByteCount(program);
        using var writer = XmlWriter.Create(destination, CreateWriterSettings(StrictUtf8));
        WriteDocument(writer, program);
        writer.Flush();
    }

    public static void Write(MathBlockProgram program, TextWriter destination)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);

        _ = GetUtf8ByteCount(program);
        using var writer = XmlWriter.Create(destination, CreateWriterSettings());
        WriteDocument(writer, program);
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
