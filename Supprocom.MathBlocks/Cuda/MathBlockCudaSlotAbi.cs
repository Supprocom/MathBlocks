using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Slot Abi contract.</summary>
/// <param name="Size">The size value.</param>
/// <param name="ScalarValueOffset">The scalar value offset value.</param>
/// <param name="DataPointerOffset">The data pointer offset value.</param>
/// <param name="ScratchPointerOffset">The scratch pointer offset value.</param>
/// <param name="BooleanValueOffset">The boolean value offset value.</param>
/// <param name="ValidOffset">The valid offset value.</param>
/// <param name="RowsOffset">The rows offset value.</param>
/// <param name="ColumnsOffset">The columns offset value.</param>
/// <param name="CountOffset">The count offset value.</param>
/// <param name="CapacityOffset">The capacity offset value.</param>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockCudaSlotAbi(
    int Size,
    int ScalarValueOffset,
    int DataPointerOffset,
    int ScratchPointerOffset,
    int BooleanValueOffset,
    int ValidOffset,
    int RowsOffset,
    int ColumnsOffset,
    int CountOffset,
    int CapacityOffset);
