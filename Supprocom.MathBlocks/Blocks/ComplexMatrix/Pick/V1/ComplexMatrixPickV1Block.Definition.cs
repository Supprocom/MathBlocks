namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class ComplexMatrixPickV1Block
    {
        internal const string Identity = "complex-matrix.pick@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreatePickMatrix();
        private static MathBlockOperation CreatePickMatrix() => MathBlockOperationFactory.Create("complex-matrix.pick", 2, PickMatrixType, inputs => inputs[0].AsComplexVector().Count > 0 &&
                     MathBlockCollectionPrimitives.All(
                         inputs[0].AsComplexVector(),
                         value => MathBlockComplex.Magnitude(value) < 1f) &&
                     MathBlockCollectionPrimitives.All(
                         inputs[1].AsComplexVector(),
                         value => MathBlockComplex.Magnitude(value) <= 1f)
            ? MathBlockValue.ComplexMatrix(
                MathBlockAdvanced.PickMatrix(inputs[0].AsComplexVector(), inputs[1].AsComplexVector()))
            : MathBlockOperationFactory.Invalid(
                PickMatrixType,
                inputs,
                "The complex values are outside the operation domain."),
            [MathBlockValue.ComplexVector([new Complex(0f, 0f)]), MathBlockValue.ComplexVector([new Complex(0.5f, 0f)])],
            MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(1, 1, [new Complex(0.75f, 0f)])),
            performanceIterations: 4);

        private static MathBlockType PickMatrixType(IReadOnlyList<MathBlockType> types)
        {
            var vector = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.ComplexVector);
            MathBlockTypeRules.RequireDimensionless(vector);
            return MathBlockType.ComplexMatrix(rows: vector.Rows, columns: vector.Rows);
        }
    }
}
