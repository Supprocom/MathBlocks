namespace Supprocom.MathBlocks;

internal static partial class PathMathBlocks
{
    internal static class TransformHaarV1Block
    {
        internal const string Identity = "transform.haar@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateHaar();

        // The Haar transform pairs entries level by level, so the length must be a power of two.
        private static MathBlockOperation CreateHaar() => MathBlockOperationFactory.Create("transform.haar", 1, SameUnitVector, inputs =>
        {
            var count = inputs[0].AsVector().Count;
            return count > 0 && (count & (count - 1)) == 0
                ? MathBlockValue.Vector(MathBlockPath.HaarTransform(inputs[0].AsVector()), inputs[0].Type.Unit, true)
                : MathBlockOperationFactory.Invalid(SameUnitVector, inputs, "The length is not a power of two.");
        }, [MathBlockValue.Vector([1d, 1d, 1d, 1d])], MathBlockValue.Vector([2d, 0d, 0d, 0d]), 1e-9, 16);
    }
}
