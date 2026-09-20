using System.Globalization;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

public static partial class MathBlockFormulaInterchange
{
    /// <summary>
    /// Imports the visible expression using explicit input types instead of the exact annotation.
    /// </summary>
    public static MathBlockFormulaImportResult Import(
        string source,
        MathBlockFormulaFormat format,
        IReadOnlyDictionary<string, MathBlockType> inputTypes,
        string outputName)
    {
        ArgumentNullException.ThrowIfNull(source);
        ArgumentNullException.ThrowIfNull(inputTypes);
        RequireFormat(format);
        if (source.Length == 0)
            throw new FormatException("The formula source is empty.");
        if (source.Length > MaximumDocumentCharacters)
            throw new FormatException("The formula source exceeds the character limit.");
        if (string.IsNullOrWhiteSpace(outputName) || outputName != outputName.Trim())
            throw new ArgumentException("A canonical output name is required.", nameof(outputName));

        var bindings = CopyBindings(inputTypes);
        var expression = ReadVisibleExpression(source, format);
        RequireFormulaVocabulary(expression, format);
        var state = new VisibleExpressionState(bindings);
        int output;
        try
        {
            output = ParseExpression(expression, state, format, 0);
            var program = state.Builder.Output(outputName, output).Build();
            var exact = MathBlockOpenMath.Import(MathBlockOpenMath.Export(program));
            return new MathBlockFormulaImportResult(exact, outputName, format);
        }
        catch (FormatException)
        {
            throw;
        }
        catch (Exception exception) when (
            exception is ArgumentException or
            InvalidOperationException or
            KeyNotFoundException or
            InvalidDataException or
            ArithmeticException)
        {
            throw new FormatException("The visible formula expression is invalid.", exception);
        }
    }

    /// <summary>
    /// Imports a visible UTF-8 expression using explicit input types instead of the exact annotation.
    /// </summary>
    public static MathBlockFormulaImportResult ImportUtf8(
        ReadOnlySpan<byte> source,
        MathBlockFormulaFormat format,
        IReadOnlyDictionary<string, MathBlockType> inputTypes,
        string outputName)
    {
        if (source.Length == 0)
            throw new FormatException("The formula source is empty.");
        if (source.Length > MaximumDocumentUtf8Bytes)
            throw new FormatException("The formula source exceeds the byte limit.");
        try
        {
            return Import(StrictUtf8.GetString(source), format, inputTypes, outputName);
        }
        catch (DecoderFallbackException exception)
        {
            throw new FormatException("The formula UTF-8 source is invalid.", exception);
        }
    }

    private static Dictionary<string, MathBlockType> CopyBindings(
        IReadOnlyDictionary<string, MathBlockType> source)
    {
        var result = new Dictionary<string, MathBlockType>(source.Count, StringComparer.Ordinal);
        foreach (var item in source)
        {
            if (string.IsNullOrWhiteSpace(item.Key) || item.Key != item.Key.Trim())
                throw new ArgumentException("An input binding name is invalid.", nameof(source));
            result.Add(item.Key, item.Value);
        }
        return result;
    }

    private static FormulaXmlElement ReadVisibleExpression(
        string source,
        MathBlockFormulaFormat format)
    {
        var settings = new XmlReaderSettings
        {
            DtdProcessing = DtdProcessing.Prohibit,
            XmlResolver = null,
            MaxCharactersInDocument = MaximumDocumentCharacters,
            IgnoreComments = false,
            IgnoreProcessingInstructions = false,
            IgnoreWhitespace = false,
            CloseInput = true
        };
        try
        {
            using var input = new StringReader(source);
            using var reader = XmlReader.Create(input, settings);
            FormulaXmlElement? root = null;
            while (reader.Read())
            {
                if (reader.NodeType is XmlNodeType.Comment or
                    XmlNodeType.ProcessingInstruction or
                    XmlNodeType.DocumentType)
                {
                    throw new FormatException(
                        "The formula document contains unsupported content.");
                }
                if (reader.NodeType == XmlNodeType.Element)
                {
                    if (root is not null)
                        throw new FormatException("The formula source is not valid XML.");
                    root = BufferCurrentElement(reader);
                    continue;
                }
                if ((reader.NodeType is XmlNodeType.Text or XmlNodeType.CDATA) &&
                    !IsFormulaWhitespace(reader.Value))
                {
                    throw new FormatException("The formula source is not valid XML.");
                }
            }
            return root is null
                ? throw new FormatException("The formula source is not valid XML.")
                : LocateVisibleExpression(root, format);
        }
        catch (XmlException exception)
        {
            throw new FormatException("The formula source is not valid XML.", exception);
        }
    }

