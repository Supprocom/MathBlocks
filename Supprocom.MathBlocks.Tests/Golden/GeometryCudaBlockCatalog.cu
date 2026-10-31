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

struct MathBlockGeometryEdge;

#line 37 "GeometryModule.cs"
struct MathBlockGeometryEdge
{
    int from;
    int to;
    double weight;
};

#line 107 "GeometryModule.cs"
__device__ void mathblocks_geometry_barycentric(
    double point_x,
    double point_y,
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y,
    double* result);

#line 70 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 238 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 56 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index);

#line 44 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 222 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right);

#line 211 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value);

#line 171 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right);

#line 83 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y);

#line 192 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_indices(
    const double* points,
    int count,
    int* indices);

#line 130 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square);

#line 107 "GeometryModule.cs"
__device__ void mathblocks_geometry_barycentric(
    double point_x,
    double point_y,
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y,
    double* result)
#line 118 "GeometryModule.cs"
{
#line 119 "GeometryModule.cs"
    double denominator = __dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(first_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(first_y, third_y)));
#line 121 "GeometryModule.cs"
    double first_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(point_y, third_y))), denominator);
#line 123 "GeometryModule.cs"
    double second_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(third_y, first_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(first_x, third_x), __dsub_rn(point_y, third_y))), denominator);
#line 125 "GeometryModule.cs"
#line 125 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &((result)[0]);
    (*(csharp2cuda_temp_0) = first_weight);
#line 126 "GeometryModule.cs"
#line 126 "GeometryModule.cs"
    double* csharp2cuda_temp_1 = &((result)[1]);
    (*(csharp2cuda_temp_1) = second_weight);
#line 127 "GeometryModule.cs"
#line 127 "GeometryModule.cs"
    double* csharp2cuda_temp_2 = &((result)[2]);
    (*(csharp2cuda_temp_2) = __dsub_rn(__dsub_rn(1.0, first_weight), second_weight));
}

#line 70 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 78 "GeometryModule.cs"
{
#line 79 "GeometryModule.cs"
    return __dsub_rn(__dmul_rn(__dsub_rn(left_x, origin_x), __dsub_rn(right_y, origin_y)), __dmul_rn(__dsub_rn(left_y, origin_y), __dsub_rn(right_x, origin_x)));
}

#line 238 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 244 "GeometryModule.cs"
{
#line 245 "GeometryModule.cs"
    int thread = threadIdx.x;
#line 246 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 246 "GeometryModule.cs"
    if (((input_count) > (0)))
    {
#line 246 "GeometryModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 246 "GeometryModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 246 "GeometryModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 247 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 247 "GeometryModule.cs"
    if (((input_count) > (1)))
    {
#line 247 "GeometryModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 247 "GeometryModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 247 "GeometryModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 248 "GeometryModule.cs"
    if (((thread) == (0)))
#line 249 "GeometryModule.cs"
    {
#line 250 "GeometryModule.cs"
#line 250 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 251 "GeometryModule.cs"
#line 251 "GeometryModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 252 "GeometryModule.cs"
#line 252 "GeometryModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 253 "GeometryModule.cs"
#line 253 "GeometryModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 254 "GeometryModule.cs"
#line 254 "GeometryModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 255 "GeometryModule.cs"
#line 255 "GeometryModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 255 "GeometryModule.cs"
        bool csharp2cuda_temp_8;
#line 255 "GeometryModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 255 "GeometryModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 255 "GeometryModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 256 "GeometryModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 257 "GeometryModule.cs"
#line 257 "GeometryModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 257 "GeometryModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 257 "GeometryModule.cs"
            bool csharp2cuda_temp_11;
#line 257 "GeometryModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 257 "GeometryModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 257 "GeometryModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 259 "GeometryModule.cs"
    __syncthreads();
#line 260 "GeometryModule.cs"
#line 260 "GeometryModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 261 "GeometryModule.cs"
        return;
    }
#line 263 "GeometryModule.cs"
    double* csharp2cuda_temp_13;
#line 263 "GeometryModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 263 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 263 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 263 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 263 "GeometryModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 264 "GeometryModule.cs"
    double* csharp2cuda_temp_15;
#line 264 "GeometryModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 264 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 264 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 264 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 264 "GeometryModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 265 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 265 "GeometryModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 266 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 266 "GeometryModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 268 "GeometryModule.cs"
    if (((thread) == (0)))
#line 269 "GeometryModule.cs"
    {
#line 270 "GeometryModule.cs"
        switch (opcode)
        {
#line 272 "GeometryModule.cs"
            case 0:
#line 273 "GeometryModule.cs"
                mathblocks_sequence_set_vector_shape(output, 3);
#line 274 "GeometryModule.cs"
#line 274 "GeometryModule.cs"
                int csharp2cuda_temp_19 = (first)->count;
#line 274 "GeometryModule.cs"
                bool csharp2cuda_temp_20;
#line 274 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_19) != (1))))
                {
#line 274 "GeometryModule.cs"
                    int csharp2cuda_temp_21 = (second)->count;
#line 274 "GeometryModule.cs"
                    csharp2cuda_temp_20 = ((csharp2cuda_temp_21) != (3));
                }
                else
                {
#line 274 "GeometryModule.cs"
                    csharp2cuda_temp_20 = true;
                }
                if (csharp2cuda_temp_20)
#line 275 "GeometryModule.cs"
                {
#line 276 "GeometryModule.cs"
#line 276 "GeometryModule.cs"
                    int* csharp2cuda_temp_22 = &((output)->valid);
                    (*(csharp2cuda_temp_22) = 0);
#line 277 "GeometryModule.cs"
                    break;
                }
#line 279 "GeometryModule.cs"
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_23 = (a)[0];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_24 = (a)[1];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_25 = (b)[0];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_26 = (b)[1];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_27 = (b)[2];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_28 = (b)[3];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_29 = (b)[4];
#line 280 "GeometryModule.cs"
                double csharp2cuda_temp_30 = (b)[5];
                mathblocks_geometry_barycentric(csharp2cuda_temp_23, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26, csharp2cuda_temp_27, csharp2cuda_temp_28, csharp2cuda_temp_29, csharp2cuda_temp_30, result);
#line 281 "GeometryModule.cs"
                {
#line 281 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (3))))
                            break;
#line 282 "GeometryModule.cs"
#line 282 "GeometryModule.cs"
                        double csharp2cuda_temp_32 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_32))))
                        {
#line 282 "GeometryModule.cs"
#line 282 "GeometryModule.cs"
                            int* csharp2cuda_temp_33 = &((output)->valid);
                            (*(csharp2cuda_temp_33) = 0);
                        }
#line 281 "GeometryModule.cs"
                        int* csharp2cuda_temp_31 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                    }
                }
#line 283 "GeometryModule.cs"
                break;
#line 284 "GeometryModule.cs"
            case 1:
#line 285 "GeometryModule.cs"
#line 285 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((output)->rows);
                (*(csharp2cuda_temp_34) = 1);
#line 286 "GeometryModule.cs"
#line 286 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &((output)->count);
                (*(csharp2cuda_temp_35) = 1);
#line 287 "GeometryModule.cs"
#line 287 "GeometryModule.cs"
                int csharp2cuda_temp_36 = (first)->count;
#line 287 "GeometryModule.cs"
                bool csharp2cuda_temp_37;
#line 287 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_36) <= (0))))
                {
#line 287 "GeometryModule.cs"
                    int csharp2cuda_temp_38 = (output)->capacity;
#line 287 "GeometryModule.cs"
                    csharp2cuda_temp_37 = ((csharp2cuda_temp_38) < (1));
                }
                else
                {
#line 287 "GeometryModule.cs"
                    csharp2cuda_temp_37 = true;
                }
                if (csharp2cuda_temp_37)
#line 288 "GeometryModule.cs"
                {
#line 289 "GeometryModule.cs"
#line 289 "GeometryModule.cs"
                    int* csharp2cuda_temp_39 = &((output)->valid);
                    (*(csharp2cuda_temp_39) = 0);
#line 290 "GeometryModule.cs"
                    break;
                }
#line 292 "GeometryModule.cs"
#line 292 "GeometryModule.cs"
                double* csharp2cuda_temp_40 = &((result)[0]);
                (*(csharp2cuda_temp_40) = 0.0);
#line 293 "GeometryModule.cs"
#line 293 "GeometryModule.cs"
                double* csharp2cuda_temp_41 = &((result)[1]);
                (*(csharp2cuda_temp_41) = 0.0);
#line 294 "GeometryModule.cs"
                {
#line 294 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 294 "GeometryModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_43))))
                            break;
#line 295 "GeometryModule.cs"
                        {
#line 296 "GeometryModule.cs"
#line 296 "GeometryModule.cs"
                            double* csharp2cuda_temp_44 = &((result)[0]);
#line 296 "GeometryModule.cs"
                            double csharp2cuda_temp_45 = *(csharp2cuda_temp_44);
#line 296 "GeometryModule.cs"
                            double csharp2cuda_temp_46 = (a)[csharp2cuda_i32_mul(2, index)];
                            (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 297 "GeometryModule.cs"
#line 297 "GeometryModule.cs"
                            double* csharp2cuda_temp_47 = &((result)[1]);
#line 297 "GeometryModule.cs"
                            double csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
#line 297 "GeometryModule.cs"
                            double csharp2cuda_temp_49 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                            (*(csharp2cuda_temp_47) = __dadd_rn(csharp2cuda_temp_48, csharp2cuda_temp_49));
                        }
#line 294 "GeometryModule.cs"
                        int* csharp2cuda_temp_42 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_42));
                    }
                }
#line 299 "GeometryModule.cs"
#line 299 "GeometryModule.cs"
                double* csharp2cuda_temp_50 = &((result)[0]);
#line 299 "GeometryModule.cs"
                double csharp2cuda_temp_51 = *(csharp2cuda_temp_50);
#line 299 "GeometryModule.cs"
                int csharp2cuda_temp_52 = (first)->count;
                (*(csharp2cuda_temp_50) = __ddiv_rn(csharp2cuda_temp_51, ((double)(csharp2cuda_temp_52))));
#line 300 "GeometryModule.cs"
#line 300 "GeometryModule.cs"
                double* csharp2cuda_temp_53 = &((result)[1]);
#line 300 "GeometryModule.cs"
                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 300 "GeometryModule.cs"
                int csharp2cuda_temp_55 = (first)->count;
                (*(csharp2cuda_temp_53) = __ddiv_rn(csharp2cuda_temp_54, ((double)(csharp2cuda_temp_55))));
#line 301 "GeometryModule.cs"
#line 301 "GeometryModule.cs"
                double csharp2cuda_temp_56 = (result)[0];
#line 301 "GeometryModule.cs"
                bool csharp2cuda_temp_57;
#line 301 "GeometryModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_56)))))
                {
#line 301 "GeometryModule.cs"
                    double csharp2cuda_temp_58 = (result)[1];
#line 301 "GeometryModule.cs"
                    csharp2cuda_temp_57 = (!(isfinite(csharp2cuda_temp_58)));
                }
                else
                {
#line 301 "GeometryModule.cs"
                    csharp2cuda_temp_57 = true;
                }
                if (csharp2cuda_temp_57)
                {
#line 301 "GeometryModule.cs"
#line 301 "GeometryModule.cs"
                    int* csharp2cuda_temp_59 = &((output)->valid);
                    (*(csharp2cuda_temp_59) = 0);
                }
#line 302 "GeometryModule.cs"
                break;
#line 303 "GeometryModule.cs"
            case 2:
#line 304 "GeometryModule.cs"
#line 304 "GeometryModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
                if (((csharp2cuda_temp_60) != (3)))
#line 305 "GeometryModule.cs"
                {
#line 306 "GeometryModule.cs"
#line 306 "GeometryModule.cs"
                    int* csharp2cuda_temp_61 = &((output)->valid);
                    (*(csharp2cuda_temp_61) = 0);
#line 307 "GeometryModule.cs"
                    break;
                }
#line 309 "GeometryModule.cs"
                {
#line 310 "GeometryModule.cs"
                    double first_length = mathblocks_geometry_distance(a, 1, a, 2);
#line 311 "GeometryModule.cs"
                    double second_length = mathblocks_geometry_distance(a, 0, a, 2);
#line 312 "GeometryModule.cs"
                    double third_length = mathblocks_geometry_distance(a, 0, a, 1);
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_62 = (a)[0];
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_63 = (a)[1];
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_64 = (a)[2];
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_65 = (a)[3];
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_66 = (a)[4];
#line 314 "GeometryModule.cs"
                    double csharp2cuda_temp_67 = (a)[5];
#line 313 "GeometryModule.cs"
                    double cross = mathblocks_geometry_cross(csharp2cuda_temp_62, csharp2cuda_temp_63, csharp2cuda_temp_64, csharp2cuda_temp_65, csharp2cuda_temp_66, csharp2cuda_temp_67);
#line 315 "GeometryModule.cs"
#line 315 "GeometryModule.cs"
                    double* csharp2cuda_temp_68 = &((output)->scalar_value);
#line 315 "GeometryModule.cs"
                    double csharp2cuda_temp_69 = __ddiv_rn(__dmul_rn(__dmul_rn(first_length, second_length), third_length), __dmul_rn(2.0, fabs(cross)));
                    (*(csharp2cuda_temp_68) = csharp2cuda_temp_69);
#line 317 "GeometryModule.cs"
                    break;
                }
#line 319 "GeometryModule.cs"
            case 3:
#line 320 "GeometryModule.cs"
#line 320 "GeometryModule.cs"
                int csharp2cuda_temp_70 = (first)->count;
#line 320 "GeometryModule.cs"
                bool csharp2cuda_temp_71;
#line 320 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_70) < (3))))
                {
#line 320 "GeometryModule.cs"
                    int csharp2cuda_temp_72 = (second)->count;
#line 320 "GeometryModule.cs"
                    csharp2cuda_temp_71 = ((csharp2cuda_temp_72) != (1));
                }
                else
                {
#line 320 "GeometryModule.cs"
                    csharp2cuda_temp_71 = true;
                }
                if (csharp2cuda_temp_71)
#line 321 "GeometryModule.cs"
                {
#line 322 "GeometryModule.cs"
#line 322 "GeometryModule.cs"
                    int* csharp2cuda_temp_73 = &((output)->valid);
                    (*(csharp2cuda_temp_73) = 0);
#line 323 "GeometryModule.cs"
                    break;
                }
#line 325 "GeometryModule.cs"
                {
#line 326 "GeometryModule.cs"
                    bool inside = false;
#line 327 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 328 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 329 "GeometryModule.cs"
                    {
#line 329 "GeometryModule.cs"
                        int current = 0;
                        while (true)
                        {
#line 329 "GeometryModule.cs"
                            int csharp2cuda_temp_75 = (first)->count;
                            if (!(((current) < (csharp2cuda_temp_75))))
                                break;
#line 330 "GeometryModule.cs"
                            {
#line 331 "GeometryModule.cs"
                                int csharp2cuda_temp_76;
#line 331 "GeometryModule.cs"
                                if (((current) == (0)))
                                {
#line 331 "GeometryModule.cs"
                                    int csharp2cuda_temp_77 = (first)->count;
#line 331 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(csharp2cuda_temp_77, 1);
                                }
                                else
                                {
#line 331 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(current, 1);
                                }
#line 331 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_76;
#line 332 "GeometryModule.cs"
                                double left_x = (a)[csharp2cuda_i32_mul(2, current)];
#line 333 "GeometryModule.cs"
                                double left_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, current), 1)];
#line 334 "GeometryModule.cs"
                                double right_x = (a)[csharp2cuda_i32_mul(2, previous)];
#line 335 "GeometryModule.cs"
                                double right_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, previous), 1)];
