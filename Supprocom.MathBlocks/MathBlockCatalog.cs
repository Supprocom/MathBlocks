namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Catalog contract.</summary>
public static class MathBlockCatalog
{
    private static readonly Lazy<MathBlockRegistry> standard = new(CreateStandard);
    private static readonly Lazy<MathBlockRegistry> windowed = new(CreateWindowed);
    private static readonly Lazy<MathBlockRegistry> elementwise = new(CreateElementwise);

    /// <summary>Gets the standard value.</summary>
    public static MathBlockRegistry Standard => standard.Value;

    /// <summary>Finds the vector operation that applies a <c>scalar.*</c> operation to every row.</summary>
    /// <remarks>
    /// The twin is <c>vector.&lt;name&gt;@1</c> when that pointwise operation exists with the same arity, and otherwise
    /// the elementwise form <c>elementwise.scalar.&lt;name&gt;@1</c>, which takes one more argument, the fill scalar.
    /// </remarks>
    /// <returns><see langword="true"/> when the scalar identity has a vector twin.</returns>
    public static bool TryGetVectorTwin(string scalarIdentity, out string vectorIdentity)
    {
        ArgumentNullException.ThrowIfNull(scalarIdentity);
        vectorIdentity = string.Empty;
        const string prefix = "scalar.";
        if (!scalarIdentity.StartsWith(prefix, StringComparison.Ordinal) || !scalarIdentity.EndsWith("@1", StringComparison.Ordinal))
            return false;
        var name = scalarIdentity[prefix.Length..^2];
        var pointwise = "vector." + name + "@1";
        var formIdentity = "elementwise.scalar." + name + "@1";
        MathBlockOperation? scalar = null;
        MathBlockOperation? vector = null;
        var hasElementwise = false;
        foreach (var operation in Standard.Operations)
        {
            if (string.Equals(operation.Identity, scalarIdentity, StringComparison.Ordinal))
                scalar = operation;
            else if (string.Equals(operation.Identity, pointwise, StringComparison.Ordinal))
                vector = operation;
            else if (string.Equals(operation.Identity, formIdentity, StringComparison.Ordinal))
                hasElementwise = true;
        }

        if (scalar is null)
            return false;
        if (vector is not null && vector.Arity == scalar.Arity && vector.Causality.Kind == MathBlockCausality.Pointwise)
        {
            vectorIdentity = pointwise;
            return true;
        }

        if (!hasElementwise)
            return false;
        vectorIdentity = formIdentity;
        return true;
    }

    /// <summary>Finds the elementwise form, with per-row validity, that applies a <c>scalar.*</c> operation to every row.</summary>
    /// <remarks>The form is <c>elementwise.scalar.&lt;name&gt;@1</c>. It takes the arguments of the scalar operation and one more, the fill scalar for rows that are not computed.</remarks>
    /// <returns><see langword="true"/> when the scalar identity has an elementwise form.</returns>
    public static bool TryGetElementwiseTwin(string scalarIdentity, out string elementwiseIdentity)
    {
        ArgumentNullException.ThrowIfNull(scalarIdentity);
        elementwiseIdentity = string.Empty;
        const string prefix = "scalar.";
        if (!scalarIdentity.StartsWith(prefix, StringComparison.Ordinal) || !scalarIdentity.EndsWith("@1", StringComparison.Ordinal))
            return false;
        var candidate = "elementwise." + scalarIdentity;
        var scalarFound = false;
        var formFound = false;
        foreach (var operation in Standard.Operations)
        {
            if (string.Equals(operation.Identity, scalarIdentity, StringComparison.Ordinal))
                scalarFound = true;
            else if (string.Equals(operation.Identity, candidate, StringComparison.Ordinal))
                formFound = true;
        }

        if (!scalarFound || !formFound)
            return false;
        elementwiseIdentity = candidate;
        return true;
    }

    // The window.*, window-valid.*, window-accurate.* and window-accurate-valid.* forms, generated from the
    // WindowMathBlocks and WindowAccurateMathBlocks tables. Standard registers these same instances.
    internal static MathBlockRegistry Windowed => windowed.Value;

    // The elementwise.* and elementwise-valid.* forms, generated from the ElementwiseMathBlocks table. Standard
    // registers these same instances.
    internal static MathBlockRegistry Elementwise => elementwise.Value;

    // The per-block operations, then the table-generated window and elementwise forms.
    private static MathBlockRegistry CreateStandard()
    {
        var operations = new List<MathBlockOperation>(MathBlockFeatureIndex.CreateOperations());
        operations.AddRange(Windowed.Operations);
        operations.AddRange(Elementwise.Operations);
        return new MathBlockRegistry(operations);
    }

    private static MathBlockRegistry CreateWindowed()
        => new(WindowMathBlocks.CreateOperations());

    private static MathBlockRegistry CreateElementwise()
        => new(ElementwiseMathBlocks.CreateOperations());
}
