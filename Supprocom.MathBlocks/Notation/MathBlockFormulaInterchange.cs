using System.Buffers;
using System.Globalization;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

/// <summary>
/// Imports and exports exact single-output formulas as OpenMath or Strict Content MathML.
/// </summary>
public static partial class MathBlockFormulaInterchange
{
    /// <summary>Gets the maximum accepted formula-document character count.</summary>
    public const int MaximumDocumentCharacters =
        MathBlockOpenMath.MaximumDocumentCharacters * 6;

    /// <summary>Gets the maximum accepted UTF-8 formula-document byte count.</summary>
    public const int MaximumDocumentUtf8Bytes = MaximumDocumentCharacters * 3 + 3;

    /// <summary>Gets the maximum number of buffered visible-expression elements.</summary>
    public const int MaximumExpressionElements = 16 * 1024;

    /// <summary>Gets the maximum visible-expression nesting depth.</summary>
    public const int MaximumExpressionDepth = 256;

    private const string OpenMathNamespace = "http://www.openmath.org/OpenMath";
    private const string MathMlNamespace = "http://www.w3.org/1998/Math/MathML";
    private static readonly Encoding StrictUtf8 = new UTF8Encoding(false, true);

    /// <summary>
    /// Exports one selected output as a canonical formula document in the lowest profile that
    /// contains every operation reachable from that output.
    /// </summary>
    public static string Export(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format) =>
        ExportCore(program, outputName, format, null);

    /// <summary>Exports one selected output as a canonical formula document in the specified profile.</summary>
    public static string Export(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile)
    {
        ArgumentNullException.ThrowIfNull(profile);
        return ExportCore(program, outputName, format, profile);
    }

