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

struct MathBlockGraphKernelEdge;

#line 55 "GraphModule.cs"
struct MathBlockGraphKernelEdge
{
    int from;
    int to;
    double weight;
};

#line 99 "GraphModule.cs"
__device__ int mathblocks_graph_component_count(
    const MathBlockGraphKernelEdge* edges,
    int edge_count,
    int vertex_count,
    int* visited,
    int* queue);

#line 166 "GraphModule.cs"
__device__ void mathblocks_graph_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 139 "GraphModule.cs"
__device__ bool mathblocks_graph_edge_less(
    const MathBlockGraphKernelEdge* left,
    const MathBlockGraphKernelEdge* right);

#line 155 "GraphModule.cs"
__device__ int mathblocks_graph_find(int* parent, int vertex);

#line 64 "GraphModule.cs"
__device__ void mathblocks_graph_sort_edges(MathBlockGraphKernelEdge* edges, MathBlockGraphKernelEdge* buffer, int count);

#line 99 "GraphModule.cs"
__device__ int mathblocks_graph_component_count(
    const MathBlockGraphKernelEdge* edges,
    int edge_count,
    int vertex_count,
    int* visited,
    int* queue)
#line 106 "GraphModule.cs"
{
#line 107 "GraphModule.cs"
    {
#line 107 "GraphModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (vertex_count))))
                break;
#line 108 "GraphModule.cs"
#line 108 "GraphModule.cs"
            int* csharp2cuda_temp_1 = &((visited)[index]);
            (*(csharp2cuda_temp_1) = 0);
#line 107 "GraphModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 109 "GraphModule.cs"
    int components = 0;
#line 110 "GraphModule.cs"
    {
#line 110 "GraphModule.cs"
        int start = 0;
        while (true)
        {
            if (!(((start) < (vertex_count))))
                break;
#line 111 "GraphModule.cs"
            {
#line 112 "GraphModule.cs"
#line 112 "GraphModule.cs"
                int csharp2cuda_temp_3 = (visited)[start];
                if (((csharp2cuda_temp_3) != 0))
                {
#line 113 "GraphModule.cs"
                    goto csharp2cuda_for_continue_2;
                }
#line 114 "GraphModule.cs"
#line 114 "GraphModule.cs"
                int* csharp2cuda_temp_4 = &(components);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
#line 115 "GraphModule.cs"
                int head = 0;
#line 116 "GraphModule.cs"
                int tail = 0;
#line 117 "GraphModule.cs"
#line 117 "GraphModule.cs"
                int* csharp2cuda_temp_5 = &(tail);
#line 117 "GraphModule.cs"
                int csharp2cuda_temp_6 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
#line 117 "GraphModule.cs"
                int* csharp2cuda_temp_7 = &((queue)[csharp2cuda_temp_6]);
                (*(csharp2cuda_temp_7) = start);
#line 118 "GraphModule.cs"
#line 118 "GraphModule.cs"
                int* csharp2cuda_temp_8 = &((visited)[start]);
                (*(csharp2cuda_temp_8) = 1);
#line 119 "GraphModule.cs"
                while (true)
                {
                    if (!(((head) < (tail))))
                        break;
#line 120 "GraphModule.cs"
                    {
#line 121 "GraphModule.cs"
                        int* csharp2cuda_temp_9 = &(head);
#line 121 "GraphModule.cs"
                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 121 "GraphModule.cs"
                        int vertex = (queue)[csharp2cuda_temp_10];
#line 122 "GraphModule.cs"
                        {
#line 122 "GraphModule.cs"
                            int edge_index = 0;
                            while (true)
                            {
                                if (!(((edge_index) < (edge_count))))
                                    break;
#line 123 "GraphModule.cs"
                                {
#line 124 "GraphModule.cs"
                                    int csharp2cuda_temp_12 = ((edges)[edge_index]).from;
#line 124 "GraphModule.cs"
                                    int csharp2cuda_temp_13;
#line 124 "GraphModule.cs"
                                    if (((csharp2cuda_temp_12) == (vertex)))
                                    {
#line 124 "GraphModule.cs"
                                        csharp2cuda_temp_13 = ((edges)[edge_index]).to;
                                    }
                                    else
                                    {
#line 126 "GraphModule.cs"
                                        int csharp2cuda_temp_14 = ((edges)[edge_index]).to;
#line 126 "GraphModule.cs"
                                        int csharp2cuda_temp_15;
#line 126 "GraphModule.cs"
                                        if (((csharp2cuda_temp_14) == (vertex)))
                                        {
#line 126 "GraphModule.cs"
                                            csharp2cuda_temp_15 = ((edges)[edge_index]).from;
                                        }
                                        else
                                        {
#line 126 "GraphModule.cs"
                                            csharp2cuda_temp_15 = csharp2cuda_i32_neg(1);
                                        }
#line 124 "GraphModule.cs"
                                        csharp2cuda_temp_13 = csharp2cuda_temp_15;
                                    }
#line 124 "GraphModule.cs"
                                    int neighbor = csharp2cuda_temp_13;
#line 129 "GraphModule.cs"
#line 129 "GraphModule.cs"
                                    bool csharp2cuda_temp_16;
#line 129 "GraphModule.cs"
                                    if (!(((neighbor) < (0))))
                                    {
#line 129 "GraphModule.cs"
                                        int csharp2cuda_temp_17 = (visited)[neighbor];
#line 129 "GraphModule.cs"
                                        csharp2cuda_temp_16 = ((csharp2cuda_temp_17) != 0);
                                    }
                                    else
                                    {
#line 129 "GraphModule.cs"
                                        csharp2cuda_temp_16 = true;
                                    }
                                    if (csharp2cuda_temp_16)
                                    {
#line 130 "GraphModule.cs"
                                        goto csharp2cuda_for_continue_1;
                                    }
#line 131 "GraphModule.cs"
#line 131 "GraphModule.cs"
                                    int* csharp2cuda_temp_18 = &((visited)[neighbor]);
                                    (*(csharp2cuda_temp_18) = 1);
#line 132 "GraphModule.cs"
#line 132 "GraphModule.cs"
                                    int* csharp2cuda_temp_19 = &(tail);
#line 132 "GraphModule.cs"
                                    int csharp2cuda_temp_20 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_19));
#line 132 "GraphModule.cs"
                                    int* csharp2cuda_temp_21 = &((queue)[csharp2cuda_temp_20]);
                                    (*(csharp2cuda_temp_21) = neighbor);
                                }
                                csharp2cuda_for_continue_1:
#line 122 "GraphModule.cs"
                                int* csharp2cuda_temp_11 = &(edge_index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
                            }
                        }
                    }
                }
            }
            csharp2cuda_for_continue_2:
#line 110 "GraphModule.cs"
            int* csharp2cuda_temp_2 = &(start);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 136 "GraphModule.cs"
    return components;
}

#line 166 "GraphModule.cs"
__device__ void mathblocks_graph_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 172 "GraphModule.cs"
{
#line 173 "GraphModule.cs"
    int thread = threadIdx.x;
#line 174 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 174 "GraphModule.cs"
    if (((input_count) > (0)))
    {
#line 174 "GraphModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 174 "GraphModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 174 "GraphModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 175 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 175 "GraphModule.cs"
    if (((input_count) > (1)))
    {
#line 175 "GraphModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 175 "GraphModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 175 "GraphModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 176 "GraphModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 176 "GraphModule.cs"
    if (((input_count) > (2)))
    {
#line 176 "GraphModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 176 "GraphModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 176 "GraphModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 177 "GraphModule.cs"
    if (((thread) == (0)))
#line 178 "GraphModule.cs"
    {
#line 179 "GraphModule.cs"
#line 179 "GraphModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 180 "GraphModule.cs"
#line 180 "GraphModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 181 "GraphModule.cs"
#line 181 "GraphModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 182 "GraphModule.cs"
#line 182 "GraphModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 183 "GraphModule.cs"
#line 183 "GraphModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 184 "GraphModule.cs"
#line 184 "GraphModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 184 "GraphModule.cs"
        bool csharp2cuda_temp_9;
#line 184 "GraphModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 184 "GraphModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 184 "GraphModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 185 "GraphModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 186 "GraphModule.cs"
#line 186 "GraphModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 186 "GraphModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 186 "GraphModule.cs"
            bool csharp2cuda_temp_12;
#line 186 "GraphModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 186 "GraphModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 186 "GraphModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 187 "GraphModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 188 "GraphModule.cs"
#line 188 "GraphModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 188 "GraphModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 188 "GraphModule.cs"
            bool csharp2cuda_temp_15;
#line 188 "GraphModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 188 "GraphModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 188 "GraphModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 190 "GraphModule.cs"
    __syncthreads();
#line 191 "GraphModule.cs"
#line 191 "GraphModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 192 "GraphModule.cs"
        return;
    }
#line 195 "GraphModule.cs"
    MathBlockGraphKernelEdge* csharp2cuda_temp_17;
#line 195 "GraphModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 195 "GraphModule.cs"
        csharp2cuda_temp_17 = ((MathBlockGraphKernelEdge*)(nullptr));
    }
    else
    {
#line 195 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 195 "GraphModule.cs"
        csharp2cuda_temp_17 = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_18));
    }
#line 194 "GraphModule.cs"
    const MathBlockGraphKernelEdge* edges = csharp2cuda_temp_17;
#line 196 "GraphModule.cs"
    double* csharp2cuda_temp_19;
#line 196 "GraphModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 196 "GraphModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 196 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_20 = (first)->data_pointer;
#line 196 "GraphModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 196 "GraphModule.cs"
    const double* matrix = csharp2cuda_temp_19;
#line 197 "GraphModule.cs"
    int* csharp2cuda_temp_21;
#line 197 "GraphModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 197 "GraphModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 197 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_22 = (second)->data_pointer;
#line 197 "GraphModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 197 "GraphModule.cs"
    const int* boolean_values = csharp2cuda_temp_21;
#line 198 "GraphModule.cs"
    double* csharp2cuda_temp_23;
#line 198 "GraphModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 198 "GraphModule.cs"
        csharp2cuda_temp_23 = ((double*)(nullptr));
    }
    else
    {
#line 198 "GraphModule.cs"
        unsigned long long csharp2cuda_temp_24 = (second)->data_pointer;
#line 198 "GraphModule.cs"
        csharp2cuda_temp_23 = ((double*)(csharp2cuda_temp_24));
    }
#line 198 "GraphModule.cs"
    const double* vector = csharp2cuda_temp_23;
#line 199 "GraphModule.cs"
    unsigned long long csharp2cuda_temp_25 = (output)->data_pointer;
#line 199 "GraphModule.cs"
    double* result = ((double*)(csharp2cuda_temp_25));
#line 200 "GraphModule.cs"
    unsigned long long csharp2cuda_temp_26 = (output)->scratch_pointer;
#line 200 "GraphModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_26));
#line 202 "GraphModule.cs"
    if (((thread) == (0)))
#line 203 "GraphModule.cs"
    {
#line 204 "GraphModule.cs"
        int vertex_count = (first)->rows;
#line 205 "GraphModule.cs"
        switch (opcode)
        {
#line 207 "GraphModule.cs"
            case 0:
#line 208 "GraphModule.cs"
                if (((vertex_count) <= (1)))
#line 209 "GraphModule.cs"
                {
#line 210 "GraphModule.cs"
#line 210 "GraphModule.cs"
                    double* csharp2cuda_temp_27 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_27) = 0.0);
#line 211 "GraphModule.cs"
                    break;
                }
#line 213 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 214 "GraphModule.cs"
                {
#line 215 "GraphModule.cs"
#line 215 "GraphModule.cs"
                    int* csharp2cuda_temp_28 = &((output)->valid);
                    (*(csharp2cuda_temp_28) = 0);
#line 216 "GraphModule.cs"
                    break;
                }
#line 218 "GraphModule.cs"
                {
#line 219 "GraphModule.cs"
                    double* laplacian = scratch;
#line 220 "GraphModule.cs"
                    double* work = csharp2cuda_pointer_add(laplacian, csharp2cuda_i32_mul(vertex_count, vertex_count));
#line 221 "GraphModule.cs"
                    double* eigenvalues = csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(vertex_count, vertex_count));
#line 222 "GraphModule.cs"
                    {
#line 222 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                                break;
#line 223 "GraphModule.cs"
#line 223 "GraphModule.cs"
                            double* csharp2cuda_temp_30 = &((laplacian)[index]);
                            (*(csharp2cuda_temp_30) = 0.0);
#line 222 "GraphModule.cs"
                            int* csharp2cuda_temp_29 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
                        }
                    }
#line 224 "GraphModule.cs"
                    {
#line 224 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 224 "GraphModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 225 "GraphModule.cs"
                            {
#line 226 "GraphModule.cs"
                                int from = ((edges)[index]).from;
#line 227 "GraphModule.cs"
                                int to = ((edges)[index]).to;
#line 228 "GraphModule.cs"
                                double weight = ((edges)[index]).weight;
#line 229 "GraphModule.cs"
#line 229 "GraphModule.cs"
                                double* csharp2cuda_temp_33 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), from)]);
