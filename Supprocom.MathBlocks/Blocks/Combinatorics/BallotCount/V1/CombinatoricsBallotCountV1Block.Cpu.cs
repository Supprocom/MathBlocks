
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>combinatorics.ballot-count@1</c> mathematical operation.</summary>
    public static float BallotCount(int leadingCount, int trailingCount) => (float)(leadingCount - trailingCount) / (float)((long)leadingCount + trailingCount) * MathBlockProbability.BinomialCoefficientWide((long)leadingCount + trailingCount, trailingCount);
}
