
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double PerronValue(MathBlockMatrix matrix, int iterations)
    {
        var vector = PerronVector(matrix, iterations);
        var product = MathBlockLinearAlgebra.Multiply(matrix, vector);
        return MathBlockVectorMath.Dot(vector, product) / MathBlockVectorMath.Dot(vector, vector);
    }
}
