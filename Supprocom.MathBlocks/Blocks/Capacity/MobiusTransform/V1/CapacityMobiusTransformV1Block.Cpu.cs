
namespace Supprocom.MathBlocks;

public static partial class MathBlockAdvanced
{
    public static double[] MobiusTransform(IReadOnlyList<double> setFunction)
    {
        var result = MathBlockCollectionPrimitives.Copy(setFunction);
        var count = Math.FloorLog2((uint)setFunction.Count);
        for (var bit = 0; bit < count; bit++)
            for (var mask = 0; mask < result.Length; mask++)
                if ((mask & (1 << bit)) != 0)
                    result[mask] -= result[mask ^ (1 << bit)];
        return result;
    }
}
