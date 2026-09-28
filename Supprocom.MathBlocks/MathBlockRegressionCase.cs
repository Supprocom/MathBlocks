namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Regression Case contract.</summary>
public sealed class MathBlockRegressionCase
{
    /// <summary>Defines one input and expected-result case for an operation.</summary>
    public MathBlockRegressionCase(
        string name,
        IEnumerable<MathBlockValue> inputs,
        MathBlockValue expected,
        double tolerance = 1e-10)
    {
        Name = RequireText(name, nameof(name));
        ArgumentNullException.ThrowIfNull(inputs);
        Inputs = Array.AsReadOnly(MathBlockCollectionPrimitives.CopyEnumerable(inputs));
        Expected = expected;
        if (!Math.IsFinite(tolerance) || tolerance < 0d)
            throw new ArgumentOutOfRangeException(nameof(tolerance));
        Tolerance = tolerance;
    }

    /// <summary>Gets the name value.</summary>
    public string Name { get; }
    /// <summary>Gets the inputs value.</summary>
    public IReadOnlyList<MathBlockValue> Inputs { get; }
    /// <summary>Gets the expected value.</summary>
    public MathBlockValue Expected { get; }
    /// <summary>Gets the tolerance value.</summary>
    public double Tolerance { get; }

    private static string RequireText(string value, string parameterName) =>
        string.IsNullOrWhiteSpace(value)
            ? throw new ArgumentException("A nonempty value is required.", parameterName)
            : value.Trim();
}
