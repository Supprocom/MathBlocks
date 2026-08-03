namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class MatrixIsTotallyNonnegativeV1Block
    {
        internal const string Identity = "matrix.is-totally-nonnegative@1";
        internal static MathBlockOperation Create() => CreateMatrixBoolean("matrix.is-totally-nonnegative", MathBlockAdvanced.IsTotallyNonnegative, MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 1d, 1d, 2d])), true);
        private static MathBlockOperation CreateMatrixBoolean(string identifier, Func<MathBlockMatrix, bool> function, MathBlockValue sample, bool expected) => MathBlockOperationFactory.Create(identifier, 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            return MathBlockType.Boolean;
        }, inputs => inputs[0].AsMatrix().Rows <= 8 && inputs[0].AsMatrix().Columns <= 8 ? MathBlockValue.Boolean(function(inputs[0].AsMatrix())) : MathBlockValue.Invalid(MathBlockType.Boolean, "The explicit minor enumeration limit is eight."), [sample], MathBlockValue.Boolean(expected), performanceIterations: 2);
    }
}
