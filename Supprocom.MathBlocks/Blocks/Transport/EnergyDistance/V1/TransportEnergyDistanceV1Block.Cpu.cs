namespace Supprocom.MathBlocks;

public static partial class MathBlockTransport
{
    public static double EnergyDistance(IReadOnlyList<double> left, IReadOnlyList<double> right)
    {
        var cross = MeanPairwiseDistance(left, right);
        var leftWithin = MeanPairwiseDistance(left, left);
        var rightWithin = MeanPairwiseDistance(right, right);
        return MathBlockScalar.SquareRoot(MathBlockScalar.Maximum(2d * cross - leftWithin - rightWithin, 0d));
    }
}
