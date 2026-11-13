namespace Supprocom.MathBlocks.Cuda;

// The elementwise.* forms and elementwise-valid.* siblings run in one kernel that stripes rows across the grid.
// Contract opcode 2 * source + sibling, with source the index in the elementwise source list
// (ElementwiseMathBlocks). The dispatched opcode adds 128 * mask, where bit k of mask is set when argument k is a
// vector, because a Scalar slot and an empty Vector slot carry the same header.
internal static class ElementwiseCudaBlockCatalog
{
    internal const int MaximumGridX = 65_535;
    internal const int ArgumentMaskMultiplier = 128;

    public static string KernelEntryPoint => "mathblocks_elementwise";
    public static uint BlockSize => 128;

    internal static readonly MathBlockCudaFeature[] Features =
    [
        new("elementwise.combinatorics.ballot-count@1", MathBlockCudaFamily.Elementwise, 0),
        new("elementwise-valid.combinatorics.ballot-count@1", MathBlockCudaFamily.Elementwise, 1),
        new("elementwise.combinatorics.binomial-coefficient@1", MathBlockCudaFamily.Elementwise, 2),
        new("elementwise-valid.combinatorics.binomial-coefficient@1", MathBlockCudaFamily.Elementwise, 3),
        new("elementwise.combinatorics.factorial@1", MathBlockCudaFamily.Elementwise, 4),
        new("elementwise-valid.combinatorics.factorial@1", MathBlockCudaFamily.Elementwise, 5),
        new("elementwise.probability.normal-cdf@1", MathBlockCudaFamily.Elementwise, 6),
        new("elementwise-valid.probability.normal-cdf@1", MathBlockCudaFamily.Elementwise, 7),
        new("elementwise.probability.poisson-cdf@1", MathBlockCudaFamily.Elementwise, 8),
        new("elementwise-valid.probability.poisson-cdf@1", MathBlockCudaFamily.Elementwise, 9),
        new("elementwise.probability.poisson-pmf@1", MathBlockCudaFamily.Elementwise, 10),
        new("elementwise-valid.probability.poisson-pmf@1", MathBlockCudaFamily.Elementwise, 11),
        new("elementwise.scalar.arc-cosine@1", MathBlockCudaFamily.Elementwise, 12),
        new("elementwise-valid.scalar.arc-cosine@1", MathBlockCudaFamily.Elementwise, 13),
        new("elementwise.scalar.arc-sine@1", MathBlockCudaFamily.Elementwise, 14),
        new("elementwise-valid.scalar.arc-sine@1", MathBlockCudaFamily.Elementwise, 15),
        new("elementwise.scalar.arc-tangent-2@1", MathBlockCudaFamily.Elementwise, 16),
        new("elementwise-valid.scalar.arc-tangent-2@1", MathBlockCudaFamily.Elementwise, 17),
        new("elementwise.scalar.arc-tangent@1", MathBlockCudaFamily.Elementwise, 18),
        new("elementwise-valid.scalar.arc-tangent@1", MathBlockCudaFamily.Elementwise, 19),
        new("elementwise.scalar.binary-logarithm@1", MathBlockCudaFamily.Elementwise, 20),
        new("elementwise-valid.scalar.binary-logarithm@1", MathBlockCudaFamily.Elementwise, 21),
        new("elementwise.scalar.ceiling@1", MathBlockCudaFamily.Elementwise, 22),
        new("elementwise-valid.scalar.ceiling@1", MathBlockCudaFamily.Elementwise, 23),
        new("elementwise.scalar.clamp@1", MathBlockCudaFamily.Elementwise, 24),
        new("elementwise-valid.scalar.clamp@1", MathBlockCudaFamily.Elementwise, 25),
        new("elementwise.scalar.common-logarithm@1", MathBlockCudaFamily.Elementwise, 26),
        new("elementwise-valid.scalar.common-logarithm@1", MathBlockCudaFamily.Elementwise, 27),
        new("elementwise.scalar.cosine@1", MathBlockCudaFamily.Elementwise, 28),
        new("elementwise-valid.scalar.cosine@1", MathBlockCudaFamily.Elementwise, 29),
        new("elementwise.scalar.cube-root@1", MathBlockCudaFamily.Elementwise, 30),
        new("elementwise-valid.scalar.cube-root@1", MathBlockCudaFamily.Elementwise, 31),
        new("elementwise.scalar.cube@1", MathBlockCudaFamily.Elementwise, 32),
        new("elementwise-valid.scalar.cube@1", MathBlockCudaFamily.Elementwise, 33),
        new("elementwise.scalar.floor@1", MathBlockCudaFamily.Elementwise, 34),
        new("elementwise-valid.scalar.floor@1", MathBlockCudaFamily.Elementwise, 35),
        new("elementwise.scalar.hyperbolic-cosine@1", MathBlockCudaFamily.Elementwise, 36),
        new("elementwise-valid.scalar.hyperbolic-cosine@1", MathBlockCudaFamily.Elementwise, 37),
        new("elementwise.scalar.hyperbolic-sine@1", MathBlockCudaFamily.Elementwise, 38),
        new("elementwise-valid.scalar.hyperbolic-sine@1", MathBlockCudaFamily.Elementwise, 39),
        new("elementwise.scalar.hyperbolic-tangent@1", MathBlockCudaFamily.Elementwise, 40),
        new("elementwise-valid.scalar.hyperbolic-tangent@1", MathBlockCudaFamily.Elementwise, 41),
        new("elementwise.scalar.inverse-hyperbolic-cosine@1", MathBlockCudaFamily.Elementwise, 42),
        new("elementwise-valid.scalar.inverse-hyperbolic-cosine@1", MathBlockCudaFamily.Elementwise, 43),
        new("elementwise.scalar.inverse-hyperbolic-sine@1", MathBlockCudaFamily.Elementwise, 44),
        new("elementwise-valid.scalar.inverse-hyperbolic-sine@1", MathBlockCudaFamily.Elementwise, 45),
        new("elementwise.scalar.inverse-hyperbolic-tangent@1", MathBlockCudaFamily.Elementwise, 46),
        new("elementwise-valid.scalar.inverse-hyperbolic-tangent@1", MathBlockCudaFamily.Elementwise, 47),
        new("elementwise.scalar.log-one-plus@1", MathBlockCudaFamily.Elementwise, 48),
        new("elementwise-valid.scalar.log-one-plus@1", MathBlockCudaFamily.Elementwise, 49),
        new("elementwise.scalar.logistic@1", MathBlockCudaFamily.Elementwise, 50),
        new("elementwise-valid.scalar.logistic@1", MathBlockCudaFamily.Elementwise, 51),
        new("elementwise.scalar.logit@1", MathBlockCudaFamily.Elementwise, 52),
        new("elementwise-valid.scalar.logit@1", MathBlockCudaFamily.Elementwise, 53),
        new("elementwise.scalar.maximum@1", MathBlockCudaFamily.Elementwise, 54),
        new("elementwise-valid.scalar.maximum@1", MathBlockCudaFamily.Elementwise, 55),
        new("elementwise.scalar.minimum@1", MathBlockCudaFamily.Elementwise, 56),
        new("elementwise-valid.scalar.minimum@1", MathBlockCudaFamily.Elementwise, 57),
        new("elementwise.scalar.modulo@1", MathBlockCudaFamily.Elementwise, 58),
        new("elementwise-valid.scalar.modulo@1", MathBlockCudaFamily.Elementwise, 59),
        new("elementwise.scalar.negate@1", MathBlockCudaFamily.Elementwise, 60),
        new("elementwise-valid.scalar.negate@1", MathBlockCudaFamily.Elementwise, 61),
        new("elementwise.scalar.reciprocal@1", MathBlockCudaFamily.Elementwise, 62),
        new("elementwise-valid.scalar.reciprocal@1", MathBlockCudaFamily.Elementwise, 63),
        new("elementwise.scalar.round@1", MathBlockCudaFamily.Elementwise, 64),
        new("elementwise-valid.scalar.round@1", MathBlockCudaFamily.Elementwise, 65),
        new("elementwise.scalar.sine@1", MathBlockCudaFamily.Elementwise, 66),
        new("elementwise-valid.scalar.sine@1", MathBlockCudaFamily.Elementwise, 67),
        new("elementwise.scalar.softplus@1", MathBlockCudaFamily.Elementwise, 68),
        new("elementwise-valid.scalar.softplus@1", MathBlockCudaFamily.Elementwise, 69),
        new("elementwise.scalar.tangent@1", MathBlockCudaFamily.Elementwise, 70),
        new("elementwise-valid.scalar.tangent@1", MathBlockCudaFamily.Elementwise, 71),
        new("elementwise.scalar.truncate@1", MathBlockCudaFamily.Elementwise, 72),
        new("elementwise-valid.scalar.truncate@1", MathBlockCudaFamily.Elementwise, 73),
        new("elementwise.special.beta@1", MathBlockCudaFamily.Elementwise, 74),
        new("elementwise-valid.special.beta@1", MathBlockCudaFamily.Elementwise, 75),
        new("elementwise.special.error-function@1", MathBlockCudaFamily.Elementwise, 76),
        new("elementwise-valid.special.error-function@1", MathBlockCudaFamily.Elementwise, 77),
        new("elementwise.special.log-gamma@1", MathBlockCudaFamily.Elementwise, 78),
        new("elementwise-valid.special.log-gamma@1", MathBlockCudaFamily.Elementwise, 79),
        new("elementwise.special.regularized-incomplete-beta@1", MathBlockCudaFamily.Elementwise, 80),
        new("elementwise-valid.special.regularized-incomplete-beta@1", MathBlockCudaFamily.Elementwise, 81)
    ];

