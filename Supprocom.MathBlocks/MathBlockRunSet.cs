using System.Collections;

namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Run Set contract.</summary>
public sealed class MathBlockRunSet : IReadOnlyList<MathBlockRun>
{
    private readonly MathBlockRun[] runs;

    /// <summary>Copies runs into an immutable run set.</summary>
    public MathBlockRunSet(IEnumerable<MathBlockRun> runs)
    {
        ArgumentNullException.ThrowIfNull(runs);
        this.runs = MathBlockCollectionPrimitives.CopyEnumerable(runs);
        for (var index = 0; index < this.runs.Length; index++)
            this.runs[index] = this.runs[index].Validate();
    }

    /// <summary>Gets the count value.</summary>
    public int Count => runs.Length;
    /// <summary>Gets the value at the specified index.</summary>
    public MathBlockRun this[int index] => runs[index];
    /// <summary>Returns a copy of the runs.</summary>
    public MathBlockRun[] ToArray() => MathBlockCollectionPrimitives.Copy(runs);
    /// <summary>Enumerates the contained values.</summary>
    public IEnumerator<MathBlockRun> GetEnumerator() => ((IEnumerable<MathBlockRun>)runs).GetEnumerator();
    IEnumerator IEnumerable.GetEnumerator() => runs.GetEnumerator();
}
