namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.cube-root@1</c> mathematical operation.</summary>
    public static float CubeRoot(float value) => CubeRoot(value, MathBlockDomainOptions.Default.CubeRootNewtonSteps);

    // The start exp(ln(x) / 3) refined by the given number of Newton steps.
    internal static float CubeRoot(float value, int newtonSteps)
    {
        if (value == 0f)
            return value;
        var magnitude = Math.Abs(value);
        var estimate = Exponential(NaturalLogarithm(magnitude) / 3f);
        for (var iteration = 0; iteration < newtonSteps; iteration++)
            estimate = (2f * estimate + magnitude / (estimate * estimate)) / 3f;
        return Math.CopySign(estimate, value);
    }
}
