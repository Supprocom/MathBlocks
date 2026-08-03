
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    public static Complex[] InverseDiscreteFourierTransform(IReadOnlyList<Complex> values)
    {
        var result = new Complex[values.Count];
        for (var index = 0; index < values.Count; index++)
        {
            var sum = new Complex(0d, 0d);
            for (var frequency = 0; frequency < values.Count; frequency++)
            {
                var angle = 2d * Math.PI * frequency * index / values.Count;
                sum = MathBlockComplex.Add(sum, MathBlockComplex.Multiply(values[frequency], MathBlockComplex.FromPolar(1d, angle)));
            }

            result[index] = MathBlockComplex.Divide(sum, new Complex(values.Count, 0d));
        }

        return result;
    }
}
