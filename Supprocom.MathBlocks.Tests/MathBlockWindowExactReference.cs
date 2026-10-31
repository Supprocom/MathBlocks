using System.Numerics;

namespace Supprocom.MathBlocks.Tests;

// Exact window sums and variances of a double series. Every finite double is m * 2^e with integer m, so scaling the
// whole series by 2^scale (scale = the largest -e) makes every value an integer, and integer prefix sums give exact
// window sums. Errors of computed doubles are measured exactly against these and only then converted to double.
internal sealed class MathBlockWindowExactReference
{
    private readonly BigInteger[] sum;
    private readonly BigInteger[] absoluteSum;
    private readonly BigInteger[] shiftedSum;
    private readonly BigInteger[] shiftedAbsoluteSum;
    private readonly BigInteger[] shiftedSquareSum;

    public MathBlockWindowExactReference(double[] x)
    {
        Count = x.Length;
        Scale = 0;
        foreach (var value in x)
        {
            if (value == 0d)
                continue;
            Decompose(value, out _, out var exponent);
            Scale = Math.Max(Scale, -exponent);
        }
        var scaled = new BigInteger[x.Length];
        for (var index = 0; index < x.Length; index++)
            scaled[index] = ToScaledInteger(x[index], Scale);
        sum = new BigInteger[x.Length + 1];
        absoluteSum = new BigInteger[x.Length + 1];
        shiftedSum = new BigInteger[x.Length + 1];
        shiftedAbsoluteSum = new BigInteger[x.Length + 1];
        shiftedSquareSum = new BigInteger[x.Length + 1];
        var shift = x.Length > 0 ? scaled[0] : BigInteger.Zero;
        for (var index = 0; index < x.Length; index++)
        {
            var d = scaled[index] - shift;
            sum[index + 1] = sum[index] + scaled[index];
            absoluteSum[index + 1] = absoluteSum[index] + BigInteger.Abs(scaled[index]);
            shiftedSum[index + 1] = shiftedSum[index] + d;
            shiftedAbsoluteSum[index + 1] = shiftedAbsoluteSum[index] + BigInteger.Abs(d);
            shiftedSquareSum[index + 1] = shiftedSquareSum[index] + d * d;
        }
    }

    public int Count { get; }

    // The series times 2^Scale is an integer series.
    public int Scale { get; }

    public static double Unit => Math.ScaleB(1d, -53);

    public static double Gamma(double k) => k * Unit / (1d - k * Unit);

    // Row t's window is rows t - width + 1 .. t.
    public double Sum(int row, int width) => ToDouble(WindowSum(sum, row, width), BigInteger.One, Scale);

    // Sum over i <= row of |x_i|.
    public double AbsoluteHistory(int row) => ToDouble(absoluteSum[row + 1], BigInteger.One, Scale);

    // Sum over i <= row of |x_i - x_0| and of (x_i - x_0)^2.
    public double ShiftedAbsoluteHistory(int row) => ToDouble(shiftedAbsoluteSum[row + 1], BigInteger.One, Scale);

    public double ShiftedSquareHistory(int row) => ToDouble(shiftedSquareSum[row + 1], BigInteger.One, 2 * Scale);

    // |S1| = |sum over the window of x_i - x_0|.
    public double ShiftedWindowAbsoluteSum(int row, int width) =>
        ToDouble(BigInteger.Abs(WindowSum(shiftedSum, row, width)), BigInteger.One, Scale);

    // (mean - x_0)^2 for the window.
    public double ShiftedMeanSquare(int row, int width)
    {
        var s1 = WindowSum(shiftedSum, row, width);
        return ToDouble(s1 * s1, (BigInteger)width * width, 2 * Scale);
    }

    public double SumError(double computed, int row, int width) =>
        AbsoluteError(computed, WindowSum(sum, row, width), BigInteger.One, Scale);

    public double MeanError(double computed, int row, int width) =>
        AbsoluteError(computed, WindowSum(sum, row, width), width, Scale);

    // The window's variance is (w S2 - S1^2) / (w q) / 2^(2 Scale), with q = w or w - 1.
    public double Variance(int row, int width, bool sample) =>
        ToDouble(VarianceNumerator(row, width), VarianceDenominator(width, sample), 2 * Scale);

