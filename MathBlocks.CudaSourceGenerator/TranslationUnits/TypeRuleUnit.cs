#pragma warning disable CS0078, CS0649

using Supprocom.CSharp2CUDA;

// The output-type rules of the row-causal operations. This one file is compiled twice: into Supprocom.MathBlocks,
// where the host resolver calls it directly, and by MathBlocks.CudaSourceGenerator, which emits it as the CUDA
// module Supprocom.MathBlocks.Cuda.MathBlockCudaTypeRuleModule. Both therefore run the same statements over the same
// int32 layout. It uses only ints, longs, pointers and the struct below.
//
// A signature row is the int sequence: rule, P, parameters[P], N, then N operand triples (accepted kind mask,
// unit constraint, constant-slot flag). The unit constraint is -1 for any unit, -2 for dimensionless and k (an
// earlier operand index) for the unit of operand k. Kinds are MathBlockValueKind values below 32, so a kind mask is
// an int. A resolved type of kind -1 is invalid.
//
// Rule 1 (Composed) parameters: outputKind (a kind above 0, or -k for the kind of operand k), shapeMode,
// shapeA, shapeB, unitMode, unitA, unitB, exponentNumerator, exponentDenominator.
//   shapeMode 0: rows and columns unknown. 1: copy operand shapeA. 3: rows of operand shapeA, columns unknown.
//   2, 4 and 7 merge operands: those whose bits are set in the mask shapeA must agree on rows and on columns wherever
//   they know them, and the output takes the first known rows and columns among those in the mask shapeB (shapeA when
//   shapeB is 0); 2 keeps rows and columns, 4 keeps the rows, 7 keeps neither (a check only).
//   5: rows of shapeA plus rows of shapeB when both are known, failing when the sum leaves int32. 6: rows of shapeA
//   plus the constant shapeB (an integer, not an operand index) when known, failing when the sum leaves int32; 9 is
//   6 with wrap-around. 8: rows of shapeA minus one, and at least one.
//   unitMode 0: dimensionless. 1: unit of unitA. 2: unit of unitA to the exponent. 3: unit of unitA times unit of
//   unitB. 4: unit of unitA divided by unit of unitB.
// Rule 2 (ElementwiseForm) parameters: validityFlag, then the embedded row of the lifted scalar operation.
// Rule 3 (WindowForm) parameters: validityFlag, lastRowFlag, seriesMask, then the embedded row of the lifted operation.
internal static unsafe class MathBlockTypeRuleModule
{
    public struct MathBlockDeviceType
    {
        public int kind;
        public int rows;
        public int columns;
        public int unit_numerator0;
        public int unit_numerator1;
        public int unit_numerator2;
        public int unit_numerator3;
        public int unit_denominator0;
        public int unit_denominator1;
        public int unit_denominator2;
        public int unit_denominator3;
    }

    private const int StatusOk = 0;
    private const int StatusArity = 1;
    private const int StatusKind = 2;
    private const int StatusDimensionless = 3;
    private const int StatusUnit = 4;
    private const int StatusShape = 5;
    private const int StatusOverflow = 6;
    private const int StatusRule = 7;

    [CudaDevice(Name = "mathblocks_type_gcd")]
    private static long GreatestCommonDivisor(long left, long right)
    {
        if (left < 0)
            left = -left;
        if (right < 0)
            right = -right;
        if (left == 0)
        {
            if (right == 0)
                return 1;
            return right;
        }
        while (right != 0)
        {
            long next = left % right;
            left = right;
            right = next;
        }
        return left;
    }

    [CudaDevice(Name = "mathblocks_type_unit_numerator")]
    private static int UnitNumerator([CudaReadOnly] MathBlockDeviceType* value, int dimension)
    {
        if (dimension == 0)
            return value->unit_numerator0;
        if (dimension == 1)
            return value->unit_numerator1;
        if (dimension == 2)
            return value->unit_numerator2;
        return value->unit_numerator3;
    }

