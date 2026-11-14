using System.Globalization;
using System.Reflection;
using System.Text;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>
/// Contains the NVRTC tests of the fused-expression CUDA source, which need NVRTC and no CUDA device: the fused source of every program the
/// fused device tests build compiles after the device source of the defaults and of every domain option set the fused and domain device tests use.
/// </summary>
public sealed class MathBlockFusedNvrtcTests
{
    private const string Architecture = "compute_86";

    private static readonly MethodInfo Compile = typeof(MathBlockCatalog).Assembly
        .GetType("Supprocom.MathBlocks.Cuda.MathBlocksCudaNative", throwOnError: true)!
        .GetMethod(
            "CompilePtxWithoutDevice",
            BindingFlags.Static | BindingFlags.NonPublic | BindingFlags.Public,
            [typeof(string), typeof(string), typeof(string), typeof(bool)])!;

    /// <summary>Gets the domain option sets of the fused and domain device tests, by name, with the defaults first.</summary>
    internal static IEnumerable<(string Name, MathBlockDomainOptions Options)> OptionSets()
    {
        yield return ("defaults", MathBlockDomainOptions.Default);
        foreach (var name in new[] { "invalid", "converging", "tolerance" })
            yield return ("fused:" + name, MathBlockFusedDomainTests.Options(name));
        foreach (var item in MathBlockDomainWiringTests.RaisedCases())
            yield return ("raised:" + item.Identity, item.Other);
        foreach (var item in MathBlockDomainWiringTests.LoweredCases())
            yield return ("lowered:" + item.Identity, item.Other);
        foreach (var item in MathBlockCudaDomainLargeDeviceTests.Cases())
            yield return (item.Name, item.Case.Other);
    }

