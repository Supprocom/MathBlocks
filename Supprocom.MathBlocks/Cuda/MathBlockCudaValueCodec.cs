using System.Runtime.InteropServices;

namespace Supprocom.MathBlocks.Cuda;

public readonly record struct MathBlockCudaValueCodecSchema(
    int Version,
    string Definition)
{
    public string Fingerprint => MathBlockCudaContractHash.Create(
        "mathblocks-cuda-value-codec-schema\n" +
        Version.ToString(System.Globalization.CultureInfo.InvariantCulture) + "\n" +
        Definition + "\n");
}

public static class MathBlockCudaValueCodec
{
    public const int SchemaVersion = 1;
    public const string SchemaDefinition = """
        byte-order=little-endian
        slot=scalar:f64,data:u64,scratch:u64,boolean:i32,valid:i32,rows:i32,columns:i32,count:i32,capacity:i32
        invalid=valid:0,count:0,payload:none
        scalar=slot.scalar:f64,payload:none,count:0,rows:0,columns:0
        boolean=slot.boolean:i32,payload:none,count:0,rows:0,columns:0
        complex=payload:[real:f64,imaginary:f64],count:1,rows:0,columns:0
        vector=payload:f64[count],rows:count,columns:0
        boolean-vector=payload:i32[count],rows:count,columns:0
        matrix=payload:f64[rows*columns],count:rows*columns
        complex-vector=payload:[real:f64,imaginary:f64][count],rows:count,columns:0
        complex-matrix=payload:[real:f64,imaginary:f64][rows*columns],count:rows*columns
        point-set=payload:[x:f64,y:f64][count],rows:count,columns:0
        graph=payload:graph-edge[count],rows:vertex-count,columns:0
        run-set=payload:run[count],rows:count,columns:0
        header-count=static-matrix-product|complex-one|declared-capacity
        read-validity=valid-zero-is-invalid
        capacity=count-must-not-exceed-capacity
        """;

    public static MathBlockCudaValueCodecSchema Schema { get; } =
        new(SchemaVersion, SchemaDefinition);

    public static string SchemaFingerprint => Schema.Fingerprint;

    public static string ImplementationFingerprint { get; } =
        MathBlockCudaContractHash.CreateImplementation(typeof(MathBlockCudaValueCodec));

    public static unsafe int GetPayloadByteCount(MathBlockValueKind kind, int capacity)
    {
        if (capacity < 0)
            throw new ArgumentOutOfRangeException(nameof(capacity));
        return kind switch
        {
            MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
            MathBlockValueKind.Vector or MathBlockValueKind.Matrix =>
                checked(capacity * sizeof(double)),
            MathBlockValueKind.BooleanVector => checked(capacity * sizeof(int)),
            MathBlockValueKind.Complex or MathBlockValueKind.ComplexVector or
                MathBlockValueKind.ComplexMatrix or MathBlockValueKind.PointSet =>
                checked(capacity * 2 * sizeof(double)),
            MathBlockValueKind.Graph =>
                checked(capacity * sizeof(MathBlockCudaGraphEdgeDescriptor)),
            MathBlockValueKind.RunSet =>
                checked(capacity * sizeof(MathBlockCudaRunDescriptor)),
            _ => throw new NotSupportedException($"The CUDA value ABI does not support '{kind}'.")
        };
    }

    public static int GetElementCount(MathBlockValue value) => value.Type.Kind switch
    {
        MathBlockValueKind.Scalar or MathBlockValueKind.Boolean => 0,
        MathBlockValueKind.Complex => 1,
        MathBlockValueKind.Vector => value.AsVector().Count,
        MathBlockValueKind.BooleanVector => value.AsBooleanVector().Count,
        MathBlockValueKind.Matrix => checked(value.AsMatrix().Rows * value.AsMatrix().Columns),
        MathBlockValueKind.ComplexVector => value.AsComplexVector().Count,
        MathBlockValueKind.ComplexMatrix =>
            checked(value.AsComplexMatrix().Rows * value.AsComplexMatrix().Columns),
        MathBlockValueKind.PointSet => value.AsPointSet().Count,
        MathBlockValueKind.Graph => value.AsGraph().Count,
        MathBlockValueKind.RunSet => value.AsRunSet().Count,
        _ => throw new NotSupportedException(
            $"The CUDA value ABI does not support '{value.Type.Kind}'.")
    };

