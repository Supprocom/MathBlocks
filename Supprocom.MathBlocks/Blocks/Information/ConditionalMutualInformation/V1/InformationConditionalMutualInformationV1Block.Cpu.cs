namespace Supprocom.MathBlocks;

public static partial class MathBlockProbability
{
    /// <summary>Computes the <c>information.conditional-mutual-information@1</c> mathematical operation.</summary>
    public static float ConditionalMutualInformation(IReadOnlyList<float> jointProbabilities, int firstCount, int secondCount, int conditionCount)
    {
        ArgumentNullException.ThrowIfNull(jointProbabilities);
        var firstCondition = new float[firstCount * conditionCount];
        var secondCondition = new float[secondCount * conditionCount];
        var condition = new float[conditionCount];
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

        var information = 0f;
        for (var first = 0; first < firstCount; first++)
        {
            for (var second = 0; second < secondCount; second++)
            {
                for (var state = 0; state < conditionCount; state++)
                {
                    var probability = jointProbabilities[(first * secondCount + second) * conditionCount + state];
                    if (probability == 0f)
                        continue;
                    information += probability * Math.Log(probability * condition[state] / (firstCondition[first * conditionCount + state] * secondCondition[second * conditionCount + state]));
                }
            }
        }

        return information;
    }
}
