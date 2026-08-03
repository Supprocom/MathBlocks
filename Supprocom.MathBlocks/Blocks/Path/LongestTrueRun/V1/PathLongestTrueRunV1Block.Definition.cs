namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathLongestTrueRunV1Block
    {
        internal const string Identity = "path.longest-true-run@1";
        internal static MathBlockOperation Create() => CreateLongestRun();
        private static MathBlockOperation CreateLongestRun() => MathBlockOperationFactory.Create("path.longest-true-run", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.BooleanVector);
            return MathBlockType.Scalar();
        }, inputs => MathBlockValue.Scalar(MathBlockPath.LongestTrueRun(inputs[0].AsBooleanVector())), [MathBlockValue.BooleanVector([true, true, false, true ])], MathBlockValue.Scalar(2d), performanceIterations: 16);
    }
}
