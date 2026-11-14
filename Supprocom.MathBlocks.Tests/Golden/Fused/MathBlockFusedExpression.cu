// MathBlocks fused expression <fused-fingerprint>.
// Program fingerprint <program-fingerprint>.
// MathBlocks CUDA source fingerprint <source-fingerprint>.
// Compile after the MathBlocks CUDA source (MathBlockCudaDeviceModule.Source).
// inputs[i]: const double* (Vector) or const int* of 0 and 1 (BooleanVector), one per vector
// input; pass a readable buffer for an invalid input. validity[i]: const int* of 0 and 1, or
// null when input i is valid in every row; validity itself may be null.
//   inputs[0] 'x' Vector
//   inputs[1] 'y' Vector
//   inputs[2] 'mask' BooleanVector
// scalars[i]: one per scalar input.
//   scalars[0] 'exponent'
// outputs[k] (1.0 or 0.0 for a BooleanVector output) and output_validity[k], per row:
//   outputs[0] 'total' Vector
//   outputs[1] 'flag' BooleanVector
//   outputs[2] 'y' Vector
//   outputs[3] 'power' Vector
// invalid_mask: bit k is set when operation node k produces a nonfinite row:
//   bit 0 node 5 vector.add@1
//   bit 1 node 6 vector.subtract@1
//   bit 2 node 7 vector.multiply@1
//   bit 3 node 8 vector.divide@1
//   bit 4 node 9 vector.add-scalar@1
//   bit 5 node 10 vector.scale@1
//   bit 6 node 11 vector.absolute@1
//   bit 7 node 12 vector.sign@1
//   bit 8 node 13 vector.positive-part@1
//   bit 9 node 14 vector.square@1
//   bit 10 node 15 vector.square-root@1
//   bit 11 node 16 vector.exponential@1
//   bit 12 node 17 vector.natural-logarithm@1
//   bit 13 node 18 vector.power@1
//   bit 14 node 19 vector.equal@1
//   bit 15 node 20 vector.less-than@1
//   bit 16 node 21 vector.greater-than@1
//   bit 17 node 22 boolean-vector.and@1
//   bit 18 node 23 boolean-vector.or@1
//   bit 19 node 24 boolean-vector.xor@1
//   bit 20 node 25 boolean-vector.not@1
//   bit 21 node 26 vector.select@1
//   bit 22 node 27 complex-vector.create@1
//   bit 23 node 28 complex-vector.real@1
//   bit 24 node 29 complex-vector.imaginary@1
//   bit 25 node 30 complex-vector.magnitude@1
//   bit 26 node 31 vector.add@1
//   bit 27 node 32 vector.add@1
//   bit 28 node 34 elementwise.scalar.arc-tangent-2@1
//   bit 29 node 35 elementwise.probability.normal-cdf@1
//   bit 30 node 36 elementwise.scalar.clamp@1
//   bit 31 node 37 elementwise-valid.special.beta@1
//   bit 32 node 38 vector.add@1
//   bit 33 node 39 boolean-vector.and@1
__device__ void mathblocks_fused_<fused-fingerprint>(
    const void* const* inputs,
    const double* scalars,
    const int* const* validity,
    long long row,
    double* outputs,
    int* output_validity,
    unsigned long long* invalid_mask)
{
    unsigned long long invalid = 0ULL;
    const double n3 = scalars[0];
    const double n4 = __longlong_as_double((long long)0xbfe0000000000000ULL);
    const double n33 = __longlong_as_double((long long)0xbff0000000000000ULL);
    const double n0 = ((const double*)inputs[0])[row];
    const int r0 = validity == 0 || validity[0] == 0 || validity[0][row] != 0;
    const double n1 = ((const double*)inputs[1])[row];
    const int r1 = validity == 0 || validity[1] == 0 || validity[1][row] != 0;
    const int b2 = ((const int*)inputs[2])[row] != 0;
    const int r2 = validity == 0 || validity[2] == 0 || validity[2][row] != 0;
    // node 5 vector.add@1
    const double n5 = __dadd_rn(n0, n1);
    if (!isfinite(n5)) invalid |= 0x1ULL;
    const int r5 = r0 & r1;
    // node 6 vector.subtract@1
    const double n6 = __dsub_rn(n0, n1);
    if (!isfinite(n6)) invalid |= 0x2ULL;
    const int r6 = r0 & r1;
    // node 7 vector.multiply@1
    const double n7 = __dmul_rn(n5, n6);
    if (!isfinite(n7)) invalid |= 0x4ULL;
    const int r7 = r5 & r6;
    // node 8 vector.divide@1
    const double n8 = __ddiv_rn(n7, n1);
    if (!isfinite(n8)) invalid |= 0x8ULL;
    const int r8 = r7 & r1;
    // node 9 vector.add-scalar@1
    const double n9 = __dadd_rn(n8, n4);
    if (!isfinite(n9)) invalid |= 0x10ULL;
    const int r9 = r8;
    // node 10 vector.scale@1
    const double n10 = __dmul_rn(n9, n4);
    if (!isfinite(n10)) invalid |= 0x20ULL;
    const int r10 = r9;
    // node 11 vector.absolute@1
    const double n11 = fabs(n10);
    if (!isfinite(n11)) invalid |= 0x40ULL;
    const int r11 = r10;
    // node 12 vector.sign@1
    const double n12 = n6 > 0.0 ? 1.0 : n6 < 0.0 ? -1.0 : 0.0;
    if (!isfinite(n12)) invalid |= 0x80ULL;
    const int r12 = r6;
    // node 13 vector.positive-part@1
    const double n13 = mathblocks_maximum(n6, 0.0);
    if (!isfinite(n13)) invalid |= 0x100ULL;
    const int r13 = r6;
    // node 14 vector.square@1
    const double n14 = __dmul_rn(n13, n13);
    if (!isfinite(n14)) invalid |= 0x200ULL;
    const int r14 = r13;
    // node 15 vector.square-root@1
    const double n15 = mathblocks_square_root(n11);
    if (!isfinite(n15)) invalid |= 0x400ULL;
    const int r15 = r11;
    // node 16 vector.exponential@1
    const double n16 = mathblocks_exponential(n12);
    if (!isfinite(n16)) invalid |= 0x800ULL;
    const int r16 = r12;
    // node 17 vector.natural-logarithm@1
    const double n17 = mathblocks_natural_logarithm(n16);
    if (!isfinite(n17)) invalid |= 0x1000ULL;
    const int r17 = r16;
    // node 18 vector.power@1
    const double n18 = mathblocks_power(n15, n3);
    if (!isfinite(n18)) invalid |= 0x2000ULL;
    const int r18 = r15;
    // node 19 vector.equal@1
    const int b19 = n0 == n1;
    const int r19 = r0 & r1;
    // node 20 vector.less-than@1
    const int b20 = n14 < n18;
    const int r20 = r14 & r18;
    // node 21 vector.greater-than@1
    const int b21 = n17 > n0;
    const int r21 = r17 & r0;
    // node 22 boolean-vector.and@1
    const int b22 = b20 && b2;
    const int r22 = r20 & r2;
    // node 23 boolean-vector.or@1
    const int b23 = b19 || b21;
    const int r23 = r19 & r21;
    // node 24 boolean-vector.xor@1
    const int b24 = b22 != b23;
    const int r24 = r22 & r23;
    // node 25 boolean-vector.not@1
    const int b25 = !b24;
    const int r25 = r24;
    // node 26 vector.select@1
    const double n26 = b25 ? n18 : n14;
    if (!isfinite(n26)) invalid |= 0x200000ULL;
    const int r26 = r25 & r18 & r14;
    // node 27 complex-vector.create@1
    const MathBlockComplexValue c27 = mathblocks_complex_make(n26, n0);
    if (!isfinite(c27.real) || !isfinite(c27.imaginary)) invalid |= 0x400000ULL;
    const int r27 = r26 & r0;
    // node 28 complex-vector.real@1
    const double n28 = c27.real;
    if (!isfinite(n28)) invalid |= 0x800000ULL;
    const int r28 = r27;
    // node 29 complex-vector.imaginary@1
    const double n29 = c27.imaginary;
    if (!isfinite(n29)) invalid |= 0x1000000ULL;
    const int r29 = r27;
    // node 30 complex-vector.magnitude@1
    const double n30 = mathblocks_complex_magnitude(c27);
    if (!isfinite(n30)) invalid |= 0x2000000ULL;
    const int r30 = r27;
    // node 31 vector.add@1
    const double n31 = __dadd_rn(n28, n29);
    if (!isfinite(n31)) invalid |= 0x4000000ULL;
    const int r31 = r28 & r29;
    // node 32 vector.add@1
    const double n32 = __dadd_rn(n31, n30);
    if (!isfinite(n32)) invalid |= 0x8000000ULL;
    const int r32 = r31 & r30;
    // node 34 elementwise.scalar.arc-tangent-2@1
    double v34 = 0.0;
    bool g34 = true;
    const int k34 = isfinite(n32) && isfinite(n3) && mathblocks_elementwise_row_value(mathblocks_elementwise_source_opcode(8), n32, n3, 0.0, &v34, &g34);
    if (!g34) mathblocks_nonconvergence_record_elementwise(16);
    const double n34 = k34 ? v34 : n33;
    const int r34 = r32 & k34;
    // node 35 elementwise.probability.normal-cdf@1
    double v35 = 0.0;
    bool g35 = true;
    const int k35 = isfinite(n34) && mathblocks_elementwise_row_value(mathblocks_elementwise_source_opcode(3), n34, 0.0, 0.0, &v35, &g35);
    if (!g35) mathblocks_nonconvergence_record_elementwise(6);
    const double n35 = k35 ? v35 : n33;
    const int r35 = r34 & k35;
    // node 36 elementwise.scalar.clamp@1
    double v36 = 0.0;
    bool g36 = true;
    const int k36 = isfinite(n35) && isfinite(n4) && isfinite(n1) && mathblocks_elementwise_row_value(mathblocks_elementwise_source_opcode(12), n35, n4, n1, &v36, &g36);
    if (!g36) mathblocks_nonconvergence_record_elementwise(24);
    const double n36 = k36 ? v36 : n33;
    const int r36 = r35 & r1 & k36;
    // node 37 elementwise-valid.special.beta@1
    double v37 = 0.0;
    bool g37 = true;
    const int k37 = isfinite(n0) && isfinite(n1) && mathblocks_elementwise_row_value(mathblocks_elementwise_source_opcode(37), n0, n1, 0.0, &v37, &g37);
    if (!g37) mathblocks_nonconvergence_record_elementwise(75);
    const int b37 = k37;
    const int r37 = r0 & r1;
    // node 38 vector.add@1
    const double n38 = __dadd_rn(n32, n36);
    if (!isfinite(n38)) invalid |= 0x100000000ULL;
    const int r38 = r32 & r36;
    // node 39 boolean-vector.and@1
    const int b39 = b25 && b37;
    const int r39 = r25 & r37;
    outputs[0] = n38;
    output_validity[0] = r38;
    outputs[1] = b39 ? 1.0 : 0.0;
    output_validity[1] = r39;
    outputs[2] = n1;
    output_validity[2] = r1;
    outputs[3] = n18;
    output_validity[3] = r18;
    if (invalid != 0ULL)
        atomicOr(invalid_mask, invalid);
}

extern "C" __global__ void mathblocks_fused_<fused-fingerprint>_kernel(
    const void* const* inputs,
    const double* scalars,
    const int* const* validity,
    long long rows,
    void* const* outputs,
    int* const* output_validity,
    unsigned long long* invalid_mask)
{
    for (long long row = (long long)blockIdx.x * blockDim.x + threadIdx.x; row < rows;
         row += (long long)gridDim.x * blockDim.x)
    {
        double values[4];
        int row_validity[4];
        mathblocks_fused_<fused-fingerprint>(inputs, scalars, validity, row, values, row_validity, invalid_mask);
        ((double*)outputs[0])[row] = values[0];
        output_validity[0][row] = row_validity[0];
        ((int*)outputs[1])[row] = values[1] != 0.0;
        output_validity[1][row] = row_validity[1];
        ((double*)outputs[2])[row] = values[2];
        output_validity[2][row] = row_validity[2];
        ((double*)outputs[3])[row] = values[3];
        output_validity[3][row] = row_validity[3];
    }
}
