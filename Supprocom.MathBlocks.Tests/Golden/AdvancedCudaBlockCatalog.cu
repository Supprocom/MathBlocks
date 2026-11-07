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

#line 121 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 85 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count);

#line 76 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value);

#line 52 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value);

#line 64 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value);

#line 46 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value);

#line 91 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns);

#line 121 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 127 "AdvancedModule.cs"
{
#line 128 "AdvancedModule.cs"
    int thread = threadIdx.x;
#line 129 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 129 "AdvancedModule.cs"
    if (((input_count) > (0)))
    {
#line 129 "AdvancedModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 129 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 129 "AdvancedModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 130 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 130 "AdvancedModule.cs"
    if (((input_count) > (1)))
    {
#line 130 "AdvancedModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 130 "AdvancedModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 130 "AdvancedModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 131 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 131 "AdvancedModule.cs"
    if (((input_count) > (2)))
    {
#line 131 "AdvancedModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 131 "AdvancedModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 131 "AdvancedModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 132 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 132 "AdvancedModule.cs"
    if (((input_count) > (3)))
    {
#line 132 "AdvancedModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 132 "AdvancedModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 132 "AdvancedModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 133 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 134 "AdvancedModule.cs"
    {
#line 135 "AdvancedModule.cs"
#line 135 "AdvancedModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 136 "AdvancedModule.cs"
#line 136 "AdvancedModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 137 "AdvancedModule.cs"
#line 137 "AdvancedModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 138 "AdvancedModule.cs"
#line 138 "AdvancedModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 139 "AdvancedModule.cs"
#line 139 "AdvancedModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 140 "AdvancedModule.cs"
#line 140 "AdvancedModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 141 "AdvancedModule.cs"
        {
#line 141 "AdvancedModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 142 "AdvancedModule.cs"
#line 142 "AdvancedModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 142 "AdvancedModule.cs"
                bool csharp2cuda_temp_12;
#line 142 "AdvancedModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 142 "AdvancedModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 142 "AdvancedModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 142 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 142 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 142 "AdvancedModule.cs"
#line 142 "AdvancedModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 141 "AdvancedModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 144 "AdvancedModule.cs"
    __syncthreads();
#line 145 "AdvancedModule.cs"
#line 145 "AdvancedModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 146 "AdvancedModule.cs"
        return;
    }
#line 148 "AdvancedModule.cs"
    double* csharp2cuda_temp_17;
#line 148 "AdvancedModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 148 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 148 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 148 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 148 "AdvancedModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 149 "AdvancedModule.cs"
    double* csharp2cuda_temp_19;
#line 149 "AdvancedModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 149 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 149 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 149 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 149 "AdvancedModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 150 "AdvancedModule.cs"
    double* csharp2cuda_temp_21;
#line 150 "AdvancedModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 150 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 150 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 150 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 150 "AdvancedModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 151 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 151 "AdvancedModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 152 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 152 "AdvancedModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 159 "AdvancedModule.cs"
#line 159 "AdvancedModule.cs"
    bool csharp2cuda_temp_25;
#line 159 "AdvancedModule.cs"
    if (!(((opcode) == (4))))
    {
#line 159 "AdvancedModule.cs"
        csharp2cuda_temp_25 = ((opcode) == (5));
    }
    else
    {
#line 159 "AdvancedModule.cs"
        csharp2cuda_temp_25 = true;
    }
    if (csharp2cuda_temp_25)
#line 160 "AdvancedModule.cs"
    {
#line 161 "AdvancedModule.cs"
        int csharp2cuda_temp_26 = (first)->count;
#line 161 "AdvancedModule.cs"
        bool csharp2cuda_temp_27;
#line 161 "AdvancedModule.cs"
        if (!(((csharp2cuda_temp_26) <= (0))))
        {
#line 161 "AdvancedModule.cs"
            int csharp2cuda_temp_28 = (first)->count;
#line 161 "AdvancedModule.cs"
            int csharp2cuda_temp_29 = (second)->count;
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_27 = ((csharp2cuda_temp_28) != (csharp2cuda_temp_29));
        }
        else
        {
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_27 = true;
        }
#line 161 "AdvancedModule.cs"
        bool csharp2cuda_temp_30;
#line 161 "AdvancedModule.cs"
        if (!(csharp2cuda_temp_27))
        {
#line 161 "AdvancedModule.cs"
            double csharp2cuda_temp_31 = (fourth)->scalar_value;
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_30 = ((csharp2cuda_temp_31) < (0.0));
        }
        else
        {
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_30 = true;
        }
#line 161 "AdvancedModule.cs"
        bool lipschitz_invalid = csharp2cuda_temp_30;
#line 162 "AdvancedModule.cs"
        if ((!(lipschitz_invalid)))
#line 163 "AdvancedModule.cs"
        {
#line 164 "AdvancedModule.cs"
            {
#line 164 "AdvancedModule.cs"
                int query = thread;
                while (true)
                {
#line 164 "AdvancedModule.cs"
                    int csharp2cuda_temp_34 = (third)->count;
                    if (!(((query) < (csharp2cuda_temp_34))))
                        break;
#line 165 "AdvancedModule.cs"
                    {
#line 166 "AdvancedModule.cs"
                        double csharp2cuda_temp_35;
#line 166 "AdvancedModule.cs"
                        if (((opcode) == (4)))
                        {
#line 166 "AdvancedModule.cs"
                            csharp2cuda_temp_35 = mathblocks_positive_infinity();
                        }
                        else
                        {
#line 166 "AdvancedModule.cs"
                            csharp2cuda_temp_35 = (-(mathblocks_positive_infinity()));
                        }
#line 166 "AdvancedModule.cs"
                        double selected = csharp2cuda_temp_35;
#line 169 "AdvancedModule.cs"
                        {
#line 169 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 169 "AdvancedModule.cs"
                                int csharp2cuda_temp_37 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_37))))
                                    break;
#line 170 "AdvancedModule.cs"
                                {
#line 171 "AdvancedModule.cs"
                                    double csharp2cuda_temp_38;
#line 171 "AdvancedModule.cs"
                                    if (((opcode) == (4)))
                                    {
#line 172 "AdvancedModule.cs"
                                        double csharp2cuda_temp_39 = (b)[index];
#line 172 "AdvancedModule.cs"
                                        double csharp2cuda_temp_40 = (fourth)->scalar_value;
#line 172 "AdvancedModule.cs"
                                        double csharp2cuda_temp_41 = (c)[query];
#line 172 "AdvancedModule.cs"
                                        double csharp2cuda_temp_42 = (a)[index];
#line 171 "AdvancedModule.cs"
                                        csharp2cuda_temp_38 = __dadd_rn(csharp2cuda_temp_39, __dmul_rn(csharp2cuda_temp_40, fabs(__dsub_rn(csharp2cuda_temp_41, csharp2cuda_temp_42))));
                                    }
                                    else
                                    {
#line 173 "AdvancedModule.cs"
                                        double csharp2cuda_temp_43 = (b)[index];
#line 173 "AdvancedModule.cs"
                                        double csharp2cuda_temp_44 = (fourth)->scalar_value;
#line 173 "AdvancedModule.cs"
                                        double csharp2cuda_temp_45 = (c)[query];
#line 173 "AdvancedModule.cs"
                                        double csharp2cuda_temp_46 = (a)[index];
#line 171 "AdvancedModule.cs"
                                        csharp2cuda_temp_38 = __dsub_rn(csharp2cuda_temp_43, __dmul_rn(csharp2cuda_temp_44, fabs(__dsub_rn(csharp2cuda_temp_45, csharp2cuda_temp_46))));
                                    }
#line 171 "AdvancedModule.cs"
                                    double candidate = csharp2cuda_temp_38;
#line 176 "AdvancedModule.cs"
#line 176 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_47 = &(selected);
#line 176 "AdvancedModule.cs"
                                    double csharp2cuda_temp_48;
#line 176 "AdvancedModule.cs"
                                    if (((opcode) == (4)))
                                    {
#line 176 "AdvancedModule.cs"
                                        csharp2cuda_temp_48 = mathblocks_minimum(selected, candidate);
                                    }
                                    else
                                    {
#line 176 "AdvancedModule.cs"
                                        csharp2cuda_temp_48 = mathblocks_maximum(selected, candidate);
                                    }
                                    (*(csharp2cuda_temp_47) = csharp2cuda_temp_48);
                                }
#line 169 "AdvancedModule.cs"
                                int* csharp2cuda_temp_36 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_36));
                            }
                        }
#line 180 "AdvancedModule.cs"
#line 180 "AdvancedModule.cs"
                        double* csharp2cuda_temp_49 = &((result)[query]);
                        (*(csharp2cuda_temp_49) = selected);
                    }
#line 164 "AdvancedModule.cs"
                    int* csharp2cuda_temp_32 = &(query);
#line 164 "AdvancedModule.cs"
                    int csharp2cuda_temp_33 = *(csharp2cuda_temp_32);
                    (*(csharp2cuda_temp_32) = csharp2cuda_i32_add(csharp2cuda_temp_33, blockDim.x));
                }
            }
        }
#line 183 "AdvancedModule.cs"
        __syncthreads();
    }
#line 186 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 187 "AdvancedModule.cs"
    {
#line 188 "AdvancedModule.cs"
        switch (opcode)
        {
#line 190 "AdvancedModule.cs"
            case 0:
#line 191 "AdvancedModule.cs"
#line 191 "AdvancedModule.cs"
                int csharp2cuda_temp_50 = (first)->count;
#line 191 "AdvancedModule.cs"
                bool csharp2cuda_temp_51;
#line 191 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_50) <= (0))))
                {
#line 191 "AdvancedModule.cs"
                    int csharp2cuda_temp_52 = (first)->count;
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_51 = ((csharp2cuda_temp_52) >= (31));
                }
                else
                {
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_51 = true;
                }
#line 191 "AdvancedModule.cs"
                bool csharp2cuda_temp_53;
#line 191 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_51))
                {
#line 192 "AdvancedModule.cs"
                    int csharp2cuda_temp_54 = (second)->count;
#line 192 "AdvancedModule.cs"
                    int csharp2cuda_temp_55 = (first)->count;
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_53 = ((csharp2cuda_temp_54) != (csharp2cuda_i32_shl(1, csharp2cuda_temp_55)));
                }
                else
                {
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_53 = true;
                }
#line 191 "AdvancedModule.cs"
                bool csharp2cuda_temp_56;
#line 191 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_53))
                {
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_56 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 191 "AdvancedModule.cs"
                    csharp2cuda_temp_56 = true;
                }
                if (csharp2cuda_temp_56)
#line 193 "AdvancedModule.cs"
                {
#line 194 "AdvancedModule.cs"
#line 194 "AdvancedModule.cs"
                    int* csharp2cuda_temp_57 = &((output)->valid);
                    (*(csharp2cuda_temp_57) = 0);
#line 195 "AdvancedModule.cs"
                    break;
                }
#line 197 "AdvancedModule.cs"
                {
#line 197 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 197 "AdvancedModule.cs"
                        int csharp2cuda_temp_59 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_59))))
                            break;
