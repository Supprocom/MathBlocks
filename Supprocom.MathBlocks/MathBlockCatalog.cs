namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Catalog contract.</summary>
public static class MathBlockCatalog
{
    private static readonly Lazy<MathBlockRegistry> standard = new(CreateStandard);
    private static readonly Lazy<MathBlockRegistry> windowed = new(CreateWindowed);
    private static readonly Lazy<MathBlockRegistry> elementwise = new(CreateElementwise);

    /// <summary>Gets the standard value.</summary>
    public static MathBlockRegistry Standard => standard.Value;

    // The window.*, window-valid.*, window-accurate.* and window-accurate-valid.* forms, generated from the
    // WindowMathBlocks and WindowAccurateMathBlocks tables. Standard registers these same instances.
    internal static MathBlockRegistry Windowed => windowed.Value;

    // The elementwise.* and elementwise-valid.* forms, generated from the ElementwiseMathBlocks table. Standard
    // registers these same instances.
    internal static MathBlockRegistry Elementwise => elementwise.Value;

    // The per-block operations, then the table-generated window and elementwise forms.
    private static MathBlockRegistry CreateStandard()
    {
        var operations = new List<MathBlockOperation>(MathBlockFeatureIndex.CreateOperations());
        operations.AddRange(Windowed.Operations);
        operations.AddRange(Elementwise.Operations);
        return new MathBlockRegistry(operations);
    }

    private static MathBlockRegistry CreateWindowed()
        => new(WindowMathBlocks.CreateOperations());

    private static MathBlockRegistry CreateElementwise()
        => new(ElementwiseMathBlocks.CreateOperations());
}
