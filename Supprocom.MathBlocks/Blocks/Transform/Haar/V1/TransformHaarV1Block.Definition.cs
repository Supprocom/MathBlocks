namespace Supprocom.MathBlocks;
internal static partial class PathMathBlocks
{
    internal static class TransformHaarV1Block
    {
        internal const string Identity = "transform.haar@1";
        internal static MathBlockOperation Create() => CreatePathVector("transform.haar", MathBlockPath.HaarTransform, MathBlockValue.Vector([1d, 1d, 1d, 1d]), [2d, 0d, 0d, 0d], SameUnitVector);
    }
}
