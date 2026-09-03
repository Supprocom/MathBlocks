using System.Globalization;
using System.Text;
using System.Xml;
using System.Xml.Linq;

namespace Supprocom.MathBlocks;

public sealed class MathBlockOpenMathImportResult
{
    internal MathBlockOpenMathImportResult(
        MathBlockProgram program,
        IReadOnlyList<MathBlockOperation> operations)
    {
        Program = program;
        Operations = Array.AsReadOnly(MathBlockCollectionPrimitives.Copy(operations));
    }

    public MathBlockProgram Program { get; }
    public IReadOnlyList<MathBlockOperation> Operations { get; }
}

public static class MathBlockOpenMath
{
    public const string StandardVersion = "2.0";
    public const string MediaType = "application/openmath+xml";
    public const string ProfileVersion = "1";
    public const string CanonicalizationAlgorithm = "http://www.w3.org/2006/12/xml-c14n11";
    public const int MaximumDocumentCharacters = 16 * 1024 * 1024;
    public const string ContentDictionaryBase =
        "https://raw.githubusercontent.com/Supprocom/MathBlocks/main/openmath/v1";
    public const string ContentDictionaryGroup =
        ContentDictionaryBase + "/mathblocks_profile1.cdg";

    private const string NamespaceUri = "http://www.openmath.org/OpenMath";
    private const string ProgramDictionary = "mathblocks_program1";
    private const string OperationDictionary = "mathblocks_operations1";
    private const string TypeDictionary = "mathblocks_types1";
    private const string ValueDictionary = "mathblocks_values1";
    private static readonly XNamespace OpenMathNamespace = NamespaceUri;
    private static readonly Lazy<ProfileState> StandardProfile = new(CreateStandardProfile);

    public static string Export(MathBlockProgram program)
    {
        ArgumentNullException.ThrowIfNull(program);

        var result = new StringBuilder();
        using (var writer = XmlWriter.Create(result, CreateWriterSettings()))
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
        return result.ToString();
    }

    public static MathBlockOpenMathImportResult Import(string source)
    {
        ArgumentNullException.ThrowIfNull(source);
        if (source.Length == 0)
            throw InvalidFormat("The OpenMath source is empty.");
        if (source.Length > MaximumDocumentCharacters)
            throw InvalidFormat("The OpenMath source exceeds the character limit.");

        XDocument document;
        try
        {
            using var textReader = new StringReader(source);
            using var xmlReader = XmlReader.Create(textReader, CreateReaderSettings());
            document = XDocument.Load(xmlReader, LoadOptions.PreserveWhitespace);
        }
        catch (XmlException exception)
        {
            throw InvalidFormat("The OpenMath source is not valid XML.", exception);
        }

        RequireDocumentContent(document);
        var root = document.Root ?? throw InvalidFormat("The OpenMath root is missing.");
        RequireElement(root, "OMOBJ");
        RequireOnlyAttributes(root, true, "version", "cdbase", "cdgroup");
        if (RequireAttribute(root, "version") != StandardVersion)
            throw InvalidFormat("The OpenMath version is not supported.");
        if (RequireAttribute(root, "cdbase") != ContentDictionaryBase)
            throw InvalidFormat("The OpenMath content dictionary base is not supported.");
        if (RequireAttribute(root, "cdgroup") != ContentDictionaryGroup)
            throw InvalidFormat("The OpenMath content dictionary group is not supported.");

        var rootChildren = ReadChildren(root);
        if (rootChildren.Length != 1)
            throw InvalidFormat("The OpenMath root must contain one object.");

        RequireOnlyAttributes(rootChildren[0], false);
        var programChildren = ReadApplication(rootChildren[0]);
        if (programChildren.Length != 3)
            throw InvalidFormat("The OpenMath program must contain nodes and outputs.");
        RequireSymbol(programChildren[0], ProgramDictionary, "program");

        var operationSymbols = StandardProfile.Value.OperationSymbols;
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var operations = new List<MathBlockOperation>();
        var nodeCount = ReadNodes(programChildren[1], builder, operationSymbols, operations);
        ReadOutputs(programChildren[2], builder, nodeCount);

        try
        {
            return new MathBlockOpenMathImportResult(builder.Build(), operations);
        }
        catch (InvalidOperationException exception)
        {
            throw InvalidFormat("The OpenMath program is invalid.", exception);
        }
    }

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

