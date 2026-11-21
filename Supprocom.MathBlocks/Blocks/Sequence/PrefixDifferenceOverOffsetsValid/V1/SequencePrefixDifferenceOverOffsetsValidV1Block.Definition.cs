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
            [MathBlockValue.Vector([1f, 2f, 3f, 4f, 5f, 6f]), MathBlockValue.BooleanVector([true, true, true, true, true, true]), MathBlockValue.Vector([0f, 1f, 2f, 3f, 4f, 5f]), MathBlockValue.Scalar(-1f), MathBlockValue.Scalar(1f)],
            MathBlockValue.BooleanVector([false, true, true, true, true, false]),
            performanceIterations: 64);
    }
}
