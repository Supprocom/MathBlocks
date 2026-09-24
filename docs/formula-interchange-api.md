# MathBlocks Formula Interchange API

This guide applies to MathBlocks 0.5.1 and Formula Interchange Profile 1.

The formula API projects one named `MathBlockProgram` output. It includes only
nodes reachable from that output and preserves operand order and shared nodes.
It does not simplify, reorder, evaluate, or infer formulas.

## Supported standards

`MathBlockFormulaFormat.OpenMath` uses
[OpenMath 2.0 Revision 2](https://openmath.org/standard/) XML and media type
`application/openmath+xml`.

`MathBlockFormulaFormat.ContentMathMl` uses
[Strict Content MathML 3.0](https://www.w3.org/TR/MathML3/chapter4.html) and
media type `application/mathml-content+xml`. Strict Content MathML is the
one-to-one Content MathML vocabulary for OpenMath objects:

| OpenMath | Content MathML |
| --- | --- |
| `OMA` | `apply` |
| `OMS` | `csymbol` |
| `OMV` | `ci` |
| `OMF` and `OMI` | `cn` |
| `OMR` | `share` |
| `OMATTR` | `semantics` |

The Content MathML root references the profile content-dictionary group with
`cdgroup`. Strict `csymbol` elements use `cd` names from that group, and shared
nodes use the standard `share src` form. The local resolver recognizes the
published profile group and does not retrieve arbitrary groups. A symbol under
an unknown group is undefined unless an explicit supported `cdbase` resolves it
on compatibility input.

MathML 4 is not the normative target for Profile 1. Documents remain within
the compatible Strict Content MathML core.

## Export and import

```csharp
var source = MathBlockFormulaInterchange.Export(
    program,
    "result",
    MathBlockFormulaFormat.ContentMathMl);

var imported = MathBlockFormulaInterchange.Import(
    source,
    MathBlockFormulaFormat.ContentMathMl);

Console.WriteLine(imported.OutputName);
Console.WriteLine(imported.Program.Fingerprint);
```

`ExportUtf8` returns canonical UTF-8. `GetUtf8ByteCount` and `TryWriteUtf8`
support caller-managed buffers. Character, byte-stream, buffer-writer, and
asynchronous output methods leave caller-owned destinations open.

`ImportUtf8` accepts contiguous or segmented UTF-8. Malformed UTF-8 and a byte
order mark are noncanonical.

To import a formula produced by independent mathematics software, provide the
MathBlocks type of every free variable and choose the output name. This reads
the visible OpenMath or Content MathML expression and does not require the
MathBlocks annotation:

```csharp
var bindings = new Dictionary<string, MathBlockType>
{
    ["x"] = MathBlockType.Scalar()
};

var external = MathBlockFormulaInterchange.Import(
    externalMathMl,
    MathBlockFormulaFormat.ContentMathMl,
    bindings,
    "result");
```

The corresponding contiguous `ImportUtf8` overload accepts the same bindings.
The visible-expression path recognizes strict `csymbol` applications and the
standard Content MathML operator elements used by common producers. It also
accepts decimal or hexadecimal OpenMath floats, resolves local backward `share`
or `OMR` references, and deterministically left-folds n-ary standard
`plus`, `times`, `and`, `or`, and `xor` applications. Unannotated numeric and
structured constants are dimensionless; exact units and types require explicit
input bindings or a verified MathBlocks annotation.

`Read` and `ReadAsync` consume a complete document from a caller-owned
`TextReader`. `ReadUtf8` and `ReadUtf8Async` consume UTF-8 from a caller-owned
stream. All reader and stream methods leave the caller-owned endpoint open.
The asynchronous methods use asynchronous endpoint I/O and accept a
`CancellationToken`.

`TryImport`, `TryImportUtf8`, `TryRead`, and `TryReadUtf8` convert document
`FormatException` failures into one `MathBlockFormulaDiagnostic`. Invalid
formats, cancellation, I/O failures, allocation failures, and implementation
errors still throw.

`Validate` and `ValidateUtf8` perform complete import and annotation
verification without exposing an imported program. `ValidateProgram` verifies
that one named output can be projected and that every reachable operation is
an exact standard-catalog instance.

## Total operation mapping

`MathBlockFormulaInterchange.Profile.Operations` contains exactly 337 entries
in standard-catalog order. Every entry has an explicit mapping classification:

- `DirectMapping` maps one operation application to one content-dictionary
  symbol application.
- `CanonicalPatternMapping` would map one operation to a fixed normative
  expression pattern.
- `Unsupported` identifies a failed vocabulary mapping.

Profile 1 contains 337 `DirectMapping` entries and zero entries in the other
two classifications. Symbol provenance is reported independently by
`MathBlockFormulaMappingKind`:

- `OfficialContentDictionary` uses an established OpenMath symbol whose
  application is exact for the formula projection.
- `MathBlocksExtension` uses the exact, versioned operation symbol from
  `mathblocks_formula_operations1`.

There is no unsupported mapping. If a later standard vocabulary cannot
represent every catalog operation, that vocabulary cannot be advertised as
supported by this profile.

`TryGetOperationMapping` accepts only the exact operation instance from
`MathBlockCatalog.Standard`. A custom operation with a copied identity is not a
standard mapping. `TryGetOperation` performs the reverse symbol lookup.

## Exact semantic annotation

The visible formula is designed for mathematics software. Common operations
use familiar public content dictionaries; domain-specific operations remain
unambiguous extension symbols.

The visible formula is also accompanied by the canonical OpenMath Profile 1
program for the selected reachable graph. This annotation is authoritative for
MathBlocks-specific details that abstract mathematical notation cannot safely
imply:

- binary64 execution and negative zero;
- exact operation versions and operand order;
- value types, units, and shapes;
- structured constants;
- the selected output name.

OpenMath carries this value as the `mathblocks_formula1:profile1` attribution.
Content MathML carries it in an `annotation` with encoding
`application/vnd.supprocom.mathblocks.openmath-profile1+xml`.

Import rebuilds the program from the annotation, regenerates the visible
formula, and requires the complete canonical document to match. A document
whose visible expression disagrees with its exact annotation is rejected.

## Constants and graph sharing

Finite binary64 constants use exactly 16 uppercase hexadecimal digits.
Content MathML uses `cn type="hexdouble"`; OpenMath uses `OMF hex`.

Structured constants use `mathblocks_formula_values1`. Matrix constructors
include their row and column counts, and graph constructors include the vertex
count. Units and full types are retained in the exact annotation.

Every emitted expression node has a deterministic `n0`, `n1`, ... identifier.
Repeated nodes use backward `OMR` or `share` references. The exporter never
duplicates a shared computation.

## Canonical and security boundary

The annotation-based `Import`, `Normalize`, validation, and try-import APIs
accept canonical Profile 1 documents only. `Normalize` therefore verifies and
returns the same canonical representation; `NormalizeUtf8` provides the
corresponding byte path. The explicit-binding `Import` overload is the
compatibility path for independent standards-compliant expressions.

Both import paths have fixed character and byte limits. Visible-expression
import additionally buffers at most 16,384 XML elements and accepts at most 256
expression levels. XML parsing prohibits DTDs and external entity resolution,
and performs no content-dictionary, schema, or network retrieval. Unknown
dictionary groups are never treated as the official OpenMath base. Both paths
reject comments, processing instructions, unknown operations, and custom
operation implementations. The annotation-based path additionally rejects
missing or duplicate annotations and every noncanonical document. The
explicit-binding path accepts compatible external serialization but still
requires one supported, type-correct expression.

The API is notation only. It does not own file access, network transport,
computer-algebra execution, formula search, or document management.

## Diagnostic codes

Stable codes distinguish null or empty sources, character and byte limits,
malformed UTF-8 or XML, unsupported XML content, missing or duplicate exact
annotations, invalid annotations, visible-expression disagreement, null or
invalid programs, missing outputs, and operations outside the profile.

Diagnostic messages never include source excerpts or annotation contents.
