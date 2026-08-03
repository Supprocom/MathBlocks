namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class PathPowerVariationV1BlockCpu
    {
        internal static MathBlockOperation Create() => CreatePowerVariation();
        private static MathBlockOperation CreatePowerVariation() => MathBlockOperationFactory.Create("path.power-variation", 2, types =>
        {
            MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Vector);
            MathBlockTypeRules.RequireKind(types[1], MathBlockValueKind.Scalar);
            MathBlockTypeRules.RequireDimensionless(types[1]);
            MathBlockTypeRules.RequireDimensionless(types[0]);
            return MathBlockType.Scalar();
        }, inputs => inputs[0].AsVector().Count > 0 && inputs[1].AsScalar() > 0d ? MathBlockValue.Scalar(MathBlockPath.PowerVariation(inputs[0].AsVector(), inputs[1].AsScalar())) : MathBlockValue.Invalid(MathBlockType.Scalar(), "The inputs are outside the operation domain."), [path, MathBlockValue.Scalar(2d)], MathBlockValue.Scalar(14d), performanceIterations: 16);
    }
}
