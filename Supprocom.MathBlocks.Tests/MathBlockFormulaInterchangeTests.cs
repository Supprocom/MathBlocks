using System.Buffers;
using System.Text;
using System.Xml.Linq;
using Supprocom.MathBlocks;

namespace Supprocom.MathBlocks.Tests;

public sealed class MathBlockFormulaInterchangeTests
{
    private static readonly MathBlockFormulaFormat[] Formats =
    [
        MathBlockFormulaFormat.OpenMath,
        MathBlockFormulaFormat.ContentMathMl
    ];

    [Fact]
    public void Profile_maps_every_operation_without_an_unsupported_class()
    {
        var profile = MathBlockFormulaInterchange.Profile;

        Assert.Equal("2.0", profile.OpenMathVersion);
        Assert.Equal("3.0", profile.ContentMathMlVersion);
        Assert.Equal("1", profile.ProfileVersion);
        Assert.Equal(337, profile.Operations.Count);
        Assert.Equal(9, profile.Artifacts.Count);
        Assert.Equal(64, profile.Fingerprint.Length);
        Assert.Equal(
            38,
            profile.Operations.Count(mapping =>
                mapping.Kind == MathBlockFormulaMappingKind.OfficialContentDictionary));
        Assert.Equal(
            299,
            profile.Operations.Count(mapping =>
                mapping.Kind == MathBlockFormulaMappingKind.MathBlocksExtension));
        Assert.Equal(
            337,
            profile.Operations.Count(mapping =>
                mapping.Classification ==
                MathBlockFormulaMappingClassification.DirectMapping));
        Assert.DoesNotContain(
            profile.Operations,
            mapping => mapping.Classification is
                MathBlockFormulaMappingClassification.CanonicalPatternMapping or
                MathBlockFormulaMappingClassification.Unsupported);
        Assert.Equal(
            MathBlockCatalog.Standard.Operations.Select(operation => operation.Identity),
            profile.Operations.Select(mapping => mapping.Identity));
        Assert.Equal(
            337,
            profile.Operations.Select(mapping => mapping.Symbol).Distinct().Count());

        foreach (var mapping in profile.Operations)
        {
            Assert.True(
                MathBlockFormulaInterchange.TryGetOperationMapping(
                    mapping.Operation,
                    out var resolvedMapping));
            Assert.Same(mapping, resolvedMapping);
            Assert.True(
                MathBlockFormulaInterchange.TryGetOperation(
                    mapping.Symbol,
                    out var resolvedOperation));
            Assert.Same(mapping.Operation, resolvedOperation);
        }

        foreach (var artifact in profile.Artifacts)
        {
            Assert.Equal(64, artifact.Sha256.Length);
            using var stream = artifact.OpenRead();
            Assert.Equal(artifact.Length, stream.Length);
            Assert.False(stream.CanWrite);
        }

        var manifest = profile.Artifacts.Single(artifact =>
            artifact.Name == "mathblocks_formula_mappings1.xml");
        using (var stream = manifest.OpenRead())
        {
            var document = XDocument.Load(stream);
            var root = Assert.IsType<XElement>(document.Root);
            var entries = root.Elements().ToArray();
            Assert.Equal("337", root.Attribute("count")?.Value);
            Assert.Equal("2.0", root.Attribute("openmath")?.Value);
            Assert.Equal("3.0", root.Attribute("content-mathml")?.Value);
            Assert.Equal(profile.Fingerprint, root.Attribute("fingerprint")?.Value);
            Assert.Equal(337, entries.Length);
            Assert.Equal(
                profile.Operations.Select(mapping => mapping.Identity),
                entries.Select(entry => entry.Attribute("identity")?.Value));
            Assert.DoesNotContain(entries, entry =>
                entry.Attribute("classification")?.Value == "unsupported");
            Assert.All(entries, entry => Assert.Equal(
                "direct-mapping",
                entry.Attribute("classification")?.Value));
        }

        var operationDictionary = profile.Artifacts.Single(artifact =>
            artifact.Name == "mathblocks_formula_operations1.ocd");
        using (var stream = operationDictionary.OpenRead())
        {
            XNamespace contentDictionaryNamespace = "http://www.openmath.org/OpenMathCD";
            var document = XDocument.Load(stream);
            var names = document
                .Descendants(contentDictionaryNamespace + "CDDefinition")
                .Select(definition => definition.Element(contentDictionaryNamespace + "Name")?.Value)
                .ToArray();
            Assert.Equal(337, names.Length);
            Assert.Equal(
                MathBlockCatalog.Standard.Operations
                    .Select(operation => $"op.{operation.Identifier}.v{operation.Version}")
                    .OrderBy(name => name, StringComparer.Ordinal),
                names);
        }

        var dictionaryGroup = profile.Artifacts.Single(artifact =>
            artifact.Name == "mathblocks_formula_profile1.cdg");
        using (var stream = dictionaryGroup.OpenRead())
        {
            XNamespace groupNamespace = "http://www.openmath.org/OpenMathCDG";
            var document = XDocument.Load(stream);
            Assert.Equal(
                [
                    "mathblocks_formula1",
                    "mathblocks_formula_operations1",
                    "mathblocks_formula_values1",
                    "arith1",
                    "complex1",
                    "logic1",
                    "relation1",
                    "rounding1",
                    "transc1"
                ],
                document
                    .Descendants(groupNamespace + "CDGroupMember")
                    .Select(member => member.Element(groupNamespace + "CDName")?.Value));
        }
    }

