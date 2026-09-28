namespace Supprocom.MathBlocks.Cuda;

internal static class SequencePathCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_sequence_path";
    public static uint BlockSize => 128;
}
