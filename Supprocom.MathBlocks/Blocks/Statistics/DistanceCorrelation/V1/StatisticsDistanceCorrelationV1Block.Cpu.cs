namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    /// <summary>Computes the <c>statistics.distance-correlation@1</c> mathematical operation.</summary>
    public static float DistanceCorrelation(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var count = left.Count;
        var leftDistances = new float[count * count];
        var rightDistances = new float[count * count];
        CenterDistanceMatrix(left, leftDistances);
        CenterDistanceMatrix(right, rightDistances);
        var covarianceSquare = 0f;
        var leftVarianceSquare = 0f;
        var rightVarianceSquare = 0f;
        for (var index = 0; index < leftDistances.Length; index++)
        {
            covarianceSquare += leftDistances[index] * rightDistances[index];
            leftVarianceSquare += leftDistances[index] * leftDistances[index];
            rightVarianceSquare += rightDistances[index] * rightDistances[index];
        }

        covarianceSquare /= count * count;
        leftVarianceSquare /= count * count;
        rightVarianceSquare /= count * count;
        // A moment or a product of the two variances that overflows would divide by an infinity and give a finite zero;
        // the result is then not finite (invalid).
        var denominator = Math.Sqrt(leftVarianceSquare * rightVarianceSquare);
        if (!Math.IsFinite(covarianceSquare) || !Math.IsFinite(leftVarianceSquare) || !Math.IsFinite(rightVarianceSquare) || !Math.IsFinite(denominator))
            return Math.NaN;
        return Math.Sqrt(covarianceSquare / denominator);
    }
}
