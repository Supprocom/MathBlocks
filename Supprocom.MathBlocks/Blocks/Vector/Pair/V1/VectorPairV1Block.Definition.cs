namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class VectorPairV1Block
    {
        internal const string Identity = "vector.pair@1";
        internal static MathBlockOperation Create() => CreatePair();
        private static MathBlockOperation CreatePair() => MathBlockOperationFactory.Create("vector.pair", 2, types =>
        {
            var scalar = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Scalar);
            return MathBlockType.Vector(scalar.Unit, 2);
        }, inputs => MathBlockValue.Vector(MathBlockStructure.Pair(inputs[0].AsScalar(), inputs[1].AsScalar()), inputs[0].Type.Unit, true), [MathBlockValue.Scalar(1d), MathBlockValue.Scalar(2d)], MathBlockValue.Vector([1d, 2d]), performanceIterations: 64);
    }
}
