
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    public static double[] Unique(IReadOnlyList<double> values)
    {
        var result = new double[values.Count];
        var count = 0;
        for (var index = 0; index < values.Count; index++)
        {
            var found = false;
            for (var prior = 0; prior < count; prior++)
            {
                if (result[prior] != values[index])
                    continue;
                found = true;
                break;
            }
            if (!found)
                result[count++] = values[index];
        }
        var exact = new double[count];
        for (var index = 0; index < count; index++)
            exact[index] = result[index];
        return exact;
    }
}
