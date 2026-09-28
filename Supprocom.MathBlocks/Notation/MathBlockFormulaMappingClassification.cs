namespace Supprocom.MathBlocks;

/// <summary>Classifies how one operation is expressed by a formula vocabulary.</summary>
public enum MathBlockFormulaMappingClassification
{
    /// <summary>The operation maps to one content-dictionary symbol application.</summary>
    DirectMapping = 1,

    /// <summary>The operation maps to a fixed, normative expression pattern.</summary>
    CanonicalPatternMapping = 2,

    /// <summary>The operation cannot be represented by the vocabulary.</summary>
    Unsupported = 3
}
