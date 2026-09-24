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

struct MathBlockComplexValue;

#line 41 "ComplexModule.cs"
struct MathBlockComplexValue
{
    double real;
    double imaginary;
};

#line 56 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_add(
    MathBlockComplexValue left,
    MathBlockComplexValue right);

#line 93 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_conjugate(MathBlockComplexValue value);

#line 183 "ComplexModule.cs"
__device__ void mathblocks_complex_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 82 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_divide(
    MathBlockComplexValue left,
    MathBlockComplexValue right);

#line 122 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_exponential(MathBlockComplexValue value);

#line 167 "ComplexModule.cs"
__device__ bool mathblocks_complex_finite(MathBlockComplexValue value);

#line 159 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_from_polar(double magnitude, double phase);

#line 131 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_logarithm(MathBlockComplexValue value);

#line 99 "ComplexModule.cs"
__device__ double mathblocks_complex_magnitude(MathBlockComplexValue value);

#line 47 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_make(double real, double imaginary);

#line 72 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_multiply(
    MathBlockComplexValue left,
    MathBlockComplexValue right);

#line 116 "ComplexModule.cs"
__device__ double mathblocks_complex_phase(MathBlockComplexValue value);

#line 150 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_power(
    MathBlockComplexValue value,
    MathBlockComplexValue exponent);

#line 173 "ComplexModule.cs"
__device__ void mathblocks_complex_shape(MathBlockSlot* output, int count);

#line 139 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_square_root(MathBlockComplexValue value);

#line 64 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_subtract(
    MathBlockComplexValue left,
    MathBlockComplexValue right);

#line 56 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_add(
    MathBlockComplexValue left,
    MathBlockComplexValue right)
