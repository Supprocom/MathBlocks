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
    if (((opcode) == (5)))
#line 160 "AdvancedModule.cs"
    {
#line 161 "AdvancedModule.cs"
        int csharp2cuda_temp_25 = (first)->count;
#line 161 "AdvancedModule.cs"
        bool csharp2cuda_temp_26;
#line 161 "AdvancedModule.cs"
        if (!(((csharp2cuda_temp_25) <= (0))))
        {
#line 161 "AdvancedModule.cs"
            int csharp2cuda_temp_27 = (first)->count;
#line 161 "AdvancedModule.cs"
            int csharp2cuda_temp_28 = (second)->count;
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_26 = ((csharp2cuda_temp_27) != (csharp2cuda_temp_28));
        }
        else
        {
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_26 = true;
        }
#line 161 "AdvancedModule.cs"
        bool csharp2cuda_temp_29;
#line 161 "AdvancedModule.cs"
        if (!(csharp2cuda_temp_26))
        {
#line 161 "AdvancedModule.cs"
            double csharp2cuda_temp_30 = (fourth)->scalar_value;
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_29 = ((csharp2cuda_temp_30) < (0.0));
        }
        else
        {
#line 161 "AdvancedModule.cs"
            csharp2cuda_temp_29 = true;
        }
#line 161 "AdvancedModule.cs"
        bool lipschitz_invalid = csharp2cuda_temp_29;
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
                    int csharp2cuda_temp_33 = (third)->count;
                    if (!(((query) < (csharp2cuda_temp_33))))
                        break;
#line 165 "AdvancedModule.cs"
                    {
#line 166 "AdvancedModule.cs"
                        double selected = (-(mathblocks_positive_infinity()));
#line 167 "AdvancedModule.cs"
                        {
#line 167 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 167 "AdvancedModule.cs"
                                int csharp2cuda_temp_35 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_35))))
                                    break;
#line 168 "AdvancedModule.cs"
                                {
#line 169 "AdvancedModule.cs"
                                    double csharp2cuda_temp_36 = (b)[index];
#line 169 "AdvancedModule.cs"
                                    double csharp2cuda_temp_37 = (fourth)->scalar_value;
#line 169 "AdvancedModule.cs"
                                    double csharp2cuda_temp_38 = (c)[query];
#line 169 "AdvancedModule.cs"
                                    double csharp2cuda_temp_39 = (a)[index];
#line 169 "AdvancedModule.cs"
                                    double candidate = __dsub_rn(csharp2cuda_temp_36, __dmul_rn(csharp2cuda_temp_37, fabs(__dsub_rn(csharp2cuda_temp_38, csharp2cuda_temp_39))));
#line 172 "AdvancedModule.cs"
#line 172 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_40 = &(selected);
                                    (*(csharp2cuda_temp_40) = mathblocks_maximum(selected, candidate));
                                }
#line 167 "AdvancedModule.cs"
                                int* csharp2cuda_temp_34 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_34));
                            }
                        }
#line 174 "AdvancedModule.cs"
#line 174 "AdvancedModule.cs"
                        double* csharp2cuda_temp_41 = &((result)[query]);
                        (*(csharp2cuda_temp_41) = selected);
                    }
#line 164 "AdvancedModule.cs"
                    int* csharp2cuda_temp_31 = &(query);
#line 164 "AdvancedModule.cs"
                    int csharp2cuda_temp_32 = *(csharp2cuda_temp_31);
                    (*(csharp2cuda_temp_31) = csharp2cuda_i32_add(csharp2cuda_temp_32, blockDim.x));
                }
            }
        }
#line 177 "AdvancedModule.cs"
        __syncthreads();
    }
#line 180 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 181 "AdvancedModule.cs"
    {
#line 182 "AdvancedModule.cs"
        switch (opcode)
        {
#line 184 "AdvancedModule.cs"
            case 0:
#line 185 "AdvancedModule.cs"
#line 185 "AdvancedModule.cs"
                int csharp2cuda_temp_42 = (first)->count;
#line 185 "AdvancedModule.cs"
                bool csharp2cuda_temp_43;
#line 185 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_42) <= (0))))
                {
#line 185 "AdvancedModule.cs"
                    int csharp2cuda_temp_44 = (first)->count;
#line 185 "AdvancedModule.cs"
                    csharp2cuda_temp_43 = ((csharp2cuda_temp_44) >= (31));
                }
                else
                {
#line 185 "AdvancedModule.cs"
                    csharp2cuda_temp_43 = true;
                }
#line 185 "AdvancedModule.cs"
                bool csharp2cuda_temp_45;
#line 185 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_43))
                {
#line 186 "AdvancedModule.cs"
                    int csharp2cuda_temp_46 = (second)->count;
#line 186 "AdvancedModule.cs"
                    int csharp2cuda_temp_47 = (first)->count;
#line 185 "AdvancedModule.cs"
                    csharp2cuda_temp_45 = ((csharp2cuda_temp_46) != (csharp2cuda_i32_shl(1, csharp2cuda_temp_47)));
                }
                else
                {
#line 185 "AdvancedModule.cs"
                    csharp2cuda_temp_45 = true;
                }
#line 185 "AdvancedModule.cs"
                bool csharp2cuda_temp_48;
#line 185 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_45))
                {
#line 185 "AdvancedModule.cs"
                    csharp2cuda_temp_48 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 185 "AdvancedModule.cs"
                    csharp2cuda_temp_48 = true;
                }
                if (csharp2cuda_temp_48)
#line 187 "AdvancedModule.cs"
                {
#line 188 "AdvancedModule.cs"
#line 188 "AdvancedModule.cs"
                    int* csharp2cuda_temp_49 = &((output)->valid);
                    (*(csharp2cuda_temp_49) = 0);
#line 189 "AdvancedModule.cs"
                    break;
                }
#line 191 "AdvancedModule.cs"
                {
#line 191 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 191 "AdvancedModule.cs"
                        int csharp2cuda_temp_51 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_51))))
                            break;
#line 192 "AdvancedModule.cs"
                        {
#line 193 "AdvancedModule.cs"
#line 193 "AdvancedModule.cs"
                            double csharp2cuda_temp_52 = (a)[index];
                            if (((csharp2cuda_temp_52) < (0.0)))
#line 194 "AdvancedModule.cs"
                            {
#line 195 "AdvancedModule.cs"
#line 195 "AdvancedModule.cs"
                                int* csharp2cuda_temp_53 = &((output)->valid);
                                (*(csharp2cuda_temp_53) = 0);
#line 196 "AdvancedModule.cs"
                                break;
                            }
#line 198 "AdvancedModule.cs"
                            int position = index;
#line 199 "AdvancedModule.cs"
                            while (true)
                            {
#line 199 "AdvancedModule.cs"
                                bool csharp2cuda_temp_54;
#line 199 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 199 "AdvancedModule.cs"
                                    double csharp2cuda_temp_55 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 199 "AdvancedModule.cs"
                                    double csharp2cuda_temp_56 = (a)[csharp2cuda_f64_to_i32(csharp2cuda_temp_55)];
#line 199 "AdvancedModule.cs"
                                    double csharp2cuda_temp_57 = (a)[index];
#line 199 "AdvancedModule.cs"
                                    csharp2cuda_temp_54 = ((csharp2cuda_temp_56) > (csharp2cuda_temp_57));
                                }
                                else
                                {
#line 199 "AdvancedModule.cs"
                                    csharp2cuda_temp_54 = false;
                                }
                                if (!(csharp2cuda_temp_54))
                                    break;
#line 200 "AdvancedModule.cs"
                                {
#line 201 "AdvancedModule.cs"
#line 201 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_58 = &((scratch)[position]);
#line 201 "AdvancedModule.cs"
                                    double csharp2cuda_temp_59 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                                    (*(csharp2cuda_temp_58) = csharp2cuda_temp_59);
#line 202 "AdvancedModule.cs"
#line 202 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_60 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_60));
                                }
                            }
#line 204 "AdvancedModule.cs"
#line 204 "AdvancedModule.cs"
                            double* csharp2cuda_temp_61 = &((scratch)[position]);
                            (*(csharp2cuda_temp_61) = ((double)(index)));
                        }
#line 191 "AdvancedModule.cs"
                        int* csharp2cuda_temp_50 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_50));
                    }
                }
#line 206 "AdvancedModule.cs"
                if ((output)->valid)
#line 207 "AdvancedModule.cs"
                {
#line 208 "AdvancedModule.cs"
                    double total = 0.0;
#line 209 "AdvancedModule.cs"
                    double previous = 0.0;
#line 210 "AdvancedModule.cs"
                    {
#line 210 "AdvancedModule.cs"
                        int position = 0;
                        while (true)
                        {
#line 210 "AdvancedModule.cs"
                            int csharp2cuda_temp_63 = (first)->count;
                            if (!(((position) < (csharp2cuda_temp_63))))
                                break;
#line 211 "AdvancedModule.cs"
                            {
#line 212 "AdvancedModule.cs"
                                int coalition = 0;
#line 213 "AdvancedModule.cs"
                                {
#line 213 "AdvancedModule.cs"
                                    int index = position;
                                    while (true)
                                    {
#line 213 "AdvancedModule.cs"
                                        int csharp2cuda_temp_65 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_65))))
                                            break;
#line 214 "AdvancedModule.cs"
#line 214 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_66 = &(coalition);
#line 214 "AdvancedModule.cs"
                                        int csharp2cuda_temp_67 = *(csharp2cuda_temp_66);
#line 214 "AdvancedModule.cs"
                                        double csharp2cuda_temp_68 = (scratch)[index];
                                        (*(csharp2cuda_temp_66) = csharp2cuda_i32_or(csharp2cuda_temp_67, csharp2cuda_i32_shl(1, csharp2cuda_f64_to_i32(csharp2cuda_temp_68))));
#line 213 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_64 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                                    }
                                }
#line 215 "AdvancedModule.cs"
                                double csharp2cuda_temp_69 = (scratch)[position];
#line 215 "AdvancedModule.cs"
                                int ordered = csharp2cuda_f64_to_i32(csharp2cuda_temp_69);
#line 216 "AdvancedModule.cs"
#line 216 "AdvancedModule.cs"
                                double* csharp2cuda_temp_70 = &(total);
#line 216 "AdvancedModule.cs"
                                double csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
#line 216 "AdvancedModule.cs"
                                double csharp2cuda_temp_72 = (a)[ordered];
#line 216 "AdvancedModule.cs"
                                double csharp2cuda_temp_73 = (b)[coalition];
                                (*(csharp2cuda_temp_70) = __dadd_rn(csharp2cuda_temp_71, __dmul_rn(__dsub_rn(csharp2cuda_temp_72, previous), csharp2cuda_temp_73)));
#line 217 "AdvancedModule.cs"
#line 217 "AdvancedModule.cs"
                                double* csharp2cuda_temp_74 = &(previous);
#line 217 "AdvancedModule.cs"
                                double csharp2cuda_temp_75 = (a)[ordered];
                                (*(csharp2cuda_temp_74) = csharp2cuda_temp_75);
                            }
#line 210 "AdvancedModule.cs"
                            int* csharp2cuda_temp_62 = &(position);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_62));
                        }
                    }
