namespace Supprocom.MathBlocks;

// The window-prefix.* forms: window statistics from prefix sums, O(n) for any width. The prefix pass runs once per
// series in index order, so a batch shares it across widths; each width then reads two prefixes per row.
//
// Prefix sums are double-double, kept as Sum2 does (Ogita, Rump and Oishi, "Accurate sum and dot product", SIAM J.
// Sci. Comput. 26(6), 2005): Hi[t] is the recursive sum of the high parts, each step an error-free TwoSum (Knuth,
// TAOCP vol. 2, 4.2.2; Moller 1965), and Lo[t] the recursive sum of the TwoSum errors and the inputs' low parts.
// Hi[t] + Lo[t] is the prefix through row t; the prefix before row 0 is 0.
//
// A window value is the double-double difference P[t] - P[t - w]: TwoSum of the high parts, plus the difference of
// the low parts. The sum rounds it once to double; the mean divides that sum by w.
//
// The variance forms use prefixes of d = x - x[0] and d^2. d is the exact double-double TwoSum(x, -x[0]) and d^2 is
// formed with Dekker's error-free product (Dekker 1971), whose split needs no FMA. Per window, S1 = sum d and
// S2 = sum d^2 as double-doubles, and M = S2 - S1^2 / w is evaluated in double-double and rounded once. The shift by
// x[0] and the double-double evaluation counter the cancellation of the one-pass formula (Chan, Golub and LeVeque,
// "Algorithms for computing the sample variance", 1983). Then the population variance is M / w, the sample variance
// M / (w - 1) and the standard deviations their square roots, by MathBlockPrimitives.Sqrt as in the statistics
// sources (Newton steps, not correctly rounded; its last step is within 3u/2 + O(u^2) of the exact root). A window whose values all compare equal has variance
// exactly 0: the prefix differences carry rounding from earlier rows and don't cancel to 0 on their own, so a count
// of value changes identifies those windows. M below 0, which the rounding of the prefixes can give for a window
// whose variance is tiny next to the earlier rows, is set to 0.
//
// A row is computed when its result is finite. A prefix that overflows makes the later rows non-finite, so they hold
// the fill. The sample forms need w >= 2.
//
// Error bounds (u = 2^-53, gamma(k) = k u / (1 - k u), t the row, X_t = sum_{i <= t} |x_i|):
// - sum: |s^ - s| <= u |s| + gamma(2t)^2 X_t.
// - mean: |m^ - m| <= (1 + u) B_sum / w + u |m|.
// - variance, v the exact window variance (population, or sample with w - 1), m its mean, c = x[0],
//   kappa = 1 + (m - c)^2 / v_population, D_t = sum_{i <= t} |d_i|, Q_t = sum_{i <= t} d_i^2, H(Y) = gamma(2t + 6)^2 Y:
//   |v^ - v| <= 2u v + 27 u^2 kappa v + h_t, with h_t = (1 + 3u) [H(Q_t) + (2 |S1| + H(D_t)) H(D_t) / w] / q,
//   q = w for the population and w - 1 for the sample variance.
//   The constant 27 sums the relative errors of the window terms: 6u^2 for each d^2, u^2 and 2u^2 from the
//   differences of S2 and S1, 6u^2 for S1^2, 4u^2 for the division by w, 3u^2 for the double-double subtraction
//   (Joldes, Muller and Popescu, ACM TOMS 44(2), 2017, Algorithm 6) and 4u^2 for the two roundings, with kappa >= 1.
//   h_t bounds the rounding of the prefix sums, which depends on every row up to t, not only on the window.
// - standard deviation: with B the variance bound,
//   |sigma^ - sigma| <= min(B / (sqrt(max(v - B, 0)) + sqrt(v)), sqrt(B)) + (3u/2 + 4u^2) sqrt(v + B).
//
// The code is plain loops over arrays with no allocation inside a loop, so a per-thread CUDA function can mirror it.
// Every operation is a single IEEE operation in a fixed order; nothing relies on FMA.
internal static class MathBlockWindowPrefix
{
    // 2^27 + 1, Dekker's (Veltkamp's) splitting constant for binary64.
    private const double Splitter = 134_217_729d;

    internal static SumPrefix PrepareSum(ReadOnlySpan<double> x)
    {
        var count = x.Length;
        var hi = new double[count];
        var lo = new double[count];
        var high = 0d;
        var low = 0d;
        for (var row = 0; row < count; row++)
        {
            TwoSum(high, x[row], out high, out var error);
            low += error;
            hi[row] = high;
            lo[row] = low;
        }
        return new SumPrefix(hi, lo);
    }

    internal static VariancePrefix PrepareVariance(ReadOnlySpan<double> x)
    {
        var count = x.Length;
        var firstHi = new double[count];
        var firstLo = new double[count];
        var secondHi = new double[count];
        var secondLo = new double[count];
        var changes = new int[count];
        var shift = x[0];
        var high1 = 0d;
        var low1 = 0d;
        var high2 = 0d;
        var low2 = 0d;
        var changeCount = 0;
        for (var row = 0; row < count; row++)
        {
            TwoSum(x[row], -shift, out var dh, out var dl);
            Square(dh, dl, out var sh, out var sl);
            TwoSum(high1, dh, out high1, out var error1);
            low1 += error1 + dl;
            TwoSum(high2, sh, out high2, out var error2);
            low2 += error2 + sl;
            if (row > 0 && x[row] != x[row - 1])
                changeCount++;
            firstHi[row] = high1;
            firstLo[row] = low1;
            secondHi[row] = high2;
            secondLo[row] = low2;
            changes[row] = changeCount;
        }
        return new VariancePrefix(firstHi, firstLo, secondHi, secondLo, changes);
    }