#line 336 "GeometryModule.cs"
                                if (((mathblocks_geometry_point_to_segment(point_x, point_y, left_x, left_y, right_x, right_y)) == (0.0)))
#line 338 "GeometryModule.cs"
                                {
#line 339 "GeometryModule.cs"
#line 339 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_78 = &(inside);
                                    (*(csharp2cuda_temp_78) = true);
#line 340 "GeometryModule.cs"
                                    break;
                                }
#line 342 "GeometryModule.cs"
#line 342 "GeometryModule.cs"
                                bool csharp2cuda_temp_79;
#line 342 "GeometryModule.cs"
                                if (((((left_y) > (point_y))) != (((right_y) > (point_y)))))
                                {
#line 343 "GeometryModule.cs"
                                    double csharp2cuda_temp_80 = __ddiv_rn(__dmul_rn(__dsub_rn(right_x, left_x), __dsub_rn(point_y, left_y)), __dsub_rn(right_y, left_y));
#line 342 "GeometryModule.cs"
                                    csharp2cuda_temp_79 = ((point_x) < (__dadd_rn(csharp2cuda_temp_80, left_x)));
                                }
                                else
                                {
#line 342 "GeometryModule.cs"
                                    csharp2cuda_temp_79 = false;
                                }
                                if (csharp2cuda_temp_79)
#line 345 "GeometryModule.cs"
                                {
#line 346 "GeometryModule.cs"
#line 346 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_81 = &(inside);
                                    (*(csharp2cuda_temp_81) = (!(inside)));
                                }
                            }
#line 329 "GeometryModule.cs"
                            int* csharp2cuda_temp_74 = &(current);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_74));
                        }
                    }
#line 349 "GeometryModule.cs"
#line 349 "GeometryModule.cs"
                    int* csharp2cuda_temp_82 = &((output)->boolean_value);
#line 349 "GeometryModule.cs"
                    int csharp2cuda_temp_83;
#line 349 "GeometryModule.cs"
                    if (inside)
                    {
#line 349 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 1;
                    }
                    else
                    {
#line 349 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 0;
                    }
                    (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
#line 350 "GeometryModule.cs"
                    break;
                }
#line 352 "GeometryModule.cs"
            case 4:
#line 353 "GeometryModule.cs"
#line 353 "GeometryModule.cs"
                int csharp2cuda_temp_84 = (first)->count;
#line 353 "GeometryModule.cs"
                bool csharp2cuda_temp_85;
#line 353 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_84) <= (0))))
                {
#line 353 "GeometryModule.cs"
                    csharp2cuda_temp_85 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 353 "GeometryModule.cs"
                    csharp2cuda_temp_85 = true;
                }
                if (csharp2cuda_temp_85)
#line 354 "GeometryModule.cs"
                {
#line 355 "GeometryModule.cs"
#line 355 "GeometryModule.cs"
                    int* csharp2cuda_temp_86 = &((output)->valid);
                    (*(csharp2cuda_temp_86) = 0);
#line 356 "GeometryModule.cs"
                    break;
                }
#line 358 "GeometryModule.cs"
                {
#line 359 "GeometryModule.cs"
                    double* sorted = scratch;
#line 360 "GeometryModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 360 "GeometryModule.cs"
                    double* hull = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_87, 2));
#line 361 "GeometryModule.cs"
                    int unique_count = 0;
#line 362 "GeometryModule.cs"
                    {
#line 362 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 362 "GeometryModule.cs"
                            int csharp2cuda_temp_89 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_89))))
                                break;
#line 363 "GeometryModule.cs"
                            {
#line 364 "GeometryModule.cs"
                                double x = (a)[csharp2cuda_i32_mul(2, index)];
#line 365 "GeometryModule.cs"
                                double y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 366 "GeometryModule.cs"
                                int position = unique_count;
#line 367 "GeometryModule.cs"
                                while (true)
                                {
#line 367 "GeometryModule.cs"
                                    bool csharp2cuda_temp_90;
#line 367 "GeometryModule.cs"
                                    if (((position) > (0)))
                                    {
#line 368 "GeometryModule.cs"
                                        double csharp2cuda_temp_91 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(position, 1))];
#line 368 "GeometryModule.cs"
                                        bool csharp2cuda_temp_92;
#line 368 "GeometryModule.cs"
                                        if (!(((csharp2cuda_temp_91) > (x))))
                                        {
#line 369 "GeometryModule.cs"
                                            double csharp2cuda_temp_93 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(position, 1))];
#line 369 "GeometryModule.cs"
                                            bool csharp2cuda_temp_94;
#line 369 "GeometryModule.cs"
                                            if (((csharp2cuda_temp_93) == (x)))
                                            {
#line 370 "GeometryModule.cs"
                                                double csharp2cuda_temp_95 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(position, 1)), 1)];
#line 369 "GeometryModule.cs"
                                                csharp2cuda_temp_94 = ((csharp2cuda_temp_95) > (y));
                                            }
                                            else
                                            {
#line 369 "GeometryModule.cs"
                                                csharp2cuda_temp_94 = false;
                                            }
#line 368 "GeometryModule.cs"
                                            csharp2cuda_temp_92 = csharp2cuda_temp_94;
                                        }
                                        else
                                        {
#line 368 "GeometryModule.cs"
                                            csharp2cuda_temp_92 = true;
                                        }
#line 367 "GeometryModule.cs"
                                        csharp2cuda_temp_90 = csharp2cuda_temp_92;
                                    }
                                    else
                                    {
#line 367 "GeometryModule.cs"
                                        csharp2cuda_temp_90 = false;
                                    }
                                    if (!(csharp2cuda_temp_90))
                                        break;
#line 371 "GeometryModule.cs"
#line 371 "GeometryModule.cs"
                                    int* csharp2cuda_temp_96 = &(position);
                                    csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_96));
                                }
#line 372 "GeometryModule.cs"
#line 372 "GeometryModule.cs"
                                bool csharp2cuda_temp_97;
#line 372 "GeometryModule.cs"
                                if (((position) < (unique_count)))
                                {
#line 372 "GeometryModule.cs"
                                    double csharp2cuda_temp_98 = (sorted)[csharp2cuda_i32_mul(2, position)];
#line 372 "GeometryModule.cs"
                                    csharp2cuda_temp_97 = ((csharp2cuda_temp_98) == (x));
                                }
                                else
                                {
#line 372 "GeometryModule.cs"
                                    csharp2cuda_temp_97 = false;
                                }
#line 372 "GeometryModule.cs"
                                bool csharp2cuda_temp_99;
#line 372 "GeometryModule.cs"
                                if (csharp2cuda_temp_97)
                                {
#line 373 "GeometryModule.cs"
                                    double csharp2cuda_temp_100 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)];
#line 372 "GeometryModule.cs"
                                    csharp2cuda_temp_99 = ((csharp2cuda_temp_100) == (y));
                                }
                                else
                                {
#line 372 "GeometryModule.cs"
                                    csharp2cuda_temp_99 = false;
                                }
                                if (csharp2cuda_temp_99)
#line 374 "GeometryModule.cs"
                                {
#line 375 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_4;
                                }
#line 377 "GeometryModule.cs"
                                {
#line 377 "GeometryModule.cs"
                                    int move = unique_count;
                                    while (true)
                                    {
                                        if (!(((move) > (position))))
                                            break;
#line 378 "GeometryModule.cs"
                                        {
#line 379 "GeometryModule.cs"
#line 379 "GeometryModule.cs"
                                            double* csharp2cuda_temp_102 = &((sorted)[csharp2cuda_i32_mul(2, move)]);
#line 379 "GeometryModule.cs"
                                            double csharp2cuda_temp_103 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(move, 1))];
                                            (*(csharp2cuda_temp_102) = csharp2cuda_temp_103);
#line 380 "GeometryModule.cs"
#line 380 "GeometryModule.cs"
                                            double* csharp2cuda_temp_104 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, move), 1)]);
#line 380 "GeometryModule.cs"
                                            double csharp2cuda_temp_105 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(move, 1)), 1)];
                                            (*(csharp2cuda_temp_104) = csharp2cuda_temp_105);
                                        }
#line 377 "GeometryModule.cs"
                                        int* csharp2cuda_temp_101 = &(move);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_101));
                                    }
                                }
#line 382 "GeometryModule.cs"
#line 382 "GeometryModule.cs"
                                double* csharp2cuda_temp_106 = &((sorted)[csharp2cuda_i32_mul(2, position)]);
                                (*(csharp2cuda_temp_106) = x);
#line 383 "GeometryModule.cs"
#line 383 "GeometryModule.cs"
                                double* csharp2cuda_temp_107 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
                                (*(csharp2cuda_temp_107) = y);
#line 384 "GeometryModule.cs"
#line 384 "GeometryModule.cs"
                                int* csharp2cuda_temp_108 = &(unique_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_108));
                            }
                            csharp2cuda_for_continue_4:
#line 362 "GeometryModule.cs"
                            int* csharp2cuda_temp_88 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_88));
                        }
                    }
#line 386 "GeometryModule.cs"
                    int count = 0;
#line 387 "GeometryModule.cs"
                    if (((unique_count) <= (1)))
#line 388 "GeometryModule.cs"
                    {
#line 389 "GeometryModule.cs"
#line 389 "GeometryModule.cs"
                        int* csharp2cuda_temp_109 = &(count);
                        (*(csharp2cuda_temp_109) = unique_count);
#line 390 "GeometryModule.cs"
                        if (((count) == (1)))
#line 391 "GeometryModule.cs"
                        {
#line 392 "GeometryModule.cs"
#line 392 "GeometryModule.cs"
                            double* csharp2cuda_temp_110 = &((hull)[0]);
#line 392 "GeometryModule.cs"
                            double csharp2cuda_temp_111 = (sorted)[0];
                            (*(csharp2cuda_temp_110) = csharp2cuda_temp_111);
#line 393 "GeometryModule.cs"
#line 393 "GeometryModule.cs"
                            double* csharp2cuda_temp_112 = &((hull)[1]);
#line 393 "GeometryModule.cs"
                            double csharp2cuda_temp_113 = (sorted)[1];
                            (*(csharp2cuda_temp_112) = csharp2cuda_temp_113);
                        }
                    }
                    else
#line 397 "GeometryModule.cs"
                    {
#line 398 "GeometryModule.cs"
                        {
#line 398 "GeometryModule.cs"
                            int index = 0;
                            while (true)
                            {
                                if (!(((index) < (unique_count))))
                                    break;
#line 399 "GeometryModule.cs"
                                {
#line 400 "GeometryModule.cs"
                                    while (true)
                                    {
#line 400 "GeometryModule.cs"
                                        bool csharp2cuda_temp_115;
#line 400 "GeometryModule.cs"
                                        if (((count) >= (2)))
                                        {
#line 401 "GeometryModule.cs"
                                            double csharp2cuda_temp_116 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 401 "GeometryModule.cs"
                                            double csharp2cuda_temp_117 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 402 "GeometryModule.cs"
                                            double csharp2cuda_temp_118 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 402 "GeometryModule.cs"
                                            double csharp2cuda_temp_119 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 403 "GeometryModule.cs"
                                            double csharp2cuda_temp_120 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 403 "GeometryModule.cs"
                                            double csharp2cuda_temp_121 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 400 "GeometryModule.cs"
                                            csharp2cuda_temp_115 = ((mathblocks_geometry_cross(csharp2cuda_temp_116, csharp2cuda_temp_117, csharp2cuda_temp_118, csharp2cuda_temp_119, csharp2cuda_temp_120, csharp2cuda_temp_121)) <= (0.0));
                                        }
                                        else
                                        {
#line 400 "GeometryModule.cs"
                                            csharp2cuda_temp_115 = false;
                                        }
                                        if (!(csharp2cuda_temp_115))
                                            break;
#line 404 "GeometryModule.cs"
                                        {
#line 405 "GeometryModule.cs"
#line 405 "GeometryModule.cs"
                                            int* csharp2cuda_temp_122 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_122));
                                        }
                                    }
#line 407 "GeometryModule.cs"
#line 407 "GeometryModule.cs"
                                    double* csharp2cuda_temp_123 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 407 "GeometryModule.cs"
                                    double csharp2cuda_temp_124 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_123) = csharp2cuda_temp_124);
#line 408 "GeometryModule.cs"
#line 408 "GeometryModule.cs"
                                    double* csharp2cuda_temp_125 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 408 "GeometryModule.cs"
                                    double csharp2cuda_temp_126 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_125) = csharp2cuda_temp_126);
#line 409 "GeometryModule.cs"
#line 409 "GeometryModule.cs"
                                    int* csharp2cuda_temp_127 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_127));
                                }
#line 398 "GeometryModule.cs"
                                int* csharp2cuda_temp_114 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_114));
                            }
                        }
#line 411 "GeometryModule.cs"
                        int lower_count = count;
#line 412 "GeometryModule.cs"
                        {
#line 412 "GeometryModule.cs"
                            int index = csharp2cuda_i32_sub(unique_count, 2);
                            while (true)
                            {
                                if (!(((index) >= (0))))
                                    break;
#line 413 "GeometryModule.cs"
                                {
#line 414 "GeometryModule.cs"
                                    while (true)
                                    {
#line 414 "GeometryModule.cs"
                                        bool csharp2cuda_temp_129;
#line 414 "GeometryModule.cs"
                                        if (((count) > (lower_count)))
                                        {
#line 415 "GeometryModule.cs"
                                            double csharp2cuda_temp_130 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 415 "GeometryModule.cs"
                                            double csharp2cuda_temp_131 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 416 "GeometryModule.cs"
                                            double csharp2cuda_temp_132 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 416 "GeometryModule.cs"
                                            double csharp2cuda_temp_133 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 417 "GeometryModule.cs"
                                            double csharp2cuda_temp_134 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 417 "GeometryModule.cs"
                                            double csharp2cuda_temp_135 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 414 "GeometryModule.cs"
                                            csharp2cuda_temp_129 = ((mathblocks_geometry_cross(csharp2cuda_temp_130, csharp2cuda_temp_131, csharp2cuda_temp_132, csharp2cuda_temp_133, csharp2cuda_temp_134, csharp2cuda_temp_135)) <= (0.0));
                                        }
                                        else
                                        {
#line 414 "GeometryModule.cs"
                                            csharp2cuda_temp_129 = false;
                                        }
                                        if (!(csharp2cuda_temp_129))
                                            break;
#line 418 "GeometryModule.cs"
                                        {
#line 419 "GeometryModule.cs"
#line 419 "GeometryModule.cs"
                                            int* csharp2cuda_temp_136 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_136));
                                        }
                                    }
#line 421 "GeometryModule.cs"
#line 421 "GeometryModule.cs"
                                    double* csharp2cuda_temp_137 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 421 "GeometryModule.cs"
                                    double csharp2cuda_temp_138 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_137) = csharp2cuda_temp_138);
#line 422 "GeometryModule.cs"
#line 422 "GeometryModule.cs"
                                    double* csharp2cuda_temp_139 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 422 "GeometryModule.cs"
                                    double csharp2cuda_temp_140 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_139) = csharp2cuda_temp_140);
#line 423 "GeometryModule.cs"
#line 423 "GeometryModule.cs"
                                    int* csharp2cuda_temp_141 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                                }
#line 412 "GeometryModule.cs"
                                int* csharp2cuda_temp_128 = &(index);
                                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_128));
                            }
                        }
#line 425 "GeometryModule.cs"
#line 425 "GeometryModule.cs"
                        int* csharp2cuda_temp_142 = &(count);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_142));
                    }
