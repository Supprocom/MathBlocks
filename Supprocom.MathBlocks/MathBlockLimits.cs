using System.Text.Json;
using Supprocom.MathBlocks.Cuda;

namespace Supprocom.MathBlocks;

/// <summary>Lists the limits of the library and of each operation.</summary>
public static class MathBlockLimits
{
    /// <summary>Returns every limit, resolved against the given CUDA options and domain options (<see cref="MathBlocksCudaOptions.Default"/> and <see cref="MathBlockDomainOptions.Default"/> when null).</summary>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range the limit it sets allows.</exception>
    public static IReadOnlyList<MathBlockLimit> Resolve(MathBlocksCudaOptions? cuda = null, MathBlockDomainOptions? domain = null)
        => MathBlockLimitCatalog.Resolve(cuda ?? MathBlocksCudaOptions.Default, domain ?? MathBlockDomainOptions.Default);

    /// <summary>Returns the global limits that apply to an operation and the limits of the operation itself.</summary>
    /// <exception cref="ArgumentException">No operation has the identity.</exception>
    /// <exception cref="ArgumentOutOfRangeException">An option is outside the range the limit it sets allows.</exception>
    public static IReadOnlyList<MathBlockLimit> For(string operationIdentity, MathBlocksCudaOptions? cuda = null, MathBlockDomainOptions? domain = null)
    {
        ArgumentNullException.ThrowIfNull(operationIdentity);
        RequireOperation(operationIdentity);
        return MathBlockLimitCatalog.For(operationIdentity, cuda ?? MathBlocksCudaOptions.Default, domain ?? MathBlockDomainOptions.Default);
    }

    /// <summary>Writes the limits as a JSON array with stable field names and order.</summary>
    /// <remarks>Each object has the fields name, operation, kind, device, minimum, maximum, value, unit, option, drivenBy and rule, in that order. Kind and device are the enum member names; absent values are null.</remarks>
    public static void WriteJson(Utf8JsonWriter writer, IReadOnlyList<MathBlockLimit> limits)
    {
        ArgumentNullException.ThrowIfNull(writer);
        ArgumentNullException.ThrowIfNull(limits);
        writer.WriteStartArray();
        foreach (var limit in limits)
        {
            writer.WriteStartObject();
            writer.WriteString("name", limit.Name);
            WriteOptionalString(writer, "operation", limit.Operation);
            writer.WriteString("kind", limit.Kind.ToString());
            writer.WriteString("device", limit.Device.ToString());
            WriteOptionalNumber(writer, "minimum", limit.Minimum);
            WriteOptionalNumber(writer, "maximum", limit.Maximum);
            WriteOptionalNumber(writer, "value", limit.Value);
            writer.WriteString("unit", limit.Unit);
            WriteOptionalString(writer, "option", limit.Option);
            writer.WriteStartArray("drivenBy");
            foreach (var driver in limit.DrivenBy)
                writer.WriteStringValue(driver);
            writer.WriteEndArray();
            writer.WriteString("rule", limit.Rule);
            writer.WriteEndObject();
        }

        writer.WriteEndArray();
    }

    private static void RequireOperation(string operationIdentity)
    {
        foreach (var operation in MathBlockCatalog.Standard.Operations)
        {
            if (string.Equals(operation.Identity, operationIdentity, StringComparison.Ordinal))
                return;
        }

        throw new ArgumentException($"No operation has the identity '{operationIdentity}'.", nameof(operationIdentity));
    }

    private static void WriteOptionalString(Utf8JsonWriter writer, string name, string? value)
    {
        if (value is null)
            writer.WriteNull(name);
        else
            writer.WriteString(name, value);
    }

    private static void WriteOptionalNumber(Utf8JsonWriter writer, string name, long? value)
    {
        if (value is { } number)
            writer.WriteNumber(name, number);
        else
            writer.WriteNull(name);
    }
}
