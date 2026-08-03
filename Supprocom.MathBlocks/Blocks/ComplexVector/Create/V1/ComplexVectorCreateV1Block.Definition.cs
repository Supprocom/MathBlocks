namespace Supprocom.MathBlocks;
internal static partial class StructuralMathBlocks
{
    internal static class ComplexVectorCreateV1Block
    {
        internal const string Identity = "complex-vector.create@1";
        internal static MathBlockOperation Create() => CreateComplexVector();
        private static MathBlockOperation CreateComplexVector() => MathBlockOperationFactory.Create("complex-vector.create", 2, types =>
        {
            var vectorType = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.ComplexVector(vectorType.Unit, vectorType.Rows);
        }, inputs => MathBlockValue.ComplexVector(MathBlockStructure.ComplexVector(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit, true), [MathBlockValue.Vector([1d, 3d]), MathBlockValue.Vector([2d, 4d])], MathBlockValue.ComplexVector([new Complex(1d, 2d), new Complex(3d, 4d)]), performanceIterations: 16);
    }
}
