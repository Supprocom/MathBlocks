namespace Supprocom.MathBlocks.Cuda;

/// <summary>
/// The fixed, versioned corpus that defines the value codec implementation fingerprint, as data. The fingerprint hashes
/// the bytes the codec itself writes and reads for these cases (see <see cref="MathBlockCudaContractHash"/>), so it moves
/// when the codec's behaviour moves and for no other reason: not for another compiler, another build configuration, an
/// assembly version, or any unrelated change in the assembly. A change to this table, or to what the codec does with an
/// entry, changes the fingerprint; the version tag is raised with every change to the table.
/// </summary>
internal static class MathBlockCudaValueCodecCorpus
{
    /// <summary>The version of the corpus table. It is part of the hashed material.</summary>
    public const string Version = "mathblocks-value-codec-corpus-v1";

    /// <summary>The payload pointer written into every slot, distinct from the scratch pointer and from zero.</summary>
    public const ulong DataPointer = 0x1122334455667788UL;

    /// <summary>The scratch pointer written into every slot, distinct from the payload pointer and from zero.</summary>
    public const ulong ScratchPointer = 0x0123456789ABCDEFUL;

    private const double NegativeZero = -0.0;
    private const double SmallestSubnormal = double.Epsilon;
    private const double Maximum = double.MaxValue;
    private const double Minimum = double.MinValue;

    private static readonly double LargestSubnormal = BitConverter.Int64BitsToDouble(0x000FFFFFFFFFFFFFL);
    private static readonly double SmallestNormal = BitConverter.Int64BitsToDouble(0x0010000000000000L);

    // Written with WriteValue, then read back with ReadValue and written again. The spare capacity is added to the
    // element count of a valid value to make the slot capacity; a negative spare capacity makes it smaller than the
    // count, which the codec rejects.
    public static ValueCase[] Values { get; } = CreateValues();

    // Written with WriteHeader.
    public static HeaderCase[] Headers { get; } = CreateHeaders();

    // Slots as a device leaves them, read with ReadValue and written again.
    public static ReadCase[] Reads { get; } = CreateReads();

    private static MathBlockUnit Unit(int dimension0, int denominator0, int dimension1, int denominator1) =>
        new(new MathRational(dimension0, denominator0), new MathRational(dimension1, denominator1), default, default);

