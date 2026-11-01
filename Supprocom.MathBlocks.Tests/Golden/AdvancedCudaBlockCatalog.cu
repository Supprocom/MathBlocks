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
#line 154 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 155 "AdvancedModule.cs"
    {
#line 156 "AdvancedModule.cs"
        switch (opcode)
        {
#line 158 "AdvancedModule.cs"
            case 0:
#line 159 "AdvancedModule.cs"
#line 159 "AdvancedModule.cs"
                int csharp2cuda_temp_25 = (first)->count;
#line 159 "AdvancedModule.cs"
                bool csharp2cuda_temp_26;
#line 159 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_25) <= (0))))
                {
#line 159 "AdvancedModule.cs"
                    int csharp2cuda_temp_27 = (first)->count;
#line 159 "AdvancedModule.cs"
                    csharp2cuda_temp_26 = ((csharp2cuda_temp_27) >= (31));
                }
                else
                {
#line 159 "AdvancedModule.cs"
                    csharp2cuda_temp_26 = true;
                }
#line 159 "AdvancedModule.cs"
                bool csharp2cuda_temp_28;
#line 159 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_26))
                {
#line 160 "AdvancedModule.cs"
                    int csharp2cuda_temp_29 = (second)->count;
#line 160 "AdvancedModule.cs"
                    int csharp2cuda_temp_30 = (first)->count;
#line 159 "AdvancedModule.cs"
                    csharp2cuda_temp_28 = ((csharp2cuda_temp_29) != (csharp2cuda_i32_shl(1, csharp2cuda_temp_30)));
                }
                else
                {
#line 159 "AdvancedModule.cs"
                    csharp2cuda_temp_28 = true;
                }
#line 159 "AdvancedModule.cs"
                bool csharp2cuda_temp_31;
#line 159 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_28))
                {
#line 159 "AdvancedModule.cs"
                    csharp2cuda_temp_31 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 159 "AdvancedModule.cs"
                    csharp2cuda_temp_31 = true;
                }
                if (csharp2cuda_temp_31)
#line 161 "AdvancedModule.cs"
                {
#line 162 "AdvancedModule.cs"
#line 162 "AdvancedModule.cs"
                    int* csharp2cuda_temp_32 = &((output)->valid);
                    (*(csharp2cuda_temp_32) = 0);
#line 163 "AdvancedModule.cs"
                    break;
                }
#line 165 "AdvancedModule.cs"
                {
#line 165 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 165 "AdvancedModule.cs"
                        int csharp2cuda_temp_34 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_34))))
                            break;
#line 166 "AdvancedModule.cs"
                        {
#line 167 "AdvancedModule.cs"
#line 167 "AdvancedModule.cs"
                            double csharp2cuda_temp_35 = (a)[index];
                            if (((csharp2cuda_temp_35) < (0.0)))
#line 168 "AdvancedModule.cs"
                            {
#line 169 "AdvancedModule.cs"
#line 169 "AdvancedModule.cs"
                                int* csharp2cuda_temp_36 = &((output)->valid);
                                (*(csharp2cuda_temp_36) = 0);
#line 170 "AdvancedModule.cs"
                                break;
                            }
#line 172 "AdvancedModule.cs"
                            int position = index;
#line 173 "AdvancedModule.cs"
                            while (true)
                            {
#line 173 "AdvancedModule.cs"
                                bool csharp2cuda_temp_37;
#line 173 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 173 "AdvancedModule.cs"
                                    double csharp2cuda_temp_38 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 173 "AdvancedModule.cs"
                                    double csharp2cuda_temp_39 = (a)[csharp2cuda_f64_to_i32(csharp2cuda_temp_38)];
#line 173 "AdvancedModule.cs"
                                    double csharp2cuda_temp_40 = (a)[index];
#line 173 "AdvancedModule.cs"
                                    csharp2cuda_temp_37 = ((csharp2cuda_temp_39) > (csharp2cuda_temp_40));
                                }
                                else
                                {
#line 173 "AdvancedModule.cs"
                                    csharp2cuda_temp_37 = false;
                                }
                                if (!(csharp2cuda_temp_37))
                                    break;
#line 174 "AdvancedModule.cs"
                                {
#line 175 "AdvancedModule.cs"
#line 175 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_41 = &((scratch)[position]);
#line 175 "AdvancedModule.cs"
                                    double csharp2cuda_temp_42 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                                    (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 176 "AdvancedModule.cs"
#line 176 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_43 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_43));
                                }
                            }
#line 178 "AdvancedModule.cs"
#line 178 "AdvancedModule.cs"
                            double* csharp2cuda_temp_44 = &((scratch)[position]);
                            (*(csharp2cuda_temp_44) = ((double)(index)));
                        }
#line 165 "AdvancedModule.cs"
                        int* csharp2cuda_temp_33 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
                    }
                }
#line 180 "AdvancedModule.cs"
                if ((output)->valid)
#line 181 "AdvancedModule.cs"
                {
#line 182 "AdvancedModule.cs"
                    double total = 0.0;
#line 183 "AdvancedModule.cs"
                    double previous = 0.0;
#line 184 "AdvancedModule.cs"
                    {
#line 184 "AdvancedModule.cs"
                        int position = 0;
                        while (true)
                        {
#line 184 "AdvancedModule.cs"
                            int csharp2cuda_temp_46 = (first)->count;
                            if (!(((position) < (csharp2cuda_temp_46))))
                                break;
#line 185 "AdvancedModule.cs"
                            {
#line 186 "AdvancedModule.cs"
                                int coalition = 0;
#line 187 "AdvancedModule.cs"
                                {
#line 187 "AdvancedModule.cs"
                                    int index = position;
                                    while (true)
                                    {
#line 187 "AdvancedModule.cs"
                                        int csharp2cuda_temp_48 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_48))))
                                            break;
#line 188 "AdvancedModule.cs"
#line 188 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_49 = &(coalition);
#line 188 "AdvancedModule.cs"
                                        int csharp2cuda_temp_50 = *(csharp2cuda_temp_49);
#line 188 "AdvancedModule.cs"
                                        double csharp2cuda_temp_51 = (scratch)[index];
                                        (*(csharp2cuda_temp_49) = csharp2cuda_i32_or(csharp2cuda_temp_50, csharp2cuda_i32_shl(1, csharp2cuda_f64_to_i32(csharp2cuda_temp_51))));
#line 187 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_47 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_47));
                                    }
                                }
#line 189 "AdvancedModule.cs"
                                double csharp2cuda_temp_52 = (scratch)[position];
#line 189 "AdvancedModule.cs"
                                int ordered = csharp2cuda_f64_to_i32(csharp2cuda_temp_52);
#line 190 "AdvancedModule.cs"
#line 190 "AdvancedModule.cs"
                                double* csharp2cuda_temp_53 = &(total);
#line 190 "AdvancedModule.cs"
                                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 190 "AdvancedModule.cs"
                                double csharp2cuda_temp_55 = (a)[ordered];
#line 190 "AdvancedModule.cs"
                                double csharp2cuda_temp_56 = (b)[coalition];
                                (*(csharp2cuda_temp_53) = __dadd_rn(csharp2cuda_temp_54, __dmul_rn(__dsub_rn(csharp2cuda_temp_55, previous), csharp2cuda_temp_56)));
#line 191 "AdvancedModule.cs"
#line 191 "AdvancedModule.cs"
                                double* csharp2cuda_temp_57 = &(previous);
#line 191 "AdvancedModule.cs"
                                double csharp2cuda_temp_58 = (a)[ordered];
                                (*(csharp2cuda_temp_57) = csharp2cuda_temp_58);
                            }
#line 184 "AdvancedModule.cs"
                            int* csharp2cuda_temp_45 = &(position);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                        }
                    }
#line 193 "AdvancedModule.cs"
#line 193 "AdvancedModule.cs"
                    double* csharp2cuda_temp_59 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_59) = total);
                }
#line 195 "AdvancedModule.cs"
                break;
#line 196 "AdvancedModule.cs"
            case 1:
#line 197 "AdvancedModule.cs"
#line 197 "AdvancedModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
#line 197 "AdvancedModule.cs"
                bool csharp2cuda_temp_61;
#line 197 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_60)))))
                {
#line 197 "AdvancedModule.cs"
                    int csharp2cuda_temp_62 = (first)->count;
#line 197 "AdvancedModule.cs"
                    csharp2cuda_temp_61 = ((csharp2cuda_temp_62) > (csharp2cuda_i32_shl(1, 12)));
                }
                else
                {
#line 197 "AdvancedModule.cs"
                    csharp2cuda_temp_61 = true;
                }
                if (csharp2cuda_temp_61)
#line 198 "AdvancedModule.cs"
                {
#line 199 "AdvancedModule.cs"
#line 199 "AdvancedModule.cs"
                    int* csharp2cuda_temp_63 = &((output)->valid);
                    (*(csharp2cuda_temp_63) = 0);
#line 200 "AdvancedModule.cs"
                    break;
                }
#line 202 "AdvancedModule.cs"
#line 202 "AdvancedModule.cs"
                int* csharp2cuda_temp_64 = &((output)->boolean_value);
                (*(csharp2cuda_temp_64) = 1);
#line 203 "AdvancedModule.cs"
                {
#line 203 "AdvancedModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 203 "AdvancedModule.cs"
                        int csharp2cuda_temp_66 = (first)->count;
#line 203 "AdvancedModule.cs"
                        bool csharp2cuda_temp_67;
#line 203 "AdvancedModule.cs"
                        if (((left) < (csharp2cuda_temp_66)))
                        {
#line 203 "AdvancedModule.cs"
                            csharp2cuda_temp_67 = (output)->boolean_value;
                        }
                        else
                        {
#line 203 "AdvancedModule.cs"
                            csharp2cuda_temp_67 = false;
                        }
                        if (!(csharp2cuda_temp_67))
                            break;
#line 204 "AdvancedModule.cs"
                        {
#line 204 "AdvancedModule.cs"
                            int right = 0;
                            while (true)
                            {
#line 204 "AdvancedModule.cs"
                                int csharp2cuda_temp_69 = (first)->count;
                                if (!(((right) < (csharp2cuda_temp_69))))
                                    break;
#line 205 "AdvancedModule.cs"
#line 205 "AdvancedModule.cs"
                                double csharp2cuda_temp_70 = (a)[left];
#line 205 "AdvancedModule.cs"
                                double csharp2cuda_temp_71 = (a)[right];
#line 205 "AdvancedModule.cs"
                                double csharp2cuda_temp_72 = (a)[csharp2cuda_i32_or(left, right)];
#line 205 "AdvancedModule.cs"
                                double csharp2cuda_temp_73 = (a)[csharp2cuda_i32_and(left, right)];
                                if (((__dadd_rn(csharp2cuda_temp_70, csharp2cuda_temp_71)) < (__dadd_rn(csharp2cuda_temp_72, csharp2cuda_temp_73))))
#line 206 "AdvancedModule.cs"
                                {
#line 207 "AdvancedModule.cs"
#line 207 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_74 = &((output)->boolean_value);
                                    (*(csharp2cuda_temp_74) = 0);
#line 208 "AdvancedModule.cs"
                                    break;
                                }
#line 204 "AdvancedModule.cs"
                                int* csharp2cuda_temp_68 = &(right);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                            }
                        }
#line 203 "AdvancedModule.cs"
                        int* csharp2cuda_temp_65 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_65));
                    }
                }
