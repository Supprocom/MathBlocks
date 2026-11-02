# MathBlocks OpenMath Profile 2

This directory defines the normative MathBlocks OpenMath profile for package
version 0.6.0.

The profile uses
[OpenMath 2.0 Revision 2](https://openmath.org/standard/om20-2019-07-01/omstd20.html).
It uses the standard OpenMath XML encoding.

The `mathblocks_profile2.cdg` file is the content dictionary group manifest. It
binds the four profile content dictionaries.

The `mathblocks_profile2.rnc` file is the restricted profile schema. The
normative OpenMath schemas also apply.

## Profile identity

The content dictionaries have OpenMath status `private`. This status means that
Supprocom controls their definitions.

After publication, Profile 2 symbol meanings and identifiers do not change. An
incompatible change requires a new profile and new dictionary names.

Profile 2 does not modify Profile 1. Profile 1 keeps its dictionaries, its
symbols, and its 337 operations.

## Program meaning

One document represents one complete typed `MathBlockProgram`. The document
stores all nodes and outputs in explicit order.

Each operation symbol identifies one exact operation and version. The profile
contains every operation from `MathBlockCatalog.Standard` in MathBlocks 0.6.0.
This includes every Profile 1 operation, under the Profile 2 dictionary names.

Each operation input uses a backward local reference. Therefore, the declared
node sequence defines one deterministic operation order.

The importer does not infer overloaded operations. It does not reorder,
simplify, or replace operations.

## Profile selection

`MathBlockOpenMath.Export` writes a program in the lowest profile that contains
every operation of the program. A program that uses only Profile 1 operations is
written in Profile 1. The overloads that take a profile write the specified
profile.

## Canonical output

`MathBlockOpenMath.Export` performs semantic normalization before XML output. It
preserves nodes, operand order, shared references, constants, units, and
outputs.

The UTF-8 encoding of the returned string conforms to Canonical XML 1.1 without
comments.

The canonicalization algorithm identifier is `http://www.w3.org/2006/12/xml-c14n11`.

Binary64 values use exactly 16 uppercase hexadecimal digits. This form
preserves finite values and negative zero.

A document's canonical form is defined within its own profile. Normalization
keeps the profile of the document.

## Import limits

`MathBlockOpenMath.Import` accepts only Profile 1 and Profile 2 and their
content dictionary groups. It does not retrieve network resources.

The importer rejects documents larger than
`MathBlockOpenMath.MaximumDocumentCharacters`. It prohibits document type
definitions and external entity resolution.

The importer rejects unknown symbols, invalid references, invalid types,
invalid values, comments, and processing instructions. It also rejects a
document that mixes Profile 1 and Profile 2 identifiers.

## Scope

This profile is semantic program notation. It does not define presentation
notation or parse text such as `sin(x) + x^2`.

Custom operations are outside Profile 2. A future profile can define
registry-owned content dictionary identities.
