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

#line 43 "GeometryModule.cs"
struct MathBlockGeometryEdge
{
    int from;
    int to;
    double weight;
};

#line 126 "GeometryModule.cs"
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

#line 113 "GeometryModule.cs"
__device__ double mathblocks_geometry_barycentric_denominator(
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y);

#line 76 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 373 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 62 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index);

#line 50 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 320 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right);

#line 309 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value);

#line 220 "GeometryModule.cs"
__device__ void mathblocks_geometry_index_order(
    const double* points,
    int count,
    int* order,
    int* buffer);

#line 198 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right);

#line 89 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y);

#line 338 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count);

#line 262 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_points(double* points, double* buffer, int count);

#line 157 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square);

#line 126 "GeometryModule.cs"
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
#line 137 "GeometryModule.cs"
{
#line 138 "GeometryModule.cs"
    double denominator = mathblocks_geometry_barycentric_denominator(first_x, first_y, second_x, second_y, third_x, third_y);
#line 141 "GeometryModule.cs"
    if ((!(isfinite(denominator))))
#line 142 "GeometryModule.cs"
    {
#line 143 "GeometryModule.cs"
#line 143 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = &((result)[0]);
        (*(csharp2cuda_temp_0) = mathblocks_quiet_nan());
#line 144 "GeometryModule.cs"
#line 144 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = &((result)[1]);
        (*(csharp2cuda_temp_1) = mathblocks_quiet_nan());
#line 145 "GeometryModule.cs"
#line 145 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((result)[2]);
        (*(csharp2cuda_temp_2) = mathblocks_quiet_nan());
#line 146 "GeometryModule.cs"
        return;
    }
#line 148 "GeometryModule.cs"
    double first_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(point_y, third_y))), denominator);
#line 150 "GeometryModule.cs"
    double second_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(third_y, first_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(first_x, third_x), __dsub_rn(point_y, third_y))), denominator);
#line 152 "GeometryModule.cs"
#line 152 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = &((result)[0]);
    (*(csharp2cuda_temp_3) = first_weight);
#line 153 "GeometryModule.cs"
#line 153 "GeometryModule.cs"
    double* csharp2cuda_temp_4 = &((result)[1]);
    (*(csharp2cuda_temp_4) = second_weight);
#line 154 "GeometryModule.cs"
#line 154 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = &((result)[2]);
    (*(csharp2cuda_temp_5) = __dsub_rn(__dsub_rn(1.0, first_weight), second_weight));
}

#line 113 "GeometryModule.cs"
__device__ double mathblocks_geometry_barycentric_denominator(
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y)
#line 121 "GeometryModule.cs"
{
#line 122 "GeometryModule.cs"
    return __dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(first_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(first_y, third_y)));
}

#line 76 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 84 "GeometryModule.cs"
{
#line 85 "GeometryModule.cs"
    return __dsub_rn(__dmul_rn(__dsub_rn(left_x, origin_x), __dsub_rn(right_y, origin_y)), __dmul_rn(__dsub_rn(left_y, origin_y), __dsub_rn(right_x, origin_x)));
}

#line 373 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 379 "GeometryModule.cs"
{
#line 380 "GeometryModule.cs"
    int thread = threadIdx.x;
#line 381 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 381 "GeometryModule.cs"
    if (((input_count) > (0)))
    {
#line 381 "GeometryModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 381 "GeometryModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 381 "GeometryModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 382 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 382 "GeometryModule.cs"
    if (((input_count) > (1)))
    {
#line 382 "GeometryModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 382 "GeometryModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 382 "GeometryModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 383 "GeometryModule.cs"
    if (((thread) == (0)))
#line 384 "GeometryModule.cs"
    {
#line 385 "GeometryModule.cs"
#line 385 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 386 "GeometryModule.cs"
#line 386 "GeometryModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 387 "GeometryModule.cs"
#line 387 "GeometryModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 388 "GeometryModule.cs"
#line 388 "GeometryModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 389 "GeometryModule.cs"
#line 389 "GeometryModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 390 "GeometryModule.cs"
#line 390 "GeometryModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 390 "GeometryModule.cs"
        bool csharp2cuda_temp_8;
#line 390 "GeometryModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 390 "GeometryModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 390 "GeometryModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 391 "GeometryModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 392 "GeometryModule.cs"
#line 392 "GeometryModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 392 "GeometryModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 392 "GeometryModule.cs"
            bool csharp2cuda_temp_11;
#line 392 "GeometryModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 392 "GeometryModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 392 "GeometryModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 394 "GeometryModule.cs"
    __syncthreads();
#line 395 "GeometryModule.cs"
#line 395 "GeometryModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 396 "GeometryModule.cs"
        return;
    }
#line 398 "GeometryModule.cs"
    double* csharp2cuda_temp_13;
#line 398 "GeometryModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 398 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 398 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 398 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 398 "GeometryModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 399 "GeometryModule.cs"
    double* csharp2cuda_temp_15;
#line 399 "GeometryModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 399 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 399 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 399 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 399 "GeometryModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 400 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 400 "GeometryModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 401 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 401 "GeometryModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 403 "GeometryModule.cs"
    if (((thread) == (0)))
#line 404 "GeometryModule.cs"
    {
#line 405 "GeometryModule.cs"
        switch (opcode)
        {
#line 407 "GeometryModule.cs"
            case 0:
#line 408 "GeometryModule.cs"
                mathblocks_sequence_set_vector_shape(output, 3);
#line 409 "GeometryModule.cs"
#line 409 "GeometryModule.cs"
                int csharp2cuda_temp_19 = (first)->count;
#line 409 "GeometryModule.cs"
                bool csharp2cuda_temp_20;
#line 409 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_19) != (1))))
                {
#line 409 "GeometryModule.cs"
                    int csharp2cuda_temp_21 = (second)->count;
#line 409 "GeometryModule.cs"
                    csharp2cuda_temp_20 = ((csharp2cuda_temp_21) != (3));
                }
                else
                {
#line 409 "GeometryModule.cs"
                    csharp2cuda_temp_20 = true;
                }
                if (csharp2cuda_temp_20)
#line 410 "GeometryModule.cs"
                {
#line 411 "GeometryModule.cs"
#line 411 "GeometryModule.cs"
                    int* csharp2cuda_temp_22 = &((output)->valid);
                    (*(csharp2cuda_temp_22) = 0);
#line 412 "GeometryModule.cs"
                    break;
                }
#line 414 "GeometryModule.cs"
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_23 = (a)[0];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_24 = (a)[1];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_25 = (b)[0];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_26 = (b)[1];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_27 = (b)[2];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_28 = (b)[3];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_29 = (b)[4];
#line 415 "GeometryModule.cs"
                double csharp2cuda_temp_30 = (b)[5];
                mathblocks_geometry_barycentric(csharp2cuda_temp_23, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26, csharp2cuda_temp_27, csharp2cuda_temp_28, csharp2cuda_temp_29, csharp2cuda_temp_30, result);
#line 416 "GeometryModule.cs"
                {
#line 416 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (3))))
                            break;
#line 417 "GeometryModule.cs"
#line 417 "GeometryModule.cs"
                        double csharp2cuda_temp_32 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_32))))
                        {
#line 417 "GeometryModule.cs"
#line 417 "GeometryModule.cs"
                            int* csharp2cuda_temp_33 = &((output)->valid);
                            (*(csharp2cuda_temp_33) = 0);
                        }
#line 416 "GeometryModule.cs"
                        int* csharp2cuda_temp_31 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                    }
                }
#line 418 "GeometryModule.cs"
                break;
#line 419 "GeometryModule.cs"
            case 1:
#line 420 "GeometryModule.cs"
#line 420 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((output)->rows);
                (*(csharp2cuda_temp_34) = 1);
#line 421 "GeometryModule.cs"
#line 421 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &((output)->count);
                (*(csharp2cuda_temp_35) = 1);
#line 422 "GeometryModule.cs"
#line 422 "GeometryModule.cs"
                int csharp2cuda_temp_36 = (first)->count;
#line 422 "GeometryModule.cs"
                bool csharp2cuda_temp_37;
#line 422 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_36) <= (0))))
                {
#line 422 "GeometryModule.cs"
                    int csharp2cuda_temp_38 = (output)->capacity;
#line 422 "GeometryModule.cs"
                    csharp2cuda_temp_37 = ((csharp2cuda_temp_38) < (1));
                }
                else
                {
#line 422 "GeometryModule.cs"
                    csharp2cuda_temp_37 = true;
                }
                if (csharp2cuda_temp_37)
#line 423 "GeometryModule.cs"
                {
#line 424 "GeometryModule.cs"
#line 424 "GeometryModule.cs"
                    int* csharp2cuda_temp_39 = &((output)->valid);
                    (*(csharp2cuda_temp_39) = 0);
#line 425 "GeometryModule.cs"
                    break;
                }
#line 427 "GeometryModule.cs"
#line 427 "GeometryModule.cs"
                double* csharp2cuda_temp_40 = &((result)[0]);
                (*(csharp2cuda_temp_40) = 0.0);
#line 428 "GeometryModule.cs"
#line 428 "GeometryModule.cs"
                double* csharp2cuda_temp_41 = &((result)[1]);
                (*(csharp2cuda_temp_41) = 0.0);
#line 429 "GeometryModule.cs"
                {
#line 429 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 429 "GeometryModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_43))))
                            break;
#line 430 "GeometryModule.cs"
                        {
#line 431 "GeometryModule.cs"
#line 431 "GeometryModule.cs"
                            double* csharp2cuda_temp_44 = &((result)[0]);
#line 431 "GeometryModule.cs"
                            double csharp2cuda_temp_45 = *(csharp2cuda_temp_44);
#line 431 "GeometryModule.cs"
                            double csharp2cuda_temp_46 = (a)[csharp2cuda_i32_mul(2, index)];
                            (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 432 "GeometryModule.cs"
#line 432 "GeometryModule.cs"
                            double* csharp2cuda_temp_47 = &((result)[1]);
#line 432 "GeometryModule.cs"
                            double csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
#line 432 "GeometryModule.cs"
                            double csharp2cuda_temp_49 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                            (*(csharp2cuda_temp_47) = __dadd_rn(csharp2cuda_temp_48, csharp2cuda_temp_49));
                        }
#line 429 "GeometryModule.cs"
                        int* csharp2cuda_temp_42 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_42));
                    }
                }
#line 434 "GeometryModule.cs"
#line 434 "GeometryModule.cs"
                double* csharp2cuda_temp_50 = &((result)[0]);
#line 434 "GeometryModule.cs"
                double csharp2cuda_temp_51 = *(csharp2cuda_temp_50);
#line 434 "GeometryModule.cs"
                int csharp2cuda_temp_52 = (first)->count;
                (*(csharp2cuda_temp_50) = __ddiv_rn(csharp2cuda_temp_51, ((double)(csharp2cuda_temp_52))));
#line 435 "GeometryModule.cs"
#line 435 "GeometryModule.cs"
                double* csharp2cuda_temp_53 = &((result)[1]);
#line 435 "GeometryModule.cs"
                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 435 "GeometryModule.cs"
                int csharp2cuda_temp_55 = (first)->count;
                (*(csharp2cuda_temp_53) = __ddiv_rn(csharp2cuda_temp_54, ((double)(csharp2cuda_temp_55))));
#line 436 "GeometryModule.cs"
#line 436 "GeometryModule.cs"
                double csharp2cuda_temp_56 = (result)[0];
#line 436 "GeometryModule.cs"
                bool csharp2cuda_temp_57;
#line 436 "GeometryModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_56)))))
                {
#line 436 "GeometryModule.cs"
                    double csharp2cuda_temp_58 = (result)[1];
#line 436 "GeometryModule.cs"
                    csharp2cuda_temp_57 = (!(isfinite(csharp2cuda_temp_58)));
                }
                else
                {
#line 436 "GeometryModule.cs"
                    csharp2cuda_temp_57 = true;
                }
                if (csharp2cuda_temp_57)
                {
#line 436 "GeometryModule.cs"
#line 436 "GeometryModule.cs"
                    int* csharp2cuda_temp_59 = &((output)->valid);
                    (*(csharp2cuda_temp_59) = 0);
                }
#line 437 "GeometryModule.cs"
                break;
#line 438 "GeometryModule.cs"
            case 2:
#line 439 "GeometryModule.cs"
#line 439 "GeometryModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
                if (((csharp2cuda_temp_60) != (3)))
#line 440 "GeometryModule.cs"
                {
#line 441 "GeometryModule.cs"
#line 441 "GeometryModule.cs"
                    int* csharp2cuda_temp_61 = &((output)->valid);
                    (*(csharp2cuda_temp_61) = 0);
#line 442 "GeometryModule.cs"
                    break;
                }
#line 444 "GeometryModule.cs"
                {
#line 445 "GeometryModule.cs"
                    double first_length = mathblocks_geometry_distance(a, 1, a, 2);
#line 446 "GeometryModule.cs"
                    double second_length = mathblocks_geometry_distance(a, 0, a, 2);
#line 447 "GeometryModule.cs"
                    double third_length = mathblocks_geometry_distance(a, 0, a, 1);
#line 449 "GeometryModule.cs"
                    double csharp2cuda_temp_62 = (a)[0];
#line 449 "GeometryModule.cs"
                    double csharp2cuda_temp_63 = (a)[1];
#line 449 "GeometryModule.cs"
                    double csharp2cuda_temp_64 = (a)[2];
#line 449 "GeometryModule.cs"
                    double csharp2cuda_temp_65 = (a)[3];
#line 449 "GeometryModule.cs"
                    double csharp2cuda_temp_66 = (a)[4];
#line 449 "GeometryModule.cs"
                    double csharp2cuda_temp_67 = (a)[5];
#line 448 "GeometryModule.cs"
                    double cross = mathblocks_geometry_cross(csharp2cuda_temp_62, csharp2cuda_temp_63, csharp2cuda_temp_64, csharp2cuda_temp_65, csharp2cuda_temp_66, csharp2cuda_temp_67);
#line 450 "GeometryModule.cs"
#line 450 "GeometryModule.cs"
                    double* csharp2cuda_temp_68 = &((output)->scalar_value);
#line 450 "GeometryModule.cs"
                    double csharp2cuda_temp_69 = __ddiv_rn(__dmul_rn(__dmul_rn(first_length, second_length), third_length), __dmul_rn(2.0, fabs(cross)));
                    (*(csharp2cuda_temp_68) = csharp2cuda_temp_69);
#line 452 "GeometryModule.cs"
                    break;
                }
#line 454 "GeometryModule.cs"
            case 3:
#line 455 "GeometryModule.cs"
#line 455 "GeometryModule.cs"
                int csharp2cuda_temp_70 = (first)->count;
#line 455 "GeometryModule.cs"
                bool csharp2cuda_temp_71;
#line 455 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_70) < (3))))
                {
#line 455 "GeometryModule.cs"
                    int csharp2cuda_temp_72 = (second)->count;
#line 455 "GeometryModule.cs"
                    csharp2cuda_temp_71 = ((csharp2cuda_temp_72) != (1));
                }
                else
                {
#line 455 "GeometryModule.cs"
                    csharp2cuda_temp_71 = true;
                }
                if (csharp2cuda_temp_71)
#line 456 "GeometryModule.cs"
                {
#line 457 "GeometryModule.cs"
#line 457 "GeometryModule.cs"
                    int* csharp2cuda_temp_73 = &((output)->valid);
                    (*(csharp2cuda_temp_73) = 0);
#line 458 "GeometryModule.cs"
                    break;
                }
#line 460 "GeometryModule.cs"
                {
#line 461 "GeometryModule.cs"
                    bool inside = false;
#line 462 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 463 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 464 "GeometryModule.cs"
                    {
#line 464 "GeometryModule.cs"
                        int current = 0;
                        while (true)
                        {
#line 464 "GeometryModule.cs"
                            int csharp2cuda_temp_75 = (first)->count;
                            if (!(((current) < (csharp2cuda_temp_75))))
                                break;
#line 465 "GeometryModule.cs"
                            {
#line 466 "GeometryModule.cs"
                                int csharp2cuda_temp_76;
#line 466 "GeometryModule.cs"
                                if (((current) == (0)))
                                {
#line 466 "GeometryModule.cs"
                                    int csharp2cuda_temp_77 = (first)->count;
#line 466 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(csharp2cuda_temp_77, 1);
                                }
                                else
                                {
#line 466 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(current, 1);
                                }
#line 466 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_76;
#line 467 "GeometryModule.cs"
                                double left_x = (a)[csharp2cuda_i32_mul(2, current)];
#line 468 "GeometryModule.cs"
                                double left_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, current), 1)];
#line 469 "GeometryModule.cs"
                                double right_x = (a)[csharp2cuda_i32_mul(2, previous)];
#line 470 "GeometryModule.cs"
                                double right_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, previous), 1)];
#line 471 "GeometryModule.cs"
                                if (((mathblocks_geometry_point_to_segment(point_x, point_y, left_x, left_y, right_x, right_y)) == (0.0)))
#line 473 "GeometryModule.cs"
                                {
#line 474 "GeometryModule.cs"
#line 474 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_78 = &(inside);
                                    (*(csharp2cuda_temp_78) = true);
#line 475 "GeometryModule.cs"
                                    break;
                                }
#line 477 "GeometryModule.cs"
#line 477 "GeometryModule.cs"
                                bool csharp2cuda_temp_79;
#line 477 "GeometryModule.cs"
                                if (((((left_y) > (point_y))) != (((right_y) > (point_y)))))
                                {
#line 478 "GeometryModule.cs"
                                    double csharp2cuda_temp_80 = __ddiv_rn(__dmul_rn(__dsub_rn(right_x, left_x), __dsub_rn(point_y, left_y)), __dsub_rn(right_y, left_y));
#line 477 "GeometryModule.cs"
                                    csharp2cuda_temp_79 = ((point_x) < (__dadd_rn(csharp2cuda_temp_80, left_x)));
                                }
                                else
                                {
#line 477 "GeometryModule.cs"
                                    csharp2cuda_temp_79 = false;
                                }
                                if (csharp2cuda_temp_79)
