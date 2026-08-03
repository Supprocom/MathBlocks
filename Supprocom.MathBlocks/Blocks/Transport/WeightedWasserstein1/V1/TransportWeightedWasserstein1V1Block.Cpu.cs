namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static double WeightedWasserstein1(IReadOnlyList<double> leftLocations, IReadOnlyList<double> leftWeights, IReadOnlyList<double> rightLocations, IReadOnlyList<double> rightWeights)
    {
        var left = MathBlockCollectionPrimitives.SortedIndices(
            leftLocations,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var right = MathBlockCollectionPrimitives.SortedIndices(
            rightLocations,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var leftIndex = 0;
        var rightIndex = 0;
        var leftRemaining = leftWeights[left[0]];
        var rightRemaining = rightWeights[right[0]];
        var result = 0d;
        while (leftIndex < left.Length && rightIndex < right.Length)
        {
            var amount = Math.Min(leftRemaining, rightRemaining);
            result += amount * Math.Abs(leftLocations[left[leftIndex]] - rightLocations[right[rightIndex]]);
            leftRemaining -= amount;
            rightRemaining -= amount;
            if (leftRemaining == 0d && ++leftIndex < left.Length)
                leftRemaining = leftWeights[left[leftIndex]];
            if (rightRemaining == 0d && ++rightIndex < right.Length)
                rightRemaining = rightWeights[right[rightIndex]];
        }

        return result;
    }
}
