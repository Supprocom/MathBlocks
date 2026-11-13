using System.Reflection;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Contains the CoreCLR tests of the elementwise lifts of the double-valued scalar operations, and of the opcode encoding of the elementwise forms.</summary>
public sealed class MathBlockElementwiseLiftTests
{
    private static readonly string[] LiftedSources =
    [
        "scalar.absolute", "scalar.add", "scalar.subtract", "scalar.multiply", "scalar.divide", "scalar.power",
        "scalar.natural-logarithm", "scalar.square-root", "scalar.square", "scalar.exponential", "scalar.positive-part", "scalar.sign"
    ];

    // Zeros of both signs, infinities, NaN, negatives, an overflowing square, and values inside and outside each domain.
    private static readonly double[] Probes =
        [0d, -0d, 1d, -1d, 0.5d, -2.5d, 3d, 400d, 1e200d, 1e308d, -1e308d, double.PositiveInfinity, double.NegativeInfinity, double.NaN];

    /// <summary>Gets the lifted source names.</summary>
    public static TheoryData<string> SourceNames() => [.. LiftedSources];

    /// <summary>Verifies each lifted source has a form and a sibling, and the registry holds 24 more operations than before.</summary>
    [Fact]
    public void EachLiftedScalarOperationHasAFormAndASibling()
    {
        foreach (var source in LiftedSources)
        {
            Assert.Equal($"elementwise.{source}@1", MathBlockCatalog.Standard.Get("elementwise." + source).Identity);
            Assert.Equal($"elementwise-valid.{source}@1", MathBlockCatalog.Standard.Get("elementwise-valid." + source).Identity);
        }

        Assert.Equal(561, MathBlockCatalog.Standard.Operations.Count);
        Assert.Equal(MathBlockCatalog.Standard.Operations.Count, MathBlockCudaDeviceModule.Operations.Count);
    }

    /// <summary>Verifies each row is invalid when an argument is non-finite or the source result is not finite, and otherwise the scalar operation's own value.</summary>
    [Theory]
    [MemberData(nameof(SourceNames))]
    public void ARowIsTheScalarOperationsValueOrInvalid(string source)
    {
        ArgumentException.ThrowIfNullOrEmpty(source);
        var scalar = MathBlockCatalog.Standard.Get(source);
        var rows = 0;
        foreach (var arguments in Combinations(scalar.Arity))
        {
            var (computed, value) = MathBlockElementwiseRowReference.Row(source, arguments);
            var inputs = arguments.Select(argument => MathBlockValue.Scalar(argument)).ToArray();
            var reference = scalar.Evaluate(inputs);
            Assert.Equal(reference.IsValid, computed);
            if (computed)
                Assert.Equal(BitConverter.DoubleToInt64Bits(reference.AsScalar()), BitConverter.DoubleToInt64Bits(value));
            if (!arguments.All(double.IsFinite))
                Assert.False(computed, string.Join(',', arguments));
            rows++;
        }

        Assert.Equal((int)Math.Pow(Probes.Length, scalar.Arity), rows);
    }

    /// <summary>Verifies the rows the lifts exist for: divide by 0, a logarithm and a square root out of domain, and overflow, each invalid on its own row only.</summary>
    [Fact]
    public void TheLiftsGiveEachRowItsOwnValidity()
    {
        var divide = MathBlockCatalog.Standard.Get("elementwise.scalar.divide");
        var result = divide.Evaluate(MathBlockValue.Vector([6d, 1d, -3d, 1e308d]), MathBlockValue.Vector([3d, 0d, 2d, 1e-10d]), MathBlockValue.Scalar(-1d));
        Assert.Equal([2d, -1d, -1.5d, -1d], result.AsVector().ToArray());
        var valid = MathBlockCatalog.Standard.Get("elementwise-valid.scalar.divide")
            .Evaluate(MathBlockValue.Vector([6d, 1d, -3d, 1e308d]), MathBlockValue.Vector([3d, 0d, 2d, 1e-10d]));
        Assert.Equal([true, false, true, false], valid.AsBooleanVector().ToArray());

        var logarithm = MathBlockCatalog.Standard.Get("elementwise.scalar.natural-logarithm")
            .Evaluate(MathBlockValue.Vector([1d, 0d, -1d, Math.E]), MathBlockValue.Scalar(-9d));
        Assert.Equal([0d, -9d, -9d, 1d], logarithm.AsVector().ToArray());
        var root = MathBlockCatalog.Standard.Get("elementwise-valid.scalar.square-root").Evaluate(MathBlockValue.Vector([4d, -4d, 0d]));
        Assert.Equal([true, false, true], root.AsBooleanVector().ToArray());
        var square = MathBlockCatalog.Standard.Get("elementwise-valid.scalar.square").Evaluate(MathBlockValue.Vector([3d, 1e200d]));
        Assert.Equal([true, false], square.AsBooleanVector().ToArray());
        var vectorTwin = MathBlockCatalog.Standard.Get("vector.divide", 1).Evaluate(MathBlockValue.Vector([6d, 1d]), MathBlockValue.Vector([3d, 0d]));
        Assert.False(vectorTwin.IsValid);
    }

