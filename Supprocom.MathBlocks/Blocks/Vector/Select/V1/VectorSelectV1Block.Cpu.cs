namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.select@1</c> mathematical operation.</summary>
    public static float[] Select(IReadOnlyList<bool> condition, IReadOnlyList<float> whenTrue, IReadOnlyList<float> whenFalse)
    {
        ArgumentNullException.ThrowIfNull(condition);
        ArgumentNullException.ThrowIfNull(whenFalse);
        ArgumentNullException.ThrowIfNull(whenTrue);
        var result = new float[condition.Count];
        for (var index = 0; index < result.Length; index++)
            result[index] = condition[index] ? whenTrue[index] : whenFalse[index];
        return result;
    }
}
