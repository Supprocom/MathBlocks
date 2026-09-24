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

#line 128 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 79 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count);

#line 70 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value);

#line 46 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value);

#line 58 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value);

#line 40 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value);

#line 109 "AdvancedModule.cs"
__device__ void mathblocks_advanced_sort_descending(
    const double* values,
    int count,
    double* result);

#line 85 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns);

#line 128 "AdvancedModule.cs"
__device__ void mathblocks_advanced_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 134 "AdvancedModule.cs"
{
#line 135 "AdvancedModule.cs"
    int thread = threadIdx.x;
#line 136 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 136 "AdvancedModule.cs"
    if (((input_count) > (0)))
    {
#line 136 "AdvancedModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 136 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 136 "AdvancedModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 137 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 137 "AdvancedModule.cs"
    if (((input_count) > (1)))
    {
#line 137 "AdvancedModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 137 "AdvancedModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 137 "AdvancedModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 138 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 138 "AdvancedModule.cs"
    if (((input_count) > (2)))
    {
#line 138 "AdvancedModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 138 "AdvancedModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 138 "AdvancedModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 139 "AdvancedModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 139 "AdvancedModule.cs"
    if (((input_count) > (3)))
    {
#line 139 "AdvancedModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 139 "AdvancedModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 139 "AdvancedModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 140 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 141 "AdvancedModule.cs"
    {
#line 142 "AdvancedModule.cs"
#line 142 "AdvancedModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 143 "AdvancedModule.cs"
#line 143 "AdvancedModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 144 "AdvancedModule.cs"
#line 144 "AdvancedModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 145 "AdvancedModule.cs"
#line 145 "AdvancedModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 146 "AdvancedModule.cs"
#line 146 "AdvancedModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 147 "AdvancedModule.cs"
#line 147 "AdvancedModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 148 "AdvancedModule.cs"
        {
#line 148 "AdvancedModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 149 "AdvancedModule.cs"
#line 149 "AdvancedModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 149 "AdvancedModule.cs"
                bool csharp2cuda_temp_12;
#line 149 "AdvancedModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 149 "AdvancedModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 149 "AdvancedModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 149 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 149 "AdvancedModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 149 "AdvancedModule.cs"
#line 149 "AdvancedModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 148 "AdvancedModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 151 "AdvancedModule.cs"
    __syncthreads();
#line 152 "AdvancedModule.cs"
#line 152 "AdvancedModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 153 "AdvancedModule.cs"
        return;
    }
#line 155 "AdvancedModule.cs"
    double* csharp2cuda_temp_17;
#line 155 "AdvancedModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 155 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 155 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 155 "AdvancedModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 155 "AdvancedModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 156 "AdvancedModule.cs"
    double* csharp2cuda_temp_19;
#line 156 "AdvancedModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 156 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 156 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 156 "AdvancedModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 156 "AdvancedModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 157 "AdvancedModule.cs"
    double* csharp2cuda_temp_21;
#line 157 "AdvancedModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 157 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(nullptr));
    }
    else
    {
#line 157 "AdvancedModule.cs"
        unsigned long long csharp2cuda_temp_22 = (third)->data_pointer;
#line 157 "AdvancedModule.cs"
        csharp2cuda_temp_21 = ((double*)(csharp2cuda_temp_22));
    }
#line 157 "AdvancedModule.cs"
    const double* c = csharp2cuda_temp_21;
#line 158 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 158 "AdvancedModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 159 "AdvancedModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 159 "AdvancedModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 161 "AdvancedModule.cs"
    if (((thread) == (0)))
#line 162 "AdvancedModule.cs"
    {
#line 163 "AdvancedModule.cs"
        switch (opcode)
        {
#line 165 "AdvancedModule.cs"
            case 0:
#line 166 "AdvancedModule.cs"
#line 166 "AdvancedModule.cs"
                int csharp2cuda_temp_25 = (first)->count;
#line 166 "AdvancedModule.cs"
                bool csharp2cuda_temp_26;
#line 166 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_25) <= (0))))
                {
#line 166 "AdvancedModule.cs"
                    int csharp2cuda_temp_27 = (first)->count;
#line 166 "AdvancedModule.cs"
                    csharp2cuda_temp_26 = ((csharp2cuda_temp_27) >= (31));
                }
                else
                {
#line 166 "AdvancedModule.cs"
                    csharp2cuda_temp_26 = true;
                }
#line 166 "AdvancedModule.cs"
                bool csharp2cuda_temp_28;
#line 166 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_26))
                {
#line 167 "AdvancedModule.cs"
                    int csharp2cuda_temp_29 = (second)->count;
#line 167 "AdvancedModule.cs"
                    int csharp2cuda_temp_30 = (first)->count;
#line 166 "AdvancedModule.cs"
                    csharp2cuda_temp_28 = ((csharp2cuda_temp_29) != (csharp2cuda_i32_shl(1, csharp2cuda_temp_30)));
                }
                else
                {
#line 166 "AdvancedModule.cs"
                    csharp2cuda_temp_28 = true;
                }
#line 166 "AdvancedModule.cs"
                bool csharp2cuda_temp_31;
#line 166 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_28))
                {
#line 166 "AdvancedModule.cs"
                    csharp2cuda_temp_31 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 166 "AdvancedModule.cs"
                    csharp2cuda_temp_31 = true;
                }
                if (csharp2cuda_temp_31)
#line 168 "AdvancedModule.cs"
                {
#line 169 "AdvancedModule.cs"
#line 169 "AdvancedModule.cs"
                    int* csharp2cuda_temp_32 = &((output)->valid);
                    (*(csharp2cuda_temp_32) = 0);
#line 170 "AdvancedModule.cs"
                    break;
                }
#line 172 "AdvancedModule.cs"
                {
#line 172 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 172 "AdvancedModule.cs"
                        int csharp2cuda_temp_34 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_34))))
                            break;
#line 173 "AdvancedModule.cs"
                        {
#line 174 "AdvancedModule.cs"
#line 174 "AdvancedModule.cs"
                            double csharp2cuda_temp_35 = (a)[index];
                            if (((csharp2cuda_temp_35) < (0.0)))
#line 175 "AdvancedModule.cs"
                            {
#line 176 "AdvancedModule.cs"
#line 176 "AdvancedModule.cs"
                                int* csharp2cuda_temp_36 = &((output)->valid);
                                (*(csharp2cuda_temp_36) = 0);
#line 177 "AdvancedModule.cs"
                                break;
                            }
#line 179 "AdvancedModule.cs"
                            int position = index;
#line 180 "AdvancedModule.cs"
                            while (true)
                            {
#line 180 "AdvancedModule.cs"
                                bool csharp2cuda_temp_37;
#line 180 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 180 "AdvancedModule.cs"
                                    double csharp2cuda_temp_38 = (scratch)[csharp2cuda_i32_sub(position, 1)];
#line 180 "AdvancedModule.cs"
                                    double csharp2cuda_temp_39 = (a)[csharp2cuda_f64_to_i32(csharp2cuda_temp_38)];
#line 180 "AdvancedModule.cs"
                                    double csharp2cuda_temp_40 = (a)[index];
#line 180 "AdvancedModule.cs"
                                    csharp2cuda_temp_37 = ((csharp2cuda_temp_39) > (csharp2cuda_temp_40));
                                }
                                else
                                {
#line 180 "AdvancedModule.cs"
                                    csharp2cuda_temp_37 = false;
                                }
                                if (!(csharp2cuda_temp_37))
                                    break;
#line 181 "AdvancedModule.cs"
                                {
#line 182 "AdvancedModule.cs"
#line 182 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_41 = &((scratch)[position]);
#line 182 "AdvancedModule.cs"
                                    double csharp2cuda_temp_42 = (scratch)[csharp2cuda_i32_sub(position, 1)];
                                    (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 183 "AdvancedModule.cs"
#line 183 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_43 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_43));
                                }
                            }
#line 185 "AdvancedModule.cs"
#line 185 "AdvancedModule.cs"
                            double* csharp2cuda_temp_44 = &((scratch)[position]);
                            (*(csharp2cuda_temp_44) = ((double)(index)));
                        }
#line 172 "AdvancedModule.cs"
                        int* csharp2cuda_temp_33 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
                    }
                }
#line 187 "AdvancedModule.cs"
                if ((output)->valid)
#line 188 "AdvancedModule.cs"
                {
#line 189 "AdvancedModule.cs"
                    double total = 0.0;
#line 190 "AdvancedModule.cs"
                    double previous = 0.0;
#line 191 "AdvancedModule.cs"
                    {
#line 191 "AdvancedModule.cs"
                        int position = 0;
                        while (true)
                        {
#line 191 "AdvancedModule.cs"
                            int csharp2cuda_temp_46 = (first)->count;
                            if (!(((position) < (csharp2cuda_temp_46))))
                                break;
#line 192 "AdvancedModule.cs"
                            {
#line 193 "AdvancedModule.cs"
                                int coalition = 0;
#line 194 "AdvancedModule.cs"
                                {
#line 194 "AdvancedModule.cs"
                                    int index = position;
                                    while (true)
                                    {
#line 194 "AdvancedModule.cs"
                                        int csharp2cuda_temp_48 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_48))))
                                            break;
#line 195 "AdvancedModule.cs"
#line 195 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_49 = &(coalition);
#line 195 "AdvancedModule.cs"
                                        int csharp2cuda_temp_50 = *(csharp2cuda_temp_49);
#line 195 "AdvancedModule.cs"
                                        double csharp2cuda_temp_51 = (scratch)[index];
                                        (*(csharp2cuda_temp_49) = csharp2cuda_i32_or(csharp2cuda_temp_50, csharp2cuda_i32_shl(1, csharp2cuda_f64_to_i32(csharp2cuda_temp_51))));
#line 194 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_47 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_47));
                                    }
                                }
#line 196 "AdvancedModule.cs"
                                double csharp2cuda_temp_52 = (scratch)[position];
#line 196 "AdvancedModule.cs"
                                int ordered = csharp2cuda_f64_to_i32(csharp2cuda_temp_52);
#line 197 "AdvancedModule.cs"
#line 197 "AdvancedModule.cs"
                                double* csharp2cuda_temp_53 = &(total);
#line 197 "AdvancedModule.cs"
                                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 197 "AdvancedModule.cs"
                                double csharp2cuda_temp_55 = (a)[ordered];
#line 197 "AdvancedModule.cs"
                                double csharp2cuda_temp_56 = (b)[coalition];
                                (*(csharp2cuda_temp_53) = __dadd_rn(csharp2cuda_temp_54, __dmul_rn(__dsub_rn(csharp2cuda_temp_55, previous), csharp2cuda_temp_56)));
#line 198 "AdvancedModule.cs"
#line 198 "AdvancedModule.cs"
                                double* csharp2cuda_temp_57 = &(previous);
#line 198 "AdvancedModule.cs"
                                double csharp2cuda_temp_58 = (a)[ordered];
                                (*(csharp2cuda_temp_57) = csharp2cuda_temp_58);
                            }
#line 191 "AdvancedModule.cs"
                            int* csharp2cuda_temp_45 = &(position);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                        }
                    }
#line 200 "AdvancedModule.cs"
#line 200 "AdvancedModule.cs"
                    double* csharp2cuda_temp_59 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_59) = total);
                }
#line 202 "AdvancedModule.cs"
                break;
#line 203 "AdvancedModule.cs"
            case 1:
#line 204 "AdvancedModule.cs"
#line 204 "AdvancedModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
#line 204 "AdvancedModule.cs"
                bool csharp2cuda_temp_61;
#line 204 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_60)))))
                {
#line 204 "AdvancedModule.cs"
                    int csharp2cuda_temp_62 = (first)->count;
#line 204 "AdvancedModule.cs"
                    csharp2cuda_temp_61 = ((csharp2cuda_temp_62) > (csharp2cuda_i32_shl(1, 12)));
                }
                else
                {
#line 204 "AdvancedModule.cs"
                    csharp2cuda_temp_61 = true;
                }
                if (csharp2cuda_temp_61)
