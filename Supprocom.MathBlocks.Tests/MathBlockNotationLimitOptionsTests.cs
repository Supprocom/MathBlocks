using System.Buffers;
using System.Text;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains tests for the OpenMath and formula-interchange size ceilings.</summary>
public sealed class MathBlockNotationLimitOptionsTests
{
    private const int MaximumStringLength = 0x3FFFFFDF;

    /// <summary>Verifies the interchange defaults are the ceilings earlier versions fixed.</summary>
    [Fact]
    public void InterchangeDefaultsAreTheFixedCeilings()
    {
        var options = MathBlockFormulaInterchangeOptions.Default;

        Assert.Equal(6 * 16 * 1024 * 1024, options.MaximumDocumentCharacters);
        Assert.Equal((6 * 16 * 1024 * 1024 * 3) + 3, options.MaximumDocumentUtf8Bytes);
        Assert.Equal(16 * 1024, options.MaximumExpressionElements);
        Assert.Equal(256, options.MaximumExpressionDepth);
        Assert.Null(options.OpenMath);
        Assert.Equal(16 * 1024 * 1024, MathBlockOpenMathImportOptions.Default.MaximumDocumentCharacters);
        Assert.Equal((16 * 1024 * 1024 * 3) + 3, MathBlockOpenMathImportOptions.Default.MaximumDocumentBytes);
    }

