namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Generates the value classes of the proof matrix from a seed, so every run sees the same inputs.</summary>
internal static class ProofData
{
    /// <summary>The seven base classes, in the order that the Mixed class cycles through them.</summary>
    internal static readonly ProofClass[] BaseClasses =
    [
        ProofClass.Typical, ProofClass.Counts, ProofClass.Extreme, ProofClass.NearOverflow, ProofClass.Subnormal, ProofClass.Invalid, ProofClass.DomainEdge
    ];

    /// <summary>The index of the Invalid class in <see cref="BaseClasses"/>.</summary>
    internal const int InvalidIndex = 5;

    // Signed zeros, divisors and radicands on the domain edges, a negative radicand, and the largest and smallest finite magnitudes.
    private static readonly double[] Edges =
    [
        0d, -0d, 1d, -1d, 4d, -4d, 2.5d, -2.5d, 1e-300d, -1e-300d, double.MaxValue, -double.MaxValue, double.Epsilon
    ];

    /// <summary>
    /// Generates <paramref name="count"/> values of a class for one operand. With <paramref name="nonFinite"/> the Invalid class holds NaN and both infinities;
    /// without it (a vector never holds them) the Invalid class holds typical values and the caller marks rows unavailable instead.
    /// </summary>
    internal static double[] Series(ProofClass kind, int count, int seed, int operand, bool nonFinite)
    {
        var random = new Random(seed);
        var values = new double[count];
        for (var row = 0; row < count; row++)
        {
            var source = kind == ProofClass.Mixed ? BaseClasses[row % BaseClasses.Length] : kind;
            values[row] = Make(source, row, operand, random, nonFinite);
        }

        return values;
    }

    private static double Make(ProofClass kind, int row, int operand, Random random, bool nonFinite) =>
        kind switch
        {
            ProofClass.Typical => Market(random),
            ProofClass.Counts => Math.Floor(random.NextDouble() * 10_001d),
            ProofClass.Extreme => Extreme(random),
            ProofClass.NearOverflow => NearOverflow(row, operand, random),
            ProofClass.Subnormal => Subnormal(random),
            ProofClass.Invalid => nonFinite ? NonFinite(row, operand, random) : Market(random),
            ProofClass.DomainEdge => Edges[(operand == 0 ? row : row / Edges.Length) % Edges.Length],
            ProofClass.AllFalse => row % 2 == 0 ? 0d : -0d,
            _ => throw new ArgumentOutOfRangeException(nameof(kind), kind, "The class has no per-row generator.")
        };

    // A market value between 1e1 and 1e5, with a fraction.
    private static double Market(Random random) => Math.Pow(10d, 1d + 4d * random.NextDouble());

    // A magnitude between 1e250 and 1e300 or between 1e-300 and 1e-250, with a random sign.
    private static double Extreme(Random random)
    {
        var exponent = 250d + 50d * random.NextDouble();
        var sign = random.Next(2) == 0 ? 1d : -1d;
        return sign * Math.Pow(10d, random.Next(2) == 0 ? exponent : -exponent);
    }

    // Operand 0 is always large. Operand 1 is large with the same sign (a sum and a product overflow), large with the opposite sign (a difference overflows),
    // or, in every fourth row, a small divisor (a quotient overflows).
    private static double NearOverflow(int row, int operand, Random random)
    {
        var big = (0.9d + 0.8d * random.NextDouble()) * 1e308d;
        var sign = (row & 1) == 0 ? 1d : -1d;
        if (operand == 0)
            return sign * big;
        if ((row & 3) == 3)
            return sign * (1e-5d + 1e-3d * random.NextDouble());
        return (((row >> 1) & 1) == 0 ? sign : -sign) * big;
    }

    // A positive or negative value whose exponent field is zero.
    private static double Subnormal(Random random)
    {
        var bits = 1L + random.NextInt64((1L << 52) - 1L);
        var sign = random.Next(2) == 0 ? 0L : long.MinValue;
        return BitConverter.Int64BitsToDouble(sign | bits);
    }

    // Three of every four rows carry NaN or an infinity in this operand; the phase differs between the operands, so some rows carry it in both.
    private static double NonFinite(int row, int operand, Random random) =>
        (operand == 0 ? row % 4 : row / 4 % 4) switch
        {
            0 => double.NaN,
            1 => double.PositiveInfinity,
            2 => double.NegativeInfinity,
            _ => Market(random)
        };
}
