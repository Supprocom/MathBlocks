namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.distance@1</c> mathematical operation.</summary>
    public static double Distance(MathBlockPoint left, MathBlockPoint right)
    {
        var x = left.X - right.X;
        var y = left.Y - right.Y;
        return Math.Sqrt(x * x + y * y);
    }
}
