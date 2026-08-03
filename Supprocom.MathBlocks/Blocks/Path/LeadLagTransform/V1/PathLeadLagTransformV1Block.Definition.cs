namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathLeadLagTransformV1Block
    {
        internal const string Identity = "path.lead-lag-transform@1";
        internal static MathBlockOperation Create() => CreateLeadLag();
        private static MathBlockOperation CreateLeadLag() => MathBlockOperationFactory.Create("path.lead-lag-transform", 1, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            return MathBlockType.Matrix(types[0].Unit, columns: 2);
        }, inputs => inputs[0].AsVector().Count > 0 ? MathBlockValue.Matrix(MathBlockPath.LeadLagTransform(inputs[0].AsVector()), inputs[0].Type.Unit) : MathBlockValue.Invalid(MathBlockType.Matrix(inputs[0].Type.Unit, columns: 2), "The path is empty."), [MathBlockValue.Vector([1d, 2d])], MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [1d, 1d, 2d, 1d, 2d, 2d])), performanceIterations: 8);
    }
}
