#ifndef CSHARP2CUDA_INTEGER_SEMANTICS_0_1
#define CSHARP2CUDA_INTEGER_SEMANTICS_0_1
static_assert(sizeof(unsigned short) == 2, "C# char requires 16 bits");
static_assert(sizeof(int) == 4, "CSharp2CUDA requires a 32-bit CUDA int.");
static_assert(sizeof(long long) == 8, "CSharp2CUDA requires a 64-bit CUDA long long.");

static __device__ __forceinline__ int csharp2cuda_index_from_end(
    int length,
    int value)
{
    if (value < 0) __trap();
    return length - value;
}

static __device__ __forceinline__ int csharp2cuda_i32_from_bits(unsigned int bits)
{
    return bits <= 0x7fffffffu ? (int)bits : -1 - (int)(~bits);
}

static __device__ __forceinline__ signed char csharp2cuda_i8_from_bits(
    unsigned int bits)
{
    unsigned int value = bits & 0xffu;
    return value <= 0x7fu
        ? (signed char)value
        : (signed char)(-1 - (int)((~value) & 0xffu));
}

static __device__ __forceinline__ short csharp2cuda_i16_from_bits(
    unsigned int bits)
{
    unsigned int value = bits & 0xffffu;
    return value <= 0x7fffu
        ? (short)value
        : (short)(-1 - (int)((~value) & 0xffffu));
}

static __device__ __forceinline__ long long csharp2cuda_i64_from_bits(unsigned long long bits)
{
    return bits <= 0x7fffffffffffffffull ? (long long)bits : -1LL - (long long)(~bits);
}

static __device__ __forceinline__ int csharp2cuda_f64_to_i32(double value)
{
    if (isnan(value)) return 0;
    if (value >= 2147483648.0) return 2147483647;
    if (value <= -2147483648.0) return (-2147483647 - 1);
    return (int)value;
}

static __device__ __forceinline__ unsigned int csharp2cuda_f64_to_u32(double value)
{
    if (isnan(value) || value <= 0.0) return 0u;
    if (value >= 4294967296.0) return 0xffffffffu;
    return (unsigned int)value;
}

static __device__ __forceinline__ long long csharp2cuda_f64_to_i64(double value)
{
    if (isnan(value)) return 0LL;
    if (value >= 9223372036854775808.0) return 9223372036854775807LL;
    if (value <= -9223372036854775808.0) return (-9223372036854775807LL - 1LL);
    return (long long)value;
}

static __device__ __forceinline__ unsigned long long csharp2cuda_f64_to_u64(
    double value)
{
    if (isnan(value) || value <= 0.0) return 0ull;
    if (value >= 18446744073709551616.0) return 0xffffffffffffffffull;
    return (unsigned long long)value;
}

static __device__ __forceinline__ signed char csharp2cuda_f64_to_i8(double value)
{
    return csharp2cuda_i8_from_bits((unsigned int)csharp2cuda_f64_to_i32(value));
}

static __device__ __forceinline__ unsigned char csharp2cuda_f64_to_u8(double value)
{
    return (unsigned char)csharp2cuda_f64_to_i32(value);
}

static __device__ __forceinline__ short csharp2cuda_f64_to_i16(double value)
{
    return csharp2cuda_i16_from_bits((unsigned int)csharp2cuda_f64_to_i32(value));
}

static __device__ __forceinline__ unsigned short csharp2cuda_f64_to_u16(double value)
{
    return (unsigned short)csharp2cuda_f64_to_i32(value);
}

template <typename T>
static __device__ __forceinline__ T* csharp2cuda_pointer_add(T* pointer, int offset)
{
    unsigned long long address = (unsigned long long)pointer;
    unsigned long long displacement =
        (unsigned long long)(long long)offset * (unsigned long long)sizeof(T);
    return (T*)(address + displacement);
}

template <typename T>
static __device__ __forceinline__ T* csharp2cuda_pointer_add_reverse(int offset, T* pointer)
{
    return csharp2cuda_pointer_add(pointer, offset);
}

static __device__ __forceinline__ double csharp2cuda_f64_maximum(double left, double right)
{
    if (left != right)
    {
        if (!isnan(left))
            return right < left ? left : right;
        return left;
    }
    return signbit(right) ? left : right;
}

static __device__ __forceinline__ double csharp2cuda_f64_minimum(double left, double right)
{
    if (left != right)
    {
        if (!isnan(left))
            return left < right ? left : right;
        return left;
    }
    return signbit(left) ? left : right;
}

static __device__ __forceinline__ float csharp2cuda_f32_maximum(float left, float right)
{
    if (left != right)
    {
        if (!isnan(left))
            return right < left ? left : right;
        return left;
    }
    return signbit(right) ? left : right;
}

static __device__ __forceinline__ float csharp2cuda_f32_minimum(float left, float right)
{
    if (left != right)
    {
        if (!isnan(left))
            return left < right ? left : right;
        return left;
    }
    return signbit(left) ? left : right;
}

static __device__ __forceinline__ double csharp2cuda_f64_clamp(
    double value,
    double minimum,
    double maximum)
{
    if (minimum > maximum)
    {
        __trap();
        return 0.0;
    }
    return value < minimum ? minimum : value > maximum ? maximum : value;
}

static __device__ __forceinline__ float csharp2cuda_f32_clamp(
    float value,
    float minimum,
    float maximum)
{
    if (minimum > maximum)
    {
        __trap();
        return 0.0f;
    }
    return value < minimum ? minimum : value > maximum ? maximum : value;
}

static __device__ __forceinline__ int csharp2cuda_f64_sign(double value)
{
    if (isnan(value))
    {
        __trap();
        return 0;
    }
    return value > 0.0 ? 1 : value < 0.0 ? -1 : 0;
}

static __device__ __forceinline__ int csharp2cuda_f32_sign(float value)
{
    if (isnan(value))
    {
        __trap();
        return 0;
    }
    return value > 0.0f ? 1 : value < 0.0f ? -1 : 0;
}

static __device__ __forceinline__ signed char csharp2cuda_integral_abs(
    signed char value)
{
    if (value == (signed char)-128)
    {
        __trap();
        return 0;
    }
    return value < 0 ? (signed char)(-(int)value) : value;
}

static __device__ __forceinline__ short csharp2cuda_integral_abs(short value)
{
    if (value == (short)-32768)
    {
        __trap();
        return 0;
    }
    return value < 0 ? (short)(-(int)value) : value;
}

static __device__ __forceinline__ int csharp2cuda_integral_abs(int value)
{
    if (value == (-2147483647 - 1))
    {
        __trap();
        return 0;
    }
    return value < 0 ? -value : value;
}

static __device__ __forceinline__ long long csharp2cuda_integral_abs(
    long long value)
{
    if (value == (-9223372036854775807LL - 1LL))
    {
        __trap();
        return 0LL;
    }
    return value < 0LL ? -value : value;
}

template <typename T>
static __device__ __forceinline__ int csharp2cuda_integral_sign(T value)
{
    return value > (T)0 ? 1 : value < (T)0 ? -1 : 0;
}

template <typename T>
static __device__ __forceinline__ T csharp2cuda_integral_minimum(T left, T right)
{
    return left < right ? left : right;
}

template <typename T>
static __device__ __forceinline__ T csharp2cuda_integral_maximum(T left, T right)
{
    return left > right ? left : right;
}

template <typename T>
static __device__ __forceinline__ T csharp2cuda_integral_clamp(
    T value,
    T minimum,
    T maximum)
{
    if (minimum > maximum)
    {
        __trap();
        return (T)0;
    }
    return value < minimum ? minimum : value > maximum ? maximum : value;
}

template <typename T>
static __device__ __forceinline__ bool csharp2cuda_is_pow2(T value)
{
    return value > (T)0 && (value & (value - (T)1)) == (T)0;
}

static __device__ __forceinline__ unsigned int
csharp2cuda_u32_round_up_to_power_of_two(unsigned int value)
{
    value--;
    value |= value >> 1;
    value |= value >> 2;
    value |= value >> 4;
    value |= value >> 8;
    value |= value >> 16;
    return value + 1u;
}

static __device__ __forceinline__ unsigned long long
csharp2cuda_u64_round_up_to_power_of_two(unsigned long long value)
{
    value--;
    value |= value >> 1;
    value |= value >> 2;
    value |= value >> 4;
    value |= value >> 8;
    value |= value >> 16;
    value |= value >> 32;
    return value + 1ull;
}

static __device__ __forceinline__ int csharp2cuda_u32_trailing_zero_count(
    unsigned int value)
{
    return value == 0u ? 32 : __ffs(value) - 1;
}

