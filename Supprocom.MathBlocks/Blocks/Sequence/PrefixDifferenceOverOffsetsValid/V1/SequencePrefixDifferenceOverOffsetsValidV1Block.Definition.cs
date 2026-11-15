namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequencePrefixDifferenceOverOffsetsValidV1Block
    {
        internal const string Identity = "sequence.prefix-difference-over-offsets-valid@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create(
            "sequence.prefix-difference-over-offsets-valid",
            5,
            MathBlockVectorMath.PrefixDifferenceValidityType,
            MathBlockVectorMath.PrefixDifferenceValidity,
            [MathBlockValue.Vector([1d, 2d, 3d, 4d, 5d, 6d]), MathBlockValue.BooleanVector([true, true, true, true, true, true]), MathBlockValue.Vector([0d, 1d, 2d, 3d, 4d, 5d]), MathBlockValue.Scalar(-1d), MathBlockValue.Scalar(1d)],
            MathBlockValue.BooleanVector([false, true, true, true, true, false]),
            performanceIterations: 64);
    }
}
