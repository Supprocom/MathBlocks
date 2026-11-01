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

#line 120 "ElementwiseModule.cs"
__device__ double mathblocks_elementwise_argument(const MathBlockSlot* slot, bool vector, int row);

#line 203 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 128 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_publish(MathBlockSlot* output, bool valid, int count, int thread);

#line 111 "ElementwiseModule.cs"
__device__ bool mathblocks_elementwise_row_value(int source_opcode, double a, double b, double c, double* value);

#line 142 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads);

#line 88 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_arity(int source);

#line 37 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_opcode(int source);

#line 120 "ElementwiseModule.cs"
__device__ double mathblocks_elementwise_argument(const MathBlockSlot* slot, bool vector, int row)
#line 122 "ElementwiseModule.cs"
{
#line 123 "ElementwiseModule.cs"
    if (((((void*)(slot))) == (((void*)(nullptr)))))
    {
#line 124 "ElementwiseModule.cs"
        return 0.0;
    }
#line 125 "ElementwiseModule.cs"
#line 125 "ElementwiseModule.cs"
    double csharp2cuda_temp_0;
#line 125 "ElementwiseModule.cs"
    if (vector)
    {
#line 125 "ElementwiseModule.cs"
        unsigned long long csharp2cuda_temp_1 = (slot)->data_pointer;
#line 125 "ElementwiseModule.cs"
        csharp2cuda_temp_0 = (((double*)(csharp2cuda_temp_1)))[row];
    }
    else
    {
#line 125 "ElementwiseModule.cs"
        csharp2cuda_temp_0 = (slot)->scalar_value;
    }
    return csharp2cuda_temp_0;
}

#line 203 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 209 "ElementwiseModule.cs"
{
#line 210 "ElementwiseModule.cs"
    mathblocks_elementwise_run(opcode, inputs, input_count, output, threadIdx.x, blockDim.x);
}

#line 128 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_publish(MathBlockSlot* output, bool valid, int count, int thread)
#line 130 "ElementwiseModule.cs"
{
#line 131 "ElementwiseModule.cs"
    if (((thread) != (0)))
    {
#line 132 "ElementwiseModule.cs"
        return;
    }
#line 133 "ElementwiseModule.cs"
#line 133 "ElementwiseModule.cs"
    double* csharp2cuda_temp_0 = &((output)->scalar_value);
    (*(csharp2cuda_temp_0) = 0.0);
#line 134 "ElementwiseModule.cs"
#line 134 "ElementwiseModule.cs"
    int* csharp2cuda_temp_1 = &((output)->boolean_value);
    (*(csharp2cuda_temp_1) = 0);
#line 135 "ElementwiseModule.cs"
#line 135 "ElementwiseModule.cs"
    int* csharp2cuda_temp_2 = &((output)->columns);
    (*(csharp2cuda_temp_2) = 0);
#line 136 "ElementwiseModule.cs"
#line 136 "ElementwiseModule.cs"
    int* csharp2cuda_temp_3 = &((output)->rows);
#line 136 "ElementwiseModule.cs"
    int csharp2cuda_temp_4;
#line 136 "ElementwiseModule.cs"
    if (valid)
    {
#line 136 "ElementwiseModule.cs"
        csharp2cuda_temp_4 = count;
    }
    else
    {
#line 136 "ElementwiseModule.cs"
        csharp2cuda_temp_4 = 0;
    }
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 137 "ElementwiseModule.cs"
#line 137 "ElementwiseModule.cs"
    int* csharp2cuda_temp_5 = &((output)->count);
#line 137 "ElementwiseModule.cs"
    int csharp2cuda_temp_6;
#line 137 "ElementwiseModule.cs"
    if (valid)
    {
#line 137 "ElementwiseModule.cs"
        csharp2cuda_temp_6 = count;
    }
    else
    {
#line 137 "ElementwiseModule.cs"
        csharp2cuda_temp_6 = 0;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 138 "ElementwiseModule.cs"
#line 138 "ElementwiseModule.cs"
    int* csharp2cuda_temp_7 = &((output)->valid);
    (*(csharp2cuda_temp_7) = valid);
}

#line 111 "ElementwiseModule.cs"
__device__ bool mathblocks_elementwise_row_value(int source_opcode, double a, double b, double c, double* value)
#line 113 "ElementwiseModule.cs"
{
#line 114 "ElementwiseModule.cs"
#line 114 "ElementwiseModule.cs"
    bool csharp2cuda_temp_0;
#line 114 "ElementwiseModule.cs"
    if (((source_opcode) >= (64)))
    {
#line 114 "ElementwiseModule.cs"
        csharp2cuda_temp_0 = mathblocks_probability_scalar_value(csharp2cuda_i32_sub(source_opcode, 64), a, b, c, value);
    }
    else
    {
#line 114 "ElementwiseModule.cs"
        csharp2cuda_temp_0 = mathblocks_scalar_value(source_opcode, a, b, c, value);
    }
    return csharp2cuda_temp_0;
}

#line 142 "ElementwiseModule.cs"
__device__ void mathblocks_elementwise_run(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output,
    int thread,
    int threads)
#line 150 "ElementwiseModule.cs"
{
#line 151 "ElementwiseModule.cs"
    int mask = csharp2cuda_i32_div(opcode, 128);
#line 152 "ElementwiseModule.cs"
    int form = csharp2cuda_i32_rem(opcode, 128);
#line 153 "ElementwiseModule.cs"
    int source = csharp2cuda_i32_div(form, 2);
#line 154 "ElementwiseModule.cs"
    int csharp2cuda_temp_0 = csharp2cuda_i32_rem(form, 2);
#line 154 "ElementwiseModule.cs"
    bool sibling = ((csharp2cuda_temp_0) != (0));
#line 155 "ElementwiseModule.cs"
    int arity = mathblocks_elementwise_source_arity(source);
#line 156 "ElementwiseModule.cs"
    bool csharp2cuda_temp_1;
#line 156 "ElementwiseModule.cs"
    if (((opcode) >= (0)))
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_1 = ((source) < (41));
    }
    else
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_1 = false;
    }
