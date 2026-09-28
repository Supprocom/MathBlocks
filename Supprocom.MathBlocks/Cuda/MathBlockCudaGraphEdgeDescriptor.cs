using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Graph Edge Descriptor contract.</summary>
[StructLayout(LayoutKind.Explicit, Size = MathBlockCudaGraphEdgeLayout.Size)]
public struct MathBlockCudaGraphEdgeDescriptor
{
    /// <summary>Gets the from value.</summary>
    [FieldOffset(MathBlockCudaGraphEdgeLayout.FromOffset)]
    public int From;

    /// <summary>Gets the to value.</summary>
    [FieldOffset(MathBlockCudaGraphEdgeLayout.ToOffset)]
    public int To;

    /// <summary>Gets the weight value.</summary>
    [FieldOffset(MathBlockCudaGraphEdgeLayout.WeightOffset)]
    public double Weight;
}
