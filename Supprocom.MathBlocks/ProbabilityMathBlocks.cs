namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    private static readonly double[] lanczosCoefficients =
    [
        676.5203681218851,
        -1259.1392167224028,
        771.32342877765313,
        -176.61502916214059,
        12.507343278686905,
        -0.13857109526572012,
        9.9843695780195716e-6,
        1.5056327351493116e-7
    ];

    private static double BetaContinuedFraction(double x, double left, double right)
    {
        const int maximumIterations = 256;
        const double tolerance = 3e-14;
        const double minimum = 1e-300;
        var qab = left + right;
        var qap = left + 1d;
        var qam = left - 1d;
        var c = 1d;
        var d = 1d - qab * x / qap;
        if (Math.Abs(d) < minimum)
            d = minimum;
        d = 1d / d;
        var result = d;
        for (var iteration = 1; iteration <= maximumIterations; iteration++)
        {
            var doubled = 2d * iteration;
            var coefficient = iteration * (right - iteration) * x /
                              ((qam + doubled) * (left + doubled));
            d = 1d + coefficient * d;
            if (Math.Abs(d) < minimum)
                d = minimum;
            c = 1d + coefficient / c;
            if (Math.Abs(c) < minimum)
                c = minimum;
            d = 1d / d;
            result *= d * c;
            coefficient = -(left + iteration) * (qab + iteration) * x /
                          ((left + doubled) * (qap + doubled));
            d = 1d + coefficient * d;
            if (Math.Abs(d) < minimum)
                d = minimum;
            c = 1d + coefficient / c;
            if (Math.Abs(c) < minimum)
                c = minimum;
            d = 1d / d;
            var delta = d * c;
            result *= delta;
            if (Math.Abs(delta - 1d) <= tolerance)
                break;
        }
        return result;
    }
}

internal static partial class ProbabilityMathBlocks
{
    private static readonly MathBlockValue fair = MathBlockValue.Vector([0.5d, 0.5d]);
    private static readonly MathBlockValue certain = MathBlockValue.Vector([1d, 0d]);

    private static MathBlockOperation CreateVectorUnary(
        string identifier,
        Func<IReadOnlyList<double>, double[]> function,
        MathBlockValue sample,
        double[] expected,
        bool requireDistribution,
        bool requireDimensionlessInput = false) => MathBlockOperationFactory.Create(
        identifier, 1,
        types => DimensionlessVectorType(types, requireDimensionlessInput),
        inputs =>
        {
            var values = inputs[0].AsVector();
            if ((requireDistribution && !IsDistribution(values)) ||
                (!requireDistribution &&
                 (values.Count == 0 || MathBlockCollectionPrimitives.Any(values, value => value < 0d))))
            {
                return MathBlockValue.Invalid(MathBlockType.Vector(length: values.Count), "The vector is outside the operation domain.");
            }
            return MathBlockValue.Vector(function(values), default, true);
        },
        [sample], MathBlockValue.Vector(expected), 1e-9, 32);

    private static MathBlockOperation CreateScalarUnary(
        string identifier,
        Func<IReadOnlyList<double>, double> function,
        MathBlockValue sample,
        double expected,
        bool requireDistribution = true) => MathBlockOperationFactory.Create(
        identifier, 1, DimensionlessScalarType,
        inputs =>
        {
            var values = inputs[0].AsVector();
            if ((requireDistribution && !IsDistribution(values)) || values.Count == 0)
                return MathBlockValue.Invalid(MathBlockType.Scalar(), "The vector is outside the operation domain.");
            return MathBlockValue.Scalar(function(values));
        },
        [sample], MathBlockValue.Scalar(expected), 1e-9, 32);

    private static MathBlockOperation CreateDistributionBinary(
        string identifier,
        Func<IReadOnlyList<double>, IReadOnlyList<double>, double> function,
        MathBlockValue left,
        MathBlockValue right,
        double expected,
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
                    if (leftValues[index] > 0d && rightValues[index] == 0d)
                        return MathBlockValue.Invalid(MathBlockType.Scalar(), "The reference distribution has zero support.");
            return MathBlockValue.Scalar(function(leftValues, rightValues));
        },
        [left, right], MathBlockValue.Scalar(expected), 1e-9, 16);

    private static MathBlockOperation CreateOrderedEntropy(
        string identifier,
        Func<IReadOnlyList<double>, double, double> function,
        double order,
        double expected) => MathBlockOperationFactory.Create(
        identifier, 2, DistributionOrderType,
        inputs =>
        {
            var probabilities = inputs[0].AsVector();
            var requestedOrder = inputs[1].AsScalar();
            return IsDistribution(probabilities) && requestedOrder > 0d
                ? MathBlockValue.Scalar(function(probabilities, requestedOrder))
                : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the entropy domain.");
        },
        [fair, MathBlockValue.Scalar(order)], MathBlockValue.Scalar(expected), 1e-9, 16);

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

    private static bool IsDistribution(IReadOnlyList<double> values) =>
        values.Count > 0 && MathBlockCollectionPrimitives.All(values, value => value >= 0d) &&
        Math.Abs(MathBlockVectorMath.Sum(values) - 1d) <= 1e-10;

    private static bool TryInteger(double value, out int result)
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