#line 210 "AdvancedModule.cs"
                break;
#line 211 "AdvancedModule.cs"
            case 2:
#line 212 "AdvancedModule.cs"
#line 212 "AdvancedModule.cs"
                int csharp2cuda_temp_75 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_75);
#line 213 "AdvancedModule.cs"
#line 213 "AdvancedModule.cs"
                int csharp2cuda_temp_76 = (first)->count;
                if ((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_76))))
#line 214 "AdvancedModule.cs"
                {
#line 215 "AdvancedModule.cs"
#line 215 "AdvancedModule.cs"
                    int* csharp2cuda_temp_77 = &((output)->valid);
                    (*(csharp2cuda_temp_77) = 0);
#line 216 "AdvancedModule.cs"
                    break;
                }
#line 218 "AdvancedModule.cs"
                {
#line 218 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 218 "AdvancedModule.cs"
                        int csharp2cuda_temp_79 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_79))))
                            break;
#line 219 "AdvancedModule.cs"
#line 219 "AdvancedModule.cs"
                        double* csharp2cuda_temp_80 = &((result)[index]);
#line 219 "AdvancedModule.cs"
                        double csharp2cuda_temp_81 = (a)[index];
                        (*(csharp2cuda_temp_80) = csharp2cuda_temp_81);
#line 218 "AdvancedModule.cs"
                        int* csharp2cuda_temp_78 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_78));
                    }
                }
#line 220 "AdvancedModule.cs"
                {
#line 220 "AdvancedModule.cs"
                    int bit = 0;
                    while (true)
                    {
#line 220 "AdvancedModule.cs"
                        int csharp2cuda_temp_83 = (first)->count;
                        if (!(((bit) < (mathblocks_advanced_log_two(csharp2cuda_temp_83)))))
                            break;
#line 221 "AdvancedModule.cs"
                        {
#line 221 "AdvancedModule.cs"
                            int mask = 0;
                            while (true)
                            {
#line 221 "AdvancedModule.cs"
                                int csharp2cuda_temp_85 = (first)->count;
                                if (!(((mask) < (csharp2cuda_temp_85))))
                                    break;
#line 222 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, bit))) != (0)))
                                {
#line 223 "AdvancedModule.cs"
#line 223 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_86 = &((result)[mask]);
#line 223 "AdvancedModule.cs"
                                    double csharp2cuda_temp_87 = *(csharp2cuda_temp_86);
#line 223 "AdvancedModule.cs"
                                    double csharp2cuda_temp_88 = (result)[csharp2cuda_i32_xor(mask, csharp2cuda_i32_shl(1, bit))];
                                    (*(csharp2cuda_temp_86) = __dsub_rn(csharp2cuda_temp_87, csharp2cuda_temp_88));
                                }
#line 221 "AdvancedModule.cs"
                                int* csharp2cuda_temp_84 = &(mask);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_84));
                            }
                        }
#line 220 "AdvancedModule.cs"
                        int* csharp2cuda_temp_82 = &(bit);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_82));
                    }
                }
#line 224 "AdvancedModule.cs"
                break;
#line 225 "AdvancedModule.cs"
            case 3:
#line 226 "AdvancedModule.cs"
#line 226 "AdvancedModule.cs"
                int csharp2cuda_temp_89 = (first)->count;
#line 226 "AdvancedModule.cs"
                bool csharp2cuda_temp_90;
#line 226 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_89)))))
                {
#line 226 "AdvancedModule.cs"
                    int csharp2cuda_temp_91 = (first)->count;
#line 226 "AdvancedModule.cs"
                    csharp2cuda_temp_90 = ((csharp2cuda_temp_91) > (csharp2cuda_i32_shl(1, 20)));
                }
                else
                {
#line 226 "AdvancedModule.cs"
                    csharp2cuda_temp_90 = true;
                }
                if (csharp2cuda_temp_90)
#line 227 "AdvancedModule.cs"
                {
#line 228 "AdvancedModule.cs"
#line 228 "AdvancedModule.cs"
                    int* csharp2cuda_temp_92 = &((output)->valid);
                    (*(csharp2cuda_temp_92) = 0);
#line 229 "AdvancedModule.cs"
                    break;
                }
#line 231 "AdvancedModule.cs"
                {
#line 232 "AdvancedModule.cs"
                    int csharp2cuda_temp_93 = (first)->count;
#line 232 "AdvancedModule.cs"
                    int player_count = mathblocks_advanced_log_two(csharp2cuda_temp_93);
#line 233 "AdvancedModule.cs"
                    mathblocks_sequence_set_vector_shape(output, player_count);
#line 234 "AdvancedModule.cs"
                    double denominator = mathblocks_advanced_factorial(player_count);
#line 235 "AdvancedModule.cs"
                    {
#line 235 "AdvancedModule.cs"
                        int player = 0;
                        while (true)
                        {
                            if (!(((player) < (player_count))))
                                break;
#line 236 "AdvancedModule.cs"
                            {
#line 237 "AdvancedModule.cs"
#line 237 "AdvancedModule.cs"
                                double* csharp2cuda_temp_95 = &((result)[player]);
                                (*(csharp2cuda_temp_95) = 0.0);
#line 238 "AdvancedModule.cs"
                                {
#line 238 "AdvancedModule.cs"
                                    int coalition = 0;
                                    while (true)
                                    {
#line 238 "AdvancedModule.cs"
                                        int csharp2cuda_temp_97 = (first)->count;
                                        if (!(((coalition) < (csharp2cuda_temp_97))))
                                            break;
#line 239 "AdvancedModule.cs"
                                        {
#line 240 "AdvancedModule.cs"
                                            if (((csharp2cuda_i32_and(coalition, csharp2cuda_i32_shl(1, player))) != (0)))
                                            {
#line 241 "AdvancedModule.cs"
                                                goto csharp2cuda_for_continue_9;
                                            }
#line 242 "AdvancedModule.cs"
                                            int size = mathblocks_advanced_popcount(coalition);
#line 243 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(__dmul_rn(mathblocks_advanced_factorial(size), mathblocks_advanced_factorial(csharp2cuda_i32_sub(csharp2cuda_i32_sub(player_count, size), 1))), denominator);
#line 246 "AdvancedModule.cs"
#line 246 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_98 = &((result)[player]);
#line 246 "AdvancedModule.cs"
                                            double csharp2cuda_temp_99 = *(csharp2cuda_temp_98);
#line 247 "AdvancedModule.cs"
                                            double csharp2cuda_temp_100 = (a)[csharp2cuda_i32_or(coalition, csharp2cuda_i32_shl(1, player))];
#line 247 "AdvancedModule.cs"
                                            double csharp2cuda_temp_101 = (a)[coalition];
                                            (*(csharp2cuda_temp_98) = __dadd_rn(csharp2cuda_temp_99, __dmul_rn(weight, __dsub_rn(csharp2cuda_temp_100, csharp2cuda_temp_101))));
                                        }
                                        csharp2cuda_for_continue_9:
#line 238 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_96 = &(coalition);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_96));
                                    }
                                }
                            }
#line 235 "AdvancedModule.cs"
                            int* csharp2cuda_temp_94 = &(player);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_94));
                        }
                    }
#line 250 "AdvancedModule.cs"
                    break;
                }
#line 252 "AdvancedModule.cs"
            case 4:
            case 5:
#line 254 "AdvancedModule.cs"
#line 254 "AdvancedModule.cs"
                int csharp2cuda_temp_102 = (third)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_102);
#line 255 "AdvancedModule.cs"
#line 255 "AdvancedModule.cs"
                int csharp2cuda_temp_103 = (first)->count;
#line 255 "AdvancedModule.cs"
                bool csharp2cuda_temp_104;
#line 255 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_103) <= (0))))
                {
#line 255 "AdvancedModule.cs"
                    int csharp2cuda_temp_105 = (first)->count;
#line 255 "AdvancedModule.cs"
                    int csharp2cuda_temp_106 = (second)->count;
#line 255 "AdvancedModule.cs"
                    csharp2cuda_temp_104 = ((csharp2cuda_temp_105) != (csharp2cuda_temp_106));
                }
                else
                {
#line 255 "AdvancedModule.cs"
                    csharp2cuda_temp_104 = true;
                }
#line 255 "AdvancedModule.cs"
                bool csharp2cuda_temp_107;
#line 255 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_104))
                {
#line 255 "AdvancedModule.cs"
                    double csharp2cuda_temp_108 = (fourth)->scalar_value;
#line 255 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = ((csharp2cuda_temp_108) < (0.0));
                }
                else
                {
#line 255 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = true;
                }
                if (csharp2cuda_temp_107)
#line 256 "AdvancedModule.cs"
                {
#line 257 "AdvancedModule.cs"
#line 257 "AdvancedModule.cs"
                    int* csharp2cuda_temp_109 = &((output)->valid);
                    (*(csharp2cuda_temp_109) = 0);
#line 258 "AdvancedModule.cs"
                    break;
                }