#line 427 "GeometryModule.cs"
#line 427 "GeometryModule.cs"
                    int* csharp2cuda_temp_143 = &((output)->rows);
                    (*(csharp2cuda_temp_143) = count);
#line 428 "GeometryModule.cs"
#line 428 "GeometryModule.cs"
                    int* csharp2cuda_temp_144 = &((output)->count);
                    (*(csharp2cuda_temp_144) = count);
#line 429 "GeometryModule.cs"
#line 429 "GeometryModule.cs"
                    int csharp2cuda_temp_145 = (output)->capacity;
                    if (((count) > (csharp2cuda_temp_145)))
#line 430 "GeometryModule.cs"
                    {
#line 431 "GeometryModule.cs"
#line 431 "GeometryModule.cs"
                        int* csharp2cuda_temp_146 = &((output)->valid);
                        (*(csharp2cuda_temp_146) = 0);
#line 432 "GeometryModule.cs"
                        break;
                    }
#line 434 "GeometryModule.cs"
                    {
#line 434 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, 2)))))
                                break;
#line 435 "GeometryModule.cs"
#line 435 "GeometryModule.cs"
                            double* csharp2cuda_temp_148 = &((result)[index]);
#line 435 "GeometryModule.cs"
                            double csharp2cuda_temp_149 = (hull)[index];
                            (*(csharp2cuda_temp_148) = csharp2cuda_temp_149);
#line 434 "GeometryModule.cs"
                            int* csharp2cuda_temp_147 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_147));
                        }
                    }
#line 436 "GeometryModule.cs"
                    break;
                }
#line 438 "GeometryModule.cs"
            case 5:
#line 439 "GeometryModule.cs"
#line 439 "GeometryModule.cs"
                int csharp2cuda_temp_150 = (first)->count;
#line 439 "GeometryModule.cs"
                bool csharp2cuda_temp_151;
#line 439 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_150) < (2))))
                {
#line 439 "GeometryModule.cs"
                    csharp2cuda_temp_151 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 439 "GeometryModule.cs"
                    csharp2cuda_temp_151 = true;
                }
                if (csharp2cuda_temp_151)
#line 440 "GeometryModule.cs"
                {
#line 441 "GeometryModule.cs"
#line 441 "GeometryModule.cs"
                    int* csharp2cuda_temp_152 = &((output)->valid);
                    (*(csharp2cuda_temp_152) = 0);
#line 442 "GeometryModule.cs"
                    break;
                }
#line 444 "GeometryModule.cs"
                {
#line 445 "GeometryModule.cs"
                    int count = (first)->count;
#line 446 "GeometryModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 447 "GeometryModule.cs"
                    int* ordered = csharp2cuda_pointer_add(adjacency, csharp2cuda_i32_mul(count, count));
#line 448 "GeometryModule.cs"
                    {
#line 448 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 449 "GeometryModule.cs"
#line 449 "GeometryModule.cs"
                            int* csharp2cuda_temp_154 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_154) = 0);
#line 448 "GeometryModule.cs"
                            int* csharp2cuda_temp_153 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                        }
                    }
#line 450 "GeometryModule.cs"
                    {
#line 450 "GeometryModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (count))))
                                break;
#line 451 "GeometryModule.cs"
                            {
#line 452 "GeometryModule.cs"
                                {
#line 452 "GeometryModule.cs"
                                    int second_index = csharp2cuda_i32_add(first_index, 1);
                                    while (true)
                                    {
                                        if (!(((second_index) < (count))))
                                            break;
#line 453 "GeometryModule.cs"
                                        {
#line 454 "GeometryModule.cs"
                                            {
#line 454 "GeometryModule.cs"
                                                int third_index = csharp2cuda_i32_add(second_index, 1);
                                                while (true)
                                                {
                                                    if (!(((third_index) < (count))))
                                                        break;
#line 455 "GeometryModule.cs"
                                                    {
#line 456 "GeometryModule.cs"
                                                        double center_x;
#line 457 "GeometryModule.cs"
                                                        double center_y;
#line 458 "GeometryModule.cs"
                                                        double radius_square;
#line 459 "GeometryModule.cs"
#line 461 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_158 = &(center_x);
#line 461 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_159 = &(center_y);
#line 461 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_160 = &(radius_square);
#line 459 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_161 = mathblocks_geometry_try_circumcircle(a, first_index, second_index, third_index, csharp2cuda_temp_158, csharp2cuda_temp_159, csharp2cuda_temp_160);
                                                        if ((!(csharp2cuda_temp_161)))
#line 462 "GeometryModule.cs"
                                                        {
#line 463 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 465 "GeometryModule.cs"
                                                        bool empty = true;
#line 466 "GeometryModule.cs"
                                                        {
#line 466 "GeometryModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
                                                                if (!(((index) < (count))))
                                                                    break;
#line 467 "GeometryModule.cs"
                                                                {
#line 468 "GeometryModule.cs"
#line 468 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_163;
#line 468 "GeometryModule.cs"
                                                                    if (!(((index) == (first_index))))
                                                                    {
#line 468 "GeometryModule.cs"
                                                                        csharp2cuda_temp_163 = ((index) == (second_index));
                                                                    }
                                                                    else
                                                                    {
#line 468 "GeometryModule.cs"
                                                                        csharp2cuda_temp_163 = true;
                                                                    }
#line 468 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_164;
#line 468 "GeometryModule.cs"
                                                                    if (!(csharp2cuda_temp_163))
                                                                    {
#line 468 "GeometryModule.cs"
                                                                        csharp2cuda_temp_164 = ((index) == (third_index));
                                                                    }
                                                                    else
                                                                    {
#line 468 "GeometryModule.cs"
                                                                        csharp2cuda_temp_164 = true;
                                                                    }
                                                                    if (csharp2cuda_temp_164)
                                                                    {
#line 469 "GeometryModule.cs"
                                                                        goto csharp2cuda_for_continue_9;
                                                                    }
#line 470 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_165 = (a)[csharp2cuda_i32_mul(2, index)];
#line 470 "GeometryModule.cs"
                                                                    double x = __dsub_rn(csharp2cuda_temp_165, center_x);
#line 471 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_166 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 471 "GeometryModule.cs"
                                                                    double y = __dsub_rn(csharp2cuda_temp_166, center_y);
#line 472 "GeometryModule.cs"
                                                                    if (((__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y))) < (radius_square)))
#line 473 "GeometryModule.cs"
                                                                    {
#line 474 "GeometryModule.cs"
#line 474 "GeometryModule.cs"
                                                                        bool* csharp2cuda_temp_167 = &(empty);
                                                                        (*(csharp2cuda_temp_167) = false);
#line 475 "GeometryModule.cs"
                                                                        break;
                                                                    }
                                                                }
                                                                csharp2cuda_for_continue_9:
#line 466 "GeometryModule.cs"
                                                                int* csharp2cuda_temp_162 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_162));
                                                            }
                                                        }
#line 478 "GeometryModule.cs"
                                                        if ((!(empty)))
                                                        {
#line 479 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 480 "GeometryModule.cs"
#line 480 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_168 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), second_index)]);
                                                        (*(csharp2cuda_temp_168) = 1);
#line 481 "GeometryModule.cs"
#line 481 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_169 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_169) = 1);
#line 482 "GeometryModule.cs"
#line 482 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_170 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_170) = 1);
                                                    }
                                                    csharp2cuda_for_continue_10:
#line 454 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_157 = &(third_index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_157));
                                                }
                                            }
                                        }
#line 452 "GeometryModule.cs"
                                        int* csharp2cuda_temp_156 = &(second_index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                                    }
                                }
                            }
#line 450 "GeometryModule.cs"
                            int* csharp2cuda_temp_155 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_155));
                        }
                    }
#line 486 "GeometryModule.cs"
                    int edge_count = 0;
#line 487 "GeometryModule.cs"
                    {
#line 487 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 488 "GeometryModule.cs"
                            {
#line 488 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (count))))
                                        break;
#line 489 "GeometryModule.cs"
#line 489 "GeometryModule.cs"
                                    int* csharp2cuda_temp_173 = &(edge_count);
#line 489 "GeometryModule.cs"
                                    int csharp2cuda_temp_174 = *(csharp2cuda_temp_173);
#line 489 "GeometryModule.cs"
                                    int csharp2cuda_temp_175 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                    (*(csharp2cuda_temp_173) = csharp2cuda_i32_add(csharp2cuda_temp_174, csharp2cuda_temp_175));
#line 488 "GeometryModule.cs"
                                    int* csharp2cuda_temp_172 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_172));
                                }
                            }
#line 487 "GeometryModule.cs"
                            int* csharp2cuda_temp_171 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_171));
                        }
                    }
#line 490 "GeometryModule.cs"
                    if (((edge_count) == (0)))
#line 491 "GeometryModule.cs"
                    {
#line 492 "GeometryModule.cs"
                        mathblocks_geometry_sort_indices(a, count, ordered);
#line 493 "GeometryModule.cs"
                        {
#line 493 "GeometryModule.cs"
                            int index = 1;
                            while (true)
                            {
                                if (!(((index) < (count))))
                                    break;
#line 494 "GeometryModule.cs"
                                {
#line 495 "GeometryModule.cs"
                                    int csharp2cuda_temp_177 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 495 "GeometryModule.cs"
                                    int csharp2cuda_temp_178 = (ordered)[index];
#line 495 "GeometryModule.cs"
                                    int csharp2cuda_temp_179;
#line 495 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_177) < (csharp2cuda_temp_178)))
                                    {
#line 495 "GeometryModule.cs"
                                        csharp2cuda_temp_179 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
                                    else
                                    {
#line 495 "GeometryModule.cs"
                                        csharp2cuda_temp_179 = (ordered)[index];
                                    }
#line 495 "GeometryModule.cs"
                                    int left = csharp2cuda_temp_179;
#line 498 "GeometryModule.cs"
                                    int csharp2cuda_temp_180 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 498 "GeometryModule.cs"
                                    int csharp2cuda_temp_181 = (ordered)[index];
#line 498 "GeometryModule.cs"
                                    int csharp2cuda_temp_182;
#line 498 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_180) < (csharp2cuda_temp_181)))
                                    {
#line 498 "GeometryModule.cs"
                                        csharp2cuda_temp_182 = (ordered)[index];
                                    }
                                    else
                                    {
#line 498 "GeometryModule.cs"
                                        csharp2cuda_temp_182 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
#line 498 "GeometryModule.cs"
                                    int right = csharp2cuda_temp_182;
#line 501 "GeometryModule.cs"
#line 501 "GeometryModule.cs"
                                    int* csharp2cuda_temp_183 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)]);
                                    (*(csharp2cuda_temp_183) = 1);
                                }
#line 493 "GeometryModule.cs"
                                int* csharp2cuda_temp_176 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_176));
                            }
                        }
                    }
#line 504 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_184 = (output)->data_pointer;
#line 504 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_184));
#line 505 "GeometryModule.cs"
#line 505 "GeometryModule.cs"
                    int* csharp2cuda_temp_185 = &(edge_count);
                    (*(csharp2cuda_temp_185) = 0);
#line 506 "GeometryModule.cs"
                    {
#line 506 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 507 "GeometryModule.cs"
                            {
#line 508 "GeometryModule.cs"
                                {
#line 508 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
                                        if (!(((right) < (count))))
                                            break;
#line 509 "GeometryModule.cs"
                                        {
#line 510 "GeometryModule.cs"
#line 510 "GeometryModule.cs"
                                            int csharp2cuda_temp_188 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                            if ((!(((csharp2cuda_temp_188) != 0))))
                                            {
#line 511 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_16;
                                            }
#line 512 "GeometryModule.cs"
#line 512 "GeometryModule.cs"
                                            int csharp2cuda_temp_189 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_189)))
#line 513 "GeometryModule.cs"
                                            {
#line 514 "GeometryModule.cs"
#line 514 "GeometryModule.cs"
                                                int* csharp2cuda_temp_190 = &((output)->count);
#line 514 "GeometryModule.cs"
                                                int csharp2cuda_temp_191 = (output)->capacity;
#line 514 "GeometryModule.cs"
                                                int csharp2cuda_temp_192;
#line 514 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_191) == (2147483647)))
                                                {
#line 514 "GeometryModule.cs"
                                                    csharp2cuda_temp_192 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 516 "GeometryModule.cs"
                                                    int csharp2cuda_temp_193 = (output)->capacity;
#line 514 "GeometryModule.cs"
                                                    csharp2cuda_temp_192 = csharp2cuda_i32_add(csharp2cuda_temp_193, 1);
                                                }
                                                (*(csharp2cuda_temp_190) = csharp2cuda_temp_192);
#line 517 "GeometryModule.cs"
#line 517 "GeometryModule.cs"
                                                int* csharp2cuda_temp_194 = &((output)->valid);
                                                (*(csharp2cuda_temp_194) = 0);
#line 518 "GeometryModule.cs"
                                                break;
                                            }
#line 520 "GeometryModule.cs"
#line 520 "GeometryModule.cs"
                                            int* csharp2cuda_temp_195 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_195) = left);
#line 521 "GeometryModule.cs"
#line 521 "GeometryModule.cs"
                                            int* csharp2cuda_temp_196 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_196) = right);
#line 522 "GeometryModule.cs"
#line 522 "GeometryModule.cs"
                                            double* csharp2cuda_temp_197 = &(((edges)[edge_count]).weight);
#line 522 "GeometryModule.cs"
                                            double csharp2cuda_temp_198 = mathblocks_geometry_distance(a, left, a, right);
                                            (*(csharp2cuda_temp_197) = csharp2cuda_temp_198);
#line 523 "GeometryModule.cs"
#line 523 "GeometryModule.cs"
                                            double csharp2cuda_temp_199 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_199))))
                                            {
#line 523 "GeometryModule.cs"
#line 523 "GeometryModule.cs"
                                                int* csharp2cuda_temp_200 = &((output)->valid);
                                                (*(csharp2cuda_temp_200) = 0);
                                            }
#line 524 "GeometryModule.cs"
#line 524 "GeometryModule.cs"
                                            int* csharp2cuda_temp_201 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_201));
                                        }
                                        csharp2cuda_for_continue_16:
#line 508 "GeometryModule.cs"
                                        int* csharp2cuda_temp_187 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_187));
                                    }
                                }
                            }
#line 506 "GeometryModule.cs"
                            int* csharp2cuda_temp_186 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_186));
                        }
                    }
#line 527 "GeometryModule.cs"
#line 527 "GeometryModule.cs"
                    int* csharp2cuda_temp_202 = &((output)->rows);
                    (*(csharp2cuda_temp_202) = count);
#line 528 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 529 "GeometryModule.cs"
#line 529 "GeometryModule.cs"
                        int* csharp2cuda_temp_203 = &((output)->count);
                        (*(csharp2cuda_temp_203) = edge_count);
                    }
#line 530 "GeometryModule.cs"
                    break;
                }
#line 532 "GeometryModule.cs"
            case 6:
#line 533 "GeometryModule.cs"
#line 533 "GeometryModule.cs"
                int csharp2cuda_temp_204 = (first)->count;
                if (((csharp2cuda_temp_204) <= (0)))
#line 534 "GeometryModule.cs"
                {
#line 535 "GeometryModule.cs"
#line 535 "GeometryModule.cs"
                    int* csharp2cuda_temp_205 = &((output)->valid);
                    (*(csharp2cuda_temp_205) = 0);
#line 536 "GeometryModule.cs"
                    break;
                }
#line 538 "GeometryModule.cs"
                {
#line 539 "GeometryModule.cs"
                    double maximum = 0.0;
#line 540 "GeometryModule.cs"
                    {
#line 540 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 540 "GeometryModule.cs"
                            int csharp2cuda_temp_207 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_207))))
                                break;
