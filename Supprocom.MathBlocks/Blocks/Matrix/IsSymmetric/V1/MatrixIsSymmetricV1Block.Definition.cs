namespace Supprocom.MathBlocks;
internal static partial class MatrixMathBlocks
{
    internal static class MatrixIsSymmetricV1Block
    {
        internal const string Identity = "matrix.is-symmetric@1";
        internal static MathBlockOperation Create() => MatrixIsSymmetricV1BlockCpu.Create();
    }
}
