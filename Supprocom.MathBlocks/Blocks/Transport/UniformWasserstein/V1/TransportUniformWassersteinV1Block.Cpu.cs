namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    /// <summary>Computes the <c>transport.uniform-wasserstein@1</c> mathematical operation.</summary>
    public static float UniformWasserstein(IReadOnlyList<float> left, IReadOnlyList<float> right, float order)
    {
        var leftSorted = MathBlockCollectionPrimitives.SortedCopy(
            left,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var rightSorted = MathBlockCollectionPrimitives.SortedCopy(
            right,
            MathBlockCollectionPrimitives.CompareDoubleAscending);
        var sum = 0f;
        for (var index = 0; index < leftSorted.Length; index++)
            sum += MathBlockScalar.Power(MathBlockScalar.Absolute(leftSorted[index] - rightSorted[index]), order);
        return MathBlockScalar.Power(sum / leftSorted.Length, 1f / order);
    }
}