    /// <summary>Exports one selected output as canonical UTF-8 in its lowest covering profile.</summary>
    public static byte[] ExportUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format) =>
        StrictUtf8.GetBytes(ExportCore(program, outputName, format, null));

    /// <summary>Exports one selected output as canonical UTF-8 in the specified profile.</summary>
    public static byte[] ExportUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile) =>
        StrictUtf8.GetBytes(Export(program, outputName, format, profile));

    /// <summary>Gets the exact canonical UTF-8 byte count in the lowest covering profile.</summary>
    public static int GetUtf8ByteCount(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format) =>
        StrictUtf8.GetByteCount(ExportCore(program, outputName, format, null));

    /// <summary>Gets the exact canonical UTF-8 byte count in the specified profile.</summary>
    public static int GetUtf8ByteCount(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile) =>
        StrictUtf8.GetByteCount(Export(program, outputName, format, profile));

    /// <summary>Tries to write one canonical formula into a supplied UTF-8 destination.</summary>
    public static bool TryWriteUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        Span<byte> destination,
        out int bytesWritten) =>
        TryWriteUtf8(
            ExportCore(program, outputName, format, null),
            destination,
            out bytesWritten);

    /// <summary>Tries to write one canonical formula in the specified profile into a UTF-8 destination.</summary>
    public static bool TryWriteUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile,
        Span<byte> destination,
        out int bytesWritten) =>
        TryWriteUtf8(
            Export(program, outputName, format, profile),
            destination,
            out bytesWritten);

    /// <summary>Writes one canonical formula through a caller-owned buffer writer.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        IBufferWriter<byte> destination)
    {
        ArgumentNullException.ThrowIfNull(destination);
        destination.Write(StrictUtf8.GetBytes(ExportCore(program, outputName, format, null)));
    }

    /// <summary>Writes one canonical formula in the specified profile through a buffer writer.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile,
        IBufferWriter<byte> destination)
    {
        ArgumentNullException.ThrowIfNull(destination);
        destination.Write(ExportUtf8(program, outputName, format, profile));
    }

    /// <summary>Writes one canonical formula to a caller-owned character writer.</summary>
    public static void Write(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        TextWriter destination)
    {
        ArgumentNullException.ThrowIfNull(destination);
        destination.Write(ExportCore(program, outputName, format, null));
    }

    /// <summary>Writes one canonical formula in the specified profile to a character writer.</summary>
    public static void Write(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile,
        TextWriter destination)
    {
        ArgumentNullException.ThrowIfNull(destination);
        destination.Write(Export(program, outputName, format, profile));
    }

    /// <summary>Writes one canonical formula to a caller-owned byte stream.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        Stream destination)
    {
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream must support writing.", nameof(destination));
        destination.Write(StrictUtf8.GetBytes(ExportCore(program, outputName, format, null)));
    }

    /// <summary>Writes one canonical formula in the specified profile to a byte stream.</summary>
    public static void WriteUtf8(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile,
        Stream destination)
    {
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream must support writing.", nameof(destination));
        destination.Write(ExportUtf8(program, outputName, format, profile));
    }

    /// <summary>Writes one canonical formula asynchronously to a caller-owned byte stream.</summary>
    public static async Task WriteUtf8Async(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        Stream destination,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream must support writing.", nameof(destination));
        cancellationToken.ThrowIfCancellationRequested();
        var source = StrictUtf8.GetBytes(ExportCore(program, outputName, format, null));
        await destination.WriteAsync(source, cancellationToken).ConfigureAwait(false);
    }

    /// <summary>Writes one canonical formula asynchronously to a caller-owned character writer.</summary>
    public static async Task WriteAsync(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        TextWriter destination,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(destination);
        cancellationToken.ThrowIfCancellationRequested();
        var source = ExportCore(program, outputName, format, null);
        await destination.WriteAsync(source.AsMemory(), cancellationToken).ConfigureAwait(false);
    }

    /// <summary>
    /// Gets the lowest supported profile that contains every operation reachable from one output.
    /// </summary>
    public static MathBlockFormulaProfileDescriptor SelectProfile(
        MathBlockProgram program,
        string outputName) =>
        CreateSelection(program, outputName, PublishedProfiles, null).Profile;

    internal static MathBlockFormulaProfileDescriptor SelectProfile(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaProfileDescriptor[] profiles) =>
        CreateSelection(program, outputName, CreateCandidates(profiles), null).Profile;

    private static string ExportCore(
        MathBlockProgram program,
        string outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor? profile)
    {
        var selection = CreateSelection(program, outputName, PublishedProfiles, profile);
        return ExportSelection(selection, format);
    }

    private static string ExportSelection(
        FormulaSelection selection,
        MathBlockFormulaFormat format)
    {
        var exact = MathBlockOpenMath.Export(selection.Program, selection.Profile.OpenMathProfile);
        var result = new StringBuilder();
        using (var writer = XmlWriter.Create(result, CreateWriterSettings()))
            WriteDocument(writer, selection, exact, format);
        return result.ToString();
    }

    private static bool TryWriteUtf8(
        string source,
        Span<byte> destination,
        out int bytesWritten)
    {
        var required = StrictUtf8.GetByteCount(source);
        if (destination.Length < required)
        {
            bytesWritten = 0;
            return false;
        }
        bytesWritten = StrictUtf8.GetBytes(source, destination);
        return true;
    }

    /// <summary>Imports one canonical formula document.</summary>
    public static MathBlockFormulaImportResult Import(
        string source,
        MathBlockFormulaFormat format) =>
        Import(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Imports one canonical formula document with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportResult Import(
        string source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        ArgumentNullException.ThrowIfNull(source);
        RequireOptions(options);
        RequireFormat(format);
        if (source.Length == 0)
            throw new FormatException("The formula source is empty.");
        if (source.Length > options.MaximumDocumentCharacters)
            throw new FormatException("The formula source exceeds the character limit.");

        return ImportCore(source, format, PublishedProfiles, options);
    }

    // Imports with an explicit ascending profile list instead of the published profiles.
    internal static MathBlockFormulaImportResult Import(
        string source,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor[] profiles)
    {
        ArgumentNullException.ThrowIfNull(source);
        RequireFormat(format);
        if (source.Length == 0)
            throw new FormatException("The formula source is empty.");
        if (source.Length > MaximumDocumentCharacters)
            throw new FormatException("The formula source exceeds the character limit.");
        return ImportCore(source, format, CreateCandidates(profiles), MathBlockFormulaInterchangeOptions.Default);
    }

    // The document's cdgroup selects the profile, and the exact annotation must be a canonical
    // program of that profile's OpenMath profile. A source whose cdgroup matches no profile is
    // checked against the lowest profile, so it fails the canonical comparison.
    private static MathBlockFormulaImportResult ImportCore(
        string source,
        MathBlockFormulaFormat format,
        Lazy<MathBlockFormulaProfileDescriptor>[] profiles,
        MathBlockFormulaInterchangeOptions options)
    {
        var exact = ExtractExactAnnotation(source, format, profiles, options, out var profile);
        MathBlockOpenMathImportResult imported;
        try
        {
            imported = MathBlockOpenMath.Import(exact, options.OpenMathOptions, [profile.OpenMathProfile]);
        }
        catch (FormatException exception)
        {
            throw new FormatException("The formula exact annotation is invalid.", exception);
        }
        if (imported.Program.OutputCount != 1)
            throw new FormatException("A formula annotation must contain exactly one output.");
        var outputName = imported.Program.GetOutputName(0);
        var canonical = ExportSelection(
            CreateSelection(imported.Program, outputName, profiles, profile),
            format);
        if (!string.Equals(source, canonical, StringComparison.Ordinal))
        {
            throw new FormatException(
                "The formula expression does not match its exact annotation or canonical form.");
        }
        return new MathBlockFormulaImportResult(imported, profile, outputName, format);
    }

    /// <summary>Imports one canonical formula from contiguous UTF-8.</summary>
    public static MathBlockFormulaImportResult ImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format) =>
        ImportUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Imports one canonical formula from contiguous UTF-8 with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportResult ImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        if (source.Length == 0)
            throw new FormatException("The formula source is empty.");
        if (source.Length > options.MaximumDocumentUtf8Bytes)
            throw new FormatException("The formula source exceeds the byte limit.");
        try
        {
            return Import(StrictUtf8.GetString(source), format, options);
        }
        catch (DecoderFallbackException exception)
        {
            throw new FormatException("The formula UTF-8 source is invalid.", exception);
        }
    }

    /// <summary>Imports one canonical formula from segmented UTF-8.</summary>
    public static MathBlockFormulaImportResult ImportUtf8(
        ReadOnlySequence<byte> source,
        MathBlockFormulaFormat format) =>
        ImportUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Imports one canonical formula from segmented UTF-8 with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportResult ImportUtf8(
        ReadOnlySequence<byte> source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        if (source.IsEmpty)
            throw new FormatException("The formula source is empty.");
        if (source.Length > options.MaximumDocumentUtf8Bytes)
            throw new FormatException("The formula source exceeds the byte limit.");
        return ImportUtf8(source.ToArray(), format, options);
    }

    /// <summary>Normalizes an already canonical formula and verifies its exact annotation.</summary>
    public static string Normalize(string source, MathBlockFormulaFormat format) =>
        Normalize(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Normalizes an already canonical formula with the specified size ceilings and verifies its exact annotation.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static string Normalize(
        string source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        var result = Import(source, format, options);
        return Export(result.Program, result.OutputName, format, result.Profile);
    }

    /// <summary>Normalizes a canonical UTF-8 formula.</summary>
    public static byte[] NormalizeUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format) =>
        NormalizeUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Normalizes a canonical UTF-8 formula with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static byte[] NormalizeUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        var result = ImportUtf8(source, format, options);
        return ExportUtf8(result.Program, result.OutputName, format, result.Profile);
    }

    /// <summary>Reads one canonical formula from a caller-owned character reader.</summary>
    public static MathBlockFormulaImportResult Read(
        TextReader source,
        MathBlockFormulaFormat format) =>
        Read(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Reads one canonical formula from a caller-owned character reader with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportResult Read(
        TextReader source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        ArgumentNullException.ThrowIfNull(source);
        RequireOptions(options);
        RequireFormat(format);
        return Import(ReadCharacters(source, options), format, options);
    }

    /// <summary>Reads one canonical formula asynchronously from a character reader.</summary>
#pragma warning disable RS0027 // The overload with options has a required token and one parameter more; callers of this shipped signature still bind here.
    public static Task<MathBlockFormulaImportResult> ReadAsync(
        TextReader source,
        MathBlockFormulaFormat format,
        CancellationToken cancellationToken = default) =>
        ReadAsync(source, format, MathBlockFormulaInterchangeOptions.Default, cancellationToken);
#pragma warning restore RS0027

    /// <summary>Reads one canonical formula asynchronously from a character reader with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static async Task<MathBlockFormulaImportResult> ReadAsync(
        TextReader source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(source);
        RequireOptions(options);
        RequireFormat(format);
        cancellationToken.ThrowIfCancellationRequested();
        return Import(
            await ReadCharactersAsync(source, options, cancellationToken).ConfigureAwait(false),
            format,
            options);
    }

    /// <summary>Reads one canonical UTF-8 formula from a caller-owned stream.</summary>
    public static MathBlockFormulaImportResult ReadUtf8(
        Stream source,
        MathBlockFormulaFormat format) =>
        ReadUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Reads one canonical UTF-8 formula from a caller-owned stream with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportResult ReadUtf8(
        Stream source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        ArgumentNullException.ThrowIfNull(source);
        RequireOptions(options);
        RequireFormat(format);
        if (!source.CanRead)
            throw new ArgumentException("The source stream must support reading.", nameof(source));
        return ImportUtf8(ReadBytes(source, options), format, options);
    }

    /// <summary>Reads one canonical UTF-8 formula asynchronously from a caller-owned stream.</summary>