#line 205 "AdvancedModule.cs"
                {
#line 206 "AdvancedModule.cs"
#line 206 "AdvancedModule.cs"
                    int* csharp2cuda_temp_63 = &((output)->valid);
                    (*(csharp2cuda_temp_63) = 0);
#line 207 "AdvancedModule.cs"
                    break;
                }
#line 209 "AdvancedModule.cs"
#line 209 "AdvancedModule.cs"
                int* csharp2cuda_temp_64 = &((output)->boolean_value);
                (*(csharp2cuda_temp_64) = 1);
#line 210 "AdvancedModule.cs"
                {
#line 210 "AdvancedModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 210 "AdvancedModule.cs"
                        int csharp2cuda_temp_66 = (first)->count;
#line 210 "AdvancedModule.cs"
                        bool csharp2cuda_temp_67;
#line 210 "AdvancedModule.cs"
                        if (((left) < (csharp2cuda_temp_66)))
                        {
#line 210 "AdvancedModule.cs"
                            csharp2cuda_temp_67 = (output)->boolean_value;
                        }
                        else
                        {
#line 210 "AdvancedModule.cs"
                            csharp2cuda_temp_67 = false;
                        }
                        if (!(csharp2cuda_temp_67))
                            break;
#line 211 "AdvancedModule.cs"
                        {
#line 211 "AdvancedModule.cs"
                            int right = 0;
                            while (true)
                            {
#line 211 "AdvancedModule.cs"
                                int csharp2cuda_temp_69 = (first)->count;
                                if (!(((right) < (csharp2cuda_temp_69))))
                                    break;
#line 212 "AdvancedModule.cs"
#line 212 "AdvancedModule.cs"
                                double csharp2cuda_temp_70 = (a)[left];
#line 212 "AdvancedModule.cs"
                                double csharp2cuda_temp_71 = (a)[right];
#line 212 "AdvancedModule.cs"
                                double csharp2cuda_temp_72 = (a)[csharp2cuda_i32_or(left, right)];
#line 212 "AdvancedModule.cs"
                                double csharp2cuda_temp_73 = (a)[csharp2cuda_i32_and(left, right)];
                                if (((__dadd_rn(csharp2cuda_temp_70, csharp2cuda_temp_71)) < (__dadd_rn(csharp2cuda_temp_72, csharp2cuda_temp_73))))
#line 213 "AdvancedModule.cs"
                                {
#line 214 "AdvancedModule.cs"
#line 214 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_74 = &((output)->boolean_value);
                                    (*(csharp2cuda_temp_74) = 0);
#line 215 "AdvancedModule.cs"
                                    break;
                                }
#line 211 "AdvancedModule.cs"
                                int* csharp2cuda_temp_68 = &(right);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                            }
                        }
#line 210 "AdvancedModule.cs"
                        int* csharp2cuda_temp_65 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_65));
                    }
                }
#line 217 "AdvancedModule.cs"
                break;
#line 218 "AdvancedModule.cs"
            case 2:
#line 219 "AdvancedModule.cs"
#line 219 "AdvancedModule.cs"
                int csharp2cuda_temp_75 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_75);
#line 220 "AdvancedModule.cs"
#line 220 "AdvancedModule.cs"
                int csharp2cuda_temp_76 = (first)->count;
                if ((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_76))))
#line 221 "AdvancedModule.cs"
                {
#line 222 "AdvancedModule.cs"
#line 222 "AdvancedModule.cs"
                    int* csharp2cuda_temp_77 = &((output)->valid);
                    (*(csharp2cuda_temp_77) = 0);
#line 223 "AdvancedModule.cs"
                    break;
                }
#line 225 "AdvancedModule.cs"
                {
#line 225 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 225 "AdvancedModule.cs"
                        int csharp2cuda_temp_79 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_79))))
                            break;
#line 226 "AdvancedModule.cs"
#line 226 "AdvancedModule.cs"
                        double* csharp2cuda_temp_80 = &((result)[index]);
#line 226 "AdvancedModule.cs"
                        double csharp2cuda_temp_81 = (a)[index];
                        (*(csharp2cuda_temp_80) = csharp2cuda_temp_81);
#line 225 "AdvancedModule.cs"
                        int* csharp2cuda_temp_78 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_78));
                    }
                }
#line 227 "AdvancedModule.cs"
                {
#line 227 "AdvancedModule.cs"
                    int bit = 0;
                    while (true)
                    {
#line 227 "AdvancedModule.cs"
                        int csharp2cuda_temp_83 = (first)->count;
                        if (!(((bit) < (mathblocks_advanced_log_two(csharp2cuda_temp_83)))))
                            break;
#line 228 "AdvancedModule.cs"
                        {
#line 228 "AdvancedModule.cs"
                            int mask = 0;
                            while (true)
                            {
#line 228 "AdvancedModule.cs"
                                int csharp2cuda_temp_85 = (first)->count;
                                if (!(((mask) < (csharp2cuda_temp_85))))
                                    break;
#line 229 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, bit))) != (0)))
                                {
#line 230 "AdvancedModule.cs"
#line 230 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_86 = &((result)[mask]);
#line 230 "AdvancedModule.cs"
                                    double csharp2cuda_temp_87 = *(csharp2cuda_temp_86);
#line 230 "AdvancedModule.cs"
                                    double csharp2cuda_temp_88 = (result)[csharp2cuda_i32_xor(mask, csharp2cuda_i32_shl(1, bit))];
                                    (*(csharp2cuda_temp_86) = __dsub_rn(csharp2cuda_temp_87, csharp2cuda_temp_88));
                                }
#line 228 "AdvancedModule.cs"
                                int* csharp2cuda_temp_84 = &(mask);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_84));
                            }
                        }
#line 227 "AdvancedModule.cs"
                        int* csharp2cuda_temp_82 = &(bit);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_82));
                    }
                }
#line 231 "AdvancedModule.cs"
                break;
#line 232 "AdvancedModule.cs"
            case 3:
#line 233 "AdvancedModule.cs"
#line 233 "AdvancedModule.cs"
                int csharp2cuda_temp_89 = (first)->count;
#line 233 "AdvancedModule.cs"
                bool csharp2cuda_temp_90;
#line 233 "AdvancedModule.cs"
                if (!((!(mathblocks_advanced_power_of_two(csharp2cuda_temp_89)))))
                {
#line 233 "AdvancedModule.cs"
                    int csharp2cuda_temp_91 = (first)->count;
#line 233 "AdvancedModule.cs"
                    csharp2cuda_temp_90 = ((csharp2cuda_temp_91) > (csharp2cuda_i32_shl(1, 20)));
                }
                else
                {
#line 233 "AdvancedModule.cs"
                    csharp2cuda_temp_90 = true;
                }
                if (csharp2cuda_temp_90)
#line 234 "AdvancedModule.cs"
                {
#line 235 "AdvancedModule.cs"
#line 235 "AdvancedModule.cs"
                    int* csharp2cuda_temp_92 = &((output)->valid);
                    (*(csharp2cuda_temp_92) = 0);
#line 236 "AdvancedModule.cs"
                    break;
                }
#line 238 "AdvancedModule.cs"
                {
#line 239 "AdvancedModule.cs"
                    int csharp2cuda_temp_93 = (first)->count;
#line 239 "AdvancedModule.cs"
                    int player_count = mathblocks_advanced_log_two(csharp2cuda_temp_93);
#line 240 "AdvancedModule.cs"
                    mathblocks_sequence_set_vector_shape(output, player_count);
#line 241 "AdvancedModule.cs"
                    double denominator = mathblocks_advanced_factorial(player_count);
#line 242 "AdvancedModule.cs"
                    {
#line 242 "AdvancedModule.cs"
                        int player = 0;
                        while (true)
                        {
                            if (!(((player) < (player_count))))
                                break;
#line 243 "AdvancedModule.cs"
                            {
#line 244 "AdvancedModule.cs"
#line 244 "AdvancedModule.cs"
                                double* csharp2cuda_temp_95 = &((result)[player]);
                                (*(csharp2cuda_temp_95) = 0.0);
#line 245 "AdvancedModule.cs"
                                {
#line 245 "AdvancedModule.cs"
                                    int coalition = 0;
                                    while (true)
                                    {
#line 245 "AdvancedModule.cs"
                                        int csharp2cuda_temp_97 = (first)->count;
                                        if (!(((coalition) < (csharp2cuda_temp_97))))
                                            break;
#line 246 "AdvancedModule.cs"
                                        {
#line 247 "AdvancedModule.cs"
                                            if (((csharp2cuda_i32_and(coalition, csharp2cuda_i32_shl(1, player))) != (0)))
                                            {
#line 248 "AdvancedModule.cs"
                                                goto csharp2cuda_for_continue_9;
                                            }
#line 249 "AdvancedModule.cs"
                                            int size = mathblocks_advanced_popcount(coalition);
#line 250 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(__dmul_rn(mathblocks_advanced_factorial(size), mathblocks_advanced_factorial(csharp2cuda_i32_sub(csharp2cuda_i32_sub(player_count, size), 1))), denominator);
#line 253 "AdvancedModule.cs"
#line 253 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_98 = &((result)[player]);
#line 253 "AdvancedModule.cs"
                                            double csharp2cuda_temp_99 = *(csharp2cuda_temp_98);
#line 254 "AdvancedModule.cs"
                                            double csharp2cuda_temp_100 = (a)[csharp2cuda_i32_or(coalition, csharp2cuda_i32_shl(1, player))];
#line 254 "AdvancedModule.cs"
                                            double csharp2cuda_temp_101 = (a)[coalition];
                                            (*(csharp2cuda_temp_98) = __dadd_rn(csharp2cuda_temp_99, __dmul_rn(weight, __dsub_rn(csharp2cuda_temp_100, csharp2cuda_temp_101))));
                                        }
                                        csharp2cuda_for_continue_9:
#line 245 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_96 = &(coalition);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_96));
                                    }
                                }
                            }
#line 242 "AdvancedModule.cs"
                            int* csharp2cuda_temp_94 = &(player);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_94));
                        }
                    }
#line 257 "AdvancedModule.cs"
                    break;
                }
#line 259 "AdvancedModule.cs"
            case 4:
            case 5:
#line 261 "AdvancedModule.cs"
#line 261 "AdvancedModule.cs"
                int csharp2cuda_temp_102 = (third)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_102);
#line 262 "AdvancedModule.cs"
#line 262 "AdvancedModule.cs"
                int csharp2cuda_temp_103 = (first)->count;
#line 262 "AdvancedModule.cs"
                bool csharp2cuda_temp_104;
#line 262 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_103) <= (0))))
                {
#line 262 "AdvancedModule.cs"
                    int csharp2cuda_temp_105 = (first)->count;
#line 262 "AdvancedModule.cs"
                    int csharp2cuda_temp_106 = (second)->count;
#line 262 "AdvancedModule.cs"
                    csharp2cuda_temp_104 = ((csharp2cuda_temp_105) != (csharp2cuda_temp_106));
                }
                else
                {
#line 262 "AdvancedModule.cs"
                    csharp2cuda_temp_104 = true;
                }
#line 262 "AdvancedModule.cs"
                bool csharp2cuda_temp_107;
#line 262 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_104))
                {
#line 262 "AdvancedModule.cs"
                    double csharp2cuda_temp_108 = (fourth)->scalar_value;
#line 262 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = ((csharp2cuda_temp_108) < (0.0));
                }
                else
                {
#line 262 "AdvancedModule.cs"
                    csharp2cuda_temp_107 = true;
                }
                if (csharp2cuda_temp_107)
#line 263 "AdvancedModule.cs"
                {
#line 264 "AdvancedModule.cs"
#line 264 "AdvancedModule.cs"
                    int* csharp2cuda_temp_109 = &((output)->valid);
                    (*(csharp2cuda_temp_109) = 0);
#line 265 "AdvancedModule.cs"
                    break;
                }