    private static FormulaXmlElement LocateVisibleExpression(
        FormulaXmlElement root,
        MathBlockFormulaFormat format)
    {
        var rootName = format == MathBlockFormulaFormat.OpenMath ? "OMOBJ" : "math";
        var rootNamespace = format == MathBlockFormulaFormat.OpenMath
            ? OpenMathNamespace
            : MathMlNamespace;
        if (!IsFormulaElement(root, rootName, rootNamespace))
            throw new FormatException("The formula document root does not match its format.");
        RequireFormulaWhitespace(root);
        if (root.Children.Length != 1)
            throw new FormatException("The formula visible expression is missing.");

        var child = root.Children[0];

        if (format == MathBlockFormulaFormat.ContentMathMl &&
            IsFormulaElement(child, "semantics", MathMlNamespace))
            return RequireMathMlSemanticBody(child);

        if (format == MathBlockFormulaFormat.OpenMath &&
            IsFormulaElement(child, "OMATTR", OpenMathNamespace))
        {
            RequireFormulaWhitespace(child);
            if (child.Children.Length != 2 ||
                !IsFormulaElement(child.Children[0], "OMATP", OpenMathNamespace))
            {
                throw new FormatException("The OpenMath formula attribution is invalid.");
            }
            return child.Children[1];
        }

        return child;
    }

    private static void RequireFormulaVocabulary(
        FormulaXmlElement root,
        MathBlockFormulaFormat format)
    {
        var expectedNamespace = format == MathBlockFormulaFormat.OpenMath
            ? OpenMathNamespace
            : MathMlNamespace;
        var pending = new Stack<FormulaXmlElement>();
        pending.Push(root);
        while (pending.Count != 0)
        {
            var element = pending.Pop();
            if (element.NamespaceName != expectedNamespace)
                throw new FormatException("The formula expression mixes XML vocabularies.");
            if (format == MathBlockFormulaFormat.ContentMathMl &&
                IsFormulaElement(element, "semantics", MathMlNamespace))
            {
                pending.Push(RequireMathMlSemanticBody(element));
                continue;
            }
            if (format == MathBlockFormulaFormat.OpenMath &&
                IsFormulaElement(element, "OMATTR", OpenMathNamespace))
            {
                if (element.Children.Length != 2 ||
                    !IsFormulaElement(element.Children[0], "OMATP", OpenMathNamespace))
                {
                    throw new FormatException("An OpenMath attribution is invalid.");
                }
                pending.Push(element.Children[1]);
                continue;
            }
            for (var index = element.Children.Length - 1; index >= 0; index--)
                pending.Push(element.Children[index]);
        }
    }

    private static FormulaXmlElement RequireMathMlSemanticBody(FormulaXmlElement element)
    {
        RequireFormulaWhitespace(element);
        if (element.Children.Length == 0)
            throw new FormatException("A Content MathML semantics element is empty.");
        for (var index = 1; index < element.Children.Length; index++)
        {
            var annotation = element.Children[index];
            if (annotation.NamespaceName != MathMlNamespace ||
                annotation.LocalName is not ("annotation" or "annotation-xml"))
            {
                throw new FormatException("A Content MathML semantics element is invalid.");
            }
        }
        return element.Children[0];
    }

    private static FormulaXmlElement BufferCurrentElement(XmlReader reader)
    {
        using var subtree = reader.ReadSubtree();
        var frames = new Stack<FormulaXmlFrame>();
        FormulaXmlElement? root = null;
        var elementCount = 0;
        while (subtree.Read())
        {
            switch (subtree.NodeType)
            {
                case XmlNodeType.Element:
                    elementCount++;
                    if (elementCount > MaximumExpressionElements)
                        throw new FormatException("The formula expression exceeds the element limit.");
                    var frame = new FormulaXmlFrame(
                        subtree,
                        frames.Count == 0 ? null : frames.Peek().ContentDictionaryBase,
                        frames.Count == 0 ? null : frames.Peek().ContentDictionaryGroup);
                    if (subtree.IsEmptyElement)
                    {
                        AddCompletedFormulaElement(frames, ref root, frame.Complete());
                    }
                    else
                    {
                        frames.Push(frame);
                    }
                    break;
                case XmlNodeType.EndElement:
                    if (frames.Count == 0)
                        throw new FormatException("The formula source is not valid XML.");
                    AddCompletedFormulaElement(frames, ref root, frames.Pop().Complete());
                    break;
                case XmlNodeType.Text:
                case XmlNodeType.CDATA:
                case XmlNodeType.Whitespace:
                case XmlNodeType.SignificantWhitespace:
                    if (frames.Count == 0)
                    {
                        if (!IsFormulaWhitespace(subtree.Value))
                            throw new FormatException("The formula expression is invalid.");
                    }
                    else
                    {
                        frames.Peek().Text.Append(subtree.Value);
                    }
                    break;
                case XmlNodeType.Comment:
                case XmlNodeType.ProcessingInstruction:
                case XmlNodeType.DocumentType:
                case XmlNodeType.EntityReference:
                    throw new FormatException(
                        "The formula document contains unsupported content.");
            }
        }
        if (frames.Count != 0 || root is null)
            throw new FormatException("The formula source is not valid XML.");
        return root;
    }

