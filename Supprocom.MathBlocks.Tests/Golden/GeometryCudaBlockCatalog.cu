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

#line 143 "GeometryModule.cs"
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

#line 130 "GeometryModule.cs"
__device__ double mathblocks_geometry_barycentric_denominator(
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y);

#line 93 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 390 "GeometryModule.cs"
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

#line 337 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right);

#line 326 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value);

#line 237 "GeometryModule.cs"
__device__ void mathblocks_geometry_index_order(
    const double* points,
    int count,
    int* order,
    int* buffer);

#line 77 "GeometryModule.cs"
__device__ bool mathblocks_geometry_not_left_turn(
    int* overflow,
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y);

#line 215 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right);

#line 106 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y);

#line 355 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count);

#line 279 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_points(double* points, double* buffer, int count);

#line 174 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square);

#line 143 "GeometryModule.cs"
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
#line 154 "GeometryModule.cs"
{
#line 155 "GeometryModule.cs"
    double denominator = mathblocks_geometry_barycentric_denominator(first_x, first_y, second_x, second_y, third_x, third_y);
#line 158 "GeometryModule.cs"
    if ((!(isfinite(denominator))))
#line 159 "GeometryModule.cs"
    {
#line 160 "GeometryModule.cs"
#line 160 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = &((result)[0]);
        (*(csharp2cuda_temp_0) = mathblocks_quiet_nan());
#line 161 "GeometryModule.cs"
#line 161 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = &((result)[1]);
        (*(csharp2cuda_temp_1) = mathblocks_quiet_nan());
#line 162 "GeometryModule.cs"
#line 162 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((result)[2]);
        (*(csharp2cuda_temp_2) = mathblocks_quiet_nan());
#line 163 "GeometryModule.cs"
        return;
    }
#line 165 "GeometryModule.cs"
    double first_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(point_y, third_y))), denominator);
#line 167 "GeometryModule.cs"
    double second_weight = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(third_y, first_y), __dsub_rn(point_x, third_x)), __dmul_rn(__dsub_rn(first_x, third_x), __dsub_rn(point_y, third_y))), denominator);
#line 169 "GeometryModule.cs"
#line 169 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = &((result)[0]);
    (*(csharp2cuda_temp_3) = first_weight);
#line 170 "GeometryModule.cs"
#line 170 "GeometryModule.cs"
    double* csharp2cuda_temp_4 = &((result)[1]);
    (*(csharp2cuda_temp_4) = second_weight);
#line 171 "GeometryModule.cs"
#line 171 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = &((result)[2]);
    (*(csharp2cuda_temp_5) = __dsub_rn(__dsub_rn(1.0, first_weight), second_weight));
}

#line 130 "GeometryModule.cs"
__device__ double mathblocks_geometry_barycentric_denominator(
    double first_x,
    double first_y,
    double second_x,
    double second_y,
    double third_x,
    double third_y)
#line 138 "GeometryModule.cs"
{
#line 139 "GeometryModule.cs"
    return __dadd_rn(__dmul_rn(__dsub_rn(second_y, third_y), __dsub_rn(first_x, third_x)), __dmul_rn(__dsub_rn(third_x, second_x), __dsub_rn(first_y, third_y)));
}

#line 93 "GeometryModule.cs"
__device__ double mathblocks_geometry_cross(
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 101 "GeometryModule.cs"
{
#line 102 "GeometryModule.cs"
    return __dsub_rn(__dmul_rn(__dsub_rn(left_x, origin_x), __dsub_rn(right_y, origin_y)), __dmul_rn(__dsub_rn(left_y, origin_y), __dsub_rn(right_x, origin_x)));
}

#line 390 "GeometryModule.cs"
__device__ void mathblocks_geometry_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 396 "GeometryModule.cs"
{
#line 397 "GeometryModule.cs"
    int thread = threadIdx.x;
#line 398 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 398 "GeometryModule.cs"
    if (((input_count) > (0)))
    {
#line 398 "GeometryModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 398 "GeometryModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 398 "GeometryModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 399 "GeometryModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 399 "GeometryModule.cs"
    if (((input_count) > (1)))
    {
#line 399 "GeometryModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 399 "GeometryModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 399 "GeometryModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 400 "GeometryModule.cs"
    if (((thread) == (0)))
#line 401 "GeometryModule.cs"
    {
#line 402 "GeometryModule.cs"
#line 402 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 403 "GeometryModule.cs"
#line 403 "GeometryModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 404 "GeometryModule.cs"
#line 404 "GeometryModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 405 "GeometryModule.cs"
#line 405 "GeometryModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 406 "GeometryModule.cs"
#line 406 "GeometryModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 407 "GeometryModule.cs"
#line 407 "GeometryModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 407 "GeometryModule.cs"
        bool csharp2cuda_temp_8;
#line 407 "GeometryModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 407 "GeometryModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 407 "GeometryModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 408 "GeometryModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 409 "GeometryModule.cs"
#line 409 "GeometryModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 409 "GeometryModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 409 "GeometryModule.cs"
            bool csharp2cuda_temp_11;
#line 409 "GeometryModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 409 "GeometryModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 409 "GeometryModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 411 "GeometryModule.cs"
    __syncthreads();
#line 412 "GeometryModule.cs"
#line 412 "GeometryModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 413 "GeometryModule.cs"
        return;
    }
#line 415 "GeometryModule.cs"
    double* csharp2cuda_temp_13;
#line 415 "GeometryModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 415 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 415 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 415 "GeometryModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 415 "GeometryModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 416 "GeometryModule.cs"
    double* csharp2cuda_temp_15;
#line 416 "GeometryModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 416 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 416 "GeometryModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 416 "GeometryModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 416 "GeometryModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 417 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 417 "GeometryModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 418 "GeometryModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 418 "GeometryModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 420 "GeometryModule.cs"
    if (((thread) == (0)))
#line 421 "GeometryModule.cs"
    {
#line 422 "GeometryModule.cs"
        switch (opcode)
        {
#line 424 "GeometryModule.cs"
            case 0:
#line 425 "GeometryModule.cs"
                mathblocks_sequence_set_vector_shape(output, 3);
#line 426 "GeometryModule.cs"
#line 426 "GeometryModule.cs"
                int csharp2cuda_temp_19 = (first)->count;
#line 426 "GeometryModule.cs"
                bool csharp2cuda_temp_20;
#line 426 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_19) != (1))))
                {
#line 426 "GeometryModule.cs"
                    int csharp2cuda_temp_21 = (second)->count;
#line 426 "GeometryModule.cs"
                    csharp2cuda_temp_20 = ((csharp2cuda_temp_21) != (3));
                }
                else
                {
#line 426 "GeometryModule.cs"
                    csharp2cuda_temp_20 = true;
                }
                if (csharp2cuda_temp_20)
#line 427 "GeometryModule.cs"
                {
#line 428 "GeometryModule.cs"
#line 428 "GeometryModule.cs"
                    int* csharp2cuda_temp_22 = &((output)->valid);
                    (*(csharp2cuda_temp_22) = 0);
#line 429 "GeometryModule.cs"
                    break;
                }
#line 431 "GeometryModule.cs"
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_23 = (a)[0];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_24 = (a)[1];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_25 = (b)[0];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_26 = (b)[1];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_27 = (b)[2];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_28 = (b)[3];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_29 = (b)[4];
#line 432 "GeometryModule.cs"
                double csharp2cuda_temp_30 = (b)[5];
                mathblocks_geometry_barycentric(csharp2cuda_temp_23, csharp2cuda_temp_24, csharp2cuda_temp_25, csharp2cuda_temp_26, csharp2cuda_temp_27, csharp2cuda_temp_28, csharp2cuda_temp_29, csharp2cuda_temp_30, result);
#line 433 "GeometryModule.cs"
                {
#line 433 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (3))))
                            break;
#line 434 "GeometryModule.cs"
#line 434 "GeometryModule.cs"
                        double csharp2cuda_temp_32 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_32))))
                        {
#line 434 "GeometryModule.cs"
#line 434 "GeometryModule.cs"
                            int* csharp2cuda_temp_33 = &((output)->valid);
                            (*(csharp2cuda_temp_33) = 0);
                        }
#line 433 "GeometryModule.cs"
                        int* csharp2cuda_temp_31 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                    }
                }
#line 435 "GeometryModule.cs"
                break;
#line 436 "GeometryModule.cs"
            case 1:
#line 437 "GeometryModule.cs"
#line 437 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((output)->rows);
                (*(csharp2cuda_temp_34) = 1);
#line 438 "GeometryModule.cs"
#line 438 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &((output)->count);
                (*(csharp2cuda_temp_35) = 1);
#line 439 "GeometryModule.cs"
#line 439 "GeometryModule.cs"
                int csharp2cuda_temp_36 = (first)->count;
#line 439 "GeometryModule.cs"
                bool csharp2cuda_temp_37;
#line 439 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_36) <= (0))))
                {
#line 439 "GeometryModule.cs"
                    int csharp2cuda_temp_38 = (output)->capacity;
#line 439 "GeometryModule.cs"
                    csharp2cuda_temp_37 = ((csharp2cuda_temp_38) < (1));
                }
                else
                {
#line 439 "GeometryModule.cs"
                    csharp2cuda_temp_37 = true;
                }
                if (csharp2cuda_temp_37)
#line 440 "GeometryModule.cs"
                {
#line 441 "GeometryModule.cs"
#line 441 "GeometryModule.cs"
                    int* csharp2cuda_temp_39 = &((output)->valid);
                    (*(csharp2cuda_temp_39) = 0);
#line 442 "GeometryModule.cs"
                    break;
                }
#line 444 "GeometryModule.cs"
#line 444 "GeometryModule.cs"
                double* csharp2cuda_temp_40 = &((result)[0]);
                (*(csharp2cuda_temp_40) = 0.0);
#line 445 "GeometryModule.cs"
#line 445 "GeometryModule.cs"
                double* csharp2cuda_temp_41 = &((result)[1]);
                (*(csharp2cuda_temp_41) = 0.0);
#line 446 "GeometryModule.cs"
                {
#line 446 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 446 "GeometryModule.cs"
                        int csharp2cuda_temp_43 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_43))))
                            break;
#line 447 "GeometryModule.cs"
                        {
#line 448 "GeometryModule.cs"
#line 448 "GeometryModule.cs"
                            double* csharp2cuda_temp_44 = &((result)[0]);
#line 448 "GeometryModule.cs"
                            double csharp2cuda_temp_45 = *(csharp2cuda_temp_44);
#line 448 "GeometryModule.cs"
                            double csharp2cuda_temp_46 = (a)[csharp2cuda_i32_mul(2, index)];
                            (*(csharp2cuda_temp_44) = __dadd_rn(csharp2cuda_temp_45, csharp2cuda_temp_46));
#line 449 "GeometryModule.cs"
#line 449 "GeometryModule.cs"
                            double* csharp2cuda_temp_47 = &((result)[1]);
#line 449 "GeometryModule.cs"
                            double csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
#line 449 "GeometryModule.cs"
                            double csharp2cuda_temp_49 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                            (*(csharp2cuda_temp_47) = __dadd_rn(csharp2cuda_temp_48, csharp2cuda_temp_49));
                        }
#line 446 "GeometryModule.cs"
                        int* csharp2cuda_temp_42 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_42));
                    }
                }
#line 451 "GeometryModule.cs"
#line 451 "GeometryModule.cs"
                double* csharp2cuda_temp_50 = &((result)[0]);
#line 451 "GeometryModule.cs"
                double csharp2cuda_temp_51 = *(csharp2cuda_temp_50);
#line 451 "GeometryModule.cs"
                int csharp2cuda_temp_52 = (first)->count;
                (*(csharp2cuda_temp_50) = __ddiv_rn(csharp2cuda_temp_51, ((double)(csharp2cuda_temp_52))));
#line 452 "GeometryModule.cs"
#line 452 "GeometryModule.cs"
                double* csharp2cuda_temp_53 = &((result)[1]);
#line 452 "GeometryModule.cs"
                double csharp2cuda_temp_54 = *(csharp2cuda_temp_53);
#line 452 "GeometryModule.cs"
                int csharp2cuda_temp_55 = (first)->count;
                (*(csharp2cuda_temp_53) = __ddiv_rn(csharp2cuda_temp_54, ((double)(csharp2cuda_temp_55))));
#line 453 "GeometryModule.cs"
#line 453 "GeometryModule.cs"
                double csharp2cuda_temp_56 = (result)[0];
#line 453 "GeometryModule.cs"
                bool csharp2cuda_temp_57;
#line 453 "GeometryModule.cs"
                if (!((!(isfinite(csharp2cuda_temp_56)))))
                {
#line 453 "GeometryModule.cs"
                    double csharp2cuda_temp_58 = (result)[1];
#line 453 "GeometryModule.cs"
                    csharp2cuda_temp_57 = (!(isfinite(csharp2cuda_temp_58)));
                }
                else
                {
#line 453 "GeometryModule.cs"
                    csharp2cuda_temp_57 = true;
                }
                if (csharp2cuda_temp_57)
                {
#line 453 "GeometryModule.cs"
#line 453 "GeometryModule.cs"
                    int* csharp2cuda_temp_59 = &((output)->valid);
                    (*(csharp2cuda_temp_59) = 0);
                }
#line 454 "GeometryModule.cs"
                break;
#line 455 "GeometryModule.cs"
            case 2:
#line 456 "GeometryModule.cs"
#line 456 "GeometryModule.cs"
                int csharp2cuda_temp_60 = (first)->count;
                if (((csharp2cuda_temp_60) != (3)))
#line 457 "GeometryModule.cs"
                {
#line 458 "GeometryModule.cs"
#line 458 "GeometryModule.cs"
                    int* csharp2cuda_temp_61 = &((output)->valid);
                    (*(csharp2cuda_temp_61) = 0);
#line 459 "GeometryModule.cs"
                    break;
                }
#line 461 "GeometryModule.cs"
                {
#line 462 "GeometryModule.cs"
                    double first_length = mathblocks_geometry_distance(a, 1, a, 2);
#line 463 "GeometryModule.cs"
                    double second_length = mathblocks_geometry_distance(a, 0, a, 2);
#line 464 "GeometryModule.cs"
                    double third_length = mathblocks_geometry_distance(a, 0, a, 1);
#line 466 "GeometryModule.cs"
                    double csharp2cuda_temp_62 = (a)[0];
#line 466 "GeometryModule.cs"
                    double csharp2cuda_temp_63 = (a)[1];
#line 466 "GeometryModule.cs"
                    double csharp2cuda_temp_64 = (a)[2];
#line 466 "GeometryModule.cs"
                    double csharp2cuda_temp_65 = (a)[3];
#line 466 "GeometryModule.cs"
                    double csharp2cuda_temp_66 = (a)[4];
#line 466 "GeometryModule.cs"
                    double csharp2cuda_temp_67 = (a)[5];
#line 465 "GeometryModule.cs"
                    double cross = mathblocks_geometry_cross(csharp2cuda_temp_62, csharp2cuda_temp_63, csharp2cuda_temp_64, csharp2cuda_temp_65, csharp2cuda_temp_66, csharp2cuda_temp_67);
#line 467 "GeometryModule.cs"
#line 467 "GeometryModule.cs"
                    double* csharp2cuda_temp_68 = &((output)->scalar_value);
#line 467 "GeometryModule.cs"
                    double csharp2cuda_temp_69 = __ddiv_rn(__dmul_rn(__dmul_rn(first_length, second_length), third_length), __dmul_rn(2.0, fabs(cross)));
                    (*(csharp2cuda_temp_68) = csharp2cuda_temp_69);
#line 469 "GeometryModule.cs"
                    break;
                }
#line 471 "GeometryModule.cs"
            case 3:
#line 472 "GeometryModule.cs"
#line 472 "GeometryModule.cs"
                int csharp2cuda_temp_70 = (first)->count;
#line 472 "GeometryModule.cs"
                bool csharp2cuda_temp_71;
#line 472 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_70) < (3))))
                {
#line 472 "GeometryModule.cs"
                    int csharp2cuda_temp_72 = (second)->count;
#line 472 "GeometryModule.cs"
                    csharp2cuda_temp_71 = ((csharp2cuda_temp_72) != (1));
                }
                else
                {
#line 472 "GeometryModule.cs"
                    csharp2cuda_temp_71 = true;
                }
                if (csharp2cuda_temp_71)
#line 473 "GeometryModule.cs"
                {
#line 474 "GeometryModule.cs"
#line 474 "GeometryModule.cs"
                    int* csharp2cuda_temp_73 = &((output)->valid);
                    (*(csharp2cuda_temp_73) = 0);
#line 475 "GeometryModule.cs"
                    break;
                }
#line 477 "GeometryModule.cs"
                {
#line 478 "GeometryModule.cs"
                    bool inside = false;
#line 479 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 480 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 481 "GeometryModule.cs"
                    {
#line 481 "GeometryModule.cs"
                        int current = 0;
                        while (true)
                        {
#line 481 "GeometryModule.cs"
                            int csharp2cuda_temp_75 = (first)->count;
                            if (!(((current) < (csharp2cuda_temp_75))))
                                break;
#line 482 "GeometryModule.cs"
                            {
#line 483 "GeometryModule.cs"
                                int csharp2cuda_temp_76;
#line 483 "GeometryModule.cs"
                                if (((current) == (0)))
                                {
#line 483 "GeometryModule.cs"
                                    int csharp2cuda_temp_77 = (first)->count;
#line 483 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(csharp2cuda_temp_77, 1);
                                }
                                else
                                {
#line 483 "GeometryModule.cs"
                                    csharp2cuda_temp_76 = csharp2cuda_i32_sub(current, 1);
                                }
#line 483 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_76;
#line 484 "GeometryModule.cs"
                                double left_x = (a)[csharp2cuda_i32_mul(2, current)];
#line 485 "GeometryModule.cs"
                                double left_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, current), 1)];
#line 486 "GeometryModule.cs"
                                double right_x = (a)[csharp2cuda_i32_mul(2, previous)];
#line 487 "GeometryModule.cs"
                                double right_y = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, previous), 1)];
#line 488 "GeometryModule.cs"
                                if (((mathblocks_geometry_point_to_segment(point_x, point_y, left_x, left_y, right_x, right_y)) == (0.0)))
#line 490 "GeometryModule.cs"
                                {
#line 491 "GeometryModule.cs"
#line 491 "GeometryModule.cs"
                                    bool* csharp2cuda_temp_78 = &(inside);
                                    (*(csharp2cuda_temp_78) = true);
#line 492 "GeometryModule.cs"
                                    break;
                                }
#line 494 "GeometryModule.cs"
                                if (((((left_y) > (point_y))) != (((right_y) > (point_y)))))
#line 495 "GeometryModule.cs"
                                {
#line 497 "GeometryModule.cs"
                                    double csharp2cuda_temp_79 = __ddiv_rn(__dmul_rn(__dsub_rn(right_x, left_x), __dsub_rn(point_y, left_y)), __dsub_rn(right_y, left_y));
#line 497 "GeometryModule.cs"
                                    double crossing = __dadd_rn(csharp2cuda_temp_79, left_x);
#line 499 "GeometryModule.cs"
                                    if ((!(isfinite(crossing))))
                                    {
#line 500 "GeometryModule.cs"
#line 500 "GeometryModule.cs"
                                        int* csharp2cuda_temp_80 = &((output)->valid);
                                        (*(csharp2cuda_temp_80) = 0);
                                    }
#line 501 "GeometryModule.cs"
                                    if (((point_x) < (crossing)))
                                    {
#line 502 "GeometryModule.cs"
#line 502 "GeometryModule.cs"
                                        bool* csharp2cuda_temp_81 = &(inside);
                                        (*(csharp2cuda_temp_81) = (!(inside)));
                                    }
                                }
                            }