    // The expressions the fused device tests build, without their inputs (the source depends on the program only): the golden and the
    // multiply-add programs, one program per fused row form, one per elementwise form and sibling under every broadcast mask, the beta
    // expression of the domain test, and random programs with elementwise rows from the seed of the device test's generator.
    internal static List<MathBlockFusedExpression> Expressions()
    {
        var expressions = new List<MathBlockFusedExpression>
        {
            MathBlockFusedExpression.Create(MathBlockFusedExpressionSourceTests.CreateGoldenProgram()),
            MathBlockFusedDomainTests.BetaExpression().Expression
        };
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var x = builder.Input("x", MathBlockType.Vector());
        var y = builder.Input("y", MathBlockType.Vector());
        var z = builder.Input("z", MathBlockType.Vector());
        expressions.Add(MathBlockFusedExpression.Create(builder
            .Output("a", builder.Apply("vector.add", 1, builder.Apply("vector.multiply", 1, x, y), z))
            .Output("b", builder.Apply("vector.subtract", 1, z, builder.Apply("vector.multiply", 1, y, y)))
            .Build()));
        foreach (var (identity, arguments, result) in MathBlockFusedTestSupport.Operations)
            expressions.Add(MathBlockFusedExpression.Create(SingleOperation(identity, arguments, result)));
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            var form = operation.Identifier.StartsWith("elementwise.", StringComparison.Ordinal);
            if (!form && !operation.Identifier.StartsWith("elementwise-valid.", StringComparison.Ordinal))
                continue;
            var arity = operation.Arity - (form ? 1 : 0);
            for (var mask = 1; mask < 1 << arity; mask++)
                expressions.Add(MathBlockFusedExpression.Create(ElementwiseProgram(operation.Identifier, form, arity, mask)));
        }
        var random = new Random(611);
        for (var trial = 0; trial < 40; trial++)
            expressions.Add(MathBlockFusedExpression.Create(MathBlockFusedTestSupport.CreateRandomProgram(
                random, random.Next(1, 7), random.Next(0, 3), random.Next(0, 3),
                random.Next(1, MathBlockFusedExpression.MaximumOperationNodes + 1),
                random.Next(1, MathBlockFusedExpression.MaximumOutputs + 1), elementwisePercent: 50)));
        return expressions;
    }

    private static MathBlockProgram SingleOperation(string identity, string arguments, char result)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var inputs = new List<int>();
        for (var index = 0; index < arguments.Length; index++)
        {
            var name = "i" + index.ToString(CultureInfo.InvariantCulture);
            switch (arguments[index])
            {
                case 'S':
                    inputs.Add(builder.Input(name, MathBlockType.Scalar()));
                    break;
                case 'B':
                    inputs.Add(builder.Input(name, MathBlockType.BooleanVector()));
                    break;
                case 'C':
                    inputs.Add(builder.Apply("complex-vector.create", 1, builder.Input(name + "r", MathBlockType.Vector()), builder.Input(name + "i", MathBlockType.Vector())));
                    break;
                default:
                    inputs.Add(builder.Input(name, MathBlockType.Vector()));
                    break;
            }
        }

        var node = builder.Apply(identity, 1, [.. inputs]);
        if (result == 'C')
            node = builder.Apply("complex-vector.real", 1, node);
        return builder.Output("out", node).Build();
    }

    private static MathBlockProgram ElementwiseProgram(string identifier, bool form, int arity, int mask)
    {
        var builder = new MathBlockProgramBuilder(MathBlockCatalog.Standard);
        var inputs = new List<int>();
        for (var index = 0; index < arity; index++)
        {
            var type = (mask >> index & 1) != 0 ? MathBlockType.Vector() : MathBlockType.Scalar();
            inputs.Add(builder.Input("a" + index.ToString(CultureInfo.InvariantCulture), type));
        }
        if (form)
            inputs.Add(builder.Input("fill", MathBlockType.Scalar()));
        return builder.Output("out", builder.Apply(identifier, 1, [.. inputs])).Build();
    }

    private static string FusedSource(IEnumerable<MathBlockFusedExpression> expressions) =>
        string.Concat(expressions.DistinctBy(expression => expression.Fingerprint, StringComparer.Ordinal).Select(expression => expression.CudaSource + "\n"));

    private static void CompileUnder(string source, MathBlockDomainOptions options, bool fusedMultiplyAdd, string label)
    {
        var composed = MathBlockCudaDeviceModule.ComposeSource(source, options);
        try
        {
            var bytes = (byte[])Compile.Invoke(null, [composed, "mathblocks-fused.cu", Architecture, fusedMultiplyAdd])!;
            Assert.Contains(".entry", Encoding.UTF8.GetString(bytes), StringComparison.Ordinal);
        }
        catch (TargetInvocationException exception) when (exception.InnerException is not null)
        {
            throw new InvalidOperationException($"{label}: {exception.InnerException.Message}", exception.InnerException);
        }
    }

    /// <summary>Verifies the fused source of every program the fused device tests build compiles with NVRTC under the defaults, with and without contraction.</summary>
    [Theory]
    [Trait("Category", "NvrtcInteropContract")]
    [InlineData(false)]
    [InlineData(true)]
    public void EveryFusedExpressionSourceCompilesWithNVRTCUnderTheDefaults(bool fusedMultiplyAdd)
    {
        var expressions = Expressions();
        var source = FusedSource(expressions);

        CompileUnder(source, MathBlockDomainOptions.Default, fusedMultiplyAdd, $"defaults fmad={fusedMultiplyAdd}, {expressions.Count} expressions");
    }

    /// <summary>
    /// Verifies the fused source compiles with NVRTC after the device source of each domain option set the fused and domain device tests use.
    /// Option sets that give the same device source are compiled once, and the compilations run in parallel.
    /// </summary>
    [Fact]
    [Trait("Category", "NvrtcInteropContract")]
    public void TheFusedExpressionSourceCompilesWithNVRTCUnderEveryDomainOptionSet()
    {
        var expressions = Expressions();
        var source = FusedSource(expressions.Where((_, index) => index < 2 || index % 11 == 0));
        var distinct = new Dictionary<string, (string Names, MathBlockDomainOptions Options)>(StringComparer.Ordinal);
        foreach (var (name, options) in OptionSets())
        {
            var key = MathBlockCudaDeviceModule.ComposeSource("// option set key", options);
            distinct[key] = distinct.TryGetValue(key, out var existing) ? (existing.Names + ", " + name, options) : (name, options);
        }

        var failures = new System.Collections.Concurrent.ConcurrentBag<string>();
        Parallel.ForEach(
            distinct.Values,
            new ParallelOptions { MaxDegreeOfParallelism = Math.Clamp(Environment.ProcessorCount, 1, 4) },
            item =>
            {
                try
                {
                    CompileUnder(source, item.Options, fusedMultiplyAdd: false, item.Names);
                }
                catch (Exception exception) when (exception is InvalidOperationException or Xunit.Sdk.XunitException)
                {
                    failures.Add($"[{item.Names}] {exception.Message}");
                }
            });

        Assert.True(distinct.Count > 1, "The option sets give one device source.");
        Assert.True(failures.IsEmpty, $"{failures.Count} of {distinct.Count} option sets failed:\n" + string.Join('\n', failures));
    }
}
