namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double Factorial(int value)
    {
        var result = 1d;
        for (var index = 2; index <= value; index++)
            result *= index;
        return result;
    }
}