#line 481 "GeometryModule.cs"
                            int* csharp2cuda_temp_74 = &(current);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_74));
                        }
                    }
#line 505 "GeometryModule.cs"
#line 505 "GeometryModule.cs"
                    int* csharp2cuda_temp_82 = &((output)->boolean_value);
#line 505 "GeometryModule.cs"
                    int csharp2cuda_temp_83;
#line 505 "GeometryModule.cs"
                    if (inside)
                    {
#line 505 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 1;
                    }
                    else
                    {
#line 505 "GeometryModule.cs"
                        csharp2cuda_temp_83 = 0;
                    }
                    (*(csharp2cuda_temp_82) = csharp2cuda_temp_83);
#line 506 "GeometryModule.cs"
                    break;
                }
#line 508 "GeometryModule.cs"
            case 4:
#line 509 "GeometryModule.cs"
#line 509 "GeometryModule.cs"
                int csharp2cuda_temp_84 = (first)->count;
#line 509 "GeometryModule.cs"
                bool csharp2cuda_temp_85;
#line 509 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_84) <= (0))))
                {
#line 509 "GeometryModule.cs"
                    csharp2cuda_temp_85 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 509 "GeometryModule.cs"
                    csharp2cuda_temp_85 = true;
                }
                if (csharp2cuda_temp_85)
#line 510 "GeometryModule.cs"
                {
#line 511 "GeometryModule.cs"
#line 511 "GeometryModule.cs"
                    int* csharp2cuda_temp_86 = &((output)->valid);
                    (*(csharp2cuda_temp_86) = 0);
#line 512 "GeometryModule.cs"
                    break;
                }
#line 514 "GeometryModule.cs"
                {
#line 515 "GeometryModule.cs"
                    double* sorted = scratch;
#line 516 "GeometryModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 516 "GeometryModule.cs"
                    double* hull = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_87, 4));
#line 517 "GeometryModule.cs"
                    {
#line 517 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 517 "GeometryModule.cs"
                            int csharp2cuda_temp_89 = (first)->count;
                            if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_89, 2)))))
                                break;
#line 518 "GeometryModule.cs"
#line 518 "GeometryModule.cs"
                            double* csharp2cuda_temp_90 = &((sorted)[index]);
#line 518 "GeometryModule.cs"
                            double csharp2cuda_temp_91 = (a)[index];
                            (*(csharp2cuda_temp_90) = csharp2cuda_temp_91);
#line 517 "GeometryModule.cs"
                            int* csharp2cuda_temp_88 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_88));
                        }
                    }
#line 519 "GeometryModule.cs"
#line 519 "GeometryModule.cs"
                    int csharp2cuda_temp_92 = (first)->count;
#line 519 "GeometryModule.cs"
                    int csharp2cuda_temp_93 = (first)->count;
                    mathblocks_geometry_sort_points(sorted, csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(csharp2cuda_temp_92, 2)), csharp2cuda_temp_93);
#line 520 "GeometryModule.cs"
                    int unique_count = 0;
#line 521 "GeometryModule.cs"
                    {
#line 521 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 521 "GeometryModule.cs"
                            int csharp2cuda_temp_95 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_95))))
                                break;
#line 522 "GeometryModule.cs"
                            {
#line 523 "GeometryModule.cs"
                                double x = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 524 "GeometryModule.cs"
                                double y = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 525 "GeometryModule.cs"
#line 525 "GeometryModule.cs"
                                bool csharp2cuda_temp_96;
#line 525 "GeometryModule.cs"
                                if (((unique_count) > (0)))
                                {
#line 525 "GeometryModule.cs"
                                    double csharp2cuda_temp_97 = (sorted)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(unique_count, 1))];
#line 525 "GeometryModule.cs"
                                    csharp2cuda_temp_96 = ((csharp2cuda_temp_97) == (x));
                                }
                                else
                                {
#line 525 "GeometryModule.cs"
                                    csharp2cuda_temp_96 = false;
                                }
#line 525 "GeometryModule.cs"
                                bool csharp2cuda_temp_98;
#line 525 "GeometryModule.cs"
                                if (csharp2cuda_temp_96)
                                {
#line 525 "GeometryModule.cs"
                                    double csharp2cuda_temp_99 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(unique_count, 1)), 1)];
#line 525 "GeometryModule.cs"
                                    csharp2cuda_temp_98 = ((csharp2cuda_temp_99) == (y));
                                }
                                else
                                {
#line 525 "GeometryModule.cs"
                                    csharp2cuda_temp_98 = false;
                                }
                                if (csharp2cuda_temp_98)
                                {
#line 526 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_4;
                                }
#line 527 "GeometryModule.cs"
#line 527 "GeometryModule.cs"
                                double* csharp2cuda_temp_100 = &((sorted)[csharp2cuda_i32_mul(2, unique_count)]);
                                (*(csharp2cuda_temp_100) = x);
#line 528 "GeometryModule.cs"
#line 528 "GeometryModule.cs"
                                double* csharp2cuda_temp_101 = &((sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, unique_count), 1)]);
                                (*(csharp2cuda_temp_101) = y);
#line 529 "GeometryModule.cs"
#line 529 "GeometryModule.cs"
                                int* csharp2cuda_temp_102 = &(unique_count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_102));
                            }
                            csharp2cuda_for_continue_4:
#line 521 "GeometryModule.cs"
                            int* csharp2cuda_temp_94 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_94));
                        }
                    }
#line 531 "GeometryModule.cs"
                    int count = 0;
#line 532 "GeometryModule.cs"
                    int hull_overflow = 0;
#line 533 "GeometryModule.cs"
                    if (((unique_count) <= (1)))
#line 534 "GeometryModule.cs"
                    {
#line 535 "GeometryModule.cs"
#line 535 "GeometryModule.cs"
                        int* csharp2cuda_temp_103 = &(count);
                        (*(csharp2cuda_temp_103) = unique_count);
#line 536 "GeometryModule.cs"
                        if (((count) == (1)))
#line 537 "GeometryModule.cs"
                        {
#line 538 "GeometryModule.cs"
#line 538 "GeometryModule.cs"
                            double* csharp2cuda_temp_104 = &((hull)[0]);
#line 538 "GeometryModule.cs"
                            double csharp2cuda_temp_105 = (sorted)[0];
                            (*(csharp2cuda_temp_104) = csharp2cuda_temp_105);
#line 539 "GeometryModule.cs"
#line 539 "GeometryModule.cs"
                            double* csharp2cuda_temp_106 = &((hull)[1]);
#line 539 "GeometryModule.cs"
                            double csharp2cuda_temp_107 = (sorted)[1];
                            (*(csharp2cuda_temp_106) = csharp2cuda_temp_107);
                        }
                    }
                    else
#line 543 "GeometryModule.cs"
                    {
#line 544 "GeometryModule.cs"
                        {
#line 544 "GeometryModule.cs"
                            int index = 0;
                            while (true)
                            {
                                if (!(((index) < (unique_count))))
                                    break;
#line 545 "GeometryModule.cs"
                                {
#line 546 "GeometryModule.cs"
                                    while (true)
                                    {
#line 546 "GeometryModule.cs"
                                        bool csharp2cuda_temp_109;
#line 546 "GeometryModule.cs"
                                        if (((count) >= (2)))
                                        {
#line 547 "GeometryModule.cs"
                                            int* csharp2cuda_temp_110 = &(hull_overflow);
#line 548 "GeometryModule.cs"
                                            double csharp2cuda_temp_111 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 548 "GeometryModule.cs"
                                            double csharp2cuda_temp_112 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 549 "GeometryModule.cs"
                                            double csharp2cuda_temp_113 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 549 "GeometryModule.cs"
                                            double csharp2cuda_temp_114 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 550 "GeometryModule.cs"
                                            double csharp2cuda_temp_115 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 550 "GeometryModule.cs"
                                            double csharp2cuda_temp_116 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 546 "GeometryModule.cs"
                                            csharp2cuda_temp_109 = mathblocks_geometry_not_left_turn(csharp2cuda_temp_110, csharp2cuda_temp_111, csharp2cuda_temp_112, csharp2cuda_temp_113, csharp2cuda_temp_114, csharp2cuda_temp_115, csharp2cuda_temp_116);
                                        }
                                        else
                                        {
#line 546 "GeometryModule.cs"
                                            csharp2cuda_temp_109 = false;
                                        }
                                        if (!(csharp2cuda_temp_109))
                                            break;
#line 551 "GeometryModule.cs"
                                        {
#line 552 "GeometryModule.cs"
#line 552 "GeometryModule.cs"
                                            int* csharp2cuda_temp_117 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_117));
                                        }
                                    }
#line 554 "GeometryModule.cs"
#line 554 "GeometryModule.cs"
                                    double* csharp2cuda_temp_118 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 554 "GeometryModule.cs"
                                    double csharp2cuda_temp_119 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_118) = csharp2cuda_temp_119);
#line 555 "GeometryModule.cs"
#line 555 "GeometryModule.cs"
                                    double* csharp2cuda_temp_120 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 555 "GeometryModule.cs"
                                    double csharp2cuda_temp_121 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_120) = csharp2cuda_temp_121);
#line 556 "GeometryModule.cs"
#line 556 "GeometryModule.cs"
                                    int* csharp2cuda_temp_122 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_122));
                                }
#line 544 "GeometryModule.cs"
                                int* csharp2cuda_temp_108 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_108));
                            }
                        }
#line 558 "GeometryModule.cs"
                        int lower_count = count;
#line 559 "GeometryModule.cs"
                        {
#line 559 "GeometryModule.cs"
                            int index = csharp2cuda_i32_sub(unique_count, 2);
                            while (true)
                            {
                                if (!(((index) >= (0))))
                                    break;
#line 560 "GeometryModule.cs"
                                {
#line 561 "GeometryModule.cs"
                                    while (true)
                                    {
#line 561 "GeometryModule.cs"
                                        bool csharp2cuda_temp_124;
#line 561 "GeometryModule.cs"
                                        if (((count) > (lower_count)))
                                        {
#line 562 "GeometryModule.cs"
                                            int* csharp2cuda_temp_125 = &(hull_overflow);
#line 563 "GeometryModule.cs"
                                            double csharp2cuda_temp_126 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2))];
#line 563 "GeometryModule.cs"
                                            double csharp2cuda_temp_127 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 2)), 1)];
#line 564 "GeometryModule.cs"
                                            double csharp2cuda_temp_128 = (hull)[csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1))];
#line 564 "GeometryModule.cs"
                                            double csharp2cuda_temp_129 = (hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, csharp2cuda_i32_sub(count, 1)), 1)];
#line 565 "GeometryModule.cs"
                                            double csharp2cuda_temp_130 = (sorted)[csharp2cuda_i32_mul(2, index)];
#line 565 "GeometryModule.cs"
                                            double csharp2cuda_temp_131 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 561 "GeometryModule.cs"
                                            csharp2cuda_temp_124 = mathblocks_geometry_not_left_turn(csharp2cuda_temp_125, csharp2cuda_temp_126, csharp2cuda_temp_127, csharp2cuda_temp_128, csharp2cuda_temp_129, csharp2cuda_temp_130, csharp2cuda_temp_131);
                                        }
                                        else
                                        {
#line 561 "GeometryModule.cs"
                                            csharp2cuda_temp_124 = false;
                                        }
                                        if (!(csharp2cuda_temp_124))
                                            break;
#line 566 "GeometryModule.cs"
                                        {
#line 567 "GeometryModule.cs"
#line 567 "GeometryModule.cs"
                                            int* csharp2cuda_temp_132 = &(count);
                                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_132));
                                        }
                                    }
#line 569 "GeometryModule.cs"
#line 569 "GeometryModule.cs"
                                    double* csharp2cuda_temp_133 = &((hull)[csharp2cuda_i32_mul(2, count)]);
#line 569 "GeometryModule.cs"
                                    double csharp2cuda_temp_134 = (sorted)[csharp2cuda_i32_mul(2, index)];
                                    (*(csharp2cuda_temp_133) = csharp2cuda_temp_134);
#line 570 "GeometryModule.cs"
#line 570 "GeometryModule.cs"
                                    double* csharp2cuda_temp_135 = &((hull)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, count), 1)]);
#line 570 "GeometryModule.cs"
                                    double csharp2cuda_temp_136 = (sorted)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                    (*(csharp2cuda_temp_135) = csharp2cuda_temp_136);
#line 571 "GeometryModule.cs"
#line 571 "GeometryModule.cs"
                                    int* csharp2cuda_temp_137 = &(count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_137));
                                }
#line 559 "GeometryModule.cs"
                                int* csharp2cuda_temp_123 = &(index);
                                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_123));
                            }
                        }
#line 573 "GeometryModule.cs"
#line 573 "GeometryModule.cs"
                        int* csharp2cuda_temp_138 = &(count);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_138));
                    }
#line 575 "GeometryModule.cs"
                    if (((hull_overflow) != (0)))
                    {
#line 576 "GeometryModule.cs"
#line 576 "GeometryModule.cs"
                        int* csharp2cuda_temp_139 = &((output)->valid);
                        (*(csharp2cuda_temp_139) = 0);
                    }
#line 577 "GeometryModule.cs"
#line 577 "GeometryModule.cs"
                    int* csharp2cuda_temp_140 = &((output)->rows);
                    (*(csharp2cuda_temp_140) = count);
#line 578 "GeometryModule.cs"
#line 578 "GeometryModule.cs"
                    int* csharp2cuda_temp_141 = &((output)->count);
                    (*(csharp2cuda_temp_141) = count);
#line 579 "GeometryModule.cs"
#line 579 "GeometryModule.cs"
                    int csharp2cuda_temp_142 = (output)->capacity;
                    if (((count) > (csharp2cuda_temp_142)))
#line 580 "GeometryModule.cs"
                    {
#line 581 "GeometryModule.cs"
#line 581 "GeometryModule.cs"
                        int* csharp2cuda_temp_143 = &((output)->valid);
                        (*(csharp2cuda_temp_143) = 0);
#line 582 "GeometryModule.cs"
                        break;
                    }
#line 584 "GeometryModule.cs"
                    {
#line 584 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, 2)))))
                                break;
#line 585 "GeometryModule.cs"
#line 585 "GeometryModule.cs"
                            double* csharp2cuda_temp_145 = &((result)[index]);
#line 585 "GeometryModule.cs"
                            double csharp2cuda_temp_146 = (hull)[index];
                            (*(csharp2cuda_temp_145) = csharp2cuda_temp_146);
#line 584 "GeometryModule.cs"
                            int* csharp2cuda_temp_144 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_144));
                        }
                    }
#line 586 "GeometryModule.cs"
                    break;
                }
#line 588 "GeometryModule.cs"
            case 5:
#line 589 "GeometryModule.cs"
#line 589 "GeometryModule.cs"
                int csharp2cuda_temp_147 = (first)->count;
#line 589 "GeometryModule.cs"
                bool csharp2cuda_temp_148;
#line 589 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_147) < (2))))
                {
#line 589 "GeometryModule.cs"
                    csharp2cuda_temp_148 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 589 "GeometryModule.cs"
                    csharp2cuda_temp_148 = true;
                }
                if (csharp2cuda_temp_148)
#line 590 "GeometryModule.cs"
                {
#line 591 "GeometryModule.cs"
#line 591 "GeometryModule.cs"
                    int* csharp2cuda_temp_149 = &((output)->valid);
                    (*(csharp2cuda_temp_149) = 0);
#line 592 "GeometryModule.cs"
                    break;
                }
#line 594 "GeometryModule.cs"
                {
#line 595 "GeometryModule.cs"
                    int count = (first)->count;
#line 596 "GeometryModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 597 "GeometryModule.cs"
                    int* ordered = csharp2cuda_pointer_add(adjacency, csharp2cuda_i32_mul(count, count));
#line 598 "GeometryModule.cs"
                    {
#line 598 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 599 "GeometryModule.cs"
#line 599 "GeometryModule.cs"
                            int* csharp2cuda_temp_151 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_151) = 0);
#line 598 "GeometryModule.cs"
                            int* csharp2cuda_temp_150 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_150));
                        }
                    }
#line 600 "GeometryModule.cs"
                    {
#line 600 "GeometryModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (count))))
                                break;
#line 601 "GeometryModule.cs"
                            {
#line 602 "GeometryModule.cs"
                                {
#line 602 "GeometryModule.cs"
                                    int second_index = csharp2cuda_i32_add(first_index, 1);
                                    while (true)
                                    {
                                        if (!(((second_index) < (count))))
                                            break;
#line 603 "GeometryModule.cs"
                                        {
#line 604 "GeometryModule.cs"
                                            {
#line 604 "GeometryModule.cs"
                                                int third_index = csharp2cuda_i32_add(second_index, 1);
                                                while (true)
                                                {
                                                    if (!(((third_index) < (count))))
                                                        break;
#line 605 "GeometryModule.cs"
                                                    {
#line 606 "GeometryModule.cs"
                                                        double center_x;
#line 607 "GeometryModule.cs"
                                                        double center_y;
#line 608 "GeometryModule.cs"
                                                        double radius_square;
#line 609 "GeometryModule.cs"
#line 611 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_155 = &(center_x);
#line 611 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_156 = &(center_y);
#line 611 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_157 = &(radius_square);
#line 609 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_158 = mathblocks_geometry_try_circumcircle(a, first_index, second_index, third_index, csharp2cuda_temp_155, csharp2cuda_temp_156, csharp2cuda_temp_157);
                                                        if ((!(csharp2cuda_temp_158)))
#line 612 "GeometryModule.cs"
                                                        {
#line 613 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 615 "GeometryModule.cs"
                                                        bool empty = true;
#line 616 "GeometryModule.cs"
                                                        {
#line 616 "GeometryModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
                                                                if (!(((index) < (count))))
                                                                    break;
#line 617 "GeometryModule.cs"
                                                                {
#line 618 "GeometryModule.cs"
#line 618 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_160;
#line 618 "GeometryModule.cs"
                                                                    if (!(((index) == (first_index))))
                                                                    {
#line 618 "GeometryModule.cs"
                                                                        csharp2cuda_temp_160 = ((index) == (second_index));
                                                                    }
                                                                    else
                                                                    {
#line 618 "GeometryModule.cs"
                                                                        csharp2cuda_temp_160 = true;
                                                                    }
#line 618 "GeometryModule.cs"
                                                                    bool csharp2cuda_temp_161;
#line 618 "GeometryModule.cs"
                                                                    if (!(csharp2cuda_temp_160))
                                                                    {
#line 618 "GeometryModule.cs"
                                                                        csharp2cuda_temp_161 = ((index) == (third_index));
                                                                    }
                                                                    else
                                                                    {
#line 618 "GeometryModule.cs"
                                                                        csharp2cuda_temp_161 = true;
                                                                    }
                                                                    if (csharp2cuda_temp_161)
                                                                    {
#line 619 "GeometryModule.cs"
                                                                        goto csharp2cuda_for_continue_9;
                                                                    }
#line 620 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_162 = (a)[csharp2cuda_i32_mul(2, index)];
#line 620 "GeometryModule.cs"
                                                                    double x = __dsub_rn(csharp2cuda_temp_162, center_x);
#line 621 "GeometryModule.cs"
                                                                    double csharp2cuda_temp_163 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 621 "GeometryModule.cs"
                                                                    double y = __dsub_rn(csharp2cuda_temp_163, center_y);
#line 622 "GeometryModule.cs"
                                                                    if (((__dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y))) < (radius_square)))
#line 623 "GeometryModule.cs"
                                                                    {
#line 624 "GeometryModule.cs"
#line 624 "GeometryModule.cs"
                                                                        bool* csharp2cuda_temp_164 = &(empty);
                                                                        (*(csharp2cuda_temp_164) = false);
#line 625 "GeometryModule.cs"
                                                                        break;
                                                                    }
                                                                }
                                                                csharp2cuda_for_continue_9:
#line 616 "GeometryModule.cs"
                                                                int* csharp2cuda_temp_159 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_159));
                                                            }
                                                        }
#line 628 "GeometryModule.cs"
                                                        if ((!(empty)))
                                                        {
#line 629 "GeometryModule.cs"
                                                            goto csharp2cuda_for_continue_10;
                                                        }
#line 630 "GeometryModule.cs"
#line 630 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_165 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), second_index)]);
                                                        (*(csharp2cuda_temp_165) = 1);
#line 631 "GeometryModule.cs"
#line 631 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_166 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_166) = 1);
#line 632 "GeometryModule.cs"
#line 632 "GeometryModule.cs"
                                                        int* csharp2cuda_temp_167 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, count), third_index)]);
                                                        (*(csharp2cuda_temp_167) = 1);
                                                    }
                                                    csharp2cuda_for_continue_10:
#line 604 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_154 = &(third_index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_154));
                                                }
                                            }
                                        }
#line 602 "GeometryModule.cs"
                                        int* csharp2cuda_temp_153 = &(second_index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                                    }
                                }
                            }
#line 600 "GeometryModule.cs"
                            int* csharp2cuda_temp_152 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_152));
                        }
                    }
#line 636 "GeometryModule.cs"
                    int edge_count = 0;
#line 637 "GeometryModule.cs"
                    {
#line 637 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 638 "GeometryModule.cs"
                            {
#line 638 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (count))))
                                        break;
#line 639 "GeometryModule.cs"
#line 639 "GeometryModule.cs"
                                    int* csharp2cuda_temp_170 = &(edge_count);
#line 639 "GeometryModule.cs"
                                    int csharp2cuda_temp_171 = *(csharp2cuda_temp_170);
#line 639 "GeometryModule.cs"
                                    int csharp2cuda_temp_172 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                    (*(csharp2cuda_temp_170) = csharp2cuda_i32_add(csharp2cuda_temp_171, csharp2cuda_temp_172));
#line 638 "GeometryModule.cs"
                                    int* csharp2cuda_temp_169 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_169));
                                }
                            }
#line 637 "GeometryModule.cs"
                            int* csharp2cuda_temp_168 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_168));
                        }
                    }
#line 640 "GeometryModule.cs"
                    if (((edge_count) == (0)))
#line 641 "GeometryModule.cs"
                    {
#line 642 "GeometryModule.cs"
                        mathblocks_geometry_index_order(a, count, ordered, csharp2cuda_pointer_add(ordered, count));
#line 643 "GeometryModule.cs"
                        {
#line 643 "GeometryModule.cs"
                            int index = 1;
                            while (true)
                            {
                                if (!(((index) < (count))))
                                    break;
#line 644 "GeometryModule.cs"
                                {
#line 645 "GeometryModule.cs"
                                    int csharp2cuda_temp_174 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 645 "GeometryModule.cs"
                                    int csharp2cuda_temp_175 = (ordered)[index];
#line 645 "GeometryModule.cs"
                                    int csharp2cuda_temp_176;
#line 645 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_174) < (csharp2cuda_temp_175)))
                                    {
#line 645 "GeometryModule.cs"
                                        csharp2cuda_temp_176 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
                                    else
                                    {
#line 645 "GeometryModule.cs"
                                        csharp2cuda_temp_176 = (ordered)[index];
                                    }
#line 645 "GeometryModule.cs"
                                    int left = csharp2cuda_temp_176;
#line 648 "GeometryModule.cs"
                                    int csharp2cuda_temp_177 = (ordered)[csharp2cuda_i32_sub(index, 1)];
#line 648 "GeometryModule.cs"
                                    int csharp2cuda_temp_178 = (ordered)[index];
#line 648 "GeometryModule.cs"
                                    int csharp2cuda_temp_179;
#line 648 "GeometryModule.cs"
                                    if (((csharp2cuda_temp_177) < (csharp2cuda_temp_178)))
                                    {
#line 648 "GeometryModule.cs"
                                        csharp2cuda_temp_179 = (ordered)[index];
                                    }
                                    else
                                    {
#line 648 "GeometryModule.cs"
                                        csharp2cuda_temp_179 = (ordered)[csharp2cuda_i32_sub(index, 1)];
                                    }
#line 648 "GeometryModule.cs"
                                    int right = csharp2cuda_temp_179;
#line 651 "GeometryModule.cs"
#line 651 "GeometryModule.cs"
                                    int* csharp2cuda_temp_180 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)]);
                                    (*(csharp2cuda_temp_180) = 1);
                                }
#line 643 "GeometryModule.cs"
                                int* csharp2cuda_temp_173 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_173));
                            }
                        }
                    }
#line 654 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_181 = (output)->data_pointer;
#line 654 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_181));
#line 655 "GeometryModule.cs"
#line 655 "GeometryModule.cs"
                    int* csharp2cuda_temp_182 = &(edge_count);
                    (*(csharp2cuda_temp_182) = 0);
#line 656 "GeometryModule.cs"
                    {
#line 656 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (count))))
                                break;
#line 657 "GeometryModule.cs"
                            {
#line 658 "GeometryModule.cs"
                                {
#line 658 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
                                        if (!(((right) < (count))))
                                            break;
#line 659 "GeometryModule.cs"
                                        {
#line 660 "GeometryModule.cs"
#line 660 "GeometryModule.cs"
                                            int csharp2cuda_temp_185 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, count), right)];
                                            if ((!(((csharp2cuda_temp_185) != 0))))
                                            {
#line 661 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_16;
                                            }
#line 662 "GeometryModule.cs"
#line 662 "GeometryModule.cs"
                                            int csharp2cuda_temp_186 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_186)))
#line 663 "GeometryModule.cs"
                                            {
#line 664 "GeometryModule.cs"
#line 664 "GeometryModule.cs"
                                                int* csharp2cuda_temp_187 = &((output)->count);
#line 664 "GeometryModule.cs"
                                                int csharp2cuda_temp_188 = (output)->capacity;
#line 664 "GeometryModule.cs"
                                                int csharp2cuda_temp_189;
#line 664 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_188) == (2147483647)))
                                                {
#line 664 "GeometryModule.cs"
                                                    csharp2cuda_temp_189 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 666 "GeometryModule.cs"
                                                    int csharp2cuda_temp_190 = (output)->capacity;
#line 664 "GeometryModule.cs"
                                                    csharp2cuda_temp_189 = csharp2cuda_i32_add(csharp2cuda_temp_190, 1);
                                                }
                                                (*(csharp2cuda_temp_187) = csharp2cuda_temp_189);
#line 667 "GeometryModule.cs"
#line 667 "GeometryModule.cs"
                                                int* csharp2cuda_temp_191 = &((output)->valid);
                                                (*(csharp2cuda_temp_191) = 0);
#line 668 "GeometryModule.cs"
                                                break;
                                            }
#line 670 "GeometryModule.cs"
#line 670 "GeometryModule.cs"
                                            int* csharp2cuda_temp_192 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_192) = left);
#line 671 "GeometryModule.cs"
#line 671 "GeometryModule.cs"
                                            int* csharp2cuda_temp_193 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_193) = right);
#line 672 "GeometryModule.cs"
#line 672 "GeometryModule.cs"
                                            double* csharp2cuda_temp_194 = &(((edges)[edge_count]).weight);
#line 672 "GeometryModule.cs"
                                            double csharp2cuda_temp_195 = mathblocks_geometry_distance(a, left, a, right);
                                            (*(csharp2cuda_temp_194) = csharp2cuda_temp_195);
#line 673 "GeometryModule.cs"
#line 673 "GeometryModule.cs"
                                            double csharp2cuda_temp_196 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_196))))
                                            {
#line 673 "GeometryModule.cs"
#line 673 "GeometryModule.cs"
                                                int* csharp2cuda_temp_197 = &((output)->valid);
                                                (*(csharp2cuda_temp_197) = 0);
                                            }
#line 674 "GeometryModule.cs"
#line 674 "GeometryModule.cs"
                                            int* csharp2cuda_temp_198 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_198));
                                        }
                                        csharp2cuda_for_continue_16:
#line 658 "GeometryModule.cs"
                                        int* csharp2cuda_temp_184 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_184));
                                    }
                                }
                            }
#line 656 "GeometryModule.cs"
                            int* csharp2cuda_temp_183 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_183));
                        }
                    }
#line 677 "GeometryModule.cs"
#line 677 "GeometryModule.cs"
                    int* csharp2cuda_temp_199 = &((output)->rows);
                    (*(csharp2cuda_temp_199) = count);
#line 678 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 679 "GeometryModule.cs"
#line 679 "GeometryModule.cs"
                        int* csharp2cuda_temp_200 = &((output)->count);
                        (*(csharp2cuda_temp_200) = edge_count);
                    }
#line 680 "GeometryModule.cs"
                    break;
                }
#line 682 "GeometryModule.cs"
            case 6:
#line 683 "GeometryModule.cs"
#line 683 "GeometryModule.cs"
                int csharp2cuda_temp_201 = (first)->count;
                if (((csharp2cuda_temp_201) <= (0)))
#line 684 "GeometryModule.cs"
                {
#line 685 "GeometryModule.cs"
#line 685 "GeometryModule.cs"
                    int* csharp2cuda_temp_202 = &((output)->valid);
                    (*(csharp2cuda_temp_202) = 0);
#line 686 "GeometryModule.cs"
                    break;
                }
#line 688 "GeometryModule.cs"
                {
#line 689 "GeometryModule.cs"
                    double maximum = 0.0;
#line 690 "GeometryModule.cs"
                    {
#line 690 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 690 "GeometryModule.cs"
                            int csharp2cuda_temp_204 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_204))))
                                break;
#line 691 "GeometryModule.cs"
                            {
#line 691 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
#line 691 "GeometryModule.cs"
                                    int csharp2cuda_temp_206 = (first)->count;
                                    if (!(((right) < (csharp2cuda_temp_206))))
                                        break;
#line 692 "GeometryModule.cs"
                                    {
#line 693 "GeometryModule.cs"
                                        double distance = mathblocks_geometry_distance(a, left, a, right);
#line 694 "GeometryModule.cs"
#line 694 "GeometryModule.cs"
                                        double* csharp2cuda_temp_207 = &(maximum);
#line 694 "GeometryModule.cs"
                                        double csharp2cuda_temp_208;
#line 694 "GeometryModule.cs"
                                        if (((maximum) > (distance)))
                                        {
#line 694 "GeometryModule.cs"
                                            csharp2cuda_temp_208 = maximum;
                                        }
                                        else
                                        {
#line 694 "GeometryModule.cs"
                                            csharp2cuda_temp_208 = distance;
                                        }
                                        (*(csharp2cuda_temp_207) = csharp2cuda_temp_208);
                                    }
#line 691 "GeometryModule.cs"
                                    int* csharp2cuda_temp_205 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                                }
                            }
#line 690 "GeometryModule.cs"
                            int* csharp2cuda_temp_203 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_203));
                        }
                    }
#line 696 "GeometryModule.cs"
#line 696 "GeometryModule.cs"
                    double* csharp2cuda_temp_209 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_209) = maximum);
#line 697 "GeometryModule.cs"
                    break;
                }
#line 699 "GeometryModule.cs"
            case 7:
#line 700 "GeometryModule.cs"
#line 700 "GeometryModule.cs"
                int csharp2cuda_temp_210 = (first)->count;
#line 700 "GeometryModule.cs"
                bool csharp2cuda_temp_211;
#line 700 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_210) <= (0))))
                {
#line 700 "GeometryModule.cs"
                    int csharp2cuda_temp_212 = (second)->count;
#line 700 "GeometryModule.cs"
                    csharp2cuda_temp_211 = ((csharp2cuda_temp_212) <= (0));
                }
                else
                {
#line 700 "GeometryModule.cs"
                    csharp2cuda_temp_211 = true;
                }
#line 700 "GeometryModule.cs"
                bool csharp2cuda_temp_213;
#line 700 "GeometryModule.cs"
                if (!(csharp2cuda_temp_211))
                {
#line 700 "GeometryModule.cs"
                    csharp2cuda_temp_213 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 700 "GeometryModule.cs"
                    csharp2cuda_temp_213 = true;
                }
                if (csharp2cuda_temp_213)
#line 701 "GeometryModule.cs"
                {
#line 702 "GeometryModule.cs"
#line 702 "GeometryModule.cs"
                    int* csharp2cuda_temp_214 = &((output)->valid);
                    (*(csharp2cuda_temp_214) = 0);
#line 703 "GeometryModule.cs"
                    break;
                }
#line 705 "GeometryModule.cs"
                {
#line 706 "GeometryModule.cs"
                    {
#line 706 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 706 "GeometryModule.cs"
                            int csharp2cuda_temp_216 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_216))))
                                break;
#line 707 "GeometryModule.cs"
                            {
#line 708 "GeometryModule.cs"
                                {
#line 708 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 708 "GeometryModule.cs"
                                        int csharp2cuda_temp_218 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_218))))
                                            break;
#line 709 "GeometryModule.cs"
                                        {
#line 710 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 711 "GeometryModule.cs"
                                            int csharp2cuda_temp_219 = (second)->count;
#line 711 "GeometryModule.cs"
                                            int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_219), right);
#line 712 "GeometryModule.cs"
#line 712 "GeometryModule.cs"
                                            bool csharp2cuda_temp_220;
#line 712 "GeometryModule.cs"
                                            if (((left) == (0)))
                                            {
#line 712 "GeometryModule.cs"
                                                csharp2cuda_temp_220 = ((right) == (0));
                                            }
                                            else
                                            {
#line 712 "GeometryModule.cs"
                                                csharp2cuda_temp_220 = false;
                                            }
                                            if (csharp2cuda_temp_220)
                                            {
#line 713 "GeometryModule.cs"
#line 713 "GeometryModule.cs"
                                                double* csharp2cuda_temp_221 = &((scratch)[0]);
                                                (*(csharp2cuda_temp_221) = distance);
                                            }
                                            else
                                            {
#line 714 "GeometryModule.cs"
                                                if (((left) == (0)))
                                                {
#line 715 "GeometryModule.cs"
#line 715 "GeometryModule.cs"
                                                    double* csharp2cuda_temp_222 = &((scratch)[right]);
#line 715 "GeometryModule.cs"
                                                    double csharp2cuda_temp_223 = (scratch)[csharp2cuda_i32_sub(right, 1)];
#line 715 "GeometryModule.cs"
                                                    double csharp2cuda_temp_224;
#line 715 "GeometryModule.cs"
                                                    if (((csharp2cuda_temp_223) > (distance)))
                                                    {
#line 715 "GeometryModule.cs"
                                                        csharp2cuda_temp_224 = (scratch)[csharp2cuda_i32_sub(right, 1)];
                                                    }
                                                    else
                                                    {
#line 715 "GeometryModule.cs"
                                                        csharp2cuda_temp_224 = distance;
                                                    }
                                                    (*(csharp2cuda_temp_222) = csharp2cuda_temp_224);
                                                }
                                                else
                                                {
#line 718 "GeometryModule.cs"
                                                    if (((right) == (0)))
                                                    {
#line 719 "GeometryModule.cs"
#line 719 "GeometryModule.cs"
                                                        int csharp2cuda_temp_225 = (second)->count;
#line 719 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_226 = &((scratch)[csharp2cuda_i32_mul(left, csharp2cuda_temp_225)]);
#line 719 "GeometryModule.cs"
                                                        int csharp2cuda_temp_227 = (second)->count;
#line 719 "GeometryModule.cs"
                                                        double csharp2cuda_temp_228 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_227)];
#line 719 "GeometryModule.cs"
                                                        double csharp2cuda_temp_229;
#line 719 "GeometryModule.cs"
                                                        if (((csharp2cuda_temp_228) > (distance)))
                                                        {
#line 720 "GeometryModule.cs"
                                                            int csharp2cuda_temp_230 = (second)->count;
#line 719 "GeometryModule.cs"
                                                            csharp2cuda_temp_229 = (scratch)[csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_230)];
                                                        }
                                                        else
                                                        {
#line 719 "GeometryModule.cs"
                                                            csharp2cuda_temp_229 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_226) = csharp2cuda_temp_229);
                                                    }
                                                    else
#line 723 "GeometryModule.cs"
                                                    {
#line 724 "GeometryModule.cs"
                                                        int csharp2cuda_temp_231 = (second)->count;
#line 724 "GeometryModule.cs"
                                                        double preceding = (scratch)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_231), right)];
#line 725 "GeometryModule.cs"
                                                        int csharp2cuda_temp_232 = (second)->count;
#line 725 "GeometryModule.cs"
                                                        double candidate = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(left, 1), csharp2cuda_temp_232), right), 1)];
#line 726 "GeometryModule.cs"
#line 726 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_233 = &(preceding);
#line 726 "GeometryModule.cs"
                                                        double csharp2cuda_temp_234;
#line 726 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 726 "GeometryModule.cs"
                                                            csharp2cuda_temp_234 = preceding;
                                                        }
                                                        else
                                                        {
#line 726 "GeometryModule.cs"
                                                            csharp2cuda_temp_234 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_233) = csharp2cuda_temp_234);
#line 727 "GeometryModule.cs"
#line 727 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_235 = &(candidate);
#line 727 "GeometryModule.cs"
                                                        int csharp2cuda_temp_236 = (second)->count;
#line 727 "GeometryModule.cs"
                                                        double csharp2cuda_temp_237 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, csharp2cuda_temp_236), right), 1)];
                                                        (*(csharp2cuda_temp_235) = csharp2cuda_temp_237);
#line 728 "GeometryModule.cs"
#line 728 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_238 = &(preceding);
#line 728 "GeometryModule.cs"
                                                        double csharp2cuda_temp_239;
#line 728 "GeometryModule.cs"
                                                        if (((preceding) < (candidate)))
                                                        {
#line 728 "GeometryModule.cs"
                                                            csharp2cuda_temp_239 = preceding;
                                                        }
                                                        else
                                                        {
#line 728 "GeometryModule.cs"
                                                            csharp2cuda_temp_239 = candidate;
                                                        }
                                                        (*(csharp2cuda_temp_238) = csharp2cuda_temp_239);
#line 729 "GeometryModule.cs"
#line 729 "GeometryModule.cs"
                                                        double* csharp2cuda_temp_240 = &((scratch)[target]);
#line 729 "GeometryModule.cs"
                                                        double csharp2cuda_temp_241;
