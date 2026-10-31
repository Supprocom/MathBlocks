namespace Supprocom.MathBlocks;

// The six window-prefix.* forms (x, width, fill) and their window-prefix-valid.* siblings (x, width). Each form has
// the length, warm-up and fill rules of the window lift. Its source operation supplies the types (the result unit
// and the fill unit); the rows come from MathBlockWindowPrefix, whose error bounds are stated there.
internal static class WindowPrefixMathBlocks
{
    internal const string FormFamily = "window-prefix";
    internal const string ValidityFamily = "window-prefix-valid";

    private static readonly MathBlockValue Level = MathBlockValue.Vector([2d, 2d, 2d, 5d, 1d, 4d]);

    // Name, type source and regression rows for the sample Level at width 3; NaN marks a filled row.
    private static readonly PrefixDefinition[] Definitions =
    [
        new("sum", MathBlockWindowPrefixStatistic.Sum, VectorMathBlocks.VectorSumV1Block.Create,
            [double.NaN, double.NaN, 6d, 9d, 8d, 10d]),
        new("mean", MathBlockWindowPrefixStatistic.Mean, VectorMathBlocks.VectorMeanV1Block.Create,
            [double.NaN, double.NaN, 2d, 3d, 8d / 3d, 10d / 3d]),
        new("population-variance", MathBlockWindowPrefixStatistic.PopulationVariance,
            StatisticalMathBlocks.StatisticsPopulationVarianceV1Block.Create,
            [double.NaN, double.NaN, 0d, 2d, 78d / 27d, 78d / 27d]),
        new("sample-variance", MathBlockWindowPrefixStatistic.SampleVariance,
            StatisticalMathBlocks.StatisticsSampleVarianceV1Block.Create,
            [double.NaN, double.NaN, 0d, 3d, 78d / 18d, 78d / 18d]),
        new("population-standard-deviation", MathBlockWindowPrefixStatistic.PopulationStandardDeviation,
            StatisticalMathBlocks.StatisticsPopulationStandardDeviationV1Block.Create,
            [double.NaN, double.NaN, 0d, Math.Sqrt(2d), Math.Sqrt(78d / 27d), Math.Sqrt(78d / 27d)]),
        new("sample-standard-deviation", MathBlockWindowPrefixStatistic.SampleStandardDeviation,
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
                new MathBlockWindowPrefixKernel(definition.Statistic));
            result[index] = new MathBlockWindowEntry(
                form,
                CreateForm(definition, form),
                CreateValidity(definition, form));
        }
        return result;
    }

    private static MathBlockOperation CreateForm(PrefixDefinition definition, MathBlockWindowForm form)
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

    private static MathBlockOperation CreateValidity(PrefixDefinition definition, MathBlockWindowForm form)
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

    private sealed record PrefixDefinition(
        string Name,
        MathBlockWindowPrefixStatistic Statistic,
        Func<MathBlockOperation> TypeSource,
        double[] Expected);
}