    /// <summary>Verifies an interchange ceiling above its .NET limit is a load error naming the limit.</summary>
    [Fact]
    public void InterchangeCeilingsAboveTheNetLimitAreLoadErrors()
    {
        var source = CreateFormula(MathBlockFormulaFormat.OpenMath);
        var cases = new (MathBlockFormulaInterchangeOptions Options, string Name, string Limit)[]
        {
            (new() { MaximumDocumentCharacters = MaximumStringLength + 1 }, "MaximumDocumentCharacters", "1,073,741,791"),
            (new() { MaximumDocumentUtf8Bytes = int.MaxValue }, "MaximumDocumentUtf8Bytes", "2,147,483,591"),
            (new() { MaximumExpressionElements = int.MaxValue }, "MaximumExpressionElements", "2,147,483,591"),
            (new() { MaximumExpressionDepth = int.MaxValue }, "MaximumExpressionDepth", "2,147,483,591"),
            (new() { MaximumDocumentCharacters = 0 }, "MaximumDocumentCharacters", "1,073,741,791")
        };

        foreach (var (options, name, limit) in cases)
        {
            var exception = Assert.Throws<ArgumentOutOfRangeException>(() =>
                MathBlockFormulaInterchange.Import(source, MathBlockFormulaFormat.OpenMath, options));
            Assert.Equal(name, exception.ParamName);
            Assert.Contains(limit, exception.Message, StringComparison.Ordinal);
        }

        var atTheLimits = new MathBlockFormulaInterchangeOptions
        {
            MaximumDocumentCharacters = MaximumStringLength,
            MaximumDocumentUtf8Bytes = Array.MaxLength,
            MaximumExpressionElements = Array.MaxLength,
            MaximumExpressionDepth = Array.MaxLength
        };
        Assert.NotNull(MathBlockFormulaInterchange.Import(source, MathBlockFormulaFormat.OpenMath, atTheLimits));
        Assert.Throws<ArgumentNullException>(() => MathBlockFormulaInterchange.Import(source, MathBlockFormulaFormat.OpenMath, null!));
        Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockFormulaInterchange.Import(
            source,
            MathBlockFormulaFormat.OpenMath,
            new MathBlockFormulaInterchangeOptions { OpenMath = new MathBlockOpenMathImportOptions { MaximumNodes = 0 } }));
    }

    /// <summary>Verifies every interchange entry point honors a lowered document ceiling and the default result is unchanged.</summary>
    [Theory]
    [InlineData(MathBlockFormulaFormat.OpenMath)]
    [InlineData(MathBlockFormulaFormat.ContentMathMl)]
    public void InterchangeEntryPointsHonorTheDocumentCeilings(MathBlockFormulaFormat format)
    {
        var source = CreateFormula(format);
        var bytes = Encoding.UTF8.GetBytes(source);
        var exactCharacters = new MathBlockFormulaInterchangeOptions { MaximumDocumentCharacters = source.Length };
        var shortCharacters = new MathBlockFormulaInterchangeOptions { MaximumDocumentCharacters = source.Length - 1 };
        var exactBytes = new MathBlockFormulaInterchangeOptions { MaximumDocumentUtf8Bytes = bytes.Length };
        var shortBytes = new MathBlockFormulaInterchangeOptions { MaximumDocumentUtf8Bytes = bytes.Length - 1 };
        var expected = MathBlockFormulaInterchange.Import(source, format).Program.Fingerprint;

        Assert.Equal(expected, MathBlockFormulaInterchange.Import(source, format, exactCharacters).Program.Fingerprint);
        Assert.Equal(expected, MathBlockFormulaInterchange.ImportUtf8(bytes, format, exactBytes).Program.Fingerprint);
        Assert.Equal(expected, MathBlockFormulaInterchange.ImportUtf8(new ReadOnlySequence<byte>(bytes), format, exactBytes).Program.Fingerprint);
        Assert.Equal(source, MathBlockFormulaInterchange.Normalize(source, format, exactCharacters));
        using (var reader = new StringReader(source))
            Assert.Equal(expected, MathBlockFormulaInterchange.Read(reader, format, exactCharacters).Program.Fingerprint);
        using (var stream = new MemoryStream(bytes))
            Assert.Equal(expected, MathBlockFormulaInterchange.ReadUtf8(stream, format, exactBytes).Program.Fingerprint);
        Assert.True(MathBlockFormulaInterchange.Validate(source, format, exactCharacters).IsValid);
        Assert.True(MathBlockFormulaInterchange.ValidateUtf8(bytes, format, exactBytes).IsValid);

        Assert.Equal("The formula source exceeds the character limit.", Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(source, format, shortCharacters)).Message);
        Assert.Equal("The formula source exceeds the byte limit.", Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.ImportUtf8(bytes, format, shortBytes)).Message);
        Assert.Equal("The formula source exceeds the byte limit.", Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.ImportUtf8(new ReadOnlySequence<byte>(bytes), format, shortBytes)).Message);
        using (var reader = new StringReader(source))
            Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Read(reader, format, shortCharacters));
        using (var stream = new MemoryStream(bytes))
            Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.ReadUtf8(stream, format, shortBytes));
        Assert.False(MathBlockFormulaInterchange.TryImport(source, format, shortCharacters).Succeeded);
        Assert.False(MathBlockFormulaInterchange.Validate(source, format, shortCharacters).IsValid);
        Assert.False(MathBlockFormulaInterchange.ValidateUtf8(bytes, format, shortBytes).IsValid);
    }

    /// <summary>Verifies the asynchronous interchange readers take the ceilings.</summary>
    [Fact]
    public async Task AsynchronousInterchangeReadersTakeTheCeilings()
    {
        var source = CreateFormula(MathBlockFormulaFormat.OpenMath);
        var bytes = Encoding.UTF8.GetBytes(source);
        var exact = new MathBlockFormulaInterchangeOptions { MaximumDocumentCharacters = source.Length, MaximumDocumentUtf8Bytes = bytes.Length };
        var shortOptions = new MathBlockFormulaInterchangeOptions { MaximumDocumentCharacters = source.Length - 1, MaximumDocumentUtf8Bytes = bytes.Length - 1 };

        using (var reader = new StringReader(source))
            Assert.NotNull(await MathBlockFormulaInterchange.ReadAsync(reader, MathBlockFormulaFormat.OpenMath, exact, CancellationToken.None));
        using (var stream = new MemoryStream(bytes))
            Assert.NotNull(await MathBlockFormulaInterchange.ReadUtf8Async(stream, MathBlockFormulaFormat.OpenMath, exact, CancellationToken.None));
        using (var reader = new StringReader(source))
            await Assert.ThrowsAsync<FormatException>(() => MathBlockFormulaInterchange.ReadAsync(reader, MathBlockFormulaFormat.OpenMath, shortOptions, CancellationToken.None));
        using (var stream = new MemoryStream(bytes))
            await Assert.ThrowsAsync<FormatException>(() => MathBlockFormulaInterchange.ReadUtf8Async(stream, MathBlockFormulaFormat.OpenMath, shortOptions, CancellationToken.None));
    }

    /// <summary>Verifies the OpenMath options of the exact annotation reach the nested OpenMath import.</summary>
    [Fact]
    public void ExactAnnotationUsesTheOpenMathOptions()
    {
        var source = CreateFormula(MathBlockFormulaFormat.OpenMath);
        var options = new MathBlockFormulaInterchangeOptions
        {
            OpenMath = new MathBlockOpenMathImportOptions { MaximumNodes = 1 }
        };

        var exception = Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(source, MathBlockFormulaFormat.OpenMath, options));

        Assert.Equal("The formula exact annotation is invalid.", exception.Message);
    }

    /// <summary>Verifies the visible-expression element and depth ceilings are options.</summary>
    [Theory]
    [InlineData(MathBlockFormulaFormat.OpenMath)]
    [InlineData(MathBlockFormulaFormat.ContentMathMl)]
    public void VisibleExpressionCeilingsAreOptions(MathBlockFormulaFormat format)
    {
        var types = new Dictionary<string, MathBlockType>(StringComparer.Ordinal);
        var wide = CreateWideFormula(format, 40);
        var deep = CreateDeepFormula(format, 300);

        Assert.Equal(
            "The formula expression exceeds the element limit.",
            Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(wide, format, types, "result", new MathBlockFormulaInterchangeOptions { MaximumExpressionElements = 8 })).Message);
        Assert.NotNull(MathBlockFormulaInterchange.Import(wide, format, types, "result", new MathBlockFormulaInterchangeOptions { MaximumExpressionElements = 100 }));

        Assert.Equal(
            "The formula expression exceeds the nesting limit.",
            Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(deep, format, types, "result")).Message);
        Assert.NotNull(MathBlockFormulaInterchange.Import(deep, format, types, "result", new MathBlockFormulaInterchangeOptions { MaximumExpressionDepth = 1_000 }));
        Assert.NotNull(MathBlockFormulaInterchange.ImportUtf8(Encoding.UTF8.GetBytes(deep), format, types, "result", new MathBlockFormulaInterchangeOptions { MaximumExpressionDepth = 1_000 }));
    }

    /// <summary>Verifies a depth ceiling the stack cannot honor is a format error, not a stack overflow.</summary>
    [Fact]
    public void DepthBeyondTheStackIsAFormatError()
    {
        var types = new Dictionary<string, MathBlockType>(StringComparer.Ordinal);
        var deep = CreateDeepFormula(MathBlockFormulaFormat.ContentMathMl, 60_000);
        FormatException? caught = null;
        var thread = new Thread(
            () =>
            {
                try
                {
                    MathBlockFormulaInterchange.Import(
                        deep,
                        MathBlockFormulaFormat.ContentMathMl,
                        types,
                        "result",
                        new MathBlockFormulaInterchangeOptions { MaximumExpressionDepth = Array.MaxLength, MaximumExpressionElements = Array.MaxLength });
                }
                catch (FormatException exception)
                {
                    caught = exception;
                }
            },
            512 * 1024);
        thread.Start();
        thread.Join();

        Assert.NotNull(caught);
        Assert.Equal("The formula expression nests deeper than the stack allows.", caught.Message);
    }

    /// <summary>Verifies the OpenMath ceilings reach the longest .NET string and byte array and no further.</summary>
    [Fact]
    public void OpenMathCeilingsReachTheNetLimits()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var constant = builder.Constant(MathBlockValue.Scalar(1d));
        var document = MathBlockOpenMath.Export(builder.Output("value", constant).Build());

        var raised = new MathBlockOpenMathImportOptions
        {
            MaximumDocumentCharacters = MaximumStringLength,
            MaximumDocumentBytes = Array.MaxLength
        };
        Assert.NotNull(MathBlockOpenMath.Import(document, raised));

        var characters = Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockOpenMath.Import(
            document,
            new MathBlockOpenMathImportOptions { MaximumDocumentCharacters = MaximumStringLength + 1 }));
        var bytes = Assert.Throws<ArgumentOutOfRangeException>(() => MathBlockOpenMath.ImportUtf8(
            Encoding.UTF8.GetBytes(document),
            new MathBlockOpenMathImportOptions { MaximumDocumentBytes = int.MaxValue }));

        Assert.Contains("1,073,741,791", characters.Message, StringComparison.Ordinal);
        Assert.Contains("2,147,483,591", bytes.Message, StringComparison.Ordinal);
    }

    /// <summary>Verifies a raised OpenMath character ceiling accepts a document the old ceiling rejected.</summary>
    [Fact]
    public void RaisedOpenMathCeilingPassesTheOldCeiling()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var constant = builder.Constant(MathBlockValue.Scalar(1d));
        var document = MathBlockOpenMath.Export(builder.Output("value", constant).Build());
        var padded = document + new string(' ', MathBlockOpenMath.MaximumDocumentCharacters);

        var rejected = Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(padded));
        var accepted = MathBlockOpenMath.Import(
            padded,
            new MathBlockOpenMathImportOptions { MaximumDocumentCharacters = padded.Length });

        Assert.Equal("The OpenMath source exceeds the character limit.", rejected.Message);
        Assert.Equal(MathBlockOpenMath.Import(document).Program.Fingerprint, accepted.Program.Fingerprint);
    }

    private static string CreateFormula(MathBlockFormulaFormat format)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", 1, left, right);
        return MathBlockFormulaInterchange.Export(builder.Output("result", sum).Build(), "result", format);
    }

    private static string CreateWideFormula(MathBlockFormulaFormat format, int count)
    {
        var result = new StringBuilder();
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            result.Append("<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\"><OMA><OMS cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\" name=\"plus\"/>");
            for (var index = 0; index < count; index++)
                result.Append("<OMI>1</OMI>");
            return result.Append("</OMA></OMOBJ>").ToString();
        }

        result.Append("<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><apply><plus/>");
        for (var index = 0; index < count; index++)
            result.Append("<cn>1</cn>");
        return result.Append("</apply></math>").ToString();
    }

    private static string CreateDeepFormula(MathBlockFormulaFormat format, int levels)
    {
        var result = new StringBuilder();
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            result.Append("<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\">");
            for (var index = 0; index < levels; index++)
                result.Append("<OMA><OMS cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\" name=\"plus\"/>");
            result.Append("<OMI>1</OMI>");
            for (var index = 0; index < levels; index++)
                result.Append("<OMI>1</OMI></OMA>");
            return result.Append("</OMOBJ>").ToString();
        }

        result.Append("<math xmlns=\"http://www.w3.org/1998/Math/MathML\">");
        for (var index = 0; index < levels; index++)
            result.Append("<apply><plus/>");
        result.Append("<cn>1</cn>");
        for (var index = 0; index < levels; index++)
            result.Append("<cn>1</cn></apply>");
        return result.Append("</math>").ToString();
    }
}
