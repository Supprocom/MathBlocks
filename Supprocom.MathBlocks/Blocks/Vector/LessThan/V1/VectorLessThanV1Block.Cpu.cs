namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static bool[] LessThan(IReadOnlyList<double> left, IReadOnlyList<double> right) => Compare(left, right, (a, b) => a < b);
}