    private static ValueCase[] CreateValues()
    {
        var length = Unit(2, 3, -1, 2);
        var edges = new[] { 0d, NegativeZero, SmallestSubnormal, LargestSubnormal, SmallestNormal, Maximum, Minimum };
        return
        [
            // Scalar: signs of zero, subnormals, extremes, units, spare capacity.
            new("scalar/zero", MathBlockValue.Scalar(0d)),
            new("scalar/negative-zero", MathBlockValue.Scalar(NegativeZero)),
            new("scalar/positive", MathBlockValue.Scalar(1.5)),
            new("scalar/negative", MathBlockValue.Scalar(-2.75)),
            new("scalar/inexact-tenth", MathBlockValue.Scalar(0.1)),
            new("scalar/smallest-subnormal", MathBlockValue.Scalar(SmallestSubnormal)),
            new("scalar/largest-subnormal", MathBlockValue.Scalar(LargestSubnormal)),
            new("scalar/smallest-normal", MathBlockValue.Scalar(SmallestNormal)),
            new("scalar/maximum", MathBlockValue.Scalar(Maximum)),
            new("scalar/minimum", MathBlockValue.Scalar(Minimum)),
            new("scalar/unit-basis", MathBlockValue.Scalar(2d, MathBlockUnit.Basis0)),
            new("scalar/unit-fractional", MathBlockValue.Scalar(3d, length)),
            new("scalar/spare-capacity", MathBlockValue.Scalar(4.5), 3),

            // Boolean.
            new("boolean/true", MathBlockValue.Boolean(true)),
            new("boolean/false", MathBlockValue.Boolean(false)),
            new("boolean/spare-capacity", MathBlockValue.Boolean(true), 2),

            // Complex.
            new("complex/zero", MathBlockValue.Complex(new Complex(0d, 0d))),
            new("complex/negative-zero-parts", MathBlockValue.Complex(new Complex(NegativeZero, NegativeZero))),
            new("complex/mixed", MathBlockValue.Complex(new Complex(1.5, -2.5))),
            new("complex/extremes", MathBlockValue.Complex(new Complex(Maximum, Minimum))),
            new("complex/subnormals", MathBlockValue.Complex(new Complex(SmallestSubnormal, LargestSubnormal))),
            new("complex/unit", MathBlockValue.Complex(new Complex(1d, 2d), MathBlockUnit.Basis1)),
            new("complex/spare-capacity", MathBlockValue.Complex(new Complex(3d, 4d)), 2),

            // Vector: empty, one element, edge values, unit, spare capacity, capacity below the count.
            new("vector/empty", MathBlockValue.Vector([])),
            new("vector/single", MathBlockValue.Vector([1.5])),
            new("vector/edges", MathBlockValue.Vector(edges)),
            new("vector/unit", MathBlockValue.Vector([1d, 2d, 3d], MathBlockUnit.Basis2)),
            new("vector/spare-capacity", MathBlockValue.Vector([1d, 2d, 3d]), 5),
            new("vector/empty-spare-capacity", MathBlockValue.Vector([]), 4),
            new("vector/capacity-below-count", MathBlockValue.Vector([1d, 2d, 3d]), -1),

            // Matrix: one element, two shapes with the same values, edge values, unit, spare capacity.
            new("matrix/1x1", MathBlockValue.Matrix(new MathBlockMatrix(1, 1, [2.5]))),
            new("matrix/2x3", MathBlockValue.Matrix(new MathBlockMatrix(2, 3, [1d, 2d, 3d, 4d, 5d, 6d]))),
            new("matrix/3x2", MathBlockValue.Matrix(new MathBlockMatrix(3, 2, [1d, 2d, 3d, 4d, 5d, 6d]))),
            new("matrix/edges-2x2", MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [NegativeZero, SmallestSubnormal, Maximum, Minimum]))),
            new("matrix/unit", MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 2d, 3d, 4d]), length)),
            new("matrix/spare-capacity", MathBlockValue.Matrix(new MathBlockMatrix(2, 2, [1d, 2d, 3d, 4d])), 6),

            // Boolean vector.
            new("boolean-vector/empty", MathBlockValue.BooleanVector([])),
            new("boolean-vector/single-true", MathBlockValue.BooleanVector([true])),
            new("boolean-vector/single-false", MathBlockValue.BooleanVector([false])),
            new("boolean-vector/mixed", MathBlockValue.BooleanVector([true, false, true, true, false])),
            new("boolean-vector/spare-capacity", MathBlockValue.BooleanVector([false, true]), 3),

            // Complex vector.
            new("complex-vector/empty", MathBlockValue.ComplexVector([])),
            new("complex-vector/single", MathBlockValue.ComplexVector([new Complex(1.5, -2.5)])),
            new("complex-vector/edges", MathBlockValue.ComplexVector(
                [new Complex(NegativeZero, SmallestSubnormal), new Complex(Maximum, Minimum), new Complex(LargestSubnormal, SmallestNormal)])),
            new("complex-vector/unit", MathBlockValue.ComplexVector([new Complex(1d, 2d), new Complex(3d, 4d)], length)),
            new("complex-vector/spare-capacity", MathBlockValue.ComplexVector([new Complex(1d, 2d)]), 4),

            // Complex matrix.
            new("complex-matrix/1x1", MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(1, 1, [new Complex(1.5, -2.5)]))),
            new("complex-matrix/2x3", MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(2, 3, ComplexRun(6)))),
            new("complex-matrix/3x2", MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(3, 2, ComplexRun(6)))),
            new("complex-matrix/unit", MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(2, 2, ComplexRun(4)), MathBlockUnit.Basis3)),
            new("complex-matrix/spare-capacity", MathBlockValue.ComplexMatrix(new MathBlockComplexMatrix(2, 2, ComplexRun(4))), 2),

            // Point set.
            new("point-set/empty", MathBlockValue.PointSet(new MathBlockPointSet([]))),
            new("point-set/single", MathBlockValue.PointSet(new MathBlockPointSet([new MathBlockPoint(1.5, -2.5)]))),
            new("point-set/edges", MathBlockValue.PointSet(new MathBlockPointSet(
                [new MathBlockPoint(NegativeZero, SmallestSubnormal), new MathBlockPoint(Maximum, Minimum), new MathBlockPoint(LargestSubnormal, SmallestNormal)]))),
            new("point-set/unit", MathBlockValue.PointSet(new MathBlockPointSet([new MathBlockPoint(1d, 2d)]), length)),
            new("point-set/spare-capacity", MathBlockValue.PointSet(new MathBlockPointSet([new MathBlockPoint(1d, 2d)])), 3),

            // Graph: no vertices, vertices without edges, one edge, edge weights at the edges.
            new("graph/empty", MathBlockValue.Graph(new MathBlockGraph(0, []))),
            new("graph/vertices-only", MathBlockValue.Graph(new MathBlockGraph(3, []))),
            new("graph/single", MathBlockValue.Graph(new MathBlockGraph(2, [new MathBlockGraphEdge(0, 1, 2.5)]))),
            new("graph/edges", MathBlockValue.Graph(new MathBlockGraph(
                4, [new MathBlockGraphEdge(0, 1, 2.5), new MathBlockGraphEdge(1, 2, NegativeZero), new MathBlockGraphEdge(3, 0, Maximum)]))),
            new("graph/unit", MathBlockValue.Graph(new MathBlockGraph(2, [new MathBlockGraphEdge(1, 0, 1d)]), length)),
            new("graph/spare-capacity", MathBlockValue.Graph(new MathBlockGraph(2, [new MathBlockGraphEdge(1, 0, 1d)])), 2),

            // Run set.
            new("run-set/empty", MathBlockValue.RunSet(new MathBlockRunSet([]))),
            new("run-set/single", MathBlockValue.RunSet(new MathBlockRunSet([new MathBlockRun(0, 1, 1.5)]))),
            new("run-set/edges", MathBlockValue.RunSet(new MathBlockRunSet(
                [new MathBlockRun(0, 2, NegativeZero), new MathBlockRun(5, 1, SmallestSubnormal), new MathBlockRun(10, 3, Maximum)]))),
            new("run-set/unit", MathBlockValue.RunSet(new MathBlockRunSet([new MathBlockRun(2, 2, 3d)]), length)),
            new("run-set/spare-capacity", MathBlockValue.RunSet(new MathBlockRunSet([new MathBlockRun(2, 2, 3d)])), 2),

            // Invalid states: every kind, with and without a unit and a shape, and the non-finite inputs that make a value invalid.
            new("invalid/scalar", MathBlockValue.Invalid(MathBlockType.Scalar(), "The scalar is invalid.")),
            new("invalid/scalar-unit", MathBlockValue.Invalid(MathBlockType.Scalar(length), "The scalar is invalid.")),
            new("invalid/scalar-not-a-number", MathBlockValue.Scalar(double.NaN)),
            new("invalid/scalar-positive-infinity", MathBlockValue.Scalar(double.PositiveInfinity, MathBlockUnit.Basis0)),
            new("invalid/scalar-negative-infinity", MathBlockValue.Scalar(double.NegativeInfinity)),
            new("invalid/scalar-spare-capacity", MathBlockValue.Invalid(MathBlockType.Scalar(), "The scalar is invalid."), 2),
            new("invalid/boolean", MathBlockValue.Invalid(MathBlockType.Boolean, "The Boolean is invalid.")),
            new("invalid/complex", MathBlockValue.Invalid(MathBlockType.Complex(length), "The complex value is invalid.")),
            new("invalid/complex-not-a-number", MathBlockValue.Complex(new Complex(double.NaN, 1d))),
            new("invalid/complex-infinite-imaginary", MathBlockValue.Complex(new Complex(1d, double.PositiveInfinity), MathBlockUnit.Basis1)),
            new("invalid/vector", MathBlockValue.Invalid(MathBlockType.Vector(length, 5), "The vector is invalid.")),
            new("invalid/vector-no-shape", MathBlockValue.Invalid(MathBlockType.Vector(), "The vector is invalid.")),
            new("invalid/matrix", MathBlockValue.Invalid(MathBlockType.Matrix(length, 2, 3), "The matrix is invalid.")),
            new("invalid/boolean-vector", MathBlockValue.Invalid(MathBlockType.BooleanVector(3), "The Boolean vector is invalid.")),
            new("invalid/complex-vector", MathBlockValue.Invalid(MathBlockType.ComplexVector(length, 4), "The complex vector is invalid.")),
            new("invalid/complex-matrix", MathBlockValue.Invalid(MathBlockType.ComplexMatrix(length, 3, 2), "The complex matrix is invalid.")),
            new("invalid/point-set", MathBlockValue.Invalid(MathBlockType.PointSet(length, 2), "The point set is invalid.")),
            new("invalid/graph", MathBlockValue.Invalid(MathBlockType.Graph(length, 4), "The graph is invalid.")),
            new("invalid/run-set", MathBlockValue.Invalid(MathBlockType.RunSet(length, 2), "The run set is invalid.")),
            new("invalid/vector-spare-capacity", MathBlockValue.Invalid(MathBlockType.Vector(length, 5), "The vector is invalid."), 4)
        ];
    }

    private static HeaderCase[] CreateHeaders()
    {
        var length = Unit(2, 3, -1, 2);
        return
        [
            new("header/scalar", MathBlockType.Scalar(length), 0, true),
            new("header/boolean", MathBlockType.Boolean, 0, true),
            new("header/complex-capacity-1", MathBlockType.Complex(length), 1, true),
            new("header/complex-capacity-3", MathBlockType.Complex(), 3, true),
            new("header/vector-7", MathBlockType.Vector(length, 7), 7, true),
            new("header/vector-no-shape", MathBlockType.Vector(), 0, true),
            new("header/vector-no-shape-capacity-5", MathBlockType.Vector(), 5, true),
            new("header/matrix-3x4-capacity-12", MathBlockType.Matrix(length, 3, 4), 12, true),
            new("header/matrix-3x4-capacity-20", MathBlockType.Matrix(length, 3, 4), 20, true),
            new("header/matrix-3x4-capacity-5", MathBlockType.Matrix(length, 3, 4), 5, true),
            new("header/matrix-46341-square", MathBlockType.Matrix(default, 46341, 46341), 46341, true),
            new("header/matrix-unknown-shape-capacity-9", MathBlockType.Matrix(), 9, true),
            new("header/matrix-rows-only-capacity-9", MathBlockType.Matrix(default, 3, 0), 9, true),
            new("header/complex-matrix-2x5-capacity-10", MathBlockType.ComplexMatrix(length, 2, 5), 10, true),
            new("header/complex-matrix-2x5-capacity-4", MathBlockType.ComplexMatrix(length, 2, 5), 4, true),
            new("header/complex-matrix-unknown-shape-capacity-6", MathBlockType.ComplexMatrix(), 6, true),
            new("header/complex-vector-5", MathBlockType.ComplexVector(length, 5), 5, true),
            new("header/boolean-vector-6", MathBlockType.BooleanVector(6), 6, true),
            new("header/point-set-3-capacity-6", MathBlockType.PointSet(length, 3), 6, true),
            new("header/graph-5-capacity-9", MathBlockType.Graph(length, 5), 9, true),
            new("header/run-set-4", MathBlockType.RunSet(length, 4), 4, true),
            new("header/scalar-invalid", MathBlockType.Scalar(length), 0, false),
            new("header/vector-invalid", MathBlockType.Vector(length, 7), 7, false),
            new("header/matrix-3x4-invalid", MathBlockType.Matrix(length, 3, 4), 12, false),
            new("header/graph-5-invalid", MathBlockType.Graph(length, 5), 9, false)
        ];
    }

    private static ReadCase[] CreateReads()
    {
        var length = Unit(2, 3, -1, 2);
        return
        [
            new(
                "read/vector",
                MathBlockType.Vector(length, 3),
                new MathBlockCudaSlotDescriptor { Valid = 1, Rows = 3, Count = 3, Capacity = 4 },
                [1.5, NegativeZero, 2.5]),
            new(
                "read/scalar",
                MathBlockType.Scalar(length),
                new MathBlockCudaSlotDescriptor { Valid = 1, ScalarValue = NegativeZero, Capacity = 2 },
                []),
            new(
                "read/boolean-nonzero",
                MathBlockType.Boolean,
                new MathBlockCudaSlotDescriptor { Valid = 1, BooleanValue = 7 },
                []),
            new(
                "read/matrix-2x2",
                MathBlockType.Matrix(default, 2, 2),
                new MathBlockCudaSlotDescriptor { Valid = 1, Rows = 2, Columns = 2, Count = 4, Capacity = 4 },
                [1d, 2d, 3d, 4d]),
            new(
                "read/invalid-with-payload",
                MathBlockType.Matrix(length, 2, 2),
                new MathBlockCudaSlotDescriptor { Valid = 0, Rows = 2, Columns = 2, Count = 4, Capacity = 4 },
                [1d, 2d, 3d, 4d]),
            new(
                "read/count-exceeds-capacity",
                MathBlockType.Vector(default, 5),
                new MathBlockCudaSlotDescriptor { Valid = 1, Rows = 5, Count = 5, Capacity = 4 },
                [1d, 2d, 3d, 4d]),
            new(
                "read/matrix-count-mismatch",
                MathBlockType.Matrix(default, 2, 3),
                new MathBlockCudaSlotDescriptor { Valid = 1, Rows = 2, Columns = 3, Count = 4, Capacity = 4 },
                [1d, 2d, 3d, 4d]),
            new(
                "read/graph-vertex-count-in-rows",
                MathBlockType.Graph(default, 4),
                new MathBlockCudaSlotDescriptor { Valid = 1, Rows = 4, Count = 0, Capacity = 2 },
                [])
        ];
    }

    private static Complex[] ComplexRun(int count)
    {
        var values = new Complex[count];
        for (var index = 0; index < count; index++)
            values[index] = new Complex(index + 0.5, -(index + 1.25));
        return values;
    }

    /// <summary>A value written with WriteValue and read back with ReadValue.</summary>
    /// <param name="Name">The entry name, hashed with the bytes.</param>
    /// <param name="Value">The value.</param>
    /// <param name="SpareCapacity">The capacity added to the element count of a valid value.</param>
    internal sealed record ValueCase(string Name, MathBlockValue Value, int SpareCapacity = 0);

    /// <summary>A header written with WriteHeader.</summary>
    /// <param name="Name">The entry name, hashed with the bytes.</param>
    /// <param name="Type">The type.</param>
    /// <param name="Capacity">The slot capacity.</param>
    /// <param name="Valid">Whether the slot is marked valid.</param>
    internal sealed record HeaderCase(string Name, MathBlockType Type, int Capacity, bool Valid);

    /// <summary>A slot as a device leaves it, read with ReadValue.</summary>
    /// <param name="Name">The entry name, hashed with the bytes.</param>
    /// <param name="Type">The type the host reads it as.</param>
    /// <param name="Slot">The slot header.</param>
    /// <param name="Payload">The payload, doubles placed after the header.</param>
    internal sealed record ReadCase(string Name, MathBlockType Type, MathBlockCudaSlotDescriptor Slot, double[] Payload);
}