#line 60 "ComplexModule.cs"
{
#line 61 "ComplexModule.cs"
#line 61 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (left).real;
#line 61 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (right).real;
#line 61 "ComplexModule.cs"
    double csharp2cuda_temp_2 = (left).imaginary;
#line 61 "ComplexModule.cs"
    double csharp2cuda_temp_3 = (right).imaginary;
    return mathblocks_complex_make(__dadd_rn(csharp2cuda_temp_0, csharp2cuda_temp_1), __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
}

#line 93 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_conjugate(MathBlockComplexValue value)
#line 95 "ComplexModule.cs"
{
#line 96 "ComplexModule.cs"
#line 96 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 96 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (value).imaginary;
    return mathblocks_complex_make(csharp2cuda_temp_0, (-(csharp2cuda_temp_1)));
}

#line 183 "ComplexModule.cs"
__device__ void mathblocks_complex_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 189 "ComplexModule.cs"
{
#line 190 "ComplexModule.cs"
    int thread = threadIdx.x;
#line 191 "ComplexModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 191 "ComplexModule.cs"
    if (((input_count) > (0)))
    {
#line 191 "ComplexModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 191 "ComplexModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 191 "ComplexModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 192 "ComplexModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 192 "ComplexModule.cs"
    if (((input_count) > (1)))
    {
#line 192 "ComplexModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 192 "ComplexModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 192 "ComplexModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 193 "ComplexModule.cs"
    if (((thread) == (0)))
#line 194 "ComplexModule.cs"
    {
#line 195 "ComplexModule.cs"
#line 195 "ComplexModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 196 "ComplexModule.cs"
#line 196 "ComplexModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 197 "ComplexModule.cs"
#line 197 "ComplexModule.cs"
        int* csharp2cuda_temp_4 = &((output)->valid);
        (*(csharp2cuda_temp_4) = 1);
#line 198 "ComplexModule.cs"
        {
#line 198 "ComplexModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 199 "ComplexModule.cs"
#line 199 "ComplexModule.cs"
                MathBlockSlot* csharp2cuda_temp_6 = (inputs)[index];
#line 199 "ComplexModule.cs"
                bool csharp2cuda_temp_7;
#line 199 "ComplexModule.cs"
                if (!(((((void*)(csharp2cuda_temp_6))) == (((void*)(nullptr))))))
                {
#line 199 "ComplexModule.cs"
                    MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 199 "ComplexModule.cs"
                    bool csharp2cuda_temp_9 = (csharp2cuda_temp_8)->valid;
#line 199 "ComplexModule.cs"
                    csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
                }
                else
                {
#line 199 "ComplexModule.cs"
                    csharp2cuda_temp_7 = true;
                }
                if (csharp2cuda_temp_7)
                {
#line 199 "ComplexModule.cs"
#line 199 "ComplexModule.cs"
                    int* csharp2cuda_temp_10 = &((output)->valid);
                    (*(csharp2cuda_temp_10) = 0);
                }
#line 198 "ComplexModule.cs"
                int* csharp2cuda_temp_5 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
            }
        }
    }
#line 201 "ComplexModule.cs"
    __syncthreads();
#line 202 "ComplexModule.cs"
#line 202 "ComplexModule.cs"
    bool csharp2cuda_temp_11 = (output)->valid;
    if ((!(csharp2cuda_temp_11)))
    {
#line 203 "ComplexModule.cs"
        return;
    }
#line 205 "ComplexModule.cs"
    unsigned long long csharp2cuda_temp_12 = (output)->data_pointer;
#line 205 "ComplexModule.cs"
    MathBlockComplexValue* result = ((MathBlockComplexValue*)(csharp2cuda_temp_12));
#line 207 "ComplexModule.cs"
    MathBlockComplexValue* csharp2cuda_temp_13;
#line 207 "ComplexModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 207 "ComplexModule.cs"
        csharp2cuda_temp_13 = ((MathBlockComplexValue*)(nullptr));
    }
    else
    {
#line 207 "ComplexModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 207 "ComplexModule.cs"
        csharp2cuda_temp_13 = ((MathBlockComplexValue*)(csharp2cuda_temp_14));
    }
#line 206 "ComplexModule.cs"
    const MathBlockComplexValue* complex_first = csharp2cuda_temp_13;
#line 209 "ComplexModule.cs"
    MathBlockComplexValue* csharp2cuda_temp_15;
#line 209 "ComplexModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 209 "ComplexModule.cs"
        csharp2cuda_temp_15 = ((MathBlockComplexValue*)(nullptr));
    }
    else
    {
#line 209 "ComplexModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 209 "ComplexModule.cs"
        csharp2cuda_temp_15 = ((MathBlockComplexValue*)(csharp2cuda_temp_16));
    }
#line 208 "ComplexModule.cs"
    const MathBlockComplexValue* complex_second = csharp2cuda_temp_15;
#line 211 "ComplexModule.cs"
    if (((opcode) <= (13)))
#line 212 "ComplexModule.cs"
    {
#line 213 "ComplexModule.cs"
        if (((thread) != (0)))
        {
#line 214 "ComplexModule.cs"
            return;
        }
#line 215 "ComplexModule.cs"
        MathBlockComplexValue value = mathblocks_complex_make(0.0, 0.0);
#line 216 "ComplexModule.cs"
        switch (opcode)
        {
#line 218 "ComplexModule.cs"
            case 0:
#line 219 "ComplexModule.cs"
#line 219 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_17 = &(value);
#line 219 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_18 = (complex_first)[0];
#line 219 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_19 = (complex_second)[0];
                (*(csharp2cuda_temp_17) = mathblocks_complex_add(csharp2cuda_temp_18, csharp2cuda_temp_19));
#line 220 "ComplexModule.cs"
                break;
#line 221 "ComplexModule.cs"
            case 1:
#line 222 "ComplexModule.cs"
#line 222 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_20 = &(value);
#line 222 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_21 = (complex_first)[0];
                (*(csharp2cuda_temp_20) = mathblocks_complex_conjugate(csharp2cuda_temp_21));
#line 223 "ComplexModule.cs"
                break;
#line 224 "ComplexModule.cs"
            case 2:
#line 225 "ComplexModule.cs"
#line 225 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_22 = &(value);
#line 225 "ComplexModule.cs"
                double csharp2cuda_temp_23 = (first)->scalar_value;
#line 225 "ComplexModule.cs"
                double csharp2cuda_temp_24 = (second)->scalar_value;
                (*(csharp2cuda_temp_22) = mathblocks_complex_make(csharp2cuda_temp_23, csharp2cuda_temp_24));
#line 226 "ComplexModule.cs"
                break;
#line 227 "ComplexModule.cs"
            case 3:
#line 228 "ComplexModule.cs"
#line 228 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_25 = &(value);
#line 228 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_26 = (complex_first)[0];
#line 228 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_27 = (complex_second)[0];
                (*(csharp2cuda_temp_25) = mathblocks_complex_divide(csharp2cuda_temp_26, csharp2cuda_temp_27));
#line 229 "ComplexModule.cs"
                break;
#line 230 "ComplexModule.cs"
            case 4:
#line 231 "ComplexModule.cs"
#line 231 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_28 = &(value);
#line 231 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_29 = (complex_first)[0];
                (*(csharp2cuda_temp_28) = mathblocks_complex_exponential(csharp2cuda_temp_29));
#line 232 "ComplexModule.cs"
                break;
#line 233 "ComplexModule.cs"
            case 5:
#line 234 "ComplexModule.cs"
#line 234 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_30 = &(value);
#line 234 "ComplexModule.cs"
                double csharp2cuda_temp_31 = (first)->scalar_value;
#line 234 "ComplexModule.cs"
                double csharp2cuda_temp_32 = (second)->scalar_value;
                (*(csharp2cuda_temp_30) = mathblocks_complex_from_polar(csharp2cuda_temp_31, csharp2cuda_temp_32));
#line 235 "ComplexModule.cs"
                break;
#line 236 "ComplexModule.cs"
            case 6:
#line 237 "ComplexModule.cs"
#line 237 "ComplexModule.cs"
                double* csharp2cuda_temp_33 = &((output)->scalar_value);
#line 237 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_34 = (complex_first)[0];
                (*(csharp2cuda_temp_33) = mathblocks_complex_magnitude(csharp2cuda_temp_34));
#line 238 "ComplexModule.cs"
#line 238 "ComplexModule.cs"
                int* csharp2cuda_temp_35 = &((output)->count);
                (*(csharp2cuda_temp_35) = 0);
#line 239 "ComplexModule.cs"
                return;
#line 240 "ComplexModule.cs"
            case 7:
#line 241 "ComplexModule.cs"
#line 241 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_36 = &(value);
#line 241 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_37 = (complex_first)[0];
#line 241 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_38 = (complex_second)[0];
                (*(csharp2cuda_temp_36) = mathblocks_complex_multiply(csharp2cuda_temp_37, csharp2cuda_temp_38));
#line 242 "ComplexModule.cs"
                break;
#line 243 "ComplexModule.cs"
            case 8:
#line 244 "ComplexModule.cs"
#line 244 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_39 = &(value);
#line 244 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_40 = (complex_first)[0];
                (*(csharp2cuda_temp_39) = mathblocks_complex_logarithm(csharp2cuda_temp_40));
#line 245 "ComplexModule.cs"
                break;
#line 246 "ComplexModule.cs"
            case 9:
#line 247 "ComplexModule.cs"
#line 247 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_41 = &(value);
#line 247 "ComplexModule.cs"
                double csharp2cuda_temp_42 = ((complex_first)[0]).real;
#line 247 "ComplexModule.cs"
                double csharp2cuda_temp_43 = ((complex_first)[0]).imaginary;
                (*(csharp2cuda_temp_41) = mathblocks_complex_make((-(csharp2cuda_temp_42)), (-(csharp2cuda_temp_43))));
#line 248 "ComplexModule.cs"
                break;
#line 249 "ComplexModule.cs"
            case 10:
#line 250 "ComplexModule.cs"
#line 250 "ComplexModule.cs"
                double* csharp2cuda_temp_44 = &((output)->scalar_value);
#line 250 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_45 = (complex_first)[0];
                (*(csharp2cuda_temp_44) = mathblocks_complex_phase(csharp2cuda_temp_45));
#line 251 "ComplexModule.cs"
#line 251 "ComplexModule.cs"
                int* csharp2cuda_temp_46 = &((output)->count);
                (*(csharp2cuda_temp_46) = 0);
#line 252 "ComplexModule.cs"
                return;
#line 253 "ComplexModule.cs"
            case 11:
#line 254 "ComplexModule.cs"
#line 254 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_47 = &(value);
#line 254 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_48 = (complex_first)[0];
#line 254 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_49 = (complex_second)[0];
                (*(csharp2cuda_temp_47) = mathblocks_complex_power(csharp2cuda_temp_48, csharp2cuda_temp_49));
#line 255 "ComplexModule.cs"
                break;
#line 256 "ComplexModule.cs"
            case 12:
#line 257 "ComplexModule.cs"
#line 257 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_50 = &(value);
#line 257 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_51 = (complex_first)[0];
                (*(csharp2cuda_temp_50) = mathblocks_complex_square_root(csharp2cuda_temp_51));
#line 258 "ComplexModule.cs"
                break;
#line 259 "ComplexModule.cs"
            case 13:
#line 260 "ComplexModule.cs"
#line 260 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_52 = &(value);
#line 260 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_53 = (complex_first)[0];
#line 260 "ComplexModule.cs"
                MathBlockComplexValue csharp2cuda_temp_54 = (complex_second)[0];
                (*(csharp2cuda_temp_52) = mathblocks_complex_subtract(csharp2cuda_temp_53, csharp2cuda_temp_54));
#line 261 "ComplexModule.cs"
                break;
        }
#line 263 "ComplexModule.cs"
#line 263 "ComplexModule.cs"
        int* csharp2cuda_temp_55 = &((output)->rows);
        (*(csharp2cuda_temp_55) = 0);
#line 264 "ComplexModule.cs"
#line 264 "ComplexModule.cs"
        int* csharp2cuda_temp_56 = &((output)->columns);
        (*(csharp2cuda_temp_56) = 0);
#line 265 "ComplexModule.cs"
#line 265 "ComplexModule.cs"
        int* csharp2cuda_temp_57 = &((output)->count);
        (*(csharp2cuda_temp_57) = 1);
#line 266 "ComplexModule.cs"
#line 266 "ComplexModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_58 = &((result)[0]);
        (*(csharp2cuda_temp_58) = value);
#line 267 "ComplexModule.cs"
        if ((!(mathblocks_complex_finite(value))))
        {
#line 267 "ComplexModule.cs"
#line 267 "ComplexModule.cs"
            int* csharp2cuda_temp_59 = &((output)->valid);
            (*(csharp2cuda_temp_59) = 0);
        }
#line 268 "ComplexModule.cs"
        return;
    }
#line 271 "ComplexModule.cs"
    if (((opcode) == (14)))
#line 272 "ComplexModule.cs"
    {
#line 273 "ComplexModule.cs"
        if (((thread) == (0)))
#line 274 "ComplexModule.cs"
        {
#line 275 "ComplexModule.cs"
#line 275 "ComplexModule.cs"
            int csharp2cuda_temp_60 = (first)->count;
            mathblocks_complex_shape(output, csharp2cuda_temp_60);
#line 276 "ComplexModule.cs"
#line 276 "ComplexModule.cs"
            int csharp2cuda_temp_61 = (first)->count;
#line 276 "ComplexModule.cs"
            int csharp2cuda_temp_62 = (second)->count;
            if (((csharp2cuda_temp_61) != (csharp2cuda_temp_62)))
            {
#line 276 "ComplexModule.cs"
#line 276 "ComplexModule.cs"
                int* csharp2cuda_temp_63 = &((output)->valid);
                (*(csharp2cuda_temp_63) = 0);
            }
        }
#line 278 "ComplexModule.cs"
        __syncthreads();
#line 279 "ComplexModule.cs"
        unsigned long long csharp2cuda_temp_64 = (first)->data_pointer;
#line 279 "ComplexModule.cs"
        const double* real = ((double*)(csharp2cuda_temp_64));
#line 280 "ComplexModule.cs"
        unsigned long long csharp2cuda_temp_65 = (second)->data_pointer;
#line 280 "ComplexModule.cs"
        const double* imaginary = ((double*)(csharp2cuda_temp_65));
#line 281 "ComplexModule.cs"
        {
#line 281 "ComplexModule.cs"
            int index = thread;
            while (true)
            {
#line 281 "ComplexModule.cs"
                bool csharp2cuda_temp_68 = (output)->valid;
#line 281 "ComplexModule.cs"
                bool csharp2cuda_temp_69;
#line 281 "ComplexModule.cs"
                if (csharp2cuda_temp_68)
                {
#line 281 "ComplexModule.cs"
                    int csharp2cuda_temp_70 = (first)->count;
#line 281 "ComplexModule.cs"
                    csharp2cuda_temp_69 = ((index) < (csharp2cuda_temp_70));
                }
                else
                {
#line 281 "ComplexModule.cs"
                    csharp2cuda_temp_69 = false;
                }
                if (!(csharp2cuda_temp_69))
                    break;
#line 282 "ComplexModule.cs"
#line 282 "ComplexModule.cs"
                MathBlockComplexValue* csharp2cuda_temp_71 = &((result)[index]);
#line 282 "ComplexModule.cs"
                double csharp2cuda_temp_72 = (real)[index];
#line 282 "ComplexModule.cs"
                double csharp2cuda_temp_73 = (imaginary)[index];
                (*(csharp2cuda_temp_71) = mathblocks_complex_make(csharp2cuda_temp_72, csharp2cuda_temp_73));
#line 281 "ComplexModule.cs"
                int* csharp2cuda_temp_66 = &(index);
#line 281 "ComplexModule.cs"
                int csharp2cuda_temp_67 = *(csharp2cuda_temp_66);
                (*(csharp2cuda_temp_66) = csharp2cuda_i32_add(csharp2cuda_temp_67, blockDim.x));
            }
        }
#line 283 "ComplexModule.cs"
        return;
    }
#line 286 "ComplexModule.cs"
#line 286 "ComplexModule.cs"
    bool csharp2cuda_temp_74;
#line 286 "ComplexModule.cs"
    if (((opcode) >= (15)))
    {
#line 286 "ComplexModule.cs"
        csharp2cuda_temp_74 = ((opcode) <= (17));
    }
    else
    {
#line 286 "ComplexModule.cs"
        csharp2cuda_temp_74 = false;
    }
    if (csharp2cuda_temp_74)
#line 287 "ComplexModule.cs"
    {
#line 288 "ComplexModule.cs"
        if (((thread) == (0)))
        {
#line 288 "ComplexModule.cs"
#line 288 "ComplexModule.cs"
            int csharp2cuda_temp_75 = (first)->count;
            mathblocks_complex_shape(output, csharp2cuda_temp_75);
        }
#line 289 "ComplexModule.cs"
        __syncthreads();
#line 290 "ComplexModule.cs"
        unsigned long long csharp2cuda_temp_76 = (output)->data_pointer;
#line 290 "ComplexModule.cs"
        double* projected = ((double*)(csharp2cuda_temp_76));
#line 291 "ComplexModule.cs"
        {
#line 291 "ComplexModule.cs"
            int index = thread;
            while (true)
            {
#line 291 "ComplexModule.cs"
                bool csharp2cuda_temp_79 = (output)->valid;
#line 291 "ComplexModule.cs"
                bool csharp2cuda_temp_80;
#line 291 "ComplexModule.cs"
                if (csharp2cuda_temp_79)
                {
#line 291 "ComplexModule.cs"
                    int csharp2cuda_temp_81 = (first)->count;
#line 291 "ComplexModule.cs"
                    csharp2cuda_temp_80 = ((index) < (csharp2cuda_temp_81));
                }
                else
                {
#line 291 "ComplexModule.cs"
                    csharp2cuda_temp_80 = false;
                }
                if (!(csharp2cuda_temp_80))
                    break;
#line 292 "ComplexModule.cs"
                {
#line 293 "ComplexModule.cs"
                    if (((opcode) == (15)))
                    {
#line 293 "ComplexModule.cs"
#line 293 "ComplexModule.cs"
                        double* csharp2cuda_temp_82 = &((projected)[index]);
#line 293 "ComplexModule.cs"
                        double csharp2cuda_temp_83 = ((complex_first)[index]).imaginary;
                        (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
                    }
                    else
                    {
#line 294 "ComplexModule.cs"
                        if (((opcode) == (16)))
                        {
#line 294 "ComplexModule.cs"
#line 294 "ComplexModule.cs"
                            double* csharp2cuda_temp_84 = &((projected)[index]);
#line 294 "ComplexModule.cs"
                            MathBlockComplexValue csharp2cuda_temp_85 = (complex_first)[index];
                            (*(csharp2cuda_temp_84) = mathblocks_complex_magnitude(csharp2cuda_temp_85));
                        }
                        else
                        {
#line 295 "ComplexModule.cs"
#line 295 "ComplexModule.cs"
                            double* csharp2cuda_temp_86 = &((projected)[index]);
#line 295 "ComplexModule.cs"
                            double csharp2cuda_temp_87 = ((complex_first)[index]).real;
                            (*(csharp2cuda_temp_86) = csharp2cuda_temp_87);
                        }
                    }
                }
#line 291 "ComplexModule.cs"
                int* csharp2cuda_temp_77 = &(index);
#line 291 "ComplexModule.cs"
                int csharp2cuda_temp_78 = *(csharp2cuda_temp_77);
                (*(csharp2cuda_temp_77) = csharp2cuda_i32_add(csharp2cuda_temp_78, blockDim.x));
            }
        }
#line 297 "ComplexModule.cs"
        return;
    }
#line 300 "ComplexModule.cs"
    if (((opcode) == (18)))
#line 301 "ComplexModule.cs"
    {
#line 302 "ComplexModule.cs"
        int count = (first)->count;
#line 303 "ComplexModule.cs"
        if (((thread) == (0)))
#line 304 "ComplexModule.cs"
        {
#line 305 "ComplexModule.cs"
#line 305 "ComplexModule.cs"
            int* csharp2cuda_temp_88 = &((output)->rows);
            (*(csharp2cuda_temp_88) = count);
#line 306 "ComplexModule.cs"
#line 306 "ComplexModule.cs"
            int* csharp2cuda_temp_89 = &((output)->columns);
            (*(csharp2cuda_temp_89) = count);
#line 307 "ComplexModule.cs"
#line 307 "ComplexModule.cs"
            int* csharp2cuda_temp_90 = &((output)->count);
            (*(csharp2cuda_temp_90) = csharp2cuda_i32_mul(count, count));
#line 308 "ComplexModule.cs"
#line 308 "ComplexModule.cs"
            bool csharp2cuda_temp_91;
#line 308 "ComplexModule.cs"
            if (!(((count) <= (0))))
            {
#line 308 "ComplexModule.cs"
                int csharp2cuda_temp_92 = (second)->count;
#line 308 "ComplexModule.cs"
                csharp2cuda_temp_91 = ((count) != (csharp2cuda_temp_92));
            }
            else
            {
#line 308 "ComplexModule.cs"
                csharp2cuda_temp_91 = true;
            }
#line 308 "ComplexModule.cs"
            bool csharp2cuda_temp_93;
#line 308 "ComplexModule.cs"
            if (!(csharp2cuda_temp_91))
            {
#line 308 "ComplexModule.cs"
                int csharp2cuda_temp_94 = (output)->count;
#line 308 "ComplexModule.cs"
                int csharp2cuda_temp_95 = (output)->capacity;
#line 308 "ComplexModule.cs"
                csharp2cuda_temp_93 = ((csharp2cuda_temp_94) > (csharp2cuda_temp_95));
            }
            else
            {
#line 308 "ComplexModule.cs"
                csharp2cuda_temp_93 = true;
            }
            if (csharp2cuda_temp_93)
            {
#line 309 "ComplexModule.cs"
#line 309 "ComplexModule.cs"
                int* csharp2cuda_temp_96 = &((output)->valid);
                (*(csharp2cuda_temp_96) = 0);
            }
        }
#line 311 "ComplexModule.cs"
        {
#line 311 "ComplexModule.cs"
            int index = thread;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 312 "ComplexModule.cs"
                {
#line 313 "ComplexModule.cs"
#line 313 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_99 = (complex_first)[index];
#line 313 "ComplexModule.cs"
                    bool csharp2cuda_temp_100;
#line 313 "ComplexModule.cs"
                    if (!(((mathblocks_complex_magnitude(csharp2cuda_temp_99)) >= (1.0))))
                    {
#line 314 "ComplexModule.cs"
                        MathBlockComplexValue csharp2cuda_temp_101 = (complex_second)[index];
#line 313 "ComplexModule.cs"
                        csharp2cuda_temp_100 = ((mathblocks_complex_magnitude(csharp2cuda_temp_101)) > (1.0));
                    }
                    else
                    {
#line 313 "ComplexModule.cs"
                        csharp2cuda_temp_100 = true;
                    }
                    if (csharp2cuda_temp_100)
#line 315 "ComplexModule.cs"
                    {
#line 316 "ComplexModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 311 "ComplexModule.cs"
                int* csharp2cuda_temp_97 = &(index);
#line 311 "ComplexModule.cs"
                int csharp2cuda_temp_98 = *(csharp2cuda_temp_97);
                (*(csharp2cuda_temp_97) = csharp2cuda_i32_add(csharp2cuda_temp_98, blockDim.x));
            }
        }
#line 319 "ComplexModule.cs"
        __syncthreads();
#line 320 "ComplexModule.cs"
        {
#line 320 "ComplexModule.cs"
            int flat = thread;
            while (true)
            {
#line 320 "ComplexModule.cs"
                bool csharp2cuda_temp_104 = (output)->valid;
#line 320 "ComplexModule.cs"
                bool csharp2cuda_temp_105;
#line 320 "ComplexModule.cs"
                if (csharp2cuda_temp_104)
                {
#line 320 "ComplexModule.cs"
                    csharp2cuda_temp_105 = ((flat) < (csharp2cuda_i32_mul(count, count)));
                }
                else
                {
#line 320 "ComplexModule.cs"
                    csharp2cuda_temp_105 = false;
                }
                if (!(csharp2cuda_temp_105))
                    break;
#line 321 "ComplexModule.cs"
                {
#line 322 "ComplexModule.cs"
                    int row = csharp2cuda_i32_div(flat, count);
#line 323 "ComplexModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, count));
#line 324 "ComplexModule.cs"
                    MathBlockComplexValue one = mathblocks_complex_make(1.0, 0.0);
#line 328 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_106 = (complex_second)[row];
#line 329 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_107 = (complex_second)[column];
#line 325 "ComplexModule.cs"
                    MathBlockComplexValue numerator = mathblocks_complex_subtract(one, mathblocks_complex_multiply(csharp2cuda_temp_106, mathblocks_complex_conjugate(csharp2cuda_temp_107)));
#line 333 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_108 = (complex_first)[row];
#line 334 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_109 = (complex_first)[column];
#line 330 "ComplexModule.cs"
                    MathBlockComplexValue denominator = mathblocks_complex_subtract(one, mathblocks_complex_multiply(csharp2cuda_temp_108, mathblocks_complex_conjugate(csharp2cuda_temp_109)));
#line 335 "ComplexModule.cs"
#line 335 "ComplexModule.cs"
                    MathBlockComplexValue* csharp2cuda_temp_110 = &((result)[flat]);
                    (*(csharp2cuda_temp_110) = mathblocks_complex_divide(numerator, denominator));
#line 336 "ComplexModule.cs"
#line 336 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_111 = (result)[flat];
                    if ((!(mathblocks_complex_finite(csharp2cuda_temp_111))))
                    {
#line 336 "ComplexModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 320 "ComplexModule.cs"
                int* csharp2cuda_temp_102 = &(flat);
#line 320 "ComplexModule.cs"
                int csharp2cuda_temp_103 = *(csharp2cuda_temp_102);
                (*(csharp2cuda_temp_102) = csharp2cuda_i32_add(csharp2cuda_temp_103, blockDim.x));
            }
        }
#line 338 "ComplexModule.cs"
        return;
    }
#line 341 "ComplexModule.cs"
    if (((opcode) == (19)))
#line 342 "ComplexModule.cs"
    {
#line 343 "ComplexModule.cs"
        if (((thread) == (0)))
#line 344 "ComplexModule.cs"
        {
#line 345 "ComplexModule.cs"
#line 345 "ComplexModule.cs"
            int csharp2cuda_temp_112 = (first)->count;
            mathblocks_complex_shape(output, csharp2cuda_temp_112);
#line 346 "ComplexModule.cs"
#line 346 "ComplexModule.cs"
            int csharp2cuda_temp_113 = (first)->count;
            if (((csharp2cuda_temp_113) <= (0)))
            {
#line 346 "ComplexModule.cs"
#line 346 "ComplexModule.cs"
                int* csharp2cuda_temp_114 = &((output)->valid);
                (*(csharp2cuda_temp_114) = 0);
            }
        }
#line 348 "ComplexModule.cs"
        __syncthreads();
#line 349 "ComplexModule.cs"
        unsigned long long csharp2cuda_temp_115 = (first)->data_pointer;
#line 349 "ComplexModule.cs"
        const double* source = ((double*)(csharp2cuda_temp_115));
#line 350 "ComplexModule.cs"
        {
#line 350 "ComplexModule.cs"
            int frequency = thread;
            while (true)
            {
#line 350 "ComplexModule.cs"
                bool csharp2cuda_temp_118 = (output)->valid;
#line 350 "ComplexModule.cs"
                bool csharp2cuda_temp_119;
#line 350 "ComplexModule.cs"
                if (csharp2cuda_temp_118)
                {
#line 350 "ComplexModule.cs"
                    int csharp2cuda_temp_120 = (first)->count;
#line 350 "ComplexModule.cs"
                    csharp2cuda_temp_119 = ((frequency) < (csharp2cuda_temp_120));
                }
                else
                {
#line 350 "ComplexModule.cs"
                    csharp2cuda_temp_119 = false;
                }
                if (!(csharp2cuda_temp_119))
                    break;
#line 351 "ComplexModule.cs"
                {
#line 352 "ComplexModule.cs"
                    MathBlockComplexValue sum = mathblocks_complex_make(0.0, 0.0);
#line 353 "ComplexModule.cs"
                    {
#line 353 "ComplexModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 353 "ComplexModule.cs"
                            int csharp2cuda_temp_122 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_122))))
                                break;
#line 354 "ComplexModule.cs"
                            {
#line 356 "ComplexModule.cs"
                                int csharp2cuda_temp_123 = (first)->count;
#line 355 "ComplexModule.cs"
                                double angle = __ddiv_rn(__dmul_rn(__dmul_rn(__dmul_rn((-(2.0)), 3.141592653589793), ((double)(frequency))), ((double)(index))), ((double)(csharp2cuda_temp_123)));
#line 357 "ComplexModule.cs"
#line 357 "ComplexModule.cs"
                                MathBlockComplexValue* csharp2cuda_temp_124 = &(sum);
#line 360 "ComplexModule.cs"
                                double csharp2cuda_temp_125 = (source)[index];
                                (*(csharp2cuda_temp_124) = mathblocks_complex_add(sum, mathblocks_complex_multiply(mathblocks_complex_make(csharp2cuda_temp_125, 0.0), mathblocks_complex_from_polar(1.0, angle))));
                            }
#line 353 "ComplexModule.cs"
                            int* csharp2cuda_temp_121 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_121));
                        }
                    }
#line 363 "ComplexModule.cs"
#line 363 "ComplexModule.cs"
                    MathBlockComplexValue* csharp2cuda_temp_126 = &((result)[frequency]);
                    (*(csharp2cuda_temp_126) = sum);
#line 364 "ComplexModule.cs"
                    if ((!(mathblocks_complex_finite(sum))))
                    {
#line 364 "ComplexModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 350 "ComplexModule.cs"
                int* csharp2cuda_temp_116 = &(frequency);
#line 350 "ComplexModule.cs"
                int csharp2cuda_temp_117 = *(csharp2cuda_temp_116);
                (*(csharp2cuda_temp_116) = csharp2cuda_i32_add(csharp2cuda_temp_117, blockDim.x));
            }
        }
#line 366 "ComplexModule.cs"
        return;
    }
