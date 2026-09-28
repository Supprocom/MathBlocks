using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Point contract.</summary>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockPoint(double X, double Y)
{
    /// <summary>Validates the supplied MathBlocks value or interchange document.</summary>
    public MathBlockPoint Validate()
    {
        if (!Math.IsFinite(X) || !Math.IsFinite(Y))
            throw new InvalidDataException("A point must contain finite coordinates.");
        return this;
    }
}