    private static readonly Dictionary<string, MathBlockCudaFeature> featuresByIdentity = CreateIndex();

    internal static IReadOnlyCollection<string> Identities { get; } =
        Array.AsReadOnly(MathBlockCollectionPrimitives.Map(Features, feature => feature.Identity));

    internal static bool IsElementwiseIdentity(string? identity) =>
        identity is not null && featuresByIdentity.ContainsKey(identity);

    internal static bool TryResolve(string identity, out MathBlockCudaFeature feature) =>
        featuresByIdentity.TryGetValue(identity, out feature);

    // The opcode the kernel receives: the contract opcode plus 128 times the mask of vector arguments. The fill
    // (last input of a form) is never a vector, so it adds nothing.
    internal static int DispatchOpcode(int opcode, MathBlockType[] inputTypes)
    {
        var mask = 0;
        for (var index = 0; index < inputTypes.Length; index++)
            if (inputTypes[index].Kind == MathBlockValueKind.Vector)
                mask |= 1 << index;
        return checked(opcode + ArgumentMaskMultiplier * mask);
    }

    // Two non-empty vector arguments of different lengths give the result no row authority, as the CoreCLR type
    // resolver does; an empty vector next to a non-empty one keeps the non-empty length.
    internal static bool VectorLengthsDiffer(MathBlockType[] inputTypes, int[] inputShapeRows)
    {
        var rows = 0;
        for (var index = 0; index < inputTypes.Length; index++)
        {
            if (inputTypes[index].Kind != MathBlockValueKind.Vector || inputShapeRows[index] <= 0)
                continue;
            if (rows == 0)
                rows = inputShapeRows[index];
            else if (rows != inputShapeRows[index])
                return true;
        }
        return false;
    }

    // One thread per row, in blocks of 128, at least one block and at most MaximumGridX; the rows stripe over the
    // grid when there are more.
    internal static int GridX(int rows) => GridXFor(rows, (int)BlockSize, MaximumGridX);

    // The blocks of a launch of blockSize threads per block, clamped to maximumGridX; wanted is the count before the clamp.
    internal static int GridXFor(int rows, int blockSize, int maximumGridX) => GridXFor(rows, blockSize, maximumGridX, out _);

    internal static int GridXFor(int rows, int blockSize, int maximumGridX, out long wanted)
    {
        wanted = rows <= blockSize ? 1L : ((long)rows + blockSize - 1L) / blockSize;
        return wanted > maximumGridX ? maximumGridX : (int)wanted;
    }

    private static Dictionary<string, MathBlockCudaFeature> CreateIndex()
    {
        var result = new Dictionary<string, MathBlockCudaFeature>(Features.Length, StringComparer.Ordinal);
        foreach (var feature in Features)
            result.Add(feature.Identity, feature);
        return result;
    }
}