#line 267 "AdvancedModule.cs"
                {
#line 267 "AdvancedModule.cs"
                    int query = 0;
                    while (true)
                    {
#line 267 "AdvancedModule.cs"
                        int csharp2cuda_temp_111 = (third)->count;
                        if (!(((query) < (csharp2cuda_temp_111))))
                            break;
#line 268 "AdvancedModule.cs"
                        {
#line 269 "AdvancedModule.cs"
                            double csharp2cuda_temp_112;
#line 269 "AdvancedModule.cs"
                            if (((opcode) == (4)))
                            {
#line 269 "AdvancedModule.cs"
                                csharp2cuda_temp_112 = mathblocks_positive_infinity();
                            }
                            else
                            {
#line 269 "AdvancedModule.cs"
                                csharp2cuda_temp_112 = (-(mathblocks_positive_infinity()));
                            }
#line 269 "AdvancedModule.cs"
                            double selected = csharp2cuda_temp_112;
#line 272 "AdvancedModule.cs"
                            {
#line 272 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
#line 272 "AdvancedModule.cs"
                                    int csharp2cuda_temp_114 = (first)->count;
                                    if (!(((index) < (csharp2cuda_temp_114))))
                                        break;
#line 273 "AdvancedModule.cs"
                                    {
#line 274 "AdvancedModule.cs"
                                        double csharp2cuda_temp_115;
#line 274 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 275 "AdvancedModule.cs"
                                            double csharp2cuda_temp_116 = (b)[index];
#line 275 "AdvancedModule.cs"
                                            double csharp2cuda_temp_117 = (fourth)->scalar_value;
#line 275 "AdvancedModule.cs"
                                            double csharp2cuda_temp_118 = (c)[query];
#line 275 "AdvancedModule.cs"
                                            double csharp2cuda_temp_119 = (a)[index];
#line 274 "AdvancedModule.cs"
                                            csharp2cuda_temp_115 = __dadd_rn(csharp2cuda_temp_116, __dmul_rn(csharp2cuda_temp_117, fabs(__dsub_rn(csharp2cuda_temp_118, csharp2cuda_temp_119))));
                                        }
                                        else
                                        {
#line 276 "AdvancedModule.cs"
                                            double csharp2cuda_temp_120 = (b)[index];
#line 276 "AdvancedModule.cs"
                                            double csharp2cuda_temp_121 = (fourth)->scalar_value;
#line 276 "AdvancedModule.cs"
                                            double csharp2cuda_temp_122 = (c)[query];
#line 276 "AdvancedModule.cs"
                                            double csharp2cuda_temp_123 = (a)[index];
#line 274 "AdvancedModule.cs"
                                            csharp2cuda_temp_115 = __dsub_rn(csharp2cuda_temp_120, __dmul_rn(csharp2cuda_temp_121, fabs(__dsub_rn(csharp2cuda_temp_122, csharp2cuda_temp_123))));
                                        }
#line 274 "AdvancedModule.cs"
                                        double candidate = csharp2cuda_temp_115;
#line 277 "AdvancedModule.cs"
#line 277 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_124 = &(selected);
#line 277 "AdvancedModule.cs"
                                        double csharp2cuda_temp_125;
#line 277 "AdvancedModule.cs"
                                        if (((opcode) == (4)))
                                        {
#line 278 "AdvancedModule.cs"
                                            double csharp2cuda_temp_126;
#line 278 "AdvancedModule.cs"
                                            if (((selected) < (candidate)))
                                            {
#line 278 "AdvancedModule.cs"
                                                csharp2cuda_temp_126 = selected;
                                            }
                                            else
                                            {
#line 278 "AdvancedModule.cs"
                                                csharp2cuda_temp_126 = candidate;
                                            }
#line 277 "AdvancedModule.cs"
                                            csharp2cuda_temp_125 = csharp2cuda_temp_126;
                                        }
                                        else
                                        {
#line 279 "AdvancedModule.cs"
                                            double csharp2cuda_temp_127;
#line 279 "AdvancedModule.cs"
                                            if (((selected) > (candidate)))
                                            {
#line 279 "AdvancedModule.cs"
                                                csharp2cuda_temp_127 = selected;
                                            }
                                            else
                                            {
#line 279 "AdvancedModule.cs"
                                                csharp2cuda_temp_127 = candidate;
                                            }
#line 277 "AdvancedModule.cs"
                                            csharp2cuda_temp_125 = csharp2cuda_temp_127;
                                        }
                                        (*(csharp2cuda_temp_124) = csharp2cuda_temp_125);
                                    }
#line 272 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_113 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                                }
                            }
#line 281 "AdvancedModule.cs"
#line 281 "AdvancedModule.cs"
                            double* csharp2cuda_temp_128 = &((result)[query]);
                            (*(csharp2cuda_temp_128) = selected);
                        }
#line 267 "AdvancedModule.cs"
                        int* csharp2cuda_temp_110 = &(query);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_110));
                    }
                }
#line 283 "AdvancedModule.cs"
                break;
#line 284 "AdvancedModule.cs"
            case 6:
#line 285 "AdvancedModule.cs"
#line 285 "AdvancedModule.cs"
                int csharp2cuda_temp_129 = (first)->count;
                if (((csharp2cuda_temp_129) <= (0)))
#line 286 "AdvancedModule.cs"
                {
#line 287 "AdvancedModule.cs"
#line 287 "AdvancedModule.cs"
                    int* csharp2cuda_temp_130 = &((output)->valid);
                    (*(csharp2cuda_temp_130) = 0);
#line 288 "AdvancedModule.cs"
                    break;
                }
#line 290 "AdvancedModule.cs"
                {
#line 291 "AdvancedModule.cs"
                    double sum = 0.0;
#line 292 "AdvancedModule.cs"
                    {
#line 292 "AdvancedModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 292 "AdvancedModule.cs"
                            int csharp2cuda_temp_132 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_132))))
                                break;
#line 293 "AdvancedModule.cs"
                            {
#line 293 "AdvancedModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 293 "AdvancedModule.cs"
                                    int csharp2cuda_temp_134 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_134))))
                                        break;
#line 294 "AdvancedModule.cs"
#line 294 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_135 = &(sum);
#line 294 "AdvancedModule.cs"
                                    double csharp2cuda_temp_136 = *(csharp2cuda_temp_135);
#line 294 "AdvancedModule.cs"
                                    double csharp2cuda_temp_137 = (a)[left];
#line 294 "AdvancedModule.cs"
                                    double csharp2cuda_temp_138 = (a)[right];
                                    (*(csharp2cuda_temp_135) = __dadd_rn(csharp2cuda_temp_136, fabs(__dsub_rn(csharp2cuda_temp_137, csharp2cuda_temp_138))));
#line 293 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_133 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_133));
                                }
                            }
#line 292 "AdvancedModule.cs"
                            int* csharp2cuda_temp_131 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_131));
                        }
                    }
#line 295 "AdvancedModule.cs"
#line 295 "AdvancedModule.cs"
                    double* csharp2cuda_temp_139 = &((output)->scalar_value);
#line 296 "AdvancedModule.cs"
                    int csharp2cuda_temp_140 = (first)->count;
#line 296 "AdvancedModule.cs"
                    int csharp2cuda_temp_141 = (first)->count;
#line 295 "AdvancedModule.cs"
                    double csharp2cuda_temp_142 = __ddiv_rn(sum, __dmul_rn(__dmul_rn(2.0, ((double)(csharp2cuda_temp_140))), mathblocks_compensated_sum(a, csharp2cuda_temp_141)));
                    (*(csharp2cuda_temp_139) = csharp2cuda_temp_142);
#line 297 "AdvancedModule.cs"
                    break;
                }
#line 299 "AdvancedModule.cs"
            case 7:
#line 300 "AdvancedModule.cs"
#line 300 "AdvancedModule.cs"
                int csharp2cuda_temp_143 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_143, 1));
#line 301 "AdvancedModule.cs"
#line 301 "AdvancedModule.cs"
                int csharp2cuda_temp_144 = (first)->count;
                if (((csharp2cuda_temp_144) <= (0)))
#line 302 "AdvancedModule.cs"
                {
#line 303 "AdvancedModule.cs"
#line 303 "AdvancedModule.cs"
                    int* csharp2cuda_temp_145 = &((output)->valid);
                    (*(csharp2cuda_temp_145) = 0);
#line 304 "AdvancedModule.cs"
                    break;
                }
#line 306 "AdvancedModule.cs"
#line 306 "AdvancedModule.cs"
                double* csharp2cuda_temp_146 = &((result)[0]);
                (*(csharp2cuda_temp_146) = 0.0);
#line 307 "AdvancedModule.cs"
                {
#line 307 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 307 "AdvancedModule.cs"
                        int csharp2cuda_temp_148 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_148))))
                            break;
#line 308 "AdvancedModule.cs"
                        {
#line 309 "AdvancedModule.cs"
                            double value = (a)[index];
#line 310 "AdvancedModule.cs"
                            int position = index;
#line 311 "AdvancedModule.cs"
                            while (true)
                            {
#line 311 "AdvancedModule.cs"
                                bool csharp2cuda_temp_149;
#line 311 "AdvancedModule.cs"
                                if (((position) > (0)))
                                {
#line 311 "AdvancedModule.cs"
                                    double csharp2cuda_temp_150 = (result)[position];
#line 311 "AdvancedModule.cs"
                                    csharp2cuda_temp_149 = ((csharp2cuda_temp_150) > (value));
                                }
                                else
                                {
#line 311 "AdvancedModule.cs"
                                    csharp2cuda_temp_149 = false;
                                }
                                if (!(csharp2cuda_temp_149))
                                    break;
#line 312 "AdvancedModule.cs"
                                {
#line 313 "AdvancedModule.cs"
#line 313 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_151 = &((result)[csharp2cuda_i32_add(position, 1)]);
#line 313 "AdvancedModule.cs"
                                    double csharp2cuda_temp_152 = (result)[position];
                                    (*(csharp2cuda_temp_151) = csharp2cuda_temp_152);
#line 314 "AdvancedModule.cs"
#line 314 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_153 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_153));
                                }
                            }
#line 316 "AdvancedModule.cs"
#line 316 "AdvancedModule.cs"
                            double* csharp2cuda_temp_154 = &((result)[csharp2cuda_i32_add(position, 1)]);
                            (*(csharp2cuda_temp_154) = value);
                        }
#line 307 "AdvancedModule.cs"
                        int* csharp2cuda_temp_147 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_147));
                    }
                }
#line 318 "AdvancedModule.cs"
                {
#line 319 "AdvancedModule.cs"
                    int csharp2cuda_temp_155 = (first)->count;
#line 319 "AdvancedModule.cs"
                    double total = mathblocks_compensated_sum(csharp2cuda_pointer_add(result, 1), csharp2cuda_temp_155);
#line 320 "AdvancedModule.cs"
                    {
#line 320 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 320 "AdvancedModule.cs"
                            int csharp2cuda_temp_157 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_157))))
                                break;
#line 321 "AdvancedModule.cs"
#line 321 "AdvancedModule.cs"
                            double* csharp2cuda_temp_158 = &((result)[csharp2cuda_i32_add(index, 1)]);
#line 321 "AdvancedModule.cs"
                            double csharp2cuda_temp_159 = (result)[index];
#line 321 "AdvancedModule.cs"
                            double csharp2cuda_temp_160 = (result)[csharp2cuda_i32_add(index, 1)];
#line 321 "AdvancedModule.cs"
                            double csharp2cuda_temp_161 = __ddiv_rn(csharp2cuda_temp_160, total);
                            (*(csharp2cuda_temp_158) = __dadd_rn(csharp2cuda_temp_159, csharp2cuda_temp_161));
#line 320 "AdvancedModule.cs"
                            int* csharp2cuda_temp_156 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                        }
                    }
#line 322 "AdvancedModule.cs"
                    break;
                }
#line 324 "AdvancedModule.cs"
            case 8:
#line 325 "AdvancedModule.cs"
#line 325 "AdvancedModule.cs"
                int csharp2cuda_temp_162 = (first)->rows;
#line 325 "AdvancedModule.cs"
                int csharp2cuda_temp_163 = (first)->columns;
#line 325 "AdvancedModule.cs"
                bool csharp2cuda_temp_164;
