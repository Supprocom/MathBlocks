namespace Supprocom.MathBlocks;

internal static class MathBlockTypeRules
{
    public static MathBlockType SameBinaryScalar(IReadOnlyList<MathBlockType> types) =>
        SameBinary(types, MathBlockValueKind.Scalar);

    public static MathBlockType DimensionlessScalar(IReadOnlyList<MathBlockType> types) =>
        DimensionlessUnary(types, MathBlockValueKind.Scalar);

    public static MathBlockType DimensionlessScalarFromScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar();
    }

    public static MathBlockType DimensionlessBinaryScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        RequireKind(types[1], MathBlockValueKind.Scalar);
        RequireDimensionless(types[0]);
        RequireDimensionless(types[1]);
        return MathBlockType.Scalar();
    }

    public static MathBlockType ReciprocalScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(-1)));
    }

    public static MathBlockType SquareScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(2)));
    }

    public static MathBlockType CubeScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(3)));
    }

    public static MathBlockType SquareRootScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(1, 2)));
    }

    public static MathBlockType CubeRootScalar(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(1, 3)));
    }

    public static MathBlockType Unary(IReadOnlyList<MathBlockType> types, MathBlockValueKind kind)
    {
        RequireKind(types[0], kind);
        return types[0];
    }

    public static MathBlockType DimensionlessUnary(IReadOnlyList<MathBlockType> types, MathBlockValueKind kind)
    {
        RequireKind(types[0], kind);
        RequireDimensionless(types[0]);
        return types[0];
    }

    public static MathBlockType SameBinary(IReadOnlyList<MathBlockType> types, MathBlockValueKind kind)
    {
        RequireKind(types[0], kind);
        RequireKind(types[1], kind);
        if (types[0].Unit != types[1].Unit)
            throw new InvalidOperationException("The input units must be equal.");
        RequireCompatibleShape(types[0], types[1]);
        return MergeShape(types[0], types[1]);
    }

    public static MathBlockType ScalarProduct(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        RequireKind(types[1], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Multiply(types[1].Unit));
    }

    public static MathBlockType ScalarQuotient(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Scalar);
        RequireKind(types[1], MathBlockValueKind.Scalar);
        return MathBlockType.Scalar(types[0].Unit.Divide(types[1].Unit));
    }

    public static MathBlockType Comparison(IReadOnlyList<MathBlockType> types)
    {
        SameBinary(types, MathBlockValueKind.Scalar);
        return MathBlockType.Boolean;
    }

    public static MathBlockType VectorReduction(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar(types[0].Unit);
    }

    public static MathBlockType VectorDimensionlessReduction(IReadOnlyList<MathBlockType> types)
    {
        RequireKind(types[0], MathBlockValueKind.Vector);
        RequireDimensionless(types[0]);
        return MathBlockType.Scalar();
    }

    public static void RequireKind(MathBlockType type, MathBlockValueKind kind)
    {
        if (type.Kind != kind)
            throw new InvalidOperationException($"Expected '{kind}', but found '{type.Kind}'.");
    }

    public static void RequireDimensionless(MathBlockType type)
    {
        if (!type.Unit.IsDimensionless)
            throw new InvalidOperationException("The input must be dimensionless.");
    }

    public static void RequireCompatibleShape(MathBlockType left, MathBlockType right)
    {
        if (left.Rows != 0 && right.Rows != 0 && left.Rows != right.Rows)
            throw new InvalidOperationException("The input row counts must be equal.");
        if (left.Columns != 0 && right.Columns != 0 && left.Columns != right.Columns)
            throw new InvalidOperationException("The input column counts must be equal.");
    }

    private static MathBlockType MergeShape(MathBlockType left, MathBlockType right) =>
        new(left.Kind, left.Unit, left.Rows == 0 ? right.Rows : left.Rows, left.Columns == 0 ? right.Columns : left.Columns);
}
