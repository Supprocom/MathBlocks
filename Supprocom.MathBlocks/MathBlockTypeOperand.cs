namespace Supprocom.MathBlocks;

/// <summary>Describes what one operand of a <see cref="MathBlockTypeSignature"/> accepts.</summary>
/// <param name="AcceptedKindMask">The accepted <see cref="MathBlockValueKind"/> values, as a mask with bit 1 shifted by the kind value.</param>
/// <param name="UnitConstraint"><see cref="MathBlockTypeOperand.AnyUnit"/>, <see cref="MathBlockTypeOperand.DimensionlessUnit"/>, or the index of an earlier operand whose unit this operand must equal.</param>
/// <param name="IsConstant">Whether the operand is a constant slot: its value, when the program supplies a constant, refines the output shape.</param>
public sealed record MathBlockTypeOperand(int AcceptedKindMask, int UnitConstraint, bool IsConstant)
{
    /// <summary>The unit constraint that accepts every unit.</summary>
    public const int AnyUnit = -1;
    /// <summary>The unit constraint that requires a dimensionless unit.</summary>
    public const int DimensionlessUnit = -2;

    /// <summary>Gets the mask of a single kind.</summary>
    public static int KindBit(MathBlockValueKind kind) => 1 << (int)kind;

    /// <summary>Tests whether the operand accepts a kind.</summary>
    public bool Accepts(MathBlockValueKind kind) => ((AcceptedKindMask >> (int)kind) & 1) != 0;
}
