using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Run Abi contract.</summary>
/// <param name="Size">The size value.</param>
/// <param name="StartOffset">The start offset value.</param>
/// <param name="LengthOffset">The length offset value.</param>
/// <param name="ValueOffset">The value offset value.</param>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockCudaRunAbi(
    int Size,
    int StartOffset,
    int LengthOffset,
    int ValueOffset);