#line 198 "AdvancedModule.cs"
                        {
#line 199 "AdvancedModule.cs"
#line 199 "AdvancedModule.cs"
                            double csharp2cuda_temp_60 = (a)[index];
                            if (((csharp2cuda_temp_60) < (0.0)))
#line 200 "AdvancedModule.cs"
                            {
#line 201 "AdvancedModule.cs"
#line 201 "AdvancedModule.cs"
                                int* csharp2cuda_temp_61 = &((output)->valid);
                                (*(csharp2cuda_temp_61) = 0);
#line 202 "AdvancedModule.cs"
                                break;
                            }
#line 204 "AdvancedModule.cs"
                            int position = index;
#line 205 "AdvancedModule.cs"
                            while (true)
                            {
#line 205 "AdvancedModule.cs"
                                bool csharp2cuda_temp_62;
#line 205 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 205 "AdvancedModule.cs"
                                    double csharp2cuda_temp_63 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 205 "AdvancedModule.cs"
                                    double csharp2cuda_temp_64 = (a)[csharp2cuda_f64_to_i32(csharp2cuda_temp_63)];
#line 205 "AdvancedModule.cs"
                                    double csharp2cuda_temp_65 = (a)[index];
#line 205 "AdvancedModule.cs"
                                    csharp2cuda_temp_62 = ((csharp2cuda_temp_64) > (csharp2cuda_temp_65));
                                }
                                else
                                {
#line 205 "AdvancedModule.cs"
                                    csharp2cuda_temp_62 = false;
                                }
                                if (!(csharp2cuda_temp_62))
                                    break;
#line 206 "AdvancedModule.cs"
                                {
#line 207 "AdvancedModule.cs"
#line 207 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_66 = &((scratch)[position]);
#line 207 "AdvancedModule.cs"
                                    double csharp2cuda_temp_67 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                                    (*(csharp2cuda_temp_66) = csharp2cuda_temp_67);
#line 208 "AdvancedModule.cs"
#line 208 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_68 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_68));
                                }
                            }
#line 210 "AdvancedModule.cs"
#line 210 "AdvancedModule.cs"
                            double* csharp2cuda_temp_69 = &((scratch)[position]);
                            (*(csharp2cuda_temp_69) = ((double)(index)));
                        }
#line 197 "AdvancedModule.cs"
                        int* csharp2cuda_temp_58 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_58));
                    }
                }
#line 212 "AdvancedModule.cs"
                if ((output)->valid)
#line 213 "AdvancedModule.cs"
                {
#line 214 "AdvancedModule.cs"
                    double total = 0.0;
#line 215 "AdvancedModule.cs"
                    double previous = 0.0;
#line 216 "AdvancedModule.cs"
                    {
#line 216 "AdvancedModule.cs"
                        int position = 0;
                        while (true)
                        {
#line 216 "AdvancedModule.cs"
                            int csharp2cuda_temp_71 = (first)->count;
                            if (!(((position) < (csharp2cuda_temp_71))))
                                break;
#line 217 "AdvancedModule.cs"
                            {
#line 218 "AdvancedModule.cs"
                                int coalition = 0;
#line 219 "AdvancedModule.cs"
                                {
#line 219 "AdvancedModule.cs"
                                    int index = position;
                                    while (true)
                                    {
#line 219 "AdvancedModule.cs"
                                        int csharp2cuda_temp_73 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_73))))
                                            break;
#line 220 "AdvancedModule.cs"
#line 220 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_74 = &(coalition);
#line 220 "AdvancedModule.cs"
                                        int csharp2cuda_temp_75 = *(csharp2cuda_temp_74);
#line 220 "AdvancedModule.cs"
                                        double csharp2cuda_temp_76 = (scratch)[index];
                                        (*(csharp2cuda_temp_74) = csharp2cuda_i32_or(csharp2cuda_temp_75, csharp2cuda_i32_shl(1, csharp2cuda_f64_to_i32(csharp2cuda_temp_76))));
#line 219 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_72 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_72));
                                    }
                                }
#line 221 "AdvancedModule.cs"
                                double csharp2cuda_temp_77 = (scratch)[position];
#line 221 "AdvancedModule.cs"
                                int ordered = csharp2cuda_f64_to_i32(csharp2cuda_temp_77);
#line 222 "AdvancedModule.cs"
#line 222 "AdvancedModule.cs"
                                double* csharp2cuda_temp_78 = &(total);
#line 222 "AdvancedModule.cs"
                                double csharp2cuda_temp_79 = *(csharp2cuda_temp_78);
#line 222 "AdvancedModule.cs"
                                double csharp2cuda_temp_80 = (a)[ordered];
#line 222 "AdvancedModule.cs"
                                double csharp2cuda_temp_81 = (b)[coalition];
                                (*(csharp2cuda_temp_78) = __dadd_rn(csharp2cuda_temp_79, __dmul_rn(__dsub_rn(csharp2cuda_temp_80, previous), csharp2cuda_temp_81)));
#line 223 "AdvancedModule.cs"
#line 223 "AdvancedModule.cs"
                                double* csharp2cuda_temp_82 = &(previous);
#line 223 "AdvancedModule.cs"
                                double csharp2cuda_temp_83 = (a)[ordered];
                                (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
                            }
#line 216 "AdvancedModule.cs"
                            int* csharp2cuda_temp_70 = &(position);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_70));
                        }
                    }
#line 225 "AdvancedModule.cs"
#line 225 "AdvancedModule.cs"
                    double* csharp2cuda_temp_84 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_84) = total);
                }
#line 227 "AdvancedModule.cs"
                break;
#line 228 "AdvancedModule.cs"
            case 1:
#line 229 "AdvancedModule.cs"
#line 229 "AdvancedModule.cs"
                int csharp2cuda_temp_85 = (first)->count;
#line 229 "AdvancedModule.cs"
                bool csharp2cuda_temp_86;
#line 229 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_85)))))
                {
#line 229 "AdvancedModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 229 "AdvancedModule.cs"
                    csharp2cuda_temp_86 = ((csharp2cuda_temp_87) > (csharp2cuda_i32_shl(1, 12)));
                }
                else
                {
#line 229 "AdvancedModule.cs"
                    csharp2cuda_temp_86 = true;
                }
                if (csharp2cuda_temp_86)
#line 230 "AdvancedModule.cs"
                {
#line 231 "AdvancedModule.cs"
#line 231 "AdvancedModule.cs"
                    int* csharp2cuda_temp_88 = &((output)->valid);
                    (*(csharp2cuda_temp_88) = 0);
#line 232 "AdvancedModule.cs"
                    break;
                }
#line 234 "AdvancedModule.cs"
#line 234 "AdvancedModule.cs"
                int* csharp2cuda_temp_89 = &((output)->boolean_value);
                (*(csharp2cuda_temp_89) = 1);
#line 235 "AdvancedModule.cs"
                {
#line 235 "AdvancedModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 235 "AdvancedModule.cs"
                        int csharp2cuda_temp_91 = (first)->count;
#line 235 "AdvancedModule.cs"
                        bool csharp2cuda_temp_92;
#line 235 "AdvancedModule.cs"
                        if (((left) < (csharp2cuda_temp_91)))
                        {
#line 235 "AdvancedModule.cs"
                            csharp2cuda_temp_92 = (output)->boolean_value;
                        }
                        else
                        {
#line 235 "AdvancedModule.cs"
                            csharp2cuda_temp_92 = false;
                        }
                        if (!(csharp2cuda_temp_92))
                            break;
#line 236 "AdvancedModule.cs"
                        {
#line 236 "AdvancedModule.cs"
                            int right = 0;
                            while (true)
                            {
#line 236 "AdvancedModule.cs"
                                int csharp2cuda_temp_94 = (first)->count;
                                if (!(((right) < (csharp2cuda_temp_94))))
                                    break;
#line 237 "AdvancedModule.cs"
#line 237 "AdvancedModule.cs"
                                double csharp2cuda_temp_95 = (a)[left];
#line 237 "AdvancedModule.cs"
                                double csharp2cuda_temp_96 = (a)[right];
#line 237 "AdvancedModule.cs"
                                double csharp2cuda_temp_97 = (a)[csharp2cuda_i32_or(left, right)];
#line 237 "AdvancedModule.cs"
                                double csharp2cuda_temp_98 = (a)[csharp2cuda_i32_and(left, right)];
                                if (((__dadd_rn(csharp2cuda_temp_95, csharp2cuda_temp_96)) < (__dadd_rn(csharp2cuda_temp_97, csharp2cuda_temp_98))))
#line 238 "AdvancedModule.cs"
                                {
#line 239 "AdvancedModule.cs"
#line 239 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_99 = &((output)->boolean_value);
                                    (*(csharp2cuda_temp_99) = 0);
#line 240 "AdvancedModule.cs"
                                    break;
                                }
#line 236 "AdvancedModule.cs"
                                int* csharp2cuda_temp_93 = &(right);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_93));
                            }
                        }
#line 235 "AdvancedModule.cs"
                        int* csharp2cuda_temp_90 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_90));
                    }
                }
#line 242 "AdvancedModule.cs"
                break;
#line 243 "AdvancedModule.cs"
            case 2:
#line 244 "AdvancedModule.cs"
#line 244 "AdvancedModule.cs"
                int csharp2cuda_temp_100 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_100);
#line 245 "AdvancedModule.cs"
#line 245 "AdvancedModule.cs"
                int csharp2cuda_temp_101 = (first)->count;
                if ((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_101))))
#line 246 "AdvancedModule.cs"
                {
#line 247 "AdvancedModule.cs"
#line 247 "AdvancedModule.cs"
                    int* csharp2cuda_temp_102 = &((output)->valid);
                    (*(csharp2cuda_temp_102) = 0);
#line 248 "AdvancedModule.cs"
                    break;
                }
#line 250 "AdvancedModule.cs"
                {
#line 250 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 250 "AdvancedModule.cs"
                        int csharp2cuda_temp_104 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_104))))
                            break;
#line 251 "AdvancedModule.cs"
#line 251 "AdvancedModule.cs"
                        double* csharp2cuda_temp_105 = &((result)[index]);
#line 251 "AdvancedModule.cs"
                        double csharp2cuda_temp_106 = (a)[index];
                        (*(csharp2cuda_temp_105) = csharp2cuda_temp_106);
#line 250 "AdvancedModule.cs"
                        int* csharp2cuda_temp_103 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_103));
                    }
                }
#line 252 "AdvancedModule.cs"
                {
#line 252 "AdvancedModule.cs"
                    int bit = 0;
                    while (true)
                    {
#line 252 "AdvancedModule.cs"
                        int csharp2cuda_temp_108 = (first)->count;
                        if (!(((bit) < (mathblocks_advanced_log_two(csharp2cuda_temp_108)))))
                            break;
#line 253 "AdvancedModule.cs"
                        {
#line 253 "AdvancedModule.cs"
                            int mask = 0;
                            while (true)
                            {
#line 253 "AdvancedModule.cs"
                                int csharp2cuda_temp_110 = (first)->count;
                                if (!(((mask) < (csharp2cuda_temp_110))))
                                    break;
#line 254 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, bit))) != (0)))
                                {
#line 255 "AdvancedModule.cs"
#line 255 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_111 = &((result)[mask]);
#line 255 "AdvancedModule.cs"
                                    double csharp2cuda_temp_112 = *(csharp2cuda_temp_111);
#line 255 "AdvancedModule.cs"
                                    double csharp2cuda_temp_113 = (result)[csharp2cuda_i32_xor(mask, csharp2cuda_i32_shl(1, bit))];
                                    (*(csharp2cuda_temp_111) = __dsub_rn(csharp2cuda_temp_112, csharp2cuda_temp_113));
                                }
#line 253 "AdvancedModule.cs"
                                int* csharp2cuda_temp_109 = &(mask);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_109));
                            }
                        }
#line 252 "AdvancedModule.cs"
                        int* csharp2cuda_temp_107 = &(bit);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_107));
                    }
                }
#line 256 "AdvancedModule.cs"
                break;
#line 257 "AdvancedModule.cs"
            case 3:
#line 258 "AdvancedModule.cs"
#line 258 "AdvancedModule.cs"
                int csharp2cuda_temp_114 = (first)->count;
#line 258 "AdvancedModule.cs"
                bool csharp2cuda_temp_115;
