namespace Supprocom.MathBlocks;

internal static class WindowMathBlocks
{
    internal const string FormFamily = "window";
    internal const string ValidityFamily = "window-valid";
    internal const float SampleWidth = 3f;
    internal const float SampleFill = -1f;

    private static readonly MathBlockValue Level = MathBlockValue.Vector([2f, 2f, 2f, 5f, 1f, 4f]);
    private static readonly MathBlockValue Response = MathBlockValue.Vector([1f, 3f, 2f, 6f, 2f, 7f]);
    private static readonly MathBlockValue Weights = MathBlockValue.Vector([1f, 2f, 1f, 3f, 1f, 2f]);
    private static readonly MathBlockValue Signed = MathBlockValue.Vector([-1f, 2f, -3f, 1f, 1f, -2f]);
    private static readonly MathBlockValue Probabilities = MathBlockValue.Vector([0.5f, 0.25f, 0.25f, 0.5f, 0.25f, 0.5f]);
    private static readonly MathBlockValue Flags = MathBlockValue.BooleanVector([true, true, false, true, true, true]);

    // The M1 source list, in design order: 25 statistics, 10 path, 5 information, 9 vector reductions,
    // 2 window positions and 2 last-row lifts.
    private static readonly WindowSource[] Sources =
    [
        new(StatisticalMathBlocks.StatisticsAutocorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(1f)],
            [float.NaN, float.NaN, float.NaN, float.NaN, -1.0f, -1.0f]),
        new(AdvancedMathBlocks.StatisticsCentralMomentV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(2f)],
            [float.NaN, float.NaN, 0.0f, 2.0f, 2.8888888888888893f, 2.8888888888888893f]),
        new(StatisticalMathBlocks.StatisticsDistanceCorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 0.9789651245099754f, 0.9789651245099753f, 0.9731978874249747f]),
        new(StatisticalMathBlocks.StatisticsInterquartileRangeV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 1.5f, 2.0f, 2.0f]),
        new(StatisticalMathBlocks.StatisticsKendallTauBV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 0.8164965809277261f, 0.8164965809277261f, 0.3333333333333333f]),
        new(StatisticalMathBlocks.StatisticsLinearInterceptV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 0.16666666666666652f, 0.46153846153846256f, 1.1538461538461542f]),
        new(StatisticalMathBlocks.StatisticsLinearRSquaredV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 0.9423076923076925f, 0.9423076923076918f, 0.8241758241758245f]),
        new(StatisticalMathBlocks.StatisticsLinearSlopeV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 1.1666666666666667f, 1.0769230769230766f, 1.1538461538461537f]),
        new(StatisticalMathBlocks.StatisticsMedianAbsoluteDeviationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 0.0f, 1.0f, 1.0f]),
        new(StatisticalMathBlocks.StatisticsPearsonCorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 0.9707253433941511f, 0.9707253433941507f, 0.9078412990032038f]),
        new(StatisticalMathBlocks.StatisticsPopulationCovarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, 0.0f, 2.3333333333333335f, 3.1111111111111107f, 3.3333333333333335f]),
        new(StatisticalMathBlocks.StatisticsPopulationExcessKurtosisV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, float.NaN, -1.5f, -1.5f, -1.5f]),
        new(StatisticalMathBlocks.StatisticsPopulationSkewnessV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, float.NaN, 0.7071067811865476f, 0.5280049792181881f, -0.5280049792181881f]),
        new(StatisticalMathBlocks.StatisticsPopulationStandardDeviationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 1.414213562373095f, 1.699673171197595f, 1.699673171197595f]),
        new(StatisticalMathBlocks.StatisticsPopulationVarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 2.0f, 2.8888888888888893f, 2.8888888888888893f]),
        new(AdvancedMathBlocks.StatisticsPseudomedianV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 2.75f, 2.5f, 3.5f]),
        new(AdvancedMathBlocks.StatisticsRawMomentV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(2f)],
            [float.NaN, float.NaN, 4.0f, 11.0f, 10.0f, 14.0f]),
        new(StatisticalMathBlocks.StatisticsRootMeanSquareV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 3.3166247903554f, 3.162277660168379f, 3.7416573867739413f]),
        new(StatisticalMathBlocks.StatisticsSampleCovarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, 0.0f, 3.5f, 4.666666666666666f, 5.0f]),
        new(StatisticalMathBlocks.StatisticsSampleStandardDeviationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 1.7320508075688772f, 2.081665999466133f, 2.081665999466133f]),
        new(StatisticalMathBlocks.StatisticsSampleVarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 3.0f, 4.333333333333334f, 4.333333333333334f]),
        new(StatisticalMathBlocks.StatisticsSpearmanCorrelationV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 0.8660254037844387f, 0.8660254037844387f, 0.5f]),
        new(StatisticalMathBlocks.StatisticsTheilSenSlopeV1Block.Create, MathBlockWindowLift.Scalar, [Level, Response],
            [float.NaN, float.NaN, float.NaN, 1.1666666666666665f, 1.0f, 1.0f]),
        new(StatisticalMathBlocks.StatisticsWeightedMeanV1Block.Create, MathBlockWindowLift.Scalar, [Level, Weights],
            [float.NaN, float.NaN, 2.0f, 3.5f, 3.6f, 4.0f]),
        new(StatisticalMathBlocks.StatisticsWeightedPopulationVarianceV1Block.Create, MathBlockWindowLift.Scalar, [Level, Weights],
            [float.NaN, float.NaN, 0.0f, 2.25f, 3.04f, 2.0f]),
        new(PathMathBlocks.PathLongestTrueRunV1Block.Create, MathBlockWindowLift.Scalar, [Flags],
            [float.NaN, float.NaN, 2.0f, 1.0f, 2.0f, 3.0f]),
        new(PathMathBlocks.PathMaximumDeclineV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 0.0f, 4.0f, 4.0f]),
        new(PathMathBlocks.PathMaximumRelativeDeclineV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 0.0f, 0.8f, 0.8f]),
        new(PathMathBlocks.PathPowerVariationV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(2f)],
            [float.NaN, float.NaN, 0.0f, 9.0f, 25.0f, 25.0f]),
        new(PathMathBlocks.PathQuadraticVariationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 9.0f, 25.0f, 25.0f]),
        new(PathMathBlocks.PathRecurrenceRateV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(1f)],
            [float.NaN, float.NaN, 1.0f, 0.5555555555555556f, 0.5555555555555556f, 0.5555555555555556f]),
        new(PathMathBlocks.PathTotalVariationV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 3.0f, 7.0f, 7.0f]),
        new(PathMathBlocks.PathTurningPointCountV1Block.Create, MathBlockWindowLift.Scalar, [Signed],
            [float.NaN, float.NaN, 1.0f, 1.0f, 0.0f, 0.0f]),
        new(PathMathBlocks.PathZeroCrossingCountV1Block.Create, MathBlockWindowLift.Scalar, [Signed],
            [float.NaN, float.NaN, 2.0f, 2.0f, 1.0f, 1.0f]),
        new(PathMathBlocks.PathFirstPassageIndexV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(4f), MathBlockValue.Boolean(true)],
            [float.NaN, float.NaN, -1.0f, 2.0f, 1.0f, 0.0f]),
        new(ProbabilityMathBlocks.InformationShannonEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities],
            [float.NaN, float.NaN, 1.0397207708399179f, 1.0397207708399179f, 1.0397207708399179f, float.NaN]),
        new(ProbabilityMathBlocks.InformationRenyiEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities, MathBlockValue.Scalar(2f)],
            [float.NaN, float.NaN, 0.9808292530117262f, 0.9808292530117262f, 0.9808292530117262f, float.NaN]),
        new(ProbabilityMathBlocks.InformationTsallisEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities, MathBlockValue.Scalar(2f)],
            [float.NaN, float.NaN, 0.625f, 0.625f, 0.625f, float.NaN]),
        new(ProbabilityMathBlocks.InformationGiniImpurityV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities],
            [float.NaN, float.NaN, 0.625f, 0.625f, 0.625f, float.NaN]),
        new(ProbabilityMathBlocks.InformationBinaryShannonEntropyV1Block.Create, MathBlockWindowLift.Scalar, [Probabilities],
            [float.NaN, float.NaN, 1.5f, 1.5f, 1.5f, float.NaN]),
        new(VectorMathBlocks.VectorSumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 6.0f, 9.0f, 8.0f, 10.0f]),
        new(VectorMathBlocks.VectorMeanV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 3.0f, 2.6666666666666665f, 3.3333333333333335f]),
        new(VectorMathBlocks.VectorMinimumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 2.0f, 1.0f, 1.0f]),
        new(VectorMathBlocks.VectorMaximumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 5.0f, 5.0f, 5.0f]),
        new(VectorMathBlocks.VectorGeometricMeanV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 2.7144176165949063f, 2.154434690031884f, 2.7144176165949063f]),
        new(VectorMathBlocks.VectorL1NormV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 6.0f, 9.0f, 8.0f, 10.0f]),
        new(VectorMathBlocks.VectorL2NormV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 3.4641016151377544f, 5.744562646538029f, 5.477225575051661f, 6.48074069840786f]),
        new(VectorMathBlocks.VectorMedianV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 2.0f, 2.0f, 2.0f, 4.0f]),
        new(VectorMathBlocks.VectorQuantileV1Block.Create, MathBlockWindowLift.Scalar, [Level, MathBlockValue.Scalar(0.25f)],
            [float.NaN, float.NaN, 2.0f, 2.0f, 1.5f, 2.5f]),
        new(VectorMathBlocks.VectorArgMaximumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 2.0f, 1.0f, 0.0f]),
        new(VectorMathBlocks.VectorArgMinimumV1Block.Create, MathBlockWindowLift.Scalar, [Level],
            [float.NaN, float.NaN, 0.0f, 0.0f, 2.0f, 1.0f]),
        new(VectorMathBlocks.VectorRankV1Block.Create, MathBlockWindowLift.LastRow, [Level],
            [float.NaN, float.NaN, 2.0f, 3.0f, 1.0f, 2.0f]),
        new(VectorMathBlocks.VectorStandardizeV1Block.Create, MathBlockWindowLift.LastRow, [Level],
            [float.NaN, float.NaN, float.NaN, 1.4142135623730951f, -0.98058067569092f, 0.392232270276368f])
    ];

    private static readonly Lazy<MathBlockWindowEntry[]> entries = new(CreateEntries);
    private static readonly Lazy<MathBlockRegistry> directReference = new(CreateDirectReference);

    // Every window.*, window-valid.*, window-accurate.* and window-accurate-valid.* operation with its form. The
    // operations are the instances registered in MathBlockCatalog.Windowed and MathBlockCatalog.Standard.
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
        var accurate = WindowAccurateMathBlocks.CreateEntries();
        var result = new MathBlockWindowEntry[sources.Length + accurate.Length];
        for (var index = 0; index < sources.Length; index++)
            result[index] = CreateEntry(sources[index], direct: false);
        for (var index = 0; index < accurate.Length; index++)
            result[sources.Length + index] = accurate[index];
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
        var expected = new float[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = float.IsNaN(definition.Expected[index]) ? SampleFill : definition.Expected[index];
        var outputUnit = form.Source
            .ResolveOutputType(MathBlockCollectionPrimitives.Map(definition.Sample, value => value.Type))
            .Unit;
        sample[^1] = MathBlockValue.Scalar(SampleFill, outputUnit);
        var operation = MathBlockOperationFactory.Create(
            $"{FormFamily}.{form.Source.Identifier}",
            form.FormArity,
            form.FormTypeResolver,
            form.EvaluateForm,
            sample,
            MathBlockValue.Vector(expected, outputUnit),
            1e-12f,
            16,
            MathBlockCausalityInfo.Trailing(form.FormArity - 2));
        operation.TypeSignatureFactory = () => form.CreateSignature(operation.Identity, validity: false);
        return operation;
    }

    private static MathBlockOperation CreateValidity(WindowSource definition, MathBlockWindowForm form)
    {
        var sample = new MathBlockValue[form.ValidityArity];
        for (var index = 0; index < definition.Sample.Length; index++)
            sample[index] = definition.Sample[index];
        sample[^1] = MathBlockValue.Scalar(SampleWidth);
        var expected = new bool[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = !float.IsNaN(definition.Expected[index]);
        var operation = MathBlockOperationFactory.Create(
            $"{ValidityFamily}.{form.Source.Identifier}",
            form.ValidityArity,
            form.ValidityTypeResolver,
            form.EvaluateValidity,
            sample,
            MathBlockValue.BooleanVector(expected),
            performanceIterations: 16,
            causality: MathBlockCausalityInfo.Trailing(form.ValidityArity - 1));
        operation.TypeSignatureFactory = () => form.CreateSignature(operation.Identity, validity: true);
        return operation;
    }

    // Create builds an independent instance of the source operation; Sample holds the source inputs used for the
    // regression and performance cases with width 3 and fill -1; Expected holds the regression rows, with NaN
    // marking a filled row.
    private sealed record WindowSource(
        Func<MathBlockOperation> Create,
        MathBlockWindowLift Lift,
        MathBlockValue[] Sample,
        float[] Expected);
}
