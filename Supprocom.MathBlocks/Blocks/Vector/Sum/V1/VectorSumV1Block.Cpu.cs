namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Sum(IReadOnlyList<double> values)
    {
        var sum = 0d;
        var correction = 0d;
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
