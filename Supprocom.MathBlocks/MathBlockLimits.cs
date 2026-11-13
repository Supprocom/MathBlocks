using System.Text.Json;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

/// <summary>Lists the limits of the library and of each operation.</summary>
public static class MathBlockLimits
{
    /// <summary>Returns every limit, resolved against the given CUDA options and domain options (<see cref="MathBlocksCudaOptions.Default"/> and <see cref="MathBlockDomainOptions.Default"/> when null).</summary>
    public static IReadOnlyList<MathBlockLimit> Resolve(MathBlocksCudaOptions? cuda = null, MathBlockDomainOptions? domain = null)
        => throw new NotSupportedException("Not implemented yet.");

    /// <summary>Returns the global limits that apply to an operation and the limits of the operation itself.</summary>
    public static IReadOnlyList<MathBlockLimit> For(string operationIdentity, MathBlocksCudaOptions? cuda = null, MathBlockDomainOptions? domain = null)
        => throw new NotSupportedException("Not implemented yet.");

    /// <summary>Writes the limits as a JSON array with stable field names and order.</summary>
    public static void WriteJson(Utf8JsonWriter writer, IReadOnlyList<MathBlockLimit> limits)
        => throw new NotSupportedException("Not implemented yet.");
}
