using System.Buffers;
using System.Globalization;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

public static partial class MathBlockOpenMath
{
    private const string DiagnosticLineKey = "MathBlocks.OpenMath.Line";
    private const string DiagnosticCodeKey = "MathBlocks.OpenMath.Code";
    private const string DiagnosticColumnKey = "MathBlocks.OpenMath.Column";
    private const string DiagnosticPathKey = "MathBlocks.OpenMath.ProfilePath";
    private const string DiagnosticNodeKey = "MathBlocks.OpenMath.NodeIndex";
    private const string DiagnosticOperationKey = "MathBlocks.OpenMath.Operation";
    private const string DiagnosticDictionaryKey = "MathBlocks.OpenMath.Dictionary";
    private const string DiagnosticSymbolKey = "MathBlocks.OpenMath.Symbol";
    private const string CommentStart = "<!--";
    private const string CDataStart = "<![CDATA[";
    private const string ProcessingInstructionStart = "<?";
    private const string ProhibitedDtdPrefix = "<!D";

    /// <summary>Imports a Profile 1 document with the specified options.</summary>
    public static MathBlockOpenMathImportResult Import(
        string source,
        MathBlockOpenMathImportOptions? options)
    {
        ArgumentNullException.ThrowIfNull(source);
        var snapshot = CreateOptionsSnapshot(options);
        if (source.Length == 0)
            throw InvalidFormat("The OpenMath source is empty.");
        if (source.Length > snapshot.MaximumDocumentCharacters)
            throw InvalidFormat("The OpenMath source exceeds the character limit.");
        var result = ImportForward(source, snapshot);
        if (snapshot.RequireCanonicalSource &&
            !string.Equals(source, Export(result.Program), StringComparison.Ordinal))
        {
            throw InvalidFormat("The OpenMath source must use the canonical form.");
        }
        return result;
    }

    /// <summary>Imports a Profile 1 document from contiguous UTF-8 bytes.</summary>
    public static unsafe MathBlockOpenMathImportResult ImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var snapshot = CreateOptionsSnapshot(options);
        if (source.Length == 0)
            throw InvalidFormat("The OpenMath source is empty.");
        if (source.Length > snapshot.MaximumDocumentBytes)
            throw InvalidFormat("The OpenMath source exceeds the byte limit.");

