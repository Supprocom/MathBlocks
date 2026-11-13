using System.Text.Json;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

/// <summary>Lists the limits of the library and of each operation.</summary>
public static class MathBlockLimits
{
    /// <summary>Returns every limit, resolved against the given CUDA options (<see cref="MathBlocksCudaOptions.Default"/> when null).</summary>
    public static IReadOnlyList<MathBlockLimit> Resolve(MathBlocksCudaOptions? options = null)
        => throw new NotSupportedException("Not implemented yet.");

    /// <summary>Returns the global limits that apply to an operation and the limits of the operation itself.</summary>
    public static IReadOnlyList<MathBlockLimit> For(string operationIdentity, MathBlocksCudaOptions? options = null)
        => throw new NotSupportedException("Not implemented yet.");

    /// <summary>Writes the limits as a JSON array with stable field names and order.</summary>
    public static void WriteJson(Utf8JsonWriter writer, IReadOnlyList<MathBlockLimit> limits)
        => throw new NotSupportedException("Not implemented yet.");
}