#line 258 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_114)))))
                {
#line 258 "AdvancedModule.cs"
                    int csharp2cuda_temp_116 = (first)->count;
#line 258 "AdvancedModule.cs"
                    csharp2cuda_temp_115 = ((csharp2cuda_temp_116) > (csharp2cuda_i32_shl(1, 20)));
                }
                else
                {
#line 258 "AdvancedModule.cs"
                    csharp2cuda_temp_115 = true;
                }
                if (csharp2cuda_temp_115)
#line 259 "AdvancedModule.cs"
                {
#line 260 "AdvancedModule.cs"
#line 260 "AdvancedModule.cs"
                    int* csharp2cuda_temp_117 = &((output)->valid);
                    (*(csharp2cuda_temp_117) = 0);
#line 261 "AdvancedModule.cs"
                    break;
                }
#line 263 "AdvancedModule.cs"
                {
#line 264 "AdvancedModule.cs"
                    int csharp2cuda_temp_118 = (first)->count;
#line 264 "AdvancedModule.cs"
                    int player_count = mathblocks_advanced_log_two(csharp2cuda_temp_118);
#line 265 "AdvancedModule.cs"
                    mathblocks_sequence_set_vector_shape(output, player_count);
#line 266 "AdvancedModule.cs"
                    double denominator = mathblocks_advanced_factorial(player_count);
#line 267 "AdvancedModule.cs"
                    {
#line 267 "AdvancedModule.cs"
                        int player = 0;
                        while (true)
                        {
                            if (!(((player) < (player_count))))
                                break;
#line 268 "AdvancedModule.cs"
                            {
#line 269 "AdvancedModule.cs"
#line 269 "AdvancedModule.cs"
                                double* csharp2cuda_temp_120 = &((result)[player]);
                                (*(csharp2cuda_temp_120) = 0.0);
#line 270 "AdvancedModule.cs"
                                {
#line 270 "AdvancedModule.cs"
                                    int coalition = 0;
                                    while (true)
                                    {
#line 270 "AdvancedModule.cs"
                                        int csharp2cuda_temp_122 = (first)->count;
                                        if (!(((coalition) < (csharp2cuda_temp_122))))
                                            break;
#line 271 "AdvancedModule.cs"
                                        {
#line 272 "AdvancedModule.cs"
                                            if (((csharp2cuda_i32_and(coalition, csharp2cuda_i32_shl(1, player))) != (0)))
                                            {
#line 273 "AdvancedModule.cs"
                                                goto csharp2cuda_for_continue_11;
                                            }
#line 274 "AdvancedModule.cs"
                                            int size = mathblocks_advanced_popcount(coalition);
#line 275 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(__dmul_rn(mathblocks_advanced_factorial(size), mathblocks_advanced_factorial(csharp2cuda_i32_sub(csharp2cuda_i32_sub(player_count, size), 1))), denominator);
#line 278 "AdvancedModule.cs"
#line 278 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_123 = &((result)[player]);
#line 278 "AdvancedModule.cs"
                                            double csharp2cuda_temp_124 = *(csharp2cuda_temp_123);
#line 279 "AdvancedModule.cs"
                                            double csharp2cuda_temp_125 = (a)[csharp2cuda_i32_or(coalition, csharp2cuda_i32_shl(1, player))];
#line 279 "AdvancedModule.cs"
                                            double csharp2cuda_temp_126 = (a)[coalition];
                                            (*(csharp2cuda_temp_123) = __dadd_rn(csharp2cuda_temp_124, __dmul_rn(weight, __dsub_rn(csharp2cuda_temp_125, csharp2cuda_temp_126))));
                                        }
                                        csharp2cuda_for_continue_11:
#line 270 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_121 = &(coalition);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_121));
                                    }
                                }
                            }
#line 267 "AdvancedModule.cs"
                            int* csharp2cuda_temp_119 = &(player);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_119));
                        }
                    }
#line 282 "AdvancedModule.cs"
                    break;
                }
#line 284 "AdvancedModule.cs"
            case 4:
            case 5:
#line 286 "AdvancedModule.cs"
#line 286 "AdvancedModule.cs"
                int csharp2cuda_temp_127 = (third)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_127);
#line 287 "AdvancedModule.cs"
#line 287 "AdvancedModule.cs"
                int csharp2cuda_temp_128 = (first)->count;
#line 287 "AdvancedModule.cs"
                bool csharp2cuda_temp_129;
#line 287 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_128) <= (0))))
                {
#line 287 "AdvancedModule.cs"
                    int csharp2cuda_temp_130 = (first)->count;
#line 287 "AdvancedModule.cs"
                    int csharp2cuda_temp_131 = (second)->count;
#line 287 "AdvancedModule.cs"
                    csharp2cuda_temp_129 = ((csharp2cuda_temp_130) != (csharp2cuda_temp_131));
                }
                else
                {
#line 287 "AdvancedModule.cs"
                    csharp2cuda_temp_129 = true;
                }
#line 287 "AdvancedModule.cs"
                bool csharp2cuda_temp_132;
#line 287 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_129))
                {
#line 287 "AdvancedModule.cs"
                    double csharp2cuda_temp_133 = (fourth)->scalar_value;
#line 287 "AdvancedModule.cs"
                    csharp2cuda_temp_132 = ((csharp2cuda_temp_133) < (0.0));
                }
                else
                {
#line 287 "AdvancedModule.cs"
                    csharp2cuda_temp_132 = true;
                }
                if (csharp2cuda_temp_132)
#line 288 "AdvancedModule.cs"
                {
#line 289 "AdvancedModule.cs"
#line 289 "AdvancedModule.cs"
                    int* csharp2cuda_temp_134 = &((output)->valid);
                    (*(csharp2cuda_temp_134) = 0);
#line 290 "AdvancedModule.cs"
                    break;
                }
#line 292 "AdvancedModule.cs"
                break;
#line 293 "AdvancedModule.cs"
            case 6:
#line 294 "AdvancedModule.cs"
#line 294 "AdvancedModule.cs"
                int csharp2cuda_temp_135 = (first)->count;
                if (((csharp2cuda_temp_135) <= (0)))
#line 295 "AdvancedModule.cs"
                {
#line 296 "AdvancedModule.cs"
#line 296 "AdvancedModule.cs"
                    int* csharp2cuda_temp_136 = &((output)->valid);
                    (*(csharp2cuda_temp_136) = 0);
#line 297 "AdvancedModule.cs"
                    break;
                }
#line 299 "AdvancedModule.cs"
                {
#line 300 "AdvancedModule.cs"
                    double sum = 0.0;
#line 301 "AdvancedModule.cs"
                    {
#line 301 "AdvancedModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 301 "AdvancedModule.cs"
                            int csharp2cuda_temp_138 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_138))))
                                break;
#line 302 "AdvancedModule.cs"
                            {
#line 302 "AdvancedModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 302 "AdvancedModule.cs"
                                    int csharp2cuda_temp_140 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_140))))
                                        break;
#line 303 "AdvancedModule.cs"
#line 303 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_141 = &(sum);
#line 303 "AdvancedModule.cs"
                                    double csharp2cuda_temp_142 = *(csharp2cuda_temp_141);
#line 303 "AdvancedModule.cs"
                                    double csharp2cuda_temp_143 = (a)[left];
#line 303 "AdvancedModule.cs"
                                    double csharp2cuda_temp_144 = (a)[right];
                                    (*(csharp2cuda_temp_141) = __dadd_rn(csharp2cuda_temp_142, fabs(__dsub_rn(csharp2cuda_temp_143, csharp2cuda_temp_144))));
#line 302 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_139 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_139));
                                }
                            }
#line 301 "AdvancedModule.cs"
                            int* csharp2cuda_temp_137 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_137));
                        }
                    }
#line 304 "AdvancedModule.cs"
#line 304 "AdvancedModule.cs"
                    double* csharp2cuda_temp_145 = &((output)->scalar_value);
#line 305 "AdvancedModule.cs"
                    int csharp2cuda_temp_146 = (first)->count;
#line 305 "AdvancedModule.cs"
                    int csharp2cuda_temp_147 = (first)->count;
#line 304 "AdvancedModule.cs"
                    double csharp2cuda_temp_148 = __ddiv_rn(sum, __dmul_rn(__dmul_rn(2.0, ((double)(csharp2cuda_temp_146))), mathblocks_compensated_sum(a, csharp2cuda_temp_147)));
                    (*(csharp2cuda_temp_145) = csharp2cuda_temp_148);
#line 306 "AdvancedModule.cs"
                    break;
                }
#line 308 "AdvancedModule.cs"
            case 7:
#line 309 "AdvancedModule.cs"
#line 309 "AdvancedModule.cs"
                int csharp2cuda_temp_149 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_149, 1));
#line 310 "AdvancedModule.cs"
#line 310 "AdvancedModule.cs"
                int csharp2cuda_temp_150 = (first)->count;
#line 310 "AdvancedModule.cs"
                bool csharp2cuda_temp_151;
#line 310 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_150) <= (0))))
                {
#line 310 "AdvancedModule.cs"
                    csharp2cuda_temp_151 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 310 "AdvancedModule.cs"
                    csharp2cuda_temp_151 = true;
                }
                if (csharp2cuda_temp_151)
#line 311 "AdvancedModule.cs"
                {
#line 312 "AdvancedModule.cs"
#line 312 "AdvancedModule.cs"
                    int* csharp2cuda_temp_152 = &((output)->valid);
                    (*(csharp2cuda_temp_152) = 0);
#line 313 "AdvancedModule.cs"
                    break;
                }
#line 315 "AdvancedModule.cs"
#line 315 "AdvancedModule.cs"
                double* csharp2cuda_temp_153 = &((result)[0]);
                (*(csharp2cuda_temp_153) = 0.0);
#line 316 "AdvancedModule.cs"
                {
#line 316 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 316 "AdvancedModule.cs"
                        int csharp2cuda_temp_155 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_155))))
                            break;
#line 317 "AdvancedModule.cs"
#line 317 "AdvancedModule.cs"
                        double* csharp2cuda_temp_156 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 317 "AdvancedModule.cs"
                        double csharp2cuda_temp_157 = (a)[index];
                        (*(csharp2cuda_temp_156) = csharp2cuda_temp_157);
#line 316 "AdvancedModule.cs"
                        int* csharp2cuda_temp_154 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_154));
                    }
                }
#line 318 "AdvancedModule.cs"
                {
#line 319 "AdvancedModule.cs"
                    int csharp2cuda_temp_158 = (first)->count;
#line 319 "AdvancedModule.cs"
                    double* sorted = mathblocks_stable_merge_sort(csharp2cuda_pointer_add(result, 1), scratch, csharp2cuda_temp_158, false);
#line 320 "AdvancedModule.cs"
                    if (((((void*)(sorted))) != (((void*)(csharp2cuda_pointer_add(result, 1))))))
                    {
#line 321 "AdvancedModule.cs"
                        {
#line 321 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 321 "AdvancedModule.cs"
                                int csharp2cuda_temp_160 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_160))))
                                    break;
#line 322 "AdvancedModule.cs"
#line 322 "AdvancedModule.cs"
                                double* csharp2cuda_temp_161 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 322 "AdvancedModule.cs"
                                double csharp2cuda_temp_162 = (sorted)[index];
                                (*(csharp2cuda_temp_161) = csharp2cuda_temp_162);
#line 321 "AdvancedModule.cs"
                                int* csharp2cuda_temp_159 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_159));
                            }
                        }
                    }
                }
#line 324 "AdvancedModule.cs"
                {
#line 325 "AdvancedModule.cs"
                    int csharp2cuda_temp_163 = (first)->count;
#line 325 "AdvancedModule.cs"
                    double total = mathblocks_compensated_sum(csharp2cuda_pointer_add(result, 1), csharp2cuda_temp_163);
#line 326 "AdvancedModule.cs"
                    {
#line 326 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 326 "AdvancedModule.cs"
                            int csharp2cuda_temp_165 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_165))))
                                break;