#line 541 "GeometryModule.cs"
                            {
#line 541 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
#line 541 "GeometryModule.cs"
                                    int csharp2cuda_temp_209 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_209))))
                                        break;
#line 542 "GeometryModule.cs"
                                    {
#line 543 "GeometryModule.cs"
                                        double distance = mathblocks_geometry_distance(a, left, a, right);
#line 544 "GeometryModule.cs"
#line 544 "GeometryModule.cs"
                                        double* csharp2cuda_temp_210 = &(maximum);
#line 544 "GeometryModule.cs"
                                        double csharp2cuda_temp_211;
#line 544 "GeometryModule.cs"
                                        if (((maximum) > (distance)))
                                        {
#line 544 "GeometryModule.cs"
                                            csharp2cuda_temp_211 = maximum;
                                        }
                                        else
                                        {
#line 544 "GeometryModule.cs"
                                            csharp2cuda_temp_211 = distance;
                                        }
                                        (*(csharp2cuda_temp_210) = csharp2cuda_temp_211);
                                    }
#line 541 "GeometryModule.cs"
                                    int* csharp2cuda_temp_208 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_208));
                                }
                            }
#line 540 "GeometryModule.cs"
                            int* csharp2cuda_temp_206 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_206));
                        }
                    }
#line 546 "GeometryModule.cs"
#line 546 "GeometryModule.cs"
                    double* csharp2cuda_temp_212 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_212) = maximum);
#line 547 "GeometryModule.cs"
                    break;
                }
#line 549 "GeometryModule.cs"
            case 7:
#line 550 "GeometryModule.cs"
#line 550 "GeometryModule.cs"
                int csharp2cuda_temp_213 = (first)->count;
#line 550 "GeometryModule.cs"
                bool csharp2cuda_temp_214;
#line 550 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_213) <= (0))))
                {
#line 550 "GeometryModule.cs"
                    int csharp2cuda_temp_215 = (second)->count;
#line 550 "GeometryModule.cs"
                    csharp2cuda_temp_214 = ((csharp2cuda_temp_215) <= (0));
                }
                else
                {
#line 550 "GeometryModule.cs"
                    csharp2cuda_temp_214 = true;
                }
#line 550 "GeometryModule.cs"
                bool csharp2cuda_temp_216;
#line 550 "GeometryModule.cs"
                if (!(csharp2cuda_temp_214))
                {
#line 550 "GeometryModule.cs"
                    csharp2cuda_temp_216 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 550 "GeometryModule.cs"
                    csharp2cuda_temp_216 = true;
                }
                if (csharp2cuda_temp_216)
#line 551 "GeometryModule.cs"
                {
#line 552 "GeometryModule.cs"
#line 552 "GeometryModule.cs"
                    int* csharp2cuda_temp_217 = &((output)->valid);
                    (*(csharp2cuda_temp_217) = 0);
#line 553 "GeometryModule.cs"
                    break;
                }
#line 555 "GeometryModule.cs"
                {
#line 556 "GeometryModule.cs"
                    {
#line 556 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 556 "GeometryModule.cs"
                            int csharp2cuda_temp_219 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_219))))
                                break;
#line 557 "GeometryModule.cs"
                            {
#line 558 "GeometryModule.cs"
                                {
#line 558 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 558 "GeometryModule.cs"
                                        int csharp2cuda_temp_221 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_221))))
                                            break;
#line 559 "GeometryModule.cs"
                                        {
#line 560 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 561 "GeometryModule.cs"
                                            int csharp2cuda_temp_222 = (second)->count;
#line 561 "GeometryModule.cs"
                                            int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_222), right);
#line 562 "GeometryModule.cs"
#line 562 "GeometryModule.cs"
                                            bool csharp2cuda_temp_223;
#line 562 "GeometryModule.cs"
                                            if (((left) == (0)))
                                            {
#line 562 "GeometryModule.cs"
                                                csharp2cuda_temp_223 = ((right) == (0));
                                            }
                                            else
                                            {
#line 562 "GeometryModule.cs"
                                                csharp2cuda_temp_223 = false;
                                            }
                                            if (csharp2cuda_temp_223)
                                            {
#line 563 "GeometryModule.cs"
#line 563 "GeometryModule.cs"
                                                double* csharp2cuda_temp_224 = &((scratch)[0]);
                                                (*(csharp2cuda_temp_224) = distance);
                                            }
                                            else
                                            {
#line 564 "GeometryModule.cs"
                                                if (((left) == (0)))
                                                {
#line 565 "GeometryModule.cs"
#line 565 "GeometryModule.cs"
                                                    double* csharp2cuda_temp_225 = &((scratch)[right]);
#line 565 "GeometryModule.cs"
                                                    double csharp2cuda_temp_226 = (scratch)[csharp2cuda_i32_sub(right, 1)];
#line 565 "GeometryModule.cs"
                                                    double csharp2cuda_temp_227;
#line 565 "GeometryModule.cs"
                                                    if (((csharp2cuda_temp_226) > (distance)))
                                                    {
#line 565 "GeometryModule.cs"
                                                        csharp2cuda_temp_227 = (scratch)[csharp2cuda_i32_sub(right, 1)];
                                                    }
                                                    else
                                                    {
#line 565 "GeometryModule.cs"
                                                        csharp2cuda_temp_227 = distance;
                                                    }
                                                    (*(csharp2cuda_temp_225) = csharp2cuda_temp_227);
                                                }
                                                else
                                                {
#line 568 "GeometryModule.cs"
                                                    if (((right) == (0)))
                                                    {
#line 569 "GeometryModule.cs"
#line 569 "GeometryModule.cs"
                                                        int csharp2cuda_temp_228 = (second)->count;
#line 569 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_229 = &((scratch)[csharp2cuda_i32_mul(left, csharp2cuda_temp_228)]);
#line 569 "GeometryModule.cs"
                                                        int csharp2cuda_temp_230 = (second)->count;
#line 569 "GeometryModule.cs"
                                                        double csharp2cuda_temp_231 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_230)];
#line 569 "GeometryModule.cs"
                                                        double csharp2cuda_temp_232;
#line 569 "GeometryModule.cs"
                                                        if (((csharp2cuda_temp_231) > (distance)))
                                                        {
#line 570 "GeometryModule.cs"
                                                            int csharp2cuda_temp_233 = (second)->count;
#line 569 "GeometryModule.cs"
                                                            csharp2cuda_temp_232 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_233)];
                                                        }
                                                        else
                                                        {
#line 569 "GeometryModule.cs"
                                                            csharp2cuda_temp_232 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_229) = csharp2cuda_temp_232);
                                                    }
                                                    else
#line 573 "GeometryModule.cs"
                                                    {
#line 574 "GeometryModule.cs"
                                                        int csharp2cuda_temp_234 = (second)->count;
#line 574 "GeometryModule.cs"
                                                        double preceding = (scratch)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_234), right)];
#line 575 "GeometryModule.cs"
                                                        int csharp2cuda_temp_235 = (second)->count;
#line 575 "GeometryModule.cs"
                                                        double candidate = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_235), right), 1)];
#line 576 "GeometryModule.cs"
#line 576 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_236 = &(preceding);
#line 576 "GeometryModule.cs"
                                                        double csharp2cuda_temp_237;
#line 576 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 576 "GeometryModule.cs"
                                                            csharp2cuda_temp_237 = preceding;
                                                        }
                                                        else
                                                        {
#line 576 "GeometryModule.cs"
                                                            csharp2cuda_temp_237 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_236) = csharp2cuda_temp_237);
#line 577 "GeometryModule.cs"
#line 577 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_238 = &(candidate);
#line 577 "GeometryModule.cs"
                                                        int csharp2cuda_temp_239 = (second)->count;
#line 577 "GeometryModule.cs"
                                                        double csharp2cuda_temp_240 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_239), right), 1)];
                                                        (*(csharp2cuda_temp_238) = csharp2cuda_temp_240);
#line 578 "GeometryModule.cs"
#line 578 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_241 = &(preceding);
#line 578 "GeometryModule.cs"
                                                        double csharp2cuda_temp_242;
#line 578 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 578 "GeometryModule.cs"
                                                            csharp2cuda_temp_242 = preceding;
                                                        }
                                                        else
                                                        {
#line 578 "GeometryModule.cs"
                                                            csharp2cuda_temp_242 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_241) = csharp2cuda_temp_242);
#line 579 "GeometryModule.cs"
#line 579 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_243 = &((scratch)[target]);
#line 579 "GeometryModule.cs"
                                                        double csharp2cuda_temp_244;
#line 579 "GeometryModule.cs"
                                                        if (((preceding) > (distance)))
                                                        {
#line 579 "GeometryModule.cs"
                                                            csharp2cuda_temp_244 = preceding;
                                                        }
                                                        else
                                                        {
#line 579 "GeometryModule.cs"
                                                            csharp2cuda_temp_244 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_243) = csharp2cuda_temp_244);
                                                    }
                                                }
                                            }
                                        }
#line 558 "GeometryModule.cs"
                                        int* csharp2cuda_temp_220 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_220));
                                    }
                                }
                            }
#line 556 "GeometryModule.cs"
                            int* csharp2cuda_temp_218 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_218));
                        }
                    }
#line 583 "GeometryModule.cs"
#line 583 "GeometryModule.cs"
                    double* csharp2cuda_temp_245 = &((output)->scalar_value);
#line 583 "GeometryModule.cs"
                    int csharp2cuda_temp_246 = (first)->count;
#line 583 "GeometryModule.cs"
                    int csharp2cuda_temp_247 = (second)->count;
#line 583 "GeometryModule.cs"
                    double csharp2cuda_temp_248 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_mul(csharp2cuda_temp_246, csharp2cuda_temp_247), 1)];
                    (*(csharp2cuda_temp_245) = csharp2cuda_temp_248);
#line 584 "GeometryModule.cs"
                    break;
                }
#line 586 "GeometryModule.cs"
            case 8:
#line 587 "GeometryModule.cs"
#line 587 "GeometryModule.cs"
                int csharp2cuda_temp_249 = (first)->count;
#line 587 "GeometryModule.cs"
                bool csharp2cuda_temp_250;
#line 587 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_249) <= (0))))
                {
#line 587 "GeometryModule.cs"
                    int csharp2cuda_temp_251 = (second)->count;
#line 587 "GeometryModule.cs"
                    csharp2cuda_temp_250 = ((csharp2cuda_temp_251) <= (0));
                }
                else
                {
#line 587 "GeometryModule.cs"
                    csharp2cuda_temp_250 = true;
                }
                if (csharp2cuda_temp_250)
                {
#line 588 "GeometryModule.cs"
#line 588 "GeometryModule.cs"
                    int* csharp2cuda_temp_252 = &((output)->valid);
                    (*(csharp2cuda_temp_252) = 0);
                }
                else
                {
#line 590 "GeometryModule.cs"
#line 590 "GeometryModule.cs"
                    double* csharp2cuda_temp_253 = &((output)->scalar_value);
#line 590 "GeometryModule.cs"
                    double csharp2cuda_temp_254 = mathblocks_geometry_distance(a, 0, b, 0);
                    (*(csharp2cuda_temp_253) = csharp2cuda_temp_254);
                }
#line 591 "GeometryModule.cs"
                break;
#line 592 "GeometryModule.cs"
            case 9:
#line 593 "GeometryModule.cs"
#line 593 "GeometryModule.cs"
                int csharp2cuda_temp_255 = (first)->count;
#line 593 "GeometryModule.cs"
                bool csharp2cuda_temp_256;
#line 593 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_255) <= (0))))
                {
#line 593 "GeometryModule.cs"
                    int csharp2cuda_temp_257 = (first)->count;
#line 593 "GeometryModule.cs"
                    int csharp2cuda_temp_258 = (second)->count;
#line 593 "GeometryModule.cs"
                    csharp2cuda_temp_256 = ((csharp2cuda_temp_257) != (csharp2cuda_temp_258));
                }
                else
                {
#line 593 "GeometryModule.cs"
                    csharp2cuda_temp_256 = true;
                }
                if (csharp2cuda_temp_256)
#line 594 "GeometryModule.cs"
                {
#line 595 "GeometryModule.cs"
#line 595 "GeometryModule.cs"
                    int* csharp2cuda_temp_259 = &((output)->valid);
                    (*(csharp2cuda_temp_259) = 0);
#line 596 "GeometryModule.cs"
                    break;
                }
#line 598 "GeometryModule.cs"
                {
#line 599 "GeometryModule.cs"
                    double affinity = 0.0;
#line 600 "GeometryModule.cs"
                    {
#line 600 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 600 "GeometryModule.cs"
                            int csharp2cuda_temp_261 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_261))))
                                break;
#line 601 "GeometryModule.cs"
#line 601 "GeometryModule.cs"
                            double* csharp2cuda_temp_262 = &(affinity);
#line 601 "GeometryModule.cs"
                            double csharp2cuda_temp_263 = *(csharp2cuda_temp_262);
#line 601 "GeometryModule.cs"
                            double csharp2cuda_temp_264 = (a)[index];
#line 601 "GeometryModule.cs"
                            double csharp2cuda_temp_265 = (b)[index];
                            (*(csharp2cuda_temp_262) = __dadd_rn(csharp2cuda_temp_263, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_264, csharp2cuda_temp_265))));
#line 600 "GeometryModule.cs"
                            int* csharp2cuda_temp_260 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_260));
                        }
                    }
#line 602 "GeometryModule.cs"
#line 602 "GeometryModule.cs"
                    double* csharp2cuda_temp_266 = &(affinity);
#line 602 "GeometryModule.cs"
                    double csharp2cuda_temp_267;
#line 602 "GeometryModule.cs"
                    if (((affinity) < ((-(1.0)))))
                    {
#line 602 "GeometryModule.cs"
                        csharp2cuda_temp_267 = (-(1.0));
                    }
                    else
                    {
#line 602 "GeometryModule.cs"
                        double csharp2cuda_temp_268;
#line 602 "GeometryModule.cs"
                        if (((affinity) > (1.0)))
                        {
#line 602 "GeometryModule.cs"
                            csharp2cuda_temp_268 = 1.0;
                        }
                        else
                        {
#line 602 "GeometryModule.cs"
                            csharp2cuda_temp_268 = affinity;
                        }
#line 602 "GeometryModule.cs"
                        csharp2cuda_temp_267 = csharp2cuda_temp_268;
                    }
                    (*(csharp2cuda_temp_266) = csharp2cuda_temp_267);
#line 603 "GeometryModule.cs"
#line 603 "GeometryModule.cs"
                    double* csharp2cuda_temp_269 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_269) = __dmul_rn(2.0, mathblocks_arc_cosine(affinity)));
#line 604 "GeometryModule.cs"
                    break;
                }
#line 606 "GeometryModule.cs"
            case 10:
#line 607 "GeometryModule.cs"
#line 607 "GeometryModule.cs"
                int csharp2cuda_temp_270 = (first)->count;
                if (((csharp2cuda_temp_270) < (2)))
#line 608 "GeometryModule.cs"
                {
#line 609 "GeometryModule.cs"
#line 609 "GeometryModule.cs"
                    int* csharp2cuda_temp_271 = &((output)->valid);
                    (*(csharp2cuda_temp_271) = 0);
#line 610 "GeometryModule.cs"
                    break;
                }
#line 612 "GeometryModule.cs"
                {
#line 613 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_272 = (output)->data_pointer;
#line 613 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_272));
#line 614 "GeometryModule.cs"
                    int edge_count = 0;
#line 615 "GeometryModule.cs"
                    {
#line 615 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 615 "GeometryModule.cs"
                            int csharp2cuda_temp_274 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_274))))
                                break;
