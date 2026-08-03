namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsRootMeanSquareV1Block
    {
        internal const string Identity = "statistics.root-mean-square@1";
        internal static MathBlockOperation Create() => CreateUnary("statistics.root-mean-square", MathBlockStatistics.RootMeanSquare, Math.Sqrt(7.5d), StandardDeviationType);
    }
}
