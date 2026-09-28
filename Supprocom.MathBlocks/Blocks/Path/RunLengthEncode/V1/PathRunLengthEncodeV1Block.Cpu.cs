
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>path.run-length-encode@1</c> mathematical operation.</summary>
    public static MathBlockRunSet RunLengthEncode(IReadOnlyList<double> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var runs = new List<MathBlockRun>();
        if (values.Count == 0)
            return new MathBlockRunSet(runs);
        var start = 0;
        for (var index = 1; index <= values.Count; index++)
        {
            if (index < values.Count && values[index] == values[start])
                continue;
            runs.Add(new MathBlockRun(start, index - start, values[start]));
            start = index;
        }

        return new MathBlockRunSet(runs);
    }
}
