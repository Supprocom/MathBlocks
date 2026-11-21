
namespace Supprocom.MathBlocks;

/// <summary>Defines the Math Block Polynomial contract.</summary>
public static partial class MathBlockPolynomial
{
    /// <summary>Computes the <c>polynomial.cubic-roots@1</c> mathematical operation.</summary>
    public static Complex[] CubicRoots(float constant, float linear, float quadratic, float leading)
    {
        if (leading == 0f)
            return [new(Math.NaN, Math.NaN), new(Math.NaN, Math.NaN), new(Math.NaN, Math.NaN)];
        var a = quadratic / leading;
        var b = linear / leading;
        var c = constant / leading;
        var p = b - a * a / 3f;
        var q = 2f * a * a * a / 27f - a * b / 3f + c;
        var squareRoot = MathBlockComplex.SquareRoot(new Complex(q * q / 4f + p * p * p / 27f, 0f));
        var u = ComplexCubeRoot(MathBlockComplex.Add(new Complex(-q / 2f, 0f), squareRoot));
        var v = u.Real == 0f && u.Imaginary == 0f ? ComplexCubeRoot(MathBlockComplex.Subtract(new Complex(-q / 2f, 0f), squareRoot)) : MathBlockComplex.Divide(new Complex(-p, 0f), MathBlockComplex.Multiply(new Complex(3f, 0f), u));
        var omega = new Complex(-0.5f, Math.Sqrt(3f) / 2f);
        return [MathBlockComplex.Subtract(MathBlockComplex.Add(u, v), new Complex(a / 3f, 0f)), MathBlockComplex.Subtract(MathBlockComplex.Add(MathBlockComplex.Multiply(omega, u), MathBlockComplex.Multiply(MathBlockComplex.Conjugate(omega), v)), new Complex(a / 3f, 0f)), MathBlockComplex.Subtract(MathBlockComplex.Add(MathBlockComplex.Multiply(MathBlockComplex.Conjugate(omega), u), MathBlockComplex.Multiply(omega, v)), new Complex(a / 3f, 0f))];
    }
}