#line 729 "GeometryModule.cs"
                                                        if (((preceding) > (distance)))
                                                        {
#line 729 "GeometryModule.cs"
                                                            csharp2cuda_temp_241 = preceding;
                                                        }
                                                        else
                                                        {
#line 729 "GeometryModule.cs"
                                                            csharp2cuda_temp_241 = distance;
                                                        }
                                                        (*(csharp2cuda_temp_240) = csharp2cuda_temp_241);
                                                    }
                                                }
                                            }
                                        }
#line 708 "GeometryModule.cs"
                                        int* csharp2cuda_temp_217 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                                    }
                                }
                            }
#line 706 "GeometryModule.cs"
                            int* csharp2cuda_temp_215 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_215));
                        }
                    }
#line 733 "GeometryModule.cs"
#line 733 "GeometryModule.cs"
                    double* csharp2cuda_temp_242 = &((output)->scalar_value);
#line 733 "GeometryModule.cs"
                    int csharp2cuda_temp_243 = (first)->count;
#line 733 "GeometryModule.cs"
                    int csharp2cuda_temp_244 = (second)->count;
#line 733 "GeometryModule.cs"
                    double csharp2cuda_temp_245 = (scratch)[csharp2cuda_i32_sub(csharp2cuda_i32_mul(csharp2cuda_temp_243, csharp2cuda_temp_244), 1)];
                    (*(csharp2cuda_temp_242) = csharp2cuda_temp_245);
#line 734 "GeometryModule.cs"
                    break;
                }
#line 736 "GeometryModule.cs"
            case 8:
#line 737 "GeometryModule.cs"
#line 737 "GeometryModule.cs"
                int csharp2cuda_temp_246 = (first)->count;
#line 737 "GeometryModule.cs"
                bool csharp2cuda_temp_247;
#line 737 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_246) <= (0))))
                {
#line 737 "GeometryModule.cs"
                    int csharp2cuda_temp_248 = (second)->count;
#line 737 "GeometryModule.cs"
                    csharp2cuda_temp_247 = ((csharp2cuda_temp_248) <= (0));
                }
                else
                {
#line 737 "GeometryModule.cs"
                    csharp2cuda_temp_247 = true;
                }
                if (csharp2cuda_temp_247)
                {
#line 738 "GeometryModule.cs"
#line 738 "GeometryModule.cs"
                    int* csharp2cuda_temp_249 = &((output)->valid);
                    (*(csharp2cuda_temp_249) = 0);
                }
                else
                {
#line 740 "GeometryModule.cs"
#line 740 "GeometryModule.cs"
                    double* csharp2cuda_temp_250 = &((output)->scalar_value);
#line 740 "GeometryModule.cs"
                    double csharp2cuda_temp_251 = mathblocks_geometry_distance(a, 0, b, 0);
                    (*(csharp2cuda_temp_250) = csharp2cuda_temp_251);
                }
#line 741 "GeometryModule.cs"
                break;
#line 742 "GeometryModule.cs"
            case 9:
#line 743 "GeometryModule.cs"
#line 743 "GeometryModule.cs"
                int csharp2cuda_temp_252 = (first)->count;
#line 743 "GeometryModule.cs"
                bool csharp2cuda_temp_253;
#line 743 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_252) <= (0))))
                {
#line 743 "GeometryModule.cs"
                    int csharp2cuda_temp_254 = (first)->count;
#line 743 "GeometryModule.cs"
                    int csharp2cuda_temp_255 = (second)->count;
#line 743 "GeometryModule.cs"
                    csharp2cuda_temp_253 = ((csharp2cuda_temp_254) != (csharp2cuda_temp_255));
                }
                else
                {
#line 743 "GeometryModule.cs"
                    csharp2cuda_temp_253 = true;
                }
#line 743 "GeometryModule.cs"
                bool csharp2cuda_temp_256;
#line 743 "GeometryModule.cs"
                if (!(csharp2cuda_temp_253))
                {
#line 744 "GeometryModule.cs"
                    int csharp2cuda_temp_257 = (first)->count;
#line 743 "GeometryModule.cs"
                    csharp2cuda_temp_256 = (!(mathblocks_probability_distribution(a, csharp2cuda_temp_257)));
                }
                else
                {
#line 743 "GeometryModule.cs"
                    csharp2cuda_temp_256 = true;
                }
#line 743 "GeometryModule.cs"
                bool csharp2cuda_temp_258;
#line 743 "GeometryModule.cs"
                if (!(csharp2cuda_temp_256))
                {
#line 745 "GeometryModule.cs"
                    int csharp2cuda_temp_259 = (second)->count;
#line 743 "GeometryModule.cs"
                    csharp2cuda_temp_258 = (!(mathblocks_probability_distribution(b, csharp2cuda_temp_259)));
                }
                else
                {
#line 743 "GeometryModule.cs"
                    csharp2cuda_temp_258 = true;
                }
                if (csharp2cuda_temp_258)
#line 746 "GeometryModule.cs"
                {
#line 747 "GeometryModule.cs"
#line 747 "GeometryModule.cs"
                    int* csharp2cuda_temp_260 = &((output)->valid);
                    (*(csharp2cuda_temp_260) = 0);
#line 748 "GeometryModule.cs"
                    break;
                }
#line 750 "GeometryModule.cs"
                {
#line 751 "GeometryModule.cs"
                    double affinity = 0.0;
#line 752 "GeometryModule.cs"
                    {
#line 752 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 752 "GeometryModule.cs"
                            int csharp2cuda_temp_262 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_262))))
                                break;
#line 753 "GeometryModule.cs"
#line 753 "GeometryModule.cs"
                            double* csharp2cuda_temp_263 = &(affinity);
#line 753 "GeometryModule.cs"
                            double csharp2cuda_temp_264 = *(csharp2cuda_temp_263);
#line 753 "GeometryModule.cs"
                            double csharp2cuda_temp_265 = (a)[index];
#line 753 "GeometryModule.cs"
                            double csharp2cuda_temp_266 = (b)[index];
                            (*(csharp2cuda_temp_263) = __dadd_rn(csharp2cuda_temp_264, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_265, csharp2cuda_temp_266))));
#line 752 "GeometryModule.cs"
                            int* csharp2cuda_temp_261 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_261));
                        }
                    }
#line 754 "GeometryModule.cs"
#line 754 "GeometryModule.cs"
                    double* csharp2cuda_temp_267 = &(affinity);
#line 754 "GeometryModule.cs"
                    double csharp2cuda_temp_268;
#line 754 "GeometryModule.cs"
                    if (((affinity) < ((-(1.0)))))
                    {
#line 754 "GeometryModule.cs"
                        csharp2cuda_temp_268 = (-(1.0));
                    }
                    else
                    {
#line 754 "GeometryModule.cs"
                        double csharp2cuda_temp_269;
#line 754 "GeometryModule.cs"
                        if (((affinity) > (1.0)))
                        {
#line 754 "GeometryModule.cs"
                            csharp2cuda_temp_269 = 1.0;
                        }
                        else
                        {
#line 754 "GeometryModule.cs"
                            csharp2cuda_temp_269 = affinity;
                        }
#line 754 "GeometryModule.cs"
                        csharp2cuda_temp_268 = csharp2cuda_temp_269;
                    }
                    (*(csharp2cuda_temp_267) = csharp2cuda_temp_268);
#line 755 "GeometryModule.cs"
#line 755 "GeometryModule.cs"
                    double* csharp2cuda_temp_270 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_270) = __dmul_rn(2.0, mathblocks_arc_cosine(affinity)));
#line 756 "GeometryModule.cs"
                    break;
                }
#line 758 "GeometryModule.cs"
            case 10:
#line 759 "GeometryModule.cs"
#line 759 "GeometryModule.cs"
                int csharp2cuda_temp_271 = (first)->count;
                if (((csharp2cuda_temp_271) < (2)))
#line 760 "GeometryModule.cs"
                {
#line 761 "GeometryModule.cs"
#line 761 "GeometryModule.cs"
                    int* csharp2cuda_temp_272 = &((output)->valid);
                    (*(csharp2cuda_temp_272) = 0);
#line 762 "GeometryModule.cs"
                    break;
                }
#line 764 "GeometryModule.cs"
                {
#line 765 "GeometryModule.cs"
                    unsigned long long csharp2cuda_temp_273 = (output)->data_pointer;
#line 765 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(csharp2cuda_temp_273));
#line 766 "GeometryModule.cs"
                    int edge_count = 0;
#line 767 "GeometryModule.cs"
                    {
#line 767 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 767 "GeometryModule.cs"
                            int csharp2cuda_temp_275 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_275))))
                                break;
#line 768 "GeometryModule.cs"
                            {
#line 769 "GeometryModule.cs"
                                {
#line 769 "GeometryModule.cs"
                                    int right = csharp2cuda_i32_add(left, 1);
                                    while (true)
                                    {
#line 769 "GeometryModule.cs"
                                        int csharp2cuda_temp_277 = (first)->count;
                                        if (!(((right) < (csharp2cuda_temp_277))))
                                            break;
#line 770 "GeometryModule.cs"
                                        {
#line 771 "GeometryModule.cs"
                                            double csharp2cuda_temp_278 = (a)[csharp2cuda_i32_mul(2, left)];
#line 771 "GeometryModule.cs"
                                            double csharp2cuda_temp_279 = (a)[csharp2cuda_i32_mul(2, right)];
#line 771 "GeometryModule.cs"
                                            double center_x = __ddiv_rn(__dadd_rn(csharp2cuda_temp_278, csharp2cuda_temp_279), 2.0);
#line 772 "GeometryModule.cs"
                                            double csharp2cuda_temp_280 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 772 "GeometryModule.cs"
                                            double csharp2cuda_temp_281 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 772 "GeometryModule.cs"
                                            double center_y = __ddiv_rn(__dadd_rn(csharp2cuda_temp_280, csharp2cuda_temp_281), 2.0);
#line 773 "GeometryModule.cs"
                                            double csharp2cuda_temp_282 = mathblocks_geometry_distance(a, left, a, right);
#line 773 "GeometryModule.cs"
                                            double radius = __ddiv_rn(csharp2cuda_temp_282, 2.0);
#line 774 "GeometryModule.cs"
                                            bool empty = true;
#line 775 "GeometryModule.cs"
                                            {
#line 775 "GeometryModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
#line 775 "GeometryModule.cs"
                                                    int csharp2cuda_temp_284 = (first)->count;
                                                    if (!(((index) < (csharp2cuda_temp_284))))
                                                        break;
#line 776 "GeometryModule.cs"
                                                    {
#line 777 "GeometryModule.cs"
#line 777 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_285;
#line 777 "GeometryModule.cs"
                                                        if (((index) != (left)))
                                                        {
#line 777 "GeometryModule.cs"
                                                            csharp2cuda_temp_285 = ((index) != (right));
                                                        }
                                                        else
                                                        {
#line 777 "GeometryModule.cs"
                                                            csharp2cuda_temp_285 = false;
                                                        }
#line 777 "GeometryModule.cs"
                                                        bool csharp2cuda_temp_286;
#line 777 "GeometryModule.cs"
                                                        if (csharp2cuda_temp_285)
                                                        {
#line 779 "GeometryModule.cs"
                                                            double csharp2cuda_temp_287 = (a)[csharp2cuda_i32_mul(2, index)];
#line 779 "GeometryModule.cs"
                                                            double csharp2cuda_temp_288 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 777 "GeometryModule.cs"
                                                            csharp2cuda_temp_286 = ((mathblocks_geometry_distance_coordinates(csharp2cuda_temp_287, csharp2cuda_temp_288, center_x, center_y)) < (radius));
                                                        }
                                                        else
                                                        {
#line 777 "GeometryModule.cs"
                                                            csharp2cuda_temp_286 = false;
                                                        }
                                                        if (csharp2cuda_temp_286)
#line 780 "GeometryModule.cs"
                                                        {
#line 781 "GeometryModule.cs"
#line 781 "GeometryModule.cs"
                                                            bool* csharp2cuda_temp_289 = &(empty);
                                                            (*(csharp2cuda_temp_289) = false);
#line 782 "GeometryModule.cs"
                                                            break;
                                                        }
                                                    }
#line 775 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_283 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_283));
                                                }
                                            }
#line 785 "GeometryModule.cs"
                                            if ((!(empty)))
                                            {
#line 786 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_24;
                                            }
#line 787 "GeometryModule.cs"
#line 787 "GeometryModule.cs"
                                            int csharp2cuda_temp_290 = (output)->capacity;
                                            if (((edge_count) >= (csharp2cuda_temp_290)))
#line 788 "GeometryModule.cs"
                                            {
#line 789 "GeometryModule.cs"
#line 789 "GeometryModule.cs"
                                                int* csharp2cuda_temp_291 = &((output)->count);
#line 789 "GeometryModule.cs"
                                                int csharp2cuda_temp_292 = (output)->capacity;
#line 789 "GeometryModule.cs"
                                                int csharp2cuda_temp_293;
#line 789 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_292) == (2147483647)))
                                                {
#line 789 "GeometryModule.cs"
                                                    csharp2cuda_temp_293 = csharp2cuda_i32_neg(1);
                                                }
                                                else
                                                {
#line 791 "GeometryModule.cs"
                                                    int csharp2cuda_temp_294 = (output)->capacity;
#line 789 "GeometryModule.cs"
                                                    csharp2cuda_temp_293 = csharp2cuda_i32_add(csharp2cuda_temp_294, 1);
                                                }
                                                (*(csharp2cuda_temp_291) = csharp2cuda_temp_293);
#line 792 "GeometryModule.cs"
#line 792 "GeometryModule.cs"
                                                int* csharp2cuda_temp_295 = &((output)->valid);
                                                (*(csharp2cuda_temp_295) = 0);
#line 793 "GeometryModule.cs"
                                                break;
                                            }
#line 795 "GeometryModule.cs"
#line 795 "GeometryModule.cs"
                                            int* csharp2cuda_temp_296 = &(((edges)[edge_count]).from);
                                            (*(csharp2cuda_temp_296) = left);
#line 796 "GeometryModule.cs"
#line 796 "GeometryModule.cs"
                                            int* csharp2cuda_temp_297 = &(((edges)[edge_count]).to);
                                            (*(csharp2cuda_temp_297) = right);
#line 797 "GeometryModule.cs"
#line 797 "GeometryModule.cs"
                                            double* csharp2cuda_temp_298 = &(((edges)[edge_count]).weight);
                                            (*(csharp2cuda_temp_298) = __dmul_rn(2.0, radius));
#line 798 "GeometryModule.cs"
#line 798 "GeometryModule.cs"
                                            double csharp2cuda_temp_299 = ((edges)[edge_count]).weight;
                                            if ((!(isfinite(csharp2cuda_temp_299))))
                                            {
#line 798 "GeometryModule.cs"
#line 798 "GeometryModule.cs"
                                                int* csharp2cuda_temp_300 = &((output)->valid);
                                                (*(csharp2cuda_temp_300) = 0);
                                            }
#line 799 "GeometryModule.cs"
#line 799 "GeometryModule.cs"
                                            int* csharp2cuda_temp_301 = &(edge_count);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_301));
                                        }
                                        csharp2cuda_for_continue_24:
#line 769 "GeometryModule.cs"
                                        int* csharp2cuda_temp_276 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_276));
                                    }
                                }
                            }
#line 767 "GeometryModule.cs"
                            int* csharp2cuda_temp_274 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_274));
                        }
                    }
#line 802 "GeometryModule.cs"
#line 802 "GeometryModule.cs"
                    int* csharp2cuda_temp_302 = &((output)->rows);
#line 802 "GeometryModule.cs"
                    int csharp2cuda_temp_303 = (first)->count;
                    (*(csharp2cuda_temp_302) = csharp2cuda_temp_303);
#line 803 "GeometryModule.cs"
                    if ((output)->valid)
                    {
#line 804 "GeometryModule.cs"
#line 804 "GeometryModule.cs"
                        int* csharp2cuda_temp_304 = &((output)->count);
                        (*(csharp2cuda_temp_304) = edge_count);
                    }
#line 805 "GeometryModule.cs"
                    break;
                }
#line 807 "GeometryModule.cs"
            case 11:
#line 808 "GeometryModule.cs"
#line 808 "GeometryModule.cs"
                int csharp2cuda_temp_305 = (first)->count;
#line 808 "GeometryModule.cs"
                bool csharp2cuda_temp_306;
#line 808 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_305) <= (0))))
                {
#line 808 "GeometryModule.cs"
                    int csharp2cuda_temp_307 = (second)->count;
#line 808 "GeometryModule.cs"
                    csharp2cuda_temp_306 = ((csharp2cuda_temp_307) != (1));
                }
                else
                {
#line 808 "GeometryModule.cs"
                    csharp2cuda_temp_306 = true;
                }
                if (csharp2cuda_temp_306)
#line 809 "GeometryModule.cs"
                {
#line 810 "GeometryModule.cs"
#line 810 "GeometryModule.cs"
                    int* csharp2cuda_temp_308 = &((output)->valid);
                    (*(csharp2cuda_temp_308) = 0);
#line 811 "GeometryModule.cs"
                    break;
                }
#line 813 "GeometryModule.cs"
                {
#line 814 "GeometryModule.cs"
                    double point_x = (b)[0];
#line 815 "GeometryModule.cs"
                    double point_y = (b)[1];
#line 816 "GeometryModule.cs"
                    int coincident = 0;
#line 817 "GeometryModule.cs"
                    int vector_count = 0;
#line 818 "GeometryModule.cs"
                    {
#line 818 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 818 "GeometryModule.cs"
                            int csharp2cuda_temp_310 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_310))))
                                break;
#line 819 "GeometryModule.cs"
                            {
#line 820 "GeometryModule.cs"
                                double csharp2cuda_temp_311 = (a)[csharp2cuda_i32_mul(2, index)];
#line 820 "GeometryModule.cs"
                                double x = __dsub_rn(csharp2cuda_temp_311, point_x);
#line 821 "GeometryModule.cs"
                                double csharp2cuda_temp_312 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 821 "GeometryModule.cs"
                                double y = __dsub_rn(csharp2cuda_temp_312, point_y);
#line 822 "GeometryModule.cs"
#line 822 "GeometryModule.cs"
                                bool csharp2cuda_temp_313;
#line 822 "GeometryModule.cs"
                                if (((x) == (0.0)))
                                {
#line 822 "GeometryModule.cs"
                                    csharp2cuda_temp_313 = ((y) == (0.0));
                                }
                                else
                                {
#line 822 "GeometryModule.cs"
                                    csharp2cuda_temp_313 = false;
                                }
                                if (csharp2cuda_temp_313)
                                {
#line 823 "GeometryModule.cs"
#line 823 "GeometryModule.cs"
                                    int* csharp2cuda_temp_314 = &(coincident);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                                }
                                else
                                {
#line 825 "GeometryModule.cs"
#line 825 "GeometryModule.cs"
                                    int* csharp2cuda_temp_315 = &(vector_count);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_315));
                                }
                            }
#line 818 "GeometryModule.cs"
                            int* csharp2cuda_temp_309 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_309));
                        }
                    }
#line 827 "GeometryModule.cs"
                    if (((vector_count) == (0)))
#line 828 "GeometryModule.cs"
                    {
#line 829 "GeometryModule.cs"
#line 829 "GeometryModule.cs"
                        double* csharp2cuda_temp_316 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_316) = 1.0);
