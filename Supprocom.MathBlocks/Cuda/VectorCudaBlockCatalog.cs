namespace Supprocom.MathBlocks.Cuda;

internal static class VectorCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_vector";
    public static uint BlockSize => 128;
}
