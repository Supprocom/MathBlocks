namespace Supprocom.MathBlocks.Cuda;

internal static class GeometryCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_geometry";
    public static uint BlockSize => 128;
}
