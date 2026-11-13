namespace Supprocom.MathBlocks.Cuda;

// The window.* forms and window-valid.* siblings run in one kernel that spreads rows across the grid. Opcode
// 2 * source + sibling, with source the index in the window source list (WindowMathBlocks), or 53 .. 58 for
// the window-accurate.* forms and window-accurate-valid.* siblings (sum, mean, population variance, sample variance,
// population and sample standard deviation); the source index selects the per-thread function and the scratch
// rule below, which mirrors mathblocks_window_scratch_count.
internal static class WindowCudaBlockCatalog
{
    // Each thread's scratch slice is planned so that every slice of the grid fits this budget.
    internal const long ScratchBudgetBytes = 256L * 1024 * 1024;
    internal const int MaximumGridX = 65_535;

    public static string KernelEntryPoint => "mathblocks_window";
    public static uint BlockSize => 128;

    internal static readonly MathBlockCudaFeature[] Features =
    [
        new("window.statistics.autocorrelation@1", MathBlockCudaFamily.Window, 0),
        new("window-valid.statistics.autocorrelation@1", MathBlockCudaFamily.Window, 1),
        new("window.statistics.central-moment@1", MathBlockCudaFamily.Window, 2),
        new("window-valid.statistics.central-moment@1", MathBlockCudaFamily.Window, 3),
        new("window.statistics.distance-correlation@1", MathBlockCudaFamily.Window, 4),
        new("window-valid.statistics.distance-correlation@1", MathBlockCudaFamily.Window, 5),
        new("window.statistics.interquartile-range@1", MathBlockCudaFamily.Window, 6),
        new("window-valid.statistics.interquartile-range@1", MathBlockCudaFamily.Window, 7),
        new("window.statistics.kendall-tau-b@1", MathBlockCudaFamily.Window, 8),
        new("window-valid.statistics.kendall-tau-b@1", MathBlockCudaFamily.Window, 9),
        new("window.statistics.linear-intercept@1", MathBlockCudaFamily.Window, 10),
        new("window-valid.statistics.linear-intercept@1", MathBlockCudaFamily.Window, 11),
        new("window.statistics.linear-r-squared@1", MathBlockCudaFamily.Window, 12),
        new("window-valid.statistics.linear-r-squared@1", MathBlockCudaFamily.Window, 13),
        new("window.statistics.linear-slope@1", MathBlockCudaFamily.Window, 14),
        new("window-valid.statistics.linear-slope@1", MathBlockCudaFamily.Window, 15),
        new("window.statistics.median-absolute-deviation@1", MathBlockCudaFamily.Window, 16),
        new("window-valid.statistics.median-absolute-deviation@1", MathBlockCudaFamily.Window, 17),
        new("window.statistics.pearson-correlation@1", MathBlockCudaFamily.Window, 18),
        new("window-valid.statistics.pearson-correlation@1", MathBlockCudaFamily.Window, 19),
        new("window.statistics.population-covariance@1", MathBlockCudaFamily.Window, 20),
        new("window-valid.statistics.population-covariance@1", MathBlockCudaFamily.Window, 21),
        new("window.statistics.population-excess-kurtosis@1", MathBlockCudaFamily.Window, 22),
        new("window-valid.statistics.population-excess-kurtosis@1", MathBlockCudaFamily.Window, 23),
        new("window.statistics.population-skewness@1", MathBlockCudaFamily.Window, 24),
        new("window-valid.statistics.population-skewness@1", MathBlockCudaFamily.Window, 25),
        new("window.statistics.population-standard-deviation@1", MathBlockCudaFamily.Window, 26),
        new("window-valid.statistics.population-standard-deviation@1", MathBlockCudaFamily.Window, 27),
        new("window.statistics.population-variance@1", MathBlockCudaFamily.Window, 28),
        new("window-valid.statistics.population-variance@1", MathBlockCudaFamily.Window, 29),
        new("window.statistics.pseudomedian@1", MathBlockCudaFamily.Window, 30),
        new("window-valid.statistics.pseudomedian@1", MathBlockCudaFamily.Window, 31),
        new("window.statistics.raw-moment@1", MathBlockCudaFamily.Window, 32),
        new("window-valid.statistics.raw-moment@1", MathBlockCudaFamily.Window, 33),
        new("window.statistics.root-mean-square@1", MathBlockCudaFamily.Window, 34),
        new("window-valid.statistics.root-mean-square@1", MathBlockCudaFamily.Window, 35),
        new("window.statistics.sample-covariance@1", MathBlockCudaFamily.Window, 36),
        new("window-valid.statistics.sample-covariance@1", MathBlockCudaFamily.Window, 37),
        new("window.statistics.sample-standard-deviation@1", MathBlockCudaFamily.Window, 38),
        new("window-valid.statistics.sample-standard-deviation@1", MathBlockCudaFamily.Window, 39),
        new("window.statistics.sample-variance@1", MathBlockCudaFamily.Window, 40),
        new("window-valid.statistics.sample-variance@1", MathBlockCudaFamily.Window, 41),
        new("window.statistics.spearman-correlation@1", MathBlockCudaFamily.Window, 42),
        new("window-valid.statistics.spearman-correlation@1", MathBlockCudaFamily.Window, 43),
        new("window.statistics.theil-sen-slope@1", MathBlockCudaFamily.Window, 44),
        new("window-valid.statistics.theil-sen-slope@1", MathBlockCudaFamily.Window, 45),
        new("window.statistics.weighted-mean@1", MathBlockCudaFamily.Window, 46),
        new("window-valid.statistics.weighted-mean@1", MathBlockCudaFamily.Window, 47),
        new("window.statistics.weighted-population-variance@1", MathBlockCudaFamily.Window, 48),
        new("window-valid.statistics.weighted-population-variance@1", MathBlockCudaFamily.Window, 49),
        new("window.path.longest-true-run@1", MathBlockCudaFamily.Window, 50),
        new("window-valid.path.longest-true-run@1", MathBlockCudaFamily.Window, 51),
        new("window.path.maximum-decline@1", MathBlockCudaFamily.Window, 52),
        new("window-valid.path.maximum-decline@1", MathBlockCudaFamily.Window, 53),
        new("window.path.maximum-relative-decline@1", MathBlockCudaFamily.Window, 54),
        new("window-valid.path.maximum-relative-decline@1", MathBlockCudaFamily.Window, 55),
        new("window.path.power-variation@1", MathBlockCudaFamily.Window, 56),
        new("window-valid.path.power-variation@1", MathBlockCudaFamily.Window, 57),
        new("window.path.quadratic-variation@1", MathBlockCudaFamily.Window, 58),
        new("window-valid.path.quadratic-variation@1", MathBlockCudaFamily.Window, 59),
        new("window.path.recurrence-rate@1", MathBlockCudaFamily.Window, 60),
        new("window-valid.path.recurrence-rate@1", MathBlockCudaFamily.Window, 61),
        new("window.path.total-variation@1", MathBlockCudaFamily.Window, 62),
        new("window-valid.path.total-variation@1", MathBlockCudaFamily.Window, 63),
        new("window.path.turning-point-count@1", MathBlockCudaFamily.Window, 64),
        new("window-valid.path.turning-point-count@1", MathBlockCudaFamily.Window, 65),
        new("window.path.zero-crossing-count@1", MathBlockCudaFamily.Window, 66),
        new("window-valid.path.zero-crossing-count@1", MathBlockCudaFamily.Window, 67),
        new("window.path.first-passage-index@1", MathBlockCudaFamily.Window, 68),
        new("window-valid.path.first-passage-index@1", MathBlockCudaFamily.Window, 69),
        new("window.information.shannon-entropy@1", MathBlockCudaFamily.Window, 70),
        new("window-valid.information.shannon-entropy@1", MathBlockCudaFamily.Window, 71),
        new("window.information.renyi-entropy@1", MathBlockCudaFamily.Window, 72),
        new("window-valid.information.renyi-entropy@1", MathBlockCudaFamily.Window, 73),
        new("window.information.tsallis-entropy@1", MathBlockCudaFamily.Window, 74),
        new("window-valid.information.tsallis-entropy@1", MathBlockCudaFamily.Window, 75),
        new("window.information.gini-impurity@1", MathBlockCudaFamily.Window, 76),
        new("window-valid.information.gini-impurity@1", MathBlockCudaFamily.Window, 77),
        new("window.information.binary-shannon-entropy@1", MathBlockCudaFamily.Window, 78),
        new("window-valid.information.binary-shannon-entropy@1", MathBlockCudaFamily.Window, 79),
        new("window.vector.sum@1", MathBlockCudaFamily.Window, 80),
        new("window-valid.vector.sum@1", MathBlockCudaFamily.Window, 81),
        new("window.vector.mean@1", MathBlockCudaFamily.Window, 82),
        new("window-valid.vector.mean@1", MathBlockCudaFamily.Window, 83),
        new("window.vector.minimum@1", MathBlockCudaFamily.Window, 84),
        new("window-valid.vector.minimum@1", MathBlockCudaFamily.Window, 85),
        new("window.vector.maximum@1", MathBlockCudaFamily.Window, 86),
        new("window-valid.vector.maximum@1", MathBlockCudaFamily.Window, 87),
        new("window.vector.geometric-mean@1", MathBlockCudaFamily.Window, 88),
        new("window-valid.vector.geometric-mean@1", MathBlockCudaFamily.Window, 89),
        new("window.vector.l1-norm@1", MathBlockCudaFamily.Window, 90),
        new("window-valid.vector.l1-norm@1", MathBlockCudaFamily.Window, 91),
        new("window.vector.l2-norm@1", MathBlockCudaFamily.Window, 92),
        new("window-valid.vector.l2-norm@1", MathBlockCudaFamily.Window, 93),
        new("window.vector.median@1", MathBlockCudaFamily.Window, 94),
        new("window-valid.vector.median@1", MathBlockCudaFamily.Window, 95),
        new("window.vector.quantile@1", MathBlockCudaFamily.Window, 96),
        new("window-valid.vector.quantile@1", MathBlockCudaFamily.Window, 97),
        new("window.vector.arg-maximum@1", MathBlockCudaFamily.Window, 98),
        new("window-valid.vector.arg-maximum@1", MathBlockCudaFamily.Window, 99),
        new("window.vector.arg-minimum@1", MathBlockCudaFamily.Window, 100),
        new("window-valid.vector.arg-minimum@1", MathBlockCudaFamily.Window, 101),
        new("window.vector.rank@1", MathBlockCudaFamily.Window, 102),
        new("window-valid.vector.rank@1", MathBlockCudaFamily.Window, 103),
        new("window.vector.standardize@1", MathBlockCudaFamily.Window, 104),
        new("window-valid.vector.standardize@1", MathBlockCudaFamily.Window, 105),
        new("window-accurate.sum@1", MathBlockCudaFamily.Window, 106),
        new("window-accurate-valid.sum@1", MathBlockCudaFamily.Window, 107),
        new("window-accurate.mean@1", MathBlockCudaFamily.Window, 108),
        new("window-accurate-valid.mean@1", MathBlockCudaFamily.Window, 109),
        new("window-accurate.population-variance@1", MathBlockCudaFamily.Window, 110),
        new("window-accurate-valid.population-variance@1", MathBlockCudaFamily.Window, 111),
        new("window-accurate.sample-variance@1", MathBlockCudaFamily.Window, 112),
        new("window-accurate-valid.sample-variance@1", MathBlockCudaFamily.Window, 113),
        new("window-accurate.population-standard-deviation@1", MathBlockCudaFamily.Window, 114),
        new("window-accurate-valid.population-standard-deviation@1", MathBlockCudaFamily.Window, 115),
        new("window-accurate.sample-standard-deviation@1", MathBlockCudaFamily.Window, 116),
        new("window-accurate-valid.sample-standard-deviation@1", MathBlockCudaFamily.Window, 117)
    ];

