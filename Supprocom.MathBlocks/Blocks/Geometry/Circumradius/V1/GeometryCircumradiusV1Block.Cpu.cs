namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    public static double Circumradius(MathBlockPoint first, MathBlockPoint second, MathBlockPoint third)
    {
        var firstLength = Distance(second, third);
        var secondLength = Distance(first, third);
        var thirdLength = Distance(first, second);
        return firstLength * secondLength * thirdLength / (2d * Math.Abs(Cross(first, second, third)));
    }
}
