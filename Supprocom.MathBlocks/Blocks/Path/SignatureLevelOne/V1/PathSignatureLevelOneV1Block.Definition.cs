namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathSignatureLevelOneV1Block
    {
        internal const string Identity = "path.signature-level-one@1";
        internal static MathBlockOperation Create() => CreateSignatureOne();
        private static MathBlockOperation CreateSignatureOne()
        {
            var sample = MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [0d, 0d, 1d, 0d, 1d, 2d]));
            return MathBlockOperationFactory.Create("path.signature-level-one", 1, types =>
            {
                MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
                return MathBlockType.Vector(types[0].Unit, types[0].Columns);
            }, inputs => inputs[0].AsMatrix().Rows > 0 ? MathBlockValue.Vector(MathBlockPath.SignatureLevelOne(inputs[0].AsMatrix()), inputs[0].Type.Unit, true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit), "The path is empty."), [sample], MathBlockValue.Vector([1d, 2d]), performanceIterations: 8);
        }
    }
}