#line 830 "GeometryModule.cs"
                        break;
                    }
#line 832 "GeometryModule.cs"
                    int maximum = 0;
#line 833 "GeometryModule.cs"
                    {
#line 833 "GeometryModule.cs"
                        int pivot = 0;
                        while (true)
                        {
#line 833 "GeometryModule.cs"
                            int csharp2cuda_temp_318 = (first)->count;
                            if (!(((pivot) < (csharp2cuda_temp_318))))
                                break;
#line 834 "GeometryModule.cs"
                            {
#line 835 "GeometryModule.cs"
                                double csharp2cuda_temp_319 = (a)[csharp2cuda_i32_mul(2, pivot)];
#line 835 "GeometryModule.cs"
                                double pivot_x = __dsub_rn(csharp2cuda_temp_319, point_x);
#line 836 "GeometryModule.cs"
                                double csharp2cuda_temp_320 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, pivot), 1)];
#line 836 "GeometryModule.cs"
                                double pivot_y = __dsub_rn(csharp2cuda_temp_320, point_y);
#line 837 "GeometryModule.cs"
#line 837 "GeometryModule.cs"
                                bool csharp2cuda_temp_321;
#line 837 "GeometryModule.cs"
                                if (((pivot_x) == (0.0)))
                                {
#line 837 "GeometryModule.cs"
                                    csharp2cuda_temp_321 = ((pivot_y) == (0.0));
                                }
                                else
                                {
#line 837 "GeometryModule.cs"
                                    csharp2cuda_temp_321 = false;
                                }
                                if (csharp2cuda_temp_321)
                                {
#line 838 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_28;
                                }
#line 839 "GeometryModule.cs"
                                int count = 0;
#line 840 "GeometryModule.cs"
                                {
#line 840 "GeometryModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 840 "GeometryModule.cs"
                                        int csharp2cuda_temp_323 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_323))))
                                            break;
#line 841 "GeometryModule.cs"
                                        {
#line 842 "GeometryModule.cs"
                                            double csharp2cuda_temp_324 = (a)[csharp2cuda_i32_mul(2, index)];
#line 842 "GeometryModule.cs"
                                            double x = __dsub_rn(csharp2cuda_temp_324, point_x);
#line 843 "GeometryModule.cs"
                                            double csharp2cuda_temp_325 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
#line 843 "GeometryModule.cs"
                                            double y = __dsub_rn(csharp2cuda_temp_325, point_y);
#line 844 "GeometryModule.cs"
#line 844 "GeometryModule.cs"
                                            bool csharp2cuda_temp_326;
#line 844 "GeometryModule.cs"
                                            if (((x) == (0.0)))
                                            {
#line 844 "GeometryModule.cs"
                                                csharp2cuda_temp_326 = ((y) == (0.0));
                                            }
                                            else
                                            {
#line 844 "GeometryModule.cs"
                                                csharp2cuda_temp_326 = false;
                                            }
                                            if (csharp2cuda_temp_326)
                                            {
#line 845 "GeometryModule.cs"
                                                goto csharp2cuda_for_continue_27;
                                            }
#line 846 "GeometryModule.cs"
                                            double cross = __dsub_rn(__dmul_rn(pivot_x, y), __dmul_rn(pivot_y, x));
#line 847 "GeometryModule.cs"
                                            double dot = __dadd_rn(__dmul_rn(pivot_x, x), __dmul_rn(pivot_y, y));
#line 849 "GeometryModule.cs"
#line 849 "GeometryModule.cs"
                                            bool csharp2cuda_temp_327;
#line 849 "GeometryModule.cs"
                                            if (!(isnan(cross)))
                                            {
#line 849 "GeometryModule.cs"
                                                csharp2cuda_temp_327 = isnan(dot);
                                            }
                                            else
                                            {
#line 849 "GeometryModule.cs"
                                                csharp2cuda_temp_327 = true;
                                            }
                                            if (csharp2cuda_temp_327)
                                            {
#line 850 "GeometryModule.cs"
#line 850 "GeometryModule.cs"
                                                int* csharp2cuda_temp_328 = &((output)->valid);
                                                (*(csharp2cuda_temp_328) = 0);
                                            }
#line 851 "GeometryModule.cs"
#line 851 "GeometryModule.cs"
                                            bool csharp2cuda_temp_329;
#line 851 "GeometryModule.cs"
                                            if (!(((cross) > (0.0))))
                                            {
#line 851 "GeometryModule.cs"
                                                bool csharp2cuda_temp_330;
#line 851 "GeometryModule.cs"
                                                if (((cross) == (0.0)))
                                                {
#line 851 "GeometryModule.cs"
                                                    csharp2cuda_temp_330 = ((dot) > (0.0));
                                                }
                                                else
                                                {
#line 851 "GeometryModule.cs"
                                                    csharp2cuda_temp_330 = false;
                                                }
#line 851 "GeometryModule.cs"
                                                csharp2cuda_temp_329 = csharp2cuda_temp_330;
                                            }
                                            else
                                            {
#line 851 "GeometryModule.cs"
                                                csharp2cuda_temp_329 = true;
                                            }
                                            if (csharp2cuda_temp_329)
                                            {
#line 852 "GeometryModule.cs"
#line 852 "GeometryModule.cs"
                                                int* csharp2cuda_temp_331 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_331));
                                            }
                                        }
                                        csharp2cuda_for_continue_27:
#line 840 "GeometryModule.cs"
                                        int* csharp2cuda_temp_322 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_322));
                                    }
                                }
#line 854 "GeometryModule.cs"
#line 854 "GeometryModule.cs"
                                int* csharp2cuda_temp_332 = &(maximum);
#line 854 "GeometryModule.cs"
                                int csharp2cuda_temp_333;
#line 854 "GeometryModule.cs"
                                if (((maximum) > (count)))
                                {
#line 854 "GeometryModule.cs"
                                    csharp2cuda_temp_333 = maximum;
                                }
                                else
                                {
#line 854 "GeometryModule.cs"
                                    csharp2cuda_temp_333 = count;
                                }
                                (*(csharp2cuda_temp_332) = csharp2cuda_temp_333);
                            }
                            csharp2cuda_for_continue_28:
#line 833 "GeometryModule.cs"
                            int* csharp2cuda_temp_317 = &(pivot);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_317));
                        }
                    }
#line 856 "GeometryModule.cs"
#line 856 "GeometryModule.cs"
                    double* csharp2cuda_temp_334 = &((output)->scalar_value);
#line 857 "GeometryModule.cs"
                    int csharp2cuda_temp_335 = (first)->count;
#line 856 "GeometryModule.cs"
                    double csharp2cuda_temp_336 = __ddiv_rn(((double)(csharp2cuda_i32_sub(csharp2cuda_i32_add(coincident, vector_count), maximum))), ((double)(csharp2cuda_temp_335)));
                    (*(csharp2cuda_temp_334) = csharp2cuda_temp_336);
#line 858 "GeometryModule.cs"
                    break;
                }
#line 860 "GeometryModule.cs"
            case 12:
#line 861 "GeometryModule.cs"
#line 861 "GeometryModule.cs"
                int csharp2cuda_temp_337 = (first)->count;
#line 861 "GeometryModule.cs"
                bool csharp2cuda_temp_338;
#line 861 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_337) <= (0))))
                {
#line 861 "GeometryModule.cs"
                    int csharp2cuda_temp_339 = (second)->count;
#line 861 "GeometryModule.cs"
                    csharp2cuda_temp_338 = ((csharp2cuda_temp_339) <= (0));
                }
                else
                {
#line 861 "GeometryModule.cs"
                    csharp2cuda_temp_338 = true;
                }
                if (csharp2cuda_temp_338)
#line 862 "GeometryModule.cs"
                {
#line 863 "GeometryModule.cs"
#line 863 "GeometryModule.cs"
                    int* csharp2cuda_temp_340 = &((output)->valid);
                    (*(csharp2cuda_temp_340) = 0);
#line 864 "GeometryModule.cs"
                    break;
                }
#line 866 "GeometryModule.cs"
                {
#line 867 "GeometryModule.cs"
                    double directed_left = 0.0;
#line 868 "GeometryModule.cs"
                    {
#line 868 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
#line 868 "GeometryModule.cs"
                            int csharp2cuda_temp_342 = (first)->count;
                            if (!(((left) < (csharp2cuda_temp_342))))
                                break;
#line 869 "GeometryModule.cs"
                            {
#line 870 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 871 "GeometryModule.cs"
                                {
#line 871 "GeometryModule.cs"
                                    int right = 0;
                                    while (true)
                                    {
#line 871 "GeometryModule.cs"
                                        int csharp2cuda_temp_344 = (second)->count;
                                        if (!(((right) < (csharp2cuda_temp_344))))
                                            break;
#line 872 "GeometryModule.cs"
                                        {
#line 873 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(a, left, b, right);
#line 874 "GeometryModule.cs"
#line 874 "GeometryModule.cs"
                                            double* csharp2cuda_temp_345 = &(minimum);
#line 874 "GeometryModule.cs"
                                            double csharp2cuda_temp_346;
#line 874 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 874 "GeometryModule.cs"
                                                csharp2cuda_temp_346 = minimum;
                                            }
                                            else
                                            {
#line 874 "GeometryModule.cs"
                                                csharp2cuda_temp_346 = distance;
                                            }
                                            (*(csharp2cuda_temp_345) = csharp2cuda_temp_346);
                                        }
#line 871 "GeometryModule.cs"
                                        int* csharp2cuda_temp_343 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_343));
                                    }
                                }
#line 876 "GeometryModule.cs"
#line 876 "GeometryModule.cs"
                                double* csharp2cuda_temp_347 = &(directed_left);
#line 876 "GeometryModule.cs"
                                double csharp2cuda_temp_348;
#line 876 "GeometryModule.cs"
                                if (((directed_left) > (minimum)))
                                {
#line 876 "GeometryModule.cs"
                                    csharp2cuda_temp_348 = directed_left;
                                }
                                else
                                {
#line 876 "GeometryModule.cs"
                                    csharp2cuda_temp_348 = minimum;
                                }
                                (*(csharp2cuda_temp_347) = csharp2cuda_temp_348);
                            }
#line 868 "GeometryModule.cs"
                            int* csharp2cuda_temp_341 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_341));
                        }
                    }
#line 878 "GeometryModule.cs"
                    double directed_right = 0.0;
#line 879 "GeometryModule.cs"
                    {
#line 879 "GeometryModule.cs"
                        int right = 0;
                        while (true)
                        {
#line 879 "GeometryModule.cs"
                            int csharp2cuda_temp_350 = (second)->count;
                            if (!(((right) < (csharp2cuda_temp_350))))
                                break;
#line 880 "GeometryModule.cs"
                            {
#line 881 "GeometryModule.cs"
                                double minimum = mathblocks_positive_infinity();
#line 882 "GeometryModule.cs"
                                {
#line 882 "GeometryModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
#line 882 "GeometryModule.cs"
                                        int csharp2cuda_temp_352 = (first)->count;
                                        if (!(((left) < (csharp2cuda_temp_352))))
                                            break;
#line 883 "GeometryModule.cs"
                                        {
#line 884 "GeometryModule.cs"
                                            double distance = mathblocks_geometry_distance(b, right, a, left);
#line 885 "GeometryModule.cs"
#line 885 "GeometryModule.cs"
                                            double* csharp2cuda_temp_353 = &(minimum);
#line 885 "GeometryModule.cs"
                                            double csharp2cuda_temp_354;
#line 885 "GeometryModule.cs"
                                            if (((minimum) < (distance)))
                                            {
#line 885 "GeometryModule.cs"
                                                csharp2cuda_temp_354 = minimum;
                                            }
                                            else
                                            {
#line 885 "GeometryModule.cs"
                                                csharp2cuda_temp_354 = distance;
                                            }
                                            (*(csharp2cuda_temp_353) = csharp2cuda_temp_354);
                                        }
#line 882 "GeometryModule.cs"
                                        int* csharp2cuda_temp_351 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_351));
                                    }
                                }
#line 887 "GeometryModule.cs"
#line 887 "GeometryModule.cs"
                                double* csharp2cuda_temp_355 = &(directed_right);
#line 887 "GeometryModule.cs"
                                double csharp2cuda_temp_356;
#line 887 "GeometryModule.cs"
                                if (((directed_right) > (minimum)))
                                {
#line 887 "GeometryModule.cs"
                                    csharp2cuda_temp_356 = directed_right;
                                }
                                else
                                {
#line 887 "GeometryModule.cs"
                                    csharp2cuda_temp_356 = minimum;
                                }
                                (*(csharp2cuda_temp_355) = csharp2cuda_temp_356);
                            }
#line 879 "GeometryModule.cs"
                            int* csharp2cuda_temp_349 = &(right);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_349));
                        }
                    }
#line 889 "GeometryModule.cs"
#line 889 "GeometryModule.cs"
                    double* csharp2cuda_temp_357 = &((output)->scalar_value);
#line 889 "GeometryModule.cs"
                    double csharp2cuda_temp_358;
#line 889 "GeometryModule.cs"
                    if (((directed_left) > (directed_right)))
                    {
#line 889 "GeometryModule.cs"
                        csharp2cuda_temp_358 = directed_left;
                    }
                    else
                    {
#line 889 "GeometryModule.cs"
                        csharp2cuda_temp_358 = directed_right;
                    }
                    (*(csharp2cuda_temp_357) = csharp2cuda_temp_358);
#line 892 "GeometryModule.cs"
                    break;
                }
#line 894 "GeometryModule.cs"
            case 13:
            case 14:
#line 896 "GeometryModule.cs"
#line 896 "GeometryModule.cs"
                int csharp2cuda_temp_359 = (first)->count;
                if (((csharp2cuda_temp_359) <= (0)))
#line 897 "GeometryModule.cs"
                {
#line 898 "GeometryModule.cs"
#line 898 "GeometryModule.cs"
                    int* csharp2cuda_temp_360 = &((output)->valid);
                    (*(csharp2cuda_temp_360) = 0);
#line 899 "GeometryModule.cs"
                    break;
                }
#line 901 "GeometryModule.cs"
                {
#line 902 "GeometryModule.cs"
                    double total = 0.0;
#line 903 "GeometryModule.cs"
                    int csharp2cuda_temp_361;
#line 903 "GeometryModule.cs"
                    if (((opcode) == (13)))
                    {
#line 903 "GeometryModule.cs"
                        csharp2cuda_temp_361 = 1;
                    }
                    else
                    {
#line 903 "GeometryModule.cs"
                        csharp2cuda_temp_361 = 0;
                    }
#line 903 "GeometryModule.cs"
                    int start = csharp2cuda_temp_361;
#line 904 "GeometryModule.cs"
                    {
#line 904 "GeometryModule.cs"
                        int index = start;
                        while (true)
                        {
#line 904 "GeometryModule.cs"
                            int csharp2cuda_temp_363 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_363))))
                                break;
#line 905 "GeometryModule.cs"
                            {
#line 906 "GeometryModule.cs"
                                int csharp2cuda_temp_364;
#line 906 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 906 "GeometryModule.cs"
                                    csharp2cuda_temp_364 = csharp2cuda_i32_sub(index, 1);
                                }
                                else
                                {
#line 906 "GeometryModule.cs"
                                    csharp2cuda_temp_364 = index;
                                }
#line 906 "GeometryModule.cs"
                                int previous = csharp2cuda_temp_364;
#line 907 "GeometryModule.cs"
                                int csharp2cuda_temp_365;
#line 907 "GeometryModule.cs"
                                if (((opcode) == (13)))
                                {
#line 907 "GeometryModule.cs"
                                    csharp2cuda_temp_365 = index;
                                }
                                else
                                {
#line 907 "GeometryModule.cs"
                                    int csharp2cuda_temp_366 = (first)->count;
#line 907 "GeometryModule.cs"
                                    csharp2cuda_temp_365 = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_366);
                                }
#line 907 "GeometryModule.cs"
                                int next = csharp2cuda_temp_365;
#line 908 "GeometryModule.cs"
#line 908 "GeometryModule.cs"
                                double* csharp2cuda_temp_367 = &(total);
#line 908 "GeometryModule.cs"
                                double csharp2cuda_temp_368 = *(csharp2cuda_temp_367);
#line 908 "GeometryModule.cs"
                                double csharp2cuda_temp_369 = mathblocks_geometry_distance(a, previous, a, next);
                                (*(csharp2cuda_temp_367) = __dadd_rn(csharp2cuda_temp_368, csharp2cuda_temp_369));
                            }
#line 904 "GeometryModule.cs"
                            int* csharp2cuda_temp_362 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_362));
                        }
                    }
#line 910 "GeometryModule.cs"
#line 910 "GeometryModule.cs"
                    double* csharp2cuda_temp_370 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_370) = total);
#line 911 "GeometryModule.cs"
                    break;
                }
#line 913 "GeometryModule.cs"
            case 15:
#line 914 "GeometryModule.cs"
#line 914 "GeometryModule.cs"
                int csharp2cuda_temp_371 = (first)->count;
#line 914 "GeometryModule.cs"
                bool csharp2cuda_temp_372;
#line 914 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_371) != (1))))
                {
#line 914 "GeometryModule.cs"
                    int csharp2cuda_temp_373 = (second)->count;
#line 914 "GeometryModule.cs"
                    csharp2cuda_temp_372 = ((csharp2cuda_temp_373) != (2));
                }
                else
                {
#line 914 "GeometryModule.cs"
                    csharp2cuda_temp_372 = true;
                }
                if (csharp2cuda_temp_372)
#line 915 "GeometryModule.cs"
                {
#line 916 "GeometryModule.cs"
#line 916 "GeometryModule.cs"
                    int* csharp2cuda_temp_374 = &((output)->valid);
                    (*(csharp2cuda_temp_374) = 0);
#line 917 "GeometryModule.cs"
                    break;
                }
#line 919 "GeometryModule.cs"
#line 919 "GeometryModule.cs"
                double* csharp2cuda_temp_375 = &((output)->scalar_value);
#line 920 "GeometryModule.cs"
                double csharp2cuda_temp_376 = (a)[0];
#line 920 "GeometryModule.cs"
                double csharp2cuda_temp_377 = (a)[1];
#line 920 "GeometryModule.cs"
                double csharp2cuda_temp_378 = (b)[0];
#line 920 "GeometryModule.cs"
                double csharp2cuda_temp_379 = (b)[1];
#line 920 "GeometryModule.cs"
                double csharp2cuda_temp_380 = (b)[2];
#line 920 "GeometryModule.cs"
                double csharp2cuda_temp_381 = (b)[3];
                (*(csharp2cuda_temp_375) = mathblocks_geometry_point_to_segment(csharp2cuda_temp_376, csharp2cuda_temp_377, csharp2cuda_temp_378, csharp2cuda_temp_379, csharp2cuda_temp_380, csharp2cuda_temp_381));
#line 921 "GeometryModule.cs"
                break;
#line 922 "GeometryModule.cs"
            case 16:
            case 17:
#line 924 "GeometryModule.cs"
#line 924 "GeometryModule.cs"
                int csharp2cuda_temp_382 = (first)->count;
                if (((csharp2cuda_temp_382) <= (0)))