#line 616 "GeometryModule.cs"
                            {
#line 617 "GeometryModule.cs"
                                {
#line 617 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 617 "GeometryModule.cs"
                                        int csharp2cuda_temp_276 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_276))))
                                            break;
#line 618 "GeometryModule.cs"
                                        {
#line 619 "GeometryModule.cs"
                                            double csharp2cuda_temp_277 = (a)[csharp2cuda_i32_mul(2, left)];
#line 619 "GeometryModule.cs"
                                            double csharp2cuda_temp_278 = (a)[csharp2cuda_i32_mul(2, right)];
#line 619 "GeometryModule.cs"
                                            double center_x = __ddiv_rn(__dadd_rn(csharp2cuda_temp_277, csharp2cuda_temp_278), 2.0);
#line 620 "GeometryModule.cs"
                                            double csharp2cuda_temp_279 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 620 "GeometryModule.cs"
                                            double csharp2cuda_temp_280 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 620 "GeometryModule.cs"
                                            double center_y = __ddiv_rn(__dadd_rn(csharp2cuda_temp_279, csharp2cuda_temp_280), 2.0);
#line 621 "GeometryModule.cs"
                                            double csharp2cuda_temp_281 = mathblocks_geometry_distance(a, left, a, right);
#line 621 "GeometryModule.cs"
                                            double radius = __ddiv_rn(csharp2cuda_temp_281, 2.0);
#line 622 "GeometryModule.cs"
                                            bool empty = true;
#line 623 "GeometryModule.cs"
                                            {
#line 623 "GeometryModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
#line 623 "GeometryModule.cs"
                                                    int csharp2cuda_temp_283 = (first)->count;
                                                    if (!(((index) < (csharp2cuda_temp_283))))
                                                        break;
#line 624 "GeometryModule.cs"
                                                    {
#line 625 "GeometryModule.cs"
#line 625 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_284;
#line 625 "GeometryModule.cs"
                                                        if (((index) != (left)))
                                                        {
#line 625 "GeometryModule.cs"
                                                            csharp2cuda_temp_284 = ((index) != (right));
                                                        }
                                                        else
                                                        {
#line 625 "GeometryModule.cs"
                                                            csharp2cuda_temp_284 = false;
                                                        }
#line 625 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_285;
#line 625 "GeometryModule.cs"
                                                        if (csharp2cuda_temp_284)
                                                        {
#line 627 "GeometryModule.cs"
                                                            double csharp2cuda_temp_286 = (a)[csharp2cuda_i32_mul(2, index)];
#line 627 "GeometryModule.cs"
                                                            double csharp2cuda_temp_287 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 625 "GeometryModule.cs"
                                                            csharp2cuda_temp_285 = ((mathblocks_geometry_distance_coordinates(csharp2cuda_temp_286, csharp2cuda_temp_287, center_x, center_y)) < (radius));
                                                        }
                                                        else
                                                        {
#line 625 "GeometryModule.cs"
                                                            csharp2cuda_temp_285 = false;
                                                        }
                                                        if (csharp2cuda_temp_285)
#line 628 "GeometryModule.cs"
                                                        {
#line 629 "GeometryModule.cs"
#line 629 "GeometryModule.cs"
                                                            bool* csharp2cuda_temp_288 = &(empty);
                                                            (*(csharp2cuda_temp_288) = false);
#line 630 "GeometryModule.cs"
                                                            break;
                                                        }
                                                    }
#line 623 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_282 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_282));
                                                }
                                            }
#line 633 "GeometryModule.cs"
                                            if ((!(empty)))
                                            {
#line 634 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_24;
                                            }
#line 635 "GeometryModule.cs"
#line 635 "GeometryModule.cs"
                                            int csharp2cuda_temp_289 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_289)))
#line 636 "GeometryModule.cs"
                                            {
#line 637 "GeometryModule.cs"
#line 637 "GeometryModule.cs"
                                                int* csharp2cuda_temp_290 = &((output)->count);
#line 637 "GeometryModule.cs"
                                                int csharp2cuda_temp_291 = (output)->capacity;
#line 637 "GeometryModule.cs"
                                                int csharp2cuda_temp_292;
#line 637 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_291) == (2147483647)))
                                                {
#line 637 "GeometryModule.cs"
                                                    csharp2cuda_temp_292 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 639 "GeometryModule.cs"
                                                    int csharp2cuda_temp_293 = (output)->capacity;
#line 637 "GeometryModule.cs"
                                                    csharp2cuda_temp_292 = csharp2cuda_i32_add(csharp2cuda_temp_293, 1);
                                                }
                                                (*(csharp2cuda_temp_290) = csharp2cuda_temp_292);
#line 640 "GeometryModule.cs"
#line 640 "GeometryModule.cs"
                                                int* csharp2cuda_temp_294 = &((output)->valid);
                                                (*(csharp2cuda_temp_294) = 0);
#line 641 "GeometryModule.cs"
                                                break;
                                            }
#line 643 "GeometryModule.cs"
#line 643 "GeometryModule.cs"
                                            int* csharp2cuda_temp_295 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_295) = left);
#line 644 "GeometryModule.cs"
#line 644 "GeometryModule.cs"
                                            int* csharp2cuda_temp_296 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_296) = right);
#line 645 "GeometryModule.cs"
#line 645 "GeometryModule.cs"
                                            double* csharp2cuda_temp_297 = &(((edges)[edge_count]).weight);
                                            (*(csharp2cuda_temp_297) = __dmul_rn(2.0, radius));
#line 646 "GeometryModule.cs"
#line 646 "GeometryModule.cs"
                                            double csharp2cuda_temp_298 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_298))))
                                            {
#line 646 "GeometryModule.cs"
#line 646 "GeometryModule.cs"
                                                int* csharp2cuda_temp_299 = &((output)->valid);
                                                (*(csharp2cuda_temp_299) = 0);
                                            }
#line 647 "GeometryModule.cs"
#line 647 "GeometryModule.cs"
                                            int* csharp2cuda_temp_300 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_300));
                                        }
                                        csharp2cuda_for_continue_24:
#line 617 "GeometryModule.cs"
                                        int* csharp2cuda_temp_275 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_275));
                                    }
                                }
                            }
#line 615 "GeometryModule.cs"
                            int* csharp2cuda_temp_273 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_273));
                        }
                    }
#line 650 "GeometryModule.cs"
#line 650 "GeometryModule.cs"
                    int* csharp2cuda_temp_301 = &((output)->rows);
#line 650 "GeometryModule.cs"
                    int csharp2cuda_temp_302 = (first)->count;
                    (*(csharp2cuda_temp_301) = csharp2cuda_temp_302);
#line 651 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 652 "GeometryModule.cs"
#line 652 "GeometryModule.cs"
                        int* csharp2cuda_temp_303 = &((output)->count);
                        (*(csharp2cuda_temp_303) = edge_count);
                    }
#line 653 "GeometryModule.cs"
                    break;
                }
#line 655 "GeometryModule.cs"
            case 11:
#line 656 "GeometryModule.cs"
#line 656 "GeometryModule.cs"
                int csharp2cuda_temp_304 = (first)->count;
#line 656 "GeometryModule.cs"
                bool csharp2cuda_temp_305;
#line 656 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_304) <= (0))))
                {
#line 656 "GeometryModule.cs"
                    int csharp2cuda_temp_306 = (second)->count;
#line 656 "GeometryModule.cs"
                    csharp2cuda_temp_305 = ((csharp2cuda_temp_306) != (1));
                }
                else
                {
#line 656 "GeometryModule.cs"
                    csharp2cuda_temp_305 = true;
                }
                if (csharp2cuda_temp_305)
#line 657 "GeometryModule.cs"
                {
#line 658 "GeometryModule.cs"
#line 658 "GeometryModule.cs"
                    int* csharp2cuda_temp_307 = &((output)->valid);
                    (*(csharp2cuda_temp_307) = 0);
#line 659 "GeometryModule.cs"
                    break;
                }
#line 661 "GeometryModule.cs"
                {
#line 662 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 663 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 664 "GeometryModule.cs"
                    int coincident = 0;
#line 665 "GeometryModule.cs"
                    int vector_count = 0;
#line 666 "GeometryModule.cs"
                    {
#line 666 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 666 "GeometryModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_309))))
                                break;
#line 667 "GeometryModule.cs"
                            {
#line 668 "GeometryModule.cs"
                                double csharp2cuda_temp_310 = (a)[csharp2cuda_i32_mul(2, index)];
#line 668 "GeometryModule.cs"
                                double x = __dsub_rn(csharp2cuda_temp_310, point_x);
#line 669 "GeometryModule.cs"
                                double csharp2cuda_temp_311 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 669 "GeometryModule.cs"
                                double y = __dsub_rn(csharp2cuda_temp_311, point_y);
#line 670 "GeometryModule.cs"
#line 670 "GeometryModule.cs"
                                bool csharp2cuda_temp_312;
#line 670 "GeometryModule.cs"
                                if (((x) == (0.0)))
                                {
#line 670 "GeometryModule.cs"
                                    csharp2cuda_temp_312 = ((y) == (0.0));
                                }
                                else
                                {
#line 670 "GeometryModule.cs"
                                    csharp2cuda_temp_312 = false;
                                }
                                if (csharp2cuda_temp_312)
                                {
#line 671 "GeometryModule.cs"
#line 671 "GeometryModule.cs"
                                    int* csharp2cuda_temp_313 = &(coincident);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_313));
                                }
                                else
                                {
#line 673 "GeometryModule.cs"
#line 673 "GeometryModule.cs"
                                    int* csharp2cuda_temp_314 = &(vector_count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                                }
                            }
#line 666 "GeometryModule.cs"
                            int* csharp2cuda_temp_308 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
#line 675 "GeometryModule.cs"
                    if (((vector_count) == (0)))
#line 676 "GeometryModule.cs"
                    {
#line 677 "GeometryModule.cs"
#line 677 "GeometryModule.cs"
                        double* csharp2cuda_temp_315 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_315) = 1.0);
#line 678 "GeometryModule.cs"
                        break;
                    }
#line 680 "GeometryModule.cs"
                    int maximum = 0;
#line 681 "GeometryModule.cs"
                    {
#line 681 "GeometryModule.cs"
                        int pivot = 0;
                        while (true)
                        {
#line 681 "GeometryModule.cs"
                            int csharp2cuda_temp_317 = (first)->count;
                            if (!(((pivot) < (csharp2cuda_temp_317))))
                                break;
#line 682 "GeometryModule.cs"
                            {
#line 683 "GeometryModule.cs"
                                double csharp2cuda_temp_318 = (a)[csharp2cuda_i32_mul(2, pivot)];
#line 683 "GeometryModule.cs"
                                double pivot_x = __dsub_rn(csharp2cuda_temp_318, point_x);
#line 684 "GeometryModule.cs"
                                double csharp2cuda_temp_319 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, pivot), 1)];
#line 684 "GeometryModule.cs"
                                double pivot_y = __dsub_rn(csharp2cuda_temp_319, point_y);
#line 685 "GeometryModule.cs"
#line 685 "GeometryModule.cs"
                                bool csharp2cuda_temp_320;
#line 685 "GeometryModule.cs"
                                if (((pivot_x) == (0.0)))
                                {
#line 685 "GeometryModule.cs"
                                    csharp2cuda_temp_320 = ((pivot_y) == (0.0));
                                }
                                else
                                {
#line 685 "GeometryModule.cs"
                                    csharp2cuda_temp_320 = false;
                                }
                                if (csharp2cuda_temp_320)
                                {
#line 686 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_28;
                                }
#line 687 "GeometryModule.cs"
                                int count = 0;
#line 688 "GeometryModule.cs"
                                {
#line 688 "GeometryModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 688 "GeometryModule.cs"
                                        int csharp2cuda_temp_322 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_322))))
                                            break;
#line 689 "GeometryModule.cs"
                                        {
#line 690 "GeometryModule.cs"
                                            double csharp2cuda_temp_323 = (a)[csharp2cuda_i32_mul(2, index)];
#line 690 "GeometryModule.cs"
                                            double x = __dsub_rn(csharp2cuda_temp_323, point_x);
#line 691 "GeometryModule.cs"
                                            double csharp2cuda_temp_324 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 691 "GeometryModule.cs"
                                            double y = __dsub_rn(csharp2cuda_temp_324, point_y);
#line 692 "GeometryModule.cs"
#line 692 "GeometryModule.cs"
                                            bool csharp2cuda_temp_325;
#line 692 "GeometryModule.cs"
                                            if (((x) == (0.0)))
                                            {
#line 692 "GeometryModule.cs"
                                                csharp2cuda_temp_325 = ((y) == (0.0));
                                            }
                                            else
                                            {
#line 692 "GeometryModule.cs"
                                                csharp2cuda_temp_325 = false;
                                            }
                                            if (csharp2cuda_temp_325)
                                            {
#line 693 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_27;
                                            }
#line 694 "GeometryModule.cs"
                                            double cross = __dsub_rn(__dmul_rn(pivot_x, y), __dmul_rn(pivot_y, x));
#line 695 "GeometryModule.cs"
                                            double dot = __dadd_rn(__dmul_rn(pivot_x, x), __dmul_rn(pivot_y, y));
#line 696 "GeometryModule.cs"
#line 696 "GeometryModule.cs"
                                            bool csharp2cuda_temp_326;
#line 696 "GeometryModule.cs"
                                            if (!(((cross) > (0.0))))
                                            {
#line 696 "GeometryModule.cs"
                                                bool csharp2cuda_temp_327;
#line 696 "GeometryModule.cs"
                                                if (((cross) == (0.0)))
                                                {
#line 696 "GeometryModule.cs"
                                                    csharp2cuda_temp_327 = ((dot) > (0.0));
                                                }
                                                else
                                                {
#line 696 "GeometryModule.cs"
                                                    csharp2cuda_temp_327 = false;
                                                }
#line 696 "GeometryModule.cs"
                                                csharp2cuda_temp_326 = csharp2cuda_temp_327;
                                            }
                                            else
                                            {
#line 696 "GeometryModule.cs"
                                                csharp2cuda_temp_326 = true;
                                            }
                                            if (csharp2cuda_temp_326)
                                            {
#line 697 "GeometryModule.cs"
#line 697 "GeometryModule.cs"
                                                int* csharp2cuda_temp_328 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_328));
                                            }
                                        }
                                        csharp2cuda_for_continue_27:
#line 688 "GeometryModule.cs"
                                        int* csharp2cuda_temp_321 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_321));
                                    }
                                }
#line 699 "GeometryModule.cs"
#line 699 "GeometryModule.cs"
                                int* csharp2cuda_temp_329 = &(maximum);
#line 699 "GeometryModule.cs"
                                int csharp2cuda_temp_330;
#line 699 "GeometryModule.cs"
                                if (((maximum) > (count)))
                                {
#line 699 "GeometryModule.cs"
                                    csharp2cuda_temp_330 = maximum;
                                }
                                else
                                {
#line 699 "GeometryModule.cs"
                                    csharp2cuda_temp_330 = count;
                                }
                                (*(csharp2cuda_temp_329) = csharp2cuda_temp_330);
                            }
                            csharp2cuda_for_continue_28:
#line 681 "GeometryModule.cs"
                            int* csharp2cuda_temp_316 = &(pivot);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_316));
                        }
                    }
#line 701 "GeometryModule.cs"
#line 701 "GeometryModule.cs"
                    double* csharp2cuda_temp_331 = &((output)->scalar_value);
#line 702 "GeometryModule.cs"
                    int csharp2cuda_temp_332 = (first)->count;
