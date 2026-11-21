using System.Runtime.CompilerServices;

namespace Supprocom.MathBlocks;

internal static class ElementwiseMathBlocks
{
    internal const string FormFamily = "elementwise";
    internal const string ValidityFamily = "elementwise-valid";
    internal const float SampleFill = -1f;

    // The sources in catalog order, so each source's index, and with it every opcode, is fixed once it is added. The first 41 are the
    // scalar-only Standard operations without a Pointwise vector.<name> form of the same meaning. The last 12 are the double-valued
    // scalar operations whose vector.<name> twin has whole-value validity (one bad row invalidates the vector): the lifts give each row its own
    // validity, as the elementwise forms of the others do.
    private static readonly ElementwiseSource[] Sources =
    [
        new(AdvancedMathBlocks.CombinatoricsBallotCountV1Block.Create, [MathBlockValue.Vector([3.0f, 4.0f, 5.0f, 2.0f, 3.0f, 6.0f]), MathBlockValue.Vector([1.0f, 2.0f, 1.0f, 2.0f, 0.0f, 2.5f])],
            [2.0f, 5.0f, 4.0f, float.NaN, 1.0f, float.NaN]),
        new(ProbabilityMathBlocks.CombinatoricsBinomialCoefficientV1Block.Create, [MathBlockValue.Vector([5.0f, 6.0f, 4.0f, 3.0f, -1.0f, 2.5f]), MathBlockValue.Scalar(2.0f)],
            [10.0f, 15.0f, 6.0f, 3.0f, float.NaN, float.NaN]),
        new(ProbabilityMathBlocks.CombinatoricsFactorialV1Block.Create, [MathBlockValue.Vector([0.0f, 1.0f, 5.0f, 2.5f, 171.0f, 3.0f])],
            [1.0f, 1.0f, 120.0f, float.NaN, float.NaN, 6.0f]),
        new(ProbabilityMathBlocks.ProbabilityNormalCdfV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [0.022750129890124482f, 0.3085375169186018f, 0.5f, 0.6914624830813982f, 0.8413447386043253f, 0.9986501019267444f]),
        new(AdvancedMathBlocks.ProbabilityPoissonCdfV1Block.Create, [MathBlockValue.Scalar(2.0f), MathBlockValue.Vector([0.0f, 1.0f, 2.0f, 3.0f, -1.0f, 1.5f])],
            [0.1353352832366128f, 0.4060058497098382f, 0.6766764161830634f, 0.8571234604985469f, float.NaN, float.NaN]),
        new(AdvancedMathBlocks.ProbabilityPoissonPmfV1Block.Create, [MathBlockValue.Vector([0.5f, 1.0f, 2.0f, 4.0f, -1.0f, 3.0f]), MathBlockValue.Scalar(2.0f)],
            [0.0758163324640791f, 0.183939720585721f, 0.2706705664732251f, 0.1465251111098733f, float.NaN, 0.22404180765538745f]),
        new(ScalarMathBlocks.ScalarArcCosineV1Block.Create, [MathBlockValue.Vector([-1.0f, -0.5f, 0.0f, 0.5f, 1.0f, 2.0f])],
            [3.141592653589793f, 2.0943951023931953f, 1.5707963267948966f, 1.0471975511965979f, 0.0f, float.NaN]),
        new(ScalarMathBlocks.ScalarArcSineV1Block.Create, [MathBlockValue.Vector([-1.0f, -0.5f, 0.0f, 0.5f, 1.0f, 2.0f])],
            [-1.5707963267948966f, -0.5235987755982989f, 0.0f, 0.5235987755982989f, 1.5707963267948966f, float.NaN]),
        new(ScalarMathBlocks.ScalarArcTangent2V1Block.Create, [MathBlockValue.Vector([1.0f, -1.0f, 0.0f, 1.0f, -1.0f, 0.0f]), MathBlockValue.Vector([1.0f, 1.0f, -1.0f, -1.0f, -1.0f, 0.0f])],
            [0.7853981633974483f, -0.7853981633974483f, 3.141592653589793f, 2.356194490192345f, -2.356194490192345f, 0.0f]),
        new(ScalarMathBlocks.ScalarArcTangentV1Block.Create, [MathBlockValue.Vector([-2.0f, -1.0f, 0.0f, 0.5f, 1.0f, 10.0f])],
            [-1.1071487177940904f, -0.7853981633974483f, 0.0f, 0.4636476090008061f, 0.7853981633974483f, 1.4711276743037345f]),
        new(ScalarMathBlocks.ScalarBinaryLogarithmV1Block.Create, [MathBlockValue.Vector([0.5f, 1.0f, 2.0f, 8.0f, 0.0f, -1.0f])],
            [-1.0f, 0.0f, 1.0f, 3.0f, float.NaN, 0.0f]),
        new(ScalarMathBlocks.ScalarCeilingV1Block.Create, [MathBlockValue.Vector([-1.5f, -0.5f, 0.5f, 1.5f, 2.5f, -2.5f])],
            [-1.0f, -0.0f, 1.0f, 2.0f, 3.0f, -2.0f]),
        new(ScalarMathBlocks.ScalarClampV1Block.Create, [MathBlockValue.Vector([5.0f, -5.0f, 2.0f, 0.5f, 3.0f, 4.0f]), MathBlockValue.Scalar(0.0f), MathBlockValue.Vector([3.0f, 3.0f, 3.0f, 1.0f, 2.0f, -1.0f])],
            [3.0f, 0.0f, 2.0f, 0.5f, 2.0f, float.NaN]),
        new(ScalarMathBlocks.ScalarCommonLogarithmV1Block.Create, [MathBlockValue.Vector([0.1f, 1.0f, 10.0f, 100.0f, 0.0f, -1.0f])],
            [-0.9999999999999998f, 0.0f, 1.0f, 2.0f, float.NaN, float.NaN]),
        new(ScalarMathBlocks.ScalarCosineV1Block.Create, [MathBlockValue.Vector([0.0f, 0.5f, 1.0f, -1.0f, 2.0f, 3.0f])],
            [1.0f, 0.8775825618903728f, 0.5403023058681398f, 0.5403023058681398f, -0.4161468365471424f, -0.9899924966004454f]),
        new(ScalarMathBlocks.ScalarCubeRootV1Block.Create, [MathBlockValue.Vector([-8.0f, -1.0f, 0.0f, 1.0f, 8.0f, 27.0f])],
            [-2.0f, -1.0f, 0.0f, 1.0f, 2.0f, 3.0f]),
        new(ScalarMathBlocks.ScalarCubeV1Block.Create, [MathBlockValue.Vector([-2.0f, -1.0f, 0.0f, 1.5f, 2.0f, 1e25f])],
            [-8.0f, -1.0f, 0.0f, 3.375f, 8.0f, float.NaN]),
        new(ScalarMathBlocks.ScalarFloorV1Block.Create, [MathBlockValue.Vector([-1.5f, -0.5f, 0.5f, 1.5f, 2.5f, -2.5f])],
            [-2.0f, -1.0f, 0.0f, 1.0f, 2.0f, -3.0f]),
        new(ScalarMathBlocks.ScalarHyperbolicCosineV1Block.Create, [MathBlockValue.Vector([0.0f, 0.5f, 1.0f, -1.0f, 2.0f, 800.0f])],
            [1.0f, 1.1276259652063807f, 1.543080634815244f, 1.543080634815244f, 3.7621956910836314f, float.NaN]),
        new(ScalarMathBlocks.ScalarHyperbolicSineV1Block.Create, [MathBlockValue.Vector([0.0f, 0.5f, 1.0f, -1.0f, 2.0f, 800.0f])],
            [0.0f, 0.5210953054937474f, 1.1752011936438016f, -1.1752011936438016f, 3.626860407847019f, float.NaN]),
        new(ScalarMathBlocks.ScalarHyperbolicTangentV1Block.Create, [MathBlockValue.Vector([0.0f, 0.5f, 1.0f, -1.0f, 2.0f, -3.0f])],
            [0.0f, 0.4621171572600098f, 0.7615941559557649f, -0.7615941559557649f, 0.964027580075817f, -0.9950547536867306f]),
        new(ScalarMathBlocks.ScalarInverseHyperbolicCosineV1Block.Create, [MathBlockValue.Vector([1.0f, 2.0f, 10.0f, 0.5f, 3.0f, 0.0f])],
            [0.0f, 1.3169578969248166f, 2.993222846126381f, float.NaN, 1.7627471740390859f, float.NaN]),
        new(ScalarMathBlocks.ScalarInverseHyperbolicSineV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [-1.4436354751788103f, -0.48121182505960347f, 0.0f, 0.48121182505960347f, 0.8813735870195429f, 1.8184464592320668f]),
        new(ScalarMathBlocks.ScalarInverseHyperbolicTangentV1Block.Create, [MathBlockValue.Vector([-0.5f, 0.0f, 0.5f, 0.9f, 1.0f, 2.0f])],
            [-0.5493061443340548f, 0.0f, 0.5493061443340548f, 1.4722194895832204f, float.NaN, float.NaN]),
        new(ScalarMathBlocks.ScalarLogOnePlusV1Block.Create, [MathBlockValue.Vector([-0.5f, 0.0f, 0.5f, 1.0f, -1.0f, -2.0f])],
            [-0.6931471805599453f, 0.0f, 0.4054651081081644f, 0.6931471805599453f, float.NaN, float.NaN]),
        new(ScalarMathBlocks.ScalarLogisticV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [0.11920292202211755f, 0.37754066879814546f, 0.5f, 0.6224593312018546f, 0.7310585786300049f, 0.9525741268224334f]),
        new(ScalarMathBlocks.ScalarLogitV1Block.Create, [MathBlockValue.Vector([0.25f, 0.5f, 0.75f, 0.0f, 1.0f, 2.0f])],
            [-1.0986122886681098f, 0.0f, 1.0986122886681096f, float.NaN, float.NaN, float.NaN]),
        new(ScalarMathBlocks.ScalarMaximumV1Block.Create, [MathBlockValue.Vector([1.0f, -2.0f, 3.0f, 0.0f, 5.0f, -1.0f]), MathBlockValue.Vector([2.0f, -3.0f, 3.0f, 1.0f, 4.0f, -1.0f])],
            [2.0f, -2.0f, 3.0f, 1.0f, 5.0f, -1.0f]),
        new(ScalarMathBlocks.ScalarMinimumV1Block.Create, [MathBlockValue.Vector([1.0f, -2.0f, 3.0f, 0.0f, 5.0f, -1.0f]), MathBlockValue.Vector([2.0f, -3.0f, 3.0f, 1.0f, 4.0f, -1.0f])],
            [1.0f, -3.0f, 3.0f, 0.0f, 4.0f, -1.0f]),
        new(ScalarMathBlocks.ScalarModuloV1Block.Create, [MathBlockValue.Vector([7.0f, -7.0f, 7.5f, 1.0f, 5.0f, 3.0f]), MathBlockValue.Vector([3.0f, 3.0f, 2.0f, 0.5f, 0.0f, -2.0f])],
            [1.0f, -1.0f, 1.5f, 0.0f, float.NaN, 1.0f]),
        new(ScalarMathBlocks.ScalarNegateV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [2.0f, 0.5f, -0.0f, -0.5f, -1.0f, -3.0f]),
        new(ScalarMathBlocks.ScalarReciprocalV1Block.Create, [MathBlockValue.Vector([0.5f, 1.0f, 2.0f, -4.0f, 0.0f, 8.0f])],
            [2.0f, 1.0f, 0.5f, -0.25f, float.NaN, 0.125f]),
        new(ScalarMathBlocks.ScalarRoundV1Block.Create, [MathBlockValue.Vector([-1.5f, -0.5f, 0.5f, 1.5f, 2.5f, -2.5f])],
            [-2.0f, -0.0f, 0.0f, 2.0f, 2.0f, -2.0f]),
        new(ScalarMathBlocks.ScalarSineV1Block.Create, [MathBlockValue.Vector([0.0f, 0.5f, 1.0f, -1.0f, 2.0f, 3.0f])],
            [0.0f, 0.479425538604203f, 0.8414709848078965f, -0.8414709848078965f, 0.9092974268256816f, 0.1411200080598672f]),
        new(ScalarMathBlocks.ScalarSoftplusV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [0.1269280110429725f, 0.4740769841801067f, 0.6931471805599453f, 0.9740769841801067f, 1.3132616875182228f, 3.048587351573742f]),
        new(ScalarMathBlocks.ScalarTangentV1Block.Create, [MathBlockValue.Vector([0.0f, 0.5f, 1.0f, -1.0f, 2.0f, 3.0f])],
            [0.0f, 0.5463024898437905f, 1.557407724654902f, -1.557407724654902f, -2.1850398632615184f, -0.1425465430742778f]),
        new(ScalarMathBlocks.ScalarTruncateV1Block.Create, [MathBlockValue.Vector([-1.5f, -0.5f, 0.5f, 1.5f, 2.5f, -2.5f])],
            [-1.0f, -0.0f, 0.0f, 1.0f, 2.0f, -2.0f]),
        new(ProbabilityMathBlocks.SpecialBetaV1Block.Create, [MathBlockValue.Vector([2.0f, 0.5f, 1.0f, 3.0f, 0.0f, -1.0f]), MathBlockValue.Vector([3.0f, 0.5f, 1.0f, 2.0f, 1.0f, 1.0f])],
            [0.08333333333333355f, 3.1415926535897927f, 0.9999999999999982f, 0.08333333333333355f, float.NaN, float.NaN]),
        new(ScalarMathBlocks.SpecialErrorFunctionV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [-0.995322265010666f, -0.5204999077232426f, 0.0f, 0.5204999077232426f, 0.8427007877600067f, 0.9999779095015785f]),
        new(ProbabilityMathBlocks.SpecialLogGammaV1Block.Create, [MathBlockValue.Vector([0.5f, 1.0f, 2.0f, 5.0f, 0.0f, -1.0f])],
            [0.5723649429246995f, -8.881784197001252e-16f, 0.0f, 3.178053830347944f, float.NaN, float.NaN]),
        new(ProbabilityMathBlocks.SpecialRegularizedIncompleteBetaV1Block.Create, [MathBlockValue.Vector([0.0f, 0.25f, 0.5f, 1.0f, 1.5f, -0.1f]), MathBlockValue.Scalar(2.0f), MathBlockValue.Vector([1.0f, 2.0f, 3.0f, 0.5f, 1.0f, 1.0f])],
            [0.0f, 0.15625f, 0.6875000000000009f, 1.0f, float.NaN, float.NaN]),
        new(ScalarMathBlocks.ScalarAbsoluteV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 3.0f, -3.16e37f])],
            [2.0f, 0.5f, 0.0f, 0.5f, 3.0f, 3.16e37f]),
        new(ScalarMathBlocks.ScalarAddV1Block.Create, [MathBlockValue.Vector([1.0f, 2.0f, 3.0f, 3.16e38f, -1.0f, 0.5f]), MathBlockValue.Vector([2.0f, -2.0f, 0.5f, 3.16e38f, 1.0f, 0.25f])],
            [3.0f, 0.0f, 3.5f, float.NaN, 0.0f, 0.75f]),
        new(ScalarMathBlocks.ScalarSubtractV1Block.Create, [MathBlockValue.Vector([5.0f, 2.0f, 3.0f, -3.16e38f, 1.0f, 0.5f]), MathBlockValue.Vector([2.0f, 2.0f, 0.5f, 3.16e38f, -1.0f, 0.25f])],
            [3.0f, 0.0f, 2.5f, float.NaN, 2.0f, 0.25f]),
        new(ScalarMathBlocks.ScalarMultiplyV1Block.Create, [MathBlockValue.Vector([2.0f, -3.0f, 0.5f, 1e25f, 0.0f, 4.0f]), MathBlockValue.Vector([3.0f, 3.0f, 0.5f, 1e25f, 5.0f, 0.25f])],
            [6.0f, -9.0f, 0.25f, float.NaN, 0.0f, 1.0f]),
        new(ScalarMathBlocks.ScalarDivideV1Block.Create, [MathBlockValue.Vector([6.0f, 1.0f, -3.0f, 1.0f, 0.0f, 5.0f]), MathBlockValue.Vector([3.0f, 0.0f, 2.0f, 4.0f, 5.0f, -2.0f])],
            [2.0f, float.NaN, -1.5f, 0.25f, 0.0f, -2.5f]),
        new(ScalarMathBlocks.ScalarPowerV1Block.Create, [MathBlockValue.Vector([2.0f, 9.0f, -8.0f, 2.0f, 0.0f, 10.0f]), MathBlockValue.Vector([3.0f, 0.5f, 0.5f, -1.0f, -1.0f, 400.0f])],
            [8.0f, 3.0f, float.NaN, 0.5f, float.NaN, float.NaN]),
        new(ScalarMathBlocks.ScalarNaturalLogarithmV1Block.Create, [MathBlockValue.Vector([1.0f, 2.0f, 0.5f, 0.0f, -1.0f, 10.0f])],
            [0.0f, 0.6931471805599453f, -0.6931471805599453f, float.NaN, float.NaN, 2.302585092994046f]),
        new(ScalarMathBlocks.ScalarSquareRootV1Block.Create, [MathBlockValue.Vector([0.0f, 1.0f, 4.0f, 2.0f, -1.0f, 0.25f])],
            [0.0f, 1.0f, 2.0f, 1.4142135623730951f, float.NaN, 0.5f]),
        new(ScalarMathBlocks.ScalarSquareV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 1.5f, 1e25f, 3.0f])],
            [4.0f, 0.25f, 0.0f, 2.25f, float.NaN, 9.0f]),
        new(ScalarMathBlocks.ScalarExponentialV1Block.Create, [MathBlockValue.Vector([0.0f, 1.0f, -1.0f, 0.5f, 800.0f, -800.0f])],
            [1.0f, 2.718281828459045f, 0.36787944117144233f, 1.6487212707001282f, float.NaN, 0.0f]),
        new(ScalarMathBlocks.ScalarPositivePartV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [0.0f, 0.0f, 0.0f, 0.5f, 1.0f, 3.0f]),
        new(ScalarMathBlocks.ScalarSignV1Block.Create, [MathBlockValue.Vector([-2.0f, -0.5f, 0.0f, 0.5f, 1.0f, 3.0f])],
            [-1.0f, -1.0f, 0.0f, 1.0f, 1.0f, 1.0f])
    ];

    // The number of elementwise sources. The opcode encoding (ElementwiseCudaBlockCatalog) holds at most MaximumSourceCount.
    internal static int SourceCount => Sources.Length;

    // The lift behind each form and sibling operation instance, so the fused expression evaluates their rows with
    // the same row function.
    private static readonly ConditionalWeakTable<MathBlockOperation, MathBlockElementwiseForm> lifts = new();

    internal static bool TryGetLift(MathBlockOperation operation, out MathBlockElementwiseForm form) =>
        lifts.TryGetValue(operation, out form!);

    internal static MathBlockOperation[] CreateOperations()
    {
        var sources = Sources;
        if (sources.Length > Cuda.MathBlockCudaElementwiseOpcode.MaximumSourceCount)
        {
            throw new InvalidOperationException(
                $"The elementwise opcode encoding holds at most {Cuda.MathBlockCudaElementwiseOpcode.MaximumSourceCount} sources, and there are {sources.Length}.");
        }

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
        var expected = new float[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = float.IsNaN(definition.Expected[index]) ? SampleFill : definition.Expected[index];
        var outputUnit = form.ResolveSourceUnit(MathBlockCollectionPrimitives.Map(definition.Sample, value => value.Type));
        sample[^1] = MathBlockValue.Scalar(SampleFill, outputUnit);
        var operation = MathBlockOperationFactory.Create(
            $"{FormFamily}.{form.Source.Identifier}",
            form.FormArity,
            form.FormTypeResolver,
            form.EvaluateForm,
            sample,
            MathBlockValue.Vector(expected, outputUnit),
            1e-12f,
            64,
            MathBlockCausalityInfo.Pointwise);
        if (form.Source.DomainEvaluator is not null)
            operation.DomainEvaluator = form.EvaluateForm;
        operation.TypeSignatureFactory = () => form.CreateSignature(operation.Identity, validity: false);
        lifts.Add(operation, form);
        return operation;
    }

    private static MathBlockOperation CreateValidity(ElementwiseSource definition)
    {
        var form = new MathBlockElementwiseForm(definition.Create());
        var expected = new bool[definition.Expected.Length];
        for (var index = 0; index < expected.Length; index++)
            expected[index] = !float.IsNaN(definition.Expected[index]);
        var operation = MathBlockOperationFactory.Create(
            $"{ValidityFamily}.{form.Source.Identifier}",
            form.ValidityArity,
            form.ValidityTypeResolver,
            form.EvaluateValidity,
            definition.Sample,
            MathBlockValue.BooleanVector(expected),
            performanceIterations: 64,
            causality: MathBlockCausalityInfo.Pointwise);
        if (form.Source.DomainEvaluator is not null)
            operation.DomainEvaluator = form.EvaluateValidity;
        operation.TypeSignatureFactory = () => form.CreateSignature(operation.Identity, validity: true);
        lifts.Add(operation, form);
        return operation;
    }

    // Create builds an independent instance of the source operation; Sample holds the source arguments (vectors
    // and broadcast scalars) used for the regression and performance cases with fill -1; Expected holds the
    // regression rows, with NaN marking a filled row.
    private sealed record ElementwiseSource(
        Func<MathBlockOperation> Create,
        MathBlockValue[] Sample,
        float[] Expected);
}