#line 327 "AdvancedModule.cs"
#line 327 "AdvancedModule.cs"
                            double* csharp2cuda_temp_166 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 327 "AdvancedModule.cs"
                            double csharp2cuda_temp_167 = (result)[index];
#line 327 "AdvancedModule.cs"
                            double csharp2cuda_temp_168 = (result)[csharp2cuda_i32_add(index, 1)];
#line 327 "AdvancedModule.cs"
                            double csharp2cuda_temp_169 = __ddiv_rn(csharp2cuda_temp_168, total);
                            (*(csharp2cuda_temp_166) = __dadd_rn(csharp2cuda_temp_167, csharp2cuda_temp_169));
#line 326 "AdvancedModule.cs"
                            int* csharp2cuda_temp_164 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_164));
                        }
                    }
#line 328 "AdvancedModule.cs"
                    break;
                }
#line 330 "AdvancedModule.cs"
            case 8:
#line 331 "AdvancedModule.cs"
#line 331 "AdvancedModule.cs"
                int csharp2cuda_temp_170 = (first)->rows;
#line 331 "AdvancedModule.cs"
                int csharp2cuda_temp_171 = (first)->columns;
#line 331 "AdvancedModule.cs"
                bool csharp2cuda_temp_172;
#line 331 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_170) != (csharp2cuda_temp_171))))
                {
#line 331 "AdvancedModule.cs"
                    int csharp2cuda_temp_173 = (first)->rows;
#line 331 "AdvancedModule.cs"
                    int csharp2cuda_temp_174 = (second)->count;
#line 331 "AdvancedModule.cs"
                    csharp2cuda_temp_172 = ((csharp2cuda_temp_173) != (csharp2cuda_temp_174));
                }
                else
                {
#line 331 "AdvancedModule.cs"
                    csharp2cuda_temp_172 = true;
                }
#line 331 "AdvancedModule.cs"
                bool csharp2cuda_temp_175;
#line 331 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_172))
                {
#line 332 "AdvancedModule.cs"
                    int csharp2cuda_temp_176 = (first)->rows;
#line 332 "AdvancedModule.cs"
                    int csharp2cuda_temp_177 = (first)->columns;
#line 332 "AdvancedModule.cs"
                    bool csharp2cuda_temp_178 = mathblocks_advanced_transition(a, csharp2cuda_temp_176, csharp2cuda_temp_177);
#line 331 "AdvancedModule.cs"
                    csharp2cuda_temp_175 = (!(csharp2cuda_temp_178));
                }
                else
                {
#line 331 "AdvancedModule.cs"
                    csharp2cuda_temp_175 = true;
                }
#line 331 "AdvancedModule.cs"
                bool csharp2cuda_temp_179;
#line 331 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_175))
                {
#line 333 "AdvancedModule.cs"
                    int csharp2cuda_temp_180 = (second)->count;
#line 333 "AdvancedModule.cs"
                    bool csharp2cuda_temp_181 = mathblocks_advanced_distribution(b, csharp2cuda_temp_180);
#line 331 "AdvancedModule.cs"
                    csharp2cuda_temp_179 = (!(csharp2cuda_temp_181));
                }
                else
                {
#line 331 "AdvancedModule.cs"
                    csharp2cuda_temp_179 = true;
                }
                if (csharp2cuda_temp_179)
#line 334 "AdvancedModule.cs"
                {
#line 335 "AdvancedModule.cs"
#line 335 "AdvancedModule.cs"
                    int* csharp2cuda_temp_182 = &((output)->valid);
                    (*(csharp2cuda_temp_182) = 0);
#line 336 "AdvancedModule.cs"
                    break;
                }
#line 338 "AdvancedModule.cs"
                {
#line 339 "AdvancedModule.cs"
                    double total = 0.0;
#line 340 "AdvancedModule.cs"
                    {
#line 340 "AdvancedModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 340 "AdvancedModule.cs"
                            int csharp2cuda_temp_184 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_184))))
                                break;
#line 341 "AdvancedModule.cs"
                            {
#line 341 "AdvancedModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 341 "AdvancedModule.cs"
                                    int csharp2cuda_temp_186 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_186))))
                                        break;
#line 342 "AdvancedModule.cs"
                                    {
#line 343 "AdvancedModule.cs"
                                        double csharp2cuda_temp_187 = (b)[row];
#line 343 "AdvancedModule.cs"
                                        int csharp2cuda_temp_188 = (first)->columns;
#line 343 "AdvancedModule.cs"
                                        double csharp2cuda_temp_189 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_188), column)];
#line 343 "AdvancedModule.cs"
                                        double forward = __dmul_rn(csharp2cuda_temp_187, csharp2cuda_temp_189);
#line 344 "AdvancedModule.cs"
                                        double csharp2cuda_temp_190 = (b)[column];
#line 344 "AdvancedModule.cs"
                                        int csharp2cuda_temp_191 = (first)->columns;
#line 344 "AdvancedModule.cs"
                                        double csharp2cuda_temp_192 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_191), row)];
#line 344 "AdvancedModule.cs"
                                        double reverse = __dmul_rn(csharp2cuda_temp_190, csharp2cuda_temp_192);
#line 345 "AdvancedModule.cs"
#line 345 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_193;
#line 345 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 345 "AdvancedModule.cs"
                                            csharp2cuda_temp_193 = ((reverse) == (0.0));
                                        }
                                        else
                                        {
#line 345 "AdvancedModule.cs"
                                            csharp2cuda_temp_193 = false;
                                        }
                                        if (csharp2cuda_temp_193)
#line 346 "AdvancedModule.cs"
                                        {
#line 347 "AdvancedModule.cs"
#line 347 "AdvancedModule.cs"
                                            int* csharp2cuda_temp_194 = &((output)->valid);
                                            (*(csharp2cuda_temp_194) = 0);
#line 348 "AdvancedModule.cs"
                                            break;
                                        }
#line 350 "AdvancedModule.cs"
#line 350 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_195;
#line 350 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 350 "AdvancedModule.cs"
                                            csharp2cuda_temp_195 = ((reverse) > (0.0));
                                        }
                                        else
                                        {
#line 350 "AdvancedModule.cs"
                                            csharp2cuda_temp_195 = false;
                                        }
                                        if (csharp2cuda_temp_195)
                                        {
#line 351 "AdvancedModule.cs"
#line 351 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_196 = &(total);
#line 351 "AdvancedModule.cs"
                                            double csharp2cuda_temp_197 = *(csharp2cuda_temp_196);
#line 351 "AdvancedModule.cs"
                                            double csharp2cuda_temp_198 = __ddiv_rn(forward, reverse);
                                            (*(csharp2cuda_temp_196) = __dadd_rn(csharp2cuda_temp_197, __dmul_rn(forward, mathblocks_natural_logarithm(csharp2cuda_temp_198))));
                                        }
                                    }
#line 341 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_185 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_185));
                                }
                            }
#line 340 "AdvancedModule.cs"
                            int* csharp2cuda_temp_183 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_183));
                        }
                    }
#line 353 "AdvancedModule.cs"
#line 353 "AdvancedModule.cs"
                    double* csharp2cuda_temp_199 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_199) = total);
#line 354 "AdvancedModule.cs"
                    break;
                }
#line 356 "AdvancedModule.cs"
            case 9:
#line 357 "AdvancedModule.cs"
#line 357 "AdvancedModule.cs"
                int csharp2cuda_temp_200 = (first)->rows;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_200);
#line 358 "AdvancedModule.cs"
#line 358 "AdvancedModule.cs"
                int csharp2cuda_temp_201 = (first)->rows;
#line 358 "AdvancedModule.cs"
                int csharp2cuda_temp_202 = (first)->columns;
#line 358 "AdvancedModule.cs"
                bool csharp2cuda_temp_203 = mathblocks_advanced_transition(a, csharp2cuda_temp_201, csharp2cuda_temp_202);
#line 358 "AdvancedModule.cs"
                bool csharp2cuda_temp_204;
#line 358 "AdvancedModule.cs"
                if (!((!(csharp2cuda_temp_203))))
                {
#line 358 "AdvancedModule.cs"
                    csharp2cuda_temp_204 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 358 "AdvancedModule.cs"
                    csharp2cuda_temp_204 = true;
                }
                if (csharp2cuda_temp_204)
#line 359 "AdvancedModule.cs"
                {
#line 360 "AdvancedModule.cs"
#line 360 "AdvancedModule.cs"
                    int* csharp2cuda_temp_205 = &((output)->valid);
                    (*(csharp2cuda_temp_205) = 0);
#line 361 "AdvancedModule.cs"
                    break;
                }
#line 363 "AdvancedModule.cs"
                {
#line 364 "AdvancedModule.cs"
                    int iterations = 0;
#line 365 "AdvancedModule.cs"
#line 365 "AdvancedModule.cs"
                    double csharp2cuda_temp_206 = (second)->scalar_value;
#line 365 "AdvancedModule.cs"
                    int* csharp2cuda_temp_207 = &(iterations);
#line 365 "AdvancedModule.cs"
                    bool csharp2cuda_temp_208 = mathblocks_sequence_positive_integer(csharp2cuda_temp_206, csharp2cuda_temp_207);
#line 365 "AdvancedModule.cs"
                    bool csharp2cuda_temp_209;
#line 365 "AdvancedModule.cs"
                    if (!((!(csharp2cuda_temp_208))))
                    {
#line 365 "AdvancedModule.cs"
                        csharp2cuda_temp_209 = ((iterations) > (10000));
                    }
                    else
                    {
#line 365 "AdvancedModule.cs"
                        csharp2cuda_temp_209 = true;
                    }
                    if (csharp2cuda_temp_209)
#line 366 "AdvancedModule.cs"
                    {
#line 367 "AdvancedModule.cs"
#line 367 "AdvancedModule.cs"
                        int* csharp2cuda_temp_210 = &((output)->valid);
                        (*(csharp2cuda_temp_210) = 0);
#line 368 "AdvancedModule.cs"
                        break;
                    }
#line 370 "AdvancedModule.cs"
                    {
#line 370 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 370 "AdvancedModule.cs"
                            int csharp2cuda_temp_212 = (first)->rows;
                            if (!(((index) < (csharp2cuda_temp_212))))
                                break;
#line 371 "AdvancedModule.cs"
#line 371 "AdvancedModule.cs"
                            double* csharp2cuda_temp_213 = &((result)[index]);
#line 371 "AdvancedModule.cs"
                            int csharp2cuda_temp_214 = (first)->rows;
#line 371 "AdvancedModule.cs"
                            double csharp2cuda_temp_215 = __ddiv_rn(1.0, ((double)(csharp2cuda_temp_214)));
                            (*(csharp2cuda_temp_213) = csharp2cuda_temp_215);
#line 370 "AdvancedModule.cs"
                            int* csharp2cuda_temp_211 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_211));
                        }
                    }
#line 372 "AdvancedModule.cs"
                    {
#line 372 "AdvancedModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 373 "AdvancedModule.cs"
                            {
#line 374 "AdvancedModule.cs"
                                {
#line 374 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 374 "AdvancedModule.cs"
                                        int csharp2cuda_temp_218 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_218))))
                                            break;
#line 375 "AdvancedModule.cs"
#line 375 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_219 = &((scratch)[index]);
                                        (*(csharp2cuda_temp_219) = 0.0);
#line 374 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_217 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                                    }
                                }
#line 376 "AdvancedModule.cs"
                                {
#line 376 "AdvancedModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 376 "AdvancedModule.cs"
                                        int csharp2cuda_temp_221 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_221))))
                                            break;
