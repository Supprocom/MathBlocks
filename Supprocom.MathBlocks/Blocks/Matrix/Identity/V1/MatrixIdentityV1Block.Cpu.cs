
namespace Supprocom.MathBlocks;

public static partial class MathBlockLinearAlgebra
{
    public static MathBlockMatrix Identity(int size)
    {
        var values = new double[size * size];
        for (var index = 0; index < size; index++)
            values[index * size + index] = 1d;
        return new MathBlockMatrix(size, size, values, true);
    }
}