#line 260 "AdvancedModule.cs"
                {
#line 260 "AdvancedModule.cs"
                    int query = 0;
                    while (true)
                    {
#line 260 "AdvancedModule.cs"
                        int csharp2cuda_temp_111 = (third)->count;
                        if (!(((query) < (csharp2cuda_temp_111))))
                            break;
#line 261 "AdvancedModule.cs"
                        {
#line 262 "AdvancedModule.cs"
                            double csharp2cuda_temp_112;
#line 262 "AdvancedModule.cs"
                            if (((opcode) == (4)))
                            {
#line 262 "AdvancedModule.cs"
                                csharp2cuda_temp_112 = mathblocks_positive_infinity();
                            }
                            else
                            {
#line 262 "AdvancedModule.cs"
                                csharp2cuda_temp_112 = (-(mathblocks_positive_infinity()));
                            }
#line 262 "AdvancedModule.cs"
                            double selected = csharp2cuda_temp_112;
#line 265 "AdvancedModule.cs"
                            {
#line 265 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
#line 265 "AdvancedModule.cs"
                                    int csharp2cuda_temp_114 = (first)->count;
                                    if (!(((index) < (csharp2cuda_temp_114))))
                                        break;
#line 266 "AdvancedModule.cs"
                                    {
#line 267 "AdvancedModule.cs"
                                        double csharp2cuda_temp_115;
#line 267 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 268 "AdvancedModule.cs"
                                            double csharp2cuda_temp_116 = (b)[index];
#line 268 "AdvancedModule.cs"
                                            double csharp2cuda_temp_117 = (fourth)->scalar_value;
#line 268 "AdvancedModule.cs"
                                            double csharp2cuda_temp_118 = (c)[query];
#line 268 "AdvancedModule.cs"
                                            double csharp2cuda_temp_119 = (a)[index];
#line 267 "AdvancedModule.cs"
                                            csharp2cuda_temp_115 = __dadd_rn(csharp2cuda_temp_116, __dmul_rn(csharp2cuda_temp_117, fabs(__dsub_rn(csharp2cuda_temp_118, csharp2cuda_temp_119))));
                                        }
                                        else
                                        {
#line 269 "AdvancedModule.cs"
                                            double csharp2cuda_temp_120 = (b)[index];
#line 269 "AdvancedModule.cs"
                                            double csharp2cuda_temp_121 = (fourth)->scalar_value;
#line 269 "AdvancedModule.cs"
                                            double csharp2cuda_temp_122 = (c)[query];
#line 269 "AdvancedModule.cs"
                                            double csharp2cuda_temp_123 = (a)[index];
#line 267 "AdvancedModule.cs"
                                            csharp2cuda_temp_115 = __dsub_rn(csharp2cuda_temp_120, __dmul_rn(csharp2cuda_temp_121, fabs(__dsub_rn(csharp2cuda_temp_122, csharp2cuda_temp_123))));
                                        }
#line 267 "AdvancedModule.cs"
                                        double candidate = csharp2cuda_temp_115;
#line 272 "AdvancedModule.cs"
#line 272 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_124 = &(selected);
#line 272 "AdvancedModule.cs"
                                        double csharp2cuda_temp_125;
#line 272 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 272 "AdvancedModule.cs"
                                            csharp2cuda_temp_125 = mathblocks_minimum(selected, candidate);
                                        }
                                        else
                                        {
#line 272 "AdvancedModule.cs"
                                            csharp2cuda_temp_125 = mathblocks_maximum(selected, candidate);
                                        }
                                        (*(csharp2cuda_temp_124) = csharp2cuda_temp_125);
                                    }
#line 265 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_113 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                                }
                            }
#line 276 "AdvancedModule.cs"
#line 276 "AdvancedModule.cs"
                            double* csharp2cuda_temp_126 = &((result)[query]);
                            (*(csharp2cuda_temp_126) = selected);
                        }
#line 260 "AdvancedModule.cs"
                        int* csharp2cuda_temp_110 = &(query);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_110));
                    }
                }
#line 278 "AdvancedModule.cs"
                break;
#line 279 "AdvancedModule.cs"
            case 6:
#line 280 "AdvancedModule.cs"
#line 280 "AdvancedModule.cs"
                int csharp2cuda_temp_127 = (first)->count;
                if (((csharp2cuda_temp_127) <= (0)))
#line 281 "AdvancedModule.cs"
                {
#line 282 "AdvancedModule.cs"
#line 282 "AdvancedModule.cs"
                    int* csharp2cuda_temp_128 = &((output)->valid);
                    (*(csharp2cuda_temp_128) = 0);
#line 283 "AdvancedModule.cs"
                    break;
                }
#line 285 "AdvancedModule.cs"
                {
#line 286 "AdvancedModule.cs"
                    double sum = 0.0;
#line 287 "AdvancedModule.cs"
                    {
#line 287 "AdvancedModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 287 "AdvancedModule.cs"
                            int csharp2cuda_temp_130 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_130))))
                                break;
#line 288 "AdvancedModule.cs"
                            {
#line 288 "AdvancedModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 288 "AdvancedModule.cs"
                                    int csharp2cuda_temp_132 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_132))))
                                        break;
#line 289 "AdvancedModule.cs"
#line 289 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_133 = &(sum);
#line 289 "AdvancedModule.cs"
                                    double csharp2cuda_temp_134 = *(csharp2cuda_temp_133);
#line 289 "AdvancedModule.cs"
                                    double csharp2cuda_temp_135 = (a)[left];
#line 289 "AdvancedModule.cs"
                                    double csharp2cuda_temp_136 = (a)[right];
                                    (*(csharp2cuda_temp_133) = __dadd_rn(csharp2cuda_temp_134, fabs(__dsub_rn(csharp2cuda_temp_135, csharp2cuda_temp_136))));
#line 288 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_131 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_131));
                                }
                            }
#line 287 "AdvancedModule.cs"
                            int* csharp2cuda_temp_129 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_129));
                        }
                    }
#line 290 "AdvancedModule.cs"
#line 290 "AdvancedModule.cs"
                    double* csharp2cuda_temp_137 = &((output)->scalar_value);
#line 291 "AdvancedModule.cs"
                    int csharp2cuda_temp_138 = (first)->count;
#line 291 "AdvancedModule.cs"
                    int csharp2cuda_temp_139 = (first)->count;
#line 290 "AdvancedModule.cs"
                    double csharp2cuda_temp_140 = __ddiv_rn(sum, __dmul_rn(__dmul_rn(2.0, ((double)(csharp2cuda_temp_138))), mathblocks_compensated_sum(a, csharp2cuda_temp_139)));
                    (*(csharp2cuda_temp_137) = csharp2cuda_temp_140);
#line 292 "AdvancedModule.cs"
                    break;
                }
#line 294 "AdvancedModule.cs"
            case 7:
#line 295 "AdvancedModule.cs"
#line 295 "AdvancedModule.cs"
                int csharp2cuda_temp_141 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_141, 1));
#line 296 "AdvancedModule.cs"
#line 296 "AdvancedModule.cs"
                int csharp2cuda_temp_142 = (first)->count;
#line 296 "AdvancedModule.cs"
                bool csharp2cuda_temp_143;
#line 296 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_142) <= (0))))
                {
#line 296 "AdvancedModule.cs"
                    csharp2cuda_temp_143 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 296 "AdvancedModule.cs"
                    csharp2cuda_temp_143 = true;
                }
                if (csharp2cuda_temp_143)
#line 297 "AdvancedModule.cs"
                {
#line 298 "AdvancedModule.cs"
#line 298 "AdvancedModule.cs"
                    int* csharp2cuda_temp_144 = &((output)->valid);
                    (*(csharp2cuda_temp_144) = 0);
#line 299 "AdvancedModule.cs"
                    break;
                }
#line 301 "AdvancedModule.cs"
#line 301 "AdvancedModule.cs"
                double* csharp2cuda_temp_145 = &((result)[0]);
                (*(csharp2cuda_temp_145) = 0.0);
#line 302 "AdvancedModule.cs"
                {
#line 302 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 302 "AdvancedModule.cs"
                        int csharp2cuda_temp_147 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_147))))
                            break;
#line 303 "AdvancedModule.cs"
#line 303 "AdvancedModule.cs"
                        double* csharp2cuda_temp_148 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 303 "AdvancedModule.cs"
                        double csharp2cuda_temp_149 = (a)[index];
                        (*(csharp2cuda_temp_148) = csharp2cuda_temp_149);
#line 302 "AdvancedModule.cs"
                        int* csharp2cuda_temp_146 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_146));
                    }
                }
#line 304 "AdvancedModule.cs"
                {
#line 305 "AdvancedModule.cs"
                    int csharp2cuda_temp_150 = (first)->count;
#line 305 "AdvancedModule.cs"
                    double* sorted = mathblocks_stable_merge_sort(csharp2cuda_pointer_add(result, 1), scratch, csharp2cuda_temp_150, false);
#line 306 "AdvancedModule.cs"
                    if (((((void*)(sorted))) != (((void*)(csharp2cuda_pointer_add(result, 1))))))
                    {
#line 307 "AdvancedModule.cs"
                        {
#line 307 "AdvancedModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 307 "AdvancedModule.cs"
                                int csharp2cuda_temp_152 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_152))))
                                    break;
#line 308 "AdvancedModule.cs"
#line 308 "AdvancedModule.cs"
                                double* csharp2cuda_temp_153 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 308 "AdvancedModule.cs"
                                double csharp2cuda_temp_154 = (sorted)[index];
                                (*(csharp2cuda_temp_153) = csharp2cuda_temp_154);
#line 307 "AdvancedModule.cs"
                                int* csharp2cuda_temp_151 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_151));
                            }
                        }
                    }
                }
#line 310 "AdvancedModule.cs"
                {
#line 311 "AdvancedModule.cs"
                    int csharp2cuda_temp_155 = (first)->count;
#line 311 "AdvancedModule.cs"
                    double total = mathblocks_compensated_sum(csharp2cuda_pointer_add(result, 1), csharp2cuda_temp_155);
#line 312 "AdvancedModule.cs"
                    {
#line 312 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 312 "AdvancedModule.cs"
                            int csharp2cuda_temp_157 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_157))))
                                break;
#line 313 "AdvancedModule.cs"
#line 313 "AdvancedModule.cs"
                            double* csharp2cuda_temp_158 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 313 "AdvancedModule.cs"
                            double csharp2cuda_temp_159 = (result)[index];
#line 313 "AdvancedModule.cs"
                            double csharp2cuda_temp_160 = (result)[csharp2cuda_i32_add(index, 1)];
#line 313 "AdvancedModule.cs"
                            double csharp2cuda_temp_161 = __ddiv_rn(csharp2cuda_temp_160, total);
                            (*(csharp2cuda_temp_158) = __dadd_rn(csharp2cuda_temp_159, csharp2cuda_temp_161));
#line 312 "AdvancedModule.cs"
                            int* csharp2cuda_temp_156 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                        }
                    }
#line 314 "AdvancedModule.cs"
                    break;
                }
#line 316 "AdvancedModule.cs"
            case 8:
#line 317 "AdvancedModule.cs"
#line 317 "AdvancedModule.cs"
                int csharp2cuda_temp_162 = (first)->rows;
#line 317 "AdvancedModule.cs"
                int csharp2cuda_temp_163 = (first)->columns;
#line 317 "AdvancedModule.cs"
                bool csharp2cuda_temp_164;
