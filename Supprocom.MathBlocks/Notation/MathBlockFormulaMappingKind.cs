namespace Supprocom.MathBlocks;

/// <summary>Identifies how a MathBlocks operation is represented in a formula.</summary>
public enum MathBlockFormulaMappingKind
{
    /// <summary>No formula symbol mapping has been selected.</summary>
    None = 0,

    /// <summary>The operation uses an established OpenMath content-dictionary symbol.</summary>
    OfficialContentDictionary = 1,

    /// <summary>The operation uses an exact symbol from the versioned MathBlocks dictionary.</summary>
    MathBlocksExtension = 2
}
