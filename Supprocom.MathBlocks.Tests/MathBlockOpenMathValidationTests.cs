using System.Buffers;
using System.Text;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockOpenMathValidationTests
{
    [Fact]
    public void Validation_reports_validity_canonicality_and_first_difference()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram());
        var canonicalResult = MathBlockOpenMath.Validate(canonical);
        var noncanonical = string.Concat("\n", canonical);
        var noncanonicalResult = MathBlockOpenMath.Validate(noncanonical);
        var invalidResult = MathBlockOpenMath.Validate("<invalid>");
        var nullResult = MathBlockOpenMath.Validate(null);

        Assert.True(canonicalResult.IsValid);
        Assert.Equal(MathBlockOpenMathCanonicality.Canonical, canonicalResult.Canonicality);
        Assert.Null(canonicalResult.Diagnostic);
        Assert.Null(canonicalResult.DifferenceIndex);
        Assert.Null(canonicalResult.DifferenceUnit);

        Assert.True(noncanonicalResult.IsValid);
        Assert.Equal(MathBlockOpenMathCanonicality.Noncanonical, noncanonicalResult.Canonicality);
        Assert.Equal(0, noncanonicalResult.DifferenceIndex);
        Assert.Equal(MathBlockOpenMathDifferenceUnit.Character, noncanonicalResult.DifferenceUnit);

        Assert.False(invalidResult.IsValid);
        Assert.Equal(MathBlockOpenMathCanonicality.NotApplicable, invalidResult.Canonicality);
        Assert.NotNull(invalidResult.Diagnostic);
        Assert.Null(invalidResult.DifferenceIndex);
        Assert.False(nullResult.IsValid);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.SourceNull, nullResult.Diagnostic?.Code);
    }

    [Fact]
    public void UTF8_validation_detects_a_BOM_for_contiguous_and_segmented_input()
    {
        var canonical = MathBlockOpenMath.ExportUtf8(CreateSampleProgram());
        var withBom = new byte[canonical.Length + 3];
        new byte[] { 0xEF, 0xBB, 0xBF }.CopyTo(withBom, 0);
        canonical.CopyTo(withBom, 3);

        var contiguous = MathBlockOpenMath.ValidateUtf8(withBom);
        var segmented = MathBlockOpenMath.ValidateUtf8(CreateSequence(withBom, 2));

        Assert.True(contiguous.IsValid);
        Assert.Equal(MathBlockOpenMathCanonicality.Noncanonical, contiguous.Canonicality);
        Assert.Equal(0, contiguous.DifferenceIndex);
        Assert.Equal(MathBlockOpenMathDifferenceUnit.Byte, contiguous.DifferenceUnit);
        Assert.True(segmented.IsValid);
        Assert.Equal(contiguous.Canonicality, segmented.Canonicality);
        Assert.Equal(contiguous.DifferenceIndex, segmented.DifferenceIndex);
    }

    [Fact]
    public void Normalization_is_exact_and_idempotent_for_all_memory_forms()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram());
        var noncanonical = string.Concat("\n", canonical);
        var bytes = Encoding.UTF8.GetBytes(noncanonical);

        Assert.Equal(canonical, MathBlockOpenMath.Normalize(noncanonical));
        Assert.Equal(canonical, MathBlockOpenMath.Normalize(canonical));
        Assert.Equal(Encoding.UTF8.GetBytes(canonical), MathBlockOpenMath.NormalizeUtf8(bytes));
        Assert.Equal(
            Encoding.UTF8.GetBytes(canonical),
            MathBlockOpenMath.NormalizeUtf8(CreateSequence(bytes, 3)));
    }

    [Fact]
    public async Task Stream_normalization_preserves_endpoints_and_invalid_destinations()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram());
        var noncanonical = string.Concat("\n", canonical);

        using var source = new StringReader(noncanonical);
        using var destination = new StringWriter();
        MathBlockOpenMath.Normalize(source, destination);
        Assert.Equal(canonical, destination.ToString());
        Assert.Equal(-1, source.Peek());

        using var asyncSource = new StringReader(noncanonical);
        using var asyncDestination = new StringWriter();
        await MathBlockOpenMath.NormalizeAsync(asyncSource, asyncDestination);
        Assert.Equal(canonical, asyncDestination.ToString());

        using var byteSource = new MemoryStream(Encoding.UTF8.GetBytes(noncanonical));
        using var byteDestination = new MemoryStream();
        MathBlockOpenMath.NormalizeUtf8(byteSource, byteDestination);
        Assert.Equal(Encoding.UTF8.GetBytes(canonical), byteDestination.ToArray());
        Assert.True(byteSource.CanRead);
        Assert.True(byteDestination.CanWrite);

        await using var asyncByteSource = new MemoryStream(Encoding.UTF8.GetBytes(noncanonical));
        await using var asyncByteDestination = new MemoryStream();
        await MathBlockOpenMath.NormalizeUtf8Async(asyncByteSource, asyncByteDestination);
        Assert.Equal(Encoding.UTF8.GetBytes(canonical), asyncByteDestination.ToArray());

        using var invalidSource = new StringReader("<invalid>");
        using var unchangedDestination = new StringWriter();
        unchangedDestination.Write("unchanged");
        Assert.Throws<FormatException>(
            () => MathBlockOpenMath.Normalize(invalidSource, unchangedDestination));
        Assert.Equal("unchanged", unchangedDestination.ToString());

        using var sameStream = new MemoryStream(Encoding.UTF8.GetBytes(canonical));
        var position = sameStream.Position;
        Assert.Throws<ArgumentException>(
            () => MathBlockOpenMath.NormalizeUtf8(sameStream, sameStream));
        Assert.Equal(position, sameStream.Position);
    }

    [Fact]
    public void Program_validation_reports_profile_export_failures()
    {
        var valid = MathBlockOpenMath.ValidateProgram(CreateSampleProgram());
        var missing = MathBlockOpenMath.ValidateProgram(null);

        var operation = new MathBlockOperation(
            "custom.identity",
            1,
            1,
            types => types[0],
            inputs => inputs[0],
            [new MathBlockRegressionCase(
                "identity",
                [MathBlockValue.Scalar(1d)],
                MathBlockValue.Scalar(1d))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1d)]));
        var builder = new MathBlockProgramBuilder(new MathBlockRegistry([operation]));
        var input = builder.Input("input", MathBlockType.Scalar());
        var output = builder.Apply(operation.Identifier, operation.Version, input);
        var custom = MathBlockOpenMath.ValidateProgram(builder.Output("output", output).Build());

        Assert.True(valid.IsValid);
        Assert.Null(valid.Diagnostic);
        Assert.False(missing.IsValid);
        Assert.Equal(MathBlockOpenMathDiagnosticCode.ProgramNull, missing.Diagnostic?.Code);
        Assert.False(custom.IsValid);
        Assert.Equal(
            MathBlockOpenMathDiagnosticCode.OperationOutsideProfile,
            custom.Diagnostic?.Code);
    }

    private static MathBlockProgram CreateSampleProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
        return builder.Output("sum", sum).Output("square", square).Build();
    }

    private static ReadOnlySequence<byte> CreateSequence(byte[] source, int split)
    {
        var first = new ByteSegment(source.AsMemory(0, split));
        var last = new ByteSegment(source.AsMemory(split));
        first.Append(last);
        return new ReadOnlySequence<byte>(first, 0, last, last.Memory.Length);
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
}
