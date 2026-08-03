namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double DistanceCorrelation(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var count = left.Count;
        var leftDistances = new double[count * count];
        var rightDistances = new double[count * count];
        CenterDistanceMatrix(left, leftDistances);
        CenterDistanceMatrix(right, rightDistances);
        var covarianceSquare = 0d;
        var leftVarianceSquare = 0d;
        var rightVarianceSquare = 0d;
        for (var index = 0; index < leftDistances.Length; index++)
        {
            covarianceSquare += leftDistances[index] * rightDistances[index];
            leftVarianceSquare += leftDistances[index] * leftDistances[index];
            rightVarianceSquare += rightDistances[index] * rightDistances[index];
        }

        covarianceSquare /= count * count;
        leftVarianceSquare /= count * count;
        rightVarianceSquare /= count * count;
        return Math.Sqrt(covarianceSquare / Math.Sqrt(leftVarianceSquare * rightVarianceSquare));
    }
}