        fixed (byte* pointer = source)
        {
            using var stream = new UnmanagedMemoryStream(
                pointer,
                source.Length,
                source.Length,
                FileAccess.Read);
            return ReadUtf8Core(stream, snapshot, false);
        }
    }

    /// <summary>Imports a Profile 1 document from segmented UTF-8 bytes.</summary>
    public static MathBlockOpenMathImportResult ImportUtf8(
        ReadOnlySequence<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        var snapshot = CreateOptionsSnapshot(options);
        if (source.IsEmpty)
            throw InvalidFormat("The OpenMath source is empty.");
        if (source.Length > snapshot.MaximumDocumentBytes)
            throw InvalidFormat("The OpenMath source exceeds the byte limit.");
        using var stream = new ReadOnlySequenceStream(source);
        return ReadUtf8Core(stream, snapshot, false);
    }

    /// <summary>Reads one Profile 1 UTF-8 document from a caller-owned stream.</summary>
    public static MathBlockOpenMathImportResult ReadUtf8(
        Stream source,
        MathBlockOpenMathImportOptions? options = null)
    {
        ArgumentNullException.ThrowIfNull(source);
        if (!source.CanRead)
            throw new ArgumentException("The source stream must support reading.", nameof(source));
        var snapshot = CreateOptionsSnapshot(options);
        return ReadUtf8Core(source, snapshot, false);
    }

    /// <summary>Reads one Profile 1 UTF-8 document asynchronously.</summary>
    public static async Task<MathBlockOpenMathImportResult> ReadUtf8Async(
        Stream source,
        MathBlockOpenMathImportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(source);
        if (!source.CanRead)
            throw new ArgumentException("The source stream must support reading.", nameof(source));
        var snapshot = CreateOptionsSnapshot(options);
        cancellationToken.ThrowIfCancellationRequested();
        try
        {
            return await ReadUtf8CoreAsync(source, snapshot, cancellationToken)
                .ConfigureAwait(false);
        }
        catch (DecoderFallbackException exception)
        {
            throw InvalidFormat("The OpenMath UTF-8 source is invalid.", exception);
        }
        catch (OpenMathByteLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the byte limit.");
        }
        catch (OpenMathCharacterLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the character limit.");
        }
    }

    /// <summary>Reads one Profile 1 document from a caller-owned character reader.</summary>
    public static MathBlockOpenMathImportResult Read(
        TextReader source,
        MathBlockOpenMathImportOptions? options = null)
    {
        ArgumentNullException.ThrowIfNull(source);
        var snapshot = CreateOptionsSnapshot(options);
        using var limited = new LimitedTextReader(
            source,
            snapshot.MaximumDocumentCharacters,
            default,
            false,
            snapshot.RequireCanonicalSource);
        using var xmlReader = XmlReader.Create(
            limited,
            CreateReaderSettings(snapshot.MaximumDocumentCharacters));
        var result = ReadForward(xmlReader, snapshot, false, () => limited.UnitsRead == 0);
        RequireCanonicalText(result, limited.CapturedText, snapshot);
        return result;
    }

    /// <summary>Reads one Profile 1 document asynchronously from a character reader.</summary>
    public static async Task<MathBlockOpenMathImportResult> ReadAsync(
        TextReader source,
        MathBlockOpenMathImportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(source);
        var snapshot = CreateOptionsSnapshot(options);
        cancellationToken.ThrowIfCancellationRequested();
        using var limited = new LimitedTextReader(
            source,
            snapshot.MaximumDocumentCharacters,
            cancellationToken,
            true,
            snapshot.RequireCanonicalSource);
        var prefix = await ReadCharacterPrefixAsync(
                limited,
                snapshot.MaximumDocumentCharacters,
                cancellationToken)
            .ConfigureAwait(false);
        using var replay = new PrefixReplayTextReader(limited, prefix.Buffer, prefix.Count);
        using var xmlReader = XmlReader.Create(
            replay,
            CreateReaderSettings(snapshot.MaximumDocumentCharacters, true));
        var result = await ReadForwardAsync(
                xmlReader,
                snapshot,
                false,
                () => limited.UnitsRead == 0,
                cancellationToken)
            .ConfigureAwait(false);
        RequireCanonicalText(result, limited.CapturedText, snapshot);
        return result;
    }

    /// <summary>Attempts to import a Profile 1 character document.</summary>
    public static MathBlockOpenMathImportAttempt TryImport(
        string? source,
        MathBlockOpenMathImportOptions? options = null)
    {
        _ = CreateOptionsSnapshot(options);
        if (source is null)
            return NullSourceAttempt();
        try
        {
            return MathBlockOpenMathImportAttempt.Success(Import(source, options));
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to import contiguous Profile 1 UTF-8 bytes.</summary>
    public static MathBlockOpenMathImportAttempt TryImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        try
        {
            return MathBlockOpenMathImportAttempt.Success(ImportUtf8(source, options));
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to import segmented Profile 1 UTF-8 bytes.</summary>
    public static MathBlockOpenMathImportAttempt TryImportUtf8(
        ReadOnlySequence<byte> source,
        MathBlockOpenMathImportOptions? options = null)
    {
        try
        {
            return MathBlockOpenMathImportAttempt.Success(ImportUtf8(source, options));
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to read one Profile 1 UTF-8 document.</summary>
    public static MathBlockOpenMathImportAttempt TryReadUtf8(
        Stream? source,
        MathBlockOpenMathImportOptions? options = null)
    {
        _ = CreateOptionsSnapshot(options);
        if (source is null)
            return NullSourceAttempt();
        try
        {
            return MathBlockOpenMathImportAttempt.Success(ReadUtf8(source, options));
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to read one Profile 1 UTF-8 document asynchronously.</summary>
    public static async Task<MathBlockOpenMathImportAttempt> TryReadUtf8Async(
        Stream? source,
        MathBlockOpenMathImportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        _ = CreateOptionsSnapshot(options);
        if (source is null)
            return NullSourceAttempt();
        try
        {
            var result = await ReadUtf8Async(source, options, cancellationToken)
                .ConfigureAwait(false);
            return MathBlockOpenMathImportAttempt.Success(result);
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to read one Profile 1 character document.</summary>
    public static MathBlockOpenMathImportAttempt TryRead(
        TextReader? source,
        MathBlockOpenMathImportOptions? options = null)
    {
        _ = CreateOptionsSnapshot(options);
        if (source is null)
            return NullSourceAttempt();
        try
        {
            return MathBlockOpenMathImportAttempt.Success(Read(source, options));
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    /// <summary>Attempts to read one Profile 1 character document asynchronously.</summary>
    public static async Task<MathBlockOpenMathImportAttempt> TryReadAsync(
        TextReader? source,
        MathBlockOpenMathImportOptions? options = null,
        CancellationToken cancellationToken = default)
    {
        _ = CreateOptionsSnapshot(options);
        if (source is null)
            return NullSourceAttempt();
        try
        {
            var result = await ReadAsync(source, options, cancellationToken)
                .ConfigureAwait(false);
            return MathBlockOpenMathImportAttempt.Success(result);
        }
        catch (FormatException exception)
        {
            return MathBlockOpenMathImportAttempt.Failure(CreateDiagnostic(exception));
        }
    }

    private static MathBlockOpenMathImportAttempt NullSourceAttempt() =>
        MathBlockOpenMathImportAttempt.Failure(new MathBlockOpenMathDiagnostic(
            MathBlockOpenMathDiagnosticCode.SourceNull,
            "The OpenMath source is null."));

    private static MathBlockOpenMathImportResult ImportForward(
        string source,
        OpenMathImportOptionsSnapshot snapshot)
    {
        using var textReader = new StringReader(source);
        using var limited = new LimitedTextReader(
            textReader,
            snapshot.MaximumDocumentCharacters,
            default,
            false,
            false);
        using var xmlReader = XmlReader.Create(
            limited,
            CreateReaderSettings(snapshot.MaximumDocumentCharacters));
        return ReadForward(xmlReader, snapshot, false);
    }

    private static MathBlockOpenMathImportResult ReadForward(
        XmlReader reader,
        OpenMathImportOptionsSnapshot snapshot,
        bool byteInput,
        Func<bool>? sourceIsEmpty = null)
    {
        var parser = new OpenMathSemanticReader(snapshot, byteInput);
        FormatException? semanticException = null;
        try
        {
            while (reader.Read())
            {
                if (semanticException is not null)
                    continue;
                try
                {
                    parser.Accept(reader);
                }
                catch (FormatException exception)
                {
                    semanticException = exception;
                }
            }
            if (sourceIsEmpty?.Invoke() == true)
                throw InvalidFormat("The OpenMath source is empty.");
            if (semanticException is not null)
                throw semanticException;
            return parser.Complete();
        }
        catch (OpenMathCharacterLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the character limit.");
        }
        catch (OpenMathByteLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the byte limit.");
        }
        catch (DecoderFallbackException exception)
        {
            throw InvalidFormat("The OpenMath UTF-8 source is invalid.", exception);
        }
        catch (XmlException exception)
        {
            if (sourceIsEmpty?.Invoke() == true)
                throw InvalidFormat("The OpenMath source is empty.");
            if (FindInnerException<OpenMathCharacterLimitException>(exception) is not null)
                throw InvalidFormat("The OpenMath source exceeds the character limit.");
            if (FindInnerException<OpenMathByteLimitException>(exception) is not null)
                throw InvalidFormat("The OpenMath source exceeds the byte limit.");
            if (FindInnerException<DecoderFallbackException>(exception) is { } decoder)
                throw InvalidFormat("The OpenMath UTF-8 source is invalid.", decoder);
            if (FindInnerException<FormatException>(exception) is { } format &&
                format.Data[DiagnosticCodeKey] is
                    MathBlockOpenMathDiagnosticCode.UnsupportedDocumentContent)
            {
                throw UnsupportedDocumentContentFormat(exception);
            }
            throw InvalidFormat("The OpenMath source is not valid XML.", exception);
        }
    }

    private static async Task<MathBlockOpenMathImportResult> ReadForwardAsync(
        XmlReader reader,
        OpenMathImportOptionsSnapshot snapshot,
        bool byteInput,
        Func<bool> sourceIsEmpty,
        CancellationToken cancellationToken)
    {
        var parser = new OpenMathSemanticReader(snapshot, byteInput);
        FormatException? semanticException = null;
        try
        {
            while (await reader.ReadAsync().ConfigureAwait(false))
            {
                cancellationToken.ThrowIfCancellationRequested();
                if (semanticException is not null)
                    continue;
                try
                {
                    var value = reader.NodeType is
                        XmlNodeType.Text or
                        XmlNodeType.CDATA or
                        XmlNodeType.Whitespace or
                        XmlNodeType.SignificantWhitespace
                            ? await reader.GetValueAsync().ConfigureAwait(false)
                            : null;
                    parser.Accept(reader, value);
                }
                catch (FormatException exception)
                {
                    semanticException = exception;
                }
            }
            if (sourceIsEmpty())
                throw InvalidFormat("The OpenMath source is empty.");
            if (semanticException is not null)
                throw semanticException;
            return parser.Complete();
        }
        catch (OperationCanceledException)
        {
            throw;
        }
        catch (OpenMathCharacterLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the character limit.");
        }
        catch (OpenMathByteLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the byte limit.");
        }
        catch (DecoderFallbackException exception)
        {
            throw InvalidFormat("The OpenMath UTF-8 source is invalid.", exception);
        }
        catch (XmlException exception)
        {
            if (sourceIsEmpty())
                throw InvalidFormat("The OpenMath source is empty.");
            if (FindInnerException<OperationCanceledException>(exception) is { } cancellation)
                throw cancellation;
            if (FindInnerException<OpenMathCharacterLimitException>(exception) is not null)
                throw InvalidFormat("The OpenMath source exceeds the character limit.");
            if (FindInnerException<OpenMathByteLimitException>(exception) is not null)
                throw InvalidFormat("The OpenMath source exceeds the byte limit.");
            if (FindInnerException<DecoderFallbackException>(exception) is { } decoder)
                throw InvalidFormat("The OpenMath UTF-8 source is invalid.", decoder);
            if (FindInnerException<FormatException>(exception) is { } format &&
                format.Data[DiagnosticCodeKey] is
                    MathBlockOpenMathDiagnosticCode.UnsupportedDocumentContent)
            {
                throw UnsupportedDocumentContentFormat(exception);
            }
            throw InvalidFormat("The OpenMath source is not valid XML.", exception);
        }
    }

    private static MathBlockOpenMathImportResult ReadUtf8Core(
        Stream source,
        OpenMathImportOptionsSnapshot snapshot,
        bool asyncOnly)
    {
        try
        {
            return ReadUtf8CoreUnchecked(source, snapshot, asyncOnly);
        }
        catch (DecoderFallbackException exception)
        {
            throw InvalidFormat("The OpenMath UTF-8 source is invalid.", exception);
        }
        catch (OpenMathByteLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the byte limit.");
        }
        catch (OpenMathCharacterLimitException)
        {
            throw InvalidFormat("The OpenMath source exceeds the character limit.");
        }
    }

    private static MathBlockOpenMathImportResult ReadUtf8CoreUnchecked(
        Stream source,
        OpenMathImportOptionsSnapshot snapshot,
        bool asyncOnly)
    {
        using var limitedBytes = new LimitedReadStream(
            source,
            snapshot.MaximumDocumentBytes,
            default,
            asyncOnly,
            snapshot.RequireCanonicalSource);
        var prefix = ReadUtf8Prefix(limitedBytes);
        using var replay = new PrefixReplayStream(limitedBytes, prefix, asyncOnly);
        using var utf8Reader = new StreamReader(
            replay,
            StrictUtf8,
            false,
            4096,
            false);
        using var limitedCharacters = new LimitedTextReader(
            utf8Reader,
            snapshot.MaximumDocumentCharacters,
            default,
            asyncOnly,
            false);
        using var xmlReader = XmlReader.Create(
            limitedCharacters,
            CreateReaderSettings(snapshot.MaximumDocumentCharacters));
        var result = ReadForward(
            xmlReader,
            snapshot,
            true,
            () => limitedBytes.UnitsRead == 0);
        RequireCanonicalUtf8(result, limitedBytes.CapturedBytes, snapshot);
        return result;
    }

    private static async Task<MathBlockOpenMathImportResult> ReadUtf8CoreAsync(
        Stream source,
        OpenMathImportOptionsSnapshot snapshot,
        CancellationToken cancellationToken)
    {
        using var limitedBytes = new LimitedReadStream(
            source,
            snapshot.MaximumDocumentBytes,
            cancellationToken,
            true,
            snapshot.RequireCanonicalSource);
        var prefix = await ReadUtf8PrefixAsync(limitedBytes, cancellationToken)
            .ConfigureAwait(false);
        using var replay = new PrefixReplayStream(limitedBytes, prefix, true);
        using var utf8Reader = new StreamReader(
            replay,
            StrictUtf8,
            false,
            4096,
            false);
        using var limitedCharacters = new LimitedTextReader(
            utf8Reader,
            snapshot.MaximumDocumentCharacters,
            cancellationToken,
            true,
            false);
        var characterPrefix = await ReadCharacterPrefixAsync(
                limitedCharacters,
                snapshot.MaximumDocumentCharacters,
                cancellationToken)
            .ConfigureAwait(false);
        using var characterReplay = new PrefixReplayTextReader(
            limitedCharacters,
            characterPrefix.Buffer,
            characterPrefix.Count);
        using var xmlReader = XmlReader.Create(
            characterReplay,
            CreateReaderSettings(snapshot.MaximumDocumentCharacters, true));
        var result = await ReadForwardAsync(
                xmlReader,
                snapshot,
                true,
                () => limitedBytes.UnitsRead == 0,
                cancellationToken)
            .ConfigureAwait(false);
        RequireCanonicalUtf8(result, limitedBytes.CapturedBytes, snapshot);
        return result;
    }

    private static byte[] ReadUtf8Prefix(Stream source)
    {
        Span<byte> buffer = stackalloc byte[4];
        var count = 0;
        while (count < buffer.Length)
        {
            var read = source.Read(buffer[count..]);
            if (read == 0)
                break;
            count += read;
        }
        return ValidateUtf8Prefix(buffer[..count]);
    }

    private static async Task<byte[]> ReadUtf8PrefixAsync(
        Stream source,
        CancellationToken cancellationToken)
    {
        var buffer = new byte[4];
        var count = 0;
        while (count < buffer.Length)
        {
            var read = await source.ReadAsync(buffer.AsMemory(count), cancellationToken)
                .ConfigureAwait(false);
            if (read == 0)
                break;
            count += read;
        }
        return ValidateUtf8Prefix(buffer.AsSpan(0, count));
    }

    private static async Task<CharacterPrefix> ReadCharacterPrefixAsync(
        TextReader source,
        int maximumCharacters,
        CancellationToken cancellationToken)
    {
        var buffer = new char[Math.Min(4096, maximumCharacters)];
        var count = 0;
        while (count < buffer.Length)
        {
            var read = await source.ReadAsync(buffer.AsMemory(count), cancellationToken)
                .ConfigureAwait(false);
            if (read == 0)
                break;
            count += read;
        }
        return new CharacterPrefix(buffer, count);
    }

    private static byte[] ValidateUtf8Prefix(ReadOnlySpan<byte> prefix)
    {
        if (HasPrefix(prefix, 0xEF, 0xBB, 0xBF))
            return prefix[3..].ToArray();
        if (HasPrefix(prefix, 0xFF, 0xFE) ||
            HasPrefix(prefix, 0xFE, 0xFF) ||
            HasPrefix(prefix, 0x00, 0x00, 0xFE, 0xFF) ||
            HasPrefix(prefix, 0xFF, 0xFE, 0x00, 0x00) ||
            HasPrefix(prefix, 0x00, 0x00, 0x00, 0x3C) ||
            HasPrefix(prefix, 0x3C, 0x00, 0x00, 0x00) ||
            HasPrefix(prefix, 0x4C, 0x6F, 0xA7, 0x94) ||
            HasPrefix(prefix, 0x00, 0x3C) ||
            HasPrefix(prefix, 0x3C, 0x00))
        {
            throw InvalidFormat("The OpenMath byte source uses an unsupported encoding.");
        }
        return prefix.ToArray();
    }

    private static bool HasPrefix(ReadOnlySpan<byte> value, byte first, byte second) =>
        value.Length >= 2 && value[0] == first && value[1] == second;

    private static bool HasPrefix(
        ReadOnlySpan<byte> value,
        byte first,
        byte second,
        byte third) =>
        value.Length >= 3 &&
        value[0] == first &&
        value[1] == second &&
        value[2] == third;

    private static bool HasPrefix(
        ReadOnlySpan<byte> value,
        byte first,
        byte second,
        byte third,
        byte fourth) =>
        value.Length >= 4 &&
        value[0] == first &&
        value[1] == second &&
        value[2] == third &&
        value[3] == fourth;

    private static OpenMathImportOptionsSnapshot CreateOptionsSnapshot(
        MathBlockOpenMathImportOptions? options)
    {
        var value = options ?? MathBlockOpenMathImportOptions.Default;
        if (value.MaximumDocumentCharacters <= 0 ||
            value.MaximumDocumentCharacters > MaximumDocumentCharacters)
        {
            throw new ArgumentOutOfRangeException(
                nameof(options),
                "The maximum document character count is outside the supported range.");
        }
        if (value.MaximumDocumentBytes <= 0 ||
            value.MaximumDocumentBytes > MaximumDocumentUtf8Bytes)
        {
            throw new ArgumentOutOfRangeException(
                nameof(options),
                "The maximum document byte count is outside the supported range.");
        }
        if (value.MaximumNodes <= 0)
        {
            throw new ArgumentOutOfRangeException(
                nameof(options),
                "The maximum node count must be positive.");
        }
        if (value.MaximumOutputs <= 0)
        {
            throw new ArgumentOutOfRangeException(
                nameof(options),
                "The maximum output count must be positive.");
        }
        if (value.MaximumValueElements <= 0)
        {
            throw new ArgumentOutOfRangeException(
                nameof(options),
                "The maximum value-element count must be positive.");
        }
        return new OpenMathImportOptionsSnapshot(
            value.MaximumDocumentCharacters,
            value.MaximumDocumentBytes,
            value.MaximumNodes,
            value.MaximumOutputs,
            value.MaximumValueElements,
            value.RequireCanonicalSource,
            value.CaptureSourceLocations);
    }

    private static void RequireCanonicalText(
        MathBlockOpenMathImportResult result,
        string? source,
        OpenMathImportOptionsSnapshot options)
    {
        if (!options.RequireCanonicalSource)
            return;
        if (source is null ||
            !string.Equals(source, Export(result.Program), StringComparison.Ordinal))
        {
            throw InvalidFormat("The OpenMath source must use the canonical form.");
        }
    }

    private static void RequireCanonicalUtf8(
        MathBlockOpenMathImportResult result,
        ReadOnlySpan<byte> source,
        OpenMathImportOptionsSnapshot options)
    {
        if (!options.RequireCanonicalSource)
            return;
        if (!source.SequenceEqual(ExportUtf8(result.Program)))
            throw InvalidFormat("The OpenMath source must use the canonical form.");
    }

    private static MathBlockOpenMathDiagnostic CreateDiagnostic(FormatException exception)
    {
        var xml = FindInnerException<XmlException>(exception);
        var line = GetDiagnosticInteger(exception, DiagnosticLineKey);
        var column = GetDiagnosticInteger(exception, DiagnosticColumnKey);
        if (xml is not null)
        {
            line ??= xml.LineNumber > 0 ? xml.LineNumber : null;
            column ??= xml.LinePosition > 0 ? xml.LinePosition : null;
        }
        return new MathBlockOpenMathDiagnostic(
            exception.Data[DiagnosticCodeKey] is MathBlockOpenMathDiagnosticCode code
                ? code
                : GetDiagnosticCode(exception.Message),
            exception.Message,
            line,
            column,
            GetDiagnosticReference<string>(exception, DiagnosticPathKey),
            GetDiagnosticInteger(exception, DiagnosticNodeKey),
            GetDiagnosticReference<string>(exception, DiagnosticOperationKey),
            GetDiagnosticReference<string>(exception, DiagnosticDictionaryKey),
            GetDiagnosticReference<string>(exception, DiagnosticSymbolKey));
    }

    private static FormatException UnsupportedDocumentContentFormat(
        XmlException? exception = null)
    {
        var result = InvalidFormat("The OpenMath document contains unsupported content.");
        result.Data[DiagnosticCodeKey] =
            MathBlockOpenMathDiagnosticCode.UnsupportedDocumentContent;
        if (exception?.LineNumber > 0)
            result.Data[DiagnosticLineKey] = exception.LineNumber;
        if (exception?.LinePosition > 0)
            result.Data[DiagnosticColumnKey] = exception.LinePosition;
        return result;
    }

    private static MathBlockOpenMathDiagnosticCode GetDiagnosticCode(string message) =>
        message switch
        {
            "The OpenMath source is empty." => MathBlockOpenMathDiagnosticCode.SourceEmpty,
            "The OpenMath source exceeds the character limit." =>
                MathBlockOpenMathDiagnosticCode.DocumentCharacterLimitExceeded,
            "The OpenMath source exceeds the byte limit." =>
                MathBlockOpenMathDiagnosticCode.DocumentByteLimitExceeded,
            "The OpenMath source exceeds the node limit." =>
                MathBlockOpenMathDiagnosticCode.NodeLimitExceeded,
            "The OpenMath source exceeds the output limit." =>
                MathBlockOpenMathDiagnosticCode.OutputLimitExceeded,
            "The OpenMath source exceeds the value-element limit." =>
                MathBlockOpenMathDiagnosticCode.ValueElementLimitExceeded,
            "The OpenMath UTF-8 source is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidUtf8,
            "The OpenMath byte source uses an unsupported encoding." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedEncoding,
            "The OpenMath source is not valid XML." =>
                MathBlockOpenMathDiagnosticCode.InvalidXml,
            "The OpenMath document contains unsupported content." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedDocumentContent,
            "The OpenMath version is not supported." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedOpenMathVersion,
            "The OpenMath content dictionary base is not supported." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedContentDictionaryBase,
            "The OpenMath content dictionary group is not supported." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedContentDictionaryGroup,
            "The OpenMath root must contain one object." or
            "The OpenMath program must contain nodes and outputs." or
            "The OpenMath program requires an output." or
            "An OpenMath application is empty." =>
                MathBlockOpenMathDiagnosticCode.InvalidProgramEnvelope,
            "The OpenMath node collection is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidNodeCollection,
            "An OpenMath node identifier is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidNodeIdentifier,
            "The OpenMath input order is invalid." or
            "The OpenMath constant order is invalid." or
            "The OpenMath operation order is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidNodeOrder,
            "An OpenMath input node is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidInputNode,
            "An OpenMath constant node is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidConstantNode,
            "An OpenMath operation symbol is not supported." or
            "An OpenMath operation is not registered." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedOperationSymbol,
            "An OpenMath operation has the wrong arity." =>
                MathBlockOpenMathDiagnosticCode.OperationArityMismatch,
            "An OpenMath node reference is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidReference,
            "An OpenMath node has incompatible types." =>
                MathBlockOpenMathDiagnosticCode.IncompatibleNodeTypes,
            "An OpenMath output is invalid." => MathBlockOpenMathDiagnosticCode.InvalidOutput,
            "An OpenMath type is not supported." or
            "An OpenMath type is invalid." => MathBlockOpenMathDiagnosticCode.UnsupportedType,
            "An OpenMath unit is invalid." => MathBlockOpenMathDiagnosticCode.InvalidUnit,
            "An OpenMath rational is invalid." or
            "An OpenMath rational denominator must be positive." or
            "An OpenMath rational must be normalized." or
            "An OpenMath rational is outside the supported range." =>
                MathBlockOpenMathDiagnosticCode.InvalidRational,
            "An OpenMath value kind is invalid." or
            "An OpenMath value kind is not supported." or
            "The OpenMath constant value kind is not supported." =>
                MathBlockOpenMathDiagnosticCode.InvalidValueKind,
            "An OpenMath matrix shape is invalid." or
            "An OpenMath matrix value count is invalid." =>
                MathBlockOpenMathDiagnosticCode.InvalidShape,
            "An OpenMath float has an invalid hexadecimal value." =>
                MathBlockOpenMathDiagnosticCode.InvalidBinary64,
            "An OpenMath float must be finite." =>
                MathBlockOpenMathDiagnosticCode.NonfiniteBinary64,
            "The OpenMath source must use the canonical form." =>
                MathBlockOpenMathDiagnosticCode.NoncanonicalSourceRequired,
            "The OpenMath program is invalid." => MathBlockOpenMathDiagnosticCode.InvalidProgram,
            "An OpenMath attribute namespace is invalid." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedAttributeNamespace,
            "An OpenMath attribute is not supported." =>
                MathBlockOpenMathDiagnosticCode.UnsupportedAttribute,
            "OpenMath element content is invalid." or
            "An OpenMath token contains unsupported content." or
            "An OpenMath symbol is invalid." => MathBlockOpenMathDiagnosticCode.InvalidValue,
            "An OpenMath node is empty." or
            "An OpenMath node is invalid." => MathBlockOpenMathDiagnosticCode.InvalidNodeCollection,
            "An OpenMath complex value is invalid." or
            "An OpenMath point is invalid." or
            "An OpenMath graph is invalid." or
            "An OpenMath graph edge is invalid." or
            "An OpenMath run is invalid." or
            "An OpenMath value application is empty." or
            "An OpenMath Boolean value is invalid." or
            "An OpenMath integer is invalid." or
            "An OpenMath constant is invalid." or
            "An OpenMath constant does not match its type." =>
                MathBlockOpenMathDiagnosticCode.InvalidValue,
            _ when message.StartsWith("Expected the OpenMath ", StringComparison.Ordinal) =>
                MathBlockOpenMathDiagnosticCode.UnexpectedElement,
            _ when message.StartsWith("The OpenMath ", StringComparison.Ordinal) &&
                   message.EndsWith(" attribute is missing.", StringComparison.Ordinal) =>
                MathBlockOpenMathDiagnosticCode.MissingAttribute,
            _ when message.StartsWith("An OpenMath ", StringComparison.Ordinal) &&
                   message.EndsWith(" name is invalid.", StringComparison.Ordinal) =>
                MathBlockOpenMathDiagnosticCode.InvalidValue,
            _ => MathBlockOpenMathDiagnosticCode.InvalidProgram
        };

    private static T? GetDiagnosticReference<T>(FormatException exception, string key)
        where T : class => exception.Data[key] as T;

    private static int? GetDiagnosticInteger(FormatException exception, string key)
    {
        return exception.Data[key] is System.Int32 value ? value : null;
    }

    private static TException? FindInnerException<TException>(Exception exception)
        where TException : Exception
    {
        for (Exception? current = exception; current is not null; current = current.InnerException)
            if (current is TException result)
                return result;
        return null;
    }

    private static void ParseNode(
        BufferedElement element,
        int nodeIndex,
        MathBlockProgramBuilder builder,
        IReadOnlyDictionary<string, MathBlockOperation> operationSymbols,
        List<MathBlockOperation> operations,
        List<MathBlockOpenMathOperationOccurrence> occurrences,
        Dictionary<string, MathBlockOpenMathSourceLocation>? sourceLocations,
        int maximumValueElements,
        ref int valueElementCount)
    {
        AddSourceLocation(
            sourceLocations,
            string.Concat("/program/nodes/", NodeIdentifier(nodeIndex)),
            element.Line,
            element.Column);
        RequireOnlyBufferedAttributes(element, "id");
        RequireBufferedElement(element, "OMA");
        if (RequireBufferedAttribute(element, "id") != NodeIdentifier(nodeIndex))
            throw InvalidFormat("An OpenMath node identifier is invalid.");

        var children = ReadBufferedChildren(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath node is empty.");
        var head = ParseSymbol(children[0]);

        try
        {
            if (head.Dictionary == ProgramDictionary && head.Name == "input")
            {
                if (children.Length != 3)
                    throw InvalidFormat("An OpenMath input node is invalid.");
                var name = ParseName(children[1], "input");
                var type = ParseType(children[2]);
                if (builder.Input(name, type) != nodeIndex)
                    throw InvalidFormat("The OpenMath input order is invalid.");
                return;
            }

            if (head.Dictionary == ProgramDictionary && head.Name == "constant")
            {
                if (children.Length != 3)
                    throw InvalidFormat("An OpenMath constant node is invalid.");
                var type = ParseType(children[1]);
                var elements = GetValueElementCount(children[2], type.Kind);
                if (elements > maximumValueElements - valueElementCount)
                    throw InvalidFormat("The OpenMath source exceeds the value-element limit.");
                valueElementCount += elements;
                var value = ParseValue(children[2], type);
                if (builder.Constant(value) != nodeIndex)
                    throw InvalidFormat("The OpenMath constant order is invalid.");
                return;
            }

            if (head.Dictionary != OperationDictionary ||
                !operationSymbols.TryGetValue(head.Name, out var operation))
            {
                throw InvalidFormat("An OpenMath operation symbol is not supported.");
            }

            var inputCount = children.Length - 1;
            if (inputCount != operation.Arity)
                throw InvalidFormat("An OpenMath operation has the wrong arity.");
            var inputs = new int[inputCount];
            for (var inputIndex = 0; inputIndex < inputCount; inputIndex++)
                inputs[inputIndex] = ParseReference(
                    children[inputIndex + 1],
                    nodeIndex,
                    true);
            if (builder.Apply(operation.Identifier, operation.Version, inputs) != nodeIndex)
                throw InvalidFormat("The OpenMath operation order is invalid.");
            operations.Add(operation);
            var symbol = new MathBlockOpenMathOperationSymbol(OperationDictionary, head.Name);
            occurrences.Add(new MathBlockOpenMathOperationOccurrence(
                occurrences.Count,
                nodeIndex,
                operation,
                symbol));
            AddSourceLocation(
                sourceLocations,
                string.Concat("/program/nodes/", NodeIdentifier(nodeIndex), "/operation"),
                children[0].Line,
                children[0].Column);
        }
        catch (ArgumentException exception)
        {
            throw InvalidFormat("An OpenMath node is invalid.", exception);
        }
        catch (KeyNotFoundException exception)
        {
            throw InvalidFormat("An OpenMath operation is not registered.", exception);
        }
        catch (InvalidOperationException exception)
        {
            throw InvalidFormat("An OpenMath node has incompatible types.", exception);
        }
    }

    private static void ParseOutput(
        BufferedElement element,
        MathBlockProgramBuilder builder,
        int nodeCount,
        int outputIndex,
        Dictionary<string, MathBlockOpenMathSourceLocation>? sourceLocations)
    {
        AddSourceLocation(
            sourceLocations,
            string.Concat(
                "/program/outputs/",
                outputIndex.ToString(CultureInfo.InvariantCulture)),
            element.Line,
            element.Column);
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath output is invalid.");
        RequireParsedSymbol(children[0], ProgramDictionary, "output");
        var name = ParseName(children[1], "output");
        var node = ParseReference(children[2], nodeCount);
        try
        {
            builder.Output(name, node);
        }
        catch (ArgumentException exception)
        {
            throw InvalidFormat("An OpenMath output is invalid.", exception);
        }
    }

    private static void AddSourceLocation(
        Dictionary<string, MathBlockOpenMathSourceLocation>? locations,
        string profilePath,
        int line,
        int column)
    {
        if (locations is null)
            return;
        locations.Add(
            profilePath,
            new MathBlockOpenMathSourceLocation(profilePath, line, column));
    }

    private static MathBlockType ParseType(BufferedElement element)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 5)
            throw InvalidFormat("An OpenMath type is invalid.");
        RequireParsedSymbol(children[0], TypeDictionary, "type");
        var kindSymbol = ParseSymbol(children[1]);
        if (kindSymbol.Dictionary != TypeDictionary)
            throw InvalidFormat("An OpenMath value kind is invalid.");
        var type = new MathBlockType(
            ReadKind(kindSymbol.Name),
            ParseUnit(children[2]),
            ParseInteger(children[3]),
            ParseInteger(children[4]));
        RequireSupportedType(type, true);
        return type;
    }

    private static MathBlockUnit ParseUnit(BufferedElement element)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 5)
            throw InvalidFormat("An OpenMath unit is invalid.");
        RequireParsedSymbol(children[0], TypeDictionary, "unit");
        return new MathBlockUnit(
            ParseRational(children[1]),
            ParseRational(children[2]),
            ParseRational(children[3]),
            ParseRational(children[4]));
    }

    private static MathRational ParseRational(BufferedElement element)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath rational is invalid.");
        RequireParsedSymbol(children[0], TypeDictionary, "rational");
        var numerator = ParseInteger(children[1]);
        var denominator = ParseInteger(children[2]);
        if (denominator <= 0)
            throw InvalidFormat("An OpenMath rational denominator must be positive.");
        try
        {
            var result = new MathRational(numerator, denominator);
            if (result.Numerator != numerator || result.Denominator != denominator)
                throw InvalidFormat("An OpenMath rational must be normalized.");
            return result;
        }
        catch (ArithmeticException exception)
        {
            throw InvalidFormat("An OpenMath rational is outside the supported range.", exception);
        }
    }

    private static MathBlockValue ParseValue(BufferedElement element, MathBlockType type)
    {
        MathBlockValue value;
        try
        {
            value = type.Kind switch
            {
                MathBlockValueKind.Scalar => MathBlockValue.Scalar(ParseDouble(element), type.Unit),
                MathBlockValueKind.Boolean => MathBlockValue.Boolean(ParseBoolean(element)),
                MathBlockValueKind.Complex => MathBlockValue.Complex(ParseComplex(element), type.Unit),
                MathBlockValueKind.Vector => ParseVector(element, type),
                MathBlockValueKind.Matrix => ParseMatrix(element, type),
                MathBlockValueKind.ComplexVector => ParseComplexVector(element, type),
                MathBlockValueKind.ComplexMatrix => ParseComplexMatrix(element, type),
                MathBlockValueKind.PointSet => ParsePointSet(element, type),
                MathBlockValueKind.Graph => ParseGraph(element, type),
                MathBlockValueKind.RunSet => ParseRunSet(element, type),
                MathBlockValueKind.BooleanVector => ParseBooleanVector(element),
                _ => throw InvalidFormat("The OpenMath constant value kind is not supported.")
            };
        }
        catch (ArgumentException exception)
        {
            throw InvalidFormat("An OpenMath constant is invalid.", exception);
        }
        catch (InvalidDataException exception)
        {
            throw InvalidFormat("An OpenMath constant is invalid.", exception);
        }

        if (!value.IsValid || value.Type != type)
            throw InvalidFormat("An OpenMath constant does not match its type.");
        return value;
    }

    private static int GetValueElementCount(
        BufferedElement element,
        MathBlockValueKind kind) => kind switch
    {
        MathBlockValueKind.Scalar or
        MathBlockValueKind.Boolean or
        MathBlockValueKind.Complex => 1,
        MathBlockValueKind.Graph => Math.Max(0, element.Children.Length - 2),
        MathBlockValueKind.Vector or
        MathBlockValueKind.Matrix or
        MathBlockValueKind.ComplexVector or
        MathBlockValueKind.ComplexMatrix or
        MathBlockValueKind.PointSet or
        MathBlockValueKind.RunSet or
        MathBlockValueKind.BooleanVector => Math.Max(0, element.Children.Length - 1),
        _ => 0
    };

    private static MathBlockValue ParseVector(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "vector");
        var values = new double[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseDouble(children[index + 1]);
        return MathBlockValue.Vector(values, type.Unit);
    }

    private static MathBlockValue ParseMatrix(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "matrix");
        var count = RequireMatrixElementCount(type, children.Length - 1);
        var values = new double[count];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseDouble(children[index + 1]);
        return MathBlockValue.Matrix(new MathBlockMatrix(type.Rows, type.Columns, values), type.Unit);
    }

    private static MathBlockComplexValue ParseComplex(BufferedElement element)
    {
        var children = ReadBufferedValueApplication(element, "complex");
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath complex value is invalid.");
        return new MathBlockComplexValue(ParseDouble(children[1]), ParseDouble(children[2]));
    }

    private static MathBlockValue ParseComplexVector(
        BufferedElement element,
        MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "complex-vector");
        var values = new MathBlockComplexValue[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseComplex(children[index + 1]);
        return MathBlockValue.ComplexVector(values, type.Unit);
    }

    private static MathBlockValue ParseComplexMatrix(
        BufferedElement element,
        MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "complex-matrix");
        var count = RequireMatrixElementCount(type, children.Length - 1);
        var values = new MathBlockComplexValue[count];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseComplex(children[index + 1]);
        return MathBlockValue.ComplexMatrix(
            new MathBlockComplexMatrix(type.Rows, type.Columns, values),
            type.Unit);
    }

    private static MathBlockValue ParsePointSet(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "point-set");
        var values = new MathBlockPoint[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var pointChildren = ReadBufferedValueApplication(children[index + 1], "point");
            if (pointChildren.Length != 3)
                throw InvalidFormat("An OpenMath point is invalid.");
            values[index] = new MathBlockPoint(
                ParseDouble(pointChildren[1]),
                ParseDouble(pointChildren[2]));
        }
        return MathBlockValue.PointSet(new MathBlockPointSet(values), type.Unit);
    }

    private static MathBlockValue ParseGraph(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "graph");
        if (children.Length < 2)
            throw InvalidFormat("An OpenMath graph is invalid.");
        var vertexCount = ParseInteger(children[1]);
        var edges = new MathBlockGraphEdge[children.Length - 2];
        for (var index = 0; index < edges.Length; index++)
        {
            var edgeChildren = ReadBufferedValueApplication(children[index + 2], "edge");
            if (edgeChildren.Length != 4)
                throw InvalidFormat("An OpenMath graph edge is invalid.");
            edges[index] = new MathBlockGraphEdge(
                ParseInteger(edgeChildren[1]),
                ParseInteger(edgeChildren[2]),
                ParseDouble(edgeChildren[3]));
        }
        return MathBlockValue.Graph(new MathBlockGraph(vertexCount, edges), type.Unit);
    }

    private static MathBlockValue ParseRunSet(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "run-set");
        var values = new MathBlockRun[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var runChildren = ReadBufferedValueApplication(children[index + 1], "run");
            if (runChildren.Length != 4)
                throw InvalidFormat("An OpenMath run is invalid.");
            values[index] = new MathBlockRun(
                ParseInteger(runChildren[1]),
                ParseInteger(runChildren[2]),
                ParseDouble(runChildren[3]));
        }
        return MathBlockValue.RunSet(new MathBlockRunSet(values), type.Unit);
    }

    private static MathBlockValue ParseBooleanVector(BufferedElement element)
    {
        var children = ReadBufferedValueApplication(element, "boolean-vector");
        var values = new bool[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseBoolean(children[index + 1]);
        return MathBlockValue.BooleanVector(values);
    }

    private static BufferedElement[] ReadBufferedValueApplication(
        BufferedElement element,
        string name)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath value application is empty.");
        RequireParsedSymbol(children[0], ValueDictionary, name);
        return children;
    }

    private static double ParseDouble(BufferedElement element)
    {
        RequireBufferedElement(element, "OMF");
        RequireOnlyBufferedAttributes(element, "hex");
        RequireNoBufferedContent(element);
        var text = RequireBufferedAttribute(element, "hex");
        if (text.Length != 16 || text != text.ToUpperInvariant() ||
            !ulong.TryParse(
                text,
                NumberStyles.AllowHexSpecifier,
                CultureInfo.InvariantCulture,
                out var bits))
        {
            throw InvalidFormat("An OpenMath float has an invalid hexadecimal value.");
        }
        var value = BitConverter.Int64BitsToDouble(unchecked((long)bits));
        if (!double.IsFinite(value))
            throw InvalidFormat("An OpenMath float must be finite.");
        return value;
    }

    private static bool ParseBoolean(BufferedElement element)
    {
        var symbol = ParseSymbol(element);
        if (symbol.Dictionary != ValueDictionary)
            throw InvalidFormat("An OpenMath Boolean value is invalid.");
        return symbol.Name switch
        {
            "true" => true,
            "false" => false,
            _ => throw InvalidFormat("An OpenMath Boolean value is invalid.")
        };
    }

    private static int ParseInteger(BufferedElement element)
    {
        RequireBufferedElement(element, "OMI");
        RequireOnlyBufferedAttributes(element);
        var text = RequireBufferedTextOnly(element);
        if (!int.TryParse(
                text,
                NumberStyles.AllowLeadingSign,
                CultureInfo.InvariantCulture,
                out var value) ||
            text != value.ToString(CultureInfo.InvariantCulture))
        {
            throw InvalidFormat("An OpenMath integer is invalid.");
        }
        return value;
    }

    private static string ParseName(BufferedElement element, string role)
    {
        RequireBufferedElement(element, "OMSTR");
        RequireOnlyBufferedAttributes(element);
        var value = RequireBufferedTextOnly(element);
        if (string.IsNullOrWhiteSpace(value) || value != value.Trim() || value.Contains('\r'))
            throw InvalidFormat($"An OpenMath {role} name is invalid.");
        return value;
    }

    private static int ParseReference(
        BufferedElement element,
        int maximumExclusive,
        bool forwardReference = false)
    {
        RequireBufferedElement(element, "OMR");
        RequireOnlyBufferedAttributes(element, "href");
        RequireNoBufferedContent(element);
        var href = RequireBufferedAttribute(element, "href");
        if (!href.StartsWith("#n", StringComparison.Ordinal) ||
            !int.TryParse(
                href.AsSpan(2),
                NumberStyles.None,
                CultureInfo.InvariantCulture,
                out var nodeIndex) ||
            nodeIndex < 0 ||
            href != string.Concat("#", NodeIdentifier(nodeIndex)))
        {
            throw InvalidFormat("An OpenMath node reference is invalid.");
        }
        if (nodeIndex >= maximumExclusive)
        {
            var exception = InvalidFormat("An OpenMath node reference is invalid.");
            if (forwardReference)
            {
                exception.Data[DiagnosticCodeKey] =
                    MathBlockOpenMathDiagnosticCode.ForwardReference;
            }
            throw exception;
        }
        return nodeIndex;
    }

    private static BufferedElement[] ReadBufferedApplication(BufferedElement element)
    {
        RequireBufferedElement(element, "OMA");
        var children = ReadBufferedChildren(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath application is empty.");
        return children;
    }

    private static OpenMathSymbol ParseSymbol(BufferedElement element)
    {
        RequireBufferedElement(element, "OMS");
        RequireOnlyBufferedAttributes(element, "cd", "name");
        RequireNoBufferedContent(element);
        return new OpenMathSymbol(
            RequireBufferedAttribute(element, "cd"),
            RequireBufferedAttribute(element, "name"));
    }

    private static void RequireParsedSymbol(
        BufferedElement element,
        string dictionary,
        string name)
    {
        var symbol = ParseSymbol(element);
        if (symbol.Dictionary != dictionary || symbol.Name != name)
            throw InvalidFormat("An OpenMath symbol is invalid.");
    }

    private static BufferedElement[] ReadBufferedChildren(BufferedElement element)
    {
        if (element.HasUnsupportedContent || !IsXmlWhitespace(element.Text))
            throw InvalidFormat("OpenMath element content is invalid.");
        return element.Children;
    }

    private static void RequireNoBufferedContent(BufferedElement element)
    {
        if (element.Children.Length != 0 ||
            element.HasUnsupportedContent ||
            !IsXmlWhitespace(element.Text))
        {
            throw InvalidFormat("An OpenMath token contains unsupported content.");
        }
    }

    private static string RequireBufferedTextOnly(BufferedElement element)
    {
        if (element.Children.Length != 0 || element.HasUnsupportedContent)
            throw InvalidFormat("An OpenMath token contains unsupported content.");
        return element.Text;
    }

    private static void RequireBufferedElement(BufferedElement element, string localName)
    {
        if (element.LocalName != localName || element.NamespaceName != NamespaceUri)
            throw InvalidFormat($"Expected the OpenMath {localName} element.");
    }

    private static string RequireBufferedAttribute(BufferedElement element, string name)
    {
        for (var index = 0; index < element.Attributes.Count; index++)
        {
            var attribute = element.Attributes[index];
            if (attribute.NamespaceName.Length == 0 && attribute.LocalName == name)
                return attribute.Value;
        }
        throw InvalidFormat($"The OpenMath {name} attribute is missing.");
    }

    private static void RequireOnlyBufferedAttributes(
        BufferedElement element,
        params string[] names) =>
        RequireOnlyBufferedAttributes(element.Attributes, names);

    private static void RequireOnlyBufferedAttributes(
        IReadOnlyList<BufferedAttribute> attributes,
        params string[] names)
    {
        for (var attributeIndex = 0; attributeIndex < attributes.Count; attributeIndex++)
        {
            var attribute = attributes[attributeIndex];
            if (attribute.IsNamespaceDeclaration)
                continue;
            if (attribute.NamespaceName.Length != 0)
                throw InvalidFormat("An OpenMath attribute namespace is invalid.");

            var supported = false;
            for (var nameIndex = 0; nameIndex < names.Length; nameIndex++)
            {
                if (attribute.LocalName != names[nameIndex])
                    continue;
                supported = true;
                break;
            }
            if (!supported)
                throw InvalidFormat("An OpenMath attribute is not supported.");
        }
    }

    private sealed class OpenMathSemanticReader(
        OpenMathImportOptionsSnapshot options,
        bool byteInput)
    {
        private readonly Stack<ElementFrame> frames = new();
        private readonly MathBlockProgramBuilder builder =
            new(MathBlockCatalog.Standard);
        private readonly List<MathBlockOperation> operations = [];
        private readonly List<MathBlockOpenMathOperationOccurrence> occurrences = [];
        private readonly Dictionary<string, MathBlockOpenMathSourceLocation>? sourceLocations =
            options.CaptureSourceLocations
                ? new Dictionary<string, MathBlockOpenMathSourceLocation>(StringComparer.Ordinal)
                : null;
        private int valueElementCount;
        private int nodeCount;
        private bool rootSeen;
        private bool rootComplete;
        private MathBlockOpenMathImportResult? result;

        public void Accept(XmlReader reader, string? asynchronousValue = null)
        {
            switch (reader.NodeType)
            {
                case XmlNodeType.Element:
                    StartElement(reader);
                    return;
                case XmlNodeType.EndElement:
                    EndElement(reader);
                    return;
                case XmlNodeType.Text:
                case XmlNodeType.CDATA:
                case XmlNodeType.Whitespace:
                case XmlNodeType.SignificantWhitespace:
                    AddText(asynchronousValue ?? reader.Value);
                    return;
                case XmlNodeType.XmlDeclaration:
                    if (frames.Count != 0 || rootSeen)
                        RejectUnsupportedContent();
                    if (byteInput &&
                        reader.GetAttribute("encoding") is { } encoding &&
                        !string.Equals(encoding, "utf-8", StringComparison.OrdinalIgnoreCase))
                    {
                        throw InvalidFormat(
                            "The OpenMath byte source uses an unsupported encoding.");
                    }
                    return;
                case XmlNodeType.None:
                    return;
                default:
                    AddUnsupportedContent();
                    return;
            }
        }

        public MathBlockOpenMathImportResult Complete()
        {
            if (frames.Count != 0)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            if (!rootSeen || !rootComplete || result is null)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            return result;
        }

        private void StartElement(XmlReader reader)
        {
            var header = ReadHeader(reader);
            ElementRole role;
            if (frames.Count == 0)
            {
                if (rootSeen)
                    throw InvalidFormat("The OpenMath document contains unsupported content.");
                rootSeen = true;
                role = ElementRole.Root;
                ValidateRootHeader(header);
            }
            else
            {
                role = frames.Peek().NextChildRole();
            }

            var frame = new ElementFrame(header, role);
            if (!reader.IsEmptyElement)
            {
                frames.Push(frame);
                return;
            }
            CompleteFrame(frame);
        }

        private void EndElement(XmlReader reader)
        {
            if (frames.Count == 0)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            var frame = frames.Pop();
            if (frame.Header.LocalName != reader.LocalName ||
                frame.Header.NamespaceName != reader.NamespaceURI)
            {
                throw InvalidFormat("The OpenMath source is not valid XML.");
            }
            CompleteFrame(frame);
        }

        private void AddText(string value)
        {
            if (frames.Count == 0)
            {
                if (!IsXmlWhitespace(value))
                    RejectUnsupportedContent();
                return;
            }
            frames.Peek().AddText(value);
        }

        private void AddUnsupportedContent()
        {
            if (frames.Count == 0)
            {
                RejectUnsupportedContent();
                return;
            }
            frames.Peek().AddUnsupportedContent();
        }

        private static void RejectUnsupportedContent() =>
            throw InvalidFormat("The OpenMath document contains unsupported content.");

        private void CompleteFrame(ElementFrame frame)
        {
            object completed = frame.Role switch
            {
                ElementRole.Root => CompleteRoot(frame),
                ElementRole.Program => CompleteProgram(frame),
                ElementRole.Nodes => CompleteNodeCollection(frame),
                ElementRole.Outputs => CompleteOutputs(frame),
                _ => frame.CreateBufferedElement()
            };

            if (frame.Role == ElementRole.Root)
            {
                rootComplete = true;
                return;
            }
            if (frames.Count == 0)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            AddCompletedChild(frames.Peek(), completed);
        }

        private object CompleteRoot(ElementFrame frame)
        {
            RequireStructuralContent(frame);
            if (frame.ChildCount != 1)
                throw InvalidFormat("The OpenMath root must contain one object.");
            if (frame.Children[0] is not ProgramResult program)
                throw InvalidFormat("The OpenMath root must contain one object.");
            if (program.Error is not null)
                throw program.Error;

            try
            {
                result = new MathBlockOpenMathImportResult(
                    builder.Build(),
                    operations,
                    occurrences,
                    sourceLocations);
            }
            catch (InvalidOperationException exception)
            {
                throw InvalidFormat("The OpenMath program is invalid.", exception);
            }
            return RootResult.Instance;
        }

        private static object CompleteProgram(ElementFrame frame)
        {
            try
            {
                CompleteProgramCore(frame);
                return new ProgramResult(null);
            }
            catch (FormatException exception)
            {
                return new ProgramResult(exception);
            }
        }

        private static void CompleteProgramCore(ElementFrame frame)
        {
            RequireOnlyBufferedAttributes(frame.Header.Attributes);
            RequireStructuralElement(frame, "OMA");
            RequireStructuralContent(frame);
            if (frame.ChildCount == 0)
                throw InvalidFormat("An OpenMath application is empty.");
            if (frame.ChildCount != 3)
                throw InvalidFormat("The OpenMath program must contain nodes and outputs.");
            if (frame.Children[0] is not BufferedElement head)
                throw InvalidFormat("An OpenMath symbol is invalid.");
            RequireParsedSymbol(head, ProgramDictionary, "program");
            if (frame.Children[1] is not NodesResult nodes ||
                frame.Children[2] is not OutputsResult outputs)
            {
                throw InvalidFormat("The OpenMath program must contain nodes and outputs.");
            }
            if (nodes.Error is not null)
                throw nodes.Error;
            if (outputs.Error is not null)
                throw outputs.Error;
        }

        private static int CompleteNodes(ElementFrame frame)
        {
            RequireOnlyBufferedAttributes(frame.Header.Attributes);
            RequireStructuralElement(frame, "OMA");
            RequireStructuralContent(frame);
            if (frame.ChildCount == 0)
                throw InvalidFormat("An OpenMath application is empty.");
            if (frame.Children[0] is not BufferedElement head)
                throw InvalidFormat("An OpenMath symbol is invalid.");
            RequireParsedSymbol(head, ProgramDictionary, "nodes");
            return frame.ChildCount - 1;
        }

        private object CompleteNodeCollection(ElementFrame frame)
        {
            try
            {
                nodeCount = CompleteNodes(frame);
                return new NodesResult(nodeCount, frame.DeferredError);
            }
            catch (FormatException exception)
            {
                return new NodesResult(0, exception);
            }
        }

        private static void CompleteOutputsCore(ElementFrame frame)
        {
            RequireOnlyBufferedAttributes(frame.Header.Attributes);
            RequireStructuralElement(frame, "OMA");
            RequireStructuralContent(frame);
            if (frame.ChildCount == 0)
                throw InvalidFormat("An OpenMath application is empty.");
            if (frame.ChildCount < 2)
                throw InvalidFormat("The OpenMath program requires an output.");
            if (frame.Children[0] is not BufferedElement head)
                throw InvalidFormat("An OpenMath symbol is invalid.");
            RequireParsedSymbol(head, ProgramDictionary, "outputs");
            if (frame.DeferredError is not null)
                throw frame.DeferredError;
        }

        private static object CompleteOutputs(ElementFrame frame)
        {
            try
            {
                CompleteOutputsCore(frame);
                return new OutputsResult(null);
            }
            catch (FormatException exception)
            {
                return new OutputsResult(exception);
            }
        }

        private void AddCompletedChild(ElementFrame parent, object child)
        {
            switch (parent.Role)
            {
                case ElementRole.Node:
                case ElementRole.Output:
                case ElementRole.Buffered:
                    parent.AddBufferedChild((BufferedElement)child);
                    break;
                case ElementRole.Nodes when parent.ChildCount > 0:
                    if (parent.ChildCount - 1 >= options.MaximumNodes)
                    {
                        parent.RecordError(
                            InvalidFormat("The OpenMath source exceeds the node limit."));
                    }
                    if (child is not BufferedElement node)
                    {
                        parent.RecordError(InvalidFormat("An OpenMath node is invalid."));
                    }
                    else if (parent.DeferredError is null)
                    {
                        try
                        {
                            ParseNode(
                                node,
                                parent.ChildCount - 1,
                                builder,
                                StandardProfile.Value.OperationSymbols,
                                operations,
                                occurrences,
                                sourceLocations,
                                options.MaximumValueElements,
                                ref valueElementCount);
                        }
                        catch (FormatException exception)
                        {
                            AttachNodeDiagnosticContext(
                                exception,
                                node,
                                parent.ChildCount - 1);
                            parent.RecordError(exception);
                        }
                    }
                    parent.Children.Add(NodeResult.Instance);
                    break;
                case ElementRole.Outputs when parent.ChildCount > 0:
                    if (parent.ChildCount - 1 >= options.MaximumOutputs)
                    {
                        parent.RecordError(
                            InvalidFormat("The OpenMath source exceeds the output limit."));
                    }
                    if (child is not BufferedElement output)
                    {
                        parent.RecordError(InvalidFormat("An OpenMath output is invalid."));
                    }
                    else if (parent.DeferredError is null)
                    {
                        try
                        {
                            ParseOutput(
                                output,
                                builder,
                                nodeCount,
                                parent.ChildCount - 1,
                                sourceLocations);
                        }
                        catch (FormatException exception)
                        {
                            AttachElementDiagnosticContext(
                                exception,
                                output,
                                string.Concat(
                                    "/program/outputs/",
                                    (parent.ChildCount - 1).ToString(
                                        CultureInfo.InvariantCulture)),
                                null);
                            parent.RecordError(exception);
                        }
                    }
                    parent.Children.Add(OutputResult.Instance);
                    break;
                default:
                    parent.Children.Add(child);
                    break;
            }
        }

        private static void AttachNodeDiagnosticContext(
            FormatException exception,
            BufferedElement node,
            int nodeIndex)
        {
            AttachElementDiagnosticContext(
                exception,
                node,
                string.Concat("/program/nodes/", NodeIdentifier(nodeIndex)),
                nodeIndex);
            if (node.Children.Length == 0)
                return;
            var head = node.Children[0];
            if (head.LocalName != "OMS" || head.NamespaceName != NamespaceUri)
                return;
            var dictionary = TryGetBufferedAttribute(head, "cd");
            var symbol = TryGetBufferedAttribute(head, "name");
            if (dictionary is not null)
                exception.Data[DiagnosticDictionaryKey] = dictionary;
            if (symbol is not null)
                exception.Data[DiagnosticSymbolKey] = symbol;
            if (dictionary == OperationDictionary &&
                symbol is not null &&
                StandardProfile.Value.OperationSymbols.TryGetValue(symbol, out var operation))
            {
                exception.Data[DiagnosticOperationKey] = operation.Identity;
            }
        }

        private static void AttachElementDiagnosticContext(
            FormatException exception,
            BufferedElement element,
            string profilePath,
            int? nodeIndex)
        {
            if (element.Line > 0)
                exception.Data[DiagnosticLineKey] = element.Line;
            if (element.Column > 0)
                exception.Data[DiagnosticColumnKey] = element.Column;
            exception.Data[DiagnosticPathKey] = profilePath;
            if (nodeIndex is not null)
                exception.Data[DiagnosticNodeKey] = nodeIndex.Value;
        }

        private static string? TryGetBufferedAttribute(
            BufferedElement element,
            string name)
        {
            for (var index = 0; index < element.Attributes.Count; index++)
            {
                var attribute = element.Attributes[index];
                if (attribute.NamespaceName.Length == 0 && attribute.LocalName == name)
                    return attribute.Value;
            }
            return null;
        }

        private static void ValidateRootHeader(BufferedHeader header)
        {
            if (header.LocalName != "OMOBJ" || header.NamespaceName != NamespaceUri)
                throw InvalidFormat("Expected the OpenMath OMOBJ element.");
            RequireOnlyBufferedAttributes(header.Attributes, "version", "cdbase", "cdgroup");
            if (RequireBufferedAttribute(header, "version") != StandardVersion)
                throw InvalidFormat("The OpenMath version is not supported.");
            if (RequireBufferedAttribute(header, "cdbase") != ContentDictionaryBase)
                throw InvalidFormat("The OpenMath content dictionary base is not supported.");
            if (RequireBufferedAttribute(header, "cdgroup") != ContentDictionaryGroup)
                throw InvalidFormat("The OpenMath content dictionary group is not supported.");
        }

        private static string RequireBufferedAttribute(BufferedHeader header, string name)
        {
            for (var index = 0; index < header.Attributes.Count; index++)
            {
                var attribute = header.Attributes[index];
                if (attribute.NamespaceName.Length == 0 && attribute.LocalName == name)
                    return attribute.Value;
            }
            throw InvalidFormat($"The OpenMath {name} attribute is missing.");
        }

        private static void RequireStructuralElement(ElementFrame frame, string localName)
        {
            if (frame.Header.LocalName != localName ||
                frame.Header.NamespaceName != NamespaceUri)
            {
                throw InvalidFormat($"Expected the OpenMath {localName} element.");
            }
        }

        private static void RequireStructuralContent(ElementFrame frame)
        {
            if (frame.HasUnsupportedContent)
                throw InvalidFormat("OpenMath element content is invalid.");
        }

        private static BufferedHeader ReadHeader(XmlReader reader)
        {
            var lineInfo = (IXmlLineInfo)reader;
            var line = lineInfo.HasLineInfo() ? lineInfo.LineNumber : 0;
            var column = lineInfo.HasLineInfo() ? lineInfo.LinePosition : 0;
            var attributes = new BufferedAttribute[reader.AttributeCount];
            var attributeIndex = 0;
            if (reader.MoveToFirstAttribute())
            {
                do
                {
                    var namespaceDeclaration =
                        reader.Prefix == "xmlns" ||
                        (reader.Prefix.Length == 0 && reader.LocalName == "xmlns");
                    attributes[attributeIndex++] = new BufferedAttribute(
                        reader.LocalName,
                        reader.NamespaceURI,
                        reader.Value,
                        namespaceDeclaration);
                }
                while (reader.MoveToNextAttribute());
                reader.MoveToElement();
            }
            return new BufferedHeader(
                reader.LocalName,
                reader.NamespaceURI,
                attributes,
                line,
                column);
        }
    }

    private sealed class ElementFrame(BufferedHeader header, ElementRole role)
    {
        private List<BufferedElement>? bufferedChildren;
        private List<object>? children;
        private string? bufferedText;
        private System.Text.StringBuilder? bufferedTextBuilder;

        public BufferedHeader Header { get; } = header;
        public ElementRole Role { get; } = role;
        public List<object> Children => children ??= [];
        public int ChildCount => children?.Count ?? 0;
        public FormatException? DeferredError { get; private set; }
        public bool HasUnsupportedContent { get; private set; }

        public ElementRole NextChildRole() => Role switch
        {
            ElementRole.Root when ChildCount == 0 => ElementRole.Program,
            ElementRole.Program when ChildCount == 1 => ElementRole.Nodes,
            ElementRole.Program when ChildCount == 2 => ElementRole.Outputs,
            ElementRole.Nodes when ChildCount > 0 => ElementRole.Node,
            ElementRole.Outputs when ChildCount > 0 => ElementRole.Output,
            _ => ElementRole.Buffered
        };

        public void AddText(string value)
        {
            if (Role is ElementRole.Node or ElementRole.Output or ElementRole.Buffered)
            {
                if (bufferedText is null)
                {
                    bufferedText = value;
                }
                else
                {
                    bufferedTextBuilder ??= new System.Text.StringBuilder(bufferedText);
                    bufferedTextBuilder.Append(value);
                }
                return;
            }
            if (!IsXmlWhitespace(value))
                HasUnsupportedContent = true;
        }

        public void AddUnsupportedContent()
        {
            if (Role is ElementRole.Node or ElementRole.Output or ElementRole.Buffered)
            {
                HasUnsupportedContent = true;
                return;
            }
            HasUnsupportedContent = true;
        }

        public void AddBufferedChild(BufferedElement element) =>
            (bufferedChildren ??= []).Add(element);

        public void RecordError(FormatException exception) =>
            DeferredError ??= exception;

        public BufferedElement CreateBufferedElement() =>
            new(
                Header.LocalName,
                Header.NamespaceName,
                Header.Attributes,
                bufferedChildren?.ToArray() ?? [],
                bufferedTextBuilder?.ToString() ?? bufferedText ?? string.Empty,
                HasUnsupportedContent,
                Header.Line,
                Header.Column);
    }

    private readonly record struct BufferedHeader(
        string LocalName,
        string NamespaceName,
        IReadOnlyList<BufferedAttribute> Attributes,
        int Line,
        int Column);

    private readonly record struct BufferedAttribute(
        string LocalName,
        string NamespaceName,
        string Value,
        bool IsNamespaceDeclaration);

    private sealed record BufferedElement(
        string LocalName,
        string NamespaceName,
        IReadOnlyList<BufferedAttribute> Attributes,
        BufferedElement[] Children,
        string Text,
        bool HasUnsupportedContent,
        int Line,
        int Column);

    private sealed record RootResult
    {
        public static RootResult Instance { get; } = new();
    }

    private sealed record ProgramResult(FormatException? Error);

    private sealed record NodesResult(int Count, FormatException? Error);

    private sealed record NodeResult
    {
        public static NodeResult Instance { get; } = new();
    }

    private sealed record OutputsResult(FormatException? Error);

    private sealed record OutputResult
    {
        public static OutputResult Instance { get; } = new();
    }

    private sealed class LimitedReadStream(
        Stream source,
        int maximumBytes,
        CancellationToken cancellationToken,
        bool asyncOnly,
        bool captureSource) : Stream
    {
        private readonly ArrayBufferWriter<byte>? captured =
            captureSource ? new ArrayBufferWriter<byte>() : null;

        public long UnitsRead { get; private set; }
        public ReadOnlySpan<byte> CapturedBytes =>
            captured is null ? ReadOnlySpan<byte>.Empty : captured.WrittenSpan;
        public override bool CanRead => source.CanRead;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => throw new NotSupportedException();
        public override long Position
        {
            get => throw new NotSupportedException();
            set => throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            Read(buffer.AsSpan(offset, count));

        public override int Read(Span<byte> buffer)
        {
            if (asyncOnly)
                throw new InvalidOperationException("The asynchronous reader used synchronous input.");
            var allowed = AllowedCount(buffer.Length);
            var read = source.Read(buffer[..allowed]);
            Capture(buffer[..read]);
            AddCount(read);
            return read;
        }

        public override Task<int> ReadAsync(
            byte[] buffer,
            int offset,
            int count,
            CancellationToken token) =>
            ReadAsync(buffer.AsMemory(offset, count), token).AsTask();

        public override async ValueTask<int> ReadAsync(
            Memory<byte> buffer,
            CancellationToken token = default)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var allowed = AllowedCount(buffer.Length);
            var read = await source.ReadAsync(
                    buffer[..allowed],
                    cancellationToken.CanBeCanceled ? cancellationToken : token)
                .ConfigureAwait(false);
            Capture(buffer.Span[..read]);
            AddCount(read);
            return read;
        }

        public override int ReadByte()
        {
            Span<byte> value = stackalloc byte[1];
            return Read(value) == 0 ? -1 : value[0];
        }

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();

        private int AllowedCount(int requested)
        {
            if (requested == 0)
                return 0;
            var remaining = maximumBytes - UnitsRead;
            if (remaining < 0)
                throw new OpenMathByteLimitException();
            return (int)Math.Min(requested, remaining + 1);
        }

        private void AddCount(int count)
        {
            UnitsRead += count;
            if (UnitsRead > maximumBytes)
                throw new OpenMathByteLimitException();
        }

        private void Capture(ReadOnlySpan<byte> value)
        {
            if (captured is not null)
                captured.Write(value);
        }
    }

    private sealed class PrefixReplayStream(
        Stream source,
        byte[] prefix,
        bool asyncOnly) : Stream
    {
        private int prefixOffset;

        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => throw new NotSupportedException();
        public override long Position
        {
            get => throw new NotSupportedException();
            set => throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            Read(buffer.AsSpan(offset, count));

        public override int Read(Span<byte> buffer)
        {
            if (asyncOnly)
                throw new InvalidOperationException("The asynchronous reader used synchronous input.");
            var copied = CopyPrefix(buffer);
            if (copied == buffer.Length)
                return copied;
            return copied + source.Read(buffer[copied..]);
        }

        public override Task<int> ReadAsync(
            byte[] buffer,
            int offset,
            int count,
            CancellationToken token) =>
            ReadAsync(buffer.AsMemory(offset, count), token).AsTask();

        public override async ValueTask<int> ReadAsync(
            Memory<byte> buffer,
            CancellationToken token = default)
        {
            var copied = CopyPrefix(buffer.Span);
            if (copied == buffer.Length)
                return copied;
            return copied + await source.ReadAsync(buffer[copied..], token).ConfigureAwait(false);
        }

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();

        private int CopyPrefix(Span<byte> destination)
        {
            var count = Math.Min(destination.Length, prefix.Length - prefixOffset);
            prefix.AsSpan(prefixOffset, count).CopyTo(destination);
            prefixOffset += count;
            return count;
        }
    }

    private sealed class PrefixReplayTextReader(
        TextReader source,
        char[] prefix,
        int prefixCount) : TextReader
    {
        private int prefixOffset;

        public override int Peek()
        {
            if (prefixOffset < prefixCount)
                return prefix[prefixOffset];
            throw new InvalidOperationException(
                "The asynchronous reader used synchronous input.");
        }

        public override int Read()
        {
            if (prefixOffset < prefixCount)
                return prefix[prefixOffset++];
            throw new InvalidOperationException(
                "The asynchronous reader used synchronous input.");
        }

        public override int Read(char[] buffer, int index, int count) =>
            Read(buffer.AsSpan(index, count));

        public override int Read(Span<char> buffer)
        {
            if (prefixOffset >= prefixCount)
            {
                throw new InvalidOperationException(
                    "The asynchronous reader used synchronous input.");
            }
            var count = Math.Min(buffer.Length, prefixCount - prefixOffset);
            prefix.AsSpan(prefixOffset, count).CopyTo(buffer);
            prefixOffset += count;
            return count;
        }

        public override Task<int> ReadAsync(char[] buffer, int index, int count) =>
            ReadAsync(buffer.AsMemory(index, count)).AsTask();

        public override ValueTask<int> ReadAsync(
            Memory<char> buffer,
            CancellationToken cancellationToken = default)
        {
            cancellationToken.ThrowIfCancellationRequested();
            if (prefixOffset < prefixCount)
            {
                var count = Math.Min(buffer.Length, prefixCount - prefixOffset);
                prefix.AsMemory(prefixOffset, count).CopyTo(buffer);
                prefixOffset += count;
                return ValueTask.FromResult(count);
            }
            return source.ReadAsync(buffer, cancellationToken);
        }
    }

    private sealed class LimitedTextReader(
        TextReader source,
        int maximumCharacters,
        CancellationToken cancellationToken,
        bool asyncOnly,
        bool captureSource) : TextReader
    {
        private readonly StringBuilder? captured = captureSource ? new StringBuilder() : null;
        private int commentStartMatchLength;
        private int commentEndMatchLength;
        private int cDataStartMatchLength;
        private int cDataEndMatchLength;
        private int processingInstructionStartMatchLength;
        private int processingInstructionEndMatchLength;
        private int prohibitedDtdMatchLength;
        private bool insideComment;
        private bool insideCData;
        private bool insideProcessingInstruction;

        public long UnitsRead { get; private set; }
        public string? CapturedText => captured?.ToString();

        public override int Peek()
        {
            if (asyncOnly)
                throw new InvalidOperationException("The asynchronous reader used synchronous input.");
            return source.Peek();
        }

        public override int Read()
        {
            if (asyncOnly)
                throw new InvalidOperationException("The asynchronous reader used synchronous input.");
            var value = source.Read();
            if (value >= 0)
            {
                captured?.Append((char)value);
                AddCount(1);
                RejectProhibitedDtd((char)value);
            }
            return value;
        }

        public override int Read(char[] buffer, int index, int count) =>
            Read(buffer.AsSpan(index, count));

        public override int Read(Span<char> buffer)
        {
            if (asyncOnly)
                throw new InvalidOperationException("The asynchronous reader used synchronous input.");
            var allowed = AllowedCount(buffer.Length);
            var read = source.Read(buffer[..allowed]);
            captured?.Append(buffer[..read]);
            AddCount(read);
            RejectProhibitedDtd(buffer[..read]);
            return read;
        }

        public override Task<int> ReadAsync(char[] buffer, int index, int count) =>
            ReadAsync(buffer.AsMemory(index, count), cancellationToken).AsTask();

        public override async ValueTask<int> ReadAsync(
            Memory<char> buffer,
            CancellationToken token = default)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var allowed = AllowedCount(buffer.Length);
            var read = await source.ReadAsync(
                    buffer[..allowed],
                    cancellationToken.CanBeCanceled ? cancellationToken : token)
                .ConfigureAwait(false);
            captured?.Append(buffer.Span[..read]);
            AddCount(read);
            RejectProhibitedDtd(buffer.Span[..read]);
            return read;
        }

        private int AllowedCount(int requested)
        {
            if (requested == 0)
                return 0;
            var remaining = maximumCharacters - UnitsRead;
            if (remaining < 0)
                throw new OpenMathCharacterLimitException();
            return (int)Math.Min(requested, remaining + 1);
        }

        private void AddCount(int count)
        {
            UnitsRead += count;
            if (UnitsRead > maximumCharacters)
                throw new OpenMathCharacterLimitException();
        }

        private void RejectProhibitedDtd(char value)
        {
            if (insideComment)
            {
                if (AdvanceDelimitedEnd(value, '-', '>', ref commentEndMatchLength))
                    insideComment = false;
                return;
            }

            if (insideCData)
            {
                if (AdvanceDelimitedEnd(value, ']', '>', ref cDataEndMatchLength))
                    insideCData = false;
                return;
            }

            if (insideProcessingInstruction)
            {
                if (AdvanceProcessingInstructionEnd(value))
                    insideProcessingInstruction = false;
                return;
            }

            if (AdvanceStart(value, CommentStart, ref commentStartMatchLength))
            {
                ResetStartMatches();
                insideComment = true;
                return;
            }

            if (AdvanceStart(
                    value,
                    ProcessingInstructionStart,
                    ref processingInstructionStartMatchLength))
            {
                ResetStartMatches();
                insideProcessingInstruction = true;
                return;
            }

            if (AdvanceStart(value, CDataStart, ref cDataStartMatchLength))
            {
                ResetStartMatches();
                insideCData = true;
                return;
            }

            if (AdvanceStart(value, ProhibitedDtdPrefix, ref prohibitedDtdMatchLength))
                throw UnsupportedDocumentContentFormat();
        }

        private void RejectProhibitedDtd(ReadOnlySpan<char> value)
        {
            for (var index = 0; index < value.Length; index++)
                RejectProhibitedDtd(value[index]);
        }

        private static bool AdvanceStart(
            char value,
            string sequence,
            ref int matchLength)
        {
            if (value == sequence[matchLength])
            {
                matchLength++;
                if (matchLength < sequence.Length)
                    return false;
                matchLength = 0;
                return true;
            }
            matchLength = value == sequence[0] ? 1 : 0;
            return false;
        }

        private static bool AdvanceDelimitedEnd(
            char value,
            char repeated,
            char terminal,
            ref int matchLength)
        {
            if (value == repeated)
            {
                matchLength = Math.Min(matchLength + 1, 2);
                return false;
            }
            if (value == terminal && matchLength == 2)
            {
                matchLength = 0;
                return true;
            }
            matchLength = 0;
            return false;
        }

        private bool AdvanceProcessingInstructionEnd(char value)
        {
            if (value == '?')
            {
                processingInstructionEndMatchLength = 1;
                return false;
            }
            if (value == '>' && processingInstructionEndMatchLength == 1)
            {
                processingInstructionEndMatchLength = 0;
                return true;
            }
            processingInstructionEndMatchLength = 0;
            return false;
        }

        private void ResetStartMatches()
        {
            commentStartMatchLength = 0;
            cDataStartMatchLength = 0;
            processingInstructionStartMatchLength = 0;
            prohibitedDtdMatchLength = 0;
        }
    }

    private sealed class ReadOnlySequenceStream : Stream
    {
        private readonly long length;
        private ReadOnlySequence<byte> remaining;

        public ReadOnlySequenceStream(ReadOnlySequence<byte> source)
        {
            length = source.Length;
            remaining = source;
        }

        public override bool CanRead => true;
        public override bool CanSeek => false;
        public override bool CanWrite => false;
        public override long Length => length;
        public override long Position
        {
            get => length - remaining.Length;
            set => throw new NotSupportedException();
        }

        public override int Read(byte[] buffer, int offset, int count) =>
            Read(buffer.AsSpan(offset, count));

        public override int Read(Span<byte> buffer)
        {
            if (buffer.Length == 0 || remaining.IsEmpty)
                return 0;
            var count = (int)Math.Min(buffer.Length, remaining.Length);
            remaining.Slice(0, count).CopyTo(buffer);
            remaining = remaining.Slice(count);
            return count;
        }

        public override void Flush() => throw new NotSupportedException();
        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();
        public override void SetLength(long value) => throw new NotSupportedException();
        public override void Write(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();
    }

    private sealed class OpenMathByteLimitException : IOException
    {
    }

    private sealed class OpenMathCharacterLimitException : IOException
    {
    }

    private readonly record struct OpenMathImportOptionsSnapshot(
        int MaximumDocumentCharacters,
        int MaximumDocumentBytes,
        int MaximumNodes,
        int MaximumOutputs,
        int MaximumValueElements,
        bool RequireCanonicalSource,
        bool CaptureSourceLocations);

    private readonly record struct CharacterPrefix(char[] Buffer, int Count);

    private enum ElementRole
    {
        Root,
        Program,
        Nodes,
        Node,
        Outputs,
        Output,
        Buffered
    }
}