    private static void AddCompletedFormulaElement(
        Stack<FormulaXmlFrame> frames,
        ref FormulaXmlElement? root,
        FormulaXmlElement element)
    {
        if (frames.Count != 0)
        {
            frames.Peek().Children.Add(element);
            return;
        }
        if (root is not null)
            throw new FormatException("The formula expression contains multiple roots.");
        root = element;
    }

    private static int ParseExpression(
        FormulaXmlElement element,
        VisibleExpressionState state,
        MathBlockFormulaFormat format,
        int depth)
    {
        if (depth > MaximumExpressionDepth)
            throw new FormatException("The formula expression exceeds the nesting limit.");

        if (IsFormulaElement(element, "OMATTR", OpenMathNamespace))
        {
            RequireFormulaWhitespace(element);
            if (element.Children.Length != 2 ||
                !IsFormulaElement(element.Children[0], "OMATP", OpenMathNamespace))
            {
                throw new FormatException("An OpenMath attribution is invalid.");
            }
            var result = ParseExpression(element.Children[1], state, format, depth + 1);
            RegisterElementId(element, result, state);
            return result;
        }
        if (IsFormulaElement(element, "semantics", MathMlNamespace))
        {
            var result = ParseExpression(
                RequireMathMlSemanticBody(element),
                state,
                format,
                depth + 1);
            RegisterElementId(element, result, state);
            return result;
        }
        if (IsFormulaElement(element, "OMR", OpenMathNamespace) ||
            IsFormulaElement(element, "share", MathMlNamespace))
        {
            RequireNoFormulaChildrenOrText(element);
            var reference = RequireFormulaAttribute(
                element,
                IsFormulaElement(element, "OMR", OpenMathNamespace) ? "href" : "src");
            if (!reference.StartsWith('#') || reference.Length == 1 ||
                !state.Ids.TryGetValue(reference[1..], out var referenced))
            {
                throw new FormatException("A formula share reference is invalid.");
            }
            return referenced;
        }
        if (IsFormulaElement(element, "OMV", OpenMathNamespace) ||
            IsFormulaElement(element, "ci", MathMlNamespace))
        {
            return ParseVariable(element, state);
        }
        if (IsFormulaNumber(element))
        {
            var result = state.Builder.Constant(MathBlockValue.Scalar(ParseFormulaDouble(element)));
            RegisterElementId(element, result, state);
            return result;
        }
        if (TryParseFormulaBoolean(element, out var boolean))
        {
            var result = state.Builder.Constant(MathBlockValue.Boolean(boolean));
            RegisterElementId(element, result, state);
            return result;
        }
        if (IsFormulaApplication(element))
            return ParseApplication(element, state, format, depth);

        throw new FormatException("A formula expression element is not supported.");
    }

    private static int ParseVariable(
        FormulaXmlElement element,
        VisibleExpressionState state)
    {
        if (element.Children.Length != 0)
            throw new FormatException("A formula variable is invalid.");
        string wireName;
        if (IsFormulaElement(element, "OMV", OpenMathNamespace))
        {
            RequireNoFormulaChildrenOrText(element);
            wireName = RequireFormulaAttribute(element, "name");
        }
        else
        {
            wireName = element.Text.Trim();
        }
        if (wireName.Length == 0)
            throw new FormatException("A formula variable name is empty.");

        string name;
        MathBlockType type;
        if (state.Bindings.TryGetValue(wireName, out type))
        {
            name = wireName;
        }
        else
        {
            name = XmlConvert.DecodeName(wireName);
            if (!state.Bindings.TryGetValue(name, out type))
                throw new FormatException($"Formula input '{wireName}' has no type binding.");
        }

        if (!state.Variables.TryGetValue(name, out var result))
        {
            result = state.Builder.Input(name, type);
            state.Variables.Add(name, result);
        }
        RegisterElementId(element, result, state);
        return result;
    }

