namespace Supprocom.MathBlocks.Cuda;

internal static class ScalarCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_scalar";
}

internal static class VectorCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_vector";
    public static uint BlockSize => 128;
}

internal static class ComplexCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_complex";
    public static uint BlockSize => 128;
}

internal static class MatrixCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_matrix";
    public static uint BlockSize => 128;
}

internal static class ProbabilityCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_probability";
    public static uint BlockSize => 128;
}

internal static class SequencePathCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_sequence_path";
    public static uint BlockSize => 128;
}

internal static class StatisticsCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_statistics";
    public static uint BlockSize => 128;
}

internal static class GeometryCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_geometry";
    public static uint BlockSize => 128;
}

internal static class GraphCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_graph";
    public static uint BlockSize => 128;
}

internal static class AdvancedCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_advanced";
    public static uint BlockSize => 128;
}

internal static class TransportCudaBlockCatalog
{
    public static string KernelEntryPoint => "mathblocks_transport";
    public static uint BlockSize => 128;
}
