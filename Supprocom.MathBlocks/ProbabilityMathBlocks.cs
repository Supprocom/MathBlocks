namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    private static readonly float[] lanczosCoefficients =
    [
        676.5203681218851f,
        -1259.1392167224028f,
        771.32342877765313f,
        -176.61502916214059f,
        12.507343278686905f,
        -0.13857109526572012f,
        9.9843695780195716e-6f,
        1.5056327351493116e-7f
    ];

    // The continued fraction stops at the first step whose correction is within tolerance of 1; converged is false when it
    // used all maximumIterations steps without that.
    private static float BetaContinuedFraction(
        float x,
        float left,
        float right,
        int maximumIterations,
        float tolerance,
        out bool converged)
    {
        const float minimum = 1.03e-37f;
        converged = false;
        var qab = left + right;
        var qap = left + 1f;
        var qam = left - 1f;
        var c = 1f;
        var d = 1f - qab * x / qap;
        if (Math.Abs(d) < minimum)
            d = minimum;
        d = 1f / d;
        var result = d;
        for (var iteration = 1; iteration <= maximumIterations; iteration++)
        {
            var doubled = 2f * iteration;
            var coefficient = iteration * (right - iteration) * x /
                              ((qam + doubled) * (left + doubled));
            d = 1f + coefficient * d;
            if (Math.Abs(d) < minimum)
                d = minimum;
            c = 1f + coefficient / c;
            if (Math.Abs(c) < minimum)
                c = minimum;
            d = 1f / d;
            result *= d * c;
            coefficient = -(left + iteration) * (qab + iteration) * x /
                          ((left + doubled) * (qap + doubled));
            d = 1f + coefficient * d;
            if (Math.Abs(d) < minimum)
                d = minimum;
            c = 1f + coefficient / c;
            if (Math.Abs(c) < minimum)
                c = minimum;
            d = 1f / d;
            var delta = d * c;
            result *= delta;
            if (Math.Abs(delta - 1f) <= tolerance)
            {
                converged = true;
                break;
            }
        }
        return result;
    }
}

internal static partial class ProbabilityMathBlocks
{
    private static readonly MathBlockValue fair = MathBlockValue.Vector([0.5f, 0.5f]);
    private static readonly MathBlockValue certain = MathBlockValue.Vector([1f, 0f]);

    private static MathBlockOperation CreateVectorUnary(
        string identifier,
        Func<IReadOnlyList<float>, float[]> function,
        MathBlockValue sample,
        float[] expected,
        bool requireDistribution,
        bool requireDimensionlessInput = false) => MathBlockOperationFactory.Create(
        identifier, 1,
        types => DimensionlessVectorType(types, requireDimensionlessInput),
        inputs =>
        {
            var values = inputs[0].AsVector();
            if ((requireDistribution && !IsDistribution(values)) ||
                (!requireDistribution &&
                 (values.Count == 0 || MathBlockCollectionPrimitives.Any(values, value => value < 0f))))
            {
                return MathBlockValue.Invalid(MathBlockType.Vector(length: values.Count), "The vector is outside the operation domain.");
            }
            return MathBlockValue.Vector(function(values), default, true);
        },
        [sample], MathBlockValue.Vector(expected), 3e-5f, 32);

    private static MathBlockOperation CreateScalarUnary(
        string identifier,
        Func<IReadOnlyList<float>, float> function,
        MathBlockValue sample,
        float expected,
        bool requireDistribution = true) => MathBlockOperationFactory.Create(
        identifier, 1, DimensionlessScalarType,
        inputs =>
        {
            var values = inputs[0].AsVector();
            if ((requireDistribution && !IsDistribution(values)) || values.Count == 0)
                return MathBlockValue.Invalid(MathBlockType.Scalar(), "The vector is outside the operation domain.");
            return MathBlockValue.Scalar(function(values));
        },
        [sample], MathBlockValue.Scalar(expected), 3e-5f, 32);

    private static MathBlockOperation CreateDistributionBinary(
        string identifier,
        Func<IReadOnlyList<float>, IReadOnlyList<float>, float> function,
        MathBlockValue left,
        MathBlockValue right,
        float expected,
        bool requireReferenceSupport = false) => MathBlockOperationFactory.Create(
        identifier, 2, DistributionPairType,
        inputs =>
        {
            var leftValues = inputs[0].AsVector();
            var rightValues = inputs[1].AsVector();
            if (!IsDistribution(leftValues) || !IsDistribution(rightValues))
                return MathBlockValue.Invalid(MathBlockType.Scalar(), "An input is not a probability distribution.");
            if (requireReferenceSupport)
                for (var index = 0; index < leftValues.Count; index++)
                    if (leftValues[index] > 0f && rightValues[index] == 0f)
                        return MathBlockValue.Invalid(MathBlockType.Scalar(), "The reference distribution has zero support.");
            return MathBlockValue.Scalar(function(leftValues, rightValues));
        },
        [left, right], MathBlockValue.Scalar(expected), 3e-5f, 16);

    private static MathBlockOperation CreateOrderedEntropy(
        string identifier,
        Func<IReadOnlyList<float>, float, float> function,
        float order,
        float expected) => MathBlockOperationFactory.Create(
        identifier, 2, DistributionOrderType,
        inputs =>
        {
            var probabilities = inputs[0].AsVector();
            var requestedOrder = inputs[1].AsScalar();
            return IsDistribution(probabilities) && requestedOrder > 0f
                ? MathBlockValue.Scalar(function(probabilities, requestedOrder))
                : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the entropy domain.");
        },
        [fair, MathBlockValue.Scalar(order)], MathBlockValue.Scalar(expected), 3e-5f, 16);

    private static MathBlockType DimensionlessVectorType(
        IReadOnlyList<MathBlockType> types,
        bool requireDimensionlessInput)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        if (requireDimensionlessInput)
            MathBlockTypeRules.RequireDimensionless(types[0]);
        return MathBlockType.Vector(length: types[0].Rows);
    }

    private static MathBlockType DimensionlessScalarType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        return MathBlockType.Scalar();
    }

    private static MathBlockType DistributionPairType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        return MathBlockType.Scalar();
    }

    private static MathBlockType DistributionOrderType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return MathBlockType.Scalar();
    }

    // Both vector values and flattened matrix arrays are valid distribution inputs.
    private static bool IsDistribution(MathBlockVector values) => IsDistributionCore(values);

    private static bool IsDistribution(float[] values) => IsDistributionCore(values);

    private static bool IsDistributionCore(IReadOnlyList<float> values) =>
        values.Count > 0 && MathBlockCollectionPrimitives.All(values, value => value >= 0f) &&
        Math.Abs(MathBlockVectorMath.Sum(values) - 1f) <= 1e-5f;

    private static bool TryInteger(float value, out int result)
    {
        if (value is >= int.MinValue and <= int.MaxValue && value == Math.Truncate(value))
        {
            result = (int)value;
            return true;
        }
        result = 0;
        return false;
    }
}
