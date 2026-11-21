namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.sum@1</c> mathematical operation.</summary>
    public static float Sum(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var sum = 0f;
        var correction = 0f;
        for (var index = 0; index < values.Count; index++)
        {
            var value = values[index];
            var next = sum + value;
            correction += Math.Abs(sum) >= Math.Abs(value) ? sum - next + value : value - next + sum;
            sum = next;
        }

        return sum + correction;
    }
}