#line 325 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_162) != (csharp2cuda_temp_163))))
                {
#line 325 "AdvancedModule.cs"
                    int csharp2cuda_temp_165 = (first)->rows;
#line 325 "AdvancedModule.cs"
                    int csharp2cuda_temp_166 = (second)->count;
#line 325 "AdvancedModule.cs"
                    csharp2cuda_temp_164 = ((csharp2cuda_temp_165) != (csharp2cuda_temp_166));
                }
                else
                {
#line 325 "AdvancedModule.cs"
                    csharp2cuda_temp_164 = true;
                }
#line 325 "AdvancedModule.cs"
                bool csharp2cuda_temp_167;
#line 325 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_164))
                {
#line 326 "AdvancedModule.cs"
                    int csharp2cuda_temp_168 = (first)->rows;
#line 326 "AdvancedModule.cs"
                    int csharp2cuda_temp_169 = (first)->columns;
#line 326 "AdvancedModule.cs"
                    bool csharp2cuda_temp_170 = mathblocks_advanced_transition(a, csharp2cuda_temp_168, csharp2cuda_temp_169);
#line 325 "AdvancedModule.cs"
                    csharp2cuda_temp_167 = (!(csharp2cuda_temp_170));
                }
                else
                {
#line 325 "AdvancedModule.cs"
                    csharp2cuda_temp_167 = true;
                }
#line 325 "AdvancedModule.cs"
                bool csharp2cuda_temp_171;
#line 325 "AdvancedModule.cs"
                if (!(csharp2cuda_temp_167))
                {
#line 327 "AdvancedModule.cs"
                    int csharp2cuda_temp_172 = (second)->count;
#line 327 "AdvancedModule.cs"
                    bool csharp2cuda_temp_173 = mathblocks_advanced_distribution(b, csharp2cuda_temp_172);
#line 325 "AdvancedModule.cs"
                    csharp2cuda_temp_171 = (!(csharp2cuda_temp_173));
                }
                else
                {
#line 325 "AdvancedModule.cs"
                    csharp2cuda_temp_171 = true;
                }
                if (csharp2cuda_temp_171)
#line 328 "AdvancedModule.cs"
                {
#line 329 "AdvancedModule.cs"
#line 329 "AdvancedModule.cs"
                    int* csharp2cuda_temp_174 = &((output)->valid);
                    (*(csharp2cuda_temp_174) = 0);
#line 330 "AdvancedModule.cs"
                    break;
                }
#line 332 "AdvancedModule.cs"
                {
#line 333 "AdvancedModule.cs"
                    double total = 0.0;
#line 334 "AdvancedModule.cs"
                    {
#line 334 "AdvancedModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 334 "AdvancedModule.cs"
                            int csharp2cuda_temp_176 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_176))))
                                break;
#line 335 "AdvancedModule.cs"
                            {
#line 335 "AdvancedModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 335 "AdvancedModule.cs"
                                    int csharp2cuda_temp_178 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_178))))
                                        break;
#line 336 "AdvancedModule.cs"
                                    {
#line 337 "AdvancedModule.cs"
                                        double csharp2cuda_temp_179 = (b)[row];
#line 337 "AdvancedModule.cs"
                                        int csharp2cuda_temp_180 = (first)->columns;
#line 337 "AdvancedModule.cs"
                                        double csharp2cuda_temp_181 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_180), column)];
#line 337 "AdvancedModule.cs"
                                        double forward = __dmul_rn(csharp2cuda_temp_179, csharp2cuda_temp_181);
#line 338 "AdvancedModule.cs"
                                        double csharp2cuda_temp_182 = (b)[column];
#line 338 "AdvancedModule.cs"
                                        int csharp2cuda_temp_183 = (first)->columns;
#line 338 "AdvancedModule.cs"
                                        double csharp2cuda_temp_184 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_183), row)];
#line 338 "AdvancedModule.cs"
                                        double reverse = __dmul_rn(csharp2cuda_temp_182, csharp2cuda_temp_184);
#line 339 "AdvancedModule.cs"
#line 339 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_185;
#line 339 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 339 "AdvancedModule.cs"
                                            csharp2cuda_temp_185 = ((reverse) == (0.0));
                                        }
                                        else
                                        {
#line 339 "AdvancedModule.cs"
                                            csharp2cuda_temp_185 = false;
                                        }
                                        if (csharp2cuda_temp_185)
#line 340 "AdvancedModule.cs"
                                        {
#line 341 "AdvancedModule.cs"
#line 341 "AdvancedModule.cs"
                                            int* csharp2cuda_temp_186 = &((output)->valid);
                                            (*(csharp2cuda_temp_186) = 0);
#line 342 "AdvancedModule.cs"
                                            break;
                                        }
#line 344 "AdvancedModule.cs"
#line 344 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_187;
#line 344 "AdvancedModule.cs"
                                        if (((forward) > (0.0)))
                                        {
#line 344 "AdvancedModule.cs"
                                            csharp2cuda_temp_187 = ((reverse) > (0.0));
                                        }
                                        else
                                        {
#line 344 "AdvancedModule.cs"
                                            csharp2cuda_temp_187 = false;
                                        }
                                        if (csharp2cuda_temp_187)
                                        {
#line 345 "AdvancedModule.cs"
#line 345 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_188 = &(total);
#line 345 "AdvancedModule.cs"
                                            double csharp2cuda_temp_189 = *(csharp2cuda_temp_188);
#line 345 "AdvancedModule.cs"
                                            double csharp2cuda_temp_190 = __ddiv_rn(forward, reverse);
                                            (*(csharp2cuda_temp_188) = __dadd_rn(csharp2cuda_temp_189, __dmul_rn(forward, mathblocks_natural_logarithm(csharp2cuda_temp_190))));
                                        }
                                    }
#line 335 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_177 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_177));
                                }
                            }
#line 334 "AdvancedModule.cs"
                            int* csharp2cuda_temp_175 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_175));
                        }
                    }
#line 347 "AdvancedModule.cs"
#line 347 "AdvancedModule.cs"
                    double* csharp2cuda_temp_191 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_191) = total);
#line 348 "AdvancedModule.cs"
                    break;
                }
#line 350 "AdvancedModule.cs"
            case 9:
#line 351 "AdvancedModule.cs"
#line 351 "AdvancedModule.cs"
                int csharp2cuda_temp_192 = (first)->rows;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_192);
#line 352 "AdvancedModule.cs"
#line 352 "AdvancedModule.cs"
                int csharp2cuda_temp_193 = (first)->rows;
#line 352 "AdvancedModule.cs"
                int csharp2cuda_temp_194 = (first)->columns;
#line 352 "AdvancedModule.cs"
                bool csharp2cuda_temp_195 = mathblocks_advanced_transition(a, csharp2cuda_temp_193, csharp2cuda_temp_194);
#line 352 "AdvancedModule.cs"
                bool csharp2cuda_temp_196;
#line 352 "AdvancedModule.cs"
                if (!((!(csharp2cuda_temp_195))))
                {
#line 352 "AdvancedModule.cs"
                    csharp2cuda_temp_196 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 352 "AdvancedModule.cs"
                    csharp2cuda_temp_196 = true;
                }
                if (csharp2cuda_temp_196)
#line 353 "AdvancedModule.cs"
                {
#line 354 "AdvancedModule.cs"
#line 354 "AdvancedModule.cs"
                    int* csharp2cuda_temp_197 = &((output)->valid);
                    (*(csharp2cuda_temp_197) = 0);
#line 355 "AdvancedModule.cs"
                    break;
                }
#line 357 "AdvancedModule.cs"
                {
#line 358 "AdvancedModule.cs"
                    int iterations = 0;
#line 359 "AdvancedModule.cs"
#line 359 "AdvancedModule.cs"
                    double csharp2cuda_temp_198 = (second)->scalar_value;
#line 359 "AdvancedModule.cs"
                    int* csharp2cuda_temp_199 = &(iterations);
#line 359 "AdvancedModule.cs"
                    bool csharp2cuda_temp_200 = mathblocks_sequence_positive_integer(csharp2cuda_temp_198, csharp2cuda_temp_199);
                    if ((!(csharp2cuda_temp_200)))
#line 360 "AdvancedModule.cs"
                    {
#line 361 "AdvancedModule.cs"
#line 361 "AdvancedModule.cs"
                        int* csharp2cuda_temp_201 = &((output)->valid);
                        (*(csharp2cuda_temp_201) = 0);
#line 362 "AdvancedModule.cs"
                        break;
                    }
#line 364 "AdvancedModule.cs"
                    {
#line 364 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 364 "AdvancedModule.cs"
                            int csharp2cuda_temp_203 = (first)->rows;
                            if (!(((index) < (csharp2cuda_temp_203))))
                                break;
#line 365 "AdvancedModule.cs"
#line 365 "AdvancedModule.cs"
                            double* csharp2cuda_temp_204 = &((result)[index]);
#line 365 "AdvancedModule.cs"
                            int csharp2cuda_temp_205 = (first)->rows;
#line 365 "AdvancedModule.cs"
                            double csharp2cuda_temp_206 = __ddiv_rn(1.0, ((double)(csharp2cuda_temp_205)));
                            (*(csharp2cuda_temp_204) = csharp2cuda_temp_206);
#line 364 "AdvancedModule.cs"
                            int* csharp2cuda_temp_202 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_202));
                        }
                    }
#line 366 "AdvancedModule.cs"
                    {
#line 366 "AdvancedModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (iterations))))
                                break;
#line 367 "AdvancedModule.cs"
                            {
#line 368 "AdvancedModule.cs"
                                {
#line 368 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 368 "AdvancedModule.cs"
                                        int csharp2cuda_temp_209 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_209))))
                                            break;
#line 369 "AdvancedModule.cs"
#line 369 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_210 = &((scratch)[index]);
                                        (*(csharp2cuda_temp_210) = 0.0);
#line 368 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_208 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_208));
                                    }
                                }
#line 370 "AdvancedModule.cs"
                                {
#line 370 "AdvancedModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
#line 370 "AdvancedModule.cs"
                                        int csharp2cuda_temp_212 = (first)->rows;
                                        if (!(((row) < (csharp2cuda_temp_212))))
                                            break;
#line 371 "AdvancedModule.cs"
                                        {
#line 371 "AdvancedModule.cs"
                                            int column = 0;
                                            while (true)
                                            {
#line 371 "AdvancedModule.cs"
                                                int csharp2cuda_temp_214 = (first)->columns;
                                                if (!(((column) < (csharp2cuda_temp_214))))
                                                    break;
#line 372 "AdvancedModule.cs"
#line 372 "AdvancedModule.cs"
                                                double* csharp2cuda_temp_215 = &((scratch)[column]);
#line 372 "AdvancedModule.cs"
                                                double csharp2cuda_temp_216 = *(csharp2cuda_temp_215);
#line 372 "AdvancedModule.cs"
                                                double csharp2cuda_temp_217 = (result)[row];
#line 372 "AdvancedModule.cs"
                                                int csharp2cuda_temp_218 = (first)->columns;
#line 372 "AdvancedModule.cs"
                                                double csharp2cuda_temp_219 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_218), column)];
                                                (*(csharp2cuda_temp_215) = __dadd_rn(csharp2cuda_temp_216, __dmul_rn(csharp2cuda_temp_217, csharp2cuda_temp_219)));
#line 371 "AdvancedModule.cs"
                                                int* csharp2cuda_temp_213 = &(column);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_213));
                                            }
                                        }
#line 370 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_211 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_211));
                                    }
                                }
#line 373 "AdvancedModule.cs"
                                {
#line 373 "AdvancedModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 373 "AdvancedModule.cs"
                                        int csharp2cuda_temp_221 = (first)->rows;
                                        if (!(((index) < (csharp2cuda_temp_221))))
                                            break;
#line 374 "AdvancedModule.cs"
#line 374 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_222 = &((result)[index]);
#line 374 "AdvancedModule.cs"
                                        double csharp2cuda_temp_223 = (scratch)[index];
                                        (*(csharp2cuda_temp_222) = csharp2cuda_temp_223);
#line 373 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_220 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_220));
                                    }
                                }
                            }
#line 366 "AdvancedModule.cs"
                            int* csharp2cuda_temp_207 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_207));
                        }
                    }
#line 376 "AdvancedModule.cs"
                    break;
                }
#line 378 "AdvancedModule.cs"
            case 10:
#line 379 "AdvancedModule.cs"
#line 379 "AdvancedModule.cs"
                int csharp2cuda_temp_224 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_224);