#line 480 "GeometryModule.cs"
                                {
#line 481 "GeometryModule.cs"
#line 481 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_81 = &(inside);
                                    (*(csharp2cuda_temp_81) = (!(inside)));
                                }
                            }
#line 464 "GeometryModule.cs"
                            int* csharp2cuda_temp_74 = &(current);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_74));
                        }
                    }
#line 484 "GeometryModule.cs"
#line 484 "GeometryModule.cs"
                    int* csharp2cuda_temp_82 = &((output)->boolean_value);
#line 484 "GeometryModule.cs"
                    int csharp2cuda_temp_83;
#line 484 "GeometryModule.cs"
                    if (inside)
                    {
#line 484 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 1;
                    }
                    else
                    {
#line 484 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 0;
                    }
                    (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
#line 485 "GeometryModule.cs"
                    break;
                }
#line 487 "GeometryModule.cs"
            case 4:
#line 488 "GeometryModule.cs"
#line 488 "GeometryModule.cs"
                int csharp2cuda_temp_84 = (first)->count;
#line 488 "GeometryModule.cs"
                bool csharp2cuda_temp_85;
#line 488 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_84) <= (0))))
                {
#line 488 "GeometryModule.cs"
                    csharp2cuda_temp_85 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 488 "GeometryModule.cs"
                    csharp2cuda_temp_85 = true;
                }
                if (csharp2cuda_temp_85)
#line 489 "GeometryModule.cs"
                {
#line 490 "GeometryModule.cs"
#line 490 "GeometryModule.cs"
                    int* csharp2cuda_temp_86 = &((output)->valid);
                    (*(csharp2cuda_temp_86) = 0);
#line 491 "GeometryModule.cs"
                    break;
                }
#line 493 "GeometryModule.cs"
                {
#line 494 "GeometryModule.cs"
                    double* sorted = scratch;
#line 495 "GeometryModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 495 "GeometryModule.cs"
                    double* hull = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_87, 4));
#line 496 "GeometryModule.cs"
                    {
#line 496 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 496 "GeometryModule.cs"
                            int csharp2cuda_temp_89 = (first)->count;
                            if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_89, 2)))))
                                break;
#line 497 "GeometryModule.cs"
#line 497 "GeometryModule.cs"
                            double* csharp2cuda_temp_90 = &((sorted)[index]);
#line 497 "GeometryModule.cs"
                            double csharp2cuda_temp_91 = (a)[index];
                            (*(csharp2cuda_temp_90) = csharp2cuda_temp_91);
#line 496 "GeometryModule.cs"
                            int* csharp2cuda_temp_88 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_88));
                        }
                    }
#line 498 "GeometryModule.cs"
#line 498 "GeometryModule.cs"
                    int csharp2cuda_temp_92 = (first)->count;
#line 498 "GeometryModule.cs"
                    int csharp2cuda_temp_93 = (first)->count;
                    mathblocks_geometry_sort_points(sorted, csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_92, 2)), csharp2cuda_temp_93);
#line 499 "GeometryModule.cs"
                    int unique_count = 0;
#line 500 "GeometryModule.cs"
                    {
#line 500 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 500 "GeometryModule.cs"
                            int csharp2cuda_temp_95 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_95))))
                                break;
#line 501 "GeometryModule.cs"
                            {
#line 502 "GeometryModule.cs"
                                double x = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 503 "GeometryModule.cs"
                                double y = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 504 "GeometryModule.cs"
#line 504 "GeometryModule.cs"
                                bool csharp2cuda_temp_96;
#line 504 "GeometryModule.cs"
                                if (((unique_count) > (0)))
                                {
#line 504 "GeometryModule.cs"
                                    double csharp2cuda_temp_97 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(unique_count, 1))];
#line 504 "GeometryModule.cs"
                                    csharp2cuda_temp_96 = ((csharp2cuda_temp_97) == (x));
                                }
                                else
                                {
#line 504 "GeometryModule.cs"
                                    csharp2cuda_temp_96 = false;
                                }
#line 504 "GeometryModule.cs"
                                bool csharp2cuda_temp_98;
#line 504 "GeometryModule.cs"
                                if (csharp2cuda_temp_96)
                                {
#line 504 "GeometryModule.cs"
                                    double csharp2cuda_temp_99 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(unique_count, 1)), 1)];
#line 504 "GeometryModule.cs"
                                    csharp2cuda_temp_98 = ((csharp2cuda_temp_99) == (y));
                                }
                                else
                                {
#line 504 "GeometryModule.cs"
                                    csharp2cuda_temp_98 = false;
                                }
                                if (csharp2cuda_temp_98)
                                {
#line 505 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_4;
                                }
#line 506 "GeometryModule.cs"
#line 506 "GeometryModule.cs"
                                double* csharp2cuda_temp_100 = &((sorted)[csharp2cuda_i32_mul(2, unique_count)]);
                                (*(csharp2cuda_temp_100) = x);
#line 507 "GeometryModule.cs"
#line 507 "GeometryModule.cs"
                                double* csharp2cuda_temp_101 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, unique_count), 1)]);
                                (*(csharp2cuda_temp_101) = y);
#line 508 "GeometryModule.cs"
#line 508 "GeometryModule.cs"
                                int* csharp2cuda_temp_102 = &(unique_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_102));
                            }
                            csharp2cuda_for_continue_4:
#line 500 "GeometryModule.cs"
                            int* csharp2cuda_temp_94 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_94));
                        }
                    }
#line 510 "GeometryModule.cs"
                    int count = 0;
#line 511 "GeometryModule.cs"
                    if (((unique_count) <= (1)))
#line 512 "GeometryModule.cs"
                    {
#line 513 "GeometryModule.cs"
#line 513 "GeometryModule.cs"
                        int* csharp2cuda_temp_103 = &(count);
                        (*(csharp2cuda_temp_103) = unique_count);
#line 514 "GeometryModule.cs"
                        if (((count) == (1)))
#line 515 "GeometryModule.cs"
                        {
#line 516 "GeometryModule.cs"
#line 516 "GeometryModule.cs"
                            double* csharp2cuda_temp_104 = &((hull)[0]);
#line 516 "GeometryModule.cs"
                            double csharp2cuda_temp_105 = (sorted)[0];
                            (*(csharp2cuda_temp_104) = csharp2cuda_temp_105);
#line 517 "GeometryModule.cs"
#line 517 "GeometryModule.cs"
                            double* csharp2cuda_temp_106 = &((hull)[1]);
#line 517 "GeometryModule.cs"
                            double csharp2cuda_temp_107 = (sorted)[1];
                            (*(csharp2cuda_temp_106) = csharp2cuda_temp_107);
                        }
                    }
                    else
#line 521 "GeometryModule.cs"
                    {
#line 522 "GeometryModule.cs"
                        {
#line 522 "GeometryModule.cs"
                            int index = 0;
                            while (true)
                            {
                                if (!(((index) < (unique_count))))
                                    break;
#line 523 "GeometryModule.cs"
                                {
#line 524 "GeometryModule.cs"
                                    while (true)
                                    {
#line 524 "GeometryModule.cs"
                                        bool csharp2cuda_temp_109;
#line 524 "GeometryModule.cs"
                                        if (((count) >= (2)))
                                        {
#line 525 "GeometryModule.cs"
                                            double csharp2cuda_temp_110 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 525 "GeometryModule.cs"
                                            double csharp2cuda_temp_111 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 526 "GeometryModule.cs"
                                            double csharp2cuda_temp_112 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 526 "GeometryModule.cs"
                                            double csharp2cuda_temp_113 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 527 "GeometryModule.cs"
                                            double csharp2cuda_temp_114 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 527 "GeometryModule.cs"
                                            double csharp2cuda_temp_115 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 524 "GeometryModule.cs"
                                            csharp2cuda_temp_109 = ((mathblocks_geometry_cross(csharp2cuda_temp_110, csharp2cuda_temp_111, csharp2cuda_temp_112, csharp2cuda_temp_113, csharp2cuda_temp_114, csharp2cuda_temp_115)) <= (0.0));
                                        }
                                        else
                                        {
#line 524 "GeometryModule.cs"
                                            csharp2cuda_temp_109 = false;
                                        }
                                        if (!(csharp2cuda_temp_109))
                                            break;
#line 528 "GeometryModule.cs"
                                        {
#line 529 "GeometryModule.cs"
#line 529 "GeometryModule.cs"
                                            int* csharp2cuda_temp_116 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_116));
                                        }
                                    }
#line 531 "GeometryModule.cs"
#line 531 "GeometryModule.cs"
                                    double* csharp2cuda_temp_117 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 531 "GeometryModule.cs"
                                    double csharp2cuda_temp_118 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_117) = csharp2cuda_temp_118);
#line 532 "GeometryModule.cs"
#line 532 "GeometryModule.cs"
                                    double* csharp2cuda_temp_119 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 532 "GeometryModule.cs"
                                    double csharp2cuda_temp_120 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_119) = csharp2cuda_temp_120);
#line 533 "GeometryModule.cs"
#line 533 "GeometryModule.cs"
                                    int* csharp2cuda_temp_121 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_121));
                                }
#line 522 "GeometryModule.cs"
                                int* csharp2cuda_temp_108 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_108));
                            }
                        }
#line 535 "GeometryModule.cs"
                        int lower_count = count;
#line 536 "GeometryModule.cs"
                        {
#line 536 "GeometryModule.cs"
                            int index = csharp2cuda_i32_sub(unique_count, 2);
                            while (true)
                            {
                                if (!(((index) >= (0))))
                                    break;
#line 537 "GeometryModule.cs"
                                {
#line 538 "GeometryModule.cs"
                                    while (true)
                                    {
#line 538 "GeometryModule.cs"
                                        bool csharp2cuda_temp_123;
#line 538 "GeometryModule.cs"
                                        if (((count) > (lower_count)))
                                        {
#line 539 "GeometryModule.cs"
                                            double csharp2cuda_temp_124 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 539 "GeometryModule.cs"
                                            double csharp2cuda_temp_125 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 540 "GeometryModule.cs"
                                            double csharp2cuda_temp_126 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 540 "GeometryModule.cs"
                                            double csharp2cuda_temp_127 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 541 "GeometryModule.cs"
                                            double csharp2cuda_temp_128 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 541 "GeometryModule.cs"
                                            double csharp2cuda_temp_129 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 538 "GeometryModule.cs"
                                            csharp2cuda_temp_123 = ((mathblocks_geometry_cross(csharp2cuda_temp_124, csharp2cuda_temp_125, csharp2cuda_temp_126, csharp2cuda_temp_127, csharp2cuda_temp_128, csharp2cuda_temp_129)) <= (0.0));
                                        }
                                        else
                                        {
#line 538 "GeometryModule.cs"
                                            csharp2cuda_temp_123 = false;
                                        }
                                        if (!(csharp2cuda_temp_123))
                                            break;
#line 542 "GeometryModule.cs"
                                        {
#line 543 "GeometryModule.cs"
#line 543 "GeometryModule.cs"
                                            int* csharp2cuda_temp_130 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_130));
                                        }
                                    }
#line 545 "GeometryModule.cs"
#line 545 "GeometryModule.cs"
                                    double* csharp2cuda_temp_131 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 545 "GeometryModule.cs"
                                    double csharp2cuda_temp_132 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_131) = csharp2cuda_temp_132);
#line 546 "GeometryModule.cs"
#line 546 "GeometryModule.cs"
                                    double* csharp2cuda_temp_133 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 546 "GeometryModule.cs"
                                    double csharp2cuda_temp_134 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_133) = csharp2cuda_temp_134);
#line 547 "GeometryModule.cs"
#line 547 "GeometryModule.cs"
                                    int* csharp2cuda_temp_135 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_135));
                                }
#line 536 "GeometryModule.cs"
                                int* csharp2cuda_temp_122 = &(index);
                                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_122));
                            }
                        }
#line 549 "GeometryModule.cs"
#line 549 "GeometryModule.cs"
                        int* csharp2cuda_temp_136 = &(count);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_136));
                    }
#line 551 "GeometryModule.cs"
#line 551 "GeometryModule.cs"
                    int* csharp2cuda_temp_137 = &((output)->rows);
                    (*(csharp2cuda_temp_137) = count);
#line 552 "GeometryModule.cs"
#line 552 "GeometryModule.cs"
                    int* csharp2cuda_temp_138 = &((output)->count);
                    (*(csharp2cuda_temp_138) = count);
#line 553 "GeometryModule.cs"
#line 553 "GeometryModule.cs"
                    int csharp2cuda_temp_139 = (output)->capacity;
                    if (((count) > (csharp2cuda_temp_139)))
#line 554 "GeometryModule.cs"
                    {
#line 555 "GeometryModule.cs"
#line 555 "GeometryModule.cs"
                        int* csharp2cuda_temp_140 = &((output)->valid);
                        (*(csharp2cuda_temp_140) = 0);
#line 556 "GeometryModule.cs"
                        break;
                    }
#line 558 "GeometryModule.cs"
                    {
#line 558 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, 2)))))
                                break;
#line 559 "GeometryModule.cs"
#line 559 "GeometryModule.cs"
                            double* csharp2cuda_temp_142 = &((result)[index]);
#line 559 "GeometryModule.cs"
                            double csharp2cuda_temp_143 = (hull)[index];
                            (*(csharp2cuda_temp_142) = csharp2cuda_temp_143);
#line 558 "GeometryModule.cs"
                            int* csharp2cuda_temp_141 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                        }
                    }
#line 560 "GeometryModule.cs"
                    break;
                }
#line 562 "GeometryModule.cs"
            case 5:
#line 563 "GeometryModule.cs"
#line 563 "GeometryModule.cs"
                int csharp2cuda_temp_144 = (first)->count;
#line 563 "GeometryModule.cs"
                bool csharp2cuda_temp_145;
#line 563 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_144) < (2))))
                {
#line 563 "GeometryModule.cs"
                    csharp2cuda_temp_145 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 563 "GeometryModule.cs"
                    csharp2cuda_temp_145 = true;
                }
                if (csharp2cuda_temp_145)
#line 564 "GeometryModule.cs"
                {
#line 565 "GeometryModule.cs"
#line 565 "GeometryModule.cs"
                    int* csharp2cuda_temp_146 = &((output)->valid);
                    (*(csharp2cuda_temp_146) = 0);
#line 566 "GeometryModule.cs"
                    break;
                }
#line 568 "GeometryModule.cs"
                {
#line 569 "GeometryModule.cs"
                    int count = (first)->count;
#line 570 "GeometryModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 571 "GeometryModule.cs"
                    int* ordered = csharp2cuda_pointer_add(adjacency, csharp2cuda_i32_mul(count, count));
#line 572 "GeometryModule.cs"
                    {
#line 572 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 573 "GeometryModule.cs"
#line 573 "GeometryModule.cs"
                            int* csharp2cuda_temp_148 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_148) = 0);
#line 572 "GeometryModule.cs"
                            int* csharp2cuda_temp_147 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_147));
                        }
                    }
#line 574 "GeometryModule.cs"
                    {
#line 574 "GeometryModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (count))))
                                break;
#line 575 "GeometryModule.cs"
                            {
#line 576 "GeometryModule.cs"
                                {
#line 576 "GeometryModule.cs"
                                    int second_index = csharp2cuda_i32_add(first_index, 1);
                                    while (true)
                                    {
                                        if (!(((second_index) < (count))))
                                            break;
#line 577 "GeometryModule.cs"
                                        {
#line 578 "GeometryModule.cs"
                                            {
#line 578 "GeometryModule.cs"
                                                int third_index = csharp2cuda_i32_add(second_index, 1);
                                                while (true)
                                                {
                                                    if (!(((third_index) < (count))))
                                                        break;
#line 579 "GeometryModule.cs"
                                                    {
#line 580 "GeometryModule.cs"
                                                        double center_x;
#line 581 "GeometryModule.cs"
                                                        double center_y;
#line 582 "GeometryModule.cs"
                                                        double radius_square;
#line 583 "GeometryModule.cs"
#line 585 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_152 = &(center_x);
#line 585 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_153 = &(center_y);
#line 585 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_154 = &(radius_square);
#line 583 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_155 = mathblocks_geometry_try_circumcircle(a, first_index, second_index, third_index, csharp2cuda_temp_152, csharp2cuda_temp_153, csharp2cuda_temp_154);
                                                        if ((!(csharp2cuda_temp_155)))
#line 586 "GeometryModule.cs"
                                                        {
#line 587 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 589 "GeometryModule.cs"
                                                        bool empty = true;
#line 590 "GeometryModule.cs"
                                                        {
#line 590 "GeometryModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
                                                                if (!(((index) < (count))))
                                                                    break;
#line 591 "GeometryModule.cs"
                                                                {
#line 592 "GeometryModule.cs"
#line 592 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_157;
#line 592 "GeometryModule.cs"
                                                                    if (!(((index) == (first_index))))
                                                                    {
#line 592 "GeometryModule.cs"
                                                                        csharp2cuda_temp_157 = ((index) == (second_index));
                                                                    }
                                                                    else
                                                                    {
#line 592 "GeometryModule.cs"
                                                                        csharp2cuda_temp_157 = true;
                                                                    }
#line 592 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_158;
#line 592 "GeometryModule.cs"
                                                                    if (!(csharp2cuda_temp_157))
                                                                    {
#line 592 "GeometryModule.cs"
                                                                        csharp2cuda_temp_158 = ((index) == (third_index));
                                                                    }
                                                                    else
                                                                    {
#line 592 "GeometryModule.cs"
                                                                        csharp2cuda_temp_158 = true;
                                                                    }
                                                                    if (csharp2cuda_temp_158)
                                                                    {
#line 593 "GeometryModule.cs"
                                                                        goto csharp2cuda_for_continue_9;
                                                                    }
#line 594 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_159 = (a)[csharp2cuda_i32_mul(2, index)];
#line 594 "GeometryModule.cs"
                                                                    double x = __dsub_rn(csharp2cuda_temp_159, center_x);
#line 595 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_160 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 595 "GeometryModule.cs"
                                                                    double y = __dsub_rn(csharp2cuda_temp_160, center_y);
#line 596 "GeometryModule.cs"
                                                                    if (((__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y))) < (radius_square)))
#line 597 "GeometryModule.cs"
                                                                    {
#line 598 "GeometryModule.cs"
#line 598 "GeometryModule.cs"
                                                                        bool* csharp2cuda_temp_161 = &(empty);
                                                                        (*(csharp2cuda_temp_161) = false);
#line 599 "GeometryModule.cs"
                                                                        break;
                                                                    }
                                                                }
                                                                csharp2cuda_for_continue_9:
#line 590 "GeometryModule.cs"
                                                                int* csharp2cuda_temp_156 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                                                            }
                                                        }
#line 602 "GeometryModule.cs"
                                                        if ((!(empty)))
                                                        {
#line 603 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 604 "GeometryModule.cs"
#line 604 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_162 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), second_index)]);
                                                        (*(csharp2cuda_temp_162) = 1);
#line 605 "GeometryModule.cs"
#line 605 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_163 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_163) = 1);
#line 606 "GeometryModule.cs"
#line 606 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_164 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_164) = 1);
                                                    }
                                                    csharp2cuda_for_continue_10:
#line 578 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_151 = &(third_index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_151));
                                                }
                                            }
                                        }
#line 576 "GeometryModule.cs"
                                        int* csharp2cuda_temp_150 = &(second_index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_150));
                                    }
                                }
                            }
