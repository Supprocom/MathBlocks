using System.Globalization;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

/// <summary>Imports, exports, validates, and describes the MathBlocks OpenMath profiles.</summary>
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

    /// <summary>
    /// Exports a typed program as canonical XML characters in the lowest profile that contains every
    /// operation of the program.
    /// </summary>
    public static string Export(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);
        return ExportCore(program, SelectProfile(program, PublishedProfiles));
    }

    /// <summary>Exports a typed program as canonical XML characters in the specified profile.</summary>
    public static string Export(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(profile);
        RequireProfileOperations(program, profile);
        return ExportCore(program, profile);
    }

    private static string ExportCore(
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        var result = new StringBuilder();
        using (var writer = XmlWriter.Create(result, CreateWriterSettings()))
            WriteDocument(writer, program, profile);
        return result.ToString();
    }

    private static void WriteDocument(
        XmlWriter writer,
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        writer.WriteStartElement("OMOBJ", NamespaceUri);
        writer.WriteAttributeString("xmlns", NamespaceUri);
        writer.WriteAttributeString("cdbase", profile.ContentDictionaryBase);
        writer.WriteAttributeString("cdgroup", profile.ContentDictionaryGroup);
        writer.WriteAttributeString("version", StandardVersion);

        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ProgramDictionary, "program");
        WriteNodes(writer, program, profile);
        WriteOutputs(writer, program, profile);
        writer.WriteEndElement();

        writer.WriteEndElement();
    }

    /// <summary>Imports a Profile 1 or Profile 2 character document with compatibility options.</summary>
    public static MathBlockOpenMathImportResult Import(string source)
        => Import(source, null);

    private static void WriteNodes(
        XmlWriter writer,
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ProgramDictionary, "nodes");
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
                    WriteSymbol(writer, profile.ProgramDictionary, "input");
                    WriteString(writer, RequireExportName(node.Name, "input"));
                    WriteType(writer, profile, node.Type);
                    break;
                case MathBlockProgramNodeKind.Constant:
                    WriteSymbol(writer, profile.ProgramDictionary, "constant");
                    WriteType(writer, profile, node.Type);
                    WriteValue(writer, profile, node.Value);
                    break;
                case MathBlockProgramNodeKind.Operation:
                    if (node.OperationIdentity is null ||
                        !profile.TryGetOperationSymbol(
                            program.Nodes[index].Operation,
                            out var operationSymbol))
                    {
                        throw OutsideProfile(program, profile, false);
                    }
                    WriteSymbol(
                        writer,
                        operationSymbol.Dictionary,
                        operationSymbol.Name);
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

    private static void WriteOutputs(
        XmlWriter writer,
        MathBlockProgram program,
        MathBlockOpenMathProfileDescriptor profile)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ProgramDictionary, "outputs");
        for (var index = 0; index < program.OutputCount; index++)
        {
            var nodeIndex = program.GetOutputNodeIndex(index);
            if (nodeIndex < 0 || nodeIndex >= program.PlanNodes.Count)
                throw new InvalidOperationException("A program output has an invalid node.");

            WriteApplicationStart(writer);
            WriteSymbol(writer, profile.ProgramDictionary, "output");
            WriteString(writer, RequireExportName(program.GetOutputName(index), "output"));
            WriteReference(writer, nodeIndex);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    internal static string OperationSymbolName(string? identity)
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

    private static void WriteType(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockType type)
    {
        RequireSupportedType(type, false);
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.TypeDictionary, "type");
        WriteSymbol(writer, profile.TypeDictionary, KindName(type.Kind));
        WriteUnit(writer, profile, type.Unit);
        WriteInteger(writer, type.Rows);
        WriteInteger(writer, type.Columns);
        writer.WriteEndElement();
    }

    private static void WriteUnit(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockUnit unit)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.TypeDictionary, "unit");
        WriteRational(writer, profile, unit.Dimension0);
        WriteRational(writer, profile, unit.Dimension1);
        WriteRational(writer, profile, unit.Dimension2);
        WriteRational(writer, profile, unit.Dimension3);
        writer.WriteEndElement();
    }

    private static void WriteRational(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathRational value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.TypeDictionary, "rational");
        WriteInteger(writer, value.Numerator);
        WriteInteger(writer, value.Denominator);
        writer.WriteEndElement();
    }

    private static void WriteValue(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockValue value)
    {
        if (!value.IsValid)
            throw new InvalidOperationException("An OpenMath constant must be valid.");

        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                WriteDouble(writer, value.AsScalar());
                break;
            case MathBlockValueKind.Boolean:
                WriteBoolean(writer, profile, value.AsBoolean());
                break;
            case MathBlockValueKind.Complex:
                WriteComplex(writer, profile, value.AsComplex());
                break;
            case MathBlockValueKind.Vector:
                WriteVector(writer, profile, value.AsVector());
                break;
            case MathBlockValueKind.Matrix:
                WriteMatrix(writer, profile, value.AsMatrix());
                break;
            case MathBlockValueKind.ComplexVector:
                WriteComplexVector(writer, profile, value.AsComplexVector());
                break;
            case MathBlockValueKind.ComplexMatrix:
                WriteComplexMatrix(writer, profile, value.AsComplexMatrix());
                break;
            case MathBlockValueKind.PointSet:
                WritePointSet(writer, profile, value.AsPointSet());
                break;
            case MathBlockValueKind.Graph:
                WriteGraph(writer, profile, value.AsGraph());
                break;
            case MathBlockValueKind.RunSet:
                WriteRunSet(writer, profile, value.AsRunSet());
                break;
            case MathBlockValueKind.BooleanVector:
                WriteBooleanVector(writer, profile, value.AsBooleanVector());
                break;
            default:
                throw new InvalidOperationException("The constant value kind is not supported.");
        }
    }

    private static void WriteVector(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockVector values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "vector");
        for (var index = 0; index < values.Count; index++)
            WriteDouble(writer, values[index]);
        writer.WriteEndElement();
    }

    private static void WriteMatrix(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockMatrix value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "matrix");
        for (var row = 0; row < value.Rows; row++)
            for (var column = 0; column < value.Columns; column++)
                WriteDouble(writer, value[row, column]);
        writer.WriteEndElement();
    }

    private static void WriteComplex(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockComplexValue value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "complex");
        WriteDouble(writer, value.Real);
        WriteDouble(writer, value.Imaginary);
        writer.WriteEndElement();
    }

    private static void WriteComplexVector(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockComplexVector values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "complex-vector");
        for (var index = 0; index < values.Count; index++)
            WriteComplex(writer, profile, values[index]);
        writer.WriteEndElement();
    }

    private static void WriteComplexMatrix(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockComplexMatrix value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "complex-matrix");
        for (var row = 0; row < value.Rows; row++)
            for (var column = 0; column < value.Columns; column++)
                WriteComplex(writer, profile, value[row, column]);
        writer.WriteEndElement();
    }

    private static void WritePointSet(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockPointSet values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "point-set");
        for (var index = 0; index < values.Count; index++)
        {
            WriteApplicationStart(writer);
            WriteSymbol(writer, profile.ValueDictionary, "point");
            WriteDouble(writer, values[index].X);
            WriteDouble(writer, values[index].Y);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteGraph(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        MathBlockGraph value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "graph");
        WriteInteger(writer, value.VertexCount);
        for (var index = 0; index < value.Count; index++)
        {
            var edge = value[index];
            WriteApplicationStart(writer);
            WriteSymbol(writer, profile.ValueDictionary, "edge");
            WriteInteger(writer, edge.From);
            WriteInteger(writer, edge.To);
            WriteDouble(writer, edge.Weight);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteRunSet(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockRunSet values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "run-set");
        for (var index = 0; index < values.Count; index++)
        {
            WriteApplicationStart(writer);
            WriteSymbol(writer, profile.ValueDictionary, "run");
            WriteInteger(writer, values[index].Start);
            WriteInteger(writer, values[index].Length);
            WriteDouble(writer, values[index].Value);
            writer.WriteEndElement();
        }
        writer.WriteEndElement();
    }

    private static void WriteBooleanVector(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        Supprocom.MathBlocks.MathBlockBooleanVector values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, profile.ValueDictionary, "boolean-vector");
        for (var index = 0; index < values.Count; index++)
            WriteBoolean(writer, profile, values[index]);
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

    private static void WriteBoolean(
        XmlWriter writer,
        MathBlockOpenMathProfileDescriptor profile,
        bool value) =>
        WriteSymbol(writer, profile.ValueDictionary, value ? "true" : "false");

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
        if (string.IsNullOrWhiteSpace(value) || !string.Equals(value, value.Trim(), StringComparison.Ordinal) || value.Contains('\r', StringComparison.Ordinal))
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
}
