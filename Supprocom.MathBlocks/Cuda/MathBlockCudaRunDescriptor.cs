using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Run Descriptor contract.</summary>
[StructLayout(LayoutKind.Explicit, Size = MathBlockCudaRunLayout.Size)]
public struct MathBlockCudaRunDescriptor
{
    /// <summary>Gets the start value.</summary>
    [FieldOffset(MathBlockCudaRunLayout.StartOffset)]
    public int Start;

    /// <summary>Gets the length value.</summary>
    [FieldOffset(MathBlockCudaRunLayout.LengthOffset)]
    public int Length;

    /// <summary>Gets the value value.</summary>
    [FieldOffset(MathBlockCudaRunLayout.ValueOffset)]
    public double Value;
}
