namespace Supprocom.MathBlocks;

public static partial class MathBlockScalar
{
    public static double CubeRoot(double value)
    {
        if (value == 0d)
            return value;
        var magnitude = Math.Abs(value);
        var estimate = Exponential(NaturalLogarithm(magnitude) / 3d);
        for (var iteration = 0; iteration < 3; iteration++)
            estimate = (2d * estimate + magnitude / (estimate * estimate)) / 3d;
        return Math.CopySign(estimate, value);
    }
}
