namespace Supprocom.MathBlocks;

internal static partial class StructuralMathBlocks
{
    internal static class VectorPairV1Block
    {
        internal const string Identity = "vector.pair@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePair();
        private static MathBlockOperation CreatePair() => MathBlockOperationFactory.Create("vector.pair", 2, types =>
        {
            var scalar = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Scalar);
            return MathBlockType.Vector(scalar.Unit, 2);
        }, inputs => MathBlockValue.Vector(MathBlockStructure.Pair(inputs[0].AsScalar(), inputs[1].AsScalar()), inputs[0].Type.Unit, true), [MathBlockValue.Scalar(1f), MathBlockValue.Scalar(2f)], MathBlockValue.Vector([1f, 2f]), performanceIterations: 64);
    }
}