#line 369 "ComplexModule.cs"
    if (((opcode) == (20)))
#line 370 "ComplexModule.cs"
    {
#line 371 "ComplexModule.cs"
        if (((thread) == (0)))
#line 372 "ComplexModule.cs"
        {
#line 373 "ComplexModule.cs"
#line 373 "ComplexModule.cs"
            int csharp2cuda_temp_127 = (first)->count;
            mathblocks_complex_shape(output, csharp2cuda_temp_127);
#line 374 "ComplexModule.cs"
#line 374 "ComplexModule.cs"
            int csharp2cuda_temp_128 = (first)->count;
            if (((csharp2cuda_temp_128) <= (0)))
            {
#line 374 "ComplexModule.cs"
#line 374 "ComplexModule.cs"
                int* csharp2cuda_temp_129 = &((output)->valid);
                (*(csharp2cuda_temp_129) = 0);
            }
        }
#line 376 "ComplexModule.cs"
        __syncthreads();
#line 377 "ComplexModule.cs"
        {
#line 377 "ComplexModule.cs"
            int index = thread;
            while (true)
            {
#line 377 "ComplexModule.cs"
                bool csharp2cuda_temp_132 = (output)->valid;
#line 377 "ComplexModule.cs"
                bool csharp2cuda_temp_133;
#line 377 "ComplexModule.cs"
                if (csharp2cuda_temp_132)
                {
#line 377 "ComplexModule.cs"
                    int csharp2cuda_temp_134 = (first)->count;
#line 377 "ComplexModule.cs"
                    csharp2cuda_temp_133 = ((index) < (csharp2cuda_temp_134));
                }
                else
                {
#line 377 "ComplexModule.cs"
                    csharp2cuda_temp_133 = false;
                }
                if (!(csharp2cuda_temp_133))
                    break;
#line 378 "ComplexModule.cs"
                {
#line 379 "ComplexModule.cs"
                    MathBlockComplexValue sum = mathblocks_complex_make(0.0, 0.0);
#line 380 "ComplexModule.cs"
                    {
#line 380 "ComplexModule.cs"
                        int frequency = 0;
                        while (true)
                        {
#line 380 "ComplexModule.cs"
                            int csharp2cuda_temp_136 = (first)->count;
                            if (!(((frequency) < (csharp2cuda_temp_136))))
                                break;
#line 381 "ComplexModule.cs"
                            {
#line 383 "ComplexModule.cs"
                                int csharp2cuda_temp_137 = (first)->count;
#line 382 "ComplexModule.cs"
                                double angle = __ddiv_rn(__dmul_rn(__dmul_rn(__dmul_rn(2.0, 3.141592653589793), ((double)(frequency))), ((double)(index))), ((double)(csharp2cuda_temp_137)));
#line 384 "ComplexModule.cs"
#line 384 "ComplexModule.cs"
                                MathBlockComplexValue* csharp2cuda_temp_138 = &(sum);
#line 387 "ComplexModule.cs"
                                MathBlockComplexValue csharp2cuda_temp_139 = (complex_first)[frequency];
                                (*(csharp2cuda_temp_138) = mathblocks_complex_add(sum, mathblocks_complex_multiply(csharp2cuda_temp_139, mathblocks_complex_from_polar(1.0, angle))));
                            }
#line 380 "ComplexModule.cs"
                            int* csharp2cuda_temp_135 = &(frequency);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_135));
                        }
                    }
#line 390 "ComplexModule.cs"
#line 390 "ComplexModule.cs"
                    MathBlockComplexValue* csharp2cuda_temp_140 = &((result)[index]);
#line 392 "ComplexModule.cs"
                    int csharp2cuda_temp_141 = (first)->count;
                    (*(csharp2cuda_temp_140) = mathblocks_complex_divide(sum, mathblocks_complex_make(((double)(csharp2cuda_temp_141)), 0.0)));
#line 393 "ComplexModule.cs"
#line 393 "ComplexModule.cs"
                    MathBlockComplexValue csharp2cuda_temp_142 = (result)[index];
                    if ((!(mathblocks_complex_finite(csharp2cuda_temp_142))))
                    {
#line 393 "ComplexModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 377 "ComplexModule.cs"
                int* csharp2cuda_temp_130 = &(index);
#line 377 "ComplexModule.cs"
                int csharp2cuda_temp_131 = *(csharp2cuda_temp_130);
                (*(csharp2cuda_temp_130) = csharp2cuda_i32_add(csharp2cuda_temp_131, blockDim.x));
            }
        }
    }
}

