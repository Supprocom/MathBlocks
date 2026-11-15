namespace Supprocom.MathBlocks.Tests.Proof;

/// <summary>Builds the input sets of the proof matrix at a given size: the seven base classes, Mixed, the real market columns when they exist, and for sequences the all-false predicate.</summary>
internal static class ProofSets
{
    private const double UnavailableShare = 0.3d;

    private static readonly ProofClass[] Kinds =
    [
        ProofClass.Typical, ProofClass.Counts, ProofClass.Extreme, ProofClass.NearOverflow, ProofClass.Subnormal, ProofClass.Invalid, ProofClass.DomainEdge, ProofClass.Mixed
    ];

    /// <summary>Builds the operand pairs of the row functions: NaN and infinities appear in the Invalid class, in Mixed and nowhere else.</summary>
    internal static ProofSet[] ForRows(int count, bool includeReal)
    {
        var sets = new List<ProofSet>();
        for (var index = 0; index < Kinds.Length; index++)
        {
            var kind = Kinds[index];
            sets.Add(new ProofSet(kind.ToString(), ProofData.Series(kind, count, 100 + index, 0, true), ProofData.Series(kind, count, 200 + index, 1, true), [], []));
        }

        if (includeReal && ProofRealData.Get() is { } real)
            sets.Add(new ProofSet("Real", Tile(real.Close, count, 0), Tile(real.Volume, count, 1), [], []));
        return [.. sets];
    }

    /// <summary>
    /// Builds the series of the sequence operations. A vector never holds NaN or an infinity, so the Invalid class is the rows whose availability flag is false (30 percent of its
    /// rows, and 30 percent of the Invalid-class rows inside Mixed), with a zero value in them as a host's fill would be.
    /// </summary>
    internal static ProofSet[] ForSequences(int count, bool includeReal, bool includeAllFalse)
    {
        var sets = new List<ProofSet>();
        for (var index = 0; index < Kinds.Length; index++)
        {
            var kind = Kinds[index];
            var values = ProofData.Series(kind, count, 300 + index, 0, false);
            var flags = Availability(kind, count, 400 + index, values);
            sets.Add(new ProofSet(kind.ToString(), values, [], values, flags));
        }

        if (includeAllFalse)
            sets.Add(new ProofSet(nameof(ProofClass.AllFalse), ProofData.Series(ProofClass.Typical, count, 500, 0, false), [], ProofData.Series(ProofClass.AllFalse, count, 0, 0, false), AllTrue(count)));
        if (includeReal && ProofRealData.Get() is { } real)
            sets.Add(new ProofSet("Real", Tile(real.Close, count, 0), [], PriceChanged(real.Close, count), AllTrue(count)));
        return [.. sets];
    }

    private static bool[] AllTrue(int count)
    {
        var flags = new bool[count];
        Array.Fill(flags, true);
        return flags;
    }

    // The availability of each row; an unavailable row also gets the value zero.
    private static bool[] Availability(ProofClass kind, int count, int seed, double[] values)
    {
        var flags = AllTrue(count);
        if (kind != ProofClass.Invalid && kind != ProofClass.Mixed)
            return flags;
        var random = new Random(seed);
        for (var row = 0; row < count; row++)
        {
            var applies = kind == ProofClass.Invalid || row % ProofData.BaseClasses.Length == ProofData.InvalidIndex;
            if (applies && random.NextDouble() < UnavailableShare)
            {
                flags[row] = false;
                values[row] = 0d;
            }
        }

        return flags;
    }

    // One where the close price differs from the previous row's, zero where it does not.
    private static double[] PriceChanged(double[] close, int count)
    {
        var tiled = Tile(close, count, 0);
        var changed = new double[count];
        for (var row = 1; row < count; row++)
            changed[row] = tiled[row] != tiled[row - 1] ? 1d : 0d;
        return changed;
    }

    /// <summary>Repeats a source column to <paramref name="count"/> rows, starting <paramref name="shift"/> rows into it.</summary>
    internal static double[] Tile(double[] source, int count, int shift)
    {
        var tiled = new double[count];
        for (var row = 0; row < count; row++)
            tiled[row] = source[(row + shift) % source.Length];
        return tiled;
    }
}
