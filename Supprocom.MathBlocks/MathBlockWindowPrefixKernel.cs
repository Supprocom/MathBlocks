namespace Supprocom.MathBlocks;

// The kernel of one window-prefix.* form and its sibling. The exact sliding sums depend on the width, so there is
// no width-independent preparation: each width runs its own pass.
internal sealed class MathBlockWindowPrefixKernel(MathBlockWindowPrefixStatistic statistic) : MathBlockWindowKernel
{
    internal override void Run(
        object? prepared,
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var x = inputs[0].AsVector().Span;
        switch (statistic)
        {
            case MathBlockWindowPrefixStatistic.Sum:
            case MathBlockWindowPrefixStatistic.Mean:
                MathBlockWindowPrefix.RunSum(
                    x,
                    count,
                    width,
                    statistic == MathBlockWindowPrefixStatistic.Mean,
                    fill,
                    values,
                    valid);
                break;
            default:
                MathBlockWindowPrefix.RunVariance(
                    x,
                    count,
                    width,
                    statistic is MathBlockWindowPrefixStatistic.SampleVariance
                        or MathBlockWindowPrefixStatistic.SampleStandardDeviation,
                    statistic is MathBlockWindowPrefixStatistic.PopulationStandardDeviation
                        or MathBlockWindowPrefixStatistic.SampleStandardDeviation,
                    fill,
                    values,
                    valid);
                break;
        }
    }
}
