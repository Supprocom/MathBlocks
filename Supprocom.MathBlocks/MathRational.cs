using System.Globalization;
using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Rational contract.</summary>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathRational
{
    private readonly int denominator;

    /// <summary>Creates a normalized rational number.</summary>
    public MathRational(int numerator, int denominator = 1)
    {
        if (denominator == 0)
            throw new DivideByZeroException("A rational denominator cannot be zero.");
        var sign = denominator < 0 ? -1L : 1L;
        var normalizedNumerator = (long)numerator * sign;
        var normalizedDenominator = (long)denominator * sign;
        var divisor = GreatestCommonDivisor(Math.Abs(normalizedNumerator), normalizedDenominator);
        normalizedNumerator /= divisor;
        normalizedDenominator /= divisor;
        if (normalizedNumerator is < int.MinValue or > int.MaxValue ||
            normalizedDenominator is < 1 or > int.MaxValue)
        {
            throw new OverflowException("The normalized rational value is outside the supported range.");
        }
        Numerator = (int)normalizedNumerator;
        this.denominator = normalizedNumerator == 0 ? 0 : (int)normalizedDenominator;
    }

    /// <summary>Gets the numerator value.</summary>
    public int Numerator { get; }
    /// <summary>Gets the denominator value.</summary>
    public int Denominator => denominator == 0 ? 1 : denominator;
    /// <summary>Gets the is zero value.</summary>
    public bool IsZero => Numerator == 0;

    /// <summary>Gets the rational value zero.</summary>
    public static MathRational Zero => new(0);
    /// <summary>Gets the rational value one.</summary>
    public static MathRational One => new(1);

    /// <summary>Applies the <c>+</c> operator to MathBlocks values.</summary>
    public static MathRational operator +(MathRational left, MathRational right) =>
        CreateChecked(
            (long)left.Numerator * right.Denominator + (long)right.Numerator * left.Denominator,
            (long)left.Denominator * right.Denominator);

    /// <summary>Applies the <c>-</c> operator to MathBlocks values.</summary>
    public static MathRational operator -(MathRational left, MathRational right) =>
        CreateChecked(
            (long)left.Numerator * right.Denominator - (long)right.Numerator * left.Denominator,
            (long)left.Denominator * right.Denominator);

    /// <summary>Applies the <c>*</c> operator to MathBlocks values.</summary>
    public static MathRational operator *(MathRational left, MathRational right) =>
        CreateChecked(
            (long)left.Numerator * right.Numerator,
            (long)left.Denominator * right.Denominator);

    /// <summary>Adds two rational values with overflow checking.</summary>
    public static MathRational Add(MathRational left, MathRational right) => left + right;

    /// <summary>Subtracts the second rational value from the first.</summary>
    public static MathRational Subtract(MathRational left, MathRational right) => left - right;

    /// <summary>Multiplies two rational values with overflow checking.</summary>
    public static MathRational Multiply(MathRational left, MathRational right) => left * right;

    /// <summary>Formats the normalized numerator and denominator.</summary>
    public override string ToString() => Denominator == 1
        ? Numerator.ToString(CultureInfo.InvariantCulture)
        : $"{Numerator.ToString(CultureInfo.InvariantCulture)}/{Denominator.ToString(CultureInfo.InvariantCulture)}";

    private static MathRational CreateChecked(long numerator, long denominator)
    {
        var divisor = GreatestCommonDivisor(Math.Abs(numerator), Math.Abs(denominator));
        numerator /= divisor;
        denominator /= divisor;
        if (denominator < 0)
        {
            numerator = -numerator;
            denominator = -denominator;
        }
        if (numerator is < int.MinValue or > int.MaxValue || denominator is < 1 or > int.MaxValue)
            throw new OverflowException("The rational operation exceeded the supported range.");
        return new MathRational((int)numerator, (int)denominator);
    }

    private static long GreatestCommonDivisor(long left, long right)
    {
        if (left == 0)
            return right == 0 ? 1 : right;
        while (right != 0)
            (left, right) = (right, left % right);
        return left;
    }
}
