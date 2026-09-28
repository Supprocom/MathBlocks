
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>state.transition-counts@1</c> mathematical operation.</summary>
    public static MathBlockMatrix TransitionCounts(IReadOnlyList<double> states, int stateCount)
    {
        ArgumentNullException.ThrowIfNull(states);
        var values = new double[stateCount * stateCount];
        for (var index = 1; index < states.Count; index++)
            values[(int)states[index - 1] * stateCount + (int)states[index]]++;
        return new MathBlockMatrix(stateCount, stateCount, values, true);
    }
}
