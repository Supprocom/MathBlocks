namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    public static double ConditionalMutualInformation(IReadOnlyList<double> jointProbabilities, int firstCount, int secondCount, int conditionCount)
    {
        var firstCondition = new double[firstCount * conditionCount];
        var secondCondition = new double[secondCount * conditionCount];
        var condition = new double[conditionCount];
        for (var first = 0; first < firstCount; first++)
        {
            for (var second = 0; second < secondCount; second++)
            {
                for (var state = 0; state < conditionCount; state++)
                {
                    var probability = jointProbabilities[(first * secondCount + second) * conditionCount + state];
                    firstCondition[first * conditionCount + state] += probability;
                    secondCondition[second * conditionCount + state] += probability;
                    condition[state] += probability;
                }
            }
        }

        var information = 0d;
        for (var first = 0; first < firstCount; first++)
        {
            for (var second = 0; second < secondCount; second++)
            {
                for (var state = 0; state < conditionCount; state++)
                {
                    var probability = jointProbabilities[(first * secondCount + second) * conditionCount + state];
                    if (probability == 0d)
                        continue;
                    information += probability * Math.Log(probability * condition[state] / (firstCondition[first * conditionCount + state] * secondCondition[second * conditionCount + state]));
                }
            }
        }

        return information;
    }
}
