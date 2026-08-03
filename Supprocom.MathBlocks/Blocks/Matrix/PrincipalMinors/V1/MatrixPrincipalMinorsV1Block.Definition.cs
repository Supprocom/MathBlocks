namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixPrincipalMinorsV1Block
    {
        internal const string Identity = "matrix.principal-minors@1";
        internal static MathBlockOperation Create() => CreatePrincipalMinors();
        private static MathBlockOperation CreatePrincipalMinors() => MathBlockOperationFactory.Create("matrix.principal-minors", 1, types =>
        {
            RequireSquareMatrix(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Vector();
        }, inputs => inputs[0].AsMatrix().Rows <= 20 ? MathBlockValue.Vector(MathBlockAdvanced.PrincipalMinors(inputs[0].AsMatrix()), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(), "The explicit subset limit is twenty."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2d, 0d, 0d, 3d]))], MathBlockValue.Vector([2d, 3d, 6d]), performanceIterations: 4);
    }
}