    private static int ParseApplication(
        FormulaXmlElement element,
        VisibleExpressionState state,
        MathBlockFormulaFormat format,
        int depth)
    {
        RequireFormulaWhitespace(element);
        if (element.Children.Length == 0)
            throw new FormatException("A formula application is empty.");
        var symbol = ParseFormulaSymbol(
            element.Children[0],
            element.Children.Length - 1,
            true);
        if (symbol.Dictionary == FormulaValueDictionary &&
            symbol.ContentDictionaryBase == ContentDictionaryBase)
        {
            var value = ParseStructuredFormulaValue(element, symbol.Name);
            var constant = state.Builder.Constant(value);
            RegisterElementId(element, constant, state);
            return constant;
        }
        if (!TryGetOperation(symbol, out var operation) || operation is null)
        {
            throw new FormatException(
                $"Formula operation symbol '{symbol.Dictionary}:{symbol.Name}' is not supported.");
        }
        var argumentCount = element.Children.Length - 1;
        if (argumentCount > operation.Arity &&
            IsAssociativeFormulaOperation(symbol, operation))
        {
            var foldedResult = ParseExpression(
                element.Children[1],
                state,
                format,
                depth + 1);
            for (var index = 2; index < element.Children.Length; index++)
            {
                var right = ParseExpression(
                    element.Children[index],
                    state,
                    format,
                    depth + 1);
                foldedResult = state.Builder.Apply(
                    operation.Identifier,
                    operation.Version,
                    foldedResult,
                    right);
            }
            RegisterElementId(element, foldedResult, state);
            return foldedResult;
        }
        if (argumentCount != operation.Arity)
            throw new FormatException("A formula operation has the wrong arity.");
        var inputs = new int[argumentCount];
        for (var index = 0; index < inputs.Length; index++)
        {
            inputs[index] = ParseExpression(
                element.Children[index + 1],
                state,
                format,
                depth + 1);
        }
        var result = state.Builder.Apply(operation.Identifier, operation.Version, inputs);
        RegisterElementId(element, result, state);
        return result;
    }

    private static bool IsAssociativeFormulaOperation(
        MathBlockFormulaSymbol symbol,
        MathBlockOperation operation) =>
        symbol.ContentDictionaryBase == OfficialContentDictionaryBase &&
        (symbol.Dictionary, symbol.Name, operation.Identifier) is
            ("arith1", "plus", "scalar.add") or
            ("arith1", "times", "scalar.multiply") or
            ("logic1", "and", "boolean.and") or
            ("logic1", "or", "boolean.or") or
            ("logic1", "xor", "boolean.xor");

    private static MathBlockFormulaSymbol ParseFormulaSymbol(
        FormulaXmlElement element,
        int applicationArity,
        bool allowPredefined)
    {
        if (IsFormulaElement(element, "OMS", OpenMathNamespace))
        {
            RequireNoFormulaChildrenOrText(element);
            var dictionary = RequireFormulaAttribute(element, "cd");
            var name = RequireFormulaAttribute(element, "name");
            return new MathBlockFormulaSymbol(
                FormulaDictionaryBase(element, dictionary),
                dictionary,
                name);
        }
        if (IsFormulaElement(element, "csymbol", MathMlNamespace))
        {
            if (element.Children.Length != 0)
                throw new FormatException("A Content MathML symbol is invalid.");
            var dictionary = RequireFormulaAttribute(element, "cd");
            var name = element.Text.Trim();
            if (name.Length == 0)
                throw new FormatException("A Content MathML symbol name is empty.");
            return new MathBlockFormulaSymbol(
                FormulaDictionaryBase(element, dictionary),
                dictionary,
                name);
        }
        if (allowPredefined && element.NamespaceName == MathMlNamespace &&
            element.Children.Length == 0 && IsFormulaWhitespace(element.Text) &&
            TryGetPredefinedSymbol(element.LocalName, applicationArity, out var symbol))
        {
            return symbol;
        }
        throw new FormatException("A formula application head is not supported.");
    }

    private static string FormulaDictionaryBase(
        FormulaXmlElement element,
        string dictionary)
    {
        if (element.ContentDictionaryBase is not null)
            return element.ContentDictionaryBase;

        var isMathBlocksDictionary =
            dictionary == FormulaOperationDictionary ||
            dictionary == FormulaValueDictionary ||
            dictionary == FormulaDictionary;
        if (element.ContentDictionaryGroup is not null)
        {
            if (element.ContentDictionaryGroup != ContentDictionaryGroup)
                return string.Empty;
            return isMathBlocksDictionary
                ? ContentDictionaryBase
                : OfficialContentDictionaryBase;
        }

        return element.NamespaceName == OpenMathNamespace && !isMathBlocksDictionary
            ? OfficialContentDictionaryBase
            : string.Empty;
    }

