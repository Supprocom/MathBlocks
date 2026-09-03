using System.Buffers;
using System.Diagnostics;

namespace Supprocom.MathBlocks;

/// <summary>Identifies the canonical state of a validated OpenMath document.</summary>
public enum MathBlockOpenMathCanonicality
{
    Canonical,
    Noncanonical,
    NotApplicable
}

/// <summary>Identifies the unit for a canonical source difference.</summary>
public enum MathBlockOpenMathDifferenceUnit
{
    Character,
    Byte
}

/// <summary>Contains a complete document-validation result.</summary>
[DebuggerDisplay("IsValid = {IsValid}, Canonicality = {Canonicality}")]
public sealed class MathBlockOpenMathValidationResult
{
    internal MathBlockOpenMathValidationResult(
        bool isValid,
        MathBlockOpenMathCanonicality canonicality,
        MathBlockOpenMathDiagnostic? diagnostic,
        long? differenceIndex,
        MathBlockOpenMathDifferenceUnit? differenceUnit)
    {
        IsValid = isValid;
        Canonicality = canonicality;
        Diagnostic = diagnostic;
        DifferenceIndex = differenceIndex;
        DifferenceUnit = differenceUnit;
    }

    /// <summary>Gets a value that identifies a valid Profile 1 document.</summary>
    public bool IsValid { get; }

    /// <summary>Gets the exact canonical state.</summary>
    public MathBlockOpenMathCanonicality Canonicality { get; }

    /// <summary>Gets the first diagnostic for invalid input.</summary>
    public MathBlockOpenMathDiagnostic? Diagnostic { get; }

    /// <summary>Gets the zero-based first canonical difference.</summary>
    public long? DifferenceIndex { get; }

    /// <summary>Gets the unit for the first canonical difference.</summary>
    public MathBlockOpenMathDifferenceUnit? DifferenceUnit { get; }
}

/// <summary>Contains the Profile 1 export-validation result for one program.</summary>
[DebuggerDisplay("IsValid = {IsValid}")]
public sealed class MathBlockOpenMathProgramValidationResult
{
    internal MathBlockOpenMathProgramValidationResult(
        bool isValid,
        MathBlockOpenMathDiagnostic? diagnostic)
    {
        IsValid = isValid;
        Diagnostic = diagnostic;
    }

    /// <summary>Gets a value that identifies an exportable program.</summary>
    public bool IsValid { get; }

    /// <summary>Gets the first export diagnostic.</summary>
    public MathBlockOpenMathDiagnostic? Diagnostic { get; }
}

public static partial class MathBlockOpenMath
{
    /// <summary>Validates a Profile 1 character document and its canonical state.</summary>
    public static MathBlockOpenMathValidationResult Validate(
        string? source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var validationOptions = CreateValidationOptions(options);
        if (source is null)
            return InvalidValidation(NullSourceAttempt().Diagnostic!);
        var attempt = TryImport(source, validationOptions);
        if (!attempt.Succeeded)
            return InvalidValidation(attempt.Diagnostic!);
        var canonical = Export(attempt.Result!.Program);
        var difference = FindDifference(source.AsSpan(), canonical.AsSpan());
        return ValidValidation(difference, MathBlockOpenMathDifferenceUnit.Character);
    }

    /// <summary>Validates contiguous Profile 1 UTF-8 bytes and their canonical state.</summary>
    public static MathBlockOpenMathValidationResult ValidateUtf8(
        ReadOnlySpan<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var validationOptions = CreateValidationOptions(options);
        var attempt = TryImportUtf8(source, validationOptions);
        if (!attempt.Succeeded)
            return InvalidValidation(attempt.Diagnostic!);
        var canonical = ExportUtf8(attempt.Result!.Program);
        var difference = FindDifference(source, canonical);
        return ValidValidation(difference, MathBlockOpenMathDifferenceUnit.Byte);
    }