#line 219 "AdvancedModule.cs"
#line 219 "AdvancedModule.cs"
                    double* csharp2cuda_temp_76 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_76) = total);
                }
#line 221 "AdvancedModule.cs"
                break;
#line 222 "AdvancedModule.cs"
            case 1:
#line 223 "AdvancedModule.cs"
#line 223 "AdvancedModule.cs"
                int csharp2cuda_temp_77 = (first)->count;
#line 223 "AdvancedModule.cs"
                bool csharp2cuda_temp_78;
#line 223 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_77)))))
                {
#line 223 "AdvancedModule.cs"
                    int csharp2cuda_temp_79 = (first)->count;
#line 223 "AdvancedModule.cs"
                    csharp2cuda_temp_78 = ((csharp2cuda_temp_79) > (csharp2cuda_i32_shl(1, 12)));
                }
                else
                {
#line 223 "AdvancedModule.cs"
                    csharp2cuda_temp_78 = true;
                }
                if (csharp2cuda_temp_78)
#line 224 "AdvancedModule.cs"
                {
#line 225 "AdvancedModule.cs"
#line 225 "AdvancedModule.cs"
                    int* csharp2cuda_temp_80 = &((output)->valid);
                    (*(csharp2cuda_temp_80) = 0);
#line 226 "AdvancedModule.cs"
                    break;
                }
#line 228 "AdvancedModule.cs"
#line 228 "AdvancedModule.cs"
                int* csharp2cuda_temp_81 = &((output)->boolean_value);
                (*(csharp2cuda_temp_81) = 1);
#line 229 "AdvancedModule.cs"
                {
#line 229 "AdvancedModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 229 "AdvancedModule.cs"
                        int csharp2cuda_temp_83 = (first)->count;
#line 229 "AdvancedModule.cs"
                        bool csharp2cuda_temp_84;
#line 229 "AdvancedModule.cs"
                        if (((left) < (csharp2cuda_temp_83)))
                        {
#line 229 "AdvancedModule.cs"
                            csharp2cuda_temp_84 = (output)->boolean_value;
                        }
                        else
                        {
#line 229 "AdvancedModule.cs"
                            csharp2cuda_temp_84 = false;
                        }
                        if (!(csharp2cuda_temp_84))
                            break;
#line 230 "AdvancedModule.cs"
                        {
#line 230 "AdvancedModule.cs"
                            int right = 0;
                            while (true)
                            {
#line 230 "AdvancedModule.cs"
                                int csharp2cuda_temp_86 = (first)->count;
                                if (!(((right) < (csharp2cuda_temp_86))))
                                    break;
#line 231 "AdvancedModule.cs"
#line 231 "AdvancedModule.cs"
                                double csharp2cuda_temp_87 = (a)[left];
#line 231 "AdvancedModule.cs"
                                double csharp2cuda_temp_88 = (a)[right];
#line 231 "AdvancedModule.cs"
                                double csharp2cuda_temp_89 = (a)[csharp2cuda_i32_or(left, right)];
#line 231 "AdvancedModule.cs"
                                double csharp2cuda_temp_90 = (a)[csharp2cuda_i32_and(left, right)];
                                if (((__dadd_rn(csharp2cuda_temp_87, csharp2cuda_temp_88)) < (__dadd_rn(csharp2cuda_temp_89, csharp2cuda_temp_90))))
#line 232 "AdvancedModule.cs"
                                {
#line 233 "AdvancedModule.cs"
#line 233 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_91 = &((output)->boolean_value);
                                    (*(csharp2cuda_temp_91) = 0);
#line 234 "AdvancedModule.cs"
                                    break;
                                }
#line 230 "AdvancedModule.cs"
                                int* csharp2cuda_temp_85 = &(right);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_85));
                            }
                        }
#line 229 "AdvancedModule.cs"
                        int* csharp2cuda_temp_82 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_82));
                    }
                }
#line 236 "AdvancedModule.cs"
                break;
#line 237 "AdvancedModule.cs"
            case 2:
#line 238 "AdvancedModule.cs"
#line 238 "AdvancedModule.cs"
                int csharp2cuda_temp_92 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_92);
#line 239 "AdvancedModule.cs"
#line 239 "AdvancedModule.cs"
                int csharp2cuda_temp_93 = (first)->count;
                if ((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_93))))
#line 240 "AdvancedModule.cs"
                {
#line 241 "AdvancedModule.cs"
#line 241 "AdvancedModule.cs"
                    int* csharp2cuda_temp_94 = &((output)->valid);
                    (*(csharp2cuda_temp_94) = 0);
#line 242 "AdvancedModule.cs"
                    break;
                }
#line 244 "AdvancedModule.cs"
                {
#line 244 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 244 "AdvancedModule.cs"
                        int csharp2cuda_temp_96 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_96))))
                            break;
#line 245 "AdvancedModule.cs"
#line 245 "AdvancedModule.cs"
                        double* csharp2cuda_temp_97 = &((result)[index]);
#line 245 "AdvancedModule.cs"
                        double csharp2cuda_temp_98 = (a)[index];
                        (*(csharp2cuda_temp_97) = csharp2cuda_temp_98);
#line 244 "AdvancedModule.cs"
                        int* csharp2cuda_temp_95 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_95));
                    }
                }
#line 246 "AdvancedModule.cs"
                {
#line 246 "AdvancedModule.cs"
                    int bit = 0;
                    while (true)
                    {
#line 246 "AdvancedModule.cs"
                        int csharp2cuda_temp_100 = (first)->count;
                        if (!(((bit) < (mathblocks_advanced_log_two(csharp2cuda_temp_100)))))
                            break;
#line 247 "AdvancedModule.cs"
                        {
#line 247 "AdvancedModule.cs"
                            int mask = 0;
                            while (true)
                            {
#line 247 "AdvancedModule.cs"
                                int csharp2cuda_temp_102 = (first)->count;
                                if (!(((mask) < (csharp2cuda_temp_102))))
                                    break;
#line 248 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, bit))) != (0)))
                                {
#line 249 "AdvancedModule.cs"
#line 249 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_103 = &((result)[mask]);
#line 249 "AdvancedModule.cs"
                                    double csharp2cuda_temp_104 = *(csharp2cuda_temp_103);
#line 249 "AdvancedModule.cs"
                                    double csharp2cuda_temp_105 = (result)[csharp2cuda_i32_xor(mask, csharp2cuda_i32_shl(1, bit))];
                                    (*(csharp2cuda_temp_103) = __dsub_rn(csharp2cuda_temp_104, csharp2cuda_temp_105));
                                }
#line 247 "AdvancedModule.cs"
                                int* csharp2cuda_temp_101 = &(mask);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_101));
                            }
                        }
#line 246 "AdvancedModule.cs"
                        int* csharp2cuda_temp_99 = &(bit);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_99));
                    }
                }
#line 250 "AdvancedModule.cs"
                break;
#line 251 "AdvancedModule.cs"
            case 3:
#line 252 "AdvancedModule.cs"
#line 252 "AdvancedModule.cs"
                int csharp2cuda_temp_106 = (first)->count;
#line 252 "AdvancedModule.cs"
                bool csharp2cuda_temp_107;
#line 252 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_106)))))
                {
#line 252 "AdvancedModule.cs"
                    int csharp2cuda_temp_108 = (first)->count;
#line 252 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = ((csharp2cuda_temp_108) > (csharp2cuda_i32_shl(1, 20)));
                }
                else
                {
#line 252 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = true;
                }
                if (csharp2cuda_temp_107)
#line 253 "AdvancedModule.cs"
                {
#line 254 "AdvancedModule.cs"
#line 254 "AdvancedModule.cs"
                    int* csharp2cuda_temp_109 = &((output)->valid);
                    (*(csharp2cuda_temp_109) = 0);
#line 255 "AdvancedModule.cs"
                    break;
                }
#line 257 "AdvancedModule.cs"
                {
#line 258 "AdvancedModule.cs"
                    int csharp2cuda_temp_110 = (first)->count;
#line 258 "AdvancedModule.cs"
                    int player_count = mathblocks_advanced_log_two(csharp2cuda_temp_110);
#line 259 "AdvancedModule.cs"
                    mathblocks_sequence_set_vector_shape(output, player_count);
#line 260 "AdvancedModule.cs"
                    double denominator = mathblocks_advanced_factorial(player_count);
#line 261 "AdvancedModule.cs"
                    {
#line 261 "AdvancedModule.cs"
                        int player = 0;
                        while (true)
                        {
                            if (!(((player) < (player_count))))
                                break;
#line 262 "AdvancedModule.cs"
                            {
#line 263 "AdvancedModule.cs"
#line 263 "AdvancedModule.cs"
                                double* csharp2cuda_temp_112 = &((result)[player]);
                                (*(csharp2cuda_temp_112) = 0.0);
#line 264 "AdvancedModule.cs"
                                {
#line 264 "AdvancedModule.cs"
                                    int coalition = 0;
                                    while (true)
                                    {
#line 264 "AdvancedModule.cs"
                                        int csharp2cuda_temp_114 = (first)->count;
                                        if (!(((coalition) < (csharp2cuda_temp_114))))
                                            break;
#line 265 "AdvancedModule.cs"
                                        {
#line 266 "AdvancedModule.cs"
                                            if (((csharp2cuda_i32_and(coalition, csharp2cuda_i32_shl(1, player))) != (0)))
                                            {
#line 267 "AdvancedModule.cs"
                                                goto csharp2cuda_for_continue_11;
                                            }
#line 268 "AdvancedModule.cs"
                                            int size = mathblocks_advanced_popcount(coalition);
#line 269 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(__dmul_rn(mathblocks_advanced_factorial(size), mathblocks_advanced_factorial(csharp2cuda_i32_sub(csharp2cuda_i32_sub(player_count, size), 1))), denominator);
#line 272 "AdvancedModule.cs"
#line 272 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_115 = &((result)[player]);
#line 272 "AdvancedModule.cs"
                                            double csharp2cuda_temp_116 = *(csharp2cuda_temp_115);
#line 273 "AdvancedModule.cs"
                                            double csharp2cuda_temp_117 = (a)[csharp2cuda_i32_or(coalition, csharp2cuda_i32_shl(1, player))];
#line 273 "AdvancedModule.cs"
                                            double csharp2cuda_temp_118 = (a)[coalition];
                                            (*(csharp2cuda_temp_115) = __dadd_rn(csharp2cuda_temp_116, __dmul_rn(weight, __dsub_rn(csharp2cuda_temp_117, csharp2cuda_temp_118))));
                                        }
                                        csharp2cuda_for_continue_11:
#line 264 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_113 = &(coalition);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                                    }
                                }
                            }
#line 261 "AdvancedModule.cs"
                            int* csharp2cuda_temp_111 = &(player);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_111));
                        }
                    }
#line 276 "AdvancedModule.cs"
                    break;
                }
#line 278 "AdvancedModule.cs"
            case 4:
            case 5:
#line 280 "AdvancedModule.cs"
#line 280 "AdvancedModule.cs"
                int csharp2cuda_temp_119 = (third)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_119);
#line 281 "AdvancedModule.cs"
#line 281 "AdvancedModule.cs"
                int csharp2cuda_temp_120 = (first)->count;