    public double VarianceError(double computed, int row, int width, bool sample) =>
        AbsoluteError(computed, VarianceNumerator(row, width), VarianceDenominator(width, sample), 2 * Scale);

    public bool VarianceIsZero(int row, int width) => VarianceNumerator(row, width).IsZero;

    // |computed - sqrt(v)|, from the exact square: |c - sqrt(v)| = |c^2 - v| / (c + sqrt(v)), and the denominator
    // is evaluated in double from c and sqrt(v), each correct to about 1e-16 relative.
    public double StandardDeviationError(double computed, int row, int width, bool sample)
    {
        var numerator = VarianceNumerator(row, width);
        var denominator = VarianceDenominator(width, sample);
        Decompose(computed, out var mantissa, out var exponent);
        // computed^2 - v = mantissa^2 2^(2 exponent) - numerator / (denominator 2^(2 Scale)).
        var squareExponent = 2 * exponent + 2 * Scale;
        BigInteger difference;
        BigInteger scaleDenominator;
        int binaryScale;
        if (squareExponent >= 0)
        {
            difference = (mantissa * mantissa << squareExponent) * denominator - numerator;
            scaleDenominator = denominator;
            binaryScale = 2 * Scale;
        }
        else
        {
            difference = mantissa * mantissa * denominator - (numerator << -squareExponent);
            scaleDenominator = denominator;
            binaryScale = -2 * exponent;
        }
        var squareError = ToDouble(BigInteger.Abs(difference), scaleDenominator, binaryScale);
        var root = Math.Sqrt(ToDouble(numerator, denominator, 2 * Scale));
        var rootSum = computed + root;
        return rootSum == 0d ? 0d : squareError / rootSum;
    }

    // value = numerator / (denominator 2^binaryScale), converted with about 60 significant bits before rounding.
    public static double ToDouble(BigInteger numerator, BigInteger denominator, int binaryScale)
    {
        if (numerator.IsZero)
            return 0d;
        var negative = numerator.Sign < 0;
        numerator = BigInteger.Abs(numerator);
        var shift = 64 - (int)(numerator.GetBitLength() - denominator.GetBitLength());
        var quotient = shift >= 0 ? (numerator << shift) / denominator : numerator / (denominator << -shift);
        var result = Math.ScaleB((double)quotient, -shift - binaryScale);
        return negative ? -result : result;
    }

    public static void Decompose(double value, out BigInteger mantissa, out int exponent)
    {
        var bits = BitConverter.DoubleToInt64Bits(value);
        var negative = bits < 0;
        var biased = (int)((bits >> 52) & 0x7FF);
        var fraction = bits & 0xF_FFFF_FFFF_FFFFL;
        if (biased == 0)
        {
            exponent = -1074;
        }
        else
        {
            fraction |= 1L << 52;
            exponent = biased - 1075;
        }
        while (fraction != 0 && (fraction & 1) == 0)
        {
            fraction >>= 1;
            exponent++;
        }
        mantissa = negative ? -(BigInteger)fraction : fraction;
    }

    private static BigInteger ToScaledInteger(double value, int scale)
    {
        if (value == 0d)
            return BigInteger.Zero;
        Decompose(value, out var mantissa, out var exponent);
        return mantissa << (exponent + scale);
    }

    // |computed - numerator / (denominator 2^binaryScale)| without rounding until the final conversion.
    private static double AbsoluteError(double computed, BigInteger numerator, BigInteger denominator, int binaryScale)
    {
        Decompose(computed, out var mantissa, out var exponent);
        var total = exponent + binaryScale;
        BigInteger difference;
        int scale;
        if (total >= 0)
        {
            difference = (mantissa << total) * denominator - numerator;
            scale = binaryScale;
        }
        else
        {
            difference = mantissa * denominator - (numerator << -total);
            scale = -exponent;
        }
        return ToDouble(BigInteger.Abs(difference), denominator, scale);
    }

    private static BigInteger WindowSum(BigInteger[] prefix, int row, int width) => prefix[row + 1] - prefix[row + 1 - width];

    private BigInteger VarianceNumerator(int row, int width)
    {
        var s1 = WindowSum(shiftedSum, row, width);
        var s2 = WindowSum(shiftedSquareSum, row, width);
        return width * s2 - s1 * s1;
    }

    private static BigInteger VarianceDenominator(int width, bool sample) => (BigInteger)width * (sample ? width - 1 : width);
}