#line 82 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_divide(
    MathBlockComplexValue left,
    MathBlockComplexValue right)
#line 86 "ComplexModule.cs"
{
#line 87 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (right).real;
#line 87 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (right).real;
#line 87 "ComplexModule.cs"
    double csharp2cuda_temp_2 = (right).imaginary;
#line 87 "ComplexModule.cs"
    double csharp2cuda_temp_3 = (right).imaginary;
#line 87 "ComplexModule.cs"
    double denominator = __dadd_rn(__dmul_rn(csharp2cuda_temp_0, csharp2cuda_temp_1), __dmul_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 88 "ComplexModule.cs"
#line 89 "ComplexModule.cs"
    double csharp2cuda_temp_4 = (left).real;
#line 89 "ComplexModule.cs"
    double csharp2cuda_temp_5 = (right).real;
#line 89 "ComplexModule.cs"
    double csharp2cuda_temp_6 = (left).imaginary;
#line 89 "ComplexModule.cs"
    double csharp2cuda_temp_7 = (right).imaginary;
#line 89 "ComplexModule.cs"
    double csharp2cuda_temp_8 = __ddiv_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), __dmul_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)), denominator);
#line 90 "ComplexModule.cs"
    double csharp2cuda_temp_9 = (left).imaginary;
#line 90 "ComplexModule.cs"
    double csharp2cuda_temp_10 = (right).real;
