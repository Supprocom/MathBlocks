
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    /// <summary>Computes the <c>matrix.identity@1</c> mathematical operation.</summary>
    public static MathBlockMatrix Identity(int size)
    {
        var values = new float[size * size];
        for (var index = 0; index < size; index++)
            values[index * size + index] = 1f;
        return new MathBlockMatrix(size, size, values, true);
    }
}