#line 317 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_162) != (csharp2cuda_temp_163))))
                {
#line 317 "AdvancedModule.cs"
                    int csharp2cuda_temp_165 = (first)->rows;
#line 317 "AdvancedModule.cs"
                    int csharp2cuda_temp_166 = (second)->count;
#line 317 "AdvancedModule.cs"
                    csharp2cuda_temp_164 = ((csharp2cuda_temp_165) != (csharp2cuda_temp_166));
                }
                else
                {
#line 317 "AdvancedModule.cs"
                    csharp2cuda_temp_164 = true;
                }
#line 317 "AdvancedModule.cs"
                bool csharp2cuda_temp_167;
#line 317 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_164))
                {
#line 318 "AdvancedModule.cs"
                    int csharp2cuda_temp_168 = (first)->rows;
#line 318 "AdvancedModule.cs"
                    int csharp2cuda_temp_169 = (first)->columns;
#line 318 "AdvancedModule.cs"
                    bool csharp2cuda_temp_170 = mathblocks_advanced_transition(a, csharp2cuda_temp_168, csharp2cuda_temp_169);
#line 317 "AdvancedModule.cs"
                    csharp2cuda_temp_167 = (!(csharp2cuda_temp_170));
                }
                else
                {
#line 317 "AdvancedModule.cs"
                    csharp2cuda_temp_167 = true;
                }
#line 317 "AdvancedModule.cs"
                bool csharp2cuda_temp_171;
#line 317 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_167))
                {
#line 319 "AdvancedModule.cs"
                    int csharp2cuda_temp_172 = (second)->count;
#line 319 "AdvancedModule.cs"
                    bool csharp2cuda_temp_173 = mathblocks_advanced_distribution(b, csharp2cuda_temp_172);
#line 317 "AdvancedModule.cs"
                    csharp2cuda_temp_171 = (!(csharp2cuda_temp_173));
                }
                else
                {
#line 317 "AdvancedModule.cs"
                    csharp2cuda_temp_171 = true;
                }
                if (csharp2cuda_temp_171)
#line 320 "AdvancedModule.cs"
                {
#line 321 "AdvancedModule.cs"
#line 321 "AdvancedModule.cs"
                    int* csharp2cuda_temp_174 = &((output)->valid);
                    (*(csharp2cuda_temp_174) = 0);
#line 322 "AdvancedModule.cs"
                    break;
                }
#line 324 "AdvancedModule.cs"
                {
#line 325 "AdvancedModule.cs"
                    double total = 0.0;
#line 326 "AdvancedModule.cs"
                    {
#line 326 "AdvancedModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 326 "AdvancedModule.cs"
                            int csharp2cuda_temp_176 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_176))))
                                break;
#line 327 "AdvancedModule.cs"
                            {
#line 327 "AdvancedModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 327 "AdvancedModule.cs"
                                    int csharp2cuda_temp_178 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_178))))
                                        break;
#line 328 "AdvancedModule.cs"
                                    {
#line 329 "AdvancedModule.cs"
                                        double csharp2cuda_temp_179 = (b)[row];
#line 329 "AdvancedModule.cs"
                                        int csharp2cuda_temp_180 = (first)->columns;
#line 329 "AdvancedModule.cs"
                                        double csharp2cuda_temp_181 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_180), column)];
#line 329 "AdvancedModule.cs"
                                        double forward = __dmul_rn(csharp2cuda_temp_179, csharp2cuda_temp_181);
#line 330 "AdvancedModule.cs"
                                        double csharp2cuda_temp_182 = (b)[column];
#line 330 "AdvancedModule.cs"
                                        int csharp2cuda_temp_183 = (first)->columns;
#line 330 "AdvancedModule.cs"
                                        double csharp2cuda_temp_184 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_183), row)];
#line 330 "AdvancedModule.cs"
                                        double reverse = __dmul_rn(csharp2cuda_temp_182, csharp2cuda_temp_184);
#line 331 "AdvancedModule.cs"
#line 331 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_185;
#line 331 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 331 "AdvancedModule.cs"
                                            csharp2cuda_temp_185 = ((reverse) == (0.0));
                                        }
                                        else
                                        {
#line 331 "AdvancedModule.cs"
                                            csharp2cuda_temp_185 = false;
                                        }
                                        if (csharp2cuda_temp_185)
#line 332 "AdvancedModule.cs"
                                        {
#line 333 "AdvancedModule.cs"
#line 333 "AdvancedModule.cs"
                                            int* csharp2cuda_temp_186 = &((output)->valid);
                                            (*(csharp2cuda_temp_186) = 0);
#line 334 "AdvancedModule.cs"
                                            break;
                                        }
#line 336 "AdvancedModule.cs"
#line 336 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_187;
#line 336 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 336 "AdvancedModule.cs"
                                            csharp2cuda_temp_187 = ((reverse) > (0.0));
                                        }
                                        else
                                        {
#line 336 "AdvancedModule.cs"
                                            csharp2cuda_temp_187 = false;
                                        }
                                        if (csharp2cuda_temp_187)
                                        {
#line 337 "AdvancedModule.cs"
#line 337 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_188 = &(total);
#line 337 "AdvancedModule.cs"
                                            double csharp2cuda_temp_189 = *(csharp2cuda_temp_188);
#line 337 "AdvancedModule.cs"
                                            double csharp2cuda_temp_190 = __ddiv_rn(forward, reverse);
                                            (*(csharp2cuda_temp_188) = __dadd_rn(csharp2cuda_temp_189, __dmul_rn(forward, mathblocks_natural_logarithm(csharp2cuda_temp_190))));
                                        }
                                    }
#line 327 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_177 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_177));
                                }
                            }
#line 326 "AdvancedModule.cs"
                            int* csharp2cuda_temp_175 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_175));
                        }
                    }
#line 339 "AdvancedModule.cs"
#line 339 "AdvancedModule.cs"
                    double* csharp2cuda_temp_191 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_191) = total);
#line 340 "AdvancedModule.cs"
                    break;
                }
#line 342 "AdvancedModule.cs"
            case 9:
#line 343 "AdvancedModule.cs"
#line 343 "AdvancedModule.cs"
                int csharp2cuda_temp_192 = (first)->rows;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_192);
#line 344 "AdvancedModule.cs"
#line 344 "AdvancedModule.cs"
                int csharp2cuda_temp_193 = (first)->rows;
#line 344 "AdvancedModule.cs"
                int csharp2cuda_temp_194 = (first)->columns;
#line 344 "AdvancedModule.cs"
                bool csharp2cuda_temp_195 = mathblocks_advanced_transition(a, csharp2cuda_temp_193, csharp2cuda_temp_194);
#line 344 "AdvancedModule.cs"
                bool csharp2cuda_temp_196;
#line 344 "AdvancedModule.cs"
                if (!((!(csharp2cuda_temp_195))))
                {
#line 344 "AdvancedModule.cs"
                    csharp2cuda_temp_196 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 344 "AdvancedModule.cs"
                    csharp2cuda_temp_196 = true;
                }
                if (csharp2cuda_temp_196)
#line 345 "AdvancedModule.cs"
                {
#line 346 "AdvancedModule.cs"
#line 346 "AdvancedModule.cs"
                    int* csharp2cuda_temp_197 = &((output)->valid);
                    (*(csharp2cuda_temp_197) = 0);
#line 347 "AdvancedModule.cs"
                    break;
                }
#line 349 "AdvancedModule.cs"
                {
#line 350 "AdvancedModule.cs"
                    int iterations = 0;
#line 351 "AdvancedModule.cs"
#line 351 "AdvancedModule.cs"
                    double csharp2cuda_temp_198 = (second)->scalar_value;
#line 351 "AdvancedModule.cs"
                    int* csharp2cuda_temp_199 = &(iterations);
#line 351 "AdvancedModule.cs"
                    bool csharp2cuda_temp_200 = mathblocks_sequence_positive_integer(csharp2cuda_temp_198, csharp2cuda_temp_199);
#line 351 "AdvancedModule.cs"
                    bool csharp2cuda_temp_201;
#line 351 "AdvancedModule.cs"
                    if (!((!(csharp2cuda_temp_200))))
                    {
#line 351 "AdvancedModule.cs"
                        csharp2cuda_temp_201 = ((iterations) > (10000));
                    }
                    else
                    {
#line 351 "AdvancedModule.cs"
                        csharp2cuda_temp_201 = true;
                    }
                    if (csharp2cuda_temp_201)
#line 352 "AdvancedModule.cs"
                    {
#line 353 "AdvancedModule.cs"
#line 353 "AdvancedModule.cs"
                        int* csharp2cuda_temp_202 = &((output)->valid);
                        (*(csharp2cuda_temp_202) = 0);
#line 354 "AdvancedModule.cs"
                        break;
                    }
#line 356 "AdvancedModule.cs"
                    {
#line 356 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 356 "AdvancedModule.cs"
                            int csharp2cuda_temp_204 = (first)->rows;
                            if (!(((index) < (csharp2cuda_temp_204))))
                                break;
#line 357 "AdvancedModule.cs"
#line 357 "AdvancedModule.cs"
                            double* csharp2cuda_temp_205 = &((result)[index]);
#line 357 "AdvancedModule.cs"
                            int csharp2cuda_temp_206 = (first)->rows;
#line 357 "AdvancedModule.cs"
                            double csharp2cuda_temp_207 = __ddiv_rn(1.0, ((double)(csharp2cuda_temp_206)));
                            (*(csharp2cuda_temp_205) = csharp2cuda_temp_207);
#line 356 "AdvancedModule.cs"
                            int* csharp2cuda_temp_203 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_203));
                        }
                    }
#line 358 "AdvancedModule.cs"
                    {
#line 358 "AdvancedModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 359 "AdvancedModule.cs"
                            {
#line 360 "AdvancedModule.cs"
                                {
#line 360 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 360 "AdvancedModule.cs"
                                        int csharp2cuda_temp_210 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_210))))
                                            break;
#line 361 "AdvancedModule.cs"
#line 361 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_211 = &((scratch)[index]);
                                        (*(csharp2cuda_temp_211) = 0.0);
#line 360 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_209 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_209));
                                    }
                                }
#line 362 "AdvancedModule.cs"
                                {
#line 362 "AdvancedModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 362 "AdvancedModule.cs"
                                        int csharp2cuda_temp_213 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_213))))
                                            break;
