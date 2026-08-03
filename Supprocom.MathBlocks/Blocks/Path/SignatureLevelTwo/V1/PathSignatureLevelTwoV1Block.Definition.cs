namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathSignatureLevelTwoV1Block
    {
        internal const string Identity = "path.signature-level-two@1";
        internal static MathBlockOperation Create() => CreateSignatureTwo();
        private static MathBlockOperation CreateSignatureTwo()
        {
            var sample = MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [0d, 0d, 1d, 0d, 1d, 2d]));
            return MathBlockOperationFactory.Create("path.signature-level-two", 1, types =>
            {
                MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
                return MathBlockType.Matrix(types[0].Unit.Pow(new MathRational(2)), types[0].Columns, types[0].Columns);
            }, inputs => MathBlockValue.Matrix(MathBlockPath.SignatureLevelTwo(inputs[0].AsMatrix()), inputs[0].Type.Unit.Pow(new MathRational(2))), [sample], MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [0.5d, 2d, 0d, 2d])), performanceIterations: 8);
        }
    }
}