#line 377 "AdvancedModule.cs"
                                        {
#line 377 "AdvancedModule.cs"
                                            int column = 0;
                                            while (true)
                                            {
#line 377 "AdvancedModule.cs"
                                                int csharp2cuda_temp_223 = (first)->columns;
                                                if (!(((column) < (csharp2cuda_temp_223))))
                                                    break;
#line 378 "AdvancedModule.cs"
#line 378 "AdvancedModule.cs"
                                                double* csharp2cuda_temp_224 = &((scratch)[column]);
#line 378 "AdvancedModule.cs"
                                                double csharp2cuda_temp_225 = *(csharp2cuda_temp_224);
#line 378 "AdvancedModule.cs"
                                                double csharp2cuda_temp_226 = (result)[row];
#line 378 "AdvancedModule.cs"
                                                int csharp2cuda_temp_227 = (first)->columns;
#line 378 "AdvancedModule.cs"
                                                double csharp2cuda_temp_228 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_227), column)];
                                                (*(csharp2cuda_temp_224) = __dadd_rn(csharp2cuda_temp_225, __dmul_rn(csharp2cuda_temp_226, csharp2cuda_temp_228)));
#line 377 "AdvancedModule.cs"
                                                int* csharp2cuda_temp_222 = &(column);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_222));
                                            }
                                        }
#line 376 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_220 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_220));
                                    }
                                }
#line 379 "AdvancedModule.cs"
                                {
#line 379 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 379 "AdvancedModule.cs"
                                        int csharp2cuda_temp_230 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_230))))
                                            break;
#line 380 "AdvancedModule.cs"
#line 380 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_231 = &((result)[index]);
#line 380 "AdvancedModule.cs"
                                        double csharp2cuda_temp_232 = (scratch)[index];
                                        (*(csharp2cuda_temp_231) = csharp2cuda_temp_232);
#line 379 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_229 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_229));
                                    }
                                }
                            }
#line 372 "AdvancedModule.cs"
                            int* csharp2cuda_temp_216 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_216));
                        }
                    }
#line 382 "AdvancedModule.cs"
                    break;
                }
#line 384 "AdvancedModule.cs"
            case 10:
#line 385 "AdvancedModule.cs"
#line 385 "AdvancedModule.cs"
                int csharp2cuda_temp_233 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_233);
#line 386 "AdvancedModule.cs"
#line 386 "AdvancedModule.cs"
                int csharp2cuda_temp_234 = (first)->count;
#line 386 "AdvancedModule.cs"
                bool csharp2cuda_temp_235;
#line 386 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_234) <= (0))))
                {
#line 386 "AdvancedModule.cs"
                    csharp2cuda_temp_235 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 386 "AdvancedModule.cs"
                    csharp2cuda_temp_235 = true;
                }
                if (csharp2cuda_temp_235)
#line 387 "AdvancedModule.cs"
                {
#line 388 "AdvancedModule.cs"
#line 388 "AdvancedModule.cs"
                    int* csharp2cuda_temp_236 = &((output)->valid);
                    (*(csharp2cuda_temp_236) = 0);
#line 389 "AdvancedModule.cs"
                    break;
                }
#line 391 "AdvancedModule.cs"
                {
#line 392 "AdvancedModule.cs"
                    double* means = scratch;
#line 393 "AdvancedModule.cs"
                    int csharp2cuda_temp_237 = (first)->count;
#line 393 "AdvancedModule.cs"
                    int* weights = ((int*)(csharp2cuda_pointer_add(means, csharp2cuda_temp_237)));
#line 394 "AdvancedModule.cs"
                    int csharp2cuda_temp_238 = (first)->count;
#line 394 "AdvancedModule.cs"
                    int* starts = csharp2cuda_pointer_add(weights, csharp2cuda_temp_238);
#line 395 "AdvancedModule.cs"
                    int block_count = 0;
#line 396 "AdvancedModule.cs"
                    {
#line 396 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 396 "AdvancedModule.cs"
                            int csharp2cuda_temp_240 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_240))))
                                break;
#line 397 "AdvancedModule.cs"
                            {
#line 398 "AdvancedModule.cs"
#line 398 "AdvancedModule.cs"
                                double* csharp2cuda_temp_241 = &((means)[block_count]);
#line 398 "AdvancedModule.cs"
                                double csharp2cuda_temp_242 = (a)[index];
                                (*(csharp2cuda_temp_241) = csharp2cuda_temp_242);
#line 399 "AdvancedModule.cs"
#line 399 "AdvancedModule.cs"
                                int* csharp2cuda_temp_243 = &((weights)[block_count]);
                                (*(csharp2cuda_temp_243) = 1);
#line 400 "AdvancedModule.cs"
#line 400 "AdvancedModule.cs"
                                int* csharp2cuda_temp_244 = &((starts)[block_count]);
                                (*(csharp2cuda_temp_244) = index);
#line 401 "AdvancedModule.cs"
#line 401 "AdvancedModule.cs"
                                int* csharp2cuda_temp_245 = &(block_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_245));
#line 402 "AdvancedModule.cs"
                                while (true)
                                {
#line 402 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_246;
#line 402 "AdvancedModule.cs"
                                    if (((block_count) >= (2)))
                                    {
#line 402 "AdvancedModule.cs"
                                        double csharp2cuda_temp_247 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 402 "AdvancedModule.cs"
                                        double csharp2cuda_temp_248 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 402 "AdvancedModule.cs"
                                        csharp2cuda_temp_246 = ((csharp2cuda_temp_247) > (csharp2cuda_temp_248));
                                    }
                                    else
                                    {
#line 402 "AdvancedModule.cs"
                                        csharp2cuda_temp_246 = false;
                                    }
                                    if (!(csharp2cuda_temp_246))
                                        break;
#line 403 "AdvancedModule.cs"
                                    {
#line 404 "AdvancedModule.cs"
                                        int csharp2cuda_temp_249 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 404 "AdvancedModule.cs"
                                        int csharp2cuda_temp_250 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 404 "AdvancedModule.cs"
                                        int combined_weight = csharp2cuda_i32_add(csharp2cuda_temp_249, csharp2cuda_temp_250);
#line 405 "AdvancedModule.cs"
#line 405 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_251 = &((means)[csharp2cuda_i32_sub(block_count, 2)]);
#line 406 "AdvancedModule.cs"
                                        double csharp2cuda_temp_252 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 406 "AdvancedModule.cs"
                                        int csharp2cuda_temp_253 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 407 "AdvancedModule.cs"
                                        double csharp2cuda_temp_254 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 407 "AdvancedModule.cs"
                                        int csharp2cuda_temp_255 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 406 "AdvancedModule.cs"
                                        double csharp2cuda_temp_256 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_252, ((double)(csharp2cuda_temp_253))), __dmul_rn(csharp2cuda_temp_254, ((double)(csharp2cuda_temp_255)))), ((double)(combined_weight)));
                                        (*(csharp2cuda_temp_251) = csharp2cuda_temp_256);
#line 409 "AdvancedModule.cs"
#line 409 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_257 = &((weights)[csharp2cuda_i32_sub(block_count, 2)]);
                                        (*(csharp2cuda_temp_257) = combined_weight);
#line 410 "AdvancedModule.cs"
#line 410 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_258 = &(block_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_258));
                                    }
                                }
                            }
#line 396 "AdvancedModule.cs"
                            int* csharp2cuda_temp_239 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_239));
                        }
                    }
#line 413 "AdvancedModule.cs"
                    {
#line 413 "AdvancedModule.cs"
                        int block = 0;
                        while (true)
                        {
                            if (!(((block) < (block_count))))
                                break;
#line 414 "AdvancedModule.cs"
                            {
#line 415 "AdvancedModule.cs"
                                int csharp2cuda_temp_260;
#line 415 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_add(block, 1)) < (block_count)))
                                {
#line 415 "AdvancedModule.cs"
                                    csharp2cuda_temp_260 = (starts)[csharp2cuda_i32_add(block, 1)];
                                }
                                else
                                {
#line 415 "AdvancedModule.cs"
                                    csharp2cuda_temp_260 = (first)->count;
                                }
#line 415 "AdvancedModule.cs"
                                int end = csharp2cuda_temp_260;
#line 416 "AdvancedModule.cs"
                                {
#line 416 "AdvancedModule.cs"
                                    int index = (starts)[block];
                                    while (true)
                                    {
                                        if (!(((index) < (end))))
                                            break;
#line 417 "AdvancedModule.cs"
#line 417 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_262 = &((result)[index]);
#line 417 "AdvancedModule.cs"
                                        double csharp2cuda_temp_263 = (means)[block];
                                        (*(csharp2cuda_temp_262) = csharp2cuda_temp_263);
#line 416 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_261 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_261));
                                    }
                                }
                            }
#line 413 "AdvancedModule.cs"
                            int* csharp2cuda_temp_259 = &(block);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_259));
                        }
                    }
#line 419 "AdvancedModule.cs"
                    break;
                }
#line 421 "AdvancedModule.cs"
            case 11:
#line 422 "AdvancedModule.cs"
#line 422 "AdvancedModule.cs"
                int csharp2cuda_temp_264 = (first)->count;
#line 422 "AdvancedModule.cs"
                int csharp2cuda_temp_265 = (second)->count;
#line 422 "AdvancedModule.cs"
                bool csharp2cuda_temp_266;
#line 422 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_264) != (csharp2cuda_temp_265))))
                {
#line 422 "AdvancedModule.cs"
                    csharp2cuda_temp_266 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 422 "AdvancedModule.cs"
                    csharp2cuda_temp_266 = true;
                }
                if (csharp2cuda_temp_266)
#line 423 "AdvancedModule.cs"
                {
#line 424 "AdvancedModule.cs"
#line 424 "AdvancedModule.cs"
                    int* csharp2cuda_temp_267 = &((output)->valid);
                    (*(csharp2cuda_temp_267) = 0);
#line 425 "AdvancedModule.cs"
                    break;
                }
#line 427 "AdvancedModule.cs"
                {
#line 428 "AdvancedModule.cs"
                    double* left_sorted = scratch;
#line 429 "AdvancedModule.cs"
                    int csharp2cuda_temp_268 = (first)->count;
#line 429 "AdvancedModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_268);
#line 430 "AdvancedModule.cs"
#line 430 "AdvancedModule.cs"
                    int csharp2cuda_temp_269 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_269, left_sorted, true);
#line 431 "AdvancedModule.cs"
#line 431 "AdvancedModule.cs"
                    int csharp2cuda_temp_270 = (first)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_270, right_sorted, true);
#line 432 "AdvancedModule.cs"
                    double left_sum = 0.0;
#line 433 "AdvancedModule.cs"
                    double right_sum = 0.0;
#line 434 "AdvancedModule.cs"
                    bool majorizes = true;
#line 435 "AdvancedModule.cs"
                    {
#line 435 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 435 "AdvancedModule.cs"
                            int csharp2cuda_temp_272 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_272))))
                                break;
