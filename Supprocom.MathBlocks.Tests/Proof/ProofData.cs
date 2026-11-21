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
    private static readonly float[] Edges =
    [
        0f, -0f, 1f, -1f, 4f, -4f, 2.5f, -2.5f, 1.03e-37f, -1.03e-37f, float.MaxValue, -float.MaxValue, float.Epsilon
    ];

    /// <summary>
    /// Generates <paramref name="count"/> values of a class for one operand. With <paramref name="nonFinite"/> the Invalid class holds NaN and both infinities;
    /// without it (a vector never holds them) the Invalid class holds typical values and the caller marks rows unavailable instead.
    /// </summary>
    internal static float[] Series(ProofClass kind, int count, int seed, int operand, bool nonFinite)
    {
        var random = new Random(seed);
        var values = new float[count];
        for (var row = 0; row < count; row++)
        {
            var source = kind == ProofClass.Mixed ? BaseClasses[row % BaseClasses.Length] : kind;
            values[row] = Make(source, row, operand, random, nonFinite);
        }

        return values;
    }

    private static float Make(ProofClass kind, int row, int operand, Random random, bool nonFinite) =>
        kind switch
        {
            ProofClass.Typical => Market(random),
            ProofClass.Counts => MathF.Floor(random.NextSingle() * 10_001f),
            ProofClass.Extreme => Extreme(random),
            ProofClass.NearOverflow => NearOverflow(row, operand, random),
            ProofClass.Subnormal => Subnormal(random),
            ProofClass.Invalid => nonFinite ? NonFinite(row, operand, random) : Market(random),
            ProofClass.DomainEdge => Edges[(operand == 0 ? row : row / Edges.Length) % Edges.Length],
            ProofClass.AllFalse => row % 2 == 0 ? 0f : -0f,
            _ => throw new ArgumentOutOfRangeException(nameof(kind), kind, "The class has no per-row generator.")
        };

    // A market value between 1e1 and 1e5, with a fraction.
    private static float Market(Random random) => MathF.Pow(10f, 1f + 4f * random.NextSingle());

    // A magnitude between 1e31 and 1e37 or between 1e-37 and 1e-31, with a random sign.
    private static float Extreme(Random random)
    {
        var exponent = 31f + 6f * random.NextSingle();
        var sign = random.Next(2) == 0 ? 1f : -1f;
        return sign * MathF.Pow(10f, random.Next(2) == 0 ? exponent : -exponent);
    }

    // Operand 0 is always large. Operand 1 is large with the same sign (a sum and a product overflow), large with the opposite sign (a difference overflows),
    // or, in every fourth row, a small divisor (a quotient overflows).
    private static float NearOverflow(int row, int operand, Random random)
    {
        var big = (0.9f + 0.8f * random.NextSingle()) * 1.9e38f;
        var sign = (row & 1) == 0 ? 1f : -1f;
        if (operand == 0)
            return sign * big;
        if ((row & 3) == 3)
            return sign * (1e-5f + 1e-3f * random.NextSingle());
        return (((row >> 1) & 1) == 0 ? sign : -sign) * big;
    }

    // A positive or negative value whose exponent field is zero.
    private static float Subnormal(Random random)
    {
        var bits = 1 + random.Next((1 << 23) - 1);
        var sign = random.Next(2) == 0 ? 0 : int.MinValue;
        return BitConverter.Int32BitsToSingle(sign | bits);
    }

    // Three of every four rows carry NaN or an infinity in this operand; the phase differs between the operands, so some rows carry it in both.
    private static float NonFinite(int row, int operand, Random random) =>
        (operand == 0 ? row % 4 : row / 4 % 4) switch
        {
            0 => float.NaN,
            1 => float.PositiveInfinity,
            2 => float.NegativeInfinity,
            _ => Market(random)
        };
}
