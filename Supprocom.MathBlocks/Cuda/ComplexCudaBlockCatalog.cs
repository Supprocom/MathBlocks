namespace Supprocom.MathBlocks.Cuda;

internal static class ComplexCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_complex";
    public static uint BlockSize => 128;
}
