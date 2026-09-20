using System.Globalization;
using System.Text;
using System.Xml;
using Supprocom.MathBlocks;

const string contentDictionaryNamespace = "http://www.openmath.org/OpenMathCD";
const string contentDictionaryGroupNamespace = "http://www.openmath.org/OpenMathCDG";
const string mappingNamespace = "https://supprocom.github.io/MathBlocks/formula-mapping/1";
const string date = "2026-09-20";
const string reviewDate = "2031-09-20";

if (args.Length == 0 || args.Length % 2 != 0)
{
    Console.Error.WriteLine("Use paired formula profile generator options.");
    return 2;
}

string? outputOption = null;
string? openMathSampleOption = null;
string? mathMlSampleOption = null;
for (var index = 0; index < args.Length; index += 2)
{
    switch (args[index])
    {
        case "--output":
            outputOption = args[index + 1];
            break;
        case "--openmath-sample":
            openMathSampleOption = args[index + 1];
            break;
        case "--mathml-sample":
            mathMlSampleOption = args[index + 1];
            break;
        default:
            Console.Error.WriteLine($"The formula profile generator option '{args[index]}' is not supported.");
            return 2;
    }
}

if (outputOption is null)
{
    Console.Error.WriteLine("The --output option is required.");
    return 2;
}

var outputDirectory = Path.GetFullPath(outputOption);
Directory.CreateDirectory(outputDirectory);

WriteContentDictionary(
    "mathblocks_formula1",
    "This content dictionary defines exact MathBlocks annotations for interoperable formula expressions.",
    [
        new(
            "profile1",
            "attribution",
            "This attribution contains the canonical MathBlocks OpenMath Profile 1 program for the selected formula output.")
    ]);

var operationDefinitions = MathBlockCatalog.Standard.Operations
    .Select(operation => new SymbolDefinition(
        OperationSymbolName(operation),
        "application",
        $"This application identifies exact MathBlocks operation {operation.Identity}. It requires {operation.Arity} ordered arguments."))
    .OrderBy(definition => definition.Name, StringComparer.Ordinal)
    .ToArray();
WriteContentDictionary(
    "mathblocks_formula_operations1",
    "This content dictionary provides exact extension symbols for every operation in the MathBlocks 0.5.0 standard catalog.",
    operationDefinitions);

WriteContentDictionary(
    "mathblocks_formula_values1",
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
    ]);

WriteContentDictionaryGroup();
WriteMappings();
var sample = CreateSampleProgram();
if (openMathSampleOption is not null)
{
    WriteSample(
        openMathSampleOption,
        MathBlockFormulaInterchange.Export(
            sample,
            "result",
            MathBlockFormulaFormat.OpenMath));
}
if (mathMlSampleOption is not null)
{
    WriteSample(
        mathMlSampleOption,
        MathBlockFormulaInterchange.Export(
            sample,
            "result",
            MathBlockFormulaFormat.ContentMathMl));
}

Console.WriteLine($"Generated Formula Interchange Profile 1 in '{outputDirectory}'.");
return 0;

void WriteContentDictionary(
    string name,
    string description,
    IReadOnlyList<SymbolDefinition> definitions)
{
    var path = Path.Combine(outputDirectory, string.Concat(name, ".ocd"));
    using var writer = CreateWriter(path);
    writer.WriteStartDocument();
    writer.WriteStartElement("CD", contentDictionaryNamespace);
    writer.WriteAttributeString("version", MathBlockFormulaInterchange.OpenMathVersion);
    WriteElement(writer, "CDName", name);
    WriteElement(writer, "CDBase", MathBlockFormulaInterchange.ContentDictionaryBase);
    WriteElement(
        writer,
        "CDURL",
        string.Concat(MathBlockFormulaInterchange.ContentDictionaryBase, "/", name, ".ocd"));
    WriteElement(writer, "CDReviewDate", reviewDate);
    WriteElement(writer, "CDStatus", "private");
    WriteElement(writer, "CDDate", date);
    WriteElement(writer, "CDVersion", MathBlockFormulaInterchange.ProfileVersion);
    WriteElement(writer, "CDRevision", "0");
    WriteElement(writer, "Description", description);

    for (var index = 0; index < definitions.Count; index++)
    {
        var definition = definitions[index];
        writer.WriteStartElement("CDDefinition", contentDictionaryNamespace);
        WriteElement(writer, "Name", definition.Name);
        WriteElement(writer, "Role", definition.Role);
        WriteElement(writer, "Description", definition.Description);
        writer.WriteEndElement();
    }

    writer.WriteEndElement();
    writer.WriteEndDocument();
}

