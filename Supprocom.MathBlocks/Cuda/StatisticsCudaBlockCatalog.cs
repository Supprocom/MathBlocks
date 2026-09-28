namespace Supprocom.MathBlocks.Cuda;

internal static class StatisticsCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_statistics";
    public static uint BlockSize => 128;
}
