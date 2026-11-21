namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.binary-logarithm@1</c> mathematical operation.</summary>
    public static float BinaryLogarithm(float value)
    {
        var bits = Math.ToBits(value);
        var exponent = (int)((bits >> 23) & 0xffu);
        var fraction = bits & 0x007f_ffffu;
        if (exponent is > 0 and < 0xff && fraction == 0u)
            return exponent - 127;
        return DeterministicNaturalLogarithm(value) / 0.69314718055994530942f;
    }
}
