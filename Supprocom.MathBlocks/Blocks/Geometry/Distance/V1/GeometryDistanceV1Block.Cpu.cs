namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double Distance(MathBlockPoint left, MathBlockPoint right)
    {
        var x = left.X - right.X;
        var y = left.Y - right.Y;
        return Math.Sqrt(x * x + y * y);
    }
}
