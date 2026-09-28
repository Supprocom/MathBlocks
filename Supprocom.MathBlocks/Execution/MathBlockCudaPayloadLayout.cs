namespace Supprocom.MathBlocks.Cuda;

internal readonly record struct MathBlockCudaPayloadLayout(
    int[] Capacities,
    int[] ShapeRows,
    int[] ShapeColumns,
    MathBlockValue?[] ExactValues,
    MathBlockType[] ResolvedTypes);