#line 90 "ComplexModule.cs"
    double csharp2cuda_temp_11 = (left).real;
#line 90 "ComplexModule.cs"
    double csharp2cuda_temp_12 = (right).imaginary;
#line 90 "ComplexModule.cs"
    double csharp2cuda_temp_13 = __ddiv_rn(__dsub_rn(__dmul_rn(csharp2cuda_temp_9, csharp2cuda_temp_10), __dmul_rn(csharp2cuda_temp_11, csharp2cuda_temp_12)), denominator);
    return mathblocks_complex_make(csharp2cuda_temp_8, csharp2cuda_temp_13);
}

#line 122 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_exponential(MathBlockComplexValue value)
#line 124 "ComplexModule.cs"
{
#line 125 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 125 "ComplexModule.cs"
    double scale = mathblocks_exponential(csharp2cuda_temp_0);
#line 126 "ComplexModule.cs"
#line 127 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (value).imaginary;
#line 128 "ComplexModule.cs"
    double csharp2cuda_temp_2 = (value).imaginary;
    return mathblocks_complex_make(__dmul_rn(scale, mathblocks_cosine(csharp2cuda_temp_1)), __dmul_rn(scale, mathblocks_sine(csharp2cuda_temp_2)));
}

#line 167 "ComplexModule.cs"
__device__ bool mathblocks_complex_finite(MathBlockComplexValue value)
#line 169 "ComplexModule.cs"
{
#line 170 "ComplexModule.cs"
#line 170 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 170 "ComplexModule.cs"
    bool csharp2cuda_temp_1;
#line 170 "ComplexModule.cs"
    if (isfinite(csharp2cuda_temp_0))
    {
#line 170 "ComplexModule.cs"
        double csharp2cuda_temp_2 = (value).imaginary;
#line 170 "ComplexModule.cs"
        csharp2cuda_temp_1 = isfinite(csharp2cuda_temp_2);
    }
    else
    {
#line 170 "ComplexModule.cs"
        csharp2cuda_temp_1 = false;
    }
    return csharp2cuda_temp_1;
}

