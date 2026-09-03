using System.Buffers;
using System.Globalization;
using System.Text;
using System.Xml.Linq;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockOpenMathRobustnessTests
{
    [Fact]
    public void Every_character_and_UTF8_truncation_fails_safely()
    {
        var text = MathBlockOpenMath.Export(CreateSampleProgram("left-α"));
        var bytes = Encoding.UTF8.GetBytes(text);

        for (var length = 0; length < text.Length; length++)
        {
            var attempt = MathBlockOpenMath.TryImport(text[..length]);
            Assert.False(attempt.Succeeded);
            Assert.NotNull(attempt.Diagnostic);
        }
        for (var length = 0; length < bytes.Length; length++)
        {
            var attempt = MathBlockOpenMath.TryImportUtf8(bytes.AsSpan(0, length));
            Assert.False(attempt.Succeeded);
            Assert.NotNull(attempt.Diagnostic);
        }

        Assert.True(MathBlockOpenMath.TryImport(text).Succeeded);
        Assert.True(MathBlockOpenMath.TryImportUtf8(bytes).Succeeded);
    }

    [Fact]
    public void UTF8_reader_rejects_each_malformed_sequence_class()
    {
        byte[][] malformed =
        [
            [0x80],
            [0xC0, 0xAF],
            [0xE0, 0x80, 0xAF],
            [0xED, 0xA0, 0x80],
            [0xF0, 0x80, 0x80, 0xAF],
            [0xF4, 0x90, 0x80, 0x80],
            [0xF5, 0x80, 0x80, 0x80],
            [0xC2],
            [0xE2, 0x82],
            [0xF0, 0x9F, 0x92]
        ];

        foreach (var source in malformed)
        {
            var contiguous = MathBlockOpenMath.TryImportUtf8(source);
            var segmented = MathBlockOpenMath.TryImportUtf8(CreateSequence(source, 1));
            AssertCode(contiguous, MathBlockOpenMathDiagnosticCode.InvalidUtf8);
            AssertCode(segmented, MathBlockOpenMathDiagnosticCode.InvalidUtf8);
        }

        var canonical = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var declared = Encoding.UTF8.GetBytes(
            string.Concat("<?xml version=\"1.0\" encoding=\"UTF-8\"?>", canonical));
        Assert.Equal(
            canonical,
            MathBlockOpenMath.Export(MathBlockOpenMath.ImportUtf8(declared).Program));
    }

    [Fact]
    public void Stream_reader_honors_position_trailing_content_and_transport_failures()
    {
        var text = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var bytes = Encoding.UTF8.GetBytes(text);
        var prefixed = new byte[bytes.Length + 7];
        Enumerable.Repeat((byte)0xA5, 7).ToArray().CopyTo(prefixed, 0);
        bytes.CopyTo(prefixed, 7);

        using var positioned = new MemoryStream(prefixed);
        positioned.Position = 7;
        var imported = MathBlockOpenMath.ReadUtf8(positioned);
        Assert.Equal(text, MathBlockOpenMath.Export(imported.Program));
        Assert.Equal(positioned.Length, positioned.Position);
        Assert.True(positioned.CanRead);

        using var whitespace = new MemoryStream(Encoding.UTF8.GetBytes(string.Concat(text, " \t\r\n")));
        Assert.Equal(text, MathBlockOpenMath.Export(MathBlockOpenMath.ReadUtf8(whitespace).Program));

        AssertCode(
            MathBlockOpenMath.TryImportUtf8(Encoding.UTF8.GetBytes(string.Concat(text, "x"))),
            MathBlockOpenMathDiagnosticCode.InvalidXml);
        AssertCode(
            MathBlockOpenMath.TryImportUtf8(Encoding.UTF8.GetBytes(string.Concat(text, text))),
            MathBlockOpenMathDiagnosticCode.InvalidXml);
        Assert.False(MathBlockOpenMath.TryImport(string.Concat(text, "\u00A0")).Succeeded);

        using var failing = new FaultingReadStream(bytes, 16, false);
        var exception = Assert.Throws<IOException>(() => MathBlockOpenMath.TryReadUtf8(failing));
        Assert.Equal("The test transport failed.", exception.Message);
    }

    [Fact]
    public async Task Async_input_uses_async_IO_beyond_its_prefix_and_preserves_failures()
    {
        var program = CreateSampleProgram(new string('α', 5_000));
        var text = MathBlockOpenMath.Export(program);
        var bytes = Encoding.UTF8.GetBytes(text);
        Assert.True(text.Length > 4_096);

        await using var stream = new AsyncOnlyReadStream(bytes, 3);
        var fromBytes = await MathBlockOpenMath.ReadUtf8Async(stream);
        Assert.Equal(program.Fingerprint, fromBytes.Program.Fingerprint);
        Assert.Equal(0, stream.SynchronousReads);
        Assert.True(stream.AsynchronousReads > 1);

        using var reader = new AsyncOnlyCharacterReader(text, 3);
        var fromCharacters = await MathBlockOpenMath.ReadAsync(reader);
        Assert.Equal(program.Fingerprint, fromCharacters.Program.Fingerprint);
        Assert.Equal(0, reader.SynchronousReads);
        Assert.True(reader.AsynchronousReads > 1);

        await using var failing = new FaultingReadStream(bytes, 16, true);
        var exception = await Assert.ThrowsAsync<IOException>(
            () => MathBlockOpenMath.TryReadUtf8Async(failing));
        Assert.Equal("The test transport failed.", exception.Message);

        using var cancellation = new CancellationTokenSource();
        await using var cancelling = new CancellingReadStream(bytes, cancellation, 16);
        await Assert.ThrowsAnyAsync<OperationCanceledException>(
            () => MathBlockOpenMath.ReadUtf8Async(
                cancelling,
                cancellationToken: cancellation.Token));
    }

    [Fact]
    public void Resource_limits_accept_exact_counts_and_reject_the_next_unit()
    {
        var program = CreateSampleProgram("left");
        var text = MathBlockOpenMath.Export(program);
        var bytes = Encoding.UTF8.GetBytes(text);

        Assert.True(MathBlockOpenMath.TryImport(
            text,
            new MathBlockOpenMathImportOptions
            {
                MaximumDocumentCharacters = text.Length,
                MaximumNodes = program.PlanNodes.Count,
                MaximumOutputs = program.Outputs.Count
            }).Succeeded);
        AssertCode(
            MathBlockOpenMath.TryImport(
                text,
                new MathBlockOpenMathImportOptions
                {
                    MaximumDocumentCharacters = text.Length - 1
                }),
            MathBlockOpenMathDiagnosticCode.DocumentCharacterLimitExceeded);
        Assert.True(MathBlockOpenMath.TryImportUtf8(
            bytes,
            new MathBlockOpenMathImportOptions { MaximumDocumentBytes = bytes.Length }).Succeeded);
        AssertCode(
            MathBlockOpenMath.TryImportUtf8(
                bytes,
                new MathBlockOpenMathImportOptions { MaximumDocumentBytes = bytes.Length - 1 }),
            MathBlockOpenMathDiagnosticCode.DocumentByteLimitExceeded);
        AssertCode(
            MathBlockOpenMath.TryImport(
                text,
                new MathBlockOpenMathImportOptions
                {
                    MaximumNodes = program.PlanNodes.Count - 1
                }),
            MathBlockOpenMathDiagnosticCode.NodeLimitExceeded);
        AssertCode(
            MathBlockOpenMath.TryImport(
                text,
                new MathBlockOpenMathImportOptions
                {
                    MaximumOutputs = program.Outputs.Count - 1
                }),
            MathBlockOpenMathDiagnosticCode.OutputLimitExceeded);

        var values = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var vector = values.Constant(MathBlockValue.Vector([1d, 2d, 3d]));
        var valueText = MathBlockOpenMath.Export(values.Output("value", vector).Build());
        Assert.True(MathBlockOpenMath.TryImport(
            valueText,
            new MathBlockOpenMathImportOptions { MaximumValueElements = 3 }).Succeeded);
        AssertCode(
            MathBlockOpenMath.TryImport(
                valueText,
                new MathBlockOpenMathImportOptions { MaximumValueElements = 2 }),
            MathBlockOpenMathDiagnosticCode.ValueElementLimitExceeded);

        var hostileShape = valueText
            .Replace("name=\"vector\"", "name=\"matrix\"", StringComparison.Ordinal)
            .Replace(
                "<OMI>3</OMI><OMI>0</OMI>",
                "<OMI>2147483647</OMI><OMI>2147483647</OMI>",
                StringComparison.Ordinal);
        AssertCode(
            MathBlockOpenMath.TryImport(hostileShape),
            MathBlockOpenMathDiagnosticCode.InvalidShape);
    }

    [Fact]
    public void Normalization_accepts_equivalent_XML_forms_and_is_idempotent()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var document = XDocument.Parse(canonical, LoadOptions.PreserveWhitespace);
        var root = Assert.IsType<XElement>(document.Root);
        root.Attribute("xmlns")?.Remove();
        root.Add(new XAttribute(XNamespace.Xmlns + "om", "http://www.openmath.org/OpenMath"));
        var prefixed = document.ToString(SaveOptions.DisableFormatting);
        string[] equivalents =
        [
            string.Concat("<?xml version=\"1.0\"?>", canonical),
            string.Concat(" \t\r\n", canonical, "\n"),
            canonical.Replace("<OMSTR>left</OMSTR>", "<OMSTR>l&#101;ft</OMSTR>", StringComparison.Ordinal),
            canonical.Replace("<OMSTR>left</OMSTR>", "<OMSTR><![CDATA[left]]></OMSTR>", StringComparison.Ordinal),
            canonical.Replace(
                "<OMS cd=\"mathblocks_program1\" name=\"program\"></OMS>",
                "<OMS name=\"program\" cd=\"mathblocks_program1\"/>",
                StringComparison.Ordinal),
            prefixed
        ];

        foreach (var equivalent in equivalents)
        {
            var normalized = MathBlockOpenMath.Normalize(equivalent);
            Assert.Equal(canonical, normalized);
            Assert.Equal(canonical, MathBlockOpenMath.Normalize(normalized));
        }

        var bytes = Encoding.UTF8.GetBytes(canonical);
        var withBom = new byte[bytes.Length + 3];
        new byte[] { 0xEF, 0xBB, 0xBF }.CopyTo(withBom, 0);
        bytes.CopyTo(withBom, 3);
        Assert.Equal(bytes, MathBlockOpenMath.NormalizeUtf8(withBom));
    }

    [Fact]
    public async Task Output_handles_every_span_capacity_and_true_async_IO()
    {
        var program = CreateSampleProgram("left-α");
        var expectedText = MathBlockOpenMath.Export(program);
        var expectedBytes = Encoding.UTF8.GetBytes(expectedText);

        for (var length = 0; length < expectedBytes.Length; length++)
        {
            var destination = Enumerable.Repeat((byte)0xA5, length).ToArray();
            var original = destination.ToArray();
            Assert.False(MathBlockOpenMath.TryWriteUtf8(
                program,
                destination,
                out var bytesWritten));
            Assert.Equal(0, bytesWritten);
            Assert.Equal(original, destination);
        }

        await using var stream = new AsyncOnlyWriteStream();
        await MathBlockOpenMath.WriteUtf8Async(program, stream);
        Assert.Equal(expectedBytes, stream.ToArray());
        Assert.Equal(0, stream.SynchronousWrites);
        Assert.True(stream.AsynchronousWrites > 0);

        using var writer = new AsyncOnlyCharacterWriter();
        await MathBlockOpenMath.WriteAsync(program, writer);
        Assert.Equal(expectedText, writer.ToString());
        Assert.Equal(0, writer.SynchronousWrites);
        Assert.True(writer.AsynchronousWrites > 0);

        using var cancellation = new CancellationTokenSource();
        await using var cancelling = new CancellingWriteStream(cancellation);
        await Assert.ThrowsAnyAsync<OperationCanceledException>(
            () => MathBlockOpenMath.WriteUtf8Async(
                program,
                cancelling,
                cancellation.Token));

        await using var failing = new FaultingWriteStream(true);
        var exception = await Assert.ThrowsAsync<IOException>(
            () => MathBlockOpenMath.WriteUtf8Async(program, failing));
        Assert.Equal("The test transport failed.", exception.Message);
    }

    [Fact]
    public async Task Full_catalog_program_uses_every_public_data_path()
    {
        var program = CreateCatalogProgram();
        var text = MathBlockOpenMath.Export(program);
        var bytes = MathBlockOpenMath.ExportUtf8(program);
        Assert.Equal(Encoding.UTF8.GetBytes(text), bytes);
        Assert.Equal(bytes.Length, MathBlockOpenMath.GetUtf8ByteCount(program));

        var span = new byte[bytes.Length];
        Assert.True(MathBlockOpenMath.TryWriteUtf8(program, span, out var count));
        Assert.Equal(bytes.Length, count);
        Assert.Equal(bytes, span);

        var buffer = new ArrayBufferWriter<byte>();
        MathBlockOpenMath.WriteUtf8(program, buffer);
        Assert.Equal(bytes, buffer.WrittenSpan.ToArray());

        using var byteOutput = new MemoryStream();
        MathBlockOpenMath.WriteUtf8(program, byteOutput);
        Assert.Equal(bytes, byteOutput.ToArray());
        using var characterOutput = new StringWriter(CultureInfo.InvariantCulture);
        MathBlockOpenMath.Write(program, characterOutput);
        Assert.Equal(text, characterOutput.ToString());

        await using var asyncByteOutput = new MemoryStream();
        await MathBlockOpenMath.WriteUtf8Async(program, asyncByteOutput);
        Assert.Equal(bytes, asyncByteOutput.ToArray());
        using var asyncCharacterOutput = new StringWriter(CultureInfo.InvariantCulture);
        await MathBlockOpenMath.WriteAsync(program, asyncCharacterOutput);
        Assert.Equal(text, asyncCharacterOutput.ToString());

        var imports = new List<MathBlockOpenMathImportResult>
        {
            MathBlockOpenMath.Import(text),
            MathBlockOpenMath.Import(text, MathBlockOpenMathImportOptions.Default),
            MathBlockOpenMath.ImportUtf8(bytes),
            MathBlockOpenMath.ImportUtf8(CreateSequence(bytes, 17))
        };
        using (var stream = new MemoryStream(bytes))
            imports.Add(MathBlockOpenMath.ReadUtf8(stream));
        using (var reader = new StringReader(text))
            imports.Add(MathBlockOpenMath.Read(reader));
        await using (var stream = new MemoryStream(bytes))
            imports.Add(await MathBlockOpenMath.ReadUtf8Async(stream));
        using (var reader = new StringReader(text))
            imports.Add(await MathBlockOpenMath.ReadAsync(reader));

        Assert.All(imports, result =>
        {
            Assert.Equal(program.Fingerprint, result.Program.Fingerprint);
            Assert.Equal(337, result.Operations.Count);
            Assert.Equal(337, result.OperationOccurrences.Count);
            Assert.Equal(
                MathBlockCatalog.Standard.Operations.Select(operation => operation.Identity),
                result.Operations.Select(operation => operation.Identity));
            Assert.Equal(
                result.Operations.Select(operation => operation.Identity),
                result.OperationOccurrences.Select(occurrence => occurrence.Operation.Identity));
        });

        Assert.True(MathBlockOpenMath.TryImport(text).Succeeded);
        Assert.True(MathBlockOpenMath.TryImportUtf8(bytes).Succeeded);
        using (var stream = new MemoryStream(bytes))
            Assert.True(MathBlockOpenMath.TryReadUtf8(stream).Succeeded);
        using (var reader = new StringReader(text))
            Assert.True(MathBlockOpenMath.TryRead(reader).Succeeded);
        await using (var stream = new MemoryStream(bytes))
            Assert.True((await MathBlockOpenMath.TryReadUtf8Async(stream)).Succeeded);
        using (var reader = new StringReader(text))
            Assert.True((await MathBlockOpenMath.TryReadAsync(reader)).Succeeded);

        Assert.Equal(MathBlockOpenMathCanonicality.Canonical, MathBlockOpenMath.Validate(text).Canonicality);
        Assert.Equal(
            MathBlockOpenMathCanonicality.Canonical,
            MathBlockOpenMath.ValidateUtf8(bytes).Canonicality);
        Assert.Equal(text, MathBlockOpenMath.Normalize(text));
        Assert.Equal(bytes, MathBlockOpenMath.NormalizeUtf8(bytes));
        Assert.True(MathBlockOpenMath.ValidateProgram(program).IsValid);
    }

    [Fact]
    public void Deep_and_deterministically_mutated_XML_fails_without_implementation_errors()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram("left"));
        var random = new Random(401);
        const string replacements = "<>/=!?x09 \t\n";
        for (var iteration = 0; iteration < 1_000; iteration++)
        {
            var characters = canonical.ToCharArray();
            var index = random.Next(characters.Length);
            characters[index] = replacements[random.Next(replacements.Length)];
            var attempt = MathBlockOpenMath.TryImport(new string(characters));
            Assert.NotEqual(attempt.Result is null, attempt.Diagnostic is null);
        }

        var rootStart = canonical[..(canonical.IndexOf('>') + 1)];
        var deep = string.Concat(
            rootStart,
            string.Concat(Enumerable.Repeat("<OMA>", 4_096)),
            string.Concat(Enumerable.Repeat("</OMA>", 4_096)),
            "</OMOBJ>");
        var deepAttempt = MathBlockOpenMath.TryImport(
            deep,
            new MathBlockOpenMathImportOptions
            {
                MaximumDocumentCharacters = deep.Length
            });
        Assert.False(deepAttempt.Succeeded);
        Assert.NotNull(deepAttempt.Diagnostic);
    }

    [Fact]
    public async Task Concurrent_calls_share_no_mutable_notation_state()
    {
        var program = CreateSampleProgram("left-α");
        var text = MathBlockOpenMath.Export(program);
        var bytes = Encoding.UTF8.GetBytes(text);
        var operation = MathBlockCatalog.Standard.Operations[0];

        await Task.WhenAll(Enumerable.Range(0, 64).Select(async _ =>
        {
            Assert.Equal(text, MathBlockOpenMath.Export(program));
            Assert.Equal(bytes, MathBlockOpenMath.ExportUtf8(program));
            Assert.Equal(program.Fingerprint, MathBlockOpenMath.Import(text).Program.Fingerprint);
            Assert.Equal(program.Fingerprint, MathBlockOpenMath.ImportUtf8(bytes).Program.Fingerprint);
            Assert.True(MathBlockOpenMath.Validate(text).IsValid);
            Assert.Equal(text, MathBlockOpenMath.Normalize(text));
            Assert.True(MathBlockOpenMath.TryGetOperationSymbol(operation, out var symbol));
            Assert.True(MathBlockOpenMath.TryGetOperation(symbol, out var resolved));
            Assert.Same(operation, resolved);

            await using var input = new MemoryStream(bytes);
            Assert.Equal(
                program.Fingerprint,
                (await MathBlockOpenMath.ReadUtf8Async(input)).Program.Fingerprint);
            await using var output = new MemoryStream();
            await MathBlockOpenMath.WriteUtf8Async(program, output);
            Assert.Equal(bytes, output.ToArray());

            foreach (var artifact in MathBlockOpenMath.Profile.Artifacts)
            {
                using var stream = artifact.OpenRead();
                Assert.Equal(artifact.Length, stream.Length);
            }
        }));
    }

    private static void AssertCode(
        MathBlockOpenMathImportAttempt attempt,
        MathBlockOpenMathDiagnosticCode code)
    {
        Assert.False(attempt.Succeeded);
        Assert.Null(attempt.Result);
        Assert.Equal(code, attempt.Diagnostic?.Code);
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

    private static MathBlockProgram CreateCatalogProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        for (var operationIndex = 0;
             operationIndex < MathBlockCatalog.Standard.Operations.Count;
             operationIndex++)
        {
            var operation = MathBlockCatalog.Standard.Operations[operationIndex];
            var regression = operation.RegressionCases[0];
            var inputs = new int[regression.Inputs.Count];
            for (var inputIndex = 0; inputIndex < inputs.Length; inputIndex++)
                inputs[inputIndex] = builder.Constant(regression.Inputs[inputIndex]);
            var result = builder.Apply(operation.Identifier, operation.Version, inputs);
            builder.Output(
                string.Concat("operation-", operationIndex.ToString(CultureInfo.InvariantCulture)),
                result);
        }
        return builder.Build();
    }

    private static ReadOnlySequence<byte> CreateSequence(byte[] source, int maximumSegment)
    {
        if (source.Length == 0)
            return ReadOnlySequence<byte>.Empty;
        ByteSegment? first = null;
        ByteSegment? last = null;
        for (var offset = 0; offset < source.Length; offset += maximumSegment)
        {
            var count = Math.Min(maximumSegment, source.Length - offset);
            var segment = new ByteSegment(source.AsMemory(offset, count));
            if (first is null)
                first = segment;
            else
                last!.Append(segment);
            last = segment;
        }
        return new ReadOnlySequence<byte>(first!, 0, last!, last!.Memory.Length);
    }

    private sealed class ByteSegment : ReadOnlySequenceSegment<byte>
    {
        public ByteSegment(ReadOnlyMemory<byte> memory) => Memory = memory;

        public void Append(ByteSegment segment)
        {
            segment.RunningIndex = RunningIndex + Memory.Length;
            Next = segment;
        }
    }

    private sealed class FaultingReadStream(
        byte[] source,
        int failAfter,
        bool asyncOnly) : Stream
    {
        private int position;

        public override bool CanRead => true;
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
            if (asyncOnly)
                throw new InvalidOperationException("Synchronous input is not permitted.");
            return CopyOrFail(buffer);
        }

        public override ValueTask<int> ReadAsync(
            Memory<byte> buffer,
            CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();
            return ValueTask.FromResult(CopyOrFail(buffer.Span));
        }

        public override Task<int> ReadAsync(
            byte[] buffer,
            int offset,
            int count,
            CancellationToken cancellationToken) =>
            ReadAsync(buffer.AsMemory(offset, count), cancellationToken).AsTask();

        private int CopyOrFail(Span<byte> destination)
        {
            if (position >= failAfter)
                throw new IOException("The test transport failed.");
            var count = Math.Min(Math.Min(destination.Length, 3), failAfter - position);
            source.AsSpan(position, count).CopyTo(destination);
            position += count;
            return count;
        }

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
    }

    private sealed class AsyncOnlyReadStream(byte[] source, int maximumChunk) : Stream
    {
        private int position;

        public int SynchronousReads { get; private set; }
        public int AsynchronousReads { get; private set; }
        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => source.Length;
        public override long Position
        {
            get => position;
            set => throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count)
        {
            SynchronousReads++;
            throw new InvalidOperationException("Synchronous input is not permitted.");
        }

        public override int Read(Span<byte> buffer)
        {
            SynchronousReads++;
            throw new InvalidOperationException("Synchronous input is not permitted.");
        }

        public override ValueTask<int> ReadAsync(
            Memory<byte> buffer,
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

        public override Task<int> ReadAsync(
            byte[] buffer,
            int offset,
            int count,
            CancellationToken cancellationToken) =>
            ReadAsync(buffer.AsMemory(offset, count), cancellationToken).AsTask();

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
    }

    private sealed class AsyncOnlyCharacterReader(string source, int maximumChunk) : TextReader
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

    private sealed class CancellingReadStream(
        byte[] source,
        CancellationTokenSource cancellation,
        int cancelAfter) : Stream
    {
        private int position;

        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => source.Length;
        public override long Position
        {
            get => position;
            set => throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new InvalidOperationException("Synchronous input is not permitted.");

        public override async ValueTask<int> ReadAsync(
            Memory<byte> buffer,
            CancellationToken cancellationToken = default)
        {
            await Task.Yield();
            cancellationToken.ThrowIfCancellationRequested();
            if (position >= cancelAfter)
            {
                cancellation.Cancel();
                cancellationToken.ThrowIfCancellationRequested();
            }
            var count = Math.Min(Math.Min(buffer.Length, 3), cancelAfter - position);
            source.AsMemory(position, count).CopyTo(buffer);
            position += count;
            return count;
        }

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
    }

    private sealed class AsyncOnlyWriteStream : Stream
    {
        private readonly MemoryStream destination = new();

        public int SynchronousWrites { get; private set; }
        public int AsynchronousWrites { get; private set; }
        public byte[] ToArray() => destination.ToArray();
        public override bool CanRead => false;
        public override bool CanSeek => false;
        public override bool CanWrite => true;
        public override long Length => destination.Length;
        public override long Position
        {
            get => destination.Position;
            set => throw new NotSupportedException();
        }

        public override void Flush()
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override Task FlushAsync(CancellationToken cancellationToken) =>
            destination.FlushAsync(cancellationToken);

        public override void Write(byte[] buffer, int offset, int count)
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override void Write(ReadOnlySpan<byte> buffer)
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override async ValueTask WriteAsync(
            ReadOnlyMemory<byte> buffer,
            CancellationToken cancellationToken = default)
        {
            AsynchronousWrites++;
            await destination.WriteAsync(buffer, cancellationToken);
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
    }

    private sealed class AsyncOnlyCharacterWriter : TextWriter
    {
        private readonly StringBuilder destination = new();

        public int SynchronousWrites { get; private set; }
        public int AsynchronousWrites { get; private set; }
        public override Encoding Encoding => Encoding.UTF8;
        public override string ToString() => destination.ToString();

        public override void Flush()
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override void Write(char value)
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override void Write(char[] buffer, int index, int count)
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override void Write(string? value)
        {
            SynchronousWrites++;
            throw new InvalidOperationException("Synchronous output is not permitted.");
        }

        public override Task WriteAsync(char value)
        {
            AsynchronousWrites++;
            destination.Append(value);
            return Task.CompletedTask;
        }

        public override Task WriteAsync(char[] buffer, int index, int count)
        {
            AsynchronousWrites++;
            destination.Append(buffer, index, count);
            return Task.CompletedTask;
        }

        public override Task WriteAsync(string? value)
        {
            AsynchronousWrites++;
            destination.Append(value);
            return Task.CompletedTask;
        }

        public override Task WriteAsync(
            ReadOnlyMemory<char> buffer,
            CancellationToken cancellationToken = default)
        {
            AsynchronousWrites++;
            cancellationToken.ThrowIfCancellationRequested();
            destination.Append(buffer.Span);
            return Task.CompletedTask;
        }

        public override Task FlushAsync()
        {
            AsynchronousWrites++;
            return Task.CompletedTask;
        }

        public override Task FlushAsync(CancellationToken cancellationToken)
        {
            AsynchronousWrites++;
            cancellationToken.ThrowIfCancellationRequested();
            return Task.CompletedTask;
        }
    }

    private sealed class CancellingWriteStream(CancellationTokenSource cancellation) : Stream
    {
        public override bool CanRead => false;
        public override bool CanSeek => false;
        public override bool CanWrite => true;
        public override long Length => 0;
        public override long Position
        {
            get => 0;
            set => throw new NotSupportedException();
        }

        public override void Flush() =>
            throw new InvalidOperationException("Synchronous output is not permitted.");

        public override Task FlushAsync(CancellationToken cancellationToken) =>
            Task.CompletedTask;

        public override void Write(byte[] buffer, int offset, int count) =>
            throw new InvalidOperationException("Synchronous output is not permitted.");

        public override ValueTask WriteAsync(
            ReadOnlyMemory<byte> buffer,
            CancellationToken cancellationToken = default)
        {
            cancellation.Cancel();
            cancellationToken.ThrowIfCancellationRequested();
            throw new InvalidOperationException("Cancellation was not observed.");
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
    }

    private sealed class FaultingWriteStream(bool asyncOnly) : Stream
    {
        public override bool CanRead => false;
        public override bool CanSeek => false;
        public override bool CanWrite => true;
        public override long Length => 0;
        public override long Position
        {
            get => 0;
            set => throw new NotSupportedException();
        }

        public override void Flush()
        {
            if (asyncOnly)
                throw new InvalidOperationException("Synchronous output is not permitted.");
            throw new IOException("The test transport failed.");
        }

        public override Task FlushAsync(CancellationToken cancellationToken) =>
            Task.FromException(new IOException("The test transport failed."));

        public override void Write(byte[] buffer, int offset, int count)
        {
            if (asyncOnly)
                throw new InvalidOperationException("Synchronous output is not permitted.");
            throw new IOException("The test transport failed.");
        }

        public override ValueTask WriteAsync(
            ReadOnlyMemory<byte> buffer,
            CancellationToken cancellationToken = default) =>
            ValueTask.FromException(new IOException("The test transport failed."));

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) => throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
    }
}