#line 574 "GeometryModule.cs"
                            int* csharp2cuda_temp_149 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_149));
                        }
                    }
#line 610 "GeometryModule.cs"
                    int edge_count = 0;
#line 611 "GeometryModule.cs"
                    {
#line 611 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 612 "GeometryModule.cs"
                            {
#line 612 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (count))))
                                        break;
#line 613 "GeometryModule.cs"
#line 613 "GeometryModule.cs"
                                    int* csharp2cuda_temp_167 = &(edge_count);
#line 613 "GeometryModule.cs"
                                    int csharp2cuda_temp_168 = *(csharp2cuda_temp_167);
#line 613 "GeometryModule.cs"
                                    int csharp2cuda_temp_169 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                    (*(csharp2cuda_temp_167) = csharp2cuda_i32_add(csharp2cuda_temp_168, csharp2cuda_temp_169));
#line 612 "GeometryModule.cs"
                                    int* csharp2cuda_temp_166 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_166));
                                }
                            }
#line 611 "GeometryModule.cs"
                            int* csharp2cuda_temp_165 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_165));
                        }
                    }
#line 614 "GeometryModule.cs"
                    if (((edge_count) == (0)))
#line 615 "GeometryModule.cs"
                    {
#line 616 "GeometryModule.cs"
                        mathblocks_geometry_index_order(a, count, ordered, csharp2cuda_pointer_add(ordered, count));
#line 617 "GeometryModule.cs"
                        {
#line 617 "GeometryModule.cs"
                            int index = 1;
                            while (true)
                            {
                                if (!(((index) < (count))))
                                    break;
#line 618 "GeometryModule.cs"
                                {
#line 619 "GeometryModule.cs"
                                    int csharp2cuda_temp_171 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 619 "GeometryModule.cs"
                                    int csharp2cuda_temp_172 = (ordered)[index];
#line 619 "GeometryModule.cs"
                                    int csharp2cuda_temp_173;
#line 619 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_171) < (csharp2cuda_temp_172)))
                                    {
#line 619 "GeometryModule.cs"
                                        csharp2cuda_temp_173 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
                                    else
                                    {
#line 619 "GeometryModule.cs"
                                        csharp2cuda_temp_173 = (ordered)[index];
                                    }
#line 619 "GeometryModule.cs"
                                    int left = csharp2cuda_temp_173;
#line 622 "GeometryModule.cs"
                                    int csharp2cuda_temp_174 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 622 "GeometryModule.cs"
                                    int csharp2cuda_temp_175 = (ordered)[index];
#line 622 "GeometryModule.cs"
                                    int csharp2cuda_temp_176;
#line 622 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_174) < (csharp2cuda_temp_175)))
                                    {
#line 622 "GeometryModule.cs"
                                        csharp2cuda_temp_176 = (ordered)[index];
                                    }
                                    else
                                    {
#line 622 "GeometryModule.cs"
                                        csharp2cuda_temp_176 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
#line 622 "GeometryModule.cs"
                                    int right = csharp2cuda_temp_176;
#line 625 "GeometryModule.cs"
#line 625 "GeometryModule.cs"
                                    int* csharp2cuda_temp_177 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)]);
                                    (*(csharp2cuda_temp_177) = 1);
                                }
#line 617 "GeometryModule.cs"
                                int* csharp2cuda_temp_170 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_170));
                            }
                        }
                    }
#line 628 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_178 = (output)->data_pointer;
#line 628 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_178));
#line 629 "GeometryModule.cs"
#line 629 "GeometryModule.cs"
                    int* csharp2cuda_temp_179 = &(edge_count);
                    (*(csharp2cuda_temp_179) = 0);
#line 630 "GeometryModule.cs"
                    {
#line 630 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 631 "GeometryModule.cs"
                            {
#line 632 "GeometryModule.cs"
                                {
#line 632 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
                                        if (!(((right) < (count))))
                                            break;
#line 633 "GeometryModule.cs"
                                        {
#line 634 "GeometryModule.cs"
#line 634 "GeometryModule.cs"
                                            int csharp2cuda_temp_182 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                            if ((!(((csharp2cuda_temp_182) != 0))))
                                            {
#line 635 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_16;
                                            }
#line 636 "GeometryModule.cs"
#line 636 "GeometryModule.cs"
                                            int csharp2cuda_temp_183 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_183)))
#line 637 "GeometryModule.cs"
                                            {
#line 638 "GeometryModule.cs"
#line 638 "GeometryModule.cs"
                                                int* csharp2cuda_temp_184 = &((output)->count);
#line 638 "GeometryModule.cs"
                                                int csharp2cuda_temp_185 = (output)->capacity;
#line 638 "GeometryModule.cs"
                                                int csharp2cuda_temp_186;
#line 638 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_185) == (2147483647)))
                                                {
#line 638 "GeometryModule.cs"
                                                    csharp2cuda_temp_186 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 640 "GeometryModule.cs"
                                                    int csharp2cuda_temp_187 = (output)->capacity;
#line 638 "GeometryModule.cs"
                                                    csharp2cuda_temp_186 = csharp2cuda_i32_add(csharp2cuda_temp_187, 1);
                                                }
                                                (*(csharp2cuda_temp_184) = csharp2cuda_temp_186);
#line 641 "GeometryModule.cs"
#line 641 "GeometryModule.cs"
                                                int* csharp2cuda_temp_188 = &((output)->valid);
                                                (*(csharp2cuda_temp_188) = 0);
#line 642 "GeometryModule.cs"
                                                break;
                                            }
#line 644 "GeometryModule.cs"
#line 644 "GeometryModule.cs"
                                            int* csharp2cuda_temp_189 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_189) = left);
#line 645 "GeometryModule.cs"
#line 645 "GeometryModule.cs"
                                            int* csharp2cuda_temp_190 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_190) = right);
#line 646 "GeometryModule.cs"
#line 646 "GeometryModule.cs"
                                            double* csharp2cuda_temp_191 = &(((edges)[edge_count]).weight);
#line 646 "GeometryModule.cs"
                                            double csharp2cuda_temp_192 = mathblocks_geometry_distance(a, left, a, right);
                                            (*(csharp2cuda_temp_191) = csharp2cuda_temp_192);
#line 647 "GeometryModule.cs"
#line 647 "GeometryModule.cs"
                                            double csharp2cuda_temp_193 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_193))))
                                            {
#line 647 "GeometryModule.cs"
#line 647 "GeometryModule.cs"
                                                int* csharp2cuda_temp_194 = &((output)->valid);
                                                (*(csharp2cuda_temp_194) = 0);
                                            }
#line 648 "GeometryModule.cs"
#line 648 "GeometryModule.cs"
                                            int* csharp2cuda_temp_195 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_195));
                                        }
                                        csharp2cuda_for_continue_16:
#line 632 "GeometryModule.cs"
                                        int* csharp2cuda_temp_181 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_181));
                                    }
                                }
                            }
#line 630 "GeometryModule.cs"
                            int* csharp2cuda_temp_180 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_180));
                        }
                    }
#line 651 "GeometryModule.cs"
#line 651 "GeometryModule.cs"
                    int* csharp2cuda_temp_196 = &((output)->rows);
                    (*(csharp2cuda_temp_196) = count);
#line 652 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 653 "GeometryModule.cs"
#line 653 "GeometryModule.cs"
                        int* csharp2cuda_temp_197 = &((output)->count);
                        (*(csharp2cuda_temp_197) = edge_count);
                    }
#line 654 "GeometryModule.cs"
                    break;
                }
#line 656 "GeometryModule.cs"
            case 6:
#line 657 "GeometryModule.cs"
#line 657 "GeometryModule.cs"
                int csharp2cuda_temp_198 = (first)->count;
                if (((csharp2cuda_temp_198) <= (0)))
#line 658 "GeometryModule.cs"
                {
#line 659 "GeometryModule.cs"
#line 659 "GeometryModule.cs"
                    int* csharp2cuda_temp_199 = &((output)->valid);
                    (*(csharp2cuda_temp_199) = 0);
#line 660 "GeometryModule.cs"
                    break;
                }
#line 662 "GeometryModule.cs"
                {
#line 663 "GeometryModule.cs"
                    double maximum = 0.0;
#line 664 "GeometryModule.cs"
                    {
#line 664 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 664 "GeometryModule.cs"
                            int csharp2cuda_temp_201 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_201))))
                                break;
#line 665 "GeometryModule.cs"
                            {
#line 665 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
#line 665 "GeometryModule.cs"
                                    int csharp2cuda_temp_203 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_203))))
                                        break;
#line 666 "GeometryModule.cs"
                                    {
#line 667 "GeometryModule.cs"
                                        double distance = mathblocks_geometry_distance(a, left, a, right);
#line 668 "GeometryModule.cs"
#line 668 "GeometryModule.cs"
                                        double* csharp2cuda_temp_204 = &(maximum);
#line 668 "GeometryModule.cs"
                                        double csharp2cuda_temp_205;
#line 668 "GeometryModule.cs"
                                        if (((maximum) > (distance)))
                                        {
#line 668 "GeometryModule.cs"
                                            csharp2cuda_temp_205 = maximum;
                                        }
                                        else
                                        {
#line 668 "GeometryModule.cs"
                                            csharp2cuda_temp_205 = distance;
                                        }
                                        (*(csharp2cuda_temp_204) = csharp2cuda_temp_205);
                                    }
#line 665 "GeometryModule.cs"
                                    int* csharp2cuda_temp_202 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_202));
                                }
                            }
#line 664 "GeometryModule.cs"
                            int* csharp2cuda_temp_200 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_200));
                        }
                    }
#line 670 "GeometryModule.cs"
#line 670 "GeometryModule.cs"
                    double* csharp2cuda_temp_206 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_206) = maximum);
#line 671 "GeometryModule.cs"
                    break;
                }
#line 673 "GeometryModule.cs"
            case 7:
#line 674 "GeometryModule.cs"
#line 674 "GeometryModule.cs"
                int csharp2cuda_temp_207 = (first)->count;
#line 674 "GeometryModule.cs"
                bool csharp2cuda_temp_208;
#line 674 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_207) <= (0))))
                {
#line 674 "GeometryModule.cs"
                    int csharp2cuda_temp_209 = (second)->count;
#line 674 "GeometryModule.cs"
                    csharp2cuda_temp_208 = ((csharp2cuda_temp_209) <= (0));
                }
                else
                {
#line 674 "GeometryModule.cs"
                    csharp2cuda_temp_208 = true;
                }
#line 674 "GeometryModule.cs"
                bool csharp2cuda_temp_210;
#line 674 "GeometryModule.cs"
                if (!(csharp2cuda_temp_208))
                {
#line 674 "GeometryModule.cs"
                    csharp2cuda_temp_210 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 674 "GeometryModule.cs"
                    csharp2cuda_temp_210 = true;
                }
                if (csharp2cuda_temp_210)
#line 675 "GeometryModule.cs"
                {
#line 676 "GeometryModule.cs"
#line 676 "GeometryModule.cs"
                    int* csharp2cuda_temp_211 = &((output)->valid);
                    (*(csharp2cuda_temp_211) = 0);
#line 677 "GeometryModule.cs"
                    break;
                }
#line 679 "GeometryModule.cs"
                {
#line 680 "GeometryModule.cs"
                    {
#line 680 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 680 "GeometryModule.cs"
                            int csharp2cuda_temp_213 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_213))))
                                break;
#line 681 "GeometryModule.cs"
                            {
#line 682 "GeometryModule.cs"
                                {
#line 682 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 682 "GeometryModule.cs"
                                        int csharp2cuda_temp_215 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_215))))
                                            break;
#line 683 "GeometryModule.cs"
                                        {
#line 684 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 685 "GeometryModule.cs"
                                            int csharp2cuda_temp_216 = (second)->count;
#line 685 "GeometryModule.cs"
                                            int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_216), right);
#line 686 "GeometryModule.cs"
#line 686 "GeometryModule.cs"
                                            bool csharp2cuda_temp_217;
#line 686 "GeometryModule.cs"
                                            if (((left) == (0)))
                                            {
#line 686 "GeometryModule.cs"
                                                csharp2cuda_temp_217 = ((right) == (0));
                                            }
                                            else
                                            {
#line 686 "GeometryModule.cs"
                                                csharp2cuda_temp_217 = false;
                                            }
                                            if (csharp2cuda_temp_217)
                                            {
#line 687 "GeometryModule.cs"
#line 687 "GeometryModule.cs"
                                                double* csharp2cuda_temp_218 = &((scratch)[0]);
                                                (*(csharp2cuda_temp_218) = distance);
                                            }
                                            else
                                            {
#line 688 "GeometryModule.cs"
                                                if (((left) == (0)))
                                                {
#line 689 "GeometryModule.cs"
#line 689 "GeometryModule.cs"
                                                    double* csharp2cuda_temp_219 = &((scratch)[right]);
#line 689 "GeometryModule.cs"
                                                    double csharp2cuda_temp_220 = (scratch)[csharp2cuda_i32_sub(right, 1)];
#line 689 "GeometryModule.cs"
                                                    double csharp2cuda_temp_221;
#line 689 "GeometryModule.cs"
                                                    if (((csharp2cuda_temp_220) > (distance)))
                                                    {
#line 689 "GeometryModule.cs"
                                                        csharp2cuda_temp_221 = (scratch)[csharp2cuda_i32_sub(right, 1)];
                                                    }
                                                    else
                                                    {
#line 689 "GeometryModule.cs"
                                                        csharp2cuda_temp_221 = distance;
                                                    }
                                                    (*(csharp2cuda_temp_219) = csharp2cuda_temp_221);
                                                }
                                                else
                                                {
#line 692 "GeometryModule.cs"
                                                    if (((right) == (0)))
                                                    {
#line 693 "GeometryModule.cs"
#line 693 "GeometryModule.cs"
                                                        int csharp2cuda_temp_222 = (second)->count;
#line 693 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_223 = &((scratch)[csharp2cuda_i32_mul(left, csharp2cuda_temp_222)]);
#line 693 "GeometryModule.cs"
                                                        int csharp2cuda_temp_224 = (second)->count;
#line 693 "GeometryModule.cs"
                                                        double csharp2cuda_temp_225 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_224)];
#line 693 "GeometryModule.cs"
                                                        double csharp2cuda_temp_226;
#line 693 "GeometryModule.cs"
                                                        if (((csharp2cuda_temp_225) > (distance)))
                                                        {
#line 694 "GeometryModule.cs"
                                                            int csharp2cuda_temp_227 = (second)->count;
#line 693 "GeometryModule.cs"
                                                            csharp2cuda_temp_226 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_227)];
                                                        }
                                                        else
                                                        {
#line 693 "GeometryModule.cs"
                                                            csharp2cuda_temp_226 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_223) = csharp2cuda_temp_226);
                                                    }
                                                    else
#line 697 "GeometryModule.cs"
                                                    {
#line 698 "GeometryModule.cs"
                                                        int csharp2cuda_temp_228 = (second)->count;
#line 698 "GeometryModule.cs"
                                                        double preceding = (scratch)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_228), right)];
#line 699 "GeometryModule.cs"
                                                        int csharp2cuda_temp_229 = (second)->count;
#line 699 "GeometryModule.cs"
                                                        double candidate = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_229), right), 1)];
#line 700 "GeometryModule.cs"
#line 700 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_230 = &(preceding);
#line 700 "GeometryModule.cs"
                                                        double csharp2cuda_temp_231;
#line 700 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 700 "GeometryModule.cs"
                                                            csharp2cuda_temp_231 = preceding;
                                                        }
                                                        else
                                                        {
#line 700 "GeometryModule.cs"
                                                            csharp2cuda_temp_231 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_230) = csharp2cuda_temp_231);
#line 701 "GeometryModule.cs"
#line 701 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_232 = &(candidate);
#line 701 "GeometryModule.cs"
                                                        int csharp2cuda_temp_233 = (second)->count;
#line 701 "GeometryModule.cs"
                                                        double csharp2cuda_temp_234 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_233), right), 1)];
                                                        (*(csharp2cuda_temp_232) = csharp2cuda_temp_234);
#line 702 "GeometryModule.cs"
#line 702 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_235 = &(preceding);
#line 702 "GeometryModule.cs"
                                                        double csharp2cuda_temp_236;
#line 702 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 702 "GeometryModule.cs"
                                                            csharp2cuda_temp_236 = preceding;
                                                        }
                                                        else
                                                        {
#line 702 "GeometryModule.cs"
                                                            csharp2cuda_temp_236 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_235) = csharp2cuda_temp_236);
#line 703 "GeometryModule.cs"
#line 703 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_237 = &((scratch)[target]);
#line 703 "GeometryModule.cs"
                                                        double csharp2cuda_temp_238;
