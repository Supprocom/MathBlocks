namespace Supprocom.MathBlocks;

/// <summary>Names the execution target a limit applies to.</summary>
public enum MathBlockLimitDevice
{
    /// <summary>Both CoreCLR and CUDA.</summary>
    All,
    /// <summary>CoreCLR only.</summary>
    CoreCLR,
    /// <summary>CUDA only.</summary>
    Cuda
}
