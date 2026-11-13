using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks;

// The output-type rule of every operation that is not a lift, as Composed signature data. Each entry lists the
// accepted kinds and unit constraint of every operand, then the nine Composed parameters (see
// MathBlockTypeRuleKind.Composed): output kind, shape mode with its two arguments, unit mode with its two operand
// arguments and exponent. The elementwise and window forms are not listed: they embed the signature of the operation
// they lift. The tests compare every entry with the operation's resolver delegate.
internal static class MathBlockTypeSignatureCatalog
{
    private const int Sc = 1 << (int)MathBlockValueKind.Scalar;
    private const int Bo = 1 << (int)MathBlockValueKind.Boolean;
    private const int Co = 1 << (int)MathBlockValueKind.Complex;
    private const int Ve = 1 << (int)MathBlockValueKind.Vector;
    private const int Ma = 1 << (int)MathBlockValueKind.Matrix;
    private const int CV = 1 << (int)MathBlockValueKind.ComplexVector;
    private const int PS = 1 << (int)MathBlockValueKind.PointSet;
    private const int Gr = 1 << (int)MathBlockValueKind.Graph;
    private const int BV = 1 << (int)MathBlockValueKind.BooleanVector;

    private static readonly Lazy<Dictionary<string, MathBlockTypeSignature>> signatures = new(
        CreateTable,
        LazyThreadSafetyMode.ExecutionAndPublication);

    // The signature of an operation by identity, or null when none is recorded.
    internal static MathBlockTypeSignature? Create(string identity) =>
        signatures.Value.TryGetValue(identity, out var signature) ? signature : null;

    private static Dictionary<string, MathBlockTypeSignature> CreateTable()
    {
        var entries = new List<MathBlockTypeSignature>(277);
        entries.AddRange(Entries1());
        entries.AddRange(Entries2());
        entries.AddRange(Entries3());
        entries.AddRange(Entries4());
        var table = new Dictionary<string, MathBlockTypeSignature>(entries.Count, StringComparer.Ordinal);
        foreach (ref readonly var entry in CollectionsMarshal.AsSpan(entries))
            table.Add(entry.Identity, entry);
        return table;
    }

