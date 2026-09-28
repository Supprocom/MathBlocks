namespace Supprocom.MathBlocks.Cuda;

internal static class ProbabilityCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_probability";
    public static uint BlockSize => 128;
}