#line 925 "GeometryModule.cs"
                {
#line 926 "GeometryModule.cs"
#line 926 "GeometryModule.cs"
                    int* csharp2cuda_temp_383 = &((output)->valid);
                    (*(csharp2cuda_temp_383) = 0);
#line 927 "GeometryModule.cs"
                    break;
                }
#line 929 "GeometryModule.cs"
                {
#line 930 "GeometryModule.cs"
                    double twice_area = 0.0;
#line 931 "GeometryModule.cs"
                    {
#line 931 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 931 "GeometryModule.cs"
                            int csharp2cuda_temp_385 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_385))))
                                break;
#line 932 "GeometryModule.cs"
                            {
#line 933 "GeometryModule.cs"
                                int csharp2cuda_temp_386 = (first)->count;
#line 933 "GeometryModule.cs"
                                int next = csharp2cuda_i32_rem(csharp2cuda_i32_add(index, 1), csharp2cuda_temp_386);
#line 934 "GeometryModule.cs"
#line 934 "GeometryModule.cs"
                                double* csharp2cuda_temp_387 = &(twice_area);
#line 934 "GeometryModule.cs"
                                double csharp2cuda_temp_388 = *(csharp2cuda_temp_387);
#line 934 "GeometryModule.cs"
                                double csharp2cuda_temp_389 = (a)[csharp2cuda_i32_mul(2, index)];
#line 934 "GeometryModule.cs"
                                double csharp2cuda_temp_390 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, next), 1)];
#line 935 "GeometryModule.cs"
                                double csharp2cuda_temp_391 = (a)[csharp2cuda_i32_mul(2, next)];
#line 935 "GeometryModule.cs"
                                double csharp2cuda_temp_392 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                (*(csharp2cuda_temp_387) = __dadd_rn(csharp2cuda_temp_388, __dsub_rn(__dmul_rn(csharp2cuda_temp_389, csharp2cuda_temp_390), __dmul_rn(csharp2cuda_temp_391, csharp2cuda_temp_392))));
                            }
#line 931 "GeometryModule.cs"
                            int* csharp2cuda_temp_384 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_384));
                        }
                    }
#line 937 "GeometryModule.cs"
#line 937 "GeometryModule.cs"
                    double* csharp2cuda_temp_393 = &((output)->scalar_value);
#line 937 "GeometryModule.cs"
                    double csharp2cuda_temp_394;
#line 937 "GeometryModule.cs"
                    if (((opcode) == (16)))
                    {
#line 937 "GeometryModule.cs"
                        double csharp2cuda_temp_395 = __ddiv_rn(twice_area, 2.0);
#line 937 "GeometryModule.cs"
                        csharp2cuda_temp_394 = fabs(csharp2cuda_temp_395);
                    }
                    else
                    {
#line 937 "GeometryModule.cs"
                        csharp2cuda_temp_394 = __ddiv_rn(twice_area, 2.0);
                    }
                    (*(csharp2cuda_temp_393) = csharp2cuda_temp_394);
#line 938 "GeometryModule.cs"
                    break;
                }
#line 940 "GeometryModule.cs"
            case 18:
#line 941 "GeometryModule.cs"
#line 941 "GeometryModule.cs"
                int csharp2cuda_temp_396 = (first)->count;
#line 941 "GeometryModule.cs"
                bool csharp2cuda_temp_397;
#line 941 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_396) < (3))))
                {
#line 941 "GeometryModule.cs"
                    int csharp2cuda_temp_398 = (second)->count;
#line 941 "GeometryModule.cs"
                    csharp2cuda_temp_397 = ((csharp2cuda_temp_398) != (1));
                }
                else
                {
#line 941 "GeometryModule.cs"
                    csharp2cuda_temp_397 = true;
                }
                if (csharp2cuda_temp_397)
#line 942 "GeometryModule.cs"
                {
#line 943 "GeometryModule.cs"
#line 943 "GeometryModule.cs"
                    int* csharp2cuda_temp_399 = &((output)->valid);
                    (*(csharp2cuda_temp_399) = 0);
#line 944 "GeometryModule.cs"
                    break;
                }
#line 946 "GeometryModule.cs"
                {
#line 947 "GeometryModule.cs"
                    int containing = 0;
#line 948 "GeometryModule.cs"
                    int total = 0;
#line 949 "GeometryModule.cs"
                    double csharp2cuda_temp_400_storage[3];
                    double* coordinates = csharp2cuda_temp_400_storage;
#line 950 "GeometryModule.cs"
                    {
#line 950 "GeometryModule.cs"
                        int one = 0;
                        while (true)
                        {
#line 950 "GeometryModule.cs"
                            int csharp2cuda_temp_402 = (first)->count;
                            if (!(((one) < (csharp2cuda_temp_402))))
                                break;
#line 951 "GeometryModule.cs"
                            {
#line 951 "GeometryModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
#line 951 "GeometryModule.cs"
                                    int csharp2cuda_temp_404 = (first)->count;
                                    if (!(((two) < (csharp2cuda_temp_404))))
                                        break;
#line 952 "GeometryModule.cs"
                                    {
#line 952 "GeometryModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
#line 952 "GeometryModule.cs"
                                            int csharp2cuda_temp_406 = (first)->count;
                                            if (!(((three) < (csharp2cuda_temp_406))))
                                                break;
#line 953 "GeometryModule.cs"
                                            {
#line 954 "GeometryModule.cs"
#line 954 "GeometryModule.cs"
                                                int* csharp2cuda_temp_407 = &(total);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_407));
#line 956 "GeometryModule.cs"
#line 957 "GeometryModule.cs"
                                                double csharp2cuda_temp_408 = (a)[csharp2cuda_i32_mul(2, one)];
#line 957 "GeometryModule.cs"
                                                double csharp2cuda_temp_409 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 958 "GeometryModule.cs"
                                                double csharp2cuda_temp_410 = (a)[csharp2cuda_i32_mul(2, two)];
#line 958 "GeometryModule.cs"
                                                double csharp2cuda_temp_411 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 959 "GeometryModule.cs"
                                                double csharp2cuda_temp_412 = (a)[csharp2cuda_i32_mul(2, three)];
#line 959 "GeometryModule.cs"
                                                double csharp2cuda_temp_413 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                if (((mathblocks_geometry_barycentric_denominator(csharp2cuda_temp_408, csharp2cuda_temp_409, csharp2cuda_temp_410, csharp2cuda_temp_411, csharp2cuda_temp_412, csharp2cuda_temp_413)) == (0.0)))
                                                {
#line 960 "GeometryModule.cs"
                                                    goto csharp2cuda_for_continue_35;
                                                }
#line 961 "GeometryModule.cs"
#line 962 "GeometryModule.cs"
                                                double csharp2cuda_temp_414 = (b)[0];
#line 962 "GeometryModule.cs"
                                                double csharp2cuda_temp_415 = (b)[1];
#line 963 "GeometryModule.cs"
                                                double csharp2cuda_temp_416 = (a)[csharp2cuda_i32_mul(2, one)];
#line 963 "GeometryModule.cs"
                                                double csharp2cuda_temp_417 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, one), 1)];
#line 964 "GeometryModule.cs"
                                                double csharp2cuda_temp_418 = (a)[csharp2cuda_i32_mul(2, two)];
#line 964 "GeometryModule.cs"
                                                double csharp2cuda_temp_419 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, two), 1)];
#line 965 "GeometryModule.cs"
                                                double csharp2cuda_temp_420 = (a)[csharp2cuda_i32_mul(2, three)];
#line 965 "GeometryModule.cs"
                                                double csharp2cuda_temp_421 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, three), 1)];
                                                mathblocks_geometry_barycentric(csharp2cuda_temp_414, csharp2cuda_temp_415, csharp2cuda_temp_416, csharp2cuda_temp_417, csharp2cuda_temp_418, csharp2cuda_temp_419, csharp2cuda_temp_420, csharp2cuda_temp_421, coordinates);
#line 967 "GeometryModule.cs"
#line 967 "GeometryModule.cs"
                                                double csharp2cuda_temp_422 = (coordinates)[0];
#line 967 "GeometryModule.cs"
                                                bool csharp2cuda_temp_423;
#line 967 "GeometryModule.cs"
                                                if (!((!(isfinite(csharp2cuda_temp_422)))))
                                                {
#line 967 "GeometryModule.cs"
                                                    double csharp2cuda_temp_424 = (coordinates)[1];
#line 967 "GeometryModule.cs"
                                                    csharp2cuda_temp_423 = (!(isfinite(csharp2cuda_temp_424)));
                                                }
                                                else
                                                {
#line 967 "GeometryModule.cs"
                                                    csharp2cuda_temp_423 = true;
                                                }
#line 967 "GeometryModule.cs"
                                                bool csharp2cuda_temp_425;
#line 967 "GeometryModule.cs"
                                                if (!(csharp2cuda_temp_423))
                                                {
#line 968 "GeometryModule.cs"
                                                    double csharp2cuda_temp_426 = (coordinates)[2];
#line 967 "GeometryModule.cs"
                                                    csharp2cuda_temp_425 = (!(isfinite(csharp2cuda_temp_426)));
                                                }
                                                else
                                                {
#line 967 "GeometryModule.cs"
                                                    csharp2cuda_temp_425 = true;
                                                }
                                                if (csharp2cuda_temp_425)
                                                {
#line 969 "GeometryModule.cs"
#line 969 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_427 = &((output)->valid);
                                                    (*(csharp2cuda_temp_427) = 0);
                                                }
#line 970 "GeometryModule.cs"
#line 970 "GeometryModule.cs"
                                                double csharp2cuda_temp_428 = (coordinates)[0];
#line 970 "GeometryModule.cs"
                                                bool csharp2cuda_temp_429;
#line 970 "GeometryModule.cs"
                                                if (((csharp2cuda_temp_428) >= (0.0)))
                                                {
#line 970 "GeometryModule.cs"
                                                    double csharp2cuda_temp_430 = (coordinates)[0];
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_429 = ((csharp2cuda_temp_430) <= (1.0));
                                                }
                                                else
                                                {
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_429 = false;
                                                }
#line 970 "GeometryModule.cs"
                                                bool csharp2cuda_temp_431;
#line 970 "GeometryModule.cs"
                                                if (csharp2cuda_temp_429)
                                                {
#line 971 "GeometryModule.cs"
                                                    double csharp2cuda_temp_432 = (coordinates)[1];
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_431 = ((csharp2cuda_temp_432) >= (0.0));
                                                }
                                                else
                                                {
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_431 = false;
                                                }
#line 970 "GeometryModule.cs"
                                                bool csharp2cuda_temp_433;
#line 970 "GeometryModule.cs"
                                                if (csharp2cuda_temp_431)
                                                {
#line 971 "GeometryModule.cs"
                                                    double csharp2cuda_temp_434 = (coordinates)[1];
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_433 = ((csharp2cuda_temp_434) <= (1.0));
                                                }
                                                else
                                                {
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_433 = false;
                                                }
#line 970 "GeometryModule.cs"
                                                bool csharp2cuda_temp_435;
#line 970 "GeometryModule.cs"
                                                if (csharp2cuda_temp_433)
                                                {
#line 972 "GeometryModule.cs"
                                                    double csharp2cuda_temp_436 = (coordinates)[2];
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_435 = ((csharp2cuda_temp_436) >= (0.0));
                                                }
                                                else
                                                {
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_435 = false;
                                                }
#line 970 "GeometryModule.cs"
                                                bool csharp2cuda_temp_437;
#line 970 "GeometryModule.cs"
                                                if (csharp2cuda_temp_435)
                                                {
#line 972 "GeometryModule.cs"
                                                    double csharp2cuda_temp_438 = (coordinates)[2];
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_437 = ((csharp2cuda_temp_438) <= (1.0));
                                                }
                                                else
                                                {
#line 970 "GeometryModule.cs"
                                                    csharp2cuda_temp_437 = false;
                                                }
                                                if (csharp2cuda_temp_437)
#line 973 "GeometryModule.cs"
                                                {
#line 974 "GeometryModule.cs"
#line 974 "GeometryModule.cs"
                                                    int* csharp2cuda_temp_439 = &(containing);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_439));
                                                }
                                            }
                                            csharp2cuda_for_continue_35:
#line 952 "GeometryModule.cs"
                                            int* csharp2cuda_temp_405 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_405));
                                        }
                                    }
#line 951 "GeometryModule.cs"
                                    int* csharp2cuda_temp_403 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_403));
                                }
                            }
#line 950 "GeometryModule.cs"
                            int* csharp2cuda_temp_401 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_401));
                        }
                    }
#line 977 "GeometryModule.cs"
#line 977 "GeometryModule.cs"
                    double* csharp2cuda_temp_440 = &((output)->scalar_value);
#line 977 "GeometryModule.cs"
                    double csharp2cuda_temp_441 = __ddiv_rn(((double)(containing)), ((double)(total)));
                    (*(csharp2cuda_temp_440) = csharp2cuda_temp_441);
#line 978 "GeometryModule.cs"
                    break;
                }
#line 980 "GeometryModule.cs"
            case 19:
#line 981 "GeometryModule.cs"
#line 981 "GeometryModule.cs"
                int* csharp2cuda_temp_442 = &((output)->rows);
#line 981 "GeometryModule.cs"
                int csharp2cuda_temp_443 = (first)->rows;
                (*(csharp2cuda_temp_442) = csharp2cuda_temp_443);
#line 982 "GeometryModule.cs"
#line 982 "GeometryModule.cs"
                int* csharp2cuda_temp_444 = &((output)->count);
#line 982 "GeometryModule.cs"
                int csharp2cuda_temp_445 = (first)->rows;
                (*(csharp2cuda_temp_444) = csharp2cuda_temp_445);
#line 983 "GeometryModule.cs"
#line 983 "GeometryModule.cs"
                int csharp2cuda_temp_446 = (first)->columns;
#line 983 "GeometryModule.cs"
                bool csharp2cuda_temp_447;
#line 983 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_446) != (2))))
                {
#line 983 "GeometryModule.cs"
                    int csharp2cuda_temp_448 = (first)->rows;
#line 983 "GeometryModule.cs"
                    int csharp2cuda_temp_449 = (output)->capacity;
#line 983 "GeometryModule.cs"
                    csharp2cuda_temp_447 = ((csharp2cuda_temp_448) > (csharp2cuda_temp_449));
                }
                else
                {
#line 983 "GeometryModule.cs"
                    csharp2cuda_temp_447 = true;
                }
                if (csharp2cuda_temp_447)
#line 984 "GeometryModule.cs"
                {
#line 985 "GeometryModule.cs"
#line 985 "GeometryModule.cs"
                    int* csharp2cuda_temp_450 = &((output)->valid);
                    (*(csharp2cuda_temp_450) = 0);
#line 986 "GeometryModule.cs"
                    break;
                }
#line 988 "GeometryModule.cs"
                {
#line 988 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 988 "GeometryModule.cs"
                        int csharp2cuda_temp_452 = (first)->rows;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_452, 2)))))
                            break;
#line 989 "GeometryModule.cs"
#line 989 "GeometryModule.cs"
                        double* csharp2cuda_temp_453 = &((result)[index]);
#line 989 "GeometryModule.cs"
                        double csharp2cuda_temp_454 = (a)[index];
                        (*(csharp2cuda_temp_453) = csharp2cuda_temp_454);
#line 988 "GeometryModule.cs"
                        int* csharp2cuda_temp_451 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_451));
                    }
                }
#line 990 "GeometryModule.cs"
                break;
#line 991 "GeometryModule.cs"
            case 20:
#line 992 "GeometryModule.cs"
#line 992 "GeometryModule.cs"
                int csharp2cuda_temp_455 = (first)->count;
                mathblocks_sequence_set_matrix_shape(output, csharp2cuda_temp_455, 2);
#line 993 "GeometryModule.cs"
#line 993 "GeometryModule.cs"
                int csharp2cuda_temp_456 = (first)->count;
                if (((csharp2cuda_temp_456) <= (0)))
#line 994 "GeometryModule.cs"
                {
#line 995 "GeometryModule.cs"
#line 995 "GeometryModule.cs"
                    int* csharp2cuda_temp_457 = &((output)->valid);
                    (*(csharp2cuda_temp_457) = 0);
#line 996 "GeometryModule.cs"
                    break;
                }
#line 998 "GeometryModule.cs"
                {
#line 998 "GeometryModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 998 "GeometryModule.cs"
                        int csharp2cuda_temp_459 = (first)->count;
                        if (!(((index) < (csharp2cuda_i32_mul(csharp2cuda_temp_459, 2)))))
                            break;
#line 999 "GeometryModule.cs"
#line 999 "GeometryModule.cs"
                        double* csharp2cuda_temp_460 = &((result)[index]);
#line 999 "GeometryModule.cs"
                        double csharp2cuda_temp_461 = (a)[index];
                        (*(csharp2cuda_temp_460) = csharp2cuda_temp_461);
#line 998 "GeometryModule.cs"
                        int* csharp2cuda_temp_458 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_458));
                    }
                }
#line 1000 "GeometryModule.cs"
                break;
#line 1001 "GeometryModule.cs"
            case 21:
#line 1002 "GeometryModule.cs"
#line 1002 "GeometryModule.cs"
                int csharp2cuda_temp_462 = (first)->count;
#line 1002 "GeometryModule.cs"
                bool csharp2cuda_temp_463;
#line 1002 "GeometryModule.cs"
                if (!(((csharp2cuda_temp_462) <= (0))))
                {
#line 1002 "GeometryModule.cs"
                    csharp2cuda_temp_463 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1002 "GeometryModule.cs"
                    csharp2cuda_temp_463 = true;
                }
                if (csharp2cuda_temp_463)
#line 1003 "GeometryModule.cs"
                {
#line 1004 "GeometryModule.cs"
#line 1004 "GeometryModule.cs"
                    int* csharp2cuda_temp_464 = &((output)->valid);
                    (*(csharp2cuda_temp_464) = 0);
#line 1005 "GeometryModule.cs"
                    break;
                }
#line 1007 "GeometryModule.cs"
#line 1007 "GeometryModule.cs"
                int csharp2cuda_temp_465 = (first)->count;
                if (((csharp2cuda_temp_465) == (1)))
#line 1008 "GeometryModule.cs"
                {
#line 1009 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, 0);
#line 1010 "GeometryModule.cs"
                    break;
                }
#line 1012 "GeometryModule.cs"
                {
#line 1013 "GeometryModule.cs"
                    int vertex_count = (first)->count;
#line 1014 "GeometryModule.cs"
                    int edge_capacity = csharp2cuda_i32_div(csharp2cuda_i32_mul(vertex_count, csharp2cuda_i32_sub(vertex_count, 1)), 2);
#line 1015 "GeometryModule.cs"
                    MathBlockGeometryEdge* edges = ((MathBlockGeometryEdge*)(scratch));
#line 1016 "GeometryModule.cs"
                    int edge_count = 0;
#line 1017 "GeometryModule.cs"
                    {
#line 1017 "GeometryModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (vertex_count))))
                                break;
#line 1018 "GeometryModule.cs"
                            {
#line 1018 "GeometryModule.cs"
                                int right = csharp2cuda_i32_add(left, 1);
                                while (true)
                                {
                                    if (!(((right) < (vertex_count))))
                                        break;
#line 1019 "GeometryModule.cs"
                                    {
#line 1020 "GeometryModule.cs"
#line 1020 "GeometryModule.cs"
                                        int* csharp2cuda_temp_468 = &(((edges)[edge_count]).from);
                                        (*(csharp2cuda_temp_468) = left);
#line 1021 "GeometryModule.cs"
#line 1021 "GeometryModule.cs"
                                        int* csharp2cuda_temp_469 = &(((edges)[edge_count]).to);
                                        (*(csharp2cuda_temp_469) = right);
#line 1022 "GeometryModule.cs"
#line 1022 "GeometryModule.cs"
                                        double* csharp2cuda_temp_470 = &(((edges)[edge_count]).weight);
#line 1022 "GeometryModule.cs"
                                        double csharp2cuda_temp_471 = mathblocks_geometry_distance(a, left, a, right);
                                        (*(csharp2cuda_temp_470) = csharp2cuda_temp_471);
#line 1023 "GeometryModule.cs"
#line 1023 "GeometryModule.cs"
                                        int* csharp2cuda_temp_472 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_472));
                                    }
#line 1018 "GeometryModule.cs"
                                    int* csharp2cuda_temp_467 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_467));
                                }
                            }
