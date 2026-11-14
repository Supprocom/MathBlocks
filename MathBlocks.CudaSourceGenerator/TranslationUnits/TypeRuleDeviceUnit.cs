#pragma warning disable CS0078, CS0649

using Supprocom.CSharp2CUDA;

// The CUDA entry point of the type-rule module. Only MathBlocks.CudaSourceGenerator compiles this file, next to
// TypeRuleUnit.cs, so the CSharp2CUDA attributes come from the package and never reach Supprocom.MathBlocks.
[TranspileToCUDA]
internal static unsafe class MathBlockTypeRuleDevice
{
    [CudaDevice(Name = "mathblocks_type_resolve")]
    private static void Resolve(
        [CudaReadOnly] int* signature_row,
        [CudaReadOnly] MathBlockTypeRuleModule.MathBlockDeviceType* inputs,
        int count,
        MathBlockTypeRuleModule.MathBlockDeviceType* output)
    {
        // The helpers take plain pointers because the transpiler keeps no read-only qualifier on them; they never write through
        // these two. The round trip through an integer drops the qualifier the entry's own parameters carry.
        MathBlockTypeRuleModule.ResolveStatus(
            (int*)(ulong)signature_row,
            (MathBlockTypeRuleModule.MathBlockDeviceType*)(ulong)inputs,
            count,
            output);
    }
}