    [CudaDevice(Name = "mathblocks_type_unit_denominator")]
    private static int UnitDenominator([CudaReadOnly] MathBlockDeviceType* value, int dimension)
    {
        if (dimension == 0)
            return value->unit_denominator0;
        if (dimension == 1)
            return value->unit_denominator1;
        if (dimension == 2)
            return value->unit_denominator2;
        return value->unit_denominator3;
    }

    [CudaDevice(Name = "mathblocks_type_set_unit")]
    private static void SetUnit(MathBlockDeviceType* value, int dimension, int numerator, int denominator)
    {
        if (dimension == 0)
        {
            value->unit_numerator0 = numerator;
            value->unit_denominator0 = denominator;
        }
        else if (dimension == 1)
        {
            value->unit_numerator1 = numerator;
            value->unit_denominator1 = denominator;
        }
        else if (dimension == 2)
        {
            value->unit_numerator2 = numerator;
            value->unit_denominator2 = denominator;
        }
        else
        {
            value->unit_numerator3 = numerator;
            value->unit_denominator3 = denominator;
        }
    }

    // MathRational.CreateChecked: reduce, move the sign to the numerator, reject a result outside int32.
    [CudaDevice(Name = "mathblocks_type_normalize")]
    private static int SetUnitChecked(MathBlockDeviceType* value, int dimension, long numerator, long denominator)
    {
        long divisor = GreatestCommonDivisor(numerator, denominator);
        numerator /= divisor;
        denominator /= divisor;
        if (denominator < 0)
        {
            numerator = -numerator;
            denominator = -denominator;
        }
        if (numerator < -2147483648L || numerator > 2147483647L || denominator < 1 || denominator > 2147483647L)
            return 0;
        if (numerator == 0)
            denominator = 1;
        SetUnit(value, dimension, (int)numerator, (int)denominator);
        return 1;
    }

    [CudaDevice(Name = "mathblocks_type_clear")]
    private static void Clear(MathBlockDeviceType* value, int kind)
    {
        value->kind = kind;
        value->rows = 0;
        value->columns = 0;
        for (int dimension = 0; dimension < 4; dimension++)
            SetUnit(value, dimension, 0, 1);
    }

    [CudaDevice(Name = "mathblocks_type_copy_unit")]
    private static void CopyUnit([CudaReadOnly] MathBlockDeviceType* source, MathBlockDeviceType* target)
    {
        for (int dimension = 0; dimension < 4; dimension++)
            SetUnit(target, dimension, UnitNumerator(source, dimension), UnitDenominator(source, dimension));
    }

    [CudaDevice(Name = "mathblocks_type_unit_equal")]
    private static bool UnitsEqual([CudaReadOnly] MathBlockDeviceType* left, [CudaReadOnly] MathBlockDeviceType* right)
    {
        for (int dimension = 0; dimension < 4; dimension++)
        {
            if (UnitNumerator(left, dimension) != UnitNumerator(right, dimension) ||
                UnitDenominator(left, dimension) != UnitDenominator(right, dimension))
                return false;
        }
        return true;
    }

    [CudaDevice(Name = "mathblocks_type_unit_is_dimensionless")]
    private static bool IsDimensionless([CudaReadOnly] MathBlockDeviceType* value)
    {
        for (int dimension = 0; dimension < 4; dimension++)
        {
            if (UnitNumerator(value, dimension) != 0)
                return false;
        }
        return true;
    }

    // Writes left^leftSign * right^rightSign * exponent into target, dimension by dimension, where the right
    // operand may be absent (a null pointer) and the exponent is exponentNumerator / exponentDenominator. Each
    // dimension is the exact checked rational sum, as the host MathRational operators compute it.
    [CudaDevice(Name = "mathblocks_type_combine_unit")]
    private static int CombineUnit(
        [CudaReadOnly] MathBlockDeviceType* left,
        [CudaReadOnly] MathBlockDeviceType* right,
        int rightSign,
        int exponentNumerator,
        int exponentDenominator,
        MathBlockDeviceType* target)
    {
        for (int dimension = 0; dimension < 4; dimension++)
        {
            long numerator = UnitNumerator(left, dimension);
            long denominator = UnitDenominator(left, dimension);
            if (right != null)
            {
                long rightNumerator = UnitNumerator(right, dimension);
                long rightDenominator = UnitDenominator(right, dimension);
                long sum = numerator * rightDenominator + rightSign * rightNumerator * denominator;
                long product = denominator * rightDenominator;
                if (SetUnitChecked(target, dimension, sum, product) == 0)
                    return 0;
                numerator = UnitNumerator(target, dimension);
                denominator = UnitDenominator(target, dimension);
            }
            if (SetUnitChecked(target, dimension, numerator * exponentNumerator, denominator * exponentDenominator) == 0)
                return 0;
        }
        return 1;
    }

