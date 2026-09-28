
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>matrix.perron-value@1</c> mathematical operation.</summary>
    public static double PerronValue(MathBlockMatrix matrix, int iterations)
    {
        var vector = PerronVector(matrix, iterations);
        var product = MathBlockLinearAlgebra.Multiply(matrix, vector);
        return MathBlockVectorMath.Dot(vector, product) / MathBlockVectorMath.Dot(vector, vector);
    }
}
