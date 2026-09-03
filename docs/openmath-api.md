# MathBlocks OpenMath API

This guide applies to MathBlocks 0.4.1 and OpenMath Profile 1.

Profile 1 represents a complete typed `MathBlockProgram`. It preserves node
order, operand order, shared nodes, constants, units, shapes, and outputs.

Profile 1 does not parse presentation expressions. Text such as `sin(x) + x^2`
is outside this API.

## Canonical form

`MathBlockOpenMath.Export` returns the canonical character form. The UTF-8
encoding follows Canonical XML 1.1 without comments.

Canonical output has no XML declaration. It has no byte-order mark and no
final newline. It uses full end elements and one fixed attribute order.

The canonical form is deterministic. The program node order determines the
operation order. The exporter does not simplify or reorder the graph.

`MathBlockOpenMath.CanonicalizationAlgorithm` identifies the canonical XML
algorithm. `MathBlockOpenMath.MediaType` is `application/openmath+xml`.

## Character output

`Export` returns one string. `Write` writes the same characters to a
caller-owned `TextWriter`.

`WriteAsync` writes the same characters with async I/O. It accepts a
`CancellationToken`.

The library leaves the text writer open. A transport error can leave partial
output in that writer.

```csharp
var notation = MathBlockOpenMath.Export(program);

using var writer = new StringWriter();
MathBlockOpenMath.Write(program, writer);

using var asyncWriter = new StringWriter();
await MathBlockOpenMath.WriteAsync(program, asyncWriter, cancellationToken);
```

## UTF-8 output

`ExportUtf8` returns canonical UTF-8 bytes. `GetUtf8ByteCount` returns the
exact required capacity.

`TryWriteUtf8` writes to a supplied span. Insufficient capacity returns
`false`, sets `bytesWritten` to zero, and leaves the span unchanged.

An invalid program still throws from `TryWriteUtf8`. It is not reported as a
capacity failure.

`WriteUtf8` writes to an `IBufferWriter<byte>` or a `Stream`.
`WriteUtf8Async` performs async stream I/O.

All caller-owned destinations stay open. Stream output completes semantic
preflight before it writes the first byte.

```csharp
var byteCount = MathBlockOpenMath.GetUtf8ByteCount(program);
var bytes = new byte[byteCount];

if (!MathBlockOpenMath.TryWriteUtf8(program, bytes, out var bytesWritten))
    throw new InvalidOperationException("The exact destination was rejected.");

await using var stream = File.Create("program.openmath.xml");
await MathBlockOpenMath.WriteUtf8Async(program, stream, cancellationToken);
```

## Character input

`Import(string)` keeps the 0.4.0 behavior. Its overload accepts import
options.

`Read` consumes a complete document from a caller-owned `TextReader`.
`ReadAsync` performs async character I/O.

The reader accepts valid equivalent XML forms. It normalizes namespace
prefixes, attribute order, empty elements, character references, and CDATA.

The reader examines content through the input end. It accepts trailing XML
whitespace. It rejects a second document and other trailing content.

The library leaves each caller-owned reader open.

## UTF-8 input

`ImportUtf8` accepts a contiguous `ReadOnlySpan<byte>` or a segmented
`ReadOnlySequence<byte>`. The sequence path does not join all segments.

`ReadUtf8` reads from a caller-owned stream at its current position.
`ReadUtf8Async` performs async stream I/O.

Byte methods accept UTF-8 only. They accept an optional UTF-8 byte-order mark.
The byte-order mark makes otherwise valid input noncanonical.

Malformed UTF-8 is invalid. UTF-16, UTF-32, EBCDIC, and conflicting XML
encoding declarations are unsupported.

The library leaves caller-owned streams open. An input failure can leave a
stream at the detected failure position.

## Import options

`MathBlockOpenMathImportOptions.Default` preserves the 0.4.0 string
acceptance boundary.

`MaximumDocumentCharacters` defaults to 16,777,216. It cannot exceed
`MathBlockOpenMath.MaximumDocumentCharacters`.

`MaximumDocumentBytes` defaults to 50,331,651. It cannot exceed
`MathBlockOpenMath.MaximumDocumentUtf8Bytes`.

`MaximumNodes`, `MaximumOutputs`, and `MaximumValueElements` default to
`Int32.MaxValue`.

`RequireCanonicalSource` rejects valid noncanonical source. It defaults to
`false`.

`CaptureSourceLocations` adds node, operation, and output locations. It
defaults to `false`.

