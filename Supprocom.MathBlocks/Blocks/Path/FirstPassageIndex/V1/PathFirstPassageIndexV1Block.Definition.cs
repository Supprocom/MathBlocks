namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathFirstPassageIndexV1Block
    {
        internal const string Identity = "path.first-passage-index@1";
        internal static MathBlockOperation Create() => CreateFirstPassage();
        private static MathBlockOperation CreateFirstPassage() => MathBlockOperationFactory.Create("path.first-passage-index", 3, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            if (types[0].Unit != types[1].Unit)
                throw new InvalidOperationException("The path and threshold units must be equal.");
            MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Boolean);
            return MathBlockType.Scalar();
        }, inputs => MathBlockValue.Scalar(MathBlockPath.FirstPassageIndex(inputs[0].AsVector(), inputs[1].AsScalar(), inputs[2].AsBoolean())), [path, MathBlockValue.Scalar(4d), MathBlockValue.Boolean(true)], MathBlockValue.Scalar(3d), performanceIterations: 16);
    }
}
