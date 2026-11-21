
namespace Supprocom.MathBlocks;

public static partial class MathBlockStructure
{
    /// <summary>Computes the <c>vector.unique@1</c> mathematical operation.</summary>
    public static float[] Unique(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count];
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
        var exact = new float[count];
        for (var index = 0; index < count; index++)
            exact[index] = result[index];
        return exact;
    }
}