static __device__ __forceinline__ int csharp2cuda_u64_trailing_zero_count(
    unsigned long long value)
{
    return value == 0ull ? 64 : __ffsll(value) - 1;
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_rotate_left(
    unsigned int value,
    int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return shift == 0u ? value : (value << shift) | (value >> (32u - shift));
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rotate_left(
    unsigned long long value,
    int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return shift == 0u ? value : (value << shift) | (value >> (64u - shift));
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_rotate_right(
    unsigned int value,
    int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return shift == 0u ? value : (value >> shift) | (value << (32u - shift));
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rotate_right(
    unsigned long long value,
    int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return shift == 0u ? value : (value >> shift) | (value << (64u - shift));
}

static __device__ __forceinline__ int csharp2cuda_u32_log2(unsigned int value)
{
    return value == 0u ? 0 : 31 - __clz(value);
}

static __device__ __forceinline__ int csharp2cuda_u64_log2(unsigned long long value)
{
    return value == 0ull ? 0 : 63 - __clzll(value);
}

static __device__ __forceinline__ int csharp2cuda_i32_add(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left + (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_sub(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left - (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_mul(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left * (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_div(int left, int right)
{
    if (right == 0 || (left == (-2147483647 - 1) && right == -1))
    {
        __trap();
        return 0;
    }
    return left / right;
}

static __device__ __forceinline__ int csharp2cuda_i32_rem(int left, int right)
{
    if (right == 0)
    {
        __trap();
        return 0;
    }
    if (left == (-2147483647 - 1) && right == -1)
        return 0;
    return left % right;
}

static __device__ __forceinline__ int csharp2cuda_i32_and(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left & (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_or(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left | (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_xor(int left, int right)
{
    return csharp2cuda_i32_from_bits((unsigned int)left ^ (unsigned int)right);
}

static __device__ __forceinline__ int csharp2cuda_i32_not(int value)
{
    return csharp2cuda_i32_from_bits(~(unsigned int)value);
}

static __device__ __forceinline__ int csharp2cuda_i32_neg(int value)
{
    return csharp2cuda_i32_from_bits(0u - (unsigned int)value);
}

static __device__ __forceinline__ int csharp2cuda_i32_shl(int value, int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return csharp2cuda_i32_from_bits((unsigned int)value << shift);
}

static __device__ __forceinline__ int csharp2cuda_i32_shr(int value, int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    if (shift == 0u)
        return value;
    unsigned int bits = (unsigned int)value >> shift;
    if (value < 0)
        bits |= ~0u << (32u - shift);
    return csharp2cuda_i32_from_bits(bits);
}

static __device__ __forceinline__ int csharp2cuda_i32_ushr(int value, int count)
{
    unsigned int shift = (unsigned int)count & 31u;
    return csharp2cuda_i32_from_bits((unsigned int)value >> shift);
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_div(unsigned int left, unsigned int right)
{
    if (right == 0u)
    {
        __trap();
        return 0u;
    }
    return left / right;
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_rem(unsigned int left, unsigned int right)
{
    if (right == 0u)
    {
        __trap();
        return 0u;
    }
    return left % right;
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_shl(unsigned int value, int count)
{
    return value << ((unsigned int)count & 31u);
}

static __device__ __forceinline__ unsigned int csharp2cuda_u32_shr(unsigned int value, int count)
{
    return value >> ((unsigned int)count & 31u);
}

static __device__ __forceinline__ long long csharp2cuda_i64_add(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left + (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_sub(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left - (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_mul(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left * (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_div(long long left, long long right)
{
    if (right == 0LL ||
        (left == (-9223372036854775807LL - 1LL) && right == -1LL))
    {
        __trap();
        return 0LL;
    }
    return left / right;
}

static __device__ __forceinline__ long long csharp2cuda_i64_rem(long long left, long long right)
{
    if (right == 0LL)
    {
        __trap();
        return 0LL;
    }
    if (left == (-9223372036854775807LL - 1LL) && right == -1LL)
        return 0LL;
    return left % right;
}

static __device__ __forceinline__ long long csharp2cuda_i64_and(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left & (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_or(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left | (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_xor(long long left, long long right)
{
    return csharp2cuda_i64_from_bits((unsigned long long)left ^ (unsigned long long)right);
}

static __device__ __forceinline__ long long csharp2cuda_i64_not(long long value)
{
    return csharp2cuda_i64_from_bits(~(unsigned long long)value);
}

static __device__ __forceinline__ long long csharp2cuda_i64_neg(long long value)
{
    return csharp2cuda_i64_from_bits(0ull - (unsigned long long)value);
}

static __device__ __forceinline__ long long csharp2cuda_i64_shl(long long value, int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return csharp2cuda_i64_from_bits((unsigned long long)value << shift);
}

static __device__ __forceinline__ long long csharp2cuda_i64_shr(long long value, int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    if (shift == 0u)
        return value;
    unsigned long long bits = (unsigned long long)value >> shift;
    if (value < 0LL)
        bits |= ~0ull << (64u - shift);
    return csharp2cuda_i64_from_bits(bits);
}

static __device__ __forceinline__ long long csharp2cuda_i64_ushr(
    long long value,
    int count)
{
    unsigned int shift = (unsigned int)count & 63u;
    return csharp2cuda_i64_from_bits((unsigned long long)value >> shift);
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_div(unsigned long long left, unsigned long long right)
{
    if (right == 0ull)
    {
        __trap();
        return 0ull;
    }
    return left / right;
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rem(unsigned long long left, unsigned long long right)
{
    if (right == 0ull)
    {
        __trap();
        return 0ull;
    }
    return left % right;
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shl(unsigned long long value, int count)
{
    return value << ((unsigned int)count & 63u);
}

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shr(unsigned long long value, int count)
{
    return value >> ((unsigned int)count & 63u);
}

static __device__ __forceinline__ int csharp2cuda_i32_add_assign(int& target, int value) { return target = csharp2cuda_i32_add(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_sub_assign(int& target, int value) { return target = csharp2cuda_i32_sub(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_mul_assign(int& target, int value) { return target = csharp2cuda_i32_mul(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_div_assign(int& target, int value) { return target = csharp2cuda_i32_div(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_rem_assign(int& target, int value) { return target = csharp2cuda_i32_rem(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_and_assign(int& target, int value) { return target = csharp2cuda_i32_and(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_or_assign(int& target, int value) { return target = csharp2cuda_i32_or(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_xor_assign(int& target, int value) { return target = csharp2cuda_i32_xor(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_shl_assign(int& target, int value) { return target = csharp2cuda_i32_shl(target, value); }
static __device__ __forceinline__ int csharp2cuda_i32_shr_assign(int& target, int value) { return target = csharp2cuda_i32_shr(target, value); }

static __device__ __forceinline__ long long csharp2cuda_i64_add_assign(long long& target, long long value) { return target = csharp2cuda_i64_add(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_sub_assign(long long& target, long long value) { return target = csharp2cuda_i64_sub(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_mul_assign(long long& target, long long value) { return target = csharp2cuda_i64_mul(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_div_assign(long long& target, long long value) { return target = csharp2cuda_i64_div(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_rem_assign(long long& target, long long value) { return target = csharp2cuda_i64_rem(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_and_assign(long long& target, long long value) { return target = csharp2cuda_i64_and(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_or_assign(long long& target, long long value) { return target = csharp2cuda_i64_or(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_xor_assign(long long& target, long long value) { return target = csharp2cuda_i64_xor(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_shl_assign(long long& target, int value) { return target = csharp2cuda_i64_shl(target, value); }
static __device__ __forceinline__ long long csharp2cuda_i64_shr_assign(long long& target, int value) { return target = csharp2cuda_i64_shr(target, value); }

static __device__ __forceinline__ unsigned int csharp2cuda_u32_div_assign(unsigned int& target, unsigned int value) { return target = csharp2cuda_u32_div(target, value); }
static __device__ __forceinline__ unsigned int csharp2cuda_u32_rem_assign(unsigned int& target, unsigned int value) { return target = csharp2cuda_u32_rem(target, value); }
static __device__ __forceinline__ unsigned int csharp2cuda_u32_shl_assign(unsigned int& target, int value) { return target = csharp2cuda_u32_shl(target, value); }
static __device__ __forceinline__ unsigned int csharp2cuda_u32_shr_assign(unsigned int& target, int value) { return target = csharp2cuda_u32_shr(target, value); }

static __device__ __forceinline__ unsigned long long csharp2cuda_u64_div_assign(unsigned long long& target, unsigned long long value) { return target = csharp2cuda_u64_div(target, value); }
static __device__ __forceinline__ unsigned long long csharp2cuda_u64_rem_assign(unsigned long long& target, unsigned long long value) { return target = csharp2cuda_u64_rem(target, value); }
static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shl_assign(unsigned long long& target, int value) { return target = csharp2cuda_u64_shl(target, value); }
static __device__ __forceinline__ unsigned long long csharp2cuda_u64_shr_assign(unsigned long long& target, int value) { return target = csharp2cuda_u64_shr(target, value); }

static __device__ __forceinline__ int csharp2cuda_i32_pre_increment(int& target) { return target = csharp2cuda_i32_add(target, 1); }
static __device__ __forceinline__ int csharp2cuda_i32_post_increment(int& target) { int result = target; target = csharp2cuda_i32_add(target, 1); return result; }
static __device__ __forceinline__ int csharp2cuda_i32_pre_decrement(int& target) { return target = csharp2cuda_i32_sub(target, 1); }
static __device__ __forceinline__ int csharp2cuda_i32_post_decrement(int& target) { int result = target; target = csharp2cuda_i32_sub(target, 1); return result; }
static __device__ __forceinline__ long long csharp2cuda_i64_pre_increment(long long& target) { return target = csharp2cuda_i64_add(target, 1LL); }
static __device__ __forceinline__ long long csharp2cuda_i64_post_increment(long long& target) { long long result = target; target = csharp2cuda_i64_add(target, 1LL); return result; }
static __device__ __forceinline__ long long csharp2cuda_i64_pre_decrement(long long& target) { return target = csharp2cuda_i64_sub(target, 1LL); }
static __device__ __forceinline__ long long csharp2cuda_i64_post_decrement(long long& target) { long long result = target; target = csharp2cuda_i64_sub(target, 1LL); return result; }
static __device__ __forceinline__ signed char csharp2cuda_i8_pre_increment(signed char& target) { return target = csharp2cuda_i8_from_bits((unsigned int)(int)target + 1u); }
static __device__ __forceinline__ signed char csharp2cuda_i8_post_increment(signed char& target) { signed char result = target; target = csharp2cuda_i8_from_bits((unsigned int)(int)target + 1u); return result; }
static __device__ __forceinline__ signed char csharp2cuda_i8_pre_decrement(signed char& target) { return target = csharp2cuda_i8_from_bits((unsigned int)(int)target - 1u); }
static __device__ __forceinline__ signed char csharp2cuda_i8_post_decrement(signed char& target) { signed char result = target; target = csharp2cuda_i8_from_bits((unsigned int)(int)target - 1u); return result; }
static __device__ __forceinline__ short csharp2cuda_i16_pre_increment(short& target) { return target = csharp2cuda_i16_from_bits((unsigned int)(int)target + 1u); }
static __device__ __forceinline__ short csharp2cuda_i16_post_increment(short& target) { short result = target; target = csharp2cuda_i16_from_bits((unsigned int)(int)target + 1u); return result; }
static __device__ __forceinline__ short csharp2cuda_i16_pre_decrement(short& target) { return target = csharp2cuda_i16_from_bits((unsigned int)(int)target - 1u); }
static __device__ __forceinline__ short csharp2cuda_i16_post_decrement(short& target) { short result = target; target = csharp2cuda_i16_from_bits((unsigned int)(int)target - 1u); return result; }
#endif

#line 133 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 97 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count);

#line 88 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value);

#line 64 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value);

#line 76 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value);

#line 58 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value);

#line 103 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns);

#line 133 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 139 "AdvancedModule.cs"
{
#line 140 "AdvancedModule.cs"
    int thread = threadIdx.x;
#line 141 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 141 "AdvancedModule.cs"
    if (((input_count) > (0)))
    {
#line 141 "AdvancedModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 141 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 141 "AdvancedModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 142 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 142 "AdvancedModule.cs"
    if (((input_count) > (1)))
    {
#line 142 "AdvancedModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 142 "AdvancedModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 142 "AdvancedModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 143 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 143 "AdvancedModule.cs"
    if (((input_count) > (2)))
    {
#line 143 "AdvancedModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 143 "AdvancedModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 143 "AdvancedModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 144 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 144 "AdvancedModule.cs"
    if (((input_count) > (3)))
    {
#line 144 "AdvancedModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 144 "AdvancedModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 144 "AdvancedModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 145 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 146 "AdvancedModule.cs"
    {
#line 147 "AdvancedModule.cs"
#line 147 "AdvancedModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 148 "AdvancedModule.cs"
#line 148 "AdvancedModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 149 "AdvancedModule.cs"
#line 149 "AdvancedModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 150 "AdvancedModule.cs"
#line 150 "AdvancedModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 151 "AdvancedModule.cs"
#line 151 "AdvancedModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 152 "AdvancedModule.cs"
#line 152 "AdvancedModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 153 "AdvancedModule.cs"
        {
#line 153 "AdvancedModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 154 "AdvancedModule.cs"
#line 154 "AdvancedModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 154 "AdvancedModule.cs"
                bool csharp2cuda_temp_12;
#line 154 "AdvancedModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 154 "AdvancedModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 154 "AdvancedModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 154 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 154 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 154 "AdvancedModule.cs"
#line 154 "AdvancedModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 153 "AdvancedModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 156 "AdvancedModule.cs"
    __syncthreads();
#line 157 "AdvancedModule.cs"
#line 157 "AdvancedModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 158 "AdvancedModule.cs"
        return;
    }
#line 160 "AdvancedModule.cs"
    double* csharp2cuda_temp_17;
#line 160 "AdvancedModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 160 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 160 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 160 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 160 "AdvancedModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 161 "AdvancedModule.cs"
    double* csharp2cuda_temp_19;
#line 161 "AdvancedModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 161 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 161 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 161 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 161 "AdvancedModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 162 "AdvancedModule.cs"
    double* csharp2cuda_temp_21;
#line 162 "AdvancedModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 162 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 162 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 162 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 162 "AdvancedModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 163 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 163 "AdvancedModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 164 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 164 "AdvancedModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 171 "AdvancedModule.cs"
#line 171 "AdvancedModule.cs"
    bool csharp2cuda_temp_25;
#line 171 "AdvancedModule.cs"
    if (!(((opcode) == (4))))
    {
#line 171 "AdvancedModule.cs"
        csharp2cuda_temp_25 = ((opcode) == (5));
    }
    else
    {
#line 171 "AdvancedModule.cs"
        csharp2cuda_temp_25 = true;
    }
    if (csharp2cuda_temp_25)
#line 172 "AdvancedModule.cs"
    {
#line 173 "AdvancedModule.cs"
        int csharp2cuda_temp_26 = (first)->count;
#line 173 "AdvancedModule.cs"
        bool csharp2cuda_temp_27;
#line 173 "AdvancedModule.cs"
        if (!(((csharp2cuda_temp_26) <= (0))))
        {
#line 173 "AdvancedModule.cs"
            int csharp2cuda_temp_28 = (first)->count;
#line 173 "AdvancedModule.cs"
            int csharp2cuda_temp_29 = (second)->count;
#line 173 "AdvancedModule.cs"
            csharp2cuda_temp_27 = ((csharp2cuda_temp_28) != (csharp2cuda_temp_29));
        }
        else
        {
#line 173 "AdvancedModule.cs"
            csharp2cuda_temp_27 = true;
        }
#line 173 "AdvancedModule.cs"
        bool csharp2cuda_temp_30;
#line 173 "AdvancedModule.cs"
        if (!(csharp2cuda_temp_27))
        {
#line 173 "AdvancedModule.cs"
            double csharp2cuda_temp_31 = (fourth)->scalar_value;
#line 173 "AdvancedModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) < (0.0));
        }
        else
        {
#line 173 "AdvancedModule.cs"
            csharp2cuda_temp_30 = true;
        }
#line 173 "AdvancedModule.cs"
        bool lipschitz_invalid = csharp2cuda_temp_30;
#line 174 "AdvancedModule.cs"
        if ((!(lipschitz_invalid)))
#line 175 "AdvancedModule.cs"
        {
#line 176 "AdvancedModule.cs"
            {
#line 176 "AdvancedModule.cs"
                int query = thread;
                while (true)
                {
#line 176 "AdvancedModule.cs"
                    int csharp2cuda_temp_34 = (third)->count;
                    if (!(((query) < (csharp2cuda_temp_34))))
                        break;
#line 177 "AdvancedModule.cs"
                    {
#line 178 "AdvancedModule.cs"
                        double csharp2cuda_temp_35;
#line 178 "AdvancedModule.cs"
                        if (((opcode) == (4)))
                        {
#line 178 "AdvancedModule.cs"
                            csharp2cuda_temp_35 = mathblocks_positive_infinity();
                        }
                        else
                        {
#line 178 "AdvancedModule.cs"
                            csharp2cuda_temp_35 = (-(mathblocks_positive_infinity()));
                        }
#line 178 "AdvancedModule.cs"
                        double selected = csharp2cuda_temp_35;
#line 181 "AdvancedModule.cs"
                        {
#line 181 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 181 "AdvancedModule.cs"
                                int csharp2cuda_temp_37 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_37))))
                                    break;
#line 182 "AdvancedModule.cs"
                                {
#line 183 "AdvancedModule.cs"
                                    double csharp2cuda_temp_38;
#line 183 "AdvancedModule.cs"
                                    if (((opcode) == (4)))
                                    {
#line 184 "AdvancedModule.cs"
                                        double csharp2cuda_temp_39 = (b)[index];
#line 184 "AdvancedModule.cs"
                                        double csharp2cuda_temp_40 = (fourth)->scalar_value;
#line 184 "AdvancedModule.cs"
                                        double csharp2cuda_temp_41 = (c)[query];
#line 184 "AdvancedModule.cs"
                                        double csharp2cuda_temp_42 = (a)[index];
#line 183 "AdvancedModule.cs"
                                        csharp2cuda_temp_38 = __dadd_rn(csharp2cuda_temp_39, __dmul_rn(csharp2cuda_temp_40, fabs(__dsub_rn(csharp2cuda_temp_41, csharp2cuda_temp_42))));
                                    }
                                    else
                                    {
#line 185 "AdvancedModule.cs"
                                        double csharp2cuda_temp_43 = (b)[index];
#line 185 "AdvancedModule.cs"
                                        double csharp2cuda_temp_44 = (fourth)->scalar_value;
#line 185 "AdvancedModule.cs"
                                        double csharp2cuda_temp_45 = (c)[query];
#line 185 "AdvancedModule.cs"
                                        double csharp2cuda_temp_46 = (a)[index];
#line 183 "AdvancedModule.cs"
                                        csharp2cuda_temp_38 = __dsub_rn(csharp2cuda_temp_43, __dmul_rn(csharp2cuda_temp_44, fabs(__dsub_rn(csharp2cuda_temp_45, csharp2cuda_temp_46))));
                                    }
#line 183 "AdvancedModule.cs"
                                    double candidate = csharp2cuda_temp_38;
#line 188 "AdvancedModule.cs"
#line 188 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_47 = &(selected);
#line 188 "AdvancedModule.cs"
                                    double csharp2cuda_temp_48;
#line 188 "AdvancedModule.cs"
                                    if (((opcode) == (4)))
                                    {
#line 188 "AdvancedModule.cs"
                                        csharp2cuda_temp_48 = mathblocks_minimum(selected, candidate);
                                    }
                                    else
                                    {
#line 188 "AdvancedModule.cs"
                                        csharp2cuda_temp_48 = mathblocks_maximum(selected, candidate);
                                    }
                                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_48);
                                }
#line 181 "AdvancedModule.cs"
                                int* csharp2cuda_temp_36 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_36));
                            }
                        }
#line 192 "AdvancedModule.cs"
#line 192 "AdvancedModule.cs"
                        double* csharp2cuda_temp_49 = &((result)[query]);
                        (*(csharp2cuda_temp_49) = selected);
                    }
#line 176 "AdvancedModule.cs"
                    int* csharp2cuda_temp_32 = &(query);
#line 176 "AdvancedModule.cs"
                    int csharp2cuda_temp_33 = *(csharp2cuda_temp_32);
                    (*(csharp2cuda_temp_32) = csharp2cuda_i32_add(csharp2cuda_temp_33, blockDim.x));
                }
            }
        }
#line 195 "AdvancedModule.cs"
        __syncthreads();
    }
#line 198 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 199 "AdvancedModule.cs"
    {
#line 200 "AdvancedModule.cs"
        switch (opcode)
        {
#line 202 "AdvancedModule.cs"
            case 0:
#line 203 "AdvancedModule.cs"
#line 203 "AdvancedModule.cs"
                int csharp2cuda_temp_50 = (first)->count;
#line 203 "AdvancedModule.cs"
                bool csharp2cuda_temp_51;
#line 203 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_50) <= (0))))
                {
#line 203 "AdvancedModule.cs"
                    int csharp2cuda_temp_52 = (first)->count;
#line 203 "AdvancedModule.cs"
                    csharp2cuda_temp_51 = ((csharp2cuda_temp_52) > (mathblocks_limit_choquet_player_count()));
                }
                else
                {
#line 203 "AdvancedModule.cs"
                    csharp2cuda_temp_51 = true;
                }
#line 203 "AdvancedModule.cs"
                bool csharp2cuda_temp_53;
#line 203 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_51))
                {
#line 204 "AdvancedModule.cs"
                    int csharp2cuda_temp_54 = (second)->count;
#line 204 "AdvancedModule.cs"
                    int csharp2cuda_temp_55 = (first)->count;
#line 203 "AdvancedModule.cs"
                    csharp2cuda_temp_53 = ((csharp2cuda_temp_54) != (csharp2cuda_i32_shl(1, csharp2cuda_temp_55)));
                }
                else
                {
#line 203 "AdvancedModule.cs"
                    csharp2cuda_temp_53 = true;
                }
#line 203 "AdvancedModule.cs"
                bool csharp2cuda_temp_56;
#line 203 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_53))
                {
#line 203 "AdvancedModule.cs"
                    csharp2cuda_temp_56 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 203 "AdvancedModule.cs"
                    csharp2cuda_temp_56 = true;
                }
                if (csharp2cuda_temp_56)
#line 205 "AdvancedModule.cs"
                {
#line 206 "AdvancedModule.cs"
#line 206 "AdvancedModule.cs"
                    int* csharp2cuda_temp_57 = &((output)->valid);
                    (*(csharp2cuda_temp_57) = 0);
#line 207 "AdvancedModule.cs"
                    break;
                }
#line 209 "AdvancedModule.cs"
                {
#line 209 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 209 "AdvancedModule.cs"
                        int csharp2cuda_temp_59 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_59))))
                            break;
#line 210 "AdvancedModule.cs"
                        {
#line 211 "AdvancedModule.cs"
#line 211 "AdvancedModule.cs"
                            double csharp2cuda_temp_60 = (a)[index];
                            if (((csharp2cuda_temp_60) < (0.0)))
#line 212 "AdvancedModule.cs"
                            {
#line 213 "AdvancedModule.cs"
#line 213 "AdvancedModule.cs"
                                int* csharp2cuda_temp_61 = &((output)->valid);
                                (*(csharp2cuda_temp_61) = 0);
#line 214 "AdvancedModule.cs"
                                break;
                            }
#line 216 "AdvancedModule.cs"
                            int position = index;
#line 217 "AdvancedModule.cs"
                            while (true)
                            {
#line 217 "AdvancedModule.cs"
                                bool csharp2cuda_temp_62;
#line 217 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 217 "AdvancedModule.cs"
                                    double csharp2cuda_temp_63 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 217 "AdvancedModule.cs"
                                    double csharp2cuda_temp_64 = (a)[csharp2cuda_f64_to_i32(csharp2cuda_temp_63)];
#line 217 "AdvancedModule.cs"
                                    double csharp2cuda_temp_65 = (a)[index];
#line 217 "AdvancedModule.cs"
                                    csharp2cuda_temp_62 = ((csharp2cuda_temp_64) > (csharp2cuda_temp_65));
                                }
                                else
                                {
#line 217 "AdvancedModule.cs"
                                    csharp2cuda_temp_62 = false;
                                }
                                if (!(csharp2cuda_temp_62))
                                    break;
#line 218 "AdvancedModule.cs"
                                {
#line 219 "AdvancedModule.cs"
#line 219 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_66 = &((scratch)[position]);
#line 219 "AdvancedModule.cs"
                                    double csharp2cuda_temp_67 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                                    (*(csharp2cuda_temp_66) = csharp2cuda_temp_67);
#line 220 "AdvancedModule.cs"
#line 220 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_68 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_68));
                                }
                            }
#line 222 "AdvancedModule.cs"
#line 222 "AdvancedModule.cs"
                            double* csharp2cuda_temp_69 = &((scratch)[position]);
                            (*(csharp2cuda_temp_69) = ((double)(index)));
                        }
#line 209 "AdvancedModule.cs"
                        int* csharp2cuda_temp_58 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_58));
                    }
                }
#line 224 "AdvancedModule.cs"
                if ((output)->valid)
#line 225 "AdvancedModule.cs"
                {
#line 226 "AdvancedModule.cs"
                    double total = 0.0;
#line 227 "AdvancedModule.cs"
                    double previous = 0.0;
#line 228 "AdvancedModule.cs"
                    {
#line 228 "AdvancedModule.cs"
                        int position = 0;
                        while (true)
                        {
#line 228 "AdvancedModule.cs"
                            int csharp2cuda_temp_71 = (first)->count;
                            if (!(((position) < (csharp2cuda_temp_71))))
                                break;
#line 229 "AdvancedModule.cs"
                            {
#line 230 "AdvancedModule.cs"
                                int coalition = 0;
#line 231 "AdvancedModule.cs"
                                {
#line 231 "AdvancedModule.cs"
                                    int index = position;
                                    while (true)
                                    {
#line 231 "AdvancedModule.cs"
                                        int csharp2cuda_temp_73 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_73))))
                                            break;
#line 232 "AdvancedModule.cs"
#line 232 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_74 = &(coalition);
#line 232 "AdvancedModule.cs"
                                        int csharp2cuda_temp_75 = *(csharp2cuda_temp_74);
#line 232 "AdvancedModule.cs"
                                        double csharp2cuda_temp_76 = (scratch)[index];
                                        (*(csharp2cuda_temp_74) = csharp2cuda_i32_or(csharp2cuda_temp_75, csharp2cuda_i32_shl(1, csharp2cuda_f64_to_i32(csharp2cuda_temp_76))));
#line 231 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_72 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_72));
                                    }
                                }
#line 233 "AdvancedModule.cs"
                                double csharp2cuda_temp_77 = (scratch)[position];
#line 233 "AdvancedModule.cs"
                                int ordered = csharp2cuda_f64_to_i32(csharp2cuda_temp_77);
#line 234 "AdvancedModule.cs"
#line 234 "AdvancedModule.cs"
                                double* csharp2cuda_temp_78 = &(total);
#line 234 "AdvancedModule.cs"
                                double csharp2cuda_temp_79 = *(csharp2cuda_temp_78);
#line 234 "AdvancedModule.cs"
                                double csharp2cuda_temp_80 = (a)[ordered];
#line 234 "AdvancedModule.cs"
                                double csharp2cuda_temp_81 = (b)[coalition];
                                (*(csharp2cuda_temp_78) = __dadd_rn(csharp2cuda_temp_79, __dmul_rn(__dsub_rn(csharp2cuda_temp_80, previous), csharp2cuda_temp_81)));
#line 235 "AdvancedModule.cs"
#line 235 "AdvancedModule.cs"
                                double* csharp2cuda_temp_82 = &(previous);
#line 235 "AdvancedModule.cs"
                                double csharp2cuda_temp_83 = (a)[ordered];
                                (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
                            }
#line 228 "AdvancedModule.cs"
                            int* csharp2cuda_temp_70 = &(position);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_70));
                        }
                    }
#line 237 "AdvancedModule.cs"
#line 237 "AdvancedModule.cs"
                    double* csharp2cuda_temp_84 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_84) = total);
                }
#line 239 "AdvancedModule.cs"
                break;
#line 240 "AdvancedModule.cs"
            case 1:
#line 241 "AdvancedModule.cs"
#line 241 "AdvancedModule.cs"
                int csharp2cuda_temp_85 = (first)->count;
#line 241 "AdvancedModule.cs"
                bool csharp2cuda_temp_86;
#line 241 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_85)))))
                {
#line 241 "AdvancedModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 241 "AdvancedModule.cs"
                    csharp2cuda_temp_86 = ((csharp2cuda_temp_87) > (mathblocks_limit_submodular_set_function_values()));
                }
                else
                {
#line 241 "AdvancedModule.cs"
                    csharp2cuda_temp_86 = true;
                }
                if (csharp2cuda_temp_86)
#line 242 "AdvancedModule.cs"
                {
#line 243 "AdvancedModule.cs"
#line 243 "AdvancedModule.cs"
                    int* csharp2cuda_temp_88 = &((output)->valid);
                    (*(csharp2cuda_temp_88) = 0);
#line 244 "AdvancedModule.cs"
                    break;
                }
#line 246 "AdvancedModule.cs"
#line 246 "AdvancedModule.cs"
                int* csharp2cuda_temp_89 = &((output)->boolean_value);
                (*(csharp2cuda_temp_89) = 1);
#line 247 "AdvancedModule.cs"
                {
#line 247 "AdvancedModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 247 "AdvancedModule.cs"
                        int csharp2cuda_temp_91 = (first)->count;
#line 247 "AdvancedModule.cs"
                        bool csharp2cuda_temp_92;
#line 247 "AdvancedModule.cs"
                        if (((left) < (csharp2cuda_temp_91)))
                        {
#line 247 "AdvancedModule.cs"
                            csharp2cuda_temp_92 = (output)->boolean_value;
                        }
                        else
                        {
#line 247 "AdvancedModule.cs"
                            csharp2cuda_temp_92 = false;
                        }
                        if (!(csharp2cuda_temp_92))
                            break;
#line 248 "AdvancedModule.cs"
                        {
#line 248 "AdvancedModule.cs"
                            int right = 0;
                            while (true)
                            {
#line 248 "AdvancedModule.cs"
                                int csharp2cuda_temp_94 = (first)->count;
                                if (!(((right) < (csharp2cuda_temp_94))))
                                    break;
#line 249 "AdvancedModule.cs"
#line 249 "AdvancedModule.cs"
                                double csharp2cuda_temp_95 = (a)[left];
#line 249 "AdvancedModule.cs"
                                double csharp2cuda_temp_96 = (a)[right];
#line 249 "AdvancedModule.cs"
                                double csharp2cuda_temp_97 = (a)[csharp2cuda_i32_or(left, right)];
#line 249 "AdvancedModule.cs"
                                double csharp2cuda_temp_98 = (a)[csharp2cuda_i32_and(left, right)];
                                if (((__dadd_rn(csharp2cuda_temp_95, csharp2cuda_temp_96)) < (__dadd_rn(csharp2cuda_temp_97, csharp2cuda_temp_98))))
#line 250 "AdvancedModule.cs"
                                {
#line 251 "AdvancedModule.cs"
#line 251 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_99 = &((output)->boolean_value);
                                    (*(csharp2cuda_temp_99) = 0);
#line 252 "AdvancedModule.cs"
                                    break;
                                }
#line 248 "AdvancedModule.cs"
                                int* csharp2cuda_temp_93 = &(right);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_93));
                            }
                        }
#line 247 "AdvancedModule.cs"
                        int* csharp2cuda_temp_90 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_90));
                    }
                }
#line 254 "AdvancedModule.cs"
                break;
#line 255 "AdvancedModule.cs"
            case 2:
#line 256 "AdvancedModule.cs"
#line 256 "AdvancedModule.cs"
                int csharp2cuda_temp_100 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_100);
#line 257 "AdvancedModule.cs"
#line 257 "AdvancedModule.cs"
                int csharp2cuda_temp_101 = (first)->count;
                if ((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_101))))
#line 258 "AdvancedModule.cs"
                {
#line 259 "AdvancedModule.cs"
#line 259 "AdvancedModule.cs"
                    int* csharp2cuda_temp_102 = &((output)->valid);
                    (*(csharp2cuda_temp_102) = 0);
#line 260 "AdvancedModule.cs"
                    break;
                }
#line 262 "AdvancedModule.cs"
                {
#line 262 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 262 "AdvancedModule.cs"
                        int csharp2cuda_temp_104 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_104))))
                            break;
#line 263 "AdvancedModule.cs"
#line 263 "AdvancedModule.cs"
                        double* csharp2cuda_temp_105 = &((result)[index]);
#line 263 "AdvancedModule.cs"
                        double csharp2cuda_temp_106 = (a)[index];
                        (*(csharp2cuda_temp_105) = csharp2cuda_temp_106);
#line 262 "AdvancedModule.cs"
                        int* csharp2cuda_temp_103 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_103));
                    }
                }
#line 264 "AdvancedModule.cs"
                {
#line 264 "AdvancedModule.cs"
                    int bit = 0;
                    while (true)
                    {
#line 264 "AdvancedModule.cs"
                        int csharp2cuda_temp_108 = (first)->count;
                        if (!(((bit) < (mathblocks_advanced_log_two(csharp2cuda_temp_108)))))
                            break;
#line 265 "AdvancedModule.cs"
                        {
#line 265 "AdvancedModule.cs"
                            int mask = 0;
                            while (true)
                            {
#line 265 "AdvancedModule.cs"
                                int csharp2cuda_temp_110 = (first)->count;
                                if (!(((mask) < (csharp2cuda_temp_110))))
                                    break;
#line 266 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, bit))) != (0)))
                                {
#line 267 "AdvancedModule.cs"
#line 267 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_111 = &((result)[mask]);
#line 267 "AdvancedModule.cs"
                                    double csharp2cuda_temp_112 = *(csharp2cuda_temp_111);
#line 267 "AdvancedModule.cs"
                                    double csharp2cuda_temp_113 = (result)[csharp2cuda_i32_xor(mask, csharp2cuda_i32_shl(1, bit))];
                                    (*(csharp2cuda_temp_111) = __dsub_rn(csharp2cuda_temp_112, csharp2cuda_temp_113));
                                }
#line 265 "AdvancedModule.cs"
                                int* csharp2cuda_temp_109 = &(mask);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_109));
                            }
                        }
#line 264 "AdvancedModule.cs"
                        int* csharp2cuda_temp_107 = &(bit);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_107));
                    }
                }
#line 268 "AdvancedModule.cs"
                break;
#line 269 "AdvancedModule.cs"
            case 3:
#line 270 "AdvancedModule.cs"
#line 270 "AdvancedModule.cs"
                int csharp2cuda_temp_114 = (first)->count;
#line 270 "AdvancedModule.cs"
                bool csharp2cuda_temp_115;
#line 270 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_114)))))
                {
#line 270 "AdvancedModule.cs"
                    int csharp2cuda_temp_116 = (first)->count;
#line 270 "AdvancedModule.cs"
                    csharp2cuda_temp_115 = ((csharp2cuda_temp_116) > (mathblocks_limit_shapley_coalition_values()));
                }
                else
                {
#line 270 "AdvancedModule.cs"
                    csharp2cuda_temp_115 = true;
                }
                if (csharp2cuda_temp_115)
#line 271 "AdvancedModule.cs"
                {
#line 272 "AdvancedModule.cs"
#line 272 "AdvancedModule.cs"
                    int* csharp2cuda_temp_117 = &((output)->valid);
                    (*(csharp2cuda_temp_117) = 0);
#line 273 "AdvancedModule.cs"
                    break;
                }
#line 275 "AdvancedModule.cs"
                {
#line 276 "AdvancedModule.cs"
                    int csharp2cuda_temp_118 = (first)->count;
#line 276 "AdvancedModule.cs"
                    int player_count = mathblocks_advanced_log_two(csharp2cuda_temp_118);
#line 277 "AdvancedModule.cs"
                    mathblocks_sequence_set_vector_shape(output, player_count);
#line 278 "AdvancedModule.cs"
                    double denominator = mathblocks_advanced_factorial(player_count);
#line 279 "AdvancedModule.cs"
                    {
#line 279 "AdvancedModule.cs"
                        int player = 0;
                        while (true)
                        {
                            if (!(((player) < (player_count))))
                                break;
#line 280 "AdvancedModule.cs"
                            {
#line 281 "AdvancedModule.cs"
#line 281 "AdvancedModule.cs"
                                double* csharp2cuda_temp_120 = &((result)[player]);
                                (*(csharp2cuda_temp_120) = 0.0);
#line 282 "AdvancedModule.cs"
                                {
#line 282 "AdvancedModule.cs"
                                    int coalition = 0;
                                    while (true)
                                    {
#line 282 "AdvancedModule.cs"
                                        int csharp2cuda_temp_122 = (first)->count;
                                        if (!(((coalition) < (csharp2cuda_temp_122))))
                                            break;
#line 283 "AdvancedModule.cs"
                                        {
#line 284 "AdvancedModule.cs"
                                            if (((csharp2cuda_i32_and(coalition, csharp2cuda_i32_shl(1, player))) != (0)))
                                            {
#line 285 "AdvancedModule.cs"
                                                goto csharp2cuda_for_continue_11;
                                            }
#line 286 "AdvancedModule.cs"
                                            int size = mathblocks_advanced_popcount(coalition);
#line 287 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(__dmul_rn(mathblocks_advanced_factorial(size), mathblocks_advanced_factorial(csharp2cuda_i32_sub(csharp2cuda_i32_sub(player_count, size), 1))), denominator);
#line 290 "AdvancedModule.cs"
#line 290 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_123 = &((result)[player]);
#line 290 "AdvancedModule.cs"
                                            double csharp2cuda_temp_124 = *(csharp2cuda_temp_123);
#line 291 "AdvancedModule.cs"
                                            double csharp2cuda_temp_125 = (a)[csharp2cuda_i32_or(coalition, csharp2cuda_i32_shl(1, player))];
#line 291 "AdvancedModule.cs"
                                            double csharp2cuda_temp_126 = (a)[coalition];
                                            (*(csharp2cuda_temp_123) = __dadd_rn(csharp2cuda_temp_124, __dmul_rn(weight, __dsub_rn(csharp2cuda_temp_125, csharp2cuda_temp_126))));
                                        }
                                        csharp2cuda_for_continue_11:
#line 282 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_121 = &(coalition);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_121));
                                    }
                                }
                            }
#line 279 "AdvancedModule.cs"
                            int* csharp2cuda_temp_119 = &(player);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_119));
                        }
                    }
#line 294 "AdvancedModule.cs"
                    break;
                }
#line 296 "AdvancedModule.cs"
            case 4:
            case 5:
#line 298 "AdvancedModule.cs"
#line 298 "AdvancedModule.cs"
                int csharp2cuda_temp_127 = (third)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_127);
#line 299 "AdvancedModule.cs"
#line 299 "AdvancedModule.cs"
                int csharp2cuda_temp_128 = (first)->count;
#line 299 "AdvancedModule.cs"
                bool csharp2cuda_temp_129;
#line 299 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_128) <= (0))))
                {
#line 299 "AdvancedModule.cs"
                    int csharp2cuda_temp_130 = (first)->count;
#line 299 "AdvancedModule.cs"
                    int csharp2cuda_temp_131 = (second)->count;
#line 299 "AdvancedModule.cs"
                    csharp2cuda_temp_129 = ((csharp2cuda_temp_130) != (csharp2cuda_temp_131));
                }
                else
                {
#line 299 "AdvancedModule.cs"
                    csharp2cuda_temp_129 = true;
                }
#line 299 "AdvancedModule.cs"
                bool csharp2cuda_temp_132;
#line 299 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_129))
                {
#line 299 "AdvancedModule.cs"
                    double csharp2cuda_temp_133 = (fourth)->scalar_value;
#line 299 "AdvancedModule.cs"
                    csharp2cuda_temp_132 = ((csharp2cuda_temp_133) < (0.0));
                }
                else
                {
#line 299 "AdvancedModule.cs"
                    csharp2cuda_temp_132 = true;
                }
                if (csharp2cuda_temp_132)
#line 300 "AdvancedModule.cs"
                {
#line 301 "AdvancedModule.cs"
#line 301 "AdvancedModule.cs"
                    int* csharp2cuda_temp_134 = &((output)->valid);
                    (*(csharp2cuda_temp_134) = 0);
#line 302 "AdvancedModule.cs"
                    break;
                }
#line 304 "AdvancedModule.cs"
                break;
#line 305 "AdvancedModule.cs"
            case 6:
#line 306 "AdvancedModule.cs"
#line 306 "AdvancedModule.cs"
                int csharp2cuda_temp_135 = (first)->count;
                if (((csharp2cuda_temp_135) <= (0)))
#line 307 "AdvancedModule.cs"
                {
#line 308 "AdvancedModule.cs"
#line 308 "AdvancedModule.cs"
                    int* csharp2cuda_temp_136 = &((output)->valid);
                    (*(csharp2cuda_temp_136) = 0);
#line 309 "AdvancedModule.cs"
                    break;
                }
#line 311 "AdvancedModule.cs"
                {
#line 312 "AdvancedModule.cs"
                    double sum = 0.0;
#line 313 "AdvancedModule.cs"
                    {
#line 313 "AdvancedModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 313 "AdvancedModule.cs"
                            int csharp2cuda_temp_138 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_138))))
                                break;
#line 314 "AdvancedModule.cs"
                            {
#line 314 "AdvancedModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 314 "AdvancedModule.cs"
                                    int csharp2cuda_temp_140 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_140))))
                                        break;
#line 315 "AdvancedModule.cs"
#line 315 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_141 = &(sum);
#line 315 "AdvancedModule.cs"
                                    double csharp2cuda_temp_142 = *(csharp2cuda_temp_141);
#line 315 "AdvancedModule.cs"
                                    double csharp2cuda_temp_143 = (a)[left];
#line 315 "AdvancedModule.cs"
                                    double csharp2cuda_temp_144 = (a)[right];
                                    (*(csharp2cuda_temp_141) = __dadd_rn(csharp2cuda_temp_142, fabs(__dsub_rn(csharp2cuda_temp_143, csharp2cuda_temp_144))));
#line 314 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_139 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_139));
                                }
                            }
#line 313 "AdvancedModule.cs"
                            int* csharp2cuda_temp_137 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_137));
                        }
                    }
#line 316 "AdvancedModule.cs"
#line 316 "AdvancedModule.cs"
                    double* csharp2cuda_temp_145 = &((output)->scalar_value);
#line 317 "AdvancedModule.cs"
                    int csharp2cuda_temp_146 = (first)->count;
#line 317 "AdvancedModule.cs"
                    int csharp2cuda_temp_147 = (first)->count;
#line 316 "AdvancedModule.cs"
                    double csharp2cuda_temp_148 = __ddiv_rn(sum, __dmul_rn(__dmul_rn(2.0, ((double)(csharp2cuda_temp_146))), mathblocks_compensated_sum(a, csharp2cuda_temp_147)));
                    (*(csharp2cuda_temp_145) = csharp2cuda_temp_148);
#line 318 "AdvancedModule.cs"
                    break;
                }
#line 320 "AdvancedModule.cs"
            case 7:
#line 321 "AdvancedModule.cs"
#line 321 "AdvancedModule.cs"
                int csharp2cuda_temp_149 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_149, 1));
#line 322 "AdvancedModule.cs"
#line 322 "AdvancedModule.cs"
                int csharp2cuda_temp_150 = (first)->count;
#line 322 "AdvancedModule.cs"
                bool csharp2cuda_temp_151;
#line 322 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_150) <= (0))))
                {
#line 322 "AdvancedModule.cs"
                    csharp2cuda_temp_151 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 322 "AdvancedModule.cs"
                    csharp2cuda_temp_151 = true;
                }
                if (csharp2cuda_temp_151)
#line 323 "AdvancedModule.cs"
                {
#line 324 "AdvancedModule.cs"
#line 324 "AdvancedModule.cs"
                    int* csharp2cuda_temp_152 = &((output)->valid);
                    (*(csharp2cuda_temp_152) = 0);
#line 325 "AdvancedModule.cs"
                    break;
                }
#line 327 "AdvancedModule.cs"
#line 327 "AdvancedModule.cs"
                double* csharp2cuda_temp_153 = &((result)[0]);
                (*(csharp2cuda_temp_153) = 0.0);
#line 328 "AdvancedModule.cs"
                {
#line 328 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 328 "AdvancedModule.cs"
                        int csharp2cuda_temp_155 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_155))))
                            break;
#line 329 "AdvancedModule.cs"
#line 329 "AdvancedModule.cs"
                        double* csharp2cuda_temp_156 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 329 "AdvancedModule.cs"
                        double csharp2cuda_temp_157 = (a)[index];
                        (*(csharp2cuda_temp_156) = csharp2cuda_temp_157);
#line 328 "AdvancedModule.cs"
                        int* csharp2cuda_temp_154 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_154));
                    }
                }
#line 330 "AdvancedModule.cs"
                {
#line 331 "AdvancedModule.cs"
                    int csharp2cuda_temp_158 = (first)->count;
#line 331 "AdvancedModule.cs"
                    double* sorted = mathblocks_stable_merge_sort(csharp2cuda_pointer_add(result, 1), scratch, csharp2cuda_temp_158, false);
#line 332 "AdvancedModule.cs"
                    if (((((void*)(sorted))) != (((void*)(csharp2cuda_pointer_add(result, 1))))))
                    {
#line 333 "AdvancedModule.cs"
                        {
#line 333 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 333 "AdvancedModule.cs"
                                int csharp2cuda_temp_160 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_160))))
                                    break;
#line 334 "AdvancedModule.cs"
#line 334 "AdvancedModule.cs"
                                double* csharp2cuda_temp_161 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 334 "AdvancedModule.cs"
                                double csharp2cuda_temp_162 = (sorted)[index];
                                (*(csharp2cuda_temp_161) = csharp2cuda_temp_162);
#line 333 "AdvancedModule.cs"
                                int* csharp2cuda_temp_159 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_159));
                            }
                        }
                    }
                }
