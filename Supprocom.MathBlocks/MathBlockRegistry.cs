namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Registry contract.</summary>
public sealed class MathBlockRegistry
{
    private readonly Dictionary<string, MathBlockOperation> operations;

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
    }

    /// <summary>Gets the operations value.</summary>
    public IReadOnlyList<MathBlockOperation> Operations { get; }

    /// <summary>Gets a registered operation by identifier and version.</summary>
    public MathBlockOperation Get(string identifier, int version = 1)
    {
        var identity = $"{identifier}@{version}";
        return operations.TryGetValue(identity, out var operation)
            ? operation
            : throw new KeyNotFoundException($"MathBlock operation '{identity}' is not registered.");
    }
}
