namespace Supprocom.MathBlocks;

// The kernel of one window-accurate.* form and its sibling. The exact sliding sums depend on the width, so there is
// no width-independent preparation: each width runs its own pass.
internal sealed class MathBlockWindowAccurateKernel(MathBlockWindowAccurateStatistic statistic) : MathBlockWindowKernel
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
            case MathBlockWindowAccurateStatistic.Sum:
            case MathBlockWindowAccurateStatistic.Mean:
                MathBlockWindowAccurate.RunSum(
                    x,
                    count,
                    width,
                    statistic == MathBlockWindowAccurateStatistic.Mean,
                    fill,
                    values,
                    valid);
                break;
            default:
                MathBlockWindowAccurate.RunVariance(
                    x,
                    count,
                    width,
                    statistic is MathBlockWindowAccurateStatistic.SampleVariance
                        or MathBlockWindowAccurateStatistic.SampleStandardDeviation,
                    statistic is MathBlockWindowAccurateStatistic.PopulationStandardDeviation
                        or MathBlockWindowAccurateStatistic.SampleStandardDeviation,
                    fill,
                    values,
                    valid);
                break;
        }
    }
}