#line 336 "AdvancedModule.cs"
                {
#line 337 "AdvancedModule.cs"
                    int csharp2cuda_temp_163 = (first)->count;
#line 337 "AdvancedModule.cs"
                    double total = mathblocks_compensated_sum(csharp2cuda_pointer_add(result, 1), csharp2cuda_temp_163);
#line 338 "AdvancedModule.cs"
                    {
#line 338 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 338 "AdvancedModule.cs"
                            int csharp2cuda_temp_165 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_165))))
                                break;
#line 339 "AdvancedModule.cs"
#line 339 "AdvancedModule.cs"
                            double* csharp2cuda_temp_166 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 339 "AdvancedModule.cs"
                            double csharp2cuda_temp_167 = (result)[index];
#line 339 "AdvancedModule.cs"
                            double csharp2cuda_temp_168 = (result)[csharp2cuda_i32_add(index, 1)];
#line 339 "AdvancedModule.cs"
                            double csharp2cuda_temp_169 = __ddiv_rn(csharp2cuda_temp_168, total);
                            (*(csharp2cuda_temp_166) = __dadd_rn(csharp2cuda_temp_167, csharp2cuda_temp_169));
#line 338 "AdvancedModule.cs"
                            int* csharp2cuda_temp_164 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_164));
                        }
                    }