#line 703 "GeometryModule.cs"
                                                        if (((preceding) > (distance)))
                                                        {
#line 703 "GeometryModule.cs"
                                                            csharp2cuda_temp_238 = preceding;
                                                        }
                                                        else
                                                        {
#line 703 "GeometryModule.cs"
                                                            csharp2cuda_temp_238 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_237) = csharp2cuda_temp_238);
                                                    }
                                                }
                                            }
                                        }
#line 682 "GeometryModule.cs"
                                        int* csharp2cuda_temp_214 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                    }
                                }
                            }
#line 680 "GeometryModule.cs"
                            int* csharp2cuda_temp_212 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                        }
                    }
#line 707 "GeometryModule.cs"
#line 707 "GeometryModule.cs"
                    double* csharp2cuda_temp_239 = &((output)->scalar_value);
#line 707 "GeometryModule.cs"
                    int csharp2cuda_temp_240 = (first)->count;
#line 707 "GeometryModule.cs"
                    int csharp2cuda_temp_241 = (second)->count;
#line 707 "GeometryModule.cs"
                    double csharp2cuda_temp_242 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_mul(csharp2cuda_temp_240, csharp2cuda_temp_241), 1)];
                    (*(csharp2cuda_temp_239) = csharp2cuda_temp_242);
#line 708 "GeometryModule.cs"
                    break;
                }
#line 710 "GeometryModule.cs"
            case 8:
#line 711 "GeometryModule.cs"
#line 711 "GeometryModule.cs"
                int csharp2cuda_temp_243 = (first)->count;
#line 711 "GeometryModule.cs"
                bool csharp2cuda_temp_244;
#line 711 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_243) <= (0))))
                {
#line 711 "GeometryModule.cs"
                    int csharp2cuda_temp_245 = (second)->count;
#line 711 "GeometryModule.cs"
                    csharp2cuda_temp_244 = ((csharp2cuda_temp_245) <= (0));
                }
                else
                {
#line 711 "GeometryModule.cs"
                    csharp2cuda_temp_244 = true;
                }
                if (csharp2cuda_temp_244)
                {
#line 712 "GeometryModule.cs"
#line 712 "GeometryModule.cs"
                    int* csharp2cuda_temp_246 = &((output)->valid);
                    (*(csharp2cuda_temp_246) = 0);
                }
                else
                {
#line 714 "GeometryModule.cs"
#line 714 "GeometryModule.cs"
                    double* csharp2cuda_temp_247 = &((output)->scalar_value);
#line 714 "GeometryModule.cs"
                    double csharp2cuda_temp_248 = mathblocks_geometry_distance(a, 0, b, 0);
                    (*(csharp2cuda_temp_247) = csharp2cuda_temp_248);
                }
#line 715 "GeometryModule.cs"
                break;
#line 716 "GeometryModule.cs"
            case 9:
#line 717 "GeometryModule.cs"
#line 717 "GeometryModule.cs"
                int csharp2cuda_temp_249 = (first)->count;
#line 717 "GeometryModule.cs"
                bool csharp2cuda_temp_250;
#line 717 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_249) <= (0))))
                {
#line 717 "GeometryModule.cs"
                    int csharp2cuda_temp_251 = (first)->count;
#line 717 "GeometryModule.cs"
                    int csharp2cuda_temp_252 = (second)->count;
#line 717 "GeometryModule.cs"
                    csharp2cuda_temp_250 = ((csharp2cuda_temp_251) != (csharp2cuda_temp_252));
                }
                else
                {
#line 717 "GeometryModule.cs"
                    csharp2cuda_temp_250 = true;
                }
#line 717 "GeometryModule.cs"
                bool csharp2cuda_temp_253;
#line 717 "GeometryModule.cs"
                if (!(csharp2cuda_temp_250))
                {
#line 718 "GeometryModule.cs"
                    int csharp2cuda_temp_254 = (first)->count;
#line 717 "GeometryModule.cs"
                    csharp2cuda_temp_253 = (!(mathblocks_probability_distribution(a, csharp2cuda_temp_254)));
                }
                else
                {
#line 717 "GeometryModule.cs"
                    csharp2cuda_temp_253 = true;
                }
#line 717 "GeometryModule.cs"
                bool csharp2cuda_temp_255;
#line 717 "GeometryModule.cs"
                if (!(csharp2cuda_temp_253))
                {
#line 719 "GeometryModule.cs"
                    int csharp2cuda_temp_256 = (second)->count;
#line 717 "GeometryModule.cs"
                    csharp2cuda_temp_255 = (!(mathblocks_probability_distribution(b, csharp2cuda_temp_256)));
                }
                else
                {
#line 717 "GeometryModule.cs"
                    csharp2cuda_temp_255 = true;
                }
                if (csharp2cuda_temp_255)
#line 720 "GeometryModule.cs"
                {
#line 721 "GeometryModule.cs"
#line 721 "GeometryModule.cs"
                    int* csharp2cuda_temp_257 = &((output)->valid);
                    (*(csharp2cuda_temp_257) = 0);
#line 722 "GeometryModule.cs"
                    break;
                }
#line 724 "GeometryModule.cs"
                {
#line 725 "GeometryModule.cs"
                    double affinity = 0.0;
#line 726 "GeometryModule.cs"
                    {
#line 726 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 726 "GeometryModule.cs"
                            int csharp2cuda_temp_259 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_259))))
                                break;
#line 727 "GeometryModule.cs"
#line 727 "GeometryModule.cs"
                            double* csharp2cuda_temp_260 = &(affinity);
#line 727 "GeometryModule.cs"
                            double csharp2cuda_temp_261 = *(csharp2cuda_temp_260);
#line 727 "GeometryModule.cs"
                            double csharp2cuda_temp_262 = (a)[index];
#line 727 "GeometryModule.cs"
                            double csharp2cuda_temp_263 = (b)[index];
                            (*(csharp2cuda_temp_260) = __dadd_rn(csharp2cuda_temp_261, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_262, csharp2cuda_temp_263))));
#line 726 "GeometryModule.cs"
                            int* csharp2cuda_temp_258 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_258));
                        }
                    }
#line 728 "GeometryModule.cs"
#line 728 "GeometryModule.cs"
                    double* csharp2cuda_temp_264 = &(affinity);
#line 728 "GeometryModule.cs"
                    double csharp2cuda_temp_265;
#line 728 "GeometryModule.cs"
                    if (((affinity) < ((-(1.0)))))
                    {
#line 728 "GeometryModule.cs"
                        csharp2cuda_temp_265 = (-(1.0));
                    }
                    else
                    {
#line 728 "GeometryModule.cs"
                        double csharp2cuda_temp_266;
#line 728 "GeometryModule.cs"
                        if (((affinity) > (1.0)))
                        {
#line 728 "GeometryModule.cs"
                            csharp2cuda_temp_266 = 1.0;
                        }
                        else
                        {
#line 728 "GeometryModule.cs"
                            csharp2cuda_temp_266 = affinity;
                        }
#line 728 "GeometryModule.cs"
                        csharp2cuda_temp_265 = csharp2cuda_temp_266;
                    }
                    (*(csharp2cuda_temp_264) = csharp2cuda_temp_265);
#line 729 "GeometryModule.cs"
#line 729 "GeometryModule.cs"
                    double* csharp2cuda_temp_267 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_267) = __dmul_rn(2.0, mathblocks_arc_cosine(affinity)));
#line 730 "GeometryModule.cs"
                    break;
                }
#line 732 "GeometryModule.cs"
            case 10:
#line 733 "GeometryModule.cs"
#line 733 "GeometryModule.cs"
                int csharp2cuda_temp_268 = (first)->count;
                if (((csharp2cuda_temp_268) < (2)))
#line 734 "GeometryModule.cs"
                {
#line 735 "GeometryModule.cs"
#line 735 "GeometryModule.cs"
                    int* csharp2cuda_temp_269 = &((output)->valid);
                    (*(csharp2cuda_temp_269) = 0);
#line 736 "GeometryModule.cs"
                    break;
                }
#line 738 "GeometryModule.cs"
                {
#line 739 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_270 = (output)->data_pointer;
#line 739 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_270));
#line 740 "GeometryModule.cs"
                    int edge_count = 0;
#line 741 "GeometryModule.cs"
                    {
#line 741 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 741 "GeometryModule.cs"
                            int csharp2cuda_temp_272 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_272))))
                                break;
#line 742 "GeometryModule.cs"
                            {
#line 743 "GeometryModule.cs"
                                {
#line 743 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 743 "GeometryModule.cs"
                                        int csharp2cuda_temp_274 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_274))))
                                            break;
#line 744 "GeometryModule.cs"
                                        {
#line 745 "GeometryModule.cs"
                                            double csharp2cuda_temp_275 = (a)[csharp2cuda_i32_mul(2, left)];
#line 745 "GeometryModule.cs"
                                            double csharp2cuda_temp_276 = (a)[csharp2cuda_i32_mul(2, right)];
#line 745 "GeometryModule.cs"
                                            double center_x = __ddiv_rn(__dadd_rn(csharp2cuda_temp_275, csharp2cuda_temp_276), 2.0);
#line 746 "GeometryModule.cs"
                                            double csharp2cuda_temp_277 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 746 "GeometryModule.cs"
                                            double csharp2cuda_temp_278 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 746 "GeometryModule.cs"
                                            double center_y = __ddiv_rn(__dadd_rn(csharp2cuda_temp_277, csharp2cuda_temp_278), 2.0);
#line 747 "GeometryModule.cs"
                                            double csharp2cuda_temp_279 = mathblocks_geometry_distance(a, left, a, right);
#line 747 "GeometryModule.cs"
                                            double radius = __ddiv_rn(csharp2cuda_temp_279, 2.0);
#line 748 "GeometryModule.cs"
                                            bool empty = true;
#line 749 "GeometryModule.cs"
                                            {
#line 749 "GeometryModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
#line 749 "GeometryModule.cs"
                                                    int csharp2cuda_temp_281 = (first)->count;
                                                    if (!(((index) < (csharp2cuda_temp_281))))
                                                        break;
#line 750 "GeometryModule.cs"
                                                    {
#line 751 "GeometryModule.cs"
#line 751 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_282;
#line 751 "GeometryModule.cs"
                                                        if (((index) != (left)))
                                                        {
#line 751 "GeometryModule.cs"
                                                            csharp2cuda_temp_282 = ((index) != (right));
                                                        }
                                                        else
                                                        {
#line 751 "GeometryModule.cs"
                                                            csharp2cuda_temp_282 = false;
                                                        }
#line 751 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_283;
#line 751 "GeometryModule.cs"
                                                        if (csharp2cuda_temp_282)
                                                        {
#line 753 "GeometryModule.cs"
                                                            double csharp2cuda_temp_284 = (a)[csharp2cuda_i32_mul(2, index)];
#line 753 "GeometryModule.cs"
                                                            double csharp2cuda_temp_285 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 751 "GeometryModule.cs"
                                                            csharp2cuda_temp_283 = ((mathblocks_geometry_distance_coordinates(csharp2cuda_temp_284, csharp2cuda_temp_285, center_x, center_y)) < (radius));
                                                        }
                                                        else
                                                        {
#line 751 "GeometryModule.cs"
                                                            csharp2cuda_temp_283 = false;
                                                        }
                                                        if (csharp2cuda_temp_283)
#line 754 "GeometryModule.cs"
                                                        {
#line 755 "GeometryModule.cs"
#line 755 "GeometryModule.cs"
                                                            bool* csharp2cuda_temp_286 = &(empty);
                                                            (*(csharp2cuda_temp_286) = false);
#line 756 "GeometryModule.cs"
                                                            break;
                                                        }
                                                    }
#line 749 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_280 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_280));
                                                }
                                            }
#line 759 "GeometryModule.cs"
                                            if ((!(empty)))
                                            {
#line 760 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_24;
                                            }
#line 761 "GeometryModule.cs"
#line 761 "GeometryModule.cs"
                                            int csharp2cuda_temp_287 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_287)))
#line 762 "GeometryModule.cs"
                                            {
#line 763 "GeometryModule.cs"
#line 763 "GeometryModule.cs"
                                                int* csharp2cuda_temp_288 = &((output)->count);
#line 763 "GeometryModule.cs"
                                                int csharp2cuda_temp_289 = (output)->capacity;
#line 763 "GeometryModule.cs"
                                                int csharp2cuda_temp_290;
#line 763 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_289) == (2147483647)))
                                                {
#line 763 "GeometryModule.cs"
                                                    csharp2cuda_temp_290 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 765 "GeometryModule.cs"
                                                    int csharp2cuda_temp_291 = (output)->capacity;
#line 763 "GeometryModule.cs"
                                                    csharp2cuda_temp_290 = csharp2cuda_i32_add(csharp2cuda_temp_291, 1);
                                                }
                                                (*(csharp2cuda_temp_288) = csharp2cuda_temp_290);
#line 766 "GeometryModule.cs"
#line 766 "GeometryModule.cs"
                                                int* csharp2cuda_temp_292 = &((output)->valid);
                                                (*(csharp2cuda_temp_292) = 0);
#line 767 "GeometryModule.cs"
                                                break;
                                            }
#line 769 "GeometryModule.cs"
#line 769 "GeometryModule.cs"
                                            int* csharp2cuda_temp_293 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_293) = left);
#line 770 "GeometryModule.cs"
#line 770 "GeometryModule.cs"
                                            int* csharp2cuda_temp_294 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_294) = right);
#line 771 "GeometryModule.cs"
#line 771 "GeometryModule.cs"
                                            double* csharp2cuda_temp_295 = &(((edges)[edge_count]).weight);
                                            (*(csharp2cuda_temp_295) = __dmul_rn(2.0, radius));
#line 772 "GeometryModule.cs"
#line 772 "GeometryModule.cs"
                                            double csharp2cuda_temp_296 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_296))))
                                            {
#line 772 "GeometryModule.cs"
#line 772 "GeometryModule.cs"
                                                int* csharp2cuda_temp_297 = &((output)->valid);
                                                (*(csharp2cuda_temp_297) = 0);
                                            }
#line 773 "GeometryModule.cs"
#line 773 "GeometryModule.cs"
                                            int* csharp2cuda_temp_298 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_298));
                                        }
                                        csharp2cuda_for_continue_24:
#line 743 "GeometryModule.cs"
                                        int* csharp2cuda_temp_273 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_273));
                                    }
                                }
                            }
#line 741 "GeometryModule.cs"
                            int* csharp2cuda_temp_271 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_271));
                        }
                    }
#line 776 "GeometryModule.cs"
#line 776 "GeometryModule.cs"
                    int* csharp2cuda_temp_299 = &((output)->rows);
#line 776 "GeometryModule.cs"
                    int csharp2cuda_temp_300 = (first)->count;
                    (*(csharp2cuda_temp_299) = csharp2cuda_temp_300);
#line 777 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 778 "GeometryModule.cs"
#line 778 "GeometryModule.cs"
                        int* csharp2cuda_temp_301 = &((output)->count);
                        (*(csharp2cuda_temp_301) = edge_count);
                    }
#line 779 "GeometryModule.cs"
                    break;
                }
#line 781 "GeometryModule.cs"
            case 11:
#line 782 "GeometryModule.cs"
#line 782 "GeometryModule.cs"
                int csharp2cuda_temp_302 = (first)->count;
#line 782 "GeometryModule.cs"
                bool csharp2cuda_temp_303;
#line 782 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_302) <= (0))))
                {
#line 782 "GeometryModule.cs"
                    int csharp2cuda_temp_304 = (second)->count;
#line 782 "GeometryModule.cs"
                    csharp2cuda_temp_303 = ((csharp2cuda_temp_304) != (1));
                }
                else
                {
#line 782 "GeometryModule.cs"
                    csharp2cuda_temp_303 = true;
                }
                if (csharp2cuda_temp_303)
#line 783 "GeometryModule.cs"
                {
#line 784 "GeometryModule.cs"
#line 784 "GeometryModule.cs"
                    int* csharp2cuda_temp_305 = &((output)->valid);
                    (*(csharp2cuda_temp_305) = 0);
#line 785 "GeometryModule.cs"
                    break;
                }
#line 787 "GeometryModule.cs"
                {
#line 788 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 789 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 790 "GeometryModule.cs"
                    int coincident = 0;
#line 791 "GeometryModule.cs"
                    int vector_count = 0;
#line 792 "GeometryModule.cs"
                    {
#line 792 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 792 "GeometryModule.cs"
                            int csharp2cuda_temp_307 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_307))))
                                break;
#line 793 "GeometryModule.cs"
                            {
#line 794 "GeometryModule.cs"
                                double csharp2cuda_temp_308 = (a)[csharp2cuda_i32_mul(2, index)];
#line 794 "GeometryModule.cs"
                                double x = __dsub_rn(csharp2cuda_temp_308, point_x);
#line 795 "GeometryModule.cs"
                                double csharp2cuda_temp_309 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 795 "GeometryModule.cs"
                                double y = __dsub_rn(csharp2cuda_temp_309, point_y);
#line 796 "GeometryModule.cs"
#line 796 "GeometryModule.cs"
                                bool csharp2cuda_temp_310;
#line 796 "GeometryModule.cs"
                                if (((x) == (0.0)))
                                {
#line 796 "GeometryModule.cs"
                                    csharp2cuda_temp_310 = ((y) == (0.0));
                                }
                                else
                                {
#line 796 "GeometryModule.cs"
                                    csharp2cuda_temp_310 = false;
                                }
                                if (csharp2cuda_temp_310)
                                {
#line 797 "GeometryModule.cs"
#line 797 "GeometryModule.cs"
                                    int* csharp2cuda_temp_311 = &(coincident);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_311));
                                }
                                else
                                {
#line 799 "GeometryModule.cs"
#line 799 "GeometryModule.cs"
                                    int* csharp2cuda_temp_312 = &(vector_count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_312));
                                }
                            }
#line 792 "GeometryModule.cs"
                            int* csharp2cuda_temp_306 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_306));
                        }
                    }
#line 801 "GeometryModule.cs"
                    if (((vector_count) == (0)))
#line 802 "GeometryModule.cs"
                    {
#line 803 "GeometryModule.cs"
#line 803 "GeometryModule.cs"
                        double* csharp2cuda_temp_313 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_313) = 1.0);
#line 804 "GeometryModule.cs"
                        break;
                    }
#line 806 "GeometryModule.cs"
                    int maximum = 0;
