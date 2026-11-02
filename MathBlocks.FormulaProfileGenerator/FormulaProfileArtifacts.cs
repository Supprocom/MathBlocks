using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Xml;
using Supprocom.MathBlocks;

namespace MathBlocks.FormulaProfileGenerator;

/// <summary>Creates the generated artifacts of one Formula Interchange profile version.</summary>
internal static class FormulaProfileArtifacts
{
    private const string ContentDictionaryNamespace = "http://www.openmath.org/OpenMathCD";
    private const string ContentDictionaryGroupNamespace = "http://www.openmath.org/OpenMathCDG";
    private const string MappingNamespacePrefix = "https://supprocom.github.io/MathBlocks/formula-mapping/";
    private const string PublishedBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/formula/v";

    private static readonly (string Name, string Version)[] OfficialDictionaries =
    [
        ("arith1", "3"),
        ("complex1", "3"),
        ("logic1", "4"),
        ("relation1", "3"),
        ("rounding1", "3"),
        ("transc1", "3")
    ];

    /// <summary>Gets the operation mappings of a profile version at generation time.</summary>
    /// <remarks>
    /// Profile 1 is its published descriptor. Profile 2 maps every operation of the standard
    /// catalog without the Profile 2 descriptor, so that the artifacts can be generated before
    /// its hash locks are updated: an operation keeps its Profile 1 public content-dictionary
    /// symbol, and every other operation gets a symbol in mathblocks_formula_operations2.
    /// </remarks>
    internal static GeneratedMapping[] Mappings(int version)
    {
        if (version == 1)
        {
            return
            [
                .. MathBlockFormulaInterchange.Profile.Operations.Select(mapping => new GeneratedMapping(
                    mapping.Operation,
                    mapping.Classification,
                    mapping.Kind,
                    mapping.Symbol))
            ];
        }
        ArgumentOutOfRangeException.ThrowIfNotEqual(version, 2);
        return Mappings(version, MathBlockCatalog.Standard.Operations);
    }

    /// <summary>Maps operations for a profile version above 1 by the Profile 2 rule.</summary>
    internal static GeneratedMapping[] Mappings(
        int version,
        IReadOnlyList<MathBlockOperation> operations)
    {
        var official = new Dictionary<string, MathBlockFormulaSymbol>(StringComparer.Ordinal);
        foreach (var mapping in MathBlockFormulaInterchange.Profile.Operations)
        {
            if (mapping.Kind == MathBlockFormulaMappingKind.OfficialContentDictionary)
                official.Add(mapping.Identity, mapping.Symbol);
        }
        var suffix = version.ToString(CultureInfo.InvariantCulture);
        var contentDictionaryBase = string.Concat(PublishedBase, suffix);
        var operationDictionary = string.Concat("mathblocks_formula_operations", suffix);
        var result = new GeneratedMapping[operations.Count];
        for (var index = 0; index < result.Length; index++)
        {
            var operation = operations[index];
            result[index] = official.TryGetValue(operation.Identity, out var symbol)
                ? new GeneratedMapping(
                    operation,
                    MathBlockFormulaMappingClassification.DirectMapping,
                    MathBlockFormulaMappingKind.OfficialContentDictionary,
                    symbol)
                : new GeneratedMapping(
                    operation,
                    MathBlockFormulaMappingClassification.DirectMapping,
                    MathBlockFormulaMappingKind.MathBlocksExtension,
                    new MathBlockFormulaSymbol(
                        contentDictionaryBase,
                        operationDictionary,
                        OperationSymbolName(operation)));
        }
        return result;
    }