#line 340 "AdvancedModule.cs"
                    break;
                }
#line 342 "AdvancedModule.cs"
            case 8:
#line 343 "AdvancedModule.cs"
#line 343 "AdvancedModule.cs"
                int csharp2cuda_temp_170 = (first)->rows;
#line 343 "AdvancedModule.cs"
                int csharp2cuda_temp_171 = (first)->columns;
#line 343 "AdvancedModule.cs"
                bool csharp2cuda_temp_172;
#line 343 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_170) != (csharp2cuda_temp_171))))
                {
#line 343 "AdvancedModule.cs"
                    int csharp2cuda_temp_173 = (first)->rows;
#line 343 "AdvancedModule.cs"
                    int csharp2cuda_temp_174 = (second)->count;
#line 343 "AdvancedModule.cs"
                    csharp2cuda_temp_172 = ((csharp2cuda_temp_173) != (csharp2cuda_temp_174));
                }
                else
                {
#line 343 "AdvancedModule.cs"
                    csharp2cuda_temp_172 = true;
                }
#line 343 "AdvancedModule.cs"
                bool csharp2cuda_temp_175;
#line 343 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_172))
                {
#line 344 "AdvancedModule.cs"
                    int csharp2cuda_temp_176 = (first)->rows;
#line 344 "AdvancedModule.cs"
                    int csharp2cuda_temp_177 = (first)->columns;
#line 344 "AdvancedModule.cs"
                    bool csharp2cuda_temp_178 = mathblocks_advanced_transition(a, csharp2cuda_temp_176, csharp2cuda_temp_177);
#line 343 "AdvancedModule.cs"
                    csharp2cuda_temp_175 = (!(csharp2cuda_temp_178));
                }
                else
                {
#line 343 "AdvancedModule.cs"
                    csharp2cuda_temp_175 = true;
                }