#line 807 "GeometryModule.cs"
                    {
#line 807 "GeometryModule.cs"
                        int pivot = 0;
                        while (true)
                        {
#line 807 "GeometryModule.cs"
                            int csharp2cuda_temp_315 = (first)->count;
                            if (!(((pivot) < (csharp2cuda_temp_315))))
                                break;
#line 808 "GeometryModule.cs"
                            {
#line 809 "GeometryModule.cs"
                                double csharp2cuda_temp_316 = (a)[csharp2cuda_i32_mul(2, pivot)];
#line 809 "GeometryModule.cs"
                                double pivot_x = __dsub_rn(csharp2cuda_temp_316, point_x);
#line 810 "GeometryModule.cs"
                                double csharp2cuda_temp_317 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, pivot), 1)];
#line 810 "GeometryModule.cs"
                                double pivot_y = __dsub_rn(csharp2cuda_temp_317, point_y);
#line 811 "GeometryModule.cs"
#line 811 "GeometryModule.cs"
                                bool csharp2cuda_temp_318;
#line 811 "GeometryModule.cs"
                                if (((pivot_x) == (0.0)))
                                {
#line 811 "GeometryModule.cs"
                                    csharp2cuda_temp_318 = ((pivot_y) == (0.0));
                                }
                                else
                                {
#line 811 "GeometryModule.cs"
                                    csharp2cuda_temp_318 = false;
                                }
                                if (csharp2cuda_temp_318)
                                {
#line 812 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_28;
                                }
#line 813 "GeometryModule.cs"
                                int count = 0;
#line 814 "GeometryModule.cs"
                                {
#line 814 "GeometryModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 814 "GeometryModule.cs"
                                        int csharp2cuda_temp_320 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_320))))
                                            break;
#line 815 "GeometryModule.cs"
                                        {
#line 816 "GeometryModule.cs"
                                            double csharp2cuda_temp_321 = (a)[csharp2cuda_i32_mul(2, index)];
#line 816 "GeometryModule.cs"
                                            double x = __dsub_rn(csharp2cuda_temp_321, point_x);
#line 817 "GeometryModule.cs"
                                            double csharp2cuda_temp_322 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 817 "GeometryModule.cs"
                                            double y = __dsub_rn(csharp2cuda_temp_322, point_y);
#line 818 "GeometryModule.cs"
#line 818 "GeometryModule.cs"
                                            bool csharp2cuda_temp_323;
#line 818 "GeometryModule.cs"
                                            if (((x) == (0.0)))
                                            {
#line 818 "GeometryModule.cs"
                                                csharp2cuda_temp_323 = ((y) == (0.0));
                                            }
                                            else
                                            {
#line 818 "GeometryModule.cs"
                                                csharp2cuda_temp_323 = false;
                                            }
                                            if (csharp2cuda_temp_323)
                                            {
#line 819 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_27;
                                            }
#line 820 "GeometryModule.cs"
                                            double cross = __dsub_rn(__dmul_rn(pivot_x, y), __dmul_rn(pivot_y, x));
#line 821 "GeometryModule.cs"
                                            double dot = __dadd_rn(__dmul_rn(pivot_x, x), __dmul_rn(pivot_y, y));
#line 823 "GeometryModule.cs"
#line 823 "GeometryModule.cs"
                                            bool csharp2cuda_temp_324;
#line 823 "GeometryModule.cs"
                                            if (!(isnan(cross)))
                                            {
#line 823 "GeometryModule.cs"
                                                csharp2cuda_temp_324 = isnan(dot);
                                            }
                                            else
                                            {
#line 823 "GeometryModule.cs"
                                                csharp2cuda_temp_324 = true;
                                            }
                                            if (csharp2cuda_temp_324)
                                            {
#line 824 "GeometryModule.cs"
#line 824 "GeometryModule.cs"
                                                int* csharp2cuda_temp_325 = &((output)->valid);
                                                (*(csharp2cuda_temp_325) = 0);
                                            }
#line 825 "GeometryModule.cs"
#line 825 "GeometryModule.cs"
                                            bool csharp2cuda_temp_326;
#line 825 "GeometryModule.cs"
                                            if (!(((cross) > (0.0))))
                                            {
#line 825 "GeometryModule.cs"
                                                bool csharp2cuda_temp_327;
#line 825 "GeometryModule.cs"
                                                if (((cross) == (0.0)))
                                                {
#line 825 "GeometryModule.cs"
                                                    csharp2cuda_temp_327 = ((dot) > (0.0));
                                                }
                                                else
                                                {
#line 825 "GeometryModule.cs"
                                                    csharp2cuda_temp_327 = false;
                                                }
#line 825 "GeometryModule.cs"
                                                csharp2cuda_temp_326 = csharp2cuda_temp_327;
                                            }
                                            else
                                            {
#line 825 "GeometryModule.cs"
                                                csharp2cuda_temp_326 = true;
                                            }
                                            if (csharp2cuda_temp_326)
                                            {
#line 826 "GeometryModule.cs"
#line 826 "GeometryModule.cs"
                                                int* csharp2cuda_temp_328 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_328));
                                            }
                                        }
                                        csharp2cuda_for_continue_27:
#line 814 "GeometryModule.cs"
                                        int* csharp2cuda_temp_319 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_319));
                                    }
                                }
#line 828 "GeometryModule.cs"
#line 828 "GeometryModule.cs"
                                int* csharp2cuda_temp_329 = &(maximum);
#line 828 "GeometryModule.cs"
                                int csharp2cuda_temp_330;
#line 828 "GeometryModule.cs"
                                if (((maximum) > (count)))
                                {
#line 828 "GeometryModule.cs"
                                    csharp2cuda_temp_330 = maximum;
                                }
                                else
                                {
#line 828 "GeometryModule.cs"
                                    csharp2cuda_temp_330 = count;
                                }
                                (*(csharp2cuda_temp_329) = csharp2cuda_temp_330);
                            }
                            csharp2cuda_for_continue_28:
#line 807 "GeometryModule.cs"
                            int* csharp2cuda_temp_314 = &(pivot);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                        }
                    }
#line 830 "GeometryModule.cs"
#line 830 "GeometryModule.cs"
                    double* csharp2cuda_temp_331 = &((output)->scalar_value);
#line 831 "GeometryModule.cs"
                    int csharp2cuda_temp_332 = (first)->count;
#line 830 "GeometryModule.cs"
                    double csharp2cuda_temp_333 = __ddiv_rn(((double)(csharp2cuda_i32_sub(csharp2cuda_i32_add(coincident, vector_count), maximum))), ((double)(csharp2cuda_temp_332)));
                    (*(csharp2cuda_temp_331) = csharp2cuda_temp_333);
#line 832 "GeometryModule.cs"
                    break;
                }
#line 834 "GeometryModule.cs"
            case 12:
#line 835 "GeometryModule.cs"
#line 835 "GeometryModule.cs"
                int csharp2cuda_temp_334 = (first)->count;
#line 835 "GeometryModule.cs"
                bool csharp2cuda_temp_335;
#line 835 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_334) <= (0))))
                {
#line 835 "GeometryModule.cs"
                    int csharp2cuda_temp_336 = (second)->count;
#line 835 "GeometryModule.cs"
                    csharp2cuda_temp_335 = ((csharp2cuda_temp_336) <= (0));
                }
                else
                {
#line 835 "GeometryModule.cs"
                    csharp2cuda_temp_335 = true;
                }
                if (csharp2cuda_temp_335)
#line 836 "GeometryModule.cs"
                {
#line 837 "GeometryModule.cs"
#line 837 "GeometryModule.cs"
                    int* csharp2cuda_temp_337 = &((output)->valid);
                    (*(csharp2cuda_temp_337) = 0);
#line 838 "GeometryModule.cs"
                    break;
                }
#line 840 "GeometryModule.cs"
                {
#line 841 "GeometryModule.cs"
                    double directed_left = 0.0;
#line 842 "GeometryModule.cs"
                    {
#line 842 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 842 "GeometryModule.cs"
                            int csharp2cuda_temp_339 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_339))))
                                break;
#line 843 "GeometryModule.cs"
                            {
#line 844 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 845 "GeometryModule.cs"
                                {
#line 845 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 845 "GeometryModule.cs"
                                        int csharp2cuda_temp_341 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_341))))
                                            break;
#line 846 "GeometryModule.cs"
                                        {
#line 847 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 848 "GeometryModule.cs"
#line 848 "GeometryModule.cs"
                                            double* csharp2cuda_temp_342 = &(minimum);
#line 848 "GeometryModule.cs"
                                            double csharp2cuda_temp_343;
#line 848 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 848 "GeometryModule.cs"
                                                csharp2cuda_temp_343 = minimum;
                                            }
                                            else
                                            {
#line 848 "GeometryModule.cs"
                                                csharp2cuda_temp_343 = distance;
                                            }
                                            (*(csharp2cuda_temp_342) = csharp2cuda_temp_343);
                                        }
#line 845 "GeometryModule.cs"
                                        int* csharp2cuda_temp_340 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                                    }
                                }
#line 850 "GeometryModule.cs"
#line 850 "GeometryModule.cs"
                                double* csharp2cuda_temp_344 = &(directed_left);
#line 850 "GeometryModule.cs"
                                double csharp2cuda_temp_345;
#line 850 "GeometryModule.cs"
                                if (((directed_left) > (minimum)))
                                {
#line 850 "GeometryModule.cs"
                                    csharp2cuda_temp_345 = directed_left;
                                }
                                else
                                {
#line 850 "GeometryModule.cs"
                                    csharp2cuda_temp_345 = minimum;
                                }
                                (*(csharp2cuda_temp_344) = csharp2cuda_temp_345);
                            }
#line 842 "GeometryModule.cs"
                            int* csharp2cuda_temp_338 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_338));
                        }
                    }
#line 852 "GeometryModule.cs"
                    double directed_right = 0.0;
#line 853 "GeometryModule.cs"
                    {
#line 853 "GeometryModule.cs"
                        int right = 0;
                        while (true)
                        {
#line 853 "GeometryModule.cs"
                            int csharp2cuda_temp_347 = (second)->count;
                            if (!(((right) < (csharp2cuda_temp_347))))
                                break;
#line 854 "GeometryModule.cs"
                            {
#line 855 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 856 "GeometryModule.cs"
                                {
#line 856 "GeometryModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
#line 856 "GeometryModule.cs"
                                        int csharp2cuda_temp_349 = (first)->count;
                                        if (!(((left) < (csharp2cuda_temp_349))))
                                            break;
#line 857 "GeometryModule.cs"
                                        {
#line 858 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(b, right, a, left);
#line 859 "GeometryModule.cs"
#line 859 "GeometryModule.cs"
                                            double* csharp2cuda_temp_350 = &(minimum);
#line 859 "GeometryModule.cs"
                                            double csharp2cuda_temp_351;
#line 859 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 859 "GeometryModule.cs"
                                                csharp2cuda_temp_351 = minimum;
                                            }
                                            else
                                            {
#line 859 "GeometryModule.cs"
                                                csharp2cuda_temp_351 = distance;
                                            }
                                            (*(csharp2cuda_temp_350) = csharp2cuda_temp_351);
                                        }
#line 856 "GeometryModule.cs"
                                        int* csharp2cuda_temp_348 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_348));
                                    }
                                }
#line 861 "GeometryModule.cs"
#line 861 "GeometryModule.cs"
                                double* csharp2cuda_temp_352 = &(directed_right);
#line 861 "GeometryModule.cs"
                                double csharp2cuda_temp_353;
#line 861 "GeometryModule.cs"
                                if (((directed_right) > (minimum)))
                                {
#line 861 "GeometryModule.cs"
                                    csharp2cuda_temp_353 = directed_right;
                                }
                                else
                                {
#line 861 "GeometryModule.cs"
                                    csharp2cuda_temp_353 = minimum;
                                }
                                (*(csharp2cuda_temp_352) = csharp2cuda_temp_353);
                            }
#line 853 "GeometryModule.cs"
                            int* csharp2cuda_temp_346 = &(right);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
                        }
                    }
#line 863 "GeometryModule.cs"
#line 863 "GeometryModule.cs"
                    double* csharp2cuda_temp_354 = &((output)->scalar_value);
#line 863 "GeometryModule.cs"
                    double csharp2cuda_temp_355;
#line 863 "GeometryModule.cs"
                    if (((directed_left) > (directed_right)))
                    {
#line 863 "GeometryModule.cs"
                        csharp2cuda_temp_355 = directed_left;
                    }
                    else
                    {
#line 863 "GeometryModule.cs"
                        csharp2cuda_temp_355 = directed_right;
                    }
                    (*(csharp2cuda_temp_354) = csharp2cuda_temp_355);
#line 866 "GeometryModule.cs"
                    break;
                }
#line 868 "GeometryModule.cs"
            case 13:
            case 14:
#line 870 "GeometryModule.cs"
#line 870 "GeometryModule.cs"
                int csharp2cuda_temp_356 = (first)->count;
                if (((csharp2cuda_temp_356) <= (0)))
#line 871 "GeometryModule.cs"
                {
#line 872 "GeometryModule.cs"
#line 872 "GeometryModule.cs"
                    int* csharp2cuda_temp_357 = &((output)->valid);
                    (*(csharp2cuda_temp_357) = 0);
#line 873 "GeometryModule.cs"
                    break;
                }
#line 875 "GeometryModule.cs"
                {
#line 876 "GeometryModule.cs"
                    double total = 0.0;
#line 877 "GeometryModule.cs"
                    int csharp2cuda_temp_358;
#line 877 "GeometryModule.cs"
                    if (((opcode) == (13)))
                    {
#line 877 "GeometryModule.cs"
                        csharp2cuda_temp_358 = 1;
                    }
                    else
                    {
#line 877 "GeometryModule.cs"
                        csharp2cuda_temp_358 = 0;
                    }
#line 877 "GeometryModule.cs"
                    int start = csharp2cuda_temp_358;
#line 878 "GeometryModule.cs"
                    {
#line 878 "GeometryModule.cs"
                        int index = start;
                        while (true)
                        {
#line 878 "GeometryModule.cs"
                            int csharp2cuda_temp_360 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_360))))
                                break;
#line 879 "GeometryModule.cs"
                            {
#line 880 "GeometryModule.cs"
                                int csharp2cuda_temp_361;
#line 880 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 880 "GeometryModule.cs"
                                    csharp2cuda_temp_361 = csharp2cuda_i32_sub(index, 1);
                                }
                                else
                                {
#line 880 "GeometryModule.cs"
                                    csharp2cuda_temp_361 = index;
                                }
#line 880 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_361;
#line 881 "GeometryModule.cs"
                                int csharp2cuda_temp_362;
#line 881 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 881 "GeometryModule.cs"
                                    csharp2cuda_temp_362 = index;
                                }
                                else
                                {
#line 881 "GeometryModule.cs"
                                    int csharp2cuda_temp_363 = (first)->count;
#line 881 "GeometryModule.cs"
                                    csharp2cuda_temp_362 = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_363);
                                }
#line 881 "GeometryModule.cs"
                                int next = csharp2cuda_temp_362;
#line 882 "GeometryModule.cs"
#line 882 "GeometryModule.cs"
                                double* csharp2cuda_temp_364 = &(total);
#line 882 "GeometryModule.cs"
                                double csharp2cuda_temp_365 = *(csharp2cuda_temp_364);
#line 882 "GeometryModule.cs"
                                double csharp2cuda_temp_366 = mathblocks_geometry_distance(a, previous, a, next);
                                (*(csharp2cuda_temp_364) = __dadd_rn(csharp2cuda_temp_365, csharp2cuda_temp_366));
                            }
#line 878 "GeometryModule.cs"
                            int* csharp2cuda_temp_359 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_359));
                        }
                    }
#line 884 "GeometryModule.cs"
#line 884 "GeometryModule.cs"
                    double* csharp2cuda_temp_367 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_367) = total);
#line 885 "GeometryModule.cs"
                    break;
                }
#line 887 "GeometryModule.cs"
            case 15:
#line 888 "GeometryModule.cs"
#line 888 "GeometryModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
#line 888 "GeometryModule.cs"
                bool csharp2cuda_temp_369;
#line 888 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_368) != (1))))
                {
#line 888 "GeometryModule.cs"
                    int csharp2cuda_temp_370 = (second)->count;
#line 888 "GeometryModule.cs"
                    csharp2cuda_temp_369 = ((csharp2cuda_temp_370) != (2));
                }
                else
                {
#line 888 "GeometryModule.cs"
                    csharp2cuda_temp_369 = true;
                }
                if (csharp2cuda_temp_369)
#line 889 "GeometryModule.cs"
                {
#line 890 "GeometryModule.cs"
#line 890 "GeometryModule.cs"
                    int* csharp2cuda_temp_371 = &((output)->valid);
                    (*(csharp2cuda_temp_371) = 0);
#line 891 "GeometryModule.cs"
                    break;
                }
#line 893 "GeometryModule.cs"
#line 893 "GeometryModule.cs"
                double* csharp2cuda_temp_372 = &((output)->scalar_value);
#line 894 "GeometryModule.cs"
                double csharp2cuda_temp_373 = (a)[0];
#line 894 "GeometryModule.cs"
                double csharp2cuda_temp_374 = (a)[1];
#line 894 "GeometryModule.cs"
                double csharp2cuda_temp_375 = (b)[0];
#line 894 "GeometryModule.cs"
                double csharp2cuda_temp_376 = (b)[1];
#line 894 "GeometryModule.cs"
                double csharp2cuda_temp_377 = (b)[2];
#line 894 "GeometryModule.cs"
                double csharp2cuda_temp_378 = (b)[3];
                (*(csharp2cuda_temp_372) = mathblocks_geometry_point_to_segment(csharp2cuda_temp_373, csharp2cuda_temp_374, csharp2cuda_temp_375, csharp2cuda_temp_376, csharp2cuda_temp_377, csharp2cuda_temp_378));
#line 895 "GeometryModule.cs"
                break;
#line 896 "GeometryModule.cs"
            case 16:
            case 17:
#line 898 "GeometryModule.cs"
#line 898 "GeometryModule.cs"
                int csharp2cuda_temp_379 = (first)->count;
                if (((csharp2cuda_temp_379) <= (0)))