#line 363 "AdvancedModule.cs"
                                        {
#line 363 "AdvancedModule.cs"
                                            int column = 0;
                                            while (true)
                                            {
#line 363 "AdvancedModule.cs"
                                                int csharp2cuda_temp_215 = (first)->columns;
                                                if (!(((column) < (csharp2cuda_temp_215))))
                                                    break;
#line 364 "AdvancedModule.cs"
#line 364 "AdvancedModule.cs"
                                                double* csharp2cuda_temp_216 = &((scratch)[column]);
#line 364 "AdvancedModule.cs"
                                                double csharp2cuda_temp_217 = *(csharp2cuda_temp_216);
#line 364 "AdvancedModule.cs"
                                                double csharp2cuda_temp_218 = (result)[row];
#line 364 "AdvancedModule.cs"
                                                int csharp2cuda_temp_219 = (first)->columns;
#line 364 "AdvancedModule.cs"
                                                double csharp2cuda_temp_220 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_219), column)];
                                                (*(csharp2cuda_temp_216) = __dadd_rn(csharp2cuda_temp_217, __dmul_rn(csharp2cuda_temp_218, csharp2cuda_temp_220)));
#line 363 "AdvancedModule.cs"
                                                int* csharp2cuda_temp_214 = &(column);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                            }
                                        }
#line 362 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_212 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                                    }
                                }
#line 365 "AdvancedModule.cs"
                                {
#line 365 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 365 "AdvancedModule.cs"
                                        int csharp2cuda_temp_222 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_222))))
                                            break;
#line 366 "AdvancedModule.cs"
#line 366 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_223 = &((result)[index]);
#line 366 "AdvancedModule.cs"
                                        double csharp2cuda_temp_224 = (scratch)[index];
                                        (*(csharp2cuda_temp_223) = csharp2cuda_temp_224);
#line 365 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_221 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_221));
                                    }
                                }
                            }
#line 358 "AdvancedModule.cs"
                            int* csharp2cuda_temp_208 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_208));
                        }
                    }
#line 368 "AdvancedModule.cs"
                    break;
                }
#line 370 "AdvancedModule.cs"
            case 10:
#line 371 "AdvancedModule.cs"
#line 371 "AdvancedModule.cs"
                int csharp2cuda_temp_225 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_225);
#line 372 "AdvancedModule.cs"
#line 372 "AdvancedModule.cs"
                int csharp2cuda_temp_226 = (first)->count;
#line 372 "AdvancedModule.cs"
                bool csharp2cuda_temp_227;
#line 372 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_226) <= (0))))
                {
#line 372 "AdvancedModule.cs"
                    csharp2cuda_temp_227 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 372 "AdvancedModule.cs"
                    csharp2cuda_temp_227 = true;
                }
                if (csharp2cuda_temp_227)
#line 373 "AdvancedModule.cs"
                {
#line 374 "AdvancedModule.cs"
#line 374 "AdvancedModule.cs"
                    int* csharp2cuda_temp_228 = &((output)->valid);
                    (*(csharp2cuda_temp_228) = 0);
#line 375 "AdvancedModule.cs"
                    break;
                }
#line 377 "AdvancedModule.cs"
                {
#line 378 "AdvancedModule.cs"
                    double* means = scratch;
#line 379 "AdvancedModule.cs"
                    int csharp2cuda_temp_229 = (first)->count;
#line 379 "AdvancedModule.cs"
                    int* weights = ((int*)(csharp2cuda_pointer_add(means, csharp2cuda_temp_229)));
#line 380 "AdvancedModule.cs"
                    int csharp2cuda_temp_230 = (first)->count;
#line 380 "AdvancedModule.cs"
                    int* starts = csharp2cuda_pointer_add(weights, csharp2cuda_temp_230);
#line 381 "AdvancedModule.cs"
                    int block_count = 0;
#line 382 "AdvancedModule.cs"
                    {
#line 382 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 382 "AdvancedModule.cs"
                            int csharp2cuda_temp_232 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_232))))
                                break;
#line 383 "AdvancedModule.cs"
                            {
#line 384 "AdvancedModule.cs"
#line 384 "AdvancedModule.cs"
                                double* csharp2cuda_temp_233 = &((means)[block_count]);
#line 384 "AdvancedModule.cs"
                                double csharp2cuda_temp_234 = (a)[index];
                                (*(csharp2cuda_temp_233) = csharp2cuda_temp_234);
#line 385 "AdvancedModule.cs"
#line 385 "AdvancedModule.cs"
                                int* csharp2cuda_temp_235 = &((weights)[block_count]);
                                (*(csharp2cuda_temp_235) = 1);
#line 386 "AdvancedModule.cs"
#line 386 "AdvancedModule.cs"
                                int* csharp2cuda_temp_236 = &((starts)[block_count]);
                                (*(csharp2cuda_temp_236) = index);
#line 387 "AdvancedModule.cs"
#line 387 "AdvancedModule.cs"
                                int* csharp2cuda_temp_237 = &(block_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_237));
#line 388 "AdvancedModule.cs"
                                while (true)
                                {
#line 388 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_238;
#line 388 "AdvancedModule.cs"
                                    if (((block_count) >= (2)))
                                    {
#line 388 "AdvancedModule.cs"
                                        double csharp2cuda_temp_239 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 388 "AdvancedModule.cs"
                                        double csharp2cuda_temp_240 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 388 "AdvancedModule.cs"
                                        csharp2cuda_temp_238 = ((csharp2cuda_temp_239) > (csharp2cuda_temp_240));
                                    }
                                    else
                                    {
#line 388 "AdvancedModule.cs"
                                        csharp2cuda_temp_238 = false;
                                    }
                                    if (!(csharp2cuda_temp_238))
                                        break;
#line 389 "AdvancedModule.cs"
                                    {
#line 390 "AdvancedModule.cs"
                                        int csharp2cuda_temp_241 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 390 "AdvancedModule.cs"
                                        int csharp2cuda_temp_242 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 390 "AdvancedModule.cs"
                                        int combined_weight = csharp2cuda_i32_add(csharp2cuda_temp_241, csharp2cuda_temp_242);
#line 391 "AdvancedModule.cs"
#line 391 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_243 = &((means)[csharp2cuda_i32_sub(block_count, 2)]);
#line 392 "AdvancedModule.cs"
                                        double csharp2cuda_temp_244 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 392 "AdvancedModule.cs"
                                        int csharp2cuda_temp_245 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 393 "AdvancedModule.cs"
                                        double csharp2cuda_temp_246 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 393 "AdvancedModule.cs"
                                        int csharp2cuda_temp_247 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 392 "AdvancedModule.cs"
                                        double csharp2cuda_temp_248 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_244, ((double)(csharp2cuda_temp_245))), __dmul_rn(csharp2cuda_temp_246, ((double)(csharp2cuda_temp_247)))), ((double)(combined_weight)));
                                        (*(csharp2cuda_temp_243) = csharp2cuda_temp_248);
#line 395 "AdvancedModule.cs"
#line 395 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_249 = &((weights)[csharp2cuda_i32_sub(block_count, 2)]);
                                        (*(csharp2cuda_temp_249) = combined_weight);
#line 396 "AdvancedModule.cs"
#line 396 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_250 = &(block_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_250));
                                    }
                                }
                            }
#line 382 "AdvancedModule.cs"
                            int* csharp2cuda_temp_231 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_231));
                        }
                    }
#line 399 "AdvancedModule.cs"
                    {
#line 399 "AdvancedModule.cs"
                        int block = 0;
                        while (true)
                        {
                            if (!(((block) < (block_count))))
                                break;
#line 400 "AdvancedModule.cs"
                            {
#line 401 "AdvancedModule.cs"
                                int csharp2cuda_temp_252;
#line 401 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_add(block, 1)) < (block_count)))
                                {
#line 401 "AdvancedModule.cs"
                                    csharp2cuda_temp_252 = (starts)[csharp2cuda_i32_add(block, 1)];
                                }
                                else
                                {
#line 401 "AdvancedModule.cs"
                                    csharp2cuda_temp_252 = (first)->count;
                                }
#line 401 "AdvancedModule.cs"
                                int end = csharp2cuda_temp_252;
#line 402 "AdvancedModule.cs"
                                {
#line 402 "AdvancedModule.cs"
                                    int index = (starts)[block];
                                    while (true)
                                    {
                                        if (!(((index) < (end))))
                                            break;
#line 403 "AdvancedModule.cs"
#line 403 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_254 = &((result)[index]);
#line 403 "AdvancedModule.cs"
                                        double csharp2cuda_temp_255 = (means)[block];
                                        (*(csharp2cuda_temp_254) = csharp2cuda_temp_255);
#line 402 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_253 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                                    }
                                }
                            }
#line 399 "AdvancedModule.cs"
                            int* csharp2cuda_temp_251 = &(block);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_251));
                        }
                    }
#line 405 "AdvancedModule.cs"
                    break;
                }
#line 407 "AdvancedModule.cs"
            case 11:
#line 408 "AdvancedModule.cs"
#line 408 "AdvancedModule.cs"
                int csharp2cuda_temp_256 = (first)->count;
#line 408 "AdvancedModule.cs"
                int csharp2cuda_temp_257 = (second)->count;
#line 408 "AdvancedModule.cs"
                bool csharp2cuda_temp_258;
#line 408 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_256) != (csharp2cuda_temp_257))))
                {
#line 408 "AdvancedModule.cs"
                    csharp2cuda_temp_258 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 408 "AdvancedModule.cs"
                    csharp2cuda_temp_258 = true;
                }
                if (csharp2cuda_temp_258)
#line 409 "AdvancedModule.cs"
                {
#line 410 "AdvancedModule.cs"
#line 410 "AdvancedModule.cs"
                    int* csharp2cuda_temp_259 = &((output)->valid);
                    (*(csharp2cuda_temp_259) = 0);
#line 411 "AdvancedModule.cs"
                    break;
                }
#line 413 "AdvancedModule.cs"
                {
#line 414 "AdvancedModule.cs"
                    double* left_sorted = scratch;
#line 415 "AdvancedModule.cs"
                    int csharp2cuda_temp_260 = (first)->count;
#line 415 "AdvancedModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_260);
#line 416 "AdvancedModule.cs"
#line 416 "AdvancedModule.cs"
                    int csharp2cuda_temp_261 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_261, left_sorted, true);
#line 417 "AdvancedModule.cs"
#line 417 "AdvancedModule.cs"
                    int csharp2cuda_temp_262 = (first)->count;
                    mathblocks_statistics_sort_copy(b, csharp2cuda_temp_262, right_sorted, true);
#line 418 "AdvancedModule.cs"
                    double left_sum = 0.0;
#line 419 "AdvancedModule.cs"
                    double right_sum = 0.0;
#line 420 "AdvancedModule.cs"
                    bool majorizes = true;
#line 421 "AdvancedModule.cs"
                    {
#line 421 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 421 "AdvancedModule.cs"
                            int csharp2cuda_temp_264 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_264))))
                                break;
