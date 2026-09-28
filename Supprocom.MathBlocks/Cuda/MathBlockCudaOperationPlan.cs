using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Operation Plan contract.</summary>
/// <param name="OutputType">The output type value.</param>
/// <param name="OutputCapacity">The output capacity value.</param>
/// <param name="OutputRows">The output rows value.</param>
/// <param name="OutputColumns">The output columns value.</param>
/// <param name="ScratchBytes">The scratch bytes value.</param>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockCudaOperationPlan(
    MathBlockType OutputType,
    int OutputCapacity,
    int OutputRows,
    int OutputColumns,
    int ScratchBytes);
