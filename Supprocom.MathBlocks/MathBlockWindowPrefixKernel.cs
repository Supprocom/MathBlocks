namespace Supprocom.MathBlocks;

// The kernel of one window-prefix.* form and its sibling.
internal sealed class MathBlockWindowPrefixKernel(MathBlockWindowPrefixStatistic statistic) : MathBlockWindowKernel
{
    internal override object? Prepare(IReadOnlyList<MathBlockValue> inputs)
    {
        var x = inputs[0].AsVector().Span;
        return statistic is MathBlockWindowPrefixStatistic.Sum or MathBlockWindowPrefixStatistic.Mean
            ? MathBlockWindowPrefix.PrepareSum(x)
            : MathBlockWindowPrefix.PrepareVariance(x);
    }

    internal override void Run(
        object? prepared,
        IReadOnlyList<MathBlockValue> inputs,
        int count,
        int width,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        switch (statistic)
        {
            case MathBlockWindowPrefixStatistic.Sum:
            case MathBlockWindowPrefixStatistic.Mean:
                MathBlockWindowPrefix.RunSum(
                    (MathBlockWindowPrefix.SumPrefix)prepared!,
                    count,
                    width,
                    statistic == MathBlockWindowPrefixStatistic.Mean,
                    fill,
                    values,
                    valid);
                break;
            default:
                MathBlockWindowPrefix.RunVariance(
                    (MathBlockWindowPrefix.VariancePrefix)prepared!,
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