#line 436 "AdvancedModule.cs"
                            {
#line 437 "AdvancedModule.cs"
#line 437 "AdvancedModule.cs"
                                double* csharp2cuda_temp_273 = &(left_sum);
#line 437 "AdvancedModule.cs"
                                double csharp2cuda_temp_274 = *(csharp2cuda_temp_273);
#line 437 "AdvancedModule.cs"
                                double csharp2cuda_temp_275 = (left_sorted)[index];
                                (*(csharp2cuda_temp_273) = __dadd_rn(csharp2cuda_temp_274, csharp2cuda_temp_275));
#line 438 "AdvancedModule.cs"
#line 438 "AdvancedModule.cs"
                                double* csharp2cuda_temp_276 = &(right_sum);
#line 438 "AdvancedModule.cs"
                                double csharp2cuda_temp_277 = *(csharp2cuda_temp_276);
#line 438 "AdvancedModule.cs"
                                double csharp2cuda_temp_278 = (right_sorted)[index];
                                (*(csharp2cuda_temp_276) = __dadd_rn(csharp2cuda_temp_277, csharp2cuda_temp_278));
#line 439 "AdvancedModule.cs"
#line 439 "AdvancedModule.cs"
                                int csharp2cuda_temp_279 = (first)->count;
#line 439 "AdvancedModule.cs"
                                bool csharp2cuda_temp_280;
#line 439 "AdvancedModule.cs"
                                if (((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_279, 1))))
                                {
#line 439 "AdvancedModule.cs"
                                    csharp2cuda_temp_280 = ((left_sum) < (right_sum));
                                }
                                else
                                {
#line 439 "AdvancedModule.cs"
                                    csharp2cuda_temp_280 = false;
                                }
                                if (csharp2cuda_temp_280)
                                {
#line 440 "AdvancedModule.cs"
#line 440 "AdvancedModule.cs"
                                    bool* csharp2cuda_temp_281 = &(majorizes);
                                    (*(csharp2cuda_temp_281) = false);
                                }
                            }
#line 435 "AdvancedModule.cs"
                            int* csharp2cuda_temp_271 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_271));
                        }
                    }
#line 442 "AdvancedModule.cs"
#line 442 "AdvancedModule.cs"
                    int* csharp2cuda_temp_282 = &((output)->boolean_value);
#line 442 "AdvancedModule.cs"
                    bool csharp2cuda_temp_283;
#line 442 "AdvancedModule.cs"
                    if (majorizes)
                    {
#line 442 "AdvancedModule.cs"
                        csharp2cuda_temp_283 = ((left_sum) == (right_sum));
                    }
                    else
                    {
#line 442 "AdvancedModule.cs"
                        csharp2cuda_temp_283 = false;
                    }
#line 442 "AdvancedModule.cs"
                    int csharp2cuda_temp_284;
#line 442 "AdvancedModule.cs"
                    if (csharp2cuda_temp_283)
                    {
#line 442 "AdvancedModule.cs"
                        csharp2cuda_temp_284 = 1;
                    }
                    else
                    {
#line 442 "AdvancedModule.cs"
                        csharp2cuda_temp_284 = 0;
                    }
                    (*(csharp2cuda_temp_282) = csharp2cuda_temp_284);
#line 443 "AdvancedModule.cs"
                    break;
                }
#line 445 "AdvancedModule.cs"
            case 12:
#line 446 "AdvancedModule.cs"
#line 446 "AdvancedModule.cs"
                int csharp2cuda_temp_285 = (first)->count;
#line 446 "AdvancedModule.cs"
                bool csharp2cuda_temp_286;
#line 446 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_285) <= (0))))
                {
#line 446 "AdvancedModule.cs"
                    int csharp2cuda_temp_287 = (first)->count;
#line 446 "AdvancedModule.cs"
                    int csharp2cuda_temp_288 = (second)->count;
#line 446 "AdvancedModule.cs"
                    csharp2cuda_temp_286 = ((csharp2cuda_temp_287) != (csharp2cuda_temp_288));
                }
                else
                {
#line 446 "AdvancedModule.cs"
                    csharp2cuda_temp_286 = true;
                }
                if (csharp2cuda_temp_286)
#line 447 "AdvancedModule.cs"
                {
#line 448 "AdvancedModule.cs"
#line 448 "AdvancedModule.cs"
                    int* csharp2cuda_temp_289 = &((output)->valid);
                    (*(csharp2cuda_temp_289) = 0);
#line 449 "AdvancedModule.cs"
                    break;
                }
#line 451 "AdvancedModule.cs"
                {
#line 452 "AdvancedModule.cs"
                    double minimum = mathblocks_positive_infinity();
#line 453 "AdvancedModule.cs"
                    double maximum = (-(mathblocks_positive_infinity()));
#line 454 "AdvancedModule.cs"
                    {
#line 454 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 454 "AdvancedModule.cs"
                            int csharp2cuda_temp_291 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_291))))
                                break;
#line 455 "AdvancedModule.cs"
                            {
#line 456 "AdvancedModule.cs"
#line 456 "AdvancedModule.cs"
                                double csharp2cuda_temp_292 = (a)[index];
#line 456 "AdvancedModule.cs"
                                bool csharp2cuda_temp_293;
#line 456 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_292) <= (0.0))))
                                {
#line 456 "AdvancedModule.cs"
                                    double csharp2cuda_temp_294 = (b)[index];
#line 456 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = ((csharp2cuda_temp_294) <= (0.0));
                                }
                                else
                                {
#line 456 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = true;
                                }
                                if (csharp2cuda_temp_293)
#line 457 "AdvancedModule.cs"
                                {
#line 458 "AdvancedModule.cs"
#line 458 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_295 = &((output)->valid);
                                    (*(csharp2cuda_temp_295) = 0);
#line 459 "AdvancedModule.cs"
                                    break;
                                }
#line 461 "AdvancedModule.cs"
                                double csharp2cuda_temp_296 = (a)[index];
#line 461 "AdvancedModule.cs"
                                double csharp2cuda_temp_297 = (b)[index];
#line 461 "AdvancedModule.cs"
                                double ratio = __ddiv_rn(csharp2cuda_temp_296, csharp2cuda_temp_297);
#line 462 "AdvancedModule.cs"
#line 462 "AdvancedModule.cs"
                                double* csharp2cuda_temp_298 = &(minimum);
#line 462 "AdvancedModule.cs"
                                double csharp2cuda_temp_299;
#line 462 "AdvancedModule.cs"
                                if (((minimum) < (ratio)))
                                {
#line 462 "AdvancedModule.cs"
                                    csharp2cuda_temp_299 = minimum;
                                }
                                else
                                {
#line 462 "AdvancedModule.cs"
                                    csharp2cuda_temp_299 = ratio;
                                }
                                (*(csharp2cuda_temp_298) = csharp2cuda_temp_299);
#line 463 "AdvancedModule.cs"
#line 463 "AdvancedModule.cs"
                                double* csharp2cuda_temp_300 = &(maximum);
#line 463 "AdvancedModule.cs"
                                double csharp2cuda_temp_301;
#line 463 "AdvancedModule.cs"
                                if (((maximum) > (ratio)))
                                {
#line 463 "AdvancedModule.cs"
                                    csharp2cuda_temp_301 = maximum;
                                }
                                else
                                {
#line 463 "AdvancedModule.cs"
                                    csharp2cuda_temp_301 = ratio;
                                }
                                (*(csharp2cuda_temp_300) = csharp2cuda_temp_301);
                            }
#line 454 "AdvancedModule.cs"
                            int* csharp2cuda_temp_290 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_290));
                        }
                    }
#line 465 "AdvancedModule.cs"
#line 465 "AdvancedModule.cs"
                    double* csharp2cuda_temp_302 = &((output)->scalar_value);
#line 465 "AdvancedModule.cs"
                    double csharp2cuda_temp_303 = __ddiv_rn(maximum, minimum);
                    (*(csharp2cuda_temp_302) = mathblocks_natural_logarithm(csharp2cuda_temp_303));
#line 466 "AdvancedModule.cs"
                    break;
                }
#line 468 "AdvancedModule.cs"
            case 13:
            case 16:
#line 470 "AdvancedModule.cs"
#line 470 "AdvancedModule.cs"
                int csharp2cuda_temp_304 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_304);
#line 471 "AdvancedModule.cs"
#line 471 "AdvancedModule.cs"
                int csharp2cuda_temp_305 = (first)->count;
#line 471 "AdvancedModule.cs"
                bool csharp2cuda_temp_306;
#line 471 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_305) <= (0))))
                {
#line 471 "AdvancedModule.cs"
                    csharp2cuda_temp_306 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 471 "AdvancedModule.cs"
                    csharp2cuda_temp_306 = true;
                }
                if (csharp2cuda_temp_306)
#line 472 "AdvancedModule.cs"
                {
#line 473 "AdvancedModule.cs"
#line 473 "AdvancedModule.cs"
                    int* csharp2cuda_temp_307 = &((output)->valid);
                    (*(csharp2cuda_temp_307) = 0);
#line 474 "AdvancedModule.cs"
                    break;
                }
#line 476 "AdvancedModule.cs"
                {
#line 477 "AdvancedModule.cs"
                    int* hull = ((int*)(scratch));
#line 478 "AdvancedModule.cs"
                    int hull_count = 0;
#line 479 "AdvancedModule.cs"
                    bool concave = ((opcode) == (16));
#line 480 "AdvancedModule.cs"
                    {
#line 480 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 480 "AdvancedModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_309))))
                                break;
#line 481 "AdvancedModule.cs"
                            {
#line 482 "AdvancedModule.cs"
#line 482 "AdvancedModule.cs"
                                int* csharp2cuda_temp_310 = &(hull_count);
#line 482 "AdvancedModule.cs"
                                int csharp2cuda_temp_311 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_310));
#line 482 "AdvancedModule.cs"
                                int* csharp2cuda_temp_312 = &((hull)[csharp2cuda_temp_311]);
                                (*(csharp2cuda_temp_312) = index);
#line 483 "AdvancedModule.cs"
                                while (true)
                                {
                                    if (!(((hull_count) >= (3))))
                                        break;
#line 484 "AdvancedModule.cs"
                                    {
#line 485 "AdvancedModule.cs"
                                        int one = (hull)[csharp2cuda_i32_sub(hull_count, 3)];
#line 486 "AdvancedModule.cs"
                                        int middle = (hull)[csharp2cuda_i32_sub(hull_count, 2)];
#line 487 "AdvancedModule.cs"
                                        int last = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
#line 488 "AdvancedModule.cs"
                                        double csharp2cuda_temp_313 = (a)[middle];
#line 488 "AdvancedModule.cs"
                                        double csharp2cuda_temp_314 = (a)[one];
#line 488 "AdvancedModule.cs"
                                        double first_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_313, csharp2cuda_temp_314), ((double)(csharp2cuda_i32_sub(middle, one))));
#line 489 "AdvancedModule.cs"
                                        double csharp2cuda_temp_315 = (a)[last];
#line 489 "AdvancedModule.cs"
                                        double csharp2cuda_temp_316 = (a)[middle];
#line 489 "AdvancedModule.cs"
                                        double second_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_315, csharp2cuda_temp_316), ((double)(csharp2cuda_i32_sub(last, middle))));
#line 490 "AdvancedModule.cs"
#line 490 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_317;
#line 490 "AdvancedModule.cs"
                                        if (concave)
                                        {
#line 490 "AdvancedModule.cs"
                                            csharp2cuda_temp_317 = ((first_slope) >= (second_slope));
                                        }
                                        else
                                        {
#line 490 "AdvancedModule.cs"
                                            csharp2cuda_temp_317 = ((first_slope) <= (second_slope));
                                        }
                                        if (csharp2cuda_temp_317)
                                        {
#line 491 "AdvancedModule.cs"
                                            break;
                                        }
#line 492 "AdvancedModule.cs"
#line 492 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_318 = &((hull)[csharp2cuda_i32_sub(hull_count, 2)]);
#line 492 "AdvancedModule.cs"
                                        int csharp2cuda_temp_319 = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
                                        (*(csharp2cuda_temp_318) = csharp2cuda_temp_319);
#line 493 "AdvancedModule.cs"
#line 493 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_320 = &(hull_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_320));
                                    }
                                }
                            }
#line 480 "AdvancedModule.cs"
                            int* csharp2cuda_temp_308 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