#line 281 "AdvancedModule.cs"
                bool csharp2cuda_temp_121;
#line 281 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_120) <= (0))))
                {
#line 281 "AdvancedModule.cs"
                    int csharp2cuda_temp_122 = (first)->count;
#line 281 "AdvancedModule.cs"
                    int csharp2cuda_temp_123 = (second)->count;
#line 281 "AdvancedModule.cs"
                    csharp2cuda_temp_121 = ((csharp2cuda_temp_122) != (csharp2cuda_temp_123));
                }
                else
                {
#line 281 "AdvancedModule.cs"
                    csharp2cuda_temp_121 = true;
                }
#line 281 "AdvancedModule.cs"
                bool csharp2cuda_temp_124;
#line 281 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_121))
                {
#line 281 "AdvancedModule.cs"
                    double csharp2cuda_temp_125 = (fourth)->scalar_value;
#line 281 "AdvancedModule.cs"
                    csharp2cuda_temp_124 = ((csharp2cuda_temp_125) < (0.0));
                }
                else
                {
#line 281 "AdvancedModule.cs"
                    csharp2cuda_temp_124 = true;
                }
                if (csharp2cuda_temp_124)
#line 282 "AdvancedModule.cs"
                {
#line 283 "AdvancedModule.cs"
#line 283 "AdvancedModule.cs"
                    int* csharp2cuda_temp_126 = &((output)->valid);
                    (*(csharp2cuda_temp_126) = 0);
#line 284 "AdvancedModule.cs"
                    break;
                }
#line 286 "AdvancedModule.cs"
                if (((opcode) == (5)))
                {
#line 287 "AdvancedModule.cs"
                    break;
                }
#line 288 "AdvancedModule.cs"
                {
#line 288 "AdvancedModule.cs"
                    int query = 0;
                    while (true)
                    {
#line 288 "AdvancedModule.cs"
                        int csharp2cuda_temp_128 = (third)->count;
                        if (!(((query) < (csharp2cuda_temp_128))))
                            break;
#line 289 "AdvancedModule.cs"
                        {
#line 290 "AdvancedModule.cs"
                            double csharp2cuda_temp_129;
#line 290 "AdvancedModule.cs"
                            if (((opcode) == (4)))
                            {
#line 290 "AdvancedModule.cs"
                                csharp2cuda_temp_129 = mathblocks_positive_infinity();
                            }
                            else
                            {
#line 290 "AdvancedModule.cs"
                                csharp2cuda_temp_129 = (-(mathblocks_positive_infinity()));
                            }
#line 290 "AdvancedModule.cs"
                            double selected = csharp2cuda_temp_129;
#line 293 "AdvancedModule.cs"
                            {
#line 293 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
#line 293 "AdvancedModule.cs"
                                    int csharp2cuda_temp_131 = (first)->count;
                                    if (!(((index) < (csharp2cuda_temp_131))))
                                        break;
#line 294 "AdvancedModule.cs"
                                    {
#line 295 "AdvancedModule.cs"
                                        double csharp2cuda_temp_132;
#line 295 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 296 "AdvancedModule.cs"
                                            double csharp2cuda_temp_133 = (b)[index];
#line 296 "AdvancedModule.cs"
                                            double csharp2cuda_temp_134 = (fourth)->scalar_value;
#line 296 "AdvancedModule.cs"
                                            double csharp2cuda_temp_135 = (c)[query];
#line 296 "AdvancedModule.cs"
                                            double csharp2cuda_temp_136 = (a)[index];
#line 295 "AdvancedModule.cs"
                                            csharp2cuda_temp_132 = __dadd_rn(csharp2cuda_temp_133, __dmul_rn(csharp2cuda_temp_134, fabs(__dsub_rn(csharp2cuda_temp_135, csharp2cuda_temp_136))));
                                        }
                                        else
                                        {
#line 297 "AdvancedModule.cs"
                                            double csharp2cuda_temp_137 = (b)[index];
#line 297 "AdvancedModule.cs"
                                            double csharp2cuda_temp_138 = (fourth)->scalar_value;
#line 297 "AdvancedModule.cs"
                                            double csharp2cuda_temp_139 = (c)[query];
#line 297 "AdvancedModule.cs"
                                            double csharp2cuda_temp_140 = (a)[index];
#line 295 "AdvancedModule.cs"
                                            csharp2cuda_temp_132 = __dsub_rn(csharp2cuda_temp_137, __dmul_rn(csharp2cuda_temp_138, fabs(__dsub_rn(csharp2cuda_temp_139, csharp2cuda_temp_140))));
                                        }
#line 295 "AdvancedModule.cs"
                                        double candidate = csharp2cuda_temp_132;
#line 300 "AdvancedModule.cs"
#line 300 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_141 = &(selected);
#line 300 "AdvancedModule.cs"
                                        double csharp2cuda_temp_142;
#line 300 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 300 "AdvancedModule.cs"
                                            csharp2cuda_temp_142 = mathblocks_minimum(selected, candidate);
                                        }
                                        else
                                        {
#line 300 "AdvancedModule.cs"
                                            csharp2cuda_temp_142 = mathblocks_maximum(selected, candidate);
                                        }
                                        (*(csharp2cuda_temp_141) = csharp2cuda_temp_142);
                                    }
#line 293 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_130 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_130));
                                }
                            }
#line 304 "AdvancedModule.cs"
#line 304 "AdvancedModule.cs"
                            double* csharp2cuda_temp_143 = &((result)[query]);
                            (*(csharp2cuda_temp_143) = selected);
                        }
#line 288 "AdvancedModule.cs"
                        int* csharp2cuda_temp_127 = &(query);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_127));
                    }
                }
#line 306 "AdvancedModule.cs"
                break;
#line 307 "AdvancedModule.cs"
            case 6:
#line 308 "AdvancedModule.cs"
#line 308 "AdvancedModule.cs"
                int csharp2cuda_temp_144 = (first)->count;
                if (((csharp2cuda_temp_144) <= (0)))
#line 309 "AdvancedModule.cs"
                {
#line 310 "AdvancedModule.cs"
#line 310 "AdvancedModule.cs"
                    int* csharp2cuda_temp_145 = &((output)->valid);
                    (*(csharp2cuda_temp_145) = 0);
#line 311 "AdvancedModule.cs"
                    break;
                }
#line 313 "AdvancedModule.cs"
                {
#line 314 "AdvancedModule.cs"
                    double sum = 0.0;
#line 315 "AdvancedModule.cs"
                    {
#line 315 "AdvancedModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 315 "AdvancedModule.cs"
                            int csharp2cuda_temp_147 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_147))))
                                break;
#line 316 "AdvancedModule.cs"
                            {
#line 316 "AdvancedModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 316 "AdvancedModule.cs"
                                    int csharp2cuda_temp_149 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_149))))
                                        break;
#line 317 "AdvancedModule.cs"
#line 317 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_150 = &(sum);
#line 317 "AdvancedModule.cs"
                                    double csharp2cuda_temp_151 = *(csharp2cuda_temp_150);
#line 317 "AdvancedModule.cs"
                                    double csharp2cuda_temp_152 = (a)[left];
#line 317 "AdvancedModule.cs"
                                    double csharp2cuda_temp_153 = (a)[right];
                                    (*(csharp2cuda_temp_150) = __dadd_rn(csharp2cuda_temp_151, fabs(__dsub_rn(csharp2cuda_temp_152, csharp2cuda_temp_153))));
#line 316 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_148 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_148));
                                }
                            }
#line 315 "AdvancedModule.cs"
                            int* csharp2cuda_temp_146 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_146));
                        }
                    }
#line 318 "AdvancedModule.cs"
#line 318 "AdvancedModule.cs"
                    double* csharp2cuda_temp_154 = &((output)->scalar_value);
#line 319 "AdvancedModule.cs"
                    int csharp2cuda_temp_155 = (first)->count;
#line 319 "AdvancedModule.cs"
                    int csharp2cuda_temp_156 = (first)->count;
#line 318 "AdvancedModule.cs"
                    double csharp2cuda_temp_157 = __ddiv_rn(sum, __dmul_rn(__dmul_rn(2.0, ((double)(csharp2cuda_temp_155))), mathblocks_compensated_sum(a, csharp2cuda_temp_156)));
                    (*(csharp2cuda_temp_154) = csharp2cuda_temp_157);
#line 320 "AdvancedModule.cs"
                    break;
                }
#line 322 "AdvancedModule.cs"
            case 7:
#line 323 "AdvancedModule.cs"
#line 323 "AdvancedModule.cs"
                int csharp2cuda_temp_158 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_158, 1));
#line 324 "AdvancedModule.cs"
#line 324 "AdvancedModule.cs"
                int csharp2cuda_temp_159 = (first)->count;
#line 324 "AdvancedModule.cs"
                bool csharp2cuda_temp_160;
#line 324 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_159) <= (0))))
                {
#line 324 "AdvancedModule.cs"
                    csharp2cuda_temp_160 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 324 "AdvancedModule.cs"
                    csharp2cuda_temp_160 = true;
                }
                if (csharp2cuda_temp_160)
#line 325 "AdvancedModule.cs"
                {
#line 326 "AdvancedModule.cs"
#line 326 "AdvancedModule.cs"
                    int* csharp2cuda_temp_161 = &((output)->valid);
                    (*(csharp2cuda_temp_161) = 0);
#line 327 "AdvancedModule.cs"
                    break;
                }
#line 329 "AdvancedModule.cs"
#line 329 "AdvancedModule.cs"
                double* csharp2cuda_temp_162 = &((result)[0]);
                (*(csharp2cuda_temp_162) = 0.0);
#line 330 "AdvancedModule.cs"
                {
#line 330 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 330 "AdvancedModule.cs"
                        int csharp2cuda_temp_164 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_164))))
                            break;
#line 331 "AdvancedModule.cs"
#line 331 "AdvancedModule.cs"
                        double* csharp2cuda_temp_165 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 331 "AdvancedModule.cs"
                        double csharp2cuda_temp_166 = (a)[index];
                        (*(csharp2cuda_temp_165) = csharp2cuda_temp_166);
#line 330 "AdvancedModule.cs"
                        int* csharp2cuda_temp_163 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_163));
                    }
                }
#line 332 "AdvancedModule.cs"
                {
#line 333 "AdvancedModule.cs"
                    int csharp2cuda_temp_167 = (first)->count;
#line 333 "AdvancedModule.cs"
                    double* sorted = mathblocks_stable_merge_sort(csharp2cuda_pointer_add(result, 1), scratch, csharp2cuda_temp_167, false);
#line 334 "AdvancedModule.cs"
                    if (((((void*)(sorted))) != (((void*)(csharp2cuda_pointer_add(result, 1))))))
                    {
#line 335 "AdvancedModule.cs"
                        {
#line 335 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 335 "AdvancedModule.cs"
                                int csharp2cuda_temp_169 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_169))))
                                    break;
#line 336 "AdvancedModule.cs"
#line 336 "AdvancedModule.cs"
                                double* csharp2cuda_temp_170 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 336 "AdvancedModule.cs"
                                double csharp2cuda_temp_171 = (sorted)[index];
                                (*(csharp2cuda_temp_170) = csharp2cuda_temp_171);
