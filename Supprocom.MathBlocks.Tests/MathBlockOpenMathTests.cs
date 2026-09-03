using System.Security.Cryptography;
using System.Text;
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
    public void Import_uses_the_supplied_registry()
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
        var source = MathBlockOpenMath.Export(program);

        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(source));

        var imported = MathBlockOpenMath.Import(source, registry);

        Assert.Equal(program.Fingerprint, imported.Program.Fingerprint);
        Assert.Single(imported.Operations);
        Assert.Same(operation, imported.Operations[0]);
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
    public void Import_rejects_DTDs_comments_and_noncanonical_floats()
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var value = builder.Constant(MathBlockValue.Scalar(1.5d));
        var source = MathBlockOpenMath.Export(builder.Output("value", value).Build());
        var dtd = string.Concat(
            "<!DOCTYPE OMOBJ [<!ENTITY external SYSTEM \"file:///not-read\">]>",
            source);
        var comment = ReplaceFirst(source, ">", "><!--comment-->");
        var lowerCaseFloat = source.Replace("3FF8000000000000", "3ff8000000000000", StringComparison.Ordinal);

        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(dtd));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(comment));
        Assert.Throws<FormatException>(() => MathBlockOpenMath.Import(lowerCaseFloat));
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
            "BD8080D04DD34405F64F0A10CC07A6793E8DECB16A73D86779512F819E444E17",
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(expected))));
        for (var index = 0; index < 1_000; index++)
            Assert.Equal(expected, MathBlockOpenMath.Export(program));
    }

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