#line 229 "GraphModule.cs"
                                double csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
                                (*(csharp2cuda_temp_33) = __dadd_rn(csharp2cuda_temp_34, weight));
#line 230 "GraphModule.cs"
#line 230 "GraphModule.cs"
                                double* csharp2cuda_temp_35 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), to)]);
#line 230 "GraphModule.cs"
                                double csharp2cuda_temp_36 = *(csharp2cuda_temp_35);
                                (*(csharp2cuda_temp_35) = __dadd_rn(csharp2cuda_temp_36, weight));
#line 231 "GraphModule.cs"
#line 231 "GraphModule.cs"
                                double* csharp2cuda_temp_37 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 231 "GraphModule.cs"
                                double csharp2cuda_temp_38 = *(csharp2cuda_temp_37);
                                (*(csharp2cuda_temp_37) = __dsub_rn(csharp2cuda_temp_38, weight));
#line 232 "GraphModule.cs"
#line 232 "GraphModule.cs"
                                double* csharp2cuda_temp_39 = &((laplacian)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 232 "GraphModule.cs"
                                double csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
                                (*(csharp2cuda_temp_39) = __dsub_rn(csharp2cuda_temp_40, weight));
                            }
#line 224 "GraphModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 234 "GraphModule.cs"
                    bool converged = mathblocks_matrix_symmetric_eigenvalues(laplacian, vertex_count, work, eigenvalues, csharp2cuda_pointer_add(eigenvalues, vertex_count));
#line 240 "GraphModule.cs"
                    if ((!(converged)))
#line 241 "GraphModule.cs"
                    {
#line 242 "GraphModule.cs"
                        mathblocks_nonconvergence_record_graph(opcode);
#line 243 "GraphModule.cs"
                        if (((mathblocks_limit_jacobi_policy()) == (1)))
#line 244 "GraphModule.cs"
                        {
#line 245 "GraphModule.cs"
#line 245 "GraphModule.cs"
                            int* csharp2cuda_temp_41 = &((output)->valid);
                            (*(csharp2cuda_temp_41) = 0);
#line 246 "GraphModule.cs"
                            break;
                        }
                    }
#line 249 "GraphModule.cs"
#line 249 "GraphModule.cs"
                    double* csharp2cuda_temp_42 = &((output)->scalar_value);
#line 249 "GraphModule.cs"
                    double csharp2cuda_temp_43 = (eigenvalues)[1];
                    (*(csharp2cuda_temp_42) = csharp2cuda_temp_43);
#line 250 "GraphModule.cs"
                    break;
                }
#line 252 "GraphModule.cs"
            case 1:
#line 253 "GraphModule.cs"
#line 253 "GraphModule.cs"
                int csharp2cuda_temp_44 = (second)->count;
                if (((csharp2cuda_temp_44) != (vertex_count)))
#line 254 "GraphModule.cs"
                {
#line 255 "GraphModule.cs"
#line 255 "GraphModule.cs"
                    int* csharp2cuda_temp_45 = &((output)->valid);
                    (*(csharp2cuda_temp_45) = 0);
#line 256 "GraphModule.cs"
                    break;
                }
#line 258 "GraphModule.cs"
                {
#line 259 "GraphModule.cs"
                    bool all = true;
#line 260 "GraphModule.cs"
                    bool none = true;
#line 261 "GraphModule.cs"
                    {
#line 261 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 261 "GraphModule.cs"
                            int csharp2cuda_temp_47 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_47))))
                                break;
#line 262 "GraphModule.cs"
                            {
#line 263 "GraphModule.cs"
#line 263 "GraphModule.cs"
                                bool* csharp2cuda_temp_48 = &(all);
#line 263 "GraphModule.cs"
                                bool csharp2cuda_temp_49;
#line 263 "GraphModule.cs"
                                if (all)
                                {
#line 263 "GraphModule.cs"
                                    int csharp2cuda_temp_50 = (boolean_values)[index];
#line 263 "GraphModule.cs"
                                    csharp2cuda_temp_49 = ((csharp2cuda_temp_50) != (0));
                                }
                                else
                                {
#line 263 "GraphModule.cs"
                                    csharp2cuda_temp_49 = false;
                                }
                                (*(csharp2cuda_temp_48) = csharp2cuda_temp_49);
#line 264 "GraphModule.cs"
#line 264 "GraphModule.cs"
                                bool* csharp2cuda_temp_51 = &(none);
#line 264 "GraphModule.cs"
                                bool csharp2cuda_temp_52;
#line 264 "GraphModule.cs"
                                if (none)
                                {
#line 264 "GraphModule.cs"
                                    int csharp2cuda_temp_53 = (boolean_values)[index];
#line 264 "GraphModule.cs"
                                    csharp2cuda_temp_52 = ((csharp2cuda_temp_53) == (0));
                                }
                                else
                                {
#line 264 "GraphModule.cs"
                                    csharp2cuda_temp_52 = false;
                                }
                                (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
                            }
#line 261 "GraphModule.cs"
                            int* csharp2cuda_temp_46 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_46));
                        }
                    }
#line 266 "GraphModule.cs"
                    double cut = 0.0;
#line 267 "GraphModule.cs"
                    double left_volume = 0.0;
#line 268 "GraphModule.cs"
                    double right_volume = 0.0;
#line 269 "GraphModule.cs"
                    {
#line 269 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 269 "GraphModule.cs"
                            int csharp2cuda_temp_55 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_55))))
                                break;
#line 270 "GraphModule.cs"
                            {
#line 271 "GraphModule.cs"
#line 271 "GraphModule.cs"
                                double csharp2cuda_temp_56 = ((edges)[index]).weight;
                                if (((csharp2cuda_temp_56) < (0.0)))
#line 272 "GraphModule.cs"
                                {
#line 273 "GraphModule.cs"
#line 273 "GraphModule.cs"
                                    int* csharp2cuda_temp_57 = &((output)->valid);
                                    (*(csharp2cuda_temp_57) = 0);
#line 274 "GraphModule.cs"
                                    break;
                                }
#line 276 "GraphModule.cs"
#line 276 "GraphModule.cs"
                                int csharp2cuda_temp_58 = ((edges)[index]).from;
#line 276 "GraphModule.cs"
                                int csharp2cuda_temp_59 = (boolean_values)[csharp2cuda_temp_58];
                                if (((csharp2cuda_temp_59) != 0))
                                {
#line 277 "GraphModule.cs"
#line 277 "GraphModule.cs"
                                    double* csharp2cuda_temp_60 = &(left_volume);
#line 277 "GraphModule.cs"
                                    double csharp2cuda_temp_61 = *(csharp2cuda_temp_60);
#line 277 "GraphModule.cs"
                                    double csharp2cuda_temp_62 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_60) = __dadd_rn(csharp2cuda_temp_61, csharp2cuda_temp_62));
                                }
                                else
                                {
#line 279 "GraphModule.cs"
#line 279 "GraphModule.cs"
                                    double* csharp2cuda_temp_63 = &(right_volume);
#line 279 "GraphModule.cs"
                                    double csharp2cuda_temp_64 = *(csharp2cuda_temp_63);
#line 279 "GraphModule.cs"
                                    double csharp2cuda_temp_65 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_63) = __dadd_rn(csharp2cuda_temp_64, csharp2cuda_temp_65));
                                }
#line 280 "GraphModule.cs"
#line 280 "GraphModule.cs"
                                int csharp2cuda_temp_66 = ((edges)[index]).to;
#line 280 "GraphModule.cs"
                                int csharp2cuda_temp_67 = (boolean_values)[csharp2cuda_temp_66];
                                if (((csharp2cuda_temp_67) != 0))
                                {
#line 281 "GraphModule.cs"
#line 281 "GraphModule.cs"
                                    double* csharp2cuda_temp_68 = &(left_volume);
#line 281 "GraphModule.cs"
                                    double csharp2cuda_temp_69 = *(csharp2cuda_temp_68);
#line 281 "GraphModule.cs"
                                    double csharp2cuda_temp_70 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_68) = __dadd_rn(csharp2cuda_temp_69, csharp2cuda_temp_70));
                                }
                                else
                                {
#line 283 "GraphModule.cs"
#line 283 "GraphModule.cs"
                                    double* csharp2cuda_temp_71 = &(right_volume);
#line 283 "GraphModule.cs"
                                    double csharp2cuda_temp_72 = *(csharp2cuda_temp_71);
#line 283 "GraphModule.cs"
                                    double csharp2cuda_temp_73 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_71) = __dadd_rn(csharp2cuda_temp_72, csharp2cuda_temp_73));
                                }
#line 284 "GraphModule.cs"
#line 284 "GraphModule.cs"
                                int csharp2cuda_temp_74 = ((edges)[index]).from;
#line 284 "GraphModule.cs"
                                int csharp2cuda_temp_75 = (boolean_values)[csharp2cuda_temp_74];
#line 284 "GraphModule.cs"
                                int csharp2cuda_temp_76 = ((edges)[index]).to;
#line 284 "GraphModule.cs"
                                int csharp2cuda_temp_77 = (boolean_values)[csharp2cuda_temp_76];
                                if (((csharp2cuda_temp_75) != (csharp2cuda_temp_77)))
                                {
#line 285 "GraphModule.cs"
#line 285 "GraphModule.cs"
                                    double* csharp2cuda_temp_78 = &(cut);
#line 285 "GraphModule.cs"
                                    double csharp2cuda_temp_79 = *(csharp2cuda_temp_78);
#line 285 "GraphModule.cs"
                                    double csharp2cuda_temp_80 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_78) = __dadd_rn(csharp2cuda_temp_79, csharp2cuda_temp_80));
                                }
                            }
#line 269 "GraphModule.cs"
                            int* csharp2cuda_temp_54 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_54));
                        }
                    }
#line 287 "GraphModule.cs"
#line 287 "GraphModule.cs"
                    bool csharp2cuda_temp_81;
#line 287 "GraphModule.cs"
                    if (!(all))
                    {
#line 287 "GraphModule.cs"
                        csharp2cuda_temp_81 = none;
                    }
                    else
                    {
#line 287 "GraphModule.cs"
                        csharp2cuda_temp_81 = true;
                    }
                    if (csharp2cuda_temp_81)
                    {
#line 288 "GraphModule.cs"
#line 288 "GraphModule.cs"
                        int* csharp2cuda_temp_82 = &((output)->valid);
                        (*(csharp2cuda_temp_82) = 0);
                    }
                    else
                    {
#line 290 "GraphModule.cs"
#line 290 "GraphModule.cs"
                        double* csharp2cuda_temp_83 = &((output)->scalar_value);
#line 291 "GraphModule.cs"
                        double csharp2cuda_temp_84;
#line 291 "GraphModule.cs"
                        if (((left_volume) < (right_volume)))
                        {
#line 291 "GraphModule.cs"
                            csharp2cuda_temp_84 = left_volume;
                        }
                        else
                        {
#line 291 "GraphModule.cs"
                            csharp2cuda_temp_84 = right_volume;
                        }
#line 290 "GraphModule.cs"
                        double csharp2cuda_temp_85 = __ddiv_rn(cut, csharp2cuda_temp_84);
                        (*(csharp2cuda_temp_83) = csharp2cuda_temp_85);
                    }
