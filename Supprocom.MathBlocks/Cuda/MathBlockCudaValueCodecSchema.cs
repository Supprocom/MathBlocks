namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Value Codec Schema contract.</summary>
/// <param name="Version">The version value.</param>
/// <param name="Definition">The definition value.</param>
public readonly record struct MathBlockCudaValueCodecSchema(
    int Version,
    string Definition)
{
    /// <summary>Gets the fingerprint of the versioned CUDA value-codec schema.</summary>
    public string Fingerprint => MathBlockCudaContractHash.Create(
        "mathblocks-cuda-value-codec-schema\n" +
        Version.ToString(System.Globalization.CultureInfo.InvariantCulture) + "\n" +
        Definition + "\n");
}
