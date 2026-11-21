
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>order.majorizes@1</c> mathematical operation.</summary>
    public static bool Majorizes(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        var leftSorted = MathBlockCollectionPrimitives.SortedCopy(
            left,
            MathBlockCollectionPrimitives.CompareDoubleDescending);
        var rightSorted = MathBlockCollectionPrimitives.SortedCopy(
            right,
            MathBlockCollectionPrimitives.CompareDoubleDescending);
        var leftSum = 0f;
        var rightSum = 0f;
        for (var index = 0; index < left.Count; index++)
        {
            leftSum += leftSorted[index];
            rightSum += rightSorted[index];
            if (index < left.Count - 1 && leftSum < rightSum)
                return false;
        }

        return leftSum == rightSum;
    }
}
