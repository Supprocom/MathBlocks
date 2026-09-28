namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Contract Case contract.</summary>
public sealed class MathBlockCudaContractCase
{
    internal MathBlockCudaContractCase(
        string name,
        IReadOnlyList<MathBlockType> operandTypes,
        MathBlockCudaOperationPlan plan,
        string evidenceFingerprint)
    {
        Name = name;
        OperandTypes = operandTypes;
        Plan = plan;
        EvidenceFingerprint = evidenceFingerprint;
    }

    /// <summary>Gets the name value.</summary>
    public string Name { get; }
    /// <summary>Gets the operand types value.</summary>
    public IReadOnlyList<MathBlockType> OperandTypes { get; }
    /// <summary>Gets the plan value.</summary>
    public MathBlockCudaOperationPlan Plan { get; }
    /// <summary>Gets the evidence fingerprint value.</summary>
    public string EvidenceFingerprint { get; }
}
