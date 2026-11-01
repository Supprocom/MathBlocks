namespace Supprocom.MathBlocks;

// An exact sum of doubles that supports adding and subtracting terms: the small superaccumulator of Neal, "Fast exact
// summation using small and large superaccumulators", arXiv:1505.05571, 2015. Chunk i holds a signed 64-bit integer
// whose value counts in units of 2^(BaseExponent + 32 i). A term's 53-bit integer significand is added to the (at
// most three) chunks under its bits, in pieces below 2^33, so no addition rounds and no carry is propagated until
// a value is read. The 31 spare bits per chunk absorb 2^27 additions before an in-place carry pass is needed.
//
// The range covers every double and every exact square of one (2^-2148 .. 2^2048), the significand bits of the
// smallest terms down to 2^-2200, and room for 2^31 terms, so sums of x and of x^2 use the same layout. The
// accumulated value is exact and does not depend on the order or history of the additions; only its chunk
// representation does, and every read first carries the chunks into the canonical form, so a read depends only on
// the value.
//
// The code is plain loops over a fixed array with no allocation after construction, so a per-thread CUDA struct can
// mirror it.
internal sealed class MathBlockExactAccumulator
{
    internal const int ChunkCount = 141;

    // Bit 0 of chunk 0 has the weight 2^BaseExponent. Every nonzero term is at least 2^-2148 in magnitude (a square
    // of a multiple of 2^-1074, or its error term), so the lowest bit of its 53-bit significand weighs at least
    // 2^-2200, and 2^-2208 is the chunk boundary below that.
    internal const int BaseExponent = -2208;

    private const long ChunkMask = 0xFFFF_FFFFL;
    private const int CarryInterval = 1 << 27;

    // Splits the scaled square into the range where Dekker's product is exact (no overflow in the split, no underflow
    // in the error term): |x| below 2^-400 or above 2^400 is scaled by 2^600 or 2^-600 first.
    private static readonly double SquareScaleUp = PowerOfTwo(600);
    private static readonly double SquareScaleDown = PowerOfTwo(-600);
    private static readonly double SquareSmall = PowerOfTwo(-400);
    private static readonly double SquareLarge = PowerOfTwo(400);

    // 2^27 + 1, Dekker's (Veltkamp's) splitting constant for binary64.
    private const double Splitter = 134_217_729d;

    private readonly long[] chunks = new long[ChunkCount];
    private readonly long[] scratch = new long[ChunkCount];
    private int lowest = ChunkCount;
    private int highest = -1;
    private int operations;

    // Adds (or subtracts) value exactly.
    internal void Add(double value, bool subtract) => Add(value, 0, subtract);

    // Adds (or subtracts) value^2 exactly, as the error-free product pair p + e = value^2 (Dekker 1971, no FMA),
    // computed on value scaled by a power of two when needed and added back at that scale.
    internal void AddSquare(double value, bool subtract)
    {
        if (value == 0d)
            return;
        var magnitude = Math.Abs(value);
        var scaled = value;
        var shift = 0;
        if (magnitude < SquareSmall)
        {
            scaled = value * SquareScaleUp;
            shift = -1200;
        }
        else if (magnitude > SquareLarge)
        {
            scaled = value * SquareScaleDown;
            shift = 1200;
        }
        TwoProduct(scaled, scaled, out var product, out var error);
        Add(product, shift, subtract);
        Add(error, shift, subtract);
    }

    // The window value rounded to the nearest double, ties to even, and the rounded remainder:
    // high = RN(S) and low = RN(S - high). An overflow gives an infinite high and a zero low.
    internal void ReadDoubleDouble(out double high, out double low) => ReadDoubleDouble(out high, out low, out _);

