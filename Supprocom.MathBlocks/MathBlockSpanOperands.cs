namespace Supprocom.MathBlocks;

// The one, two or three operands of a span evaluation, held by value so a kernel reads them without an array or a list.
// The operands of an evaluation on values and of an evaluation on span arguments take the same kernels.
internal readonly ref struct MathBlockSpanOperands
{
    internal readonly MathBlockSpanArgument First;
    internal readonly MathBlockSpanArgument Second;
    internal readonly MathBlockSpanArgument Third;

    internal MathBlockSpanOperands(in MathBlockSpanArgument first)
    {
        Count = 1;
        First = first;
        Second = default;
        Third = default;
    }

    internal MathBlockSpanOperands(in MathBlockSpanArgument first, in MathBlockSpanArgument second)
    {
        Count = 2;
        First = first;
        Second = second;
        Third = default;
    }

    internal MathBlockSpanOperands(in MathBlockSpanArgument first, in MathBlockSpanArgument second, in MathBlockSpanArgument third)
    {
        Count = 3;
        First = first;
        Second = second;
        Third = third;
    }

    private MathBlockSpanOperands(int count, in MathBlockSpanArgument first, in MathBlockSpanArgument second, in MathBlockSpanArgument third)
    {
        Count = count;
        First = first;
        Second = second;
        Third = third;
    }

    internal ref readonly MathBlockSpanArgument this[int index]
    {
        get
        {
            switch (index)
            {
                case 0:
                    return ref First;
                case 1:
                    return ref Second;
                default:
                    return ref Third;
            }
        }
    }

    // The number of operands; a kernel of another arity declines the evaluation.
    internal int Count { get; }

    // The views of input values. More than three inputs give no operands, so every kernel declines them.
    internal static MathBlockSpanOperands FromValues(ReadOnlySpan<MathBlockValue> inputs) => inputs.Length switch
    {
        1 => new(1, MathBlockSpanArgument.FromValue(inputs[0]), default, default),
        2 => new(2, MathBlockSpanArgument.FromValue(inputs[0]), MathBlockSpanArgument.FromValue(inputs[1]), default),
        3 => new(3, MathBlockSpanArgument.FromValue(inputs[0]), MathBlockSpanArgument.FromValue(inputs[1]), MathBlockSpanArgument.FromValue(inputs[2])),
        _ => new(0, default, default, default)
    };

    // The inputs as values, for the evaluation that no kernel serves.
    internal MathBlockValue[] ToValues()
    {
        var values = new MathBlockValue[Count];
        if (Count > 0)
            values[0] = First.ToValue();
        if (Count > 1)
            values[1] = Second.ToValue();
        if (Count > 2)
            values[2] = Third.ToValue();
        return values;
    }
}
