
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>path.signature-level-three@1</c> mathematical operation.</summary>
    public static float[] SignatureLevelThree(MathBlockMatrix path)
    {
        ArgumentNullException.ThrowIfNull(path);
        var dimension = path.Columns;
        var first = new float[dimension];
        var second = new float[dimension * dimension];
        var third = new float[dimension * dimension * dimension];
        for (var row = 1; row < path.Rows; row++)
        {
            var increment = new float[dimension];
            for (var index = 0; index < dimension; index++)
                increment[index] = path[row, index] - path[row - 1, index];
            for (var left = 0; left < dimension; left++)
            {
                for (var middle = 0; middle < dimension; middle++)
                {
                    for (var right = 0; right < dimension; right++)
                    {
                        third[(left * dimension + middle) * dimension + right] += second[left * dimension + middle] * increment[right] + first[left] * increment[middle] * increment[right] / 2f + increment[left] * increment[middle] * increment[right] / 6f;
                    }

                    second[left * dimension + middle] += first[left] * increment[middle] + increment[left] * increment[middle] / 2f;
                }

                first[left] += increment[left];
            }
        }

        return third;
    }
}