#line 335 "AdvancedModule.cs"
                                int* csharp2cuda_temp_168 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_168));
                            }
                        }
                    }
                }
#line 338 "AdvancedModule.cs"
                {
#line 339 "AdvancedModule.cs"
                    int csharp2cuda_temp_172 = (first)->count;
#line 339 "AdvancedModule.cs"
                    double total = mathblocks_compensated_sum(csharp2cuda_pointer_add(result, 1), csharp2cuda_temp_172);
#line 340 "AdvancedModule.cs"
                    {
#line 340 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 340 "AdvancedModule.cs"
                            int csharp2cuda_temp_174 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_174))))
                                break;
#line 341 "AdvancedModule.cs"
#line 341 "AdvancedModule.cs"
                            double* csharp2cuda_temp_175 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 341 "AdvancedModule.cs"
                            double csharp2cuda_temp_176 = (result)[index];
#line 341 "AdvancedModule.cs"
                            double csharp2cuda_temp_177 = (result)[csharp2cuda_i32_add(index, 1)];
#line 341 "AdvancedModule.cs"
                            double csharp2cuda_temp_178 = __ddiv_rn(csharp2cuda_temp_177, total);
                            (*(csharp2cuda_temp_175) = __dadd_rn(csharp2cuda_temp_176, csharp2cuda_temp_178));
#line 340 "AdvancedModule.cs"
                            int* csharp2cuda_temp_173 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_173));
                        }
                    }
#line 342 "AdvancedModule.cs"
                    break;
                }
#line 344 "AdvancedModule.cs"
            case 8:
#line 345 "AdvancedModule.cs"
#line 345 "AdvancedModule.cs"
                int csharp2cuda_temp_179 = (first)->rows;
#line 345 "AdvancedModule.cs"
                int csharp2cuda_temp_180 = (first)->columns;
#line 345 "AdvancedModule.cs"
                bool csharp2cuda_temp_181;
#line 345 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_179) != (csharp2cuda_temp_180))))
                {
#line 345 "AdvancedModule.cs"
                    int csharp2cuda_temp_182 = (first)->rows;
#line 345 "AdvancedModule.cs"
                    int csharp2cuda_temp_183 = (second)->count;
#line 345 "AdvancedModule.cs"
                    csharp2cuda_temp_181 = ((csharp2cuda_temp_182) != (csharp2cuda_temp_183));
                }
                else
                {
#line 345 "AdvancedModule.cs"
                    csharp2cuda_temp_181 = true;
                }
#line 345 "AdvancedModule.cs"
                bool csharp2cuda_temp_184;
#line 345 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_181))
                {
#line 346 "AdvancedModule.cs"
                    int csharp2cuda_temp_185 = (first)->rows;
#line 346 "AdvancedModule.cs"
                    int csharp2cuda_temp_186 = (first)->columns;
#line 346 "AdvancedModule.cs"
                    bool csharp2cuda_temp_187 = mathblocks_advanced_transition(a, csharp2cuda_temp_185, csharp2cuda_temp_186);
#line 345 "AdvancedModule.cs"
                    csharp2cuda_temp_184 = (!(csharp2cuda_temp_187));
                }
                else
                {
#line 345 "AdvancedModule.cs"
                    csharp2cuda_temp_184 = true;
                }
#line 345 "AdvancedModule.cs"
                bool csharp2cuda_temp_188;
#line 345 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_184))
                {
#line 347 "AdvancedModule.cs"
                    int csharp2cuda_temp_189 = (second)->count;
#line 347 "AdvancedModule.cs"
                    bool csharp2cuda_temp_190 = mathblocks_advanced_distribution(b, csharp2cuda_temp_189);
#line 345 "AdvancedModule.cs"
                    csharp2cuda_temp_188 = (!(csharp2cuda_temp_190));
                }
                else
                {
#line 345 "AdvancedModule.cs"
                    csharp2cuda_temp_188 = true;
                }
                if (csharp2cuda_temp_188)
#line 348 "AdvancedModule.cs"
                {
#line 349 "AdvancedModule.cs"
#line 349 "AdvancedModule.cs"
                    int* csharp2cuda_temp_191 = &((output)->valid);
                    (*(csharp2cuda_temp_191) = 0);
#line 350 "AdvancedModule.cs"
                    break;
                }
#line 352 "AdvancedModule.cs"
                {
#line 353 "AdvancedModule.cs"
                    double total = 0.0;
#line 354 "AdvancedModule.cs"
                    {
#line 354 "AdvancedModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 354 "AdvancedModule.cs"
                            int csharp2cuda_temp_193 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_193))))
                                break;
#line 355 "AdvancedModule.cs"
                            {
#line 355 "AdvancedModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 355 "AdvancedModule.cs"
                                    int csharp2cuda_temp_195 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_195))))
                                        break;
#line 356 "AdvancedModule.cs"
                                    {
#line 357 "AdvancedModule.cs"
                                        double csharp2cuda_temp_196 = (b)[row];
#line 357 "AdvancedModule.cs"
                                        int csharp2cuda_temp_197 = (first)->columns;
#line 357 "AdvancedModule.cs"
                                        double csharp2cuda_temp_198 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_197), column)];
#line 357 "AdvancedModule.cs"
                                        double forward = __dmul_rn(csharp2cuda_temp_196, csharp2cuda_temp_198);
#line 358 "AdvancedModule.cs"
                                        double csharp2cuda_temp_199 = (b)[column];
#line 358 "AdvancedModule.cs"
                                        int csharp2cuda_temp_200 = (first)->columns;
#line 358 "AdvancedModule.cs"
                                        double csharp2cuda_temp_201 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_200), row)];
#line 358 "AdvancedModule.cs"
                                        double reverse = __dmul_rn(csharp2cuda_temp_199, csharp2cuda_temp_201);
#line 359 "AdvancedModule.cs"
#line 359 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_202;
#line 359 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 359 "AdvancedModule.cs"
                                            csharp2cuda_temp_202 = ((reverse) == (0.0));
                                        }
                                        else
                                        {
#line 359 "AdvancedModule.cs"
                                            csharp2cuda_temp_202 = false;
                                        }
                                        if (csharp2cuda_temp_202)
#line 360 "AdvancedModule.cs"
                                        {
#line 361 "AdvancedModule.cs"
#line 361 "AdvancedModule.cs"
                                            int* csharp2cuda_temp_203 = &((output)->valid);
                                            (*(csharp2cuda_temp_203) = 0);
#line 362 "AdvancedModule.cs"
                                            break;
                                        }
#line 364 "AdvancedModule.cs"
#line 364 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_204;
#line 364 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 364 "AdvancedModule.cs"
                                            csharp2cuda_temp_204 = ((reverse) > (0.0));
                                        }
                                        else
                                        {
#line 364 "AdvancedModule.cs"
                                            csharp2cuda_temp_204 = false;
                                        }
                                        if (csharp2cuda_temp_204)
                                        {
#line 365 "AdvancedModule.cs"
#line 365 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_205 = &(total);
#line 365 "AdvancedModule.cs"
                                            double csharp2cuda_temp_206 = *(csharp2cuda_temp_205);
#line 365 "AdvancedModule.cs"
                                            double csharp2cuda_temp_207 = __ddiv_rn(forward, reverse);
                                            (*(csharp2cuda_temp_205) = __dadd_rn(csharp2cuda_temp_206, __dmul_rn(forward, mathblocks_natural_logarithm(csharp2cuda_temp_207))));
                                        }
                                    }
#line 355 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_194 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_194));
                                }
                            }
#line 354 "AdvancedModule.cs"
                            int* csharp2cuda_temp_192 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_192));
                        }
                    }
#line 367 "AdvancedModule.cs"
#line 367 "AdvancedModule.cs"
                    double* csharp2cuda_temp_208 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_208) = total);
#line 368 "AdvancedModule.cs"
                    break;
                }
#line 370 "AdvancedModule.cs"
            case 9:
#line 371 "AdvancedModule.cs"
#line 371 "AdvancedModule.cs"
                int csharp2cuda_temp_209 = (first)->rows;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_209);
#line 372 "AdvancedModule.cs"
#line 372 "AdvancedModule.cs"
                int csharp2cuda_temp_210 = (first)->rows;
#line 372 "AdvancedModule.cs"
                int csharp2cuda_temp_211 = (first)->columns;
#line 372 "AdvancedModule.cs"
                bool csharp2cuda_temp_212 = mathblocks_advanced_transition(a, csharp2cuda_temp_210, csharp2cuda_temp_211);
#line 372 "AdvancedModule.cs"
                bool csharp2cuda_temp_213;
#line 372 "AdvancedModule.cs"
                if (!((!(csharp2cuda_temp_212))))
                {
#line 372 "AdvancedModule.cs"
                    csharp2cuda_temp_213 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 372 "AdvancedModule.cs"
                    csharp2cuda_temp_213 = true;
                }
                if (csharp2cuda_temp_213)
#line 373 "AdvancedModule.cs"
                {
#line 374 "AdvancedModule.cs"
#line 374 "AdvancedModule.cs"
                    int* csharp2cuda_temp_214 = &((output)->valid);
                    (*(csharp2cuda_temp_214) = 0);
#line 375 "AdvancedModule.cs"
                    break;
                }
#line 377 "AdvancedModule.cs"
                {
#line 378 "AdvancedModule.cs"
                    int iterations = 0;
#line 379 "AdvancedModule.cs"
#line 379 "AdvancedModule.cs"
                    double csharp2cuda_temp_215 = (second)->scalar_value;
#line 379 "AdvancedModule.cs"
                    int* csharp2cuda_temp_216 = &(iterations);
#line 379 "AdvancedModule.cs"
                    bool csharp2cuda_temp_217 = mathblocks_sequence_positive_integer(csharp2cuda_temp_215, csharp2cuda_temp_216);
#line 379 "AdvancedModule.cs"
                    bool csharp2cuda_temp_218;
#line 379 "AdvancedModule.cs"
                    if (!((!(csharp2cuda_temp_217))))
                    {
#line 379 "AdvancedModule.cs"
                        csharp2cuda_temp_218 = ((iterations) > (10000));
                    }
                    else
                    {
#line 379 "AdvancedModule.cs"
                        csharp2cuda_temp_218 = true;
                    }
                    if (csharp2cuda_temp_218)
#line 380 "AdvancedModule.cs"
                    {
#line 381 "AdvancedModule.cs"
#line 381 "AdvancedModule.cs"
                        int* csharp2cuda_temp_219 = &((output)->valid);
                        (*(csharp2cuda_temp_219) = 0);
#line 382 "AdvancedModule.cs"
                        break;
                    }
#line 384 "AdvancedModule.cs"
                    {
#line 384 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 384 "AdvancedModule.cs"
                            int csharp2cuda_temp_221 = (first)->rows;
                            if (!(((index) < (csharp2cuda_temp_221))))
                                break;
#line 385 "AdvancedModule.cs"
#line 385 "AdvancedModule.cs"
                            double* csharp2cuda_temp_222 = &((result)[index]);
#line 385 "AdvancedModule.cs"
                            int csharp2cuda_temp_223 = (first)->rows;
#line 385 "AdvancedModule.cs"
                            double csharp2cuda_temp_224 = __ddiv_rn(1.0, ((double)(csharp2cuda_temp_223)));
                            (*(csharp2cuda_temp_222) = csharp2cuda_temp_224);
#line 384 "AdvancedModule.cs"
                            int* csharp2cuda_temp_220 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_220));
                        }
                    }
