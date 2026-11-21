namespace Supprocom.MathBlocks;

internal static partial class VectorMathBlocks
{
    internal static class SequencePrefixDifferenceOverOffsetsV1Block
    {
        internal const string Identity = "sequence.prefix-difference-over-offsets@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Forward;
        internal static MathBlockOperation Create() => MathBlockOperationFactory.Create(
            "sequence.prefix-difference-over-offsets",
            6,
            MathBlockVectorMath.PrefixDifferenceFormType,
            MathBlockVectorMath.PrefixDifferenceForm,
            [MathBlockValue.Vector([1f, 2f, 3f, 4f, 5f, 6f]), MathBlockValue.BooleanVector([true, true, true, true, true, true]), MathBlockValue.Vector([0f, 1f, 2f, 3f, 4f, 5f]), MathBlockValue.Scalar(-1f), MathBlockValue.Scalar(1f), MathBlockValue.Scalar(-1f)],
            MathBlockValue.Vector([-1f, 6f, 9f, 12f, 15f, -1f]),
            3e-5f,
            64);
    }
}