    private static bool TryGetPredefinedSymbol(
        string localName,
        int arity,
        out MathBlockFormulaSymbol symbol)
    {
        var pair = localName switch
        {
            "abs" => ("arith1", "abs"),
            "and" => ("logic1", "and"),
            "arccos" => ("transc1", "arccos"),
            "arcsin" => ("transc1", "arcsin"),
            "arctan" => ("transc1", "arctan"),
            "arccosh" => ("transc1", "arccosh"),
            "arcsinh" => ("transc1", "arcsinh"),
            "arctanh" => ("transc1", "arctanh"),
            "arg" => ("complex1", "argument"),
            "ceiling" => ("rounding1", "ceiling"),
            "conjugate" => ("complex1", "conjugate"),
            "cos" => ("transc1", "cos"),
            "cosh" => ("transc1", "cosh"),
            "divide" => ("arith1", "divide"),
            "eq" => ("relation1", "eq"),
            "exp" => ("transc1", "exp"),
            "floor" => ("rounding1", "floor"),
            "geq" => ("relation1", "geq"),
            "gt" => ("relation1", "gt"),
            "leq" => ("relation1", "leq"),
            "ln" => ("transc1", "ln"),
            "lt" => ("relation1", "lt"),
            "minus" when arity == 1 => ("arith1", "unary_minus"),
            "minus" when arity == 2 => ("arith1", "minus"),
            "neq" => ("relation1", "neq"),
            "not" => ("logic1", "not"),
            "or" => ("logic1", "or"),
            "plus" => ("arith1", "plus"),
            "power" => ("arith1", "power"),
            "sin" => ("transc1", "sin"),
            "sinh" => ("transc1", "sinh"),
            "tan" => ("transc1", "tan"),
            "tanh" => ("transc1", "tanh"),
            "times" => ("arith1", "times"),
            "xor" => ("logic1", "xor"),
            _ => default
        };
        if (pair == default)
        {
            symbol = default;
            return false;
        }
        symbol = new MathBlockFormulaSymbol(
            OfficialContentDictionaryBase,
            pair.Item1,
            pair.Item2);
        return true;
    }

    private static MathBlockValue ParseStructuredFormulaValue(
        FormulaXmlElement application,
        string name)
    {
        var children = application.Children;
        try
        {
            return name switch
            {
                "vector" => ParseFormulaVector(children),
                "matrix" => ParseFormulaMatrix(children),
                "complex" => MathBlockValue.Complex(ParseFormulaComplex(application)),
                "complex-vector" => ParseFormulaComplexVector(children),
                "complex-matrix" => ParseFormulaComplexMatrix(children),
                "point-set" => ParseFormulaPointSet(children),
                "graph" => ParseFormulaGraph(children),
                "run-set" => ParseFormulaRunSet(children),
                "boolean-vector" => ParseFormulaBooleanVector(children),
                _ => throw new FormatException(
                    $"Formula value symbol '{name}' is not supported.")
            };
        }
        catch (FormatException)
        {
            throw;
        }
        catch (Exception exception) when (
            exception is ArgumentException or InvalidDataException or ArithmeticException)
        {
            throw new FormatException("A structured formula constant is invalid.", exception);
        }
    }