#line 422 "AdvancedModule.cs"
                            {
#line 423 "AdvancedModule.cs"
#line 423 "AdvancedModule.cs"
                                double* csharp2cuda_temp_265 = &(left_sum);
#line 423 "AdvancedModule.cs"
                                double csharp2cuda_temp_266 = *(csharp2cuda_temp_265);
#line 423 "AdvancedModule.cs"
                                double csharp2cuda_temp_267 = (left_sorted)[index];
                                (*(csharp2cuda_temp_265) = __dadd_rn(csharp2cuda_temp_266, csharp2cuda_temp_267));
#line 424 "AdvancedModule.cs"
#line 424 "AdvancedModule.cs"
                                double* csharp2cuda_temp_268 = &(right_sum);
#line 424 "AdvancedModule.cs"
                                double csharp2cuda_temp_269 = *(csharp2cuda_temp_268);
#line 424 "AdvancedModule.cs"
                                double csharp2cuda_temp_270 = (right_sorted)[index];
                                (*(csharp2cuda_temp_268) = __dadd_rn(csharp2cuda_temp_269, csharp2cuda_temp_270));
#line 425 "AdvancedModule.cs"
#line 425 "AdvancedModule.cs"
                                int csharp2cuda_temp_271 = (first)->count;
#line 425 "AdvancedModule.cs"
                                bool csharp2cuda_temp_272;
#line 425 "AdvancedModule.cs"
                                if (((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_271, 1))))
                                {
#line 425 "AdvancedModule.cs"
                                    csharp2cuda_temp_272 = ((left_sum) < (right_sum));
                                }
                                else
                                {
#line 425 "AdvancedModule.cs"
                                    csharp2cuda_temp_272 = false;
                                }
                                if (csharp2cuda_temp_272)
                                {
#line 426 "AdvancedModule.cs"
#line 426 "AdvancedModule.cs"
                                    bool* csharp2cuda_temp_273 = &(majorizes);
                                    (*(csharp2cuda_temp_273) = false);
                                }
                            }
#line 421 "AdvancedModule.cs"
                            int* csharp2cuda_temp_263 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_263));
                        }
                    }
#line 428 "AdvancedModule.cs"
#line 428 "AdvancedModule.cs"
                    int* csharp2cuda_temp_274 = &((output)->boolean_value);
#line 428 "AdvancedModule.cs"
                    bool csharp2cuda_temp_275;
#line 428 "AdvancedModule.cs"
                    if (majorizes)
                    {
#line 428 "AdvancedModule.cs"
                        csharp2cuda_temp_275 = ((left_sum) == (right_sum));
                    }
                    else
                    {
#line 428 "AdvancedModule.cs"
                        csharp2cuda_temp_275 = false;
                    }
#line 428 "AdvancedModule.cs"
                    int csharp2cuda_temp_276;
#line 428 "AdvancedModule.cs"
                    if (csharp2cuda_temp_275)
                    {
#line 428 "AdvancedModule.cs"
                        csharp2cuda_temp_276 = 1;
                    }
                    else
                    {
#line 428 "AdvancedModule.cs"
                        csharp2cuda_temp_276 = 0;
                    }
                    (*(csharp2cuda_temp_274) = csharp2cuda_temp_276);
#line 429 "AdvancedModule.cs"
                    break;
                }
#line 431 "AdvancedModule.cs"
            case 12:
#line 432 "AdvancedModule.cs"
#line 432 "AdvancedModule.cs"
                int csharp2cuda_temp_277 = (first)->count;
#line 432 "AdvancedModule.cs"
                bool csharp2cuda_temp_278;
#line 432 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_277) <= (0))))
                {
#line 432 "AdvancedModule.cs"
                    int csharp2cuda_temp_279 = (first)->count;
#line 432 "AdvancedModule.cs"
                    int csharp2cuda_temp_280 = (second)->count;
#line 432 "AdvancedModule.cs"
                    csharp2cuda_temp_278 = ((csharp2cuda_temp_279) != (csharp2cuda_temp_280));
                }
                else
                {
#line 432 "AdvancedModule.cs"
                    csharp2cuda_temp_278 = true;
                }
                if (csharp2cuda_temp_278)
#line 433 "AdvancedModule.cs"
                {
#line 434 "AdvancedModule.cs"
#line 434 "AdvancedModule.cs"
                    int* csharp2cuda_temp_281 = &((output)->valid);
                    (*(csharp2cuda_temp_281) = 0);
#line 435 "AdvancedModule.cs"
                    break;
                }
#line 437 "AdvancedModule.cs"
                {
#line 438 "AdvancedModule.cs"
                    double minimum = mathblocks_positive_infinity();
#line 439 "AdvancedModule.cs"
                    double maximum = (-(mathblocks_positive_infinity()));
#line 440 "AdvancedModule.cs"
                    {
#line 440 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 440 "AdvancedModule.cs"
                            int csharp2cuda_temp_283 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_283))))
                                break;
#line 441 "AdvancedModule.cs"
                            {
#line 442 "AdvancedModule.cs"
#line 442 "AdvancedModule.cs"
                                double csharp2cuda_temp_284 = (a)[index];
#line 442 "AdvancedModule.cs"
                                bool csharp2cuda_temp_285;
#line 442 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_284) <= (0.0))))
                                {
#line 442 "AdvancedModule.cs"
                                    double csharp2cuda_temp_286 = (b)[index];
#line 442 "AdvancedModule.cs"
                                    csharp2cuda_temp_285 = ((csharp2cuda_temp_286) <= (0.0));
                                }
                                else
                                {
#line 442 "AdvancedModule.cs"
                                    csharp2cuda_temp_285 = true;
                                }
                                if (csharp2cuda_temp_285)
#line 443 "AdvancedModule.cs"
                                {
#line 444 "AdvancedModule.cs"
#line 444 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_287 = &((output)->valid);
                                    (*(csharp2cuda_temp_287) = 0);
#line 445 "AdvancedModule.cs"
                                    break;
                                }
#line 447 "AdvancedModule.cs"
                                double csharp2cuda_temp_288 = (a)[index];
#line 447 "AdvancedModule.cs"
                                double csharp2cuda_temp_289 = (b)[index];
#line 447 "AdvancedModule.cs"
                                double ratio = __ddiv_rn(csharp2cuda_temp_288, csharp2cuda_temp_289);
#line 448 "AdvancedModule.cs"
#line 448 "AdvancedModule.cs"
                                double* csharp2cuda_temp_290 = &(minimum);
#line 448 "AdvancedModule.cs"
                                double csharp2cuda_temp_291;
#line 448 "AdvancedModule.cs"
                                if (((minimum) < (ratio)))
                                {
#line 448 "AdvancedModule.cs"
                                    csharp2cuda_temp_291 = minimum;
                                }
                                else
                                {
#line 448 "AdvancedModule.cs"
                                    csharp2cuda_temp_291 = ratio;
                                }
                                (*(csharp2cuda_temp_290) = csharp2cuda_temp_291);
#line 449 "AdvancedModule.cs"
#line 449 "AdvancedModule.cs"
                                double* csharp2cuda_temp_292 = &(maximum);
#line 449 "AdvancedModule.cs"
                                double csharp2cuda_temp_293;
#line 449 "AdvancedModule.cs"
                                if (((maximum) > (ratio)))
                                {
#line 449 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = maximum;
                                }
                                else
                                {
#line 449 "AdvancedModule.cs"
                                    csharp2cuda_temp_293 = ratio;
                                }
                                (*(csharp2cuda_temp_292) = csharp2cuda_temp_293);
                            }
#line 440 "AdvancedModule.cs"
                            int* csharp2cuda_temp_282 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_282));
                        }
                    }
#line 451 "AdvancedModule.cs"
#line 451 "AdvancedModule.cs"
                    double* csharp2cuda_temp_294 = &((output)->scalar_value);
#line 451 "AdvancedModule.cs"
                    double csharp2cuda_temp_295 = __ddiv_rn(maximum, minimum);
                    (*(csharp2cuda_temp_294) = mathblocks_natural_logarithm(csharp2cuda_temp_295));
#line 452 "AdvancedModule.cs"
                    break;
                }
#line 454 "AdvancedModule.cs"
            case 13:
            case 16:
#line 456 "AdvancedModule.cs"
#line 456 "AdvancedModule.cs"
                int csharp2cuda_temp_296 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_296);
#line 457 "AdvancedModule.cs"
#line 457 "AdvancedModule.cs"
                int csharp2cuda_temp_297 = (first)->count;
#line 457 "AdvancedModule.cs"
                bool csharp2cuda_temp_298;
#line 457 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_297) <= (0))))
                {
#line 457 "AdvancedModule.cs"
                    csharp2cuda_temp_298 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 457 "AdvancedModule.cs"
                    csharp2cuda_temp_298 = true;
                }
                if (csharp2cuda_temp_298)
#line 458 "AdvancedModule.cs"
                {
#line 459 "AdvancedModule.cs"
#line 459 "AdvancedModule.cs"
                    int* csharp2cuda_temp_299 = &((output)->valid);
                    (*(csharp2cuda_temp_299) = 0);
#line 460 "AdvancedModule.cs"
                    break;
                }
#line 462 "AdvancedModule.cs"
                {
#line 463 "AdvancedModule.cs"
                    int* hull = ((int*)(scratch));
#line 464 "AdvancedModule.cs"
                    int hull_count = 0;
#line 465 "AdvancedModule.cs"
                    bool concave = ((opcode) == (16));
#line 466 "AdvancedModule.cs"
                    {
#line 466 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 466 "AdvancedModule.cs"
                            int csharp2cuda_temp_301 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_301))))
                                break;
#line 467 "AdvancedModule.cs"
                            {
#line 468 "AdvancedModule.cs"
#line 468 "AdvancedModule.cs"
                                int* csharp2cuda_temp_302 = &(hull_count);
#line 468 "AdvancedModule.cs"
                                int csharp2cuda_temp_303 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_302));
#line 468 "AdvancedModule.cs"
                                int* csharp2cuda_temp_304 = &((hull)[csharp2cuda_temp_303]);
                                (*(csharp2cuda_temp_304) = index);
#line 469 "AdvancedModule.cs"
                                while (true)
                                {
                                    if (!(((hull_count) >= (3))))
                                        break;
#line 470 "AdvancedModule.cs"
                                    {
#line 471 "AdvancedModule.cs"
                                        int one = (hull)[csharp2cuda_i32_sub(hull_count, 3)];
#line 472 "AdvancedModule.cs"
                                        int middle = (hull)[csharp2cuda_i32_sub(hull_count, 2)];
#line 473 "AdvancedModule.cs"
                                        int last = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
#line 474 "AdvancedModule.cs"
                                        double csharp2cuda_temp_305 = (a)[middle];
#line 474 "AdvancedModule.cs"
                                        double csharp2cuda_temp_306 = (a)[one];
#line 474 "AdvancedModule.cs"
                                        double first_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_305, csharp2cuda_temp_306), ((double)(csharp2cuda_i32_sub(middle, one))));
