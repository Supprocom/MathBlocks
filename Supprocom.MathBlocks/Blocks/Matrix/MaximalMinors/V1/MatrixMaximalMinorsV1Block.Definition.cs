namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixMaximalMinorsV1Block
    {
        internal const string Identity = "matrix.maximal-minors@1";
        internal static MathBlockOperation Create() => CreateMaximalMinors();
        private static MathBlockOperation CreateMaximalMinors() => MathBlockOperationFactory.Create("matrix.maximal-minors", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            if (types[0].Rows != 0 && types[0].Columns != 0 && types[0].Rows > types[0].Columns)
                throw new InvalidOperationException("The matrix cannot have more rows than columns.");
            if (types[0].Rows == 0 && !types[0].Unit.IsDimensionless)
                throw new InvalidOperationException("A dimensional minor requires a known order.");
            return MathBlockType.Vector(types[0].Unit.Pow(new MathRational(types[0].Rows)));
        }, inputs => inputs[0].AsMatrix().Rows <= inputs[0].AsMatrix().Columns && inputs[0].AsMatrix().Columns <= 20 ? MathBlockValue.Vector(MathBlockAdvanced.MaximalMinors(inputs[0].AsMatrix()), inputs[0].Type.Unit.Pow(new MathRational(inputs[0].AsMatrix().Rows)), true) : MathBlockValue.Invalid(MathBlockType.Vector(), "The matrix shape is outside the operation domain."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 3, [1d, 0d, 1d, 0d, 1d, 1d]))], MathBlockValue.Vector([1d, 1d, -1d]), performanceIterations: 4);
    }
}
