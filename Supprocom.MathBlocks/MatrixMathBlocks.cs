
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{

    public static MathBlockMatrix Multiply(MathBlockMatrix left, MathBlockMatrix right)
    {
        var result = new double[left.Rows * right.Columns];
        for (var row = 0; row < left.Rows; row++)
        {
            for (var inner = 0; inner < left.Columns; inner++)
            {
                var leftValue = left[row, inner];
                for (var column = 0; column < right.Columns; column++)
                    result[row * right.Columns + column] += leftValue * right[inner, column];
            }
        }
        return new MathBlockMatrix(left.Rows, right.Columns, result, true);
    }

    public static double[] Multiply(MathBlockMatrix matrix, IReadOnlyList<double> vector)
    {
        var result = new double[matrix.Rows];
        for (var row = 0; row < matrix.Rows; row++)
        {
            var sum = 0d;
            for (var column = 0; column < matrix.Columns; column++)
                sum += matrix[row, column] * vector[column];
            result[row] = sum;
        }
        return result;
    }

    public static bool IsSymmetric(MathBlockMatrix matrix)
    {
        if (matrix.Rows != matrix.Columns)
            return false;
        for (var row = 0; row < matrix.Rows; row++)
            for (var column = row + 1; column < matrix.Columns; column++)
                if (matrix[row, column] != matrix[column, row])
                    return false;
        return true;
    }

    public static double[] SymmetricEigenvalues(MathBlockMatrix matrix)
    {
        var size = matrix.Rows;
        var values = matrix.ToArray();
        for (var iteration = 0; iteration < 64 * size * size; iteration++)
        {
            var pivotRow = 0;
            var pivotColumn = 0;
            var largest = 0d;
            for (var row = 0; row < size; row++)
            {
                for (var column = row + 1; column < size; column++)
                {
                    var magnitude = Math.Abs(values[row * size + column]);
                    if (magnitude <= largest)
                        continue;
                    largest = magnitude;
                    pivotRow = row;
                    pivotColumn = column;
                }
            }
            if (largest == 0d)
                break;
            var angle = 0.5d * Math.Atan2(
                2d * values[pivotRow * size + pivotColumn],
                values[pivotColumn * size + pivotColumn] - values[pivotRow * size + pivotRow]);
            var cosine = Math.Cos(angle);
            var sine = Math.Sin(angle);
            var aa = values[pivotRow * size + pivotRow];
            var bb = values[pivotColumn * size + pivotColumn];
            var ab = values[pivotRow * size + pivotColumn];
            values[pivotRow * size + pivotRow] = cosine * cosine * aa - 2d * sine * cosine * ab + sine * sine * bb;
            values[pivotColumn * size + pivotColumn] = sine * sine * aa + 2d * sine * cosine * ab + cosine * cosine * bb;
            values[pivotRow * size + pivotColumn] = 0d;
            values[pivotColumn * size + pivotRow] = 0d;
            for (var other = 0; other < size; other++)
            {
                if (other == pivotRow || other == pivotColumn)
                    continue;
                var first = values[other * size + pivotRow];
                var second = values[other * size + pivotColumn];
                values[other * size + pivotRow] = values[pivotRow * size + other] = cosine * first - sine * second;
                values[other * size + pivotColumn] = values[pivotColumn * size + other] = sine * first + cosine * second;
            }
        }
        var result = new double[size];
        for (var index = 0; index < size; index++)
            result[index] = values[index * size + index];
        MathBlockCollectionPrimitives.StableMergeSort(
            result,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        return result;
    }

    private static MathBlockMatrix Elementwise(
        MathBlockMatrix left,
        MathBlockMatrix right,
        Func<double, double, double> function)
    {
        var leftValues = left.ToArray();
        var rightValues = right.ToArray();
        for (var index = 0; index < leftValues.Length; index++)
            leftValues[index] = function(leftValues[index], rightValues[index]);
        return new MathBlockMatrix(left.Rows, left.Columns, leftValues, true);
    }

    private static void SwapRows(double[] values, int columns, int left, int right)
    {
        if (left == right)
            return;
        for (var column = 0; column < columns; column++)
            (values[left * columns + column], values[right * columns + column]) =
                (values[right * columns + column], values[left * columns + column]);
    }
}

public static partial class MathBlockPolynomial
{

    private static Complex ComplexCubeRoot(Complex value) => value.Real == 0d && value.Imaginary == 0d
        ? new Complex(0d, 0d)
        : MathBlockComplex.FromPolar(
            Math.Cbrt(MathBlockComplex.Magnitude(value)),
            MathBlockComplex.Phase(value) / 3d);
}

internal static partial class MatrixMathBlocks
{
    private static readonly MathBlockValue matrixA = MathBlockValue.Matrix(
        new MathBlockMatrix(2, 2, [1d, 2d, 3d, 4d]));
    private static readonly MathBlockValue matrixB = MathBlockValue.Matrix(
        new MathBlockMatrix(2, 2, [2d, 0d, 1d, 2d]));
    private static readonly MathBlockValue symmetric = MathBlockValue.Matrix(
        new MathBlockMatrix(2, 2, [2d, 1d, 1d, 2d]));

    private static MathBlockOperation CreateUnaryMatrix(
        string identifier,
        Func<MathBlockMatrix, MathBlockMatrix> function,
        MathBlockMatrix expected,
        MathBlockTypeResolver resolver,
        MathBlockValue? sample = null) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Matrix(function(inputs[0].AsMatrix()), type.Unit);
        },
        [sample ?? matrixA], MathBlockValue.Matrix(expected), 1e-9, 8);

    private static MathBlockOperation CreateBinaryMatrix(
        string identifier,
        Func<MathBlockMatrix, MathBlockMatrix, MathBlockMatrix> function,
        MathBlockMatrix expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 2, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Matrix(function(inputs[0].AsMatrix(), inputs[1].AsMatrix()), type.Unit);
        },
        [matrixA, matrixB], MathBlockValue.Matrix(expected), 1e-9, 8);

    private static MathBlockOperation CreateScalarMatrixReduction(
        string identifier,
        Func<MathBlockMatrix, double> function,
        MathBlockValue sample,
        double expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Scalar(function(inputs[0].AsMatrix()), type.Unit);
        },
        [sample], MathBlockValue.Scalar(expected), 1e-9, 8);

    private static MathBlockOperation CreateBooleanMatrix(
        string identifier,
        Func<MathBlockMatrix, bool> function,
        MathBlockValue sample,
        bool expected) => MathBlockOperationFactory.Create(
        identifier, 1,
        types => { MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix); return MathBlockType.Boolean; },
        inputs => MathBlockValue.Boolean(function(inputs[0].AsMatrix())),
        [sample], MathBlockValue.Boolean(expected), performanceIterations: 8);

    private static MathBlockType TransposeType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        return MathBlockType.Matrix(types[0].Unit, types[0].Columns, types[0].Rows);
    }

    private static MathBlockType SameMatrices(IReadOnlyList<MathBlockType> types) =>
        MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Matrix);

    private static MathBlockType HadamardType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireCompatibleShape(types[0], types[1]);
        return MathBlockType.Matrix(types[0].Unit.Multiply(types[1].Unit), types[0].Rows, types[0].Columns);
    }

    private static MathBlockType MatrixScaleType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
        return MathBlockType.Matrix(types[0].Unit.Multiply(types[1].Unit), types[0].Rows, types[0].Columns);
    }

    private static MathBlockType MultiplyType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Matrix);
        if (types[0].Columns != 0 && types[1].Rows != 0 && types[0].Columns != types[1].Rows)
            throw new InvalidOperationException("The inner matrix dimensions must be equal.");
        return MathBlockType.Matrix(types[0].Unit.Multiply(types[1].Unit), types[0].Rows, types[1].Columns);
    }

    private static MathBlockType MatrixVectorType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        if (types[0].Columns != 0 && types[1].Rows != 0 && types[0].Columns != types[1].Rows)
            throw new InvalidOperationException("The matrix and vector dimensions must agree.");
        return MathBlockType.Vector(types[0].Unit.Multiply(types[1].Unit), types[0].Rows);
    }

    private static MathBlockType OuterProductType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        return MathBlockType.Matrix(types[0].Unit.Multiply(types[1].Unit), types[0].Rows, types[1].Rows);
    }

    private static MathBlockType TraceType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquare(types[0]);
        return MathBlockType.Scalar(types[0].Unit);
    }

    private static MathBlockType DeterminantType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquare(types[0]);
        if (types[0].Rows == 0)
            throw new InvalidOperationException("The determinant requires a known matrix size.");
        return MathBlockType.Scalar(types[0].Unit.Pow(new MathRational(types[0].Rows)));
    }

    private static MathBlockType SolveType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquare(types[0]);
        MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Vector);
        if (types[0].Rows != 0 && types[1].Rows != 0 && types[0].Rows != types[1].Rows)
            throw new InvalidOperationException("The matrix and vector dimensions must agree.");
        return MathBlockType.Vector(types[1].Unit.Divide(types[0].Unit), types[1].Rows);
    }

    private static MathBlockType InverseType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquare(types[0]);
        return MathBlockType.Matrix(types[0].Unit.Pow(new MathRational(-1)), types[0].Rows, types[0].Columns);
    }

    private static MathBlockType EigenvaluesType(IReadOnlyList<MathBlockType> types)
    {
        RequireSquare(types[0]);
        return MathBlockType.Vector(types[0].Unit, types[0].Rows);
    }

    private static MathBlockType GramType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        return MathBlockType.Matrix(types[0].Unit.Pow(new MathRational(2)), types[0].Columns, types[0].Columns);
    }

    private static MathBlockType CovarianceMatrixType(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
        return MathBlockType.Matrix(types[0].Unit.Pow(new MathRational(2)), types[0].Columns, types[0].Columns);
    }

    private static void RequireSquare(MathBlockType type)
    {
        MathBlockTypeRules.RequireKind(type, MathBlockValueKind.Matrix);
        if (type.Rows != 0 && type.Columns != 0 && type.Rows != type.Columns)
            throw new InvalidOperationException("The matrix must be square.");
    }
}