#line 386 "AdvancedModule.cs"
                    {
#line 386 "AdvancedModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 387 "AdvancedModule.cs"
                            {
#line 388 "AdvancedModule.cs"
                                {
#line 388 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 388 "AdvancedModule.cs"
                                        int csharp2cuda_temp_227 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_227))))
                                            break;
#line 389 "AdvancedModule.cs"
#line 389 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_228 = &((scratch)[index]);
                                        (*(csharp2cuda_temp_228) = 0.0);
#line 388 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_226 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_226));
                                    }
                                }
#line 390 "AdvancedModule.cs"
                                {
#line 390 "AdvancedModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 390 "AdvancedModule.cs"
                                        int csharp2cuda_temp_230 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_230))))
                                            break;
#line 391 "AdvancedModule.cs"
                                        {
#line 391 "AdvancedModule.cs"
                                            int column = 0;
                                            while (true)
                                            {
#line 391 "AdvancedModule.cs"
                                                int csharp2cuda_temp_232 = (first)->columns;
                                                if (!(((column) < (csharp2cuda_temp_232))))
                                                    break;
#line 392 "AdvancedModule.cs"
#line 392 "AdvancedModule.cs"
                                                double* csharp2cuda_temp_233 = &((scratch)[column]);
#line 392 "AdvancedModule.cs"
                                                double csharp2cuda_temp_234 = *(csharp2cuda_temp_233);
#line 392 "AdvancedModule.cs"
                                                double csharp2cuda_temp_235 = (result)[row];
#line 392 "AdvancedModule.cs"
                                                int csharp2cuda_temp_236 = (first)->columns;
#line 392 "AdvancedModule.cs"
                                                double csharp2cuda_temp_237 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_236), column)];
                                                (*(csharp2cuda_temp_233) = __dadd_rn(csharp2cuda_temp_234, __dmul_rn(csharp2cuda_temp_235, csharp2cuda_temp_237)));
#line 391 "AdvancedModule.cs"
                                                int* csharp2cuda_temp_231 = &(column);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_231));
                                            }
                                        }
#line 390 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_229 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_229));
                                    }
                                }
#line 393 "AdvancedModule.cs"
                                {
#line 393 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 393 "AdvancedModule.cs"
                                        int csharp2cuda_temp_239 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_239))))
                                            break;
#line 394 "AdvancedModule.cs"
#line 394 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_240 = &((result)[index]);
#line 394 "AdvancedModule.cs"
                                        double csharp2cuda_temp_241 = (scratch)[index];
                                        (*(csharp2cuda_temp_240) = csharp2cuda_temp_241);
#line 393 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_238 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_238));
                                    }
                                }
                            }
#line 386 "AdvancedModule.cs"
                            int* csharp2cuda_temp_225 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_225));
                        }
                    }
#line 396 "AdvancedModule.cs"
                    break;
                }
#line 398 "AdvancedModule.cs"
            case 10:
#line 399 "AdvancedModule.cs"
#line 399 "AdvancedModule.cs"
                int csharp2cuda_temp_242 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_242);
#line 400 "AdvancedModule.cs"
#line 400 "AdvancedModule.cs"
                int csharp2cuda_temp_243 = (first)->count;
#line 400 "AdvancedModule.cs"
                bool csharp2cuda_temp_244;
#line 400 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_243) <= (0))))
                {
#line 400 "AdvancedModule.cs"
                    csharp2cuda_temp_244 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 400 "AdvancedModule.cs"
                    csharp2cuda_temp_244 = true;
                }
                if (csharp2cuda_temp_244)
#line 401 "AdvancedModule.cs"
                {
#line 402 "AdvancedModule.cs"
#line 402 "AdvancedModule.cs"
                    int* csharp2cuda_temp_245 = &((output)->valid);
                    (*(csharp2cuda_temp_245) = 0);
#line 403 "AdvancedModule.cs"
                    break;
                }
#line 405 "AdvancedModule.cs"
                {
#line 406 "AdvancedModule.cs"
                    double* means = scratch;
#line 407 "AdvancedModule.cs"
                    int csharp2cuda_temp_246 = (first)->count;
#line 407 "AdvancedModule.cs"
                    int* weights = ((int*)(csharp2cuda_pointer_add(means, csharp2cuda_temp_246)));
#line 408 "AdvancedModule.cs"
                    int csharp2cuda_temp_247 = (first)->count;
#line 408 "AdvancedModule.cs"
                    int* starts = csharp2cuda_pointer_add(weights, csharp2cuda_temp_247);
#line 409 "AdvancedModule.cs"
                    int block_count = 0;
#line 410 "AdvancedModule.cs"
                    {
#line 410 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 410 "AdvancedModule.cs"
                            int csharp2cuda_temp_249 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_249))))
                                break;
#line 411 "AdvancedModule.cs"
                            {
#line 412 "AdvancedModule.cs"
#line 412 "AdvancedModule.cs"
                                double* csharp2cuda_temp_250 = &((means)[block_count]);
#line 412 "AdvancedModule.cs"
                                double csharp2cuda_temp_251 = (a)[index];
                                (*(csharp2cuda_temp_250) = csharp2cuda_temp_251);
#line 413 "AdvancedModule.cs"
#line 413 "AdvancedModule.cs"
                                int* csharp2cuda_temp_252 = &((weights)[block_count]);
                                (*(csharp2cuda_temp_252) = 1);
#line 414 "AdvancedModule.cs"
#line 414 "AdvancedModule.cs"
                                int* csharp2cuda_temp_253 = &((starts)[block_count]);
                                (*(csharp2cuda_temp_253) = index);
#line 415 "AdvancedModule.cs"
#line 415 "AdvancedModule.cs"
                                int* csharp2cuda_temp_254 = &(block_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_254));
#line 416 "AdvancedModule.cs"
                                while (true)
                                {
#line 416 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_255;
#line 416 "AdvancedModule.cs"
                                    if (((block_count) >= (2)))
                                    {
#line 416 "AdvancedModule.cs"
                                        double csharp2cuda_temp_256 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 416 "AdvancedModule.cs"
                                        double csharp2cuda_temp_257 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 416 "AdvancedModule.cs"
                                        csharp2cuda_temp_255 = ((csharp2cuda_temp_256) > (csharp2cuda_temp_257));
                                    }
                                    else
                                    {
#line 416 "AdvancedModule.cs"
                                        csharp2cuda_temp_255 = false;
                                    }
                                    if (!(csharp2cuda_temp_255))
                                        break;
#line 417 "AdvancedModule.cs"
                                    {
#line 418 "AdvancedModule.cs"
                                        int csharp2cuda_temp_258 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 418 "AdvancedModule.cs"
                                        int csharp2cuda_temp_259 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 418 "AdvancedModule.cs"
                                        int combined_weight = csharp2cuda_i32_add(csharp2cuda_temp_258, csharp2cuda_temp_259);
#line 419 "AdvancedModule.cs"
#line 419 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_260 = &((means)[csharp2cuda_i32_sub(block_count, 2)]);
#line 420 "AdvancedModule.cs"
                                        double csharp2cuda_temp_261 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 420 "AdvancedModule.cs"
                                        int csharp2cuda_temp_262 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 421 "AdvancedModule.cs"
                                        double csharp2cuda_temp_263 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 421 "AdvancedModule.cs"
                                        int csharp2cuda_temp_264 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 420 "AdvancedModule.cs"
                                        double csharp2cuda_temp_265 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_261, ((double)(csharp2cuda_temp_262))), __dmul_rn(csharp2cuda_temp_263, ((double)(csharp2cuda_temp_264)))), ((double)(combined_weight)));
                                        (*(csharp2cuda_temp_260) = csharp2cuda_temp_265);
#line 423 "AdvancedModule.cs"
#line 423 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_266 = &((weights)[csharp2cuda_i32_sub(block_count, 2)]);
                                        (*(csharp2cuda_temp_266) = combined_weight);
#line 424 "AdvancedModule.cs"
#line 424 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_267 = &(block_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_267));
                                    }
                                }
                            }
#line 410 "AdvancedModule.cs"
                            int* csharp2cuda_temp_248 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_248));
                        }
                    }
#line 427 "AdvancedModule.cs"
                    {
#line 427 "AdvancedModule.cs"
                        int block = 0;
                        while (true)
                        {
                            if (!(((block) < (block_count))))
                                break;
#line 428 "AdvancedModule.cs"
                            {
#line 429 "AdvancedModule.cs"
                                int csharp2cuda_temp_269;
#line 429 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_add(block, 1)) < (block_count)))
                                {
#line 429 "AdvancedModule.cs"
                                    csharp2cuda_temp_269 = (starts)[csharp2cuda_i32_add(block, 1)];
                                }
                                else
                                {
#line 429 "AdvancedModule.cs"
                                    csharp2cuda_temp_269 = (first)->count;
                                }
#line 429 "AdvancedModule.cs"
                                int end = csharp2cuda_temp_269;
#line 430 "AdvancedModule.cs"
                                {
#line 430 "AdvancedModule.cs"
                                    int index = (starts)[block];
                                    while (true)
                                    {
                                        if (!(((index) < (end))))
                                            break;
#line 431 "AdvancedModule.cs"
#line 431 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_271 = &((result)[index]);
#line 431 "AdvancedModule.cs"
                                        double csharp2cuda_temp_272 = (means)[block];
                                        (*(csharp2cuda_temp_271) = csharp2cuda_temp_272);
#line 430 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_270 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_270));
                                    }
                                }
                            }
#line 427 "AdvancedModule.cs"
                            int* csharp2cuda_temp_268 = &(block);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_268));
                        }
                    }
#line 433 "AdvancedModule.cs"
                    break;
                }
#line 435 "AdvancedModule.cs"
            case 11:
#line 436 "AdvancedModule.cs"
#line 436 "AdvancedModule.cs"
                int csharp2cuda_temp_273 = (first)->count;
#line 436 "AdvancedModule.cs"
                int csharp2cuda_temp_274 = (second)->count;
#line 436 "AdvancedModule.cs"
                bool csharp2cuda_temp_275;
#line 436 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_273) != (csharp2cuda_temp_274))))
                {
#line 436 "AdvancedModule.cs"
                    csharp2cuda_temp_275 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 436 "AdvancedModule.cs"
                    csharp2cuda_temp_275 = true;
                }
                if (csharp2cuda_temp_275)
#line 437 "AdvancedModule.cs"
                {
#line 438 "AdvancedModule.cs"
#line 438 "AdvancedModule.cs"
                    int* csharp2cuda_temp_276 = &((output)->valid);
                    (*(csharp2cuda_temp_276) = 0);
#line 439 "AdvancedModule.cs"
                    break;
                }