#line 292 "GraphModule.cs"
                    break;
                }
#line 294 "GraphModule.cs"
            case 2:
            case 7:
#line 296 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 297 "GraphModule.cs"
                {
#line 298 "GraphModule.cs"
#line 298 "GraphModule.cs"
                    int* csharp2cuda_temp_86 = &((output)->valid);
                    (*(csharp2cuda_temp_86) = 0);
#line 299 "GraphModule.cs"
                    break;
                }
#line 301 "GraphModule.cs"
                {
#line 302 "GraphModule.cs"
                    int* visited = ((int*)(scratch));
#line 303 "GraphModule.cs"
                    int* queue = csharp2cuda_pointer_add(visited, vertex_count);
#line 306 "GraphModule.cs"
                    int csharp2cuda_temp_87 = (first)->count;
#line 304 "GraphModule.cs"
                    int components = mathblocks_graph_component_count(edges, csharp2cuda_temp_87, vertex_count, visited, queue);
#line 310 "GraphModule.cs"
                    if (((opcode) == (2)))
                    {
#line 311 "GraphModule.cs"
#line 311 "GraphModule.cs"
                        double* csharp2cuda_temp_88 = &((output)->scalar_value);
                        (*(csharp2cuda_temp_88) = ((double)(components)));
                    }
                    else
                    {
#line 313 "GraphModule.cs"
#line 313 "GraphModule.cs"
                        int* csharp2cuda_temp_89 = &((output)->boolean_value);
#line 313 "GraphModule.cs"
                        int csharp2cuda_temp_90;
#line 313 "GraphModule.cs"
                        if (((components) == (1)))
                        {
#line 313 "GraphModule.cs"
                            csharp2cuda_temp_90 = 1;
                        }
                        else
                        {
#line 313 "GraphModule.cs"
                            csharp2cuda_temp_90 = 0;
                        }
                        (*(csharp2cuda_temp_89) = csharp2cuda_temp_90);
                    }
#line 314 "GraphModule.cs"
                    break;
                }
#line 316 "GraphModule.cs"
            case 3:
            case 15:
#line 318 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 319 "GraphModule.cs"
                {
#line 319 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (vertex_count))))
                            break;
#line 320 "GraphModule.cs"
#line 320 "GraphModule.cs"
                        double* csharp2cuda_temp_92 = &((result)[index]);
                        (*(csharp2cuda_temp_92) = 0.0);
#line 319 "GraphModule.cs"
                        int* csharp2cuda_temp_91 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_91));
                    }
                }
#line 321 "GraphModule.cs"
                {
#line 321 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 321 "GraphModule.cs"
                        int csharp2cuda_temp_94 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_94))))
                            break;
#line 322 "GraphModule.cs"
                        {
#line 323 "GraphModule.cs"
                            double csharp2cuda_temp_95;
#line 323 "GraphModule.cs"
                            if (((opcode) == (3)))
                            {
#line 323 "GraphModule.cs"
                                csharp2cuda_temp_95 = 1.0;
                            }
                            else
                            {
#line 323 "GraphModule.cs"
                                csharp2cuda_temp_95 = ((edges)[index]).weight;
                            }
#line 323 "GraphModule.cs"
                            double amount = csharp2cuda_temp_95;
#line 324 "GraphModule.cs"
#line 324 "GraphModule.cs"
                            int csharp2cuda_temp_96 = ((edges)[index]).from;
#line 324 "GraphModule.cs"
                            double* csharp2cuda_temp_97 = &((result)[csharp2cuda_temp_96]);
#line 324 "GraphModule.cs"
                            double csharp2cuda_temp_98 = *(csharp2cuda_temp_97);
                            (*(csharp2cuda_temp_97) = __dadd_rn(csharp2cuda_temp_98, amount));
#line 325 "GraphModule.cs"
#line 325 "GraphModule.cs"
                            int csharp2cuda_temp_99 = ((edges)[index]).to;
#line 325 "GraphModule.cs"
                            double* csharp2cuda_temp_100 = &((result)[csharp2cuda_temp_99]);
#line 325 "GraphModule.cs"
                            double csharp2cuda_temp_101 = *(csharp2cuda_temp_100);
                            (*(csharp2cuda_temp_100) = __dadd_rn(csharp2cuda_temp_101, amount));
                        }
#line 321 "GraphModule.cs"
                        int* csharp2cuda_temp_93 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_93));
                    }
                }
#line 327 "GraphModule.cs"
                break;
#line 328 "GraphModule.cs"
            case 4:
#line 329 "GraphModule.cs"
#line 329 "GraphModule.cs"
                int csharp2cuda_temp_102 = (first)->rows;
#line 329 "GraphModule.cs"
                int csharp2cuda_temp_103 = (first)->columns;
                if (((csharp2cuda_temp_102) != (csharp2cuda_temp_103)))
#line 330 "GraphModule.cs"
                {
#line 331 "GraphModule.cs"
#line 331 "GraphModule.cs"
                    int* csharp2cuda_temp_104 = &((output)->valid);
                    (*(csharp2cuda_temp_104) = 0);
#line 332 "GraphModule.cs"
                    break;
                }
#line 334 "GraphModule.cs"
                {
#line 336 "GraphModule.cs"
                    unsigned long long csharp2cuda_temp_105 = (output)->data_pointer;
#line 335 "GraphModule.cs"
                    MathBlockGraphKernelEdge* graph = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_105));
#line 337 "GraphModule.cs"
                    int edge_count = 0;
#line 338 "GraphModule.cs"
                    {
#line 338 "GraphModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 338 "GraphModule.cs"
                            int csharp2cuda_temp_107 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_107))))
                                break;
#line 339 "GraphModule.cs"
                            {
#line 339 "GraphModule.cs"
                                int column = 0;
                                while (true)
                                {
#line 339 "GraphModule.cs"
                                    int csharp2cuda_temp_109 = (first)->columns;
                                    if (!(((column) < (csharp2cuda_temp_109))))
                                        break;
#line 340 "GraphModule.cs"
#line 340 "GraphModule.cs"
                                    bool csharp2cuda_temp_110;
#line 340 "GraphModule.cs"
                                    if (((row) != (column)))
                                    {
#line 340 "GraphModule.cs"
                                        int csharp2cuda_temp_111 = (first)->columns;
#line 340 "GraphModule.cs"
                                        double csharp2cuda_temp_112 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_111), column)];
#line 340 "GraphModule.cs"
                                        csharp2cuda_temp_110 = ((csharp2cuda_temp_112) != (0.0));
                                    }
                                    else
                                    {
#line 340 "GraphModule.cs"
                                        csharp2cuda_temp_110 = false;
                                    }
                                    if (csharp2cuda_temp_110)
#line 341 "GraphModule.cs"
                                    {
#line 342 "GraphModule.cs"
#line 342 "GraphModule.cs"
                                        int csharp2cuda_temp_113 = (output)->capacity;
                                        if (((edge_count) >= (csharp2cuda_temp_113)))
#line 343 "GraphModule.cs"
                                        {
#line 344 "GraphModule.cs"
#line 344 "GraphModule.cs"
                                            int* csharp2cuda_temp_114 = &((output)->count);
#line 344 "GraphModule.cs"
                                            int csharp2cuda_temp_115 = (output)->capacity;
#line 344 "GraphModule.cs"
                                            int csharp2cuda_temp_116;
#line 344 "GraphModule.cs"
                                            if (((csharp2cuda_temp_115) == (2147483647)))
                                            {
#line 344 "GraphModule.cs"
                                                csharp2cuda_temp_116 = csharp2cuda_i32_neg(1);
                                            }
                                            else
                                            {
#line 346 "GraphModule.cs"
                                                int csharp2cuda_temp_117 = (output)->capacity;
#line 344 "GraphModule.cs"
                                                csharp2cuda_temp_116 = csharp2cuda_i32_add(csharp2cuda_temp_117, 1);
                                            }
                                            (*(csharp2cuda_temp_114) = csharp2cuda_temp_116);
#line 347 "GraphModule.cs"
#line 347 "GraphModule.cs"
                                            int* csharp2cuda_temp_118 = &((output)->valid);
                                            (*(csharp2cuda_temp_118) = 0);
#line 348 "GraphModule.cs"
                                            break;
                                        }
#line 350 "GraphModule.cs"
#line 350 "GraphModule.cs"
                                        int* csharp2cuda_temp_119 = &(((graph)[edge_count]).from);
                                        (*(csharp2cuda_temp_119) = row);
#line 351 "GraphModule.cs"
#line 351 "GraphModule.cs"
                                        int* csharp2cuda_temp_120 = &(((graph)[edge_count]).to);
                                        (*(csharp2cuda_temp_120) = column);
#line 352 "GraphModule.cs"
#line 352 "GraphModule.cs"
                                        double* csharp2cuda_temp_121 = &(((graph)[edge_count]).weight);
#line 352 "GraphModule.cs"
                                        int csharp2cuda_temp_122 = (first)->columns;
#line 352 "GraphModule.cs"
                                        double csharp2cuda_temp_123 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_122), column)];
                                        (*(csharp2cuda_temp_121) = csharp2cuda_temp_123);
#line 353 "GraphModule.cs"
#line 353 "GraphModule.cs"
                                        int* csharp2cuda_temp_124 = &(edge_count);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_124));
                                    }
#line 339 "GraphModule.cs"
                                    int* csharp2cuda_temp_108 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_108));
                                }
                            }
#line 338 "GraphModule.cs"
                            int* csharp2cuda_temp_106 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_106));
                        }
                    }
#line 355 "GraphModule.cs"
#line 355 "GraphModule.cs"
                    int* csharp2cuda_temp_125 = &((output)->rows);
#line 355 "GraphModule.cs"
                    int csharp2cuda_temp_126 = (first)->rows;
                    (*(csharp2cuda_temp_125) = csharp2cuda_temp_126);
#line 356 "GraphModule.cs"
                    if ((output)->valid)
                    {
#line 357 "GraphModule.cs"
#line 357 "GraphModule.cs"
                        int* csharp2cuda_temp_127 = &((output)->count);
                        (*(csharp2cuda_temp_127) = edge_count);
                    }
#line 358 "GraphModule.cs"
                    break;
                }
#line 360 "GraphModule.cs"
            case 5:
#line 361 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 362 "GraphModule.cs"
#line 362 "GraphModule.cs"
                bool csharp2cuda_temp_128;
#line 362 "GraphModule.cs"
                if (!(((vertex_count) <= (0))))
                {
#line 362 "GraphModule.cs"
                    csharp2cuda_temp_128 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 362 "GraphModule.cs"
                    csharp2cuda_temp_128 = true;
                }
                if (csharp2cuda_temp_128)
#line 363 "GraphModule.cs"
                {
#line 364 "GraphModule.cs"
#line 364 "GraphModule.cs"
                    int* csharp2cuda_temp_129 = &((output)->valid);
                    (*(csharp2cuda_temp_129) = 0);
#line 365 "GraphModule.cs"
                    break;
                }
#line 367 "GraphModule.cs"
#line 367 "GraphModule.cs"
                double* csharp2cuda_temp_130 = &((result)[0]);
                (*(csharp2cuda_temp_130) = 0.0);
#line 368 "GraphModule.cs"
                if (((vertex_count) == (1)))
                {
#line 369 "GraphModule.cs"
                    break;
                }
#line 370 "GraphModule.cs"
                {
#line 371 "GraphModule.cs"
                    int size = csharp2cuda_i32_sub(vertex_count, 1);
#line 372 "GraphModule.cs"
                    double* reduced_matrix = scratch;
#line 373 "GraphModule.cs"
                    double* right = csharp2cuda_pointer_add(reduced_matrix, csharp2cuda_i32_mul(size, size));
#line 374 "GraphModule.cs"
                    double* augmented = csharp2cuda_pointer_add(right, size);
#line 375 "GraphModule.cs"
                    {
#line 375 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(size, size)))))
                                break;
#line 376 "GraphModule.cs"
#line 376 "GraphModule.cs"
                            double* csharp2cuda_temp_132 = &((reduced_matrix)[index]);
                            (*(csharp2cuda_temp_132) = 0.0);
#line 375 "GraphModule.cs"
                            int* csharp2cuda_temp_131 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_131));
                        }
                    }