#line 701 "GeometryModule.cs"
                    double csharp2cuda_temp_333 = __ddiv_rn(((double)(csharp2cuda_i32_sub(csharp2cuda_i32_add(coincident, vector_count), maximum))), ((double)(csharp2cuda_temp_332)));
                    (*(csharp2cuda_temp_331) = csharp2cuda_temp_333);
#line 703 "GeometryModule.cs"
                    break;
                }
#line 705 "GeometryModule.cs"
            case 12:
#line 706 "GeometryModule.cs"
#line 706 "GeometryModule.cs"
                int csharp2cuda_temp_334 = (first)->count;
#line 706 "GeometryModule.cs"
                bool csharp2cuda_temp_335;
#line 706 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_334) <= (0))))
                {
#line 706 "GeometryModule.cs"
                    int csharp2cuda_temp_336 = (second)->count;
#line 706 "GeometryModule.cs"
                    csharp2cuda_temp_335 = ((csharp2cuda_temp_336) <= (0));
                }
                else
                {
#line 706 "GeometryModule.cs"
                    csharp2cuda_temp_335 = true;
                }
                if (csharp2cuda_temp_335)
#line 707 "GeometryModule.cs"
                {
#line 708 "GeometryModule.cs"
#line 708 "GeometryModule.cs"
                    int* csharp2cuda_temp_337 = &((output)->valid);
                    (*(csharp2cuda_temp_337) = 0);
#line 709 "GeometryModule.cs"
                    break;
                }
#line 711 "GeometryModule.cs"
                {
#line 712 "GeometryModule.cs"
                    double directed_left = 0.0;
#line 713 "GeometryModule.cs"
                    {
#line 713 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 713 "GeometryModule.cs"
                            int csharp2cuda_temp_339 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_339))))
                                break;
#line 714 "GeometryModule.cs"
                            {
#line 715 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 716 "GeometryModule.cs"
                                {
#line 716 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 716 "GeometryModule.cs"
                                        int csharp2cuda_temp_341 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_341))))
                                            break;
#line 717 "GeometryModule.cs"
                                        {
#line 718 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 719 "GeometryModule.cs"
#line 719 "GeometryModule.cs"
                                            double* csharp2cuda_temp_342 = &(minimum);
#line 719 "GeometryModule.cs"
                                            double csharp2cuda_temp_343;
#line 719 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 719 "GeometryModule.cs"
                                                csharp2cuda_temp_343 = minimum;
                                            }
                                            else
                                            {
#line 719 "GeometryModule.cs"
                                                csharp2cuda_temp_343 = distance;
                                            }
                                            (*(csharp2cuda_temp_342) = csharp2cuda_temp_343);
                                        }
#line 716 "GeometryModule.cs"
                                        int* csharp2cuda_temp_340 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                                    }
                                }
#line 721 "GeometryModule.cs"
#line 721 "GeometryModule.cs"
                                double* csharp2cuda_temp_344 = &(directed_left);
#line 721 "GeometryModule.cs"
                                double csharp2cuda_temp_345;
#line 721 "GeometryModule.cs"
                                if (((directed_left) > (minimum)))
                                {
#line 721 "GeometryModule.cs"
                                    csharp2cuda_temp_345 = directed_left;
                                }
                                else
                                {
#line 721 "GeometryModule.cs"
                                    csharp2cuda_temp_345 = minimum;
                                }
                                (*(csharp2cuda_temp_344) = csharp2cuda_temp_345);
                            }
#line 713 "GeometryModule.cs"
                            int* csharp2cuda_temp_338 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_338));
                        }
                    }
#line 723 "GeometryModule.cs"
                    double directed_right = 0.0;
#line 724 "GeometryModule.cs"
                    {
#line 724 "GeometryModule.cs"
                        int right = 0;
                        while (true)
                        {
#line 724 "GeometryModule.cs"
                            int csharp2cuda_temp_347 = (second)->count;
                            if (!(((right) < (csharp2cuda_temp_347))))
                                break;
#line 725 "GeometryModule.cs"
                            {
#line 726 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 727 "GeometryModule.cs"
                                {
#line 727 "GeometryModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
#line 727 "GeometryModule.cs"
                                        int csharp2cuda_temp_349 = (first)->count;
                                        if (!(((left) < (csharp2cuda_temp_349))))
                                            break;
#line 728 "GeometryModule.cs"
                                        {
#line 729 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(b, right, a, left);
#line 730 "GeometryModule.cs"
#line 730 "GeometryModule.cs"
                                            double* csharp2cuda_temp_350 = &(minimum);
#line 730 "GeometryModule.cs"
                                            double csharp2cuda_temp_351;
#line 730 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 730 "GeometryModule.cs"
                                                csharp2cuda_temp_351 = minimum;
                                            }
                                            else
                                            {
#line 730 "GeometryModule.cs"
                                                csharp2cuda_temp_351 = distance;
                                            }
                                            (*(csharp2cuda_temp_350) = csharp2cuda_temp_351);
                                        }
#line 727 "GeometryModule.cs"
                                        int* csharp2cuda_temp_348 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_348));
                                    }
                                }
#line 732 "GeometryModule.cs"
#line 732 "GeometryModule.cs"
                                double* csharp2cuda_temp_352 = &(directed_right);
#line 732 "GeometryModule.cs"
                                double csharp2cuda_temp_353;
#line 732 "GeometryModule.cs"
                                if (((directed_right) > (minimum)))
                                {
#line 732 "GeometryModule.cs"
                                    csharp2cuda_temp_353 = directed_right;
                                }
                                else
                                {
#line 732 "GeometryModule.cs"
                                    csharp2cuda_temp_353 = minimum;
                                }
                                (*(csharp2cuda_temp_352) = csharp2cuda_temp_353);
                            }
#line 724 "GeometryModule.cs"
                            int* csharp2cuda_temp_346 = &(right);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
                        }
                    }
#line 734 "GeometryModule.cs"
#line 734 "GeometryModule.cs"
                    double* csharp2cuda_temp_354 = &((output)->scalar_value);
#line 734 "GeometryModule.cs"
                    double csharp2cuda_temp_355;
#line 734 "GeometryModule.cs"
                    if (((directed_left) > (directed_right)))
                    {
#line 734 "GeometryModule.cs"
                        csharp2cuda_temp_355 = directed_left;
                    }
                    else
                    {
#line 734 "GeometryModule.cs"
                        csharp2cuda_temp_355 = directed_right;
                    }
                    (*(csharp2cuda_temp_354) = csharp2cuda_temp_355);
#line 737 "GeometryModule.cs"
                    break;
                }
#line 739 "GeometryModule.cs"
            case 13:
            case 14:
#line 741 "GeometryModule.cs"
#line 741 "GeometryModule.cs"
                int csharp2cuda_temp_356 = (first)->count;
                if (((csharp2cuda_temp_356) <= (0)))
#line 742 "GeometryModule.cs"
                {
#line 743 "GeometryModule.cs"
#line 743 "GeometryModule.cs"
                    int* csharp2cuda_temp_357 = &((output)->valid);
                    (*(csharp2cuda_temp_357) = 0);
#line 744 "GeometryModule.cs"
                    break;
                }
#line 746 "GeometryModule.cs"
                {
#line 747 "GeometryModule.cs"
                    double total = 0.0;
#line 748 "GeometryModule.cs"
                    int csharp2cuda_temp_358;
#line 748 "GeometryModule.cs"
                    if (((opcode) == (13)))
                    {
#line 748 "GeometryModule.cs"
                        csharp2cuda_temp_358 = 1;
                    }
                    else
                    {
#line 748 "GeometryModule.cs"
                        csharp2cuda_temp_358 = 0;
                    }
#line 748 "GeometryModule.cs"
                    int start = csharp2cuda_temp_358;
#line 749 "GeometryModule.cs"
                    {
#line 749 "GeometryModule.cs"
                        int index = start;
                        while (true)
                        {
#line 749 "GeometryModule.cs"
                            int csharp2cuda_temp_360 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_360))))
                                break;
#line 750 "GeometryModule.cs"
                            {
#line 751 "GeometryModule.cs"
                                int csharp2cuda_temp_361;
#line 751 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 751 "GeometryModule.cs"
                                    csharp2cuda_temp_361 = csharp2cuda_i32_sub(index, 1);
                                }
                                else
                                {
#line 751 "GeometryModule.cs"
                                    csharp2cuda_temp_361 = index;
                                }
#line 751 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_361;
#line 752 "GeometryModule.cs"
                                int csharp2cuda_temp_362;
#line 752 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 752 "GeometryModule.cs"
                                    csharp2cuda_temp_362 = index;
                                }
                                else
                                {
#line 752 "GeometryModule.cs"
                                    int csharp2cuda_temp_363 = (first)->count;
#line 752 "GeometryModule.cs"
                                    csharp2cuda_temp_362 = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_363);
                                }
#line 752 "GeometryModule.cs"
                                int next = csharp2cuda_temp_362;
#line 753 "GeometryModule.cs"
#line 753 "GeometryModule.cs"
                                double* csharp2cuda_temp_364 = &(total);
#line 753 "GeometryModule.cs"
                                double csharp2cuda_temp_365 = *(csharp2cuda_temp_364);
#line 753 "GeometryModule.cs"
                                double csharp2cuda_temp_366 = mathblocks_geometry_distance(a, previous, a, next);
                                (*(csharp2cuda_temp_364) = __dadd_rn(csharp2cuda_temp_365, csharp2cuda_temp_366));
                            }
#line 749 "GeometryModule.cs"
                            int* csharp2cuda_temp_359 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_359));
                        }
                    }
#line 755 "GeometryModule.cs"
#line 755 "GeometryModule.cs"
                    double* csharp2cuda_temp_367 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_367) = total);
#line 756 "GeometryModule.cs"
                    break;
                }
#line 758 "GeometryModule.cs"
            case 15:
#line 759 "GeometryModule.cs"
#line 759 "GeometryModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
#line 759 "GeometryModule.cs"
                bool csharp2cuda_temp_369;
#line 759 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_368) != (1))))
                {
#line 759 "GeometryModule.cs"
                    int csharp2cuda_temp_370 = (second)->count;
#line 759 "GeometryModule.cs"
                    csharp2cuda_temp_369 = ((csharp2cuda_temp_370) != (2));
                }
                else
                {
#line 759 "GeometryModule.cs"
                    csharp2cuda_temp_369 = true;
                }
                if (csharp2cuda_temp_369)
#line 760 "GeometryModule.cs"
                {
#line 761 "GeometryModule.cs"
#line 761 "GeometryModule.cs"
                    int* csharp2cuda_temp_371 = &((output)->valid);
                    (*(csharp2cuda_temp_371) = 0);
#line 762 "GeometryModule.cs"
                    break;
                }
#line 764 "GeometryModule.cs"
#line 764 "GeometryModule.cs"
                double* csharp2cuda_temp_372 = &((output)->scalar_value);
#line 765 "GeometryModule.cs"
                double csharp2cuda_temp_373 = (a)[0];
#line 765 "GeometryModule.cs"
                double csharp2cuda_temp_374 = (a)[1];
#line 765 "GeometryModule.cs"
                double csharp2cuda_temp_375 = (b)[0];
#line 765 "GeometryModule.cs"
                double csharp2cuda_temp_376 = (b)[1];
#line 765 "GeometryModule.cs"
                double csharp2cuda_temp_377 = (b)[2];
#line 765 "GeometryModule.cs"
                double csharp2cuda_temp_378 = (b)[3];
                (*(csharp2cuda_temp_372) = mathblocks_geometry_point_to_segment(csharp2cuda_temp_373, csharp2cuda_temp_374, csharp2cuda_temp_375, csharp2cuda_temp_376, csharp2cuda_temp_377, csharp2cuda_temp_378));
#line 766 "GeometryModule.cs"
                break;
#line 767 "GeometryModule.cs"
            case 16:
            case 17:
#line 769 "GeometryModule.cs"
#line 769 "GeometryModule.cs"
                int csharp2cuda_temp_379 = (first)->count;
                if (((csharp2cuda_temp_379) <= (0)))
#line 770 "GeometryModule.cs"
                {
#line 771 "GeometryModule.cs"
#line 771 "GeometryModule.cs"
                    int* csharp2cuda_temp_380 = &((output)->valid);
                    (*(csharp2cuda_temp_380) = 0);
#line 772 "GeometryModule.cs"
                    break;
                }
#line 774 "GeometryModule.cs"
                {
#line 775 "GeometryModule.cs"
                    double twice_area = 0.0;
#line 776 "GeometryModule.cs"
                    {
#line 776 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 776 "GeometryModule.cs"
                            int csharp2cuda_temp_382 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_382))))
                                break;
#line 777 "GeometryModule.cs"
                            {
#line 778 "GeometryModule.cs"
                                int csharp2cuda_temp_383 = (first)->count;
#line 778 "GeometryModule.cs"
                                int next = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_383);
#line 779 "GeometryModule.cs"
#line 779 "GeometryModule.cs"
                                double* csharp2cuda_temp_384 = &(twice_area);
#line 779 "GeometryModule.cs"
                                double csharp2cuda_temp_385 = *(csharp2cuda_temp_384);
#line 779 "GeometryModule.cs"
                                double csharp2cuda_temp_386 = (a)[csharp2cuda_i32_mul(2, index)];
#line 779 "GeometryModule.cs"
                                double csharp2cuda_temp_387 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, next), 1)];
#line 780 "GeometryModule.cs"
                                double csharp2cuda_temp_388 = (a)[csharp2cuda_i32_mul(2, next)];
#line 780 "GeometryModule.cs"
                                double csharp2cuda_temp_389 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                (*(csharp2cuda_temp_384) = __dadd_rn(csharp2cuda_temp_385, __dsub_rn(__dmul_rn(csharp2cuda_temp_386, csharp2cuda_temp_387), __dmul_rn(csharp2cuda_temp_388, csharp2cuda_temp_389))));
                            }
#line 776 "GeometryModule.cs"
                            int* csharp2cuda_temp_381 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_381));
                        }
                    }
#line 782 "GeometryModule.cs"
#line 782 "GeometryModule.cs"
                    double* csharp2cuda_temp_390 = &((output)->scalar_value);
#line 782 "GeometryModule.cs"
                    double csharp2cuda_temp_391;
#line 782 "GeometryModule.cs"
                    if (((opcode) == (16)))
                    {
#line 782 "GeometryModule.cs"
                        double csharp2cuda_temp_392 = __ddiv_rn(twice_area, 2.0);
#line 782 "GeometryModule.cs"
                        csharp2cuda_temp_391 = fabs(csharp2cuda_temp_392);
                    }
                    else
                    {
#line 782 "GeometryModule.cs"
                        csharp2cuda_temp_391 = __ddiv_rn(twice_area, 2.0);
                    }
                    (*(csharp2cuda_temp_390) = csharp2cuda_temp_391);
#line 783 "GeometryModule.cs"
                    break;
                }
#line 785 "GeometryModule.cs"
            case 18:
#line 786 "GeometryModule.cs"
#line 786 "GeometryModule.cs"
                int csharp2cuda_temp_393 = (first)->count;
#line 786 "GeometryModule.cs"
                bool csharp2cuda_temp_394;
#line 786 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_393) < (3))))
                {
#line 786 "GeometryModule.cs"
                    int csharp2cuda_temp_395 = (second)->count;
#line 786 "GeometryModule.cs"
                    csharp2cuda_temp_394 = ((csharp2cuda_temp_395) != (1));
                }
                else
                {
#line 786 "GeometryModule.cs"
                    csharp2cuda_temp_394 = true;
                }
                if (csharp2cuda_temp_394)
#line 787 "GeometryModule.cs"
                {
#line 788 "GeometryModule.cs"
#line 788 "GeometryModule.cs"
                    int* csharp2cuda_temp_396 = &((output)->valid);
                    (*(csharp2cuda_temp_396) = 0);
#line 789 "GeometryModule.cs"
                    break;
                }