#line 475 "AdvancedModule.cs"
                                        double csharp2cuda_temp_307 = (a)[last];
#line 475 "AdvancedModule.cs"
                                        double csharp2cuda_temp_308 = (a)[middle];
#line 475 "AdvancedModule.cs"
                                        double second_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_307, csharp2cuda_temp_308), ((double)(csharp2cuda_i32_sub(last, middle))));
#line 476 "AdvancedModule.cs"
#line 476 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_309;
#line 476 "AdvancedModule.cs"
                                        if (concave)
                                        {
#line 476 "AdvancedModule.cs"
                                            csharp2cuda_temp_309 = ((first_slope) >= (second_slope));
                                        }
                                        else
                                        {
#line 476 "AdvancedModule.cs"
                                            csharp2cuda_temp_309 = ((first_slope) <= (second_slope));
                                        }
                                        if (csharp2cuda_temp_309)
                                        {
#line 477 "AdvancedModule.cs"
                                            break;
                                        }
#line 478 "AdvancedModule.cs"
#line 478 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_310 = &((hull)[csharp2cuda_i32_sub(hull_count, 2)]);
#line 478 "AdvancedModule.cs"
                                        int csharp2cuda_temp_311 = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
                                        (*(csharp2cuda_temp_310) = csharp2cuda_temp_311);
#line 479 "AdvancedModule.cs"
#line 479 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_312 = &(hull_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_312));
                                    }
                                }
                            }
#line 466 "AdvancedModule.cs"
                            int* csharp2cuda_temp_300 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_300));
                        }
                    }
#line 482 "AdvancedModule.cs"
                    {
#line 482 "AdvancedModule.cs"
                        int segment = 1;
                        while (true)
                        {
                            if (!(((segment) < (hull_count))))
                                break;
#line 483 "AdvancedModule.cs"
                            {
#line 484 "AdvancedModule.cs"
                                int start = (hull)[csharp2cuda_i32_sub(segment, 1)];
#line 485 "AdvancedModule.cs"
                                int end = (hull)[segment];
#line 486 "AdvancedModule.cs"
                                {
#line 486 "AdvancedModule.cs"
                                    int index = start;
                                    while (true)
                                    {
                                        if (!(((index) <= (end))))
                                            break;
#line 487 "AdvancedModule.cs"
                                        {
#line 488 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(((double)(csharp2cuda_i32_sub(index, start))), ((double)(csharp2cuda_i32_sub(end, start))));
#line 489 "AdvancedModule.cs"
#line 489 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_315 = &((result)[index]);
#line 489 "AdvancedModule.cs"
                                            double csharp2cuda_temp_316 = (a)[start];
#line 489 "AdvancedModule.cs"
                                            double csharp2cuda_temp_317 = (a)[end];
                                            (*(csharp2cuda_temp_315) = __dadd_rn(__dmul_rn(csharp2cuda_temp_316, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_317, weight)));
                                        }
#line 486 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_314 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                                    }
                                }
                            }
#line 482 "AdvancedModule.cs"
                            int* csharp2cuda_temp_313 = &(segment);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_313));
                        }
                    }
#line 492 "AdvancedModule.cs"
                    break;
                }
#line 494 "AdvancedModule.cs"
            case 14:
#line 495 "AdvancedModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 496 "AdvancedModule.cs"
                {
#line 497 "AdvancedModule.cs"
#line 497 "AdvancedModule.cs"
                    int* csharp2cuda_temp_318 = &((output)->valid);
                    (*(csharp2cuda_temp_318) = 0);
#line 498 "AdvancedModule.cs"
                    break;
                }
#line 500 "AdvancedModule.cs"
                {
#line 500 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 500 "AdvancedModule.cs"
                        int csharp2cuda_temp_320 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_320))))
                            break;
#line 501 "AdvancedModule.cs"
#line 501 "AdvancedModule.cs"
                        double* csharp2cuda_temp_321 = &((scratch)[index]);
#line 501 "AdvancedModule.cs"
                        double csharp2cuda_temp_322 = (a)[index];
                        (*(csharp2cuda_temp_321) = csharp2cuda_temp_322);
#line 500 "AdvancedModule.cs"
                        int* csharp2cuda_temp_319 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_319));
                    }
                }
#line 502 "AdvancedModule.cs"
#line 502 "AdvancedModule.cs"
                int* csharp2cuda_temp_323 = &((output)->boolean_value);
                (*(csharp2cuda_temp_323) = 1);
#line 503 "AdvancedModule.cs"
                {
#line 503 "AdvancedModule.cs"
                    int order = 0;
#line 503 "AdvancedModule.cs"
                    int length = (first)->count;
                    while (true)
                    {
#line 504 "AdvancedModule.cs"
                        int csharp2cuda_temp_326 = (first)->count;
#line 504 "AdvancedModule.cs"
                        bool csharp2cuda_temp_327;
#line 504 "AdvancedModule.cs"
                        if (((order) < (csharp2cuda_temp_326)))
                        {
#line 504 "AdvancedModule.cs"
                            csharp2cuda_temp_327 = (output)->boolean_value;
                        }
                        else
                        {
#line 504 "AdvancedModule.cs"
                            csharp2cuda_temp_327 = false;
                        }
                        if (!(csharp2cuda_temp_327))
                            break;
#line 506 "AdvancedModule.cs"
                        {
#line 507 "AdvancedModule.cs"
                            double csharp2cuda_temp_328;
#line 507 "AdvancedModule.cs"
                            if (((csharp2cuda_i32_and(order, 1)) == (0)))
                            {
#line 507 "AdvancedModule.cs"
                                csharp2cuda_temp_328 = 1.0;
                            }
                            else
                            {
#line 507 "AdvancedModule.cs"
                                csharp2cuda_temp_328 = (-(1.0));
                            }
#line 507 "AdvancedModule.cs"
                            double sign = csharp2cuda_temp_328;
#line 508 "AdvancedModule.cs"
                            {
#line 508 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 509 "AdvancedModule.cs"
#line 509 "AdvancedModule.cs"
                                    double csharp2cuda_temp_330 = (scratch)[index];
                                    if (((__dmul_rn(sign, csharp2cuda_temp_330)) < (0.0)))
#line 510 "AdvancedModule.cs"
                                    {
#line 511 "AdvancedModule.cs"
#line 511 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_331 = &((output)->boolean_value);
                                        (*(csharp2cuda_temp_331) = 0);
#line 512 "AdvancedModule.cs"
                                        break;
                                    }
#line 508 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_329 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_329));
                                }
                            }
#line 514 "AdvancedModule.cs"
                            {
#line 514 "AdvancedModule.cs"
                                int index = 1;
                                while (true)
                                {
#line 514 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_333 = (output)->boolean_value;
#line 514 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_334;
#line 514 "AdvancedModule.cs"
                                    if (csharp2cuda_temp_333)
                                    {
#line 514 "AdvancedModule.cs"
                                        csharp2cuda_temp_334 = ((index) < (length));
                                    }
                                    else
                                    {
#line 514 "AdvancedModule.cs"
                                        csharp2cuda_temp_334 = false;
                                    }
                                    if (!(csharp2cuda_temp_334))
                                        break;
#line 515 "AdvancedModule.cs"
#line 515 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_335 = &((scratch)[csharp2cuda_i32_sub(index, 1)]);
#line 515 "AdvancedModule.cs"
                                    double csharp2cuda_temp_336 = (scratch)[index];
#line 515 "AdvancedModule.cs"
                                    double csharp2cuda_temp_337 = (scratch)[csharp2cuda_i32_sub(index, 1)];
                                    (*(csharp2cuda_temp_335) = __dsub_rn(csharp2cuda_temp_336, csharp2cuda_temp_337));
#line 514 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_332 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_332));
                                }
                            }
                        }
#line 505 "AdvancedModule.cs"
                        int* csharp2cuda_temp_324 = &(order);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_324));
#line 505 "AdvancedModule.cs"
                        int* csharp2cuda_temp_325 = &(length);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_325));
                    }
                }
#line 517 "AdvancedModule.cs"
                break;
#line 518 "AdvancedModule.cs"
            case 15:
#line 519 "AdvancedModule.cs"
#line 519 "AdvancedModule.cs"
                int* csharp2cuda_temp_338 = &((output)->boolean_value);
                (*(csharp2cuda_temp_338) = 1);
#line 520 "AdvancedModule.cs"
                {
#line 520 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 520 "AdvancedModule.cs"
                        int csharp2cuda_temp_340 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_340))))
                            break;
#line 521 "AdvancedModule.cs"
#line 521 "AdvancedModule.cs"
                        double csharp2cuda_temp_341 = (a)[index];
                        if (((csharp2cuda_temp_341) < (0.0)))
                        {
#line 521 "AdvancedModule.cs"
#line 521 "AdvancedModule.cs"
                            int* csharp2cuda_temp_342 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_342) = 0);
                        }
#line 520 "AdvancedModule.cs"
                        int* csharp2cuda_temp_339 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_339));
                    }
                }
#line 522 "AdvancedModule.cs"
                {
#line 522 "AdvancedModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 522 "AdvancedModule.cs"
                        bool csharp2cuda_temp_344 = (output)->boolean_value;
#line 522 "AdvancedModule.cs"
                        bool csharp2cuda_temp_345;
#line 522 "AdvancedModule.cs"
                        if (csharp2cuda_temp_344)
                        {
#line 522 "AdvancedModule.cs"
                            int csharp2cuda_temp_346 = (first)->count;
#line 522 "AdvancedModule.cs"
                            csharp2cuda_temp_345 = ((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_346, 1)));
                        }
                        else
                        {
#line 522 "AdvancedModule.cs"
                            csharp2cuda_temp_345 = false;
                        }
                        if (!(csharp2cuda_temp_345))
                            break;
#line 523 "AdvancedModule.cs"
#line 523 "AdvancedModule.cs"
                        double csharp2cuda_temp_347 = (a)[index];
#line 523 "AdvancedModule.cs"
                        double csharp2cuda_temp_348 = (a)[index];
#line 523 "AdvancedModule.cs"
                        double csharp2cuda_temp_349 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 523 "AdvancedModule.cs"
                        double csharp2cuda_temp_350 = (a)[csharp2cuda_i32_add(index, 1)];
                        if (((__dmul_rn(csharp2cuda_temp_347, csharp2cuda_temp_348)) < (__dmul_rn(csharp2cuda_temp_349, csharp2cuda_temp_350))))
                        {
#line 524 "AdvancedModule.cs"
#line 524 "AdvancedModule.cs"
                            int* csharp2cuda_temp_351 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_351) = 0);
                        }
