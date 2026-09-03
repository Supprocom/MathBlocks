# MathBlocks OpenMath Profile 1

This directory defines the normative MathBlocks OpenMath profile for package
version 0.4.0.

The profile uses
[OpenMath 2.0 Revision 2](https://openmath.org/standard/om20-2019-07-01/omstd20.html).
It uses the standard OpenMath XML encoding.

The `mathblocks_profile1.cdg` file is the content dictionary group manifest. It
binds the four profile content dictionaries.

The `mathblocks_profile1.rnc` file is the restricted profile schema. The
normative OpenMath schemas also apply.

## Profile identity

The content dictionaries have OpenMath status `private`. This status means that
Supprocom controls their definitions.

After publication, Profile 1 symbol meanings and identifiers do not change. An
incompatible change requires a new profile and new dictionary names.

## Program meaning

One document represents one complete typed `MathBlockProgram`. The document
stores all nodes and outputs in explicit order.

Each operation symbol identifies one exact operation and version. The profile
contains only operations from `MathBlockCatalog.Standard` in MathBlocks 0.4.0.

Each operation input uses a backward local reference. Therefore, the declared
node sequence defines one deterministic operation order.

The importer does not infer overloaded operations. It does not reorder,
simplify, or replace operations.

## Canonical output

`MathBlockOpenMath.Export` performs semantic normalization before XML output. It
preserves nodes, operand order, shared references, constants, units, and
outputs.

The UTF-8 encoding of the returned string conforms to Canonical XML 1.1 without
comments.

The canonicalization algorithm identifier is `http://www.w3.org/2006/12/xml-c14n11`.

Binary64 values use exactly 16 uppercase hexadecimal digits. This form
preserves finite values and negative zero.

## Import limits

`MathBlockOpenMath.Import` accepts only this profile and its content dictionary
group. It does not retrieve network resources.

The importer rejects documents larger than
`MathBlockOpenMath.MaximumDocumentCharacters`. It prohibits document type
definitions and external entity resolution.

The importer rejects unknown symbols, invalid references, invalid types,
invalid values, comments, and processing instructions.

## Scope

This profile is semantic program notation. It does not define presentation
notation or parse text such as `sin(x) + x^2`.

Custom operations are outside Profile 1. A future profile can define
registry-owned content dictionary identities.