#line 377 "GraphModule.cs"
                    {
#line 377 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (size))))
                                break;
#line 378 "GraphModule.cs"
#line 378 "GraphModule.cs"
                            double* csharp2cuda_temp_134 = &((right)[index]);
                            (*(csharp2cuda_temp_134) = 0.0);
#line 377 "GraphModule.cs"
                            int* csharp2cuda_temp_133 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_133));
                        }
                    }
#line 379 "GraphModule.cs"
                    {
#line 379 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 379 "GraphModule.cs"
                            int csharp2cuda_temp_136 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_136))))
                                break;
#line 380 "GraphModule.cs"
                            {
#line 381 "GraphModule.cs"
                                int from = ((edges)[index]).from;
#line 382 "GraphModule.cs"
                                int to = ((edges)[index]).to;
#line 383 "GraphModule.cs"
                                if (((from) != (0)))
#line 384 "GraphModule.cs"
                                {
#line 385 "GraphModule.cs"
#line 385 "GraphModule.cs"
                                    double* csharp2cuda_temp_137 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(from, 1), size), from), 1)]);
#line 385 "GraphModule.cs"
                                    double csharp2cuda_temp_138 = *(csharp2cuda_temp_137);
                                    (*(csharp2cuda_temp_137) = __dadd_rn(csharp2cuda_temp_138, 1.0));
#line 386 "GraphModule.cs"
#line 386 "GraphModule.cs"
                                    double* csharp2cuda_temp_139 = &((right)[csharp2cuda_i32_sub(from, 1)]);
#line 386 "GraphModule.cs"
                                    double csharp2cuda_temp_140 = *(csharp2cuda_temp_139);
#line 386 "GraphModule.cs"
                                    double csharp2cuda_temp_141 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_139) = __dsub_rn(csharp2cuda_temp_140, csharp2cuda_temp_141));
                                }
#line 388 "GraphModule.cs"
                                if (((to) != (0)))
#line 389 "GraphModule.cs"
                                {
#line 390 "GraphModule.cs"
#line 390 "GraphModule.cs"
                                    double* csharp2cuda_temp_142 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(to, 1), size), to), 1)]);
#line 390 "GraphModule.cs"
                                    double csharp2cuda_temp_143 = *(csharp2cuda_temp_142);
                                    (*(csharp2cuda_temp_142) = __dadd_rn(csharp2cuda_temp_143, 1.0));
#line 391 "GraphModule.cs"
#line 391 "GraphModule.cs"
                                    double* csharp2cuda_temp_144 = &((right)[csharp2cuda_i32_sub(to, 1)]);
#line 391 "GraphModule.cs"
                                    double csharp2cuda_temp_145 = *(csharp2cuda_temp_144);
#line 391 "GraphModule.cs"
                                    double csharp2cuda_temp_146 = ((edges)[index]).weight;
                                    (*(csharp2cuda_temp_144) = __dadd_rn(csharp2cuda_temp_145, csharp2cuda_temp_146));
                                }
#line 393 "GraphModule.cs"
#line 393 "GraphModule.cs"
                                bool csharp2cuda_temp_147;
#line 393 "GraphModule.cs"
                                if (((from) != (0)))
                                {
#line 393 "GraphModule.cs"
                                    csharp2cuda_temp_147 = ((to) != (0));
                                }
                                else
                                {
#line 393 "GraphModule.cs"
                                    csharp2cuda_temp_147 = false;
                                }
                                if (csharp2cuda_temp_147)
#line 394 "GraphModule.cs"
                                {
#line 395 "GraphModule.cs"
#line 395 "GraphModule.cs"
                                    double* csharp2cuda_temp_148 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(from, 1), size), to), 1)]);
#line 395 "GraphModule.cs"
                                    double csharp2cuda_temp_149 = *(csharp2cuda_temp_148);
                                    (*(csharp2cuda_temp_148) = __dsub_rn(csharp2cuda_temp_149, 1.0));
#line 396 "GraphModule.cs"
#line 396 "GraphModule.cs"
                                    double* csharp2cuda_temp_150 = &((reduced_matrix)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(to, 1), size), from), 1)]);
#line 396 "GraphModule.cs"
                                    double csharp2cuda_temp_151 = *(csharp2cuda_temp_150);
                                    (*(csharp2cuda_temp_150) = __dsub_rn(csharp2cuda_temp_151, 1.0));
                                }
                            }
#line 379 "GraphModule.cs"
                            int* csharp2cuda_temp_135 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_135));
                        }
                    }
#line 399 "GraphModule.cs"
#line 399 "GraphModule.cs"
                    bool csharp2cuda_temp_152 = mathblocks_matrix_try_solve(reduced_matrix, right, size, augmented, csharp2cuda_pointer_add(result, 1));
                    if ((!(csharp2cuda_temp_152)))
#line 405 "GraphModule.cs"
                    {
#line 406 "GraphModule.cs"
#line 406 "GraphModule.cs"
                        int* csharp2cuda_temp_153 = &((output)->valid);
                        (*(csharp2cuda_temp_153) = 0);
                    }
#line 408 "GraphModule.cs"
                    break;
                }
#line 410 "GraphModule.cs"
            case 6:
#line 411 "GraphModule.cs"
#line 411 "GraphModule.cs"
                int csharp2cuda_temp_154 = (second)->count;
                if (((csharp2cuda_temp_154) != (vertex_count)))
#line 412 "GraphModule.cs"
                {
#line 413 "GraphModule.cs"
#line 413 "GraphModule.cs"
                    int* csharp2cuda_temp_155 = &((output)->valid);
                    (*(csharp2cuda_temp_155) = 0);
#line 414 "GraphModule.cs"
                    break;
                }
#line 416 "GraphModule.cs"
                {
#line 417 "GraphModule.cs"
                    double sum_squares = 0.0;
#line 418 "GraphModule.cs"
                    {
#line 418 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 418 "GraphModule.cs"
                            int csharp2cuda_temp_157 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_157))))
                                break;
#line 419 "GraphModule.cs"
                            {
#line 420 "GraphModule.cs"
                                int csharp2cuda_temp_158 = ((edges)[index]).to;
#line 420 "GraphModule.cs"
                                double csharp2cuda_temp_159 = (vector)[csharp2cuda_temp_158];
#line 421 "GraphModule.cs"
                                int csharp2cuda_temp_160 = ((edges)[index]).from;
#line 421 "GraphModule.cs"
                                double csharp2cuda_temp_161 = (vector)[csharp2cuda_temp_160];
#line 422 "GraphModule.cs"
                                double csharp2cuda_temp_162 = ((edges)[index]).weight;
#line 420 "GraphModule.cs"
                                double residual = __dsub_rn(__dsub_rn(csharp2cuda_temp_159, csharp2cuda_temp_161), csharp2cuda_temp_162);
#line 423 "GraphModule.cs"
#line 423 "GraphModule.cs"
                                double* csharp2cuda_temp_163 = &(sum_squares);
#line 423 "GraphModule.cs"
                                double csharp2cuda_temp_164 = *(csharp2cuda_temp_163);
                                (*(csharp2cuda_temp_163) = __dadd_rn(csharp2cuda_temp_164, __dmul_rn(residual, residual)));
                            }
#line 418 "GraphModule.cs"
                            int* csharp2cuda_temp_156 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_156));
                        }
                    }
#line 425 "GraphModule.cs"
#line 425 "GraphModule.cs"
                    double* csharp2cuda_temp_165 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_165) = mathblocks_square_root(sum_squares));
#line 426 "GraphModule.cs"
                    break;
                }
#line 428 "GraphModule.cs"
            case 8:
#line 429 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 430 "GraphModule.cs"
                {
#line 431 "GraphModule.cs"
#line 431 "GraphModule.cs"
                    int* csharp2cuda_temp_166 = &((output)->valid);
                    (*(csharp2cuda_temp_166) = 0);
#line 432 "GraphModule.cs"
                    break;
                }
#line 434 "GraphModule.cs"
                {
#line 435 "GraphModule.cs"
                    MathBlockGraphKernelEdge* work = ((MathBlockGraphKernelEdge*)(scratch));
#line 436 "GraphModule.cs"
                    {
#line 436 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 436 "GraphModule.cs"
                            int csharp2cuda_temp_168 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_168))))
                                break;
#line 437 "GraphModule.cs"
#line 437 "GraphModule.cs"
                            MathBlockGraphKernelEdge* csharp2cuda_temp_169 = &((work)[index]);
#line 437 "GraphModule.cs"
                            MathBlockGraphKernelEdge csharp2cuda_temp_170 = (edges)[index];
                            (*(csharp2cuda_temp_169) = csharp2cuda_temp_170);
#line 436 "GraphModule.cs"
                            int* csharp2cuda_temp_167 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_167));
                        }
                    }
#line 438 "GraphModule.cs"
#line 438 "GraphModule.cs"
                    int csharp2cuda_temp_171 = (first)->count;
#line 438 "GraphModule.cs"
                    int csharp2cuda_temp_172 = (first)->count;
                    mathblocks_graph_sort_edges(work, csharp2cuda_pointer_add(work, csharp2cuda_temp_171), csharp2cuda_temp_172);
#line 439 "GraphModule.cs"
                    int csharp2cuda_temp_173 = (first)->count;
#line 439 "GraphModule.cs"
                    int* parent = ((int*)(csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(2, csharp2cuda_temp_173))));
#line 440 "GraphModule.cs"
                    unsigned char* rank = ((unsigned char*)(csharp2cuda_pointer_add(parent, vertex_count)));
#line 441 "GraphModule.cs"
                    {
#line 441 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (vertex_count))))
                                break;
#line 442 "GraphModule.cs"
                            {
#line 443 "GraphModule.cs"
#line 443 "GraphModule.cs"
                                int* csharp2cuda_temp_175 = &((parent)[index]);
                                (*(csharp2cuda_temp_175) = index);
#line 444 "GraphModule.cs"
#line 444 "GraphModule.cs"
                                unsigned char* csharp2cuda_temp_176 = &((rank)[index]);
                                (*(csharp2cuda_temp_176) = ((unsigned char)(0)));
                            }
#line 441 "GraphModule.cs"
                            int* csharp2cuda_temp_174 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_174));
                        }
                    }
#line 447 "GraphModule.cs"
                    unsigned long long csharp2cuda_temp_177 = (output)->data_pointer;
#line 446 "GraphModule.cs"
                    MathBlockGraphKernelEdge* selected = ((MathBlockGraphKernelEdge*)(csharp2cuda_temp_177));
#line 448 "GraphModule.cs"
                    int selected_count = 0;
#line 449 "GraphModule.cs"
                    {
#line 449 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 449 "GraphModule.cs"
                            int csharp2cuda_temp_179 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_179))))
                                break;
