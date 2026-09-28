namespace Supprocom.MathBlocks.Cuda;

internal static class TransportCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_transport";
    public static uint BlockSize => 128;
}
