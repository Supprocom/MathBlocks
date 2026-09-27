using System.Buffers;
using System.Text;
using SharpFuzz;
using Supprocom.MathBlocks;

const int MaximumInputBytes = 262_144;

if (args.Length != 0)
{
    if (args.Length != 2 || !string.Equals(args[0], "--replay", StringComparison.Ordinal))
        throw new ArgumentException("Use --replay with one corpus directory.");

    var files = Directory.EnumerateFiles(args[1]).Order(StringComparer.Ordinal).ToArray();
    foreach (var file in files)
        Exercise(File.ReadAllBytes(file));
    Console.WriteLine($"replayed={files.Length}");
    Console.WriteLine("status=passed");
    return;
}

Fuzzer.LibFuzzer.Run(source =>
{
    if (source.Length <= MaximumInputBytes)
        Exercise(source.ToArray());
});

static void Exercise(byte[] source)
{
    ExerciseOpenMath(source);
    ExerciseFormulaInterchange(source);
}

static void ExerciseOpenMath(byte[] source)
{
    var options = CreateOptions();
    var contiguous = MathBlockOpenMath.TryImportUtf8(source, options);
    CheckAttempt(contiguous);

    var sequence = CreateSequence(source, source.Length == 0 ? 1 : source[0] % 31 + 1);
    var segmented = MathBlockOpenMath.TryImportUtf8(sequence, options);
    CheckEquivalent(contiguous, segmented);

    using var byteStream = new MemoryStream(source, false);
    var streamed = MathBlockOpenMath.TryReadUtf8(byteStream, options);
    CheckEquivalent(contiguous, streamed);

    var contiguousValidation = MathBlockOpenMath.ValidateUtf8(source, options);
    var segmentedValidation = MathBlockOpenMath.ValidateUtf8(sequence, options);
    CheckValidation(contiguous, contiguousValidation);
    CheckValidation(segmented, segmentedValidation);

    var text = Encoding.UTF8.GetString(source);
    var characters = MathBlockOpenMath.TryImport(text, options);
    CheckAttempt(characters);
    using var characterReader = new StringReader(text);
    var characterStream = MathBlockOpenMath.TryRead(characterReader, options);
    CheckEquivalent(characters, characterStream);
    CheckValidation(characters, MathBlockOpenMath.Validate(text, options));

    if (contiguous.Succeeded)
    {
        var result = contiguous.Result!;
        Require(MathBlockOpenMath.ValidateProgram(result.Program).IsValid);
        var canonical = MathBlockOpenMath.NormalizeUtf8(source, options);
        Require(
            MathBlockOpenMath.ValidateUtf8(canonical, options).Canonicality ==
            MathBlockOpenMathCanonicality.Canonical);

        using var normalizationSource = new MemoryStream(source, false);
        using var normalizationDestination = new MemoryStream();
        MathBlockOpenMath.NormalizeUtf8(
            normalizationSource,
            normalizationDestination,
            options);
        Require(canonical.AsSpan().SequenceEqual(normalizationDestination.ToArray()));
    }

    if (characters.Succeeded)
    {
        var canonical = MathBlockOpenMath.Normalize(text, options);
        Require(
            MathBlockOpenMath.Validate(canonical, options).Canonicality ==
            MathBlockOpenMathCanonicality.Canonical);
    }
}

static void ExerciseFormulaInterchange(byte[] source)
{
    foreach (var format in new[]
             {
                 MathBlockFormulaFormat.OpenMath,
                 MathBlockFormulaFormat.ContentMathMl
             })
    {
        var contiguous = MathBlockFormulaInterchange.TryImportUtf8(source, format);
        CheckFormulaAttempt(contiguous);

        var sequence = CreateSequence(source, source.Length == 0 ? 1 : source[0] % 31 + 1);
        var segmented = MathBlockFormulaInterchange.TryImportUtf8(sequence, format);
        CheckFormulaEquivalent(contiguous, segmented);

        using var stream = new MemoryStream(source, false);
        var streamed = MathBlockFormulaInterchange.TryReadUtf8(stream, format);
        CheckFormulaEquivalent(contiguous, streamed);
        Require(
            contiguous.Succeeded ==
            MathBlockFormulaInterchange.ValidateUtf8(source, format).IsValid);

        ExerciseVisibleFormulaUtf8(source, format);

        string text;
        try
        {
            text = new UTF8Encoding(false, true).GetString(source);
        }
        catch (DecoderFallbackException)
        {
            continue;
        }

        var characters = MathBlockFormulaInterchange.TryImport(text, format);
        CheckFormulaAttempt(characters);
        using var reader = new StringReader(text);
        var characterStream = MathBlockFormulaInterchange.TryRead(reader, format);
        CheckFormulaEquivalent(characters, characterStream);
        Require(
            characters.Succeeded ==
            MathBlockFormulaInterchange.Validate(text, format).IsValid);
        ExerciseVisibleFormulaText(text, format);

        if (contiguous.Succeeded)
        {
            var result = contiguous.Result!;
            var canonical = MathBlockFormulaInterchange.ExportUtf8(
                result.Program,
                result.OutputName,
                format);
            Require(canonical.AsSpan().SequenceEqual(source));
            Require(
                MathBlockFormulaInterchange.ImportUtf8(canonical, format).Program.Fingerprint ==
                result.Program.Fingerprint);
        }
    }
}

