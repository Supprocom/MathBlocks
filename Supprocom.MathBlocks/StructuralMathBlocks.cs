
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{

    /// <summary>Returns a copy of the sequence with a value appended.</summary>
    public static float[] Append(IReadOnlyList<float> values, float value)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count + 1];
        for (var index = 0; index < values.Count; index++)
            result[index] = values[index];
        result[^1] = value;
        return result;
    }

    /// <summary>Returns a copy of the sequence with a value prepended.</summary>
    public static float[] Prepend(float value, IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count + 1];
        result[0] = value;
        for (var index = 0; index < values.Count; index++)
            result[index + 1] = values[index];
        return result;
    }

    /// <summary>Copies one row from a matrix.</summary>
    public static float[] Row(MathBlockMatrix matrix, int row)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = new float[matrix.Columns];
        for (var column = 0; column < matrix.Columns; column++)
            result[column] = matrix[row, column];
        return result;
    }

    /// <summary>Copies one column from a matrix.</summary>
    public static float[] Column(MathBlockMatrix matrix, int column)
    {
        ArgumentNullException.ThrowIfNull(matrix);
        var result = new float[matrix.Rows];
        for (var row = 0; row < matrix.Rows; row++)
            result[row] = matrix[row, column];
        return result;
    }
}

internal static partial class StructuralMathBlocks
{
    private static readonly MathBlockValue vector = MathBlockValue.Vector([1f, 2f, 3f, 4f]);
    private static readonly MathBlockValue matrix = MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1f, 2f, 3f, 4f]));

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
        [MathBlockValue.Vector([1f, 2f]), MathBlockValue.Scalar(3f)],
        MathBlockValue.Vector(prepend ? [3f, 1f, 2f] : [1f, 2f, 3f]), performanceIterations: 32);

    private static MathBlockOperation CreateMatrixIndex(string identifier, bool row)
    {
        MathBlockTypeResolver resolver = types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            RequireDimensionlessScalar(types[1]);
            return MathBlockType.Vector(types[0].Unit, row ? types[0].Columns : types[0].Rows);
        };
        return MathBlockOperationFactory.Create(
            identifier, 2,
            resolver,
            inputs =>
            {
                var selected = inputs[1].AsScalar();
                var source = inputs[0].AsMatrix();
                var limit = row ? source.Rows : source.Columns;
                if (!TryNonnegativeInteger(selected, out var index) || index >= limit)
                    return MathBlockOperationFactory.Invalid(resolver, inputs, "The index is outside the matrix domain.");
                return MathBlockValue.Vector(row ? MathBlockStructure.Row(source, index) : MathBlockStructure.Column(source, index),
                    inputs[0].Type.Unit, true);
            },
            [matrix, MathBlockValue.Scalar(1f)], MathBlockValue.Vector(row ? [3f, 4f] : [2f, 4f]),
            performanceIterations: 32);
    }

    private static MathBlockOperation CreateMatrixReduction(
        string identifier,
        Func<MathBlockMatrix, float[]> function,
        float[] expected,
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

    private static bool TryNonnegativeInteger(float value, out int result)
    {
        if (value is >= 0f and <= int.MaxValue && value == Math.Truncate(value))
        {
            result = (int)value;
            return true;
        }
        result = 0;
        return false;
    }
}