    /// <summary>Verifies the opcode of every source below 64 is the encoding of every earlier version, and every contract opcode of the catalog matches it.</summary>
    [Fact]
    public void SourcesBelow64KeepTheLegacyOpcodes()
    {
        for (var source = 0; source < 64; source++)
        {
            for (var sibling = 0; sibling < 2; sibling++)
            {
                for (var mask = 0; mask < 8; mask++)
                {
                    var opcode = Opcode.Encode(source, sibling == 1, mask);
                    Assert.Equal(2 * source + sibling + 128 * mask, opcode);
                    Assert.InRange(opcode, 0, 1023);
                    Assert.Equal((source, sibling == 1, mask), Opcode.Decode(opcode));
                }
            }
        }

        Assert.Equal(82, MathBlockCudaDeviceModule.GetOperation("elementwise.scalar.absolute@1").Opcode);
        Assert.Equal(105, MathBlockCudaDeviceModule.GetOperation("elementwise-valid.scalar.sign@1").Opcode);
        Assert.Equal(54, MathBlockCudaDeviceModule.GetOperation("elementwise.scalar.maximum@1").Opcode);
        var opcodes = ElementwiseCudaBlockCatalog_Features().Select(feature => feature.Opcode).Order().ToArray();
        Assert.Equal(Enumerable.Range(0, opcodes.Length).ToArray(), opcodes);
        Assert.Equal(106, opcodes.Length);
    }

    /// <summary>Verifies the wide encoding round-trips for synthetic sources 64, 1000 and 32,767 with every mask and sibling, and the cap is the int32 opcode.</summary>
    [Fact]
    public void LargerSourcesUseTheWideEncoding()
    {
        foreach (var source in new[] { 64, 65, 1_000, 32_766, 32_767 })
        {
            for (var sibling = 0; sibling < 2; sibling++)
            {
                for (var mask = 0; mask < 8; mask++)
                {
                    var opcode = Opcode.Encode(source, sibling == 1, mask);
                    Assert.Equal(1024 + 2 * source + sibling + 65_536 * mask, opcode);
                    Assert.True(opcode >= 1024);
                    Assert.Equal((source, sibling == 1, mask), Opcode.Decode(opcode));
                    Assert.Equal(opcode, Opcode.AddMask(Opcode.Encode(source, sibling == 1, 0), mask));
                }
            }
        }

        Assert.Equal(32_767, Opcode.MaximumSourceIndex);
        Assert.True(Opcode.Encode(32_767, true, 7) > 0);
        Assert.Throws<ArgumentOutOfRangeException>(() => Opcode.Encode(32_768, false, 0));
        Assert.Throws<ArgumentOutOfRangeException>(() => Opcode.Encode(0, false, 8));
        Assert.True(ElementwiseSourceCount() <= Opcode.MaximumSourceCount);
        Assert.Equal(53, ElementwiseSourceCount());
    }

    /// <summary>Verifies the limit catalog records the source count, derived from the opcode encoding.</summary>
    [Fact]
    public void TheLimitCatalogRecordsTheSourceCount()
    {
        var limit = MathBlockLimits.Resolve().Single(candidate => string.Equals(candidate.Name, "elementwise.maximum-source-count", StringComparison.Ordinal));

        Assert.Equal(MathBlockLimitKind.Derived, limit.Kind);
        Assert.Equal(53L, limit.Value);
        Assert.Equal(32_768L, limit.Maximum);
        Assert.Contains("int32 opcode and 3 mask bits", limit.Rule, StringComparison.Ordinal);
    }

    // The internal opcode encoding, through reflection: the test assembly has no access to the library's internals.
    private static class Opcode
    {
        private static readonly Type Type = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.MathBlockCudaElementwiseOpcode", throwOnError: true)!;

        internal static int MaximumSourceIndex => (int)Type.GetField(nameof(MaximumSourceIndex), BindingFlags.Static | BindingFlags.NonPublic)!.GetRawConstantValue()!;

        internal static int MaximumSourceCount => (int)Type.GetField(nameof(MaximumSourceCount), BindingFlags.Static | BindingFlags.NonPublic)!.GetRawConstantValue()!;

        internal static int Encode(int source, bool sibling, int mask) => Call(nameof(Encode), source, sibling, mask);

        internal static int AddMask(int contractOpcode, int mask) => Call(nameof(AddMask), contractOpcode, mask);

        internal static (int Source, bool Sibling, int Mask) Decode(int opcode) => Call<(int, bool, int)>(nameof(Decode), opcode);

        private static int Call(string name, params object[] arguments) => Call<int>(name, arguments);

        private static T Call<T>(string name, params object[] arguments)
        {
            try
            {
                return (T)Type.GetMethod(name, BindingFlags.Static | BindingFlags.NonPublic)!.Invoke(null, arguments)!;
            }
            catch (TargetInvocationException exception) when (exception.InnerException is not null)
            {
                throw exception.InnerException;
            }
        }
    }

    private static IEnumerable<double[]> Combinations(int arity) => arity == 1
        ? Probes.Select(first => new[] { first })
        : Probes.SelectMany(first => Probes.Select(second => new[] { first, second }));

    private static IEnumerable<(string Identity, int Opcode)> ElementwiseCudaBlockCatalog_Features()
    {
        var catalog = typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.Cuda.ElementwiseCudaBlockCatalog", throwOnError: true)!;
        var features = (Array)catalog.GetField("Features", BindingFlags.Static | BindingFlags.NonPublic)!.GetValue(null)!;
        foreach (var feature in features)
        {
            var type = feature.GetType();
            yield return ((string)type.GetProperty("Identity")!.GetValue(feature)!, (int)type.GetProperty("Opcode")!.GetValue(feature)!);
        }
    }

    private static int ElementwiseSourceCount() =>
        (int)typeof(MathBlockCudaDeviceModule).Assembly.GetType("Supprocom.MathBlocks.ElementwiseMathBlocks", throwOnError: true)!
            .GetProperty("SourceCount", BindingFlags.Static | BindingFlags.NonPublic)!.GetValue(null)!;
}
