namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>combinatorics.factorial@1</c> mathematical operation.</summary>
    public static float Factorial(int value)
    {
        var result = 1f;
        for (var index = 2; index <= value; index++)
            result *= index;
        return result;
    }
}