#line 496 "AdvancedModule.cs"
                    {
#line 496 "AdvancedModule.cs"
                        int segment = 1;
                        while (true)
                        {
                            if (!(((segment) < (hull_count))))
                                break;
#line 497 "AdvancedModule.cs"
                            {
#line 498 "AdvancedModule.cs"
                                int start = (hull)[csharp2cuda_i32_sub(segment, 1)];
#line 499 "AdvancedModule.cs"
                                int end = (hull)[segment];
#line 500 "AdvancedModule.cs"
                                {
#line 500 "AdvancedModule.cs"
                                    int index = start;
                                    while (true)
                                    {
                                        if (!(((index) <= (end))))
                                            break;
#line 501 "AdvancedModule.cs"
                                        {
#line 502 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(((double)(csharp2cuda_i32_sub(index, start))), ((double)(csharp2cuda_i32_sub(end, start))));
#line 503 "AdvancedModule.cs"
#line 503 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_323 = &((result)[index]);
#line 503 "AdvancedModule.cs"
                                            double csharp2cuda_temp_324 = (a)[start];
#line 503 "AdvancedModule.cs"
                                            double csharp2cuda_temp_325 = (a)[end];
                                            (*(csharp2cuda_temp_323) = __dadd_rn(__dmul_rn(csharp2cuda_temp_324, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_325, weight)));
                                        }
#line 500 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_322 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_322));
                                    }
                                }
                            }
#line 496 "AdvancedModule.cs"
                            int* csharp2cuda_temp_321 = &(segment);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_321));
                        }
                    }
#line 506 "AdvancedModule.cs"
                    break;
                }
#line 508 "AdvancedModule.cs"
            case 14:
#line 509 "AdvancedModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 510 "AdvancedModule.cs"
                {
#line 511 "AdvancedModule.cs"
#line 511 "AdvancedModule.cs"
                    int* csharp2cuda_temp_326 = &((output)->valid);
                    (*(csharp2cuda_temp_326) = 0);
#line 512 "AdvancedModule.cs"
                    break;
                }
#line 514 "AdvancedModule.cs"
                {
#line 514 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 514 "AdvancedModule.cs"
                        int csharp2cuda_temp_328 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_328))))
                            break;
#line 515 "AdvancedModule.cs"
#line 515 "AdvancedModule.cs"
                        double* csharp2cuda_temp_329 = &((scratch)[index]);
#line 515 "AdvancedModule.cs"
                        double csharp2cuda_temp_330 = (a)[index];
                        (*(csharp2cuda_temp_329) = csharp2cuda_temp_330);
#line 514 "AdvancedModule.cs"
                        int* csharp2cuda_temp_327 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_327));
                    }
                }
#line 516 "AdvancedModule.cs"
#line 516 "AdvancedModule.cs"
                int* csharp2cuda_temp_331 = &((output)->boolean_value);
                (*(csharp2cuda_temp_331) = 1);
#line 517 "AdvancedModule.cs"
                {
#line 517 "AdvancedModule.cs"
                    int order = 0;
#line 517 "AdvancedModule.cs"
                    int length = (first)->count;
                    while (true)
                    {
#line 518 "AdvancedModule.cs"
                        int csharp2cuda_temp_334 = (first)->count;
#line 518 "AdvancedModule.cs"
                        bool csharp2cuda_temp_335;
#line 518 "AdvancedModule.cs"
                        if (((order) < (csharp2cuda_temp_334)))
                        {
#line 518 "AdvancedModule.cs"
                            csharp2cuda_temp_335 = (output)->boolean_value;
                        }
                        else
                        {
#line 518 "AdvancedModule.cs"
                            csharp2cuda_temp_335 = false;
                        }
                        if (!(csharp2cuda_temp_335))
                            break;
#line 520 "AdvancedModule.cs"
                        {
#line 521 "AdvancedModule.cs"
                            double csharp2cuda_temp_336;
#line 521 "AdvancedModule.cs"
                            if (((csharp2cuda_i32_and(order, 1)) == (0)))
                            {
#line 521 "AdvancedModule.cs"
                                csharp2cuda_temp_336 = 1.0;
                            }
                            else
                            {
#line 521 "AdvancedModule.cs"
                                csharp2cuda_temp_336 = (-(1.0));
                            }
#line 521 "AdvancedModule.cs"
                            double sign = csharp2cuda_temp_336;
#line 522 "AdvancedModule.cs"
                            {
#line 522 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 523 "AdvancedModule.cs"
#line 523 "AdvancedModule.cs"
                                    double csharp2cuda_temp_338 = (scratch)[index];
                                    if (((__dmul_rn(sign, csharp2cuda_temp_338)) < (0.0)))
#line 524 "AdvancedModule.cs"
                                    {
#line 525 "AdvancedModule.cs"
#line 525 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_339 = &((output)->boolean_value);
                                        (*(csharp2cuda_temp_339) = 0);
#line 526 "AdvancedModule.cs"
                                        break;
                                    }
#line 522 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_337 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_337));
                                }
                            }
#line 528 "AdvancedModule.cs"
                            {
#line 528 "AdvancedModule.cs"
                                int index = 1;
                                while (true)
                                {
#line 528 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_341 = (output)->boolean_value;
#line 528 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_342;
#line 528 "AdvancedModule.cs"
                                    if (csharp2cuda_temp_341)
                                    {
#line 528 "AdvancedModule.cs"
                                        csharp2cuda_temp_342 = ((index) < (length));
                                    }
                                    else
                                    {
#line 528 "AdvancedModule.cs"
                                        csharp2cuda_temp_342 = false;
                                    }
                                    if (!(csharp2cuda_temp_342))
                                        break;
#line 529 "AdvancedModule.cs"
#line 529 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_343 = &((scratch)[csharp2cuda_i32_sub(index, 1)]);
#line 529 "AdvancedModule.cs"
                                    double csharp2cuda_temp_344 = (scratch)[index];
#line 529 "AdvancedModule.cs"
                                    double csharp2cuda_temp_345 = (scratch)[csharp2cuda_i32_sub(index, 1)];
                                    (*(csharp2cuda_temp_343) = __dsub_rn(csharp2cuda_temp_344, csharp2cuda_temp_345));
#line 528 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_340 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                                }
                            }
                        }
#line 519 "AdvancedModule.cs"
                        int* csharp2cuda_temp_332 = &(order);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_332));
#line 519 "AdvancedModule.cs"
                        int* csharp2cuda_temp_333 = &(length);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_333));
                    }
                }
#line 531 "AdvancedModule.cs"
                break;
#line 532 "AdvancedModule.cs"
            case 15:
#line 533 "AdvancedModule.cs"
#line 533 "AdvancedModule.cs"
                int* csharp2cuda_temp_346 = &((output)->boolean_value);
                (*(csharp2cuda_temp_346) = 1);
#line 534 "AdvancedModule.cs"
                {
#line 534 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 534 "AdvancedModule.cs"
                        int csharp2cuda_temp_348 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_348))))
                            break;
#line 535 "AdvancedModule.cs"
#line 535 "AdvancedModule.cs"
                        double csharp2cuda_temp_349 = (a)[index];
                        if (((csharp2cuda_temp_349) < (0.0)))
                        {
#line 535 "AdvancedModule.cs"
#line 535 "AdvancedModule.cs"
                            int* csharp2cuda_temp_350 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_350) = 0);
                        }
#line 534 "AdvancedModule.cs"
                        int* csharp2cuda_temp_347 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_347));
                    }
                }
#line 536 "AdvancedModule.cs"
                {
#line 536 "AdvancedModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 536 "AdvancedModule.cs"
                        bool csharp2cuda_temp_352 = (output)->boolean_value;
#line 536 "AdvancedModule.cs"
                        bool csharp2cuda_temp_353;
#line 536 "AdvancedModule.cs"
                        if (csharp2cuda_temp_352)
                        {
#line 536 "AdvancedModule.cs"
                            int csharp2cuda_temp_354 = (first)->count;
#line 536 "AdvancedModule.cs"
                            csharp2cuda_temp_353 = ((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_354, 1)));
                        }
                        else
                        {
#line 536 "AdvancedModule.cs"
                            csharp2cuda_temp_353 = false;
                        }
                        if (!(csharp2cuda_temp_353))
                            break;
#line 537 "AdvancedModule.cs"
#line 537 "AdvancedModule.cs"
                        double csharp2cuda_temp_355 = (a)[index];
#line 537 "AdvancedModule.cs"
                        double csharp2cuda_temp_356 = (a)[index];
#line 537 "AdvancedModule.cs"
                        double csharp2cuda_temp_357 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 537 "AdvancedModule.cs"
                        double csharp2cuda_temp_358 = (a)[csharp2cuda_i32_add(index, 1)];
                        if (((__dmul_rn(csharp2cuda_temp_355, csharp2cuda_temp_356)) < (__dmul_rn(csharp2cuda_temp_357, csharp2cuda_temp_358))))
                        {
#line 538 "AdvancedModule.cs"
#line 538 "AdvancedModule.cs"
                            int* csharp2cuda_temp_359 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_359) = 0);
                        }
#line 536 "AdvancedModule.cs"
                        int* csharp2cuda_temp_351 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_351));
                    }
                }
#line 539 "AdvancedModule.cs"
                break;
#line 540 "AdvancedModule.cs"
            case 17:
#line 541 "AdvancedModule.cs"
#line 541 "AdvancedModule.cs"
                int csharp2cuda_temp_360 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_360);
#line 542 "AdvancedModule.cs"
#line 542 "AdvancedModule.cs"
                int csharp2cuda_temp_361 = (first)->count;
#line 542 "AdvancedModule.cs"
                bool csharp2cuda_temp_362 = mathblocks_advanced_distribution(a, csharp2cuda_temp_361);
                if ((!(csharp2cuda_temp_362)))
#line 543 "AdvancedModule.cs"
                {
#line 544 "AdvancedModule.cs"
#line 544 "AdvancedModule.cs"
                    int* csharp2cuda_temp_363 = &((output)->valid);
                    (*(csharp2cuda_temp_363) = 0);
#line 545 "AdvancedModule.cs"
                    break;
                }
#line 547 "AdvancedModule.cs"
                {
#line 548 "AdvancedModule.cs"
                    double survival = 1.0;
#line 549 "AdvancedModule.cs"
                    {
#line 549 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 549 "AdvancedModule.cs"
                            int csharp2cuda_temp_365 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_365))))
                                break;
#line 550 "AdvancedModule.cs"
                            {
#line 551 "AdvancedModule.cs"
#line 551 "AdvancedModule.cs"
                                double* csharp2cuda_temp_366 = &((result)[index]);
#line 551 "AdvancedModule.cs"
                                double csharp2cuda_temp_367 = (a)[index];
#line 551 "AdvancedModule.cs"
                                double csharp2cuda_temp_368 = __ddiv_rn(csharp2cuda_temp_367, survival);
                                (*(csharp2cuda_temp_366) = csharp2cuda_temp_368);
#line 552 "AdvancedModule.cs"
#line 552 "AdvancedModule.cs"
                                double* csharp2cuda_temp_369 = &(survival);
#line 552 "AdvancedModule.cs"
                                double csharp2cuda_temp_370 = *(csharp2cuda_temp_369);
#line 552 "AdvancedModule.cs"
                                double csharp2cuda_temp_371 = (a)[index];
                                (*(csharp2cuda_temp_369) = __dsub_rn(csharp2cuda_temp_370, csharp2cuda_temp_371));
                            }
#line 549 "AdvancedModule.cs"
                            int* csharp2cuda_temp_364 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_364));
                        }
                    }
#line 554 "AdvancedModule.cs"
                    break;
                }
#line 556 "AdvancedModule.cs"
            case 18:
#line 557 "AdvancedModule.cs"
#line 557 "AdvancedModule.cs"
                int csharp2cuda_temp_372 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_372);
#line 558 "AdvancedModule.cs"
#line 558 "AdvancedModule.cs"
                int csharp2cuda_temp_373 = (first)->count;
