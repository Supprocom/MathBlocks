
namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{

    private static MathBlockOperation CreateVectorUnary(
        string identifier,
        Func<IReadOnlyList<double>, double[]> function,
        MathBlockValue sample,
        double[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            var values = inputs[0].AsVector();
            return values.Count > 0
                ? MathBlockValue.Vector(function(values), type.Unit, true)
                : MathBlockValue.Invalid(type, "The vector is empty.");
        },
        [sample], MathBlockValue.Vector(expected), 1e-8, 8);

    private static MathBlockOperation CreateVectorScalar(
        string identifier,
        Func<IReadOnlyList<double>, double> function,
        MathBlockValue sample,
        double expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return inputs[0].AsVector().Count > 0
                ? MathBlockValue.Scalar(function(inputs[0].AsVector()), type.Unit)
                : MathBlockValue.Invalid(type, "The vector is empty.");
        },
        [sample], MathBlockValue.Scalar(expected), 1e-8, 8);

    private static MathBlockOperation CreateStructuredMatrix(
        string identifier,
        Func<IReadOnlyList<double>, IReadOnlyList<double>, MathBlockMatrix> function,
        MathBlockValue first,
        MathBlockValue second,
        MathBlockMatrix expected) => MathBlockOperationFactory.Create(
        identifier, 2,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return MathBlockType.Matrix(types[0].Unit, types[0].Rows, types[1].Rows);
        },
        inputs => inputs[0].AsVector().Count > 0 && inputs[1].AsVector().Count > 0 &&
                  (identifier == "matrix.hankel"
                      ? inputs[0].AsVector()[^1] == inputs[1].AsVector()[0]
                      : inputs[0].AsVector()[0] == inputs[1].AsVector()[0])
            ? MathBlockValue.Matrix(function(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit)
            : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit), "The boundary vectors are incompatible."),
        [first, second], MathBlockValue.Matrix(expected), 1e-9, 8);

    private static MathBlockOperation CreateSemiringMultiply(
        string identifier,
        Func<MathBlockMatrix, MathBlockMatrix, MathBlockMatrix> function,
        MathBlockMatrix expected) => MathBlockOperationFactory.Create(
        identifier, 2, AdditiveMatrixProductType,
        inputs => MathBlockValue.Matrix(function(inputs[0].AsMatrix(), inputs[1].AsMatrix()), inputs[0].Type.Unit),
        [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 2d, 3d, 4d])),
         MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [5d, 6d, 7d, 8d]))],
        MathBlockValue.Matrix(expected), performanceIterations: 8);

    private static MathBlockOperation CreateVectorBoolean(
        string identifier,
        Func<IReadOnlyList<double>, bool> function,
        MathBlockValue sample,
        bool expected) => MathBlockOperationFactory.Create(
        identifier, 1,
        types => { MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector); return MathBlockType.Boolean; },
        inputs => MathBlockValue.Boolean(function(inputs[0].AsVector())),
        [sample], MathBlockValue.Boolean(expected), performanceIterations: 8);

    private static MathBlockOperation CreateLipschitzExtension(
        string identifier,
        Func<IReadOnlyList<double>, IReadOnlyList<double>, IReadOnlyList<double>, double, double[]> function) =>
        MathBlockOperationFactory.Create(
            identifier, 4, LipschitzType,
            inputs => inputs[0].AsVector().Count > 0 && inputs[0].AsVector().Count == inputs[1].AsVector().Count &&
                      inputs[3].AsScalar() >= 0d
                ? MathBlockValue.Vector(function(inputs[0].AsVector(), inputs[1].AsVector(), inputs[2].AsVector(),
                    inputs[3].AsScalar()), inputs[1].Type.Unit, true)
                : MathBlockValue.Invalid(MathBlockType.Vector(inputs[1].Type.Unit), "The inputs are outside the operation domain."),
            [MathBlockValue.Vector([0d, 2d]), MathBlockValue.Vector([0d, 2d]),
             MathBlockValue.Vector([1d]), MathBlockValue.Scalar(1d)],
            MathBlockValue.Vector([1d]), performanceIterations: 8);

    private static MathBlockOperation CreatePositiveVectorMetric(
        string identifier,
        Func<IReadOnlyList<double>, IReadOnlyList<double>, double> function,
        MathBlockValue left,
        MathBlockValue right,
        double expected,
        bool distribution) => MathBlockOperationFactory.Create(
        identifier, 2,
        types =>
        {
            MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.Scalar();
        },
        inputs => IsPositivePair(inputs[0].AsVector(), inputs[1].AsVector(), distribution)
            ? MathBlockValue.Scalar(function(inputs[0].AsVector(), inputs[1].AsVector()))
            : MathBlockValue.Invalid(MathBlockType.Scalar(), "The vectors are outside the operation domain."),
        [left, right], MathBlockValue.Scalar(expected), 1e-8, 8);

    private static MathBlockOperation CreatePoisson(
        string identifier,
        Func<double, int, double> function,
        double expected,
        int count = 0) => MathBlockOperationFactory.Create(
        identifier, 2, MathBlockTypeRules.DimensionlessBinaryScalar,
        inputs => TryInteger(inputs[1].AsScalar(), out var requested) && requested >= 0 && inputs[0].AsScalar() >= 0d
            ? MathBlockValue.Scalar(function(inputs[0].AsScalar(), requested))
            : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the operation domain."),
        [MathBlockValue.Scalar(2d), MathBlockValue.Scalar(count)], MathBlockValue.Scalar(expected),
        1e-9, 16);

    private static MathBlockOperation CreateMoment(
        string identifier,
        Func<IReadOnlyList<double>, int, double> function,
        double expected) => MathBlockOperationFactory.Create(
        identifier, 2,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            RequireDimensionlessScalar(types[1]);
            return MathBlockType.Scalar();
        },
        inputs => inputs[0].AsVector().Count > 0 && TryInteger(inputs[1].AsScalar(), out var order) && order >= 0
            ? MathBlockValue.Scalar(function(inputs[0].AsVector(), order))
            : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the operation domain."),
        [MathBlockValue.Vector([1d, 2d, 3d]), MathBlockValue.Scalar(2d)], MathBlockValue.Scalar(expected),
        performanceIterations: 8);

    private static MathBlockType SameVector(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.Unary(types, MathBlockValueKind.Vector);

    private static MathBlockType DimensionlessVectorOutput(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Vector(length: types[0].Rows == 0 ? 0 : types[0].Rows + 1);
    }

    private static MathBlockType DimensionlessSameLengthVectorOutput(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        return MathBlockType.Vector(length: types[0].Rows);
    }

    private static MathBlockType DimensionlessScalar(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        return MathBlockType.Scalar();
    }

    private static MathBlockType SameUnitScalar(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.VectorReduction(types);

    private static MathBlockType ProductSquareMatrices(IReadOnlyList<MathBlockType> types)
    {
        RequireSquareMatrix(types[0]);
        RequireSquareMatrix(types[1]);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        return MathBlockType.Matrix(types[0].Unit.Multiply(types[1].Unit), types[0].Rows, types[0].Columns);
    }

    private static MathBlockType AdditiveMatrixProductType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Matrix);
        if (types[0].Unit != types[1].Unit)
            throw new InvalidOperationException("The input units must be equal.");
        if (types[0].Columns != 0 && types[1].Rows != 0 && types[0].Columns != types[1].Rows)
            throw new InvalidOperationException("The inner dimensions must agree.");
        return MathBlockType.Matrix(types[0].Unit, types[0].Rows, types[1].Columns);
    }

    private static MathBlockType PerronVectorType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquareMatrix(types[0]);
        RequireDimensionlessScalar(types[1]);
        return MathBlockType.Vector(length: types[0].Rows);
    }

    private static MathBlockType PerronValueType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquareMatrix(types[0]);
        RequireDimensionlessScalar(types[1]);
        return MathBlockType.Scalar(types[0].Unit);
    }

    private static MathBlockType LipschitzType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[3], MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        if (types[0].Unit != types[2].Unit ||
            types[3].Unit != types[1].Unit.Divide(types[0].Unit))
            throw new InvalidOperationException("The extension units are incompatible.");
        return MathBlockType.Vector(types[1].Unit, types[2].Rows);
    }

    private static MathBlockType MarkovVectorType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquareMatrix(types[0]);
        MathBlockTypeRules.RequireDimensionless(types[0]);
        RequireDimensionlessScalar(types[1]);
        return MathBlockType.Vector(length: types[0].Rows);
    }

    private static void RequireSquareMatrix(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Matrix);
        if (type.Rows != 0 && type.Columns != 0 && type.Rows != type.Columns)
            throw new InvalidOperationException("The matrix must be square.");
    }

    private static void RequireDimensionlessScalar(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(type);
    }

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

    private static bool IsNonnegative(MathBlockMatrix matrix)
    {
        for (var row = 0; row < matrix.Rows; row++)
            for (var column = 0; column < matrix.Columns; column++)
                if (matrix[row, column] < 0d)
                    return false;
        return true;
    }

    private static bool IsPositivePair(
        IReadOnlyList<double> left,
        IReadOnlyList<double> right,
        bool distribution)
    {
        if (left.Count == 0 || left.Count != right.Count)
            return false;
        if (distribution)
            return IsDistribution(left) && IsDistribution(right);
        return MathBlockCollectionPrimitives.All(left, value => value > 0d) &&
               MathBlockCollectionPrimitives.All(right, value => value > 0d);
    }

    private static bool IsDistribution(IReadOnlyList<double> values) =>
        values.Count > 0 && MathBlockCollectionPrimitives.All(values, value => value >= 0d) &&
        Math.Abs(MathBlockVectorMath.Sum(values) - 1d) <= 1e-10;

    private static bool IsTransitionMatrix(MathBlockMatrix matrix)
    {
        if (matrix.Rows != matrix.Columns)
            return false;
        for (var row = 0; row < matrix.Rows; row++)
        {
            var sum = 0d;
            for (var column = 0; column < matrix.Columns; column++)
            {
                if (matrix[row, column] < 0d)
                    return false;
                sum += matrix[row, column];
            }
            if (Math.Abs(sum - 1d) > 1e-10)
                return false;
        }
        return true;
    }

    private static bool IsPowerOfTwo(int value) => value > 0 && (value & (value - 1)) == 0;
}