#line 1017 "GeometryModule.cs"
                            int* csharp2cuda_temp_466 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_466));
                        }
                    }
#line 1025 "GeometryModule.cs"
                    mathblocks_geometry_sort_edges(edges, csharp2cuda_pointer_add(edges, edge_capacity), edge_count);
#line 1026 "GeometryModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(edges, csharp2cuda_i32_mul(2, edge_capacity))));
#line 1027 "GeometryModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 1028 "GeometryModule.cs"
                    {
#line 1028 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 1029 "GeometryModule.cs"
                            {
#line 1030 "GeometryModule.cs"
#line 1030 "GeometryModule.cs"
                                int* csharp2cuda_temp_474 = &((parent)[index]);
                                (*(csharp2cuda_temp_474) = index);
#line 1031 "GeometryModule.cs"
#line 1031 "GeometryModule.cs"
                                unsigned char* csharp2cuda_temp_475 = &((rank)[index]);
                                (*(csharp2cuda_temp_475) = ((unsigned char)(0)));
                            }
#line 1028 "GeometryModule.cs"
                            int* csharp2cuda_temp_473 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
                        }
                    }
#line 1033 "GeometryModule.cs"
                    int selected = 0;
#line 1034 "GeometryModule.cs"
                    {
#line 1034 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1034 "GeometryModule.cs"
                            bool csharp2cuda_temp_477;
#line 1034 "GeometryModule.cs"
                            if (((index) < (edge_count)))
                            {
#line 1034 "GeometryModule.cs"
                                csharp2cuda_temp_477 = ((selected) < (csharp2cuda_i32_sub(vertex_count, 1)));
                            }
                            else
                            {
#line 1034 "GeometryModule.cs"
                                csharp2cuda_temp_477 = false;
                            }
                            if (!(csharp2cuda_temp_477))
                                break;
#line 1035 "GeometryModule.cs"
                            {
#line 1036 "GeometryModule.cs"
                                int csharp2cuda_temp_478 = ((edges)[index]).from;
#line 1036 "GeometryModule.cs"
                                int left = mathblocks_geometry_find(parent, csharp2cuda_temp_478);
#line 1037 "GeometryModule.cs"
                                int csharp2cuda_temp_479 = ((edges)[index]).to;
#line 1037 "GeometryModule.cs"
                                int right = mathblocks_geometry_find(parent, csharp2cuda_temp_479);
#line 1038 "GeometryModule.cs"
                                if (((left) == (right)))
                                {
#line 1039 "GeometryModule.cs"
                                    goto csharp2cuda_for_continue_43;
                                }
#line 1040 "GeometryModule.cs"
#line 1040 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_480 = (rank)[left];
#line 1040 "GeometryModule.cs"
                                unsigned char csharp2cuda_temp_481 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_480))) < (((int)(csharp2cuda_temp_481)))))
                                {
#line 1041 "GeometryModule.cs"
#line 1041 "GeometryModule.cs"
                                    int* csharp2cuda_temp_482 = &((parent)[left]);
                                    (*(csharp2cuda_temp_482) = right);
                                }
                                else
                                {
#line 1042 "GeometryModule.cs"
#line 1042 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_483 = (rank)[left];
#line 1042 "GeometryModule.cs"
                                    unsigned char csharp2cuda_temp_484 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_483))) > (((int)(csharp2cuda_temp_484)))))
                                    {
#line 1043 "GeometryModule.cs"
#line 1043 "GeometryModule.cs"
                                        int* csharp2cuda_temp_485 = &((parent)[right]);
                                        (*(csharp2cuda_temp_485) = left);
                                    }
                                    else
#line 1045 "GeometryModule.cs"
                                    {
#line 1046 "GeometryModule.cs"
#line 1046 "GeometryModule.cs"
                                        int* csharp2cuda_temp_486 = &((parent)[right]);
                                        (*(csharp2cuda_temp_486) = left);
#line 1047 "GeometryModule.cs"
#line 1047 "GeometryModule.cs"
                                        unsigned char* csharp2cuda_temp_487 = &((rank)[left]);
                                        (*(csharp2cuda_temp_487))++;
                                    }
                                }
#line 1049 "GeometryModule.cs"
#line 1049 "GeometryModule.cs"
                                int* csharp2cuda_temp_488 = &(selected);
#line 1049 "GeometryModule.cs"
                                int csharp2cuda_temp_489 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_488));
#line 1049 "GeometryModule.cs"
                                double* csharp2cuda_temp_490 = &((result)[csharp2cuda_temp_489]);
#line 1049 "GeometryModule.cs"
                                double csharp2cuda_temp_491 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_490) = csharp2cuda_temp_491);
                            }
                            csharp2cuda_for_continue_43:
#line 1034 "GeometryModule.cs"
                            int* csharp2cuda_temp_476 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_476));
                        }
                    }
#line 1051 "GeometryModule.cs"
                    mathblocks_sequence_set_vector_shape(output, selected);
#line 1052 "GeometryModule.cs"
                    {
#line 1052 "GeometryModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (selected))))
                                break;
#line 1053 "GeometryModule.cs"
#line 1053 "GeometryModule.cs"
                            double csharp2cuda_temp_493 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_493))))
                            {
#line 1053 "GeometryModule.cs"
#line 1053 "GeometryModule.cs"
                                int* csharp2cuda_temp_494 = &((output)->valid);
                                (*(csharp2cuda_temp_494) = 0);
                            }
#line 1052 "GeometryModule.cs"
                            int* csharp2cuda_temp_492 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_492));
                        }
                    }
#line 1054 "GeometryModule.cs"
                    break;
                }
        }
#line 1057 "GeometryModule.cs"
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_495 = (output)->valid;
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_496;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_495)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_496 = ((opcode) != (0));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_496 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_497;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_496)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_497 = ((opcode) != (1));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_497 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_498;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_497)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_498 = ((opcode) != (3));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_498 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_499;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_498)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_499 = ((opcode) != (4));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_499 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_500;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_499)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_500 = ((opcode) != (5));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_500 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_501;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_500)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_501 = ((opcode) != (10));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_501 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_502;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_501)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_502 = ((opcode) != (19));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_502 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_503;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_502)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_503 = ((opcode) != (20));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_503 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_504;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_503)
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_504 = ((opcode) != (21));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_504 = false;
        }
#line 1057 "GeometryModule.cs"
        bool csharp2cuda_temp_505;
#line 1057 "GeometryModule.cs"
        if (csharp2cuda_temp_504)
        {
#line 1060 "GeometryModule.cs"
            double csharp2cuda_temp_506 = (output)->scalar_value;
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_505 = (!(isfinite(csharp2cuda_temp_506)));
        }
        else
        {
#line 1057 "GeometryModule.cs"
            csharp2cuda_temp_505 = false;
        }
        if (csharp2cuda_temp_505)
#line 1061 "GeometryModule.cs"
        {
#line 1062 "GeometryModule.cs"
#line 1062 "GeometryModule.cs"
            int* csharp2cuda_temp_507 = &((output)->valid);
            (*(csharp2cuda_temp_507) = 0);
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

#line 337 "GeometryModule.cs"
__device__ bool mathblocks_geometry_edge_less(
    const MathBlockGeometryEdge* left,
    const MathBlockGeometryEdge* right)
#line 341 "GeometryModule.cs"
{
#line 342 "GeometryModule.cs"
#line 342 "GeometryModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 342 "GeometryModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 343 "GeometryModule.cs"
        return true;
    }
#line 344 "GeometryModule.cs"
#line 344 "GeometryModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 344 "GeometryModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 345 "GeometryModule.cs"
        return false;
    }
#line 346 "GeometryModule.cs"
#line 346 "GeometryModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 346 "GeometryModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 347 "GeometryModule.cs"
        return true;
    }
#line 348 "GeometryModule.cs"
#line 348 "GeometryModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 348 "GeometryModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 349 "GeometryModule.cs"
        return false;
    }
#line 350 "GeometryModule.cs"
#line 350 "GeometryModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 350 "GeometryModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 326 "GeometryModule.cs"
__device__ int mathblocks_geometry_find(int* parent, int value)
#line 328 "GeometryModule.cs"
{
#line 329 "GeometryModule.cs"
    while (true)
    {
#line 329 "GeometryModule.cs"
        int csharp2cuda_temp_0 = (parent)[value];
        if (!(((csharp2cuda_temp_0) != (value))))
            break;
#line 330 "GeometryModule.cs"
        {
#line 331 "GeometryModule.cs"
#line 331 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[value]);
#line 331 "GeometryModule.cs"
            int csharp2cuda_temp_2 = (parent)[value];
#line 331 "GeometryModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 332 "GeometryModule.cs"
#line 332 "GeometryModule.cs"
            int* csharp2cuda_temp_4 = &(value);
#line 332 "GeometryModule.cs"
            int csharp2cuda_temp_5 = (parent)[value];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 334 "GeometryModule.cs"
    return value;
}

#line 237 "GeometryModule.cs"
__device__ void mathblocks_geometry_index_order(
    const double* points,
    int count,
    int* order,
    int* buffer)
#line 243 "GeometryModule.cs"
{
#line 244 "GeometryModule.cs"
    {
#line 244 "GeometryModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 245 "GeometryModule.cs"
#line 245 "GeometryModule.cs"
            int* csharp2cuda_temp_1 = &((order)[index]);
            (*(csharp2cuda_temp_1) = index);
#line 244 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 246 "GeometryModule.cs"
    int* source = order;
#line 247 "GeometryModule.cs"
    int* target = buffer;
#line 248 "GeometryModule.cs"
    {
#line 248 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 249 "GeometryModule.cs"
            {
#line 250 "GeometryModule.cs"
                {
#line 250 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 251 "GeometryModule.cs"
                        {
#line 252 "GeometryModule.cs"
                            int csharp2cuda_temp_6;
#line 252 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 252 "GeometryModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 252 "GeometryModule.cs"
                                csharp2cuda_temp_6 = count;
                            }
#line 252 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_6;
#line 253 "GeometryModule.cs"
                            int csharp2cuda_temp_7;
#line 253 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 253 "GeometryModule.cs"
                                csharp2cuda_temp_7 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 253 "GeometryModule.cs"
                                csharp2cuda_temp_7 = count;
                            }
#line 253 "GeometryModule.cs"
                            int end = csharp2cuda_temp_7;
#line 254 "GeometryModule.cs"
                            int left = start;
#line 255 "GeometryModule.cs"
                            int right = middle;
#line 256 "GeometryModule.cs"
                            int position = start;
#line 257 "GeometryModule.cs"
                            while (true)
                            {
#line 257 "GeometryModule.cs"
                                bool csharp2cuda_temp_8;
#line 257 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 257 "GeometryModule.cs"
                                    csharp2cuda_temp_8 = ((right) < (end));
                                }
                                else
                                {
#line 257 "GeometryModule.cs"
                                    csharp2cuda_temp_8 = false;
                                }
                                if (!(csharp2cuda_temp_8))
                                    break;
#line 258 "GeometryModule.cs"
                                {
#line 259 "GeometryModule.cs"
                                    int csharp2cuda_temp_9 = (source)[right];
#line 259 "GeometryModule.cs"
                                    int csharp2cuda_temp_10 = (source)[left];
#line 259 "GeometryModule.cs"
                                    bool take_right = mathblocks_geometry_point_less(points, csharp2cuda_temp_9, csharp2cuda_temp_10);
#line 260 "GeometryModule.cs"
#line 260 "GeometryModule.cs"
                                    int* csharp2cuda_temp_11 = &(position);
#line 260 "GeometryModule.cs"
                                    int csharp2cuda_temp_12 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
#line 260 "GeometryModule.cs"
                                    int* csharp2cuda_temp_13 = &((target)[csharp2cuda_temp_12]);
#line 260 "GeometryModule.cs"
                                    int csharp2cuda_temp_14;
#line 260 "GeometryModule.cs"
                                    if (take_right)
                                    {
#line 260 "GeometryModule.cs"
                                        int* csharp2cuda_temp_15 = &(right);
#line 260 "GeometryModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 260 "GeometryModule.cs"
                                        csharp2cuda_temp_14 = (source)[csharp2cuda_temp_16];
                                    }
                                    else
                                    {
#line 260 "GeometryModule.cs"
                                        int* csharp2cuda_temp_17 = &(left);
#line 260 "GeometryModule.cs"
                                        int csharp2cuda_temp_18 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
#line 260 "GeometryModule.cs"
                                        csharp2cuda_temp_14 = (source)[csharp2cuda_temp_18];
                                    }
                                    (*(csharp2cuda_temp_13) = csharp2cuda_temp_14);
                                }
                            }
#line 262 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 263 "GeometryModule.cs"
#line 263 "GeometryModule.cs"
                                int* csharp2cuda_temp_19 = &(position);
#line 263 "GeometryModule.cs"
                                int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 263 "GeometryModule.cs"
                                int* csharp2cuda_temp_21 = &((target)[csharp2cuda_temp_20]);
#line 263 "GeometryModule.cs"
                                int* csharp2cuda_temp_22 = &(left);
#line 263 "GeometryModule.cs"
                                int csharp2cuda_temp_23 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_22));
#line 263 "GeometryModule.cs"
                                int csharp2cuda_temp_24 = (source)[csharp2cuda_temp_23];
                                (*(csharp2cuda_temp_21) = csharp2cuda_temp_24);
                            }
#line 264 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 265 "GeometryModule.cs"
#line 265 "GeometryModule.cs"
                                int* csharp2cuda_temp_25 = &(position);
#line 265 "GeometryModule.cs"
                                int csharp2cuda_temp_26 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_25));
#line 265 "GeometryModule.cs"
                                int* csharp2cuda_temp_27 = &((target)[csharp2cuda_temp_26]);
#line 265 "GeometryModule.cs"
                                int* csharp2cuda_temp_28 = &(right);
#line 265 "GeometryModule.cs"
                                int csharp2cuda_temp_29 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_28));
#line 265 "GeometryModule.cs"
                                int csharp2cuda_temp_30 = (source)[csharp2cuda_temp_29];
                                (*(csharp2cuda_temp_27) = csharp2cuda_temp_30);
                            }
                        }
#line 250 "GeometryModule.cs"
                        int* csharp2cuda_temp_4 = &(start);
#line 250 "GeometryModule.cs"
                        int csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
                        (*(csharp2cuda_temp_4) = csharp2cuda_i32_add(csharp2cuda_temp_5, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 267 "GeometryModule.cs"
                int* sorted = target;
#line 268 "GeometryModule.cs"
#line 268 "GeometryModule.cs"
                int** csharp2cuda_temp_31 = &(target);
                (*(csharp2cuda_temp_31) = source);
#line 269 "GeometryModule.cs"
#line 269 "GeometryModule.cs"
                int** csharp2cuda_temp_32 = &(source);
                (*(csharp2cuda_temp_32) = sorted);
            }
#line 248 "GeometryModule.cs"
            int* csharp2cuda_temp_2 = &(width);
#line 248 "GeometryModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, width));
        }
    }
#line 271 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(order)))))
    {
#line 272 "GeometryModule.cs"
        {
#line 272 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 273 "GeometryModule.cs"
#line 273 "GeometryModule.cs"
                int* csharp2cuda_temp_34 = &((order)[index]);
#line 273 "GeometryModule.cs"
                int csharp2cuda_temp_35 = (source)[index];
                (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
#line 272 "GeometryModule.cs"
                int* csharp2cuda_temp_33 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
            }
        }
    }
}

#line 77 "GeometryModule.cs"
__device__ bool mathblocks_geometry_not_left_turn(
    int* overflow,
    double origin_x,
    double origin_y,
    double left_x,
    double left_y,
    double right_x,
    double right_y)
#line 86 "GeometryModule.cs"
{
#line 87 "GeometryModule.cs"
    double cross = mathblocks_geometry_cross(origin_x, origin_y, left_x, left_y, right_x, right_y);
#line 88 "GeometryModule.cs"
    if (isnan(cross))
    {
#line 89 "GeometryModule.cs"
#line 89 "GeometryModule.cs"
        int* csharp2cuda_temp_0 = overflow;
        (*(csharp2cuda_temp_0) = 1);
    }
#line 90 "GeometryModule.cs"
    return ((cross) <= (0.0));
}

#line 215 "GeometryModule.cs"
__device__ bool mathblocks_geometry_point_less(
    const double* points,
    int left,
    int right)
#line 220 "GeometryModule.cs"
{
#line 221 "GeometryModule.cs"
    double left_x = (points)[csharp2cuda_i32_mul(2, left)];
#line 222 "GeometryModule.cs"
    double right_x = (points)[csharp2cuda_i32_mul(2, right)];
#line 223 "GeometryModule.cs"
    if (((left_x) < (right_x)))
    {
#line 224 "GeometryModule.cs"
        return true;
    }
#line 225 "GeometryModule.cs"
    if (((right_x) < (left_x)))
    {
#line 226 "GeometryModule.cs"
        return false;
    }
#line 227 "GeometryModule.cs"
    double left_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 228 "GeometryModule.cs"
    double right_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 229 "GeometryModule.cs"
    if (((left_y) < (right_y)))
    {
#line 230 "GeometryModule.cs"
        return true;
    }
#line 231 "GeometryModule.cs"
    if (((right_y) < (left_y)))
    {
#line 232 "GeometryModule.cs"
        return false;
    }
#line 233 "GeometryModule.cs"
    return ((left) < (right));
}

#line 106 "GeometryModule.cs"
__device__ double mathblocks_geometry_point_to_segment(
    double point_x,
    double point_y,
    double start_x,
    double start_y,
    double end_x,
    double end_y)
#line 114 "GeometryModule.cs"
{
#line 115 "GeometryModule.cs"
    double x = __dsub_rn(end_x, start_x);
#line 116 "GeometryModule.cs"
    double y = __dsub_rn(end_y, start_y);
#line 117 "GeometryModule.cs"
    double length_square = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y));
#line 118 "GeometryModule.cs"
    if (((length_square) == (0.0)))
    {
#line 119 "GeometryModule.cs"
        return mathblocks_geometry_distance_coordinates(point_x, point_y, start_x, start_y);
    }
#line 120 "GeometryModule.cs"
    double projection = __ddiv_rn(__dadd_rn(__dmul_rn(__dsub_rn(point_x, start_x), x), __dmul_rn(__dsub_rn(point_y, start_y), y)), length_square);
