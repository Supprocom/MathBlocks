namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    /// <summary>Computes the <c>transport.energy-distance@1</c> mathematical operation.</summary>
    public static float EnergyDistance(IReadOnlyList<float> left, IReadOnlyList<float> right)
    {
        ArgumentNullException.ThrowIfNull(left);
        ArgumentNullException.ThrowIfNull(right);
        var cross = MeanPairwiseDistance(left, right);
        var leftWithin = MeanPairwiseDistance(left, left);
        var rightWithin = MeanPairwiseDistance(right, right);
        return MathBlockScalar.SquareRoot(MathBlockScalar.Maximum(2f * cross - leftWithin - rightWithin, 0f));
    }
}
