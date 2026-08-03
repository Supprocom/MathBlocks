namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static double UniformWasserstein(IReadOnlyList<double> left, IReadOnlyList<double> right, double order)
    {
        var leftSorted = MathBlockCollectionPrimitives.SortedCopy(
            left,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var rightSorted = MathBlockCollectionPrimitives.SortedCopy(
            right,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var sum = 0d;
        for (var index = 0; index < leftSorted.Length; index++)
            sum += MathBlockScalar.Power(MathBlockScalar.Absolute(leftSorted[index] - rightSorted[index]), order);
        return MathBlockScalar.Power(sum / leftSorted.Length, 1d / order);
    }
}