    private static int ReadNodes(
        XElement element,
        MathBlockProgramBuilder builder,
        IReadOnlyDictionary<string, MathBlockOperation> operationSymbols,
        List<MathBlockOperation> operations)
    {
        RequireOnlyAttributes(element, false);
        var children = ReadApplication(element);
        if (children.Length == 0)
            throw InvalidFormat("The OpenMath node collection is invalid.");
        RequireSymbol(children[0], ProgramDictionary, "nodes");

        for (var nodeIndex = 0; nodeIndex < children.Length - 1; nodeIndex++)
        {
            var elementIndex = nodeIndex + 1;
            var nodeElement = children[elementIndex];
            RequireOnlyAttributes(nodeElement, false, "id");
            RequireElement(nodeElement, "OMA");
            if (RequireAttribute(nodeElement, "id") != NodeIdentifier(nodeIndex))
                throw InvalidFormat("An OpenMath node identifier is invalid.");

            var nodeChildren = ReadChildren(nodeElement);
            if (nodeChildren.Length == 0)
                throw InvalidFormat("An OpenMath node is empty.");
            var head = ReadSymbol(nodeChildren[0]);

            try
            {
                if (head.Dictionary == ProgramDictionary && head.Name == "input")
                {
                    if (nodeChildren.Length != 3)
                        throw InvalidFormat("An OpenMath input node is invalid.");
                    var name = ReadName(nodeChildren[1], "input");
                    var type = ReadType(nodeChildren[2]);
                    if (builder.Input(name, type) != nodeIndex)
                        throw InvalidFormat("The OpenMath input order is invalid.");
                    continue;
                }

                if (head.Dictionary == ProgramDictionary && head.Name == "constant")
                {
                    if (nodeChildren.Length != 3)
                        throw InvalidFormat("An OpenMath constant node is invalid.");
                    var type = ReadType(nodeChildren[1]);
                    var value = ReadValue(nodeChildren[2], type);
                    if (builder.Constant(value) != nodeIndex)
                        throw InvalidFormat("The OpenMath constant order is invalid.");
                    continue;
                }

                if (head.Dictionary != OperationDictionary ||
                    !operationSymbols.TryGetValue(head.Name, out var operation))
                {
                    throw InvalidFormat("An OpenMath operation symbol is not supported.");
                }

                var inputCount = nodeChildren.Length - 1;
                if (inputCount != operation.Arity)
                    throw InvalidFormat("An OpenMath operation has the wrong arity.");
                var inputs = new int[inputCount];
                for (var inputIndex = 0; inputIndex < inputCount; inputIndex++)
                    inputs[inputIndex] = ReadReference(nodeChildren[inputIndex + 1], nodeIndex);
                if (builder.Apply(operation.Identifier, operation.Version, inputs) != nodeIndex)
                    throw InvalidFormat("The OpenMath operation order is invalid.");
                operations.Add(operation);
            }
            catch (ArgumentException exception)
            {
                throw InvalidFormat("An OpenMath node is invalid.", exception);
            }
            catch (KeyNotFoundException exception)
            {
                throw InvalidFormat("An OpenMath operation is not registered.", exception);
            }
            catch (InvalidOperationException exception)
            {
                throw InvalidFormat("An OpenMath node has incompatible types.", exception);
            }
        }

        return children.Length - 1;
    }

