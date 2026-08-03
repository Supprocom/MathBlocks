
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static Complex[] DiscreteFourierTransform(IReadOnlyList<double> values)
    {
        var result = new Complex[values.Count];
        for (var frequency = 0; frequency < values.Count; frequency++)
        {
            var sum = new Complex(0d, 0d);
            for (var index = 0; index < values.Count; index++)
            {
                var angle = -2d * Math.PI * frequency * index / values.Count;
                sum = MathBlockComplex.Add(sum, MathBlockComplex.Multiply(new Complex(values[index], 0d), MathBlockComplex.FromPolar(1d, angle)));
            }

            result[frequency] = sum;
        }

        return result;
    }
}
