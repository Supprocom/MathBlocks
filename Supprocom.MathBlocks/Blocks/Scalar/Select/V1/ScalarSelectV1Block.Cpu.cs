namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarSelectV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreateSelect();
        private static MathBlockOperation CreateSelect() => MathBlockOperationFactory.Create("scalar.select", 3, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Boolean);
            return MathBlockTypeRules.SameBinary([types[1], types[2]], MathBlockValueKind.Scalar);
        }, inputs => inputs[0].AsBoolean() ? inputs[1] : inputs[2], [MathBlockValue.Boolean(true), MathBlockValue.Scalar(4d), MathBlockValue.Scalar(9d)], MathBlockValue.Scalar(4d), performanceIterations: 512);
    }
}