#line 441 "AdvancedModule.cs"
                {
#line 442 "AdvancedModule.cs"
                    double* left_sorted = scratch;
#line 443 "AdvancedModule.cs"
                    int csharp2cuda_temp_277 = (first)->count;
#line 443 "AdvancedModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_277);
#line 444 "AdvancedModule.cs"
#line 444 "AdvancedModule.cs"
                    int csharp2cuda_temp_278 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_278, left_sorted, true);
#line 445 "AdvancedModule.cs"
#line 445 "AdvancedModule.cs"
                    int csharp2cuda_temp_279 = (first)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_279, right_sorted, true);
#line 446 "AdvancedModule.cs"
                    double left_sum = 0.0;
#line 447 "AdvancedModule.cs"
                    double right_sum = 0.0;
#line 448 "AdvancedModule.cs"
                    bool majorizes = true;
#line 449 "AdvancedModule.cs"
                    {
#line 449 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 449 "AdvancedModule.cs"
                            int csharp2cuda_temp_281 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_281))))
                                break;
#line 450 "AdvancedModule.cs"
                            {
#line 451 "AdvancedModule.cs"
#line 451 "AdvancedModule.cs"
                                double* csharp2cuda_temp_282 = &(left_sum);
#line 451 "AdvancedModule.cs"
                                double csharp2cuda_temp_283 = *(csharp2cuda_temp_282);
#line 451 "AdvancedModule.cs"
                                double csharp2cuda_temp_284 = (left_sorted)[index];
                                (*(csharp2cuda_temp_282) = __dadd_rn(csharp2cuda_temp_283, csharp2cuda_temp_284));
#line 452 "AdvancedModule.cs"
#line 452 "AdvancedModule.cs"
                                double* csharp2cuda_temp_285 = &(right_sum);
#line 452 "AdvancedModule.cs"
                                double csharp2cuda_temp_286 = *(csharp2cuda_temp_285);
#line 452 "AdvancedModule.cs"
                                double csharp2cuda_temp_287 = (right_sorted)[index];
                                (*(csharp2cuda_temp_285) = __dadd_rn(csharp2cuda_temp_286, csharp2cuda_temp_287));
#line 453 "AdvancedModule.cs"
#line 453 "AdvancedModule.cs"
                                int csharp2cuda_temp_288 = (first)->count;
#line 453 "AdvancedModule.cs"
                                bool csharp2cuda_temp_289;
#line 453 "AdvancedModule.cs"
                                if (((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_288, 1))))
                                {
#line 453 "AdvancedModule.cs"
                                    csharp2cuda_temp_289 = ((left_sum) < (right_sum));
                                }
                                else
                                {
#line 453 "AdvancedModule.cs"
                                    csharp2cuda_temp_289 = false;
                                }
                                if (csharp2cuda_temp_289)
                                {
#line 454 "AdvancedModule.cs"
#line 454 "AdvancedModule.cs"
                                    bool* csharp2cuda_temp_290 = &(majorizes);
                                    (*(csharp2cuda_temp_290) = false);
                                }
                            }
#line 449 "AdvancedModule.cs"
                            int* csharp2cuda_temp_280 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_280));
                        }
                    }
#line 456 "AdvancedModule.cs"
#line 456 "AdvancedModule.cs"
                    int* csharp2cuda_temp_291 = &((output)->boolean_value);
#line 456 "AdvancedModule.cs"
                    bool csharp2cuda_temp_292;
#line 456 "AdvancedModule.cs"
                    if (majorizes)
                    {
#line 456 "AdvancedModule.cs"
                        csharp2cuda_temp_292 = ((left_sum) == (right_sum));
                    }
                    else
                    {
#line 456 "AdvancedModule.cs"
                        csharp2cuda_temp_292 = false;
                    }
#line 456 "AdvancedModule.cs"
                    int csharp2cuda_temp_293;
#line 456 "AdvancedModule.cs"
                    if (csharp2cuda_temp_292)
                    {
#line 456 "AdvancedModule.cs"
                        csharp2cuda_temp_293 = 1;
                    }
                    else
                    {
#line 456 "AdvancedModule.cs"
                        csharp2cuda_temp_293 = 0;
                    }
                    (*(csharp2cuda_temp_291) = csharp2cuda_temp_293);
#line 457 "AdvancedModule.cs"
                    break;
                }
#line 459 "AdvancedModule.cs"
            case 12:
#line 460 "AdvancedModule.cs"
#line 460 "AdvancedModule.cs"
                int csharp2cuda_temp_294 = (first)->count;
#line 460 "AdvancedModule.cs"
                bool csharp2cuda_temp_295;
#line 460 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_294) <= (0))))
                {
#line 460 "AdvancedModule.cs"
                    int csharp2cuda_temp_296 = (first)->count;
#line 460 "AdvancedModule.cs"
                    int csharp2cuda_temp_297 = (second)->count;
#line 460 "AdvancedModule.cs"
                    csharp2cuda_temp_295 = ((csharp2cuda_temp_296) != (csharp2cuda_temp_297));
                }
                else
                {
#line 460 "AdvancedModule.cs"
                    csharp2cuda_temp_295 = true;
                }
                if (csharp2cuda_temp_295)
#line 461 "AdvancedModule.cs"
                {
#line 462 "AdvancedModule.cs"
#line 462 "AdvancedModule.cs"
                    int* csharp2cuda_temp_298 = &((output)->valid);
                    (*(csharp2cuda_temp_298) = 0);
#line 463 "AdvancedModule.cs"
                    break;
                }
#line 465 "AdvancedModule.cs"
                {
#line 466 "AdvancedModule.cs"
                    double minimum = mathblocks_positive_infinity();
#line 467 "AdvancedModule.cs"
                    double maximum = (-(mathblocks_positive_infinity()));
#line 468 "AdvancedModule.cs"
                    {
#line 468 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 468 "AdvancedModule.cs"
                            int csharp2cuda_temp_300 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_300))))
                                break;
#line 469 "AdvancedModule.cs"
                            {
#line 470 "AdvancedModule.cs"
#line 470 "AdvancedModule.cs"
                                double csharp2cuda_temp_301 = (a)[index];
#line 470 "AdvancedModule.cs"
                                bool csharp2cuda_temp_302;
#line 470 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_301) <= (0.0))))
                                {
#line 470 "AdvancedModule.cs"
                                    double csharp2cuda_temp_303 = (b)[index];
#line 470 "AdvancedModule.cs"
                                    csharp2cuda_temp_302 = ((csharp2cuda_temp_303) <= (0.0));
                                }
                                else
                                {
#line 470 "AdvancedModule.cs"
                                    csharp2cuda_temp_302 = true;
                                }
                                if (csharp2cuda_temp_302)
#line 471 "AdvancedModule.cs"
                                {
#line 472 "AdvancedModule.cs"
#line 472 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_304 = &((output)->valid);
                                    (*(csharp2cuda_temp_304) = 0);
#line 473 "AdvancedModule.cs"
                                    break;
                                }
#line 475 "AdvancedModule.cs"
                                double csharp2cuda_temp_305 = (a)[index];
#line 475 "AdvancedModule.cs"
                                double csharp2cuda_temp_306 = (b)[index];
#line 475 "AdvancedModule.cs"
                                double ratio = __ddiv_rn(csharp2cuda_temp_305, csharp2cuda_temp_306);
#line 476 "AdvancedModule.cs"
#line 476 "AdvancedModule.cs"
                                double* csharp2cuda_temp_307 = &(minimum);
#line 476 "AdvancedModule.cs"
                                double csharp2cuda_temp_308;
#line 476 "AdvancedModule.cs"
                                if (((minimum) < (ratio)))
                                {
#line 476 "AdvancedModule.cs"
                                    csharp2cuda_temp_308 = minimum;
                                }
                                else
                                {
#line 476 "AdvancedModule.cs"
                                    csharp2cuda_temp_308 = ratio;
                                }
                                (*(csharp2cuda_temp_307) = csharp2cuda_temp_308);
#line 477 "AdvancedModule.cs"
#line 477 "AdvancedModule.cs"
                                double* csharp2cuda_temp_309 = &(maximum);
#line 477 "AdvancedModule.cs"
                                double csharp2cuda_temp_310;
#line 477 "AdvancedModule.cs"
                                if (((maximum) > (ratio)))
                                {
#line 477 "AdvancedModule.cs"
                                    csharp2cuda_temp_310 = maximum;
                                }
                                else
                                {
#line 477 "AdvancedModule.cs"
                                    csharp2cuda_temp_310 = ratio;
                                }
                                (*(csharp2cuda_temp_309) = csharp2cuda_temp_310);
                            }
#line 468 "AdvancedModule.cs"
                            int* csharp2cuda_temp_299 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_299));
                        }
                    }
#line 479 "AdvancedModule.cs"
#line 479 "AdvancedModule.cs"
                    double* csharp2cuda_temp_311 = &((output)->scalar_value);
#line 479 "AdvancedModule.cs"
                    double csharp2cuda_temp_312 = __ddiv_rn(maximum, minimum);
                    (*(csharp2cuda_temp_311) = mathblocks_natural_logarithm(csharp2cuda_temp_312));
#line 480 "AdvancedModule.cs"
                    break;
                }
#line 482 "AdvancedModule.cs"
            case 13:
            case 16:
#line 484 "AdvancedModule.cs"
#line 484 "AdvancedModule.cs"
                int csharp2cuda_temp_313 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_313);
#line 485 "AdvancedModule.cs"
#line 485 "AdvancedModule.cs"
                int csharp2cuda_temp_314 = (first)->count;
#line 485 "AdvancedModule.cs"
                bool csharp2cuda_temp_315;
#line 485 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_314) <= (0))))
                {
#line 485 "AdvancedModule.cs"
                    csharp2cuda_temp_315 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 485 "AdvancedModule.cs"
                    csharp2cuda_temp_315 = true;
                }
                if (csharp2cuda_temp_315)
#line 486 "AdvancedModule.cs"
                {
#line 487 "AdvancedModule.cs"
#line 487 "AdvancedModule.cs"
                    int* csharp2cuda_temp_316 = &((output)->valid);
                    (*(csharp2cuda_temp_316) = 0);
#line 488 "AdvancedModule.cs"
                    break;
                }
#line 490 "AdvancedModule.cs"
                {
#line 491 "AdvancedModule.cs"
                    int* hull = ((int*)(scratch));
#line 492 "AdvancedModule.cs"
                    int hull_count = 0;
#line 493 "AdvancedModule.cs"
                    bool concave = ((opcode) == (16));
#line 494 "AdvancedModule.cs"
                    {
#line 494 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 494 "AdvancedModule.cs"
                            int csharp2cuda_temp_318 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_318))))
                                break;
#line 495 "AdvancedModule.cs"
                            {
#line 496 "AdvancedModule.cs"
#line 496 "AdvancedModule.cs"
                                int* csharp2cuda_temp_319 = &(hull_count);
#line 496 "AdvancedModule.cs"
                                int csharp2cuda_temp_320 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_319));
#line 496 "AdvancedModule.cs"
                                int* csharp2cuda_temp_321 = &((hull)[csharp2cuda_temp_320]);
                                (*(csharp2cuda_temp_321) = index);
