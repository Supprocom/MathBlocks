using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Complex Value contract.</summary>
[StructLayout(LayoutKind.Sequential)]
public readonly struct MathBlockComplexValue : IEquatable<MathBlockComplexValue>
{
    /// <summary>Creates a complex value from real and imaginary components.</summary>
    public MathBlockComplexValue(double real, double imaginary)
    {
        Real = real;
        Imaginary = imaginary;
    }

    /// <summary>Gets the real value.</summary>
    public double Real { get; }
    /// <summary>Gets the imaginary value.</summary>
    public double Imaginary { get; }

    /// <summary>Compares both complex components for equality.</summary>
    public bool Equals(MathBlockComplexValue other) =>
        Real == other.Real && Imaginary == other.Imaginary;

    /// <summary>Compares this value with a boxed complex value.</summary>
    // Retain the published parameter name for named-argument source callers.
#pragma warning disable CA1725
    public override bool Equals(object? value) =>
        value is MathBlockComplexValue other && Equals(other);
#pragma warning restore CA1725

    /// <summary>Computes a hash from both complex components.</summary>
    public override int GetHashCode()
    {
        var real = Math.ToBits(Real);
        var imaginary = Math.ToBits(Imaginary);
        return unchecked(
            ((int)real ^ (int)(real >> 32)) * 397 ^
            (int)imaginary ^ (int)(imaginary >> 32));
    }

    /// <summary>Applies the <c>==</c> operator to MathBlocks values.</summary>
    public static bool operator ==(MathBlockComplexValue left, MathBlockComplexValue right) =>
        left.Equals(right);

    /// <summary>Applies the <c>!=</c> operator to MathBlocks values.</summary>
    public static bool operator !=(MathBlockComplexValue left, MathBlockComplexValue right) =>
        !left.Equals(right);
}