#line 159 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_from_polar(double magnitude, double phase)
#line 161 "ComplexModule.cs"
{
#line 162 "ComplexModule.cs"
    return mathblocks_complex_make(__dmul_rn(magnitude, mathblocks_cosine(phase)), __dmul_rn(magnitude, mathblocks_sine(phase)));
}

#line 131 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_logarithm(MathBlockComplexValue value)
#line 133 "ComplexModule.cs"
{
#line 134 "ComplexModule.cs"
    return mathblocks_complex_make(mathblocks_natural_logarithm(mathblocks_complex_magnitude(value)), mathblocks_complex_phase(value));
}

#line 99 "ComplexModule.cs"
__device__ double mathblocks_complex_magnitude(MathBlockComplexValue value)
#line 101 "ComplexModule.cs"
{
#line 102 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 102 "ComplexModule.cs"
    double real = fabs(csharp2cuda_temp_0);
#line 103 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (value).imaginary;
#line 103 "ComplexModule.cs"
    double imaginary = fabs(csharp2cuda_temp_1);
#line 104 "ComplexModule.cs"
    if (((real) < (imaginary)))
#line 105 "ComplexModule.cs"
    {
#line 106 "ComplexModule.cs"
        double temporary = real;
#line 107 "ComplexModule.cs"
#line 107 "ComplexModule.cs"
        double* csharp2cuda_temp_2 = &(real);
        (*(csharp2cuda_temp_2) = imaginary);
#line 108 "ComplexModule.cs"
#line 108 "ComplexModule.cs"
        double* csharp2cuda_temp_3 = &(imaginary);
        (*(csharp2cuda_temp_3) = temporary);
    }
#line 110 "ComplexModule.cs"
    if (((real) == (0.0)))
    {
#line 111 "ComplexModule.cs"
        return 0.0;
    }
#line 112 "ComplexModule.cs"
    double ratio = __ddiv_rn(imaginary, real);
#line 113 "ComplexModule.cs"
    return __dmul_rn(real, mathblocks_square_root(__dadd_rn(1.0, __dmul_rn(ratio, ratio))));
}

