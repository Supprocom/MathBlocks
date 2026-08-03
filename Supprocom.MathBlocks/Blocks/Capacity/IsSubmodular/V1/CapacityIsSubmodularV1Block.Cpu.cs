
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static bool IsSubmodular(IReadOnlyList<double> setFunction)
    {
        for (var left = 0; left < setFunction.Count; left++)
            for (var right = 0; right < setFunction.Count; right++)
                if (setFunction[left] + setFunction[right] < setFunction[left | right] + setFunction[left & right])
                    return false;
        return true;
    }
}
