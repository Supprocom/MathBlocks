using static Supprocom.MathBlocks.Tests.MathBlockWindowM2TestSupport;

namespace Supprocom.MathBlocks.Tests;

/// <summary>Verifies the window batch against each form evaluated alone.</summary>
public sealed class MathBlocksWindowBatchTests
{
    private const double Sentinel = 31.5d;

    private static readonly int[] Widths = [1, 2, 3, 17, 96, 0, -1, 400, 401];

    /// <summary>Gets every form identity the batch supports.</summary>
    public static TheoryData<string> Identities =>
    [
        .. KernelSources.Select(source => $"window.{source}@1"),
        .. AccurateNames.Select(name => $"window-accurate.{name}@1")
    ];

    /// <summary>
    /// Verifies each width's result is bit-identical to the form evaluated alone at that width, including the
    /// type and the invalid state and reason of out-of-domain widths.
    /// </summary>
    [Theory]
    [MemberData(nameof(Identities))]
    public void EachWidthEqualsTheFormEvaluatedAlone(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var operation = Resolve(identity);
        var random = new Random(41);
        var values = new double[400];
        for (var row = 0; row < values.Length; row++)
            values[row] = row is >= 100 and < 220 ? 7d : random.Next(5) == 0 ? -0d : random.NextDouble() * 50d;
        var series = MathBlockValue.Vector(values);
        foreach (var parameters in Parameters(identity))
        {
            var results = parameters.Length == 0
                ? MathBlocksWindowBatch.Evaluate(series, identity, Widths, Sentinel)
                : MathBlocksWindowBatch.Evaluate(series, identity, parameters, Widths, Sentinel);

            Assert.Equal(Widths.Length, results.Count);
            for (var index = 0; index < Widths.Length; index++)
            {
                var alone = operation.Evaluate([series, .. parameters, MathBlockValue.Scalar(Widths[index]), MathBlockValue.Scalar(Sentinel)]);
                var difference = Difference(alone, results[index]);
                Assert.True(difference is null, $"{identity} w={Widths[index]}: {difference}");
            }
        }
    }

    /// <summary>Verifies the paired entry point equals the form and its sibling evaluated separately.</summary>
    [Theory]
    [MemberData(nameof(Identities))]
    public void ValuesAndValidityEqualTheTwoIdentitiesEvaluatedSeparately(string identity)
    {
        ArgumentException.ThrowIfNullOrEmpty(identity);
        var operation = Resolve(identity);
        var sibling = MathBlockWindowTestSupport.Windowed.Get(SiblingIdentifier(identity));
        var random = new Random(43);
        var values = new double[300];
        for (var row = 0; row < values.Length; row++)
            values[row] = row is >= 50 and < 80 ? 3d : random.NextDouble() * 4d;
        var series = MathBlockValue.Vector(values);
        foreach (var parameters in Parameters(identity))
        {
            foreach (var width in new[] { 1, 2, 9, 300, 301, 0 })
            {
                foreach (var fill in new[] { Sentinel, double.NaN })
                {
                    MathBlockValue[] inputs = [series, .. parameters, MathBlockValue.Scalar(width), MathBlockValue.Scalar(fill)];
                    var result = MathBlocksWindowBatch.EvaluateWithValidity(identity, inputs);

                    var valuesDifference = Difference(operation.Evaluate(inputs), result.Values);
                    var validityDifference = Difference(sibling.Evaluate(inputs[..^1]), result.Validity);
                    Assert.True(valuesDifference is null, $"{identity} w={width} fill={fill}: values {valuesDifference}");
                    Assert.True(validityDifference is null, $"{identity} w={width} fill={fill}: validity {validityDifference}");
                }
            }
        }
    }

    /// <summary>Verifies an invalid series gives each width the form's own invalid result.</summary>
    [Fact]
    public void AnInvalidSeriesGivesTheFormsInvalidResult()
    {
        var series = MathBlockValue.Invalid(MathBlockType.Vector(), "upstream");
        foreach (var identity in new[] { "window-accurate.sum@1", "window.vector.minimum@1" })
        {
            var results = MathBlocksWindowBatch.Evaluate(series, identity, [2, 3], Sentinel);
            foreach (var (width, result) in new[] { 2, 3 }.Zip(results))
            {
                var alone = Resolve(identity).Evaluate(series, MathBlockValue.Scalar(width), MathBlockValue.Scalar(Sentinel));
                Assert.Null(Difference(alone, result));
                Assert.Equal("upstream", result.InvalidReason);
            }
        }
    }

