
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static MathBlockMatrix LeadLagTransform(IReadOnlyList<double> values)
    {
        if (values.Count == 1)
            return new MathBlockMatrix(1, 2, [values[0], values[0]]);
        var result = new double[(2 * values.Count - 1) * 2];
        var row = 0;
        result[0] = values[0];
        result[1] = values[0];
        for (var index = 1; index < values.Count; index++)
        {
            row++;
            result[row * 2] = values[index];
            result[row * 2 + 1] = values[index - 1];
            row++;
            result[row * 2] = values[index];
            result[row * 2 + 1] = values[index];
        }

        return new MathBlockMatrix(2 * values.Count - 1, 2, result, true);
    }
}