#line 380 "AdvancedModule.cs"
#line 380 "AdvancedModule.cs"
                int csharp2cuda_temp_225 = (first)->count;
#line 380 "AdvancedModule.cs"
                bool csharp2cuda_temp_226;
#line 380 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_225) <= (0))))
                {
#line 380 "AdvancedModule.cs"
                    csharp2cuda_temp_226 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 380 "AdvancedModule.cs"
                    csharp2cuda_temp_226 = true;
                }
                if (csharp2cuda_temp_226)
#line 381 "AdvancedModule.cs"
                {
#line 382 "AdvancedModule.cs"
#line 382 "AdvancedModule.cs"
                    int* csharp2cuda_temp_227 = &((output)->valid);
                    (*(csharp2cuda_temp_227) = 0);
#line 383 "AdvancedModule.cs"
                    break;
                }
#line 385 "AdvancedModule.cs"
                {
#line 386 "AdvancedModule.cs"
                    double* means = scratch;
#line 387 "AdvancedModule.cs"
                    int csharp2cuda_temp_228 = (first)->count;
#line 387 "AdvancedModule.cs"
                    int* weights = ((int*)(csharp2cuda_pointer_add(means, csharp2cuda_temp_228)));
#line 388 "AdvancedModule.cs"
                    int csharp2cuda_temp_229 = (first)->count;
#line 388 "AdvancedModule.cs"
                    int* starts = csharp2cuda_pointer_add(weights, csharp2cuda_temp_229);
#line 389 "AdvancedModule.cs"
                    int block_count = 0;
#line 390 "AdvancedModule.cs"
                    {
#line 390 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 390 "AdvancedModule.cs"
                            int csharp2cuda_temp_231 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_231))))
                                break;
#line 391 "AdvancedModule.cs"
                            {
#line 392 "AdvancedModule.cs"
#line 392 "AdvancedModule.cs"
                                double* csharp2cuda_temp_232 = &((means)[block_count]);
#line 392 "AdvancedModule.cs"
                                double csharp2cuda_temp_233 = (a)[index];
                                (*(csharp2cuda_temp_232) = csharp2cuda_temp_233);
#line 393 "AdvancedModule.cs"
#line 393 "AdvancedModule.cs"
                                int* csharp2cuda_temp_234 = &((weights)[block_count]);
                                (*(csharp2cuda_temp_234) = 1);
#line 394 "AdvancedModule.cs"
#line 394 "AdvancedModule.cs"
                                int* csharp2cuda_temp_235 = &((starts)[block_count]);
                                (*(csharp2cuda_temp_235) = index);
#line 395 "AdvancedModule.cs"
#line 395 "AdvancedModule.cs"
                                int* csharp2cuda_temp_236 = &(block_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_236));
#line 396 "AdvancedModule.cs"
                                while (true)
                                {
#line 396 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_237;
#line 396 "AdvancedModule.cs"
                                    if (((block_count) >= (2)))
                                    {
#line 396 "AdvancedModule.cs"
                                        double csharp2cuda_temp_238 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 396 "AdvancedModule.cs"
                                        double csharp2cuda_temp_239 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 396 "AdvancedModule.cs"
                                        csharp2cuda_temp_237 = ((csharp2cuda_temp_238) > (csharp2cuda_temp_239));
                                    }
                                    else
                                    {
#line 396 "AdvancedModule.cs"
                                        csharp2cuda_temp_237 = false;
                                    }
                                    if (!(csharp2cuda_temp_237))
                                        break;
#line 397 "AdvancedModule.cs"
                                    {
#line 398 "AdvancedModule.cs"
                                        int csharp2cuda_temp_240 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 398 "AdvancedModule.cs"
                                        int csharp2cuda_temp_241 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 398 "AdvancedModule.cs"
                                        int combined_weight = csharp2cuda_i32_add(csharp2cuda_temp_240, csharp2cuda_temp_241);
#line 399 "AdvancedModule.cs"
#line 399 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_242 = &((means)[csharp2cuda_i32_sub(block_count, 2)]);
#line 400 "AdvancedModule.cs"
                                        double csharp2cuda_temp_243 = (means)[csharp2cuda_i32_sub(block_count, 2)];
#line 400 "AdvancedModule.cs"
                                        int csharp2cuda_temp_244 = (weights)[csharp2cuda_i32_sub(block_count, 2)];
#line 401 "AdvancedModule.cs"
                                        double csharp2cuda_temp_245 = (means)[csharp2cuda_i32_sub(block_count, 1)];
#line 401 "AdvancedModule.cs"
                                        int csharp2cuda_temp_246 = (weights)[csharp2cuda_i32_sub(block_count, 1)];
#line 400 "AdvancedModule.cs"
                                        double csharp2cuda_temp_247 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_243, ((double)(csharp2cuda_temp_244))), __dmul_rn(csharp2cuda_temp_245, ((double)(csharp2cuda_temp_246)))), ((double)(combined_weight)));
                                        (*(csharp2cuda_temp_242) = csharp2cuda_temp_247);
#line 403 "AdvancedModule.cs"
#line 403 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_248 = &((weights)[csharp2cuda_i32_sub(block_count, 2)]);
                                        (*(csharp2cuda_temp_248) = combined_weight);
#line 404 "AdvancedModule.cs"
#line 404 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_249 = &(block_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_249));
                                    }
                                }
                            }
#line 390 "AdvancedModule.cs"
                            int* csharp2cuda_temp_230 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_230));
                        }
                    }
#line 407 "AdvancedModule.cs"
                    {
#line 407 "AdvancedModule.cs"
                        int block = 0;
                        while (true)
                        {
                            if (!(((block) < (block_count))))
                                break;
#line 408 "AdvancedModule.cs"
                            {
#line 409 "AdvancedModule.cs"
                                int csharp2cuda_temp_251;
#line 409 "AdvancedModule.cs"
                                if (((csharp2cuda_i32_add(block, 1)) < (block_count)))
                                {
#line 409 "AdvancedModule.cs"
                                    csharp2cuda_temp_251 = (starts)[csharp2cuda_i32_add(block, 1)];
                                }
                                else
                                {
#line 409 "AdvancedModule.cs"
                                    csharp2cuda_temp_251 = (first)->count;
                                }
#line 409 "AdvancedModule.cs"
                                int end = csharp2cuda_temp_251;
#line 410 "AdvancedModule.cs"
                                {
#line 410 "AdvancedModule.cs"
                                    int index = (starts)[block];
                                    while (true)
                                    {
                                        if (!(((index) < (end))))
                                            break;
#line 411 "AdvancedModule.cs"
#line 411 "AdvancedModule.cs"
                                        double* csharp2cuda_temp_253 = &((result)[index]);
#line 411 "AdvancedModule.cs"
                                        double csharp2cuda_temp_254 = (means)[block];
                                        (*(csharp2cuda_temp_253) = csharp2cuda_temp_254);
#line 410 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_252 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_252));
                                    }
                                }
                            }
#line 407 "AdvancedModule.cs"
                            int* csharp2cuda_temp_250 = &(block);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_250));
                        }
                    }
#line 413 "AdvancedModule.cs"
                    break;
                }
#line 415 "AdvancedModule.cs"
            case 11:
#line 416 "AdvancedModule.cs"
#line 416 "AdvancedModule.cs"
                int csharp2cuda_temp_255 = (first)->count;
#line 416 "AdvancedModule.cs"
                int csharp2cuda_temp_256 = (second)->count;
#line 416 "AdvancedModule.cs"
                bool csharp2cuda_temp_257;
#line 416 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_255) != (csharp2cuda_temp_256))))
                {
#line 416 "AdvancedModule.cs"
                    csharp2cuda_temp_257 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 416 "AdvancedModule.cs"
                    csharp2cuda_temp_257 = true;
                }
                if (csharp2cuda_temp_257)
#line 417 "AdvancedModule.cs"
                {
#line 418 "AdvancedModule.cs"
#line 418 "AdvancedModule.cs"
                    int* csharp2cuda_temp_258 = &((output)->valid);
                    (*(csharp2cuda_temp_258) = 0);
#line 419 "AdvancedModule.cs"
                    break;
                }
#line 421 "AdvancedModule.cs"
                {
#line 422 "AdvancedModule.cs"
                    double* left_sorted = scratch;
#line 423 "AdvancedModule.cs"
                    int csharp2cuda_temp_259 = (first)->count;
#line 423 "AdvancedModule.cs"
                    double* right_sorted = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_259);
#line 424 "AdvancedModule.cs"
#line 424 "AdvancedModule.cs"
                    int csharp2cuda_temp_260 = (first)->count;
                    mathblocks_advanced_sort_descending(a, csharp2cuda_temp_260, left_sorted);
#line 425 "AdvancedModule.cs"
#line 425 "AdvancedModule.cs"
                    int csharp2cuda_temp_261 = (first)->count;
                    mathblocks_advanced_sort_descending(b, csharp2cuda_temp_261, right_sorted);
#line 426 "AdvancedModule.cs"
                    double left_sum = 0.0;
#line 427 "AdvancedModule.cs"
                    double right_sum = 0.0;
#line 428 "AdvancedModule.cs"
                    bool majorizes = true;
#line 429 "AdvancedModule.cs"
                    {
#line 429 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 429 "AdvancedModule.cs"
                            int csharp2cuda_temp_263 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_263))))
                                break;
#line 430 "AdvancedModule.cs"
                            {
#line 431 "AdvancedModule.cs"
#line 431 "AdvancedModule.cs"
                                double* csharp2cuda_temp_264 = &(left_sum);
#line 431 "AdvancedModule.cs"
                                double csharp2cuda_temp_265 = *(csharp2cuda_temp_264);
#line 431 "AdvancedModule.cs"
                                double csharp2cuda_temp_266 = (left_sorted)[index];
                                (*(csharp2cuda_temp_264) = __dadd_rn(csharp2cuda_temp_265, csharp2cuda_temp_266));
#line 432 "AdvancedModule.cs"
#line 432 "AdvancedModule.cs"
                                double* csharp2cuda_temp_267 = &(right_sum);
#line 432 "AdvancedModule.cs"
                                double csharp2cuda_temp_268 = *(csharp2cuda_temp_267);
#line 432 "AdvancedModule.cs"
                                double csharp2cuda_temp_269 = (right_sorted)[index];
                                (*(csharp2cuda_temp_267) = __dadd_rn(csharp2cuda_temp_268, csharp2cuda_temp_269));
#line 433 "AdvancedModule.cs"
#line 433 "AdvancedModule.cs"
                                int csharp2cuda_temp_270 = (first)->count;
#line 433 "AdvancedModule.cs"
                                bool csharp2cuda_temp_271;
#line 433 "AdvancedModule.cs"
                                if (((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_270, 1))))
                                {
#line 433 "AdvancedModule.cs"
                                    csharp2cuda_temp_271 = ((left_sum) < (right_sum));
                                }
                                else
                                {
#line 433 "AdvancedModule.cs"
                                    csharp2cuda_temp_271 = false;
                                }
                                if (csharp2cuda_temp_271)
                                {
#line 434 "AdvancedModule.cs"
#line 434 "AdvancedModule.cs"
                                    bool* csharp2cuda_temp_272 = &(majorizes);
                                    (*(csharp2cuda_temp_272) = false);
                                }
                            }
#line 429 "AdvancedModule.cs"
                            int* csharp2cuda_temp_262 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_262));
                        }
                    }
#line 436 "AdvancedModule.cs"
#line 436 "AdvancedModule.cs"
                    int* csharp2cuda_temp_273 = &((output)->boolean_value);
#line 436 "AdvancedModule.cs"
                    bool csharp2cuda_temp_274;
#line 436 "AdvancedModule.cs"
                    if (majorizes)
                    {
#line 436 "AdvancedModule.cs"
                        csharp2cuda_temp_274 = ((left_sum) == (right_sum));
                    }
                    else
                    {
#line 436 "AdvancedModule.cs"
                        csharp2cuda_temp_274 = false;
                    }
#line 436 "AdvancedModule.cs"
                    int csharp2cuda_temp_275;
