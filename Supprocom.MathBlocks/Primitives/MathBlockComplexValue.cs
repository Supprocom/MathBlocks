namespace Supprocom.MathBlocks;

public readonly struct MathBlockComplexValue : IEquatable<MathBlockComplexValue>
{
    public MathBlockComplexValue(double real, double imaginary)
    {
        Real = real;
        Imaginary = imaginary;
    }

    public double Real { get; }
    public double Imaginary { get; }

    public bool Equals(MathBlockComplexValue other) =>
        Real == other.Real && Imaginary == other.Imaginary;

    public override bool Equals(object? value) =>
        value is MathBlockComplexValue other && Equals(other);

    public override int GetHashCode()
    {
        var real = Math.ToBits(Real);
        var imaginary = Math.ToBits(Imaginary);
        return unchecked(
            ((int)real ^ (int)(real >> 32)) * 397 ^
            (int)imaginary ^ (int)(imaginary >> 32));
    }

    public static bool operator ==(MathBlockComplexValue left, MathBlockComplexValue right) =>
        left.Equals(right);

    public static bool operator !=(MathBlockComplexValue left, MathBlockComplexValue right) =>
        !left.Equals(right);
}
