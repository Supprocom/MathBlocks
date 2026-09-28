
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>combinatorics.ballot-count@1</c> mathematical operation.</summary>
    public static double BallotCount(int leadingCount, int trailingCount) => (double)(leadingCount - trailingCount) / (leadingCount + trailingCount) * MathBlockProbability.BinomialCoefficient(leadingCount + trailingCount, trailingCount);
}
