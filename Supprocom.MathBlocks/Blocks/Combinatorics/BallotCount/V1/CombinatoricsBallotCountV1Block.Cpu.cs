
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double BallotCount(int leadingCount, int trailingCount) => (double)(leadingCount - trailingCount) / (leadingCount + trailingCount) * MathBlockProbability.BinomialCoefficient(leadingCount + trailingCount, trailingCount);
}