    /// <summary>Validates segmented Profile 1 UTF-8 bytes and their canonical state.</summary>
    public static MathBlockOpenMathValidationResult ValidateUtf8(
        ReadOnlySequence<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var validationOptions = CreateValidationOptions(options);
        var attempt = TryImportUtf8(source, validationOptions);
        if (!attempt.Succeeded)
            return InvalidValidation(attempt.Diagnostic!);
        var canonical = ExportUtf8(attempt.Result!.Program);
        var difference = FindDifference(source, canonical);
        return ValidValidation(difference, MathBlockOpenMathDifferenceUnit.Byte);
    }

    /// <summary>Normalizes one valid Profile 1 character document.</summary>
    public static string Normalize(
        string source,
        MathBlockOpenMathImportOptions? options = null)
    {
        ArgumentNullException.ThrowIfNull(source);
        var result = Import(source, CreateValidationOptions(options));
        return Export(result.Program);
    }

    /// <summary>Normalizes contiguous Profile 1 UTF-8 bytes.</summary>
    public static byte[] NormalizeUtf8(
        ReadOnlySpan<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var result = ImportUtf8(source, CreateValidationOptions(options));
        return ExportUtf8(result.Program);
    }

    /// <summary>Normalizes segmented Profile 1 UTF-8 bytes.</summary>
    public static byte[] NormalizeUtf8(
        ReadOnlySequence<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var result = ImportUtf8(source, CreateValidationOptions(options));
        return ExportUtf8(result.Program);
    }