#line 497 "AdvancedModule.cs"
                                while (true)
                                {
                                    if (!(((hull_count) >= (3))))
                                        break;
#line 498 "AdvancedModule.cs"
                                    {
#line 499 "AdvancedModule.cs"
                                        int one = (hull)[csharp2cuda_i32_sub(hull_count, 3)];
#line 500 "AdvancedModule.cs"
                                        int middle = (hull)[csharp2cuda_i32_sub(hull_count, 2)];
#line 501 "AdvancedModule.cs"
                                        int last = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
#line 502 "AdvancedModule.cs"
                                        double csharp2cuda_temp_322 = (a)[middle];
#line 502 "AdvancedModule.cs"
                                        double csharp2cuda_temp_323 = (a)[one];
#line 502 "AdvancedModule.cs"
                                        double first_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_322, csharp2cuda_temp_323), ((double)(csharp2cuda_i32_sub(middle, one))));
#line 503 "AdvancedModule.cs"
                                        double csharp2cuda_temp_324 = (a)[last];
#line 503 "AdvancedModule.cs"
                                        double csharp2cuda_temp_325 = (a)[middle];
#line 503 "AdvancedModule.cs"
                                        double second_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_324, csharp2cuda_temp_325), ((double)(csharp2cuda_i32_sub(last, middle))));
#line 504 "AdvancedModule.cs"
#line 504 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_326;
#line 504 "AdvancedModule.cs"
                                        if (concave)
                                        {
#line 504 "AdvancedModule.cs"
                                            csharp2cuda_temp_326 = ((first_slope) >= (second_slope));
                                        }
                                        else
                                        {
#line 504 "AdvancedModule.cs"
                                            csharp2cuda_temp_326 = ((first_slope) <= (second_slope));
                                        }
                                        if (csharp2cuda_temp_326)
                                        {
#line 505 "AdvancedModule.cs"
                                            break;
                                        }
#line 506 "AdvancedModule.cs"
#line 506 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_327 = &((hull)[csharp2cuda_i32_sub(hull_count, 2)]);
#line 506 "AdvancedModule.cs"
                                        int csharp2cuda_temp_328 = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
                                        (*(csharp2cuda_temp_327) = csharp2cuda_temp_328);
#line 507 "AdvancedModule.cs"
#line 507 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_329 = &(hull_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_329));
                                    }
                                }
                            }
#line 494 "AdvancedModule.cs"
                            int* csharp2cuda_temp_317 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_317));
                        }
                    }
#line 510 "AdvancedModule.cs"
                    {
#line 510 "AdvancedModule.cs"
                        int segment = 1;
                        while (true)
                        {
                            if (!(((segment) < (hull_count))))
                                break;
#line 511 "AdvancedModule.cs"
                            {
#line 512 "AdvancedModule.cs"
                                int start = (hull)[csharp2cuda_i32_sub(segment, 1)];
#line 513 "AdvancedModule.cs"
                                int end = (hull)[segment];
#line 514 "AdvancedModule.cs"
                                {
#line 514 "AdvancedModule.cs"
                                    int index = start;
                                    while (true)
                                    {
                                        if (!(((index) <= (end))))
                                            break;
#line 515 "AdvancedModule.cs"
                                        {
#line 516 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(((double)(csharp2cuda_i32_sub(index, start))), ((double)(csharp2cuda_i32_sub(end, start))));
#line 517 "AdvancedModule.cs"
#line 517 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_332 = &((result)[index]);
#line 517 "AdvancedModule.cs"
                                            double csharp2cuda_temp_333 = (a)[start];
#line 517 "AdvancedModule.cs"
                                            double csharp2cuda_temp_334 = (a)[end];
                                            (*(csharp2cuda_temp_332) = __dadd_rn(__dmul_rn(csharp2cuda_temp_333, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_334, weight)));
                                        }
#line 514 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_331 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_331));
                                    }
                                }
                            }
#line 510 "AdvancedModule.cs"
                            int* csharp2cuda_temp_330 = &(segment);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_330));
                        }
                    }
#line 520 "AdvancedModule.cs"
                    break;
                }
#line 522 "AdvancedModule.cs"
            case 14:
#line 523 "AdvancedModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 524 "AdvancedModule.cs"
                {
#line 525 "AdvancedModule.cs"
#line 525 "AdvancedModule.cs"
                    int* csharp2cuda_temp_335 = &((output)->valid);
                    (*(csharp2cuda_temp_335) = 0);
#line 526 "AdvancedModule.cs"
                    break;
                }
#line 528 "AdvancedModule.cs"
                {
#line 528 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 528 "AdvancedModule.cs"
                        int csharp2cuda_temp_337 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_337))))
                            break;
#line 529 "AdvancedModule.cs"
#line 529 "AdvancedModule.cs"
                        double* csharp2cuda_temp_338 = &((scratch)[index]);
#line 529 "AdvancedModule.cs"
                        double csharp2cuda_temp_339 = (a)[index];
                        (*(csharp2cuda_temp_338) = csharp2cuda_temp_339);
#line 528 "AdvancedModule.cs"
                        int* csharp2cuda_temp_336 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_336));
                    }
                }
#line 530 "AdvancedModule.cs"
#line 530 "AdvancedModule.cs"
                int* csharp2cuda_temp_340 = &((output)->boolean_value);
                (*(csharp2cuda_temp_340) = 1);
#line 531 "AdvancedModule.cs"
                {
#line 531 "AdvancedModule.cs"
                    int order = 0;
#line 531 "AdvancedModule.cs"
                    int length = (first)->count;
                    while (true)
                    {
#line 532 "AdvancedModule.cs"
                        int csharp2cuda_temp_343 = (first)->count;
#line 532 "AdvancedModule.cs"
                        bool csharp2cuda_temp_344;
#line 532 "AdvancedModule.cs"
                        if (((order) < (csharp2cuda_temp_343)))
                        {
#line 532 "AdvancedModule.cs"
                            csharp2cuda_temp_344 = (output)->boolean_value;
                        }
                        else
                        {
#line 532 "AdvancedModule.cs"
                            csharp2cuda_temp_344 = false;
                        }
                        if (!(csharp2cuda_temp_344))
                            break;
#line 534 "AdvancedModule.cs"
                        {
#line 535 "AdvancedModule.cs"
                            double csharp2cuda_temp_345;
#line 535 "AdvancedModule.cs"
                            if (((csharp2cuda_i32_and(order, 1)) == (0)))
                            {
#line 535 "AdvancedModule.cs"
                                csharp2cuda_temp_345 = 1.0;
                            }
                            else
                            {
#line 535 "AdvancedModule.cs"
                                csharp2cuda_temp_345 = (-(1.0));
                            }
#line 535 "AdvancedModule.cs"
                            double sign = csharp2cuda_temp_345;
#line 536 "AdvancedModule.cs"
                            {
#line 536 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 537 "AdvancedModule.cs"
#line 537 "AdvancedModule.cs"
                                    double csharp2cuda_temp_347 = (scratch)[index];
                                    if (((__dmul_rn(sign, csharp2cuda_temp_347)) < (0.0)))
#line 538 "AdvancedModule.cs"
                                    {
#line 539 "AdvancedModule.cs"
#line 539 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_348 = &((output)->boolean_value);
                                        (*(csharp2cuda_temp_348) = 0);
#line 540 "AdvancedModule.cs"
                                        break;
                                    }
#line 536 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_346 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
                                }
                            }
#line 542 "AdvancedModule.cs"
                            {
#line 542 "AdvancedModule.cs"
                                int index = 1;
                                while (true)
                                {
#line 542 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_350 = (output)->boolean_value;
#line 542 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_351;
#line 542 "AdvancedModule.cs"
                                    if (csharp2cuda_temp_350)
                                    {
#line 542 "AdvancedModule.cs"
                                        csharp2cuda_temp_351 = ((index) < (length));
                                    }
                                    else
                                    {
#line 542 "AdvancedModule.cs"
                                        csharp2cuda_temp_351 = false;
                                    }
                                    if (!(csharp2cuda_temp_351))
                                        break;
#line 543 "AdvancedModule.cs"
#line 543 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_352 = &((scratch)[csharp2cuda_i32_sub(index, 1)]);
#line 543 "AdvancedModule.cs"
                                    double csharp2cuda_temp_353 = (scratch)[index];
#line 543 "AdvancedModule.cs"
                                    double csharp2cuda_temp_354 = (scratch)[csharp2cuda_i32_sub(index, 1)];
                                    (*(csharp2cuda_temp_352) = __dsub_rn(csharp2cuda_temp_353, csharp2cuda_temp_354));
#line 542 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_349 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_349));
                                }
                            }
                        }
#line 533 "AdvancedModule.cs"
                        int* csharp2cuda_temp_341 = &(order);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_341));
#line 533 "AdvancedModule.cs"
                        int* csharp2cuda_temp_342 = &(length);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_342));
                    }
                }
#line 545 "AdvancedModule.cs"
                break;
#line 546 "AdvancedModule.cs"
            case 15:
#line 547 "AdvancedModule.cs"
#line 547 "AdvancedModule.cs"
                int* csharp2cuda_temp_355 = &((output)->boolean_value);
                (*(csharp2cuda_temp_355) = 1);
#line 548 "AdvancedModule.cs"
                {
#line 548 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 548 "AdvancedModule.cs"
                        int csharp2cuda_temp_357 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_357))))
                            break;
#line 549 "AdvancedModule.cs"
#line 549 "AdvancedModule.cs"
                        double csharp2cuda_temp_358 = (a)[index];
                        if (((csharp2cuda_temp_358) < (0.0)))
                        {
#line 549 "AdvancedModule.cs"
#line 549 "AdvancedModule.cs"
                            int* csharp2cuda_temp_359 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_359) = 0);
                        }
#line 548 "AdvancedModule.cs"
                        int* csharp2cuda_temp_356 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_356));
                    }
                }
#line 550 "AdvancedModule.cs"
                {
#line 550 "AdvancedModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 550 "AdvancedModule.cs"
                        bool csharp2cuda_temp_361 = (output)->boolean_value;
#line 550 "AdvancedModule.cs"
                        bool csharp2cuda_temp_362;
#line 550 "AdvancedModule.cs"
                        if (csharp2cuda_temp_361)
                        {
#line 550 "AdvancedModule.cs"
                            int csharp2cuda_temp_363 = (first)->count;
#line 550 "AdvancedModule.cs"
                            csharp2cuda_temp_362 = ((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_363, 1)));
                        }
                        else
                        {
#line 550 "AdvancedModule.cs"
                            csharp2cuda_temp_362 = false;
                        }
                        if (!(csharp2cuda_temp_362))
                            break;
#line 551 "AdvancedModule.cs"
#line 551 "AdvancedModule.cs"
                        double csharp2cuda_temp_364 = (a)[index];
#line 551 "AdvancedModule.cs"
                        double csharp2cuda_temp_365 = (a)[index];
#line 551 "AdvancedModule.cs"
                        double csharp2cuda_temp_366 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 551 "AdvancedModule.cs"
                        double csharp2cuda_temp_367 = (a)[csharp2cuda_i32_add(index, 1)];
                        if (((__dmul_rn(csharp2cuda_temp_364, csharp2cuda_temp_365)) < (__dmul_rn(csharp2cuda_temp_366, csharp2cuda_temp_367))))
                        {
#line 552 "AdvancedModule.cs"
#line 552 "AdvancedModule.cs"
                            int* csharp2cuda_temp_368 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_368) = 0);
                        }
