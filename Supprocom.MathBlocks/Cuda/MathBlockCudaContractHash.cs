using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks.Cuda;

internal static class MathBlockCudaContractHash
{
    public static string Create(string value) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(value)));

    public static unsafe string CreateValue(MathBlockValue value)
    {
        var capacity = value.IsValid ? MathBlockCudaValueCodec.GetElementCount(value) : 0;
        var payloadBytes = MathBlockCudaValueCodec.GetPayloadByteCount(value.Type.Kind, capacity);
        var byteCount = checked(MathBlockCudaSlotLayout.Size + payloadBytes);
        var arena = Marshal.AllocHGlobal(byteCount);
        try
        {
            new Span<byte>((void*)arena, byteCount).Clear();
            MathBlockCudaValueCodec.WriteValue(
                arena,
                0,
                payloadBytes == 0 ? -1 : MathBlockCudaSlotLayout.Size,
                0ul,
                0ul,
                capacity,
                value);
            var bytes = new byte[byteCount];
            Marshal.Copy(arena, bytes, 0, byteCount);
            return Convert.ToHexString(SHA256.HashData(bytes));
        }
        finally
        {
            Marshal.FreeHGlobal(arena);
        }
    }

    public static string CreateImplementation(Type type) =>
        Create(MathBlockCudaCanonicalIl.CreateImplementationMaterial(type));
}
