namespace Supprocom.MathBlocks;

/// <summary>Sets operation domain limits. They change which rows are valid, so CoreCLR and CUDA must use the same values.</summary>
public sealed class MathBlockDomainOptions
{
    /// <summary>Gets the option set with today's domain limits.</summary>
    public static MathBlockDomainOptions Default { get; } = new();

    /// <summary>Gets the largest size of an explicit subset enumeration: the matrix rows of <c>matrix.principal-minors</c>, the values of <c>combinatorics.nonempty-subset-sums</c> and the matrix rows of <c>transport.minimum-assignment</c>.</summary>
    public int MaximumExplicitSubsetSize { get; init; } = 20;

    /// <summary>Gets the largest state count of <c>state.transition-counts</c>.</summary>
    public int MaximumStateCount { get; init; } = 4_096;
}