    // The input i as the operation under resolution sees it: unchanged (mode 0), a vector as the scalar of its unit
    // (mode 1, the elementwise lift), or a series input as the unit-carrying type without a length (mode 2).
    [CudaDevice(Name = "mathblocks_type_input")]
    private static MathBlockDeviceType Input(
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int index,
        int mode,
        int seriesMask)
    {
        MathBlockDeviceType value = inputs[index];
        if (mode == 1 && value.kind == 4)
        {
            value.kind = 1;
            value.rows = 0;
            value.columns = 0;
        }
        else if (mode == 2 && ((seriesMask >> index) & 1) != 0)
        {
            value.rows = 0;
            value.columns = 0;
        }
        return value;
    }

    // The common checks of a row: operand count, accepted kinds and unit constraints.
    [CudaDevice(Name = "mathblocks_type_check_operands")]
    private static int CheckOperands(
        [CudaReadOnly] int* row,
        int start,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        int mode,
        int seriesMask)
    {
        int operandStart = start + 2 + row[start + 1];
        if (row[operandStart] != count)
            return StatusArity;
        for (int index = 0; index < count; index++)
        {
            MathBlockDeviceType input = Input(inputs, index, mode, seriesMask);
            int kind = input.kind;
            int mask = row[operandStart + 1 + index * 3];
            int constraint = row[operandStart + 2 + index * 3];
            if (kind < 1 || kind > 31 || ((mask >> kind) & 1) == 0)
                return StatusKind;
            if (constraint == -2)
            {
                if (!IsDimensionless(&input))
                    return StatusDimensionless;
            }
            else if (constraint >= 0)
            {
                MathBlockDeviceType other = Input(inputs, constraint, mode, seriesMask);
                if (!UnitsEqual(&input, &other))
                    return StatusUnit;
            }
        }
        return StatusOk;
    }

    // The operands named by checkMask must agree on their rows, and on their columns, wherever they know them. The
    // output takes the first known rows and the first known columns among the operands named by outputMask, or by
    // checkMask when outputMask is 0.
    [CudaDevice(Name = "mathblocks_type_merge_shape")]
    private static int MergeShape(
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int checkMask,
        int outputMask,
        int mode,
        int seriesMask,
        int count,
        MathBlockDeviceType* output)
    {
        if (outputMask == 0)
            outputMask = checkMask;
        int rows = 0;
        int columns = 0;
        int outputRows = 0;
        int outputColumns = 0;
        for (int index = 0; index < count; index++)
        {
            if (((checkMask >> index) & 1) == 0)
                continue;
            MathBlockDeviceType input = Input(inputs, index, mode, seriesMask);
            if (input.rows != 0)
            {
                if (rows != 0 && rows != input.rows)
                    return StatusShape;
                rows = input.rows;
            }
            if (input.columns != 0)
            {
                if (columns != 0 && columns != input.columns)
                    return StatusShape;
                columns = input.columns;
            }
            if (((outputMask >> index) & 1) != 0)
            {
                if (outputRows == 0)
                    outputRows = input.rows;
                if (outputColumns == 0)
                    outputColumns = input.columns;
            }
        }
        output->rows = outputRows;
        output->columns = outputColumns;
        return StatusOk;
    }