#line 791 "GeometryModule.cs"
                {
#line 792 "GeometryModule.cs"
                    int containing = 0;
#line 793 "GeometryModule.cs"
                    int total = 0;
#line 794 "GeometryModule.cs"
                    double csharp2cuda_temp_397_storage[3];
                    double* coordinates = csharp2cuda_temp_397_storage;
#line 795 "GeometryModule.cs"
                    {
#line 795 "GeometryModule.cs"
                        int one = 0;
                        while (true)
                        {
#line 795 "GeometryModule.cs"
                            int csharp2cuda_temp_399 = (first)->count;
                            if (!(((one) < (csharp2cuda_temp_399))))
                                break;
#line 796 "GeometryModule.cs"
                            {
#line 796 "GeometryModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
#line 796 "GeometryModule.cs"
                                    int csharp2cuda_temp_401 = (first)->count;
                                    if (!(((two) < (csharp2cuda_temp_401))))
                                        break;
#line 797 "GeometryModule.cs"
                                    {
#line 797 "GeometryModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
#line 797 "GeometryModule.cs"
                                            int csharp2cuda_temp_403 = (first)->count;
                                            if (!(((three) < (csharp2cuda_temp_403))))
                                                break;
#line 798 "GeometryModule.cs"
                                            {
#line 799 "GeometryModule.cs"
#line 799 "GeometryModule.cs"
                                                int* csharp2cuda_temp_404 = &(total);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_404));
#line 800 "GeometryModule.cs"
#line 801 "GeometryModule.cs"
                                                double csharp2cuda_temp_405 = (b)[0];
#line 801 "GeometryModule.cs"
                                                double csharp2cuda_temp_406 = (b)[1];
#line 802 "GeometryModule.cs"
                                                double csharp2cuda_temp_407 = (a)[csharp2cuda_i32_mul(2, one)];
#line 802 "GeometryModule.cs"
                                                double csharp2cuda_temp_408 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 803 "GeometryModule.cs"
                                                double csharp2cuda_temp_409 = (a)[csharp2cuda_i32_mul(2, two)];
#line 803 "GeometryModule.cs"
                                                double csharp2cuda_temp_410 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 804 "GeometryModule.cs"
                                                double csharp2cuda_temp_411 = (a)[csharp2cuda_i32_mul(2, three)];
#line 804 "GeometryModule.cs"
                                                double csharp2cuda_temp_412 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                mathblocks_geometry_barycentric(csharp2cuda_temp_405, csharp2cuda_temp_406, csharp2cuda_temp_407, csharp2cuda_temp_408, csharp2cuda_temp_409, csharp2cuda_temp_410, csharp2cuda_temp_411, csharp2cuda_temp_412, coordinates);
#line 806 "GeometryModule.cs"
#line 806 "GeometryModule.cs"
                                                double csharp2cuda_temp_413 = (coordinates)[0];
#line 806 "GeometryModule.cs"
                                                bool csharp2cuda_temp_414;
#line 806 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_413) >= (0.0)))
                                                {
#line 806 "GeometryModule.cs"
                                                    double csharp2cuda_temp_415 = (coordinates)[0];
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_414 = ((csharp2cuda_temp_415) <= (1.0));
                                                }
                                                else
                                                {
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_414 = false;
                                                }
#line 806 "GeometryModule.cs"
                                                bool csharp2cuda_temp_416;
#line 806 "GeometryModule.cs"
                                                if (csharp2cuda_temp_414)
                                                {
#line 807 "GeometryModule.cs"
                                                    double csharp2cuda_temp_417 = (coordinates)[1];
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_416 = ((csharp2cuda_temp_417) >= (0.0));
                                                }
                                                else
                                                {
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_416 = false;
                                                }
#line 806 "GeometryModule.cs"
                                                bool csharp2cuda_temp_418;
#line 806 "GeometryModule.cs"
                                                if (csharp2cuda_temp_416)
                                                {
#line 807 "GeometryModule.cs"
                                                    double csharp2cuda_temp_419 = (coordinates)[1];
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_418 = ((csharp2cuda_temp_419) <= (1.0));
                                                }
                                                else
                                                {
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_418 = false;
                                                }
#line 806 "GeometryModule.cs"
                                                bool csharp2cuda_temp_420;
#line 806 "GeometryModule.cs"
                                                if (csharp2cuda_temp_418)
                                                {
#line 808 "GeometryModule.cs"
                                                    double csharp2cuda_temp_421 = (coordinates)[2];
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_420 = ((csharp2cuda_temp_421) >= (0.0));
                                                }
                                                else
                                                {
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_420 = false;
                                                }
#line 806 "GeometryModule.cs"
                                                bool csharp2cuda_temp_422;
#line 806 "GeometryModule.cs"
                                                if (csharp2cuda_temp_420)
                                                {
#line 808 "GeometryModule.cs"
                                                    double csharp2cuda_temp_423 = (coordinates)[2];
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_422 = ((csharp2cuda_temp_423) <= (1.0));
                                                }
                                                else
                                                {
#line 806 "GeometryModule.cs"
                                                    csharp2cuda_temp_422 = false;
                                                }
                                                if (csharp2cuda_temp_422)
#line 809 "GeometryModule.cs"
                                                {
#line 810 "GeometryModule.cs"
#line 810 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_424 = &(containing);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_424));
                                                }
                                            }
#line 797 "GeometryModule.cs"
                                            int* csharp2cuda_temp_402 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_402));
                                        }
                                    }
#line 796 "GeometryModule.cs"
                                    int* csharp2cuda_temp_400 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_400));
                                }
                            }
#line 795 "GeometryModule.cs"
                            int* csharp2cuda_temp_398 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_398));
                        }
                    }
#line 813 "GeometryModule.cs"
#line 813 "GeometryModule.cs"
                    double* csharp2cuda_temp_425 = &((output)->scalar_value);
#line 813 "GeometryModule.cs"
                    double csharp2cuda_temp_426 = __ddiv_rn(((double)(containing)), ((double)(total)));
                    (*(csharp2cuda_temp_425) = csharp2cuda_temp_426);
#line 814 "GeometryModule.cs"
                    break;
                }
#line 816 "GeometryModule.cs"
            case 19:
#line 817 "GeometryModule.cs"
#line 817 "GeometryModule.cs"
                int* csharp2cuda_temp_427 = &((output)->rows);
#line 817 "GeometryModule.cs"
                int csharp2cuda_temp_428 = (first)->rows;
                (*(csharp2cuda_temp_427) = csharp2cuda_temp_428);
#line 818 "GeometryModule.cs"
#line 818 "GeometryModule.cs"
                int* csharp2cuda_temp_429 = &((output)->count);
#line 818 "GeometryModule.cs"
                int csharp2cuda_temp_430 = (first)->rows;
                (*(csharp2cuda_temp_429) = csharp2cuda_temp_430);
#line 819 "GeometryModule.cs"
#line 819 "GeometryModule.cs"
                int csharp2cuda_temp_431 = (first)->columns;
#line 819 "GeometryModule.cs"
                bool csharp2cuda_temp_432;
#line 819 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_431) != (2))))
                {
#line 819 "GeometryModule.cs"
                    int csharp2cuda_temp_433 = (first)->rows;
#line 819 "GeometryModule.cs"
                    int csharp2cuda_temp_434 = (output)->capacity;
#line 819 "GeometryModule.cs"
                    csharp2cuda_temp_432 = ((csharp2cuda_temp_433) > (csharp2cuda_temp_434));
                }
                else
                {
#line 819 "GeometryModule.cs"
                    csharp2cuda_temp_432 = true;
                }
                if (csharp2cuda_temp_432)
#line 820 "GeometryModule.cs"
                {
#line 821 "GeometryModule.cs"
#line 821 "GeometryModule.cs"
                    int* csharp2cuda_temp_435 = &((output)->valid);
                    (*(csharp2cuda_temp_435) = 0);
#line 822 "GeometryModule.cs"
                    break;
                }
#line 824 "GeometryModule.cs"
                {
#line 824 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 824 "GeometryModule.cs"
                        int csharp2cuda_temp_437 = (first)->rows;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_437, 2)))))
                            break;
#line 825 "GeometryModule.cs"
#line 825 "GeometryModule.cs"
                        double* csharp2cuda_temp_438 = &((result)[index]);
#line 825 "GeometryModule.cs"
                        double csharp2cuda_temp_439 = (a)[index];
                        (*(csharp2cuda_temp_438) = csharp2cuda_temp_439);
#line 824 "GeometryModule.cs"
                        int* csharp2cuda_temp_436 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_436));
                    }
                }
#line 826 "GeometryModule.cs"
                break;
#line 827 "GeometryModule.cs"
            case 20:
#line 828 "GeometryModule.cs"
#line 828 "GeometryModule.cs"
                int csharp2cuda_temp_440 = (first)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_440, 2);
#line 829 "GeometryModule.cs"
#line 829 "GeometryModule.cs"
                int csharp2cuda_temp_441 = (first)->count;
                if (((csharp2cuda_temp_441) <= (0)))
#line 830 "GeometryModule.cs"
                {
#line 831 "GeometryModule.cs"
#line 831 "GeometryModule.cs"
                    int* csharp2cuda_temp_442 = &((output)->valid);
                    (*(csharp2cuda_temp_442) = 0);
#line 832 "GeometryModule.cs"
                    break;
                }
#line 834 "GeometryModule.cs"
                {
#line 834 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 834 "GeometryModule.cs"
                        int csharp2cuda_temp_444 = (first)->count;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_444, 2)))))
                            break;
#line 835 "GeometryModule.cs"
#line 835 "GeometryModule.cs"
                        double* csharp2cuda_temp_445 = &((result)[index]);
#line 835 "GeometryModule.cs"
                        double csharp2cuda_temp_446 = (a)[index];
                        (*(csharp2cuda_temp_445) = csharp2cuda_temp_446);
#line 834 "GeometryModule.cs"
                        int* csharp2cuda_temp_443 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_443));
                    }
                }
#line 836 "GeometryModule.cs"
                break;
#line 837 "GeometryModule.cs"
            case 21:
#line 838 "GeometryModule.cs"
#line 838 "GeometryModule.cs"
                int csharp2cuda_temp_447 = (first)->count;
#line 838 "GeometryModule.cs"
                bool csharp2cuda_temp_448;
#line 838 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_447) <= (0))))
                {
#line 838 "GeometryModule.cs"
                    csharp2cuda_temp_448 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 838 "GeometryModule.cs"
                    csharp2cuda_temp_448 = true;
                }
                if (csharp2cuda_temp_448)
#line 839 "GeometryModule.cs"
                {
#line 840 "GeometryModule.cs"
#line 840 "GeometryModule.cs"
                    int* csharp2cuda_temp_449 = &((output)->valid);
                    (*(csharp2cuda_temp_449) = 0);
#line 841 "GeometryModule.cs"
                    break;
                }
#line 843 "GeometryModule.cs"
#line 843 "GeometryModule.cs"
                int csharp2cuda_temp_450 = (first)->count;
                if (((csharp2cuda_temp_450) == (1)))
#line 844 "GeometryModule.cs"
                {
#line 845 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, 0);
#line 846 "GeometryModule.cs"
                    break;
                }
#line 848 "GeometryModule.cs"
                {
#line 849 "GeometryModule.cs"
                    int vertex_count = (first)->count;
#line 850 "GeometryModule.cs"
                    int edge_capacity = csharp2cuda_i32_div(csharp2cuda_i32_mul(vertex_count, csharp2cuda_i32_sub(vertex_count, 1)), 2);
#line 851 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(scratch));
#line 852 "GeometryModule.cs"
                    int edge_count = 0;
#line 853 "GeometryModule.cs"
                    {
#line 853 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (vertex_count))))
                                break;
#line 854 "GeometryModule.cs"
                            {
#line 854 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (vertex_count))))
                                        break;
#line 855 "GeometryModule.cs"
                                    {
#line 856 "GeometryModule.cs"
#line 856 "GeometryModule.cs"
                                        int* csharp2cuda_temp_453 = &(((edges)[edge_count]).from);
                                        (*(csharp2cuda_temp_453) = left);
#line 857 "GeometryModule.cs"
#line 857 "GeometryModule.cs"
                                        int* csharp2cuda_temp_454 = &(((edges)[edge_count]).to);
                                        (*(csharp2cuda_temp_454) = right);
#line 858 "GeometryModule.cs"
#line 858 "GeometryModule.cs"
                                        double* csharp2cuda_temp_455 = &(((edges)[edge_count]).weight);
#line 858 "GeometryModule.cs"
                                        double csharp2cuda_temp_456 = mathblocks_geometry_distance(a, left, a, right);
                                        (*(csharp2cuda_temp_455) = csharp2cuda_temp_456);
#line 859 "GeometryModule.cs"
#line 859 "GeometryModule.cs"
                                        int* csharp2cuda_temp_457 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_457));
                                    }
#line 854 "GeometryModule.cs"
                                    int* csharp2cuda_temp_452 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_452));
                                }
                            }
#line 853 "GeometryModule.cs"
                            int* csharp2cuda_temp_451 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_451));
                        }
                    }
#line 861 "GeometryModule.cs"
                    {
#line 861 "GeometryModule.cs"
                        int index = 1;
                        while (true)
                        {
                            if (!(((index) < (edge_count))))
                                break;
#line 862 "GeometryModule.cs"
                            {
#line 863 "GeometryModule.cs"
                                MathBlockGeometryEdge value = (edges)[index];
#line 864 "GeometryModule.cs"
                                int position = index;
#line 865 "GeometryModule.cs"
                                while (true)
                                {
#line 865 "GeometryModule.cs"
                                    bool csharp2cuda_temp_459;
#line 865 "GeometryModule.cs"
                                    if (((position) > (0)))
                                    {
#line 865 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_460 = &(value);
#line 865 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_461 = &((edges)[csharp2cuda_i32_sub(position, 1)]);
#line 865 "GeometryModule.cs"
                                        csharp2cuda_temp_459 = mathblocks_geometry_edge_less(csharp2cuda_temp_460, csharp2cuda_temp_461);
                                    }
                                    else
                                    {
#line 865 "GeometryModule.cs"
                                        csharp2cuda_temp_459 = false;
                                    }
                                    if (!(csharp2cuda_temp_459))
                                        break;
#line 866 "GeometryModule.cs"
                                    {
#line 867 "GeometryModule.cs"
#line 867 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_462 = &((edges)[position]);
#line 867 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_463 = (edges)[csharp2cuda_i32_sub(position, 1)];
                                        (*(csharp2cuda_temp_462) = csharp2cuda_temp_463);
#line 868 "GeometryModule.cs"
#line 868 "GeometryModule.cs"
                                        int* csharp2cuda_temp_464 = &(position);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_464));
                                    }
                                }
#line 870 "GeometryModule.cs"
#line 870 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_465 = &((edges)[position]);
                                (*(csharp2cuda_temp_465) = value);
                            }
#line 861 "GeometryModule.cs"
                            int* csharp2cuda_temp_458 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_458));
                        }
                    }
#line 872 "GeometryModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(edges, edge_capacity)));
#line 873 "GeometryModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 874 "GeometryModule.cs"
                    {
#line 874 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 875 "GeometryModule.cs"
                            {
#line 876 "GeometryModule.cs"
#line 876 "GeometryModule.cs"
                                int* csharp2cuda_temp_467 = &((parent)[index]);
                                (*(csharp2cuda_temp_467) = index);
#line 877 "GeometryModule.cs"
#line 877 "GeometryModule.cs"
                                unsigned char* csharp2cuda_temp_468 = &((rank)[index]);
                                (*(csharp2cuda_temp_468) = ((unsigned char)(0)));
                            }
#line 874 "GeometryModule.cs"
                            int* csharp2cuda_temp_466 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_466));
                        }
                    }
