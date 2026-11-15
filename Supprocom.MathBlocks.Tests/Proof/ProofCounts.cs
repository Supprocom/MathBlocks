using System.Globalization;

namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Builds the contiguity counts classes: all contiguous, a gap every few rows, series starts every few rows, and random gaps.</summary>
internal static class ProofCounts
{
    /// <summary>The number of counts classes of the timing tests: contiguous, gaps and series starts.</summary>
    internal const int TimingKinds = 3;

    /// <summary>The number of counts classes of the safety tests, which add random gaps.</summary>
    internal const int SafetyKinds = 4;

    private const double RandomGapShare = 0.05d;

    /// <summary>Gets the name of a counts class for the report.</summary>
    internal static string Name(int kind, int gapPeriod, int seriesPeriod) =>
        kind switch
        {
            0 => "contiguous",
            1 => string.Create(CultureInfo.InvariantCulture, $"gap-every-{gapPeriod}"),
            2 => string.Create(CultureInfo.InvariantCulture, $"series-start-every-{seriesPeriod}"),
            _ => "random-gaps"
        };

    /// <summary>
    /// Builds counts[t], the number of contiguous steps before row t: t when contiguous, t modulo the gap period, t modulo the series period, or a count that restarts at
    /// zero in about 5 percent of the rows. Row 0 always has the count 0.
    /// </summary>
    internal static double[] Build(int kind, int count, int gapPeriod, int seriesPeriod)
    {
        var counts = new double[count];
        var random = new Random(7);
        for (var row = 0; row < count; row++)
        {
            counts[row] = kind switch
            {
                0 => row,
                1 => row % gapPeriod,
                2 => row % seriesPeriod,
                _ => row == 0 || random.NextDouble() < RandomGapShare ? 0d : counts[row - 1] + 1d
            };
        }

        return counts;
    }
}