#line 436 "AdvancedModule.cs"
                    if (csharp2cuda_temp_274)
                    {
#line 436 "AdvancedModule.cs"
                        csharp2cuda_temp_275 = 1;
                    }
                    else
                    {
#line 436 "AdvancedModule.cs"
                        csharp2cuda_temp_275 = 0;
                    }
                    (*(csharp2cuda_temp_273) = csharp2cuda_temp_275);
#line 437 "AdvancedModule.cs"
                    break;
                }
#line 439 "AdvancedModule.cs"
            case 12:
#line 440 "AdvancedModule.cs"
#line 440 "AdvancedModule.cs"
                int csharp2cuda_temp_276 = (first)->count;
#line 440 "AdvancedModule.cs"
                bool csharp2cuda_temp_277;
#line 440 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_276) <= (0))))
                {
#line 440 "AdvancedModule.cs"
                    int csharp2cuda_temp_278 = (first)->count;
#line 440 "AdvancedModule.cs"
                    int csharp2cuda_temp_279 = (second)->count;
#line 440 "AdvancedModule.cs"
                    csharp2cuda_temp_277 = ((csharp2cuda_temp_278) != (csharp2cuda_temp_279));
                }
                else
                {
#line 440 "AdvancedModule.cs"
                    csharp2cuda_temp_277 = true;
                }
                if (csharp2cuda_temp_277)
#line 441 "AdvancedModule.cs"
                {
#line 442 "AdvancedModule.cs"
#line 442 "AdvancedModule.cs"
                    int* csharp2cuda_temp_280 = &((output)->valid);
                    (*(csharp2cuda_temp_280) = 0);
#line 443 "AdvancedModule.cs"
                    break;
                }
#line 445 "AdvancedModule.cs"
                {
#line 446 "AdvancedModule.cs"
                    double minimum = mathblocks_positive_infinity();
#line 447 "AdvancedModule.cs"
                    double maximum = (-(mathblocks_positive_infinity()));
#line 448 "AdvancedModule.cs"
                    {
#line 448 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 448 "AdvancedModule.cs"
                            int csharp2cuda_temp_282 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_282))))
                                break;
#line 449 "AdvancedModule.cs"
                            {
#line 450 "AdvancedModule.cs"
#line 450 "AdvancedModule.cs"
                                double csharp2cuda_temp_283 = (a)[index];
#line 450 "AdvancedModule.cs"
                                bool csharp2cuda_temp_284;
#line 450 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_283) <= (0.0))))
                                {
#line 450 "AdvancedModule.cs"
                                    double csharp2cuda_temp_285 = (b)[index];
#line 450 "AdvancedModule.cs"
                                    csharp2cuda_temp_284 = ((csharp2cuda_temp_285) <= (0.0));
                                }
                                else
                                {
#line 450 "AdvancedModule.cs"
                                    csharp2cuda_temp_284 = true;
                                }
                                if (csharp2cuda_temp_284)
#line 451 "AdvancedModule.cs"
                                {
#line 452 "AdvancedModule.cs"
#line 452 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_286 = &((output)->valid);
                                    (*(csharp2cuda_temp_286) = 0);
#line 453 "AdvancedModule.cs"
                                    break;
                                }
#line 455 "AdvancedModule.cs"
                                double csharp2cuda_temp_287 = (a)[index];
#line 455 "AdvancedModule.cs"
                                double csharp2cuda_temp_288 = (b)[index];
#line 455 "AdvancedModule.cs"
                                double ratio = __ddiv_rn(csharp2cuda_temp_287, csharp2cuda_temp_288);
#line 456 "AdvancedModule.cs"
#line 456 "AdvancedModule.cs"
                                double* csharp2cuda_temp_289 = &(minimum);
#line 456 "AdvancedModule.cs"
                                double csharp2cuda_temp_290;
#line 456 "AdvancedModule.cs"
                                if (((minimum) < (ratio)))
                                {
#line 456 "AdvancedModule.cs"
                                    csharp2cuda_temp_290 = minimum;
                                }
                                else
                                {
#line 456 "AdvancedModule.cs"
                                    csharp2cuda_temp_290 = ratio;
                                }
                                (*(csharp2cuda_temp_289) = csharp2cuda_temp_290);
#line 457 "AdvancedModule.cs"
#line 457 "AdvancedModule.cs"
                                double* csharp2cuda_temp_291 = &(maximum);
#line 457 "AdvancedModule.cs"
                                double csharp2cuda_temp_292;
#line 457 "AdvancedModule.cs"
                                if (((maximum) > (ratio)))
                                {
#line 457 "AdvancedModule.cs"
                                    csharp2cuda_temp_292 = maximum;
                                }
                                else
                                {
#line 457 "AdvancedModule.cs"
                                    csharp2cuda_temp_292 = ratio;
                                }
                                (*(csharp2cuda_temp_291) = csharp2cuda_temp_292);
                            }
#line 448 "AdvancedModule.cs"
                            int* csharp2cuda_temp_281 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_281));
                        }
                    }
#line 459 "AdvancedModule.cs"
#line 459 "AdvancedModule.cs"
                    double* csharp2cuda_temp_293 = &((output)->scalar_value);
#line 459 "AdvancedModule.cs"
                    double csharp2cuda_temp_294 = __ddiv_rn(maximum, minimum);
                    (*(csharp2cuda_temp_293) = mathblocks_natural_logarithm(csharp2cuda_temp_294));
#line 460 "AdvancedModule.cs"
                    break;
                }
#line 462 "AdvancedModule.cs"
            case 13:
            case 16:
#line 464 "AdvancedModule.cs"
#line 464 "AdvancedModule.cs"
                int csharp2cuda_temp_295 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_295);
#line 465 "AdvancedModule.cs"
#line 465 "AdvancedModule.cs"
                int csharp2cuda_temp_296 = (first)->count;
#line 465 "AdvancedModule.cs"
                bool csharp2cuda_temp_297;
#line 465 "AdvancedModule.cs"
                if (!(((csharp2cuda_temp_296) <= (0))))
                {
#line 465 "AdvancedModule.cs"
                    csharp2cuda_temp_297 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 465 "AdvancedModule.cs"
                    csharp2cuda_temp_297 = true;
                }
                if (csharp2cuda_temp_297)
#line 466 "AdvancedModule.cs"
                {
#line 467 "AdvancedModule.cs"
#line 467 "AdvancedModule.cs"
                    int* csharp2cuda_temp_298 = &((output)->valid);
                    (*(csharp2cuda_temp_298) = 0);
#line 468 "AdvancedModule.cs"
                    break;
                }
#line 470 "AdvancedModule.cs"
                {
#line 471 "AdvancedModule.cs"
                    int* hull = ((int*)(scratch));
#line 472 "AdvancedModule.cs"
                    int hull_count = 0;
#line 473 "AdvancedModule.cs"
                    bool concave = ((opcode) == (16));
#line 474 "AdvancedModule.cs"
                    {
#line 474 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 474 "AdvancedModule.cs"
                            int csharp2cuda_temp_300 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_300))))
                                break;
#line 475 "AdvancedModule.cs"
                            {
#line 476 "AdvancedModule.cs"
#line 476 "AdvancedModule.cs"
                                int* csharp2cuda_temp_301 = &(hull_count);
#line 476 "AdvancedModule.cs"
                                int csharp2cuda_temp_302 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_301));
#line 476 "AdvancedModule.cs"
                                int* csharp2cuda_temp_303 = &((hull)[csharp2cuda_temp_302]);
                                (*(csharp2cuda_temp_303) = index);
#line 477 "AdvancedModule.cs"
                                while (true)
                                {
                                    if (!(((hull_count) >= (3))))
                                        break;
#line 478 "AdvancedModule.cs"
                                    {
#line 479 "AdvancedModule.cs"
                                        int one = (hull)[csharp2cuda_i32_sub(hull_count, 3)];
#line 480 "AdvancedModule.cs"
                                        int middle = (hull)[csharp2cuda_i32_sub(hull_count, 2)];
#line 481 "AdvancedModule.cs"
                                        int last = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
#line 482 "AdvancedModule.cs"
                                        double csharp2cuda_temp_304 = (a)[middle];
#line 482 "AdvancedModule.cs"
                                        double csharp2cuda_temp_305 = (a)[one];
#line 482 "AdvancedModule.cs"
                                        double first_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_304, csharp2cuda_temp_305), ((double)(csharp2cuda_i32_sub(middle, one))));
#line 483 "AdvancedModule.cs"
                                        double csharp2cuda_temp_306 = (a)[last];
#line 483 "AdvancedModule.cs"
                                        double csharp2cuda_temp_307 = (a)[middle];
#line 483 "AdvancedModule.cs"
                                        double second_slope = __ddiv_rn(__dsub_rn(csharp2cuda_temp_306, csharp2cuda_temp_307), ((double)(csharp2cuda_i32_sub(last, middle))));
#line 484 "AdvancedModule.cs"
#line 484 "AdvancedModule.cs"
                                        bool csharp2cuda_temp_308;
#line 484 "AdvancedModule.cs"
                                        if (concave)
                                        {
#line 484 "AdvancedModule.cs"
                                            csharp2cuda_temp_308 = ((first_slope) >= (second_slope));
                                        }
                                        else
                                        {
#line 484 "AdvancedModule.cs"
                                            csharp2cuda_temp_308 = ((first_slope) <= (second_slope));
                                        }
                                        if (csharp2cuda_temp_308)
                                        {
#line 485 "AdvancedModule.cs"
                                            break;
                                        }
#line 486 "AdvancedModule.cs"
#line 486 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_309 = &((hull)[csharp2cuda_i32_sub(hull_count, 2)]);
#line 486 "AdvancedModule.cs"
                                        int csharp2cuda_temp_310 = (hull)[csharp2cuda_i32_sub(hull_count, 1)];
                                        (*(csharp2cuda_temp_309) = csharp2cuda_temp_310);
#line 487 "AdvancedModule.cs"
#line 487 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_311 = &(hull_count);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_311));
                                    }
                                }
                            }
#line 474 "AdvancedModule.cs"
                            int* csharp2cuda_temp_299 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_299));
                        }
                    }
#line 490 "AdvancedModule.cs"
                    {
#line 490 "AdvancedModule.cs"
                        int segment = 1;
                        while (true)
                        {
                            if (!(((segment) < (hull_count))))
                                break;
#line 491 "AdvancedModule.cs"
                            {
#line 492 "AdvancedModule.cs"
                                int start = (hull)[csharp2cuda_i32_sub(segment, 1)];
#line 493 "AdvancedModule.cs"
                                int end = (hull)[segment];
#line 494 "AdvancedModule.cs"
                                {
#line 494 "AdvancedModule.cs"
                                    int index = start;
                                    while (true)
                                    {
                                        if (!(((index) <= (end))))
                                            break;
#line 495 "AdvancedModule.cs"
                                        {
#line 496 "AdvancedModule.cs"
                                            double weight = __ddiv_rn(((double)(csharp2cuda_i32_sub(index, start))), ((double)(csharp2cuda_i32_sub(end, start))));
#line 497 "AdvancedModule.cs"
#line 497 "AdvancedModule.cs"
                                            double* csharp2cuda_temp_314 = &((result)[index]);
#line 497 "AdvancedModule.cs"
                                            double csharp2cuda_temp_315 = (a)[start];
#line 497 "AdvancedModule.cs"
                                            double csharp2cuda_temp_316 = (a)[end];
                                            (*(csharp2cuda_temp_314) = __dadd_rn(__dmul_rn(csharp2cuda_temp_315, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_316, weight)));
                                        }
#line 494 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_313 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_313));
                                    }
                                }
                            }
#line 490 "AdvancedModule.cs"
                            int* csharp2cuda_temp_312 = &(segment);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_312));
                        }
                    }
#line 500 "AdvancedModule.cs"
                    break;
                }
#line 502 "AdvancedModule.cs"
            case 14:
#line 503 "AdvancedModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 504 "AdvancedModule.cs"
                {
#line 505 "AdvancedModule.cs"
#line 505 "AdvancedModule.cs"
                    int* csharp2cuda_temp_317 = &((output)->valid);
                    (*(csharp2cuda_temp_317) = 0);
#line 506 "AdvancedModule.cs"
                    break;
                }