    [Fact]
    public void Every_operation_round_trips_through_every_supported_format()
    {
        Assert.Equal(337, MathBlockCatalog.Standard.Operations.Count);
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var regression = operation.RegressionCases[0];
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var inputs = new int[regression.Inputs.Count];
            for (var index = 0; index < inputs.Length; index++)
                inputs[index] = builder.Constant(regression.Inputs[index]);
            var result = builder.Apply(operation.Identifier, operation.Version, inputs);
            var program = builder.Output("result", result).Build();

            foreach (var format in Formats)
            {
                var source = MathBlockFormulaInterchange.Export(program, "result", format);
                var imported = MathBlockFormulaInterchange.Import(source, format);
                var visibleImported = MathBlockFormulaInterchange.Import(
                    source,
                    format,
                    new Dictionary<string, MathBlockType>(),
                    "result");

                Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
                Assert.Equal(program.Fingerprint, visibleImported.Program.Fingerprint);
                Assert.Equal("result", imported.OutputName);
                Assert.Equal(format, imported.Format);
                Assert.Same(operation, Assert.Single(imported.Operations));
                Assert.Equal(
                    source,
                    MathBlockFormulaInterchange.Export(
                        imported.Program,
                        imported.OutputName,
                        format));
            }
        }
    }

    [Fact]
    public void Visible_expression_import_accepts_standard_external_formulas()
    {
        const string mathMl =
            "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><apply><plus/><ci>x</ci><cn type=\"real\">2</cn></apply></math>";
        const string openMath =
            "<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\"><OMA><OMS cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\" name=\"plus\"/><OMV name=\"x\"/><OMF dec=\"2.0\"/></OMA></OMOBJ>";
        var bindings = new Dictionary<string, MathBlockType>
        {
            ["x"] = MathBlockType.Scalar()
        };

        var fromMathMl = MathBlockFormulaInterchange.Import(
            mathMl,
            MathBlockFormulaFormat.ContentMathMl,
            bindings,
            "result");
        var fromOpenMath = MathBlockFormulaInterchange.Import(
            openMath,
            MathBlockFormulaFormat.OpenMath,
            bindings,
            "result");

        foreach (var imported in new[] { fromMathMl, fromOpenMath })
        {
            var result = imported.Program.Evaluate(new Dictionary<string, MathBlockValue>
            {
                ["x"] = MathBlockValue.Scalar(3d)
            });
            Assert.Equal(5d, result["result"].AsScalar());
            Assert.Equal("scalar.add@1", Assert.Single(imported.Operations).Identity);
        }
    }

    [Fact]
    public void Visible_expression_import_folds_standard_associative_applications()
    {
        const string mathMl =
            "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><apply><plus/><ci>x</ci><cn type=\"integer\">2</cn><cn type=\"double\">4.0</cn></apply></math>";
        var imported = MathBlockFormulaInterchange.Import(
            mathMl,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>
            {
                ["x"] = MathBlockType.Scalar()
            },
            "result");

        Assert.Equal(
            ["scalar.add@1", "scalar.add@1"],
            imported.Operations.Select(operation => operation.Identity));
        var result = imported.Program.Evaluate(new Dictionary<string, MathBlockValue>
        {
            ["x"] = MathBlockValue.Scalar(3d)
        });
        Assert.Equal(9d, result["result"].AsScalar());
    }

    [Fact]
    public void Visible_expression_import_accepts_extensions_sharing_and_encoded_names()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var value = builder.Input("input value", MathBlockType.Scalar());
        var stable = builder.Apply("scalar.softplus", inputs: [value]);
        var sum = builder.Apply("scalar.add", inputs: [stable, stable]);
        var program = builder.Output("source", sum).Build();
        var bindings = new Dictionary<string, MathBlockType>
        {
            ["input value"] = MathBlockType.Scalar()
        };

        foreach (var format in Formats)
        {
            var source = MathBlockFormulaInterchange.Export(program, "source", format);
            var imported = MathBlockFormulaInterchange.Import(
                source,
                format,
                bindings,
                "external result");

            Assert.Equal("external result", imported.OutputName);
            Assert.Equal(
                ["scalar.softplus@1", "scalar.add@1"],
                imported.Operations.Select(operation => operation.Identity));
            Assert.Equal(3, imported.Program.PlanNodes.Count);
            var expected = 2d * Math.Log(2d);
            var result = imported.Program.Evaluate(new Dictionary<string, MathBlockValue>
            {
                ["input value"] = MathBlockValue.Scalar(0d)
            });
            Assert.Equal(expected, result["external result"].AsScalar(), 12);
        }
    }

    [Fact]
    public void Visible_expression_import_rejects_missing_bindings_unknown_symbols_and_mixed_vocabularies()
    {
        const string missingBinding =
            "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><ci>x</ci></math>";
        const string unknownSymbol =
            "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><apply><csymbol cd=\"unknown\" cdbase=\"https://example.invalid\">unknown</csymbol><cn>1</cn></apply></math>";
        const string mixedVocabulary =
            "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><OMF xmlns=\"http://www.openmath.org/OpenMath\" hex=\"3FF0000000000000\"/></math>";

        Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(
            missingBinding,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>(),
            "result"));
        Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(
            unknownSymbol,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>(),
            "result"));
        Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(
            mixedVocabulary,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>(),
            "result"));

        var extensionBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var value = extensionBuilder.Constant(MathBlockValue.Scalar(0d));
        var extension = extensionBuilder.Apply("scalar.softplus", inputs: [value]);
        var extensionProgram = extensionBuilder.Output("result", extension).Build();
        var extensionSource = MathBlockFormulaInterchange.Export(
            extensionProgram,
            "result",
            MathBlockFormulaFormat.ContentMathMl);
        var withoutDictionaryGroup = extensionSource.Replace(
            " cdgroup=\"https://raw.githubusercontent.com/Supprocom/MathBlocks/main/formula/v1/mathblocks_formula_profile1.cdg\"",
            string.Empty,
            StringComparison.Ordinal);
        Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(
            withoutDictionaryGroup,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>(),
            "result"));
    }

    [Fact]
    public void Visible_expression_import_uses_the_official_base_for_ungrouped_mathml_symbols()
    {
        const string source =
            "<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><apply><csymbol cd=\"arith1\">plus</csymbol><cn>1</cn><cn>2</cn></apply></math>";

        var imported = MathBlockFormulaInterchange.Import(
            source,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>(),
            "result");

        Assert.Equal(
            3d,
            imported.Program.Evaluate(new Dictionary<string, MathBlockValue>())["result"]
                .AsScalar());
    }

    [Fact]
    public void Visible_expression_import_rejects_foreign_dictionary_groups_without_an_accepted_base()
    {
        const string foreignGroup = "https://example.invalid/foreign.cdg";
        var openMath =
            $"<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\" cdgroup=\"{foreignGroup}\"><OMA><OMS cd=\"arith1\" name=\"plus\"/><OMI>1</OMI><OMI>2</OMI></OMA></OMOBJ>";
        var mathMl =
            $"<math xmlns=\"http://www.w3.org/1998/Math/MathML\" cdgroup=\"{foreignGroup}\"><apply><csymbol cd=\"arith1\">plus</csymbol><cn>1</cn><cn>2</cn></apply></math>";

        Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(
            openMath,
            MathBlockFormulaFormat.OpenMath,
            new Dictionary<string, MathBlockType>(),
            "result"));
        Assert.Throws<FormatException>(() => MathBlockFormulaInterchange.Import(
            mathMl,
            MathBlockFormulaFormat.ContentMathMl,
            new Dictionary<string, MathBlockType>(),
            "result"));

        var openMathWithBase = openMath.Replace(
            "cd=\"arith1\"",
            "cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\"",
            StringComparison.Ordinal);
        var mathMlWithBase = mathMl.Replace(
            "cd=\"arith1\"",
            "cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\"",
            StringComparison.Ordinal);
        foreach (var item in new[]
                 {
                     (Source: openMathWithBase, Format: MathBlockFormulaFormat.OpenMath),
                     (Source: mathMlWithBase, Format: MathBlockFormulaFormat.ContentMathMl)
                 })
        {
            var imported = MathBlockFormulaInterchange.Import(
                item.Source,
                item.Format,
                new Dictionary<string, MathBlockType>(),
                "result");
            Assert.Equal(
                3d,
                imported.Program.Evaluate(new Dictionary<string, MathBlockValue>())["result"]
                    .AsScalar());
        }
    }

    [Theory]
    [InlineData(MathBlockFormulaFormat.OpenMath)]
    [InlineData(MathBlockFormulaFormat.ContentMathMl)]
    public void Visible_expression_import_bounds_element_and_nesting_amplification(
        MathBlockFormulaFormat format)
    {
        var elementException = Assert.Throws<FormatException>(() =>
            MathBlockFormulaInterchange.Import(
                CreateWideFormula(format),
                format,
                new Dictionary<string, MathBlockType>(),
                "result"));
        Assert.Equal(
            "The formula expression exceeds the element limit.",
            elementException.Message);

        var nestingException = Assert.Throws<FormatException>(() =>
            MathBlockFormulaInterchange.Import(
                CreateDeepFormula(format),
                format,
                new Dictionary<string, MathBlockType>(),
                "result"));
        Assert.Equal(
            "The formula expression exceeds the nesting limit.",
            nestingException.Message);
    }

    [Fact]
    public void Official_and_extension_symbols_are_visible_in_both_vocabularies()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var stable = builder.Apply("scalar.softplus", inputs: [sum]);
        var program = builder.Output("result", stable).Build();

        var openMath = MathBlockFormulaInterchange.Export(
            program,
            "result",
            MathBlockFormulaFormat.OpenMath);
        var mathMl = MathBlockFormulaInterchange.Export(
            program,
            "result",
            MathBlockFormulaFormat.ContentMathMl);

        Assert.Contains(
            "cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\" name=\"plus\"",
            openMath,
            StringComparison.Ordinal);
        Assert.Contains(
            "cd=\"mathblocks_formula_operations1\" name=\"op.scalar.softplus.v1\"",
            openMath,
            StringComparison.Ordinal);
        Assert.Contains(
            "<csymbol cd=\"arith1\">plus</csymbol>",
            mathMl,
            StringComparison.Ordinal);
        Assert.Contains(
            "<csymbol cd=\"mathblocks_formula_operations1\">op.scalar.softplus.v1</csymbol>",
            mathMl,
            StringComparison.Ordinal);
        Assert.Contains(
            "cdgroup=\"https://raw.githubusercontent.com/Supprocom/MathBlocks/main/formula/v1/mathblocks_formula_profile1.cdg\"",
            mathMl,
            StringComparison.Ordinal);
    }

    [Fact]
    public void Selected_output_excludes_unreachable_nodes_and_preserves_sharing()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        _ = builder.Constant(MathBlockValue.Scalar(99d));
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
        var program = builder
            .Output("sum", sum)
            .Output("square", square)
            .Build();

        var openMath = MathBlockFormulaInterchange.Export(
            program,
            "square",
            MathBlockFormulaFormat.OpenMath);
        var mathMl = MathBlockFormulaInterchange.Export(
            program,
            "square",
            MathBlockFormulaFormat.ContentMathMl);
        var imported = MathBlockFormulaInterchange.Import(
            mathMl,
            MathBlockFormulaFormat.ContentMathMl);

        Assert.Contains("<OMR href=\"#n2\"></OMR>", openMath, StringComparison.Ordinal);
        Assert.Contains("<share src=\"#n2\"></share>", mathMl, StringComparison.Ordinal);
        Assert.DoesNotContain("4058C00000000000", mathMl, StringComparison.Ordinal);
        Assert.Equal(4, imported.Program.PlanNodes.Count);
        Assert.Equal(["square"], imported.Program.Outputs.Keys);
    }

    [Fact]
    public void Every_value_kind_and_binary64_bits_round_trip_in_both_formats()
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

        for (var valueIndex = 0; valueIndex < values.Length; valueIndex++)
        {
            var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
            var constant = builder.Constant(values[valueIndex]);
            var program = builder.Output("value", constant).Build();
            foreach (var format in Formats)
            {
                var source = MathBlockFormulaInterchange.Export(program, "value", format);
                var imported = MathBlockFormulaInterchange.Import(source, format);

                Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
                Assert.Equal(source, MathBlockFormulaInterchange.Normalize(source, format));
            }
        }

        var negativeZeroBuilder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var negativeZero = negativeZeroBuilder.Constant(MathBlockValue.Scalar(-0d, unit));
        var negativeZeroProgram = negativeZeroBuilder.Output("value", negativeZero).Build();
        var mathMl = MathBlockFormulaInterchange.Export(
            negativeZeroProgram,
            "value",
            MathBlockFormulaFormat.ContentMathMl);
        Assert.Contains(
            "<cn id=\"n0\" type=\"hexdouble\">8000000000000000</cn>",
            mathMl,
            StringComparison.Ordinal);
    }

    [Fact]
    public async Task UTF8_buffer_stream_and_async_APIs_return_the_canonical_document()
    {
        var program = CreateSampleProgram();
        foreach (var format in Formats)
        {
            var source = MathBlockFormulaInterchange.Export(program, "square", format);
            var expected = Encoding.UTF8.GetBytes(source);
            Assert.Equal(expected, MathBlockFormulaInterchange.ExportUtf8(program, "square", format));
            Assert.Equal(expected.Length, MathBlockFormulaInterchange.GetUtf8ByteCount(
                program,
                "square",
                format));

            var destination = new byte[expected.Length];
            Assert.True(MathBlockFormulaInterchange.TryWriteUtf8(
                program,
                "square",
                format,
                destination,
                out var written));
            Assert.Equal(expected.Length, written);
            Assert.Equal(expected, destination);

            var segmented = new ReadOnlySequence<byte>(expected);
            Assert.Equal(
                program.Fingerprint,
                MathBlockFormulaInterchange.ImportUtf8(segmented, format).Program.Fingerprint);
            Assert.True(MathBlockFormulaInterchange.TryImport(source, format).Succeeded);
            Assert.True(MathBlockFormulaInterchange.TryImportUtf8(expected, format).Succeeded);
            Assert.True(MathBlockFormulaInterchange.Validate(source, format).IsValid);
            Assert.True(MathBlockFormulaInterchange.ValidateUtf8(expected, format).IsValid);
            Assert.True(MathBlockFormulaInterchange.ValidateProgram(
                program,
                "square",
                format).IsValid);
            Assert.Equal(expected, MathBlockFormulaInterchange.NormalizeUtf8(expected, format));

            using var reader = new StringReader(source);
            Assert.Equal(
                program.Fingerprint,
                MathBlockFormulaInterchange.Read(reader, format).Program.Fingerprint);
            using var asyncReader = new StringReader(source);
            Assert.Equal(
                program.Fingerprint,
                (await MathBlockFormulaInterchange.ReadAsync(asyncReader, format))
                    .Program.Fingerprint);
            using var input = new MemoryStream(expected, false);
            Assert.Equal(
                program.Fingerprint,
                MathBlockFormulaInterchange.ReadUtf8(input, format).Program.Fingerprint);
            await using var asyncInput = new MemoryStream(expected, false);
            Assert.Equal(
                program.Fingerprint,
                (await MathBlockFormulaInterchange.ReadUtf8Async(asyncInput, format))
                    .Program.Fingerprint);

            await using var stream = new MemoryStream();
            await MathBlockFormulaInterchange.WriteUtf8Async(
                program,
                "square",
                format,
                stream);
            Assert.Equal(expected, stream.ToArray());
        }
    }

    [Fact]
    public void Import_rejects_visible_annotation_disagreement_and_DTDs()
    {
        var program = CreateSampleProgram();
        foreach (var format in Formats)
        {
            var source = MathBlockFormulaInterchange.Export(program, "square", format);
            var visibleTamper = format == MathBlockFormulaFormat.OpenMath
                ? ReplaceFirst(source, "name=\"plus\"", "name=\"times\"")
                : ReplaceFirst(source, ">plus</csymbol>", ">times</csymbol>");

            Assert.Throws<FormatException>(() =>
                MathBlockFormulaInterchange.Import(visibleTamper, format));
            var attempt = MathBlockFormulaInterchange.TryImport(visibleTamper, format);
            Assert.False(attempt.Succeeded);
            Assert.Equal(
                MathBlockFormulaDiagnosticCode.VisibleExpressionMismatch,
                attempt.Diagnostic?.Code);
            Assert.Throws<FormatException>(() =>
                MathBlockFormulaInterchange.Import(
                    string.Concat("<!DOCTYPE test [<!ENTITY x SYSTEM \"file:///not-read\">]>", source),
                    format));
        }
    }

    [Fact]
    public void Export_rejects_custom_operations_even_when_the_identity_is_copied()
    {
        var operation = new MathBlockOperation(
            "scalar.add",
            1,
            2,
            types => types[0],
            inputs => inputs[0],
            [new MathBlockRegressionCase(
                "copied",
                [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)],
                MathBlockValue.Scalar(1d))],
            new MathBlockPerformanceCase([MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)]));
        var registry = new MathBlockRegistry([operation]);
        var builder = new MathBlockProgramBuilder(registry);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var result = builder.Apply("scalar.add", inputs: [left, right]);
        var program = builder.Output("result", result).Build();

        Assert.Throws<InvalidOperationException>(() =>
            MathBlockFormulaInterchange.Export(
                program,
                "result",
                MathBlockFormulaFormat.OpenMath));
        var validation = MathBlockFormulaInterchange.ValidateProgram(
            program,
            "result",
            MathBlockFormulaFormat.OpenMath);
        Assert.False(validation.IsValid);
        Assert.Equal(
            MathBlockFormulaDiagnosticCode.OperationOutsideProfile,
            validation.Diagnostic?.Code);
    }

    private static MathBlockProgram CreateSampleProgram()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var left = builder.Input("left", MathBlockType.Scalar());
        var right = builder.Input("right", MathBlockType.Scalar());
        var sum = builder.Apply("scalar.add", inputs: [left, right]);
        var square = builder.Apply("scalar.multiply", inputs: [sum, sum]);
        return builder.Output("square", square).Build();
    }

    private static string CreateWideFormula(MathBlockFormulaFormat format)
    {
        var result = new StringBuilder();
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            result.Append("<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\"><OMA><OMS cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\" name=\"plus\"/>");
            for (var index = 0; index < MathBlockFormulaInterchange.MaximumExpressionElements;
                 index++)
            {
                result.Append("<OMI>1</OMI>");
            }
            return result.Append("</OMA></OMOBJ>").ToString();
        }

        result.Append("<math xmlns=\"http://www.w3.org/1998/Math/MathML\"><apply><plus/>");
        for (var index = 0; index < MathBlockFormulaInterchange.MaximumExpressionElements;
             index++)
        {
            result.Append("<cn>1</cn>");
        }
        return result.Append("</apply></math>").ToString();
    }

    private static string CreateDeepFormula(MathBlockFormulaFormat format)
    {
        var result = new StringBuilder();
        var levels = MathBlockFormulaInterchange.MaximumExpressionDepth + 2;
        if (format == MathBlockFormulaFormat.OpenMath)
        {
            result.Append("<OMOBJ xmlns=\"http://www.openmath.org/OpenMath\">");
            for (var index = 0; index < levels; index++)
            {
                result.Append("<OMA><OMS cd=\"arith1\" cdbase=\"http://www.openmath.org/cd\" name=\"plus\"/>");
            }
            result.Append("<OMI>1</OMI>");
            for (var index = 0; index < levels; index++)
                result.Append("<OMI>1</OMI></OMA>");
            return result.Append("</OMOBJ>").ToString();
        }

        result.Append("<math xmlns=\"http://www.w3.org/1998/Math/MathML\">");
        for (var index = 0; index < levels; index++)
            result.Append("<apply><plus/>");
        result.Append("<cn>1</cn>");
        for (var index = 0; index < levels; index++)
            result.Append("<cn>1</cn></apply>");
        return result.Append("</math>").ToString();
    }

    private static string ReplaceFirst(string source, string oldValue, string newValue)
    {
        var index = source.IndexOf(oldValue, StringComparison.Ordinal);
        Assert.True(index >= 0);
        return string.Concat(source.AsSpan(0, index), newValue, source.AsSpan(index + oldValue.Length));
    }
}