    // Resolves a rule-1 row.
    [CudaDevice(Name = "mathblocks_type_composed")]
    private static int Composed(
        [CudaReadOnly] int* row,
        int start,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        MathBlockDeviceType* output,
        int mode,
        int seriesMask)
    {
        int p = start + 2;
        int outputKind = row[p + 0];
        if (outputKind <= 0)
            outputKind = Input(inputs, -outputKind, mode, seriesMask).kind;
        Clear(output, outputKind);

        int shapeMode = row[p + 1];
        if (shapeMode == 2 || shapeMode == 4 || shapeMode == 7)
        {
            int merged = MergeShape(inputs, row[p + 2], row[p + 3], mode, seriesMask, count, output);
            if (merged != StatusOk)
                return merged;
            if (shapeMode == 4)
                output->columns = 0;
            else if (shapeMode == 7)
                output->rows = 0;
            if (shapeMode == 7)
                output->columns = 0;
        }
        else if (shapeMode >= 1)
        {
            MathBlockDeviceType shapeA = Input(inputs, row[p + 2], mode, seriesMask);
            if (shapeMode == 1)
            {
                output->rows = shapeA.rows;
                output->columns = shapeA.columns;
            }
            else if (shapeMode == 3)
            {
                output->rows = shapeA.rows;
            }
            else if (shapeMode == 5)
            {
                MathBlockDeviceType shapeB = Input(inputs, row[p + 3], mode, seriesMask);
                if (shapeA.rows > 0 && shapeB.rows > 0)
                {
                    long total = (long)shapeA.rows + shapeB.rows;
                    if (total > 2147483647L)
                        return StatusOverflow;
                    output->rows = (int)total;
                }
            }
            else if (shapeMode == 6)
            {
                if (shapeA.rows > 0)
                {
                    long total = (long)shapeA.rows + row[p + 3];
                    if (total > 2147483647L)
                        return StatusOverflow;
                    output->rows = (int)total;
                }
            }
            else if (shapeMode == 9)
            {
                if (shapeA.rows > 0)
                    output->rows = (int)((long)shapeA.rows + row[p + 3]);
            }
            else if (shapeMode == 8)
            {
                output->rows = 1;
                if (shapeA.rows > 1)
                    output->rows = shapeA.rows - 1;
            }
        }

        int unitMode = row[p + 4];
        if (unitMode == 0)
            return StatusOk;
        MathBlockDeviceType unitA = Input(inputs, row[p + 5], mode, seriesMask);
        MathBlockDeviceType unitB;
        Clear(&unitB, 0);
        if (unitMode >= 3)
            unitB = Input(inputs, row[p + 6], mode, seriesMask);
        int combined = 1;
        if (unitMode == 1)
            CopyUnit(&unitA, output);
        else if (unitMode == 2)
            combined = CombineUnit(&unitA, null, 1, row[p + 7], row[p + 8], output);
        else if (unitMode == 3)
            combined = CombineUnit(&unitA, &unitB, 1, 1, 1, output);
        else if (unitMode == 4)
            combined = CombineUnit(&unitA, &unitB, -1, 1, 1, output);
        if (combined == 0)
            return StatusOverflow;
        return StatusOk;
    }

    // Resolves a plain (non-lift) row against the inputs as seen under the mode.
    [CudaDevice(Name = "mathblocks_type_core")]
    private static int Core(
        [CudaReadOnly] int* row,
        int start,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        MathBlockDeviceType* output,
        int mode,
        int seriesMask)
    {
        int checkedOperands = CheckOperands(row, start, inputs, count, mode, seriesMask);
        if (checkedOperands != StatusOk)
            return checkedOperands;
        if (row[start] == 1)
            return Composed(row, start, inputs, count, output, mode, seriesMask);
        return StatusRule;
    }

    // The fill operand of a lift is a scalar of the unit of the lifted result.
    [CudaDevice(Name = "mathblocks_type_lift_result")]
    private static int LiftResult(
        [CudaReadOnly] MathBlockDeviceType* inputs,
        [CudaReadOnly] MathBlockDeviceType* sourceResult,
        int validity,
        int fillIndex,
        int rows,
        MathBlockDeviceType* output)
    {
        if (validity != 0)
        {
            Clear(output, 11);
            output->rows = rows;
            return StatusOk;
        }
        MathBlockDeviceType fill = inputs[fillIndex];
        if (fill.kind != 1)
            return StatusKind;
        if (!UnitsEqual(&fill, sourceResult))
            return StatusUnit;
        CopyUnit(sourceResult, output);
        output->kind = 4;
        output->rows = rows;
        output->columns = 0;
        return StatusOk;
    }