    private static MathBlockValue ParseFormulaVector(FormulaXmlElement[] children)
    {
        var values = new double[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseFormulaDouble(children[index + 1]);
        return MathBlockValue.Vector(values);
    }

    private static MathBlockValue ParseFormulaMatrix(FormulaXmlElement[] children)
    {
        if (children.Length < 3)
            throw new FormatException("A formula matrix is invalid.");
        var rows = ParseFormulaInteger(children[1]);
        var columns = ParseFormulaInteger(children[2]);
        if (rows <= 0 || columns <= 0 || rows > int.MaxValue / columns ||
            children.Length - 3 != rows * columns)
        {
            throw new FormatException("A formula matrix shape is invalid.");
        }
        var values = new double[rows * columns];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseFormulaDouble(children[index + 3]);
        return MathBlockValue.Matrix(new MathBlockMatrix(rows, columns, values));
    }

    private static MathBlockComplexValue ParseFormulaComplex(FormulaXmlElement element)
    {
        var children = element.Children;
        if (!IsFormulaApplication(element) || children.Length != 3)
            throw new FormatException("A formula complex value is invalid.");
        RequireFormulaWhitespace(element);
        var symbol = ParseFormulaSymbol(children[0], children.Length - 1, false);
        if (symbol.ContentDictionaryBase != ContentDictionaryBase ||
            symbol.Dictionary != FormulaValueDictionary ||
            symbol.Name != "complex")
        {
            throw new FormatException("A formula complex value is invalid.");
        }
        return new MathBlockComplexValue(
            ParseFormulaDouble(children[1]),
            ParseFormulaDouble(children[2]));
    }

    private static MathBlockValue ParseFormulaComplexVector(FormulaXmlElement[] children)
    {
        var values = new MathBlockComplexValue[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseFormulaComplex(children[index + 1]);
        return MathBlockValue.ComplexVector(values);
    }

    private static MathBlockValue ParseFormulaComplexMatrix(FormulaXmlElement[] children)
    {
        if (children.Length < 3)
            throw new FormatException("A formula complex matrix is invalid.");
        var rows = ParseFormulaInteger(children[1]);
        var columns = ParseFormulaInteger(children[2]);
        if (rows <= 0 || columns <= 0 || rows > int.MaxValue / columns ||
            children.Length - 3 != rows * columns)
        {
            throw new FormatException("A formula complex matrix shape is invalid.");
        }
        var values = new MathBlockComplexValue[rows * columns];
        for (var index = 0; index < values.Length; index++)
            values[index] = ParseFormulaComplex(children[index + 3]);
        return MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(rows, columns, values));
    }

    private static MathBlockValue ParseFormulaPointSet(FormulaXmlElement[] children)
    {
        var values = new MathBlockPoint[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var point = children[index + 1];
            if (!IsFormulaApplication(point) || point.Children.Length != 3)
                throw new FormatException("A formula point is invalid.");
            RequireFormulaWhitespace(point);
            var symbol = ParseFormulaSymbol(point.Children[0], point.Children.Length - 1, false);
            if (symbol.ContentDictionaryBase != ContentDictionaryBase ||
                symbol.Dictionary != FormulaValueDictionary || symbol.Name != "point")
            {
                throw new FormatException("A formula point is invalid.");
            }
            values[index] = new MathBlockPoint(
                ParseFormulaDouble(point.Children[1]),
                ParseFormulaDouble(point.Children[2]));
        }
        return MathBlockValue.PointSet(new MathBlockPointSet(values));
    }

    private static MathBlockValue ParseFormulaGraph(FormulaXmlElement[] children)
    {
        if (children.Length < 2)
            throw new FormatException("A formula graph is invalid.");
        var vertexCount = ParseFormulaInteger(children[1]);
        var edges = new MathBlockGraphEdge[children.Length - 2];
        for (var index = 0; index < edges.Length; index++)
        {
            var edge = children[index + 2];
            if (!IsFormulaApplication(edge) || edge.Children.Length != 4)
                throw new FormatException("A formula graph edge is invalid.");
            RequireFormulaWhitespace(edge);
            var symbol = ParseFormulaSymbol(edge.Children[0], edge.Children.Length - 1, false);
            if (symbol.ContentDictionaryBase != ContentDictionaryBase ||
                symbol.Dictionary != FormulaValueDictionary || symbol.Name != "edge")
            {
                throw new FormatException("A formula graph edge is invalid.");
            }
            edges[index] = new MathBlockGraphEdge(
                ParseFormulaInteger(edge.Children[1]),
                ParseFormulaInteger(edge.Children[2]),
                ParseFormulaDouble(edge.Children[3]));
        }
        return MathBlockValue.Graph(new MathBlockGraph(vertexCount, edges));
    }

    private static MathBlockValue ParseFormulaRunSet(FormulaXmlElement[] children)
    {
        var values = new MathBlockRun[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            var run = children[index + 1];
            if (!IsFormulaApplication(run) || run.Children.Length != 4)
                throw new FormatException("A formula run is invalid.");
            RequireFormulaWhitespace(run);
            var symbol = ParseFormulaSymbol(run.Children[0], run.Children.Length - 1, false);
            if (symbol.ContentDictionaryBase != ContentDictionaryBase ||
                symbol.Dictionary != FormulaValueDictionary || symbol.Name != "run")
            {
                throw new FormatException("A formula run is invalid.");
            }
            values[index] = new MathBlockRun(
                ParseFormulaInteger(run.Children[1]),
                ParseFormulaInteger(run.Children[2]),
                ParseFormulaDouble(run.Children[3]));
        }
        return MathBlockValue.RunSet(new MathBlockRunSet(values));
    }

    private static MathBlockValue ParseFormulaBooleanVector(FormulaXmlElement[] children)
    {
        var values = new bool[children.Length - 1];
        for (var index = 0; index < values.Length; index++)
        {
            if (!TryParseFormulaBoolean(children[index + 1], out values[index]))
                throw new FormatException("A formula Boolean vector is invalid.");
        }
        return MathBlockValue.BooleanVector(values);
    }

    private static bool TryParseFormulaBoolean(
        FormulaXmlElement element,
        out bool value)
    {
        value = false;
        if (element.NamespaceName == MathMlNamespace &&
            element.Children.Length == 0 && IsFormulaWhitespace(element.Text) &&
            element.LocalName is "true" or "false")
        {
            value = element.LocalName == "true";
            return true;
        }
        MathBlockFormulaSymbol symbol;
        try
        {
            symbol = ParseFormulaSymbol(element, 0, false);
        }
        catch (FormatException)
        {
            return false;
        }
        if ((symbol.Dictionary == "logic1" &&
             symbol.ContentDictionaryBase == OfficialContentDictionaryBase) ||
            (symbol.Dictionary == FormulaValueDictionary &&
             symbol.ContentDictionaryBase == ContentDictionaryBase))
        {
            if (symbol.Name == "true")
            {
                value = true;
                return true;
            }
            if (symbol.Name == "false")
                return true;
        }
        return false;
    }

    private static bool IsFormulaNumber(FormulaXmlElement element) =>
        IsFormulaElement(element, "OMF", OpenMathNamespace) ||
        IsFormulaElement(element, "OMI", OpenMathNamespace) ||
        IsFormulaElement(element, "cn", MathMlNamespace);

    private static double ParseFormulaDouble(FormulaXmlElement element)
    {
        if (element.Children.Length != 0)
            throw new FormatException("A formula number is invalid.");
        if (IsFormulaElement(element, "OMF", OpenMathNamespace))
        {
            RequireNoFormulaChildrenOrText(element);
            var hexadecimal = GetFormulaAttribute(element, "hex");
            var decimalValue = GetFormulaAttribute(element, "dec");
            if ((hexadecimal is null) == (decimalValue is null))
                throw new FormatException("An OpenMath formula float is invalid.");
            if (hexadecimal is not null)
                return ParseFormulaHexDouble(hexadecimal);
            if (!double.TryParse(
                    decimalValue,
                    NumberStyles.Float,
                    CultureInfo.InvariantCulture,
                    out var openMathValue) ||
                !double.IsFinite(openMathValue))
            {
                throw new FormatException("An OpenMath formula float is invalid.");
            }
            return openMathValue;
        }
        var text = element.Text.Trim();
        if (IsFormulaElement(element, "OMI", OpenMathNamespace))
            return ParseFormulaArbitraryInteger(text, "An OpenMath formula integer is invalid.");
        if (!IsFormulaElement(element, "cn", MathMlNamespace))
            throw new FormatException("A formula number is invalid.");
        var type = GetFormulaAttribute(element, "type") ?? "real";
        if (type == "hexdouble")
            return ParseFormulaHexDouble(text);
        if (type == "integer")
            return ParseFormulaArbitraryInteger(text, "A Content MathML integer is invalid.");
        if (type is not ("real" or "double") ||
            !double.TryParse(text, NumberStyles.Float, CultureInfo.InvariantCulture, out var value) ||
            !double.IsFinite(value))
        {
            throw new FormatException("A Content MathML number is invalid.");
        }
        return value;
    }

    private static double ParseFormulaArbitraryInteger(string text, string message)
    {
        var firstDigit = text.Length > 0 && text[0] is '+' or '-' ? 1 : 0;
        if (firstDigit == text.Length)
            throw new FormatException(message);
        for (var index = firstDigit; index < text.Length; index++)
        {
            if (text[index] is < '0' or > '9')
                throw new FormatException(message);
        }
        if (!double.TryParse(
                text,
                NumberStyles.AllowLeadingSign,
                CultureInfo.InvariantCulture,
                out var value) ||
            !double.IsFinite(value))
        {
            throw new FormatException(message);
        }
        return value;
    }

    private static double ParseFormulaHexDouble(string text)
    {
        if (text.Length != 16 || text != text.ToUpperInvariant() ||
            !ulong.TryParse(
                text,
                NumberStyles.AllowHexSpecifier,
                CultureInfo.InvariantCulture,
                out var bits))
        {
            throw new FormatException("A formula hexadecimal binary64 value is invalid.");
        }
        var value = BitConverter.Int64BitsToDouble(unchecked((long)bits));
        if (!double.IsFinite(value))
            throw new FormatException("A formula binary64 value must be finite.");
        return value;
    }

    private static int ParseFormulaInteger(FormulaXmlElement element)
    {
        if (element.Children.Length != 0)
            throw new FormatException("A formula integer is invalid.");
        var text = element.Text.Trim();
        if (IsFormulaElement(element, "OMI", OpenMathNamespace) ||
            (IsFormulaElement(element, "cn", MathMlNamespace) &&
             GetFormulaAttribute(element, "type") == "integer"))
        {
            if (int.TryParse(
                    text,
                    NumberStyles.AllowLeadingSign,
                    CultureInfo.InvariantCulture,
                    out var value) &&
                text == value.ToString(CultureInfo.InvariantCulture))
            {
                return value;
            }
        }
        throw new FormatException("A formula integer is invalid.");
    }

    private static bool IsFormulaApplication(FormulaXmlElement element) =>
        IsFormulaElement(element, "OMA", OpenMathNamespace) ||
        IsFormulaElement(element, "apply", MathMlNamespace);

    private static void RegisterElementId(
        FormulaXmlElement element,
        int nodeIndex,
        VisibleExpressionState state)
    {
        var id = GetFormulaAttribute(element, "id");
        if (id is null)
            return;
        if (id.Length == 0 || !state.Ids.TryAdd(id, nodeIndex))
            throw new FormatException("A formula node identifier is invalid or duplicated.");
    }

    private static string RequireFormulaAttribute(
        FormulaXmlElement element,
        string name) =>
        GetFormulaAttribute(element, name) ??
        throw new FormatException($"The formula {name} attribute is missing.");

    private static string? GetFormulaAttribute(
        FormulaXmlElement element,
        string name)
    {
        for (var index = 0; index < element.Attributes.Length; index++)
        {
            var attribute = element.Attributes[index];
            if (!attribute.IsNamespaceDeclaration &&
                attribute.NamespaceName.Length == 0 &&
                attribute.LocalName == name)
            {
                return attribute.Value;
            }
        }
        return null;
    }

    private static void RequireNoFormulaChildrenOrText(FormulaXmlElement element)
    {
        if (element.Children.Length != 0 || !IsFormulaWhitespace(element.Text))
            throw new FormatException("A formula token contains unsupported content.");
    }

    private static void RequireFormulaWhitespace(FormulaXmlElement element)
    {
        if (!IsFormulaWhitespace(element.Text))
            throw new FormatException("A formula application contains text.");
    }

    private static bool IsFormulaWhitespace(string value)
    {
        for (var index = 0; index < value.Length; index++)
            if (value[index] is not (' ' or '\t' or '\r' or '\n'))
                return false;
        return true;
    }

    private static bool IsFormulaElement(
        FormulaXmlElement element,
        string localName,
        string namespaceName) =>
        element.LocalName == localName && element.NamespaceName == namespaceName;

    private sealed class VisibleExpressionState(
        IReadOnlyDictionary<string, MathBlockType> bindings)
    {
        public MathBlockProgramBuilder Builder { get; } =
            new(MathBlockCatalog.Standard);
        public IReadOnlyDictionary<string, MathBlockType> Bindings { get; } = bindings;
        public Dictionary<string, int> Variables { get; } = new(StringComparer.Ordinal);
        public Dictionary<string, int> Ids { get; } = new(StringComparer.Ordinal);
    }

    private sealed class FormulaXmlFrame
    {
        public FormulaXmlFrame(
            XmlReader reader,
            string? inheritedContentDictionaryBase,
            string? inheritedContentDictionaryGroup)
        {
            LocalName = reader.LocalName;
            NamespaceName = reader.NamespaceURI;
            ContentDictionaryBase =
                reader.GetAttribute("cdbase") ?? inheritedContentDictionaryBase;
            ContentDictionaryGroup =
                reader.GetAttribute("cdgroup") ?? inheritedContentDictionaryGroup;
            var attributes = new FormulaXmlAttribute[reader.AttributeCount];
            var index = 0;
            if (reader.MoveToFirstAttribute())
            {
                do
                {
                    var namespaceDeclaration =
                        reader.Prefix == "xmlns" ||
                        (reader.Prefix.Length == 0 && reader.LocalName == "xmlns");
                    attributes[index++] = new FormulaXmlAttribute(
                        reader.LocalName,
                        reader.NamespaceURI,
                        reader.Value,
                        namespaceDeclaration);
                }
                while (reader.MoveToNextAttribute());
                reader.MoveToElement();
            }
            Attributes = attributes;
        }

        public string LocalName { get; }
        public string NamespaceName { get; }
        public string? ContentDictionaryBase { get; }
        public string? ContentDictionaryGroup { get; }
        public FormulaXmlAttribute[] Attributes { get; }
        public List<FormulaXmlElement> Children { get; } = [];
        public StringBuilder Text { get; } = new();

        public FormulaXmlElement Complete() => new(
            LocalName,
            NamespaceName,
            ContentDictionaryBase,
            ContentDictionaryGroup,
            Attributes,
            Children.ToArray(),
            Text.ToString());
    }

    private sealed record FormulaXmlElement(
        string LocalName,
        string NamespaceName,
        string? ContentDictionaryBase,
        string? ContentDictionaryGroup,
        FormulaXmlAttribute[] Attributes,
        FormulaXmlElement[] Children,
        string Text);

    private readonly record struct FormulaXmlAttribute(
        string LocalName,
        string NamespaceName,
        string Value,
        bool IsNamespaceDeclaration);
}