#line 899 "GeometryModule.cs"
                {
#line 900 "GeometryModule.cs"
#line 900 "GeometryModule.cs"
                    int* csharp2cuda_temp_380 = &((output)->valid);
                    (*(csharp2cuda_temp_380) = 0);
#line 901 "GeometryModule.cs"
                    break;
                }
#line 903 "GeometryModule.cs"
                {
#line 904 "GeometryModule.cs"
                    double twice_area = 0.0;
#line 905 "GeometryModule.cs"
                    {
#line 905 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 905 "GeometryModule.cs"
                            int csharp2cuda_temp_382 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_382))))
                                break;
#line 906 "GeometryModule.cs"
                            {
#line 907 "GeometryModule.cs"
                                int csharp2cuda_temp_383 = (first)->count;
#line 907 "GeometryModule.cs"
                                int next = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_383);
#line 908 "GeometryModule.cs"
#line 908 "GeometryModule.cs"
                                double* csharp2cuda_temp_384 = &(twice_area);
#line 908 "GeometryModule.cs"
                                double csharp2cuda_temp_385 = *(csharp2cuda_temp_384);
#line 908 "GeometryModule.cs"
                                double csharp2cuda_temp_386 = (a)[csharp2cuda_i32_mul(2, index)];
#line 908 "GeometryModule.cs"
                                double csharp2cuda_temp_387 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, next), 1)];
#line 909 "GeometryModule.cs"
                                double csharp2cuda_temp_388 = (a)[csharp2cuda_i32_mul(2, next)];
#line 909 "GeometryModule.cs"
                                double csharp2cuda_temp_389 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                (*(csharp2cuda_temp_384) = __dadd_rn(csharp2cuda_temp_385, __dsub_rn(__dmul_rn(csharp2cuda_temp_386, csharp2cuda_temp_387), __dmul_rn(csharp2cuda_temp_388, csharp2cuda_temp_389))));
                            }
#line 905 "GeometryModule.cs"
                            int* csharp2cuda_temp_381 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_381));
                        }
                    }
#line 911 "GeometryModule.cs"
#line 911 "GeometryModule.cs"
                    double* csharp2cuda_temp_390 = &((output)->scalar_value);
#line 911 "GeometryModule.cs"
                    double csharp2cuda_temp_391;
#line 911 "GeometryModule.cs"
                    if (((opcode) == (16)))
                    {
#line 911 "GeometryModule.cs"
                        double csharp2cuda_temp_392 = __ddiv_rn(twice_area, 2.0);
#line 911 "GeometryModule.cs"
                        csharp2cuda_temp_391 = fabs(csharp2cuda_temp_392);
                    }
                    else
                    {
#line 911 "GeometryModule.cs"
                        csharp2cuda_temp_391 = __ddiv_rn(twice_area, 2.0);
                    }
                    (*(csharp2cuda_temp_390) = csharp2cuda_temp_391);
#line 912 "GeometryModule.cs"
                    break;
                }
#line 914 "GeometryModule.cs"
            case 18:
#line 915 "GeometryModule.cs"
#line 915 "GeometryModule.cs"
                int csharp2cuda_temp_393 = (first)->count;
#line 915 "GeometryModule.cs"
                bool csharp2cuda_temp_394;
#line 915 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_393) < (3))))
                {
#line 915 "GeometryModule.cs"
                    int csharp2cuda_temp_395 = (second)->count;
#line 915 "GeometryModule.cs"
                    csharp2cuda_temp_394 = ((csharp2cuda_temp_395) != (1));
                }
                else
                {
#line 915 "GeometryModule.cs"
                    csharp2cuda_temp_394 = true;
                }
                if (csharp2cuda_temp_394)
#line 916 "GeometryModule.cs"
                {
#line 917 "GeometryModule.cs"
#line 917 "GeometryModule.cs"
                    int* csharp2cuda_temp_396 = &((output)->valid);
                    (*(csharp2cuda_temp_396) = 0);
#line 918 "GeometryModule.cs"
                    break;
                }
#line 920 "GeometryModule.cs"
                {
#line 921 "GeometryModule.cs"
                    int containing = 0;
#line 922 "GeometryModule.cs"
                    int total = 0;
#line 923 "GeometryModule.cs"
                    double csharp2cuda_temp_397_storage[3];
                    double* coordinates = csharp2cuda_temp_397_storage;
#line 924 "GeometryModule.cs"
                    {
#line 924 "GeometryModule.cs"
                        int one = 0;
                        while (true)
                        {
#line 924 "GeometryModule.cs"
                            int csharp2cuda_temp_399 = (first)->count;
                            if (!(((one) < (csharp2cuda_temp_399))))
                                break;
#line 925 "GeometryModule.cs"
                            {
#line 925 "GeometryModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
#line 925 "GeometryModule.cs"
                                    int csharp2cuda_temp_401 = (first)->count;
                                    if (!(((two) < (csharp2cuda_temp_401))))
                                        break;
#line 926 "GeometryModule.cs"
                                    {
#line 926 "GeometryModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
#line 926 "GeometryModule.cs"
                                            int csharp2cuda_temp_403 = (first)->count;
                                            if (!(((three) < (csharp2cuda_temp_403))))
                                                break;
#line 927 "GeometryModule.cs"
                                            {
#line 928 "GeometryModule.cs"
#line 928 "GeometryModule.cs"
                                                int* csharp2cuda_temp_404 = &(total);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_404));
#line 930 "GeometryModule.cs"
#line 931 "GeometryModule.cs"
                                                double csharp2cuda_temp_405 = (a)[csharp2cuda_i32_mul(2, one)];
#line 931 "GeometryModule.cs"
                                                double csharp2cuda_temp_406 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 932 "GeometryModule.cs"
                                                double csharp2cuda_temp_407 = (a)[csharp2cuda_i32_mul(2, two)];
#line 932 "GeometryModule.cs"
                                                double csharp2cuda_temp_408 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 933 "GeometryModule.cs"
                                                double csharp2cuda_temp_409 = (a)[csharp2cuda_i32_mul(2, three)];
#line 933 "GeometryModule.cs"
                                                double csharp2cuda_temp_410 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                if (((mathblocks_geometry_barycentric_denominator(csharp2cuda_temp_405, csharp2cuda_temp_406, csharp2cuda_temp_407, csharp2cuda_temp_408, csharp2cuda_temp_409, csharp2cuda_temp_410)) == (0.0)))
                                                {
#line 934 "GeometryModule.cs"
                                                    goto csharp2cuda_for_continue_35;
                                                }
#line 935 "GeometryModule.cs"
#line 936 "GeometryModule.cs"
                                                double csharp2cuda_temp_411 = (b)[0];
#line 936 "GeometryModule.cs"
                                                double csharp2cuda_temp_412 = (b)[1];
#line 937 "GeometryModule.cs"
                                                double csharp2cuda_temp_413 = (a)[csharp2cuda_i32_mul(2, one)];
#line 937 "GeometryModule.cs"
                                                double csharp2cuda_temp_414 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 938 "GeometryModule.cs"
                                                double csharp2cuda_temp_415 = (a)[csharp2cuda_i32_mul(2, two)];
#line 938 "GeometryModule.cs"
                                                double csharp2cuda_temp_416 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 939 "GeometryModule.cs"
                                                double csharp2cuda_temp_417 = (a)[csharp2cuda_i32_mul(2, three)];
#line 939 "GeometryModule.cs"
                                                double csharp2cuda_temp_418 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                mathblocks_geometry_barycentric(csharp2cuda_temp_411, csharp2cuda_temp_412, csharp2cuda_temp_413, csharp2cuda_temp_414, csharp2cuda_temp_415, csharp2cuda_temp_416, csharp2cuda_temp_417, csharp2cuda_temp_418, coordinates);
#line 941 "GeometryModule.cs"
#line 941 "GeometryModule.cs"
                                                double csharp2cuda_temp_419 = (coordinates)[0];
#line 941 "GeometryModule.cs"
                                                bool csharp2cuda_temp_420;
#line 941 "GeometryModule.cs"
                                                if (!((!(isfinite(csharp2cuda_temp_419)))))
                                                {
#line 941 "GeometryModule.cs"
                                                    double csharp2cuda_temp_421 = (coordinates)[1];
#line 941 "GeometryModule.cs"
                                                    csharp2cuda_temp_420 = (!(isfinite(csharp2cuda_temp_421)));
                                                }
                                                else
                                                {
#line 941 "GeometryModule.cs"
                                                    csharp2cuda_temp_420 = true;
                                                }
#line 941 "GeometryModule.cs"
                                                bool csharp2cuda_temp_422;
#line 941 "GeometryModule.cs"
                                                if (!(csharp2cuda_temp_420))
                                                {
#line 942 "GeometryModule.cs"
                                                    double csharp2cuda_temp_423 = (coordinates)[2];
#line 941 "GeometryModule.cs"
                                                    csharp2cuda_temp_422 = (!(isfinite(csharp2cuda_temp_423)));
                                                }
                                                else
                                                {
#line 941 "GeometryModule.cs"
                                                    csharp2cuda_temp_422 = true;
                                                }
                                                if (csharp2cuda_temp_422)
                                                {
#line 943 "GeometryModule.cs"
#line 943 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_424 = &((output)->valid);
                                                    (*(csharp2cuda_temp_424) = 0);
                                                }
#line 944 "GeometryModule.cs"
#line 944 "GeometryModule.cs"
                                                double csharp2cuda_temp_425 = (coordinates)[0];
#line 944 "GeometryModule.cs"
                                                bool csharp2cuda_temp_426;
#line 944 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_425) >= (0.0)))
                                                {
#line 944 "GeometryModule.cs"
                                                    double csharp2cuda_temp_427 = (coordinates)[0];
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_426 = ((csharp2cuda_temp_427) <= (1.0));
                                                }
                                                else
                                                {
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_426 = false;
                                                }
#line 944 "GeometryModule.cs"
                                                bool csharp2cuda_temp_428;
#line 944 "GeometryModule.cs"
                                                if (csharp2cuda_temp_426)
                                                {
#line 945 "GeometryModule.cs"
                                                    double csharp2cuda_temp_429 = (coordinates)[1];
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_428 = ((csharp2cuda_temp_429) >= (0.0));
                                                }
                                                else
                                                {
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_428 = false;
                                                }
#line 944 "GeometryModule.cs"
                                                bool csharp2cuda_temp_430;
#line 944 "GeometryModule.cs"
                                                if (csharp2cuda_temp_428)
                                                {
#line 945 "GeometryModule.cs"
                                                    double csharp2cuda_temp_431 = (coordinates)[1];
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_430 = ((csharp2cuda_temp_431) <= (1.0));
                                                }
                                                else
                                                {
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_430 = false;
                                                }
#line 944 "GeometryModule.cs"
                                                bool csharp2cuda_temp_432;
#line 944 "GeometryModule.cs"
                                                if (csharp2cuda_temp_430)
                                                {
#line 946 "GeometryModule.cs"
                                                    double csharp2cuda_temp_433 = (coordinates)[2];
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_432 = ((csharp2cuda_temp_433) >= (0.0));
                                                }
                                                else
                                                {
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_432 = false;
                                                }
#line 944 "GeometryModule.cs"
                                                bool csharp2cuda_temp_434;
#line 944 "GeometryModule.cs"
                                                if (csharp2cuda_temp_432)
                                                {
#line 946 "GeometryModule.cs"
                                                    double csharp2cuda_temp_435 = (coordinates)[2];
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_434 = ((csharp2cuda_temp_435) <= (1.0));
                                                }
                                                else
                                                {
#line 944 "GeometryModule.cs"
                                                    csharp2cuda_temp_434 = false;
                                                }
                                                if (csharp2cuda_temp_434)
#line 947 "GeometryModule.cs"
                                                {
#line 948 "GeometryModule.cs"
#line 948 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_436 = &(containing);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_436));
                                                }
                                            }
                                            csharp2cuda_for_continue_35:
#line 926 "GeometryModule.cs"
                                            int* csharp2cuda_temp_402 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_402));
                                        }
                                    }
#line 925 "GeometryModule.cs"
                                    int* csharp2cuda_temp_400 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_400));
                                }
                            }
#line 924 "GeometryModule.cs"
                            int* csharp2cuda_temp_398 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_398));
                        }
                    }
#line 951 "GeometryModule.cs"
#line 951 "GeometryModule.cs"
                    double* csharp2cuda_temp_437 = &((output)->scalar_value);
#line 951 "GeometryModule.cs"
                    double csharp2cuda_temp_438 = __ddiv_rn(((double)(containing)), ((double)(total)));
                    (*(csharp2cuda_temp_437) = csharp2cuda_temp_438);
#line 952 "GeometryModule.cs"
                    break;
                }
#line 954 "GeometryModule.cs"
            case 19:
#line 955 "GeometryModule.cs"
#line 955 "GeometryModule.cs"
                int* csharp2cuda_temp_439 = &((output)->rows);
#line 955 "GeometryModule.cs"
                int csharp2cuda_temp_440 = (first)->rows;
                (*(csharp2cuda_temp_439) = csharp2cuda_temp_440);
#line 956 "GeometryModule.cs"
#line 956 "GeometryModule.cs"
                int* csharp2cuda_temp_441 = &((output)->count);
#line 956 "GeometryModule.cs"
                int csharp2cuda_temp_442 = (first)->rows;
                (*(csharp2cuda_temp_441) = csharp2cuda_temp_442);
#line 957 "GeometryModule.cs"
#line 957 "GeometryModule.cs"
                int csharp2cuda_temp_443 = (first)->columns;
#line 957 "GeometryModule.cs"
                bool csharp2cuda_temp_444;
#line 957 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_443) != (2))))
                {
#line 957 "GeometryModule.cs"
                    int csharp2cuda_temp_445 = (first)->rows;
#line 957 "GeometryModule.cs"
                    int csharp2cuda_temp_446 = (output)->capacity;
#line 957 "GeometryModule.cs"
                    csharp2cuda_temp_444 = ((csharp2cuda_temp_445) > (csharp2cuda_temp_446));
                }
                else
                {
#line 957 "GeometryModule.cs"
                    csharp2cuda_temp_444 = true;
                }
                if (csharp2cuda_temp_444)
#line 958 "GeometryModule.cs"
                {
#line 959 "GeometryModule.cs"
#line 959 "GeometryModule.cs"
                    int* csharp2cuda_temp_447 = &((output)->valid);
                    (*(csharp2cuda_temp_447) = 0);
#line 960 "GeometryModule.cs"
                    break;
                }
#line 962 "GeometryModule.cs"
                {
#line 962 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 962 "GeometryModule.cs"
                        int csharp2cuda_temp_449 = (first)->rows;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_449, 2)))))
                            break;
#line 963 "GeometryModule.cs"
#line 963 "GeometryModule.cs"
                        double* csharp2cuda_temp_450 = &((result)[index]);
#line 963 "GeometryModule.cs"
                        double csharp2cuda_temp_451 = (a)[index];
                        (*(csharp2cuda_temp_450) = csharp2cuda_temp_451);
#line 962 "GeometryModule.cs"
                        int* csharp2cuda_temp_448 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_448));
                    }
                }
#line 964 "GeometryModule.cs"
                break;
#line 965 "GeometryModule.cs"
            case 20:
#line 966 "GeometryModule.cs"
#line 966 "GeometryModule.cs"
                int csharp2cuda_temp_452 = (first)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_452, 2);
#line 967 "GeometryModule.cs"
#line 967 "GeometryModule.cs"
                int csharp2cuda_temp_453 = (first)->count;
                if (((csharp2cuda_temp_453) <= (0)))
#line 968 "GeometryModule.cs"
                {
#line 969 "GeometryModule.cs"
#line 969 "GeometryModule.cs"
                    int* csharp2cuda_temp_454 = &((output)->valid);
                    (*(csharp2cuda_temp_454) = 0);
#line 970 "GeometryModule.cs"
                    break;
                }
#line 972 "GeometryModule.cs"
                {
#line 972 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 972 "GeometryModule.cs"
                        int csharp2cuda_temp_456 = (first)->count;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_456, 2)))))
                            break;
#line 973 "GeometryModule.cs"
#line 973 "GeometryModule.cs"
                        double* csharp2cuda_temp_457 = &((result)[index]);
#line 973 "GeometryModule.cs"
                        double csharp2cuda_temp_458 = (a)[index];
                        (*(csharp2cuda_temp_457) = csharp2cuda_temp_458);
#line 972 "GeometryModule.cs"
                        int* csharp2cuda_temp_455 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_455));
                    }
                }
#line 974 "GeometryModule.cs"
                break;
#line 975 "GeometryModule.cs"
            case 21:
#line 976 "GeometryModule.cs"
#line 976 "GeometryModule.cs"
                int csharp2cuda_temp_459 = (first)->count;
#line 976 "GeometryModule.cs"
                bool csharp2cuda_temp_460;
#line 976 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_459) <= (0))))
                {
#line 976 "GeometryModule.cs"
                    csharp2cuda_temp_460 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 976 "GeometryModule.cs"
                    csharp2cuda_temp_460 = true;
                }
                if (csharp2cuda_temp_460)
#line 977 "GeometryModule.cs"
                {
#line 978 "GeometryModule.cs"
#line 978 "GeometryModule.cs"
                    int* csharp2cuda_temp_461 = &((output)->valid);
                    (*(csharp2cuda_temp_461) = 0);
#line 979 "GeometryModule.cs"
                    break;
                }
#line 981 "GeometryModule.cs"
#line 981 "GeometryModule.cs"
                int csharp2cuda_temp_462 = (first)->count;
                if (((csharp2cuda_temp_462) == (1)))
#line 982 "GeometryModule.cs"
                {
#line 983 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, 0);
#line 984 "GeometryModule.cs"
                    break;
                }