    // As above; zero tells whether the exact value is 0, which a high of 0 alone doesn't (S may round to 0).
    internal void ReadDoubleDouble(out double high, out double low, out bool zero)
    {
        zero = true;
        if (highest < 0)
        {
            high = 0d;
            low = 0d;
            return;
        }
        var top = LoadMagnitude(out var negative);
        for (var index = lowest; index <= top; index++)
            zero &= scratch[index] == 0L;
        high = RoundMagnitude(scratch, lowest, top, false);
        low = 0d;
        if (!double.IsFinite(high))
        {
            high = negative ? -high : high;
            return;
        }
        _ = AddTo(scratch, high, 0, true);
        var restNegative = Carry(scratch, lowest, top) < 0L;
        if (restNegative)
        {
            Negate(scratch, lowest, top + 1);
            _ = Carry(scratch, lowest, top + 1);
        }
        low = RoundMagnitude(scratch, lowest, top + 1, false);
        if (restNegative)
            low = -low;
        if (negative)
        {
            high = -high;
            low = -low;
        }
    }

    // RN(S / divisor) for an integer divisor >= 1: the canonical chunks divided top-down by long division, with a
    // nonzero remainder as the sticky bit of the rounding. The division continues four chunks below the leading
    // chunk (at least 96 bits), so the quotient's significand and rounding bit are digits, not remainder; the chunks
    // below lowest that it writes are cleared again afterwards.
    internal double ReadQuotient(int divisor)
    {
        if (highest < 0)
            return 0d;
        var top = LoadMagnitude(out var negative);
        var leading = top;
        while (leading > lowest && scratch[leading] == 0L)
            leading--;
        var start = leading - 4 < lowest ? leading - 4 : lowest;
        if (start < 0)
            start = 0;
        var remainder = 0L;
        for (var index = top + 1; index >= start; index--)
        {
            var current = (remainder << 32) | scratch[index];
            scratch[index] = current / divisor;
            remainder = current % divisor;
        }
        var result = RoundMagnitude(scratch, start, top + 1, remainder != 0L);
        for (var index = start; index < lowest; index++)
            scratch[index] = 0L;
        return negative ? -result : result;
    }

    private void Add(double value, int shift, bool subtract)
    {
        if (value == 0d)
            return;
        var index = AddTo(chunks, value, shift, subtract);
        if (index < lowest)
            lowest = index;
        if (index + 2 > highest)
            highest = index + 2;
        if (++operations == CarryInterval)
        {
            _ = Carry(chunks, lowest, highest);
            highest += 1;
            operations = 0;
        }
    }

    // Adds value * 2^shift to the chunks and returns the lowest chunk index it touched.
    private static int AddTo(long[] target, double value, int shift, bool subtract)
    {
        var bits = BitConverter.DoubleToInt64Bits(value);
        var negative = (bits < 0L) != subtract;
        var biased = (int)((bits >> 52) & 0x7FFL);
        var significand = bits & 0xF_FFFF_FFFF_FFFFL;
        int exponent;
        if (biased == 0)
        {
            exponent = -1074;
        }
        else
        {
            significand |= 1L << 52;
            exponent = biased - 1075;
        }
        var position = exponent + shift - BaseExponent;
        var index = position >> 5;
        var offset = position & 31;
        var lowPart = (significand & ChunkMask) << offset;
        var highPart = (significand >> 32) << offset;
        var first = lowPart & ChunkMask;
        var second = (lowPart >> 32) + (highPart & ChunkMask);
        var third = highPart >> 32;
        if (negative)
        {
            target[index] -= first;
            target[index + 1] -= second;
            target[index + 2] -= third;
        }
        else
        {
            target[index] += first;
            target[index + 1] += second;
            target[index + 2] += third;
        }
        return index;
    }

    // Copies the chunks into scratch in canonical form with the magnitude of the value: chunks lowest .. top + 1
    // are in [0, 2^32). Returns top; negative tells the sign.
    private int LoadMagnitude(out bool negative)
    {
        for (var index = lowest; index <= highest; index++)
            scratch[index] = chunks[index];
        // Rounding reads up to two chunks above the leading one, and the remainder pass carries one chunk higher.
        for (var index = highest + 1; index <= highest + 4; index++)
            scratch[index] = 0L;
        negative = Carry(scratch, lowest, highest) < 0L;
        if (negative)
        {
            Negate(scratch, lowest, highest + 1);
            _ = Carry(scratch, lowest, highest + 1);
        }
        return highest + 1;
    }

