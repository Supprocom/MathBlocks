namespace Supprocom.MathBlocks;

internal static partial class StructuralMathBlocks
{
    internal static class ComplexVectorCreateV1Block
    {
        internal const string Identity = "complex-vector.create@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.Pointwise;
        internal static MathBlockOperation Create() => CreateComplexVector();
        private static MathBlockOperation CreateComplexVector() => MathBlockOperationFactory.Create("complex-vector.create", 2, ComplexVectorType, inputs => inputs[0].AsVector().Count == inputs[1].AsVector().Count ? MathBlockValue.ComplexVector(MathBlockStructure.ComplexVector(inputs[0].AsVector(), inputs[1].AsVector()), inputs[0].Type.Unit, true) : MathBlockOperationFactory.Invalid(ComplexVectorType, inputs, "The input row counts must be equal."), [MathBlockValue.Vector([1d, 3d]), MathBlockValue.Vector([2d, 4d])], MathBlockValue.ComplexVector([new Complex(1d, 2d), new Complex(3d, 4d)]), performanceIterations: 16);

        private static MathBlockType ComplexVectorType(IReadOnlyList<MathBlockType> types)
        {
            var vectorType = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.Vector);
            return MathBlockType.ComplexVector(vectorType.Unit, vectorType.Rows);
        }
    }
}