#line 122 "GeometryModule.cs"
#line 122 "GeometryModule.cs"
    double* csharp2cuda_temp_0 = &(projection);
#line 122 "GeometryModule.cs"
    double csharp2cuda_temp_1;
#line 122 "GeometryModule.cs"
    if (((projection) < (0.0)))
    {
#line 122 "GeometryModule.cs"
        csharp2cuda_temp_1 = 0.0;
    }
    else
    {
#line 122 "GeometryModule.cs"
        double csharp2cuda_temp_2;
#line 122 "GeometryModule.cs"
        if (((projection) > (1.0)))
        {
#line 122 "GeometryModule.cs"
            csharp2cuda_temp_2 = 1.0;
        }
        else
        {
#line 122 "GeometryModule.cs"
            csharp2cuda_temp_2 = projection;
        }
#line 122 "GeometryModule.cs"
        csharp2cuda_temp_1 = csharp2cuda_temp_2;
    }
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 123 "GeometryModule.cs"
    return mathblocks_geometry_distance_coordinates(point_x, point_y, __dadd_rn(start_x, __dmul_rn(projection, x)), __dadd_rn(start_y, __dmul_rn(projection, y)));
}

#line 355 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_edges(MathBlockGeometryEdge* edges, MathBlockGeometryEdge* buffer, int count)
#line 357 "GeometryModule.cs"
{
#line 358 "GeometryModule.cs"
    MathBlockGeometryEdge* source = edges;
#line 359 "GeometryModule.cs"
    MathBlockGeometryEdge* target = buffer;
#line 360 "GeometryModule.cs"
    {
#line 360 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 361 "GeometryModule.cs"
            {
#line 362 "GeometryModule.cs"
                {
#line 362 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 363 "GeometryModule.cs"
                        {
#line 364 "GeometryModule.cs"
                            int csharp2cuda_temp_4;
#line 364 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 364 "GeometryModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 364 "GeometryModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 364 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 365 "GeometryModule.cs"
                            int csharp2cuda_temp_5;
#line 365 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 365 "GeometryModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 365 "GeometryModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 365 "GeometryModule.cs"
                            int end = csharp2cuda_temp_5;
#line 366 "GeometryModule.cs"
                            int left = start;
#line 367 "GeometryModule.cs"
                            int right = middle;
#line 368 "GeometryModule.cs"
                            int position = start;
#line 369 "GeometryModule.cs"
                            while (true)
                            {
#line 369 "GeometryModule.cs"
                                bool csharp2cuda_temp_6;
#line 369 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 369 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 369 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 370 "GeometryModule.cs"
                                {
#line 371 "GeometryModule.cs"
#line 371 "GeometryModule.cs"
                                    MathBlockGeometryEdge* csharp2cuda_temp_7 = &((source)[right]);
#line 371 "GeometryModule.cs"
                                    MathBlockGeometryEdge* csharp2cuda_temp_8 = &((source)[left]);
                                    if (mathblocks_geometry_edge_less(csharp2cuda_temp_7, csharp2cuda_temp_8))
                                    {
#line 372 "GeometryModule.cs"
#line 372 "GeometryModule.cs"
                                        int* csharp2cuda_temp_9 = &(position);
#line 372 "GeometryModule.cs"
                                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 372 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_11 = &((target)[csharp2cuda_temp_10]);
#line 372 "GeometryModule.cs"
                                        int* csharp2cuda_temp_12 = &(right);
#line 372 "GeometryModule.cs"
                                        int csharp2cuda_temp_13 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
#line 372 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_14 = (source)[csharp2cuda_temp_13];
                                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_14);
                                    }
                                    else
                                    {
#line 374 "GeometryModule.cs"
#line 374 "GeometryModule.cs"
                                        int* csharp2cuda_temp_15 = &(position);
#line 374 "GeometryModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 374 "GeometryModule.cs"
                                        MathBlockGeometryEdge* csharp2cuda_temp_17 = &((target)[csharp2cuda_temp_16]);
#line 374 "GeometryModule.cs"
                                        int* csharp2cuda_temp_18 = &(left);
#line 374 "GeometryModule.cs"
                                        int csharp2cuda_temp_19 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
#line 374 "GeometryModule.cs"
                                        MathBlockGeometryEdge csharp2cuda_temp_20 = (source)[csharp2cuda_temp_19];
                                        (*(csharp2cuda_temp_17) = csharp2cuda_temp_20);
                                    }
                                }
                            }
#line 376 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 377 "GeometryModule.cs"
#line 377 "GeometryModule.cs"
                                int* csharp2cuda_temp_21 = &(position);
#line 377 "GeometryModule.cs"
                                int csharp2cuda_temp_22 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
#line 377 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_23 = &((target)[csharp2cuda_temp_22]);
#line 377 "GeometryModule.cs"
                                int* csharp2cuda_temp_24 = &(left);
#line 377 "GeometryModule.cs"
                                int csharp2cuda_temp_25 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
#line 377 "GeometryModule.cs"
                                MathBlockGeometryEdge csharp2cuda_temp_26 = (source)[csharp2cuda_temp_25];
                                (*(csharp2cuda_temp_23) = csharp2cuda_temp_26);
                            }
#line 378 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 379 "GeometryModule.cs"
#line 379 "GeometryModule.cs"
                                int* csharp2cuda_temp_27 = &(position);
#line 379 "GeometryModule.cs"
                                int csharp2cuda_temp_28 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 379 "GeometryModule.cs"
                                MathBlockGeometryEdge* csharp2cuda_temp_29 = &((target)[csharp2cuda_temp_28]);
#line 379 "GeometryModule.cs"
                                int* csharp2cuda_temp_30 = &(right);
#line 379 "GeometryModule.cs"
                                int csharp2cuda_temp_31 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_30));
#line 379 "GeometryModule.cs"
                                MathBlockGeometryEdge csharp2cuda_temp_32 = (source)[csharp2cuda_temp_31];
                                (*(csharp2cuda_temp_29) = csharp2cuda_temp_32);
                            }
                        }
#line 362 "GeometryModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 362 "GeometryModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 381 "GeometryModule.cs"
                MathBlockGeometryEdge* sorted = target;
#line 382 "GeometryModule.cs"
#line 382 "GeometryModule.cs"
                MathBlockGeometryEdge** csharp2cuda_temp_33 = &(target);
                (*(csharp2cuda_temp_33) = source);
#line 383 "GeometryModule.cs"
#line 383 "GeometryModule.cs"
                MathBlockGeometryEdge** csharp2cuda_temp_34 = &(source);
                (*(csharp2cuda_temp_34) = sorted);
            }
#line 360 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 360 "GeometryModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 385 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(edges)))))
    {
#line 386 "GeometryModule.cs"
        {
#line 386 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 387 "GeometryModule.cs"
#line 387 "GeometryModule.cs"
                MathBlockGeometryEdge* csharp2cuda_temp_36 = &((edges)[index]);
#line 387 "GeometryModule.cs"
                MathBlockGeometryEdge csharp2cuda_temp_37 = (source)[index];
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 386 "GeometryModule.cs"
                int* csharp2cuda_temp_35 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
            }
        }
    }
}

#line 279 "GeometryModule.cs"
__device__ void mathblocks_geometry_sort_points(double* points, double* buffer, int count)
#line 281 "GeometryModule.cs"
{
#line 282 "GeometryModule.cs"
    double* source = points;
#line 283 "GeometryModule.cs"
    double* target = buffer;
#line 284 "GeometryModule.cs"
    {
#line 284 "GeometryModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 285 "GeometryModule.cs"
            {
#line 286 "GeometryModule.cs"
                {
#line 286 "GeometryModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 287 "GeometryModule.cs"
                        {
#line 288 "GeometryModule.cs"
                            int csharp2cuda_temp_4;
#line 288 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 288 "GeometryModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 288 "GeometryModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 288 "GeometryModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 289 "GeometryModule.cs"
                            int csharp2cuda_temp_5;
#line 289 "GeometryModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 289 "GeometryModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 289 "GeometryModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 289 "GeometryModule.cs"
                            int end = csharp2cuda_temp_5;
#line 290 "GeometryModule.cs"
                            int left = start;
#line 291 "GeometryModule.cs"
                            int right = middle;
#line 292 "GeometryModule.cs"
                            int position = start;
#line 293 "GeometryModule.cs"
                            while (true)
                            {
#line 293 "GeometryModule.cs"
                                bool csharp2cuda_temp_6;
#line 293 "GeometryModule.cs"
                                if (((left) < (middle)))
                                {
#line 293 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 293 "GeometryModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 294 "GeometryModule.cs"
                                {
#line 295 "GeometryModule.cs"
                                    double csharp2cuda_temp_7 = (source)[csharp2cuda_i32_mul(2, right)];
#line 295 "GeometryModule.cs"
                                    double csharp2cuda_temp_8 = (source)[csharp2cuda_i32_mul(2, left)];
#line 295 "GeometryModule.cs"
                                    bool csharp2cuda_temp_9;
#line 295 "GeometryModule.cs"
                                    if (!(((csharp2cuda_temp_7) < (csharp2cuda_temp_8))))
                                    {
#line 296 "GeometryModule.cs"
                                        double csharp2cuda_temp_10 = (source)[csharp2cuda_i32_mul(2, right)];
#line 296 "GeometryModule.cs"
                                        double csharp2cuda_temp_11 = (source)[csharp2cuda_i32_mul(2, left)];
#line 296 "GeometryModule.cs"
                                        bool csharp2cuda_temp_12;
#line 296 "GeometryModule.cs"
                                        if (((csharp2cuda_temp_10) == (csharp2cuda_temp_11)))
                                        {
#line 296 "GeometryModule.cs"
                                            double csharp2cuda_temp_13 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
#line 296 "GeometryModule.cs"
                                            double csharp2cuda_temp_14 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
#line 296 "GeometryModule.cs"
                                            csharp2cuda_temp_12 = ((csharp2cuda_temp_13) < (csharp2cuda_temp_14));
                                        }
                                        else
                                        {
#line 296 "GeometryModule.cs"
                                            csharp2cuda_temp_12 = false;
                                        }
#line 295 "GeometryModule.cs"
                                        csharp2cuda_temp_9 = csharp2cuda_temp_12;
                                    }
                                    else
                                    {
#line 295 "GeometryModule.cs"
                                        csharp2cuda_temp_9 = true;
                                    }
#line 295 "GeometryModule.cs"
                                    bool take_right = csharp2cuda_temp_9;
#line 297 "GeometryModule.cs"
                                    int csharp2cuda_temp_15;
#line 297 "GeometryModule.cs"
                                    if (take_right)
                                    {
#line 297 "GeometryModule.cs"
                                        int* csharp2cuda_temp_16 = &(right);
#line 297 "GeometryModule.cs"
                                        csharp2cuda_temp_15 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                    }
                                    else
                                    {
#line 297 "GeometryModule.cs"
                                        int* csharp2cuda_temp_17 = &(left);
#line 297 "GeometryModule.cs"
                                        csharp2cuda_temp_15 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_17));
                                    }
#line 297 "GeometryModule.cs"
                                    int from = csharp2cuda_temp_15;
#line 298 "GeometryModule.cs"
#line 298 "GeometryModule.cs"
                                    double* csharp2cuda_temp_18 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 298 "GeometryModule.cs"
                                    double csharp2cuda_temp_19 = (source)[csharp2cuda_i32_mul(2, from)];
                                    (*(csharp2cuda_temp_18) = csharp2cuda_temp_19);
#line 299 "GeometryModule.cs"
#line 299 "GeometryModule.cs"
                                    double* csharp2cuda_temp_20 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 299 "GeometryModule.cs"
                                    double csharp2cuda_temp_21 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, from), 1)];
                                    (*(csharp2cuda_temp_20) = csharp2cuda_temp_21);
#line 300 "GeometryModule.cs"
#line 300 "GeometryModule.cs"
                                    int* csharp2cuda_temp_22 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_22));
                                }
                            }
#line 302 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 303 "GeometryModule.cs"
                                {
#line 304 "GeometryModule.cs"
#line 304 "GeometryModule.cs"
                                    double* csharp2cuda_temp_23 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 304 "GeometryModule.cs"
                                    double csharp2cuda_temp_24 = (source)[csharp2cuda_i32_mul(2, left)];
                                    (*(csharp2cuda_temp_23) = csharp2cuda_temp_24);
#line 305 "GeometryModule.cs"
#line 305 "GeometryModule.cs"
                                    double* csharp2cuda_temp_25 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 305 "GeometryModule.cs"
                                    double csharp2cuda_temp_26 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, left), 1)];
                                    (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 306 "GeometryModule.cs"
#line 306 "GeometryModule.cs"
                                    int* csharp2cuda_temp_27 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 307 "GeometryModule.cs"
#line 307 "GeometryModule.cs"
                                    int* csharp2cuda_temp_28 = &(left);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_28));
                                }
                            }
#line 309 "GeometryModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 310 "GeometryModule.cs"
                                {
#line 311 "GeometryModule.cs"
#line 311 "GeometryModule.cs"
                                    double* csharp2cuda_temp_29 = &((target)[csharp2cuda_i32_mul(2, position)]);
#line 311 "GeometryModule.cs"
                                    double csharp2cuda_temp_30 = (source)[csharp2cuda_i32_mul(2, right)];
                                    (*(csharp2cuda_temp_29) = csharp2cuda_temp_30);
#line 312 "GeometryModule.cs"
#line 312 "GeometryModule.cs"
                                    double* csharp2cuda_temp_31 = &((target)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, position), 1)]);
#line 312 "GeometryModule.cs"
                                    double csharp2cuda_temp_32 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, right), 1)];
                                    (*(csharp2cuda_temp_31) = csharp2cuda_temp_32);
#line 313 "GeometryModule.cs"
#line 313 "GeometryModule.cs"
                                    int* csharp2cuda_temp_33 = &(position);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_33));
#line 314 "GeometryModule.cs"
#line 314 "GeometryModule.cs"
                                    int* csharp2cuda_temp_34 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_34));
                                }
                            }
                        }
#line 286 "GeometryModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 286 "GeometryModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 317 "GeometryModule.cs"
                double* sorted = target;
#line 318 "GeometryModule.cs"
#line 318 "GeometryModule.cs"
                double** csharp2cuda_temp_35 = &(target);
                (*(csharp2cuda_temp_35) = source);
#line 319 "GeometryModule.cs"
#line 319 "GeometryModule.cs"
                double** csharp2cuda_temp_36 = &(source);
                (*(csharp2cuda_temp_36) = sorted);
            }
#line 284 "GeometryModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 284 "GeometryModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 321 "GeometryModule.cs"
    if (((((void*)(source))) != (((void*)(points)))))
    {
#line 322 "GeometryModule.cs"
        {
#line 322 "GeometryModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (csharp2cuda_i32_mul(2, count)))))
                    break;
#line 323 "GeometryModule.cs"
#line 323 "GeometryModule.cs"
                double* csharp2cuda_temp_38 = &((points)[index]);
#line 323 "GeometryModule.cs"
                double csharp2cuda_temp_39 = (source)[index];
                (*(csharp2cuda_temp_38) = csharp2cuda_temp_39);
#line 322 "GeometryModule.cs"
                int* csharp2cuda_temp_37 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_37));
            }
        }
    }
}

#line 174 "GeometryModule.cs"
__device__ bool mathblocks_geometry_try_circumcircle(
    const double* points,
    int first,
    int second,
    int third,
    double* center_x,
    double* center_y,
    double* radius_square)
#line 183 "GeometryModule.cs"
{
#line 184 "GeometryModule.cs"
    double first_x = (points)[csharp2cuda_i32_mul(2, first)];
#line 185 "GeometryModule.cs"
    double first_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, first), 1)];
#line 186 "GeometryModule.cs"
    double second_x = (points)[csharp2cuda_i32_mul(2, second)];
#line 187 "GeometryModule.cs"
    double second_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, second), 1)];
#line 188 "GeometryModule.cs"
    double third_x = (points)[csharp2cuda_i32_mul(2, third)];
#line 189 "GeometryModule.cs"
    double third_y = (points)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, third), 1)];
#line 190 "GeometryModule.cs"
    double denominator = __dmul_rn(2.0, __dadd_rn(__dadd_rn(__dmul_rn(first_x, __dsub_rn(second_y, third_y)), __dmul_rn(second_x, __dsub_rn(third_y, first_y))), __dmul_rn(third_x, __dsub_rn(first_y, second_y))));
#line 193 "GeometryModule.cs"
    if (((denominator) == (0.0)))
#line 194 "GeometryModule.cs"
    {
#line 195 "GeometryModule.cs"
#line 195 "GeometryModule.cs"
        double* csharp2cuda_temp_0 = center_x;
        (*(csharp2cuda_temp_0) = 0.0);
#line 196 "GeometryModule.cs"
#line 196 "GeometryModule.cs"
        double* csharp2cuda_temp_1 = center_y;
        (*(csharp2cuda_temp_1) = 0.0);
#line 197 "GeometryModule.cs"
#line 197 "GeometryModule.cs"
        double* csharp2cuda_temp_2 = radius_square;
        (*(csharp2cuda_temp_2) = 0.0);
#line 198 "GeometryModule.cs"
        return false;
    }
#line 200 "GeometryModule.cs"
    double first_square = __dadd_rn(__dmul_rn(first_x, first_x), __dmul_rn(first_y, first_y));
#line 201 "GeometryModule.cs"
    double second_square = __dadd_rn(__dmul_rn(second_x, second_x), __dmul_rn(second_y, second_y));
#line 202 "GeometryModule.cs"
    double third_square = __dadd_rn(__dmul_rn(third_x, third_x), __dmul_rn(third_y, third_y));
#line 203 "GeometryModule.cs"
#line 203 "GeometryModule.cs"
    double* csharp2cuda_temp_3 = center_x;
#line 203 "GeometryModule.cs"
    double csharp2cuda_temp_4 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(second_y, third_y)), __dmul_rn(second_square, __dsub_rn(third_y, first_y))), __dmul_rn(third_square, __dsub_rn(first_y, second_y))), denominator);
    (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 206 "GeometryModule.cs"
#line 206 "GeometryModule.cs"
    double* csharp2cuda_temp_5 = center_y;
#line 206 "GeometryModule.cs"
    double csharp2cuda_temp_6 = __ddiv_rn(__dadd_rn(__dadd_rn(__dmul_rn(first_square, __dsub_rn(third_x, second_x)), __dmul_rn(second_square, __dsub_rn(first_x, third_x))), __dmul_rn(third_square, __dsub_rn(second_x, first_x))), denominator);
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 209 "GeometryModule.cs"
    double csharp2cuda_temp_7 = *(center_x);
#line 209 "GeometryModule.cs"
    double x = __dsub_rn(first_x, csharp2cuda_temp_7);
#line 210 "GeometryModule.cs"
    double csharp2cuda_temp_8 = *(center_y);
#line 210 "GeometryModule.cs"
    double y = __dsub_rn(first_y, csharp2cuda_temp_8);
#line 211 "GeometryModule.cs"
#line 211 "GeometryModule.cs"
    double* csharp2cuda_temp_9 = radius_square;
    (*(csharp2cuda_temp_9) = __dadd_rn(__dmul_rn(x, x), __dmul_rn(y, y)));
#line 212 "GeometryModule.cs"
    return true;
}