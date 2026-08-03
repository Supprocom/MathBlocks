namespace Supprocom.MathBlocks;
internal static partial class StatisticalMathBlocks
{
    internal static class StatisticsLinearInterceptV1Block
    {
        internal const string Identity = "statistics.linear-intercept@1";
        internal static MathBlockOperation Create() => CreateBinary("statistics.linear-intercept", MathBlockStatistics.LinearIntercept, 1d, InterceptType);
    }
}
