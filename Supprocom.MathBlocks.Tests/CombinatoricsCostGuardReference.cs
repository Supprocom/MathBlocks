namespace Supprocom.MathBlocks.Tests;

/// <summary>Reference copies of the binomial-coefficient loop, without the early return, for the cost-guard tests.</summary>
internal static class CombinatoricsCostGuardReference
{
    /// <summary>The integers the grids are built from: small values, values around the guard at 600 and price-like values.</summary>
    public static readonly int[] Values =
    [
        0, 1, 2, 3, 5, 10, 40, 299, 300, 301, 598, 599, 600, 601, 602, 1198, 1199, 1200, 1201, 1202, 1500, 3000, 43000, 42950, 1_000, 2_000,
        5_000, 10_000, 20_000, 50_000, 100_000, 500_000, 1_000_000,
    ];

    /// <summary>Returns the binomial coefficient as the loop of the released 0.6.1 computed it, in int arithmetic.</summary>
    public static double Today(int n, int k)
    {
        if (k < 0 || k > n)
            return 0d;
        k = Math.Min(k, n - k);
        var result = 1d;
        for (var index = 1; index <= k; index++)
            result = result * (n - k + index) / index;
        return result;
    }

    /// <summary>Returns the ballot count as the 0.6.1 expression computed it, with the sum in int arithmetic.</summary>
    public static double TodayBallot(int leading, int trailing) =>
        (double)(leading - trailing) / (leading + trailing) * Today(leading + trailing, trailing);

    /// <summary>Returns the binomial coefficient with n in 64 bits and the loop unguarded, or null where the loop would run over 20000 steps.</summary>
    public static double? Wide(long n, int k)
    {
        if (k < 0 || k > n)
            return 0d;
        k = (int)Math.Min(k, n - k);
        if (k > 20_000)
            return null;
        var result = 1d;
        for (var index = 1; index <= k; index++)
            result = result * (double)(n - k + index) / index;
        return result;
    }

    /// <summary>Returns the ballot count with the sum in 64 bits and the loop unguarded, or null where the loop would be long.</summary>
    public static double? WideBallot(int leading, int trailing)
    {
        var total = (long)leading + trailing;
        return Wide(total, trailing) is { } coefficient ? (double)(leading - trailing) / (double)total * coefficient : null;
    }

    /// <summary>Returns every ordered pair of the values.</summary>
    public static (int First, int Second)[] Pairs(int[] values)
    {
        var pairs = new (int, int)[values.Length * values.Length];
        for (var first = 0; first < values.Length; first++)
        {
            for (var second = 0; second < values.Length; second++)
                pairs[first * values.Length + second] = (values[first], values[second]);
        }

        return pairs;
    }

    /// <summary>Returns whether a ballot-count row is in the operation's domain.</summary>
    public static bool InBallotDomain(int leading, int trailing) => leading > trailing && trailing >= 0;
}
