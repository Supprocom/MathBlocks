using System.Buffers;
using System.Text;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockOpenMathInputTests
{
    [Fact]
    public void Character_and_UTF8_inputs_share_the_string_result()
    {
        var program = CreateSampleProgram("left-α");
        var text = MathBlockOpenMath.Export(program);
        var bytes = Encoding.UTF8.GetBytes(text);
        var expected = MathBlockOpenMath.Import(text);

        using var characterReader = new StringReader(text);
        var fromCharacters = MathBlockOpenMath.Read(characterReader);
        var fromBytes = MathBlockOpenMath.ImportUtf8(bytes);
        var fromSequence = MathBlockOpenMath.ImportUtf8(CreateSequence(bytes));

        using var stream = new ChunkedReadStream(bytes, 1, false);
        var fromStream = MathBlockOpenMath.ReadUtf8(stream);

        Assert.Equal(expected.Program.Fingerprint, fromCharacters.Program.Fingerprint);
        Assert.Equal(expected.Program.Fingerprint, fromBytes.Program.Fingerprint);
        Assert.Equal(expected.Program.Fingerprint, fromSequence.Program.Fingerprint);
        Assert.Equal(expected.Program.Fingerprint, fromStream.Program.Fingerprint);
        Assert.Equal(expected.Operations, fromCharacters.Operations);
        Assert.Equal(expected.Operations, fromBytes.Operations);
        Assert.Equal(expected.Operations, fromSequence.Operations);
        Assert.Equal(expected.Operations, fromStream.Operations);
        Assert.True(stream.CanRead);
        Assert.Equal(bytes.Length, stream.Position);
    }

    [Fact]
    public void UTF8_inputs_accept_a_BOM_and_reject_other_encodings()
    {
        var text = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var bytes = Encoding.UTF8.GetBytes(text);
        var withBom = new byte[bytes.Length + 3];
        new byte[] { 0xEF, 0xBB, 0xBF }.CopyTo(withBom, 0);
        bytes.CopyTo(withBom, 3);

        var imported = MathBlockOpenMath.ImportUtf8(withBom);

        Assert.Equal(text, MathBlockOpenMath.Export(imported.Program));
        Assert.Equal(
            "The OpenMath byte source uses an unsupported encoding.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.ImportUtf8(Encoding.Unicode.GetBytes(text))).Message);
        Assert.Equal(
            "The OpenMath byte source uses an unsupported encoding.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.ImportUtf8(Encoding.BigEndianUnicode.GetBytes(text))).Message);
        Assert.Equal(
            "The OpenMath byte source uses an unsupported encoding.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.ImportUtf8([0x00, 0x00, 0x00, 0x3C])).Message);
        Assert.Equal(
            "The OpenMath byte source uses an unsupported encoding.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.ImportUtf8([0x4C, 0x6F, 0xA7, 0x94])).Message);

        var malformed = bytes.ToArray();
        malformed[10] = 0xFF;
        Assert.Equal(
            "The OpenMath UTF-8 source is invalid.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.ImportUtf8(malformed)).Message);

        var unsupportedDeclaration = Encoding.UTF8.GetBytes(
            string.Concat("<?xml version=\"1.0\" encoding=\"utf-16\"?>", text));
        Assert.Equal(
            "The OpenMath byte source uses an unsupported encoding.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.ImportUtf8(unsupportedDeclaration)).Message);

        Assert.Equal(
            "The OpenMath source must use the canonical form.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.ImportUtf8(
                withBom,
                new MathBlockOpenMathImportOptions { RequireCanonicalSource = true })).Message);
    }

    [Fact]
    public void Input_options_enforce_each_resource_limit()
    {
        var program = CreateSampleProgram("left");
        var text = MathBlockOpenMath.Export(program);
        var bytes = Encoding.UTF8.GetBytes(text);

        Assert.Equal(
            "The OpenMath source exceeds the character limit.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(
                text,
                new MathBlockOpenMathImportOptions
                {
                    MaximumDocumentCharacters = text.Length - 1
                })).Message);
        Assert.Equal(
            "The OpenMath source exceeds the byte limit.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.ImportUtf8(
                bytes,
                new MathBlockOpenMathImportOptions
                {
                    MaximumDocumentBytes = bytes.Length - 1
                })).Message);
        Assert.Equal(
            "The OpenMath source exceeds the node limit.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(
                text,
                new MathBlockOpenMathImportOptions
                {
                    MaximumNodes = program.PlanNodes.Count - 1
                })).Message);
        Assert.Equal(
            "The OpenMath source exceeds the output limit.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(
                text,
                new MathBlockOpenMathImportOptions
                {
                    MaximumOutputs = program.Outputs.Count - 1
                })).Message);

        var values = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var vector = values.Constant(MathBlockValue.Vector([1d, 2d, 3d]));
        var valueSource = MathBlockOpenMath.Export(values.Output("value", vector).Build());
        Assert.Equal(
            "The OpenMath source exceeds the value-element limit.",
            Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(
                valueSource,
                new MathBlockOpenMathImportOptions
                {
                    MaximumValueElements = 2
                })).Message);

        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockOpenMath.Import(
            text,
            new MathBlockOpenMathImportOptions { MaximumNodes = 0 }));

        using var unread = new ChunkedReadStream(bytes, 1, false);
        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockOpenMath.ReadUtf8(
            unread,
            new MathBlockOpenMathImportOptions { MaximumNodes = 0 }));
        Assert.Equal(0, unread.SynchronousReads);
        Assert.Equal(0, unread.Position);
    }

    [Fact]
    public void Canonical_source_options_reject_valid_noncanonical_input()
    {
        var text = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var noncanonical = string.Concat("\n", text);
        var options = new MathBlockOpenMathImportOptions { RequireCanonicalSource = true };

        Assert.Equal(
            "The OpenMath source must use the canonical form.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.Import(noncanonical, options)).Message);
        Assert.Equal(
            "The OpenMath source must use the canonical form.",
            Assert.Throws<FormatException>(
                () => MathBlockOpenMath.ImportUtf8(Encoding.UTF8.GetBytes(noncanonical), options))
                .Message);

        using var textReader = new StringReader(noncanonical);
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Read(textReader, options));
        using var byteStream = new MemoryStream(Encoding.UTF8.GetBytes(noncanonical));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.ReadUtf8(byteStream, options));

        Assert.Equal(
            text,
            MathBlockOpenMath.Export(MathBlockOpenMath.Import(text, options).Program));
    }

    [Fact]
    public void Import_reports_operation_occurrences_and_optional_source_locations()
    {
        var text = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var withoutLocations = MathBlockOpenMath.Import(text);
        var imported = MathBlockOpenMath.Import(
            text,
            new MathBlockOpenMathImportOptions { CaptureSourceLocations = true });

        Assert.Null(withoutLocations.SourceLocations);
        Assert.Equal(2, imported.OperationOccurrences.Count);
        Assert.Equal(0, imported.OperationOccurrences[0].Ordinal);
        Assert.Equal(2, imported.OperationOccurrences[0].NodeIndex);
        Assert.Equal("scalar.add@1", imported.OperationOccurrences[0].Operation.Identity);
        Assert.Equal(
            new MathBlockOpenMathOperationSymbol(
                "mathblocks_operations1",
                "op.scalar.add.v1"),
            imported.OperationOccurrences[0].Symbol);
        Assert.Equal(1, imported.OperationOccurrences[1].Ordinal);
        Assert.Equal(3, imported.OperationOccurrences[1].NodeIndex);

        var locations = Assert.IsAssignableFrom<
            IReadOnlyDictionary<string, MathBlockOpenMathSourceLocation>>(
                imported.SourceLocations);
        Assert.Equal(8, locations.Count);
        Assert.Equal("/program/nodes/n2/operation", locations["/program/nodes/n2/operation"].ProfilePath);
        Assert.Equal(1, locations["/program/nodes/n2/operation"].Line);
        Assert.True(locations["/program/nodes/n2/operation"].Column > 0);
        Assert.Equal(1, locations["/program/outputs/0"].Line);
    }

    [Fact]
    public async Task Async_inputs_use_async_IO_and_honor_cancellation()
    {
        var text = MathBlockOpenMath.Export(CreateSampleProgram("left-α"));
        var bytes = Encoding.UTF8.GetBytes(text);

        await using var stream = new ChunkedReadStream(bytes, 1, true);
        var fromStream = await MathBlockOpenMath.ReadUtf8Async(stream);
        Assert.Equal(text, MathBlockOpenMath.Export(fromStream.Program));
        Assert.Equal(0, stream.SynchronousReads);
        Assert.True(stream.AsynchronousReads > 0);
        Assert.True(stream.CanRead);

        using var reader = new AsyncOnlyTextReader(text, 1);
        var fromCharacters = await MathBlockOpenMath.ReadAsync(reader);
        Assert.Equal(text, MathBlockOpenMath.Export(fromCharacters.Program));
        Assert.Equal(0, reader.SynchronousReads);
        Assert.True(reader.AsynchronousReads > 0);

        using var cancellation = new CancellationTokenSource();
        cancellation.Cancel();
        await Assert.ThrowsAnyAsync<OperationCanceledException>(
            () => MathBlockOpenMath.ReadUtf8Async(
                new ChunkedReadStream(bytes, 1, true),
                cancellationToken: cancellation.Token));
    }

    [Fact]
    public async Task Nonthrowing_inputs_return_one_stable_diagnostic()
    {
        var nullAttempt = MathBlockOpenMath.TryImport(null);
        Assert.False(nullAttempt.Succeeded);
        Assert.Null(nullAttempt.Result);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.SourceNull, nullAttempt.Diagnostic?.Code);

        var malformed = MathBlockOpenMath.TryImport("<OMOBJ>");
        Assert.False(malformed.Succeeded);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.InvalidXml, malformed.Diagnostic?.Code);
        Assert.NotNull(malformed.Diagnostic?.Line);
        Assert.NotNull(malformed.Diagnostic?.Column);

        var text = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var foreign = text.Replace(
            "cd=\"mathblocks_operations1\" name=\"op.scalar.add.v1\"",
            "cd=\"arith1\" name=\"plus\"",
            StringComparison.Ordinal);
        var operation = MathBlockOpenMath.TryImport(foreign);
        var diagnostic = Assert.IsType<MathBlockOpenMathDiagnostic>(operation.Diagnostic);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.UnsupportedOperationSymbol, diagnostic.Code);
        Assert.Equal(2, diagnostic.NodeIndex);
        Assert.Equal("/program/nodes/n2", diagnostic.ProfilePath);
        Assert.Equal("arith1", diagnostic.Dictionary);
        Assert.Equal("plus", diagnostic.Symbol);
        Assert.NotNull(diagnostic.Line);
        Assert.DoesNotContain(foreign, diagnostic.ToString(), StringComparison.Ordinal);

        var forward = text.Replace("href=\"#n0\"", "href=\"#n3\"", StringComparison.Ordinal);
        Assert.Equal(
            MathBlockOpenMathDiagnosticCode.ForwardReference,
            MathBlockOpenMath.TryImport(forward).Diagnostic?.Code);

        var missingOutput = text.Replace(
            "<OMSTR>sum</OMSTR><OMR href=\"#n2\"></OMR>",
            "<OMSTR>sum</OMSTR><OMR href=\"#n99\"></OMR>",
            StringComparison.Ordinal);
        Assert.Equal(
            MathBlockOpenMathDiagnosticCode.InvalidReference,
            MathBlockOpenMath.TryImport(missingOutput).Diagnostic?.Code);

        var success = MathBlockOpenMath.TryImportUtf8(Encoding.UTF8.GetBytes(text));
        Assert.True(success.Succeeded);
        Assert.NotNull(success.Result);
        Assert.Null(success.Diagnostic);

        using var cancellation = new CancellationTokenSource();
        cancellation.Cancel();
        await Assert.ThrowsAnyAsync<OperationCanceledException>(() =>
            MathBlockOpenMath.TryReadUtf8Async(
                new ChunkedReadStream(Encoding.UTF8.GetBytes(text), 1, true),
                cancellationToken: cancellation.Token));

        var malformedBytes = Encoding.UTF8.GetBytes(text);
        malformedBytes[10] = 0xFF;
        await using var malformedStream = new ChunkedReadStream(malformedBytes, 1, true);
        var malformedAttempt = await MathBlockOpenMath.TryReadUtf8Async(malformedStream);
        Assert.Equal(
            MathBlockOpenMathDiagnosticCode.InvalidUtf8,
            malformedAttempt.Diagnostic?.Code);
    }

    [Fact]
    public void Stream_and_character_inputs_leave_their_sources_open_after_failure()
    {
        using var stream = new ChunkedReadStream([0xFF], 1, false);
        Assert.Throws<FormatException>(() => MathBlockOpenMath.ReadUtf8(stream));
        Assert.True(stream.CanRead);

        using var reader = new StringReader("<invalid>");
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Read(reader));
        Assert.Equal(-1, reader.Peek());
    }

    [Fact]
    public void Every_operation_round_trips_through_contiguous_UTF8_input()
    {
        Assert.Equal(337, MathBlockCatalog.Standard.Operations.Count);
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var regression = operation.RegressionCases[0];
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var inputs = new int[regression.Inputs.Count];
            for (var index = 0; index < inputs.Length; index++)
                inputs[index] = builder.Constant(regression.Inputs[index]);
            var result = builder.Apply(operation.Identifier, operation.Version, inputs);
            var program = builder.Output("result", result).Build();
            var imported = MathBlockOpenMath.ImportUtf8(MathBlockOpenMath.ExportUtf8(program));

            Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
            Assert.Same(operation, Assert.Single(imported.Operations));
        }
    }

    private static MathBlockProgram CreateSampleProgram(string leftName)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input(leftName, MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
        return builder.Output("sum", sum).Output("square", square).Build();
    }

    private static ReadOnlySequence<byte> CreateSequence(byte[] source)
    {
        ByteSegment? first = null;
        ByteSegment? last = null;
        for (var index = 0; index < source.Length; index++)
        {
            var segment = new ByteSegment(source.AsMemory(index, 1));
            if (first is null)
                first = segment;
            else
                last!.Append(segment);
            last = segment;
        }
        return new ReadOnlySequence<byte>(first!, 0, last!, 1);
    }

    private sealed class ByteSegment : ReadOnlySequenceSegment<byte>
    {
        public ByteSegment(ReadOnlyMemory<byte> memory)
        {
            Memory = memory;
        }

        public void Append(ByteSegment segment)
        {
            segment.RunningIndex = RunningIndex + Memory.Length;
            Next = segment;
        }
    }

    private sealed class ChunkedReadStream(
        byte[] source,
        int maximumChunk,
        bool asyncOnly) : Stream
    {
        private bool open = true;
        private int position;

        public int SynchronousReads { get; private set; }
        public int AsynchronousReads { get; private set; }
        public override bool CanRead => open;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => source.Length;
        public override long Position
        {
            get => position;
            set => throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            Read(buffer.AsSpan(offset, count));

        public override int Read(Span<byte> buffer)
        {
            SynchronousReads++;
            if (asyncOnly)
                throw new InvalidOperationException("Synchronous input is not permitted.");
            return Copy(buffer);
        }

        public override Task<int> ReadAsync(
            byte[] buffer,
            int offset,
            int count,
            CancellationToken cancellationToken) =>
            ReadAsync(buffer.AsMemory(offset, count), cancellationToken).AsTask();

        public override ValueTask<int> ReadAsync(
            Memory<byte> buffer,
            CancellationToken cancellationToken = default)
        {
            AsynchronousReads++;
            cancellationToken.ThrowIfCancellationRequested();
            return ValueTask.FromResult(Copy(buffer.Span));
        }

        protected override void Dispose(bool disposing)
        {
            open = false;
            base.Dispose(disposing);
        }

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();

        private int Copy(Span<byte> destination)
        {
            var count = Math.Min(Math.Min(destination.Length, maximumChunk), source.Length - position);
            source.AsSpan(position, count).CopyTo(destination);
            position += count;
            return count;
        }
    }

    private sealed class AsyncOnlyTextReader(string source, int maximumChunk) : TextReader
    {
        private int position;

        public int SynchronousReads { get; private set; }
        public int AsynchronousReads { get; private set; }

        public override int Peek()
        {
            SynchronousReads++;
            throw new InvalidOperationException("Synchronous input is not permitted.");
        }

        public override int Read(char[] buffer, int index, int count)
        {
            SynchronousReads++;
            throw new InvalidOperationException("Synchronous input is not permitted.");
        }

        public override ValueTask<int> ReadAsync(
            Memory<char> buffer,
            CancellationToken cancellationToken = default)
        {
            AsynchronousReads++;
            cancellationToken.ThrowIfCancellationRequested();
            var count = Math.Min(
                Math.Min(buffer.Length, maximumChunk),
                source.Length - position);
            source.AsMemory(position, count).CopyTo(buffer);
            position += count;
            return ValueTask.FromResult(count);
        }
    }
}