    private static readonly Dictionary<string, MathBlockCudaFeature> featuresByIdentity = CreateIndex();

    internal static IReadOnlyCollection<string> Identities { get; } =
        Array.AsReadOnly(MathBlockCollectionPrimitives.Map(Features, feature => feature.Identity));

    internal static bool IsWindowIdentity(string? identity) =>
        identity is not null && featuresByIdentity.ContainsKey(identity);

    internal static MathBlockCudaFeature Resolve(string identity) =>
        featuresByIdentity.TryGetValue(identity, out var feature)
            ? feature
            : throw new NotSupportedException($"MathBlock '{identity}' has no CUDA implementation.");

    // Scratch doubles one thread needs for one window: the sorted copy (interquartile range, median, quantile),
    // the logarithms (geometric mean), two rows of means (distance correlation), the sorted copy and deviations
    // (median absolute deviation), two rank vectors (Spearman), or the pair values and a merge buffer of equal
    // size (Theil-Sen, pseudomedian). The window-accurate sources (53 .. 58) need one exact accumulator of 285
    // 64-bit words for the sum and mean, two for the variances and deviations, whatever the width.
    internal static long ScratchDoubles(int source, long width) => source switch
    {
        44 or 47 or 48 => width,
        2 or 3 or 8 or 21 => width * 2,
        22 => width * (width - 1),
        15 => width * (width + 1),
        53 or 54 => 285,
        55 or 56 or 57 or 58 => 570,
        _ => 0
    };