#line 47 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_make(double real, double imaginary)
#line 49 "ComplexModule.cs"
{
#line 50 "ComplexModule.cs"
    MathBlockComplexValue result;
#line 51 "ComplexModule.cs"
#line 51 "ComplexModule.cs"
    double* csharp2cuda_temp_0 = &((result).real);
    (*(csharp2cuda_temp_0) = real);
#line 52 "ComplexModule.cs"
#line 52 "ComplexModule.cs"
    double* csharp2cuda_temp_1 = &((result).imaginary);
    (*(csharp2cuda_temp_1) = imaginary);
#line 53 "ComplexModule.cs"
    return result;
}

#line 72 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_multiply(
    MathBlockComplexValue left,
    MathBlockComplexValue right)
#line 76 "ComplexModule.cs"
{
#line 77 "ComplexModule.cs"
#line 78 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (left).real;
#line 78 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (right).real;
#line 78 "ComplexModule.cs"
    double csharp2cuda_temp_2 = (left).imaginary;
#line 78 "ComplexModule.cs"
    double csharp2cuda_temp_3 = (right).imaginary;
#line 79 "ComplexModule.cs"
    double csharp2cuda_temp_4 = (left).real;
#line 79 "ComplexModule.cs"
    double csharp2cuda_temp_5 = (right).imaginary;
#line 79 "ComplexModule.cs"
    double csharp2cuda_temp_6 = (left).imaginary;
#line 79 "ComplexModule.cs"
    double csharp2cuda_temp_7 = (right).real;
    return mathblocks_complex_make(__dsub_rn(__dmul_rn(csharp2cuda_temp_0, csharp2cuda_temp_1), __dmul_rn(csharp2cuda_temp_2, csharp2cuda_temp_3)), __dadd_rn(__dmul_rn(csharp2cuda_temp_4, csharp2cuda_temp_5), __dmul_rn(csharp2cuda_temp_6, csharp2cuda_temp_7)));
}

