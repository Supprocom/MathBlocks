namespace Supprocom.MathBlocks;

// Window sums, means, variances and standard deviations from exact sliding sums. Per series and width, one
// MathBlockExactAccumulator (Neal 2015) carries the exact window sum S1 = sum x and one the exact S2 = sum x^2:
// each row adds x[t] (and x[t]^2 as an exact Dekker product pair) and subtracts x[t - w] the same way. The sums are
// exact, so they don't drift and don't depend on rows before the window, and every rounding below acts on exact
// window values: a row's bits depend only on its window's values.
//
// - sum: RN(S1), the exact window sum correctly rounded (ties to even).
// - mean: RN(S1 / w), the exact window sum divided by w and correctly rounded, by exact long division.
// - variance: S1 and S2 rounded to double-doubles (h = RN(S), l = RN(S - h)), M = S2 - S1^2 / w evaluated in
//   double-double and rounded once, then M / w (population) or M / (w - 1) (sample).
// - standard deviation: the square root of that variance.
// A window whose values all compare equal has variance +0 exactly. The double-double steps don't cancel to 0 on
// their own (w x^2 needs up to 108 bits), so a sliding count of value changes identifies those windows. M at or below
// 0, possible only when kappa > 1 / (13 u^2), is set to 0.
//
// No shift is applied. With exact sums the only cancellation left is in S2 - S1^2 / w, which kappa below measures;
// a shift by an earlier row (such as x[0]) would make the bits depend on that row, and a shift by a window value
// would need exact products of the shift with S1.
//
// Rows are computed when the result is finite, so a window whose S2, S1^2 or sum overflows holds the fill. The
// sample forms need w >= 2.
//
// Guarantees (u = 2^-53; v the exact window variance, population or sample; m the exact window mean;
// kappa = 1 + m^2 / v_population; assuming S2 and S1^2 are 0 or within [2^-968, 2^1023], so no double-double step
// underflows or overflows):
// - sum and mean: correctly rounded.
// - variance: v = 0 gives +0; otherwise |v^ - v| <= 2u v + 18 u^2 kappa v. The u^2 kappa terms, relative to
//   S2 = w v_population kappa: 1 from rounding S2 to a double-double, 2 from S1 (squared), 6 for the double-double
//   square (Square), 4 for the division by w (DivideByInteger), total 13; then 3 u^2 v for the accurate
//   double-double subtraction (Joldes, Muller and Popescu, ACM TOMS 44(2), 2017, Algorithm 6) and u^2 v from the two
//   final roundings, 4 <= 4 kappa; 17, and 1 more for the O(u^3 kappa) products of these.
// - standard deviation, B the variance bound and a correctly rounded square root:
//   |sigma^ - sigma| <= min(B / (sqrt(max(v - B, 0)) + sqrt(v)), sqrt(B)) + u sqrt(v + B).
//   The square root is MathBlockPrimitives.Sqrt (as in the statistics sources). It is not correctly rounded today
//   (Newton steps, within 3u/2 + O(u^2)); until it is, the last term is (3u/2 + 4u^2) sqrt(v + B).
//
// The code is plain loops with no allocation inside a loop and no FMA, so a per-thread CUDA function can mirror it.
internal static class MathBlockWindowPrefix
{
    // 2^27 + 1, Dekker's (Veltkamp's) splitting constant for binary64.
    private const double Splitter = 134_217_729d;

    internal static void RunSum(
        ReadOnlySpan<double> x,
        int count,
        int width,
        bool mean,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var sum = new MathBlockExactAccumulator();
        for (var row = 0; row < count; row++)
        {
            sum.Add(x[row], false);
            if (row >= width)
                sum.Add(x[row - width], true);
            if (row < width - 1)
            {
                Store(values, valid, row, fill, 0d, false);
                continue;
            }
            double result;
            if (mean)
                result = sum.ReadQuotient(width);
            else
                sum.ReadDoubleDouble(out result, out _);
            Store(values, valid, row, fill, result, double.IsFinite(result));
        }
    }

    internal static void RunVariance(
        ReadOnlySpan<double> x,
        int count,
        int width,
        bool sample,
        bool deviation,
        double fill,
        double[]? values,
        bool[]? valid)
    {
        var first = new MathBlockExactAccumulator();
        var second = new MathBlockExactAccumulator();
        var divisor = sample ? width - 1d : width;
        // The number of rows i in the window, after its first row, with x[i] != x[i - 1].
        var changes = 0;
        for (var row = 0; row < count; row++)
        {
            first.Add(x[row], false);
            second.AddSquare(x[row], false);
            if (row > 0 && x[row] != x[row - 1])
                changes++;
            if (row >= width)
            {
                first.Add(x[row - width], true);
                second.AddSquare(x[row - width], true);
                if (row - width + 1 > 0 && x[row - width + 1] != x[row - width])
                    changes--;
            }
            if (row < width - 1)
            {
                Store(values, valid, row, fill, 0d, false);
                continue;
            }
            double moment;
            if (changes == 0)
            {
                moment = 0d;
            }
            else
            {
                first.ReadDoubleDouble(out var s1h, out var s1l);
                second.ReadDoubleDouble(out var s2h, out var s2l);
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
    private static void TwoSum(double a, double b, out double s, out double e)
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

    private static void Store(double[]? values, bool[]? valid, int row, double fill, double value, bool computed)
    {
        if (values is not null)
            values[row] = computed ? value : fill;
        if (valid is not null)
            valid[row] = computed;
    }
}
