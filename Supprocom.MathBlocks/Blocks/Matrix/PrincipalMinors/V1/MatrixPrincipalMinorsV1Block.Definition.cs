namespace Supprocom.MathBlocks;

internal static partial class AdvancedMathBlocks
{
    internal static class MatrixPrincipalMinorsV1Block
    {
        internal const string Identity = "matrix.principal-minors@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.NotSeries;
        internal static MathBlockOperation Create() => CreatePrincipalMinors();
        private static MathBlockOperation CreatePrincipalMinors() => MathBlockOperationFactory.CreateDomain("matrix.principal-minors", 1, types =>
        {
            RequireSquareMatrix(types[0]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Vector();
        }, (inputs, domain) => inputs[0].AsMatrix().Rows <= domain.Options.MaximumExplicitSubsetSize ? MathBlockValue.Vector(MathBlockAdvanced.PrincipalMinors(inputs[0].AsMatrix()), default, true) : MathBlockValue.Invalid(MathBlockType.Vector(), "The explicit subset limit is twenty."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [2f, 0f, 0f, 3f]))], MathBlockValue.Vector([2f, 3f, 6f]), performanceIterations: 4);
    }
}
