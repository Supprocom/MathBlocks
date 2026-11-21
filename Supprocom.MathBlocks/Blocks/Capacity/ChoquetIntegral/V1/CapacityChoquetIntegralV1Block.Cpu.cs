
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    /// <summary>Computes the <c>capacity.choquet-integral@1</c> mathematical operation.</summary>
    public static float ChoquetIntegral(IReadOnlyList<float> values, IReadOnlyList<float> capacity)
    {
        ArgumentNullException.ThrowIfNull(capacity);
        ArgumentNullException.ThrowIfNull(values);
        var order = MathBlockCollectionPrimitives.SortedIndices(
            values,
            (left, right) => left < right ? -1 : left > right ? 1 : 0);
        var result = 0f;
        var previous = 0f;
        for (var position = 0; position < order.Length; position++)
        {
            var coalition = 0;
            for (var index = position; index < order.Length; index++)
                coalition |= 1 << order[index];
            result += (values[order[position]] - previous) * capacity[coalition];
            previous = values[order[position]];
        }

        return result;
    }
}
