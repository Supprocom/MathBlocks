namespace Supprocom.MathBlocks;

internal static class ElementwiseMathBlocks
{
    internal const string FormFamily = "elementwise";
    internal const string ValidityFamily = "elementwise-valid";
    internal const double SampleFill = -1d;

    // The 41 M4 sources in catalog order: the scalar-only Standard operations without a Pointwise
    // vector.<name> form of the same meaning.
    private static readonly ElementwiseSource[] Sources =
    [
        new(AdvancedMathBlocks.CombinatoricsBallotCountV1Block.Create, [MathBlockValue.Vector([3.0d, 4.0d, 5.0d, 2.0d, 3.0d, 6.0d]), MathBlockValue.Vector([1.0d, 2.0d, 1.0d, 2.0d, 0.0d, 2.5d])],
            [2.0d, 5.0d, 4.0d, double.NaN, 1.0d, double.NaN]),
        new(ProbabilityMathBlocks.CombinatoricsBinomialCoefficientV1Block.Create, [MathBlockValue.Vector([5.0d, 6.0d, 4.0d, 3.0d, -1.0d, 2.5d]), MathBlockValue.Scalar(2.0d)],
            [10.0d, 15.0d, 6.0d, 3.0d, double.NaN, double.NaN]),
        new(ProbabilityMathBlocks.CombinatoricsFactorialV1Block.Create, [MathBlockValue.Vector([0.0d, 1.0d, 5.0d, 2.5d, 171.0d, 3.0d])],
            [1.0d, 1.0d, 120.0d, double.NaN, double.NaN, 6.0d]),
        new(ProbabilityMathBlocks.ProbabilityNormalCdfV1Block.Create, [MathBlockValue.Vector([-2.0d, -0.5d, 0.0d, 0.5d, 1.0d, 3.0d])],
            [0.022750129890124482d, 0.3085375169186018d, 0.5d, 0.6914624830813982d, 0.8413447386043253d, 0.9986501019267444d]),
        new(AdvancedMathBlocks.ProbabilityPoissonCdfV1Block.Create, [MathBlockValue.Scalar(2.0d), MathBlockValue.Vector([0.0d, 1.0d, 2.0d, 3.0d, -1.0d, 1.5d])],
            [0.1353352832366128d, 0.4060058497098382d, 0.6766764161830634d, 0.8571234604985469d, double.NaN, double.NaN]),
        new(AdvancedMathBlocks.ProbabilityPoissonPmfV1Block.Create, [MathBlockValue.Vector([0.5d, 1.0d, 2.0d, 4.0d, -1.0d, 3.0d]), MathBlockValue.Scalar(2.0d)],
            [0.0758163324640791d, 0.183939720585721d, 0.2706705664732251d, 0.1465251111098733d, double.NaN, 0.22404180765538745d]),
        new(ScalarMathBlocks.ScalarArcCosineV1Block.Create, [MathBlockValue.Vector([-1.0d, -0.5d, 0.0d, 0.5d, 1.0d, 2.0d])],
            [3.141592653589793d, 2.0943951023931953d, 1.5707963267948966d, 1.0471975511965979d, 0.0d, double.NaN]),
        new(ScalarMathBlocks.ScalarArcSineV1Block.Create, [MathBlockValue.Vector([-1.0d, -0.5d, 0.0d, 0.5d, 1.0d, 2.0d])],
            [-1.5707963267948966d, -0.5235987755982989d, 0.0d, 0.5235987755982989d, 1.5707963267948966d, double.NaN]),
        new(ScalarMathBlocks.ScalarArcTangent2V1Block.Create, [MathBlockValue.Vector([1.0d, -1.0d, 0.0d, 1.0d, -1.0d, 0.0d]), MathBlockValue.Vector([1.0d, 1.0d, -1.0d, -1.0d, -1.0d, 0.0d])],
            [0.7853981633974483d, -0.7853981633974483d, 3.141592653589793d, 2.356194490192345d, -2.356194490192345d, 0.0d]),
        new(ScalarMathBlocks.ScalarArcTangentV1Block.Create, [MathBlockValue.Vector([-2.0d, -1.0d, 0.0d, 0.5d, 1.0d, 10.0d])],
            [-1.1071487177940904d, -0.7853981633974483d, 0.0d, 0.4636476090008061d, 0.7853981633974483d, 1.4711276743037345d]),
        new(ScalarMathBlocks.ScalarBinaryLogarithmV1Block.Create, [MathBlockValue.Vector([0.5d, 1.0d, 2.0d, 8.0d, 0.0d, -1.0d])],
            [-1.0d, 0.0d, 1.0d, 3.0d, double.NaN, 0.0d]),
        new(ScalarMathBlocks.ScalarCeilingV1Block.Create, [MathBlockValue.Vector([-1.5d, -0.5d, 0.5d, 1.5d, 2.5d, -2.5d])],
            [-1.0d, -0.0d, 1.0d, 2.0d, 3.0d, -2.0d]),
        new(ScalarMathBlocks.ScalarClampV1Block.Create, [MathBlockValue.Vector([5.0d, -5.0d, 2.0d, 0.5d, 3.0d, 4.0d]), MathBlockValue.Scalar(-4.0d), MathBlockValue.Vector([3.0d, 3.0d, 3.0d, 1.0d, 2.0d, 10.0d])],
            [3.0d, -4.0d, 2.0d, 0.5d, 2.0d, 4.0d]),
        new(ScalarMathBlocks.ScalarCommonLogarithmV1Block.Create, [MathBlockValue.Vector([0.1d, 1.0d, 10.0d, 100.0d, 0.0d, -1.0d])],
            [-0.9999999999999998d, 0.0d, 1.0d, 2.0d, double.NaN, double.NaN]),
        new(ScalarMathBlocks.ScalarCosineV1Block.Create, [MathBlockValue.Vector([0.0d, 0.5d, 1.0d, -1.0d, 2.0d, 3.0d])],
            [1.0d, 0.8775825618903728d, 0.5403023058681398d, 0.5403023058681398d, -0.4161468365471424d, -0.9899924966004454d]),
        new(ScalarMathBlocks.ScalarCubeRootV1Block.Create, [MathBlockValue.Vector([-8.0d, -1.0d, 0.0d, 1.0d, 8.0d, 27.0d])],
            [-2.0d, -1.0d, 0.0d, 1.0d, 2.0d, 3.0d]),
        new(ScalarMathBlocks.ScalarCubeV1Block.Create, [MathBlockValue.Vector([-2.0d, -1.0d, 0.0d, 1.5d, 2.0d, 1e+200d])],
            [-8.0d, -1.0d, 0.0d, 3.375d, 8.0d, double.NaN]),
        new(ScalarMathBlocks.ScalarFloorV1Block.Create, [MathBlockValue.Vector([-1.5d, -0.5d, 0.5d, 1.5d, 2.5d, -2.5d])],
            [-2.0d, -1.0d, 0.0d, 1.0d, 2.0d, -3.0d]),
        new(ScalarMathBlocks.ScalarHyperbolicCosineV1Block.Create, [MathBlockValue.Vector([0.0d, 0.5d, 1.0d, -1.0d, 2.0d, 800.0d])],
            [1.0d, 1.1276259652063807d, 1.543080634815244d, 1.543080634815244d, 3.7621956910836314d, double.NaN]),
        new(ScalarMathBlocks.ScalarHyperbolicSineV1Block.Create, [MathBlockValue.Vector([0.0d, 0.5d, 1.0d, -1.0d, 2.0d, 800.0d])],
            [0.0d, 0.5210953054937474d, 1.1752011936438016d, -1.1752011936438016d, 3.626860407847019d, double.NaN]),
        new(ScalarMathBlocks.ScalarHyperbolicTangentV1Block.Create, [MathBlockValue.Vector([0.0d, 0.5d, 1.0d, -1.0d, 2.0d, -3.0d])],
            [0.0d, 0.4621171572600098d, 0.7615941559557649d, -0.7615941559557649d, 0.964027580075817d, -0.9950547536867306d]),
        new(ScalarMathBlocks.ScalarInverseHyperbolicCosineV1Block.Create, [MathBlockValue.Vector([1.0d, 2.0d, 10.0d, 0.5d, 3.0d, 0.0d])],
            [0.0d, 1.3169578969248166d, 2.993222846126381d, double.NaN, 1.7627471740390859d, double.NaN]),
        new(ScalarMathBlocks.ScalarInverseHyperbolicSineV1Block.Create, [MathBlockValue.Vector([-2.0d, -0.5d, 0.0d, 0.5d, 1.0d, 3.0d])],
            [-1.4436354751788103d, -0.48121182505960347d, 0.0d, 0.48121182505960347d, 0.8813735870195429d, 1.8184464592320668d]),
        new(ScalarMathBlocks.ScalarInverseHyperbolicTangentV1Block.Create, [MathBlockValue.Vector([-0.5d, 0.0d, 0.5d, 0.9d, 1.0d, 2.0d])],
            [-0.5493061443340548d, 0.0d, 0.5493061443340548d, 1.4722194895832204d, double.NaN, double.NaN]),
        new(ScalarMathBlocks.ScalarLogOnePlusV1Block.Create, [MathBlockValue.Vector([-0.5d, 0.0d, 0.5d, 1.0d, -1.0d, -2.0d])],
            [-0.6931471805599453d, 0.0d, 0.4054651081081644d, 0.6931471805599453d, double.NaN, double.NaN]),
        new(ScalarMathBlocks.ScalarLogisticV1Block.Create, [MathBlockValue.Vector([-2.0d, -0.5d, 0.0d, 0.5d, 1.0d, 3.0d])],
            [0.11920292202211755d, 0.37754066879814546d, 0.5d, 0.6224593312018546d, 0.7310585786300049d, 0.9525741268224334d]),
        new(ScalarMathBlocks.ScalarLogitV1Block.Create, [MathBlockValue.Vector([0.25d, 0.5d, 0.75d, 0.0d, 1.0d, 2.0d])],
            [-1.0986122886681098d, 0.0d, 1.0986122886681096d, double.NaN, double.NaN, double.NaN]),
        new(ScalarMathBlocks.ScalarMaximumV1Block.Create, [MathBlockValue.Vector([1.0d, -2.0d, 3.0d, 0.0d, 5.0d, -1.0d]), MathBlockValue.Vector([2.0d, -3.0d, 3.0d, 1.0d, 4.0d, -1.0d])],
            [2.0d, -2.0d, 3.0d, 1.0d, 5.0d, -1.0d]),
        new(ScalarMathBlocks.ScalarMinimumV1Block.Create, [MathBlockValue.Vector([1.0d, -2.0d, 3.0d, 0.0d, 5.0d, -1.0d]), MathBlockValue.Vector([2.0d, -3.0d, 3.0d, 1.0d, 4.0d, -1.0d])],
            [1.0d, -3.0d, 3.0d, 0.0d, 4.0d, -1.0d]),
        new(ScalarMathBlocks.ScalarModuloV1Block.Create, [MathBlockValue.Vector([7.0d, -7.0d, 7.5d, 1.0d, 5.0d, 3.0d]), MathBlockValue.Vector([3.0d, 3.0d, 2.0d, 0.5d, 0.0d, -2.0d])],
            [1.0d, -1.0d, 1.5d, 0.0d, double.NaN, 1.0d]),
        new(ScalarMathBlocks.ScalarNegateV1Block.Create, [MathBlockValue.Vector([-2.0d, -0.5d, 0.0d, 0.5d, 1.0d, 3.0d])],
            [2.0d, 0.5d, -0.0d, -0.5d, -1.0d, -3.0d]),
        new(ScalarMathBlocks.ScalarReciprocalV1Block.Create, [MathBlockValue.Vector([0.5d, 1.0d, 2.0d, -4.0d, 0.0d, 8.0d])],
            [2.0d, 1.0d, 0.5d, -0.25d, double.NaN, 0.125d]),
        new(ScalarMathBlocks.ScalarRoundV1Block.Create, [MathBlockValue.Vector([-1.5d, -0.5d, 0.5d, 1.5d, 2.5d, -2.5d])],
            [-2.0d, -0.0d, 0.0d, 2.0d, 2.0d, -2.0d]),
        new(ScalarMathBlocks.ScalarSineV1Block.Create, [MathBlockValue.Vector([0.0d, 0.5d, 1.0d, -1.0d, 2.0d, 3.0d])],
            [0.0d, 0.479425538604203d, 0.8414709848078965d, -0.8414709848078965d, 0.9092974268256816d, 0.1411200080598672d]),
        new(ScalarMathBlocks.ScalarSoftplusV1Block.Create, [MathBlockValue.Vector([-2.0d, -0.5d, 0.0d, 0.5d, 1.0d, 3.0d])],
            [0.1269280110429725d, 0.4740769841801067d, 0.6931471805599453d, 0.9740769841801067d, 1.3132616875182228d, 3.048587351573742d]),
        new(ScalarMathBlocks.ScalarTangentV1Block.Create, [MathBlockValue.Vector([0.0d, 0.5d, 1.0d, -1.0d, 2.0d, 3.0d])],
            [0.0d, 0.5463024898437905d, 1.557407724654902d, -1.557407724654902d, -2.1850398632615184d, -0.1425465430742778d]),
        new(ScalarMathBlocks.ScalarTruncateV1Block.Create, [MathBlockValue.Vector([-1.5d, -0.5d, 0.5d, 1.5d, 2.5d, -2.5d])],
            [-1.0d, -0.0d, 0.0d, 1.0d, 2.0d, -2.0d]),
        new(ProbabilityMathBlocks.SpecialBetaV1Block.Create, [MathBlockValue.Vector([2.0d, 0.5d, 1.0d, 3.0d, 0.0d, -1.0d]), MathBlockValue.Vector([3.0d, 0.5d, 1.0d, 2.0d, 1.0d, 1.0d])],
            [0.08333333333333355d, 3.1415926535897927d, 0.9999999999999982d, 0.08333333333333355d, double.NaN, double.NaN]),
        new(ScalarMathBlocks.SpecialErrorFunctionV1Block.Create, [MathBlockValue.Vector([-2.0d, -0.5d, 0.0d, 0.5d, 1.0d, 3.0d])],
            [-0.995322265010666d, -0.5204999077232426d, 0.0d, 0.5204999077232426d, 0.8427007877600067d, 0.9999779095015785d]),
        new(ProbabilityMathBlocks.SpecialLogGammaV1Block.Create, [MathBlockValue.Vector([0.5d, 1.0d, 2.0d, 5.0d, 0.0d, -1.0d])],
            [0.5723649429246995d, -8.881784197001252e-16d, 0.0d, 3.178053830347944d, double.NaN, double.NaN]),
        new(ProbabilityMathBlocks.SpecialRegularizedIncompleteBetaV1Block.Create, [MathBlockValue.Vector([0.0d, 0.25d, 0.5d, 1.0d, 1.5d, -0.1d]), MathBlockValue.Scalar(2.0d), MathBlockValue.Vector([1.0d, 2.0d, 3.0d, 0.5d, 1.0d, 1.0d])],
            [0.0d, 0.15625d, 0.6875000000000009d, 1.0d, double.NaN, double.NaN])
    ];