    /// <summary>Normalizes a character document between caller-owned endpoints.</summary>
    public static void Normalize(
        TextReader source,
        TextWriter destination,
        MathBlockOpenMathImportOptions? options = null)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(destination);
        if (ReferenceEquals(source, destination))
            throw new ArgumentException("The source and destination must be different objects.");
        var result = Read(source, CreateValidationOptions(options));
        Write(result.Program, destination);
    }

    /// <summary>Normalizes a character document asynchronously.</summary>
    public static async Task NormalizeAsync(
        TextReader source,
        TextWriter destination,
        MathBlockOpenMathImportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(destination);
        if (ReferenceEquals(source, destination))
            throw new ArgumentException("The source and destination must be different objects.");
        cancellationToken.ThrowIfCancellationRequested();
        var result = await ReadAsync(
                source,
                CreateValidationOptions(options),
                cancellationToken)
            .ConfigureAwait(false);
        await WriteAsync(result.Program, destination, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>Normalizes a UTF-8 document between caller-owned streams.</summary>
    public static void NormalizeUtf8(
        Stream source,
        Stream destination,
        MathBlockOpenMathImportOptions? options = null)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(destination);
        if (ReferenceEquals(source, destination))
            throw new ArgumentException("The source and destination streams must be different.");
        var result = ReadUtf8(source, CreateValidationOptions(options));
        WriteUtf8(result.Program, destination);
    }

    /// <summary>Normalizes a UTF-8 document asynchronously.</summary>
    public static async Task NormalizeUtf8Async(
        Stream source,
        Stream destination,
        MathBlockOpenMathImportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(destination);
        if (ReferenceEquals(source, destination))
            throw new ArgumentException("The source and destination streams must be different.");
        cancellationToken.ThrowIfCancellationRequested();
        var result = await ReadUtf8Async(
                source,
                CreateValidationOptions(options),
                cancellationToken)
            .ConfigureAwait(false);
        await WriteUtf8Async(result.Program, destination, cancellationToken)
            .ConfigureAwait(false);
    }

    /// <summary>Checks whether Profile 1 can export a program.</summary>
    public static MathBlockOpenMathProgramValidationResult ValidateProgram(
        MathBlockProgram? program)
    {
        if (program is null)
        {
            return new MathBlockOpenMathProgramValidationResult(
                false,
                new MathBlockOpenMathDiagnostic(
                    MathBlockOpenMathDiagnosticCode.ProgramNull,
                    "The MathBlocks program is null."));
        }
        try
        {
            _ = GetUtf8ByteCount(program);
            return new MathBlockOpenMathProgramValidationResult(true, null);
        }
        catch (InvalidOperationException exception)
        {
            return new MathBlockOpenMathProgramValidationResult(
                false,
                CreateProgramDiagnostic(exception));
        }
    }

    private static MathBlockOpenMathValidationResult InvalidValidation(
        MathBlockOpenMathDiagnostic diagnostic) => new(
            false,
            MathBlockOpenMathCanonicality.NotApplicable,
            diagnostic,
            null,
            null);

    private static MathBlockOpenMathValidationResult ValidValidation(
        long? difference,
        MathBlockOpenMathDifferenceUnit unit) => new(
            true,
            difference is null
                ? MathBlockOpenMathCanonicality.Canonical
                : MathBlockOpenMathCanonicality.Noncanonical,
            null,
            difference,
            difference is null ? null : unit);

    private static long? FindDifference(ReadOnlySpan<char> source, ReadOnlySpan<char> canonical)
    {
        var count = Math.Min(source.Length, canonical.Length);
        for (var index = 0; index < count; index++)
            if (source[index] != canonical[index])
                return index;
        return source.Length == canonical.Length ? null : count;
    }

    private static long? FindDifference(ReadOnlySpan<byte> source, ReadOnlySpan<byte> canonical)
    {
        var count = Math.Min(source.Length, canonical.Length);
        for (var index = 0; index < count; index++)
            if (source[index] != canonical[index])
                return index;
        return source.Length == canonical.Length ? null : count;
    }

    private static long? FindDifference(ReadOnlySequence<byte> source, ReadOnlySpan<byte> canonical)
    {
        long index = 0;
        foreach (var segment in source)
        {
            var value = segment.Span;
            for (var offset = 0; offset < value.Length; offset++, index++)
            {
                if (index >= canonical.Length || value[offset] != canonical[(int)index])
                    return index;
            }
        }
        return index == canonical.Length ? null : index;
    }

    private static MathBlockOpenMathImportOptions CreateValidationOptions(
        MathBlockOpenMathImportOptions? options)
    {
        var snapshot = CreateOptionsSnapshot(options);
        return new MathBlockOpenMathImportOptions
        {
            MaximumDocumentCharacters = snapshot.MaximumDocumentCharacters,
            MaximumDocumentBytes = snapshot.MaximumDocumentBytes,
            MaximumNodes = snapshot.MaximumNodes,
            MaximumOutputs = snapshot.MaximumOutputs,
            MaximumValueElements = snapshot.MaximumValueElements,
            RequireCanonicalSource = false,
            CaptureSourceLocations = false
        };
    }

    private static MathBlockOpenMathDiagnostic CreateProgramDiagnostic(
        InvalidOperationException exception)
    {
        var code = exception.Message switch
        {
            "The program contains an operation outside the standard OpenMath profile." =>
                MathBlockOpenMathDiagnosticCode.OperationOutsideProfile,
            "The program node order is invalid." or
            "An operation input must reference an earlier node." =>
                MathBlockOpenMathDiagnosticCode.InvalidProgramNodeOrder,
            "The program contains an unsupported node kind." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedProgramNodeKind,
            "A program input name is not supported by OpenMath." or
            "A program output name is not supported by OpenMath." or
            "A program input name contains an unsupported XML character." or
            "A program output name contains an unsupported XML character." =>
                MathBlockOpenMathDiagnosticCode.InvalidProgramName,
            "A program type is not supported by OpenMath." =>
                MathBlockOpenMathDiagnosticCode.InvalidProgramType,
            "An OpenMath constant must be valid." or
            "The constant value kind is not supported." or
            "An OpenMath float must be finite." =>
                MathBlockOpenMathDiagnosticCode.InvalidProgramConstant,
            "A program output has an invalid node." =>
                MathBlockOpenMathDiagnosticCode.InvalidProgramOutput,
            _ => MathBlockOpenMathDiagnosticCode.InvalidProgram
        };
        return new MathBlockOpenMathDiagnostic(code, exception.Message);
    }
}
