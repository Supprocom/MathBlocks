namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    public static double Mean(IReadOnlyList<double> values) => Sum(values) / values.Count;
}
