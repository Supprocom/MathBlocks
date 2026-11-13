namespace Supprocom.MathBlocks;

/// <summary>Chooses what an iterative closed-form computation returns when it stops at its iteration budget without converging.</summary>
public enum MathBlockNonConvergencePolicy
{
    /// <summary>Returns the last estimate as a valid value, as every earlier version did.</summary>
    Estimate,
    /// <summary>Returns an invalid row.</summary>
    Invalid
}
