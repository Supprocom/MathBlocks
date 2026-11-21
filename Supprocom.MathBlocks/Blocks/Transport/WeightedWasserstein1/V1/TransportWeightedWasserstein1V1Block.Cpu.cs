namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    /// <summary>Computes the <c>transport.weighted-wasserstein-1@1</c> mathematical operation.</summary>
    public static float WeightedWasserstein1(IReadOnlyList<float> leftLocations, IReadOnlyList<float> leftWeights, IReadOnlyList<float> rightLocations, IReadOnlyList<float> rightWeights)
    {
        ArgumentNullException.ThrowIfNull(leftLocations);
        ArgumentNullException.ThrowIfNull(leftWeights);
        ArgumentNullException.ThrowIfNull(rightLocations);
        ArgumentNullException.ThrowIfNull(rightWeights);
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
        var result = 0f;
        while (leftIndex < left.Length && rightIndex < right.Length)
        {
            var amount = Math.Min(leftRemaining, rightRemaining);
            result += amount * Math.Abs(leftLocations[left[leftIndex]] - rightLocations[right[rightIndex]]);
            leftRemaining -= amount;
            rightRemaining -= amount;
            if (leftRemaining == 0f && ++leftIndex < left.Length)
                leftRemaining = leftWeights[left[leftIndex]];
            if (rightRemaining == 0f && ++rightIndex < right.Length)
                rightRemaining = rightWeights[right[rightIndex]];
        }

        return result;
    }
}