#line 156 "ElementwiseModule.cs"
    bool csharp2cuda_temp_2;
#line 156 "ElementwiseModule.cs"
    if (csharp2cuda_temp_1)
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_2 = ((mask) > (0));
    }
    else
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_2 = false;
    }
#line 156 "ElementwiseModule.cs"
    bool csharp2cuda_temp_3;
#line 156 "ElementwiseModule.cs"
    if (csharp2cuda_temp_2)
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_3 = ((mask) < (csharp2cuda_i32_shl(1, arity)));
    }
    else
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_3 = false;
    }
#line 156 "ElementwiseModule.cs"
    bool csharp2cuda_temp_4;
#line 156 "ElementwiseModule.cs"
    if (csharp2cuda_temp_3)
    {
#line 157 "ElementwiseModule.cs"
        int csharp2cuda_temp_5;
#line 157 "ElementwiseModule.cs"
        if (sibling)
        {
#line 157 "ElementwiseModule.cs"
            csharp2cuda_temp_5 = 0;
        }
        else
        {
#line 157 "ElementwiseModule.cs"
            csharp2cuda_temp_5 = 1;
        }
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_4 = ((input_count) == (csharp2cuda_i32_add(arity, csharp2cuda_temp_5)));
    }
    else
    {
#line 156 "ElementwiseModule.cs"
        csharp2cuda_temp_4 = false;
    }
#line 156 "ElementwiseModule.cs"
    bool valid = csharp2cuda_temp_4;
