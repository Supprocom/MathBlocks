
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.hysteresis@1</c> mathematical operation.</summary>
    public static float[] Hysteresis(IReadOnlyList<float> values, float lower, float upper)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new float[values.Count];
        var state = 0f;
        for (var index = 0; index < values.Count; index++)
        {
            if (values[index] >= upper)
                state = 1f;
            else if (values[index] <= lower)
                state = -1f;
            result[index] = state;
        }

        return result;
    }
}
