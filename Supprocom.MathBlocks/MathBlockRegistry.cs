using System.Security.Cryptography;
using System.Text;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Registry contract.</summary>
public sealed class MathBlockRegistry
{
    private readonly Dictionary<string, MathBlockOperation> operations;
    private readonly Lazy<string> causalityFingerprint;

    /// <summary>Indexes versioned operations by identifier.</summary>
    public MathBlockRegistry(IEnumerable<MathBlockOperation> operations)
    {
        ArgumentNullException.ThrowIfNull(operations);
        this.operations = new Dictionary<string, MathBlockOperation>(StringComparer.Ordinal);
        foreach (var operation in operations)
        {
            ArgumentNullException.ThrowIfNull(operation);
            if (!this.operations.TryAdd(operation.Identity, operation))
                throw new ArgumentException($"Duplicate MathBlock operation '{operation.Identity}'.", nameof(operations));
        }
        if (this.operations.Count == 0)
            throw new ArgumentException("The registry must contain an operation.", nameof(operations));
        var ordered = MathBlockCollectionPrimitives.CopyEnumerable(this.operations.Values);
        MathBlockCollectionPrimitives.StableMergeSort(
            ordered,
            (left, right) => StringComparer.Ordinal.Compare(left.Identity, right.Identity));
        Operations = Array.AsReadOnly(ordered);
        causalityFingerprint = new Lazy<string>(CreateCausalityFingerprint);
    }

    /// <summary>Gets the operations value.</summary>
    public IReadOnlyList<MathBlockOperation> Operations { get; }

    /// <summary>Gets the SHA-256 fingerprint of the registered operations' causality labels.</summary>
    /// <remarks>
    /// The material is one line <c>identity=kind</c> per operation, with <c>:</c> and the width input index appended
    /// for a Trailing label, sorted by ordinal comparison and each ended by a line feed. The value is the lowercase
    /// hexadecimal SHA-256 of its UTF-8 bytes. Operation fingerprints do not include causality labels.
    /// </remarks>
    /// <exception cref="InvalidOperationException">A registered operation has no causality label.</exception>
    public string CausalityFingerprint => causalityFingerprint.Value;

    /// <summary>Gets a registered operation by identifier and version.</summary>
    public MathBlockOperation Get(string identifier, int version = 1)
    {
        var identity = $"{identifier}@{version}";
        return operations.TryGetValue(identity, out var operation)
            ? operation
            : throw new KeyNotFoundException($"MathBlock operation '{identity}' is not registered.");
    }

    private string CreateCausalityFingerprint()
    {
        var lines = MathBlockCollectionPrimitives.Map(
            Operations,
            operation => $"{operation.Identity}={operation.Causality}");
        MathBlockCollectionPrimitives.StableMergeSort(lines, StringComparer.Ordinal.Compare);
        var builder = new StringBuilder();
        foreach (var line in lines)
            builder.Append(line).Append('\n');
        return Convert.ToHexStringLower(SHA256.HashData(Encoding.UTF8.GetBytes(builder.ToString())));
    }
}
