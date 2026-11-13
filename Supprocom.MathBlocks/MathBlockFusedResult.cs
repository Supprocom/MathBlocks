using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

/// <summary>Holds the outputs of a fused expression, each output's row validity, and the invalid mask.</summary>
public sealed class MathBlockFusedResult
{
    internal MathBlockFusedResult(
        IReadOnlyDictionary<string, MathBlockValue> outputs,
        IReadOnlyDictionary<string, MathBlockValue> validity,
        ulong invalidMask)
    {
        Outputs = outputs;
        Validity = validity;
        InvalidMask = invalidMask;
    }

    /// <summary>Gets each output by name, equal to the output of the unfused program.</summary>
    public IReadOnlyDictionary<string, MathBlockValue> Outputs { get; }

    /// <summary>Gets each output's row validity by output name, as a Boolean vector.</summary>
    /// <remarks>
    /// Row t is true when row t of every contributing vector input is valid according to its validity input, and no
    /// <c>elementwise.*</c> form on the path to the output holds its fill at row t. An input without a validity input
    /// is valid in every row.
    /// </remarks>
    public IReadOnlyDictionary<string, MathBlockValue> Validity { get; }

    /// <summary>Gets the geometry of the kernel launch that produced the result, or null when it came from CoreCLR.</summary>
    /// <remarks>
    /// <see cref="MathBlockCudaLaunch.WantedBlocks"/> is the blocks the rows call for with <see cref="MathBlocksCudaOptions.FusedBlockSize"/> threads each, and
    /// <see cref="MathBlockCudaLaunch.ClampedBy"/> is <c>FusedMaximumBlocks</c> when <see cref="MathBlocksCudaOptions.FusedMaximumBlocks"/> cut the grid. The clamp is
    /// speed-only: the rows stripe over the remaining blocks (row = block * block size + thread, stepping by blocks * block size), every row is computed by the same
    /// expression, and the result is unchanged. A launch with no rows has zero blocks.
    /// </remarks>
    public MathBlockCudaLaunch? Launch { get; internal set; }

    /// <summary>Gets the invalid mask: bit k is set when operation node k produced a nonfinite row.</summary>
    /// <remarks>Operation nodes are numbered in program node order; see <see cref="MathBlockFusedExpression.MaskNodeIndexes"/>.</remarks>
    public ulong InvalidMask { get; }
}