#line 343 "AdvancedModule.cs"
                bool csharp2cuda_temp_179;
#line 343 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_175))
                {
#line 345 "AdvancedModule.cs"
                    int csharp2cuda_temp_180 = (second)->count;
#line 345 "AdvancedModule.cs"
                    bool csharp2cuda_temp_181 = mathblocks_advanced_distribution(b, csharp2cuda_temp_180);
#line 343 "AdvancedModule.cs"
                    csharp2cuda_temp_179 = (!(csharp2cuda_temp_181));
                }
                else
                {
#line 343 "AdvancedModule.cs"
                    csharp2cuda_temp_179 = true;
                }
                if (csharp2cuda_temp_179)
#line 346 "AdvancedModule.cs"
                {
#line 347 "AdvancedModule.cs"
#line 347 "AdvancedModule.cs"
                    int* csharp2cuda_temp_182 = &((output)->valid);
                    (*(csharp2cuda_temp_182) = 0);
#line 348 "AdvancedModule.cs"
                    break;
                }
#line 350 "AdvancedModule.cs"
                {
#line 351 "AdvancedModule.cs"
                    double total = 0.0;
#line 352 "AdvancedModule.cs"
                    {
#line 352 "AdvancedModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 352 "AdvancedModule.cs"
                            int csharp2cuda_temp_184 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_184))))
                                break;
#line 353 "AdvancedModule.cs"
                            {
#line 353 "AdvancedModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 353 "AdvancedModule.cs"
                                    int csharp2cuda_temp_186 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_186))))
                                        break;
#line 354 "AdvancedModule.cs"
                                    {
#line 355 "AdvancedModule.cs"
                                        double csharp2cuda_temp_187 = (b)[row];
#line 355 "AdvancedModule.cs"
                                        int csharp2cuda_temp_188 = (first)->columns;
#line 355 "AdvancedModule.cs"
                                        double csharp2cuda_temp_189 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_188), column)];
#line 355 "AdvancedModule.cs"
                                        double forward = __dmul_rn(csharp2cuda_temp_187, csharp2cuda_temp_189);
#line 356 "AdvancedModule.cs"
                                        double csharp2cuda_temp_190 = (b)[column];
#line 356 "AdvancedModule.cs"
                                        int csharp2cuda_temp_191 = (first)->columns;
#line 356 "AdvancedModule.cs"
                                        double csharp2cuda_temp_192 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_191), row)];
#line 356 "AdvancedModule.cs"
                                        double reverse = __dmul_rn(csharp2cuda_temp_190, csharp2cuda_temp_192);
#line 357 "AdvancedModule.cs"
#line 357 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_193;
#line 357 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 357 "AdvancedModule.cs"
                                            csharp2cuda_temp_193 = ((reverse) == (0.0));
                                        }
                                        else
                                        {
#line 357 "AdvancedModule.cs"
                                            csharp2cuda_temp_193 = false;
                                        }
                                        if (csharp2cuda_temp_193)
#line 358 "AdvancedModule.cs"
                                        {
#line 359 "AdvancedModule.cs"
#line 359 "AdvancedModule.cs"
                                            int* csharp2cuda_temp_194 = &((output)->valid);
                                            (*(csharp2cuda_temp_194) = 0);
#line 360 "AdvancedModule.cs"
                                            break;
                                        }
#line 362 "AdvancedModule.cs"
#line 362 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_195;
#line 362 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 362 "AdvancedModule.cs"
                                            csharp2cuda_temp_195 = ((reverse) > (0.0));
                                        }
                                        else
                                        {
#line 362 "AdvancedModule.cs"
                                            csharp2cuda_temp_195 = false;
                                        }
                                        if (csharp2cuda_temp_195)
                                        {
#line 363 "AdvancedModule.cs"
#line 363 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_196 = &(total);
#line 363 "AdvancedModule.cs"
                                            double csharp2cuda_temp_197 = *(csharp2cuda_temp_196);
#line 363 "AdvancedModule.cs"
                                            double csharp2cuda_temp_198 = __ddiv_rn(forward, reverse);
                                            (*(csharp2cuda_temp_196) = __dadd_rn(csharp2cuda_temp_197, __dmul_rn(forward, mathblocks_natural_logarithm(csharp2cuda_temp_198))));
                                        }
                                    }
#line 353 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_185 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_185));
                                }
                            }
#line 352 "AdvancedModule.cs"
                            int* csharp2cuda_temp_183 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_183));
                        }
                    }
#line 365 "AdvancedModule.cs"
#line 365 "AdvancedModule.cs"
                    double* csharp2cuda_temp_199 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_199) = total);
#line 366 "AdvancedModule.cs"
                    break;
                }
#line 368 "AdvancedModule.cs"
            case 9:
#line 369 "AdvancedModule.cs"
#line 369 "AdvancedModule.cs"
                int csharp2cuda_temp_200 = (first)->rows;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_200);
#line 370 "AdvancedModule.cs"
#line 370 "AdvancedModule.cs"
                int csharp2cuda_temp_201 = (first)->rows;
#line 370 "AdvancedModule.cs"
                int csharp2cuda_temp_202 = (first)->columns;
#line 370 "AdvancedModule.cs"
                bool csharp2cuda_temp_203 = mathblocks_advanced_transition(a, csharp2cuda_temp_201, csharp2cuda_temp_202);
#line 370 "AdvancedModule.cs"
                bool csharp2cuda_temp_204;
#line 370 "AdvancedModule.cs"
                if (!((!(csharp2cuda_temp_203))))
                {
#line 370 "AdvancedModule.cs"
                    csharp2cuda_temp_204 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 370 "AdvancedModule.cs"
                    csharp2cuda_temp_204 = true;
                }
                if (csharp2cuda_temp_204)
#line 371 "AdvancedModule.cs"
                {
#line 372 "AdvancedModule.cs"
#line 372 "AdvancedModule.cs"
                    int* csharp2cuda_temp_205 = &((output)->valid);
                    (*(csharp2cuda_temp_205) = 0);
#line 373 "AdvancedModule.cs"
                    break;
                }
#line 375 "AdvancedModule.cs"
                {
#line 376 "AdvancedModule.cs"
                    int iterations = 0;
#line 377 "AdvancedModule.cs"
#line 377 "AdvancedModule.cs"
                    double csharp2cuda_temp_206 = (second)->scalar_value;
#line 377 "AdvancedModule.cs"
                    int* csharp2cuda_temp_207 = &(iterations);
#line 377 "AdvancedModule.cs"
                    bool csharp2cuda_temp_208 = mathblocks_sequence_positive_integer(csharp2cuda_temp_206, csharp2cuda_temp_207);
#line 377 "AdvancedModule.cs"
                    bool csharp2cuda_temp_209;
#line 377 "AdvancedModule.cs"
                    if (!((!(csharp2cuda_temp_208))))
                    {
#line 377 "AdvancedModule.cs"
                        csharp2cuda_temp_209 = ((iterations) > (mathblocks_limit_iteration_count()));
                    }
                    else
                    {
#line 377 "AdvancedModule.cs"
                        csharp2cuda_temp_209 = true;
                    }
                    if (csharp2cuda_temp_209)
#line 378 "AdvancedModule.cs"
                    {
#line 379 "AdvancedModule.cs"
#line 379 "AdvancedModule.cs"
                        int* csharp2cuda_temp_210 = &((output)->valid);
                        (*(csharp2cuda_temp_210) = 0);
#line 380 "AdvancedModule.cs"
                        break;
                    }
#line 382 "AdvancedModule.cs"
                    {
#line 382 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 382 "AdvancedModule.cs"
                            int csharp2cuda_temp_212 = (first)->rows;
                            if (!(((index) < (csharp2cuda_temp_212))))
                                break;
#line 383 "AdvancedModule.cs"
#line 383 "AdvancedModule.cs"
                            double* csharp2cuda_temp_213 = &((result)[index]);
#line 383 "AdvancedModule.cs"
                            int csharp2cuda_temp_214 = (first)->rows;
#line 383 "AdvancedModule.cs"
                            double csharp2cuda_temp_215 = __ddiv_rn(1.0, ((double)(csharp2cuda_temp_214)));
                            (*(csharp2cuda_temp_213) = csharp2cuda_temp_215);
#line 382 "AdvancedModule.cs"
                            int* csharp2cuda_temp_211 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_211));
                        }
                    }
#line 384 "AdvancedModule.cs"
                    {
#line 384 "AdvancedModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 385 "AdvancedModule.cs"
                            {
#line 386 "AdvancedModule.cs"
                                {
#line 386 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 386 "AdvancedModule.cs"
                                        int csharp2cuda_temp_218 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_218))))
                                            break;
#line 387 "AdvancedModule.cs"
#line 387 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_219 = &((scratch)[index]);
                                        (*(csharp2cuda_temp_219) = 0.0);
#line 386 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_217 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                                    }
                                }
#line 388 "AdvancedModule.cs"
                                {
#line 388 "AdvancedModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 388 "AdvancedModule.cs"
                                        int csharp2cuda_temp_221 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_221))))
                                            break;
#line 389 "AdvancedModule.cs"
                                        {
#line 389 "AdvancedModule.cs"
                                            int column = 0;
                                            while (true)
                                            {
#line 389 "AdvancedModule.cs"
                                                int csharp2cuda_temp_223 = (first)->columns;
                                                if (!(((column) < (csharp2cuda_temp_223))))
                                                    break;
#line 390 "AdvancedModule.cs"
#line 390 "AdvancedModule.cs"
                                                double* csharp2cuda_temp_224 = &((scratch)[column]);
#line 390 "AdvancedModule.cs"
                                                double csharp2cuda_temp_225 = *(csharp2cuda_temp_224);
#line 390 "AdvancedModule.cs"
                                                double csharp2cuda_temp_226 = (result)[row];
#line 390 "AdvancedModule.cs"
                                                int csharp2cuda_temp_227 = (first)->columns;
#line 390 "AdvancedModule.cs"
                                                double csharp2cuda_temp_228 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_227), column)];
                                                (*(csharp2cuda_temp_224) = __dadd_rn(csharp2cuda_temp_225, __dmul_rn(csharp2cuda_temp_226, csharp2cuda_temp_228)));
#line 389 "AdvancedModule.cs"
                                                int* csharp2cuda_temp_222 = &(column);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_222));
                                            }
                                        }
#line 388 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_220 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_220));
                                    }
                                }
#line 391 "AdvancedModule.cs"
                                {
#line 391 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 391 "AdvancedModule.cs"
                                        int csharp2cuda_temp_230 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_230))))
                                            break;
#line 392 "AdvancedModule.cs"
#line 392 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_231 = &((result)[index]);
#line 392 "AdvancedModule.cs"
                                        double csharp2cuda_temp_232 = (scratch)[index];
                                        (*(csharp2cuda_temp_231) = csharp2cuda_temp_232);
#line 391 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_229 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_229));
                                    }
                                }
                            }
#line 384 "AdvancedModule.cs"
                            int* csharp2cuda_temp_216 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_216));
                        }
                    }
#line 394 "AdvancedModule.cs"
                    break;
                }
#line 396 "AdvancedModule.cs"
            case 10:
#line 397 "AdvancedModule.cs"
#line 397 "AdvancedModule.cs"
                int csharp2cuda_temp_233 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_233);
#line 398 "AdvancedModule.cs"
#line 398 "AdvancedModule.cs"
                int csharp2cuda_temp_234 = (first)->count;
#line 398 "AdvancedModule.cs"
                bool csharp2cuda_temp_235;
#line 398 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_234) <= (0))))
                {
#line 398 "AdvancedModule.cs"
                    csharp2cuda_temp_235 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 398 "AdvancedModule.cs"
                    csharp2cuda_temp_235 = true;
                }
                if (csharp2cuda_temp_235)
#line 399 "AdvancedModule.cs"
                {
#line 400 "AdvancedModule.cs"
#line 400 "AdvancedModule.cs"
                    int* csharp2cuda_temp_236 = &((output)->valid);
                    (*(csharp2cuda_temp_236) = 0);
#line 401 "AdvancedModule.cs"
                    break;
                }
#line 403 "AdvancedModule.cs"
                {
#line 404 "AdvancedModule.cs"
                    double* means = scratch;
#line 405 "AdvancedModule.cs"
                    int csharp2cuda_temp_237 = (first)->count;
#line 405 "AdvancedModule.cs"
                    int* weights = ((int*)(csharp2cuda_pointer_add(means, csharp2cuda_temp_237)));
#line 406 "AdvancedModule.cs"
                    int csharp2cuda_temp_238 = (first)->count;
#line 406 "AdvancedModule.cs"
                    int* starts = csharp2cuda_pointer_add(weights, csharp2cuda_temp_238);
#line 407 "AdvancedModule.cs"
                    int block_count = 0;
#line 408 "AdvancedModule.cs"
                    {
#line 408 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 408 "AdvancedModule.cs"
                            int csharp2cuda_temp_240 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_240))))
                                break;
