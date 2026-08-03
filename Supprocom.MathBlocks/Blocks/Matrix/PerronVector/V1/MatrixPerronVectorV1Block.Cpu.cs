
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] PerronVector(MathBlockMatrix matrix, int iterations)
    {
        var vector = MathBlockCollectionPrimitives.Repeat(1d / matrix.Rows, matrix.Rows);
        for (var iteration = 0; iteration < iterations; iteration++)
        {
            var next = MathBlockLinearAlgebra.Multiply(matrix, vector);
            for (var index = 0; index < next.Length; index++)
                next[index] += vector[index];
            vector = next;
            var norm = MathBlockVectorMath.Sum(vector);
            for (var index = 0; index < vector.Length; index++)
                vector[index] /= norm;
        }

        return vector;
    }
}