#line 450 "GraphModule.cs"
                            {
#line 451 "GraphModule.cs"
                                int csharp2cuda_temp_180 = ((work)[index]).from;
#line 451 "GraphModule.cs"
                                int left = mathblocks_graph_find(parent, csharp2cuda_temp_180);
#line 452 "GraphModule.cs"
                                int csharp2cuda_temp_181 = ((work)[index]).to;
#line 452 "GraphModule.cs"
                                int right = mathblocks_graph_find(parent, csharp2cuda_temp_181);
#line 453 "GraphModule.cs"
                                if (((left) == (right)))
                                {
#line 454 "GraphModule.cs"
                                    goto csharp2cuda_for_continue_14;
                                }
#line 455 "GraphModule.cs"
#line 455 "GraphModule.cs"
                                unsigned char csharp2cuda_temp_182 = (rank)[left];
#line 455 "GraphModule.cs"
                                unsigned char csharp2cuda_temp_183 = (rank)[right];
                                if (((((int)(csharp2cuda_temp_182))) < (((int)(csharp2cuda_temp_183)))))
                                {
#line 456 "GraphModule.cs"
#line 456 "GraphModule.cs"
                                    int* csharp2cuda_temp_184 = &((parent)[left]);
                                    (*(csharp2cuda_temp_184) = right);
                                }
                                else
                                {
#line 457 "GraphModule.cs"
#line 457 "GraphModule.cs"
                                    unsigned char csharp2cuda_temp_185 = (rank)[left];
#line 457 "GraphModule.cs"
                                    unsigned char csharp2cuda_temp_186 = (rank)[right];
                                    if (((((int)(csharp2cuda_temp_185))) > (((int)(csharp2cuda_temp_186)))))
                                    {
#line 458 "GraphModule.cs"
#line 458 "GraphModule.cs"
                                        int* csharp2cuda_temp_187 = &((parent)[right]);
                                        (*(csharp2cuda_temp_187) = left);
                                    }
                                    else
#line 460 "GraphModule.cs"
                                    {
#line 461 "GraphModule.cs"
#line 461 "GraphModule.cs"
                                        int* csharp2cuda_temp_188 = &((parent)[right]);
                                        (*(csharp2cuda_temp_188) = left);
#line 462 "GraphModule.cs"
#line 462 "GraphModule.cs"
                                        unsigned char* csharp2cuda_temp_189 = &((rank)[left]);
                                        (*(csharp2cuda_temp_189))++;
                                    }
                                }
#line 464 "GraphModule.cs"
#line 464 "GraphModule.cs"
                                int* csharp2cuda_temp_190 = &(selected_count);
#line 464 "GraphModule.cs"
                                int csharp2cuda_temp_191 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_190));
#line 464 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_192 = &((selected)[csharp2cuda_temp_191]);
#line 464 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_193 = (work)[index];
                                (*(csharp2cuda_temp_192) = csharp2cuda_temp_193);
                            }
                            csharp2cuda_for_continue_14:
#line 449 "GraphModule.cs"
                            int* csharp2cuda_temp_178 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_178));
                        }
                    }
#line 466 "GraphModule.cs"
#line 466 "GraphModule.cs"
                    int* csharp2cuda_temp_194 = &((output)->rows);
                    (*(csharp2cuda_temp_194) = vertex_count);
#line 467 "GraphModule.cs"
#line 467 "GraphModule.cs"
                    int* csharp2cuda_temp_195 = &((output)->count);
                    (*(csharp2cuda_temp_195) = selected_count);
#line 468 "GraphModule.cs"
                    break;
                }
#line 470 "GraphModule.cs"
            case 9:
#line 471 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 472 "GraphModule.cs"
#line 472 "GraphModule.cs"
                bool csharp2cuda_temp_196;
#line 472 "GraphModule.cs"
                if (!(((vertex_count) <= (0))))
                {
#line 472 "GraphModule.cs"
                    csharp2cuda_temp_196 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 472 "GraphModule.cs"
                    csharp2cuda_temp_196 = true;
                }
                if (csharp2cuda_temp_196)
#line 473 "GraphModule.cs"
                {
#line 474 "GraphModule.cs"
#line 474 "GraphModule.cs"
                    int* csharp2cuda_temp_197 = &((output)->valid);
                    (*(csharp2cuda_temp_197) = 0);
#line 475 "GraphModule.cs"
                    break;
                }
#line 477 "GraphModule.cs"
                {
#line 478 "GraphModule.cs"
                    double damping = (second)->scalar_value;
#line 479 "GraphModule.cs"
                    int iterations = 0;
#line 480 "GraphModule.cs"
#line 480 "GraphModule.cs"
                    bool csharp2cuda_temp_198;
#line 480 "GraphModule.cs"
                    if (!(((damping) < (0.0))))
                    {
#line 480 "GraphModule.cs"
                        csharp2cuda_temp_198 = ((damping) > (1.0));
                    }
                    else
                    {
#line 480 "GraphModule.cs"
                        csharp2cuda_temp_198 = true;
                    }
#line 480 "GraphModule.cs"
                    bool csharp2cuda_temp_199;
#line 480 "GraphModule.cs"
                    if (!(csharp2cuda_temp_198))
                    {
#line 481 "GraphModule.cs"
                        double csharp2cuda_temp_200 = (third)->scalar_value;
#line 481 "GraphModule.cs"
                        int* csharp2cuda_temp_201 = &(iterations);
#line 481 "GraphModule.cs"
                        bool csharp2cuda_temp_202 = mathblocks_sequence_positive_integer(csharp2cuda_temp_200, csharp2cuda_temp_201);
#line 480 "GraphModule.cs"
                        csharp2cuda_temp_199 = (!(csharp2cuda_temp_202));
                    }
                    else
                    {
#line 480 "GraphModule.cs"
                        csharp2cuda_temp_199 = true;
                    }
#line 480 "GraphModule.cs"
                    bool csharp2cuda_temp_203;
#line 480 "GraphModule.cs"
                    if (!(csharp2cuda_temp_199))
                    {
#line 480 "GraphModule.cs"
                        csharp2cuda_temp_203 = ((iterations) > (mathblocks_limit_iteration_count()));
                    }
                    else
                    {
#line 480 "GraphModule.cs"
                        csharp2cuda_temp_203 = true;
                    }
                    if (csharp2cuda_temp_203)
#line 483 "GraphModule.cs"
                    {
#line 484 "GraphModule.cs"
#line 484 "GraphModule.cs"
                        int* csharp2cuda_temp_204 = &((output)->valid);
                        (*(csharp2cuda_temp_204) = 0);
#line 485 "GraphModule.cs"
                        break;
                    }
#line 487 "GraphModule.cs"
                    double* outgoing = scratch;
#line 488 "GraphModule.cs"
                    double* next = csharp2cuda_pointer_add(scratch, vertex_count);
#line 489 "GraphModule.cs"
                    {
#line 489 "GraphModule.cs"
                        int vertex = 0;
                        while (true)
                        {
                            if (!(((vertex) < (vertex_count))))
                                break;
#line 490 "GraphModule.cs"
                            {
#line 491 "GraphModule.cs"
#line 491 "GraphModule.cs"
                                double* csharp2cuda_temp_206 = &((result)[vertex]);
#line 491 "GraphModule.cs"
                                double csharp2cuda_temp_207 = __ddiv_rn(1.0, ((double)(vertex_count)));
                                (*(csharp2cuda_temp_206) = csharp2cuda_temp_207);
#line 492 "GraphModule.cs"
#line 492 "GraphModule.cs"
                                double* csharp2cuda_temp_208 = &((outgoing)[vertex]);
                                (*(csharp2cuda_temp_208) = 0.0);
                            }
#line 489 "GraphModule.cs"
                            int* csharp2cuda_temp_205 = &(vertex);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                        }
                    }
#line 494 "GraphModule.cs"
                    {
#line 494 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 494 "GraphModule.cs"
                            int csharp2cuda_temp_210 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_210))))
                                break;
#line 495 "GraphModule.cs"
                            {
#line 496 "GraphModule.cs"
#line 496 "GraphModule.cs"
                                double csharp2cuda_temp_211 = ((edges)[index]).weight;
                                if (((csharp2cuda_temp_211) < (0.0)))
#line 497 "GraphModule.cs"
                                {
#line 498 "GraphModule.cs"
#line 498 "GraphModule.cs"
                                    int* csharp2cuda_temp_212 = &((output)->valid);
                                    (*(csharp2cuda_temp_212) = 0);
#line 499 "GraphModule.cs"
                                    break;
                                }
#line 501 "GraphModule.cs"
#line 501 "GraphModule.cs"
                                int csharp2cuda_temp_213 = ((edges)[index]).from;
#line 501 "GraphModule.cs"
                                double* csharp2cuda_temp_214 = &((outgoing)[csharp2cuda_temp_213]);
#line 501 "GraphModule.cs"
                                double csharp2cuda_temp_215 = *(csharp2cuda_temp_214);
#line 501 "GraphModule.cs"
                                double csharp2cuda_temp_216 = ((edges)[index]).weight;
                                (*(csharp2cuda_temp_214) = __dadd_rn(csharp2cuda_temp_215, csharp2cuda_temp_216));
                            }
#line 494 "GraphModule.cs"
                            int* csharp2cuda_temp_209 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_209));
                        }
                    }
#line 503 "GraphModule.cs"
                    {
#line 503 "GraphModule.cs"
                        int iteration = 0;
                        while (true)
                        {
#line 503 "GraphModule.cs"
                            bool csharp2cuda_temp_218 = (output)->valid;
#line 503 "GraphModule.cs"
                            bool csharp2cuda_temp_219;
#line 503 "GraphModule.cs"
                            if (csharp2cuda_temp_218)
                            {
#line 503 "GraphModule.cs"
                                csharp2cuda_temp_219 = ((iteration) < (iterations));
                            }
                            else
                            {
#line 503 "GraphModule.cs"
                                csharp2cuda_temp_219 = false;
                            }
                            if (!(csharp2cuda_temp_219))
                                break;
#line 504 "GraphModule.cs"
                            {
#line 505 "GraphModule.cs"
                                {
#line 505 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 506 "GraphModule.cs"
#line 506 "GraphModule.cs"
                                        double* csharp2cuda_temp_221 = &((next)[vertex]);
#line 506 "GraphModule.cs"
                                        double csharp2cuda_temp_222 = __ddiv_rn(__dsub_rn(1.0, damping), ((double)(vertex_count)));
                                        (*(csharp2cuda_temp_221) = csharp2cuda_temp_222);
#line 505 "GraphModule.cs"
                                        int* csharp2cuda_temp_220 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_220));
                                    }
                                }
#line 507 "GraphModule.cs"
                                double dangling = 0.0;
#line 508 "GraphModule.cs"
                                {
#line 508 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 509 "GraphModule.cs"
#line 509 "GraphModule.cs"
                                        double csharp2cuda_temp_224 = (outgoing)[vertex];
                                        if (((csharp2cuda_temp_224) == (0.0)))
                                        {
#line 510 "GraphModule.cs"
#line 510 "GraphModule.cs"
                                            double* csharp2cuda_temp_225 = &(dangling);
#line 510 "GraphModule.cs"
                                            double csharp2cuda_temp_226 = *(csharp2cuda_temp_225);
#line 510 "GraphModule.cs"
                                            double csharp2cuda_temp_227 = (result)[vertex];
                                            (*(csharp2cuda_temp_225) = __dadd_rn(csharp2cuda_temp_226, csharp2cuda_temp_227));
                                        }
#line 508 "GraphModule.cs"
                                        int* csharp2cuda_temp_223 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_223));
                                    }
                                }
#line 511 "GraphModule.cs"
                                double dangling_share = __ddiv_rn(__dmul_rn(damping, dangling), ((double)(vertex_count)));
#line 512 "GraphModule.cs"
                                {
#line 512 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 513 "GraphModule.cs"
#line 513 "GraphModule.cs"
                                        double* csharp2cuda_temp_229 = &((next)[vertex]);
#line 513 "GraphModule.cs"
                                        double csharp2cuda_temp_230 = *(csharp2cuda_temp_229);
                                        (*(csharp2cuda_temp_229) = __dadd_rn(csharp2cuda_temp_230, dangling_share));
#line 512 "GraphModule.cs"
                                        int* csharp2cuda_temp_228 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_228));
                                    }
                                }
#line 514 "GraphModule.cs"
                                {
#line 514 "GraphModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 514 "GraphModule.cs"
                                        int csharp2cuda_temp_232 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_232))))
                                            break;
#line 515 "GraphModule.cs"
#line 515 "GraphModule.cs"
                                        int csharp2cuda_temp_233 = ((edges)[index]).to;
#line 515 "GraphModule.cs"
                                        double* csharp2cuda_temp_234 = &((next)[csharp2cuda_temp_233]);
#line 515 "GraphModule.cs"
                                        double csharp2cuda_temp_235 = *(csharp2cuda_temp_234);