#line 409 "AdvancedModule.cs"
                            {
#line 410 "AdvancedModule.cs"
#line 410 "AdvancedModule.cs"
                                double* csharp2cuda_temp_241 = &((means)[block_count]);
#line 410 "AdvancedModule.cs"
                                double csharp2cuda_temp_242 = (a)[index];
                                (*(csharp2cuda_temp_241) = csharp2cuda_temp_242);
#line 411 "AdvancedModule.cs"
#line 411 "AdvancedModule.cs"
                                int* csharp2cuda_temp_243 = &((weights)[block_count]);
                                (*(csharp2cuda_temp_243) = 1);
#line 412 "AdvancedModule.cs"
#line 412 "AdvancedModule.cs"
                                int* csharp2cuda_temp_244 = &((starts)[block_count]);
                                (*(csharp2cuda_temp_244) = index);
#line 413 "AdvancedModule.cs"
#line 413 "AdvancedModule.cs"
                                int* csharp2cuda_temp_245 = &(block_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_245));
#line 414 "AdvancedModule.cs"
                                while (true)
                                {
#line 414 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_246;
#line 414 "AdvancedModule.cs"
                                    if (((block_count) >= (2)))
                                    {
#line 414 "AdvancedModule.cs"
                                        double csharp2cuda_temp_247 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 414 "AdvancedModule.cs"
                                        double csharp2cuda_temp_248 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 414 "AdvancedModule.cs"
                                        csharp2cuda_temp_246 = ((csharp2cuda_temp_247) > (csharp2cuda_temp_248));
                                    }
                                    else
                                    {
#line 414 "AdvancedModule.cs"
                                        csharp2cuda_temp_246 = false;
                                    }
                                    if (!(csharp2cuda_temp_246))
                                        break;
#line 415 "AdvancedModule.cs"
                                    {
#line 416 "AdvancedModule.cs"
                                        int csharp2cuda_temp_249 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 416 "AdvancedModule.cs"
                                        int csharp2cuda_temp_250 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 416 "AdvancedModule.cs"
                                        int combined_weight = csharp2cuda_i32_add(csharp2cuda_temp_249, csharp2cuda_temp_250);
#line 417 "AdvancedModule.cs"
#line 417 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_251 = &((means)[csharp2cuda_i32_sub(block_count, 2)]);
#line 418 "AdvancedModule.cs"
                                        double csharp2cuda_temp_252 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 418 "AdvancedModule.cs"
                                        int csharp2cuda_temp_253 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 419 "AdvancedModule.cs"
                                        double csharp2cuda_temp_254 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 419 "AdvancedModule.cs"
                                        int csharp2cuda_temp_255 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 418 "AdvancedModule.cs"
                                        double csharp2cuda_temp_256 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_252, ((double)(csharp2cuda_temp_253))), __dmul_rn(csharp2cuda_temp_254, ((double)(csharp2cuda_temp_255)))), ((double)(combined_weight)));
                                        (*(csharp2cuda_temp_251) = csharp2cuda_temp_256);
#line 421 "AdvancedModule.cs"
#line 421 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_257 = &((weights)[csharp2cuda_i32_sub(block_count, 2)]);
                                        (*(csharp2cuda_temp_257) = combined_weight);
#line 422 "AdvancedModule.cs"
#line 422 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_258 = &(block_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_258));
                                    }
                                }
                            }
#line 408 "AdvancedModule.cs"
                            int* csharp2cuda_temp_239 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_239));
                        }
                    }
#line 425 "AdvancedModule.cs"
                    {
#line 425 "AdvancedModule.cs"
                        int block = 0;
                        while (true)
                        {
                            if (!(((block) < (block_count))))
                                break;
#line 426 "AdvancedModule.cs"
                            {
#line 427 "AdvancedModule.cs"
                                int csharp2cuda_temp_260;
#line 427 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_add(block, 1)) < (block_count)))
                                {
#line 427 "AdvancedModule.cs"
                                    csharp2cuda_temp_260 = (starts)[csharp2cuda_i32_add(block, 1)];
                                }
                                else
                                {
#line 427 "AdvancedModule.cs"
                                    csharp2cuda_temp_260 = (first)->count;
                                }
#line 427 "AdvancedModule.cs"
                                int end = csharp2cuda_temp_260;
#line 428 "AdvancedModule.cs"
                                {
#line 428 "AdvancedModule.cs"
                                    int index = (starts)[block];
                                    while (true)
                                    {
                                        if (!(((index) < (end))))
                                            break;
#line 429 "AdvancedModule.cs"
#line 429 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_262 = &((result)[index]);
#line 429 "AdvancedModule.cs"
                                        double csharp2cuda_temp_263 = (means)[block];
                                        (*(csharp2cuda_temp_262) = csharp2cuda_temp_263);
#line 428 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_261 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_261));
                                    }
                                }
                            }
#line 425 "AdvancedModule.cs"
                            int* csharp2cuda_temp_259 = &(block);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_259));
                        }
                    }
#line 431 "AdvancedModule.cs"
                    break;
                }
#line 433 "AdvancedModule.cs"
            case 11:
#line 434 "AdvancedModule.cs"
#line 434 "AdvancedModule.cs"
                int csharp2cuda_temp_264 = (first)->count;
#line 434 "AdvancedModule.cs"
                int csharp2cuda_temp_265 = (second)->count;
#line 434 "AdvancedModule.cs"
                bool csharp2cuda_temp_266;
#line 434 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_264) != (csharp2cuda_temp_265))))
                {
#line 434 "AdvancedModule.cs"
                    csharp2cuda_temp_266 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 434 "AdvancedModule.cs"
                    csharp2cuda_temp_266 = true;
                }
                if (csharp2cuda_temp_266)
#line 435 "AdvancedModule.cs"
                {
#line 436 "AdvancedModule.cs"
#line 436 "AdvancedModule.cs"
                    int* csharp2cuda_temp_267 = &((output)->valid);
                    (*(csharp2cuda_temp_267) = 0);
#line 437 "AdvancedModule.cs"
                    break;
                }
#line 439 "AdvancedModule.cs"
                {
#line 440 "AdvancedModule.cs"
                    double* left_sorted = scratch;
#line 441 "AdvancedModule.cs"
                    int csharp2cuda_temp_268 = (first)->count;
#line 441 "AdvancedModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_268);
#line 442 "AdvancedModule.cs"
#line 442 "AdvancedModule.cs"
                    int csharp2cuda_temp_269 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_269, left_sorted, true);
#line 443 "AdvancedModule.cs"
#line 443 "AdvancedModule.cs"
                    int csharp2cuda_temp_270 = (first)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_270, right_sorted, true);
#line 444 "AdvancedModule.cs"
                    double left_sum = 0.0;
#line 445 "AdvancedModule.cs"
                    double right_sum = 0.0;
#line 446 "AdvancedModule.cs"
                    bool majorizes = true;
#line 447 "AdvancedModule.cs"
                    {
#line 447 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 447 "AdvancedModule.cs"
                            int csharp2cuda_temp_272 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_272))))
                                break;
#line 448 "AdvancedModule.cs"
                            {
#line 449 "AdvancedModule.cs"
#line 449 "AdvancedModule.cs"
                                double* csharp2cuda_temp_273 = &(left_sum);
#line 449 "AdvancedModule.cs"
                                double csharp2cuda_temp_274 = *(csharp2cuda_temp_273);
#line 449 "AdvancedModule.cs"
                                double csharp2cuda_temp_275 = (left_sorted)[index];
                                (*(csharp2cuda_temp_273) = __dadd_rn(csharp2cuda_temp_274, csharp2cuda_temp_275));
#line 450 "AdvancedModule.cs"
#line 450 "AdvancedModule.cs"
                                double* csharp2cuda_temp_276 = &(right_sum);
#line 450 "AdvancedModule.cs"
                                double csharp2cuda_temp_277 = *(csharp2cuda_temp_276);
#line 450 "AdvancedModule.cs"
                                double csharp2cuda_temp_278 = (right_sorted)[index];
                                (*(csharp2cuda_temp_276) = __dadd_rn(csharp2cuda_temp_277, csharp2cuda_temp_278));
#line 451 "AdvancedModule.cs"
#line 451 "AdvancedModule.cs"
                                int csharp2cuda_temp_279 = (first)->count;
#line 451 "AdvancedModule.cs"
                                bool csharp2cuda_temp_280;
#line 451 "AdvancedModule.cs"
                                if (((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_279, 1))))
                                {
#line 451 "AdvancedModule.cs"
                                    csharp2cuda_temp_280 = ((left_sum) < (right_sum));
                                }
                                else
                                {
#line 451 "AdvancedModule.cs"
                                    csharp2cuda_temp_280 = false;
                                }
                                if (csharp2cuda_temp_280)
                                {
#line 452 "AdvancedModule.cs"
#line 452 "AdvancedModule.cs"
                                    bool* csharp2cuda_temp_281 = &(majorizes);
                                    (*(csharp2cuda_temp_281) = false);
                                }
                            }
#line 447 "AdvancedModule.cs"
                            int* csharp2cuda_temp_271 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_271));
                        }
                    }
#line 454 "AdvancedModule.cs"
#line 454 "AdvancedModule.cs"
                    int* csharp2cuda_temp_282 = &((output)->boolean_value);
#line 454 "AdvancedModule.cs"
                    bool csharp2cuda_temp_283;
#line 454 "AdvancedModule.cs"
                    if (majorizes)
                    {
#line 454 "AdvancedModule.cs"
                        csharp2cuda_temp_283 = ((left_sum) == (right_sum));
                    }
                    else
                    {
#line 454 "AdvancedModule.cs"
                        csharp2cuda_temp_283 = false;
                    }
#line 454 "AdvancedModule.cs"
                    int csharp2cuda_temp_284;
#line 454 "AdvancedModule.cs"
                    if (csharp2cuda_temp_283)
                    {
#line 454 "AdvancedModule.cs"
                        csharp2cuda_temp_284 = 1;
                    }
                    else
                    {
#line 454 "AdvancedModule.cs"
                        csharp2cuda_temp_284 = 0;
                    }
                    (*(csharp2cuda_temp_282) = csharp2cuda_temp_284);
#line 455 "AdvancedModule.cs"
                    break;
                }
#line 457 "AdvancedModule.cs"
            case 12:
#line 458 "AdvancedModule.cs"
#line 458 "AdvancedModule.cs"
                int csharp2cuda_temp_285 = (first)->count;
#line 458 "AdvancedModule.cs"
                bool csharp2cuda_temp_286;
#line 458 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_285) <= (0))))
                {
#line 458 "AdvancedModule.cs"
                    int csharp2cuda_temp_287 = (first)->count;
#line 458 "AdvancedModule.cs"
                    int csharp2cuda_temp_288 = (second)->count;
#line 458 "AdvancedModule.cs"
                    csharp2cuda_temp_286 = ((csharp2cuda_temp_287) != (csharp2cuda_temp_288));
                }
                else
                {
#line 458 "AdvancedModule.cs"
                    csharp2cuda_temp_286 = true;
                }
                if (csharp2cuda_temp_286)
#line 459 "AdvancedModule.cs"
                {
#line 460 "AdvancedModule.cs"
#line 460 "AdvancedModule.cs"
                    int* csharp2cuda_temp_289 = &((output)->valid);
                    (*(csharp2cuda_temp_289) = 0);
#line 461 "AdvancedModule.cs"
                    break;
                }
#line 463 "AdvancedModule.cs"
                {
#line 464 "AdvancedModule.cs"
                    double minimum = mathblocks_positive_infinity();
#line 465 "AdvancedModule.cs"
                    double maximum = (-(mathblocks_positive_infinity()));
#line 466 "AdvancedModule.cs"
                    {
#line 466 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 466 "AdvancedModule.cs"
                            int csharp2cuda_temp_291 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_291))))
                                break;
#line 467 "AdvancedModule.cs"
                            {
#line 468 "AdvancedModule.cs"
#line 468 "AdvancedModule.cs"
                                double csharp2cuda_temp_292 = (a)[index];
#line 468 "AdvancedModule.cs"
                                bool csharp2cuda_temp_293;
#line 468 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_292) <= (0.0))))
                                {
#line 468 "AdvancedModule.cs"
                                    double csharp2cuda_temp_294 = (b)[index];
#line 468 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = ((csharp2cuda_temp_294) <= (0.0));
                                }
                                else
                                {
#line 468 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = true;
                                }
                                if (csharp2cuda_temp_293)
#line 469 "AdvancedModule.cs"
                                {
#line 470 "AdvancedModule.cs"
#line 470 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_295 = &((output)->valid);
                                    (*(csharp2cuda_temp_295) = 0);
#line 471 "AdvancedModule.cs"
                                    break;
                                }
#line 473 "AdvancedModule.cs"
                                double csharp2cuda_temp_296 = (a)[index];
#line 473 "AdvancedModule.cs"
                                double csharp2cuda_temp_297 = (b)[index];
#line 473 "AdvancedModule.cs"
                                double ratio = __ddiv_rn(csharp2cuda_temp_296, csharp2cuda_temp_297);
#line 474 "AdvancedModule.cs"
#line 474 "AdvancedModule.cs"
                                double* csharp2cuda_temp_298 = &(minimum);
#line 474 "AdvancedModule.cs"
                                double csharp2cuda_temp_299;
#line 474 "AdvancedModule.cs"
                                if (((minimum) < (ratio)))
                                {
#line 474 "AdvancedModule.cs"
                                    csharp2cuda_temp_299 = minimum;
                                }
                                else
                                {
#line 474 "AdvancedModule.cs"
                                    csharp2cuda_temp_299 = ratio;
                                }
                                (*(csharp2cuda_temp_298) = csharp2cuda_temp_299);
#line 475 "AdvancedModule.cs"
#line 475 "AdvancedModule.cs"
                                double* csharp2cuda_temp_300 = &(maximum);
#line 475 "AdvancedModule.cs"
                                double csharp2cuda_temp_301;
#line 475 "AdvancedModule.cs"
                                if (((maximum) > (ratio)))
                                {
#line 475 "AdvancedModule.cs"
                                    csharp2cuda_temp_301 = maximum;
                                }
                                else
                                {
#line 475 "AdvancedModule.cs"
                                    csharp2cuda_temp_301 = ratio;
                                }
                                (*(csharp2cuda_temp_300) = csharp2cuda_temp_301);
                            }