#line 986 "GeometryModule.cs"
                {
#line 987 "GeometryModule.cs"
                    int vertex_count = (first)->count;
#line 988 "GeometryModule.cs"
                    int edge_capacity = csharp2cuda_i32_div(csharp2cuda_i32_mul(vertex_count, csharp2cuda_i32_sub(vertex_count, 1)), 2);
#line 989 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(scratch));
#line 990 "GeometryModule.cs"
                    int edge_count = 0;
#line 991 "GeometryModule.cs"
                    {
#line 991 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (vertex_count))))
                                break;
#line 992 "GeometryModule.cs"
                            {
#line 992 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (vertex_count))))
                                        break;
#line 993 "GeometryModule.cs"
                                    {
#line 994 "GeometryModule.cs"
#line 994 "GeometryModule.cs"
                                        int* csharp2cuda_temp_465 = &(((edges)[edge_count]).from);
                                        (*(csharp2cuda_temp_465) = left);
#line 995 "GeometryModule.cs"
#line 995 "GeometryModule.cs"
                                        int* csharp2cuda_temp_466 = &(((edges)[edge_count]).to);
                                        (*(csharp2cuda_temp_466) = right);
#line 996 "GeometryModule.cs"
#line 996 "GeometryModule.cs"
                                        double* csharp2cuda_temp_467 = &(((edges)[edge_count]).weight);
#line 996 "GeometryModule.cs"
                                        double csharp2cuda_temp_468 = mathblocks_geometry_distance(a, left, a, right);
                                        (*(csharp2cuda_temp_467) = csharp2cuda_temp_468);
#line 997 "GeometryModule.cs"
#line 997 "GeometryModule.cs"
                                        int* csharp2cuda_temp_469 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_469));
                                    }
#line 992 "GeometryModule.cs"
                                    int* csharp2cuda_temp_464 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_464));
                                }
                            }
#line 991 "GeometryModule.cs"
                            int* csharp2cuda_temp_463 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_463));
                        }
                    }
#line 999 "GeometryModule.cs"
                    mathblocks_geometry_sort_edges(edges, csharp2cuda_pointer_add(edges, edge_capacity), edge_count);
#line 1000 "GeometryModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(edges, csharp2cuda_i32_mul(2, edge_capacity))));
#line 1001 "GeometryModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 1002 "GeometryModule.cs"
                    {
#line 1002 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 1003 "GeometryModule.cs"
                            {
#line 1004 "GeometryModule.cs"
#line 1004 "GeometryModule.cs"
                                int* csharp2cuda_temp_471 = &((parent)[index]);
                                (*(csharp2cuda_temp_471) = index);
#line 1005 "GeometryModule.cs"
#line 1005 "GeometryModule.cs"
                                unsigned char* csharp2cuda_temp_472 = &((rank)[index]);
                                (*(csharp2cuda_temp_472) = ((unsigned char)(0)));
                            }
#line 1002 "GeometryModule.cs"
                            int* csharp2cuda_temp_470 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_470));
                        }
                    }
#line 1007 "GeometryModule.cs"
                    int selected = 0;
#line 1008 "GeometryModule.cs"
                    {
#line 1008 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1008 "GeometryModule.cs"
                            bool csharp2cuda_temp_474;
#line 1008 "GeometryModule.cs"
                            if (((index) < (edge_count)))
                            {
#line 1008 "GeometryModule.cs"
                                csharp2cuda_temp_474 = ((selected) < (csharp2cuda_i32_sub(vertex_count, 1)));
                            }
                            else
                            {
#line 1008 "GeometryModule.cs"
                                csharp2cuda_temp_474 = false;
                            }
                            if (!(csharp2cuda_temp_474))
                                break;
#line 1009 "GeometryModule.cs"
                            {
#line 1010 "GeometryModule.cs"
                                int csharp2cuda_temp_475 = ((edges)[index]).from;
#line 1010 "GeometryModule.cs"
                                int left = mathblocks_geometry_find(parent, csharp2cuda_temp_475);
#line 1011 "GeometryModule.cs"
                                int csharp2cuda_temp_476 = ((edges)[index]).to;
#line 1011 "GeometryModule.cs"
                                int right = mathblocks_geometry_find(parent, csharp2cuda_temp_476);
#line 1012 "GeometryModule.cs"
                                if (((left) == (right)))
                                {
#line 1013 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_43;
                                }
#line 1014 "GeometryModule.cs"
#line 1014 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_477 = (rank)[left];
#line 1014 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_478 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_477))) < (((int)(csharp2cuda_temp_478)))))
                                {
#line 1015 "GeometryModule.cs"
#line 1015 "GeometryModule.cs"
                                    int* csharp2cuda_temp_479 = &((parent)[left]);
                                    (*(csharp2cuda_temp_479) = right);
                                }
                                else
                                {
#line 1016 "GeometryModule.cs"
#line 1016 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_480 = (rank)[left];
#line 1016 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_481 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_480))) > (((int)(csharp2cuda_temp_481)))))
                                    {
#line 1017 "GeometryModule.cs"
#line 1017 "GeometryModule.cs"
                                        int* csharp2cuda_temp_482 = &((parent)[right]);
                                        (*(csharp2cuda_temp_482) = left);
                                    }
                                    else
#line 1019 "GeometryModule.cs"
                                    {
#line 1020 "GeometryModule.cs"
#line 1020 "GeometryModule.cs"
                                        int* csharp2cuda_temp_483 = &((parent)[right]);
                                        (*(csharp2cuda_temp_483) = left);
#line 1021 "GeometryModule.cs"
#line 1021 "GeometryModule.cs"
                                        unsigned char* csharp2cuda_temp_484 = &((rank)[left]);
                                        (*(csharp2cuda_temp_484))++;
                                    }
                                }
#line 1023 "GeometryModule.cs"
#line 1023 "GeometryModule.cs"
                                int* csharp2cuda_temp_485 = &(selected);
#line 1023 "GeometryModule.cs"
                                int csharp2cuda_temp_486 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_485));
#line 1023 "GeometryModule.cs"
                                double* csharp2cuda_temp_487 = &((result)[csharp2cuda_temp_486]);
#line 1023 "GeometryModule.cs"
                                double csharp2cuda_temp_488 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_487) = csharp2cuda_temp_488);
                            }
                            csharp2cuda_for_continue_43:
#line 1008 "GeometryModule.cs"
                            int* csharp2cuda_temp_473 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
                        }
                    }
#line 1025 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, selected);
#line 1026 "GeometryModule.cs"
                    {
#line 1026 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (selected))))
                                break;
#line 1027 "GeometryModule.cs"
#line 1027 "GeometryModule.cs"
                            double csharp2cuda_temp_490 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_490))))
                            {
#line 1027 "GeometryModule.cs"
#line 1027 "GeometryModule.cs"
                                int* csharp2cuda_temp_491 = &((output)->valid);
                                (*(csharp2cuda_temp_491) = 0);
                            }
#line 1026 "GeometryModule.cs"
                            int* csharp2cuda_temp_489 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_489));
                        }
                    }
#line 1028 "GeometryModule.cs"
                    break;
                }
        }
#line 1031 "GeometryModule.cs"
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_492 = (output)->valid;
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_493;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_492)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_493 = ((opcode) != (0));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_493 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_494;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_493)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_494 = ((opcode) != (1));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_494 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_495;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_494)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_495 = ((opcode) != (3));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_495 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_496;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_495)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_496 = ((opcode) != (4));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_496 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_497;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_496)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_497 = ((opcode) != (5));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_497 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_498;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_497)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_498 = ((opcode) != (10));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_498 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_499;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_498)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_499 = ((opcode) != (19));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_499 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_500;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_499)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_500 = ((opcode) != (20));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_500 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_501;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_500)
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_501 = ((opcode) != (21));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_501 = false;
        }
#line 1031 "GeometryModule.cs"
        bool csharp2cuda_temp_502;
#line 1031 "GeometryModule.cs"
        if (csharp2cuda_temp_501)
        {
#line 1034 "GeometryModule.cs"
            double csharp2cuda_temp_503 = (output)->scalar_value;
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_502 = (!(isfinite(csharp2cuda_temp_503)));
        }
        else
        {
#line 1031 "GeometryModule.cs"
            csharp2cuda_temp_502 = false;
        }
        if (csharp2cuda_temp_502)
#line 1035 "GeometryModule.cs"
        {
#line 1036 "GeometryModule.cs"
#line 1036 "GeometryModule.cs"
            int* csharp2cuda_temp_504 = &((output)->valid);
            (*(csharp2cuda_temp_504) = 0);
        }
    }
}

#line 62 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance(
    const double* left,
    int left_index,
    const double* right,
    int right_index)
#line 68 "GeometryModule.cs"
{
#line 69 "GeometryModule.cs"
#line 70 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (left)[csharp2cuda_i32_mul(2, left_index)];
#line 71 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (left)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left_index), 1)];
#line 72 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (right)[csharp2cuda_i32_mul(2, right_index)];
#line 73 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (right)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right_index), 1)];
    return mathblocks_geometry_distance_coordinates(csharp2cuda_temp_0, csharp2cuda_temp_1, csharp2cuda_temp_2, csharp2cuda_temp_3);
}

#line 50 "GeometryModule.cs"
__device__ double mathblocks_geometry_distance_coordinates(
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 56 "GeometryModule.cs"
{
#line 57 "GeometryModule.cs"
    double x = __dsub_rn(left_x, right_x);
#line 58 "GeometryModule.cs"
    double y = __dsub_rn(left_y, right_y);
#line 59 "GeometryModule.cs"
    return mathblocks_square_root(__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
}

#line 320 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right)
#line 324 "GeometryModule.cs"
{
#line 325 "GeometryModule.cs"
#line 325 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 325 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 326 "GeometryModule.cs"
        return true;
    }
#line 327 "GeometryModule.cs"
#line 327 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 327 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 328 "GeometryModule.cs"
        return false;
    }
#line 329 "GeometryModule.cs"
#line 329 "GeometryModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 329 "GeometryModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 330 "GeometryModule.cs"
        return true;
    }
#line 331 "GeometryModule.cs"
#line 331 "GeometryModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 331 "GeometryModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 332 "GeometryModule.cs"
        return false;
    }
#line 333 "GeometryModule.cs"
#line 333 "GeometryModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 333 "GeometryModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 309 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value)
#line 311 "GeometryModule.cs"
{
#line 312 "GeometryModule.cs"
    while (true)
    {
#line 312 "GeometryModule.cs"
        int csharp2cuda_temp_0 = (parent)[value];
        if (!(((csharp2cuda_temp_0) != (value))))
            break;
#line 313 "GeometryModule.cs"
        {
#line 314 "GeometryModule.cs"
#line 314 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[value]);
#line 314 "GeometryModule.cs"
            int csharp2cuda_temp_2 = (parent)[value];
#line 314 "GeometryModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 315 "GeometryModule.cs"
#line 315 "GeometryModule.cs"
            int* csharp2cuda_temp_4 = &(value);
#line 315 "GeometryModule.cs"
            int csharp2cuda_temp_5 = (parent)[value];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 317 "GeometryModule.cs"
    return value;
}

#line 220 "GeometryModule.cs"
__device__ void mathblocks_geometry_index_order(
    const double* points,
    int count,
    int* order,
    int* buffer)
#line 226 "GeometryModule.cs"
{
#line 227 "GeometryModule.cs"
    {
#line 227 "GeometryModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 228 "GeometryModule.cs"
#line 228 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((order)[index]);
            (*(csharp2cuda_temp_1) = index);
#line 227 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 229 "GeometryModule.cs"
    int* source = order;
#line 230 "GeometryModule.cs"
    int* target = buffer;
#line 231 "GeometryModule.cs"
    {
#line 231 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 232 "GeometryModule.cs"
            {
#line 233 "GeometryModule.cs"
                {
#line 233 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 234 "GeometryModule.cs"
                        {
#line 235 "GeometryModule.cs"
                            int csharp2cuda_temp_6;
#line 235 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 235 "GeometryModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 235 "GeometryModule.cs"
                                csharp2cuda_temp_6 = count;
                            }
#line 235 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_6;
#line 236 "GeometryModule.cs"
                            int csharp2cuda_temp_7;
#line 236 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 236 "GeometryModule.cs"
                                csharp2cuda_temp_7 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 236 "GeometryModule.cs"
                                csharp2cuda_temp_7 = count;
                            }
#line 236 "GeometryModule.cs"
                            int end = csharp2cuda_temp_7;
#line 237 "GeometryModule.cs"
                            int left = start;
#line 238 "GeometryModule.cs"
                            int right = middle;
#line 239 "GeometryModule.cs"
                            int position = start;
#line 240 "GeometryModule.cs"
                            while (true)
                            {
#line 240 "GeometryModule.cs"
                                bool csharp2cuda_temp_8;
#line 240 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 240 "GeometryModule.cs"
                                    csharp2cuda_temp_8 = ((right) < (end));
                                }
                                else
                                {
#line 240 "GeometryModule.cs"
                                    csharp2cuda_temp_8 = false;
                                }
                                if (!(csharp2cuda_temp_8))
                                    break;
#line 241 "GeometryModule.cs"
                                {
#line 242 "GeometryModule.cs"
                                    int csharp2cuda_temp_9 = (source)[right];
#line 242 "GeometryModule.cs"
                                    int csharp2cuda_temp_10 = (source)[left];
#line 242 "GeometryModule.cs"
                                    bool take_right = mathblocks_geometry_point_less(points, csharp2cuda_temp_9, csharp2cuda_temp_10);
#line 243 "GeometryModule.cs"
#line 243 "GeometryModule.cs"
                                    int* csharp2cuda_temp_11 = &(position);
#line 243 "GeometryModule.cs"
                                    int csharp2cuda_temp_12 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
#line 243 "GeometryModule.cs"
                                    int* csharp2cuda_temp_13 = &((target)[csharp2cuda_temp_12]);
#line 243 "GeometryModule.cs"
                                    int csharp2cuda_temp_14;
#line 243 "GeometryModule.cs"
                                    if (take_right)
                                    {
#line 243 "GeometryModule.cs"
                                        int* csharp2cuda_temp_15 = &(right);
#line 243 "GeometryModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 243 "GeometryModule.cs"
                                        csharp2cuda_temp_14 = (source)[csharp2cuda_temp_16];
                                    }
                                    else
                                    {
#line 243 "GeometryModule.cs"
                                        int* csharp2cuda_temp_17 = &(left);
#line 243 "GeometryModule.cs"
                                        int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 243 "GeometryModule.cs"
                                        csharp2cuda_temp_14 = (source)[csharp2cuda_temp_18];
                                    }
                                    (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
                                }
                            }
#line 245 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 246 "GeometryModule.cs"
#line 246 "GeometryModule.cs"
                                int* csharp2cuda_temp_19 = &(position);
#line 246 "GeometryModule.cs"
                                int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 246 "GeometryModule.cs"
                                int* csharp2cuda_temp_21 = &((target)[csharp2cuda_temp_20]);
#line 246 "GeometryModule.cs"
                                int* csharp2cuda_temp_22 = &(left);
#line 246 "GeometryModule.cs"
                                int csharp2cuda_temp_23 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_22));
#line 246 "GeometryModule.cs"
                                int csharp2cuda_temp_24 = (source)[csharp2cuda_temp_23];
                                (*(csharp2cuda_temp_21) = csharp2cuda_temp_24);
                            }
#line 247 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 248 "GeometryModule.cs"
#line 248 "GeometryModule.cs"
                                int* csharp2cuda_temp_25 = &(position);
#line 248 "GeometryModule.cs"
                                int csharp2cuda_temp_26 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_25));
#line 248 "GeometryModule.cs"
                                int* csharp2cuda_temp_27 = &((target)[csharp2cuda_temp_26]);
#line 248 "GeometryModule.cs"
                                int* csharp2cuda_temp_28 = &(right);
#line 248 "GeometryModule.cs"
                                int csharp2cuda_temp_29 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_28));
#line 248 "GeometryModule.cs"
                                int csharp2cuda_temp_30 = (source)[csharp2cuda_temp_29];
                                (*(csharp2cuda_temp_27) = csharp2cuda_temp_30);
                            }
                        }
#line 233 "GeometryModule.cs"
                        int* csharp2cuda_temp_4 = &(start);
#line 233 "GeometryModule.cs"
                        int csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
                        (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(csharp2cuda_temp_5, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 250 "GeometryModule.cs"
                int* sorted = target;
#line 251 "GeometryModule.cs"
#line 251 "GeometryModule.cs"
                int** csharp2cuda_temp_31 = &(target);
                (*(csharp2cuda_temp_31) = source);
#line 252 "GeometryModule.cs"
#line 252 "GeometryModule.cs"
                int** csharp2cuda_temp_32 = &(source);
                (*(csharp2cuda_temp_32) = sorted);
            }
#line 231 "GeometryModule.cs"
            int* csharp2cuda_temp_2 = &(width);
#line 231 "GeometryModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, width));
        }
    }
#line 254 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(order)))))
    {
#line 255 "GeometryModule.cs"
        {
#line 255 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 256 "GeometryModule.cs"
#line 256 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((order)[index]);
#line 256 "GeometryModule.cs"
                int csharp2cuda_temp_35 = (source)[index];
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 255 "GeometryModule.cs"
                int* csharp2cuda_temp_33 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
            }
        }
    }
}

#line 198 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right)
#line 203 "GeometryModule.cs"
{
#line 204 "GeometryModule.cs"
    double left_x = (points)[csharp2cuda_i32_mul(2, left)];
#line 205 "GeometryModule.cs"
    double right_x = (points)[csharp2cuda_i32_mul(2, right)];
#line 206 "GeometryModule.cs"
    if (((left_x) < (right_x)))
    {
#line 207 "GeometryModule.cs"
        return true;
    }
#line 208 "GeometryModule.cs"
    if (((right_x) < (left_x)))
    {
#line 209 "GeometryModule.cs"
        return false;
    }
#line 210 "GeometryModule.cs"
    double left_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 211 "GeometryModule.cs"
    double right_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 212 "GeometryModule.cs"
    if (((left_y) < (right_y)))
    {
#line 213 "GeometryModule.cs"
        return true;
    }
#line 214 "GeometryModule.cs"
    if (((right_y) < (left_y)))
    {
#line 215 "GeometryModule.cs"
        return false;
    }
#line 216 "GeometryModule.cs"
    return ((left) < (right));
}