    // Carries chunks first .. last into [0, 2^32) and adds the final carry to chunk last + 1, which then holds the
    // sign: the value is negative exactly when it is negative. Needs |chunk| below 2^62.
    private static long Carry(long[] target, int first, int last)
    {
        var carry = 0L;
        for (var index = first; index <= last; index++)
        {
            var current = target[index] + carry;
            carry = current >> 32;
            target[index] = current & ChunkMask;
        }
        target[last + 1] += carry;
        return target[last + 1];
    }

    private static void Negate(long[] target, int first, int last)
    {
        for (var index = first; index <= last; index++)
            target[index] = -target[index];
    }

    // Rounds a nonnegative value in canonical chunks (lowest .. top in [0, 2^32), zero above top) to the nearest
    // double, ties to even, with sticky an extra nonzero part below every chunk bit. Builds the result's bits
    // directly, so no step of the conversion rounds.
    private static double RoundMagnitude(long[] value, int lowest, int top, bool sticky)
    {
        var chunk = top;
        while (chunk >= lowest && value[chunk] == 0L)
            chunk--;
        if (chunk < lowest)
            return 0d;
        var bit = 31;
        while (((value[chunk] >> bit) & 1L) == 0L)
            bit--;
        var most = BaseExponent + 32 * chunk + bit;
        var least = most - 52 < -1074 ? -1074 : most - 52;
        var count = most - least + 1;
        var significand = count > 0 ? Bits(value, least, count) : 0L;
        var round = Bits(value, least - 1, 1) != 0L;
        var below = sticky || AnyBitBelow(value, lowest, least - 1);
        if (round && (below || (significand & 1L) != 0L))
            significand++;
        if (significand == 1L << 53)
        {
            significand = 1L << 52;
            least++;
        }
        if (significand >= 1L << 52)
        {
            var biased = least + 1075;
            if (biased >= 2047)
                return double.PositiveInfinity;
            return BitConverter.Int64BitsToDouble(((long)biased << 52) | (significand - (1L << 52)));
        }
        return BitConverter.Int64BitsToDouble(significand);
    }

    // count (1 .. 53) bits of the value starting at the bit with weight 2^position.
    private static long Bits(long[] value, int position, int count)
    {
        var relative = position - BaseExponent;
        var index = relative >> 5;
        var offset = relative & 31;
        var word = (ulong)value[index] | ((ulong)value[index + 1] << 32);
        var result = word >> offset;
        if (offset != 0)
            result |= (ulong)value[index + 2] << (64 - offset);
        return (long)(result & ((1UL << count) - 1UL));
    }

    // Whether any bit with weight below 2^position is set.
    private static bool AnyBitBelow(long[] value, int lowest, int position)
    {
        var relative = position - BaseExponent;
        var index = relative >> 5;
        var offset = relative & 31;
        if ((value[index] & ((1L << offset) - 1L)) != 0L)
            return true;
        for (var chunk = lowest; chunk < index; chunk++)
            if (value[chunk] != 0L)
                return true;
        return false;
    }

    private static double PowerOfTwo(int exponent) => BitConverter.Int64BitsToDouble((long)(exponent + 1023) << 52);

    private static void TwoProduct(double a, double b, out double p, out double e)
    {
        p = a * b;
        Split(a, out var ah, out var al);
        Split(b, out var bh, out var bl);
        e = ((ah * bh - p) + ah * bl + al * bh) + al * bl;
    }

    private static void Split(double a, out double high, out double low)
    {
        var c = Splitter * a;
        high = c - (c - a);
        low = a - high;
    }
}
