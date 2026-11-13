namespace Supprocom.MathBlocks;

/// <summary>Identifies how a <see cref="MathBlockTypeSignature"/> computes its output type.</summary>
/// <remarks>The values are the rule numbers of the signature table and of the CUDA type-rule module; they never change.</remarks>
public enum MathBlockTypeRuleKind
{
    /// <summary>No rule: the table has no row for the operation.</summary>
    None = 0,
    /// <summary>
    /// The output kind, shape and unit follow from the operand types by the parameters:
    /// outputKind, shapeMode, shapeA, shapeB, unitMode, unitA, unitB, exponentNumerator, exponentDenominator.
    /// </summary>
    Composed = 1,
    /// <summary>
    /// The elementwise form of a scalar operation, or its validity sibling. The parameters are the validity flag and the
    /// embedded signature row of the lifted operation.
    /// </summary>
    ElementwiseForm = 2,
    /// <summary>
    /// The trailing-window form of a series operation, or its validity sibling. The parameters are the validity flag, the
    /// last-row flag, the series operand mask and the embedded signature row of the lifted operation.
    /// </summary>
    WindowForm = 3
}