    public static unsafe void WriteHeader(
        IntPtr arena,
        int slotOffset,
        ulong payloadPointer,
        ulong scratchPointer,
        int capacity,
        MathBlockType type,
        bool valid)
    {
        RequireArena(arena);
        RequireOffset(slotOffset, nameof(slotOffset));
        if (capacity < 0)
            throw new ArgumentOutOfRangeException(nameof(capacity));
        var slot = new MathBlockCudaSlotDescriptor
        {
            DataPointer = payloadPointer,
            ScratchPointer = scratchPointer,
            Valid = valid ? 1 : 0,
            Rows = type.Rows,
            Columns = type.Columns,
            Count = type.Kind is MathBlockValueKind.Matrix or MathBlockValueKind.ComplexMatrix &&
                    type.Rows > 0 &&
                    type.Columns > 0
                ? checked(type.Rows * type.Columns)
                : type.Kind == MathBlockValueKind.Complex
                    ? 1
                    : capacity,
            Capacity = capacity
        };
        *(MathBlockCudaSlotDescriptor*)((byte*)arena + slotOffset) = slot;
    }

    public static unsafe void WriteValue(
        IntPtr arena,
        int slotOffset,
        int payloadOffset,
        ulong payloadPointer,
        ulong scratchPointer,
        int capacity,
        MathBlockValue value)
    {
        RequireArena(arena);
        RequireOffset(slotOffset, nameof(slotOffset));
        if (capacity < 0)
            throw new ArgumentOutOfRangeException(nameof(capacity));
        var count = value.IsValid ? GetElementCount(value) : 0;
        if (count > capacity)
        {
            throw new ArgumentException(
                $"The CUDA input requires {count} elements, but its capacity is {capacity}.",
                nameof(value));
        }

        var slot = new MathBlockCudaSlotDescriptor
        {
            ScalarValue = value.IsValid && value.Type.Kind == MathBlockValueKind.Scalar
                ? value.AsScalar()
                : 0d,
            DataPointer = payloadPointer,
            ScratchPointer = scratchPointer,
            BooleanValue = value.IsValid &&
                value.Type.Kind == MathBlockValueKind.Boolean &&
                value.AsBoolean()
                    ? 1
                    : 0,
            Valid = value.IsValid ? 1 : 0,
            Rows = GetRows(value, count),
            Columns = GetColumns(value),
            Count = count,
            Capacity = capacity
        };
        if (value.IsValid && count != 0)
            WritePayload(arena, payloadOffset, value, count);
        *(MathBlockCudaSlotDescriptor*)((byte*)arena + slotOffset) = slot;
    }

