namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{

    private static double[] Map(IReadOnlyList<double> values, Func<double, double> function)
    {
        var result = new double[values.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = function(values[index]);
        return result;
    }

    private static double[] Zip(
        IReadOnlyList<double> left,
        IReadOnlyList<double> right,
        Func<double, double, double> function)
    {
        var result = new double[left.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = function(left[index], right[index]);
        return result;
    }

    private static bool[] Compare(
        IReadOnlyList<double> left,
        IReadOnlyList<double> right,
        Func<double, double, bool> function)
    {
        var result = new bool[left.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = function(left[index], right[index]);
        return result;
    }

    private static double[] RollingExtreme(IReadOnlyList<double> values, int width, bool minimum)
    {
        var result = new double[values.Count - width + 1];
        var deque = new int[values.Count];
        var head = 0;
        var tail = 0;
        for (var index = 0; index < values.Count; index++)
        {
            while (head < tail && deque[head] <= index - width)
                head++;
            while (head < tail && (minimum
                       ? values[deque[tail - 1]] >= values[index]
                       : values[deque[tail - 1]] <= values[index]))
            {
                tail--;
            }
            deque[tail++] = index;
            if (index >= width - 1)
                result[index - width + 1] = values[deque[head]];
        }
        return result;
    }
}

internal static partial class VectorMathBlocks
{
    private static readonly MathBlockValue sampleVector = MathBlockValue.Vector([1d, 2d, 3d, 4d]);
    private static readonly MathBlockValue secondVector = MathBlockValue.Vector([4d, 3d, 2d, 1d]);

    private static MathBlockOperation CreateVectorUnary(
        string identifier,
        Func<IReadOnlyList<double>, double[]> function,
        double[] sample,
        double[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Vector(function(inputs[0].AsVector()), type.Unit, true);
        },
        [MathBlockValue.Vector(sample)], MathBlockValue.Vector(expected), 1e-9, 64);

    private static MathBlockOperation CreateVectorBinary(
        string identifier,
        Func<IReadOnlyList<double>, IReadOnlyList<double>, double[]> function,
        double[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 2, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Vector(function(inputs[0].AsVector(), inputs[1].AsVector()), type.Unit, true);
        },
        [sampleVector, secondVector], MathBlockValue.Vector(expected), 1e-9, 64);

    private static MathBlockOperation CreateVectorScalar(
        string identifier,
        Func<IReadOnlyList<double>, double, double[]> function,
        double scalar,
        double[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 2, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Vector(function(inputs[0].AsVector(), inputs[1].AsScalar()), type.Unit, true);
        },
        [sampleVector, MathBlockValue.Scalar(scalar)], MathBlockValue.Vector(expected), 1e-9, 64);

    private static MathBlockOperation CreateReduction(
        string identifier,
        Func<IReadOnlyList<double>, double> function,
        double expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Scalar(function(inputs[0].AsVector()), type.Unit);
        },
        [sampleVector], MathBlockValue.Scalar(expected), 1e-9, 64);

    private static MathBlockOperation CreateRolling(
        string identifier,
        Func<IReadOnlyList<double>, int, double[]> function,
        double[] expected,
        bool squaredOutput) => MathBlockOperationFactory.Create(
        identifier, 2, VectorScalarVectorType,
        inputs =>
        {
            var width = RequirePositiveInteger(inputs[1].AsScalar());
            var values = inputs[0].AsVector();
            var unit = squaredOutput ? inputs[0].Type.Unit.Pow(new MathRational(2)) : inputs[0].Type.Unit;
            return width <= values.Count
                ? MathBlockValue.Vector(function(values, width), unit, true)
                : MathBlockValue.Invalid(MathBlockType.Vector(unit), "The width is outside the sequence domain.");
        },
        [sampleVector, MathBlockValue.Scalar(2d)], MathBlockValue.Vector(expected), 1e-9, 32);

    private static MathBlockOperation CreateVectorComparison(
        string identifier,
        Func<IReadOnlyList<double>, IReadOnlyList<double>, bool[]> function,
        bool[] expected) => MathBlockOperationFactory.Create(
        identifier, 2, VectorComparisonType,
        inputs => MathBlockValue.BooleanVector(function(inputs[0].AsVector(), inputs[1].AsVector()), true),
        [sampleVector, secondVector], MathBlockValue.BooleanVector(expected), performanceIterations: 64);

    private static MathBlockOperation CreateBooleanVectorBinary(
        string identifier,
        Func<bool, bool, bool> function,
        bool[] expected) => MathBlockOperationFactory.Create(
        identifier, 2, BooleanVectorBinaryType,
        inputs =>
        {
            var left = inputs[0].AsBooleanVector();
            var right = inputs[1].AsBooleanVector();
            var result = new bool[left.Count];
            for (var index = 0; index < result.Length; index++)
                result[index] = function(left[index], right[index]);
            return MathBlockValue.BooleanVector(result, true);
        },
        [MathBlockValue.BooleanVector([true, false, true]), MathBlockValue.BooleanVector([false, false, true])],
        MathBlockValue.BooleanVector(expected), performanceIterations: 64);

    private static MathBlockType SameVectorUnary(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.Unary(types, MathBlockValueKind.Vector);

    private static MathBlockType DimensionlessVector(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.DimensionlessUnary(types, MathBlockValueKind.Vector);

    private static MathBlockType DimensionlessVectorFromVector(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Vector(length: types[0].Rows);
    }

    private static MathBlockType SquareVector(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Vector(types[0].Unit.Pow(new MathRational(2)), types[0].Rows);
    }

    private static MathBlockType SquareRootVector(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Vector(types[0].Unit.Pow(new MathRational(1, 2)), types[0].Rows);
    }

    private static MathBlockType SameVectors(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);

    private static MathBlockType ProductVectors(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        return MathBlockType.Vector(types[0].Unit.Multiply(types[1].Unit), MergedLength(types[0], types[1]));
    }

    private static MathBlockType QuotientVectors(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        return MathBlockType.Vector(types[0].Unit.Divide(types[1].Unit), MergedLength(types[0], types[1]));
    }

    private static MathBlockType AddScalarType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        if (types[0].Unit != types[1].Unit)
            throw new InvalidOperationException("The input units must be equal.");
        return types[0];
    }

    private static MathBlockType ScaleType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        return MathBlockType.Vector(types[0].Unit.Multiply(types[1].Unit), types[0].Rows);
    }

    private static MathBlockType DimensionlessVectorScalar(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return types[0];
    }

    private static MathBlockType VectorScalarReductionType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return MathBlockType.Scalar(types[0].Unit);
    }

    private static MathBlockType DotType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        return MathBlockType.Scalar(types[0].Unit.Multiply(types[1].Unit));
    }

    private static MathBlockType ProductReductionType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        if (types[0].Rows == 0 && !types[0].Unit.IsDimensionless)
            throw new InvalidOperationException("A dimensional product requires a known vector length.");
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(types[0].Rows)));
    }

    private static MathBlockType DimensionlessReductionType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar();
    }

    private static MathBlockType VectorScalarVectorType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return MathBlockType.Vector(types[0].Unit);
    }

    private static MathBlockType VectorTwoScalarVectorType(IReadOnlyList<MathBlockType> types)
    {
        VectorScalarVectorType([types[0], types[1]]);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[2]);
        return MathBlockType.Vector(types[0].Unit);
    }

    private static MathBlockType ConvolutionType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        return MathBlockType.Vector(types[0].Unit.Multiply(types[1].Unit));
    }

    private static MathBlockType ConcatenateType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        if (types[0].Unit != types[1].Unit)
            throw new InvalidOperationException("The input units must be equal.");
        var length = types[0].Rows > 0 && types[1].Rows > 0
            ? checked(types[0].Rows + types[1].Rows)
            : 0;
        return MathBlockType.Vector(types[0].Unit, length);
    }

    private static MathBlockType VectorComparisonType(IReadOnlyList<MathBlockType> types)
    {
        var vector = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
        return MathBlockType.BooleanVector(vector.Rows);
    }

    private static MathBlockType BooleanVectorBinaryType(IReadOnlyList<MathBlockType> types)
    {
        var vector = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.BooleanVector);
        return MathBlockType.BooleanVector(vector.Rows);
    }

    private static MathBlockType VectorSelectType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.BooleanVector);
        var vector = MathBlockTypeRules.SameBinary([types[1], types[2]], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireCompatibleShape(types[0], vector);
        return vector;
    }

    private static MathBlockType LinspaceType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.SameBinary([types[0], types[1]], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[2]);
        return MathBlockType.Vector(types[0].Unit);
    }

    private static MathBlockType RepeatType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(types[1]);
        return MathBlockType.Vector(types[0].Unit);
    }

    private static int MergedLength(MathBlockType left, MathBlockType right) =>
        left.Rows == 0 ? right.Rows : left.Rows;

    private static int RequirePositiveInteger(double value)
    {
        var integer = RequireNonnegativeInteger(value);
        return integer > 0 ? integer : throw new ArgumentOutOfRangeException(nameof(value));
    }

    private static int RequireNonnegativeInteger(double value)
    {
        if (value < 0d || value > int.MaxValue || value != Math.Truncate(value))
            throw new ArgumentOutOfRangeException(nameof(value));
        return (int)value;
    }
}