#line 515 "GraphModule.cs"
                                        int csharp2cuda_temp_236 = ((edges)[index]).from;
#line 515 "GraphModule.cs"
                                        double csharp2cuda_temp_237 = (result)[csharp2cuda_temp_236];
#line 516 "GraphModule.cs"
                                        double csharp2cuda_temp_238 = ((edges)[index]).weight;
#line 516 "GraphModule.cs"
                                        int csharp2cuda_temp_239 = ((edges)[index]).from;
#line 516 "GraphModule.cs"
                                        double csharp2cuda_temp_240 = (outgoing)[csharp2cuda_temp_239];
#line 515 "GraphModule.cs"
                                        double csharp2cuda_temp_241 = __ddiv_rn(__dmul_rn(__dmul_rn(damping, csharp2cuda_temp_237), csharp2cuda_temp_238), csharp2cuda_temp_240);
                                        (*(csharp2cuda_temp_234) = __dadd_rn(csharp2cuda_temp_235, csharp2cuda_temp_241));
#line 514 "GraphModule.cs"
                                        int* csharp2cuda_temp_231 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_231));
                                    }
                                }
#line 517 "GraphModule.cs"
                                {
#line 517 "GraphModule.cs"
                                    int vertex = 0;
                                    while (true)
                                    {
                                        if (!(((vertex) < (vertex_count))))
                                            break;
#line 518 "GraphModule.cs"
#line 518 "GraphModule.cs"
                                        double* csharp2cuda_temp_243 = &((result)[vertex]);
#line 518 "GraphModule.cs"
                                        double csharp2cuda_temp_244 = (next)[vertex];
                                        (*(csharp2cuda_temp_243) = csharp2cuda_temp_244);
#line 517 "GraphModule.cs"
                                        int* csharp2cuda_temp_242 = &(vertex);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_242));
                                    }
                                }
                            }
#line 503 "GraphModule.cs"
                            int* csharp2cuda_temp_217 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                        }
                    }
#line 520 "GraphModule.cs"
                    break;
                }
#line 522 "GraphModule.cs"
            case 10:
            case 12:
            case 13:
#line 525 "GraphModule.cs"
                mathblocks_sequence_set_matrix_shape(output, vertex_count, vertex_count);
#line 526 "GraphModule.cs"
                {
#line 526 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
                        if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                            break;
#line 527 "GraphModule.cs"
#line 527 "GraphModule.cs"
                        double* csharp2cuda_temp_246 = &((result)[index]);
                        (*(csharp2cuda_temp_246) = 0.0);
#line 526 "GraphModule.cs"
                        int* csharp2cuda_temp_245 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_245));
                    }
                }
#line 528 "GraphModule.cs"
                {
#line 528 "GraphModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 528 "GraphModule.cs"
                        int csharp2cuda_temp_248 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_248))))
                            break;
#line 529 "GraphModule.cs"
                        {
#line 530 "GraphModule.cs"
                            int from = ((edges)[index]).from;
#line 531 "GraphModule.cs"
                            int to = ((edges)[index]).to;
#line 532 "GraphModule.cs"
                            double weight = ((edges)[index]).weight;
#line 533 "GraphModule.cs"
                            if (((opcode) == (10)))
#line 534 "GraphModule.cs"
                            {
#line 535 "GraphModule.cs"
#line 535 "GraphModule.cs"
                                double* csharp2cuda_temp_249 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 535 "GraphModule.cs"
                                double csharp2cuda_temp_250 = *(csharp2cuda_temp_249);
                                (*(csharp2cuda_temp_249) = __dadd_rn(csharp2cuda_temp_250, weight));
                            }
                            else
                            {
#line 537 "GraphModule.cs"
                                if (((opcode) == (12)))
#line 538 "GraphModule.cs"
                                {
#line 539 "GraphModule.cs"
#line 539 "GraphModule.cs"
                                    double* csharp2cuda_temp_251 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 539 "GraphModule.cs"
                                    double csharp2cuda_temp_252 = *(csharp2cuda_temp_251);
                                    (*(csharp2cuda_temp_251) = __dadd_rn(csharp2cuda_temp_252, weight));
#line 540 "GraphModule.cs"
#line 540 "GraphModule.cs"
                                    double* csharp2cuda_temp_253 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 540 "GraphModule.cs"
                                    double csharp2cuda_temp_254 = *(csharp2cuda_temp_253);
                                    (*(csharp2cuda_temp_253) = __dadd_rn(csharp2cuda_temp_254, weight));
                                }
                                else
#line 543 "GraphModule.cs"
                                {
#line 544 "GraphModule.cs"
#line 544 "GraphModule.cs"
                                    double* csharp2cuda_temp_255 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), from)]);
#line 544 "GraphModule.cs"
                                    double csharp2cuda_temp_256 = *(csharp2cuda_temp_255);
                                    (*(csharp2cuda_temp_255) = __dadd_rn(csharp2cuda_temp_256, weight));
#line 545 "GraphModule.cs"
#line 545 "GraphModule.cs"
                                    double* csharp2cuda_temp_257 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), to)]);
#line 545 "GraphModule.cs"
                                    double csharp2cuda_temp_258 = *(csharp2cuda_temp_257);
                                    (*(csharp2cuda_temp_257) = __dadd_rn(csharp2cuda_temp_258, weight));
#line 546 "GraphModule.cs"
#line 546 "GraphModule.cs"
                                    double* csharp2cuda_temp_259 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(from, vertex_count), to)]);
#line 546 "GraphModule.cs"
                                    double csharp2cuda_temp_260 = *(csharp2cuda_temp_259);
                                    (*(csharp2cuda_temp_259) = __dsub_rn(csharp2cuda_temp_260, weight));
#line 547 "GraphModule.cs"
#line 547 "GraphModule.cs"
                                    double* csharp2cuda_temp_261 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(to, vertex_count), from)]);
#line 547 "GraphModule.cs"
                                    double csharp2cuda_temp_262 = *(csharp2cuda_temp_261);
                                    (*(csharp2cuda_temp_261) = __dsub_rn(csharp2cuda_temp_262, weight));
                                }
                            }
                        }
#line 528 "GraphModule.cs"
                        int* csharp2cuda_temp_247 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_247));
                    }
                }
#line 550 "GraphModule.cs"
                break;
#line 551 "GraphModule.cs"
            case 11:
#line 552 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 553 "GraphModule.cs"
                {
#line 554 "GraphModule.cs"
#line 554 "GraphModule.cs"
                    int* csharp2cuda_temp_263 = &((output)->valid);
                    (*(csharp2cuda_temp_263) = 0);
#line 555 "GraphModule.cs"
                    break;
                }
#line 557 "GraphModule.cs"
                {
#line 558 "GraphModule.cs"
                    int* adjacency = ((int*)(scratch));
#line 559 "GraphModule.cs"
                    {
#line 559 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(vertex_count, vertex_count)))))
                                break;
#line 560 "GraphModule.cs"
#line 560 "GraphModule.cs"
                            int* csharp2cuda_temp_265 = &((adjacency)[index]);
                            (*(csharp2cuda_temp_265) = 0);
#line 559 "GraphModule.cs"
                            int* csharp2cuda_temp_264 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_264));
                        }
                    }
#line 561 "GraphModule.cs"
                    {
#line 561 "GraphModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 561 "GraphModule.cs"
                            int csharp2cuda_temp_267 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_267))))
                                break;
#line 562 "GraphModule.cs"
                            {
#line 563 "GraphModule.cs"
#line 563 "GraphModule.cs"
                                int csharp2cuda_temp_268 = ((edges)[index]).from;
#line 563 "GraphModule.cs"
                                int csharp2cuda_temp_269 = ((edges)[index]).to;
#line 563 "GraphModule.cs"
                                int* csharp2cuda_temp_270 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_268, vertex_count), csharp2cuda_temp_269)]);
                                (*(csharp2cuda_temp_270) = 1);
#line 564 "GraphModule.cs"
#line 564 "GraphModule.cs"
                                int csharp2cuda_temp_271 = ((edges)[index]).to;
#line 564 "GraphModule.cs"
                                int csharp2cuda_temp_272 = ((edges)[index]).from;
#line 564 "GraphModule.cs"
                                int* csharp2cuda_temp_273 = &((adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_temp_271, vertex_count), csharp2cuda_temp_272)]);
                                (*(csharp2cuda_temp_273) = 1);
                            }
#line 561 "GraphModule.cs"
                            int* csharp2cuda_temp_266 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_266));
                        }
                    }
#line 566 "GraphModule.cs"
                    int count = 0;
#line 567 "GraphModule.cs"
                    {
#line 567 "GraphModule.cs"
                        int one = 0;
                        while (true)
                        {
                            if (!(((one) < (vertex_count))))
                                break;
#line 568 "GraphModule.cs"
                            {
#line 568 "GraphModule.cs"
                                int two = csharp2cuda_i32_add(one, 1);
                                while (true)
                                {
                                    if (!(((two) < (vertex_count))))
                                        break;
#line 569 "GraphModule.cs"
                                    {
#line 569 "GraphModule.cs"
                                        int three = csharp2cuda_i32_add(two, 1);
                                        while (true)
                                        {
                                            if (!(((three) < (vertex_count))))
                                                break;
#line 570 "GraphModule.cs"
#line 570 "GraphModule.cs"
                                            int csharp2cuda_temp_277 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(one, vertex_count), two)];
#line 570 "GraphModule.cs"
                                            bool csharp2cuda_temp_278;
#line 570 "GraphModule.cs"
                                            if (((csharp2cuda_temp_277) != 0))
                                            {
#line 571 "GraphModule.cs"
                                                int csharp2cuda_temp_279 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(one, vertex_count), three)];
#line 570 "GraphModule.cs"
                                                csharp2cuda_temp_278 = ((csharp2cuda_temp_279) != 0);
                                            }
                                            else
                                            {
#line 570 "GraphModule.cs"
                                                csharp2cuda_temp_278 = false;
                                            }
#line 570 "GraphModule.cs"
                                            bool csharp2cuda_temp_280;
#line 570 "GraphModule.cs"
                                            if (csharp2cuda_temp_278)
                                            {
#line 572 "GraphModule.cs"
                                                int csharp2cuda_temp_281 = (adjacency)[csharp2cuda_i32_add(csharp2cuda_i32_mul(two, vertex_count), three)];
#line 570 "GraphModule.cs"
                                                csharp2cuda_temp_280 = ((csharp2cuda_temp_281) != 0);
                                            }
                                            else
                                            {
#line 570 "GraphModule.cs"
                                                csharp2cuda_temp_280 = false;
                                            }
                                            if (csharp2cuda_temp_280)
#line 573 "GraphModule.cs"
                                            {
#line 574 "GraphModule.cs"
#line 574 "GraphModule.cs"
                                                int* csharp2cuda_temp_282 = &(count);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_282));
                                            }
#line 569 "GraphModule.cs"
                                            int* csharp2cuda_temp_276 = &(three);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_276));
                                        }
                                    }
#line 568 "GraphModule.cs"
                                    int* csharp2cuda_temp_275 = &(two);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_275));
                                }
                            }
#line 567 "GraphModule.cs"
                            int* csharp2cuda_temp_274 = &(one);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_274));
                        }
                    }
#line 576 "GraphModule.cs"
#line 576 "GraphModule.cs"
                    double* csharp2cuda_temp_283 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_283) = ((double)(count)));
#line 577 "GraphModule.cs"
                    break;
                }
#line 579 "GraphModule.cs"
            case 14:
#line 580 "GraphModule.cs"
                mathblocks_sequence_set_vector_shape(output, vertex_count);
#line 581 "GraphModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 582 "GraphModule.cs"
                {
#line 583 "GraphModule.cs"
#line 583 "GraphModule.cs"
                    int* csharp2cuda_temp_284 = &((output)->valid);
                    (*(csharp2cuda_temp_284) = 0);
#line 584 "GraphModule.cs"
                    break;
                }
