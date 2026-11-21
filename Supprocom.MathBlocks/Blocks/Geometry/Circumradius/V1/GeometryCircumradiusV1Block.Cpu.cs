namespace Supprocom.MathBlocks;

public static partial class MathBlockGeometry
{
    /// <summary>Computes the <c>geometry.circumradius@1</c> mathematical operation.</summary>
    public static float Circumradius(MathBlockPoint first, MathBlockPoint second, MathBlockPoint third)
    {
        var firstLength = Distance(second, third);
        var secondLength = Distance(first, third);
        var thirdLength = Distance(first, second);
        return firstLength * secondLength * thirdLength / (2f * Math.Abs(Cross(first, second, third)));
    }
}