#line 466 "AdvancedModule.cs"
                            int* csharp2cuda_temp_290 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_290));
                        }
                    }
#line 477 "AdvancedModule.cs"
#line 477 "AdvancedModule.cs"
                    double* csharp2cuda_temp_302 = &((output)->scalar_value);
#line 477 "AdvancedModule.cs"
                    double csharp2cuda_temp_303 = __ddiv_rn(maximum, minimum);
                    (*(csharp2cuda_temp_302) = mathblocks_natural_logarithm(csharp2cuda_temp_303));
#line 478 "AdvancedModule.cs"
                    break;
                }
#line 480 "AdvancedModule.cs"
            case 13:
            case 16:
#line 482 "AdvancedModule.cs"
#line 482 "AdvancedModule.cs"
                int csharp2cuda_temp_304 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_304);
#line 483 "AdvancedModule.cs"
#line 483 "AdvancedModule.cs"
                int csharp2cuda_temp_305 = (first)->count;
#line 483 "AdvancedModule.cs"
                bool csharp2cuda_temp_306;
#line 483 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_305) <= (0))))
                {
#line 483 "AdvancedModule.cs"
                    csharp2cuda_temp_306 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 483 "AdvancedModule.cs"
                    csharp2cuda_temp_306 = true;
                }
                if (csharp2cuda_temp_306)
#line 484 "AdvancedModule.cs"
                {
#line 485 "AdvancedModule.cs"
#line 485 "AdvancedModule.cs"
                    int* csharp2cuda_temp_307 = &((output)->valid);
                    (*(csharp2cuda_temp_307) = 0);
#line 486 "AdvancedModule.cs"
                    break;
                }
#line 488 "AdvancedModule.cs"
                {
#line 489 "AdvancedModule.cs"
                    int* hull = ((int*)(scratch));
#line 490 "AdvancedModule.cs"
                    int hull_count = 0;
#line 491 "AdvancedModule.cs"
                    bool concave = ((opcode) == (16));
#line 492 "AdvancedModule.cs"
                    {
#line 492 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 492 "AdvancedModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_309))))
                                break;
#line 493 "AdvancedModule.cs"
                            {
#line 494 "AdvancedModule.cs"
#line 494 "AdvancedModule.cs"
                                int* csharp2cuda_temp_310 = &(hull_count);
#line 494 "AdvancedModule.cs"
                                int csharp2cuda_temp_311 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_310));
#line 494 "AdvancedModule.cs"
                                int* csharp2cuda_temp_312 = &((hull)[csharp2cuda_temp_311]);
                                (*(csharp2cuda_temp_312) = index);
#line 495 "AdvancedModule.cs"
                                while (true)
                                {
                                    if (!(((hull_count) >= (3))))
                                        break;
#line 496 "AdvancedModule.cs"
                                    {
#line 497 "AdvancedModule.cs"
                                        int one = (hull)[csharp2cuda_i32_sub(hull_count, 3)];
#line 498 "AdvancedModule.cs"
                                        int middle = (hull)[csharp2cuda_i32_sub(hull_count, 2)];
#line 499 "AdvancedModule.cs"
                                        int last = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
#line 500 "AdvancedModule.cs"
                                        double csharp2cuda_temp_313 = (a)[middle];
#line 500 "AdvancedModule.cs"
                                        double csharp2cuda_temp_314 = (a)[one];
#line 500 "AdvancedModule.cs"
                                        double first_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_313, csharp2cuda_temp_314), ((double)(csharp2cuda_i32_sub(middle, one))));
#line 501 "AdvancedModule.cs"
                                        double csharp2cuda_temp_315 = (a)[last];
#line 501 "AdvancedModule.cs"
                                        double csharp2cuda_temp_316 = (a)[middle];
#line 501 "AdvancedModule.cs"
                                        double second_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_315, csharp2cuda_temp_316), ((double)(csharp2cuda_i32_sub(last, middle))));
#line 502 "AdvancedModule.cs"
#line 502 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_317;
#line 502 "AdvancedModule.cs"
                                        if (concave)
                                        {
#line 502 "AdvancedModule.cs"
                                            csharp2cuda_temp_317 = ((first_slope) >= (second_slope));
                                        }
                                        else
                                        {
#line 502 "AdvancedModule.cs"
                                            csharp2cuda_temp_317 = ((first_slope) <= (second_slope));
                                        }
                                        if (csharp2cuda_temp_317)
                                        {
#line 503 "AdvancedModule.cs"
                                            break;
                                        }
#line 504 "AdvancedModule.cs"
#line 504 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_318 = &((hull)[csharp2cuda_i32_sub(hull_count, 2)]);
#line 504 "AdvancedModule.cs"
                                        int csharp2cuda_temp_319 = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
                                        (*(csharp2cuda_temp_318) = csharp2cuda_temp_319);
#line 505 "AdvancedModule.cs"
#line 505 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_320 = &(hull_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_320));
                                    }
                                }
                            }
#line 492 "AdvancedModule.cs"
                            int* csharp2cuda_temp_308 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
#line 508 "AdvancedModule.cs"
                    {
#line 508 "AdvancedModule.cs"
                        int segment = 1;
                        while (true)
                        {
                            if (!(((segment) < (hull_count))))
                                break;
#line 509 "AdvancedModule.cs"
                            {
#line 510 "AdvancedModule.cs"
                                int start = (hull)[csharp2cuda_i32_sub(segment, 1)];
#line 511 "AdvancedModule.cs"
                                int end = (hull)[segment];
#line 512 "AdvancedModule.cs"
                                {
#line 512 "AdvancedModule.cs"
                                    int index = start;
                                    while (true)
                                    {
                                        if (!(((index) <= (end))))
                                            break;
#line 513 "AdvancedModule.cs"
                                        {
#line 514 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(((double)(csharp2cuda_i32_sub(index, start))), ((double)(csharp2cuda_i32_sub(end, start))));
#line 515 "AdvancedModule.cs"
#line 515 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_323 = &((result)[index]);
#line 515 "AdvancedModule.cs"
                                            double csharp2cuda_temp_324 = (a)[start];
#line 515 "AdvancedModule.cs"
                                            double csharp2cuda_temp_325 = (a)[end];
                                            (*(csharp2cuda_temp_323) = __dadd_rn(__dmul_rn(csharp2cuda_temp_324, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_325, weight)));
                                        }
#line 512 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_322 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_322));
                                    }
                                }
                            }
#line 508 "AdvancedModule.cs"
                            int* csharp2cuda_temp_321 = &(segment);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_321));
                        }
                    }
#line 518 "AdvancedModule.cs"
                    break;
                }
#line 520 "AdvancedModule.cs"
            case 14:
#line 521 "AdvancedModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 522 "AdvancedModule.cs"
                {
#line 523 "AdvancedModule.cs"
#line 523 "AdvancedModule.cs"
                    int* csharp2cuda_temp_326 = &((output)->valid);
                    (*(csharp2cuda_temp_326) = 0);
#line 524 "AdvancedModule.cs"
                    break;
                }
#line 526 "AdvancedModule.cs"
                {
#line 526 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 526 "AdvancedModule.cs"
                        int csharp2cuda_temp_328 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_328))))
                            break;
#line 527 "AdvancedModule.cs"
#line 527 "AdvancedModule.cs"
                        double* csharp2cuda_temp_329 = &((scratch)[index]);
#line 527 "AdvancedModule.cs"
                        double csharp2cuda_temp_330 = (a)[index];
                        (*(csharp2cuda_temp_329) = csharp2cuda_temp_330);
#line 526 "AdvancedModule.cs"
                        int* csharp2cuda_temp_327 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_327));
                    }
                }
#line 528 "AdvancedModule.cs"
#line 528 "AdvancedModule.cs"
                int* csharp2cuda_temp_331 = &((output)->boolean_value);
                (*(csharp2cuda_temp_331) = 1);
#line 529 "AdvancedModule.cs"
                {
#line 529 "AdvancedModule.cs"
                    int order = 0;
#line 529 "AdvancedModule.cs"
                    int length = (first)->count;
                    while (true)
                    {
#line 530 "AdvancedModule.cs"
                        int csharp2cuda_temp_334 = (first)->count;
#line 530 "AdvancedModule.cs"
                        bool csharp2cuda_temp_335;
#line 530 "AdvancedModule.cs"
                        if (((order) < (csharp2cuda_temp_334)))
                        {
#line 530 "AdvancedModule.cs"
                            csharp2cuda_temp_335 = (output)->boolean_value;
                        }
                        else
                        {
#line 530 "AdvancedModule.cs"
                            csharp2cuda_temp_335 = false;
                        }
                        if (!(csharp2cuda_temp_335))
                            break;
#line 532 "AdvancedModule.cs"
                        {
#line 533 "AdvancedModule.cs"
                            double csharp2cuda_temp_336;
#line 533 "AdvancedModule.cs"
                            if (((csharp2cuda_i32_and(order, 1)) == (0)))
                            {
#line 533 "AdvancedModule.cs"
                                csharp2cuda_temp_336 = 1.0;
                            }
                            else
                            {
#line 533 "AdvancedModule.cs"
                                csharp2cuda_temp_336 = (-(1.0));
                            }
#line 533 "AdvancedModule.cs"
                            double sign = csharp2cuda_temp_336;
#line 534 "AdvancedModule.cs"
                            {
#line 534 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 535 "AdvancedModule.cs"
#line 535 "AdvancedModule.cs"
                                    double csharp2cuda_temp_338 = (scratch)[index];
                                    if (((__dmul_rn(sign, csharp2cuda_temp_338)) < (0.0)))
#line 536 "AdvancedModule.cs"
                                    {
#line 537 "AdvancedModule.cs"
#line 537 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_339 = &((output)->boolean_value);
                                        (*(csharp2cuda_temp_339) = 0);
#line 538 "AdvancedModule.cs"
                                        break;
                                    }
#line 534 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_337 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_337));
                                }
                            }
#line 540 "AdvancedModule.cs"
                            {
#line 540 "AdvancedModule.cs"
                                int index = 1;
                                while (true)
                                {
#line 540 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_341 = (output)->boolean_value;
#line 540 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_342;
#line 540 "AdvancedModule.cs"
                                    if (csharp2cuda_temp_341)
                                    {
#line 540 "AdvancedModule.cs"
                                        csharp2cuda_temp_342 = ((index) < (length));
                                    }
                                    else
                                    {
#line 540 "AdvancedModule.cs"
                                        csharp2cuda_temp_342 = false;
                                    }
                                    if (!(csharp2cuda_temp_342))
                                        break;
#line 541 "AdvancedModule.cs"
#line 541 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_343 = &((scratch)[csharp2cuda_i32_sub(index, 1)]);
#line 541 "AdvancedModule.cs"
                                    double csharp2cuda_temp_344 = (scratch)[index];
#line 541 "AdvancedModule.cs"
                                    double csharp2cuda_temp_345 = (scratch)[csharp2cuda_i32_sub(index, 1)];
                                    (*(csharp2cuda_temp_343) = __dsub_rn(csharp2cuda_temp_344, csharp2cuda_temp_345));
#line 540 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_340 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                                }
                            }
                        }
#line 531 "AdvancedModule.cs"
                        int* csharp2cuda_temp_332 = &(order);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_332));
#line 531 "AdvancedModule.cs"
                        int* csharp2cuda_temp_333 = &(length);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_333));
                    }
                }
#line 543 "AdvancedModule.cs"
                break;
#line 544 "AdvancedModule.cs"
            case 15:
#line 545 "AdvancedModule.cs"
#line 545 "AdvancedModule.cs"
                int* csharp2cuda_temp_346 = &((output)->boolean_value);
                (*(csharp2cuda_temp_346) = 1);
#line 546 "AdvancedModule.cs"
                {
#line 546 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 546 "AdvancedModule.cs"
                        int csharp2cuda_temp_348 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_348))))
                            break;
#line 547 "AdvancedModule.cs"
#line 547 "AdvancedModule.cs"
                        double csharp2cuda_temp_349 = (a)[index];
                        if (((csharp2cuda_temp_349) < (0.0)))
                        {
#line 547 "AdvancedModule.cs"
#line 547 "AdvancedModule.cs"
                            int* csharp2cuda_temp_350 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_350) = 0);
                        }
#line 546 "AdvancedModule.cs"
                        int* csharp2cuda_temp_347 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_347));
                    }
                }
#line 548 "AdvancedModule.cs"
                {
#line 548 "AdvancedModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 548 "AdvancedModule.cs"
                        bool csharp2cuda_temp_352 = (output)->boolean_value;
#line 548 "AdvancedModule.cs"
                        bool csharp2cuda_temp_353;
#line 548 "AdvancedModule.cs"
                        if (csharp2cuda_temp_352)
                        {
#line 548 "AdvancedModule.cs"
                            int csharp2cuda_temp_354 = (first)->count;
#line 548 "AdvancedModule.cs"
                            csharp2cuda_temp_353 = ((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_354, 1)));
                        }
                        else
                        {
#line 548 "AdvancedModule.cs"
                            csharp2cuda_temp_353 = false;
                        }
                        if (!(csharp2cuda_temp_353))
                            break;
#line 549 "AdvancedModule.cs"
#line 549 "AdvancedModule.cs"
                        double csharp2cuda_temp_355 = (a)[index];
#line 549 "AdvancedModule.cs"
                        double csharp2cuda_temp_356 = (a)[index];
#line 549 "AdvancedModule.cs"
                        double csharp2cuda_temp_357 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 549 "AdvancedModule.cs"
                        double csharp2cuda_temp_358 = (a)[csharp2cuda_i32_add(index, 1)];
                        if (((__dmul_rn(csharp2cuda_temp_355, csharp2cuda_temp_356)) < (__dmul_rn(csharp2cuda_temp_357, csharp2cuda_temp_358))))
                        {
#line 550 "AdvancedModule.cs"
#line 550 "AdvancedModule.cs"
                            int* csharp2cuda_temp_359 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_359) = 0);
                        }
#line 548 "AdvancedModule.cs"
                        int* csharp2cuda_temp_351 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_351));
                    }
                }
#line 551 "AdvancedModule.cs"
                break;
#line 552 "AdvancedModule.cs"
            case 17:
