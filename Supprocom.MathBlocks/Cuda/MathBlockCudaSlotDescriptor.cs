using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Slot Descriptor contract.</summary>
[StructLayout(LayoutKind.Explicit, Size = MathBlockCudaSlotLayout.Size)]
public struct MathBlockCudaSlotDescriptor
{
    /// <summary>Gets the scalar value value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.ScalarValueOffset)]
    public double ScalarValue;

    /// <summary>Gets the data pointer value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.DataPointerOffset)]
    public ulong DataPointer;

    /// <summary>Gets the scratch pointer value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.ScratchPointerOffset)]
    public ulong ScratchPointer;

    /// <summary>Gets the boolean value value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.BooleanValueOffset)]
    public int BooleanValue;

    /// <summary>Gets the valid value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.ValidOffset)]
    public int Valid;

    /// <summary>Gets the rows value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.RowsOffset)]
    public int Rows;

    /// <summary>Gets the columns value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.ColumnsOffset)]
    public int Columns;

    /// <summary>Gets the count value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.CountOffset)]
    public int Count;

    /// <summary>Gets the capacity value.</summary>
    [FieldOffset(MathBlockCudaSlotLayout.CapacityOffset)]
    public int Capacity;
}