    // The largest width whose scratch for one block of threads fits the int byte count of the plan (the plan needs at least
    // one block); a source whose scratch does not depend on the width has no limit.
    internal static long MaximumWidth(int source) => MaximumWidth(source, (int)BlockSize);

    // The same for a launch of blockSize threads per block: the one block's scratch grows with the block size, so the largest
    // width shrinks with it (the results of the widths that fit do not depend on it).
    internal static long MaximumWidth(int source, int blockSize)
    {
        long limit = int.MaxValue / (sizeof(double) * (long)blockSize);
        // A source has no limit only when even the widest width fits: the scratch at width 1 can be 0 while it grows with the width
        // (theil-sen-slope needs width squared doubles per thread), so that is not the test.
        if (ScratchDoubles(source, int.MaxValue) <= limit)
            return int.MaxValue;
        long low = 1;
        long high = int.MaxValue;
        while (low < high)
        {
            var middle = low + ((high - low + 1) / 2);
            if (ScratchDoubles(source, middle) <= limit)
                low = middle;
            else
                high = middle - 1;
        }

        return low;
    }

    // Rows each thread evaluates. The median, the quantile and the window-accurate sources slide their state over a
    // block of consecutive rows after adding the width - 1 rows before it, so a block of twice the width (at least
    // 32 rows) keeps that start-up below half of the work; without a plan-time width the block is 256 rows. The
    // other sources evaluate one row per thread. The block size changes only the speed: every row's bits are those
    // of the sequential pass.
    internal static long RowsPerThread(int source, long? width)
    {
        if (source is not (47 or 48 or >= 53))
            return 1;
        if (width is not { } planned)
            return 256;
        return planned * 2 < 32 ? 32 : planned * 2;
    }

    // Theil-Sen and the pseudomedian need w^2 scratch per thread, so their plan needs the width itself rather
    // than the series length as a bound.
    internal static bool RequiresPlanTimeWidth(int source) => source is 15 or 22;

    private static Dictionary<string, MathBlockCudaFeature> CreateIndex()
    {
        var result = new Dictionary<string, MathBlockCudaFeature>(Features.Length, StringComparer.Ordinal);
        foreach (var feature in Features)
            result.Add(feature.Identity, feature);
        return result;
    }
}
