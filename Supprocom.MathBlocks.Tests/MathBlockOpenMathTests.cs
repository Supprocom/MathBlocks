using System.Buffers;
using System.Globalization;
using System.Security.Cryptography;
using System.Text;
using System.Xml.Linq;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockOpenMathTests
{
    [Fact]
    public void Export_and_import_preserve_program_topology_and_operation_order()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var width = builder.Input("width", MathBlockType.Scalar(MathBlockUnit.Basis0));
        var height = builder.Input("height", MathBlockType.Scalar(MathBlockUnit.Basis0));
        var offset = builder.Constant(MathBlockValue.Scalar(2d, MathBlockUnit.Basis0));
        var adjustedWidth = builder.Apply("scalar.add", inputs: [width, offset]);
        var area = builder.Apply("scalar.multiply", inputs: [adjustedWidth, height]);
        var program = builder
            .Output("adjusted width", adjustedWidth)
            .Output("area", area)
            .Build();

        var source = MathBlockOpenMath.Export(program);
        var imported = MathBlockOpenMath.Import(source);
        var output = imported.Program.Evaluate(new Dictionary<string, MathBlockValue>
        {
            ["width"] = MathBlockValue.Scalar(6d, MathBlockUnit.Basis0),
            ["height"] = MathBlockValue.Scalar(4d, MathBlockUnit.Basis0)
        });

        Assert.Equal("2.0", MathBlockOpenMath.StandardVersion);
        Assert.Equal("application/openmath+xml", MathBlockOpenMath.MediaType);
        Assert.Equal("1", MathBlockOpenMath.ProfileVersion);
        Assert.Equal("http://www.w3.org/2006/12/xml-c14n11", MathBlockOpenMath.CanonicalizationAlgorithm);
        Assert.Equal(16 * 1024 * 1024, MathBlockOpenMath.MaximumDocumentCharacters);
        Assert.Equal(50_331_651, MathBlockOpenMath.MaximumDocumentUtf8Bytes);
        Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
        Assert.Equal(source, MathBlockOpenMath.Export(imported.Program));
        Assert.Equal(
            ["scalar.add@1", "scalar.multiply@1"],
            imported.Operations.Select(operation => operation.Identity));
        Assert.Equal(8d, output["adjusted width"].AsScalar());
        Assert.Equal(32d, output["area"].AsScalar());
    }

    [Fact]
    public void Export_and_import_cover_every_standard_operation()
    {
        Assert.Equal(337, MathBlockCatalog.Standard.Operations.Count);

        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var regressionCase = operation.RegressionCases[0];
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var inputs = new int[regressionCase.Inputs.Count];
            for (var index = 0; index < inputs.Length; index++)
                inputs[index] = builder.Constant(regressionCase.Inputs[index]);
            var result = builder.Apply(operation.Identifier, operation.Version, inputs);
            var program = builder.Output("result", result).Build();

            var source = MathBlockOpenMath.Export(program);
            var imported = MathBlockOpenMath.Import(source);

            Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
            Assert.Equal(source, MathBlockOpenMath.Export(imported.Program));
            Assert.Equal(Encoding.UTF8.GetBytes(source), MathBlockOpenMath.ExportUtf8(program));
            Assert.Single(imported.Operations);
            Assert.Same(operation, imported.Operations[0]);
        }
    }

    [Fact]
    public void Export_and_import_preserve_every_value_kind_and_binary64_bits()
    {
        var unit = new MathBlockUnit(
            new MathRational(1, 2),
            new MathRational(-2, 3),
            new MathRational(5),
            new MathRational(-7, 11));
        MathBlockValue[] values =
        [
            MathBlockValue.Scalar(-0d, unit),
            MathBlockValue.Boolean(true),
            MathBlockValue.Complex(new MathBlockComplexValue(-0d, double.Epsilon), unit),
            MathBlockValue.Vector([1.5d, -0d, double.MaxValue], unit),
            MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, -2d, 3d, -0d]), unit),
            MathBlockValue.ComplexVector(
                [new MathBlockComplexValue(1d, -2d), new MathBlockComplexValue(-0d, 4d)],
                unit),
            MathBlockValue.ComplexMatrix(
                new MathBlockComplexMatrix(
                    1,
                    2,
                    [new MathBlockComplexValue(1d, 2d), new MathBlockComplexValue(-3d, -0d)]),
                unit),
            MathBlockValue.PointSet(
                new MathBlockPointSet([new MathBlockPoint(-0d, 2d), new MathBlockPoint(3d, -4d)]),
                unit),
            MathBlockValue.Graph(
                new MathBlockGraph(
                    3,
                    [new MathBlockGraphEdge(0, 1, -0d), new MathBlockGraphEdge(2, 0, 3.5d)]),
                unit),
            MathBlockValue.RunSet(
                new MathBlockRunSet([new MathBlockRun(0, 2, -0d), new MathBlockRun(4, 3, 7.25d)]),
                unit),
            MathBlockValue.BooleanVector([true, false, true])
        ];
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        for (var index = 0; index < values.Length; index++)
        {
            var node = builder.Constant(values[index]);
            builder.Output(string.Concat("value-", index), node);
        }
        var program = builder.Build();

        var source = MathBlockOpenMath.Export(program);
        var imported = MathBlockOpenMath.Import(source);

        Assert.Contains("hex=\"8000000000000000\"", source, StringComparison.Ordinal);
        Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
        Assert.Equal(source, MathBlockOpenMath.Export(imported.Program));
        Assert.Empty(imported.Operations);
        Assert.Equal(values.Length, imported.Program.PlanNodes.Count);
    }

    [Fact]
    public void Export_rejects_operations_outside_the_standard_profile()
    {
        var operation = new MathBlockOperation(
            "7custom.identity",
            7,
            1,
            types => types[0],
            inputs => inputs[0],
            [new MathBlockRegressionCase(
                "identity",
                [MathBlockValue.Scalar(1d)],
                MathBlockValue.Scalar(1d))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1d)]));
        var registry = new MathBlockRegistry([operation]);
        var builder = new MathBlockProgramBuilder(registry);
        var input = builder.Input("input", MathBlockType.Scalar());
        var result = builder.Apply(operation.Identifier, operation.Version, input);
        var program = builder.Output("result", result).Build();
        var exception = Assert.Throws<InvalidOperationException>(() => MathBlockOpenMath.Export(program));
        Assert.Equal(
            "The program contains an operation outside the standard OpenMath profile.",
            exception.Message);

        using var stream = new MemoryStream([1, 2, 3], writable: true);
        stream.Position = stream.Length;
        var streamException = Assert.Throws<InvalidOperationException>(
            () => MathBlockOpenMath.WriteUtf8(program, stream));
        Assert.Equal(exception.Message, streamException.Message);
        Assert.Equal([1, 2, 3], stream.ToArray());
    }

    [Fact]
    public void Export_rejects_a_custom_operation_with_a_standard_identity()
    {
        var operation = new MathBlockOperation(
            "scalar.add",
            1,
            2,
            types => types[0],
            inputs => inputs[0],
            [new MathBlockRegressionCase(
                "left",
                [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)],
                MathBlockValue.Scalar(1d))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)]));
        var registry = new MathBlockRegistry([operation]);
        var builder = new MathBlockProgramBuilder(registry);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var result = builder.Apply(operation.Identifier, operation.Version, left, right);
        var program = builder.Output("result", result).Build();

        var exception = Assert.Throws<InvalidOperationException>(() => MathBlockOpenMath.Export(program));

        Assert.Equal(
            "The program contains an operation outside the standard OpenMath profile.",
            exception.Message);
    }

    [Fact]
    public void Import_rejects_nonprofile_symbols_and_forward_references()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var source = MathBlockOpenMath.Export(builder.Output("sum", sum).Build());
        var foreignSymbol = source.Replace(
            "cd=\"mathblocks_operations1\" name=\"op.scalar.add.v1\"",
            "cd=\"arith1\" name=\"plus\"",
            StringComparison.Ordinal);
        var forwardReference = ReplaceFirst(
            source,
            "href=\"#n0\"",
            "href=\"#n2\"");

        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(foreignSymbol));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(forwardReference));
    }

    [Fact]
    public void Import_rejects_DTDs_comments_processing_instructions_and_noncanonical_floats()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var value = builder.Constant(MathBlockValue.Scalar(1.5d));
        var source = MathBlockOpenMath.Export(builder.Output("value", value).Build());
        var dtd = string.Concat(
            "<!DOCTYPE OMOBJ [<!ENTITY external SYSTEM \"file:///not-read\">]>",
            source);
        var comment = ReplaceFirst(source, ">", "><!--comment-->");
        var processingInstruction = string.Concat("<?mathblocks test?>", source);
        var lowerCaseFloat = source.Replace("3FF8000000000000", "3ff8000000000000", StringComparison.Ordinal);
        var wrongGroup = source.Replace(
            MathBlockOpenMath.ContentDictionaryGroup,
            string.Concat(MathBlockOpenMath.ContentDictionaryBase, "/other.cdg"),
            StringComparison.Ordinal);

        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(dtd));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(comment));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(processingInstruction));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(lowerCaseFloat));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(wrongGroup));
    }

    [Fact]
    public void Export_is_stable_across_repeated_calls()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
        var program = builder.Output("sum", sum).Output("square", square).Build();
        var expected = MathBlockOpenMath.Export(program);

        Assert.Equal(
            "4EFA70505E04938DF3976754D1F00115362F39CCD1ED7FCB1D24E79DB1BE7E85",
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(expected))));
        for (var index = 0; index < 1_000; index++)
            Assert.Equal(expected, MathBlockOpenMath.Export(program));
    }

    [Fact]
    public void Synchronous_output_APIs_produce_the_exact_canonical_form()
    {
        var program = CreateSampleProgram();
        var expectedText = MathBlockOpenMath.Export(program);
        var expectedBytes = Encoding.UTF8.GetBytes(expectedText);

        Assert.Equal(expectedBytes.Length, MathBlockOpenMath.GetUtf8ByteCount(program));
        Assert.Equal(expectedBytes, MathBlockOpenMath.ExportUtf8(program));

        var exactDestination = new byte[expectedBytes.Length];
        Assert.True(MathBlockOpenMath.TryWriteUtf8(program, exactDestination, out var bytesWritten));
        Assert.Equal(expectedBytes.Length, bytesWritten);
        Assert.Equal(expectedBytes, exactDestination);

        var shortDestination = Enumerable.Repeat((byte)0xA5, expectedBytes.Length - 1).ToArray();
        var originalShortDestination = shortDestination.ToArray();
        Assert.False(MathBlockOpenMath.TryWriteUtf8(program, shortDestination, out bytesWritten));
        Assert.Equal(0, bytesWritten);
        Assert.Equal(originalShortDestination, shortDestination);

        var buffer = new ArrayBufferWriter<byte>();
        MathBlockOpenMath.WriteUtf8(program, buffer);
        Assert.Equal(expectedBytes, buffer.WrittenSpan.ToArray());

        using var stream = new MemoryStream();
        MathBlockOpenMath.WriteUtf8(program, stream);
        Assert.True(stream.CanWrite);
        Assert.Equal(expectedBytes, stream.ToArray());

        using var textWriter = new StringWriter(CultureInfo.InvariantCulture);
        MathBlockOpenMath.Write(program, textWriter);
        Assert.Equal(expectedText, textWriter.ToString());
    }

    [Fact]
    public void Export_uses_the_Canonical_XML_1_1_lexical_form()
    {
        var source = MathBlockOpenMath.Export(CreateSampleProgram());
        var expectedRoot = string.Concat(
            "<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\" cdbase=\"",
            MathBlockOpenMath.ContentDictionaryBase,
            "\" cdgroup=\"",
            MathBlockOpenMath.ContentDictionaryGroup,
            "\" version=\"2.0\">");

        Assert.StartsWith(expectedRoot, source, StringComparison.Ordinal);
        Assert.DoesNotContain("/>", source, StringComparison.Ordinal);
        Assert.DoesNotContain('\r', source);
        Assert.EndsWith("</OMOBJ>", source, StringComparison.Ordinal);
    }

    [Fact]
    public void Import_normalizes_valid_noncanonical_XML()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram());
        var canonicalRoot = string.Concat(
            "<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\" cdbase=\"",
            MathBlockOpenMath.ContentDictionaryBase,
            "\" cdgroup=\"",
            MathBlockOpenMath.ContentDictionaryGroup,
            "\" version=\"2.0\">");
        var noncanonicalRoot = string.Concat(
            "<OMOBJ version=\"2.0\" cdgroup=\"",
            MathBlockOpenMath.ContentDictionaryGroup,
            "\" cdbase=\"",
            MathBlockOpenMath.ContentDictionaryBase,
            "\" xmlns=\"http://www.openmath.org/OpenMath\">\n");
        var noncanonical = canonical
            .Replace(canonicalRoot, noncanonicalRoot, StringComparison.Ordinal)
            .Replace(
                "<OMS cd=\"mathblocks_program1\" name=\"program\"></OMS>",
                "<OMS name=\"program\" cd=\"mathblocks_program1\"/>",
                StringComparison.Ordinal);

        var imported = MathBlockOpenMath.Import(noncanonical);

        Assert.NotEqual(canonical, noncanonical);
        Assert.Equal(canonical, MathBlockOpenMath.Export(imported.Program));
    }

    [Fact]
    public void Import_normalizes_a_fully_namespace_prefixed_document()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram());
        var document = XDocument.Parse(canonical, LoadOptions.PreserveWhitespace);
        var root = Assert.IsType<XElement>(document.Root);
        root.Attribute("xmlns")?.Remove();
        root.Add(new XAttribute(XNamespace.Xmlns + "om", "http://www.openmath.org/OpenMath"));
        var prefixed = document.ToString(SaveOptions.DisableFormatting);
        var namespacedAttribute = ReplaceFirst(prefixed, " cd=", " om:cd=");
        var wrongElementNamespace = prefixed.Replace(
            "xmlns:om=\"http://www.openmath.org/OpenMath\"",
            "xmlns:om=\"urn:invalid\"",
            StringComparison.Ordinal);

        var imported = MathBlockOpenMath.Import(prefixed);

        Assert.StartsWith("<om:OMOBJ", prefixed, StringComparison.Ordinal);
        Assert.DoesNotContain("<OM", prefixed, StringComparison.Ordinal);
        Assert.DoesNotContain("</OM", prefixed, StringComparison.Ordinal);
        Assert.Equal(canonical, MathBlockOpenMath.Export(imported.Program));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(namespacedAttribute));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(wrongElementNamespace));
    }

    [Fact]
    public void Import_rejects_non_XML_whitespace_in_markup_positions()
    {
        var canonical = MathBlockOpenMath.Export(CreateSampleProgram());
        var betweenElements = ReplaceFirst(canonical, ">", ">\u00A0");
        var insideEmptyToken = ReplaceFirst(canonical, "></OMS>", ">\u00A0</OMS>");

        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(betweenElements));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(insideEmptyToken));
    }

    [Fact]
    public void Import_rejects_a_document_above_the_fixed_character_limit()
    {
        var source = new string(' ', MathBlockOpenMath.MaximumDocumentCharacters + 1);

        var exception = Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(source));

        Assert.Equal("The OpenMath source exceeds the character limit.", exception.Message);
    }

    [Fact]
    public void Export_is_independent_of_the_current_culture()
    {
        var program = CreateSampleProgram();
        var expected = MathBlockOpenMath.Export(program);
        var originalCulture = CultureInfo.CurrentCulture;
        var originalUiCulture = CultureInfo.CurrentUICulture;
        try
        {
            foreach (var cultureName in new[] { "ar-SA", "fr-FR", "tr-TR" })
            {
                var culture = CultureInfo.GetCultureInfo(cultureName);
                CultureInfo.CurrentCulture = culture;
                CultureInfo.CurrentUICulture = culture;
                Assert.Equal(expected, MathBlockOpenMath.Export(program));
            }
        }
        finally
        {
            CultureInfo.CurrentCulture = originalCulture;
            CultureInfo.CurrentUICulture = originalUiCulture;
        }
    }

    [Fact]
    public void Profile_content_dictionaries_match_the_standard_catalog()
    {
        XNamespace dictionaryNamespace = "http://www.openmath.org/OpenMathCD";
        var expectedDictionaries = new Dictionary<string, string[]>(StringComparer.Ordinal)
        {
            ["mathblocks_program1"] =
                ["constant", "input", "nodes", "output", "outputs", "program"],
            ["mathblocks_types1"] =
            [
                "boolean", "boolean-vector", "complex", "complex-matrix", "complex-vector",
                "graph", "matrix", "point-set", "rational", "run-set", "scalar", "type",
                "unit", "vector"
            ],
            ["mathblocks_values1"] =
            [
                "boolean-vector", "complex", "complex-matrix", "complex-vector", "edge", "false",
                "graph", "matrix", "point", "point-set", "run", "run-set", "true", "vector"
            ],
            ["mathblocks_operations1"] = MathBlockCatalog.Standard.Operations
                .Select(OperationSymbolName)
                .OrderBy(name => name, StringComparer.Ordinal)
                .ToArray()
        };

        foreach (var expected in expectedDictionaries)
        {
            var document = XDocument.Load(ProfilePath(string.Concat(expected.Key, ".ocd")));
            var root = Assert.IsType<XElement>(document.Root);
            Assert.Equal(dictionaryNamespace + "CD", root.Name);
            Assert.Equal("2.0", (string?)root.Attribute("version"));
            Assert.Equal(expected.Key, root.Element(dictionaryNamespace + "CDName")?.Value);
            Assert.Equal(
                MathBlockOpenMath.ContentDictionaryBase,
                root.Element(dictionaryNamespace + "CDBase")?.Value);
            Assert.Equal(
                string.Concat(MathBlockOpenMath.ContentDictionaryBase, "/", expected.Key, ".ocd"),
                root.Element(dictionaryNamespace + "CDURL")?.Value);
            Assert.Equal("private", root.Element(dictionaryNamespace + "CDStatus")?.Value);
            Assert.Equal("1", root.Element(dictionaryNamespace + "CDVersion")?.Value);
            Assert.Equal(
                expected.Value,
                root.Elements(dictionaryNamespace + "CDDefinition")
                    .Select(element => element.Element(dictionaryNamespace + "Name")?.Value)
                    .OrderBy(name => name, StringComparer.Ordinal));
        }

        var operationDocument = XDocument.Load(ProfilePath("mathblocks_operations1.ocd"));
        var operationDefinitions = operationDocument.Root?
            .Elements(dictionaryNamespace + "CDDefinition")
            .ToDictionary(
                element => element.Element(dictionaryNamespace + "Name")?.Value ?? string.Empty,
                StringComparer.Ordinal) ?? throw new InvalidDataException("The operation dictionary is empty.");
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var definition = operationDefinitions[OperationSymbolName(operation)];
            var description = definition.Element(dictionaryNamespace + "Description")?.Value;
            Assert.Equal(
                $"This application identifies MathBlocks operation {operation.Identity}. " +
                $"It requires {operation.Arity} ordered operand references.",
                description);
        }
    }

    [Fact]
    public void Profile_group_binds_all_content_dictionaries()
    {
        XNamespace groupNamespace = "http://www.openmath.org/OpenMathCDG";
        var document = XDocument.Load(ProfilePath("mathblocks_profile1.cdg"));
        var root = Assert.IsType<XElement>(document.Root);
        var members = root.Elements(groupNamespace + "CDGroupMember").ToArray();

        Assert.Equal(groupNamespace + "CDGroup", root.Name);
        Assert.Equal("2.0", (string?)root.Attribute("version"));
        Assert.Equal("mathblocks_profile1", root.Element(groupNamespace + "CDGroupName")?.Value);
        Assert.Equal("1", root.Element(groupNamespace + "CDGroupVersion")?.Value);
        Assert.Equal(MathBlockOpenMath.ContentDictionaryGroup, root.Element(groupNamespace + "CDGroupURL")?.Value);
        Assert.Equal(
            ["mathblocks_program1", "mathblocks_operations1", "mathblocks_types1", "mathblocks_values1"],
            members.Select(member => member.Element(groupNamespace + "CDName")?.Value));
        Assert.All(
            members,
            member => Assert.Equal("1", member.Element(groupNamespace + "CDVersion")?.Value));
        Assert.All(
            members,
            member => Assert.Equal(
                string.Concat(
                    MathBlockOpenMath.ContentDictionaryBase,
                    "/",
                    member.Element(groupNamespace + "CDName")?.Value,
                    ".ocd"),
                member.Element(groupNamespace + "CDURL")?.Value));
    }

    [Fact]
    public void Profile_schema_binds_the_public_profile_identifiers()
    {
        var schema = File.ReadAllText(ProfilePath("mathblocks_profile1.rnc"));

        Assert.Contains(MathBlockOpenMath.ContentDictionaryBase, schema, StringComparison.Ordinal);
        Assert.Contains(MathBlockOpenMath.ContentDictionaryGroup, schema, StringComparison.Ordinal);
        Assert.Contains("mathblocks_program1", schema, StringComparison.Ordinal);
        Assert.Contains("mathblocks_operations1", schema, StringComparison.Ordinal);
        Assert.Contains("mathblocks_types1", schema, StringComparison.Ordinal);
        Assert.Contains("mathblocks_values1", schema, StringComparison.Ordinal);
    }

    private static MathBlockProgram CreateSampleProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
        return builder.Output("sum", sum).Output("square", square).Build();
    }

    private static string OperationSymbolName(MathBlockOperation operation) =>
        string.Concat(
            "op.",
            operation.Identifier,
            ".v",
            operation.Version.ToString(CultureInfo.InvariantCulture));

    private static string ProfilePath(string fileName) =>
        Path.Combine(AppContext.BaseDirectory, "openmath", "v1", fileName);

    private static string ReplaceFirst(string source, string oldValue, string newValue)
    {
        var index = source.IndexOf(oldValue, StringComparison.Ordinal);
        Assert.True(index >= 0, $"The source does not contain '{oldValue}'.");
        return string.Concat(
            source.AsSpan(0, index),
            newValue,
            source.AsSpan(index + oldValue.Length));
    }
}
