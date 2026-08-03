namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{

    public static double Cross(MathBlockPoint origin, MathBlockPoint left, MathBlockPoint right) =>
        (left.X - origin.X) * (right.Y - origin.Y) -
        (left.Y - origin.Y) * (right.X - origin.X);

    private static double DirectedHausdorff(
        IReadOnlyList<MathBlockPoint> left,
        IReadOnlyList<MathBlockPoint> right)
    {
        var maximum = 0d;
        for (var leftIndex = 0; leftIndex < left.Count; leftIndex++)
        {
        var minimum = Math.PositiveInfinity;
            for (var rightIndex = 0; rightIndex < right.Count; rightIndex++)
                minimum = Math.Min(minimum, Distance(left[leftIndex], right[rightIndex]));
            maximum = Math.Max(maximum, minimum);
        }
        return maximum;
    }

    private static bool TryCircumcircle(
        MathBlockPoint first,
        MathBlockPoint second,
        MathBlockPoint third,
        out MathBlockPoint center,
        out double radiusSquare)
    {
        var denominator = 2d * (first.X * (second.Y - third.Y) +
                                second.X * (third.Y - first.Y) +
                                third.X * (first.Y - second.Y));
        if (denominator == 0d)
        {
            center = default;
            radiusSquare = 0d;
            return false;
        }
        var firstSquare = first.X * first.X + first.Y * first.Y;
        var secondSquare = second.X * second.X + second.Y * second.Y;
        var thirdSquare = third.X * third.X + third.Y * third.Y;
        center = new MathBlockPoint(
            (firstSquare * (second.Y - third.Y) + secondSquare * (third.Y - first.Y) +
             thirdSquare * (first.Y - second.Y)) / denominator,
            (firstSquare * (third.X - second.X) + secondSquare * (first.X - third.X) +
             thirdSquare * (second.X - first.X)) / denominator);
        var x = first.X - center.X;
        var y = first.Y - center.Y;
        radiusSquare = x * x + y * y;
        return true;
    }
}

internal static partial class GeometryMathBlocks
{
    private static readonly MathBlockValue square = MathBlockValue.PointSet(
        new MathBlockPointSet([new(0d, 0d), new(1d, 0d), new(1d, 1d), new(0d, 1d)]));

    private static MathBlockOperation CreatePointSetScalar(
        string identifier,
        Func<IReadOnlyList<MathBlockPoint>, double> function,
        MathBlockValue sample,
        double expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return inputs[0].AsPointSet().Count > 0
                ? MathBlockValue.Scalar(function(inputs[0].AsPointSet()), type.Unit)
                : MathBlockValue.Invalid(type, "The point set is empty.");
        },
        [sample], MathBlockValue.Scalar(expected), 1e-9, 8);

    private static MathBlockOperation CreatePointPairScalar(
        string identifier,
        Func<IReadOnlyList<MathBlockPoint>, IReadOnlyList<MathBlockPoint>, double> function,
        MathBlockValue left,
        MathBlockValue right,
        double expected) => MathBlockOperationFactory.Create(
        identifier, 2, PointPairLengthType,
        inputs => inputs[0].AsPointSet().Count > 0 && inputs[1].AsPointSet().Count > 0
            ? MathBlockValue.Scalar(function(inputs[0].AsPointSet(), inputs[1].AsPointSet()), inputs[0].Type.Unit)
            : MathBlockValue.Invalid(MathBlockType.Scalar(inputs[0].Type.Unit), "A point set is empty."),
        [left, right], MathBlockValue.Scalar(expected), 1e-9, 4);

    private static MathBlockValue Singleton(double x, double y) =>
        MathBlockValue.PointSet(new MathBlockPointSet([new MathBlockPoint(x, y)]));

    private static MathBlockType SamePointSet(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
        return MathBlockType.PointSet(types[0].Unit);
    }

    private static MathBlockType LengthType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
        return MathBlockType.Scalar(types[0].Unit);
    }

    private static MathBlockType AreaType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(2)));
    }

    private static MathBlockType PointPairLengthType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.PointSet);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.PointSet);
        if (types[0].Unit != types[1].Unit)
            throw new InvalidOperationException("The input units must be equal.");
        return MathBlockType.Scalar(types[0].Unit);
    }
}
