# MathBlocks Formula Interchange Profile 2

This directory defines the normative formula-interchange profile introduced by
MathBlocks 0.6.0. It does not modify MathBlocks OpenMath Profile 1 or Formula
Interchange Profile 1.

One document represents one selected output and only the program nodes reachable
from that output. The first mathematical object is a conventional expression
graph. Repeated nodes use OpenMath `OMR` or Content MathML `share` references.

The profile supports two XML vocabularies:

- OpenMath 2.0 Revision 2;
- Strict Content MathML 3.0.

Both vocabularies carry the same content-dictionary symbols. The operation
mapping manifest contains exactly 537 entries in standard-catalog order. An
entry explicitly classifies its representation as `direct-mapping`,
`canonical-pattern-mapping`, or `unsupported`, independently of symbol
provenance. Profile 2 has 537 direct mappings and zero canonical-pattern or
unsupported mappings. A direct mapping uses either a public OpenMath
content-dictionary symbol with exact applicability or an exact symbol from
`mathblocks_formula_operations2`. Every operation keeps the public symbol it
has in Profile 1.

Content MathML identifies the complete dictionary set with the `cdgroup`
attribute on `math`; each strict `csymbol` carries only its `cd` name. The group
contains the three profile dictionaries and all six public OpenMath
dictionaries used by direct mappings. Content MathML sharing uses `share src`,
the strict counterpart of OpenMath `OMR href`.

## Profile selection

`MathBlockFormulaInterchange.Export` writes the lowest profile that contains
every operation reachable from the selected output. A formula that uses only
Profile 1 operations is written in Profile 1. The overloads that take a profile
write the specified profile.

## Exact annotation

The expression is annotated with the canonical MathBlocks OpenMath Profile 2
program for the selected reachable graph. This annotation is authoritative for
MathBlocks binary64 evaluation, types, units, shapes, operation versions, and
the output name.

OpenMath uses the `mathblocks_formula2:profile2` attribution. Content MathML
uses an `annotation` whose encoding is
`application/vnd.supprocom.mathblocks.openmath-profile2+xml`.

An importer verifies the annotation by rebuilding the complete formula and
requiring the canonical document to match. It never silently accepts a visible
expression that differs from its exact annotation.

An independent OpenMath or Content MathML expression can also be imported from
the visible expression when the caller supplies the MathBlocks type of every
free variable and an output name. This path does not require a MathBlocks
annotation. Unannotated numeric constants are dimensionless binary64 values.

## Constants and sharing

Binary64 values use 16 uppercase hexadecimal digits. Content MathML represents
them as `cn` elements with `type="hexdouble"`. OpenMath represents them as
`OMF` elements with the `hex` attribute.

Structured constants use `mathblocks_formula_values2`. Matrix constructors
include their row and column counts. Graph constructors include their vertex
count. Units and exact MathBlocks types remain in the authoritative annotation.

## Security and canonical form

Import is local and deterministic. It does not retrieve content dictionaries,
schemas, or other resources. DTD processing and external entity resolution are
disabled. Comments and processing instructions are unsupported. Only the
published profile groups are resolved locally; an unknown `cdgroup` cannot
change an official symbol's identity unless an explicit supported `cdbase`
resolves that symbol.

The annotation-based Profile 2 importer accepts canonical profile documents
only. Canonical output has no XML declaration, byte-order mark, comments, or
final newline. The explicit-binding compatibility importer accepts independent
serialization while retaining the same document limits, local-only processing,
and supported-expression boundary. Visible expressions are bounded to 16,384
XML elements and 256 expression levels.

## Artifacts

- `mathblocks_formula2.ocd` defines the exact annotation key.
- `mathblocks_formula_operations2.ocd` defines exact extension operations.
- `mathblocks_formula_values2.ocd` defines structured constants.
- `mathblocks_formula_profile2.cdg` binds the profile and public dictionaries.
- `mathblocks_formula_mappings2.xml` maps all 537 operations.
- `mathblocks_formula_mappings2.rnc` defines the mapping-manifest grammar.
- `mathblocks_formula_openmath2.rnc` restricts the OpenMath vocabulary.
- `mathblocks_formula_mathml2.rnc` restricts the Content MathML vocabulary.