#line 158 "ElementwiseModule.cs"
    {
#line 158 "ElementwiseModule.cs"
        int index = 0;
        while (true)
        {
#line 158 "ElementwiseModule.cs"
            bool csharp2cuda_temp_7;
#line 158 "ElementwiseModule.cs"
            if (valid)
            {
#line 158 "ElementwiseModule.cs"
                csharp2cuda_temp_7 = ((index) < (input_count));
            }
            else
            {
#line 158 "ElementwiseModule.cs"
                csharp2cuda_temp_7 = false;
            }
            if (!(csharp2cuda_temp_7))
                break;
#line 159 "ElementwiseModule.cs"
#line 159 "ElementwiseModule.cs"
            MathBlockSlot* csharp2cuda_temp_8 = (inputs)[index];
#line 159 "ElementwiseModule.cs"
            bool csharp2cuda_temp_9;
#line 159 "ElementwiseModule.cs"
            if (!(((((void*)(csharp2cuda_temp_8))) == (((void*)(nullptr))))))
            {
#line 159 "ElementwiseModule.cs"
                MathBlockSlot* csharp2cuda_temp_10 = (inputs)[index];
#line 159 "ElementwiseModule.cs"
                bool csharp2cuda_temp_11 = (csharp2cuda_temp_10)->valid;
#line 159 "ElementwiseModule.cs"
                csharp2cuda_temp_9 = (!(csharp2cuda_temp_11));
            }
            else
            {
#line 159 "ElementwiseModule.cs"
                csharp2cuda_temp_9 = true;
            }
            if (csharp2cuda_temp_9)
            {
#line 160 "ElementwiseModule.cs"
#line 160 "ElementwiseModule.cs"
                bool* csharp2cuda_temp_12 = &(valid);
                (*(csharp2cuda_temp_12) = false);
            }
#line 158 "ElementwiseModule.cs"
            int* csharp2cuda_temp_6 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 161 "ElementwiseModule.cs"
    int count = -1;
#line 162 "ElementwiseModule.cs"
    {
#line 162 "ElementwiseModule.cs"
        int index = 0;
        while (true)
        {
#line 162 "ElementwiseModule.cs"
            bool csharp2cuda_temp_14;
#line 162 "ElementwiseModule.cs"
            if (valid)
            {
#line 162 "ElementwiseModule.cs"
                csharp2cuda_temp_14 = ((index) < (arity));
            }
            else
            {
#line 162 "ElementwiseModule.cs"
                csharp2cuda_temp_14 = false;
            }
            if (!(csharp2cuda_temp_14))
                break;
#line 163 "ElementwiseModule.cs"
            {
#line 164 "ElementwiseModule.cs"
                if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, index))) == (0)))
                {
#line 165 "ElementwiseModule.cs"
                    goto csharp2cuda_for_continue_1;
                }
#line 166 "ElementwiseModule.cs"
                if (((count) < (0)))
                {
#line 167 "ElementwiseModule.cs"
#line 167 "ElementwiseModule.cs"
                    int* csharp2cuda_temp_15 = &(count);
#line 167 "ElementwiseModule.cs"
                    MathBlockSlot* csharp2cuda_temp_16 = (inputs)[index];
#line 167 "ElementwiseModule.cs"
                    int csharp2cuda_temp_17 = (csharp2cuda_temp_16)->count;
                    (*(csharp2cuda_temp_15) = csharp2cuda_temp_17);
                }
                else
                {
#line 168 "ElementwiseModule.cs"
#line 168 "ElementwiseModule.cs"
                    MathBlockSlot* csharp2cuda_temp_18 = (inputs)[index];
#line 168 "ElementwiseModule.cs"
                    int csharp2cuda_temp_19 = (csharp2cuda_temp_18)->count;
                    if (((csharp2cuda_temp_19) != (count)))
                    {
#line 169 "ElementwiseModule.cs"
#line 169 "ElementwiseModule.cs"
                        bool* csharp2cuda_temp_20 = &(valid);
                        (*(csharp2cuda_temp_20) = false);
                    }
                }
            }
            csharp2cuda_for_continue_1:
#line 162 "ElementwiseModule.cs"
            int* csharp2cuda_temp_13 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
        }
    }
#line 171 "ElementwiseModule.cs"
#line 171 "ElementwiseModule.cs"
    bool csharp2cuda_temp_21;
