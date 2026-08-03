namespace Supprocom.MathBlocks;
internal static partial class AdvancedMathBlocks
{
    internal static class InequalityGiniCoefficientV1Block
    {
        internal const string Identity = "inequality.gini-coefficient@1";
        internal static MathBlockOperation Create() => CreateVectorScalar("inequality.gini-coefficient", MathBlockAdvanced.GiniCoefficient, MathBlockValue.Vector([1d, 3d]), 0.25d, DimensionlessScalar);
    }
}
