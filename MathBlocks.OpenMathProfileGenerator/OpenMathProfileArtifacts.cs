using System.Globalization;
using System.Text;
using System.Xml;
using Supprocom.MathBlocks;

namespace MathBlocks.OpenMathProfileGenerator;

/// <summary>Creates the generated content dictionaries of one OpenMath profile version.</summary>
internal static class OpenMathProfileArtifacts
{
    private const string ContentDictionaryNamespace = "http://www.openmath.org/OpenMathCD";
    private const string ContentDictionaryGroupNamespace = "http://www.openmath.org/OpenMathCDG";
    private const string PublishedBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v";

    /// <summary>Gets the operations of a profile version at generation time.</summary>
    /// <remarks>
    /// Profile 1 is the frozen operation list of its published descriptor. Profile 2 is every
    /// operation of the standard catalog, read without the Profile 2 descriptor so that the
    /// artifacts can be generated before its hash locks are updated.
    /// </remarks>
    internal static IReadOnlyList<MathBlockOperation> Operations(int version) => version switch
    {
        1 => [.. MathBlockOpenMath.Profile.Operations.Select(definition => definition.Operation)],
        2 => MathBlockCatalog.Standard.Operations,
        _ => throw new ArgumentOutOfRangeException(nameof(version))
    };

