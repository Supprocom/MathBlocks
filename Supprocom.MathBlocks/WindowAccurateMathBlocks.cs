namespace Supprocom.MathBlocks;

/// <summary>
/// The six <c>window-accurate.*</c> forms <c>(x, width, fill)</c> and their <c>window-accurate-valid.*</c> siblings
/// <c>(x, width)</c>, computed from exact sliding window sums. Row t depends only on rows t - width + 1 .. t.
/// </summary>
/// <remarks>
/// <para>Guarantees, with u = 2^-53, v the exact window variance, m the exact window mean and
/// kappa = 1 + m^2 / v (population variance):</para>
/// <list type="bullet">
/// <item><description><c>window-accurate.sum@1</c>: the exact window sum, correctly rounded.</description></item>
/// <item><description><c>window-accurate.mean@1</c>: the exact window sum divided by the width, correctly
/// rounded.</description></item>
/// <item><description><c>window-accurate.population-variance@1</c> and <c>window-accurate.sample-variance@1</c>:
/// +0 when every value of the window compares equal, otherwise within 2u v + 18 u^2 kappa v of the exact variance.
/// Valid input range: a row is computed only when S2 = sum x^2 and S1^2 are 0 or within [2^-968, the largest
/// double], S1^2 / w is 0 or within [2^-968, 2^996] and the rounded S2 - S1^2 / w is 0 or at least 2^-968, roughly
/// windows of values between 1e-146 and 1e149 in magnitude; other rows hold the fill and the sibling is
/// false.</description></item>
/// <item><description><c>window-accurate.population-standard-deviation@1</c> and
/// <c>window-accurate.sample-standard-deviation@1</c>: the square root of that variance, within
/// min(B / (sqrt(max(v - B, 0)) + sqrt(v)), sqrt(B)) + u sqrt(v + B) of the exact deviation, B the variance bound,
/// for a correctly rounded square root (the current MathBlockPrimitives.Sqrt needs 3u/2 + 4u^2 in place of
/// u). Same valid input range as the variances.</description></item>
/// </list>
/// <para>Each form has the length, warm-up and fill rules of the window lift; a row whose result is not finite holds
/// the fill. Its source operation supplies the types (the result unit and the fill unit); the rows and the derivation
/// of the bounds are in MathBlockWindowAccurate.</para>
/// </remarks>
internal static class WindowAccurateMathBlocks
{
    internal const string FormFamily = "window-accurate";
    internal const string ValidityFamily = "window-accurate-valid";

    private static readonly MathBlockValue Level = MathBlockValue.Vector([2d, 2d, 2d, 5d, 1d, 4d]);

    // Name, type source and regression rows for the sample Level at width 3; NaN marks a filled row.
    private static readonly AccurateDefinition[] Definitions =
    [
        new("sum", MathBlockWindowAccurateStatistic.Sum, VectorMathBlocks.VectorSumV1Block.Create,
            [double.NaN, double.NaN, 6d, 9d, 8d, 10d]),
        new("mean", MathBlockWindowAccurateStatistic.Mean, VectorMathBlocks.VectorMeanV1Block.Create,
            [double.NaN, double.NaN, 2d, 3d, 8d / 3d, 10d / 3d]),
        new("population-variance", MathBlockWindowAccurateStatistic.PopulationVariance,
            StatisticalMathBlocks.StatisticsPopulationVarianceV1Block.Create,
            [double.NaN, double.NaN, 0d, 2d, 78d / 27d, 78d / 27d]),
        new("sample-variance", MathBlockWindowAccurateStatistic.SampleVariance,
            StatisticalMathBlocks.StatisticsSampleVarianceV1Block.Create,
            [double.NaN, double.NaN, 0d, 3d, 78d / 18d, 78d / 18d]),
        new("population-standard-deviation", MathBlockWindowAccurateStatistic.PopulationStandardDeviation,
            StatisticalMathBlocks.StatisticsPopulationStandardDeviationV1Block.Create,
            [double.NaN, double.NaN, 0d, Math.Sqrt(2d), Math.Sqrt(78d / 27d), Math.Sqrt(78d / 27d)]),
        new("sample-standard-deviation", MathBlockWindowAccurateStatistic.SampleStandardDeviation,
            StatisticalMathBlocks.StatisticsSampleStandardDeviationV1Block.Create,
            [double.NaN, double.NaN, 0d, Math.Sqrt(3d), Math.Sqrt(78d / 18d), Math.Sqrt(78d / 18d)])
    ];

    internal static MathBlockWindowEntry[] CreateEntries()
    {
        var result = new MathBlockWindowEntry[Definitions.Length];
        for (var index = 0; index < Definitions.Length; index++)
        {
            var definition = Definitions[index];
            var form = new MathBlockWindowForm(
                definition.TypeSource(),
                MathBlockWindowLift.Scalar,
                [true],
                new MathBlockWindowAccurateKernel(definition.Statistic));
            result[index] = new MathBlockWindowEntry(
                form,
                CreateForm(definition, form),
                CreateValidity(definition, form));
        }
        return result;
    }

    private static MathBlockOperation CreateForm(AccurateDefinition definition, MathBlockWindowForm form)
    {
        var unit = form.ResolveResultUnit([Level.Type]);
        var expected = new double[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
        {
            expected[index] = double.IsNaN(definition.Expected[index])
                ? WindowMathBlocks.SampleFill
                : definition.Expected[index];
        }
        return MathBlockOperationFactory.Create(
            $"{FormFamily}.{definition.Name}",
            form.FormArity,
            form.FormTypeResolver,
            form.EvaluateForm,
            [Level, MathBlockValue.Scalar(WindowMathBlocks.SampleWidth), MathBlockValue.Scalar(WindowMathBlocks.SampleFill, unit)],
            MathBlockValue.Vector(expected, unit),
            1e-12,
            64,
            MathBlockCausalityInfo.Trailing(form.FormArity - 2));
    }

    private static MathBlockOperation CreateValidity(AccurateDefinition definition, MathBlockWindowForm form)
    {
        var expected = new bool[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = !double.IsNaN(definition.Expected[index]);
        return MathBlockOperationFactory.Create(
            $"{ValidityFamily}.{definition.Name}",
            form.ValidityArity,
            form.ValidityTypeResolver,
            form.EvaluateValidity,
            [Level, MathBlockValue.Scalar(WindowMathBlocks.SampleWidth)],
            MathBlockValue.BooleanVector(expected),
            performanceIterations: 64,
            causality: MathBlockCausalityInfo.Trailing(form.ValidityArity - 1));
    }

    private sealed record AccurateDefinition(
        string Name,
        MathBlockWindowAccurateStatistic Statistic,
        Func<MathBlockOperation> TypeSource,
        double[] Expected);
}
