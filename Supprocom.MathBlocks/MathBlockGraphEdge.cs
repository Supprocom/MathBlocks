using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Graph Edge contract.</summary>
[StructLayout(LayoutKind.Sequential)]
public readonly record struct MathBlockGraphEdge(int From, int To, double Weight)
{
    /// <summary>Validates the supplied MathBlocks value or interchange document.</summary>
    public MathBlockGraphEdge Validate(int vertexCount)
    {
        if ((uint)From >= (uint)vertexCount || (uint)To >= (uint)vertexCount)
            throw new InvalidDataException("A graph edge has invalid vertices.");
        if (!Math.IsFinite(Weight))
            throw new InvalidDataException("A graph edge must have a finite weight.");
        return this;
    }
}