#line 171 "ElementwiseModule.cs"
    if (valid)
    {
#line 171 "ElementwiseModule.cs"
        int csharp2cuda_temp_22 = (output)->capacity;
#line 171 "ElementwiseModule.cs"
        csharp2cuda_temp_21 = ((count) > (csharp2cuda_temp_22));
    }
    else
    {
#line 171 "ElementwiseModule.cs"
        csharp2cuda_temp_21 = false;
    }
    if (csharp2cuda_temp_21)
    {
#line 172 "ElementwiseModule.cs"
#line 172 "ElementwiseModule.cs"
        bool* csharp2cuda_temp_23 = &(valid);
        (*(csharp2cuda_temp_23) = false);
    }
#line 173 "ElementwiseModule.cs"
    mathblocks_elementwise_publish(output, valid, count, thread);
#line 174 "ElementwiseModule.cs"
    if ((!(valid)))
    {
#line 175 "ElementwiseModule.cs"
        return;
    }
#line 177 "ElementwiseModule.cs"
    MathBlockSlot* csharp2cuda_temp_24 = (inputs)[0];
#line 177 "ElementwiseModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_24;
#line 178 "ElementwiseModule.cs"
    MathBlockSlot* csharp2cuda_temp_25;
#line 178 "ElementwiseModule.cs"
    if (((arity) > (1)))
    {
#line 178 "ElementwiseModule.cs"
        csharp2cuda_temp_25 = (inputs)[1];
    }
    else
    {
#line 178 "ElementwiseModule.cs"
        csharp2cuda_temp_25 = ((MathBlockSlot*)(nullptr));
    }
#line 178 "ElementwiseModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_25;
#line 179 "ElementwiseModule.cs"
    MathBlockSlot* csharp2cuda_temp_26;
#line 179 "ElementwiseModule.cs"
    if (((arity) > (2)))
    {
#line 179 "ElementwiseModule.cs"
        csharp2cuda_temp_26 = (inputs)[2];
    }
    else
    {
#line 179 "ElementwiseModule.cs"
        csharp2cuda_temp_26 = ((MathBlockSlot*)(nullptr));
    }
#line 179 "ElementwiseModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_26;
#line 180 "ElementwiseModule.cs"
    bool first_vector = ((csharp2cuda_i32_and(mask, 1)) != (0));
#line 181 "ElementwiseModule.cs"
    bool second_vector = ((csharp2cuda_i32_and(mask, 2)) != (0));
#line 182 "ElementwiseModule.cs"
    bool third_vector = ((csharp2cuda_i32_and(mask, 4)) != (0));
#line 183 "ElementwiseModule.cs"
    double csharp2cuda_temp_27;
#line 183 "ElementwiseModule.cs"
    if (sibling)
    {
#line 183 "ElementwiseModule.cs"
        csharp2cuda_temp_27 = 0.0;
    }
    else
    {
#line 183 "ElementwiseModule.cs"
        MathBlockSlot* csharp2cuda_temp_28 = (inputs)[arity];
#line 183 "ElementwiseModule.cs"
        csharp2cuda_temp_27 = (csharp2cuda_temp_28)->scalar_value;
    }
#line 183 "ElementwiseModule.cs"
    double fill = csharp2cuda_temp_27;
#line 184 "ElementwiseModule.cs"
    int source_opcode = mathblocks_elementwise_source_opcode(source);
#line 185 "ElementwiseModule.cs"
    unsigned long long csharp2cuda_temp_29 = (output)->data_pointer;
#line 185 "ElementwiseModule.cs"
    double* result = ((double*)(csharp2cuda_temp_29));
#line 186 "ElementwiseModule.cs"
    unsigned long long csharp2cuda_temp_30 = (output)->data_pointer;