#line 522 "AdvancedModule.cs"
                        int* csharp2cuda_temp_343 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_343));
                    }
                }
#line 525 "AdvancedModule.cs"
                break;
#line 526 "AdvancedModule.cs"
            case 17:
#line 527 "AdvancedModule.cs"
#line 527 "AdvancedModule.cs"
                int csharp2cuda_temp_352 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_352);
#line 528 "AdvancedModule.cs"
#line 528 "AdvancedModule.cs"
                int csharp2cuda_temp_353 = (first)->count;
#line 528 "AdvancedModule.cs"
                bool csharp2cuda_temp_354 = mathblocks_advanced_distribution(a, csharp2cuda_temp_353);
                if ((!(csharp2cuda_temp_354)))
#line 529 "AdvancedModule.cs"
                {
#line 530 "AdvancedModule.cs"
#line 530 "AdvancedModule.cs"
                    int* csharp2cuda_temp_355 = &((output)->valid);
                    (*(csharp2cuda_temp_355) = 0);
#line 531 "AdvancedModule.cs"
                    break;
                }
#line 533 "AdvancedModule.cs"
                {
#line 534 "AdvancedModule.cs"
                    double survival = 1.0;
#line 535 "AdvancedModule.cs"
                    {
#line 535 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 535 "AdvancedModule.cs"
                            int csharp2cuda_temp_357 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_357))))
                                break;
#line 536 "AdvancedModule.cs"
                            {
#line 537 "AdvancedModule.cs"
#line 537 "AdvancedModule.cs"
                                double* csharp2cuda_temp_358 = &((result)[index]);
#line 537 "AdvancedModule.cs"
                                double csharp2cuda_temp_359 = (a)[index];
#line 537 "AdvancedModule.cs"
                                double csharp2cuda_temp_360 = __ddiv_rn(csharp2cuda_temp_359, survival);
                                (*(csharp2cuda_temp_358) = csharp2cuda_temp_360);
#line 538 "AdvancedModule.cs"
#line 538 "AdvancedModule.cs"
                                double* csharp2cuda_temp_361 = &(survival);
#line 538 "AdvancedModule.cs"
                                double csharp2cuda_temp_362 = *(csharp2cuda_temp_361);
#line 538 "AdvancedModule.cs"
                                double csharp2cuda_temp_363 = (a)[index];
                                (*(csharp2cuda_temp_361) = __dsub_rn(csharp2cuda_temp_362, csharp2cuda_temp_363));
                            }
#line 535 "AdvancedModule.cs"
                            int* csharp2cuda_temp_356 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_356));
                        }
                    }
#line 540 "AdvancedModule.cs"
                    break;
                }
#line 542 "AdvancedModule.cs"
            case 18:
#line 543 "AdvancedModule.cs"
#line 543 "AdvancedModule.cs"
                int csharp2cuda_temp_364 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_364);
#line 544 "AdvancedModule.cs"
#line 544 "AdvancedModule.cs"
                int csharp2cuda_temp_365 = (first)->count;
#line 544 "AdvancedModule.cs"
                int csharp2cuda_temp_366 = (second)->count;
                if (((csharp2cuda_temp_365) != (csharp2cuda_temp_366)))
#line 545 "AdvancedModule.cs"
                {
#line 546 "AdvancedModule.cs"
#line 546 "AdvancedModule.cs"
                    int* csharp2cuda_temp_367 = &((output)->valid);
                    (*(csharp2cuda_temp_367) = 0);
#line 547 "AdvancedModule.cs"
                    break;
                }
#line 549 "AdvancedModule.cs"
                {
#line 550 "AdvancedModule.cs"
                    double survival = 1.0;
#line 551 "AdvancedModule.cs"
                    {
#line 551 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 551 "AdvancedModule.cs"
                            int csharp2cuda_temp_369 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_369))))
                                break;
#line 552 "AdvancedModule.cs"
                            {
#line 553 "AdvancedModule.cs"
#line 553 "AdvancedModule.cs"
                                double csharp2cuda_temp_370 = (a)[index];
#line 553 "AdvancedModule.cs"
                                bool csharp2cuda_temp_371;
#line 553 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_370) < (0.0))))
                                {
#line 553 "AdvancedModule.cs"
                                    double csharp2cuda_temp_372 = (b)[index];
#line 553 "AdvancedModule.cs"
                                    csharp2cuda_temp_371 = ((csharp2cuda_temp_372) <= (0.0));
                                }
                                else
                                {
#line 553 "AdvancedModule.cs"
                                    csharp2cuda_temp_371 = true;
                                }
#line 553 "AdvancedModule.cs"
                                bool csharp2cuda_temp_373;
#line 553 "AdvancedModule.cs"
                                if (!(csharp2cuda_temp_371))
                                {
#line 553 "AdvancedModule.cs"
                                    double csharp2cuda_temp_374 = (a)[index];
#line 553 "AdvancedModule.cs"
                                    double csharp2cuda_temp_375 = (b)[index];
#line 553 "AdvancedModule.cs"
                                    csharp2cuda_temp_373 = ((csharp2cuda_temp_374) > (csharp2cuda_temp_375));
                                }
                                else
                                {
#line 553 "AdvancedModule.cs"
                                    csharp2cuda_temp_373 = true;
                                }
                                if (csharp2cuda_temp_373)
#line 554 "AdvancedModule.cs"
                                {
#line 555 "AdvancedModule.cs"
#line 555 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_376 = &((output)->valid);
                                    (*(csharp2cuda_temp_376) = 0);
#line 556 "AdvancedModule.cs"
                                    break;
                                }
#line 558 "AdvancedModule.cs"
#line 558 "AdvancedModule.cs"
                                double* csharp2cuda_temp_377 = &(survival);
#line 558 "AdvancedModule.cs"
                                double csharp2cuda_temp_378 = *(csharp2cuda_temp_377);
#line 558 "AdvancedModule.cs"
                                double csharp2cuda_temp_379 = (a)[index];
#line 558 "AdvancedModule.cs"
                                double csharp2cuda_temp_380 = (b)[index];
#line 558 "AdvancedModule.cs"
                                double csharp2cuda_temp_381 = __ddiv_rn(csharp2cuda_temp_379, csharp2cuda_temp_380);
                                (*(csharp2cuda_temp_377) = __dmul_rn(csharp2cuda_temp_378, __dsub_rn(1.0, csharp2cuda_temp_381)));
#line 559 "AdvancedModule.cs"
#line 559 "AdvancedModule.cs"
                                double* csharp2cuda_temp_382 = &((result)[index]);
                                (*(csharp2cuda_temp_382) = survival);
                            }
#line 551 "AdvancedModule.cs"
                            int* csharp2cuda_temp_368 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_368));
                        }
                    }
#line 561 "AdvancedModule.cs"
                    break;
                }
        }
#line 565 "AdvancedModule.cs"
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_383 = (output)->valid;
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_384;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_383)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_384 = ((opcode) != (1));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_384 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_385;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_384)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_385 = ((opcode) != (2));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_385 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_386;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_385)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_386 = ((opcode) != (3));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_386 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_387;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_386)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_387 = ((opcode) != (4));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_387 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_388;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_387)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_388 = ((opcode) != (5));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_388 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_389;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_388)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_389 = ((opcode) != (7));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_389 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_390;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_389)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_390 = ((opcode) != (9));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_390 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_391;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_390)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_391 = ((opcode) != (10));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_391 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_392;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_391)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_392 = ((opcode) != (11));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_392 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_393;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_392)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_393 = ((opcode) != (13));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_393 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_394;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_393)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_394 = ((opcode) != (14));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_394 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_395;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_394)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_395 = ((opcode) != (15));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_395 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_396;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_395)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_396 = ((opcode) != (16));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_396 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_397;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_396)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_397 = ((opcode) != (17));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_397 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_398;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_397)
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_398 = ((opcode) != (18));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_398 = false;
        }
#line 565 "AdvancedModule.cs"
        bool csharp2cuda_temp_399;
#line 565 "AdvancedModule.cs"
        if (csharp2cuda_temp_398)
        {
#line 569 "AdvancedModule.cs"
            double csharp2cuda_temp_400 = (output)->scalar_value;
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_399 = (!(isfinite(csharp2cuda_temp_400)));
        }
        else
        {
#line 565 "AdvancedModule.cs"
            csharp2cuda_temp_399 = false;
        }
        if (csharp2cuda_temp_399)
#line 570 "AdvancedModule.cs"
        {
#line 571 "AdvancedModule.cs"
#line 571 "AdvancedModule.cs"
            int* csharp2cuda_temp_401 = &((output)->valid);
            (*(csharp2cuda_temp_401) = 0);
        }
#line 573 "AdvancedModule.cs"
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_402 = (output)->valid;
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_403;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_402)
        {
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_404;
#line 574 "AdvancedModule.cs"
            if (!(((opcode) == (2))))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_404 = ((opcode) == (3));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_404 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_405;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_404))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_405 = ((opcode) == (4));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_405 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_406;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_405))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_406 = ((opcode) == (5));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_406 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_407;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_406))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_407 = ((opcode) == (7));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_407 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_408;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_407))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_408 = ((opcode) == (9));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_408 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_409;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_408))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_409 = ((opcode) == (10));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_409 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_410;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_409))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_410 = ((opcode) == (13));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_410 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_411;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_410))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_411 = ((opcode) == (16));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_411 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_412;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_411))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_412 = ((opcode) == (17));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_412 = true;
            }
#line 574 "AdvancedModule.cs"
            bool csharp2cuda_temp_413;
#line 574 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_412))
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_413 = ((opcode) == (18));
            }
            else
            {
#line 574 "AdvancedModule.cs"
                csharp2cuda_temp_413 = true;
            }
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_403 = csharp2cuda_temp_413;
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_403 = false;
        }
        if (csharp2cuda_temp_403)
#line 577 "AdvancedModule.cs"
        {
#line 578 "AdvancedModule.cs"
            {
#line 578 "AdvancedModule.cs"
                int index = 0;
                while (true)
                {
#line 578 "AdvancedModule.cs"
                    int csharp2cuda_temp_415 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_415))))
                        break;
#line 579 "AdvancedModule.cs"
#line 579 "AdvancedModule.cs"
                    double csharp2cuda_temp_416 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_416))))
                    {
#line 579 "AdvancedModule.cs"
#line 579 "AdvancedModule.cs"
                        int* csharp2cuda_temp_417 = &((output)->valid);
                        (*(csharp2cuda_temp_417) = 0);
                    }
#line 578 "AdvancedModule.cs"
                    int* csharp2cuda_temp_414 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_414));
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