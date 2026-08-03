
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{

    public static double[] Append(IReadOnlyList<double> values, double value)
    {
        var result = new double[values.Count + 1];
        for (var index = 0; index < values.Count; index++)
            result[index] = values[index];
        result[^1] = value;
        return result;
    }

    public static double[] Prepend(double value, IReadOnlyList<double> values)
    {
        var result = new double[values.Count + 1];
        result[0] = value;
        for (var index = 0; index < values.Count; index++)
            result[index + 1] = values[index];
        return result;
    }

    public static double[] Row(MathBlockMatrix matrix, int row)
    {
        var result = new double[matrix.Columns];
        for (var column = 0; column < matrix.Columns; column++)
            result[column] = matrix[row, column];
        return result;
    }

    public static double[] Column(MathBlockMatrix matrix, int column)
    {
        var result = new double[matrix.Rows];
        for (var row = 0; row < matrix.Rows; row++)
            result[row] = matrix[row, column];
        return result;
    }
}

internal static partial class StructuralMathBlocks
{
    private static readonly MathBlockValue vector = MathBlockValue.Vector([1d, 2d, 3d, 4d]);
    private static readonly MathBlockValue matrix = MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 2d, 3d, 4d]));

    private static MathBlockOperation CreateAppend(string identifier, bool prepend) => MathBlockOperationFactory.Create(
        identifier, 2,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return MathBlockType.Vector(types[0].Unit, types[0].Rows == 0 ? 0 : types[0].Rows + 1);
        },
        inputs => MathBlockValue.Vector(
            prepend
                ? MathBlockStructure.Prepend(inputs[1].AsScalar(), inputs[0].AsVector())
                : MathBlockStructure.Append(inputs[0].AsVector(), inputs[1].AsScalar()),
            inputs[0].Type.Unit, true),
        [MathBlockValue.Vector([1d, 2d]), MathBlockValue.Scalar(3d)],
        MathBlockValue.Vector(prepend ? [3d, 1d, 2d] : [1d, 2d, 3d]), performanceIterations: 32);

    private static MathBlockOperation CreateMatrixIndex(string identifier, bool row) => MathBlockOperationFactory.Create(
        identifier, 2,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            RequireDimensionlessScalar(types[1]);
            return MathBlockType.Vector(types[0].Unit, row ? types[0].Columns : types[0].Rows);
        },
        inputs =>
        {
            var selected = inputs[1].AsScalar();
            var source = inputs[0].AsMatrix();
            var limit = row ? source.Rows : source.Columns;
            if (!TryNonnegativeInteger(selected, out var index) || index >= limit)
                return MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The index is outside the matrix domain.");
            return MathBlockValue.Vector(row ? MathBlockStructure.Row(source, index) : MathBlockStructure.Column(source, index),
                inputs[0].Type.Unit, true);
        },
        [matrix, MathBlockValue.Scalar(1d)], MathBlockValue.Vector(row ? [3d, 4d] : [2d, 4d]),
        performanceIterations: 32);

    private static MathBlockOperation CreateMatrixReduction(
        string identifier,
        Func<MathBlockMatrix, double[]> function,
        double[] expected,
        bool rows) => MathBlockOperationFactory.Create(
        identifier, 1,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            return MathBlockType.Vector(types[0].Unit, rows ? types[0].Rows : types[0].Columns);
        },
        inputs => MathBlockValue.Vector(function(inputs[0].AsMatrix()), inputs[0].Type.Unit, true),
        [matrix], MathBlockValue.Vector(expected), performanceIterations: 16);

    private static MathBlockOperation CreateBooleanReduction(
        string identifier,
        Func<IReadOnlyList<bool>, bool> function,
        bool expected) => MathBlockOperationFactory.Create(
        identifier, 1,
        types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.BooleanVector);
            return MathBlockType.Boolean;
        },
        inputs => MathBlockValue.Boolean(function(inputs[0].AsBooleanVector())),
        [MathBlockValue.BooleanVector([true, false])], MathBlockValue.Boolean(expected), performanceIterations: 32);

    private static void RequireDimensionlessScalar(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Scalar);
        MathBlockTypeRules.RequireDimensionless(type);
    }

    private static int ProductOrUnknown(int left, int right) => left == 0 || right == 0 ? 0 : left * right;

    private static bool TryNonnegativeInteger(double value, out int result)
    {
        if (value is >= 0d and <= int.MaxValue && value == Math.Truncate(value))
        {
            result = (int)value;
            return true;
        }
        result = 0;
        return false;
    }
}