#line 186 "ElementwiseModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_30));
#line 187 "ElementwiseModule.cs"
    {
#line 187 "ElementwiseModule.cs"
        int row = thread;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 188 "ElementwiseModule.cs"
            {
#line 189 "ElementwiseModule.cs"
                double value = 0.0;
#line 192 "ElementwiseModule.cs"
                double csharp2cuda_temp_33 = mathblocks_elementwise_argument(first, first_vector, row);
#line 193 "ElementwiseModule.cs"
                double csharp2cuda_temp_34 = mathblocks_elementwise_argument(second, second_vector, row);
#line 194 "ElementwiseModule.cs"
                double csharp2cuda_temp_35 = mathblocks_elementwise_argument(third, third_vector, row);
#line 195 "ElementwiseModule.cs"
                double* csharp2cuda_temp_36 = &(value);
#line 190 "ElementwiseModule.cs"
                bool row_valid = mathblocks_elementwise_row_value(source_opcode, csharp2cuda_temp_33, csharp2cuda_temp_34, csharp2cuda_temp_35, csharp2cuda_temp_36);
#line 196 "ElementwiseModule.cs"
                if (sibling)
                {
#line 197 "ElementwiseModule.cs"
#line 197 "ElementwiseModule.cs"
                    int* csharp2cuda_temp_37 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_37) = row_valid);
                }
                else
                {
#line 199 "ElementwiseModule.cs"
#line 199 "ElementwiseModule.cs"
                    double* csharp2cuda_temp_38 = &((result)[row]);
#line 199 "ElementwiseModule.cs"
                    double csharp2cuda_temp_39;
#line 199 "ElementwiseModule.cs"
                    if (row_valid)
                    {
#line 199 "ElementwiseModule.cs"
                        csharp2cuda_temp_39 = value;
                    }
                    else
                    {
#line 199 "ElementwiseModule.cs"
                        csharp2cuda_temp_39 = fill;
                    }
                    (*(csharp2cuda_temp_38) = csharp2cuda_temp_39);
                }
            }
#line 187 "ElementwiseModule.cs"
            int* csharp2cuda_temp_31 = &(row);
#line 187 "ElementwiseModule.cs"
            int csharp2cuda_temp_32 = *(csharp2cuda_temp_31);
            (*(csharp2cuda_temp_31) = csharp2cuda_i32_add(csharp2cuda_temp_32, threads));
        }
    }
}

#line 88 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_arity(int source)
#line 90 "ElementwiseModule.cs"
{
#line 91 "ElementwiseModule.cs"
    switch (source)
    {
#line 93 "ElementwiseModule.cs"
        case 0:
        case 1:
        case 4:
        case 5:
        case 8:
        case 27:
        case 28:
        case 29:
        case 37:
#line 102 "ElementwiseModule.cs"
            return 2;
#line 103 "ElementwiseModule.cs"
        case 12:
        case 40:
#line 105 "ElementwiseModule.cs"
            return 3;
#line 106 "ElementwiseModule.cs"
        default:
#line 107 "ElementwiseModule.cs"
            return 1;
    }
}

