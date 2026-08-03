namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathRunLengthEncodeV1Block
    {
        internal const string Identity = "path.run-length-encode@1";
        internal static MathBlockOperation Create() => CreateRunLength();
        private static MathBlockOperation CreateRunLength() => MathBlockOperationFactory.Create("path.run-length-encode", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.RunSet(types[0].Unit);
        }, inputs => MathBlockValue.RunSet(MathBlockPath.RunLengthEncode(inputs[0].AsVector()), inputs[0].Type.Unit), [MathBlockValue.Vector([1d, 1d, 2d, 2d, 2d])], MathBlockValue.RunSet(new MathBlockRunSet([new(0, 2, 1d), new(2, 3, 2d)])), performanceIterations: 16);
    }
}