    /// <summary>Computes the ordered mapping fingerprint that the runtime descriptor publishes.</summary>
    internal static string Fingerprint(int version, IReadOnlyList<GeneratedMapping> mappings)
    {
        var source = new StringBuilder();
        source
            .Append("mathblocks-formula-profile-")
            .Append(version.ToString(CultureInfo.InvariantCulture))
            .Append('\n');
        foreach (var mapping in mappings)
        {
            source
                .Append(mapping.Operation.Identity).Append('|')
                .Append(((int)mapping.Classification).ToString(CultureInfo.InvariantCulture)).Append('|')
                .Append(((int)mapping.Kind).ToString(CultureInfo.InvariantCulture)).Append('|')
                .Append(mapping.Symbol.ContentDictionaryBase).Append('|')
                .Append(mapping.Symbol.Dictionary).Append('|')
                .Append(mapping.Symbol.Name).Append('\n');
        }
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(source.ToString())));
    }

    /// <summary>Creates the five generated artifacts of a profile version.</summary>
    internal static GeneratedArtifact[] Create(
        int version,
        IReadOnlyList<GeneratedMapping> mappings)
    {
        var text = ProfileText.For(version);
        var suffix = version.ToString(CultureInfo.InvariantCulture);
        var context = new DictionaryContext(string.Concat(PublishedBase, suffix), suffix, text);
        var formulaDictionary = string.Concat("mathblocks_formula", suffix);
        var operationDictionary = string.Concat("mathblocks_formula_operations", suffix);
        var valueDictionary = string.Concat("mathblocks_formula_values", suffix);
        var artifacts = new List<GeneratedArtifact>
        {
            CreateContentDictionary(
                context,
                formulaDictionary,
                "This content dictionary defines exact MathBlocks annotations for interoperable formula expressions.",
                [
                    new(
                        string.Concat("profile", suffix),
                        "attribution",
                        string.Format(
                            CultureInfo.InvariantCulture,
                            "This attribution contains the canonical MathBlocks OpenMath Profile {0} program for the selected formula output.",
                            suffix))
                ])
        };

        var operationDefinitions = mappings
            .Select(mapping => new SymbolDefinition(
                OperationSymbolName(mapping.Operation),
                "application",
                string.Format(
                    CultureInfo.InvariantCulture,
                    "This application identifies exact MathBlocks operation {0}. It requires {1} ordered arguments.",
                    mapping.Operation.Identity,
                    mapping.Operation.Arity)))
            .OrderBy(definition => definition.Name, StringComparer.Ordinal)
            .ToArray();
        artifacts.Add(CreateContentDictionary(
            context,
            operationDictionary,
            text.OperationDictionaryDescription,
            operationDefinitions));

        artifacts.Add(CreateContentDictionary(
            context,
            valueDictionary,
            "This content dictionary defines exact structured constants in MathBlocks formula expressions.",
            [
                new("vector", "application", "An ordered vector of binary64 values."),
                new("matrix", "application", "A row count, column count, and row-major binary64 matrix values."),
                new("complex", "application", "Real and imaginary binary64 components."),
                new("complex-vector", "application", "An ordered vector of complex values."),
                new("complex-matrix", "application", "A row count, column count, and row-major complex matrix values."),
                new("point-set", "application", "An ordered collection of two-dimensional points."),
                new("point", "application", "Two binary64 coordinates."),
                new("graph", "application", "A vertex count and ordered directed weighted edges."),
                new("edge", "application", "Source, target, and binary64 edge weight."),
                new("run-set", "application", "An ordered collection of runs."),
                new("run", "application", "Start, length, and binary64 run value."),
                new("boolean-vector", "application", "An ordered vector of Boolean values."),
                new("true", "constant", "The Boolean true value."),
                new("false", "constant", "The Boolean false value.")
            ]));

        artifacts.Add(CreateContentDictionaryGroup(
            context,
            [formulaDictionary, operationDictionary, valueDictionary]));
        artifacts.Add(CreateMappings(context, mappings, Fingerprint(version, mappings)));
        return [.. artifacts];
    }

    private static GeneratedArtifact CreateContentDictionary(
        DictionaryContext context,
        string name,
        string description,
        IReadOnlyList<SymbolDefinition> definitions)
    {
        using var stream = new MemoryStream();
        using (var writer = CreateWriter(stream))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("CD", ContentDictionaryNamespace);
            writer.WriteAttributeString("version", MathBlockFormulaInterchange.OpenMathVersion);
            WriteElement(writer, ContentDictionaryNamespace, "CDName", name);
            WriteElement(writer, ContentDictionaryNamespace, "CDBase", context.ContentDictionaryBase);
            WriteElement(
                writer,
                ContentDictionaryNamespace,
                "CDURL",
                string.Concat(context.ContentDictionaryBase, "/", name, ".ocd"));
            WriteElement(writer, ContentDictionaryNamespace, "CDReviewDate", context.Text.ReviewDate);
            WriteElement(writer, ContentDictionaryNamespace, "CDStatus", "private");
            WriteElement(writer, ContentDictionaryNamespace, "CDDate", context.Text.Date);
            WriteElement(writer, ContentDictionaryNamespace, "CDVersion", context.Version);
            WriteElement(writer, ContentDictionaryNamespace, "CDRevision", "0");
            WriteElement(writer, ContentDictionaryNamespace, "Description", description);

            for (var index = 0; index < definitions.Count; index++)
            {
                var definition = definitions[index];
                writer.WriteStartElement("CDDefinition", ContentDictionaryNamespace);
                WriteElement(writer, ContentDictionaryNamespace, "Name", definition.Name);
                WriteElement(writer, ContentDictionaryNamespace, "Role", definition.Role);
                WriteElement(writer, ContentDictionaryNamespace, "Description", definition.Description);
                writer.WriteEndElement();
            }

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
        return new GeneratedArtifact(string.Concat(name, ".ocd"), stream.ToArray());
    }

    private static GeneratedArtifact CreateContentDictionaryGroup(
        DictionaryContext context,
        IReadOnlyList<string> members)
    {
        var name = string.Concat("mathblocks_formula_profile", context.Version);
        using var stream = new MemoryStream();
        using (var writer = CreateWriter(stream))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("CDGroup", ContentDictionaryGroupNamespace);
            writer.WriteAttributeString("version", MathBlockFormulaInterchange.OpenMathVersion);
            WriteElement(writer, ContentDictionaryGroupNamespace, "CDGroupName", name);
            WriteElement(writer, ContentDictionaryGroupNamespace, "CDGroupVersion", context.Version);
            WriteElement(writer, ContentDictionaryGroupNamespace, "CDGroupRevision", "0");
            WriteElement(
                writer,
                ContentDictionaryGroupNamespace,
                "CDGroupURL",
                string.Concat(context.ContentDictionaryBase, "/", name, ".cdg"));
            WriteElement(
                writer,
                ContentDictionaryGroupNamespace,
                "CDGroupDescription",
                "This group defines lossless MathBlocks formula expressions in OpenMath and Strict Content MathML.");

            foreach (var member in members)
            {
                writer.WriteStartElement("CDGroupMember", ContentDictionaryGroupNamespace);
                WriteElement(writer, ContentDictionaryGroupNamespace, "CDName", member);
                WriteElement(writer, ContentDictionaryGroupNamespace, "CDVersion", context.Version);
                WriteElement(
                    writer,
                    ContentDictionaryGroupNamespace,
                    "CDURL",
                    string.Concat(context.ContentDictionaryBase, "/", member, ".ocd"));
                writer.WriteEndElement();
            }

            foreach (var (memberName, memberVersion) in OfficialDictionaries)
            {
                writer.WriteStartElement("CDGroupMember", ContentDictionaryGroupNamespace);
                WriteElement(writer, ContentDictionaryGroupNamespace, "CDName", memberName);
                WriteElement(writer, ContentDictionaryGroupNamespace, "CDVersion", memberVersion);
                WriteElement(
                    writer,
                    ContentDictionaryGroupNamespace,
                    "CDURL",
                    string.Concat("http://www.openmath.org/cd/", memberName, ".ocd"));
                writer.WriteEndElement();
            }

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
        return new GeneratedArtifact(string.Concat(name, ".cdg"), stream.ToArray());
    }

    private static GeneratedArtifact CreateMappings(
        DictionaryContext context,
        IReadOnlyList<GeneratedMapping> mappings,
        string fingerprint)
    {
        var mappingNamespace = string.Concat(MappingNamespacePrefix, context.Version);
        using var stream = new MemoryStream();
        using (var writer = CreateWriter(stream))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("operation-mappings", mappingNamespace);
            writer.WriteAttributeString("profile", context.Version);
            writer.WriteAttributeString("openmath", MathBlockFormulaInterchange.OpenMathVersion);
            writer.WriteAttributeString("content-mathml", MathBlockFormulaInterchange.ContentMathMlVersion);
            writer.WriteAttributeString("count", mappings.Count.ToString(CultureInfo.InvariantCulture));
            writer.WriteAttributeString("fingerprint", fingerprint);
            foreach (var mapping in mappings)
            {
                writer.WriteStartElement("operation", mappingNamespace);
                writer.WriteAttributeString("identity", mapping.Operation.Identity);
                writer.WriteAttributeString(
                    "arity",
                    mapping.Operation.Arity.ToString(CultureInfo.InvariantCulture));
                writer.WriteAttributeString(
                    "classification",
                    mapping.Classification switch
                    {
                        MathBlockFormulaMappingClassification.DirectMapping => "direct-mapping",
                        MathBlockFormulaMappingClassification.CanonicalPatternMapping =>
                            "canonical-pattern-mapping",
                        MathBlockFormulaMappingClassification.Unsupported => "unsupported",
                        _ => throw new InvalidOperationException(
                            "The formula mapping classification is invalid.")
                    });
                writer.WriteAttributeString(
                    "kind",
                    mapping.Kind == MathBlockFormulaMappingKind.OfficialContentDictionary
                        ? "official"
                        : "mathblocks-extension");
                writer.WriteAttributeString("cdbase", mapping.Symbol.ContentDictionaryBase);
                writer.WriteAttributeString("cd", mapping.Symbol.Dictionary);
                writer.WriteAttributeString("name", mapping.Symbol.Name);
                writer.WriteEndElement();
            }
            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
        return new GeneratedArtifact(
            string.Concat("mathblocks_formula_mappings", context.Version, ".xml"),
            stream.ToArray());
    }

    private static XmlWriter CreateWriter(Stream stream) => XmlWriter.Create(
        stream,
        new XmlWriterSettings
        {
            Encoding = new UTF8Encoding(false),
            Indent = true,
            NewLineChars = "\n",
            NewLineHandling = NewLineHandling.None
        });

    private static void WriteElement(XmlWriter writer, string ns, string name, string value)
    {
        writer.WriteStartElement(name, ns);
        writer.WriteString(value);
        writer.WriteEndElement();
    }

    private static string OperationSymbolName(MathBlockOperation operation) =>
        string.Concat(
            "op.",
            operation.Identifier,
            ".v",
            operation.Version.ToString(CultureInfo.InvariantCulture));

    /// <summary>Holds the human-readable text that differs between profile versions.</summary>
    internal sealed record ProfileText(
        string Date,
        string ReviewDate,
        string OperationDictionaryDescription)
    {
        internal static ProfileText For(int version) => version switch
        {
            1 => new(
                "2026-09-20",
                "2031-09-20",
                "This content dictionary provides exact extension symbols for every operation in the MathBlocks 0.5.0 standard catalog."),
            2 => new(
                "2026-11-02",
                "2031-11-02",
                "This content dictionary provides exact extension symbols for every operation in the MathBlocks 0.6.0 standard catalog."),
            _ => throw new ArgumentOutOfRangeException(nameof(version))
        };
    }

    /// <summary>Contains one operation mapping as the generator writes it.</summary>
    internal sealed record GeneratedMapping(
        MathBlockOperation Operation,
        MathBlockFormulaMappingClassification Classification,
        MathBlockFormulaMappingKind Kind,
        MathBlockFormulaSymbol Symbol);

    /// <summary>Contains one generated artifact file name and its exact bytes.</summary>
    internal sealed record GeneratedArtifact(string Name, byte[] Content);

    private sealed record SymbolDefinition(string Name, string Role, string Description);

    private sealed record DictionaryContext(
        string ContentDictionaryBase,
        string Version,
        ProfileText Text);
}