#line 879 "GeometryModule.cs"
                    int selected = 0;
#line 880 "GeometryModule.cs"
                    {
#line 880 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 880 "GeometryModule.cs"
                            bool csharp2cuda_temp_470;
#line 880 "GeometryModule.cs"
                            if (((index) < (edge_count)))
                            {
#line 880 "GeometryModule.cs"
                                csharp2cuda_temp_470 = ((selected) < (csharp2cuda_i32_sub(vertex_count, 1)));
                            }
                            else
                            {
#line 880 "GeometryModule.cs"
                                csharp2cuda_temp_470 = false;
                            }
                            if (!(csharp2cuda_temp_470))
                                break;
#line 881 "GeometryModule.cs"
                            {
#line 882 "GeometryModule.cs"
                                int csharp2cuda_temp_471 = ((edges)[index]).from;
#line 882 "GeometryModule.cs"
                                int left = mathblocks_geometry_find(parent, csharp2cuda_temp_471);
#line 883 "GeometryModule.cs"
                                int csharp2cuda_temp_472 = ((edges)[index]).to;
#line 883 "GeometryModule.cs"
                                int right = mathblocks_geometry_find(parent, csharp2cuda_temp_472);
#line 884 "GeometryModule.cs"
                                if (((left) == (right)))
                                {
#line 885 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_44;
                                }
#line 886 "GeometryModule.cs"
#line 886 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_473 = (rank)[left];
#line 886 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_474 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_473))) < (((int)(csharp2cuda_temp_474)))))
                                {
#line 887 "GeometryModule.cs"
#line 887 "GeometryModule.cs"
                                    int* csharp2cuda_temp_475 = &((parent)[left]);
                                    (*(csharp2cuda_temp_475) = right);
                                }
                                else
                                {
#line 888 "GeometryModule.cs"
#line 888 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_476 = (rank)[left];
#line 888 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_477 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_476))) > (((int)(csharp2cuda_temp_477)))))
                                    {
#line 889 "GeometryModule.cs"
#line 889 "GeometryModule.cs"
                                        int* csharp2cuda_temp_478 = &((parent)[right]);
                                        (*(csharp2cuda_temp_478) = left);
                                    }
                                    else
#line 891 "GeometryModule.cs"
                                    {
#line 892 "GeometryModule.cs"
#line 892 "GeometryModule.cs"
                                        int* csharp2cuda_temp_479 = &((parent)[right]);
                                        (*(csharp2cuda_temp_479) = left);
#line 893 "GeometryModule.cs"
#line 893 "GeometryModule.cs"
                                        unsigned char* csharp2cuda_temp_480 = &((rank)[left]);
                                        (*(csharp2cuda_temp_480))++;
                                    }
                                }
#line 895 "GeometryModule.cs"
#line 895 "GeometryModule.cs"
                                int* csharp2cuda_temp_481 = &(selected);
#line 895 "GeometryModule.cs"
                                int csharp2cuda_temp_482 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_481));
#line 895 "GeometryModule.cs"
                                double* csharp2cuda_temp_483 = &((result)[csharp2cuda_temp_482]);
#line 895 "GeometryModule.cs"
                                double csharp2cuda_temp_484 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_483) = csharp2cuda_temp_484);
                            }
                            csharp2cuda_for_continue_44:
#line 880 "GeometryModule.cs"
                            int* csharp2cuda_temp_469 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_469));
                        }
                    }
#line 897 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, selected);
#line 898 "GeometryModule.cs"
                    {
#line 898 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (selected))))
                                break;
#line 899 "GeometryModule.cs"
#line 899 "GeometryModule.cs"
                            double csharp2cuda_temp_486 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_486))))
                            {
#line 899 "GeometryModule.cs"
#line 899 "GeometryModule.cs"
                                int* csharp2cuda_temp_487 = &((output)->valid);
                                (*(csharp2cuda_temp_487) = 0);
                            }
#line 898 "GeometryModule.cs"
                            int* csharp2cuda_temp_485 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_485));
                        }
                    }
#line 900 "GeometryModule.cs"
                    break;
                }
        }
#line 903 "GeometryModule.cs"
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_488 = (output)->valid;
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_489;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_488)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_489 = ((opcode) != (0));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_489 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_490;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_489)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_490 = ((opcode) != (1));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_490 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_491;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_490)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_491 = ((opcode) != (3));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_491 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_492;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_491)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_492 = ((opcode) != (4));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_492 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_493;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_492)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_493 = ((opcode) != (5));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_493 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_494;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_493)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_494 = ((opcode) != (10));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_494 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_495;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_494)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_495 = ((opcode) != (19));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_495 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_496;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_495)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_496 = ((opcode) != (20));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_496 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_497;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_496)
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_497 = ((opcode) != (21));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_497 = false;
        }
#line 903 "GeometryModule.cs"
        bool csharp2cuda_temp_498;
#line 903 "GeometryModule.cs"
        if (csharp2cuda_temp_497)
        {
#line 906 "GeometryModule.cs"
            double csharp2cuda_temp_499 = (output)->scalar_value;
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_498 = (!(isfinite(csharp2cuda_temp_499)));
        }
        else
        {
#line 903 "GeometryModule.cs"
            csharp2cuda_temp_498 = false;
        }
        if (csharp2cuda_temp_498)
#line 907 "GeometryModule.cs"
        {
#line 908 "GeometryModule.cs"
#line 908 "GeometryModule.cs"
            int* csharp2cuda_temp_500 = &((output)->valid);
            (*(csharp2cuda_temp_500) = 0);
        }
    }
}

#line 56 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index)
#line 62 "GeometryModule.cs"
{
#line 63 "GeometryModule.cs"
#line 64 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (left)[csharp2cuda_i32_mul(2, left_index)];
#line 65 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (left)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left_index), 1)];
#line 66 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (right)[csharp2cuda_i32_mul(2, right_index)];
#line 67 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (right)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right_index), 1)];
    return mathblocks_geometry_distance_coordinates(csharp2cuda_temp_0, csharp2cuda_temp_1, csharp2cuda_temp_2, csharp2cuda_temp_3);
}

#line 44 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 50 "GeometryModule.cs"
{
#line 51 "GeometryModule.cs"
    double x = __dsub_rn(left_x, right_x);
#line 52 "GeometryModule.cs"
    double y = __dsub_rn(left_y, right_y);
#line 53 "GeometryModule.cs"
    return mathblocks_square_root(__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
}

#line 222 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right)
#line 226 "GeometryModule.cs"
{
#line 227 "GeometryModule.cs"
#line 227 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 227 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 228 "GeometryModule.cs"
        return true;
    }
#line 229 "GeometryModule.cs"
#line 229 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 229 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 230 "GeometryModule.cs"
        return false;
    }
#line 231 "GeometryModule.cs"
#line 231 "GeometryModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 231 "GeometryModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 232 "GeometryModule.cs"
        return true;
    }
#line 233 "GeometryModule.cs"
#line 233 "GeometryModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 233 "GeometryModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 234 "GeometryModule.cs"
        return false;
    }
#line 235 "GeometryModule.cs"
#line 235 "GeometryModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 235 "GeometryModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 211 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value)
#line 213 "GeometryModule.cs"
{
#line 214 "GeometryModule.cs"
    while (true)
    {
#line 214 "GeometryModule.cs"
        int csharp2cuda_temp_0 = (parent)[value];
        if (!(((csharp2cuda_temp_0) != (value))))
            break;
#line 215 "GeometryModule.cs"
        {
#line 216 "GeometryModule.cs"
#line 216 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[value]);
#line 216 "GeometryModule.cs"
            int csharp2cuda_temp_2 = (parent)[value];
#line 216 "GeometryModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 217 "GeometryModule.cs"
#line 217 "GeometryModule.cs"
            int* csharp2cuda_temp_4 = &(value);
#line 217 "GeometryModule.cs"
            int csharp2cuda_temp_5 = (parent)[value];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 219 "GeometryModule.cs"
    return value;
}

#line 171 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right)
#line 176 "GeometryModule.cs"
{
#line 177 "GeometryModule.cs"
    double left_x = (points)[csharp2cuda_i32_mul(2, left)];
#line 178 "GeometryModule.cs"
    double right_x = (points)[csharp2cuda_i32_mul(2, right)];
#line 179 "GeometryModule.cs"
    if (((left_x) < (right_x)))
    {
#line 180 "GeometryModule.cs"
        return true;
    }
#line 181 "GeometryModule.cs"
    if (((right_x) < (left_x)))
    {
#line 182 "GeometryModule.cs"
        return false;
    }
#line 183 "GeometryModule.cs"
    double left_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 184 "GeometryModule.cs"
    double right_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 185 "GeometryModule.cs"
    if (((left_y) < (right_y)))
    {
#line 186 "GeometryModule.cs"
        return true;
    }
#line 187 "GeometryModule.cs"
    if (((right_y) < (left_y)))
    {
#line 188 "GeometryModule.cs"
        return false;
    }
#line 189 "GeometryModule.cs"
    return ((left) < (right));
}

#line 83 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y)
#line 91 "GeometryModule.cs"
{
#line 92 "GeometryModule.cs"
    double x = __dsub_rn(end_x, start_x);
#line 93 "GeometryModule.cs"
    double y = __dsub_rn(end_y, start_y);
#line 94 "GeometryModule.cs"
    double length_square = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y));
#line 95 "GeometryModule.cs"
    if (((length_square) == (0.0)))
    {
#line 96 "GeometryModule.cs"
        return mathblocks_geometry_distance_coordinates(point_x, point_y, start_x, start_y);
    }
#line 97 "GeometryModule.cs"
    double projection = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(point_x, start_x), x), __dmul_rn(__dsub_rn(point_y, start_y), y)), length_square);
#line 99 "GeometryModule.cs"
#line 99 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &(projection);
#line 99 "GeometryModule.cs"
    double csharp2cuda_temp_1;
#line 99 "GeometryModule.cs"
    if (((projection) < (0.0)))
    {
#line 99 "GeometryModule.cs"
        csharp2cuda_temp_1 = 0.0;
    }
    else
    {
#line 99 "GeometryModule.cs"
        double csharp2cuda_temp_2;
#line 99 "GeometryModule.cs"
        if (((projection) > (1.0)))
        {
#line 99 "GeometryModule.cs"
            csharp2cuda_temp_2 = 1.0;
        }
        else
        {
#line 99 "GeometryModule.cs"
            csharp2cuda_temp_2 = projection;
        }
#line 99 "GeometryModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_temp_2;
    }
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 100 "GeometryModule.cs"
    return mathblocks_geometry_distance_coordinates(point_x, point_y, __dadd_rn(start_x, __dmul_rn(projection, x)), __dadd_rn(start_y, __dmul_rn(projection, y)));
}

#line 192 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_indices(
    const double* points,
    int count,
    int* indices)
#line 197 "GeometryModule.cs"
{
#line 198 "GeometryModule.cs"
    {
#line 198 "GeometryModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 199 "GeometryModule.cs"
            {
#line 200 "GeometryModule.cs"
                int value = index;
#line 201 "GeometryModule.cs"
                int position = index;
#line 202 "GeometryModule.cs"
                while (true)
                {
#line 202 "GeometryModule.cs"
                    bool csharp2cuda_temp_1;
#line 202 "GeometryModule.cs"
                    if (((position) > (0)))
                    {
#line 202 "GeometryModule.cs"
                        int csharp2cuda_temp_2 = (indices)[csharp2cuda_i32_sub(position, 1)];
#line 202 "GeometryModule.cs"
                        csharp2cuda_temp_1 = mathblocks_geometry_point_less(points, value, csharp2cuda_temp_2);
                    }
                    else
                    {
#line 202 "GeometryModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 203 "GeometryModule.cs"
                    {
#line 204 "GeometryModule.cs"
#line 204 "GeometryModule.cs"
                        int* csharp2cuda_temp_3 = &((indices)[position]);
#line 204 "GeometryModule.cs"
                        int csharp2cuda_temp_4 = (indices)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 205 "GeometryModule.cs"
#line 205 "GeometryModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 207 "GeometryModule.cs"
#line 207 "GeometryModule.cs"
                int* csharp2cuda_temp_6 = &((indices)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 198 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 130 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square)
#line 139 "GeometryModule.cs"
{
#line 140 "GeometryModule.cs"
    double first_x = (points)[csharp2cuda_i32_mul(2, first)];
#line 141 "GeometryModule.cs"
    double first_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, first), 1)];
#line 142 "GeometryModule.cs"
    double second_x = (points)[csharp2cuda_i32_mul(2, second)];
#line 143 "GeometryModule.cs"
    double second_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, second), 1)];
#line 144 "GeometryModule.cs"
    double third_x = (points)[csharp2cuda_i32_mul(2, third)];
#line 145 "GeometryModule.cs"
    double third_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, third), 1)];
#line 146 "GeometryModule.cs"
    double denominator = __dmul_rn(2.0, __dadd_rn(__dadd_rn(__dmul_rn(first_x, __dsub_rn(second_y, third_y)), __dmul_rn(second_x, __dsub_rn(third_y, first_y))), __dmul_rn(third_x, __dsub_rn(first_y, second_y))));
#line 149 "GeometryModule.cs"
    if (((denominator) == (0.0)))
#line 150 "GeometryModule.cs"
    {
#line 151 "GeometryModule.cs"
#line 151 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = center_x;
        (*(csharp2cuda_temp_0) = 0.0);
#line 152 "GeometryModule.cs"
#line 152 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = center_y;
        (*(csharp2cuda_temp_1) = 0.0);
#line 153 "GeometryModule.cs"
#line 153 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = radius_square;
        (*(csharp2cuda_temp_2) = 0.0);
#line 154 "GeometryModule.cs"
        return false;
    }
#line 156 "GeometryModule.cs"
    double first_square = __dadd_rn(__dmul_rn(first_x, first_x), __dmul_rn(first_y, first_y));
#line 157 "GeometryModule.cs"
    double second_square = __dadd_rn(__dmul_rn(second_x, second_x), __dmul_rn(second_y, second_y));
#line 158 "GeometryModule.cs"
    double third_square = __dadd_rn(__dmul_rn(third_x, third_x), __dmul_rn(third_y, third_y));
#line 159 "GeometryModule.cs"
#line 159 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = center_x;
#line 159 "GeometryModule.cs"
    double csharp2cuda_temp_4 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(second_y, third_y)), __dmul_rn(second_square, __dsub_rn(third_y, first_y))), __dmul_rn(third_square, __dsub_rn(first_y, second_y))), denominator);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 162 "GeometryModule.cs"
#line 162 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = center_y;
#line 162 "GeometryModule.cs"
    double csharp2cuda_temp_6 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(third_x, second_x)), __dmul_rn(second_square, __dsub_rn(first_x, third_x))), __dmul_rn(third_square, __dsub_rn(second_x, first_x))), denominator);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 165 "GeometryModule.cs"
    double csharp2cuda_temp_7 = *(center_x);
#line 165 "GeometryModule.cs"
    double x = __dsub_rn(first_x, csharp2cuda_temp_7);
#line 166 "GeometryModule.cs"
    double csharp2cuda_temp_8 = *(center_y);
#line 166 "GeometryModule.cs"
    double y = __dsub_rn(first_y, csharp2cuda_temp_8);
#line 167 "GeometryModule.cs"
#line 167 "GeometryModule.cs"
    double* csharp2cuda_temp_9 = radius_square;
    (*(csharp2cuda_temp_9) = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
#line 168 "GeometryModule.cs"
    return true;
}