#line 558 "AdvancedModule.cs"
                int csharp2cuda_temp_374 = (second)->count;
                if (((csharp2cuda_temp_373) != (csharp2cuda_temp_374)))
#line 559 "AdvancedModule.cs"
                {
#line 560 "AdvancedModule.cs"
#line 560 "AdvancedModule.cs"
                    int* csharp2cuda_temp_375 = &((output)->valid);
                    (*(csharp2cuda_temp_375) = 0);
#line 561 "AdvancedModule.cs"
                    break;
                }
#line 563 "AdvancedModule.cs"
                {
#line 564 "AdvancedModule.cs"
                    double survival = 1.0;
#line 565 "AdvancedModule.cs"
                    {
#line 565 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 565 "AdvancedModule.cs"
                            int csharp2cuda_temp_377 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_377))))
                                break;
#line 566 "AdvancedModule.cs"
                            {
#line 567 "AdvancedModule.cs"
#line 567 "AdvancedModule.cs"
                                double csharp2cuda_temp_378 = (a)[index];
#line 567 "AdvancedModule.cs"
                                bool csharp2cuda_temp_379;
#line 567 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_378) < (0.0))))
                                {
#line 567 "AdvancedModule.cs"
                                    double csharp2cuda_temp_380 = (b)[index];
#line 567 "AdvancedModule.cs"
                                    csharp2cuda_temp_379 = ((csharp2cuda_temp_380) <= (0.0));
                                }
                                else
                                {
#line 567 "AdvancedModule.cs"
                                    csharp2cuda_temp_379 = true;
                                }
#line 567 "AdvancedModule.cs"
                                bool csharp2cuda_temp_381;
#line 567 "AdvancedModule.cs"
                                if (!(csharp2cuda_temp_379))
                                {
#line 567 "AdvancedModule.cs"
                                    double csharp2cuda_temp_382 = (a)[index];
#line 567 "AdvancedModule.cs"
                                    double csharp2cuda_temp_383 = (b)[index];
#line 567 "AdvancedModule.cs"
                                    csharp2cuda_temp_381 = ((csharp2cuda_temp_382) > (csharp2cuda_temp_383));
                                }
                                else
                                {
#line 567 "AdvancedModule.cs"
                                    csharp2cuda_temp_381 = true;
                                }
                                if (csharp2cuda_temp_381)
#line 568 "AdvancedModule.cs"
                                {
#line 569 "AdvancedModule.cs"
#line 569 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_384 = &((output)->valid);
                                    (*(csharp2cuda_temp_384) = 0);
#line 570 "AdvancedModule.cs"
                                    break;
                                }
#line 572 "AdvancedModule.cs"
#line 572 "AdvancedModule.cs"
                                double* csharp2cuda_temp_385 = &(survival);
#line 572 "AdvancedModule.cs"
                                double csharp2cuda_temp_386 = *(csharp2cuda_temp_385);
#line 572 "AdvancedModule.cs"
                                double csharp2cuda_temp_387 = (a)[index];
#line 572 "AdvancedModule.cs"
                                double csharp2cuda_temp_388 = (b)[index];
#line 572 "AdvancedModule.cs"
                                double csharp2cuda_temp_389 = __ddiv_rn(csharp2cuda_temp_387, csharp2cuda_temp_388);
                                (*(csharp2cuda_temp_385) = __dmul_rn(csharp2cuda_temp_386, __dsub_rn(1.0, csharp2cuda_temp_389)));
#line 573 "AdvancedModule.cs"
#line 573 "AdvancedModule.cs"
                                double* csharp2cuda_temp_390 = &((result)[index]);
                                (*(csharp2cuda_temp_390) = survival);
                            }
#line 565 "AdvancedModule.cs"
                            int* csharp2cuda_temp_376 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
                        }
                    }
#line 575 "AdvancedModule.cs"
                    break;
                }
        }
#line 579 "AdvancedModule.cs"
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_391 = (output)->valid;
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_392;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_391)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_392 = ((opcode) != (1));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_392 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_393;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_392)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_393 = ((opcode) != (2));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_393 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_394;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_393)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_394 = ((opcode) != (3));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_394 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_395;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_394)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_395 = ((opcode) != (4));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_395 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_396;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_395)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_396 = ((opcode) != (5));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_396 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_397;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_396)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_397 = ((opcode) != (7));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_397 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_398;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_397)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_398 = ((opcode) != (9));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_398 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_399;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_398)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_399 = ((opcode) != (10));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_399 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_400;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_399)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_400 = ((opcode) != (11));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_400 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_401;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_400)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_401 = ((opcode) != (13));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_401 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_402;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_401)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_402 = ((opcode) != (14));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_402 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_403;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_402)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_403 = ((opcode) != (15));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_403 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_404;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_403)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_404 = ((opcode) != (16));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_404 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_405;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_404)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_405 = ((opcode) != (17));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_405 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_406;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_405)
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_406 = ((opcode) != (18));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_406 = false;
        }
#line 579 "AdvancedModule.cs"
        bool csharp2cuda_temp_407;
#line 579 "AdvancedModule.cs"
        if (csharp2cuda_temp_406)
        {
#line 583 "AdvancedModule.cs"
            double csharp2cuda_temp_408 = (output)->scalar_value;
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_407 = (!(isfinite(csharp2cuda_temp_408)));
        }
        else
        {
#line 579 "AdvancedModule.cs"
            csharp2cuda_temp_407 = false;
        }
        if (csharp2cuda_temp_407)
#line 584 "AdvancedModule.cs"
        {
#line 585 "AdvancedModule.cs"
#line 585 "AdvancedModule.cs"
            int* csharp2cuda_temp_409 = &((output)->valid);
            (*(csharp2cuda_temp_409) = 0);
        }
#line 587 "AdvancedModule.cs"
#line 587 "AdvancedModule.cs"
        bool csharp2cuda_temp_410 = (output)->valid;
#line 587 "AdvancedModule.cs"
        bool csharp2cuda_temp_411;
#line 587 "AdvancedModule.cs"
        if (csharp2cuda_temp_410)
        {
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_412;
#line 588 "AdvancedModule.cs"
            if (!(((opcode) == (2))))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_412 = ((opcode) == (3));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_412 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_413;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_412))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_413 = ((opcode) == (4));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_413 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_414;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_413))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_414 = ((opcode) == (5));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_414 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_415;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_414))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_415 = ((opcode) == (7));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_415 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_416;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_415))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_416 = ((opcode) == (9));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_416 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_417;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_416))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_417 = ((opcode) == (10));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_417 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_418;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_417))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_418 = ((opcode) == (13));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_418 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_419;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_418))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_419 = ((opcode) == (16));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_419 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_420;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_419))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_420 = ((opcode) == (17));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_420 = true;
            }
#line 588 "AdvancedModule.cs"
            bool csharp2cuda_temp_421;
#line 588 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_420))
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_421 = ((opcode) == (18));
            }
            else
            {
#line 588 "AdvancedModule.cs"
                csharp2cuda_temp_421 = true;
            }
#line 587 "AdvancedModule.cs"
            csharp2cuda_temp_411 = csharp2cuda_temp_421;
        }
        else
        {
#line 587 "AdvancedModule.cs"
            csharp2cuda_temp_411 = false;
        }
        if (csharp2cuda_temp_411)
#line 591 "AdvancedModule.cs"
        {
#line 592 "AdvancedModule.cs"
            {
#line 592 "AdvancedModule.cs"
                int index = 0;
                while (true)
                {
#line 592 "AdvancedModule.cs"
                    int csharp2cuda_temp_423 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_423))))
                        break;
#line 593 "AdvancedModule.cs"
#line 593 "AdvancedModule.cs"
                    double csharp2cuda_temp_424 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_424))))
                    {
#line 593 "AdvancedModule.cs"
#line 593 "AdvancedModule.cs"
                        int* csharp2cuda_temp_425 = &((output)->valid);
                        (*(csharp2cuda_temp_425) = 0);
                    }
#line 592 "AdvancedModule.cs"
                    int* csharp2cuda_temp_422 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_422));
                }
            }
        }
    }
}

#line 85 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count)
#line 87 "AdvancedModule.cs"
{
#line 88 "AdvancedModule.cs"
    return mathblocks_probability_distribution(values, count);
}

#line 76 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value)
#line 78 "AdvancedModule.cs"
{
#line 79 "AdvancedModule.cs"
    double result = 1.0;
#line 80 "AdvancedModule.cs"
    {
#line 80 "AdvancedModule.cs"
        int index = 2;
        while (true)
        {
            if (!(((index) <= (value))))
                break;
#line 81 "AdvancedModule.cs"
#line 81 "AdvancedModule.cs"
            double* csharp2cuda_temp_1 = &(result);
#line 81 "AdvancedModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
            (*(csharp2cuda_temp_1) = __dmul_rn(csharp2cuda_temp_2, ((double)(index))));
#line 80 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 82 "AdvancedModule.cs"
    return result;
}

#line 52 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value)
#line 54 "AdvancedModule.cs"
{
#line 55 "AdvancedModule.cs"
    int result = 0;
#line 56 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) > (1))))
            break;
#line 57 "AdvancedModule.cs"
        {
#line 58 "AdvancedModule.cs"
#line 58 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(value);
#line 58 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_shr(csharp2cuda_temp_1, 1));
#line 59 "AdvancedModule.cs"
#line 59 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(result);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 61 "AdvancedModule.cs"
    return result;
}

#line 64 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value)
#line 66 "AdvancedModule.cs"
{
#line 67 "AdvancedModule.cs"
    int result = 0;
#line 68 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) != (0))))
            break;
#line 69 "AdvancedModule.cs"
        {
#line 70 "AdvancedModule.cs"
#line 70 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(result);
#line 70 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, csharp2cuda_i32_and(value, 1)));
#line 71 "AdvancedModule.cs"
#line 71 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(value);
#line 71 "AdvancedModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_shr(csharp2cuda_temp_3, 1));
        }
    }
#line 73 "AdvancedModule.cs"
    return result;
}

#line 46 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value)
#line 48 "AdvancedModule.cs"
{
#line 49 "AdvancedModule.cs"
#line 49 "AdvancedModule.cs"
    bool csharp2cuda_temp_0;
#line 49 "AdvancedModule.cs"
    if (((value) > (0)))
    {
#line 49 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 49 "AdvancedModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 91 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns)
#line 96 "AdvancedModule.cs"
{
#line 97 "AdvancedModule.cs"
    if (((rows) != (columns)))
    {
#line 98 "AdvancedModule.cs"
        return false;
    }
#line 99 "AdvancedModule.cs"
    {
#line 99 "AdvancedModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (rows))))
                break;
#line 100 "AdvancedModule.cs"
            {
#line 101 "AdvancedModule.cs"
                double sum = 0.0;
#line 102 "AdvancedModule.cs"
                {
#line 102 "AdvancedModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (columns))))
                            break;
#line 103 "AdvancedModule.cs"
                        {
#line 104 "AdvancedModule.cs"
                            double value = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 105 "AdvancedModule.cs"
                            if (((value) < (0.0)))
                            {
#line 106 "AdvancedModule.cs"
                                return false;
                            }
#line 107 "AdvancedModule.cs"
#line 107 "AdvancedModule.cs"
                            double* csharp2cuda_temp_2 = &(sum);
#line 107 "AdvancedModule.cs"
                            double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                            (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, value));
                        }
#line 102 "AdvancedModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 109 "AdvancedModule.cs"
                if (((fabs(__dsub_rn(sum, 1.0))) > (1E-10)))
                {
#line 110 "AdvancedModule.cs"
                    return false;
                }
            }
#line 99 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 112 "AdvancedModule.cs"
    return true;
}