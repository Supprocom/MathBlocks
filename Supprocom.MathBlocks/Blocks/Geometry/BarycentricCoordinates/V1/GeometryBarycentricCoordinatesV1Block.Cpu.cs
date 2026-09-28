namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Geometry contract.</summary>
public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.barycentric-coordinates@1</c> mathematical operation.</summary>
    public static double[] BarycentricCoordinates(MathBlockPoint point, MathBlockPoint first, MathBlockPoint second, MathBlockPoint third)
    {
        var denominator = (second.Y - third.Y) * (first.X - third.X) + (third.X - second.X) * (first.Y - third.Y);
        var firstWeight = ((second.Y - third.Y) * (point.X - third.X) + (third.X - second.X) * (point.Y - third.Y)) / denominator;
        var secondWeight = ((third.Y - first.Y) * (point.X - third.X) + (first.X - third.X) * (point.Y - third.Y)) / denominator;
        return [firstWeight, secondWeight, 1d - firstWeight - secondWeight];
    }
}