#line 116 "ComplexModule.cs"
__device__ double mathblocks_complex_phase(MathBlockComplexValue value)
#line 118 "ComplexModule.cs"
{
#line 119 "ComplexModule.cs"
#line 119 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (value).imaginary;
#line 119 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (value).real;
    return mathblocks_arc_tangent_2(csharp2cuda_temp_0, csharp2cuda_temp_1);
}

#line 150 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_power(
    MathBlockComplexValue value,
    MathBlockComplexValue exponent)
#line 154 "ComplexModule.cs"
{
#line 155 "ComplexModule.cs"
    return mathblocks_complex_exponential(mathblocks_complex_multiply(exponent, mathblocks_complex_logarithm(value)));
}

#line 173 "ComplexModule.cs"
__device__ void mathblocks_complex_shape(MathBlockSlot* output, int count)
#line 175 "ComplexModule.cs"
{
#line 176 "ComplexModule.cs"
#line 176 "ComplexModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 177 "ComplexModule.cs"
#line 177 "ComplexModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 178 "ComplexModule.cs"
#line 178 "ComplexModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 179 "ComplexModule.cs"
#line 179 "ComplexModule.cs"
    bool csharp2cuda_temp_3;
#line 179 "ComplexModule.cs"
    if (!(((count) < (0))))
    {
#line 179 "ComplexModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 179 "ComplexModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 179 "ComplexModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
    {
#line 180 "ComplexModule.cs"
#line 180 "ComplexModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
    }
}

#line 139 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_square_root(MathBlockComplexValue value)
#line 141 "ComplexModule.cs"
{
#line 142 "ComplexModule.cs"
#line 142 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 142 "ComplexModule.cs"
    bool csharp2cuda_temp_1;
#line 142 "ComplexModule.cs"
    if (((csharp2cuda_temp_0) == (0.0)))
    {
#line 142 "ComplexModule.cs"
        double csharp2cuda_temp_2 = (value).imaginary;
#line 142 "ComplexModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) == (0.0));
    }
    else
    {
#line 142 "ComplexModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 143 "ComplexModule.cs"
#line 143 "ComplexModule.cs"
        double csharp2cuda_temp_3 = (value).imaginary;
        return mathblocks_complex_make(0.0, csharp2cuda_temp_3);
    }
#line 144 "ComplexModule.cs"
    double magnitude = mathblocks_complex_magnitude(value);
#line 145 "ComplexModule.cs"
#line 146 "ComplexModule.cs"
    double csharp2cuda_temp_4 = (value).real;
#line 146 "ComplexModule.cs"
    double csharp2cuda_temp_5 = __ddiv_rn(__dadd_rn(magnitude, csharp2cuda_temp_4), 2.0);
#line 147 "ComplexModule.cs"
    double csharp2cuda_temp_6 = (value).real;
#line 147 "ComplexModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(magnitude, csharp2cuda_temp_6), 2.0);
#line 147 "ComplexModule.cs"
    double csharp2cuda_temp_8 = (value).imaginary;
    return mathblocks_complex_make(mathblocks_square_root(csharp2cuda_temp_5), copysign(mathblocks_square_root(csharp2cuda_temp_7), csharp2cuda_temp_8));
}

#line 64 "ComplexModule.cs"
__device__ MathBlockComplexValue mathblocks_complex_subtract(
    MathBlockComplexValue left,
    MathBlockComplexValue right)
#line 68 "ComplexModule.cs"
{
#line 69 "ComplexModule.cs"
#line 69 "ComplexModule.cs"
    double csharp2cuda_temp_0 = (left).real;
#line 69 "ComplexModule.cs"
    double csharp2cuda_temp_1 = (right).real;
#line 69 "ComplexModule.cs"
    double csharp2cuda_temp_2 = (left).imaginary;
#line 69 "ComplexModule.cs"
    double csharp2cuda_temp_3 = (right).imaginary;
    return mathblocks_complex_make(__dsub_rn(csharp2cuda_temp_0, csharp2cuda_temp_1), __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
}