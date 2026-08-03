
namespace Supprocom.MathBlocks;

public static partial class MathBlockPolynomial
{
    public static Complex[] CubicRoots(double constant, double linear, double quadratic, double leading)
    {
        if (leading == 0d)
            return[new(Math.NaN, Math.NaN), new(Math.NaN, Math.NaN), new(Math.NaN, Math.NaN)];
        var a = quadratic / leading;
        var b = linear / leading;
        var c = constant / leading;
        var p = b - a * a / 3d;
        var q = 2d * a * a * a / 27d - a * b / 3d + c;
        var squareRoot = MathBlockComplex.SquareRoot(new Complex(q * q / 4d + p * p * p / 27d, 0d));
        var u = ComplexCubeRoot(MathBlockComplex.Add(new Complex(-q / 2d, 0d), squareRoot));
        var v = u.Real == 0d && u.Imaginary == 0d ? ComplexCubeRoot(MathBlockComplex.Subtract(new Complex(-q / 2d, 0d), squareRoot)) : MathBlockComplex.Divide(new Complex(-p, 0d), MathBlockComplex.Multiply(new Complex(3d, 0d), u));
        var omega = new Complex(-0.5d, Math.Sqrt(3d) / 2d);
        return[MathBlockComplex.Subtract(MathBlockComplex.Add(u, v), new Complex(a / 3d, 0d)), MathBlockComplex.Subtract(MathBlockComplex.Add(MathBlockComplex.Multiply(omega, u), MathBlockComplex.Multiply(MathBlockComplex.Conjugate(omega), v)), new Complex(a / 3d, 0d)), MathBlockComplex.Subtract(MathBlockComplex.Add(MathBlockComplex.Multiply(MathBlockComplex.Conjugate(omega), u), MathBlockComplex.Multiply(omega, v)), new Complex(a / 3d, 0d))];
    }
}