void WriteContentDictionaryGroup()
{
    var path = Path.Combine(outputDirectory, "mathblocks_formula_profile1.cdg");
    using var writer = CreateWriter(path);
    writer.WriteStartDocument();
    writer.WriteStartElement("CDGroup", contentDictionaryGroupNamespace);
    writer.WriteAttributeString("version", MathBlockFormulaInterchange.OpenMathVersion);
    WriteGroupElement(writer, "CDGroupName", "mathblocks_formula_profile1");
    WriteGroupElement(writer, "CDGroupVersion", MathBlockFormulaInterchange.ProfileVersion);
    WriteGroupElement(writer, "CDGroupRevision", "0");
    WriteGroupElement(writer, "CDGroupURL", MathBlockFormulaInterchange.ContentDictionaryGroup);
    WriteGroupElement(
        writer,
        "CDGroupDescription",
        "This group defines lossless MathBlocks formula expressions in OpenMath and Strict Content MathML.");

    foreach (var name in new[]
             {
                 "mathblocks_formula1",
                 "mathblocks_formula_operations1",
                 "mathblocks_formula_values1"
             })
    {
        writer.WriteStartElement("CDGroupMember", contentDictionaryGroupNamespace);
        WriteGroupElement(writer, "CDName", name);
        WriteGroupElement(writer, "CDVersion", MathBlockFormulaInterchange.ProfileVersion);
        WriteGroupElement(
            writer,
            "CDURL",
            string.Concat(MathBlockFormulaInterchange.ContentDictionaryBase, "/", name, ".ocd"));
        writer.WriteEndElement();
    }

    foreach (var member in new[]
             {
                 new OfficialDictionaryMember("arith1", "3"),
                 new OfficialDictionaryMember("complex1", "3"),
                 new OfficialDictionaryMember("logic1", "4"),
                 new OfficialDictionaryMember("relation1", "3"),
                 new OfficialDictionaryMember("rounding1", "3"),
                 new OfficialDictionaryMember("transc1", "3")
             })
    {
        writer.WriteStartElement("CDGroupMember", contentDictionaryGroupNamespace);
        WriteGroupElement(writer, "CDName", member.Name);
        WriteGroupElement(writer, "CDVersion", member.Version);
        WriteGroupElement(
            writer,
            "CDURL",
            string.Concat("http://www.openmath.org/cd/", member.Name, ".ocd"));
        writer.WriteEndElement();
    }

    writer.WriteEndElement();
    writer.WriteEndDocument();
}

void WriteMappings()
{
    var path = Path.Combine(outputDirectory, "mathblocks_formula_mappings1.xml");
    using var writer = CreateWriter(path);
    writer.WriteStartDocument();
    writer.WriteStartElement("operation-mappings", mappingNamespace);
    writer.WriteAttributeString("profile", MathBlockFormulaInterchange.ProfileVersion);
    writer.WriteAttributeString("openmath", MathBlockFormulaInterchange.OpenMathVersion);
    writer.WriteAttributeString("content-mathml", MathBlockFormulaInterchange.ContentMathMlVersion);
    writer.WriteAttributeString("count", MathBlockFormulaInterchange.Profile.Operations.Count
        .ToString(CultureInfo.InvariantCulture));
    writer.WriteAttributeString("fingerprint", MathBlockFormulaInterchange.Profile.Fingerprint);
    foreach (var mapping in MathBlockFormulaInterchange.Profile.Operations)
    {
        writer.WriteStartElement("operation", mappingNamespace);
        writer.WriteAttributeString("identity", mapping.Identity);
        writer.WriteAttributeString("arity", mapping.Arity.ToString(CultureInfo.InvariantCulture));
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

XmlWriter CreateWriter(string path) => XmlWriter.Create(
    path,
    new XmlWriterSettings
    {
        Encoding = new UTF8Encoding(false),
        Indent = true,
        NewLineChars = "\n",
        NewLineHandling = NewLineHandling.None
    });

void WriteElement(XmlWriter writer, string name, string value)
{
    writer.WriteStartElement(name, contentDictionaryNamespace);
    writer.WriteString(value);
    writer.WriteEndElement();
}

void WriteGroupElement(XmlWriter writer, string name, string value)
{
    writer.WriteStartElement(name, contentDictionaryGroupNamespace);
    writer.WriteString(value);
    writer.WriteEndElement();
}

static string OperationSymbolName(MathBlockOperation operation) =>
    string.Concat(
        "op.",
        operation.Identifier,
        ".v",
        operation.Version.ToString(CultureInfo.InvariantCulture));

static MathBlockProgram CreateSampleProgram()
{
    var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
    var left = builder.Input("left", MathBlockType.Scalar());
    var right = builder.Input("right", MathBlockType.Scalar());
    var sum = builder.Apply("scalar.add", inputs: [left, right]);
    var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
    var result = builder.Apply("scalar.softplus", inputs: [square]);
    return builder.Output("result", result).Build();
}

static void WriteSample(string sourcePath, string source)
{
    var path = Path.GetFullPath(sourcePath);
    var directory = Path.GetDirectoryName(path) ??
        throw new InvalidOperationException("The sample path has no directory.");
    Directory.CreateDirectory(directory);
    File.WriteAllText(path, source, new UTF8Encoding(false));
}

internal sealed record SymbolDefinition(string Name, string Role, string Description);

internal sealed record OfficialDictionaryMember(string Name, string Version);