#line 550 "AdvancedModule.cs"
                        int* csharp2cuda_temp_360 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_360));
                    }
                }
#line 553 "AdvancedModule.cs"
                break;
#line 554 "AdvancedModule.cs"
            case 17:
#line 555 "AdvancedModule.cs"
#line 555 "AdvancedModule.cs"
                int csharp2cuda_temp_369 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_369);
#line 556 "AdvancedModule.cs"
#line 556 "AdvancedModule.cs"
                int csharp2cuda_temp_370 = (first)->count;
#line 556 "AdvancedModule.cs"
                bool csharp2cuda_temp_371 = mathblocks_advanced_distribution(a, csharp2cuda_temp_370);
                if ((!(csharp2cuda_temp_371)))
#line 557 "AdvancedModule.cs"
                {
#line 558 "AdvancedModule.cs"
#line 558 "AdvancedModule.cs"
                    int* csharp2cuda_temp_372 = &((output)->valid);
                    (*(csharp2cuda_temp_372) = 0);
#line 559 "AdvancedModule.cs"
                    break;
                }
#line 561 "AdvancedModule.cs"
                {
#line 562 "AdvancedModule.cs"
                    double survival = 1.0;
#line 563 "AdvancedModule.cs"
                    {
#line 563 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 563 "AdvancedModule.cs"
                            int csharp2cuda_temp_374 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_374))))
                                break;
#line 564 "AdvancedModule.cs"
                            {
#line 565 "AdvancedModule.cs"
#line 565 "AdvancedModule.cs"
                                double* csharp2cuda_temp_375 = &((result)[index]);
#line 565 "AdvancedModule.cs"
                                double csharp2cuda_temp_376 = (a)[index];
#line 565 "AdvancedModule.cs"
                                double csharp2cuda_temp_377 = __ddiv_rn(csharp2cuda_temp_376, survival);
                                (*(csharp2cuda_temp_375) = csharp2cuda_temp_377);
#line 566 "AdvancedModule.cs"
#line 566 "AdvancedModule.cs"
                                double* csharp2cuda_temp_378 = &(survival);
#line 566 "AdvancedModule.cs"
                                double csharp2cuda_temp_379 = *(csharp2cuda_temp_378);
#line 566 "AdvancedModule.cs"
                                double csharp2cuda_temp_380 = (a)[index];
                                (*(csharp2cuda_temp_378) = __dsub_rn(csharp2cuda_temp_379, csharp2cuda_temp_380));
                            }
#line 563 "AdvancedModule.cs"
                            int* csharp2cuda_temp_373 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_373));
                        }
                    }
#line 568 "AdvancedModule.cs"
                    break;
                }
#line 570 "AdvancedModule.cs"
            case 18:
#line 571 "AdvancedModule.cs"
#line 571 "AdvancedModule.cs"
                int csharp2cuda_temp_381 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_381);
#line 572 "AdvancedModule.cs"
#line 572 "AdvancedModule.cs"
                int csharp2cuda_temp_382 = (first)->count;
#line 572 "AdvancedModule.cs"
                int csharp2cuda_temp_383 = (second)->count;
                if (((csharp2cuda_temp_382) != (csharp2cuda_temp_383)))
#line 573 "AdvancedModule.cs"
                {
#line 574 "AdvancedModule.cs"
#line 574 "AdvancedModule.cs"
                    int* csharp2cuda_temp_384 = &((output)->valid);
                    (*(csharp2cuda_temp_384) = 0);
#line 575 "AdvancedModule.cs"
                    break;
                }
#line 577 "AdvancedModule.cs"
                {
#line 578 "AdvancedModule.cs"
                    double survival = 1.0;
#line 579 "AdvancedModule.cs"
                    {
#line 579 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 579 "AdvancedModule.cs"
                            int csharp2cuda_temp_386 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_386))))
                                break;
#line 580 "AdvancedModule.cs"
                            {
#line 581 "AdvancedModule.cs"
#line 581 "AdvancedModule.cs"
                                double csharp2cuda_temp_387 = (a)[index];
#line 581 "AdvancedModule.cs"
                                bool csharp2cuda_temp_388;
#line 581 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_387) < (0.0))))
                                {
#line 581 "AdvancedModule.cs"
                                    double csharp2cuda_temp_389 = (b)[index];
#line 581 "AdvancedModule.cs"
                                    csharp2cuda_temp_388 = ((csharp2cuda_temp_389) <= (0.0));
                                }
                                else
                                {
#line 581 "AdvancedModule.cs"
                                    csharp2cuda_temp_388 = true;
                                }
#line 581 "AdvancedModule.cs"
                                bool csharp2cuda_temp_390;
#line 581 "AdvancedModule.cs"
                                if (!(csharp2cuda_temp_388))
                                {
#line 581 "AdvancedModule.cs"
                                    double csharp2cuda_temp_391 = (a)[index];
#line 581 "AdvancedModule.cs"
                                    double csharp2cuda_temp_392 = (b)[index];
#line 581 "AdvancedModule.cs"
                                    csharp2cuda_temp_390 = ((csharp2cuda_temp_391) > (csharp2cuda_temp_392));
                                }
                                else
                                {
#line 581 "AdvancedModule.cs"
                                    csharp2cuda_temp_390 = true;
                                }
                                if (csharp2cuda_temp_390)
#line 582 "AdvancedModule.cs"
                                {
#line 583 "AdvancedModule.cs"
#line 583 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_393 = &((output)->valid);
                                    (*(csharp2cuda_temp_393) = 0);
#line 584 "AdvancedModule.cs"
                                    break;
                                }
#line 586 "AdvancedModule.cs"
#line 586 "AdvancedModule.cs"
                                double* csharp2cuda_temp_394 = &(survival);
#line 586 "AdvancedModule.cs"
                                double csharp2cuda_temp_395 = *(csharp2cuda_temp_394);
#line 586 "AdvancedModule.cs"
                                double csharp2cuda_temp_396 = (a)[index];
#line 586 "AdvancedModule.cs"
                                double csharp2cuda_temp_397 = (b)[index];
#line 586 "AdvancedModule.cs"
                                double csharp2cuda_temp_398 = __ddiv_rn(csharp2cuda_temp_396, csharp2cuda_temp_397);
                                (*(csharp2cuda_temp_394) = __dmul_rn(csharp2cuda_temp_395, __dsub_rn(1.0, csharp2cuda_temp_398)));
#line 587 "AdvancedModule.cs"
#line 587 "AdvancedModule.cs"
                                double* csharp2cuda_temp_399 = &((result)[index]);
                                (*(csharp2cuda_temp_399) = survival);
                            }
#line 579 "AdvancedModule.cs"
                            int* csharp2cuda_temp_385 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_385));
                        }
                    }
#line 589 "AdvancedModule.cs"
                    break;
                }
        }
#line 593 "AdvancedModule.cs"
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_400 = (output)->valid;
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_401;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_400)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_401 = ((opcode) != (1));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_401 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_402;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_401)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_402 = ((opcode) != (2));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_402 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_403;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_402)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_403 = ((opcode) != (3));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_403 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_404;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_403)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_404 = ((opcode) != (4));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_404 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_405;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_404)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_405 = ((opcode) != (5));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_405 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_406;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_405)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_406 = ((opcode) != (7));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_406 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_407;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_406)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_407 = ((opcode) != (9));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_407 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_408;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_407)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_408 = ((opcode) != (10));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_408 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_409;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_408)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_409 = ((opcode) != (11));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_409 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_410;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_409)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_410 = ((opcode) != (13));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_410 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_411;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_410)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_411 = ((opcode) != (14));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_411 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_412;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_411)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_412 = ((opcode) != (15));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_412 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_413;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_412)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_413 = ((opcode) != (16));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_413 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_414;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_413)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_414 = ((opcode) != (17));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_414 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_415;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_414)
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_415 = ((opcode) != (18));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_415 = false;
        }
#line 593 "AdvancedModule.cs"
        bool csharp2cuda_temp_416;
#line 593 "AdvancedModule.cs"
        if (csharp2cuda_temp_415)
        {
#line 597 "AdvancedModule.cs"
            double csharp2cuda_temp_417 = (output)->scalar_value;
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_416 = (!(isfinite(csharp2cuda_temp_417)));
        }
        else
        {
#line 593 "AdvancedModule.cs"
            csharp2cuda_temp_416 = false;
        }
        if (csharp2cuda_temp_416)
#line 598 "AdvancedModule.cs"
        {
#line 599 "AdvancedModule.cs"
#line 599 "AdvancedModule.cs"
            int* csharp2cuda_temp_418 = &((output)->valid);
            (*(csharp2cuda_temp_418) = 0);
        }
#line 601 "AdvancedModule.cs"
#line 601 "AdvancedModule.cs"
        bool csharp2cuda_temp_419 = (output)->valid;
#line 601 "AdvancedModule.cs"
        bool csharp2cuda_temp_420;
#line 601 "AdvancedModule.cs"
        if (csharp2cuda_temp_419)
        {
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_421;
#line 602 "AdvancedModule.cs"
            if (!(((opcode) == (2))))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_421 = ((opcode) == (3));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_421 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_422;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_421))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_422 = ((opcode) == (4));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_422 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_423;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_422))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_423 = ((opcode) == (5));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_423 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_424;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_423))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_424 = ((opcode) == (7));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_424 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_425;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_424))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_425 = ((opcode) == (9));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_425 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_426;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_425))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_426 = ((opcode) == (10));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_426 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_427;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_426))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_427 = ((opcode) == (13));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_427 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_428;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_427))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_428 = ((opcode) == (16));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_428 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_429;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_428))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_429 = ((opcode) == (17));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_429 = true;
            }
#line 602 "AdvancedModule.cs"
            bool csharp2cuda_temp_430;
#line 602 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_429))
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_430 = ((opcode) == (18));
            }
            else
            {
#line 602 "AdvancedModule.cs"
                csharp2cuda_temp_430 = true;
            }
#line 601 "AdvancedModule.cs"
            csharp2cuda_temp_420 = csharp2cuda_temp_430;
        }
        else
        {
#line 601 "AdvancedModule.cs"
            csharp2cuda_temp_420 = false;
        }
        if (csharp2cuda_temp_420)
#line 605 "AdvancedModule.cs"
        {
#line 606 "AdvancedModule.cs"
            {
#line 606 "AdvancedModule.cs"
                int index = 0;
                while (true)
                {
#line 606 "AdvancedModule.cs"
                    int csharp2cuda_temp_432 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_432))))
                        break;
#line 607 "AdvancedModule.cs"
#line 607 "AdvancedModule.cs"
                    double csharp2cuda_temp_433 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_433))))
                    {
#line 607 "AdvancedModule.cs"
#line 607 "AdvancedModule.cs"
                        int* csharp2cuda_temp_434 = &((output)->valid);
                        (*(csharp2cuda_temp_434) = 0);
                    }
#line 606 "AdvancedModule.cs"
                    int* csharp2cuda_temp_431 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_431));
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