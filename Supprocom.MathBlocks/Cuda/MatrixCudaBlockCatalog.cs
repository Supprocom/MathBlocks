namespace Supprocom.MathBlocks.Cuda;

internal static class MatrixCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_matrix";
    public static uint BlockSize => 128;
}