#line 586 "GraphModule.cs"
                {
#line 587 "GraphModule.cs"
                    int source = 0;
#line 588 "GraphModule.cs"
#line 588 "GraphModule.cs"
                    double csharp2cuda_temp_285 = (second)->scalar_value;
#line 588 "GraphModule.cs"
                    int* csharp2cuda_temp_286 = &(source);
#line 588 "GraphModule.cs"
                    bool csharp2cuda_temp_287 = mathblocks_nonnegative_integer(csharp2cuda_temp_285, csharp2cuda_temp_286);
#line 588 "GraphModule.cs"
                    bool csharp2cuda_temp_288;
#line 588 "GraphModule.cs"
                    if (!((!(csharp2cuda_temp_287))))
                    {
#line 588 "GraphModule.cs"
                        csharp2cuda_temp_288 = ((source) >= (vertex_count));
                    }
                    else
                    {
#line 588 "GraphModule.cs"
                        csharp2cuda_temp_288 = true;
                    }
                    if (csharp2cuda_temp_288)
#line 589 "GraphModule.cs"
                    {
#line 590 "GraphModule.cs"
#line 590 "GraphModule.cs"
                        int* csharp2cuda_temp_289 = &((output)->valid);
                        (*(csharp2cuda_temp_289) = 0);
#line 591 "GraphModule.cs"
                        break;
                    }
#line 593 "GraphModule.cs"
                    int* visited = ((int*)(scratch));
#line 594 "GraphModule.cs"
                    {
#line 594 "GraphModule.cs"
                        int vertex = 0;
                        while (true)
                        {
                            if (!(((vertex) < (vertex_count))))
                                break;
#line 595 "GraphModule.cs"
                            {
#line 596 "GraphModule.cs"
#line 596 "GraphModule.cs"
                                double* csharp2cuda_temp_291 = &((result)[vertex]);
                                (*(csharp2cuda_temp_291) = mathblocks_positive_infinity());
#line 597 "GraphModule.cs"
#line 597 "GraphModule.cs"
                                int* csharp2cuda_temp_292 = &((visited)[vertex]);
                                (*(csharp2cuda_temp_292) = 0);
                            }
#line 594 "GraphModule.cs"
                            int* csharp2cuda_temp_290 = &(vertex);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_290));
                        }
                    }
#line 599 "GraphModule.cs"
#line 599 "GraphModule.cs"
                    double* csharp2cuda_temp_293 = &((result)[source]);
                    (*(csharp2cuda_temp_293) = 0.0);
#line 600 "GraphModule.cs"
                    {
#line 600 "GraphModule.cs"
                        int iteration = 0;
                        while (true)
                        {
                            if (!(((iteration) < (vertex_count))))
                                break;
#line 601 "GraphModule.cs"
                            {
#line 602 "GraphModule.cs"
                                int vertex = -1;
#line 603 "GraphModule.cs"
                                double best = mathblocks_positive_infinity();
#line 604 "GraphModule.cs"
                                {
#line 604 "GraphModule.cs"
                                    int candidate = 0;
                                    while (true)
                                    {
                                        if (!(((candidate) < (vertex_count))))
                                            break;
#line 605 "GraphModule.cs"
#line 605 "GraphModule.cs"
                                        int csharp2cuda_temp_296 = (visited)[candidate];
#line 605 "GraphModule.cs"
                                        bool csharp2cuda_temp_297;
#line 605 "GraphModule.cs"
                                        if ((!(((csharp2cuda_temp_296) != 0))))
                                        {
#line 605 "GraphModule.cs"
                                            double csharp2cuda_temp_298 = (result)[candidate];
#line 605 "GraphModule.cs"
                                            csharp2cuda_temp_297 = ((csharp2cuda_temp_298) < (best));
                                        }
                                        else
                                        {
#line 605 "GraphModule.cs"
                                            csharp2cuda_temp_297 = false;
                                        }
                                        if (csharp2cuda_temp_297)
#line 606 "GraphModule.cs"
                                        {
#line 607 "GraphModule.cs"
#line 607 "GraphModule.cs"
                                            double* csharp2cuda_temp_299 = &(best);
#line 607 "GraphModule.cs"
                                            double csharp2cuda_temp_300 = (result)[candidate];
                                            (*(csharp2cuda_temp_299) = csharp2cuda_temp_300);
#line 608 "GraphModule.cs"
#line 608 "GraphModule.cs"
                                            int* csharp2cuda_temp_301 = &(vertex);
                                            (*(csharp2cuda_temp_301) = candidate);
                                        }
#line 604 "GraphModule.cs"
                                        int* csharp2cuda_temp_295 = &(candidate);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_295));
                                    }
                                }
#line 610 "GraphModule.cs"
                                if (((vertex) < (0)))
                                {
#line 611 "GraphModule.cs"
                                    break;
                                }
#line 612 "GraphModule.cs"
#line 612 "GraphModule.cs"
                                int* csharp2cuda_temp_302 = &((visited)[vertex]);
                                (*(csharp2cuda_temp_302) = 1);
#line 613 "GraphModule.cs"
                                {
#line 613 "GraphModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 613 "GraphModule.cs"
                                        int csharp2cuda_temp_304 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_304))))
                                            break;
#line 614 "GraphModule.cs"
                                        {
#line 615 "GraphModule.cs"
#line 615 "GraphModule.cs"
                                            double csharp2cuda_temp_305 = ((edges)[index]).weight;
                                            if (((csharp2cuda_temp_305) < (0.0)))
#line 616 "GraphModule.cs"
                                            {
#line 617 "GraphModule.cs"
#line 617 "GraphModule.cs"
                                                int* csharp2cuda_temp_306 = &((output)->valid);
                                                (*(csharp2cuda_temp_306) = 0);
#line 618 "GraphModule.cs"
                                                break;
                                            }
#line 620 "GraphModule.cs"
                                            int csharp2cuda_temp_307 = ((edges)[index]).from;
#line 620 "GraphModule.cs"
                                            int csharp2cuda_temp_308;
#line 620 "GraphModule.cs"
                                            if (((csharp2cuda_temp_307) == (vertex)))
                                            {
#line 620 "GraphModule.cs"
                                                csharp2cuda_temp_308 = ((edges)[index]).to;
                                            }
                                            else
                                            {
#line 622 "GraphModule.cs"
                                                int csharp2cuda_temp_309 = ((edges)[index]).to;
#line 622 "GraphModule.cs"
                                                int csharp2cuda_temp_310;
#line 622 "GraphModule.cs"
                                                if (((csharp2cuda_temp_309) == (vertex)))
                                                {
#line 622 "GraphModule.cs"
                                                    csharp2cuda_temp_310 = ((edges)[index]).from;
                                                }
                                                else
                                                {
#line 622 "GraphModule.cs"
                                                    csharp2cuda_temp_310 = csharp2cuda_i32_neg(1);
                                                }
#line 620 "GraphModule.cs"
                                                csharp2cuda_temp_308 = csharp2cuda_temp_310;
                                            }
#line 620 "GraphModule.cs"
                                            int neighbor = csharp2cuda_temp_308;
#line 625 "GraphModule.cs"
                                            if (((neighbor) < (0)))
                                            {
#line 626 "GraphModule.cs"
                                                goto csharp2cuda_for_continue_32;
                                            }
#line 627 "GraphModule.cs"
                                            double csharp2cuda_temp_311 = (result)[vertex];
#line 627 "GraphModule.cs"
                                            double csharp2cuda_temp_312 = ((edges)[index]).weight;
#line 627 "GraphModule.cs"
                                            double candidate = __dadd_rn(csharp2cuda_temp_311, csharp2cuda_temp_312);
#line 628 "GraphModule.cs"
#line 628 "GraphModule.cs"
                                            double* csharp2cuda_temp_313 = &((result)[neighbor]);
#line 628 "GraphModule.cs"
                                            double csharp2cuda_temp_314 = (result)[neighbor];
#line 628 "GraphModule.cs"
                                            double csharp2cuda_temp_315;
#line 628 "GraphModule.cs"
                                            if (((csharp2cuda_temp_314) < (candidate)))
                                            {
#line 628 "GraphModule.cs"
                                                csharp2cuda_temp_315 = (result)[neighbor];
                                            }
                                            else
                                            {
#line 628 "GraphModule.cs"
                                                csharp2cuda_temp_315 = candidate;
                                            }
                                            (*(csharp2cuda_temp_313) = csharp2cuda_temp_315);
                                        }
                                        csharp2cuda_for_continue_32:
#line 613 "GraphModule.cs"
                                        int* csharp2cuda_temp_303 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_303));
                                    }
                                }
                            }
#line 600 "GraphModule.cs"
                            int* csharp2cuda_temp_294 = &(iteration);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_294));
                        }
                    }
#line 633 "GraphModule.cs"
                    break;
                }
        }
#line 637 "GraphModule.cs"
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_316 = (output)->valid;
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_317;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_316)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_317 = ((opcode) != (3));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_317 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_318;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_317)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_318 = ((opcode) != (4));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_318 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_319;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_318)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_319 = ((opcode) != (5));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_319 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_320;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_319)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_320 = ((opcode) != (7));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_320 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_321;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_320)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_321 = ((opcode) != (8));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_321 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_322;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_321)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_322 = ((opcode) != (9));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_322 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_323;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_322)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_323 = ((opcode) != (10));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_323 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_324;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_323)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_324 = ((opcode) != (12));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_324 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_325;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_324)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_325 = ((opcode) != (13));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_325 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_326;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_325)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_326 = ((opcode) != (14));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_326 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_327;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_326)
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_327 = ((opcode) != (15));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_327 = false;
        }
#line 637 "GraphModule.cs"
        bool csharp2cuda_temp_328;
#line 637 "GraphModule.cs"
        if (csharp2cuda_temp_327)
        {
#line 640 "GraphModule.cs"
            double csharp2cuda_temp_329 = (output)->scalar_value;
#line 637 "GraphModule.cs"
            csharp2cuda_temp_328 = (!(isfinite(csharp2cuda_temp_329)));
        }
        else
        {
#line 637 "GraphModule.cs"
            csharp2cuda_temp_328 = false;
        }
        if (csharp2cuda_temp_328)
#line 641 "GraphModule.cs"
        {
#line 642 "GraphModule.cs"
#line 642 "GraphModule.cs"
            int* csharp2cuda_temp_330 = &((output)->valid);
            (*(csharp2cuda_temp_330) = 0);
        }
#line 644 "GraphModule.cs"
#line 644 "GraphModule.cs"
        bool csharp2cuda_temp_331 = (output)->valid;
#line 644 "GraphModule.cs"
        bool csharp2cuda_temp_332;
#line 644 "GraphModule.cs"
        if (csharp2cuda_temp_331)
        {
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_333;
#line 645 "GraphModule.cs"
            if (!(((opcode) == (3))))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_333 = ((opcode) == (5));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_333 = true;
            }
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_334;
#line 645 "GraphModule.cs"
            if (!(csharp2cuda_temp_333))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_334 = ((opcode) == (9));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_334 = true;
            }
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_335;
#line 645 "GraphModule.cs"
            if (!(csharp2cuda_temp_334))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_335 = ((opcode) == (10));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_335 = true;
            }
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_336;
#line 645 "GraphModule.cs"
            if (!(csharp2cuda_temp_335))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_336 = ((opcode) == (12));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_336 = true;
            }
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_337;
#line 645 "GraphModule.cs"
            if (!(csharp2cuda_temp_336))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_337 = ((opcode) == (13));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_337 = true;
            }
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_338;
#line 645 "GraphModule.cs"
            if (!(csharp2cuda_temp_337))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_338 = ((opcode) == (14));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_338 = true;
            }
#line 645 "GraphModule.cs"
            bool csharp2cuda_temp_339;
#line 645 "GraphModule.cs"
            if (!(csharp2cuda_temp_338))
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_339 = ((opcode) == (15));
            }
            else
            {
#line 645 "GraphModule.cs"
                csharp2cuda_temp_339 = true;
            }
#line 644 "GraphModule.cs"
            csharp2cuda_temp_332 = csharp2cuda_temp_339;
        }
        else
        {
#line 644 "GraphModule.cs"
            csharp2cuda_temp_332 = false;
        }
        if (csharp2cuda_temp_332)
