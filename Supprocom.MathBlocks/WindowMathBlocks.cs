namespace Supprocom.MathBlocks;

internal static class WindowMathBlocks
{
    internal const string FormFamily = "window";
    internal const string ValidityFamily = "window-valid";
    internal const double SampleWidth = 3d;
    internal const double SampleFill = -1d;

    private static readonly MathBlockValue Level = MathBlockValue.Vector([2d, 2d, 2d, 5d, 1d, 4d]);
    private static readonly MathBlockValue Response = MathBlockValue.Vector([1d, 3d, 2d, 6d, 2d, 7d]);
    private static readonly MathBlockValue Weights = MathBlockValue.Vector([1d, 2d, 1d, 3d, 1d, 2d]);
    private static readonly MathBlockValue Signed = MathBlockValue.Vector([-1d, 2d, -3d, 1d, 1d, -2d]);
    private static readonly MathBlockValue Probabilities = MathBlockValue.Vector([0.5d, 0.25d, 0.25d, 0.5d, 0.25d, 0.5d]);
    private static readonly MathBlockValue Flags = MathBlockValue.BooleanVector([true, true, false, true, true, true]);

    // The M1 source list, in design order: 25 statistics, 10 path, 5 information, 9 vector reductions,
    // 2 window positions and 2 last-row lifts.
    private static readonly WindowSource[] Sources =
    [
        new(StatisticalMathBlocks.StatisticsAutocorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(1d)],
            [double.NaN, double.NaN, double.NaN, double.NaN, -1.0d, -1.0d]),
        new(AdvancedMathBlocks.StatisticsCentralMomentV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(2d)],
            [double.NaN, double.NaN, 0.0d, 2.0d, 2.8888888888888893d, 2.8888888888888893d]),
        new(StatisticalMathBlocks.StatisticsDistanceCorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 0.9789651245099754d, 0.9789651245099753d, 0.9731978874249747d]),
        new(StatisticalMathBlocks.StatisticsInterquartileRangeV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 1.5d, 2.0d, 2.0d]),
        new(StatisticalMathBlocks.StatisticsKendallTauBV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 0.8164965809277261d, 0.8164965809277261d, 0.3333333333333333d]),
        new(StatisticalMathBlocks.StatisticsLinearInterceptV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 0.16666666666666652d, 0.46153846153846256d, 1.1538461538461542d]),
        new(StatisticalMathBlocks.StatisticsLinearRSquaredV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 0.9423076923076925d, 0.9423076923076918d, 0.8241758241758245d]),
        new(StatisticalMathBlocks.StatisticsLinearSlopeV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 1.1666666666666667d, 1.0769230769230766d, 1.1538461538461537d]),
        new(StatisticalMathBlocks.StatisticsMedianAbsoluteDeviationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 0.0d, 1.0d, 1.0d]),
        new(StatisticalMathBlocks.StatisticsPearsonCorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 0.9707253433941511d, 0.9707253433941507d, 0.9078412990032038d]),
        new(StatisticalMathBlocks.StatisticsPopulationCovarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, 0.0d, 2.3333333333333335d, 3.1111111111111107d, 3.3333333333333335d]),
        new(StatisticalMathBlocks.StatisticsPopulationExcessKurtosisV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, double.NaN, -1.5d, -1.5d, -1.5d]),
        new(StatisticalMathBlocks.StatisticsPopulationSkewnessV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, double.NaN, 0.7071067811865476d, 0.5280049792181881d, -0.5280049792181881d]),
        new(StatisticalMathBlocks.StatisticsPopulationStandardDeviationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 1.414213562373095d, 1.699673171197595d, 1.699673171197595d]),
        new(StatisticalMathBlocks.StatisticsPopulationVarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 2.0d, 2.8888888888888893d, 2.8888888888888893d]),
        new(AdvancedMathBlocks.StatisticsPseudomedianV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 2.75d, 2.5d, 3.5d]),
        new(AdvancedMathBlocks.StatisticsRawMomentV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(2d)],
            [double.NaN, double.NaN, 4.0d, 11.0d, 10.0d, 14.0d]),
        new(StatisticalMathBlocks.StatisticsRootMeanSquareV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 3.3166247903554d, 3.162277660168379d, 3.7416573867739413d]),
        new(StatisticalMathBlocks.StatisticsSampleCovarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, 0.0d, 3.5d, 4.666666666666666d, 5.0d]),
        new(StatisticalMathBlocks.StatisticsSampleStandardDeviationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 1.7320508075688772d, 2.081665999466133d, 2.081665999466133d]),
        new(StatisticalMathBlocks.StatisticsSampleVarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 3.0d, 4.333333333333334d, 4.333333333333334d]),
        new(StatisticalMathBlocks.StatisticsSpearmanCorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 0.8660254037844387d, 0.8660254037844387d, 0.5d]),
        new(StatisticalMathBlocks.StatisticsTheilSenSlopeV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [double.NaN, double.NaN, double.NaN, 1.1666666666666665d, 1.0d, 1.0d]),
        new(StatisticalMathBlocks.StatisticsWeightedMeanV1Block.Create, MathBlockWindowLift.Scalar, [Level, Weights],
            [double.NaN, double.NaN, 2.0d, 3.5d, 3.6d, 4.0d]),
        new(StatisticalMathBlocks.StatisticsWeightedPopulationVarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level, Weights],
            [double.NaN, double.NaN, 0.0d, 2.25d, 3.04d, 2.0d]),
        new(PathMathBlocks.PathLongestTrueRunV1Block.Create, MathBlockWindowLift.Scalar, [Flags],
            [double.NaN, double.NaN, 2.0d, 1.0d, 2.0d, 3.0d]),
        new(PathMathBlocks.PathMaximumDeclineV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 0.0d, 4.0d, 4.0d]),
        new(PathMathBlocks.PathMaximumRelativeDeclineV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 0.0d, 0.8d, 0.8d]),
        new(PathMathBlocks.PathPowerVariationV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(2d)],
            [double.NaN, double.NaN, 0.0d, 9.0d, 25.0d, 25.0d]),
        new(PathMathBlocks.PathQuadraticVariationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 9.0d, 25.0d, 25.0d]),
        new(PathMathBlocks.PathRecurrenceRateV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(1d)],
            [double.NaN, double.NaN, 1.0d, 0.5555555555555556d, 0.5555555555555556d, 0.5555555555555556d]),
        new(PathMathBlocks.PathTotalVariationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 3.0d, 7.0d, 7.0d]),
        new(PathMathBlocks.PathTurningPointCountV1Block.Create, MathBlockWindowLift.Scalar, [Signed],
            [double.NaN, double.NaN, 1.0d, 1.0d, 0.0d, 0.0d]),
        new(PathMathBlocks.PathZeroCrossingCountV1Block.Create, MathBlockWindowLift.Scalar, [Signed],
            [double.NaN, double.NaN, 2.0d, 2.0d, 1.0d, 1.0d]),
        new(PathMathBlocks.PathFirstPassageIndexV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(4d), MathBlockValue.Boolean(true)],
            [double.NaN, double.NaN, -1.0d, 2.0d, 1.0d, 0.0d]),
        new(ProbabilityMathBlocks.InformationShannonEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities],
            [double.NaN, double.NaN, 1.0397207708399179d, 1.0397207708399179d, 1.0397207708399179d, double.NaN]),
        new(ProbabilityMathBlocks.InformationRenyiEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities, MathBlockValue.Scalar(2d)],
            [double.NaN, double.NaN, 0.9808292530117262d, 0.9808292530117262d, 0.9808292530117262d, double.NaN]),
        new(ProbabilityMathBlocks.InformationTsallisEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities, MathBlockValue.Scalar(2d)],
            [double.NaN, double.NaN, 0.625d, 0.625d, 0.625d, double.NaN]),
        new(ProbabilityMathBlocks.InformationGiniImpurityV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities],
            [double.NaN, double.NaN, 0.625d, 0.625d, 0.625d, double.NaN]),
        new(ProbabilityMathBlocks.InformationBinaryShannonEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities],
            [double.NaN, double.NaN, 1.5d, 1.5d, 1.5d, double.NaN]),
        new(VectorMathBlocks.VectorSumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 6.0d, 9.0d, 8.0d, 10.0d]),
        new(VectorMathBlocks.VectorMeanV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 3.0d, 2.6666666666666665d, 3.3333333333333335d]),
        new(VectorMathBlocks.VectorMinimumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 2.0d, 1.0d, 1.0d]),
        new(VectorMathBlocks.VectorMaximumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 5.0d, 5.0d, 5.0d]),
        new(VectorMathBlocks.VectorGeometricMeanV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 2.7144176165949063d, 2.154434690031884d, 2.7144176165949063d]),
        new(VectorMathBlocks.VectorL1NormV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 6.0d, 9.0d, 8.0d, 10.0d]),
        new(VectorMathBlocks.VectorL2NormV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 3.4641016151377544d, 5.744562646538029d, 5.477225575051661d, 6.48074069840786d]),
        new(VectorMathBlocks.VectorMedianV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 2.0d, 2.0d, 2.0d, 4.0d]),
        new(VectorMathBlocks.VectorQuantileV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(0.25d)],
            [double.NaN, double.NaN, 2.0d, 2.0d, 1.5d, 2.5d]),
        new(VectorMathBlocks.VectorArgMaximumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 2.0d, 1.0d, 0.0d]),
        new(VectorMathBlocks.VectorArgMinimumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [double.NaN, double.NaN, 0.0d, 0.0d, 2.0d, 1.0d]),
        new(VectorMathBlocks.VectorRankV1Block.Create, MathBlockWindowLift.LastRow, [Level],
            [double.NaN, double.NaN, 2.0d, 3.0d, 1.0d, 2.0d]),
        new(VectorMathBlocks.VectorStandardizeV1Block.Create, MathBlockWindowLift.LastRow, [Level],
            [double.NaN, double.NaN, double.NaN, 1.4142135623730951d, -0.98058067569092d, 0.392232270276368d])
    ];

    private static readonly Lazy<MathBlockWindowEntry[]> entries = new(CreateEntries);
    private static readonly Lazy<MathBlockRegistry> directReference = new(CreateDirectReference);

    // Every window.*, window-valid.*, window-prefix.* and window-prefix-valid.* operation with its form. The
    // operations are the instances registered in MathBlockCatalog.Windowed.
    internal static IReadOnlyList<MathBlockWindowEntry> Entries => entries.Value;

    // The window.* and window-valid.* forms evaluated by the direct lift on every row, including the forms that have
    // a kernel. It is the reference the kernels are tested against.
    internal static MathBlockRegistry DirectReference => directReference.Value;

    internal static MathBlockOperation[] CreateOperations()
    {
        var all = Entries;
        var result = new MathBlockOperation[all.Count * 2];
        for (var index = 0; index < all.Count; index++)
        {
            result[index * 2] = all[index].FormOperation;
            result[index * 2 + 1] = all[index].ValidityOperation;
        }
        return result;
    }

    // The forms the window batch accepts: those whose rows come from a kernel.
    internal static bool TryGetBatchEntry(string formIdentity, out MathBlockWindowEntry entry)
    {
        var all = Entries;
        for (var index = 0; index < all.Count; index++)
        {
            if (all[index].Form.Kernel is not null &&
                string.Equals(all[index].FormOperation.Identity, formIdentity, StringComparison.Ordinal))
            {
                entry = all[index];
                return true;
            }
        }
        entry = null!;
        return false;
    }

    private static MathBlockWindowEntry[] CreateEntries()
    {
        var sources = Sources;
        var prefix = WindowPrefixMathBlocks.CreateEntries();
        var result = new MathBlockWindowEntry[sources.Length + prefix.Length];
        for (var index = 0; index < sources.Length; index++)
            result[index] = CreateEntry(sources[index], direct: false);
        for (var index = 0; index < prefix.Length; index++)
            result[sources.Length + index] = prefix[index];
        return result;
    }

    private static MathBlockRegistry CreateDirectReference()
    {
        var sources = Sources;
        var result = new MathBlockOperation[sources.Length * 2];
        for (var index = 0; index < sources.Length; index++)
        {
            var entry = CreateEntry(sources[index], direct: true);
            result[index * 2] = entry.FormOperation;
            result[index * 2 + 1] = entry.ValidityOperation;
        }
        return new MathBlockRegistry(result);
    }

    private static MathBlockWindowEntry CreateEntry(WindowSource definition, bool direct)
    {
        var form = CreateLift(definition);
        if (direct)
            form = form.WithoutKernel();
        return new MathBlockWindowEntry(form, CreateForm(definition, form), CreateValidity(definition, form));
    }

    private static MathBlockWindowForm CreateLift(WindowSource definition)
    {
        var source = definition.Create();
        var series = new bool[definition.Sample.Length];
        for (var index = 0; index < series.Length; index++)
            series[index] = definition.Sample[index].Type.Kind is
                MathBlockValueKind.Vector or MathBlockValueKind.BooleanVector;
        return new MathBlockWindowForm(source, definition.Lift, series, CreateKernel(source.Identifier));
    }

    // The M2 fast paths behind M1 identities. Each kernel gives the bits of the direct lift on every row.
    private static MathBlockWindowKernel? CreateKernel(string sourceIdentifier) => sourceIdentifier switch
    {
        "vector.minimum" => new MathBlockWindowExtremeKernel(maximum: false, position: false),
        "vector.maximum" => new MathBlockWindowExtremeKernel(maximum: true, position: false),
        "vector.arg-minimum" => new MathBlockWindowExtremeKernel(maximum: false, position: true),
        "vector.arg-maximum" => new MathBlockWindowExtremeKernel(maximum: true, position: true),
        "vector.median" => new MathBlockWindowQuantileKernel(median: true),
        "vector.quantile" => new MathBlockWindowQuantileKernel(median: false),
        _ => null
    };

    private static MathBlockOperation CreateForm(WindowSource definition, MathBlockWindowForm form)
    {
        var sample = new MathBlockValue[form.FormArity];
        for (var index = 0; index < definition.Sample.Length; index++)
            sample[index] = definition.Sample[index];
        sample[^2] = MathBlockValue.Scalar(SampleWidth);
        var expected = new double[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = double.IsNaN(definition.Expected[index]) ? SampleFill : definition.Expected[index];
        var outputUnit = form.Source
            .ResolveOutputType(MathBlockCollectionPrimitives.Map(definition.Sample, value => value.Type))
            .Unit;
        sample[^1] = MathBlockValue.Scalar(SampleFill, outputUnit);
        return MathBlockOperationFactory.Create(
            $"{FormFamily}.{form.Source.Identifier}",
            form.FormArity,
            form.FormTypeResolver,
            form.EvaluateForm,
            sample,
            MathBlockValue.Vector(expected, outputUnit),
            1e-12,
            16,
            MathBlockCausalityInfo.Trailing(form.FormArity - 2));
    }

    private static MathBlockOperation CreateValidity(WindowSource definition, MathBlockWindowForm form)
    {
        var sample = new MathBlockValue[form.ValidityArity];
        for (var index = 0; index < definition.Sample.Length; index++)
            sample[index] = definition.Sample[index];
        sample[^1] = MathBlockValue.Scalar(SampleWidth);
        var expected = new bool[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = !double.IsNaN(definition.Expected[index]);
        return MathBlockOperationFactory.Create(
            $"{ValidityFamily}.{form.Source.Identifier}",
            form.ValidityArity,
            form.ValidityTypeResolver,
            form.EvaluateValidity,
            sample,
            MathBlockValue.BooleanVector(expected),
            performanceIterations: 16,
            causality: MathBlockCausalityInfo.Trailing(form.ValidityArity - 1));
    }

    // Create builds an independent instance of the source operation; Sample holds the source inputs used for the
    // regression and performance cases with width 3 and fill -1; Expected holds the regression rows, with NaN
    // marking a filled row.
    private sealed record WindowSource(
        Func<MathBlockOperation> Create,
        MathBlockWindowLift Lift,
        MathBlockValue[] Sample,
        double[] Expected);
}