    private static void ReadOutputs(
        XElement element,
        MathBlockProgramBuilder builder,
        int nodeCount)
    {
        RequireOnlyAttributes(element, false);
        var children = ReadApplication(element);
        if (children.Length < 2)
            throw InvalidFormat("The OpenMath program requires an output.");
        RequireSymbol(children[0], ProgramDictionary, "outputs");

        for (var index = 1; index < children.Length; index++)
        {
            RequireOnlyAttributes(children[index], false);
            var outputChildren = ReadApplication(children[index]);
            if (outputChildren.Length != 3)
                throw InvalidFormat("An OpenMath output is invalid.");
            RequireSymbol(outputChildren[0], ProgramDictionary, "output");
            var name = ReadName(outputChildren[1], "output");
            var node = ReadReference(outputChildren[2], nodeCount);
            try
            {
                builder.Output(name, node);
            }
            catch (ArgumentException exception)
            {
                throw InvalidFormat("An OpenMath output is invalid.", exception);
            }
        }
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

    private static MathBlockType ReadType(XElement element)
    {
        RequireOnlyAttributes(element, false);
        var children = ReadApplication(element);
        if (children.Length != 5)
            throw InvalidFormat("An OpenMath type is invalid.");
        RequireSymbol(children[0], TypeDictionary, "type");
        var kindSymbol = ReadSymbol(children[1]);
        if (kindSymbol.Dictionary != TypeDictionary)
            throw InvalidFormat("An OpenMath value kind is invalid.");
        var type = new MathBlockType(
            ReadKind(kindSymbol.Name),
            ReadUnit(children[2]),
            ReadInteger(children[3]),
            ReadInteger(children[4]));
        RequireSupportedType(type, true);
        return type;
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

    private static MathBlockUnit ReadUnit(XElement element)
    {
        RequireOnlyAttributes(element, false);
        var children = ReadApplication(element);
        if (children.Length != 5)
            throw InvalidFormat("An OpenMath unit is invalid.");
        RequireSymbol(children[0], TypeDictionary, "unit");
        return new MathBlockUnit(
            ReadRational(children[1]),
            ReadRational(children[2]),
            ReadRational(children[3]),
            ReadRational(children[4]));
    }

    private static void WriteRational(XmlWriter writer, MathRational value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, TypeDictionary, "rational");
        WriteInteger(writer, value.Numerator);
        WriteInteger(writer, value.Denominator);
        writer.WriteEndElement();
    }

    private static MathRational ReadRational(XElement element)
    {
        RequireOnlyAttributes(element, false);
        var children = ReadApplication(element);
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath rational is invalid.");
        RequireSymbol(children[0], TypeDictionary, "rational");
        var numerator = ReadInteger(children[1]);
        var denominator = ReadInteger(children[2]);
        if (denominator <= 0)
            throw InvalidFormat("An OpenMath rational denominator must be positive.");
        try
        {
            var result = new MathRational(numerator, denominator);
            if (result.Numerator != numerator || result.Denominator != denominator)
                throw InvalidFormat("An OpenMath rational must be normalized.");
            return result;
        }
        catch (ArithmeticException exception)
        {
            throw InvalidFormat("An OpenMath rational is outside the supported range.", exception);
        }
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

    private static MathBlockValue ReadValue(XElement element, MathBlockType type)
    {
        MathBlockValue value;
        try
        {
            value = type.Kind switch
            {
                MathBlockValueKind.Scalar => MathBlockValue.Scalar(ReadDouble(element), type.Unit),
                MathBlockValueKind.Boolean => MathBlockValue.Boolean(ReadBoolean(element)),
                MathBlockValueKind.Complex => MathBlockValue.Complex(ReadComplex(element), type.Unit),
                MathBlockValueKind.Vector => ReadVector(element, type),
                MathBlockValueKind.Matrix => ReadMatrix(element, type),
                MathBlockValueKind.ComplexVector => ReadComplexVector(element, type),
                MathBlockValueKind.ComplexMatrix => ReadComplexMatrix(element, type),
                MathBlockValueKind.PointSet => ReadPointSet(element, type),
                MathBlockValueKind.Graph => ReadGraph(element, type),
                MathBlockValueKind.RunSet => ReadRunSet(element, type),
                MathBlockValueKind.BooleanVector => ReadBooleanVector(element),
                _ => throw InvalidFormat("The OpenMath constant value kind is not supported.")
            };
        }
        catch (ArgumentException exception)
        {
            throw InvalidFormat("An OpenMath constant is invalid.", exception);
        }
        catch (InvalidDataException exception)
        {
            throw InvalidFormat("An OpenMath constant is invalid.", exception);
        }

        if (!value.IsValid || value.Type != type)
            throw InvalidFormat("An OpenMath constant does not match its type.");
        return value;
    }

    private static void WriteVector(XmlWriter writer, IReadOnlyList<double> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "vector");
        for (var index = 0; index < values.Count; index++)
            WriteDouble(writer, values[index]);
        writer.WriteEndElement();
    }

    private static MathBlockValue ReadVector(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "vector");
        var values = new double[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ReadDouble(children[index + 1]);
        return MathBlockValue.Vector(values, type.Unit);
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

    private static MathBlockValue ReadMatrix(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "matrix");
        var count = RequireMatrixElementCount(type, children.Length - 1);
        var values = new double[count];
        for (var index = 0; index < values.Length; index++)
            values[index] = ReadDouble(children[index + 1]);
        return MathBlockValue.Matrix(new MathBlockMatrix(type.Rows, type.Columns, values), type.Unit);
    }

    private static void WriteComplex(XmlWriter writer, MathBlockComplexValue value)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "complex");
        WriteDouble(writer, value.Real);
        WriteDouble(writer, value.Imaginary);
        writer.WriteEndElement();
    }

    private static MathBlockComplexValue ReadComplex(XElement element)
    {
        var children = ReadValueApplication(element, "complex");
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath complex value is invalid.");
        return new MathBlockComplexValue(ReadDouble(children[1]), ReadDouble(children[2]));
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

    private static MathBlockValue ReadComplexVector(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "complex-vector");
        var values = new MathBlockComplexValue[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ReadComplex(children[index + 1]);
        return MathBlockValue.ComplexVector(values, type.Unit);
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

    private static MathBlockValue ReadComplexMatrix(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "complex-matrix");
        var count = RequireMatrixElementCount(type, children.Length - 1);
        var values = new MathBlockComplexValue[count];
        for (var index = 0; index < values.Length; index++)
            values[index] = ReadComplex(children[index + 1]);
        return MathBlockValue.ComplexMatrix(
            new MathBlockComplexMatrix(type.Rows, type.Columns, values),
            type.Unit);
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

    private static MathBlockValue ReadPointSet(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "point-set");
        var values = new MathBlockPoint[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var pointChildren = ReadValueApplication(children[index + 1], "point");
            if (pointChildren.Length != 3)
                throw InvalidFormat("An OpenMath point is invalid.");
            values[index] = new MathBlockPoint(
                ReadDouble(pointChildren[1]),
                ReadDouble(pointChildren[2]));
        }
        return MathBlockValue.PointSet(new MathBlockPointSet(values), type.Unit);
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

    private static MathBlockValue ReadGraph(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "graph");
        if (children.Length < 2)
            throw InvalidFormat("An OpenMath graph is invalid.");
        var vertexCount = ReadInteger(children[1]);
        var edges = new MathBlockGraphEdge[children.Length - 2];
        for (var index = 0; index < edges.Length; index++)
        {
            var edgeChildren = ReadValueApplication(children[index + 2], "edge");
            if (edgeChildren.Length != 4)
                throw InvalidFormat("An OpenMath graph edge is invalid.");
            edges[index] = new MathBlockGraphEdge(
                ReadInteger(edgeChildren[1]),
                ReadInteger(edgeChildren[2]),
                ReadDouble(edgeChildren[3]));
        }
        return MathBlockValue.Graph(new MathBlockGraph(vertexCount, edges), type.Unit);
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

    private static MathBlockValue ReadRunSet(XElement element, MathBlockType type)
    {
        var children = ReadValueApplication(element, "run-set");
        var values = new MathBlockRun[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var runChildren = ReadValueApplication(children[index + 1], "run");
            if (runChildren.Length != 4)
                throw InvalidFormat("An OpenMath run is invalid.");
            values[index] = new MathBlockRun(
                ReadInteger(runChildren[1]),
                ReadInteger(runChildren[2]),
                ReadDouble(runChildren[3]));
        }
        return MathBlockValue.RunSet(new MathBlockRunSet(values), type.Unit);
    }

    private static void WriteBooleanVector(XmlWriter writer, IReadOnlyList<bool> values)
    {
        WriteApplicationStart(writer);
        WriteSymbol(writer, ValueDictionary, "boolean-vector");
        for (var index = 0; index < values.Count; index++)
            WriteBoolean(writer, values[index]);
        writer.WriteEndElement();
    }

    private static MathBlockValue ReadBooleanVector(XElement element)
    {
        var children = ReadValueApplication(element, "boolean-vector");
        var values = new bool[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ReadBoolean(children[index + 1]);
        return MathBlockValue.BooleanVector(values);
    }

    private static XElement[] ReadValueApplication(XElement element, string name)
    {
        RequireOnlyAttributes(element, false);
        var children = ReadApplication(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath value application is empty.");
        RequireSymbol(children[0], ValueDictionary, name);
        return children;
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

    private static double ReadDouble(XElement element)
    {
        RequireElement(element, "OMF");
        RequireOnlyAttributes(element, false, "hex");
        RequireNoContent(element);
        var text = RequireAttribute(element, "hex");
        if (text.Length != 16 || text != text.ToUpperInvariant() ||
            !ulong.TryParse(text, NumberStyles.AllowHexSpecifier, CultureInfo.InvariantCulture, out var bits))
        {
            throw InvalidFormat("An OpenMath float has an invalid hexadecimal value.");
        }
        var value = BitConverter.Int64BitsToDouble(unchecked((long)bits));
        if (!double.IsFinite(value))
            throw InvalidFormat("An OpenMath float must be finite.");
        return value;
    }

    private static void WriteBoolean(XmlWriter writer, bool value) =>
        WriteSymbol(writer, ValueDictionary, value ? "true" : "false");

    private static bool ReadBoolean(XElement element)
    {
        var symbol = ReadSymbol(element);
        if (symbol.Dictionary != ValueDictionary)
            throw InvalidFormat("An OpenMath Boolean value is invalid.");
        return symbol.Name switch
        {
            "true" => true,
            "false" => false,
            _ => throw InvalidFormat("An OpenMath Boolean value is invalid.")
        };
    }

    private static void WriteInteger(XmlWriter writer, int value)
    {
        writer.WriteStartElement("OMI", NamespaceUri);
        writer.WriteString(value.ToString(CultureInfo.InvariantCulture));
        writer.WriteEndElement();
    }

    private static int ReadInteger(XElement element)
    {
        RequireElement(element, "OMI");
        RequireOnlyAttributes(element, false);
        RequireTextOnly(element);
        var text = element.Value;
        if (!int.TryParse(text, NumberStyles.AllowLeadingSign, CultureInfo.InvariantCulture, out var value) ||
            text != value.ToString(CultureInfo.InvariantCulture))
        {
            throw InvalidFormat("An OpenMath integer is invalid.");
        }
        return value;
    }

    private static string ReadName(XElement element, string role)
    {
        RequireElement(element, "OMSTR");
        RequireOnlyAttributes(element, false);
        RequireTextOnly(element);
        var value = element.Value;
        if (string.IsNullOrWhiteSpace(value) || value != value.Trim() || value.Contains('\r'))
            throw InvalidFormat($"An OpenMath {role} name is invalid.");
        return value;
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

    private static int ReadReference(XElement element, int maximumExclusive)
    {
        RequireElement(element, "OMR");
        RequireOnlyAttributes(element, false, "href");
        RequireNoContent(element);
        var href = RequireAttribute(element, "href");
        if (!href.StartsWith("#n", StringComparison.Ordinal) ||
            !int.TryParse(
                href.AsSpan(2),
                NumberStyles.None,
                CultureInfo.InvariantCulture,
                out var nodeIndex) ||
            nodeIndex < 0 ||
            nodeIndex >= maximumExclusive ||
            href != string.Concat("#", NodeIdentifier(nodeIndex)))
        {
            throw InvalidFormat("An OpenMath node reference is invalid.");
        }
        return nodeIndex;
    }

    private static XElement[] ReadApplication(XElement element)
    {
        RequireElement(element, "OMA");
        var children = ReadChildren(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath application is empty.");
        return children;
    }

    private static OpenMathSymbol ReadSymbol(XElement element)
    {
        RequireElement(element, "OMS");
        RequireOnlyAttributes(element, false, "cd", "name");
        RequireNoContent(element);
        return new OpenMathSymbol(
            RequireAttribute(element, "cd"),
            RequireAttribute(element, "name"));
    }

    private static void RequireSymbol(XElement element, string dictionary, string name)
    {
        var symbol = ReadSymbol(element);
        if (symbol.Dictionary != dictionary || symbol.Name != name)
            throw InvalidFormat("An OpenMath symbol is invalid.");
    }

    private static XElement[] ReadChildren(XElement element)
    {
        var result = new List<XElement>();
        foreach (var node in element.Nodes())
        {
            if (node is XElement child)
            {
                result.Add(child);
                continue;
            }
            if (node is XText text && string.IsNullOrWhiteSpace(text.Value))
                continue;
            throw InvalidFormat("OpenMath element content is invalid.");
        }
        return result.ToArray();
    }

    private static void RequireDocumentContent(XDocument document)
    {
        foreach (var node in document.Nodes())
        {
            if (node is XElement)
                continue;
            if (node is XText text && string.IsNullOrWhiteSpace(text.Value))
                continue;
            throw InvalidFormat("The OpenMath document contains unsupported content.");
        }
    }

    private static void RequireNoContent(XElement element)
    {
        foreach (var node in element.Nodes())
            if (node is not XText text || !string.IsNullOrWhiteSpace(text.Value))
                throw InvalidFormat("An OpenMath token contains unsupported content.");
    }

    private static void RequireTextOnly(XElement element)
    {
        foreach (var node in element.Nodes())
            if (node is not XText)
                throw InvalidFormat("An OpenMath token contains unsupported content.");
    }

    private static void RequireElement(XElement element, string localName)
    {
        if (element.Name != OpenMathNamespace + localName)
            throw InvalidFormat($"Expected the OpenMath {localName} element.");
    }

    private static string RequireAttribute(XElement element, string name)
    {
        var attribute = element.Attribute(name);
        return attribute?.Value ?? throw InvalidFormat($"The OpenMath {name} attribute is missing.");
    }

    private static void RequireOnlyAttributes(
        XElement element,
        bool allowDefaultNamespace,
        params string[] names)
    {
        foreach (var attribute in element.Attributes())
        {
            if (attribute.IsNamespaceDeclaration)
            {
                if (allowDefaultNamespace &&
                    attribute.Name.LocalName == "xmlns" &&
                    attribute.Value == NamespaceUri)
                {
                    continue;
                }
                throw InvalidFormat("An OpenMath namespace declaration is invalid.");
            }

            if (attribute.Name.Namespace != XNamespace.None)
                throw InvalidFormat("An OpenMath attribute namespace is invalid.");
            var supported = false;
            for (var index = 0; index < names.Length; index++)
                if (attribute.Name.LocalName == names[index])
                {
                    supported = true;
                    break;
                }
            if (!supported)
                throw InvalidFormat("An OpenMath attribute is not supported.");
        }
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

    private static XmlWriterSettings CreateWriterSettings() => new()
    {
        OmitXmlDeclaration = true,
        Indent = false,
        NewLineHandling = NewLineHandling.None,
        NamespaceHandling = NamespaceHandling.OmitDuplicates,
        CheckCharacters = true
    };

    private static XmlReaderSettings CreateReaderSettings() => new()
    {
        DtdProcessing = DtdProcessing.Prohibit,
        XmlResolver = null,
        MaxCharactersInDocument = MaximumDocumentCharacters,
        IgnoreComments = false,
        IgnoreProcessingInstructions = false,
        IgnoreWhitespace = false,
        CloseInput = true
    };

    private static FormatException InvalidFormat(string message) => new(message);

    private static FormatException InvalidFormat(string message, Exception innerException) =>
        new(message, innerException);

    private readonly record struct OpenMathSymbol(string Dictionary, string Name);

    private sealed record ProfileState(
        IReadOnlyDictionary<string, MathBlockOperation> OperationSymbols);
}
