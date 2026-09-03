using System.Globalization;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

/// <summary>Contains one imported Profile 1 program and its operation metadata.</summary>
[System.Diagnostics.DebuggerDisplay("{Program.PlanNodes.Count} nodes, {Operations.Count} operations")]
public sealed class MathBlockOpenMathImportResult
{
    internal MathBlockOpenMathImportResult(
        MathBlockProgram program,
        IReadOnlyList<MathBlockOperation> operations,
        IReadOnlyList<MathBlockOpenMathOperationOccurrence> operationOccurrences,
        IReadOnlyDictionary<string, MathBlockOpenMathSourceLocation>? sourceLocations)
    {
        Program = program;
        Operations = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(operations));
        OperationOccurrences = Array.AsReadOnly(
            MathBlockCollectionPrimitives.Copy(operationOccurrences));
        SourceLocations = sourceLocations is null
            ? null
            : new System.Collections.ObjectModel.ReadOnlyDictionary<
                string,
                MathBlockOpenMathSourceLocation>(
                    new Dictionary<string, MathBlockOpenMathSourceLocation>(
                        sourceLocations,
                        StringComparer.Ordinal));
    }

    /// <summary>Gets the imported typed program.</summary>
    public MathBlockProgram Program { get; }

    /// <summary>Gets operations in program node order.</summary>
    public IReadOnlyList<MathBlockOperation> Operations { get; }

    /// <summary>Gets operation occurrences in program node order.</summary>
    public IReadOnlyList<MathBlockOpenMathOperationOccurrence> OperationOccurrences { get; }

    /// <summary>Gets captured source locations when the import requested them.</summary>
    public IReadOnlyDictionary<string, MathBlockOpenMathSourceLocation>? SourceLocations { get; }
}

/// <summary>Imports, exports, validates, and describes MathBlocks OpenMath Profile 1.</summary>
public static partial class MathBlockOpenMath
{
    /// <summary>Gets the supported OpenMath standard version.</summary>
    public const string StandardVersion = "2.0";

    /// <summary>Gets the OpenMath XML media type.</summary>
    public const string MediaType = "application/openmath+xml";

    /// <summary>Gets the MathBlocks OpenMath profile version.</summary>
    public const string ProfileVersion = "1";

    /// <summary>Gets the canonical XML algorithm URI.</summary>
    public const string CanonicalizationAlgorithm = "http://www.w3.org/2006/12/xml-c14n11";

    /// <summary>Gets the compatibility maximum for decoded source characters.</summary>
    public const int MaximumDocumentCharacters = 16 * 1024 * 1024;

    /// <summary>Gets the compatibility maximum for UTF-8 source bytes.</summary>
    public const int MaximumDocumentUtf8Bytes = MaximumDocumentCharacters * 3 + 3;

    /// <summary>Gets the fixed Profile 1 content dictionary base URI.</summary>
    public const string ContentDictionaryBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v1";

    /// <summary>Gets the fixed Profile 1 content dictionary group URI.</summary>
    public const string ContentDictionaryGroup =
        ContentDictionaryBase + "/mathblocks_profile1.cdg";

    private const string NamespaceUri = "http://www.openmath.org/OpenMath";
    private const string ProgramDictionary = "mathblocks_program1";
    private const string OperationDictionary = "mathblocks_operations1";
    private const string TypeDictionary = "mathblocks_types1";
    private const string ValueDictionary = "mathblocks_values1";
    private static readonly Lazy<ProfileState> StandardProfile = new(CreateStandardProfile);

    /// <summary>Exports a typed program as canonical Profile 1 XML characters.</summary>
    public static string Export(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);

