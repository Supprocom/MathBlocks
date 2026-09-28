namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Slot Layout contract.</summary>
public static class MathBlockCudaSlotLayout
{
    /// <summary>Gets the size value.</summary>
    public const int Size = 48;
    /// <summary>Gets the scalar value offset value.</summary>
    public const int ScalarValueOffset = 0;
    /// <summary>Gets the data pointer offset value.</summary>
    public const int DataPointerOffset = 8;
    /// <summary>Gets the scratch pointer offset value.</summary>
    public const int ScratchPointerOffset = 16;
    /// <summary>Gets the boolean value offset value.</summary>
    public const int BooleanValueOffset = 24;
    /// <summary>Gets the valid offset value.</summary>
    public const int ValidOffset = 28;
    /// <summary>Gets the rows offset value.</summary>
    public const int RowsOffset = 32;
    /// <summary>Gets the columns offset value.</summary>
    public const int ColumnsOffset = 36;
    /// <summary>Gets the count offset value.</summary>
    public const int CountOffset = 40;
    /// <summary>Gets the capacity offset value.</summary>
    public const int CapacityOffset = 44;
}