Every numeric limit must be positive. Invalid options throw
`ArgumentOutOfRangeException` before caller input is consumed.

The library copies all option values before parsing. Later caller changes
cannot affect an active import.

```csharp
var options = new MathBlockOpenMathImportOptions
{
    MaximumDocumentBytes = 4 * 1024 * 1024,
    MaximumNodes = 50_000,
    MaximumOutputs = 1_000,
    MaximumValueElements = 2_000_000,
    RequireCanonicalSource = true,
    CaptureSourceLocations = true
};

var imported = MathBlockOpenMath.ImportUtf8(sourceBytes, options);
```

## Import results

`MathBlockOpenMathImportResult.Program` is the complete typed program.
`Operations` keeps each operation use in program node order.

`OperationOccurrences` adds an ordinal, node index, operation, and Profile 1
symbol for each use. Repeated uses remain separate records.

`SourceLocations` is null unless location capture was requested. Its keys use
stable Profile 1 paths.

Representative paths have these forms.

```text
/program/nodes/n0
/program/nodes/n2/operation
/program/outputs/0
```

Lines and columns are one-based. Byte and character offsets are not reported.
The result retains no source text, stream, reader, or parser.

## Nonthrowing import

`TryImport`, `TryImportUtf8`, `TryRead`, and `TryReadUtf8` avoid
exception-driven document control flow. Async reader forms are also available.

A successful attempt has one `Result` and no `Diagnostic`. A failed attempt
has one `Diagnostic` and no `Result`.

These methods convert only document `FormatException` failures. Invalid
options, cancellation, I/O errors, allocation failures, and implementation
errors still throw.

```csharp
var attempt = MathBlockOpenMath.TryImport(untrustedSource);
if (!attempt.Succeeded)
{
    logger.LogWarning(
        "OpenMath failure {Code} at {Line}:{Column}.",
        attempt.Diagnostic!.Code,
        attempt.Diagnostic.Line,
        attempt.Diagnostic.Column);
}
```

Diagnostics never contain a source excerpt. Applications can log a code and
location without disclosing the document.

## Diagnostic fields

`Code` is the stable machine value. `Message` is invariant English text.

`Line` and `Column` contain one-based XML reader positions when available.
`ProfilePath` identifies the semantic profile position.

`NodeIndex` identifies a program node when available.
`OperationIdentifier` identifies a resolved standard operation.

`Dictionary` and `Symbol` identify an encountered OpenMath symbol.
Unknown context uses null.

## Diagnostic codes

`SourceNull` means that a nullable nonthrowing source was null.
`SourceEmpty` means that the source had no document bytes or characters.
`ProgramNull` means that program preflight received null.

`DocumentCharacterLimitExceeded` and `DocumentByteLimitExceeded` identify
document size limits. `NodeLimitExceeded`, `OutputLimitExceeded`, and
`ValueElementLimitExceeded` identify semantic count limits.

`InvalidUtf8` identifies malformed UTF-8. `UnsupportedEncoding` identifies
another byte encoding or a conflicting declaration.

`InvalidXml` identifies XML well-formedness failure.
`UnsupportedDocumentContent` identifies a comment, processing instruction,
DTD, or disallowed content position. `MissingRoot` identifies an absent
Profile 1 root.

`UnexpectedElement` identifies an element with the wrong expanded name.
`MissingAttribute` identifies a required unqualified attribute.
`UnsupportedAttribute` identifies an extra unqualified attribute.
`UnsupportedAttributeNamespace` identifies a qualified profile attribute.

`UnsupportedOpenMathVersion` identifies another OpenMath version.
`UnsupportedContentDictionaryBase` identifies another dictionary base.
`UnsupportedContentDictionaryGroup` identifies another dictionary group.

`InvalidProgramEnvelope` identifies an invalid root program shape.
`InvalidNodeCollection` identifies an invalid node collection or node
envelope. `InvalidNodeIdentifier` identifies a noncanonical node ID.
`InvalidNodeOrder` identifies inconsistent node construction order.

`InvalidInputNode` and `InvalidConstantNode` identify malformed node forms.
`UnsupportedOperationSymbol` identifies an operation outside Profile 1.
`OperationArityMismatch` identifies the wrong operand count.

`InvalidReference` identifies malformed or missing node targets.
`ForwardReference` identifies an operation operand that is not earlier.
`IncompatibleNodeTypes` identifies a typed operation mismatch.
`InvalidOutput` identifies an invalid output declaration.

