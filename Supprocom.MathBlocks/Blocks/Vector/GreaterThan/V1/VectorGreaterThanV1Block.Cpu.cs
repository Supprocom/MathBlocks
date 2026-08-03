namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static bool[] GreaterThan(IReadOnlyList<double> left, IReadOnlyList<double> right) => Compare(left, right, (a, b) => a > b);
}
