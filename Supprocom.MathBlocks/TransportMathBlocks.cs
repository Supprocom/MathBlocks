namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{

    private static float MeanPairwiseDistance(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        var sum = 0f;
        for (var leftIndex = 0; leftIndex < left.Count; leftIndex++)
            for (var rightIndex = 0; rightIndex < right.Count; rightIndex++)
                sum += Math.Abs(left[leftIndex] - right[rightIndex]);
        return sum / (left.Count * right.Count);
    }
}

internal static partial class TransportMathBlocks
{
    private static readonly MathBlockValue left = MathBlockValue.Vector([0f, 1f]);
    private static readonly MathBlockValue right = MathBlockValue.Vector([1f, 2f]);
    private static readonly MathBlockValue fair = MathBlockValue.Vector([0.5f, 0.5f]);

    private static MathBlockType SinkhornType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[3], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireKind(types[4], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        MathBlockTypeRules.RequireDimensionless(types[2]);
        MathBlockTypeRules.RequireDimensionless(types[4]);
        if (types[0].Unit != types[3].Unit)
            throw new InvalidOperationException("The cost and regularization units must be equal.");
        if (types[0].Rows != 0 && types[1].Rows != 0 && types[0].Rows != types[1].Rows ||
            types[0].Columns != 0 && types[2].Rows != 0 && types[0].Columns != types[2].Rows)
            throw new InvalidOperationException("The cost and mass dimensions must agree.");
        return MathBlockType.Matrix(rows: types[0].Rows, columns: types[0].Columns);
    }

    private static void SameSupportPair(MathBlockType leftType, MathBlockType rightType, bool requireEqualLength = true)
    {
        MathBlockTypeRules.RequireKind(leftType, MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(rightType, MathBlockValueKind.Vector);
        if (leftType.Unit != rightType.Unit)
            throw new InvalidOperationException("The support units must be equal.");
        if (requireEqualLength)
            MathBlockTypeRules.RequireCompatibleShape(leftType, rightType);
    }

    private static void RequireWeights(MathBlockType weights, MathBlockType support)
    {
        MathBlockTypeRules.RequireKind(weights, MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(weights);
        MathBlockTypeRules.RequireCompatibleShape(weights, support);
    }

    private static void RequireSquareMatrix(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Matrix);
        if (type.Rows != 0 && type.Columns != 0 && type.Rows != type.Columns)
            throw new InvalidOperationException("The matrix must be square.");
    }

    private static bool IsDistribution(IReadOnlyList<float> values) =>
        values.Count > 0 && MathBlockCollectionPrimitives.All(values, value => value >= 0f) &&
        Math.Abs(MathBlockVectorMath.Sum(values) - 1f) <= 1e-10f;
}
