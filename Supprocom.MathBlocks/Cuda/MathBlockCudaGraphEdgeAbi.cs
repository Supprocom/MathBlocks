using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Graph Edge Abi contract.</summary>
/// <param name="Size">The size value.</param>
/// <param name="FromOffset">The from offset value.</param>
/// <param name="ToOffset">The to offset value.</param>
/// <param name="WeightOffset">The weight offset value.</param>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockCudaGraphEdgeAbi(
    int Size,
    int FromOffset,
    int ToOffset,
    int WeightOffset);