    private static MathBlockTypeSignature[] Entries1() =>
    [
        E("boolean-vector.all@1", [O(BV, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("boolean-vector.and@1", [O(BV, -1), O(BV, 0)], 11, 4, 3, 0, 0, 0, 0, 1, 1),
        E("boolean-vector.any@1", [O(BV, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("boolean-vector.not@1", [O(BV, -1)], 11, 1, 0, 0, 1, 0, 0, 1, 1),
        E("boolean-vector.or@1", [O(BV, -1), O(BV, 0)], 11, 4, 3, 0, 0, 0, 0, 1, 1),
        E("boolean-vector.true-count@1", [O(BV, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("boolean-vector.true-indices@1", [O(BV, -1)], 4, 0, 0, 0, 0, 0, 0, 1, 1),
        E("boolean-vector.xor@1", [O(BV, -1), O(BV, 0)], 11, 4, 3, 0, 0, 0, 0, 1, 1),
        E("boolean.and@1", [O(Bo, -1), O(Bo, 0)], 2, 2, 3, 0, 1, 0, 0, 1, 1),
        E("boolean.not@1", [O(Bo, -1)], 2, 1, 0, 0, 1, 0, 0, 1, 1),
        E("boolean.or@1", [O(Bo, -1), O(Bo, 0)], 2, 2, 3, 0, 1, 0, 0, 1, 1),
        E("boolean.xor@1", [O(Bo, -1), O(Bo, 0)], 2, 2, 3, 0, 1, 0, 0, 1, 1),
        E("capacity.choquet-integral@1", [O(Ve, -1), O(Ve, -2)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("capacity.is-submodular@1", [O(Ve, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("capacity.mobius-transform@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("combinatorics.ballot-count@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("combinatorics.binomial-coefficient@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("combinatorics.factorial@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("combinatorics.nonempty-subset-sums@1", [O(Ve, -1)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("complex-vector.create@1", [O(Ve, -1), O(Ve, 0)], 6, 4, 3, 0, 1, 0, 0, 1, 1),
        E("complex-vector.imaginary@1", [O(CV, -1)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("complex-vector.magnitude@1", [O(CV, -1)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("complex-vector.real@1", [O(CV, -1)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("complex.add@1", [O(Co, -1), O(Co, 0)], 3, 2, 3, 0, 1, 0, 0, 1, 1),
        E("complex.conjugate@1", [O(Co, -1)], 3, 1, 0, 0, 1, 0, 0, 1, 1),
        E("complex.create@1", [O(Sc, -1), O(Sc, 0)], 3, 7, 3, 0, 1, 0, 0, 1, 1),
        E("complex.divide@1", [O(Co, -1), O(Co, -1)], 3, 0, 0, 0, 4, 0, 1, 1, 1),
        E("complex.exponential@1", [O(Co, -2)], 3, 1, 0, 0, 0, 0, 0, 1, 1),
        E("complex.from-polar@1", [O(Sc, -1), O(Sc, -2)], 3, 0, 0, 0, 1, 0, 0, 1, 1),
        E("complex.magnitude@1", [O(Co, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("complex.multiply@1", [O(Co, -1), O(Co, -1)], 3, 0, 0, 0, 3, 0, 1, 1, 1),
        E("complex.natural-logarithm@1", [O(Co, -2)], 3, 1, 0, 0, 0, 0, 0, 1, 1),
        E("complex.negate@1", [O(Co, -1)], 3, 1, 0, 0, 1, 0, 0, 1, 1),
        E("complex.phase@1", [O(Co, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("complex.power@1", [O(Co, -2), O(Co, -2)], 3, 0, 0, 0, 0, 0, 0, 1, 1),
        E("complex.square-root@1", [O(Co, -1)], 3, 0, 0, 0, 2, 0, 0, 1, 2),
        E("complex.subtract@1", [O(Co, -1), O(Co, 0)], 3, 2, 3, 0, 1, 0, 0, 1, 1),
        E("cooperative.shapley-values@1", [O(Ve, -1)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.circumradius@1", [O(PS, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.contains-point@1", [O(PS, -1), O(PS, 0)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("geometry.convex-hull@1", [O(PS, -1)], 8, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.delaunay-graph@1", [O(PS, -1)], 9, 3, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.diameter@1", [O(PS, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.discrete-frechet-distance@1", [O(PS, -1), O(PS, 0)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.distance@1", [O(PS, -1), O(PS, 0)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.fisher-rao-distance@1", [O(Ve, -1), O(Ve, 0)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("geometry.gabriel-graph@1", [O(PS, -1)], 9, 3, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.halfspace-depth@1", [O(PS, -1), O(PS, 0)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("geometry.hausdorff-distance@1", [O(PS, -1), O(PS, 0)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.path-length@1", [O(PS, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.perimeter@1", [O(PS, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.point-to-segment-distance@1", [O(PS, -1), O(PS, 0)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("geometry.polygon-area@1", [O(PS, -1)], 1, 0, 0, 0, 2, 0, 0, 2, 1),
        E("geometry.signed-polygon-area@1", [O(PS, -1)], 1, 0, 0, 0, 2, 0, 0, 2, 1),
        E("geometry.simplicial-depth@1", [O(PS, -1), O(PS, 0)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("graph.algebraic-connectivity@1", [O(Gr, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("graph.conductance@1", [O(Gr, -1), O(BV, -1)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("graph.connected-component-count@1", [O(Gr, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("graph.degree@1", [O(Gr, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("graph.hodge-potential@1", [O(Gr, -1)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("graph.hodge-residual-norm@1", [O(Gr, -1), O(Ve, 0)], 1, 7, 3, 0, 1, 0, 0, 1, 1),
        E("graph.is-connected@1", [O(Gr, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("graph.minimum-spanning-forest@1", [O(Gr, -1)], 9, 1, 0, 0, 1, 0, 0, 1, 1),
        E("graph.page-rank@1", [O(Gr, -2), O(Sc, -2), O(Sc, -2)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("graph.triangle-count@1", [O(Gr, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("graph.undirected-shortest-paths@1", [O(Gr, -1), O(Sc, -2)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("graph.weighted-degree@1", [O(Gr, -1)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("inequality.gini-coefficient@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("inequality.lorenz-curve@1", [O(Ve, -1)], 4, 9, 0, 1, 0, 0, 0, 1, 1),
        E("information.bhattacharyya-coefficient@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1)
    ];

    private static MathBlockTypeSignature[] Entries2() =>
    [
        E("information.binary-shannon-entropy@1", [O(Ve, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("information.conditional-mutual-information@1", [O(Ve, -2), O(Sc, -2), O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("information.cross-entropy@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("information.gini-impurity@1", [O(Ve, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("information.hellinger-distance@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("information.jensen-shannon@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("information.kullback-leibler@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("information.mutual-information@1", [O(Ma, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("information.renyi-entropy@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("information.shannon-entropy@1", [O(Ve, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("information.total-variation-distance@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("information.tsallis-entropy@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("matrix.add@1", [O(Ma, -1), O(Ma, 0)], 5, 2, 3, 0, 1, 0, 0, 1, 1),
        E("matrix.column@1", [O(Ma, -1), O(Sc, -2)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("matrix.hadamard-product@1", [O(Ma, -1), O(Ma, -1)], 5, 2, 3, 1, 3, 0, 1, 1, 1),
        E("matrix.identity@1", [O(Sc, -2)], 5, 0, 0, 0, 0, 0, 0, 1, 1),
        E("matrix.is-positive-definite@1", [O(Ma, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("matrix.is-symmetric@1", [O(Ma, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("matrix.is-totally-nonnegative@1", [O(Ma, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("matrix.rank@1", [O(Ma, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("matrix.reshape@1", [O(Ve, -1), O(Sc, -2), O(Sc, -2)], 5, 0, 0, 0, 1, 0, 0, 1, 1),
        E("matrix.row-sums@1", [O(Ma, -1)], 4, 3, 0, 0, 1, 0, 0, 1, 1),
        E("matrix.scale@1", [O(Ma, -1), O(Sc, -1)], 5, 1, 0, 0, 3, 0, 1, 1, 1),
        E("matrix.subtract@1", [O(Ma, -1), O(Ma, 0)], 5, 2, 3, 0, 1, 0, 0, 1, 1),
        E("order.isotonic-regression@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("order.majorizes@1", [O(Ve, -1), O(Ve, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1),
        E("path.cumulative-deviation@1", [O(Ve, -1), O(Sc, 0)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("path.dynamic-time-warping@1", [O(Ve, -1), O(Ve, 0)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("path.first-passage-index@1", [O(Ve, -1), O(Sc, 0), O(Bo, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("path.hysteresis@1", [O(Ve, -1), O(Sc, 0), O(Sc, 0)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("path.longest-true-run@1", [O(BV, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("path.maximum-decline@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("path.maximum-relative-decline@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("path.power-variation@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("path.quadratic-variation@1", [O(Ve, -1)], 1, 0, 0, 0, 2, 0, 0, 2, 1),
        E("path.recurrence-rate@1", [O(Ve, -1), O(Sc, 0)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("path.reflected-cumulative-sum@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("path.run-length-encode@1", [O(Ve, -1)], 10, 0, 0, 0, 1, 0, 0, 1, 1),
        E("path.total-variation@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("path.turning-point-count@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("path.zero-crossing-count@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("polynomial.bernstein-evaluate@1", [O(Ve, -1), O(Sc, -2)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("polynomial.derivative@1", [O(Ve, -2)], 4, 8, 0, 0, 0, 0, 0, 1, 1),
        E("polynomial.elementary-symmetric@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("polynomial.evaluate@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("probability.log-sum-exp@1", [O(Ve, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("probability.normal-cdf@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("probability.normalize@1", [O(Ve, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("probability.poisson-cdf@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("probability.poisson-pmf@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("probability.softmax@1", [O(Ve, -2)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("projective.hilbert-distance@1", [O(Ve, -1), O(Ve, 0)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("scalar.absolute@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.add@1", [O(Sc, -1), O(Sc, 0)], 1, 2, 3, 0, 1, 0, 0, 1, 1),
        E("scalar.arc-cosine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.arc-sine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.arc-tangent-2@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.arc-tangent@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.binary-logarithm@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.ceiling@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.clamp@1", [O(Sc, -1), O(Sc, 0), O(Sc, 0)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.common-logarithm@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.cosine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.cube-root@1", [O(Sc, -1)], 1, 0, 0, 0, 2, 0, 0, 1, 3),
        E("scalar.cube@1", [O(Sc, -1)], 1, 0, 0, 0, 2, 0, 0, 3, 1),
        E("scalar.divide@1", [O(Sc, -1), O(Sc, -1)], 1, 0, 0, 0, 4, 0, 1, 1, 1),
        E("scalar.equal@1", [O(Sc, -1), O(Sc, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1),
        E("scalar.exponential@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.floor@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.greater-or-equal@1", [O(Sc, -1), O(Sc, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1)
    ];

    private static MathBlockTypeSignature[] Entries3() =>
    [
        E("scalar.greater-than@1", [O(Sc, -1), O(Sc, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1),
        E("scalar.hyperbolic-cosine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.hyperbolic-sine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.hyperbolic-tangent@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.inverse-hyperbolic-cosine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.inverse-hyperbolic-sine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.inverse-hyperbolic-tangent@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.less-or-equal@1", [O(Sc, -1), O(Sc, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1),
        E("scalar.less-than@1", [O(Sc, -1), O(Sc, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1),
        E("scalar.log-one-plus@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.logistic@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.logit@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.maximum@1", [O(Sc, -1), O(Sc, 0)], 1, 2, 3, 0, 1, 0, 0, 1, 1),
        E("scalar.minimum@1", [O(Sc, -1), O(Sc, 0)], 1, 2, 3, 0, 1, 0, 0, 1, 1),
        E("scalar.modulo@1", [O(Sc, -1), O(Sc, 0)], 1, 2, 3, 0, 1, 0, 0, 1, 1),
        E("scalar.multiply@1", [O(Sc, -1), O(Sc, -1)], 1, 0, 0, 0, 3, 0, 1, 1, 1),
        E("scalar.natural-logarithm@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.negate@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.not-equal@1", [O(Sc, -1), O(Sc, 0)], 2, 7, 3, 0, 0, 0, 0, 1, 1),
        E("scalar.positive-part@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.power@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.reciprocal@1", [O(Sc, -1)], 1, 0, 0, 0, 2, 0, 0, -1, 1),
        E("scalar.round@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("scalar.select@1", [O(Bo, -1), O(Sc, -1), O(Sc, 1)], 1, 2, 6, 0, 1, 1, 0, 1, 1),
        E("scalar.sign@1", [O(Sc, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.sine@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.softplus@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.square-root@1", [O(Sc, -1)], 1, 0, 0, 0, 2, 0, 0, 1, 2),
        E("scalar.square@1", [O(Sc, -1)], 1, 0, 0, 0, 2, 0, 0, 2, 1),
        E("scalar.subtract@1", [O(Sc, -1), O(Sc, 0)], 1, 2, 3, 0, 1, 0, 0, 1, 1),
        E("scalar.tangent@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("scalar.truncate@1", [O(Sc, -1)], 1, 1, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.convolution@1", [O(Ve, -1), O(Ve, -1)], 4, 0, 0, 0, 3, 0, 1, 1, 1),
        E("sequence.difference@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.exponential-moving-average@1", [O(Ve, -1), O(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-maximum@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-mean@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-median@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-minimum@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-quantile@1", [O(Ve, -1), C(Sc, -2), O(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-standard-deviation@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-sum@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("sequence.rolling-variance@1", [O(Ve, -1), C(Sc, -2)], 4, 0, 0, 0, 2, 0, 0, 2, 1),
        E("shape.greatest-convex-minorant@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("shape.is-completely-monotone@1", [O(Ve, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("shape.is-log-concave@1", [O(Ve, -1)], 2, 0, 0, 0, 0, 0, 0, 1, 1),
        E("shape.least-concave-majorant@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("special.beta@1", [O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("special.error-function@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("special.log-gamma@1", [O(Sc, -2)], 1, 1, 0, 0, 0, 0, 0, 1, 1),
        E("special.regularized-incomplete-beta@1", [O(Sc, -2), O(Sc, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("state.transition-counts@1", [O(Ve, -2), O(Sc, -2)], 5, 0, 0, 0, 0, 0, 0, 1, 1),
        E("statistics.autocorrelation@1", [O(Ve, -1), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("statistics.central-moment@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("statistics.distance-correlation@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("statistics.histogram@1", [O(Ve, -1), O(Ve, 0)], 4, 0, 0, 0, 0, 0, 0, 1, 1),
        E("statistics.interquartile-range@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("statistics.kendall-tau-b@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("statistics.linear-intercept@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 1, 1, 0, 1, 1),
        E("statistics.linear-r-squared@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("statistics.linear-slope@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 4, 1, 0, 1, 1),
        E("statistics.median-absolute-deviation@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("statistics.pearson-correlation@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("statistics.population-covariance@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 3, 0, 1, 1, 1),
        E("statistics.population-excess-kurtosis@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("statistics.population-skewness@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("statistics.population-standard-deviation@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("statistics.population-variance@1", [O(Ve, -1)], 1, 0, 0, 0, 2, 0, 0, 2, 1),
        E("statistics.pseudomedian@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("statistics.raw-moment@1", [O(Ve, -2), O(Sc, -2)], 1, 0, 0, 0, 0, 0, 0, 1, 1)
    ];

    private static MathBlockTypeSignature[] Entries4() =>
    [
        E("statistics.root-mean-square@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("statistics.sample-covariance@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 3, 0, 1, 1, 1),
        E("statistics.sample-standard-deviation@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("statistics.sample-variance@1", [O(Ve, -1)], 1, 0, 0, 0, 2, 0, 0, 2, 1),
        E("statistics.spearman-correlation@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("statistics.theil-sen-slope@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 4, 1, 0, 1, 1),
        E("statistics.weighted-mean@1", [O(Ve, -1), O(Ve, -2)], 1, 7, 3, 0, 1, 0, 0, 1, 1),
        E("statistics.weighted-population-variance@1", [O(Ve, -1), O(Ve, -2)], 1, 7, 3, 0, 2, 0, 0, 2, 1),
        E("survival.discrete-hazard@1", [O(Ve, -2)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("survival.product-limit@1", [O(Ve, -1), O(Ve, 0)], 4, 4, 3, 0, 0, 0, 0, 1, 1),
        E("topology.zero-dimensional-persistence@1", [O(PS, -1)], 4, 6, 0, -1, 1, 0, 0, 1, 1),
        E("transform.discrete-fourier@1", [O(Ve, -1)], 6, 3, 0, 0, 1, 0, 0, 1, 1),
        E("transform.haar@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("transform.inverse-discrete-fourier@1", [O(CV, -1)], 6, 1, 0, 0, 1, 0, 0, 1, 1),
        E("transform.walsh-hadamard@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("transport.coupling-cost@1", [O(Ma, -2), O(Ma, -1)], 1, 7, 3, 0, 1, 1, 0, 1, 1),
        E("transport.energy-distance@1", [O(Ve, -1), O(Ve, 0)], 1, 0, 0, 0, 2, 0, 0, 1, 2),
        E("transport.ordered-earth-mover@1", [O(Ve, -2), O(Ve, -2)], 1, 7, 3, 0, 0, 0, 0, 1, 1),
        E("transport.uniform-wasserstein@1", [O(Ve, -1), O(Ve, 0), O(Sc, -2)], 1, 7, 3, 0, 1, 0, 0, 1, 1),
        E("vector.absolute@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("vector.add-scalar@1", [O(Ve, -1), O(Sc, 0)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("vector.add@1", [O(Ve, -1), O(Ve, 0)], 4, 2, 3, 0, 1, 0, 0, 1, 1),
        E("vector.append@1", [O(Ve, -1), O(Sc, 0)], 4, 9, 0, 1, 1, 0, 0, 1, 1),
        E("vector.arg-maximum@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("vector.arg-minimum@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("vector.concatenate@1", [O(Ve, -1), O(Ve, 0)], 4, 5, 0, 1, 1, 0, 0, 1, 1),
        E("vector.cumulative-product@1", [O(Ve, -2)], 4, 1, 0, 0, 0, 0, 0, 1, 1),
        E("vector.cumulative-sum@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("vector.divide@1", [O(Ve, -1), O(Ve, -1)], 4, 4, 3, 0, 4, 0, 1, 1, 1),
        E("vector.dot@1", [O(Ve, -1), O(Ve, -1)], 1, 7, 3, 0, 3, 0, 1, 1, 1),
        E("vector.equal@1", [O(Ve, -1), O(Ve, 0)], 11, 4, 3, 0, 0, 0, 0, 1, 1),
        E("vector.exponential@1", [O(Ve, -2)], 4, 1, 0, 0, 0, 0, 0, 1, 1),
        E("vector.gather@1", [O(Ve, -1), O(Ve, -2)], 4, 3, 1, 0, 1, 0, 0, 1, 1),
        E("vector.geometric-mean@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.greater-than@1", [O(Ve, -1), O(Ve, 0)], 11, 4, 3, 0, 0, 0, 0, 1, 1),
        E("vector.index@1", [O(Ve, -1), O(Sc, -2)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.l1-norm@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.l2-norm@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.length@1", [O(Ve, -1)], 1, 0, 0, 0, 0, 0, 0, 1, 1),
        E("vector.less-than@1", [O(Ve, -1), O(Ve, 0)], 11, 4, 3, 0, 0, 0, 0, 1, 1),
        E("vector.linspace@1", [O(Sc, -1), O(Sc, 0), O(Sc, -2)], 4, 7, 3, 0, 1, 0, 0, 1, 1),
        E("vector.maximum@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.mean@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.median@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.minimum@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.multiply@1", [O(Ve, -1), O(Ve, -1)], 4, 4, 3, 0, 3, 0, 1, 1, 1),
        E("vector.natural-logarithm@1", [O(Ve, -2)], 4, 1, 0, 0, 0, 0, 0, 1, 1),
        E("vector.normalize-l1@1", [O(Ve, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("vector.normalize-l2@1", [O(Ve, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("vector.positive-part@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("vector.power@1", [O(Ve, -2), O(Sc, -2)], 4, 1, 0, 0, 0, 0, 0, 1, 1),
        E("vector.prepend@1", [O(Ve, -1), O(Sc, 0)], 4, 9, 0, 1, 1, 0, 0, 1, 1),
        E("vector.quantile@1", [O(Ve, -1), O(Sc, -2)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.rank@1", [O(Ve, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("vector.repeat@1", [O(Sc, -1), O(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.reverse@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("vector.scale@1", [O(Ve, -1), O(Sc, -1)], 4, 3, 0, 0, 3, 0, 1, 1, 1),
        E("vector.select@1", [O(BV, -1), O(Ve, -1), O(Ve, 1)], 4, 2, 7, 6, 1, 1, 0, 1, 1),
        E("vector.sign@1", [O(Ve, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("vector.slice@1", [O(Ve, -1), O(Sc, -2), O(Sc, -2)], 4, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.sort@1", [O(Ve, -1)], 4, 1, 0, 0, 1, 0, 0, 1, 1),
        E("vector.square-root@1", [O(Ve, -1)], 4, 3, 0, 0, 2, 0, 0, 1, 2),
        E("vector.square@1", [O(Ve, -1)], 4, 3, 0, 0, 2, 0, 0, 2, 1),
        E("vector.standardize@1", [O(Ve, -1)], 4, 3, 0, 0, 0, 0, 0, 1, 1),
        E("vector.subtract@1", [O(Ve, -1), O(Ve, 0)], 4, 2, 3, 0, 1, 0, 0, 1, 1),
        E("vector.sum@1", [O(Ve, -1)], 1, 0, 0, 0, 1, 0, 0, 1, 1),
        E("vector.unique@1", [O(Ve, -1)], 4, 0, 0, 0, 1, 0, 0, 1, 1)
    ];

    private static MathBlockTypeOperand O(int kinds, int unit) => new(kinds, unit, false);

    private static MathBlockTypeOperand C(int kinds, int unit) => new(kinds, unit, true);

    private static MathBlockTypeSignature E(string identity, MathBlockTypeOperand[] operands, params int[] parameters) =>
        new(identity, MathBlockTypeRuleKind.Composed, parameters, operands);
}
