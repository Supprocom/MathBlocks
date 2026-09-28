namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    /// <summary>Computes the <c>transport.ordered-earth-mover@1</c> mathematical operation.</summary>
    public static double OrderedEarthMoverDistance(IReadOnlyList<double> leftMass, IReadOnlyList<double> rightMass)
    {
        ArgumentNullException.ThrowIfNull(leftMass);
        ArgumentNullException.ThrowIfNull(rightMass);
        var cumulative = 0d;
        var result = 0d;
        for (var index = 0; index < leftMass.Count - 1; index++)
        {
            cumulative += leftMass[index] - rightMass[index];
            result += Math.Abs(cumulative);
        }

        return result;
    }
}
