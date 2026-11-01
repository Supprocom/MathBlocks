namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Geometry contract.</summary>
public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.barycentric-coordinates@1</c> mathematical operation.</summary>
    public static double[] BarycentricCoordinates(MathBlockPoint point, MathBlockPoint first, MathBlockPoint second, MathBlockPoint third)
    {
        var denominator = BarycentricDenominator(first, second, third);
        // A denominator that overflows would divide the numerators by an infinity and give finite weights near zero.
        if (!Math.IsFinite(denominator))
            return [Math.NaN, Math.NaN, Math.NaN];
        var firstWeight = ((second.Y - third.Y) * (point.X - third.X) + (third.X - second.X) * (point.Y - third.Y)) / denominator;
        var secondWeight = ((third.Y - first.Y) * (point.X - third.X) + (first.X - third.X) * (point.Y - third.Y)) / denominator;
        return [firstWeight, secondWeight, 1d - firstWeight - secondWeight];
    }

    internal static double BarycentricDenominator(MathBlockPoint first, MathBlockPoint second, MathBlockPoint third) =>
        (second.Y - third.Y) * (first.X - third.X) + (third.X - second.X) * (first.Y - third.Y);
}
