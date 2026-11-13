namespace Supprocom.MathBlocks;

/// <summary>Classifies how a limit is set and what exceeding it does.</summary>
public enum MathBlockLimitKind
{
    /// <summary>A speed-only launch clamp; results are unchanged and a <c>MathBlocksCudaOptions</c> value sets it.</summary>
    Launch,
    /// <summary>A configurable option that is not speed-only, such as an OpenMath import limit, CoreCLR worker concurrency or the CUDA block size.</summary>
    Option,
    /// <summary>A value computed from other limits; the record names them and states the derivation.</summary>
    Derived,
    /// <summary>A constant of this version of the library.</summary>
    Fixed,
    /// <summary>Part of an operation's definition; inputs beyond it give invalid rows on every device. A <c>MathBlockDomainOptions</c> value sets the explicit-subset and state-count limits for CoreCLR and CUDA together.</summary>
    Domain
}
