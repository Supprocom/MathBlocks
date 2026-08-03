namespace Supprocom.MathBlocks;
internal static partial class ScalarMathBlocks
{
    internal static class ScalarClampV1Block
    {
        internal const string Identity = "scalar.clamp@1";
        internal static MathBlockOperation Create() => CreateClamp();
        private static MathBlockOperation CreateClamp() => MathBlockOperationFactory.Create("scalar.clamp", 3, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireKind(types[2], MathBlockValueKind.Scalar);
            if (types[0].Unit != types[1].Unit || types[0].Unit != types[2].Unit)
                throw new InvalidOperationException("The input units must be equal.");
            return types[0];
        }, inputs => MathBlockValue.Scalar(MathBlockScalar.Clamp(inputs[0].AsScalar(), inputs[1].AsScalar(), inputs[2].AsScalar()), inputs[0].Type.Unit), [MathBlockValue.Scalar(5d), MathBlockValue.Scalar(0d), MathBlockValue.Scalar(3d)], MathBlockValue.Scalar(3d), performanceIterations: 512);
    }
}