`UnsupportedType` identifies a type outside Profile 1.
`InvalidUnit` and `InvalidRational` identify unit encoding failures.
`InvalidValueKind` identifies an unsupported value-kind symbol.

`InvalidValue` identifies invalid value content.
`InvalidShape` identifies matrix shape or element-count failure.
`InvalidBinary64` identifies a malformed hexadecimal binary64 value.
`NonfiniteBinary64` identifies an infinity or NaN value.

`OperationOutsideProfile` identifies a custom operation during export
preflight. `InvalidProgramNodeOrder` identifies an invalid program graph.
`UnsupportedProgramNodeKind` identifies an unknown program node kind.

`InvalidProgramName`, `InvalidProgramType`, and `InvalidProgramConstant`
identify export failures in those program fields.
`InvalidProgramOutput` identifies an invalid output target.
`InvalidProgram` identifies another program-level failure.

`NoncanonicalSourceRequired` means that valid input did not have the required
canonical form.

## Validation

`Validate` and `ValidateUtf8` perform complete semantic validation. They do
not retain the imported program.

A valid result has `Canonical` or `Noncanonical` canonicality. An invalid
result has `NotApplicable` canonicality and one diagnostic.

A noncanonical result reports the zero-based first difference. The difference
unit is `Character` or `Byte`.

`ValidateProgram` checks whether Profile 1 can export a program. It creates no
complete output document.

## Normalization

`Normalize` and `NormalizeUtf8` import and then export one document. They do
not simplify the program.

Stream and text normalization parse the complete source before output starts.
A document failure leaves the destination unchanged.

Source and destination streams must be different objects. This check occurs
before input starts.

Normalization leaves all caller-owned endpoints open. An output I/O failure
can leave partial canonical output.

## Profile discovery

`MathBlockOpenMath.Profile` is one immutable descriptor. It exposes the
standard version, profile version, media type, dictionary URIs, and canonical
algorithm.

`Profile.Operations` has exactly 337 entries in standard catalog order. Each
entry binds the exact `MathBlockCatalog.Standard` operation instance.

`TryGetOperationSymbol` accepts only an exact standard operation instance. A
custom operation with a copied identity does not resolve.

`TryGetOperation` resolves one exact Profile 1 operation symbol. Unknown or
default symbols do not resolve.

`Profile.Artifacts` describes the four content dictionaries, group, schema,
and profile README. Each entry includes its path, length, SHA-256, and normative
state.

The embedded profile README still identifies version 0.4.0. Profile 1 became
immutable in that release, so version 0.4.1 does not rewrite the artifact.

`OpenRead` returns a new read-only stream at position zero. It reads embedded
bytes and does not use an installation path or network request.

## Security boundary

MathBlocks uses a forward-only XML reader. It prohibits DTD processing and has
no XML resolver.

The importer does not retrieve schemas, dictionaries, entities, or references.
It performs no network access.

References can target only earlier nodes in the same document. Profile 1 does
not resolve external URIs.

Apply smaller import limits when source trust is low. The node, output, and
value limits stop semantic growth independently of the document limit.

Use `RequireCanonicalSource` before signature or hash verification. A normal
import intentionally accepts equivalent noncanonical XML.

Do not log source documents through diagnostics. Diagnostics contain no source
excerpt, but application logging policy remains the caller's responsibility.

## Thread safety and ownership

Static calls support independent concurrent use. Profile metadata is immutable
after its first initialization.

The library creates one immutable option snapshot per call. It does not change
global parser or writer settings.

The library disposes only its own wrappers, XML objects, and temporary buffers.
It leaves caller-owned streams, readers, writers, and buffer writers open.

## HTTP use

HTTP content should use this content type.

```text
application/openmath+xml; charset=utf-8
```

The core package does not create HTTP clients. Callers own timeouts, retries,
credentials, response limits, and transport validation.

```csharp
using var response = await httpClient.GetAsync(
    uri,
    HttpCompletionOption.ResponseHeadersRead,
    cancellationToken);
response.EnsureSuccessStatusCode();

await using var content = await response.Content.ReadAsStreamAsync(cancellationToken);
var imported = await MathBlockOpenMath.ReadUtf8Async(
    content,
    new MathBlockOpenMathImportOptions
    {
        MaximumDocumentBytes = 4 * 1024 * 1024,
        MaximumNodes = 50_000
    },
    cancellationToken);
```
