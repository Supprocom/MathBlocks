using System.Globalization;
using System.Xml;

namespace Supprocom.MathBlocks;

public static partial class MathBlockOpenMath
{
    private static MathBlockOpenMathImportResult ImportForward(string source)
    {
        using var textReader = new StringReader(source);
        using var xmlReader = XmlReader.Create(textReader, CreateReaderSettings());
        return ReadForward(xmlReader);
    }

    private static MathBlockOpenMathImportResult ReadForward(XmlReader reader)
    {
        var parser = new OpenMathSemanticReader();
        FormatException? semanticException = null;
        try
        {
            while (reader.Read())
            {
                if (semanticException is not null)
                    continue;
                try
                {
                    parser.Accept(reader);
                }
                catch (FormatException exception)
                {
                    semanticException = exception;
                }
            }
            if (semanticException is not null)
                throw semanticException;
            return parser.Complete();
        }
        catch (XmlException exception)
        {
            throw InvalidFormat("The OpenMath source is not valid XML.", exception);
        }
    }

    private static void ParseNode(
        BufferedElement element,
        int nodeIndex,
        MathBlockProgramBuilder builder,
        IReadOnlyDictionary<string, MathBlockOperation> operationSymbols,
        List<MathBlockOperation> operations)
    {
        RequireOnlyBufferedAttributes(element, "id");
        RequireBufferedElement(element, "OMA");
        if (RequireBufferedAttribute(element, "id") != NodeIdentifier(nodeIndex))
            throw InvalidFormat("An OpenMath node identifier is invalid.");

        var children = ReadBufferedChildren(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath node is empty.");
        var head = ParseSymbol(children[0]);

        try
        {
            if (head.Dictionary == ProgramDictionary && head.Name == "input")
            {
                if (children.Length != 3)
                    throw InvalidFormat("An OpenMath input node is invalid.");
                var name = ParseName(children[1], "input");
                var type = ParseType(children[2]);
                if (builder.Input(name, type) != nodeIndex)
                    throw InvalidFormat("The OpenMath input order is invalid.");
                return;
            }

            if (head.Dictionary == ProgramDictionary && head.Name == "constant")
            {
                if (children.Length != 3)
                    throw InvalidFormat("An OpenMath constant node is invalid.");
                var type = ParseType(children[1]);
                var value = ParseValue(children[2], type);
                if (builder.Constant(value) != nodeIndex)
                    throw InvalidFormat("The OpenMath constant order is invalid.");
                return;
            }

            if (head.Dictionary != OperationDictionary ||
                !operationSymbols.TryGetValue(head.Name, out var operation))
            {
                throw InvalidFormat("An OpenMath operation symbol is not supported.");
            }

            var inputCount = children.Length - 1;
            if (inputCount != operation.Arity)
                throw InvalidFormat("An OpenMath operation has the wrong arity.");
            var inputs = new int[inputCount];
            for (var inputIndex = 0; inputIndex < inputCount; inputIndex++)
                inputs[inputIndex] = ParseReference(children[inputIndex + 1], nodeIndex);
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

    private static void ParseOutput(
        BufferedElement element,
        MathBlockProgramBuilder builder,
        int nodeCount)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath output is invalid.");
        RequireParsedSymbol(children[0], ProgramDictionary, "output");
        var name = ParseName(children[1], "output");
        var node = ParseReference(children[2], nodeCount);
        try
        {
            builder.Output(name, node);
        }
        catch (ArgumentException exception)
        {
            throw InvalidFormat("An OpenMath output is invalid.", exception);
        }
    }

    private static MathBlockType ParseType(BufferedElement element)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 5)
            throw InvalidFormat("An OpenMath type is invalid.");
        RequireParsedSymbol(children[0], TypeDictionary, "type");
        var kindSymbol = ParseSymbol(children[1]);
        if (kindSymbol.Dictionary != TypeDictionary)
            throw InvalidFormat("An OpenMath value kind is invalid.");
        var type = new MathBlockType(
            ReadKind(kindSymbol.Name),
            ParseUnit(children[2]),
            ParseInteger(children[3]),
            ParseInteger(children[4]));
        RequireSupportedType(type, true);
        return type;
    }

