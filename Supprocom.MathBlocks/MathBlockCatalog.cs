namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Catalog contract.</summary>
public static class MathBlockCatalog
{
    private static readonly Lazy<MathBlockRegistry> standard = new(CreateStandard);

    /// <summary>Gets the standard value.</summary>
    public static MathBlockRegistry Standard => standard.Value;

    private static MathBlockRegistry CreateStandard()
        => new(MathBlockFeatureIndex.CreateOperations());
}