    internal static MathBlockOperation[] CreateOperations()
    {
        var sources = Sources;
        var result = new MathBlockOperation[sources.Length * 2];
        for (var index = 0; index < sources.Length; index++)
        {
            result[index * 2] = CreateForm(sources[index]);
            result[index * 2 + 1] = CreateValidity(sources[index]);
        }
        return result;
    }

    private static MathBlockOperation CreateForm(ElementwiseSource definition)
    {
        var form = new MathBlockElementwiseForm(definition.Create());
        var sample = new MathBlockValue[form.FormArity];
        for (var index = 0; index < definition.Sample.Length; index++)
            sample[index] = definition.Sample[index];
        var expected = new double[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = double.IsNaN(definition.Expected[index]) ? SampleFill : definition.Expected[index];
        var outputUnit = form.ResolveSourceUnit(MathBlockCollectionPrimitives.Map(definition.Sample, value => value.Type));
        sample[^1] = MathBlockValue.Scalar(SampleFill, outputUnit);
        return MathBlockOperationFactory.Create(
            $"{FormFamily}.{form.Source.Identifier}",
            form.FormArity,
            form.FormTypeResolver,
            form.EvaluateForm,
            sample,
            MathBlockValue.Vector(expected, outputUnit),
            1e-12,
            64,
            MathBlockCausalityInfo.Pointwise);
    }

    private static MathBlockOperation CreateValidity(ElementwiseSource definition)
    {
        var form = new MathBlockElementwiseForm(definition.Create());
        var expected = new bool[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = !double.IsNaN(definition.Expected[index]);
        return MathBlockOperationFactory.Create(
            $"{ValidityFamily}.{form.Source.Identifier}",
            form.ValidityArity,
            form.ValidityTypeResolver,
            form.EvaluateValidity,
            definition.Sample,
            MathBlockValue.BooleanVector(expected),
            performanceIterations: 64,
            causality: MathBlockCausalityInfo.Pointwise);
    }

    // Create builds an independent instance of the source operation; Sample holds the source arguments (vectors
    // and broadcast scalars) used for the regression and performance cases with fill -1; Expected holds the
    // regression rows, with NaN marking a filled row.
    private sealed record ElementwiseSource(
        Func<MathBlockOperation> Create,
        MathBlockValue[] Sample,
        double[] Expected);
}