#line 647 "GraphModule.cs"
        {
#line 648 "GraphModule.cs"
            {
#line 648 "GraphModule.cs"
                int index = 0;
                while (true)
                {
#line 648 "GraphModule.cs"
                    int csharp2cuda_temp_341 = (output)->count;
                    if (!(((index) < (csharp2cuda_temp_341))))
                        break;
#line 649 "GraphModule.cs"
#line 649 "GraphModule.cs"
                    double csharp2cuda_temp_342 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_342))))
                    {
#line 649 "GraphModule.cs"
#line 649 "GraphModule.cs"
                        int* csharp2cuda_temp_343 = &((output)->valid);
                        (*(csharp2cuda_temp_343) = 0);
                    }
#line 648 "GraphModule.cs"
                    int* csharp2cuda_temp_340 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_340));
                }
            }
        }
    }
}

#line 139 "GraphModule.cs"
__device__ bool mathblocks_graph_edge_less(
    const MathBlockGraphKernelEdge* left,
    const MathBlockGraphKernelEdge* right)
#line 143 "GraphModule.cs"
{
#line 144 "GraphModule.cs"
#line 144 "GraphModule.cs"
    double csharp2cuda_temp_0 = (*(left)).weight;
#line 144 "GraphModule.cs"
    double csharp2cuda_temp_1 = (*(right)).weight;
    if (((csharp2cuda_temp_0) < (csharp2cuda_temp_1)))
    {
#line 145 "GraphModule.cs"
        return true;
    }
#line 146 "GraphModule.cs"
#line 146 "GraphModule.cs"
    double csharp2cuda_temp_2 = (*(right)).weight;
#line 146 "GraphModule.cs"
    double csharp2cuda_temp_3 = (*(left)).weight;
    if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
    {
#line 147 "GraphModule.cs"
        return false;
    }
#line 148 "GraphModule.cs"
#line 148 "GraphModule.cs"
    int csharp2cuda_temp_4 = (*(left)).from;
#line 148 "GraphModule.cs"
    int csharp2cuda_temp_5 = (*(right)).from;
    if (((csharp2cuda_temp_4) < (csharp2cuda_temp_5)))
    {
#line 149 "GraphModule.cs"
        return true;
    }
#line 150 "GraphModule.cs"
#line 150 "GraphModule.cs"
    int csharp2cuda_temp_6 = (*(right)).from;
#line 150 "GraphModule.cs"
    int csharp2cuda_temp_7 = (*(left)).from;
    if (((csharp2cuda_temp_6) < (csharp2cuda_temp_7)))
    {
#line 151 "GraphModule.cs"
        return false;
    }
#line 152 "GraphModule.cs"
#line 152 "GraphModule.cs"
    int csharp2cuda_temp_8 = (*(left)).to;
#line 152 "GraphModule.cs"
    int csharp2cuda_temp_9 = (*(right)).to;
    return ((csharp2cuda_temp_8) < (csharp2cuda_temp_9));
}

#line 155 "GraphModule.cs"
__device__ int mathblocks_graph_find(int* parent, int vertex)
#line 157 "GraphModule.cs"
{
#line 158 "GraphModule.cs"
    while (true)
    {
#line 158 "GraphModule.cs"
        int csharp2cuda_temp_0 = (parent)[vertex];
        if (!(((csharp2cuda_temp_0) != (vertex))))
            break;
#line 159 "GraphModule.cs"
        {
#line 160 "GraphModule.cs"
#line 160 "GraphModule.cs"
            int* csharp2cuda_temp_1 = &((parent)[vertex]);
#line 160 "GraphModule.cs"
            int csharp2cuda_temp_2 = (parent)[vertex];
#line 160 "GraphModule.cs"
            int csharp2cuda_temp_3 = (parent)[csharp2cuda_temp_2];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 161 "GraphModule.cs"
#line 161 "GraphModule.cs"
            int* csharp2cuda_temp_4 = &(vertex);
#line 161 "GraphModule.cs"
            int csharp2cuda_temp_5 = (parent)[vertex];
            (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
        }
    }
#line 163 "GraphModule.cs"
    return vertex;
}

#line 64 "GraphModule.cs"
__device__ void mathblocks_graph_sort_edges(MathBlockGraphKernelEdge* edges, MathBlockGraphKernelEdge* buffer, int count)
#line 66 "GraphModule.cs"
{
#line 67 "GraphModule.cs"
    MathBlockGraphKernelEdge* source = edges;
#line 68 "GraphModule.cs"
    MathBlockGraphKernelEdge* target = buffer;
#line 69 "GraphModule.cs"
    {
#line 69 "GraphModule.cs"
        int width = 1;
        while (true)
        {
            if (!(((width) < (count))))
                break;
#line 70 "GraphModule.cs"
            {
#line 71 "GraphModule.cs"
                {
#line 71 "GraphModule.cs"
                    int start = 0;
                    while (true)
                    {
                        if (!(((start) < (count))))
                            break;
#line 72 "GraphModule.cs"
                        {
#line 73 "GraphModule.cs"
                            int csharp2cuda_temp_4;
#line 73 "GraphModule.cs"
                            if (((csharp2cuda_i32_add(start, width)) < (count)))
                            {
#line 73 "GraphModule.cs"
                                csharp2cuda_temp_4 = csharp2cuda_i32_add(start, width);
                            }
                            else
                            {
#line 73 "GraphModule.cs"
                                csharp2cuda_temp_4 = count;
                            }
#line 73 "GraphModule.cs"
                            int middle = csharp2cuda_temp_4;
#line 74 "GraphModule.cs"
                            int csharp2cuda_temp_5;
#line 74 "GraphModule.cs"
                            if (((csharp2cuda_i32_add(middle, width)) < (count)))
                            {
#line 74 "GraphModule.cs"
                                csharp2cuda_temp_5 = csharp2cuda_i32_add(middle, width);
                            }
                            else
                            {
#line 74 "GraphModule.cs"
                                csharp2cuda_temp_5 = count;
                            }
#line 74 "GraphModule.cs"
                            int end = csharp2cuda_temp_5;
#line 75 "GraphModule.cs"
                            int left = start;
#line 76 "GraphModule.cs"
                            int right = middle;
#line 77 "GraphModule.cs"
                            int position = start;
#line 78 "GraphModule.cs"
                            while (true)
                            {
#line 78 "GraphModule.cs"
                                bool csharp2cuda_temp_6;
#line 78 "GraphModule.cs"
                                if (((left) < (middle)))
                                {
#line 78 "GraphModule.cs"
                                    csharp2cuda_temp_6 = ((right) < (end));
                                }
                                else
                                {
#line 78 "GraphModule.cs"
                                    csharp2cuda_temp_6 = false;
                                }
                                if (!(csharp2cuda_temp_6))
                                    break;
#line 79 "GraphModule.cs"
                                {
#line 80 "GraphModule.cs"
#line 80 "GraphModule.cs"
                                    MathBlockGraphKernelEdge* csharp2cuda_temp_7 = &((source)[right]);
#line 80 "GraphModule.cs"
                                    MathBlockGraphKernelEdge* csharp2cuda_temp_8 = &((source)[left]);
                                    if (mathblocks_graph_edge_less(csharp2cuda_temp_7, csharp2cuda_temp_8))
                                    {
#line 81 "GraphModule.cs"
#line 81 "GraphModule.cs"
                                        int* csharp2cuda_temp_9 = &(position);
#line 81 "GraphModule.cs"
                                        int csharp2cuda_temp_10 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
#line 81 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_11 = &((target)[csharp2cuda_temp_10]);
#line 81 "GraphModule.cs"
                                        int* csharp2cuda_temp_12 = &(right);
#line 81 "GraphModule.cs"
                                        int csharp2cuda_temp_13 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
#line 81 "GraphModule.cs"
                                        MathBlockGraphKernelEdge csharp2cuda_temp_14 = (source)[csharp2cuda_temp_13];
                                        (*(csharp2cuda_temp_11) = csharp2cuda_temp_14);
                                    }
                                    else
                                    {
#line 83 "GraphModule.cs"
#line 83 "GraphModule.cs"
                                        int* csharp2cuda_temp_15 = &(position);
#line 83 "GraphModule.cs"
                                        int csharp2cuda_temp_16 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
#line 83 "GraphModule.cs"
                                        MathBlockGraphKernelEdge* csharp2cuda_temp_17 = &((target)[csharp2cuda_temp_16]);
#line 83 "GraphModule.cs"
                                        int* csharp2cuda_temp_18 = &(left);
#line 83 "GraphModule.cs"
                                        int csharp2cuda_temp_19 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
#line 83 "GraphModule.cs"
                                        MathBlockGraphKernelEdge csharp2cuda_temp_20 = (source)[csharp2cuda_temp_19];
                                        (*(csharp2cuda_temp_17) = csharp2cuda_temp_20);
                                    }
                                }
                            }
#line 85 "GraphModule.cs"
                            while (true)
                            {
                                if (!(((left) < (middle))))
                                    break;
#line 86 "GraphModule.cs"
#line 86 "GraphModule.cs"
                                int* csharp2cuda_temp_21 = &(position);
#line 86 "GraphModule.cs"
                                int csharp2cuda_temp_22 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_21));
#line 86 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_23 = &((target)[csharp2cuda_temp_22]);
#line 86 "GraphModule.cs"
                                int* csharp2cuda_temp_24 = &(left);
#line 86 "GraphModule.cs"
                                int csharp2cuda_temp_25 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_24));
#line 86 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_26 = (source)[csharp2cuda_temp_25];
                                (*(csharp2cuda_temp_23) = csharp2cuda_temp_26);
                            }
#line 87 "GraphModule.cs"
                            while (true)
                            {
                                if (!(((right) < (end))))
                                    break;
#line 88 "GraphModule.cs"
#line 88 "GraphModule.cs"
                                int* csharp2cuda_temp_27 = &(position);
#line 88 "GraphModule.cs"
                                int csharp2cuda_temp_28 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_27));
#line 88 "GraphModule.cs"
                                MathBlockGraphKernelEdge* csharp2cuda_temp_29 = &((target)[csharp2cuda_temp_28]);
#line 88 "GraphModule.cs"
                                int* csharp2cuda_temp_30 = &(right);
#line 88 "GraphModule.cs"
                                int csharp2cuda_temp_31 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_30));
#line 88 "GraphModule.cs"
                                MathBlockGraphKernelEdge csharp2cuda_temp_32 = (source)[csharp2cuda_temp_31];
                                (*(csharp2cuda_temp_29) = csharp2cuda_temp_32);
                            }
                        }
#line 71 "GraphModule.cs"
                        int* csharp2cuda_temp_2 = &(start);
#line 71 "GraphModule.cs"
                        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                        (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, csharp2cuda_i32_add(width, width)));
                    }
                }
#line 90 "GraphModule.cs"
                MathBlockGraphKernelEdge* sorted = target;
#line 91 "GraphModule.cs"
#line 91 "GraphModule.cs"
                MathBlockGraphKernelEdge** csharp2cuda_temp_33 = &(target);
                (*(csharp2cuda_temp_33) = source);
#line 92 "GraphModule.cs"
#line 92 "GraphModule.cs"
                MathBlockGraphKernelEdge** csharp2cuda_temp_34 = &(source);
                (*(csharp2cuda_temp_34) = sorted);
            }
#line 69 "GraphModule.cs"
            int* csharp2cuda_temp_0 = &(width);
#line 69 "GraphModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, width));
        }
    }
#line 94 "GraphModule.cs"
    if (((((void*)(source))) != (((void*)(edges)))))
    {
#line 95 "GraphModule.cs"
        {
#line 95 "GraphModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 96 "GraphModule.cs"
#line 96 "GraphModule.cs"
                MathBlockGraphKernelEdge* csharp2cuda_temp_36 = &((edges)[index]);
#line 96 "GraphModule.cs"
                MathBlockGraphKernelEdge csharp2cuda_temp_37 = (source)[index];
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 95 "GraphModule.cs"
                int* csharp2cuda_temp_35 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_35));
            }
        }
    }
}