#line 89 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y)
#line 97 "GeometryModule.cs"
{
#line 98 "GeometryModule.cs"
    double x = __dsub_rn(end_x, start_x);
#line 99 "GeometryModule.cs"
    double y = __dsub_rn(end_y, start_y);
#line 100 "GeometryModule.cs"
    double length_square = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y));
#line 101 "GeometryModule.cs"
    if (((length_square) == (0.0)))
    {
#line 102 "GeometryModule.cs"
        return mathblocks_geometry_distance_coordinates(point_x, point_y, start_x, start_y);
    }
#line 103 "GeometryModule.cs"
    double projection = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(point_x, start_x), x), __dmul_rn(__dsub_rn(point_y, start_y), y)), length_square);
#line 105 "GeometryModule.cs"
#line 105 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &(projection);
#line 105 "GeometryModule.cs"
    double csharp2cuda_temp_1;
#line 105 "GeometryModule.cs"
    if (((projection) < (0.0)))
    {
#line 105 "GeometryModule.cs"
        csharp2cuda_temp_1 = 0.0;
    }
    else
    {
#line 105 "GeometryModule.cs"
        double csharp2cuda_temp_2;
#line 105 "GeometryModule.cs"
        if (((projection) > (1.0)))
        {
#line 105 "GeometryModule.cs"
            csharp2cuda_temp_2 = 1.0;
        }
        else
        {
#line 105 "GeometryModule.cs"
            csharp2cuda_temp_2 = projection;
        }
#line 105 "GeometryModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_temp_2;
    }
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 106 "GeometryModule.cs"
    return mathblocks_geometry_distance_coordinates(point_x, point_y, __dadd_rn(start_x, __dmul_rn(projection, x)), __dadd_rn(start_y, __dmul_rn(projection, y)));
}

#line 338 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count)
#line 340 "GeometryModule.cs"
{
#line 341 "GeometryModule.cs"
    MathBlockGeometryEdge* source = edges;
#line 342 "GeometryModule.cs"
    MathBlockGeometryEdge* target = buffer;
#line 343 "GeometryModule.cs"
    {
#line 343 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 344 "GeometryModule.cs"
            {
#line 345 "GeometryModule.cs"
                {
#line 345 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 346 "GeometryModule.cs"
                        {
#line 347 "GeometryModule.cs"
                            int csharp2cuda_temp_4;
#line 347 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 347 "GeometryModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 347 "GeometryModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 347 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 348 "GeometryModule.cs"
                            int csharp2cuda_temp_5;
#line 348 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 348 "GeometryModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 348 "GeometryModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 348 "GeometryModule.cs"
                            int end = csharp2cuda_temp_5;
#line 349 "GeometryModule.cs"
                            int left = start;
#line 350 "GeometryModule.cs"
                            int right = middle;
#line 351 "GeometryModule.cs"
                            int position = start;
#line 352 "GeometryModule.cs"
                            while (true)
                            {
#line 352 "GeometryModule.cs"
                                bool csharp2cuda_temp_6;
#line 352 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 352 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 352 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 353 "GeometryModule.cs"
                                {
#line 354 "GeometryModule.cs"
#line 354 "GeometryModule.cs"
                                    MathBlockGeometryEdge* csharp2cuda_temp_7 = &((source)[right]);
#line 354 "GeometryModule.cs"
                                    MathBlockGeometryEdge* csharp2cuda_temp_8 = &((source)[left]);
                                    if (mathblocks_geometry_edge_less(csharp2cuda_temp_7, csharp2cuda_temp_8))
                                    {
#line 355 "GeometryModule.cs"
#line 355 "GeometryModule.cs"
                                        int* csharp2cuda_temp_9 = &(position);
#line 355 "GeometryModule.cs"
                                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 355 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_11 = &((target)[csharp2cuda_temp_10]);
#line 355 "GeometryModule.cs"
                                        int* csharp2cuda_temp_12 = &(right);
#line 355 "GeometryModule.cs"
                                        int csharp2cuda_temp_13 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
#line 355 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_14 = (source)[csharp2cuda_temp_13];
                                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_14);
                                    }
                                    else
                                    {
#line 357 "GeometryModule.cs"
#line 357 "GeometryModule.cs"
                                        int* csharp2cuda_temp_15 = &(position);
#line 357 "GeometryModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 357 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_17 = &((target)[csharp2cuda_temp_16]);
#line 357 "GeometryModule.cs"
                                        int* csharp2cuda_temp_18 = &(left);
#line 357 "GeometryModule.cs"
                                        int csharp2cuda_temp_19 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
#line 357 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_20 = (source)[csharp2cuda_temp_19];
                                        (*(csharp2cuda_temp_17) = csharp2cuda_temp_20);
                                    }
                                }
                            }
#line 359 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 360 "GeometryModule.cs"
#line 360 "GeometryModule.cs"
                                int* csharp2cuda_temp_21 = &(position);
#line 360 "GeometryModule.cs"
                                int csharp2cuda_temp_22 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
#line 360 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_23 = &((target)[csharp2cuda_temp_22]);
#line 360 "GeometryModule.cs"
                                int* csharp2cuda_temp_24 = &(left);
#line 360 "GeometryModule.cs"
                                int csharp2cuda_temp_25 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
#line 360 "GeometryModule.cs"
                                MathBlockGeometryEdge csharp2cuda_temp_26 = (source)[csharp2cuda_temp_25];
                                (*(csharp2cuda_temp_23) = csharp2cuda_temp_26);
                            }
#line 361 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 362 "GeometryModule.cs"
#line 362 "GeometryModule.cs"
                                int* csharp2cuda_temp_27 = &(position);
#line 362 "GeometryModule.cs"
                                int csharp2cuda_temp_28 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 362 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_29 = &((target)[csharp2cuda_temp_28]);
#line 362 "GeometryModule.cs"
                                int* csharp2cuda_temp_30 = &(right);
#line 362 "GeometryModule.cs"
                                int csharp2cuda_temp_31 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_30));
#line 362 "GeometryModule.cs"
                                MathBlockGeometryEdge csharp2cuda_temp_32 = (source)[csharp2cuda_temp_31];
                                (*(csharp2cuda_temp_29) = csharp2cuda_temp_32);
                            }
                        }
#line 345 "GeometryModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 345 "GeometryModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 364 "GeometryModule.cs"
                MathBlockGeometryEdge* sorted = target;
#line 365 "GeometryModule.cs"
#line 365 "GeometryModule.cs"
                MathBlockGeometryEdge** csharp2cuda_temp_33 = &(target);
                (*(csharp2cuda_temp_33) = source);
#line 366 "GeometryModule.cs"
#line 366 "GeometryModule.cs"
                MathBlockGeometryEdge** csharp2cuda_temp_34 = &(source);
                (*(csharp2cuda_temp_34) = sorted);
            }
#line 343 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 343 "GeometryModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 368 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(edges)))))
    {
#line 369 "GeometryModule.cs"
        {
#line 369 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 370 "GeometryModule.cs"
#line 370 "GeometryModule.cs"
                MathBlockGeometryEdge* csharp2cuda_temp_36 = &((edges)[index]);
#line 370 "GeometryModule.cs"
                MathBlockGeometryEdge csharp2cuda_temp_37 = (source)[index];
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 369 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
            }
        }
    }
}

#line 262 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_points(double* points, double* buffer, int count)
#line 264 "GeometryModule.cs"
{
#line 265 "GeometryModule.cs"
    double* source = points;
#line 266 "GeometryModule.cs"
    double* target = buffer;
#line 267 "GeometryModule.cs"
    {
#line 267 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 268 "GeometryModule.cs"
            {
#line 269 "GeometryModule.cs"
                {
#line 269 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 270 "GeometryModule.cs"
                        {
#line 271 "GeometryModule.cs"
                            int csharp2cuda_temp_4;
#line 271 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 271 "GeometryModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 271 "GeometryModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 271 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 272 "GeometryModule.cs"
                            int csharp2cuda_temp_5;
#line 272 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 272 "GeometryModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 272 "GeometryModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 272 "GeometryModule.cs"
                            int end = csharp2cuda_temp_5;
#line 273 "GeometryModule.cs"
                            int left = start;
#line 274 "GeometryModule.cs"
                            int right = middle;
#line 275 "GeometryModule.cs"
                            int position = start;
#line 276 "GeometryModule.cs"
                            while (true)
                            {
#line 276 "GeometryModule.cs"
                                bool csharp2cuda_temp_6;
#line 276 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 276 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 276 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 277 "GeometryModule.cs"
                                {
#line 278 "GeometryModule.cs"
                                    double csharp2cuda_temp_7 = (source)[csharp2cuda_i32_mul(2, right)];
#line 278 "GeometryModule.cs"
                                    double csharp2cuda_temp_8 = (source)[csharp2cuda_i32_mul(2, left)];
#line 278 "GeometryModule.cs"
                                    bool csharp2cuda_temp_9;
#line 278 "GeometryModule.cs"
                                    if (!(((csharp2cuda_temp_7) < (csharp2cuda_temp_8))))
                                    {
#line 279 "GeometryModule.cs"
                                        double csharp2cuda_temp_10 = (source)[csharp2cuda_i32_mul(2, right)];
#line 279 "GeometryModule.cs"
                                        double csharp2cuda_temp_11 = (source)[csharp2cuda_i32_mul(2, left)];
#line 279 "GeometryModule.cs"
                                        bool csharp2cuda_temp_12;
#line 279 "GeometryModule.cs"
                                        if (((csharp2cuda_temp_10) == (csharp2cuda_temp_11)))
                                        {
#line 279 "GeometryModule.cs"
                                            double csharp2cuda_temp_13 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 279 "GeometryModule.cs"
                                            double csharp2cuda_temp_14 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 279 "GeometryModule.cs"
                                            csharp2cuda_temp_12 = ((csharp2cuda_temp_13) < (csharp2cuda_temp_14));
                                        }
                                        else
                                        {
#line 279 "GeometryModule.cs"
                                            csharp2cuda_temp_12 = false;
                                        }
#line 278 "GeometryModule.cs"
                                        csharp2cuda_temp_9 = csharp2cuda_temp_12;
                                    }
                                    else
                                    {
#line 278 "GeometryModule.cs"
                                        csharp2cuda_temp_9 = true;
                                    }
#line 278 "GeometryModule.cs"
                                    bool take_right = csharp2cuda_temp_9;
#line 280 "GeometryModule.cs"
                                    int csharp2cuda_temp_15;
#line 280 "GeometryModule.cs"
                                    if (take_right)
                                    {
#line 280 "GeometryModule.cs"
                                        int* csharp2cuda_temp_16 = &(right);
#line 280 "GeometryModule.cs"
                                        csharp2cuda_temp_15 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                    }
                                    else
                                    {
#line 280 "GeometryModule.cs"
                                        int* csharp2cuda_temp_17 = &(left);
#line 280 "GeometryModule.cs"
                                        csharp2cuda_temp_15 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                                    }
#line 280 "GeometryModule.cs"
                                    int from = csharp2cuda_temp_15;
#line 281 "GeometryModule.cs"
#line 281 "GeometryModule.cs"
                                    double* csharp2cuda_temp_18 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 281 "GeometryModule.cs"
                                    double csharp2cuda_temp_19 = (source)[csharp2cuda_i32_mul(2, from)];
                                    (*(csharp2cuda_temp_18) = csharp2cuda_temp_19);
#line 282 "GeometryModule.cs"
#line 282 "GeometryModule.cs"
                                    double* csharp2cuda_temp_20 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 282 "GeometryModule.cs"
                                    double csharp2cuda_temp_21 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, from), 1)];
                                    (*(csharp2cuda_temp_20) = csharp2cuda_temp_21);
#line 283 "GeometryModule.cs"
#line 283 "GeometryModule.cs"
                                    int* csharp2cuda_temp_22 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_22));
                                }
                            }
#line 285 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 286 "GeometryModule.cs"
                                {
#line 287 "GeometryModule.cs"
#line 287 "GeometryModule.cs"
                                    double* csharp2cuda_temp_23 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 287 "GeometryModule.cs"
                                    double csharp2cuda_temp_24 = (source)[csharp2cuda_i32_mul(2, left)];
                                    (*(csharp2cuda_temp_23) = csharp2cuda_temp_24);
#line 288 "GeometryModule.cs"
#line 288 "GeometryModule.cs"
                                    double* csharp2cuda_temp_25 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 288 "GeometryModule.cs"
                                    double csharp2cuda_temp_26 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
                                    (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 289 "GeometryModule.cs"
#line 289 "GeometryModule.cs"
                                    int* csharp2cuda_temp_27 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 290 "GeometryModule.cs"
#line 290 "GeometryModule.cs"
                                    int* csharp2cuda_temp_28 = &(left);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_28));
                                }
                            }
#line 292 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 293 "GeometryModule.cs"
                                {
#line 294 "GeometryModule.cs"
#line 294 "GeometryModule.cs"
                                    double* csharp2cuda_temp_29 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 294 "GeometryModule.cs"
                                    double csharp2cuda_temp_30 = (source)[csharp2cuda_i32_mul(2, right)];
                                    (*(csharp2cuda_temp_29) = csharp2cuda_temp_30);
#line 295 "GeometryModule.cs"
#line 295 "GeometryModule.cs"
                                    double* csharp2cuda_temp_31 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 295 "GeometryModule.cs"
                                    double csharp2cuda_temp_32 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
                                    (*(csharp2cuda_temp_31) = csharp2cuda_temp_32);
#line 296 "GeometryModule.cs"
#line 296 "GeometryModule.cs"
                                    int* csharp2cuda_temp_33 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
#line 297 "GeometryModule.cs"
#line 297 "GeometryModule.cs"
                                    int* csharp2cuda_temp_34 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_34));
                                }
                            }
                        }
#line 269 "GeometryModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 269 "GeometryModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 300 "GeometryModule.cs"
                double* sorted = target;
#line 301 "GeometryModule.cs"
#line 301 "GeometryModule.cs"
                double** csharp2cuda_temp_35 = &(target);
                (*(csharp2cuda_temp_35) = source);
#line 302 "GeometryModule.cs"
#line 302 "GeometryModule.cs"
                double** csharp2cuda_temp_36 = &(source);
                (*(csharp2cuda_temp_36) = sorted);
            }
#line 267 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 267 "GeometryModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 304 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(points)))))
    {
#line 305 "GeometryModule.cs"
        {
#line 305 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (csharp2cuda_i32_mul(2, count)))))
                    break;
#line 306 "GeometryModule.cs"
#line 306 "GeometryModule.cs"
                double* csharp2cuda_temp_38 = &((points)[index]);
#line 306 "GeometryModule.cs"
                double csharp2cuda_temp_39 = (source)[index];
                (*(csharp2cuda_temp_38) = csharp2cuda_temp_39);
#line 305 "GeometryModule.cs"
                int* csharp2cuda_temp_37 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_37));
            }
        }
    }
}

#line 157 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square)
#line 166 "GeometryModule.cs"
{
#line 167 "GeometryModule.cs"
    double first_x = (points)[csharp2cuda_i32_mul(2, first)];
#line 168 "GeometryModule.cs"
    double first_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, first), 1)];
#line 169 "GeometryModule.cs"
    double second_x = (points)[csharp2cuda_i32_mul(2, second)];
#line 170 "GeometryModule.cs"
    double second_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, second), 1)];
#line 171 "GeometryModule.cs"
    double third_x = (points)[csharp2cuda_i32_mul(2, third)];
#line 172 "GeometryModule.cs"
    double third_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, third), 1)];
#line 173 "GeometryModule.cs"
    double denominator = __dmul_rn(2.0, __dadd_rn(__dadd_rn(__dmul_rn(first_x, __dsub_rn(second_y, third_y)), __dmul_rn(second_x, __dsub_rn(third_y, first_y))), __dmul_rn(third_x, __dsub_rn(first_y, second_y))));
#line 176 "GeometryModule.cs"
    if (((denominator) == (0.0)))
#line 177 "GeometryModule.cs"
    {
#line 178 "GeometryModule.cs"
#line 178 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = center_x;
        (*(csharp2cuda_temp_0) = 0.0);
#line 179 "GeometryModule.cs"
#line 179 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = center_y;
        (*(csharp2cuda_temp_1) = 0.0);
#line 180 "GeometryModule.cs"
#line 180 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = radius_square;
        (*(csharp2cuda_temp_2) = 0.0);
#line 181 "GeometryModule.cs"
        return false;
    }
#line 183 "GeometryModule.cs"
    double first_square = __dadd_rn(__dmul_rn(first_x, first_x), __dmul_rn(first_y, first_y));
#line 184 "GeometryModule.cs"
    double second_square = __dadd_rn(__dmul_rn(second_x, second_x), __dmul_rn(second_y, second_y));
#line 185 "GeometryModule.cs"
    double third_square = __dadd_rn(__dmul_rn(third_x, third_x), __dmul_rn(third_y, third_y));
#line 186 "GeometryModule.cs"
#line 186 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = center_x;
#line 186 "GeometryModule.cs"
    double csharp2cuda_temp_4 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(second_y, third_y)), __dmul_rn(second_square, __dsub_rn(third_y, first_y))), __dmul_rn(third_square, __dsub_rn(first_y, second_y))), denominator);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 189 "GeometryModule.cs"
#line 189 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = center_y;
#line 189 "GeometryModule.cs"
    double csharp2cuda_temp_6 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(third_x, second_x)), __dmul_rn(second_square, __dsub_rn(first_x, third_x))), __dmul_rn(third_square, __dsub_rn(second_x, first_x))), denominator);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 192 "GeometryModule.cs"
    double csharp2cuda_temp_7 = *(center_x);
#line 192 "GeometryModule.cs"
    double x = __dsub_rn(first_x, csharp2cuda_temp_7);
#line 193 "GeometryModule.cs"
    double csharp2cuda_temp_8 = *(center_y);
#line 193 "GeometryModule.cs"
    double y = __dsub_rn(first_y, csharp2cuda_temp_8);
#line 194 "GeometryModule.cs"
#line 194 "GeometryModule.cs"
    double* csharp2cuda_temp_9 = radius_square;
    (*(csharp2cuda_temp_9) = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
#line 195 "GeometryModule.cs"
    return true;
}