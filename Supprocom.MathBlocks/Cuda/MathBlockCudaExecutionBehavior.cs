namespace Supprocom.MathBlocks.Cuda;

/// <summary>Defines the Math Block Cuda Execution Behavior contract.</summary>
public enum MathBlockCudaExecutionBehavior
{
    /// <summary>Identifies the <c>SingleThread</c> value.</summary>
    SingleThread,
    /// <summary>Identifies the <c>CooperativeBlock</c> value.</summary>
    CooperativeBlock
}