    /// <summary>Verifies unsupported forms and wrong parameter counts are rejected with the form named.</summary>
    [Fact]
    public void UnsupportedFormsAreRejectedByName()
    {
        var series = MathBlockValue.Vector([1d, 2d, 3d]);
        foreach (var identity in new[]
                 {
                     "window.vector.sum@1", "window.statistics.population-variance@1", "window-valid.vector.minimum@1",
                     "window-accurate-valid.sum@1", "vector.minimum@1", "window-accurate.sum", "window-accurate.sum@2"
                 })
        {
            var exception = Assert.Throws<ArgumentException>(() => MathBlocksWindowBatch.Evaluate(series, identity, [2], 0d));
            Assert.Contains($"'{identity}'", exception.Message, StringComparison.Ordinal);
            var paired = Assert.Throws<ArgumentException>(
                () => MathBlocksWindowBatch.EvaluateWithValidity(identity, [series, MathBlockValue.Scalar(2d), MathBlockValue.Scalar(0d)]));
            Assert.Contains($"'{identity}'", paired.Message, StringComparison.Ordinal);
        }

        var quantile = Assert.Throws<ArgumentException>(() => MathBlocksWindowBatch.Evaluate(series, "window.vector.quantile@1", [2], 0d));
        Assert.Contains("'window.vector.quantile@1'", quantile.Message, StringComparison.Ordinal);
        Assert.Throws<ArgumentException>(
            () => MathBlocksWindowBatch.Evaluate(series, "window-accurate.mean@1", [MathBlockValue.Scalar(0.5d)], [2], 0d));
    }

    /// <summary>
    /// Verifies the CUDA entry points reject unsupported forms, wrong parameter and input counts and a null worker
    /// before they compile anything, and return no results for no widths. Nothing here reaches the CUDA driver.
    /// </summary>
    [Fact]
    public void CUDAEntryPointsRejectInvalidRequestsBeforeCompiling()
    {
        var worker = new Supprocom.MathBlocks.Cuda.MathBlocksCUDAWorker();
        var series = MathBlockValue.Vector([1d, 2d, 3d]);
        foreach (var identity in new[] { "window.vector.sum@1", "window-accurate-valid.sum@1", "vector.minimum@1", "window-accurate.sum" })
        {
            var exception = Assert.Throws<ArgumentException>(() => MathBlocksWindowBatch.EvaluateCUDA(worker, series, identity, [2], 0d));
            Assert.Contains($"'{identity}'", exception.Message, StringComparison.Ordinal);
            var paired = Assert.Throws<ArgumentException>(
                () => MathBlocksWindowBatch.EvaluateWithValidityCUDA(worker, identity, [series, MathBlockValue.Scalar(2d), MathBlockValue.Scalar(0d)]));
            Assert.Contains($"'{identity}'", paired.Message, StringComparison.Ordinal);
        }

        Assert.Throws<ArgumentException>(() => MathBlocksWindowBatch.EvaluateCUDA(worker, series, "window.vector.quantile@1", [2], 0d));
        Assert.Throws<ArgumentException>(
            () => MathBlocksWindowBatch.EvaluateCUDA(worker, series, "window-accurate.mean@1", [MathBlockValue.Scalar(0.5d)], [2], 0d));
        Assert.Throws<ArgumentException>(
            () => MathBlocksWindowBatch.EvaluateWithValidityCUDA(worker, "window-accurate.mean@1", [series, MathBlockValue.Scalar(2d)]));
        Assert.Throws<ArgumentNullException>(() => MathBlocksWindowBatch.EvaluateCUDA(null!, series, "window-accurate.mean@1", [2], 0d));
        Assert.Empty(MathBlocksWindowBatch.EvaluateCUDA(worker, series, "window-accurate.mean@1", [], 0d));
    }

    internal static MathBlockOperation Resolve(string identity) =>
        MathBlockWindowTestSupport.Windowed.Get(identity[..identity.LastIndexOf('@')]);

    internal static string SiblingIdentifier(string identity)
    {
        var identifier = identity[..identity.LastIndexOf('@')];
        return identifier.StartsWith("window-accurate.", StringComparison.Ordinal)
            ? $"window-accurate-valid.{identifier["window-accurate.".Length..]}"
            : $"window-valid.{identifier["window.".Length..]}";
    }

    internal static MathBlockValue[][] Parameters(string identity) =>
        identity.StartsWith("window.vector.quantile", StringComparison.Ordinal)
            ? [[MathBlockValue.Scalar(0.3d)], [MathBlockValue.Scalar(1d)], [MathBlockValue.Scalar(1.5d)]]
            : [[]];
}