    public static unsafe MathBlockValue ReadValue(
        IntPtr arena,
        int slotOffset,
        int payloadOffset,
        MathBlockType type)
    {
        RequireArena(arena);
        RequireOffset(slotOffset, nameof(slotOffset));
        var slot = *(MathBlockCudaSlotDescriptor*)((byte*)arena + slotOffset);
        if (slot.Valid == 0)
            return MathBlockValue.Invalid(type, "The CUDA result is invalid.");
        if (slot.Count < 0 || slot.Count > slot.Capacity)
            throw new InvalidOperationException("The CUDA result count exceeds its arena capacity.");
        return type.Kind switch
        {
            MathBlockValueKind.Scalar => MathBlockValue.Scalar(slot.ScalarValue, type.Unit),
            MathBlockValueKind.Boolean => MathBlockValue.Boolean(slot.BooleanValue != 0),
            MathBlockValueKind.Complex => MathBlockValue.Complex(
                ReadComplex(arena, payloadOffset),
                type.Unit),
            MathBlockValueKind.Vector => MathBlockValue.Vector(
                ReadDoubles(arena, payloadOffset, slot.Count),
                type.Unit),
            MathBlockValueKind.BooleanVector => MathBlockValue.BooleanVector(
                ReadBooleans(arena, payloadOffset, slot.Count)),
            MathBlockValueKind.Matrix => MathBlockValue.Matrix(
                new MathBlockMatrix(
                    slot.Rows,
                    slot.Columns,
                    ReadDoubles(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.ComplexVector => MathBlockValue.ComplexVector(
                ReadComplexValues(arena, payloadOffset, slot.Count),
                type.Unit),
            MathBlockValueKind.ComplexMatrix => MathBlockValue.ComplexMatrix(
                new MathBlockComplexMatrix(
                    slot.Rows,
                    slot.Columns,
                    ReadComplexValues(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.PointSet => MathBlockValue.PointSet(
                new MathBlockPointSet(ReadPoints(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.Graph => MathBlockValue.Graph(
                new MathBlockGraph(slot.Rows, ReadGraphEdges(arena, payloadOffset, slot.Count)),
                type.Unit),
            MathBlockValueKind.RunSet => MathBlockValue.RunSet(
                new MathBlockRunSet(ReadRuns(arena, payloadOffset, slot.Count)),
                type.Unit),
            _ => throw new InvalidOperationException(
                $"Unsupported CUDA output kind '{type.Kind}'.")
        };
    }

    private static unsafe void WritePayload(
        IntPtr arena,
        int payloadOffset,
        MathBlockValue value,
        int count)
    {
        RequirePayload(payloadOffset);
        if (value.Type.Kind is MathBlockValueKind.Vector or MathBlockValueKind.Matrix)
        {
            var destination = (double*)((byte*)arena + payloadOffset);
            if (value.Type.Kind == MathBlockValueKind.Vector)
            {
                var source = value.AsVector();
                for (var index = 0; index < count; index++)
                    destination[index] = source[index];
            }
            else
            {
                var source = value.AsMatrix();
                var index = 0;
                for (var row = 0; row < source.Rows; row++)
                for (var column = 0; column < source.Columns; column++)
                    destination[index++] = source[row, column];
            }
        }
        else if (value.Type.Kind == MathBlockValueKind.BooleanVector)
        {
            var source = value.AsBooleanVector();
            var destination = (int*)((byte*)arena + payloadOffset);
            for (var index = 0; index < count; index++)
                destination[index] = source[index] ? 1 : 0;
        }
        else if (value.Type.Kind == MathBlockValueKind.Complex)
        {
            var source = value.AsComplex();
            var destination = (double*)((byte*)arena + payloadOffset);
            destination[0] = source.Real;
            destination[1] = source.Imaginary;
        }
        else if (value.Type.Kind is MathBlockValueKind.ComplexVector or
                 MathBlockValueKind.ComplexMatrix)
        {
            var destination = (double*)((byte*)arena + payloadOffset);
            if (value.Type.Kind == MathBlockValueKind.ComplexVector)
            {
                var source = value.AsComplexVector();
                for (var index = 0; index < count; index++)
                {
                    destination[index * 2] = source[index].Real;
                    destination[index * 2 + 1] = source[index].Imaginary;
                }
            }
            else
            {
                var source = value.AsComplexMatrix();
                var index = 0;
                for (var row = 0; row < source.Rows; row++)
                for (var column = 0; column < source.Columns; column++)
                {
                    var item = source[row, column];
                    destination[index * 2] = item.Real;
                    destination[index * 2 + 1] = item.Imaginary;
                    index++;
                }
            }
        }
        else if (value.Type.Kind == MathBlockValueKind.PointSet)
        {
            var source = value.AsPointSet();
            var destination = (double*)((byte*)arena + payloadOffset);
            for (var index = 0; index < count; index++)
            {
                destination[index * 2] = source[index].X;
                destination[index * 2 + 1] = source[index].Y;
            }
        }
        else if (value.Type.Kind == MathBlockValueKind.Graph)
        {
            var source = value.AsGraph();
            var destination = (MathBlockCudaGraphEdgeDescriptor*)((byte*)arena + payloadOffset);
            for (var index = 0; index < count; index++)
            {
                destination[index] = new MathBlockCudaGraphEdgeDescriptor
                {
                    From = source[index].From,
                    To = source[index].To,
                    Weight = source[index].Weight
                };
            }
        }
        else if (value.Type.Kind == MathBlockValueKind.RunSet)
        {
            var source = value.AsRunSet();
            var destination = (MathBlockCudaRunDescriptor*)((byte*)arena + payloadOffset);
            for (var index = 0; index < count; index++)
            {
                destination[index] = new MathBlockCudaRunDescriptor
                {
                    Start = source[index].Start,
                    Length = source[index].Length,
                    Value = source[index].Value
                };
            }
        }
    }

    private static int GetRows(MathBlockValue value, int count)
    {
        if (!value.IsValid)
            return value.Type.Rows;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Matrix => value.AsMatrix().Rows,
            MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Rows,
            MathBlockValueKind.Graph => value.AsGraph().VertexCount,
            MathBlockValueKind.Scalar or MathBlockValueKind.Boolean or MathBlockValueKind.Complex => 0,
            _ => count
        };
    }

    private static int GetColumns(MathBlockValue value)
    {
        if (!value.IsValid)
            return value.Type.Columns;
        return value.Type.Kind switch
        {
            MathBlockValueKind.Matrix => value.AsMatrix().Columns,
            MathBlockValueKind.ComplexMatrix => value.AsComplexMatrix().Columns,
            _ => 0
        };
    }

    private static unsafe Complex ReadComplex(IntPtr arena, int payloadOffset)
    {
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        return new Complex(source[0], source[1]);
    }

    private static unsafe Complex[] ReadComplexValues(IntPtr arena, int payloadOffset, int count)
    {
        var values = new Complex[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new Complex(source[index * 2], source[index * 2 + 1]);
        return values;
    }

    private static unsafe MathBlockPoint[] ReadPoints(IntPtr arena, int payloadOffset, int count)
    {
        var values = new MathBlockPoint[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new MathBlockPoint(source[index * 2], source[index * 2 + 1]);
        return values;
    }

    private static unsafe MathBlockGraphEdge[] ReadGraphEdges(
        IntPtr arena,
        int payloadOffset,
        int count)
    {
        var values = new MathBlockGraphEdge[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (MathBlockCudaGraphEdgeDescriptor*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new MathBlockGraphEdge(source[index].From, source[index].To, source[index].Weight);
        return values;
    }

    private static unsafe MathBlockRun[] ReadRuns(IntPtr arena, int payloadOffset, int count)
    {
        var values = new MathBlockRun[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (MathBlockCudaRunDescriptor*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = new MathBlockRun(source[index].Start, source[index].Length, source[index].Value);
        return values;
    }

    private static unsafe double[] ReadDoubles(IntPtr arena, int payloadOffset, int count)
    {
        var values = new double[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (double*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = source[index];
        return values;
    }

    private static unsafe bool[] ReadBooleans(IntPtr arena, int payloadOffset, int count)
    {
        var values = new bool[count];
        if (count == 0)
            return values;
        RequirePayload(payloadOffset);
        var source = (int*)((byte*)arena + payloadOffset);
        for (var index = 0; index < count; index++)
            values[index] = source[index] != 0;
        return values;
    }

    private static void RequireArena(IntPtr arena)
    {
        if (arena == IntPtr.Zero)
            throw new ArgumentException("The CUDA arena pointer is required.", nameof(arena));
    }

    private static void RequireOffset(int offset, string parameterName)
    {
        if (offset < 0)
            throw new ArgumentOutOfRangeException(parameterName);
    }

    private static void RequirePayload(int payloadOffset)
    {
        if (payloadOffset < 0)
            throw new InvalidOperationException("The CUDA value has no payload allocation.");
    }
}
