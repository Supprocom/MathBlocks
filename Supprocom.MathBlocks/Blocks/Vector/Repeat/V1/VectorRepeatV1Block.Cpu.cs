namespace Supprocom.MathBlocks;

public static partial class MathBlockVectorMath
{
    /// <summary>Computes the <c>vector.repeat@1</c> mathematical operation.</summary>
    public static double[] Repeat(double value, int count)
    {
        return MathBlockCollectionPrimitives.Repeat(value, count);
    }
}