        var result = new StringBuilder();
        using (var writer = XmlWriter.Create(result, CreateWriterSettings()))
            WriteDocument(writer, program);
        return result.ToString();
    }

    private static void WriteDocument(XmlWriter writer, MathBlockProgram program)
    {
        writer.WriteStartElement("OMOBJ", NamespaceUri);
        writer.WriteAttributeString("xmlns", NamespaceUri);
        writer.WriteAttributeString("cdbase", ContentDictionaryBase);
        writer.WriteAttributeString("cdgroup", ContentDictionaryGroup);
        writer.WriteAttributeString("version", StandardVersion);

        WriteApplicationStart(writer);
        WriteSymbol(writer, ProgramDictionary, "program");
        WriteNodes(writer, program);
        WriteOutputs(writer, program);
        writer.WriteEndElement();

        writer.WriteEndElement();
    }

    /// <summary>Imports a Profile 1 character document with compatibility options.</summary>
    public static MathBlockOpenMathImportResult Import(string source)
        => Import(source, null);

    private static void WriteNodes(XmlWriter writer, MathBlockProgram program)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ProgramDictionary, "nodes");
        for (var index = 0; index < program.PlanNodes.Count; index++)
        {
            var node = program.PlanNodes[index];
            if (node.Index != index)
                throw new InvalidOperationException("The program node order is invalid.");

            writer.WriteStartElement("OMA", NamespaceUri);
            writer.WriteAttributeString("id", NodeIdentifier(index));
            switch (node.Kind)
            {
                case MathBlockProgramNodeKind.Input:
                    WriteSymbol(writer, ProgramDictionary, "input");
                    WriteString(writer, RequireExportName(node.Name, "input"));
                    WriteType(writer, node.Type);
                    break;
                case MathBlockProgramNodeKind.Constant:
                    WriteSymbol(writer, ProgramDictionary, "constant");
                    WriteType(writer, node.Type);
                    WriteValue(writer, node.Value);
                    break;
                case MathBlockProgramNodeKind.Operation:
                    if (node.OperationIdentity is null)
                    {
                        throw new InvalidOperationException(
                            "The program contains an operation outside the standard OpenMath profile.");
                    }

                    var operationSymbol = OperationSymbolName(node.OperationIdentity);
                    if (!StandardProfile.Value.OperationSymbols.TryGetValue(
                            operationSymbol,
                            out var standardOperation) ||
                        !ReferenceEquals(program.Nodes[index].Operation, standardOperation))
                    {
                        throw new InvalidOperationException(
                            "The program contains an operation outside the standard OpenMath profile.");
                    }
                    WriteSymbol(
                        writer,
                        OperationDictionary,
                        operationSymbol);
                    for (var inputIndex = 0; inputIndex < node.Inputs.Count; inputIndex++)
                    {
                        var input = node.Inputs[inputIndex];
                        if (input < 0 || input >= index)
                            throw new InvalidOperationException(
                                "An operation input must reference an earlier node.");
                        WriteReference(writer, input);
                    }
                    break;
                default:
                    throw new InvalidOperationException("The program contains an unsupported node kind.");
            }
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteOutputs(XmlWriter writer, MathBlockProgram program)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ProgramDictionary, "outputs");
        for (var index = 0; index < program.OutputCount; index++)
        {
            var nodeIndex = program.GetOutputNodeIndex(index);
            if (nodeIndex < 0 || nodeIndex >= program.PlanNodes.Count)
                throw new InvalidOperationException("A program output has an invalid node.");

            WriteApplicationStart(writer);
            WriteSymbol(writer, ProgramDictionary, "output");
            WriteString(writer, RequireExportName(program.GetOutputName(index), "output"));
            WriteReference(writer, nodeIndex);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static ProfileState CreateStandardProfile()
    {
        var operations = MathBlockCatalog.Standard.Operations;
        var symbols = new Dictionary<string, MathBlockOperation>(StringComparer.Ordinal);
        for (var index = 0; index < operations.Count; index++)
        {
            var operation = operations[index];
            var symbol = OperationSymbolName(operation.Identity);
            if (!symbols.TryAdd(symbol, operation))
                throw new InvalidOperationException("The standard catalog has duplicate OpenMath symbols.");
        }
        return new ProfileState(symbols);
    }

    private static string OperationSymbolName(string? identity)
    {
        if (string.IsNullOrEmpty(identity))
            throw new InvalidOperationException("An operation identity is missing.");
        var separator = identity.LastIndexOf('@');
        if (separator <= 0 || separator == identity.Length - 1 ||
            !int.TryParse(
                identity.AsSpan(separator + 1),
                NumberStyles.None,
                CultureInfo.InvariantCulture,
                out var version) ||
            version <= 0)
        {
            throw new InvalidOperationException("An operation identity is invalid.");
        }

        var name = string.Concat(
            "op.",
            identity[..separator],
            ".v",
            version.ToString(CultureInfo.InvariantCulture));
        try
        {
            XmlConvert.VerifyNCName(name);
        }
        catch (XmlException exception)
        {
            throw new InvalidOperationException("An operation identity is not an OpenMath name.", exception);
        }
        return name;
    }

    private static void WriteType(XmlWriter writer, MathBlockType type)
    {
        RequireSupportedType(type, false);
        WriteApplicationStart(writer);
        WriteSymbol(writer, TypeDictionary, "type");
        WriteSymbol(writer, TypeDictionary, KindName(type.Kind));
        WriteUnit(writer, type.Unit);
        WriteInteger(writer, type.Rows);
        WriteInteger(writer, type.Columns);
        writer.WriteEndElement();
    }

    private static void WriteUnit(XmlWriter writer, MathBlockUnit unit)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, TypeDictionary, "unit");
        WriteRational(writer, unit.Dimension0);
        WriteRational(writer, unit.Dimension1);
        WriteRational(writer, unit.Dimension2);
        WriteRational(writer, unit.Dimension3);
        writer.WriteEndElement();
    }

    private static void WriteRational(XmlWriter writer, MathRational value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, TypeDictionary, "rational");
        WriteInteger(writer, value.Numerator);
        WriteInteger(writer, value.Denominator);
        writer.WriteEndElement();
    }

    private static void WriteValue(XmlWriter writer, MathBlockValue value)
    {
        if (!value.IsValid)
            throw new InvalidOperationException("An OpenMath constant must be valid.");

        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                WriteDouble(writer, value.AsScalar());
                break;
            case MathBlockValueKind.Boolean:
                WriteBoolean(writer, value.AsBoolean());
                break;
            case MathBlockValueKind.Complex:
                WriteComplex(writer, value.AsComplex());
                break;
            case MathBlockValueKind.Vector:
                WriteVector(writer, value.AsVector());
                break;
            case MathBlockValueKind.Matrix:
                WriteMatrix(writer, value.AsMatrix());
                break;
            case MathBlockValueKind.ComplexVector:
                WriteComplexVector(writer, value.AsComplexVector());
                break;
            case MathBlockValueKind.ComplexMatrix:
                WriteComplexMatrix(writer, value.AsComplexMatrix());
                break;
            case MathBlockValueKind.PointSet:
                WritePointSet(writer, value.AsPointSet());
                break;
            case MathBlockValueKind.Graph:
                WriteGraph(writer, value.AsGraph());
                break;
            case MathBlockValueKind.RunSet:
                WriteRunSet(writer, value.AsRunSet());
                break;
            case MathBlockValueKind.BooleanVector:
                WriteBooleanVector(writer, value.AsBooleanVector());
                break;
            default:
                throw new InvalidOperationException("The constant value kind is not supported.");
        }
    }

    private static void WriteVector(XmlWriter writer, IReadOnlyList<double> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "vector");
        for (var index = 0; index < values.Count; index++)
            WriteDouble(writer, values[index]);
        writer.WriteEndElement();
    }

    private static void WriteMatrix(XmlWriter writer, MathBlockMatrix value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "matrix");
        for (var row = 0; row < value.Rows; row++)
            for (var column = 0; column < value.Columns; column++)
                WriteDouble(writer, value[row, column]);
        writer.WriteEndElement();
    }

    private static void WriteComplex(XmlWriter writer, MathBlockComplexValue value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "complex");
        WriteDouble(writer, value.Real);
        WriteDouble(writer, value.Imaginary);
        writer.WriteEndElement();
    }

    private static void WriteComplexVector(
        XmlWriter writer,
        IReadOnlyList<MathBlockComplexValue> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "complex-vector");
        for (var index = 0; index < values.Count; index++)
            WriteComplex(writer, values[index]);
        writer.WriteEndElement();
    }

    private static void WriteComplexMatrix(XmlWriter writer, MathBlockComplexMatrix value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "complex-matrix");
        for (var row = 0; row < value.Rows; row++)
            for (var column = 0; column < value.Columns; column++)
                WriteComplex(writer, value[row, column]);
        writer.WriteEndElement();
    }

    private static void WritePointSet(XmlWriter writer, IReadOnlyList<MathBlockPoint> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "point-set");
        for (var index = 0; index < values.Count; index++)
        {
            WriteApplicationStart(writer);
            WriteSymbol(writer, ValueDictionary, "point");
            WriteDouble(writer, values[index].X);
            WriteDouble(writer, values[index].Y);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteGraph(XmlWriter writer, MathBlockGraph value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "graph");
        WriteInteger(writer, value.VertexCount);
        for (var index = 0; index < value.Count; index++)
        {
            var edge = value[index];
            WriteApplicationStart(writer);
            WriteSymbol(writer, ValueDictionary, "edge");
            WriteInteger(writer, edge.From);
            WriteInteger(writer, edge.To);
            WriteDouble(writer, edge.Weight);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteRunSet(XmlWriter writer, IReadOnlyList<MathBlockRun> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "run-set");
        for (var index = 0; index < values.Count; index++)
        {
            WriteApplicationStart(writer);
            WriteSymbol(writer, ValueDictionary, "run");
            WriteInteger(writer, values[index].Start);
            WriteInteger(writer, values[index].Length);
            WriteDouble(writer, values[index].Value);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteBooleanVector(XmlWriter writer, IReadOnlyList<bool> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "boolean-vector");
        for (var index = 0; index < values.Count; index++)
            WriteBoolean(writer, values[index]);
        writer.WriteEndElement();
    }

    private static void WriteDouble(XmlWriter writer, double value)
    {
        if (!double.IsFinite(value))
            throw new InvalidOperationException("An OpenMath float must be finite.");
        writer.WriteStartElement("OMF", NamespaceUri);
        writer.WriteAttributeString(
            "hex",
            BitConverter.DoubleToUInt64Bits(value).ToString("X16", CultureInfo.InvariantCulture));
        writer.WriteFullEndElement();
    }

    private static void WriteBoolean(XmlWriter writer, bool value) =>
        WriteSymbol(writer, ValueDictionary, value ? "true" : "false");

    private static void WriteInteger(XmlWriter writer, int value)
    {
        writer.WriteStartElement("OMI", NamespaceUri);
        writer.WriteString(value.ToString(CultureInfo.InvariantCulture));
        writer.WriteEndElement();
    }

    private static void WriteString(XmlWriter writer, string value)
    {
        writer.WriteStartElement("OMSTR", NamespaceUri);
        writer.WriteString(value);
        writer.WriteEndElement();
    }

    private static void WriteReference(XmlWriter writer, int nodeIndex)
    {
        writer.WriteStartElement("OMR", NamespaceUri);
        writer.WriteAttributeString("href", string.Concat("#", NodeIdentifier(nodeIndex)));
        writer.WriteFullEndElement();
    }

    private static bool IsXmlWhitespace(string value)
    {
        for (var index = 0; index < value.Length; index++)
            if (value[index] is not (' ' or '\t' or '\r' or '\n'))
                return false;
        return true;
    }

    private static void RequireSupportedType(MathBlockType type, bool importing)
    {
        var supported = type.Kind switch
        {
            MathBlockValueKind.Scalar or
            MathBlockValueKind.Boolean or
            MathBlockValueKind.Complex => type.Rows == 0 && type.Columns == 0,
            MathBlockValueKind.Vector or
            MathBlockValueKind.ComplexVector or
            MathBlockValueKind.PointSet or
            MathBlockValueKind.Graph or
            MathBlockValueKind.RunSet or
            MathBlockValueKind.BooleanVector => type.Rows >= 0 && type.Columns == 0,
            MathBlockValueKind.Matrix or
            MathBlockValueKind.ComplexMatrix => type.Rows >= 0 && type.Columns >= 0,
            _ => false
        };
        if ((type.Kind == MathBlockValueKind.Boolean ||
             type.Kind == MathBlockValueKind.BooleanVector) &&
            !type.Unit.IsDimensionless)
        {
            supported = false;
        }
        if (!supported)
        {
            if (importing)
                throw InvalidFormat("An OpenMath type is not supported.");
            throw new InvalidOperationException("A program type is not supported by OpenMath.");
        }
    }

    private static int RequireMatrixElementCount(MathBlockType type, int actual)
    {
        if (type.Rows <= 0 || type.Columns <= 0 || type.Rows > int.MaxValue / type.Columns)
            throw InvalidFormat("An OpenMath matrix shape is invalid.");
        var expected = type.Rows * type.Columns;
        if (actual != expected)
            throw InvalidFormat("An OpenMath matrix value count is invalid.");
        return expected;
    }

    private static string KindName(MathBlockValueKind kind) => kind switch
    {
        MathBlockValueKind.Scalar => "scalar",
        MathBlockValueKind.Boolean => "boolean",
        MathBlockValueKind.Complex => "complex",
        MathBlockValueKind.Vector => "vector",
        MathBlockValueKind.Matrix => "matrix",
        MathBlockValueKind.ComplexVector => "complex-vector",
        MathBlockValueKind.ComplexMatrix => "complex-matrix",
        MathBlockValueKind.PointSet => "point-set",
        MathBlockValueKind.Graph => "graph",
        MathBlockValueKind.RunSet => "run-set",
        MathBlockValueKind.BooleanVector => "boolean-vector",
        _ => throw new InvalidOperationException("The value kind is not supported by OpenMath.")
    };

    private static MathBlockValueKind ReadKind(string name) => name switch
    {
        "scalar" => MathBlockValueKind.Scalar,
        "boolean" => MathBlockValueKind.Boolean,
        "complex" => MathBlockValueKind.Complex,
        "vector" => MathBlockValueKind.Vector,
        "matrix" => MathBlockValueKind.Matrix,
        "complex-vector" => MathBlockValueKind.ComplexVector,
        "complex-matrix" => MathBlockValueKind.ComplexMatrix,
        "point-set" => MathBlockValueKind.PointSet,
        "graph" => MathBlockValueKind.Graph,
        "run-set" => MathBlockValueKind.RunSet,
        "boolean-vector" => MathBlockValueKind.BooleanVector,
        _ => throw InvalidFormat("An OpenMath value kind is not supported.")
    };

    private static string RequireExportName(string? value, string role)
    {
        if (string.IsNullOrWhiteSpace(value) || value != value.Trim() || value.Contains('\r'))
            throw new InvalidOperationException($"A program {role} name is not supported by OpenMath.");
        try
        {
            XmlConvert.VerifyXmlChars(value);
        }
        catch (XmlException exception)
        {
            throw new InvalidOperationException(
                $"A program {role} name contains an unsupported XML character.",
                exception);
        }
        return value;
    }

    private static string NodeIdentifier(int index) =>
        string.Concat("n", index.ToString(CultureInfo.InvariantCulture));

    private static void WriteApplicationStart(XmlWriter writer) =>
        writer.WriteStartElement("OMA", NamespaceUri);

    private static void WriteSymbol(XmlWriter writer, string dictionary, string name)
    {
        writer.WriteStartElement("OMS", NamespaceUri);
        writer.WriteAttributeString("cd", dictionary);
        writer.WriteAttributeString("name", name);
        writer.WriteFullEndElement();
    }

    private static XmlWriterSettings CreateWriterSettings(
        Encoding? encoding = null,
        bool async = false)
    {
        var settings = new XmlWriterSettings
        {
            OmitXmlDeclaration = true,
            Indent = false,
            NewLineHandling = NewLineHandling.None,
            NamespaceHandling = NamespaceHandling.OmitDuplicates,
            CheckCharacters = true,
            CloseOutput = false,
            Async = async
        };
        if (encoding is not null)
            settings.Encoding = encoding;
        return settings;
    }

    private static XmlReaderSettings CreateReaderSettings(
        int maximumDocumentCharacters,
        bool async = false) => new()
    {
        DtdProcessing = DtdProcessing.Prohibit,
        XmlResolver = null,
        MaxCharactersInDocument = maximumDocumentCharacters,
        IgnoreComments = false,
        IgnoreProcessingInstructions = false,
        IgnoreWhitespace = false,
        CloseInput = true,
        Async = async
    };

    private static FormatException InvalidFormat(string message) => new(message);

    private static FormatException InvalidFormat(string message, Exception innerException) =>
        new(message, innerException);

    private readonly record struct OpenMathSymbol(string Dictionary, string Name);

    private sealed record ProfileState(
        IReadOnlyDictionary<string, MathBlockOperation> OperationSymbols);
}
