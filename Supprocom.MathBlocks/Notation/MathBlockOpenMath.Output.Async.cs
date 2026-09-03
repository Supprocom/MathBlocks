using System.Globalization;
using System.Text;
using System.Xml;

namespace Supprocom.MathBlocks;

public static partial class MathBlockOpenMath
{
    public static async Task WriteUtf8Async(
        MathBlockProgram program,
        Stream destination,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);
        if (!destination.CanWrite)
            throw new ArgumentException("The destination stream is not writable.", nameof(destination));

        cancellationToken.ThrowIfCancellationRequested();
        await ValidateOutputAsync(program, cancellationToken).ConfigureAwait(false);
        await using var output = new CancellationWriteStream(destination, cancellationToken);
        using var writer = XmlWriter.Create(output, CreateWriterSettings(StrictUtf8, true));
        await WriteDocumentAsync(writer, program, cancellationToken).ConfigureAwait(false);
        await writer.FlushAsync().ConfigureAwait(false);
    }

    public static async Task WriteAsync(
        MathBlockProgram program,
        TextWriter destination,
        CancellationToken cancellationToken = default)
    {
        ArgumentNullException.ThrowIfNull(program);
        ArgumentNullException.ThrowIfNull(destination);

        cancellationToken.ThrowIfCancellationRequested();
        await ValidateOutputAsync(program, cancellationToken).ConfigureAwait(false);
        await using var output = new CancellationTextWriter(destination, cancellationToken);
        using var writer = XmlWriter.Create(output, CreateWriterSettings(async: true));
        await WriteDocumentAsync(writer, program, cancellationToken).ConfigureAwait(false);
        await writer.FlushAsync().ConfigureAwait(false);
    }

    private static async Task ValidateOutputAsync(
        MathBlockProgram program,
        CancellationToken cancellationToken)
    {
        using var stream = new CountingWriteStream();
        using var writer = XmlWriter.Create(stream, CreateWriterSettings(StrictUtf8, true));
        await WriteDocumentAsync(writer, program, cancellationToken).ConfigureAwait(false);
        await writer.FlushAsync().ConfigureAwait(false);
    }

    private static async Task WriteDocumentAsync(
        XmlWriter writer,
        MathBlockProgram program,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await writer.WriteStartElementAsync(null, "OMOBJ", NamespaceUri).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(null, "xmlns", null, NamespaceUri).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(null, "cdbase", null, ContentDictionaryBase).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(null, "cdgroup", null, ContentDictionaryGroup).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(null, "version", null, StandardVersion).ConfigureAwait(false);

        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ProgramDictionary, "program").ConfigureAwait(false);
        await WriteNodesAsync(writer, program, cancellationToken).ConfigureAwait(false);
        await WriteOutputsAsync(writer, program, cancellationToken).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteNodesAsync(
        XmlWriter writer,
        MathBlockProgram program,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ProgramDictionary, "nodes").ConfigureAwait(false);
        for (var index = 0; index < program.PlanNodes.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var node = program.PlanNodes[index];
            if (node.Index != index)
                throw new InvalidOperationException("The program node order is invalid.");

            await writer.WriteStartElementAsync(null, "OMA", NamespaceUri).ConfigureAwait(false);
            await writer.WriteAttributeStringAsync(
                    null,
                    "id",
                    null,
                    NodeIdentifier(index))
                .ConfigureAwait(false);
            switch (node.Kind)
            {
                case MathBlockProgramNodeKind.Input:
                    await WriteSymbolAsync(writer, ProgramDictionary, "input").ConfigureAwait(false);
                    await WriteStringAsync(
                            writer,
                            RequireExportName(node.Name, "input"))
                        .ConfigureAwait(false);
                    await WriteTypeAsync(writer, node.Type, cancellationToken).ConfigureAwait(false);
                    break;
                case MathBlockProgramNodeKind.Constant:
                    await WriteSymbolAsync(writer, ProgramDictionary, "constant").ConfigureAwait(false);
                    await WriteTypeAsync(writer, node.Type, cancellationToken).ConfigureAwait(false);
                    await WriteValueAsync(writer, node.Value, cancellationToken).ConfigureAwait(false);
                    break;
                case MathBlockProgramNodeKind.Operation:
                    if (node.OperationIdentity is null)
                    {
                        throw new InvalidOperationException(
                            "The program contains an operation outside the standard OpenMath profile.");
                    }

                    var operationSymbol = OperationSymbolName(node.OperationIdentity);
                    if (!StandardProfile.Value.OperationSymbols.TryGetValue(
                            operationSymbol,
                            out var standardOperation) ||
                        !ReferenceEquals(program.Nodes[index].Operation, standardOperation))
                    {
                        throw new InvalidOperationException(
                            "The program contains an operation outside the standard OpenMath profile.");
                    }
                    await WriteSymbolAsync(
                            writer,
                            OperationDictionary,
                            operationSymbol)
                        .ConfigureAwait(false);
                    for (var inputIndex = 0; inputIndex < node.Inputs.Count; inputIndex++)
                    {
                        cancellationToken.ThrowIfCancellationRequested();
                        var input = node.Inputs[inputIndex];
                        if (input < 0 || input >= index)
                        {
                            throw new InvalidOperationException(
                                "An operation input must reference an earlier node.");
                        }
                        await WriteReferenceAsync(writer, input).ConfigureAwait(false);
                    }
                    break;
                default:
                    throw new InvalidOperationException("The program contains an unsupported node kind.");
            }
            await writer.WriteEndElementAsync().ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteOutputsAsync(
        XmlWriter writer,
        MathBlockProgram program,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ProgramDictionary, "outputs").ConfigureAwait(false);
        for (var index = 0; index < program.OutputCount; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var nodeIndex = program.GetOutputNodeIndex(index);
            if (nodeIndex < 0 || nodeIndex >= program.PlanNodes.Count)
                throw new InvalidOperationException("A program output has an invalid node.");

            await WriteApplicationStartAsync(writer).ConfigureAwait(false);
            await WriteSymbolAsync(writer, ProgramDictionary, "output").ConfigureAwait(false);
            await WriteStringAsync(
                    writer,
                    RequireExportName(program.GetOutputName(index), "output"))
                .ConfigureAwait(false);
            await WriteReferenceAsync(writer, nodeIndex).ConfigureAwait(false);
            await writer.WriteEndElementAsync().ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteTypeAsync(
        XmlWriter writer,
        MathBlockType type,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        RequireSupportedType(type, false);
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, TypeDictionary, "type").ConfigureAwait(false);
        await WriteSymbolAsync(writer, TypeDictionary, KindName(type.Kind)).ConfigureAwait(false);
        await WriteUnitAsync(writer, type.Unit, cancellationToken).ConfigureAwait(false);
        await WriteIntegerAsync(writer, type.Rows).ConfigureAwait(false);
        await WriteIntegerAsync(writer, type.Columns).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteUnitAsync(
        XmlWriter writer,
        MathBlockUnit unit,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, TypeDictionary, "unit").ConfigureAwait(false);
        await WriteRationalAsync(writer, unit.Dimension0).ConfigureAwait(false);
        await WriteRationalAsync(writer, unit.Dimension1).ConfigureAwait(false);
        await WriteRationalAsync(writer, unit.Dimension2).ConfigureAwait(false);
        await WriteRationalAsync(writer, unit.Dimension3).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteRationalAsync(XmlWriter writer, MathRational value)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, TypeDictionary, "rational").ConfigureAwait(false);
        await WriteIntegerAsync(writer, value.Numerator).ConfigureAwait(false);
        await WriteIntegerAsync(writer, value.Denominator).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteValueAsync(
        XmlWriter writer,
        MathBlockValue value,
        CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        if (!value.IsValid)
            throw new InvalidOperationException("An OpenMath constant must be valid.");

        switch (value.Type.Kind)
        {
            case MathBlockValueKind.Scalar:
                await WriteDoubleAsync(writer, value.AsScalar()).ConfigureAwait(false);
                break;
            case MathBlockValueKind.Boolean:
                await WriteBooleanAsync(writer, value.AsBoolean()).ConfigureAwait(false);
                break;
            case MathBlockValueKind.Complex:
                await WriteComplexAsync(writer, value.AsComplex()).ConfigureAwait(false);
                break;
            case MathBlockValueKind.Vector:
                await WriteVectorAsync(writer, value.AsVector(), cancellationToken).ConfigureAwait(false);
                break;
            case MathBlockValueKind.Matrix:
                await WriteMatrixAsync(writer, value.AsMatrix(), cancellationToken).ConfigureAwait(false);
                break;
            case MathBlockValueKind.ComplexVector:
                await WriteComplexVectorAsync(
                        writer,
                        value.AsComplexVector(),
                        cancellationToken)
                    .ConfigureAwait(false);
                break;
            case MathBlockValueKind.ComplexMatrix:
                await WriteComplexMatrixAsync(
                        writer,
                        value.AsComplexMatrix(),
                        cancellationToken)
                    .ConfigureAwait(false);
                break;
            case MathBlockValueKind.PointSet:
                await WritePointSetAsync(writer, value.AsPointSet(), cancellationToken).ConfigureAwait(false);
                break;
            case MathBlockValueKind.Graph:
                await WriteGraphAsync(writer, value.AsGraph(), cancellationToken).ConfigureAwait(false);
                break;
            case MathBlockValueKind.RunSet:
                await WriteRunSetAsync(writer, value.AsRunSet(), cancellationToken).ConfigureAwait(false);
                break;
            case MathBlockValueKind.BooleanVector:
                await WriteBooleanVectorAsync(
                        writer,
                        value.AsBooleanVector(),
                        cancellationToken)
                    .ConfigureAwait(false);
                break;
            default:
                throw new InvalidOperationException("The constant value kind is not supported.");
        }
    }

    private static async Task WriteVectorAsync(
        XmlWriter writer,
        IReadOnlyList<double> values,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "vector").ConfigureAwait(false);
        for (var index = 0; index < values.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await WriteDoubleAsync(writer, values[index]).ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteMatrixAsync(
        XmlWriter writer,
        MathBlockMatrix value,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "matrix").ConfigureAwait(false);
        for (var row = 0; row < value.Rows; row++)
        {
            for (var column = 0; column < value.Columns; column++)
            {
                cancellationToken.ThrowIfCancellationRequested();
                await WriteDoubleAsync(writer, value[row, column]).ConfigureAwait(false);
            }
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteComplexAsync(XmlWriter writer, MathBlockComplexValue value)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "complex").ConfigureAwait(false);
        await WriteDoubleAsync(writer, value.Real).ConfigureAwait(false);
        await WriteDoubleAsync(writer, value.Imaginary).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteComplexVectorAsync(
        XmlWriter writer,
        IReadOnlyList<MathBlockComplexValue> values,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "complex-vector").ConfigureAwait(false);
        for (var index = 0; index < values.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await WriteComplexAsync(writer, values[index]).ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteComplexMatrixAsync(
        XmlWriter writer,
        MathBlockComplexMatrix value,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "complex-matrix").ConfigureAwait(false);
        for (var row = 0; row < value.Rows; row++)
        {
            for (var column = 0; column < value.Columns; column++)
            {
                cancellationToken.ThrowIfCancellationRequested();
                await WriteComplexAsync(writer, value[row, column]).ConfigureAwait(false);
            }
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WritePointSetAsync(
        XmlWriter writer,
        IReadOnlyList<MathBlockPoint> values,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "point-set").ConfigureAwait(false);
        for (var index = 0; index < values.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await WriteApplicationStartAsync(writer).ConfigureAwait(false);
            await WriteSymbolAsync(writer, ValueDictionary, "point").ConfigureAwait(false);
            await WriteDoubleAsync(writer, values[index].X).ConfigureAwait(false);
            await WriteDoubleAsync(writer, values[index].Y).ConfigureAwait(false);
            await writer.WriteEndElementAsync().ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteGraphAsync(
        XmlWriter writer,
        MathBlockGraph value,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "graph").ConfigureAwait(false);
        await WriteIntegerAsync(writer, value.VertexCount).ConfigureAwait(false);
        for (var index = 0; index < value.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            var edge = value[index];
            await WriteApplicationStartAsync(writer).ConfigureAwait(false);
            await WriteSymbolAsync(writer, ValueDictionary, "edge").ConfigureAwait(false);
            await WriteIntegerAsync(writer, edge.From).ConfigureAwait(false);
            await WriteIntegerAsync(writer, edge.To).ConfigureAwait(false);
            await WriteDoubleAsync(writer, edge.Weight).ConfigureAwait(false);
            await writer.WriteEndElementAsync().ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteRunSetAsync(
        XmlWriter writer,
        IReadOnlyList<MathBlockRun> values,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "run-set").ConfigureAwait(false);
        for (var index = 0; index < values.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await WriteApplicationStartAsync(writer).ConfigureAwait(false);
            await WriteSymbolAsync(writer, ValueDictionary, "run").ConfigureAwait(false);
            await WriteIntegerAsync(writer, values[index].Start).ConfigureAwait(false);
            await WriteIntegerAsync(writer, values[index].Length).ConfigureAwait(false);
            await WriteDoubleAsync(writer, values[index].Value).ConfigureAwait(false);
            await writer.WriteEndElementAsync().ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteBooleanVectorAsync(
        XmlWriter writer,
        IReadOnlyList<bool> values,
        CancellationToken cancellationToken)
    {
        await WriteApplicationStartAsync(writer).ConfigureAwait(false);
        await WriteSymbolAsync(writer, ValueDictionary, "boolean-vector").ConfigureAwait(false);
        for (var index = 0; index < values.Count; index++)
        {
            cancellationToken.ThrowIfCancellationRequested();
            await WriteBooleanAsync(writer, values[index]).ConfigureAwait(false);
        }
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteDoubleAsync(XmlWriter writer, double value)
    {
        if (!double.IsFinite(value))
            throw new InvalidOperationException("An OpenMath float must be finite.");
        await writer.WriteStartElementAsync(null, "OMF", NamespaceUri).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(
                null,
                "hex",
                null,
                BitConverter.DoubleToUInt64Bits(value).ToString("X16", CultureInfo.InvariantCulture))
            .ConfigureAwait(false);
        await writer.WriteFullEndElementAsync().ConfigureAwait(false);
    }

    private static Task WriteBooleanAsync(XmlWriter writer, bool value) =>
        WriteSymbolAsync(writer, ValueDictionary, value ? "true" : "false");

    private static async Task WriteIntegerAsync(XmlWriter writer, int value)
    {
        await writer.WriteStartElementAsync(null, "OMI", NamespaceUri).ConfigureAwait(false);
        await writer.WriteStringAsync(value.ToString(CultureInfo.InvariantCulture)).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteStringAsync(XmlWriter writer, string value)
    {
        await writer.WriteStartElementAsync(null, "OMSTR", NamespaceUri).ConfigureAwait(false);
        await writer.WriteStringAsync(value).ConfigureAwait(false);
        await writer.WriteEndElementAsync().ConfigureAwait(false);
    }

    private static async Task WriteReferenceAsync(XmlWriter writer, int nodeIndex)
    {
        await writer.WriteStartElementAsync(null, "OMR", NamespaceUri).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(
                null,
                "href",
                null,
                string.Concat("#", NodeIdentifier(nodeIndex)))
            .ConfigureAwait(false);
        await writer.WriteFullEndElementAsync().ConfigureAwait(false);
    }

    private static Task WriteApplicationStartAsync(XmlWriter writer) =>
        writer.WriteStartElementAsync(null, "OMA", NamespaceUri);

    private static async Task WriteSymbolAsync(
        XmlWriter writer,
        string dictionary,
        string name)
    {
        await writer.WriteStartElementAsync(null, "OMS", NamespaceUri).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(null, "cd", null, dictionary).ConfigureAwait(false);
        await writer.WriteAttributeStringAsync(null, "name", null, name).ConfigureAwait(false);
        await writer.WriteFullEndElementAsync().ConfigureAwait(false);
    }

    private sealed class CancellationWriteStream(
        Stream destination,
        CancellationToken cancellationToken) : Stream
    {
        public override bool CanRead => false;
        public override bool CanSeek => false;
        public override bool CanWrite => destination.CanWrite;
        public override long Length => throw new NotSupportedException();
        public override long Position
        {
            get => throw new NotSupportedException();
            set => throw new NotSupportedException();
        }

        public override void Flush()
        {
        }

        public override Task FlushAsync(CancellationToken token) =>
            destination.FlushAsync(SelectToken(token));

        public override void Write(byte[] buffer, int offset, int count) =>
            throw new InvalidOperationException("The async writer used synchronous output.");

        public override void Write(ReadOnlySpan<byte> buffer) =>
            throw new InvalidOperationException("The async writer used synchronous output.");

        public override Task WriteAsync(
            byte[] buffer,
            int offset,
            int count,
            CancellationToken token) =>
            destination.WriteAsync(buffer, offset, count, SelectToken(token));

        public override ValueTask WriteAsync(
            ReadOnlyMemory<byte> buffer,
            CancellationToken token = default) =>
            destination.WriteAsync(buffer, SelectToken(token));

        public override int Read(byte[] buffer, int offset, int count) =>
            throw new NotSupportedException();

        public override long Seek(long offset, SeekOrigin origin) =>
            throw new NotSupportedException();

        public override void SetLength(long value) => throw new NotSupportedException();

        private CancellationToken SelectToken(CancellationToken token)
        {
            cancellationToken.ThrowIfCancellationRequested();
            return cancellationToken.CanBeCanceled ? cancellationToken : token;
        }
    }

    private sealed class CancellationTextWriter(
        TextWriter destination,
        CancellationToken cancellationToken) : TextWriter
    {
        public override Encoding Encoding => destination.Encoding;

        public override void Flush()
        {
        }

        public override void Write(char value) =>
            throw new InvalidOperationException("The async writer used synchronous output.");

        public override void Write(char[] buffer, int index, int count) =>
            throw new InvalidOperationException("The async writer used synchronous output.");

        public override void Write(string? value) =>
            throw new InvalidOperationException("The async writer used synchronous output.");

        public override Task WriteAsync(char value) =>
            destination.WriteAsync(value);

        public override Task WriteAsync(char[] buffer, int index, int count) =>
            destination.WriteAsync(buffer, index, count);

        public override Task WriteAsync(string? value) =>
            destination.WriteAsync(value);

        public override Task WriteAsync(
            ReadOnlyMemory<char> buffer,
            CancellationToken token = default) =>
            destination.WriteAsync(buffer, SelectToken(token));

        public override Task FlushAsync() => destination.FlushAsync(cancellationToken);

        public override Task FlushAsync(CancellationToken token) =>
            destination.FlushAsync(SelectToken(token));

        private CancellationToken SelectToken(CancellationToken token)
        {
            cancellationToken.ThrowIfCancellationRequested();
            return cancellationToken.CanBeCanceled ? cancellationToken : token;
        }
    }
}
