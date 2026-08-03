namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static MathBlockMatrix MonotoneCoupling(IReadOnlyList<double> leftWeights, IReadOnlyList<double> rightWeights)
    {
        var result = new double[leftWeights.Count * rightWeights.Count];
        var leftIndex = 0;
        var rightIndex = 0;
        var leftRemaining = leftWeights[0];
        var rightRemaining = rightWeights[0];
        while (leftIndex < leftWeights.Count && rightIndex < rightWeights.Count)
        {
            var amount = Math.Min(leftRemaining, rightRemaining);
            result[leftIndex * rightWeights.Count + rightIndex] += amount;
            leftRemaining -= amount;
            rightRemaining -= amount;
            if (leftRemaining == 0d && ++leftIndex < leftWeights.Count)
                leftRemaining = leftWeights[leftIndex];
            if (rightRemaining == 0d && ++rightIndex < rightWeights.Count)
                rightRemaining = rightWeights[rightIndex];
        }

        return new MathBlockMatrix(leftWeights.Count, rightWeights.Count, result, true);
    }
}
