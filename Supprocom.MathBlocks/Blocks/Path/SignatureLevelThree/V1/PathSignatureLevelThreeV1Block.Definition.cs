namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class PathSignatureLevelThreeV1Block
    {
        internal const string Identity = "path.signature-level-three@1";
        internal static MathBlockOperation Create() => CreateSignatureLevelThree();
        private static MathBlockOperation CreateSignatureLevelThree() => MathBlockOperationFactory.Create("path.signature-level-three", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Matrix);
            var length = types[0].Columns == 0 ? 0 : types[0].Columns * types[0].Columns * types[0].Columns;
            return MathBlockType.Vector(types[0].Unit.Pow(new MathRational(3)), length);
        }, inputs => inputs[0].AsMatrix().Rows >= 1 ? MathBlockValue.Vector(MathBlockAdvanced.SignatureLevelThree(inputs[0].AsMatrix()), inputs[0].Type.Unit.Pow(new MathRational(3)), true) : MathBlockValue.Invalid(MathBlockType.Vector(inputs[0].Type.Unit.Pow(new MathRational(3))), "The path is empty."), [MathBlockValue.Matrix(new MathBlockMatrix(2, 1, [0d, 2d]))], MathBlockValue.Vector([4d / 3d]), performanceIterations: 4);
    }
}
