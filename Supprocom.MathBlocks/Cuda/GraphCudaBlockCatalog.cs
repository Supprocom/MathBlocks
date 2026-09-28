namespace Supprocom.MathBlocks.Cuda;

internal static class GraphCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_graph";
    public static uint BlockSize => 128;
}