#line 508 "AdvancedModule.cs"
                {
#line 508 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 508 "AdvancedModule.cs"
                        int csharp2cuda_temp_319 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_319))))
                            break;
#line 509 "AdvancedModule.cs"
#line 509 "AdvancedModule.cs"
                        double* csharp2cuda_temp_320 = &((scratch)[index]);
#line 509 "AdvancedModule.cs"
                        double csharp2cuda_temp_321 = (a)[index];
                        (*(csharp2cuda_temp_320) = csharp2cuda_temp_321);
#line 508 "AdvancedModule.cs"
                        int* csharp2cuda_temp_318 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_318));
                    }
                }
#line 510 "AdvancedModule.cs"
#line 510 "AdvancedModule.cs"
                int* csharp2cuda_temp_322 = &((output)->boolean_value);
                (*(csharp2cuda_temp_322) = 1);
#line 511 "AdvancedModule.cs"
                {
#line 511 "AdvancedModule.cs"
                    int order = 0;
#line 511 "AdvancedModule.cs"
                    int length = (first)->count;
                    while (true)
                    {
#line 512 "AdvancedModule.cs"
                        int csharp2cuda_temp_325 = (first)->count;
#line 512 "AdvancedModule.cs"
                        bool csharp2cuda_temp_326;
#line 512 "AdvancedModule.cs"
                        if (((order) < (csharp2cuda_temp_325)))
                        {
#line 512 "AdvancedModule.cs"
                            csharp2cuda_temp_326 = (output)->boolean_value;
                        }
                        else
                        {
#line 512 "AdvancedModule.cs"
                            csharp2cuda_temp_326 = false;
                        }
                        if (!(csharp2cuda_temp_326))
                            break;
#line 514 "AdvancedModule.cs"
                        {
#line 515 "AdvancedModule.cs"
                            double csharp2cuda_temp_327;
#line 515 "AdvancedModule.cs"
                            if (((csharp2cuda_i32_and(order, 1)) == (0)))
                            {
#line 515 "AdvancedModule.cs"
                                csharp2cuda_temp_327 = 1.0;
                            }
                            else
                            {
#line 515 "AdvancedModule.cs"
                                csharp2cuda_temp_327 = (-(1.0));
                            }
#line 515 "AdvancedModule.cs"
                            double sign = csharp2cuda_temp_327;
#line 516 "AdvancedModule.cs"
                            {
#line 516 "AdvancedModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 517 "AdvancedModule.cs"
#line 517 "AdvancedModule.cs"
                                    double csharp2cuda_temp_329 = (scratch)[index];
                                    if (((__dmul_rn(sign, csharp2cuda_temp_329)) < (0.0)))
#line 518 "AdvancedModule.cs"
                                    {
#line 519 "AdvancedModule.cs"
#line 519 "AdvancedModule.cs"
                                        int* csharp2cuda_temp_330 = &((output)->boolean_value);
                                        (*(csharp2cuda_temp_330) = 0);
#line 520 "AdvancedModule.cs"
                                        break;
                                    }
#line 516 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_328 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_328));
                                }
                            }
#line 522 "AdvancedModule.cs"
                            {
#line 522 "AdvancedModule.cs"
                                int index = 1;
                                while (true)
                                {
#line 522 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_332 = (output)->boolean_value;
#line 522 "AdvancedModule.cs"
                                    bool csharp2cuda_temp_333;
#line 522 "AdvancedModule.cs"
                                    if (csharp2cuda_temp_332)
                                    {
#line 522 "AdvancedModule.cs"
                                        csharp2cuda_temp_333 = ((index) < (length));
                                    }
                                    else
                                    {
#line 522 "AdvancedModule.cs"
                                        csharp2cuda_temp_333 = false;
                                    }
                                    if (!(csharp2cuda_temp_333))
                                        break;
#line 523 "AdvancedModule.cs"
#line 523 "AdvancedModule.cs"
                                    double* csharp2cuda_temp_334 = &((scratch)[csharp2cuda_i32_sub(index, 1)]);
#line 523 "AdvancedModule.cs"
                                    double csharp2cuda_temp_335 = (scratch)[index];
#line 523 "AdvancedModule.cs"
                                    double csharp2cuda_temp_336 = (scratch)[csharp2cuda_i32_sub(index, 1)];
                                    (*(csharp2cuda_temp_334) = __dsub_rn(csharp2cuda_temp_335, csharp2cuda_temp_336));
#line 522 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_331 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_331));
                                }
                            }
                        }
#line 513 "AdvancedModule.cs"
                        int* csharp2cuda_temp_323 = &(order);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_323));
#line 513 "AdvancedModule.cs"
                        int* csharp2cuda_temp_324 = &(length);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_324));
                    }
                }
#line 525 "AdvancedModule.cs"
                break;
#line 526 "AdvancedModule.cs"
            case 15:
#line 527 "AdvancedModule.cs"
#line 527 "AdvancedModule.cs"
                int* csharp2cuda_temp_337 = &((output)->boolean_value);
                (*(csharp2cuda_temp_337) = 1);
#line 528 "AdvancedModule.cs"
                {
#line 528 "AdvancedModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 528 "AdvancedModule.cs"
                        int csharp2cuda_temp_339 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_339))))
                            break;
#line 529 "AdvancedModule.cs"
#line 529 "AdvancedModule.cs"
                        double csharp2cuda_temp_340 = (a)[index];
                        if (((csharp2cuda_temp_340) < (0.0)))
                        {
#line 529 "AdvancedModule.cs"
#line 529 "AdvancedModule.cs"
                            int* csharp2cuda_temp_341 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_341) = 0);
                        }
#line 528 "AdvancedModule.cs"
                        int* csharp2cuda_temp_338 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_338));
                    }
                }
#line 530 "AdvancedModule.cs"
                {
#line 530 "AdvancedModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 530 "AdvancedModule.cs"
                        bool csharp2cuda_temp_343 = (output)->boolean_value;
#line 530 "AdvancedModule.cs"
                        bool csharp2cuda_temp_344;
#line 530 "AdvancedModule.cs"
                        if (csharp2cuda_temp_343)
                        {
#line 530 "AdvancedModule.cs"
                            int csharp2cuda_temp_345 = (first)->count;
#line 530 "AdvancedModule.cs"
                            csharp2cuda_temp_344 = ((index) < (csharp2cuda_i32_sub(csharp2cuda_temp_345, 1)));
                        }
                        else
                        {
#line 530 "AdvancedModule.cs"
                            csharp2cuda_temp_344 = false;
                        }
                        if (!(csharp2cuda_temp_344))
                            break;
#line 531 "AdvancedModule.cs"
#line 531 "AdvancedModule.cs"
                        double csharp2cuda_temp_346 = (a)[index];
#line 531 "AdvancedModule.cs"
                        double csharp2cuda_temp_347 = (a)[index];
#line 531 "AdvancedModule.cs"
                        double csharp2cuda_temp_348 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 531 "AdvancedModule.cs"
                        double csharp2cuda_temp_349 = (a)[csharp2cuda_i32_add(index, 1)];
                        if (((__dmul_rn(csharp2cuda_temp_346, csharp2cuda_temp_347)) < (__dmul_rn(csharp2cuda_temp_348, csharp2cuda_temp_349))))
                        {
#line 532 "AdvancedModule.cs"
#line 532 "AdvancedModule.cs"
                            int* csharp2cuda_temp_350 = &((output)->boolean_value);
                            (*(csharp2cuda_temp_350) = 0);
                        }
#line 530 "AdvancedModule.cs"
                        int* csharp2cuda_temp_342 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_342));
                    }
                }
#line 533 "AdvancedModule.cs"
                break;
#line 534 "AdvancedModule.cs"
            case 17:
#line 535 "AdvancedModule.cs"
#line 535 "AdvancedModule.cs"
                int csharp2cuda_temp_351 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_351);
#line 536 "AdvancedModule.cs"
#line 536 "AdvancedModule.cs"
                int csharp2cuda_temp_352 = (first)->count;
#line 536 "AdvancedModule.cs"
                bool csharp2cuda_temp_353 = mathblocks_advanced_distribution(a, csharp2cuda_temp_352);
                if ((!(csharp2cuda_temp_353)))
#line 537 "AdvancedModule.cs"
                {
#line 538 "AdvancedModule.cs"
#line 538 "AdvancedModule.cs"
                    int* csharp2cuda_temp_354 = &((output)->valid);
                    (*(csharp2cuda_temp_354) = 0);
#line 539 "AdvancedModule.cs"
                    break;
                }
#line 541 "AdvancedModule.cs"
                {
#line 542 "AdvancedModule.cs"
                    double survival = 1.0;
#line 543 "AdvancedModule.cs"
                    {
#line 543 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 543 "AdvancedModule.cs"
                            int csharp2cuda_temp_356 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_356))))
                                break;
#line 544 "AdvancedModule.cs"
                            {
#line 545 "AdvancedModule.cs"
#line 545 "AdvancedModule.cs"
                                double* csharp2cuda_temp_357 = &((result)[index]);
#line 545 "AdvancedModule.cs"
                                double csharp2cuda_temp_358 = (a)[index];
#line 545 "AdvancedModule.cs"
                                double csharp2cuda_temp_359 = __ddiv_rn(csharp2cuda_temp_358, survival);
                                (*(csharp2cuda_temp_357) = csharp2cuda_temp_359);
#line 546 "AdvancedModule.cs"
#line 546 "AdvancedModule.cs"
                                double* csharp2cuda_temp_360 = &(survival);
#line 546 "AdvancedModule.cs"
                                double csharp2cuda_temp_361 = *(csharp2cuda_temp_360);
#line 546 "AdvancedModule.cs"
                                double csharp2cuda_temp_362 = (a)[index];
                                (*(csharp2cuda_temp_360) = __dsub_rn(csharp2cuda_temp_361, csharp2cuda_temp_362));
                            }
#line 543 "AdvancedModule.cs"
                            int* csharp2cuda_temp_355 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_355));
                        }
                    }
#line 548 "AdvancedModule.cs"
                    break;
                }
#line 550 "AdvancedModule.cs"
            case 18:
#line 551 "AdvancedModule.cs"
#line 551 "AdvancedModule.cs"
                int csharp2cuda_temp_363 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_363);
#line 552 "AdvancedModule.cs"
#line 552 "AdvancedModule.cs"
                int csharp2cuda_temp_364 = (first)->count;
#line 552 "AdvancedModule.cs"
                int csharp2cuda_temp_365 = (second)->count;
                if (((csharp2cuda_temp_364) != (csharp2cuda_temp_365)))
#line 553 "AdvancedModule.cs"
                {
#line 554 "AdvancedModule.cs"
#line 554 "AdvancedModule.cs"
                    int* csharp2cuda_temp_366 = &((output)->valid);
                    (*(csharp2cuda_temp_366) = 0);
#line 555 "AdvancedModule.cs"
                    break;
                }
#line 557 "AdvancedModule.cs"
                {
#line 558 "AdvancedModule.cs"
                    double survival = 1.0;
#line 559 "AdvancedModule.cs"
                    {
#line 559 "AdvancedModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 559 "AdvancedModule.cs"
                            int csharp2cuda_temp_368 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_368))))
                                break;