#line 37 "ElementwiseModule.cs"
__device__ int mathblocks_elementwise_source_opcode(int source)
#line 39 "ElementwiseModule.cs"
{
#line 40 "ElementwiseModule.cs"
    switch (source)
    {
#line 42 "ElementwiseModule.cs"
        case 0:
#line 42 "ElementwiseModule.cs"
            return 64;
#line 43 "ElementwiseModule.cs"
        case 1:
#line 43 "ElementwiseModule.cs"
            return 65;
#line 44 "ElementwiseModule.cs"
        case 2:
#line 44 "ElementwiseModule.cs"
            return 66;
#line 45 "ElementwiseModule.cs"
        case 3:
#line 45 "ElementwiseModule.cs"
            return 87;
#line 46 "ElementwiseModule.cs"
        case 4:
#line 46 "ElementwiseModule.cs"
            return 89;
#line 47 "ElementwiseModule.cs"
        case 5:
#line 47 "ElementwiseModule.cs"
            return 90;
#line 48 "ElementwiseModule.cs"
        case 6:
#line 48 "ElementwiseModule.cs"
            return 25;
#line 49 "ElementwiseModule.cs"
        case 7:
#line 49 "ElementwiseModule.cs"
            return 24;
#line 50 "ElementwiseModule.cs"
        case 8:
#line 50 "ElementwiseModule.cs"
            return 27;
#line 51 "ElementwiseModule.cs"
        case 9:
#line 51 "ElementwiseModule.cs"
            return 26;
#line 52 "ElementwiseModule.cs"
        case 10:
#line 52 "ElementwiseModule.cs"
            return 19;
#line 53 "ElementwiseModule.cs"
        case 11:
#line 53 "ElementwiseModule.cs"
            return 35;
#line 54 "ElementwiseModule.cs"
        case 12:
#line 54 "ElementwiseModule.cs"
            return 10;
#line 55 "ElementwiseModule.cs"
        case 13:
#line 55 "ElementwiseModule.cs"
            return 20;
#line 56 "ElementwiseModule.cs"
        case 14:
#line 56 "ElementwiseModule.cs"
            return 22;
#line 57 "ElementwiseModule.cs"
        case 15:
#line 57 "ElementwiseModule.cs"
            return 15;
#line 58 "ElementwiseModule.cs"
        case 16:
#line 58 "ElementwiseModule.cs"
            return 13;
#line 59 "ElementwiseModule.cs"
        case 17:
#line 59 "ElementwiseModule.cs"
            return 34;
#line 60 "ElementwiseModule.cs"
        case 18:
#line 60 "ElementwiseModule.cs"
            return 29;
#line 61 "ElementwiseModule.cs"
        case 19:
#line 61 "ElementwiseModule.cs"
            return 28;
#line 62 "ElementwiseModule.cs"
        case 20:
#line 62 "ElementwiseModule.cs"
            return 30;
#line 63 "ElementwiseModule.cs"
        case 21:
#line 63 "ElementwiseModule.cs"
            return 32;
#line 64 "ElementwiseModule.cs"
        case 22:
#line 64 "ElementwiseModule.cs"
            return 31;
#line 65 "ElementwiseModule.cs"
        case 23:
#line 65 "ElementwiseModule.cs"
            return 33;
#line 66 "ElementwiseModule.cs"
        case 24:
#line 66 "ElementwiseModule.cs"
            return 42;
#line 67 "ElementwiseModule.cs"
        case 25:
#line 67 "ElementwiseModule.cs"
            return 39;
#line 68 "ElementwiseModule.cs"
        case 26:
#line 68 "ElementwiseModule.cs"
            return 40;
#line 69 "ElementwiseModule.cs"
        case 27:
#line 69 "ElementwiseModule.cs"
            return 9;
#line 70 "ElementwiseModule.cs"
        case 28:
#line 70 "ElementwiseModule.cs"
            return 8;
#line 71 "ElementwiseModule.cs"
        case 29:
#line 71 "ElementwiseModule.cs"
            return 38;
#line 72 "ElementwiseModule.cs"
        case 30:
#line 72 "ElementwiseModule.cs"
            return 4;
#line 73 "ElementwiseModule.cs"
        case 31:
#line 73 "ElementwiseModule.cs"
            return 11;
#line 74 "ElementwiseModule.cs"
        case 32:
#line 74 "ElementwiseModule.cs"
            return 36;
#line 75 "ElementwiseModule.cs"
        case 33:
#line 75 "ElementwiseModule.cs"
            return 21;
#line 76 "ElementwiseModule.cs"
        case 34:
#line 76 "ElementwiseModule.cs"
            return 41;
#line 77 "ElementwiseModule.cs"
        case 35:
#line 77 "ElementwiseModule.cs"
            return 23;
#line 78 "ElementwiseModule.cs"
        case 36:
#line 78 "ElementwiseModule.cs"
            return 37;
#line 79 "ElementwiseModule.cs"
        case 37:
#line 79 "ElementwiseModule.cs"
            return 92;
#line 80 "ElementwiseModule.cs"
        case 38:
#line 80 "ElementwiseModule.cs"
            return 43;
#line 81 "ElementwiseModule.cs"
        case 39:
#line 81 "ElementwiseModule.cs"
            return 93;
#line 82 "ElementwiseModule.cs"
        case 40:
#line 82 "ElementwiseModule.cs"
            return 94;
#line 83 "ElementwiseModule.cs"
        default:
#line 83 "ElementwiseModule.cs"
            return csharp2cuda_i32_neg(1);
    }
}