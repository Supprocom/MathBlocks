namespace Supprocom.MathBlocks.Cuda;

internal static class AdvancedCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_advanced";
    public static uint BlockSize => 128;
}