    private static MathBlockUnit ParseUnit(BufferedElement element)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 5)
            throw InvalidFormat("An OpenMath unit is invalid.");
        RequireParsedSymbol(children[0], TypeDictionary, "unit");
        return new MathBlockUnit(
            ParseRational(children[1]),
            ParseRational(children[2]),
            ParseRational(children[3]),
            ParseRational(children[4]));
    }

    private static MathRational ParseRational(BufferedElement element)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath rational is invalid.");
        RequireParsedSymbol(children[0], TypeDictionary, "rational");
        var numerator = ParseInteger(children[1]);
        var denominator = ParseInteger(children[2]);
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

    private static MathBlockValue ParseValue(BufferedElement element, MathBlockType type)
    {
        MathBlockValue value;
        try
        {
            value = type.Kind switch
            {
                MathBlockValueKind.Scalar => MathBlockValue.Scalar(ParseDouble(element), type.Unit),
                MathBlockValueKind.Boolean => MathBlockValue.Boolean(ParseBoolean(element)),
                MathBlockValueKind.Complex => MathBlockValue.Complex(ParseComplex(element), type.Unit),
                MathBlockValueKind.Vector => ParseVector(element, type),
                MathBlockValueKind.Matrix => ParseMatrix(element, type),
                MathBlockValueKind.ComplexVector => ParseComplexVector(element, type),
                MathBlockValueKind.ComplexMatrix => ParseComplexMatrix(element, type),
                MathBlockValueKind.PointSet => ParsePointSet(element, type),
                MathBlockValueKind.Graph => ParseGraph(element, type),
                MathBlockValueKind.RunSet => ParseRunSet(element, type),
                MathBlockValueKind.BooleanVector => ParseBooleanVector(element),
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

    private static MathBlockValue ParseVector(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "vector");
        var values = new double[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseDouble(children[index + 1]);
        return MathBlockValue.Vector(values, type.Unit);
    }

    private static MathBlockValue ParseMatrix(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "matrix");
        var count = RequireMatrixElementCount(type, children.Length - 1);
        var values = new double[count];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseDouble(children[index + 1]);
        return MathBlockValue.Matrix(new MathBlockMatrix(type.Rows, type.Columns, values), type.Unit);
    }

    private static MathBlockComplexValue ParseComplex(BufferedElement element)
    {
        var children = ReadBufferedValueApplication(element, "complex");
        if (children.Length != 3)
            throw InvalidFormat("An OpenMath complex value is invalid.");
        return new MathBlockComplexValue(ParseDouble(children[1]), ParseDouble(children[2]));
    }

    private static MathBlockValue ParseComplexVector(
        BufferedElement element,
        MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "complex-vector");
        var values = new MathBlockComplexValue[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseComplex(children[index + 1]);
        return MathBlockValue.ComplexVector(values, type.Unit);
    }

    private static MathBlockValue ParseComplexMatrix(
        BufferedElement element,
        MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "complex-matrix");
        var count = RequireMatrixElementCount(type, children.Length - 1);
        var values = new MathBlockComplexValue[count];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseComplex(children[index + 1]);
        return MathBlockValue.ComplexMatrix(
            new MathBlockComplexMatrix(type.Rows, type.Columns, values),
            type.Unit);
    }

    private static MathBlockValue ParsePointSet(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "point-set");
        var values = new MathBlockPoint[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var pointChildren = ReadBufferedValueApplication(children[index + 1], "point");
            if (pointChildren.Length != 3)
                throw InvalidFormat("An OpenMath point is invalid.");
            values[index] = new MathBlockPoint(
                ParseDouble(pointChildren[1]),
                ParseDouble(pointChildren[2]));
        }
        return MathBlockValue.PointSet(new MathBlockPointSet(values), type.Unit);
    }

    private static MathBlockValue ParseGraph(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "graph");
        if (children.Length < 2)
            throw InvalidFormat("An OpenMath graph is invalid.");
        var vertexCount = ParseInteger(children[1]);
        var edges = new MathBlockGraphEdge[children.Length - 2];
        for (var index = 0; index < edges.Length; index++)
        {
            var edgeChildren = ReadBufferedValueApplication(children[index + 2], "edge");
            if (edgeChildren.Length != 4)
                throw InvalidFormat("An OpenMath graph edge is invalid.");
            edges[index] = new MathBlockGraphEdge(
                ParseInteger(edgeChildren[1]),
                ParseInteger(edgeChildren[2]),
                ParseDouble(edgeChildren[3]));
        }
        return MathBlockValue.Graph(new MathBlockGraph(vertexCount, edges), type.Unit);
    }

    private static MathBlockValue ParseRunSet(BufferedElement element, MathBlockType type)
    {
        var children = ReadBufferedValueApplication(element, "run-set");
        var values = new MathBlockRun[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var runChildren = ReadBufferedValueApplication(children[index + 1], "run");
            if (runChildren.Length != 4)
                throw InvalidFormat("An OpenMath run is invalid.");
            values[index] = new MathBlockRun(
                ParseInteger(runChildren[1]),
                ParseInteger(runChildren[2]),
                ParseDouble(runChildren[3]));
        }
        return MathBlockValue.RunSet(new MathBlockRunSet(values), type.Unit);
    }

    private static MathBlockValue ParseBooleanVector(BufferedElement element)
    {
        var children = ReadBufferedValueApplication(element, "boolean-vector");
        var values = new bool[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseBoolean(children[index + 1]);
        return MathBlockValue.BooleanVector(values);
    }

    private static BufferedElement[] ReadBufferedValueApplication(
        BufferedElement element,
        string name)
    {
        RequireOnlyBufferedAttributes(element);
        var children = ReadBufferedApplication(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath value application is empty.");
        RequireParsedSymbol(children[0], ValueDictionary, name);
        return children;
    }

    private static double ParseDouble(BufferedElement element)
    {
        RequireBufferedElement(element, "OMF");
        RequireOnlyBufferedAttributes(element, "hex");
        RequireNoBufferedContent(element);
        var text = RequireBufferedAttribute(element, "hex");
        if (text.Length != 16 || text != text.ToUpperInvariant() ||
            !ulong.TryParse(
                text,
                NumberStyles.AllowHexSpecifier,
                CultureInfo.InvariantCulture,
                out var bits))
        {
            throw InvalidFormat("An OpenMath float has an invalid hexadecimal value.");
        }
        var value = BitConverter.Int64BitsToDouble(unchecked((long)bits));
        if (!double.IsFinite(value))
            throw InvalidFormat("An OpenMath float must be finite.");
        return value;
    }

    private static bool ParseBoolean(BufferedElement element)
    {
        var symbol = ParseSymbol(element);
        if (symbol.Dictionary != ValueDictionary)
            throw InvalidFormat("An OpenMath Boolean value is invalid.");
        return symbol.Name switch
        {
            "true" => true,
            "false" => false,
            _ => throw InvalidFormat("An OpenMath Boolean value is invalid.")
        };
    }

    private static int ParseInteger(BufferedElement element)
    {
        RequireBufferedElement(element, "OMI");
        RequireOnlyBufferedAttributes(element);
        var text = RequireBufferedTextOnly(element);
        if (!int.TryParse(
                text,
                NumberStyles.AllowLeadingSign,
                CultureInfo.InvariantCulture,
                out var value) ||
            text != value.ToString(CultureInfo.InvariantCulture))
        {
            throw InvalidFormat("An OpenMath integer is invalid.");
        }
        return value;
    }

    private static string ParseName(BufferedElement element, string role)
    {
        RequireBufferedElement(element, "OMSTR");
        RequireOnlyBufferedAttributes(element);
        var value = RequireBufferedTextOnly(element);
        if (string.IsNullOrWhiteSpace(value) || value != value.Trim() || value.Contains('\r'))
            throw InvalidFormat($"An OpenMath {role} name is invalid.");
        return value;
    }

    private static int ParseReference(BufferedElement element, int maximumExclusive)
    {
        RequireBufferedElement(element, "OMR");
        RequireOnlyBufferedAttributes(element, "href");
        RequireNoBufferedContent(element);
        var href = RequireBufferedAttribute(element, "href");
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

    private static BufferedElement[] ReadBufferedApplication(BufferedElement element)
    {
        RequireBufferedElement(element, "OMA");
        var children = ReadBufferedChildren(element);
        if (children.Length == 0)
            throw InvalidFormat("An OpenMath application is empty.");
        return children;
    }

    private static OpenMathSymbol ParseSymbol(BufferedElement element)
    {
        RequireBufferedElement(element, "OMS");
        RequireOnlyBufferedAttributes(element, "cd", "name");
        RequireNoBufferedContent(element);
        return new OpenMathSymbol(
            RequireBufferedAttribute(element, "cd"),
            RequireBufferedAttribute(element, "name"));
    }

    private static void RequireParsedSymbol(
        BufferedElement element,
        string dictionary,
        string name)
    {
        var symbol = ParseSymbol(element);
        if (symbol.Dictionary != dictionary || symbol.Name != name)
            throw InvalidFormat("An OpenMath symbol is invalid.");
    }

    private static BufferedElement[] ReadBufferedChildren(BufferedElement element)
    {
        if (element.HasUnsupportedContent || !IsXmlWhitespace(element.Text))
            throw InvalidFormat("OpenMath element content is invalid.");
        return element.Children;
    }

    private static void RequireNoBufferedContent(BufferedElement element)
    {
        if (element.Children.Length != 0 ||
            element.HasUnsupportedContent ||
            !IsXmlWhitespace(element.Text))
        {
            throw InvalidFormat("An OpenMath token contains unsupported content.");
        }
    }

    private static string RequireBufferedTextOnly(BufferedElement element)
    {
        if (element.Children.Length != 0 || element.HasUnsupportedContent)
            throw InvalidFormat("An OpenMath token contains unsupported content.");
        return element.Text;
    }

    private static void RequireBufferedElement(BufferedElement element, string localName)
    {
        if (element.LocalName != localName || element.NamespaceName != NamespaceUri)
            throw InvalidFormat($"Expected the OpenMath {localName} element.");
    }

    private static string RequireBufferedAttribute(BufferedElement element, string name)
    {
        for (var index = 0; index < element.Attributes.Count; index++)
        {
            var attribute = element.Attributes[index];
            if (attribute.NamespaceName.Length == 0 && attribute.LocalName == name)
                return attribute.Value;
        }
        throw InvalidFormat($"The OpenMath {name} attribute is missing.");
    }

    private static void RequireOnlyBufferedAttributes(
        BufferedElement element,
        params string[] names) =>
        RequireOnlyBufferedAttributes(element.Attributes, names);

    private static void RequireOnlyBufferedAttributes(
        IReadOnlyList<BufferedAttribute> attributes,
        params string[] names)
    {
        for (var attributeIndex = 0; attributeIndex < attributes.Count; attributeIndex++)
        {
            var attribute = attributes[attributeIndex];
            if (attribute.IsNamespaceDeclaration)
                continue;
            if (attribute.NamespaceName.Length != 0)
                throw InvalidFormat("An OpenMath attribute namespace is invalid.");

            var supported = false;
            for (var nameIndex = 0; nameIndex < names.Length; nameIndex++)
            {
                if (attribute.LocalName != names[nameIndex])
                    continue;
                supported = true;
                break;
            }
            if (!supported)
                throw InvalidFormat("An OpenMath attribute is not supported.");
        }
    }

    private sealed class OpenMathSemanticReader
    {
        private readonly Stack<ElementFrame> frames = new();
        private readonly MathBlockProgramBuilder builder =
            new(MathBlockCatalog.Standard);
        private readonly List<MathBlockOperation> operations = [];
        private int nodeCount;
        private bool rootSeen;
        private bool rootComplete;
        private MathBlockOpenMathImportResult? result;

        public void Accept(XmlReader reader)
        {
            switch (reader.NodeType)
            {
                case XmlNodeType.Element:
                    StartElement(reader);
                    return;
                case XmlNodeType.EndElement:
                    EndElement(reader);
                    return;
                case XmlNodeType.Text:
                case XmlNodeType.CDATA:
                case XmlNodeType.Whitespace:
                case XmlNodeType.SignificantWhitespace:
                    AddText(reader.Value);
                    return;
                case XmlNodeType.XmlDeclaration:
                    if (frames.Count != 0 || rootSeen)
                        RejectUnsupportedContent();
                    return;
                case XmlNodeType.None:
                    return;
                default:
                    AddUnsupportedContent();
                    return;
            }
        }

        public MathBlockOpenMathImportResult Complete()
        {
            if (frames.Count != 0)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            if (!rootSeen)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            if (!rootComplete || result is null)
                throw InvalidFormat("The OpenMath root is missing.");
            return result;
        }

        private void StartElement(XmlReader reader)
        {
            var header = ReadHeader(reader);
            ElementRole role;
            if (frames.Count == 0)
            {
                if (rootSeen)
                    throw InvalidFormat("The OpenMath document contains unsupported content.");
                rootSeen = true;
                role = ElementRole.Root;
                ValidateRootHeader(header);
            }
            else
            {
                role = frames.Peek().NextChildRole();
            }

            var frame = new ElementFrame(header, role);
            if (!reader.IsEmptyElement)
            {
                frames.Push(frame);
                return;
            }
            CompleteFrame(frame);
        }

        private void EndElement(XmlReader reader)
        {
            if (frames.Count == 0)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            var frame = frames.Pop();
            if (frame.Header.LocalName != reader.LocalName ||
                frame.Header.NamespaceName != reader.NamespaceURI)
            {
                throw InvalidFormat("The OpenMath source is not valid XML.");
            }
            CompleteFrame(frame);
        }

        private void AddText(string value)
        {
            if (frames.Count == 0)
            {
                if (!IsXmlWhitespace(value))
                    RejectUnsupportedContent();
                return;
            }
            frames.Peek().AddText(value);
        }

        private void AddUnsupportedContent()
        {
            if (frames.Count == 0)
            {
                RejectUnsupportedContent();
                return;
            }
            frames.Peek().AddUnsupportedContent();
        }

        private static void RejectUnsupportedContent() =>
            throw InvalidFormat("The OpenMath document contains unsupported content.");

        private void CompleteFrame(ElementFrame frame)
        {
            object completed = frame.Role switch
            {
                ElementRole.Root => CompleteRoot(frame),
                ElementRole.Program => CompleteProgram(frame),
                ElementRole.Nodes => CompleteNodeCollection(frame),
                ElementRole.Outputs => CompleteOutputs(frame),
                _ => frame.CreateBufferedElement()
            };

            if (frame.Role == ElementRole.Root)
            {
                rootComplete = true;
                return;
            }
            if (frames.Count == 0)
                throw InvalidFormat("The OpenMath source is not valid XML.");
            AddCompletedChild(frames.Peek(), completed);
        }

        private object CompleteRoot(ElementFrame frame)
        {
            RequireStructuralContent(frame);
            if (frame.ChildCount != 1)
                throw InvalidFormat("The OpenMath root must contain one object.");
            if (frame.Children[0] is not ProgramResult program)
                throw InvalidFormat("The OpenMath root must contain one object.");
            if (program.Error is not null)
                throw program.Error;

            try
            {
                result = new MathBlockOpenMathImportResult(builder.Build(), operations);
            }
            catch (InvalidOperationException exception)
            {
                throw InvalidFormat("The OpenMath program is invalid.", exception);
            }
            return RootResult.Instance;
        }

        private static object CompleteProgram(ElementFrame frame)
        {
            try
            {
                CompleteProgramCore(frame);
                return new ProgramResult(null);
            }
            catch (FormatException exception)
            {
                return new ProgramResult(exception);
            }
        }

        private static void CompleteProgramCore(ElementFrame frame)
        {
            RequireOnlyBufferedAttributes(frame.Header.Attributes);
            RequireStructuralElement(frame, "OMA");
            RequireStructuralContent(frame);
            if (frame.ChildCount == 0)
                throw InvalidFormat("An OpenMath application is empty.");
            if (frame.ChildCount != 3)
                throw InvalidFormat("The OpenMath program must contain nodes and outputs.");
            if (frame.Children[0] is not BufferedElement head)
                throw InvalidFormat("An OpenMath symbol is invalid.");
            RequireParsedSymbol(head, ProgramDictionary, "program");
            if (frame.Children[1] is not NodesResult nodes ||
                frame.Children[2] is not OutputsResult outputs)
            {
                throw InvalidFormat("The OpenMath program must contain nodes and outputs.");
            }
            if (nodes.Error is not null)
                throw nodes.Error;
            if (outputs.Error is not null)
                throw outputs.Error;
        }

        private static int CompleteNodes(ElementFrame frame)
        {
            RequireOnlyBufferedAttributes(frame.Header.Attributes);
            RequireStructuralElement(frame, "OMA");
            RequireStructuralContent(frame);
            if (frame.ChildCount == 0)
                throw InvalidFormat("An OpenMath application is empty.");
            if (frame.Children[0] is not BufferedElement head)
                throw InvalidFormat("An OpenMath symbol is invalid.");
            RequireParsedSymbol(head, ProgramDictionary, "nodes");
            return frame.ChildCount - 1;
        }

        private object CompleteNodeCollection(ElementFrame frame)
        {
            try
            {
                nodeCount = CompleteNodes(frame);
                return new NodesResult(nodeCount, frame.DeferredError);
            }
            catch (FormatException exception)
            {
                return new NodesResult(0, exception);
            }
        }

        private static void CompleteOutputsCore(ElementFrame frame)
        {
            RequireOnlyBufferedAttributes(frame.Header.Attributes);
            RequireStructuralElement(frame, "OMA");
            RequireStructuralContent(frame);
            if (frame.ChildCount == 0)
                throw InvalidFormat("An OpenMath application is empty.");
            if (frame.ChildCount < 2)
                throw InvalidFormat("The OpenMath program requires an output.");
            if (frame.Children[0] is not BufferedElement head)
                throw InvalidFormat("An OpenMath symbol is invalid.");
            RequireParsedSymbol(head, ProgramDictionary, "outputs");
            if (frame.DeferredError is not null)
                throw frame.DeferredError;
        }

        private static object CompleteOutputs(ElementFrame frame)
        {
            try
            {
                CompleteOutputsCore(frame);
                return new OutputsResult(null);
            }
            catch (FormatException exception)
            {
                return new OutputsResult(exception);
            }
        }

        private void AddCompletedChild(ElementFrame parent, object child)
        {
            switch (parent.Role)
            {
                case ElementRole.Node:
                case ElementRole.Output:
                case ElementRole.Buffered:
                    parent.AddBufferedChild((BufferedElement)child);
                    break;
                case ElementRole.Nodes when parent.ChildCount > 0:
                    if (child is not BufferedElement node)
                    {
                        parent.RecordError(InvalidFormat("An OpenMath node is invalid."));
                    }
                    else if (parent.DeferredError is null)
                    {
                        try
                        {
                            ParseNode(
                                node,
                                parent.ChildCount - 1,
                                builder,
                                StandardProfile.Value.OperationSymbols,
                                operations);
                        }
                        catch (FormatException exception)
                        {
                            parent.RecordError(exception);
                        }
                    }
                    parent.Children.Add(NodeResult.Instance);
                    break;
                case ElementRole.Outputs when parent.ChildCount > 0:
                    if (child is not BufferedElement output)
                    {
                        parent.RecordError(InvalidFormat("An OpenMath output is invalid."));
                    }
                    else if (parent.DeferredError is null)
                    {
                        try
                        {
                            ParseOutput(output, builder, nodeCount);
                        }
                        catch (FormatException exception)
                        {
                            parent.RecordError(exception);
                        }
                    }
                    parent.Children.Add(OutputResult.Instance);
                    break;
                default:
                    parent.Children.Add(child);
                    break;
            }
        }

        private static void ValidateRootHeader(BufferedHeader header)
        {
            if (header.LocalName != "OMOBJ" || header.NamespaceName != NamespaceUri)
                throw InvalidFormat("Expected the OpenMath OMOBJ element.");
            RequireOnlyBufferedAttributes(header.Attributes, "version", "cdbase", "cdgroup");
            if (RequireBufferedAttribute(header, "version") != StandardVersion)
                throw InvalidFormat("The OpenMath version is not supported.");
            if (RequireBufferedAttribute(header, "cdbase") != ContentDictionaryBase)
                throw InvalidFormat("The OpenMath content dictionary base is not supported.");
            if (RequireBufferedAttribute(header, "cdgroup") != ContentDictionaryGroup)
                throw InvalidFormat("The OpenMath content dictionary group is not supported.");
        }

        private static string RequireBufferedAttribute(BufferedHeader header, string name)
        {
            for (var index = 0; index < header.Attributes.Count; index++)
            {
                var attribute = header.Attributes[index];
                if (attribute.NamespaceName.Length == 0 && attribute.LocalName == name)
                    return attribute.Value;
            }
            throw InvalidFormat($"The OpenMath {name} attribute is missing.");
        }

        private static void RequireStructuralElement(ElementFrame frame, string localName)
        {
            if (frame.Header.LocalName != localName ||
                frame.Header.NamespaceName != NamespaceUri)
            {
                throw InvalidFormat($"Expected the OpenMath {localName} element.");
            }
        }

        private static void RequireStructuralContent(ElementFrame frame)
        {
            if (frame.HasUnsupportedContent)
                throw InvalidFormat("OpenMath element content is invalid.");
        }

        private static BufferedHeader ReadHeader(XmlReader reader)
        {
            var attributes = new BufferedAttribute[reader.AttributeCount];
            var attributeIndex = 0;
            if (reader.MoveToFirstAttribute())
            {
                do
                {
                    var namespaceDeclaration =
                        reader.Prefix == "xmlns" ||
                        (reader.Prefix.Length == 0 && reader.LocalName == "xmlns");
                    attributes[attributeIndex++] = new BufferedAttribute(
                        reader.LocalName,
                        reader.NamespaceURI,
                        reader.Value,
                        namespaceDeclaration);
                }
                while (reader.MoveToNextAttribute());
                reader.MoveToElement();
            }
            return new BufferedHeader(reader.LocalName, reader.NamespaceURI, attributes);
        }
    }

    private sealed class ElementFrame(BufferedHeader header, ElementRole role)
    {
        private List<BufferedElement>? bufferedChildren;
        private List<object>? children;
        private string? bufferedText;
        private System.Text.StringBuilder? bufferedTextBuilder;

        public BufferedHeader Header { get; } = header;
        public ElementRole Role { get; } = role;
        public List<object> Children => children ??= [];
        public int ChildCount => children?.Count ?? 0;
        public FormatException? DeferredError { get; private set; }
        public bool HasUnsupportedContent { get; private set; }

        public ElementRole NextChildRole() => Role switch
        {
            ElementRole.Root when ChildCount == 0 => ElementRole.Program,
            ElementRole.Program when ChildCount == 1 => ElementRole.Nodes,
            ElementRole.Program when ChildCount == 2 => ElementRole.Outputs,
            ElementRole.Nodes when ChildCount > 0 => ElementRole.Node,
            ElementRole.Outputs when ChildCount > 0 => ElementRole.Output,
            _ => ElementRole.Buffered
        };

        public void AddText(string value)
        {
            if (Role is ElementRole.Node or ElementRole.Output or ElementRole.Buffered)
            {
                if (bufferedText is null)
                {
                    bufferedText = value;
                }
                else
                {
                    bufferedTextBuilder ??= new System.Text.StringBuilder(bufferedText);
                    bufferedTextBuilder.Append(value);
                }
                return;
            }
            if (!IsXmlWhitespace(value))
                HasUnsupportedContent = true;
        }

        public void AddUnsupportedContent()
        {
            if (Role is ElementRole.Node or ElementRole.Output or ElementRole.Buffered)
            {
                HasUnsupportedContent = true;
                return;
            }
            HasUnsupportedContent = true;
        }

        public void AddBufferedChild(BufferedElement element) =>
            (bufferedChildren ??= []).Add(element);

        public void RecordError(FormatException exception) =>
            DeferredError ??= exception;

        public BufferedElement CreateBufferedElement() =>
            new(
                Header.LocalName,
                Header.NamespaceName,
                Header.Attributes,
                bufferedChildren?.ToArray() ?? [],
                bufferedTextBuilder?.ToString() ?? bufferedText ?? string.Empty,
                HasUnsupportedContent);
    }

    private readonly record struct BufferedHeader(
        string LocalName,
        string NamespaceName,
        IReadOnlyList<BufferedAttribute> Attributes);

    private readonly record struct BufferedAttribute(
        string LocalName,
        string NamespaceName,
        string Value,
        bool IsNamespaceDeclaration);

    private sealed record BufferedElement(
        string LocalName,
        string NamespaceName,
        IReadOnlyList<BufferedAttribute> Attributes,
        BufferedElement[] Children,
        string Text,
        bool HasUnsupportedContent);

    private sealed record RootResult
    {
        public static RootResult Instance { get; } = new();
    }

    private sealed record ProgramResult(FormatException? Error);

    private sealed record NodesResult(int Count, FormatException? Error);

    private sealed record NodeResult
    {
        public static NodeResult Instance { get; } = new();
    }

    private sealed record OutputsResult(FormatException? Error);

    private sealed record OutputResult
    {
        public static OutputResult Instance { get; } = new();
    }

    private enum ElementRole
    {
        Root,
        Program,
        Nodes,
        Node,
        Outputs,
        Output,
        Buffered
    }
}
