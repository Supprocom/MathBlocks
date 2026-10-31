namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Catalog contract.</summary>
public static class MathBlockCatalog
{
    private static readonly Lazy<MathBlockRegistry> standard = new(CreateStandard);
    private static readonly Lazy<MathBlockRegistry> windowed = new(CreateWindowed);
    private static readonly Lazy<MathBlockRegistry> cuda = new(CreateCuda);
    private static readonly Lazy<MathBlockRegistry> elementwise = new(CreateElementwise);

    /// <summary>Gets the standard value.</summary>
    public static MathBlockRegistry Standard => standard.Value;

    // The window.* and window-valid.* forms stay outside Standard until they are registered there.
    internal static MathBlockRegistry Windowed => windowed.Value;

    // CUDA plans, contracts and kernels resolve operations from Standard and the window forms together, so the
    // window forms have CUDA support without being part of Standard.
    internal static MathBlockRegistry Cuda => cuda.Value;

    // The elementwise.* and elementwise-valid.* forms have CoreCLR evaluators only. They stay outside Standard,
    // which requires a CUDA implementation for every operation.
    internal static MathBlockRegistry Elementwise => elementwise.Value;

    private static MathBlockRegistry CreateStandard()
        => new(MathBlockFeatureIndex.CreateOperations());

    private static MathBlockRegistry CreateWindowed()
        => new(WindowMathBlocks.CreateOperations());

    private static MathBlockRegistry CreateCuda()
        => new([.. Standard.Operations, .. Windowed.Operations]);

    private static MathBlockRegistry CreateElementwise()
        => new(ElementwiseMathBlocks.CreateOperations());
}