static void ExerciseVisibleFormulaUtf8(byte[] source, MathBlockFormulaFormat format)
{
    try
    {
        var result = MathBlockFormulaInterchange.ImportUtf8(
            source,
            format,
            new Dictionary<string, MathBlockType>(),
            "result");
        CheckVisibleFormulaResult(result, format);
    }
    catch (FormatException)
    {
    }
}

static void ExerciseVisibleFormulaText(string source, MathBlockFormulaFormat format)
{
    try
    {
        var result = MathBlockFormulaInterchange.Import(
            source,
            format,
            new Dictionary<string, MathBlockType>(),
            "result");
        CheckVisibleFormulaResult(result, format);
    }
    catch (FormatException)
    {
    }
}

static void CheckVisibleFormulaResult(
    MathBlockFormulaImportResult result,
    MathBlockFormulaFormat format)
{
    var canonical = MathBlockFormulaInterchange.Export(
        result.Program,
        result.OutputName,
        format);
    var exact = MathBlockFormulaInterchange.Import(canonical, format);
    Require(exact.Program.Fingerprint == result.Program.Fingerprint);
}

static MathBlockOpenMathImportOptions CreateOptions() => new()
{
    MaximumDocumentCharacters = MaximumInputBytes,
    MaximumDocumentBytes = MaximumInputBytes,
    MaximumNodes = 512,
    MaximumOutputs = 512,
    MaximumValueElements = 4_096,
    CaptureSourceLocations = true
};

static void CheckAttempt(MathBlockOpenMathImportAttempt attempt)
{
    Require(attempt.Succeeded == (attempt.Result is not null));
    Require(attempt.Succeeded == (attempt.Diagnostic is null));
}

static void CheckFormulaAttempt(MathBlockFormulaImportAttempt attempt)
{
    Require(attempt.Succeeded == (attempt.Result is not null));
    Require(attempt.Succeeded == (attempt.Diagnostic is null));
}

static void CheckEquivalent(
    MathBlockOpenMathImportAttempt expected,
    MathBlockOpenMathImportAttempt actual)
{
    CheckAttempt(actual);
    Require(expected.Succeeded == actual.Succeeded);
    if (expected.Succeeded)
    {
        Require(expected.Result!.Program.Fingerprint == actual.Result!.Program.Fingerprint);
        Require(expected.Result.Operations.Count == actual.Result.Operations.Count);
        Require(
            expected.Result.OperationOccurrences.Count ==
            actual.Result.OperationOccurrences.Count);
    }
    else
    {
        Require(expected.Diagnostic!.Code == actual.Diagnostic!.Code);
    }
}

static void CheckFormulaEquivalent(
    MathBlockFormulaImportAttempt expected,
    MathBlockFormulaImportAttempt actual)
{
    CheckFormulaAttempt(actual);
    Require(expected.Succeeded == actual.Succeeded);
    if (expected.Succeeded)
    {
        Require(expected.Result!.Program.Fingerprint == actual.Result!.Program.Fingerprint);
        Require(expected.Result.OutputName == actual.Result.OutputName);
        Require(expected.Result.Format == actual.Result.Format);
    }
    else
    {
        Require(expected.Diagnostic!.Code == actual.Diagnostic!.Code);
    }
}

static void CheckValidation(
    MathBlockOpenMathImportAttempt attempt,
    MathBlockOpenMathValidationResult validation)
{
    Require(attempt.Succeeded == validation.IsValid);
    Require(validation.IsValid == (validation.Diagnostic is null));
    if (!validation.IsValid)
        Require(attempt.Diagnostic!.Code == validation.Diagnostic!.Code);
}

static ReadOnlySequence<byte> CreateSequence(byte[] source, int maximumSegment)
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

static void Require(bool condition)
{
    if (!condition)
        throw new InvalidOperationException("A notation fuzz invariant failed.");
}

sealed class ByteSegment : ReadOnlySequenceSegment<byte>
{
    public ByteSegment(ReadOnlyMemory<byte> memory) => Memory = memory;

    public void Append(ByteSegment segment)
    {
        segment.RunningIndex = RunningIndex + Memory.Length;
        Next = segment;
    }
}
