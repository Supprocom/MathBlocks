namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Catalog contract.</summary>
public static class MathBlockCatalog
{
    private static readonly Lazy<MathBlockRegistry> standard = new(CreateStandard);
    private static readonly Lazy<MathBlockRegistry> windowed = new(CreateWindowed);

    /// <summary>Gets the standard value.</summary>
    public static MathBlockRegistry Standard => standard.Value;

    // The window.*, window-valid.*, window-accurate.* and window-accurate-valid.* forms have CoreCLR evaluators only.
    // They stay outside Standard, which requires a CUDA implementation for every operation.
    internal static MathBlockRegistry Windowed => windowed.Value;

    private static MathBlockRegistry CreateStandard()
        => new(MathBlockFeatureIndex.CreateOperations());

    private static MathBlockRegistry CreateWindowed()
        => new(WindowMathBlocks.CreateOperations());
}
