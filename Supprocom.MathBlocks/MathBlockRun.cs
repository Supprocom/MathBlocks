using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Run contract.</summary>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockRun(int Start, int Length, double Value)
{
    /// <summary>Validates the supplied MathBlocks value or interchange document.</summary>
    public MathBlockRun Validate()
    {
        if (Start < 0 || Length <= 0 || !Math.IsFinite(Value))
            throw new InvalidDataException("A run has invalid state.");
        return this;
    }
}
