namespace Supprocom.MathBlocks;

/// <summary>Holds a window form's result and its validity sibling's result from one pass.</summary>
public sealed class MathBlockWindowBatchResult
{
    internal MathBlockWindowBatchResult(MathBlockValue values, MathBlockValue validity)
    {
        Values = values;
        Validity = validity;
    }

    /// <summary>Gets the form's result: a vector with one row per series row.</summary>
    public MathBlockValue Values { get; }

    /// <summary>Gets the validity sibling's result: a Boolean vector that is true where a row was computed.</summary>
    public MathBlockValue Validity { get; }
}
