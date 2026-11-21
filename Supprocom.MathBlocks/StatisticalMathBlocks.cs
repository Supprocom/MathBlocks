namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{

    private static void CenterDistanceMatrix(IReadOnlyList<float> values, float[] result)
    {
        var count = values.Count;
        var rowMeans = new float[count];
        var totalMean = 0f;
        for (var row = 0; row < count; row++)
        {
            for (var column = 0; column < count; column++)
            {
                var distance = Math.Abs(values[row] - values[column]);
                result[row * count + column] = distance;
                rowMeans[row] += distance;
                totalMean += distance;
            }
            rowMeans[row] /= count;
        }
        totalMean /= count * count;
        for (var row = 0; row < count; row++)
            for (var column = 0; column < count; column++)
                result[row * count + column] -= rowMeans[row] + rowMeans[column] - totalMean;
    }
}

internal static partial class StatisticalMathBlocks
{
    private static readonly MathBlockValue ascending = MathBlockValue.Vector([1f, 2f, 3f, 4f]);
    private static readonly MathBlockValue linear = MathBlockValue.Vector([3f, 5f, 7f, 9f]);

    private static MathBlockOperation CreateUnary(
        string identifier,
        Func<IReadOnlyList<float>, float> function,
        float expected,
        MathBlockTypeResolver resolver) =>
        CreateUnaryWithSample(identifier, function, ascending, expected, resolver);

    private static MathBlockOperation CreateUnaryWithSample(
        string identifier,
        Func<IReadOnlyList<float>, float> function,
        MathBlockValue sample,
        float expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Scalar(function(inputs[0].AsVector()), type.Unit);
        },
        [sample], MathBlockValue.Scalar(expected), 3e-5f, 32);

    private static MathBlockOperation CreateBinary(
        string identifier,
        Func<IReadOnlyList<float>, IReadOnlyList<float>, float> function,
        float expected,
        MathBlockTypeResolver resolver) =>
        CreateBinaryWithSamples(identifier, function, ascending, linear, expected, resolver);

    private static MathBlockOperation CreateBinaryWithSamples(
        string identifier,
        Func<IReadOnlyList<float>, IReadOnlyList<float>, float> function,
        MathBlockValue left,
        MathBlockValue right,
        float expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 2, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Scalar(function(inputs[0].AsVector(), inputs[1].AsVector()), type.Unit);
        },
        [left, right], MathBlockValue.Scalar(expected), 1e-4f, 16);

    private static MathBlockOperation CreateWeighted(
        string identifier,
        Func<IReadOnlyList<float>, IReadOnlyList<float>, float> function,
        float expected,
        MathBlockTypeResolver outputResolver) => MathBlockOperationFactory.Create(
        identifier, 2, WeightedType(outputResolver),
        inputs =>
        {
            var type = outputResolver([inputs[0].Type]);
            return MathBlockValue.Scalar(function(inputs[0].AsVector(), inputs[1].AsVector()), type.Unit);
        },
        [MathBlockValue.Vector([2f, 4f]), MathBlockValue.Vector([1f, 1f])],
        MathBlockValue.Scalar(expected), 3e-5f, 32);

    private static MathBlockType VarianceType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(2)));
    }

    private static MathBlockType StandardDeviationType(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.VectorReduction(types);

    private static MathBlockType DimensionlessStatisticType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar();
    }

    private static MathBlockType CovarianceType(IReadOnlyList<MathBlockType> types)
    {
        RequirePairedVectors(types);
        return MathBlockType.Scalar(types[0].Unit.Multiply(types[1].Unit));
    }

    private static MathBlockType CorrelationType(IReadOnlyList<MathBlockType> types)
    {
        RequirePairedVectors(types);
        return MathBlockType.Scalar();
    }

    private static MathBlockType SlopeType(IReadOnlyList<MathBlockType> types)
    {
        RequirePairedVectors(types);
        return MathBlockType.Scalar(types[1].Unit.Divide(types[0].Unit));
    }

    private static MathBlockType InterceptType(IReadOnlyList<MathBlockType> types)
    {
        RequirePairedVectors(types);
        return MathBlockType.Scalar(types[1].Unit);
    }

    private static MathBlockTypeResolver WeightedType(MathBlockTypeResolver resolver) => types =>
    {
        RequirePairedVectors(types);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return resolver([types[0]]);
    };

    private static void RequirePairedVectors(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
    }
}