    internal static void RunSum(
        SumPrefix prefix,
        int count,
        int width,
        bool mean,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        for (var row = 0; row < count; row++)
        {
            if (row < width - 1)
            {
                Store(values, valid, row, fill, 0d, false);
                continue;
            }
            Difference(prefix.Hi, prefix.Lo, row, width, out var high, out var low);
            var result = high + low;
            if (mean)
                result /= width;
            Store(values, valid, row, fill, result, double.IsFinite(result));
        }
    }

    internal static void RunVariance(
        VariancePrefix prefix,
        int count,
        int width,
        bool sample,
        bool deviation,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var divisor = sample ? width - 1d : width;
        for (var row = 0; row < count; row++)
        {
            if (row < width - 1)
            {
                Store(values, valid, row, fill, 0d, false);
                continue;
            }
            double moment;
            if (prefix.Changes[row] - prefix.Changes[row - width + 1] == 0)
            {
                moment = 0d;
            }
            else
            {
                Difference(prefix.FirstHi, prefix.FirstLo, row, width, out var s1h, out var s1l);
                TwoSum(s1h, s1l, out s1h, out s1l);
                Difference(prefix.SecondHi, prefix.SecondLo, row, width, out var s2h, out var s2l);
                TwoSum(s2h, s2l, out s2h, out s2l);
                Square(s1h, s1l, out var qh, out var ql);
                DivideByInteger(qh, ql, width, out var rh, out var rl);
                moment = SubtractRounded(s2h, s2l, rh, rl);
                if (moment <= 0d)
                    moment = 0d;
            }
            var result = moment / divisor;
            if (deviation)
                result = Math.Sqrt(result);
            Store(values, valid, row, fill, result, double.IsFinite(result));
        }
    }

    // Knuth's TwoSum: s = fl(a + b) and s + e = a + b exactly, for any finite a and b whose sum doesn't overflow.
    internal static void TwoSum(double a, double b, out double s, out double e)
    {
        s = a + b;
        var bVirtual = s - a;
        var aVirtual = s - bVirtual;
        e = (a - aVirtual) + (b - bVirtual);
    }

    // Dekker's FastTwoSum: exact when |a| >= |b| (or a = 0).
    private static void FastTwoSum(double a, double b, out double s, out double e)
    {
        s = a + b;
        e = b - (s - a);
    }

    private static void Split(double a, out double high, out double low)
    {
        var c = Splitter * a;
        high = c - (c - a);
        low = a - high;
    }

    // Dekker's product: p = fl(a b) and p + e = a b exactly, barring overflow and underflow.
    private static void TwoProduct(double a, double b, out double p, out double e)
    {
        p = a * b;
        Split(a, out var ah, out var al);
        Split(b, out var bh, out var bl);
        e = ((ah * bh - p) + ah * bl + al * bh) + al * bl;
    }

    // (h + l)^2 for |l| <= u |h|: h^2 exactly, plus the rounded cross term 2 h l. The omitted l^2 is below u^2 h^2.
    private static void Square(double h, double l, out double sh, out double sl)
    {
        TwoProduct(h, h, out var p, out var e);
        var low = e + (h + h) * l;
        FastTwoSum(p, low, out sh, out sl);
    }

    // (h + l) / w for an integer w >= 1: the quotient's high part, then the exact remainder h - q w plus l, over w.
    private static void DivideByInteger(double h, double l, int width, out double qh, out double ql)
    {
        var divisor = (double)width;
        var high = h / divisor;
        TwoProduct(high, divisor, out var p, out var e);
        var low = ((h - p) - e + l) / divisor;
        FastTwoSum(high, low, out qh, out ql);
    }

    // (ah + al) - (bh + bl) by the accurate double-double addition (Joldes, Muller and Popescu 2017, Algorithm 6),
    // rounded once to double: the normalized high part is the double nearest the double-double result.
    private static double SubtractRounded(double ah, double al, double bh, double bl)
    {
        TwoSum(ah, -bh, out var sh, out var sl);
        TwoSum(al, -bl, out var th, out var tl);
        var c = sl + th;
        FastTwoSum(sh, c, out var vh, out var vl);
        var w = tl + vl;
        FastTwoSum(vh, w, out var zh, out _);
        return zh;
    }

    // P[row] - P[row - width] as an unnormalized double-double: the exact difference of the high parts, with the
    // difference of the low parts added to its error term.
    private static void Difference(double[] hi, double[] lo, int row, int width, out double high, out double low)
    {
        var start = row - width;
        var startHi = start >= 0 ? hi[start] : 0d;
        var startLo = start >= 0 ? lo[start] : 0d;
        TwoSum(hi[row], -startHi, out high, out var error);
        low = error + (lo[row] - startLo);
    }

    private static void Store(double[]? values, bool[]? valid, int row, double fill, double value, bool computed)
    {
        if (values is not null)
            values[row] = computed ? value : fill;
        if (valid is not null)
            valid[row] = computed;
    }

    internal sealed class SumPrefix(double[] hi, double[] lo)
    {
        internal double[] Hi { get; } = hi;

        internal double[] Lo { get; } = lo;
    }

    internal sealed class VariancePrefix(
        double[] firstHi,
        double[] firstLo,
        double[] secondHi,
        double[] secondLo,
        int[] changes)
    {
        internal double[] FirstHi { get; } = firstHi;

        internal double[] FirstLo { get; } = firstLo;

        internal double[] SecondHi { get; } = secondHi;

        internal double[] SecondLo { get; } = secondLo;

        // Changes[t] counts the rows i in 1 .. t with x[i] != x[i - 1].
        internal int[] Changes { get; } = changes;
    }
}
