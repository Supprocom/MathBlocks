namespace Supprocom.MathBlocks;

public static partial class MathBlockStatistics
{
    public static double KendallTauB(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        long concordant = 0;
        long discordant = 0;
        long leftTies = 0;
        long rightTies = 0;
        for (var first = 0; first < left.Count; first++)
        {
            for (var second = first + 1; second < left.Count; second++)
            {
                var leftSign = Math.Sign(left[first] - left[second]);
                var rightSign = Math.Sign(right[first] - right[second]);
                if (leftSign == 0 && rightSign == 0)
                    continue;
                if (leftSign == 0)
                    leftTies++;
                else if (rightSign == 0)
                    rightTies++;
                else if (leftSign == rightSign)
                    concordant++;
                else
                    discordant++;
            }
        }

        return (concordant - discordant) / Math.Sqrt((double)(concordant + discordant + leftTies) * (concordant + discordant + rightTies));
    }
}
