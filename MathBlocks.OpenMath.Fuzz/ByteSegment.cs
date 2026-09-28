using System.Buffers;

sealed class ByteSegment : ReadOnlySequenceSegment<byte>
{
    public ByteSegment(ReadOnlyMemory<byte> memory) => Memory = memory;

    public void Append(ByteSegment segment)
    {
        segment.RunningIndex = RunningIndex + Memory.Length;
        Next = segment;
    }
}
