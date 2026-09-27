using System.Globalization;
using System.Text;
using System.Xml;
using Supprocom.MathBlocks;

const string contentDictionaryNamespace = "http://www.openmath.org/OpenMathCD";
const string contentDictionaryGroupNamespace = "http://www.openmath.org/OpenMathCDG";
const string date = "2026-09-03";
const string reviewDate = "2031-09-03";

if (args.Length == 0 || args.Length % 2 != 0)
{
    Console.Error.WriteLine("Use paired profile generator options.");
    return 2;
}

string? outputOption = null;
string? sampleOption = null;
string? catalogSampleOption = null;
for (var index = 0; index < args.Length; index += 2)
{
    switch (args[index])
    {
        case "--output":
            outputOption = args[index + 1];
            break;
        case "--sample":
            sampleOption = args[index + 1];
            break;
        case "--catalog-sample":
            catalogSampleOption = args[index + 1];
            break;
        default:
            Console.Error.WriteLine($"The profile generator option '{args[index]}' is not supported.");
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
    "mathblocks_program1",
    "This content dictionary defines the MathBlocks program envelope and its ordered program nodes.",
    [
        new("program", "application", "This application contains one ordered node collection and one ordered output collection."),
        new("nodes", "application", "This application contains program nodes in their canonical order."),
        new("input", "application", "This application defines one named and typed program input."),
        new("constant", "application", "This application defines one typed program constant."),
        new("outputs", "application", "This application contains named program outputs in their canonical order."),
        new("output", "application", "This application defines one named output and its local node reference.")
    ]);

var operationDefinitions = MathBlockCatalog.Standard.Operations
    .Select(operation => new SymbolDefinition(
        OperationSymbolName(operation),
        "application",
        $"This application identifies MathBlocks operation {operation.Identity}. It requires {operation.Arity} ordered operand references."))
    .OrderBy(definition => definition.Name, StringComparer.Ordinal)
    .ToArray();
WriteContentDictionary(
    "mathblocks_operations1",
    "This content dictionary defines the exact operations in the MathBlocks 0.4.0 standard catalog.",
    operationDefinitions);

WriteContentDictionary(
    "mathblocks_types1",
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
    ]);

WriteContentDictionary(
    "mathblocks_values1",
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
    ]);

WriteContentDictionaryGroup();

if (sampleOption is not null)
    WriteSample(sampleOption, CreateSampleProgram());
if (catalogSampleOption is not null)
    WriteSample(catalogSampleOption, CreateCatalogSampleProgram());

Console.WriteLine($"Generated the MathBlocks OpenMath profile in '{outputDirectory}'.");
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
    writer.WriteAttributeString("version", MathBlockOpenMath.StandardVersion);
    WriteElement(writer, "CDName", name);
    WriteElement(writer, "CDBase", MathBlockOpenMath.ContentDictionaryBase);
    WriteElement(
        writer,
        "CDURL",
        string.Concat(MathBlockOpenMath.ContentDictionaryBase, "/", name, ".ocd"));
    WriteElement(writer, "CDReviewDate", reviewDate);
    WriteElement(writer, "CDStatus", "private");
    WriteElement(writer, "CDDate", date);
    WriteElement(writer, "CDVersion", MathBlockOpenMath.ProfileVersion);
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
    var path = Path.Combine(outputDirectory, "mathblocks_profile1.cdg");
    using var writer = CreateWriter(path);
    writer.WriteStartDocument();
    writer.WriteStartElement("CDGroup", contentDictionaryGroupNamespace);
    writer.WriteAttributeString("version", MathBlockOpenMath.StandardVersion);
    WriteGroupElement(writer, "CDGroupName", "mathblocks_profile1");
    WriteGroupElement(writer, "CDGroupVersion", MathBlockOpenMath.ProfileVersion);
    WriteGroupElement(writer, "CDGroupRevision", "0");
    WriteGroupElement(writer, "CDGroupURL", MathBlockOpenMath.ContentDictionaryGroup);
    WriteGroupElement(
        writer,
        "CDGroupDescription",
        "This group defines the deterministic MathBlocks OpenMath program profile.");

    foreach (var name in new[]
             {
                 "mathblocks_program1",
                 "mathblocks_operations1",
                 "mathblocks_types1",
                 "mathblocks_values1"
             })
    {
        writer.WriteStartElement("CDGroupMember", contentDictionaryGroupNamespace);
        WriteGroupElement(writer, "CDName", name);
        WriteGroupElement(writer, "CDVersion", MathBlockOpenMath.ProfileVersion);
        WriteGroupElement(
            writer,
            "CDURL",
            string.Concat(MathBlockOpenMath.ContentDictionaryBase, "/", name, ".ocd"));
        writer.WriteEndElement();
    }

    writer.WriteEndElement();
    writer.WriteEndDocument();
}

XmlWriter CreateWriter(string path)
{
    var settings = new XmlWriterSettings
    {
        Encoding = new UTF8Encoding(false),
        Indent = true,
        NewLineChars = "\n",
        NewLineHandling = NewLineHandling.None
    };
    return XmlWriter.Create(path, settings);
}

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
        operation.Version.ToString(System.Globalization.CultureInfo.InvariantCulture));

static MathBlockProgram CreateSampleProgram()
{
    var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
    var left = builder.Input("left", MathBlockType.Scalar());
    var right = builder.Input("right", MathBlockType.Scalar());
    var sum = builder.Apply("scalar.add", inputs: [left, right]);
    var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
    return builder.Output("sum", sum).Output("square", square).Build();
}

static MathBlockProgram CreateCatalogSampleProgram()
{
    var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
    var operations = MathBlockCatalog.Standard.Operations;
    for (var operationIndex = 0; operationIndex < operations.Count; operationIndex++)
    {
        var operation = operations[operationIndex];
        var regressionCase = operation.RegressionCases[0];
        var inputs = new int[regressionCase.Inputs.Count];
        for (var inputIndex = 0; inputIndex < inputs.Length; inputIndex++)
            inputs[inputIndex] = builder.Constant(regressionCase.Inputs[inputIndex]);
        var result = builder.Apply(operation.Identifier, operation.Version, inputs);
        builder.Output(
            string.Concat("operation-", operationIndex.ToString("D3", CultureInfo.InvariantCulture)),
            result);
    }
    return builder.Build();
}

static void WriteSample(string sourcePath, MathBlockProgram program)
{
    var path = Path.GetFullPath(sourcePath);
    var directory = Path.GetDirectoryName(path) ??
        throw new InvalidOperationException("The sample path has no directory.");
    Directory.CreateDirectory(directory);
    File.WriteAllText(path, MathBlockOpenMath.Export(program), new UTF8Encoding(false));
}

internal sealed record SymbolDefinition(string Name, string Role, string Description);
