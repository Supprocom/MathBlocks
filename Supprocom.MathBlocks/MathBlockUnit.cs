using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Represents four rational physical-dimension exponents.</summary>
/// <param name="Dimension0">The dimension0 value.</param>
/// <param name="Dimension1">The dimension1 value.</param>
/// <param name="Dimension2">The dimension2 value.</param>
/// <param name="Dimension3">The dimension3 value.</param>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockUnit(
    MathRational Dimension0,
    MathRational Dimension1,
    MathRational Dimension2,
    MathRational Dimension3)
{
    /// <summary>Gets the unit with no physical dimensions.</summary>
    public static MathBlockUnit Dimensionless => default;
    /// <summary>Gets the first base dimension.</summary>
    public static MathBlockUnit Basis0 => new(MathRational.One, default, default, default);
    /// <summary>Gets the second base dimension.</summary>
    public static MathBlockUnit Basis1 => new(default, MathRational.One, default, default);
    /// <summary>Gets the third base dimension.</summary>
    public static MathBlockUnit Basis2 => new(default, default, MathRational.One, default);
    /// <summary>Gets the fourth base dimension.</summary>
    public static MathBlockUnit Basis3 => new(default, default, default, MathRational.One);

    /// <summary>Gets whether all dimension exponents are zero.</summary>
    public bool IsDimensionless =>
        Dimension0.IsZero && Dimension1.IsZero && Dimension2.IsZero && Dimension3.IsZero;

    /// <summary>Multiplies units by adding their dimension exponents.</summary>
    public MathBlockUnit Multiply(MathBlockUnit other) => new(
        Dimension0 + other.Dimension0,
        Dimension1 + other.Dimension1,
        Dimension2 + other.Dimension2,
        Dimension3 + other.Dimension3);

    /// <summary>Divides units by subtracting their dimension exponents.</summary>
    public MathBlockUnit Divide(MathBlockUnit other) => new(
        Dimension0 - other.Dimension0,
        Dimension1 - other.Dimension1,
        Dimension2 - other.Dimension2,
        Dimension3 - other.Dimension3);

    /// <summary>Raises a unit to a rational exponent.</summary>
    public MathBlockUnit Pow(MathRational exponent) => new(
        Dimension0 * exponent,
        Dimension1 * exponent,
        Dimension2 * exponent,
        Dimension3 * exponent);

    /// <summary>Formats the four dimension exponents for diagnostics.</summary>
    public override string ToString() =>
        $"d0^{Dimension0}|d1^{Dimension1}|d2^{Dimension2}|d3^{Dimension3}";
}