#pragma warning disable RS0027 // The overload with options has a required token and one parameter more; callers of this shipped signature still bind here.
    public static Task<MathBlockFormulaImportResult> ReadUtf8Async(
        Stream source,
        MathBlockFormulaFormat format,
        CancellationToken cancellationToken = default) =>
        ReadUtf8Async(source, format, MathBlockFormulaInterchangeOptions.Default, cancellationToken);
#pragma warning restore RS0027

    /// <summary>Reads one canonical UTF-8 formula asynchronously from a caller-owned stream with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static async Task<MathBlockFormulaImportResult> ReadUtf8Async(
        Stream source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options,
        CancellationToken cancellationToken)
    {
        ArgumentNullException.ThrowIfNull(source);
        RequireOptions(options);
        RequireFormat(format);
        if (!source.CanRead)
            throw new ArgumentException("The source stream must support reading.", nameof(source));
        cancellationToken.ThrowIfCancellationRequested();
        return ImportUtf8(
            await ReadBytesAsync(source, options, cancellationToken).ConfigureAwait(false),
            format,
            options);
    }

    /// <summary>Attempts to import one canonical formula document.</summary>
    public static MathBlockFormulaImportAttempt TryImport(
        string? source,
        MathBlockFormulaFormat format) =>
        TryImport(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Attempts to import one canonical formula document with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportAttempt TryImport(
        string? source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        RequireFormat(format);
        if (source is null)
        {
            return MathBlockFormulaImportAttempt.Failure(
                new MathBlockFormulaDiagnostic(
                    MathBlockFormulaDiagnosticCode.SourceNull,
                    "The formula source is null."));
        }
        try
        {
            return MathBlockFormulaImportAttempt.Success(Import(source, format, options));
        }
        catch (FormatException exception)
        {
            return MathBlockFormulaImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to import one canonical formula from contiguous UTF-8.</summary>
    public static MathBlockFormulaImportAttempt TryImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format) =>
        TryImportUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Attempts to import one canonical formula from contiguous UTF-8 with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportAttempt TryImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        try
        {
            return MathBlockFormulaImportAttempt.Success(ImportUtf8(source, format, options));
        }
        catch (FormatException exception)
        {
            return MathBlockFormulaImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to import one canonical formula from segmented UTF-8.</summary>
    public static MathBlockFormulaImportAttempt TryImportUtf8(
        ReadOnlySequence<byte> source,
        MathBlockFormulaFormat format) =>
        TryImportUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Attempts to import one canonical formula from segmented UTF-8 with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportAttempt TryImportUtf8(
        ReadOnlySequence<byte> source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        try
        {
            return MathBlockFormulaImportAttempt.Success(ImportUtf8(source, format, options));
        }
        catch (FormatException exception)
        {
            return MathBlockFormulaImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to read one canonical formula from a character reader.</summary>
    public static MathBlockFormulaImportAttempt TryRead(
        TextReader? source,
        MathBlockFormulaFormat format) =>
        TryRead(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Attempts to read one canonical formula from a character reader with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportAttempt TryRead(
        TextReader? source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        RequireFormat(format);
        if (source is null)
        {
            return MathBlockFormulaImportAttempt.Failure(
                new MathBlockFormulaDiagnostic(
                    MathBlockFormulaDiagnosticCode.SourceNull,
                    "The formula source is null."));
        }
        try
        {
            return MathBlockFormulaImportAttempt.Success(Read(source, format, options));
        }
        catch (FormatException exception)
        {
            return MathBlockFormulaImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to read one canonical UTF-8 formula from a stream.</summary>
    public static MathBlockFormulaImportAttempt TryReadUtf8(
        Stream? source,
        MathBlockFormulaFormat format) =>
        TryReadUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Attempts to read one canonical UTF-8 formula from a stream with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaImportAttempt TryReadUtf8(
        Stream? source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        RequireOptions(options);
        RequireFormat(format);
        if (source is null)
        {
            return MathBlockFormulaImportAttempt.Failure(
                new MathBlockFormulaDiagnostic(
                    MathBlockFormulaDiagnosticCode.SourceNull,
                    "The formula source is null."));
        }
        try
        {
            return MathBlockFormulaImportAttempt.Success(ReadUtf8(source, format, options));
        }
        catch (FormatException exception)
        {
            return MathBlockFormulaImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Validates one formula document completely.</summary>
    public static MathBlockFormulaValidationResult Validate(
        string? source,
        MathBlockFormulaFormat format) =>
        Validate(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Validates one formula document completely with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaValidationResult Validate(
        string? source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        var attempt = TryImport(source, format, options);
        return new MathBlockFormulaValidationResult(attempt.Succeeded, attempt.Diagnostic);
    }

    /// <summary>Validates one contiguous UTF-8 formula completely.</summary>
    public static MathBlockFormulaValidationResult ValidateUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format) =>
        ValidateUtf8(source, format, MathBlockFormulaInterchangeOptions.Default);

    /// <summary>Validates one contiguous UTF-8 formula completely with the specified size ceilings.</summary>
    /// <exception cref="ArgumentOutOfRangeException">A ceiling is above the .NET limit it is bounded by.</exception>
    public static MathBlockFormulaValidationResult ValidateUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format,
        MathBlockFormulaInterchangeOptions options)
    {
        var attempt = TryImportUtf8(source, format, options);
        return new MathBlockFormulaValidationResult(attempt.Succeeded, attempt.Diagnostic);
    }

    /// <summary>Checks whether one selected output can be exported by a supported profile.</summary>
    public static MathBlockFormulaValidationResult ValidateProgram(
        MathBlockProgram? program,
        string? outputName,
        MathBlockFormulaFormat format) =>
        ValidateProgramCore(program, outputName, format, null);

    /// <summary>Checks whether one selected output can be exported by the specified profile.</summary>
    public static MathBlockFormulaValidationResult ValidateProgram(
        MathBlockProgram? program,
        string? outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor profile)
    {
        ArgumentNullException.ThrowIfNull(profile);
        return ValidateProgramCore(program, outputName, format, profile);
    }

    private static MathBlockFormulaValidationResult ValidateProgramCore(
        MathBlockProgram? program,
        string? outputName,
        MathBlockFormulaFormat format,
        MathBlockFormulaProfileDescriptor? profile)
    {
        RequireFormat(format);
        if (program is null)
        {
            return new MathBlockFormulaValidationResult(
                false,
                new MathBlockFormulaDiagnostic(
                    MathBlockFormulaDiagnosticCode.ProgramNull,
                    "The MathBlocks program is null."));
        }
        try
        {
            _ = ExportCore(program, outputName!, format, profile);
            return new MathBlockFormulaValidationResult(true, null);
        }
        catch (ArgumentException exception)
        {
            return new MathBlockFormulaValidationResult(
                false,
                new MathBlockFormulaDiagnostic(
                    MathBlockFormulaDiagnosticCode.InvalidOutputName,
                    exception.Message));
        }
        catch (KeyNotFoundException exception)
        {
            return new MathBlockFormulaValidationResult(
                false,
                new MathBlockFormulaDiagnostic(
                    MathBlockFormulaDiagnosticCode.MissingOutput,
                    exception.Message));
        }
        catch (InvalidOperationException exception)
        {
            var code = exception.Data.Contains(OutsideProfileKey)
                ? MathBlockFormulaDiagnosticCode.OperationOutsideProfile
                : MathBlockFormulaDiagnosticCode.InvalidProgram;
            return new MathBlockFormulaValidationResult(
                false,
                new MathBlockFormulaDiagnostic(code, exception.Message));
        }
    }

    private static string ReadCharacters(TextReader source, MathBlockFormulaInterchangeOptions options)
    {
        var result = new StringBuilder();
        var buffer = new char[8192];
        while (true)
        {
            var count = source.Read(buffer, 0, buffer.Length);
            if (count == 0)
                return result.ToString();
            if (count > options.MaximumDocumentCharacters - result.Length)
                throw new FormatException("The formula source exceeds the character limit.");
            result.Append(buffer, 0, count);
        }
    }

    private static async Task<string> ReadCharactersAsync(
        TextReader source,
        MathBlockFormulaInterchangeOptions options,
        CancellationToken cancellationToken)
    {
        var result = new StringBuilder();
        var buffer = new char[8192];
        while (true)
        {
            var count = await source.ReadAsync(buffer.AsMemory(), cancellationToken)
                .ConfigureAwait(false);
            if (count == 0)
                return result.ToString();
            if (count > options.MaximumDocumentCharacters - result.Length)
                throw new FormatException("The formula source exceeds the character limit.");
            result.Append(buffer, 0, count);
        }
    }

    private static byte[] ReadBytes(Stream source, MathBlockFormulaInterchangeOptions options)
    {
        var result = new ArrayBufferWriter<byte>();
        var buffer = new byte[8192];
        while (true)
        {
            var count = source.Read(buffer, 0, buffer.Length);
            if (count == 0)
                return result.WrittenSpan.ToArray();
            if (count > options.MaximumDocumentUtf8Bytes - result.WrittenCount)
                throw new FormatException("The formula source exceeds the byte limit.");
            result.Write(buffer.AsSpan(0, count));
        }
    }

    private static async Task<byte[]> ReadBytesAsync(
        Stream source,
        MathBlockFormulaInterchangeOptions options,
        CancellationToken cancellationToken)
    {
        var result = new ArrayBufferWriter<byte>();
        var buffer = new byte[8192];
        while (true)
        {
            var count = await source.ReadAsync(buffer.AsMemory(), cancellationToken)
                .ConfigureAwait(false);
            if (count == 0)
                return result.WrittenSpan.ToArray();
            if (count > options.MaximumDocumentUtf8Bytes - result.WrittenCount)
                throw new FormatException("The formula source exceeds the byte limit.");
            result.Write(buffer.AsSpan(0, count));
        }
    }

    private static MathBlockFormulaDiagnostic CreateDiagnostic(FormatException exception)
    {
        var code = exception.Message switch
        {
            "The formula source is empty." => MathBlockFormulaDiagnosticCode.SourceEmpty,
            "The formula source exceeds the character limit." =>
                MathBlockFormulaDiagnosticCode.DocumentCharacterLimitExceeded,
            "The formula source exceeds the byte limit." =>
                MathBlockFormulaDiagnosticCode.DocumentByteLimitExceeded,
            "The formula UTF-8 source is invalid." =>
                MathBlockFormulaDiagnosticCode.InvalidUtf8,
            "The formula source is not valid XML." or
            "The formula document root does not match its format." =>
                MathBlockFormulaDiagnosticCode.InvalidXml,
            "The formula document contains unsupported content." =>
                MathBlockFormulaDiagnosticCode.UnsupportedDocumentContent,
            "The formula exact annotation is missing." =>
                MathBlockFormulaDiagnosticCode.MissingExactAnnotation,
            "The formula has duplicate exact annotations." =>
                MathBlockFormulaDiagnosticCode.DuplicateExactAnnotation,
            "The formula exact annotation is invalid." or
            "A formula annotation must contain exactly one output." =>
                MathBlockFormulaDiagnosticCode.InvalidExactAnnotation,
            "The formula expression does not match its exact annotation or canonical form." =>
                MathBlockFormulaDiagnosticCode.VisibleExpressionMismatch,
            _ => MathBlockFormulaDiagnosticCode.InvalidProgram
        };
        return new MathBlockFormulaDiagnostic(code, exception.Message);
    }

    private static FormulaSelection CreateSelection(
        MathBlockProgram program,
        string outputName,
        Lazy<MathBlockFormulaProfileDescriptor>[] profiles,
        MathBlockFormulaProfileDescriptor? requiredProfile)
    {
        ArgumentNullException.ThrowIfNull(program);
        if (string.IsNullOrWhiteSpace(outputName) || !string.Equals(outputName, outputName.Trim(), StringComparison.Ordinal))
            throw new ArgumentException("A canonical output name is required.", nameof(outputName));
        if (!program.OutputNodeIndexes.TryGetValue(outputName, out var rootNode))
            throw new KeyNotFoundException($"Program output '{outputName}' is missing.");

        var nodes = program.Nodes;
        var reachable = new bool[nodes.Length];
        var pending = new Stack<int>();
        pending.Push(rootNode);
        while (pending.Count != 0)
        {
            var index = pending.Pop();
            if ((uint)index >= (uint)nodes.Length)
                throw new InvalidOperationException("The formula output has an invalid node.");
            if (reachable[index])
                continue;
            reachable[index] = true;
            var node = nodes[index];
            for (var inputIndex = 0; inputIndex < node.Inputs.Length; inputIndex++)
            {
                var input = node.Inputs[inputIndex];
                if (input < 0 || input >= index)
                {
                    throw new InvalidOperationException(
                        "A formula operation must reference an earlier node.");
                }
                pending.Push(input);
            }
        }

        var profile = requiredProfile is null
            ? SelectReachableProfile(nodes, reachable, profiles)
            : RequireReachableProfile(nodes, reachable, requiredProfile);
        var builder = new MathBlockProgramBuilder(profile.OpenMathProfile.Registry);
        var indexes = new int[nodes.Length];
        for (var index = 0; index < indexes.Length; index++)
            indexes[index] = -1;

        for (var index = 0; index < nodes.Length; index++)
        {
            if (!reachable[index])
                continue;
            var node = nodes[index];
            indexes[index] = node.Kind switch
            {
                MathBlockProgramBuilder.NodeKind.Input =>
                    builder.Input(node.Name!, node.Type),
                MathBlockProgramBuilder.NodeKind.Constant =>
                    builder.Constant(node.Value),
                MathBlockProgramBuilder.NodeKind.Operation =>
                    CopyOperation(builder, node, indexes, profile),
                _ => throw new InvalidOperationException(
                    "The formula contains an unsupported node kind.")
            };
        }

        var selectedRoot = indexes[rootNode];
        if (selectedRoot < 0)
            throw new InvalidOperationException("The formula output has an invalid node.");
        return new FormulaSelection(
            builder.Output(outputName, selectedRoot).Build(),
            selectedRoot,
            profile);
    }

    // Profiles are tried in ascending order, so an output that a lower profile covers never
    // constructs a higher one.
    private static MathBlockFormulaProfileDescriptor SelectReachableProfile(
        MathBlockProgram.Node[] nodes,
        bool[] reachable,
        Lazy<MathBlockFormulaProfileDescriptor>[] profiles)
    {
        MathBlockFormulaProfileDescriptor? highest = null;
        for (var index = 0; index < profiles.Length; index++)
        {
            highest = profiles[index].Value;
            if (FindReachableOperationOutside(nodes, reachable, highest) < 0)
                return highest;
        }
        var outside = FindReachableOperationOutside(nodes, reachable, highest!);
        _ = RequireMapping(highest!, nodes[outside].Operation, true);
        return highest!;
    }

    private static MathBlockFormulaProfileDescriptor RequireReachableProfile(
        MathBlockProgram.Node[] nodes,
        bool[] reachable,
        MathBlockFormulaProfileDescriptor profile)
    {
        var outside = FindReachableOperationOutside(nodes, reachable, profile);
        if (outside >= 0)
            _ = RequireMapping(profile, nodes[outside].Operation, false);
        return profile;
    }

    private static int FindReachableOperationOutside(
        MathBlockProgram.Node[] nodes,
        bool[] reachable,
        MathBlockFormulaProfileDescriptor profile)
    {
        for (var index = 0; index < nodes.Length; index++)
        {
            if (reachable[index] &&
                nodes[index].Kind == MathBlockProgramBuilder.NodeKind.Operation &&
                !profile.Contains(nodes[index].Operation))
            {
                return index;
            }
        }
        return -1;
    }

    private static int CopyOperation(
        MathBlockProgramBuilder builder,
        MathBlockProgram.Node node,
        int[] indexes,
        MathBlockFormulaProfileDescriptor profile)
    {
        var mapping = RequireMapping(profile, node.Operation, false);
        var inputs = new int[node.Inputs.Length];
        for (var index = 0; index < inputs.Length; index++)
        {
            inputs[index] = indexes[node.Inputs[index]];
            if (inputs[index] < 0)
                throw new InvalidOperationException("A formula operation input is unavailable.");
        }
        return builder.Apply(
            mapping.Operation.Identifier,
            mapping.Operation.Version,
            inputs);
    }

    private static void WriteDocument(
        XmlWriter writer,
        FormulaSelection selection,
        string exact,
        MathBlockFormulaFormat format)
    {
        RequireFormat(format);
        switch (format)
        {
            case MathBlockFormulaFormat.OpenMath:
                WriteOpenMathDocument(writer, selection, exact, selection.Profile);
                break;
            case MathBlockFormulaFormat.ContentMathMl:
                WriteMathMlDocument(writer, selection, exact, selection.Profile);
                break;
        }
    }

    private static void WriteOpenMathDocument(
        XmlWriter writer,
        FormulaSelection selection,
        string exact,
        MathBlockFormulaProfileDescriptor profile)
    {
        writer.WriteStartElement("OMOBJ", OpenMathNamespace);
        writer.WriteAttributeString("xmlns", OpenMathNamespace);
        writer.WriteAttributeString("cdbase", profile.ContentDictionaryBase);
        writer.WriteAttributeString("cdgroup", profile.ContentDictionaryGroup);
        writer.WriteAttributeString("version", OpenMathVersion);

        writer.WriteStartElement("OMATTR", OpenMathNamespace);
        writer.WriteStartElement("OMATP", OpenMathNamespace);
        WriteOpenMathSymbol(writer, profile, profile.FormulaDictionary, profile.AnnotationSymbol, null);
        writer.WriteStartElement("OMSTR", OpenMathNamespace);
        writer.WriteString(exact);
        writer.WriteEndElement();
        writer.WriteEndElement();
        WriteExpression(writer, selection, MathBlockFormulaFormat.OpenMath);
        writer.WriteEndElement();
        writer.WriteEndElement();
    }

    private static void WriteMathMlDocument(
        XmlWriter writer,
        FormulaSelection selection,
        string exact,
        MathBlockFormulaProfileDescriptor profile)
    {
        writer.WriteStartElement("math", MathMlNamespace);
        writer.WriteAttributeString("xmlns", MathMlNamespace);
        writer.WriteAttributeString("cdgroup", profile.ContentDictionaryGroup);
        writer.WriteStartElement("semantics", MathMlNamespace);
        WriteExpression(writer, selection, MathBlockFormulaFormat.ContentMathMl);
        writer.WriteStartElement("annotation", MathMlNamespace);
        writer.WriteAttributeString("encoding", profile.ExactAnnotationMediaType);
        writer.WriteString(exact);
        writer.WriteEndElement();
        writer.WriteEndElement();
        writer.WriteEndElement();
    }

    private static void WriteExpression(
        XmlWriter writer,
        FormulaSelection selection,
        MathBlockFormulaFormat format)
    {
        var nodes = selection.Program.Nodes;
        var emitted = new bool[nodes.Length];
        var frames = new Stack<ExpressionFrame>();
        frames.Push(new ExpressionFrame(selection.RootNode, false));
        while (frames.Count != 0)
        {
            var frame = frames.Pop();
            if (frame.Close)
            {
                writer.WriteEndElement();
                continue;
            }

            if (emitted[frame.NodeIndex])
            {
                WriteReference(writer, frame.NodeIndex, format);
                continue;
            }
            emitted[frame.NodeIndex] = true;
            var node = nodes[frame.NodeIndex];
            switch (node.Kind)
            {
                case MathBlockProgramBuilder.NodeKind.Input:
                    WriteVariable(writer, frame.NodeIndex, node.Name!, format);
                    break;
                case MathBlockProgramBuilder.NodeKind.Constant:
                    WriteValue(writer, selection.Profile, frame.NodeIndex, node.Value, format);
                    break;
                case MathBlockProgramBuilder.NodeKind.Operation:
                    WriteApplicationStart(writer, frame.NodeIndex, format);
                    var mapping = RequireMapping(selection.Profile, node.Operation, false);
                    WriteOperationSymbol(writer, selection.Profile, mapping.Symbol, format);
                    frames.Push(new ExpressionFrame(frame.NodeIndex, true));
                    for (var index = node.Inputs.Length - 1; index >= 0; index--)
                        frames.Push(new ExpressionFrame(node.Inputs[index], false));
                    break;
                default:
                    throw new InvalidOperationException(
                        "The formula contains an unsupported node kind.");
            }
        }
    }

    private static void WriteApplicationStart(
        XmlWriter writer,
        int nodeIndex,
        MathBlockFormulaFormat format)
    {
        writer.WriteStartElement(
            format == MathBlockFormulaFormat.OpenMath ? "OMA" : "apply",
            format == MathBlockFormulaFormat.OpenMath ? OpenMathNamespace : MathMlNamespace);
        writer.WriteAttributeString("id", NodeIdentifier(nodeIndex));
    }

    private static void WriteVariable(
        XmlWriter writer,
        int nodeIndex,
        string name,
        MathBlockFormulaFormat format)
    {
        var formulaName = XmlConvert.EncodeLocalName(name);
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            writer.WriteStartElement("OMV", OpenMathNamespace);
            writer.WriteAttributeString("id", NodeIdentifier(nodeIndex));
            writer.WriteAttributeString("name", formulaName);
            writer.WriteFullEndElement();
            return;
        }
        writer.WriteStartElement("ci", MathMlNamespace);
        writer.WriteAttributeString("id", NodeIdentifier(nodeIndex));
        writer.WriteString(formulaName);
        writer.WriteEndElement();
    }

    private static void WriteReference(
        XmlWriter writer,
        int nodeIndex,
        MathBlockFormulaFormat format)
    {
        writer.WriteStartElement(
            format == MathBlockFormulaFormat.OpenMath ? "OMR" : "share",
            format == MathBlockFormulaFormat.OpenMath ? OpenMathNamespace : MathMlNamespace);
        writer.WriteAttributeString(
            format == MathBlockFormulaFormat.OpenMath ? "href" : "src",
            string.Concat("#", NodeIdentifier(nodeIndex)));
        writer.WriteFullEndElement();
    }

    private static void WriteOperationSymbol(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        MathBlockFormulaSymbol symbol,
        MathBlockFormulaFormat format)
    {
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            WriteOpenMathSymbol(writer, profile, symbol.Dictionary, symbol.Name, symbol.ContentDictionaryBase);
            return;
        }
        WriteMathMlSymbol(writer, symbol.Dictionary, symbol.Name, null);
    }

    private static void WriteValue(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        int nodeIndex,
        MathBlockValue value,
        MathBlockFormulaFormat format)
    {
        if (!value.IsValid)
            throw new InvalidOperationException("A formula constant must be valid.");
        var id = NodeIdentifier(nodeIndex);
        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                WriteDouble(writer, value.AsScalar(), id, format);
                break;
            case MathBlockValueKind.Boolean:
                WriteBoolean(writer, profile, value.AsBoolean(), id, format);
                break;
            case MathBlockValueKind.Complex:
                WriteComplex(writer, profile, value.AsComplex(), id, format);
                break;
            case MathBlockValueKind.Vector:
                WriteVector(writer, profile, value.AsVector(), id, format);
                break;
            case MathBlockValueKind.Matrix:
                WriteMatrix(writer, profile, value.AsMatrix(), id, format);
                break;
            case MathBlockValueKind.ComplexVector:
                WriteComplexVector(writer, profile, value.AsComplexVector(), id, format);
                break;
            case MathBlockValueKind.ComplexMatrix:
                WriteComplexMatrix(writer, profile, value.AsComplexMatrix(), id, format);
                break;
            case MathBlockValueKind.PointSet:
                WritePointSet(writer, profile, value.AsPointSet(), id, format);
                break;
            case MathBlockValueKind.Graph:
                WriteGraph(writer, profile, value.AsGraph(), id, format);
                break;
            case MathBlockValueKind.RunSet:
                WriteRunSet(writer, profile, value.AsRunSet(), id, format);
                break;
            case MathBlockValueKind.BooleanVector:
                WriteBooleanVector(writer, profile, value.AsBooleanVector(), id, format);
                break;
            default:
                throw new InvalidOperationException(
                    "The formula constant value kind is not supported.");
        }
    }

    private static void WriteVector(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockVector values,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "vector", id, format);
        for (var index = 0; index < values.Count; index++)
            WriteDouble(writer, values[index], null, format);
        writer.WriteEndElement();
    }

    private static void WriteMatrix(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        MathBlockMatrix value,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "matrix", id, format);
        WriteInteger(writer, value.Rows, format);
        WriteInteger(writer, value.Columns, format);
        for (var row = 0; row < value.Rows; row++)
            for (var column = 0; column < value.Columns; column++)
                WriteDouble(writer, value[row, column], null, format);
        writer.WriteEndElement();
    }

    private static void WriteComplex(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        MathBlockComplexValue value,
        string? id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "complex", id, format);
        WriteDouble(writer, value.Real, null, format);
        WriteDouble(writer, value.Imaginary, null, format);
        writer.WriteEndElement();
    }

    private static void WriteComplexVector(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockComplexVector values,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "complex-vector", id, format);
        for (var index = 0; index < values.Count; index++)
            WriteComplex(writer, profile, values[index], null, format);
        writer.WriteEndElement();
    }

    private static void WriteComplexMatrix(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        MathBlockComplexMatrix value,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "complex-matrix", id, format);
        WriteInteger(writer, value.Rows, format);
        WriteInteger(writer, value.Columns, format);
        for (var row = 0; row < value.Rows; row++)
            for (var column = 0; column < value.Columns; column++)
                WriteComplex(writer, profile, value[row, column], null, format);
        writer.WriteEndElement();
    }

    private static void WritePointSet(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockPointSet values,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "point-set", id, format);
        for (var index = 0; index < values.Count; index++)
        {
            WriteValueApplicationStart(writer, profile, "point", null, format);
            WriteDouble(writer, values[index].X, null, format);
            WriteDouble(writer, values[index].Y, null, format);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteGraph(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        MathBlockGraph value,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "graph", id, format);
        WriteInteger(writer, value.VertexCount, format);
        for (var index = 0; index < value.Count; index++)
        {
            var edge = value[index];
            WriteValueApplicationStart(writer, profile, "edge", null, format);
            WriteInteger(writer, edge.From, format);
            WriteInteger(writer, edge.To, format);
            WriteDouble(writer, edge.Weight, null, format);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteRunSet(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockRunSet values,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "run-set", id, format);
        for (var index = 0; index < values.Count; index++)
        {
            WriteValueApplicationStart(writer, profile, "run", null, format);
            WriteInteger(writer, values[index].Start, format);
            WriteInteger(writer, values[index].Length, format);
            WriteDouble(writer, values[index].Value, null, format);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteBooleanVector(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockBooleanVector values,
        string id,
        MathBlockFormulaFormat format)
    {
        WriteValueApplicationStart(writer, profile, "boolean-vector", id, format);
        for (var index = 0; index < values.Count; index++)
            WriteBoolean(writer, profile, values[index], null, format);
        writer.WriteEndElement();
    }

    private static void WriteValueApplicationStart(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        string name,
        string? id,
        MathBlockFormulaFormat format)
    {
        writer.WriteStartElement(
            format == MathBlockFormulaFormat.OpenMath ? "OMA" : "apply",
            format == MathBlockFormulaFormat.OpenMath ? OpenMathNamespace : MathMlNamespace);
        if (id is not null)
            writer.WriteAttributeString("id", id);
        if (format == MathBlockFormulaFormat.OpenMath)
            WriteOpenMathSymbol(writer, profile, profile.FormulaValueDictionary, name, null);
        else
            WriteMathMlSymbol(writer, profile.FormulaValueDictionary, name, null);
    }

    private static void WriteDouble(
        XmlWriter writer,
        double value,
        string? id,
        MathBlockFormulaFormat format)
    {
        if (!double.IsFinite(value))
            throw new InvalidOperationException("A formula float must be finite.");
        var bits = BitConverter.DoubleToUInt64Bits(value)
            .ToString("X16", CultureInfo.InvariantCulture);
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            writer.WriteStartElement("OMF", OpenMathNamespace);
            writer.WriteAttributeString("hex", bits);
            if (id is not null)
                writer.WriteAttributeString("id", id);
            writer.WriteFullEndElement();
            return;
        }
        writer.WriteStartElement("cn", MathMlNamespace);
        if (id is not null)
            writer.WriteAttributeString("id", id);
        writer.WriteAttributeString("type", "hexdouble");
        writer.WriteString(bits);
        writer.WriteEndElement();
    }

    private static void WriteBoolean(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        bool value,
        string? id,
        MathBlockFormulaFormat format)
    {
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            WriteOpenMathSymbol(
                writer,
                profile,
                profile.FormulaValueDictionary,
                value ? "true" : "false",
                null,
                id);
            return;
        }
        WriteMathMlSymbol(
            writer,
            "logic1",
            value ? "true" : "false",
            id);
    }

    private static void WriteInteger(
        XmlWriter writer,
        int value,
        MathBlockFormulaFormat format)
    {
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            writer.WriteStartElement("OMI", OpenMathNamespace);
            writer.WriteString(value.ToString(CultureInfo.InvariantCulture));
            writer.WriteEndElement();
            return;
        }
        writer.WriteStartElement("cn", MathMlNamespace);
        writer.WriteAttributeString("type", "integer");
        writer.WriteString(value.ToString(CultureInfo.InvariantCulture));
        writer.WriteEndElement();
    }

    private static void WriteOpenMathSymbol(
        XmlWriter writer,
        MathBlockFormulaProfileDescriptor profile,
        string dictionary,
        string name,
        string? dictionaryBase,
        string? id = null)
    {
        writer.WriteStartElement("OMS", OpenMathNamespace);
        writer.WriteAttributeString("cd", dictionary);
        if (dictionaryBase is not null && !string.Equals(dictionaryBase, profile.ContentDictionaryBase, StringComparison.Ordinal))
            writer.WriteAttributeString("cdbase", dictionaryBase);
        if (id is not null)
            writer.WriteAttributeString("id", id);
        writer.WriteAttributeString("name", name);
        writer.WriteFullEndElement();
    }

    private static void WriteMathMlSymbol(
        XmlWriter writer,
        string dictionary,
        string name,
        string? id)
    {
        writer.WriteStartElement("csymbol", MathMlNamespace);
        writer.WriteAttributeString("cd", dictionary);
        if (id is not null)
            writer.WriteAttributeString("id", id);
        writer.WriteString(name);
        writer.WriteEndElement();
    }

    private static string ExtractExactAnnotation(
        string source,
        MathBlockFormulaFormat format,
        Lazy<MathBlockFormulaProfileDescriptor>[] profiles,
        MathBlockFormulaInterchangeOptions options,
        out MathBlockFormulaProfileDescriptor profile)
    {
        profile = profiles[0].Value;
        var settings = new XmlReaderSettings
        {
            DtdProcessing = DtdProcessing.Prohibit,
            XmlResolver = null,
            MaxCharactersInDocument = options.MaximumDocumentCharacters,
            IgnoreComments = false,
            IgnoreProcessingInstructions = false,
            IgnoreWhitespace = false,
            CloseInput = true
        };
        try
        {
            using var input = new StringReader(source);
            using var reader = XmlReader.Create(input, settings);
            string? exact = null;
            var rootSeen = false;
            var awaitingOpenMathValue = false;
            while (reader.Read())
            {
                if (reader.NodeType is XmlNodeType.Comment or
                    XmlNodeType.ProcessingInstruction or
                    XmlNodeType.DocumentType)
                {
                    throw new FormatException(
                        "The formula document contains unsupported content.");
                }
                if (reader.NodeType != XmlNodeType.Element)
                    continue;
                if (!rootSeen)
                {
                    rootSeen = true;
                    var expectedName = format == MathBlockFormulaFormat.OpenMath
                        ? "OMOBJ"
                        : "math";
                    var expectedNamespace = format == MathBlockFormulaFormat.OpenMath
                        ? OpenMathNamespace
                        : MathMlNamespace;
                    if (!string.Equals(reader.LocalName, expectedName, StringComparison.Ordinal) ||
!string.Equals(reader.NamespaceURI, expectedNamespace, StringComparison.Ordinal))
                    {
                        throw new FormatException(
                            "The formula document root does not match its format.");
                    }
                    profile = SelectDocumentProfile(reader.GetAttribute("cdgroup"), profiles);
                }

                if (format == MathBlockFormulaFormat.OpenMath)
                {
                    if (awaitingOpenMathValue &&
string.Equals(reader.LocalName, "OMSTR", StringComparison.Ordinal) &&
string.Equals(reader.NamespaceURI, OpenMathNamespace, StringComparison.Ordinal))
                    {
                        if (exact is not null)
                            throw new FormatException("The formula has duplicate exact annotations.");
                        exact = reader.ReadElementContentAsString();
                        awaitingOpenMathValue = false;
                        continue;
                    }
                    awaitingOpenMathValue =
string.Equals(reader.LocalName, "OMS", StringComparison.Ordinal) &&
string.Equals(reader.NamespaceURI, OpenMathNamespace, StringComparison.Ordinal) &&
string.Equals(reader.GetAttribute("cd"), profile.FormulaDictionary, StringComparison.Ordinal) &&
string.Equals(reader.GetAttribute("name"), profile.AnnotationSymbol, StringComparison.Ordinal);
                    continue;
                }

                if (string.Equals(reader.LocalName, "annotation", StringComparison.Ordinal) &&
string.Equals(reader.NamespaceURI, MathMlNamespace, StringComparison.Ordinal) &&
string.Equals(reader.GetAttribute("encoding"), profile.ExactAnnotationMediaType, StringComparison.Ordinal))
                {
                    if (exact is not null)
                        throw new FormatException("The formula has duplicate exact annotations.");
                    exact = reader.ReadElementContentAsString();
                }
            }
            if (!rootSeen)
                throw new FormatException("The formula source is not valid XML.");
            return exact ?? throw new FormatException(
                "The formula exact annotation is missing.");
        }
        catch (XmlException exception)
        {
            throw new FormatException("The formula source is not valid XML.", exception);
        }
    }

    private static MathBlockFormulaProfileDescriptor SelectDocumentProfile(
        string? contentDictionaryGroup,
        Lazy<MathBlockFormulaProfileDescriptor>[] profiles)
    {
        if (contentDictionaryGroup is not null)
        {
            for (var index = 0; index < profiles.Length; index++)
            {
                var candidate = profiles[index].Value;
                if (string.Equals(contentDictionaryGroup, candidate.ContentDictionaryGroup, StringComparison.Ordinal))
                    return candidate;
            }
        }
        return profiles[0].Value;
    }

    // Validates the size ceilings and the OpenMath options of the exact annotation before any source is read.
    private static void RequireOptions(MathBlockFormulaInterchangeOptions options)
    {
        ArgumentNullException.ThrowIfNull(options);
        options.Validate();
        MathBlockOpenMath.RequireOptions(options.OpenMathOptions);
    }

    private static void RequireFormat(MathBlockFormulaFormat format)
    {
        if (format is not MathBlockFormulaFormat.OpenMath and
            not MathBlockFormulaFormat.ContentMathMl)
        {
            throw new ArgumentOutOfRangeException(nameof(format));
        }
    }

    private static string NodeIdentifier(int index) =>
        string.Concat("n", index.ToString(CultureInfo.InvariantCulture));

    private static XmlWriterSettings CreateWriterSettings() => new()
    {
        OmitXmlDeclaration = true,
        Indent = false,
        NewLineHandling = NewLineHandling.None,
        NamespaceHandling = NamespaceHandling.OmitDuplicates,
        CheckCharacters = true,
        CloseOutput = false
    };

    private sealed record FormulaSelection(
        MathBlockProgram Program,
        int RootNode,
        MathBlockFormulaProfileDescriptor Profile);

    private readonly record struct ExpressionFrame(int NodeIndex, bool Close);
}