#line 560 "AdvancedModule.cs"
                            {
#line 561 "AdvancedModule.cs"
#line 561 "AdvancedModule.cs"
                                double csharp2cuda_temp_369 = (a)[index];
#line 561 "AdvancedModule.cs"
                                bool csharp2cuda_temp_370;
#line 561 "AdvancedModule.cs"
                                if (!(((csharp2cuda_temp_369) < (0.0))))
                                {
#line 561 "AdvancedModule.cs"
                                    double csharp2cuda_temp_371 = (b)[index];
#line 561 "AdvancedModule.cs"
                                    csharp2cuda_temp_370 = ((csharp2cuda_temp_371) <= (0.0));
                                }
                                else
                                {
#line 561 "AdvancedModule.cs"
                                    csharp2cuda_temp_370 = true;
                                }
#line 561 "AdvancedModule.cs"
                                bool csharp2cuda_temp_372;
#line 561 "AdvancedModule.cs"
                                if (!(csharp2cuda_temp_370))
                                {
#line 561 "AdvancedModule.cs"
                                    double csharp2cuda_temp_373 = (a)[index];
#line 561 "AdvancedModule.cs"
                                    double csharp2cuda_temp_374 = (b)[index];
#line 561 "AdvancedModule.cs"
                                    csharp2cuda_temp_372 = ((csharp2cuda_temp_373) > (csharp2cuda_temp_374));
                                }
                                else
                                {
#line 561 "AdvancedModule.cs"
                                    csharp2cuda_temp_372 = true;
                                }
                                if (csharp2cuda_temp_372)
#line 562 "AdvancedModule.cs"
                                {
#line 563 "AdvancedModule.cs"
#line 563 "AdvancedModule.cs"
                                    int* csharp2cuda_temp_375 = &((output)->valid);
                                    (*(csharp2cuda_temp_375) = 0);
#line 564 "AdvancedModule.cs"
                                    break;
                                }
#line 566 "AdvancedModule.cs"
#line 566 "AdvancedModule.cs"
                                double* csharp2cuda_temp_376 = &(survival);
#line 566 "AdvancedModule.cs"
                                double csharp2cuda_temp_377 = *(csharp2cuda_temp_376);
#line 566 "AdvancedModule.cs"
                                double csharp2cuda_temp_378 = (a)[index];
#line 566 "AdvancedModule.cs"
                                double csharp2cuda_temp_379 = (b)[index];
#line 566 "AdvancedModule.cs"
                                double csharp2cuda_temp_380 = __ddiv_rn(csharp2cuda_temp_378, csharp2cuda_temp_379);
                                (*(csharp2cuda_temp_376) = __dmul_rn(csharp2cuda_temp_377, __dsub_rn(1.0, csharp2cuda_temp_380)));
#line 567 "AdvancedModule.cs"
#line 567 "AdvancedModule.cs"
                                double* csharp2cuda_temp_381 = &((result)[index]);
                                (*(csharp2cuda_temp_381) = survival);
                            }
#line 559 "AdvancedModule.cs"
                            int* csharp2cuda_temp_367 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_367));
                        }
                    }
#line 569 "AdvancedModule.cs"
                    break;
                }
        }
#line 573 "AdvancedModule.cs"
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_382 = (output)->valid;
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_383;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_382)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_383 = ((opcode) != (1));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_383 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_384;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_383)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_384 = ((opcode) != (2));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_384 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_385;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_384)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_385 = ((opcode) != (3));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_385 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_386;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_385)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_386 = ((opcode) != (4));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_386 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_387;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_386)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_387 = ((opcode) != (5));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_387 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_388;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_387)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_388 = ((opcode) != (7));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_388 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_389;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_388)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_389 = ((opcode) != (9));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_389 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_390;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_389)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_390 = ((opcode) != (10));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_390 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_391;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_390)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_391 = ((opcode) != (11));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_391 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_392;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_391)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_392 = ((opcode) != (13));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_392 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_393;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_392)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_393 = ((opcode) != (14));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_393 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_394;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_393)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_394 = ((opcode) != (15));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_394 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_395;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_394)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_395 = ((opcode) != (16));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_395 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_396;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_395)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_396 = ((opcode) != (17));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_396 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_397;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_396)
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_397 = ((opcode) != (18));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_397 = false;
        }
#line 573 "AdvancedModule.cs"
        bool csharp2cuda_temp_398;
#line 573 "AdvancedModule.cs"
        if (csharp2cuda_temp_397)
        {
#line 577 "AdvancedModule.cs"
            double csharp2cuda_temp_399 = (output)->scalar_value;
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_398 = (!(isfinite(csharp2cuda_temp_399)));
        }
        else
        {
#line 573 "AdvancedModule.cs"
            csharp2cuda_temp_398 = false;
        }
        if (csharp2cuda_temp_398)
#line 578 "AdvancedModule.cs"
        {
#line 579 "AdvancedModule.cs"
#line 579 "AdvancedModule.cs"
            int* csharp2cuda_temp_400 = &((output)->valid);
            (*(csharp2cuda_temp_400) = 0);
        }
#line 581 "AdvancedModule.cs"
#line 581 "AdvancedModule.cs"
        bool csharp2cuda_temp_401 = (output)->valid;
#line 581 "AdvancedModule.cs"
        bool csharp2cuda_temp_402;
#line 581 "AdvancedModule.cs"
        if (csharp2cuda_temp_401)
        {
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_403;
#line 582 "AdvancedModule.cs"
            if (!(((opcode) == (2))))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_403 = ((opcode) == (3));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_403 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_404;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_403))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_404 = ((opcode) == (4));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_404 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_405;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_404))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_405 = ((opcode) == (5));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_405 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_406;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_405))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_406 = ((opcode) == (7));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_406 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_407;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_406))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_407 = ((opcode) == (9));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_407 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_408;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_407))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_408 = ((opcode) == (10));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_408 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_409;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_408))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_409 = ((opcode) == (13));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_409 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_410;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_409))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_410 = ((opcode) == (16));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_410 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_411;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_410))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_411 = ((opcode) == (17));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_411 = true;
            }
#line 582 "AdvancedModule.cs"
            bool csharp2cuda_temp_412;
#line 582 "AdvancedModule.cs"
            if (!(csharp2cuda_temp_411))
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_412 = ((opcode) == (18));
            }
            else
            {
#line 582 "AdvancedModule.cs"
                csharp2cuda_temp_412 = true;
            }
#line 581 "AdvancedModule.cs"
            csharp2cuda_temp_402 = csharp2cuda_temp_412;
        }
        else
        {
#line 581 "AdvancedModule.cs"
            csharp2cuda_temp_402 = false;
        }
        if (csharp2cuda_temp_402)
#line 585 "AdvancedModule.cs"
        {
#line 586 "AdvancedModule.cs"
            {
#line 586 "AdvancedModule.cs"
                int index = 0;
                while (true)
                {
#line 586 "AdvancedModule.cs"
                    int csharp2cuda_temp_414 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_414))))
                        break;
#line 587 "AdvancedModule.cs"
#line 587 "AdvancedModule.cs"
                    double csharp2cuda_temp_415 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_415))))
                    {
#line 587 "AdvancedModule.cs"
#line 587 "AdvancedModule.cs"
                        int* csharp2cuda_temp_416 = &((output)->valid);
                        (*(csharp2cuda_temp_416) = 0);
                    }
#line 586 "AdvancedModule.cs"
                    int* csharp2cuda_temp_413 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_413));
                }
            }
        }
    }
}

#line 79 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_distribution(const double* values, int count)
#line 81 "AdvancedModule.cs"
{
#line 82 "AdvancedModule.cs"
    return mathblocks_probability_distribution(values, count);
}

#line 70 "AdvancedModule.cs"
__device__ double mathblocks_advanced_factorial(int value)
#line 72 "AdvancedModule.cs"
{
#line 73 "AdvancedModule.cs"
    double result = 1.0;
#line 74 "AdvancedModule.cs"
    {
#line 74 "AdvancedModule.cs"
        int index = 2;
        while (true)
        {
            if (!(((index) <= (value))))
                break;
#line 75 "AdvancedModule.cs"
#line 75 "AdvancedModule.cs"
            double* csharp2cuda_temp_1 = &(result);
#line 75 "AdvancedModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
            (*(csharp2cuda_temp_1) = __dmul_rn(csharp2cuda_temp_2, ((double)(index))));
#line 74 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 76 "AdvancedModule.cs"
    return result;
}

#line 46 "AdvancedModule.cs"
__device__ int mathblocks_advanced_log_two(int value)
#line 48 "AdvancedModule.cs"
{
#line 49 "AdvancedModule.cs"
    int result = 0;
#line 50 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) > (1))))
            break;
#line 51 "AdvancedModule.cs"
        {
#line 52 "AdvancedModule.cs"
#line 52 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(value);
#line 52 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_shr(csharp2cuda_temp_1, 1));
#line 53 "AdvancedModule.cs"
#line 53 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(result);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 55 "AdvancedModule.cs"
    return result;
}

#line 58 "AdvancedModule.cs"
__device__ int mathblocks_advanced_popcount(int value)
#line 60 "AdvancedModule.cs"
{
#line 61 "AdvancedModule.cs"
    int result = 0;
#line 62 "AdvancedModule.cs"
    while (true)
    {
        if (!(((value) != (0))))
            break;
#line 63 "AdvancedModule.cs"
        {
#line 64 "AdvancedModule.cs"
#line 64 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(result);
#line 64 "AdvancedModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, csharp2cuda_i32_and(value, 1)));
#line 65 "AdvancedModule.cs"
#line 65 "AdvancedModule.cs"
            int* csharp2cuda_temp_2 = &(value);
#line 65 "AdvancedModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_shr(csharp2cuda_temp_3, 1));
        }
    }
#line 67 "AdvancedModule.cs"
    return result;
}

#line 40 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_power_of_two(int value)
#line 42 "AdvancedModule.cs"
{
#line 43 "AdvancedModule.cs"
#line 43 "AdvancedModule.cs"
    bool csharp2cuda_temp_0;
#line 43 "AdvancedModule.cs"
    if (((value) > (0)))
    {
#line 43 "AdvancedModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 43 "AdvancedModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 109 "AdvancedModule.cs"
__device__ void mathblocks_advanced_sort_descending(
    const double* values,
    int count,
    double* result)
#line 114 "AdvancedModule.cs"
{
#line 115 "AdvancedModule.cs"
    {
#line 115 "AdvancedModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 116 "AdvancedModule.cs"
            {
#line 117 "AdvancedModule.cs"
                double value = (values)[index];
#line 118 "AdvancedModule.cs"
                int position = index;
#line 119 "AdvancedModule.cs"
                while (true)
                {
#line 119 "AdvancedModule.cs"
                    bool csharp2cuda_temp_1;
#line 119 "AdvancedModule.cs"
                    if (((position) > (0)))
                    {
#line 119 "AdvancedModule.cs"
                        double csharp2cuda_temp_2 = (result)[csharp2cuda_i32_sub(position, 1)];
#line 119 "AdvancedModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) < (value));
                    }
                    else
                    {
#line 119 "AdvancedModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 120 "AdvancedModule.cs"
                    {
#line 121 "AdvancedModule.cs"
#line 121 "AdvancedModule.cs"
                        double* csharp2cuda_temp_3 = &((result)[position]);
#line 121 "AdvancedModule.cs"
                        double csharp2cuda_temp_4 = (result)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 122 "AdvancedModule.cs"
#line 122 "AdvancedModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 124 "AdvancedModule.cs"
#line 124 "AdvancedModule.cs"
                double* csharp2cuda_temp_6 = &((result)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 115 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 85 "AdvancedModule.cs"
__device__ bool mathblocks_advanced_transition(
    const double* values,
    int rows,
    int columns)
#line 90 "AdvancedModule.cs"
{
#line 91 "AdvancedModule.cs"
    if (((rows) != (columns)))
    {
#line 92 "AdvancedModule.cs"
        return false;
    }
#line 93 "AdvancedModule.cs"
    {
#line 93 "AdvancedModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (rows))))
                break;
#line 94 "AdvancedModule.cs"
            {
#line 95 "AdvancedModule.cs"
                double sum = 0.0;
#line 96 "AdvancedModule.cs"
                {
#line 96 "AdvancedModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (columns))))
                            break;
#line 97 "AdvancedModule.cs"
                        {
#line 98 "AdvancedModule.cs"
                            double value = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 99 "AdvancedModule.cs"
                            if (((value) < (0.0)))
                            {
#line 100 "AdvancedModule.cs"
                                return false;
                            }
#line 101 "AdvancedModule.cs"
#line 101 "AdvancedModule.cs"
                            double* csharp2cuda_temp_2 = &(sum);
#line 101 "AdvancedModule.cs"
                            double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                            (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, value));
                        }
#line 96 "AdvancedModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 103 "AdvancedModule.cs"
                if (((fabs(__dsub_rn(sum, 1.0))) > (1E-10)))
                {
#line 104 "AdvancedModule.cs"
                    return false;
                }
            }
#line 93 "AdvancedModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 106 "AdvancedModule.cs"
    return true;
}