    // Resolves a rule-2 row: the elementwise form of a scalar operation, or its validity sibling.
    [CudaDevice(Name = "mathblocks_type_elementwise_form")]
    private static int ElementwiseForm(
        [CudaReadOnly] int* row,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        MathBlockDeviceType* output)
    {
        int validity = row[2];
        int source = 3;
        int sourceArity = row[source + 2 + row[source + 1]];
        if (count != sourceArity + 1 - validity)
            return StatusArity;
        int rows = 0;
        int vectors = 0;
        int consistent = 1;
        for (int index = 0; index < sourceArity; index++)
        {
            if (inputs[index].kind != 4)
                continue;
            vectors++;
            int length = inputs[index].rows;
            if (length > 0)
            {
                if (rows == 0)
                    rows = length;
                else if (rows != length)
                    consistent = 0;
            }
        }
        if (vectors == 0)
            return StatusRule;
        if (consistent == 0)
            rows = 0;
        MathBlockDeviceType result;
        Clear(&result, 0);
        int status = Core(row, source, inputs, sourceArity, &result, 1, 0);
        if (status != StatusOk)
            return status;
        if (result.kind != 1)
            return StatusKind;
        return LiftResult(inputs, &result, validity, sourceArity, rows, output);
    }

    // Resolves a rule-3 row: the trailing-window form of a series operation, or its validity sibling.
    [CudaDevice(Name = "mathblocks_type_window_form")]
    private static int WindowForm(
        [CudaReadOnly] int* row,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        MathBlockDeviceType* output)
    {
        int validity = row[2];
        int lastRow = row[3];
        int seriesMask = row[4];
        int source = 5;
        int sourceArity = row[source + 2 + row[source + 1]];
        if (count != sourceArity + 2 - validity)
            return StatusArity;
        int rows = 0;
        int consistent = 1;
        for (int index = 0; index < sourceArity; index++)
        {
            if (((seriesMask >> index) & 1) == 0)
                continue;
            int kind = inputs[index].kind;
            if (kind != 4 && kind != 11)
                return StatusKind;
            int length = inputs[index].rows;
            if (length > 0)
            {
                if (rows == 0)
                    rows = length;
                else if (rows != length)
                    consistent = 0;
            }
        }
        if (consistent == 0)
            rows = 0;
        MathBlockDeviceType result;
        Clear(&result, 0);
        int status = Core(row, source, inputs, sourceArity, &result, 2, seriesMask);
        if (status != StatusOk)
            return status;
        int expectedKind = 1;
        if (lastRow != 0)
            expectedKind = 4;
        if (result.kind != expectedKind)
            return StatusKind;
        MathBlockDeviceType width = inputs[sourceArity];
        if (width.kind != 1)
            return StatusKind;
        if (!IsDimensionless(&width))
            return StatusDimensionless;
        return LiftResult(inputs, &result, validity, sourceArity + 1, rows, output);
    }

    // Resolves a signature row and returns the status: 0 for a valid type, otherwise the first failing check.
    [CudaDevice(Name = "mathblocks_type_resolve_status")]
    internal static int ResolveStatus(
        [CudaReadOnly] int* signature_row,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        MathBlockDeviceType* output)
    {
        int rule = signature_row[0];
        int status = StatusRule;
        if (rule == 2)
            status = ElementwiseForm(signature_row, inputs, count, output);
        else if (rule == 3)
            status = WindowForm(signature_row, inputs, count, output);
        else
            status = Core(signature_row, 0, inputs, count, output, 0, 0);
        if (status != StatusOk)
            Clear(output, -1);
        return status;
    }

    [CudaDevice(Name = "mathblocks_type_resolve")]
    private static void Resolve(
        [CudaReadOnly] int* signature_row,
        [CudaReadOnly] MathBlockDeviceType* inputs,
        int count,
        MathBlockDeviceType* output)
    {
        ResolveStatus(signature_row, inputs, count, output);
    }
}