#line 553 "AdvancedModule.cs"
#line 553 "AdvancedModule.cs"
                int csharp2cuda_temp_360 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_360);
#line 554 "AdvancedModule.cs"
#line 554 "AdvancedModule.cs"
                int csharp2cuda_temp_361 = (first)->count;
#line 554 "AdvancedModule.cs"
                bool csharp2cuda_temp_362 = mathblocks_advanced_distribution(a, csharp2cuda_temp_361);
                if ((!(csharp2cuda_temp_362)))
#line 555 "AdvancedModule.cs"
                {
#line 556 "AdvancedModule.cs"
#line 556 "AdvancedModule.cs"
                    int* csharp2cuda_temp_363 = &((output)->valid);
                    (*(csharp2cuda_temp_363) = 0);
#line 557 "AdvancedModule.cs"
                    break;
                }
#line 559 "AdvancedModule.cs"
                {
#line 560 "AdvancedModule.cs"
                    double survival = 1.0;
#line 561 "AdvancedModule.cs"
                    {
#line 561 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 561 "AdvancedModule.cs"
                            int csharp2cuda_temp_365 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_365))))
                                break;
#line 562 "AdvancedModule.cs"
                            {
#line 563 "AdvancedModule.cs"
#line 563 "AdvancedModule.cs"
                                double* csharp2cuda_temp_366 = &((result)[index]);
#line 563 "AdvancedModule.cs"
                                double csharp2cuda_temp_367 = (a)[index];
#line 563 "AdvancedModule.cs"
                                double csharp2cuda_temp_368 = __ddiv_rn(csharp2cuda_temp_367, survival);
                                (*(csharp2cuda_temp_366) = csharp2cuda_temp_368);
#line 564 "AdvancedModule.cs"
#line 564 "AdvancedModule.cs"
                                double* csharp2cuda_temp_369 = &(survival);
#line 564 "AdvancedModule.cs"
                                double csharp2cuda_temp_370 = *(csharp2cuda_temp_369);
#line 564 "AdvancedModule.cs"
                                double csharp2cuda_temp_371 = (a)[index];
                                (*(csharp2cuda_temp_369) = __dsub_rn(csharp2cuda_temp_370, csharp2cuda_temp_371));
                            }
#line 561 "AdvancedModule.cs"
                            int* csharp2cuda_temp_364 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_364));
                        }
                    }
#line 566 "AdvancedModule.cs"
                    break;
                }
#line 568 "AdvancedModule.cs"
            case 18:
#line 569 "AdvancedModule.cs"
#line 569 "AdvancedModule.cs"
                int csharp2cuda_temp_372 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_372);
#line 570 "AdvancedModule.cs"
#line 570 "AdvancedModule.cs"
                int csharp2cuda_temp_373 = (first)->count;
#line 570 "AdvancedModule.cs"
                int csharp2cuda_temp_374 = (second)->count;
                if (((csharp2cuda_temp_373) != (csharp2cuda_temp_374)))
#line 571 "AdvancedModule.cs"
                {
#line 572 "AdvancedModule.cs"
#line 572 "AdvancedModule.cs"
                    int* csharp2cuda_temp_375 = &((output)->valid);
                    (*(csharp2cuda_temp_375) = 0);
#line 573 "AdvancedModule.cs"
                    break;
                }
#line 575 "AdvancedModule.cs"
                {
#line 576 "AdvancedModule.cs"
                    double survival = 1.0;
#line 577 "AdvancedModule.cs"
                    {
#line 577 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 577 "AdvancedModule.cs"
                            int csharp2cuda_temp_377 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_377))))
                                break;
#line 578 "AdvancedModule.cs"
                            {
#line 579 "AdvancedModule.cs"
#line 579 "AdvancedModule.cs"
                                double csharp2cuda_temp_378 = (a)[index];
#line 579 "AdvancedModule.cs"
                                bool csharp2cuda_temp_379;
#line 579 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_378) < (0.0))))
                                {
#line 579 "AdvancedModule.cs"
                                    double csharp2cuda_temp_380 = (b)[index];
#line 579 "AdvancedModule.cs"
                                    csharp2cuda_temp_379 = ((csharp2cuda_temp_380) <= (0.0));
                                }
                                else
                                {
#line 579 "AdvancedModule.cs"
                                    csharp2cuda_temp_379 = true;
                                }
#line 579 "AdvancedModule.cs"
                                bool csharp2cuda_temp_381;
#line 579 "AdvancedModule.cs"
                                if (!(csharp2cuda_temp_379))
                                {
#line 579 "AdvancedModule.cs"
                                    double csharp2cuda_temp_382 = (a)[index];
#line 579 "AdvancedModule.cs"
                                    double csharp2cuda_temp_383 = (b)[index];
#line 579 "AdvancedModule.cs"
                                    csharp2cuda_temp_381 = ((csharp2cuda_temp_382) > (csharp2cuda_temp_383));
                                }
                                else
                                {
#line 579 "AdvancedModule.cs"
                                    csharp2cuda_temp_381 = true;
                                }
                                if (csharp2cuda_temp_381)
#line 580 "AdvancedModule.cs"
                                {
#line 581 "AdvancedModule.cs"
#line 581 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_384 = &((output)->valid);
                                    (*(csharp2cuda_temp_384) = 0);
#line 582 "AdvancedModule.cs"
                                    break;
                                }
#line 584 "AdvancedModule.cs"
#line 584 "AdvancedModule.cs"
                                double* csharp2cuda_temp_385 = &(survival);
#line 584 "AdvancedModule.cs"
                                double csharp2cuda_temp_386 = *(csharp2cuda_temp_385);
#line 584 "AdvancedModule.cs"
                                double csharp2cuda_temp_387 = (a)[index];
#line 584 "AdvancedModule.cs"
                                double csharp2cuda_temp_388 = (b)[index];
#line 584 "AdvancedModule.cs"
                                double csharp2cuda_temp_389 = __ddiv_rn(csharp2cuda_temp_387, csharp2cuda_temp_388);
                                (*(csharp2cuda_temp_385) = __dmul_rn(csharp2cuda_temp_386, __dsub_rn(1.0, csharp2cuda_temp_389)));
#line 585 "AdvancedModule.cs"
#line 585 "AdvancedModule.cs"
                                double* csharp2cuda_temp_390 = &((result)[index]);
                                (*(csharp2cuda_temp_390) = survival);
                            }
#line 577 "AdvancedModule.cs"
                            int* csharp2cuda_temp_376 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
                        }
                    }
#line 587 "AdvancedModule.cs"
                    break;
                }
        }
#line 591 "AdvancedModule.cs"
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_391 = (output)->valid;
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_392;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_391)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_392 = ((opcode) != (1));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_392 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_393;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_392)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_393 = ((opcode) != (2));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_393 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_394;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_393)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_394 = ((opcode) != (3));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_394 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_395;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_394)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_395 = ((opcode) != (4));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_395 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_396;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_395)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_396 = ((opcode) != (5));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_396 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_397;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_396)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_397 = ((opcode) != (7));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_397 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_398;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_397)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_398 = ((opcode) != (9));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_398 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_399;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_398)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_399 = ((opcode) != (10));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_399 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_400;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_399)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_400 = ((opcode) != (11));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_400 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_401;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_400)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_401 = ((opcode) != (13));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_401 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_402;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_401)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_402 = ((opcode) != (14));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_402 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_403;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_402)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_403 = ((opcode) != (15));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_403 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_404;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_403)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_404 = ((opcode) != (16));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_404 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_405;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_404)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_405 = ((opcode) != (17));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_405 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_406;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_405)
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_406 = ((opcode) != (18));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_406 = false;
        }
#line 591 "AdvancedModule.cs"
        bool csharp2cuda_temp_407;
#line 591 "AdvancedModule.cs"
        if (csharp2cuda_temp_406)
        {
#line 595 "AdvancedModule.cs"
            double csharp2cuda_temp_408 = (output)->scalar_value;
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_407 = (!(isfinite(csharp2cuda_temp_408)));
        }
        else
        {
#line 591 "AdvancedModule.cs"
            csharp2cuda_temp_407 = false;
        }
        if (csharp2cuda_temp_407)
#line 596 "AdvancedModule.cs"
        {
#line 597 "AdvancedModule.cs"
#line 597 "AdvancedModule.cs"
            int* csharp2cuda_temp_409 = &((output)->valid);
            (*(csharp2cuda_temp_409) = 0);
        }
#line 599 "AdvancedModule.cs"
#line 599 "AdvancedModule.cs"
        bool csharp2cuda_temp_410 = (output)->valid;
#line 599 "AdvancedModule.cs"
        bool csharp2cuda_temp_411;
#line 599 "AdvancedModule.cs"
        if (csharp2cuda_temp_410)
        {
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_412;
#line 600 "AdvancedModule.cs"
            if (!(((opcode) == (2))))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_412 = ((opcode) == (3));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_412 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_413;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_412))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_413 = ((opcode) == (4));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_413 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_414;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_413))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_414 = ((opcode) == (5));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_414 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_415;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_414))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_415 = ((opcode) == (7));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_415 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_416;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_415))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_416 = ((opcode) == (9));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_416 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_417;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_416))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_417 = ((opcode) == (10));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_417 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_418;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_417))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_418 = ((opcode) == (13));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_418 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_419;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_418))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_419 = ((opcode) == (16));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_419 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_420;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_419))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_420 = ((opcode) == (17));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_420 = true;
            }
#line 600 "AdvancedModule.cs"
            bool csharp2cuda_temp_421;
#line 600 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_420))
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_421 = ((opcode) == (18));
            }
            else
            {
#line 600 "AdvancedModule.cs"
                csharp2cuda_temp_421 = true;
            }
#line 599 "AdvancedModule.cs"
            csharp2cuda_temp_411 = csharp2cuda_temp_421;
        }
        else
        {
#line 599 "AdvancedModule.cs"
            csharp2cuda_temp_411 = false;
        }
        if (csharp2cuda_temp_411)
#line 603 "AdvancedModule.cs"
        {
#line 604 "AdvancedModule.cs"
            {
#line 604 "AdvancedModule.cs"
                int index = 0;
                while (true)
                {
#line 604 "AdvancedModule.cs"
                    int csharp2cuda_temp_423 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_423))))
                        break;
#line 605 "AdvancedModule.cs"
#line 605 "AdvancedModule.cs"
                    double csharp2cuda_temp_424 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_424))))
                    {
#line 605 "AdvancedModule.cs"
#line 605 "AdvancedModule.cs"
                        int* csharp2cuda_temp_425 = &((output)->valid);
                        (*(csharp2cuda_temp_425) = 0);
                    }
#line 604 "AdvancedModule.cs"
                    int* csharp2cuda_temp_422 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_422));
                }
            }
        }
    }
}

#line 97 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count)
#line 99 "AdvancedModule.cs"
{
#line 100 "AdvancedModule.cs"
    return mathblocks_probability_distribution(values, count);
}

#line 88 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value)
#line 90 "AdvancedModule.cs"
{
#line 91 "AdvancedModule.cs"
    double result = 1.0;
#line 92 "AdvancedModule.cs"
    {
#line 92 "AdvancedModule.cs"
        int index = 2;
        while (true)
        {
            if (!(((index) <= (value))))
                break;
#line 93 "AdvancedModule.cs"
#line 93 "AdvancedModule.cs"
            double* csharp2cuda_temp_1 = &(result);
#line 93 "AdvancedModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
            (*(csharp2cuda_temp_1) = __dmul_rn(csharp2cuda_temp_2, ((double)(index))));
#line 92 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 94 "AdvancedModule.cs"
    return result;
}

#line 64 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value)
#line 66 "AdvancedModule.cs"
{
#line 67 "AdvancedModule.cs"
    int result = 0;
#line 68 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) > (1))))
            break;
#line 69 "AdvancedModule.cs"
        {
#line 70 "AdvancedModule.cs"
#line 70 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(value);
#line 70 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_shr(csharp2cuda_temp_1, 1));
#line 71 "AdvancedModule.cs"
#line 71 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(result);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 73 "AdvancedModule.cs"
    return result;
}

#line 76 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value)
#line 78 "AdvancedModule.cs"
{
#line 79 "AdvancedModule.cs"
    int result = 0;
#line 80 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) != (0))))
            break;
#line 81 "AdvancedModule.cs"
        {
#line 82 "AdvancedModule.cs"
#line 82 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(result);
#line 82 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, csharp2cuda_i32_and(value, 1)));
#line 83 "AdvancedModule.cs"
#line 83 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(value);
#line 83 "AdvancedModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_shr(csharp2cuda_temp_3, 1));
        }
    }
#line 85 "AdvancedModule.cs"
    return result;
}

#line 58 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value)
#line 60 "AdvancedModule.cs"
{
#line 61 "AdvancedModule.cs"
#line 61 "AdvancedModule.cs"
    bool csharp2cuda_temp_0;
#line 61 "AdvancedModule.cs"
    if (((value) > (0)))
    {
#line 61 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 61 "AdvancedModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 103 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns)
#line 108 "AdvancedModule.cs"
{
#line 109 "AdvancedModule.cs"
    if (((rows) != (columns)))
    {
#line 110 "AdvancedModule.cs"
        return false;
    }
#line 111 "AdvancedModule.cs"
    {
#line 111 "AdvancedModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (rows))))
                break;
#line 112 "AdvancedModule.cs"
            {
#line 113 "AdvancedModule.cs"
                double sum = 0.0;
#line 114 "AdvancedModule.cs"
                {
#line 114 "AdvancedModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (columns))))
                            break;
#line 115 "AdvancedModule.cs"
                        {
#line 116 "AdvancedModule.cs"
                            double value = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 117 "AdvancedModule.cs"
                            if (((value) < (0.0)))
                            {
#line 118 "AdvancedModule.cs"
                                return false;
                            }
#line 119 "AdvancedModule.cs"
#line 119 "AdvancedModule.cs"
                            double* csharp2cuda_temp_2 = &(sum);
#line 119 "AdvancedModule.cs"
                            double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                            (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, value));
                        }
#line 114 "AdvancedModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 121 "AdvancedModule.cs"
                if (((fabs(__dsub_rn(sum, 1.0))) > (1E-10)))
                {
#line 122 "AdvancedModule.cs"
                    return false;
                }
            }
#line 111 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 124 "AdvancedModule.cs"
    return true;
}