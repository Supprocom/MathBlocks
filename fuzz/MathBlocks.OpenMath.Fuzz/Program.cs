using System.Buffers;
using System.Text;
using SharpFuzz;
using Supprocom.MathBlocks;

const int MaximumInputBytes = 65_536;

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
        throw new InvalidOperationException("An OpenMath fuzz invariant failed.");
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
