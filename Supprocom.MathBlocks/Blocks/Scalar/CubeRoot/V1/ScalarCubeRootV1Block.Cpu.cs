namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    /// <summary>Computes the <c>scalar.cube-root@1</c> mathematical operation.</summary>
    public static double CubeRoot(double value) => CubeRoot(value, MathBlockDomainOptions.Default.CubeRootNewtonSteps);

    // The start exp(ln(x) / 3) refined by the given number of Newton steps.
    internal static double CubeRoot(double value, int newtonSteps)
    {
        if (value == 0d)
            return value;
        var magnitude = Math.Abs(value);
        var estimate = Exponential(NaturalLogarithm(magnitude) / 3d);
        for (var iteration = 0; iteration < newtonSteps; iteration++)
            estimate = (2d * estimate + magnitude / (estimate * estimate)) / 3d;
        return Math.CopySign(estimate, value);
    }
}
