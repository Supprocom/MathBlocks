
namespace Supprocom.MathBlocks;

public static partial class MathBlockPath
{
    /// <summary>Computes the <c>transform.discrete-fourier@1</c> mathematical operation.</summary>
    public static Complex[] DiscreteFourierTransform(IReadOnlyList<float> values)
    {
        ArgumentNullException.ThrowIfNull(values);
        var result = new Complex[values.Count];
        for (var frequency = 0; frequency < values.Count; frequency++)
        {
            var sum = new Complex(0f, 0f);
            for (var index = 0; index < values.Count; index++)
            {
                var angle = -2f * Math.PI * frequency * index / values.Count;
                sum = MathBlockComplex.Add(sum, MathBlockComplex.Multiply(new Complex(values[index], 0f), MathBlockComplex.FromPolar(1f, angle)));
            }

            result[frequency] = sum;
        }

        return result;
    }
}
