namespace Supprocom.MathBlocks;

internal static partial class PathMathBlocks
{
    internal static class PathRunLengthEncodeV1Block
    {
        internal const string Identity = "path.run-length-encode@1";
        internal static readonly MathBlockCausalityInfo Causality = MathBlockCausalityInfo.WholeSeries;
        internal static MathBlockOperation Create() => CreateRunLength();
        private static MathBlockOperation CreateRunLength() => MathBlockOperationFactory.Create("path.run-length-encode", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.RunSet(types[0].Unit);
        }, inputs => MathBlockValue.RunSet(MathBlockPath.RunLengthEncode(inputs[0].AsVector()), inputs[0].Type.Unit), [MathBlockValue.Vector([1f, 1f, 2f, 2f, 2f])], MathBlockValue.RunSet(new MathBlockRunSet([new(0, 2, 1f), new(2, 3, 2f)])), performanceIterations: 16);
    }
}