    /// <summary>Creates the five generated artifacts of a profile version.</summary>
    internal static GeneratedArtifact[] Create(
        int version,
        IReadOnlyList<MathBlockOperation> operations)
    {
        var text = ProfileText.For(version);
        var suffix = version.ToString(CultureInfo.InvariantCulture);
        var contentDictionaryBase = string.Concat(PublishedBase, suffix);
        var programDictionary = string.Concat("mathblocks_program", suffix);
        var operationDictionary = string.Concat("mathblocks_operations", suffix);
        var typeDictionary = string.Concat("mathblocks_types", suffix);
        var valueDictionary = string.Concat("mathblocks_values", suffix);
        var artifacts = new List<GeneratedArtifact>();
        var context = new DictionaryContext(contentDictionaryBase, suffix, text);

        artifacts.Add(CreateContentDictionary(
            context,
            programDictionary,
            "This content dictionary defines the MathBlocks program envelope and its ordered program nodes.",
            [
                new("program", "application", "This application contains one ordered node collection and one ordered output collection."),
                new("nodes", "application", "This application contains program nodes in their canonical order."),
                new("input", "application", "This application defines one named and typed program input."),
                new("constant", "application", "This application defines one typed program constant."),
                new("outputs", "application", "This application contains named program outputs in their canonical order."),
                new("output", "application", "This application defines one named output and its local node reference.")
            ]));

        var operationDefinitions = operations
            .Select(operation => new SymbolDefinition(
                OperationSymbolName(operation),
                "application",
                string.Format(
                    CultureInfo.InvariantCulture,
                    "This application identifies MathBlocks operation {0}. It requires {1} ordered operand references.",
                    operation.Identity,
                    operation.Arity)))
            .OrderBy(definition => definition.Name, StringComparer.Ordinal)
            .ToArray();
        artifacts.Add(CreateContentDictionary(
            context,
            operationDictionary,
            text.OperationDictionaryDescription,
            operationDefinitions));

        artifacts.Add(CreateContentDictionary(
            context,
            typeDictionary,
            "This content dictionary defines MathBlocks value types, shapes, units, and rational dimensions.",
            [
                new("type", "application", "This application defines one MathBlocks value type, unit, row count, and column count."),
                new("scalar", "constant", "This symbol identifies the scalar value kind."),
                new("boolean", "constant", "This symbol identifies the Boolean value kind."),
                new("complex", "constant", "This symbol identifies the complex value kind."),
                new("vector", "constant", "This symbol identifies the vector value kind."),
                new("matrix", "constant", "This symbol identifies the matrix value kind."),
                new("complex-vector", "constant", "This symbol identifies the complex-vector value kind."),
                new("complex-matrix", "constant", "This symbol identifies the complex-matrix value kind."),
                new("point-set", "constant", "This symbol identifies the point-set value kind."),
                new("graph", "constant", "This symbol identifies the graph value kind."),
                new("run-set", "constant", "This symbol identifies the run-set value kind."),
                new("boolean-vector", "constant", "This symbol identifies the Boolean-vector value kind."),
                new("unit", "application", "This application defines the four rational dimensions of a MathBlocks unit."),
                new("rational", "application", "This application defines a normalized integer numerator and a positive denominator.")
            ]));

        artifacts.Add(CreateContentDictionary(
            context,
            valueDictionary,
            "This content dictionary defines exact MathBlocks structured constant values.",
            [
                new("vector", "application", "This application defines an ordered vector of binary64 values."),
                new("matrix", "application", "This application defines a row-major matrix of binary64 values."),
                new("complex", "application", "This application defines one complex value from real and imaginary binary64 values."),
                new("complex-vector", "application", "This application defines an ordered vector of complex values."),
                new("complex-matrix", "application", "This application defines a row-major matrix of complex values."),
                new("point-set", "application", "This application defines an ordered set of two-dimensional points."),
                new("point", "application", "This application defines one two-dimensional point."),
                new("graph", "application", "This application defines a graph vertex count and an ordered edge collection."),
                new("edge", "application", "This application defines one directed weighted graph edge."),
                new("run-set", "application", "This application defines an ordered run collection."),
                new("run", "application", "This application defines one run start, length, and binary64 value."),
                new("boolean-vector", "application", "This application defines an ordered vector of Boolean values."),
                new("true", "constant", "This symbol defines the Boolean true value."),
                new("false", "constant", "This symbol defines the Boolean false value.")
            ]));

        artifacts.Add(CreateContentDictionaryGroup(
            context,
            [programDictionary, operationDictionary, typeDictionary, valueDictionary]));
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
            writer.WriteAttributeString("version", MathBlockOpenMath.StandardVersion);
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
        var name = string.Concat("mathblocks_profile", context.Version);
        using var stream = new MemoryStream();
        using (var writer = CreateWriter(stream))
        {
            writer.WriteStartDocument();
            writer.WriteStartElement("CDGroup", ContentDictionaryGroupNamespace);
            writer.WriteAttributeString("version", MathBlockOpenMath.StandardVersion);
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
                "This group defines the deterministic MathBlocks OpenMath program profile.");

            for (var index = 0; index < members.Count; index++)
            {
                writer.WriteStartElement("CDGroupMember", ContentDictionaryGroupNamespace);
                WriteElement(writer, ContentDictionaryGroupNamespace, "CDName", members[index]);
                WriteElement(writer, ContentDictionaryGroupNamespace, "CDVersion", context.Version);
                WriteElement(
                    writer,
                    ContentDictionaryGroupNamespace,
                    "CDURL",
                    string.Concat(context.ContentDictionaryBase, "/", members[index], ".ocd"));
                writer.WriteEndElement();
            }

            writer.WriteEndElement();
            writer.WriteEndDocument();
        }
        return new GeneratedArtifact(string.Concat(name, ".cdg"), stream.ToArray());
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
                "2026-09-03",
                "2031-09-03",
                "This content dictionary defines the exact operations in the MathBlocks 0.4.0 standard catalog."),
            2 => new(
                "2026-10-31",
                "2031-10-31",
                "This content dictionary defines the exact operations in the MathBlocks 0.6.0 standard catalog."),
            _ => throw new ArgumentOutOfRangeException(nameof(version))
        };
    }

    /// <summary>Contains one generated artifact file name and its exact bytes.</summary>
    internal sealed record GeneratedArtifact(string Name, byte[] Content);

    private sealed record SymbolDefinition(string Name, string Role, string Description);

    private sealed record DictionaryContext(
        string ContentDictionaryBase,
        string Version,
        ProfileText Text);
}
