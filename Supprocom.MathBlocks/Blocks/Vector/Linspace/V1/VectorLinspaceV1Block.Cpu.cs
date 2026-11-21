namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.linspace@1</c> mathematical operation.</summary>
    public static float[] Linspace(float start, float end, int count)
    {
        var result = new float[count];
        if (count == 1)
        {
            result[0] = start;
            return result;
        }

        var step = (end - start) / (count - 1);
        for (var index = 0; index < count; index++)
            result[index] = index == count - 1 ? end : start + step * index;
        return result;
    }
}
