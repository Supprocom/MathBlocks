namespace Supprocom.MathBlocks;

public static partial class MathBlockGraphMath
{

    private static List<int>[] CreateUndirectedAdjacency(MathBlockGraph graph)
    {
        var result = new List<int>[graph.VertexCount];
        for (var vertex = 0; vertex < graph.VertexCount; vertex++)
            result[vertex] = [];
        foreach (var edge in graph)
        {
            result[edge.From].Add(edge.To);
            result[edge.To].Add(edge.From);
        }
        return result;
    }

    private static int Find(int[] parent, int vertex)
    {
        while (parent[vertex] != vertex)
        {
            parent[vertex] = parent[parent[vertex]];
            vertex = parent[vertex];
        }
        return vertex;
    }
}

internal static partial class GraphMathBlocks
{
    private static readonly MathBlockValue path = MathBlockValue.Graph(new MathBlockGraph(3,
    [
        new(0, 1, 1d),
        new(1, 2, 2d)
    ]));
    private static readonly MathBlockValue triangle = MathBlockValue.Graph(new MathBlockGraph(3,
    [
        new(0, 1, 1d),
        new(0, 2, 1d),
        new(1, 2, 1d)
    ]));

    private static MathBlockOperation CreateScalar(
        string identifier,
        Func<MathBlockGraph, double> function,
        MathBlockValue sample,
        double expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Scalar(function(inputs[0].AsGraph()), type.Unit);
        },
        [sample], MathBlockValue.Scalar(expected), 1e-8, 4);

    private static MathBlockOperation CreateVector(
        string identifier,
        Func<MathBlockGraph, double[]> function,
        MathBlockValue sample,
        double[] expected,
        MathBlockTypeResolver resolver) => MathBlockOperationFactory.Create(
        identifier, 1, resolver,
        inputs =>
        {
            var type = resolver(MathBlockCollectionPrimitives.Map(inputs, input => input.Type));
            return MathBlockValue.Vector(function(inputs[0].AsGraph()), type.Unit, true);
        },
        [sample], MathBlockValue.Vector(expected), 1e-8, 4);

    private static MathBlockOperation CreateMatrix(
        string identifier,
        Func<MathBlockGraph, MathBlockMatrix> function,
        MathBlockValue sample,
        MathBlockMatrix expected) => MathBlockOperationFactory.Create(
        identifier, 1, WeightedGraphMatrix,
        inputs => MathBlockValue.Matrix(function(inputs[0].AsGraph()), inputs[0].Type.Unit),
        [sample], MathBlockValue.Matrix(expected), 1e-9, 4);

    private static MathBlockType DimensionlessGraphScalar(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
        return MathBlockType.Scalar();
    }

    private static MathBlockType WeightedGraphScalar(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
        return MathBlockType.Scalar(types[0].Unit);
    }

    private static MathBlockType DimensionlessGraphVector(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
        return MathBlockType.Vector(length: types[0].Rows);
    }

    private static MathBlockType WeightedGraphVector(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
        return MathBlockType.Vector(types[0].Unit, types[0].Rows);
    }

    private static MathBlockType WeightedGraphMatrix(IReadOnlyList<MathBlockType> types)
    {
        MathBlockTypeRules.RequireKind(types[0], MathBlockValueKind.Graph);
        return MathBlockType.Matrix(types[0].Unit, types[0].Rows, types[0].Rows);
    }
}
