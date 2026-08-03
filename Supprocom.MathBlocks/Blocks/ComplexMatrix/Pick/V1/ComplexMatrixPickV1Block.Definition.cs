namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class ComplexMatrixPickV1Block
    {
        internal const string Identity = "complex-matrix.pick@1";
        internal static MathBlockOperation Create() => CreatePickMatrix();
        private static MathBlockOperation CreatePickMatrix() => MathBlockOperationFactory.Create("complex-matrix.pick", 2, types =>
        {
            var vector = MathBlockTypeRules.SameBinary(types, MathBlockValueKind.ComplexVector);
            MathBlockTypeRules.RequireDimensionless(vector);
            return MathBlockType.ComplexMatrix(rows: vector.Rows, columns: vector.Rows);
        }, inputs => inputs[0].AsComplexVector().Count > 0 &&
                     MathBlockCollectionPrimitives.All(
                         inputs[0].AsComplexVector(),
                         value => MathBlockComplex.Magnitude(value) < 1d) &&
                     MathBlockCollectionPrimitives.All(
                         inputs[1].AsComplexVector(),
                         value => MathBlockComplex.Magnitude(value) <= 1d)
            ? MathBlockValue.ComplexMatrix(
                MathBlockAdvanced.PickMatrix(inputs[0].AsComplexVector(), inputs[1].AsComplexVector()))
            : MathBlockValue.Invalid(
                MathBlockType.ComplexMatrix(),
                "The complex values are outside the operation domain."),
            [MathBlockValue.ComplexVector([new Complex(0d, 0d)]), MathBlockValue.ComplexVector([new Complex(0.5d, 0d)])],
            MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(1, 1, [new Complex(0.75d, 0d)])),
            performanceIterations: 4);
    }
}
