using System.Globalization;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Device Abi contract.</summary>
/// <param name="Version">The version value.</param>
/// <param name="DispatcherBlockSize">The dispatcher block size value.</param>
/// <param name="DispatchFunctionName">The dispatch function name value.</param>
/// <param name="DispatchSignature">The dispatch signature value.</param>
/// <param name="Slot">The slot value.</param>
/// <param name="GraphEdge">The graph edge value.</param>
/// <param name="Run">The run value.</param>
/// <param name="ValueCodecSchema">The value codec schema value.</param>
/// <param name="ValueCodecImplementationFingerprint">The value codec implementation fingerprint value.</param>
/// <param name="SourceFingerprint">The source fingerprint value.</param>
/// <param name="OperationTableFingerprint">The operation table fingerprint value.</param>
public readonly record struct MathBlockCudaDeviceAbi(
    int Version,
    int DispatcherBlockSize,
    string DispatchFunctionName,
    string DispatchSignature,
    MathBlockCudaSlotAbi Slot,
    MathBlockCudaGraphEdgeAbi GraphEdge,
    MathBlockCudaRunAbi Run,
    MathBlockCudaValueCodecSchema ValueCodecSchema,
    string ValueCodecImplementationFingerprint,
    string SourceFingerprint,
    string OperationTableFingerprint)
{
    /// <summary>Gets the fingerprint of the CUDA device ABI contract.</summary>
    public string Fingerprint => MathBlockCudaContractHash.Create(CreateFingerprintMaterial());

    private string CreateFingerprintMaterial()
    {
        var builder = new StringBuilder("mathblocks-cuda-device-abi-v2\n");
        Append(builder, Version);
        Append(builder, DispatcherBlockSize);
        Append(builder, DispatchFunctionName);
        Append(builder, DispatchSignature);
        Append(builder, Slot.Size);
        Append(builder, Slot.ScalarValueOffset);
        Append(builder, Slot.DataPointerOffset);
        Append(builder, Slot.ScratchPointerOffset);
        Append(builder, Slot.BooleanValueOffset);
        Append(builder, Slot.ValidOffset);
        Append(builder, Slot.RowsOffset);
        Append(builder, Slot.ColumnsOffset);
        Append(builder, Slot.CountOffset);
        Append(builder, Slot.CapacityOffset);
        Append(builder, GraphEdge.Size);
        Append(builder, GraphEdge.FromOffset);
        Append(builder, GraphEdge.ToOffset);
        Append(builder, GraphEdge.WeightOffset);
        Append(builder, Run.Size);
        Append(builder, Run.StartOffset);
        Append(builder, Run.LengthOffset);
        Append(builder, Run.ValueOffset);
        Append(builder, ValueCodecSchema.Version);
        Append(builder, ValueCodecSchema.Fingerprint);
        Append(builder, ValueCodecImplementationFingerprint);
        Append(builder, SourceFingerprint);
        Append(builder, OperationTableFingerprint);
        return builder.ToString();
    }

    private static void Append(StringBuilder builder, int value) =>
        builder.Append(value.ToString(CultureInfo.InvariantCulture)).Append('\n');

    private static void Append(StringBuilder builder, string value) =>
        builder.Append(value).Append('\n');
}
