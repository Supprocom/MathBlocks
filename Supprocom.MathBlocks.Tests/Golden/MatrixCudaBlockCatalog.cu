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

#line 64 "MatrixModule.cs"
__device__ bool mathblocks_matrix_compatible(
    const MathBlockSlot* left,
    const MathBlockSlot* right);

#line 72 "MatrixModule.cs"
__device__ void mathblocks_matrix_copy(const double* source, double* destination, int count);

#line 96 "MatrixModule.cs"
__device__ double mathblocks_matrix_determinant(
    const double* source,
    int size,
    double* work);

#line 436 "MatrixModule.cs"
__device__ void mathblocks_matrix_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 241 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_positive_definite(
    const double* values,
    int size,
    double* lower);

#line 229 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_symmetric(const double* values, int rows, int columns);

#line 378 "MatrixModule.cs"
__device__ void mathblocks_matrix_multiply_square(
    const double* left,
    const double* right,
    int size,
    double* destination);

#line 344 "MatrixModule.cs"
__device__ int mathblocks_matrix_rank(const double* source, int rows, int columns, double* work);

#line 53 "MatrixModule.cs"
__device__ void mathblocks_matrix_shape(MathBlockSlot* output, int rows, int columns);

#line 409 "MatrixModule.cs"
__device__ void mathblocks_matrix_submatrix_from_masks(
    const double* source,
    int source_columns,
    int row_mask,
    int column_mask,
    int order,
    double* destination);

#line 79 "MatrixModule.cs"
__device__ void mathblocks_matrix_swap_rows(
    double* values,
    int columns,
    int left,
    int right);

#line 273 "MatrixModule.cs"
__device__ void mathblocks_matrix_symmetric_eigenvalues(
    const double* source,
    int size,
    double* work,
    double* eigenvalues);

#line 129 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve(
    const double* matrix,
    const double* right,
    int size,
    double* augmented,
    double* solution);

#line 179 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve_basis(
    const double* matrix,
    int size,
    int basis,
    double* augmented,
    double* solution);

#line 397 "MatrixModule.cs"
__device__ int mathblocks_pop_count(int value);

#line 64 "MatrixModule.cs"
__device__ bool mathblocks_matrix_compatible(
    const MathBlockSlot* left,
    const MathBlockSlot* right)
#line 68 "MatrixModule.cs"
{
#line 69 "MatrixModule.cs"
#line 69 "MatrixModule.cs"
    int csharp2cuda_temp_0 = (left)->rows;
#line 69 "MatrixModule.cs"
    int csharp2cuda_temp_1 = (right)->rows;
#line 69 "MatrixModule.cs"
    bool csharp2cuda_temp_2;
#line 69 "MatrixModule.cs"
    if (((csharp2cuda_temp_0) == (csharp2cuda_temp_1)))
    {
#line 69 "MatrixModule.cs"
        int csharp2cuda_temp_3 = (left)->columns;
#line 69 "MatrixModule.cs"
        int csharp2cuda_temp_4 = (right)->columns;
#line 69 "MatrixModule.cs"
        csharp2cuda_temp_2 = ((csharp2cuda_temp_3) == (csharp2cuda_temp_4));
    }
    else
    {
#line 69 "MatrixModule.cs"
        csharp2cuda_temp_2 = false;
    }
    return csharp2cuda_temp_2;
}

#line 72 "MatrixModule.cs"
__device__ void mathblocks_matrix_copy(const double* source, double* destination, int count)
#line 74 "MatrixModule.cs"
{
#line 75 "MatrixModule.cs"
    {
#line 75 "MatrixModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 76 "MatrixModule.cs"
#line 76 "MatrixModule.cs"
            double* csharp2cuda_temp_1 = &((destination)[index]);
#line 76 "MatrixModule.cs"
            double csharp2cuda_temp_2 = (source)[index];
            (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 75 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 96 "MatrixModule.cs"
__device__ double mathblocks_matrix_determinant(
    const double* source,
    int size,
    double* work)
#line 101 "MatrixModule.cs"
{
#line 102 "MatrixModule.cs"
    mathblocks_matrix_copy(source, work, csharp2cuda_i32_mul(size, size));
#line 103 "MatrixModule.cs"
    double determinant = 1.0;
#line 104 "MatrixModule.cs"
    {
#line 104 "MatrixModule.cs"
        int pivot = 0;
        while (true)
        {
            if (!(((pivot) < (size))))
                break;
#line 105 "MatrixModule.cs"
            {
#line 106 "MatrixModule.cs"
                int pivot_row = pivot;
#line 107 "MatrixModule.cs"
                {
#line 107 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 108 "MatrixModule.cs"
#line 108 "MatrixModule.cs"
                        double csharp2cuda_temp_2 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), pivot)];
#line 108 "MatrixModule.cs"
                        double csharp2cuda_temp_3 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot)];
                        if (((fabs(csharp2cuda_temp_2)) > (fabs(csharp2cuda_temp_3))))
                        {
#line 109 "MatrixModule.cs"
#line 109 "MatrixModule.cs"
                            int* csharp2cuda_temp_4 = &(pivot_row);
                            (*(csharp2cuda_temp_4) = row);
                        }
#line 107 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 110 "MatrixModule.cs"
#line 110 "MatrixModule.cs"
                double csharp2cuda_temp_5 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot)];
                if (((csharp2cuda_temp_5) == (0.0)))
                {
#line 111 "MatrixModule.cs"
                    return 0.0;
                }
#line 112 "MatrixModule.cs"
                if (((pivot_row) != (pivot)))
#line 113 "MatrixModule.cs"
                {
#line 114 "MatrixModule.cs"
                    mathblocks_matrix_swap_rows(work, size, pivot, pivot_row);
#line 115 "MatrixModule.cs"
#line 115 "MatrixModule.cs"
                    double* csharp2cuda_temp_6 = &(determinant);
                    (*(csharp2cuda_temp_6) = (-(determinant)));
                }
#line 117 "MatrixModule.cs"
                double diagonal = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, size), pivot)];
#line 118 "MatrixModule.cs"
#line 118 "MatrixModule.cs"
                double* csharp2cuda_temp_7 = &(determinant);
#line 118 "MatrixModule.cs"
                double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
                (*(csharp2cuda_temp_7) = __dmul_rn(csharp2cuda_temp_8, diagonal));
#line 119 "MatrixModule.cs"
                {
#line 119 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 120 "MatrixModule.cs"
                        {
#line 121 "MatrixModule.cs"
                            double csharp2cuda_temp_10 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), pivot)];
#line 121 "MatrixModule.cs"
                            double scale = __ddiv_rn(csharp2cuda_temp_10, diagonal);
#line 122 "MatrixModule.cs"
                            {
#line 122 "MatrixModule.cs"
                                int column = csharp2cuda_i32_add(pivot, 1);
                                while (true)
                                {
                                    if (!(((column) < (size))))
                                        break;
#line 123 "MatrixModule.cs"
#line 123 "MatrixModule.cs"
                                    double* csharp2cuda_temp_12 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
#line 123 "MatrixModule.cs"
                                    double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
#line 123 "MatrixModule.cs"
                                    double csharp2cuda_temp_14 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, size), column)];
                                    (*(csharp2cuda_temp_12) = __dsub_rn(csharp2cuda_temp_13, __dmul_rn(scale, csharp2cuda_temp_14)));
#line 122 "MatrixModule.cs"
                                    int* csharp2cuda_temp_11 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_11));
                                }
                            }
                        }
#line 119 "MatrixModule.cs"
                        int* csharp2cuda_temp_9 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                    }
                }
            }
#line 104 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(pivot);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 126 "MatrixModule.cs"
    return determinant;
}

#line 436 "MatrixModule.cs"
__device__ void mathblocks_matrix_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 442 "MatrixModule.cs"
{
#line 443 "MatrixModule.cs"
    int thread = threadIdx.x;
#line 444 "MatrixModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 444 "MatrixModule.cs"
    if (((input_count) > (0)))
    {
#line 444 "MatrixModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 444 "MatrixModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 444 "MatrixModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 445 "MatrixModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 445 "MatrixModule.cs"
    if (((input_count) > (1)))
    {
#line 445 "MatrixModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 445 "MatrixModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 445 "MatrixModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 446 "MatrixModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 446 "MatrixModule.cs"
    if (((input_count) > (2)))
    {
#line 446 "MatrixModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 446 "MatrixModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 446 "MatrixModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 447 "MatrixModule.cs"
    if (((thread) == (0)))
#line 448 "MatrixModule.cs"
    {
#line 449 "MatrixModule.cs"
#line 449 "MatrixModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 450 "MatrixModule.cs"
#line 450 "MatrixModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 451 "MatrixModule.cs"
#line 451 "MatrixModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 452 "MatrixModule.cs"
#line 452 "MatrixModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 453 "MatrixModule.cs"
#line 453 "MatrixModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 454 "MatrixModule.cs"
#line 454 "MatrixModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
        (*(csharp2cuda_temp_8) = 1);
#line 455 "MatrixModule.cs"
        {
#line 455 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 456 "MatrixModule.cs"
#line 456 "MatrixModule.cs"
                MathBlockSlot* csharp2cuda_temp_10 = (inputs)[index];
#line 456 "MatrixModule.cs"
                bool csharp2cuda_temp_11;
#line 456 "MatrixModule.cs"
                if (!(((((void*)(csharp2cuda_temp_10))) == (((void*)(nullptr))))))
                {
#line 456 "MatrixModule.cs"
                    MathBlockSlot* csharp2cuda_temp_12 = (inputs)[index];
#line 456 "MatrixModule.cs"
                    bool csharp2cuda_temp_13 = (csharp2cuda_temp_12)->valid;
#line 456 "MatrixModule.cs"
                    csharp2cuda_temp_11 = (!(csharp2cuda_temp_13));
                }
                else
                {
#line 456 "MatrixModule.cs"
                    csharp2cuda_temp_11 = true;
                }
                if (csharp2cuda_temp_11)
                {
#line 456 "MatrixModule.cs"
#line 456 "MatrixModule.cs"
                    int* csharp2cuda_temp_14 = &((output)->valid);
                    (*(csharp2cuda_temp_14) = 0);
                }
#line 455 "MatrixModule.cs"
                int* csharp2cuda_temp_9 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
            }
        }
    }
#line 458 "MatrixModule.cs"
    __syncthreads();
#line 459 "MatrixModule.cs"
#line 459 "MatrixModule.cs"
    bool csharp2cuda_temp_15 = (output)->valid;
    if ((!(csharp2cuda_temp_15)))
    {
#line 460 "MatrixModule.cs"
        return;
    }
#line 462 "MatrixModule.cs"
    double* csharp2cuda_temp_16;
#line 462 "MatrixModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 462 "MatrixModule.cs"
        csharp2cuda_temp_16 = ((double*)(nullptr));
    }
    else
    {
#line 462 "MatrixModule.cs"
        unsigned long long csharp2cuda_temp_17 = (first)->data_pointer;
#line 462 "MatrixModule.cs"
        csharp2cuda_temp_16 = ((double*)(csharp2cuda_temp_17));
    }
#line 462 "MatrixModule.cs"
    const double* a = csharp2cuda_temp_16;
#line 463 "MatrixModule.cs"
    double* csharp2cuda_temp_18;
#line 463 "MatrixModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 463 "MatrixModule.cs"
        csharp2cuda_temp_18 = ((double*)(nullptr));
    }
    else
    {
#line 463 "MatrixModule.cs"
        unsigned long long csharp2cuda_temp_19 = (second)->data_pointer;
#line 463 "MatrixModule.cs"
        csharp2cuda_temp_18 = ((double*)(csharp2cuda_temp_19));
    }
#line 463 "MatrixModule.cs"
    const double* b = csharp2cuda_temp_18;
#line 464 "MatrixModule.cs"
    unsigned long long csharp2cuda_temp_20 = (output)->data_pointer;
#line 464 "MatrixModule.cs"
    double* result = ((double*)(csharp2cuda_temp_20));
#line 465 "MatrixModule.cs"
    unsigned long long csharp2cuda_temp_21 = (output)->scratch_pointer;
#line 465 "MatrixModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_21));
#line 467 "MatrixModule.cs"
#line 467 "MatrixModule.cs"
    bool csharp2cuda_temp_22;
#line 467 "MatrixModule.cs"
    if (!(((opcode) == (0))))
    {
#line 467 "MatrixModule.cs"
        csharp2cuda_temp_22 = ((opcode) == (10));
    }
    else
    {
#line 467 "MatrixModule.cs"
        csharp2cuda_temp_22 = true;
    }
#line 467 "MatrixModule.cs"
    bool csharp2cuda_temp_23;
#line 467 "MatrixModule.cs"
    if (!(csharp2cuda_temp_22))
    {
#line 467 "MatrixModule.cs"
        csharp2cuda_temp_23 = ((opcode) == (22));
    }
    else
    {
#line 467 "MatrixModule.cs"
        csharp2cuda_temp_23 = true;
    }
    if (csharp2cuda_temp_23)
#line 468 "MatrixModule.cs"
    {
#line 469 "MatrixModule.cs"
        if (((thread) == (0)))
#line 470 "MatrixModule.cs"
        {
#line 471 "MatrixModule.cs"
#line 471 "MatrixModule.cs"
            int csharp2cuda_temp_24 = (first)->rows;
#line 471 "MatrixModule.cs"
            int csharp2cuda_temp_25 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_24, csharp2cuda_temp_25);
#line 472 "MatrixModule.cs"
#line 472 "MatrixModule.cs"
            bool csharp2cuda_temp_26 = mathblocks_matrix_compatible(first, second);
            if ((!(csharp2cuda_temp_26)))
            {
#line 472 "MatrixModule.cs"
#line 472 "MatrixModule.cs"
                int* csharp2cuda_temp_27 = &((output)->valid);
                (*(csharp2cuda_temp_27) = 0);
            }
        }
#line 474 "MatrixModule.cs"
        __syncthreads();
#line 475 "MatrixModule.cs"
        {
#line 475 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 475 "MatrixModule.cs"
                bool csharp2cuda_temp_30 = (output)->valid;
#line 475 "MatrixModule.cs"
                bool csharp2cuda_temp_31;
#line 475 "MatrixModule.cs"
                if (csharp2cuda_temp_30)
                {
#line 475 "MatrixModule.cs"
                    int csharp2cuda_temp_32 = (first)->count;
#line 475 "MatrixModule.cs"
                    csharp2cuda_temp_31 = ((index) < (csharp2cuda_temp_32));
                }
                else
                {
#line 475 "MatrixModule.cs"
                    csharp2cuda_temp_31 = false;
                }
                if (!(csharp2cuda_temp_31))
                    break;
#line 476 "MatrixModule.cs"
                {
#line 477 "MatrixModule.cs"
                    double csharp2cuda_temp_33;
#line 477 "MatrixModule.cs"
                    if (((opcode) == (0)))
                    {
#line 477 "MatrixModule.cs"
                        double csharp2cuda_temp_34 = (a)[index];
#line 477 "MatrixModule.cs"
                        double csharp2cuda_temp_35 = (b)[index];
#line 477 "MatrixModule.cs"
                        csharp2cuda_temp_33 = __dadd_rn(csharp2cuda_temp_34, csharp2cuda_temp_35);
                    }
                    else
                    {
#line 478 "MatrixModule.cs"
                        double csharp2cuda_temp_36;
#line 478 "MatrixModule.cs"
                        if (((opcode) == (10)))
                        {
#line 478 "MatrixModule.cs"
                            double csharp2cuda_temp_37 = (a)[index];
#line 478 "MatrixModule.cs"
                            double csharp2cuda_temp_38 = (b)[index];
#line 478 "MatrixModule.cs"
                            csharp2cuda_temp_36 = __dmul_rn(csharp2cuda_temp_37, csharp2cuda_temp_38);
                        }
                        else
                        {
#line 479 "MatrixModule.cs"
                            double csharp2cuda_temp_39 = (a)[index];
#line 479 "MatrixModule.cs"
                            double csharp2cuda_temp_40 = (b)[index];
#line 478 "MatrixModule.cs"
                            csharp2cuda_temp_36 = __dsub_rn(csharp2cuda_temp_39, csharp2cuda_temp_40);
                        }
#line 477 "MatrixModule.cs"
                        csharp2cuda_temp_33 = csharp2cuda_temp_36;
                    }
#line 477 "MatrixModule.cs"
                    double value = csharp2cuda_temp_33;
#line 480 "MatrixModule.cs"
#line 480 "MatrixModule.cs"
                    double* csharp2cuda_temp_41 = &((result)[index]);
                    (*(csharp2cuda_temp_41) = value);
#line 481 "MatrixModule.cs"
                    if ((!(isfinite(value))))
                    {
#line 481 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 475 "MatrixModule.cs"
                int* csharp2cuda_temp_28 = &(index);
#line 475 "MatrixModule.cs"
                int csharp2cuda_temp_29 = *(csharp2cuda_temp_28);
                (*(csharp2cuda_temp_28) = csharp2cuda_i32_add(csharp2cuda_temp_29, blockDim.x));
            }
        }
#line 483 "MatrixModule.cs"
        return;
    }
#line 486 "MatrixModule.cs"
    if (((opcode) == (1)))
#line 487 "MatrixModule.cs"
    {
#line 488 "MatrixModule.cs"
        if (((thread) == (0)))
#line 489 "MatrixModule.cs"
        {
#line 490 "MatrixModule.cs"
#line 490 "MatrixModule.cs"
            int csharp2cuda_temp_42 = (first)->rows;
#line 490 "MatrixModule.cs"
            int csharp2cuda_temp_43 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_42, 1), csharp2cuda_temp_43);
#line 491 "MatrixModule.cs"
#line 491 "MatrixModule.cs"
            int csharp2cuda_temp_44 = (second)->count;
#line 491 "MatrixModule.cs"
            int csharp2cuda_temp_45 = (first)->columns;
            if (((csharp2cuda_temp_44) != (csharp2cuda_temp_45)))
            {
#line 491 "MatrixModule.cs"
#line 491 "MatrixModule.cs"
                int* csharp2cuda_temp_46 = &((output)->valid);
                (*(csharp2cuda_temp_46) = 0);
            }
        }
#line 493 "MatrixModule.cs"
        __syncthreads();
#line 494 "MatrixModule.cs"
        {
#line 494 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 494 "MatrixModule.cs"
                bool csharp2cuda_temp_49 = (output)->valid;
#line 494 "MatrixModule.cs"
                bool csharp2cuda_temp_50;
#line 494 "MatrixModule.cs"
                if (csharp2cuda_temp_49)
                {
#line 494 "MatrixModule.cs"
                    int csharp2cuda_temp_51 = (output)->count;
#line 494 "MatrixModule.cs"
                    csharp2cuda_temp_50 = ((index) < (csharp2cuda_temp_51));
                }
                else
                {
#line 494 "MatrixModule.cs"
                    csharp2cuda_temp_50 = false;
                }
                if (!(csharp2cuda_temp_50))
                    break;
#line 495 "MatrixModule.cs"
#line 495 "MatrixModule.cs"
                double* csharp2cuda_temp_52 = &((result)[index]);
#line 495 "MatrixModule.cs"
                int csharp2cuda_temp_53 = (first)->count;
#line 495 "MatrixModule.cs"
                double csharp2cuda_temp_54;
#line 495 "MatrixModule.cs"
                if (((index) < (csharp2cuda_temp_53)))
                {
#line 495 "MatrixModule.cs"
                    csharp2cuda_temp_54 = (a)[index];
                }
                else
                {
#line 495 "MatrixModule.cs"
                    int csharp2cuda_temp_55 = (first)->count;
#line 495 "MatrixModule.cs"
                    csharp2cuda_temp_54 = (b)[csharp2cuda_i32_sub(index, csharp2cuda_temp_55)];
                }
                (*(csharp2cuda_temp_52) = csharp2cuda_temp_54);
#line 494 "MatrixModule.cs"
                int* csharp2cuda_temp_47 = &(index);
#line 494 "MatrixModule.cs"
                int csharp2cuda_temp_48 = *(csharp2cuda_temp_47);
                (*(csharp2cuda_temp_47) = csharp2cuda_i32_add(csharp2cuda_temp_48, blockDim.x));
            }
        }
#line 496 "MatrixModule.cs"
        return;
    }
#line 499 "MatrixModule.cs"
#line 499 "MatrixModule.cs"
    bool csharp2cuda_temp_56;
#line 499 "MatrixModule.cs"
    if (!(((opcode) == (2))))
    {
#line 499 "MatrixModule.cs"
        csharp2cuda_temp_56 = ((opcode) == (18));
    }
    else
    {
#line 499 "MatrixModule.cs"
        csharp2cuda_temp_56 = true;
    }
    if (csharp2cuda_temp_56)
#line 500 "MatrixModule.cs"
    {
#line 501 "MatrixModule.cs"
        int csharp2cuda_temp_57;
#line 501 "MatrixModule.cs"
        if (((opcode) == (2)))
        {
#line 501 "MatrixModule.cs"
            csharp2cuda_temp_57 = (first)->columns;
        }
        else
        {
#line 501 "MatrixModule.cs"
            csharp2cuda_temp_57 = (first)->rows;
        }
#line 501 "MatrixModule.cs"
        int count = csharp2cuda_temp_57;
#line 502 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 502 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 503 "MatrixModule.cs"
        __syncthreads();
#line 504 "MatrixModule.cs"
        {
#line 504 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 504 "MatrixModule.cs"
                bool csharp2cuda_temp_60 = (output)->valid;
#line 504 "MatrixModule.cs"
                bool csharp2cuda_temp_61;
#line 504 "MatrixModule.cs"
                if (csharp2cuda_temp_60)
                {
#line 504 "MatrixModule.cs"
                    csharp2cuda_temp_61 = ((index) < (count));
                }
                else
                {
#line 504 "MatrixModule.cs"
                    csharp2cuda_temp_61 = false;
                }
                if (!(csharp2cuda_temp_61))
                    break;
#line 505 "MatrixModule.cs"
                {
#line 506 "MatrixModule.cs"
                    double sum = 0.0;
#line 507 "MatrixModule.cs"
                    if (((opcode) == (2)))
#line 508 "MatrixModule.cs"
                    {
#line 509 "MatrixModule.cs"
                        {
#line 509 "MatrixModule.cs"
                            int row = 0;
                            while (true)
                            {
#line 509 "MatrixModule.cs"
                                int csharp2cuda_temp_63 = (first)->rows;
                                if (!(((row) < (csharp2cuda_temp_63))))
                                    break;
#line 510 "MatrixModule.cs"
#line 510 "MatrixModule.cs"
                                double* csharp2cuda_temp_64 = &(sum);
#line 510 "MatrixModule.cs"
                                double csharp2cuda_temp_65 = *(csharp2cuda_temp_64);
#line 510 "MatrixModule.cs"
                                int csharp2cuda_temp_66 = (first)->columns;
#line 510 "MatrixModule.cs"
                                double csharp2cuda_temp_67 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_66), index)];
                                (*(csharp2cuda_temp_64) = __dadd_rn(csharp2cuda_temp_65, csharp2cuda_temp_67));
#line 509 "MatrixModule.cs"
                                int* csharp2cuda_temp_62 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_62));
                            }
                        }
                    }
                    else
#line 513 "MatrixModule.cs"
                    {
#line 514 "MatrixModule.cs"
                        {
#line 514 "MatrixModule.cs"
                            int column = 0;
                            while (true)
                            {
#line 514 "MatrixModule.cs"
                                int csharp2cuda_temp_69 = (first)->columns;
                                if (!(((column) < (csharp2cuda_temp_69))))
                                    break;
#line 515 "MatrixModule.cs"
#line 515 "MatrixModule.cs"
                                double* csharp2cuda_temp_70 = &(sum);
#line 515 "MatrixModule.cs"
                                double csharp2cuda_temp_71 = *(csharp2cuda_temp_70);
#line 515 "MatrixModule.cs"
                                int csharp2cuda_temp_72 = (first)->columns;
#line 515 "MatrixModule.cs"
                                double csharp2cuda_temp_73 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_72), column)];
                                (*(csharp2cuda_temp_70) = __dadd_rn(csharp2cuda_temp_71, csharp2cuda_temp_73));
#line 514 "MatrixModule.cs"
                                int* csharp2cuda_temp_68 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                            }
                        }
                    }
#line 517 "MatrixModule.cs"
#line 517 "MatrixModule.cs"
                    double* csharp2cuda_temp_74 = &((result)[index]);
                    (*(csharp2cuda_temp_74) = sum);
#line 518 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 518 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 504 "MatrixModule.cs"
                int* csharp2cuda_temp_58 = &(index);
#line 504 "MatrixModule.cs"
                int csharp2cuda_temp_59 = *(csharp2cuda_temp_58);
                (*(csharp2cuda_temp_58) = csharp2cuda_i32_add(csharp2cuda_temp_59, blockDim.x));
            }
        }
#line 520 "MatrixModule.cs"
        return;
    }
#line 523 "MatrixModule.cs"
#line 523 "MatrixModule.cs"
    bool csharp2cuda_temp_75;
#line 523 "MatrixModule.cs"
    if (!(((opcode) == (3))))
    {
#line 523 "MatrixModule.cs"
        csharp2cuda_temp_75 = ((opcode) == (19));
    }
    else
    {
#line 523 "MatrixModule.cs"
        csharp2cuda_temp_75 = true;
    }
    if (csharp2cuda_temp_75)
#line 524 "MatrixModule.cs"
    {
#line 525 "MatrixModule.cs"
        int selected = 0;
#line 526 "MatrixModule.cs"
        double csharp2cuda_temp_76 = (second)->scalar_value;
#line 526 "MatrixModule.cs"
        int* csharp2cuda_temp_77 = &(selected);
#line 526 "MatrixModule.cs"
        bool valid_index = mathblocks_nonnegative_integer(csharp2cuda_temp_76, csharp2cuda_temp_77);
#line 527 "MatrixModule.cs"
        int csharp2cuda_temp_78;
#line 527 "MatrixModule.cs"
        if (((opcode) == (3)))
        {
#line 527 "MatrixModule.cs"
            csharp2cuda_temp_78 = (first)->columns;
        }
        else
        {
#line 527 "MatrixModule.cs"
            csharp2cuda_temp_78 = (first)->rows;
        }
#line 527 "MatrixModule.cs"
        int limit = csharp2cuda_temp_78;
#line 528 "MatrixModule.cs"
        int csharp2cuda_temp_79;
#line 528 "MatrixModule.cs"
        if (((opcode) == (3)))
        {
#line 528 "MatrixModule.cs"
            csharp2cuda_temp_79 = (first)->rows;
        }
        else
        {
#line 528 "MatrixModule.cs"
            csharp2cuda_temp_79 = (first)->columns;
        }
#line 528 "MatrixModule.cs"
        int count = csharp2cuda_temp_79;
#line 529 "MatrixModule.cs"
        if (((thread) == (0)))
#line 530 "MatrixModule.cs"
        {
#line 531 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, count);
#line 532 "MatrixModule.cs"
#line 532 "MatrixModule.cs"
            bool csharp2cuda_temp_80;
#line 532 "MatrixModule.cs"
            if (!((!(valid_index))))
            {
#line 532 "MatrixModule.cs"
                csharp2cuda_temp_80 = ((selected) >= (limit));
            }
            else
            {
#line 532 "MatrixModule.cs"
                csharp2cuda_temp_80 = true;
            }
            if (csharp2cuda_temp_80)
            {
#line 532 "MatrixModule.cs"
#line 532 "MatrixModule.cs"
                int* csharp2cuda_temp_81 = &((output)->valid);
                (*(csharp2cuda_temp_81) = 0);
            }
        }
#line 534 "MatrixModule.cs"
        __syncthreads();
#line 535 "MatrixModule.cs"
        {
#line 535 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 535 "MatrixModule.cs"
                bool csharp2cuda_temp_84 = (output)->valid;
#line 535 "MatrixModule.cs"
                bool csharp2cuda_temp_85;
#line 535 "MatrixModule.cs"
                if (csharp2cuda_temp_84)
                {
#line 535 "MatrixModule.cs"
                    csharp2cuda_temp_85 = ((index) < (count));
                }
                else
                {
#line 535 "MatrixModule.cs"
                    csharp2cuda_temp_85 = false;
                }
                if (!(csharp2cuda_temp_85))
                    break;
#line 536 "MatrixModule.cs"
#line 536 "MatrixModule.cs"
                double* csharp2cuda_temp_86 = &((result)[index]);
#line 536 "MatrixModule.cs"
                double csharp2cuda_temp_87;
#line 536 "MatrixModule.cs"
                if (((opcode) == (3)))
                {
#line 537 "MatrixModule.cs"
                    int csharp2cuda_temp_88 = (first)->columns;
#line 536 "MatrixModule.cs"
                    csharp2cuda_temp_87 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_88), selected)];
                }
                else
                {
#line 538 "MatrixModule.cs"
                    int csharp2cuda_temp_89 = (first)->columns;
#line 536 "MatrixModule.cs"
                    csharp2cuda_temp_87 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(selected, csharp2cuda_temp_89), index)];
                }
                (*(csharp2cuda_temp_86) = csharp2cuda_temp_87);
#line 535 "MatrixModule.cs"
                int* csharp2cuda_temp_82 = &(index);
#line 535 "MatrixModule.cs"
                int csharp2cuda_temp_83 = *(csharp2cuda_temp_82);
                (*(csharp2cuda_temp_82) = csharp2cuda_i32_add(csharp2cuda_temp_83, blockDim.x));
            }
        }
#line 539 "MatrixModule.cs"
        return;
    }
#line 542 "MatrixModule.cs"
    if (((opcode) == (4)))
#line 543 "MatrixModule.cs"
    {
#line 544 "MatrixModule.cs"
        if (((thread) == (0)))
#line 545 "MatrixModule.cs"
        {
#line 546 "MatrixModule.cs"
#line 546 "MatrixModule.cs"
            int csharp2cuda_temp_90 = (first)->rows;
#line 546 "MatrixModule.cs"
            int csharp2cuda_temp_91 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_90, csharp2cuda_temp_91);
#line 547 "MatrixModule.cs"
#line 547 "MatrixModule.cs"
            bool csharp2cuda_temp_92 = mathblocks_matrix_compatible(first, second);
#line 547 "MatrixModule.cs"
            bool csharp2cuda_temp_93;
#line 547 "MatrixModule.cs"
            if (!((!(csharp2cuda_temp_92))))
            {
#line 547 "MatrixModule.cs"
                int csharp2cuda_temp_94 = (first)->rows;
#line 547 "MatrixModule.cs"
                int csharp2cuda_temp_95 = (first)->columns;
#line 547 "MatrixModule.cs"
                csharp2cuda_temp_93 = ((csharp2cuda_temp_94) != (csharp2cuda_temp_95));
            }
            else
            {
#line 547 "MatrixModule.cs"
                csharp2cuda_temp_93 = true;
            }
            if (csharp2cuda_temp_93)
            {
#line 548 "MatrixModule.cs"
#line 548 "MatrixModule.cs"
                int* csharp2cuda_temp_96 = &((output)->valid);
                (*(csharp2cuda_temp_96) = 0);
            }
        }
#line 550 "MatrixModule.cs"
        __syncthreads();
#line 551 "MatrixModule.cs"
        {
#line 551 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 551 "MatrixModule.cs"
                bool csharp2cuda_temp_99 = (output)->valid;
#line 551 "MatrixModule.cs"
                bool csharp2cuda_temp_100;
#line 551 "MatrixModule.cs"
                if (csharp2cuda_temp_99)
                {
#line 551 "MatrixModule.cs"
                    int csharp2cuda_temp_101 = (output)->count;
#line 551 "MatrixModule.cs"
                    csharp2cuda_temp_100 = ((flat) < (csharp2cuda_temp_101));
                }
                else
                {
#line 551 "MatrixModule.cs"
                    csharp2cuda_temp_100 = false;
                }
                if (!(csharp2cuda_temp_100))
                    break;
#line 552 "MatrixModule.cs"
                {
#line 553 "MatrixModule.cs"
                    int csharp2cuda_temp_102 = (first)->columns;
#line 553 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_102);
#line 554 "MatrixModule.cs"
                    int csharp2cuda_temp_103 = (first)->columns;
#line 554 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_103));
#line 555 "MatrixModule.cs"
                    double left_product = 0.0;
#line 556 "MatrixModule.cs"
                    double right_product = 0.0;
#line 557 "MatrixModule.cs"
                    {
#line 557 "MatrixModule.cs"
                        int inner = 0;
                        while (true)
                        {
#line 557 "MatrixModule.cs"
                            int csharp2cuda_temp_105 = (first)->columns;
                            if (!(((inner) < (csharp2cuda_temp_105))))
                                break;
#line 558 "MatrixModule.cs"
                            {
#line 559 "MatrixModule.cs"
#line 559 "MatrixModule.cs"
                                double* csharp2cuda_temp_106 = &(left_product);
#line 559 "MatrixModule.cs"
                                double csharp2cuda_temp_107 = *(csharp2cuda_temp_106);
#line 559 "MatrixModule.cs"
                                int csharp2cuda_temp_108 = (first)->columns;
#line 559 "MatrixModule.cs"
                                double csharp2cuda_temp_109 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_108), inner)];
#line 560 "MatrixModule.cs"
                                int csharp2cuda_temp_110 = (second)->columns;
#line 560 "MatrixModule.cs"
                                double csharp2cuda_temp_111 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_110), column)];
                                (*(csharp2cuda_temp_106) = __dadd_rn(csharp2cuda_temp_107, __dmul_rn(csharp2cuda_temp_109, csharp2cuda_temp_111)));
#line 561 "MatrixModule.cs"
#line 561 "MatrixModule.cs"
                                double* csharp2cuda_temp_112 = &(right_product);
#line 561 "MatrixModule.cs"
                                double csharp2cuda_temp_113 = *(csharp2cuda_temp_112);
#line 561 "MatrixModule.cs"
                                int csharp2cuda_temp_114 = (second)->columns;
#line 561 "MatrixModule.cs"
                                double csharp2cuda_temp_115 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_114), inner)];
#line 562 "MatrixModule.cs"
                                int csharp2cuda_temp_116 = (first)->columns;
#line 562 "MatrixModule.cs"
                                double csharp2cuda_temp_117 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_116), column)];
                                (*(csharp2cuda_temp_112) = __dadd_rn(csharp2cuda_temp_113, __dmul_rn(csharp2cuda_temp_115, csharp2cuda_temp_117)));
                            }
#line 557 "MatrixModule.cs"
                            int* csharp2cuda_temp_104 = &(inner);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_104));
                        }
                    }
#line 564 "MatrixModule.cs"
#line 564 "MatrixModule.cs"
                    double* csharp2cuda_temp_118 = &((result)[flat]);
                    (*(csharp2cuda_temp_118) = __dsub_rn(left_product, right_product));
#line 565 "MatrixModule.cs"
#line 565 "MatrixModule.cs"
                    double csharp2cuda_temp_119 = (result)[flat];
                    if ((!(isfinite(csharp2cuda_temp_119))))
                    {
#line 565 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 551 "MatrixModule.cs"
                int* csharp2cuda_temp_97 = &(flat);
#line 551 "MatrixModule.cs"
                int csharp2cuda_temp_98 = *(csharp2cuda_temp_97);
                (*(csharp2cuda_temp_97) = csharp2cuda_i32_add(csharp2cuda_temp_98, blockDim.x));
            }
        }
#line 567 "MatrixModule.cs"
        return;
    }
#line 570 "MatrixModule.cs"
    if (((opcode) == (5)))
#line 571 "MatrixModule.cs"
    {
#line 572 "MatrixModule.cs"
        int size = (first)->count;
#line 573 "MatrixModule.cs"
        if (((thread) == (0)))
#line 574 "MatrixModule.cs"
        {
#line 575 "MatrixModule.cs"
            mathblocks_matrix_shape(output, size, size);
#line 576 "MatrixModule.cs"
            if (((size) <= (0)))
            {
#line 576 "MatrixModule.cs"
#line 576 "MatrixModule.cs"
                int* csharp2cuda_temp_120 = &((output)->valid);
                (*(csharp2cuda_temp_120) = 0);
            }
        }
#line 578 "MatrixModule.cs"
        __syncthreads();
#line 579 "MatrixModule.cs"
        {
#line 579 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 579 "MatrixModule.cs"
                bool csharp2cuda_temp_123 = (output)->valid;
#line 579 "MatrixModule.cs"
                bool csharp2cuda_temp_124;
#line 579 "MatrixModule.cs"
                if (csharp2cuda_temp_123)
                {
#line 579 "MatrixModule.cs"
                    csharp2cuda_temp_124 = ((flat) < (csharp2cuda_i32_mul(size, size)));
                }
                else
                {
#line 579 "MatrixModule.cs"
                    csharp2cuda_temp_124 = false;
                }
                if (!(csharp2cuda_temp_124))
                    break;
#line 580 "MatrixModule.cs"
                {
#line 581 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, size);
#line 582 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, size));
#line 583 "MatrixModule.cs"
#line 583 "MatrixModule.cs"
                    double* csharp2cuda_temp_125 = &((result)[flat]);
#line 583 "MatrixModule.cs"
                    double csharp2cuda_temp_126;
#line 583 "MatrixModule.cs"
                    if (((row) == (column)))
                    {
#line 583 "MatrixModule.cs"
                        csharp2cuda_temp_126 = (a)[row];
                    }
                    else
                    {
#line 583 "MatrixModule.cs"
                        csharp2cuda_temp_126 = 0.0;
                    }
                    (*(csharp2cuda_temp_125) = csharp2cuda_temp_126);
                }
#line 579 "MatrixModule.cs"
                int* csharp2cuda_temp_121 = &(flat);
#line 579 "MatrixModule.cs"
                int csharp2cuda_temp_122 = *(csharp2cuda_temp_121);
                (*(csharp2cuda_temp_121) = csharp2cuda_i32_add(csharp2cuda_temp_122, blockDim.x));
            }
        }
#line 585 "MatrixModule.cs"
        return;
    }
#line 588 "MatrixModule.cs"
    if (((opcode) == (6)))
#line 589 "MatrixModule.cs"
    {
#line 590 "MatrixModule.cs"
        int csharp2cuda_temp_127 = (first)->rows;
#line 590 "MatrixModule.cs"
        int csharp2cuda_temp_128 = (first)->columns;
#line 590 "MatrixModule.cs"
        int csharp2cuda_temp_129;
#line 590 "MatrixModule.cs"
        if (((csharp2cuda_temp_127) < (csharp2cuda_temp_128)))
        {
#line 590 "MatrixModule.cs"
            csharp2cuda_temp_129 = (first)->rows;
        }
        else
        {
#line 590 "MatrixModule.cs"
            csharp2cuda_temp_129 = (first)->columns;
        }
#line 590 "MatrixModule.cs"
        int count = csharp2cuda_temp_129;
#line 591 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 591 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 592 "MatrixModule.cs"
        __syncthreads();
#line 593 "MatrixModule.cs"
        {
#line 593 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 593 "MatrixModule.cs"
                bool csharp2cuda_temp_132 = (output)->valid;
#line 593 "MatrixModule.cs"
                bool csharp2cuda_temp_133;
#line 593 "MatrixModule.cs"
                if (csharp2cuda_temp_132)
                {
#line 593 "MatrixModule.cs"
                    csharp2cuda_temp_133 = ((index) < (count));
                }
                else
                {
#line 593 "MatrixModule.cs"
                    csharp2cuda_temp_133 = false;
                }
                if (!(csharp2cuda_temp_133))
                    break;
#line 594 "MatrixModule.cs"
#line 594 "MatrixModule.cs"
                double* csharp2cuda_temp_134 = &((result)[index]);
#line 594 "MatrixModule.cs"
                int csharp2cuda_temp_135 = (first)->columns;
#line 594 "MatrixModule.cs"
                double csharp2cuda_temp_136 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_135), index)];
                (*(csharp2cuda_temp_134) = csharp2cuda_temp_136);
#line 593 "MatrixModule.cs"
                int* csharp2cuda_temp_130 = &(index);
#line 593 "MatrixModule.cs"
                int csharp2cuda_temp_131 = *(csharp2cuda_temp_130);
                (*(csharp2cuda_temp_130) = csharp2cuda_i32_add(csharp2cuda_temp_131, blockDim.x));
            }
        }
#line 595 "MatrixModule.cs"
        return;
    }
#line 598 "MatrixModule.cs"
    if (((opcode) == (7)))
#line 599 "MatrixModule.cs"
    {
#line 600 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 600 "MatrixModule.cs"
#line 600 "MatrixModule.cs"
            int csharp2cuda_temp_137 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_137);
        }
#line 601 "MatrixModule.cs"
        __syncthreads();
#line 602 "MatrixModule.cs"
        {
#line 602 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 602 "MatrixModule.cs"
                bool csharp2cuda_temp_140 = (output)->valid;
#line 602 "MatrixModule.cs"
                bool csharp2cuda_temp_141;
#line 602 "MatrixModule.cs"
                if (csharp2cuda_temp_140)
                {
#line 602 "MatrixModule.cs"
                    int csharp2cuda_temp_142 = (first)->count;
#line 602 "MatrixModule.cs"
                    csharp2cuda_temp_141 = ((index) < (csharp2cuda_temp_142));
                }
                else
                {
#line 602 "MatrixModule.cs"
                    csharp2cuda_temp_141 = false;
                }
                if (!(csharp2cuda_temp_141))
                    break;
#line 603 "MatrixModule.cs"
#line 603 "MatrixModule.cs"
                double* csharp2cuda_temp_143 = &((result)[index]);
#line 603 "MatrixModule.cs"
                double csharp2cuda_temp_144 = (a)[index];
                (*(csharp2cuda_temp_143) = csharp2cuda_temp_144);
#line 602 "MatrixModule.cs"
                int* csharp2cuda_temp_138 = &(index);
#line 602 "MatrixModule.cs"
                int csharp2cuda_temp_139 = *(csharp2cuda_temp_138);
                (*(csharp2cuda_temp_138) = csharp2cuda_i32_add(csharp2cuda_temp_139, blockDim.x));
            }
        }
#line 604 "MatrixModule.cs"
        return;
    }
#line 607 "MatrixModule.cs"
    if (((opcode) == (8)))
#line 608 "MatrixModule.cs"
    {
#line 609 "MatrixModule.cs"
        if (((thread) == (0)))
#line 610 "MatrixModule.cs"
        {
#line 611 "MatrixModule.cs"
#line 611 "MatrixModule.cs"
            double* csharp2cuda_temp_145 = &((output)->scalar_value);
#line 612 "MatrixModule.cs"
            int csharp2cuda_temp_146 = (first)->count;
            (*(csharp2cuda_temp_145) = mathblocks_square_root(mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_146)));
#line 613 "MatrixModule.cs"
#line 613 "MatrixModule.cs"
            double csharp2cuda_temp_147 = (output)->scalar_value;
            if ((!(isfinite(csharp2cuda_temp_147))))
            {
#line 613 "MatrixModule.cs"
#line 613 "MatrixModule.cs"
                int* csharp2cuda_temp_148 = &((output)->valid);
                (*(csharp2cuda_temp_148) = 0);
            }
        }
#line 615 "MatrixModule.cs"
        return;
    }
#line 618 "MatrixModule.cs"
    if (((opcode) == (9)))
#line 619 "MatrixModule.cs"
    {
#line 620 "MatrixModule.cs"
        int size = (first)->columns;
#line 621 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 621 "MatrixModule.cs"
            mathblocks_matrix_shape(output, size, size);
        }
#line 622 "MatrixModule.cs"
        __syncthreads();
#line 623 "MatrixModule.cs"
        {
#line 623 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 623 "MatrixModule.cs"
                bool csharp2cuda_temp_151 = (output)->valid;
#line 623 "MatrixModule.cs"
                bool csharp2cuda_temp_152;
#line 623 "MatrixModule.cs"
                if (csharp2cuda_temp_151)
                {
#line 623 "MatrixModule.cs"
                    csharp2cuda_temp_152 = ((flat) < (csharp2cuda_i32_mul(size, size)));
                }
                else
                {
#line 623 "MatrixModule.cs"
                    csharp2cuda_temp_152 = false;
                }
                if (!(csharp2cuda_temp_152))
                    break;
#line 624 "MatrixModule.cs"
                {
#line 625 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, size);
#line 626 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, size));
#line 627 "MatrixModule.cs"
                    double sum = 0.0;
#line 628 "MatrixModule.cs"
                    {
#line 628 "MatrixModule.cs"
                        int inner = 0;
                        while (true)
                        {
#line 628 "MatrixModule.cs"
                            int csharp2cuda_temp_154 = (first)->rows;
                            if (!(((inner) < (csharp2cuda_temp_154))))
                                break;
#line 629 "MatrixModule.cs"
#line 629 "MatrixModule.cs"
                            double* csharp2cuda_temp_155 = &(sum);
#line 629 "MatrixModule.cs"
                            double csharp2cuda_temp_156 = *(csharp2cuda_temp_155);
#line 629 "MatrixModule.cs"
                            int csharp2cuda_temp_157 = (first)->columns;
#line 629 "MatrixModule.cs"
                            double csharp2cuda_temp_158 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_157), row)];
#line 629 "MatrixModule.cs"
                            int csharp2cuda_temp_159 = (first)->columns;
#line 629 "MatrixModule.cs"
                            double csharp2cuda_temp_160 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_159), column)];
                            (*(csharp2cuda_temp_155) = __dadd_rn(csharp2cuda_temp_156, __dmul_rn(csharp2cuda_temp_158, csharp2cuda_temp_160)));
#line 628 "MatrixModule.cs"
                            int* csharp2cuda_temp_153 = &(inner);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                        }
                    }
#line 630 "MatrixModule.cs"
#line 630 "MatrixModule.cs"
                    double* csharp2cuda_temp_161 = &((result)[flat]);
                    (*(csharp2cuda_temp_161) = sum);
#line 631 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 631 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 623 "MatrixModule.cs"
                int* csharp2cuda_temp_149 = &(flat);
#line 623 "MatrixModule.cs"
                int csharp2cuda_temp_150 = *(csharp2cuda_temp_149);
                (*(csharp2cuda_temp_149) = csharp2cuda_i32_add(csharp2cuda_temp_150, blockDim.x));
            }
        }
#line 633 "MatrixModule.cs"
        return;
    }
#line 636 "MatrixModule.cs"
#line 636 "MatrixModule.cs"
    bool csharp2cuda_temp_162;
#line 636 "MatrixModule.cs"
    if (!(((opcode) == (11))))
    {
#line 636 "MatrixModule.cs"
        csharp2cuda_temp_162 = ((opcode) == (23));
    }
    else
    {
#line 636 "MatrixModule.cs"
        csharp2cuda_temp_162 = true;
    }
    if (csharp2cuda_temp_162)
#line 637 "MatrixModule.cs"
    {
#line 638 "MatrixModule.cs"
        if (((thread) == (0)))
#line 639 "MatrixModule.cs"
        {
#line 640 "MatrixModule.cs"
#line 640 "MatrixModule.cs"
            int csharp2cuda_temp_163 = (first)->count;
#line 640 "MatrixModule.cs"
            int csharp2cuda_temp_164 = (second)->count;
            mathblocks_matrix_shape(output, csharp2cuda_temp_163, csharp2cuda_temp_164);
#line 641 "MatrixModule.cs"
#line 641 "MatrixModule.cs"
            int csharp2cuda_temp_165 = (first)->count;
#line 641 "MatrixModule.cs"
            bool csharp2cuda_temp_166;
#line 641 "MatrixModule.cs"
            if (!(((csharp2cuda_temp_165) <= (0))))
            {
#line 641 "MatrixModule.cs"
                int csharp2cuda_temp_167 = (second)->count;
#line 641 "MatrixModule.cs"
                csharp2cuda_temp_166 = ((csharp2cuda_temp_167) <= (0));
            }
            else
            {
#line 641 "MatrixModule.cs"
                csharp2cuda_temp_166 = true;
            }
#line 641 "MatrixModule.cs"
            bool csharp2cuda_temp_168;
#line 641 "MatrixModule.cs"
            if (!(csharp2cuda_temp_166))
            {
#line 642 "MatrixModule.cs"
                bool csharp2cuda_temp_169;
#line 642 "MatrixModule.cs"
                if (((opcode) == (11)))
                {
#line 642 "MatrixModule.cs"
                    int csharp2cuda_temp_170 = (first)->count;
#line 642 "MatrixModule.cs"
                    double csharp2cuda_temp_171 = (a)[csharp2cuda_i32_sub(csharp2cuda_temp_170, 1)];
#line 642 "MatrixModule.cs"
                    double csharp2cuda_temp_172 = (b)[0];
#line 642 "MatrixModule.cs"
                    csharp2cuda_temp_169 = ((csharp2cuda_temp_171) != (csharp2cuda_temp_172));
                }
                else
                {
#line 642 "MatrixModule.cs"
                    double csharp2cuda_temp_173 = (a)[0];
#line 642 "MatrixModule.cs"
                    double csharp2cuda_temp_174 = (b)[0];
#line 642 "MatrixModule.cs"
                    csharp2cuda_temp_169 = ((csharp2cuda_temp_173) != (csharp2cuda_temp_174));
                }
#line 641 "MatrixModule.cs"
                csharp2cuda_temp_168 = csharp2cuda_temp_169;
            }
            else
            {
#line 641 "MatrixModule.cs"
                csharp2cuda_temp_168 = true;
            }
            if (csharp2cuda_temp_168)
#line 643 "MatrixModule.cs"
            {
#line 644 "MatrixModule.cs"
#line 644 "MatrixModule.cs"
                int* csharp2cuda_temp_175 = &((output)->valid);
                (*(csharp2cuda_temp_175) = 0);
            }
        }
#line 647 "MatrixModule.cs"
        __syncthreads();
#line 648 "MatrixModule.cs"
        {
#line 648 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 648 "MatrixModule.cs"
                bool csharp2cuda_temp_178 = (output)->valid;
#line 648 "MatrixModule.cs"
                bool csharp2cuda_temp_179;
#line 648 "MatrixModule.cs"
                if (csharp2cuda_temp_178)
                {
#line 648 "MatrixModule.cs"
                    int csharp2cuda_temp_180 = (output)->count;
#line 648 "MatrixModule.cs"
                    csharp2cuda_temp_179 = ((flat) < (csharp2cuda_temp_180));
                }
                else
                {
#line 648 "MatrixModule.cs"
                    csharp2cuda_temp_179 = false;
                }
                if (!(csharp2cuda_temp_179))
                    break;
#line 649 "MatrixModule.cs"
                {
#line 650 "MatrixModule.cs"
                    int csharp2cuda_temp_181 = (second)->count;
#line 650 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_181);
#line 651 "MatrixModule.cs"
                    int csharp2cuda_temp_182 = (second)->count;
#line 651 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_182));
#line 652 "MatrixModule.cs"
                    if (((opcode) == (23)))
#line 653 "MatrixModule.cs"
                    {
#line 654 "MatrixModule.cs"
#line 654 "MatrixModule.cs"
                        double* csharp2cuda_temp_183 = &((result)[flat]);
#line 654 "MatrixModule.cs"
                        double csharp2cuda_temp_184;
#line 654 "MatrixModule.cs"
                        if (((column) >= (row)))
                        {
#line 654 "MatrixModule.cs"
                            csharp2cuda_temp_184 = (b)[csharp2cuda_i32_sub(column, row)];
                        }
                        else
                        {
#line 654 "MatrixModule.cs"
                            csharp2cuda_temp_184 = (a)[csharp2cuda_i32_sub(row, column)];
                        }
                        (*(csharp2cuda_temp_183) = csharp2cuda_temp_184);
                    }
                    else
#line 657 "MatrixModule.cs"
                    {
#line 658 "MatrixModule.cs"
                        int index = csharp2cuda_i32_add(row, column);
#line 659 "MatrixModule.cs"
#line 659 "MatrixModule.cs"
                        double* csharp2cuda_temp_185 = &((result)[flat]);
#line 659 "MatrixModule.cs"
                        int csharp2cuda_temp_186 = (first)->count;
#line 659 "MatrixModule.cs"
                        double csharp2cuda_temp_187;
#line 659 "MatrixModule.cs"
                        if (((index) < (csharp2cuda_temp_186)))
                        {
#line 659 "MatrixModule.cs"
                            csharp2cuda_temp_187 = (a)[index];
                        }
                        else
                        {
#line 659 "MatrixModule.cs"
                            int csharp2cuda_temp_188 = (first)->count;
#line 659 "MatrixModule.cs"
                            csharp2cuda_temp_187 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, csharp2cuda_temp_188), 1)];
                        }
                        (*(csharp2cuda_temp_185) = csharp2cuda_temp_187);
                    }
                }
#line 648 "MatrixModule.cs"
                int* csharp2cuda_temp_176 = &(flat);
#line 648 "MatrixModule.cs"
                int csharp2cuda_temp_177 = *(csharp2cuda_temp_176);
                (*(csharp2cuda_temp_176) = csharp2cuda_i32_add(csharp2cuda_temp_177, blockDim.x));
            }
        }
#line 662 "MatrixModule.cs"
        return;
    }
#line 665 "MatrixModule.cs"
    if (((opcode) == (12)))
#line 666 "MatrixModule.cs"
    {
#line 667 "MatrixModule.cs"
        int size = 0;
#line 668 "MatrixModule.cs"
        double csharp2cuda_temp_189 = (first)->scalar_value;
#line 668 "MatrixModule.cs"
        int* csharp2cuda_temp_190 = &(size);
#line 668 "MatrixModule.cs"
        bool valid_size = mathblocks_nonnegative_integer(csharp2cuda_temp_189, csharp2cuda_temp_190);
#line 669 "MatrixModule.cs"
        if (((thread) == (0)))
#line 670 "MatrixModule.cs"
        {
#line 671 "MatrixModule.cs"
            mathblocks_matrix_shape(output, size, size);
#line 672 "MatrixModule.cs"
#line 672 "MatrixModule.cs"
            bool csharp2cuda_temp_191;
#line 672 "MatrixModule.cs"
            if (!((!(valid_size))))
            {
#line 672 "MatrixModule.cs"
                csharp2cuda_temp_191 = ((size) <= (0));
            }
            else
            {
#line 672 "MatrixModule.cs"
                csharp2cuda_temp_191 = true;
            }
#line 672 "MatrixModule.cs"
            bool csharp2cuda_temp_192;
#line 672 "MatrixModule.cs"
            if (!(csharp2cuda_temp_191))
            {
#line 672 "MatrixModule.cs"
                csharp2cuda_temp_192 = ((size) > (4096));
            }
            else
            {
#line 672 "MatrixModule.cs"
                csharp2cuda_temp_192 = true;
            }
            if (csharp2cuda_temp_192)
            {
#line 672 "MatrixModule.cs"
#line 672 "MatrixModule.cs"
                int* csharp2cuda_temp_193 = &((output)->valid);
                (*(csharp2cuda_temp_193) = 0);
            }
        }
#line 674 "MatrixModule.cs"
        __syncthreads();
#line 675 "MatrixModule.cs"
        {
#line 675 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 675 "MatrixModule.cs"
                bool csharp2cuda_temp_196 = (output)->valid;
#line 675 "MatrixModule.cs"
                bool csharp2cuda_temp_197;
#line 675 "MatrixModule.cs"
                if (csharp2cuda_temp_196)
                {
#line 675 "MatrixModule.cs"
                    csharp2cuda_temp_197 = ((flat) < (csharp2cuda_i32_mul(size, size)));
                }
                else
                {
#line 675 "MatrixModule.cs"
                    csharp2cuda_temp_197 = false;
                }
                if (!(csharp2cuda_temp_197))
                    break;
#line 676 "MatrixModule.cs"
                {
#line 677 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, size);
#line 678 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, size));
#line 679 "MatrixModule.cs"
#line 679 "MatrixModule.cs"
                    double* csharp2cuda_temp_198 = &((result)[flat]);
#line 679 "MatrixModule.cs"
                    double csharp2cuda_temp_199;
#line 679 "MatrixModule.cs"
                    if (((row) == (column)))
                    {
#line 679 "MatrixModule.cs"
                        csharp2cuda_temp_199 = 1.0;
                    }
                    else
                    {
#line 679 "MatrixModule.cs"
                        csharp2cuda_temp_199 = 0.0;
                    }
                    (*(csharp2cuda_temp_198) = csharp2cuda_temp_199);
                }
#line 675 "MatrixModule.cs"
                int* csharp2cuda_temp_194 = &(flat);
#line 675 "MatrixModule.cs"
                int csharp2cuda_temp_195 = *(csharp2cuda_temp_194);
                (*(csharp2cuda_temp_194) = csharp2cuda_i32_add(csharp2cuda_temp_195, blockDim.x));
            }
        }
#line 681 "MatrixModule.cs"
        return;
    }
#line 684 "MatrixModule.cs"
    if (((opcode) == (13)))
#line 685 "MatrixModule.cs"
    {
#line 686 "MatrixModule.cs"
        int csharp2cuda_temp_200 = (first)->rows;
#line 686 "MatrixModule.cs"
        int csharp2cuda_temp_201 = (second)->rows;
#line 686 "MatrixModule.cs"
        int rows = csharp2cuda_i32_mul(csharp2cuda_temp_200, csharp2cuda_temp_201);
#line 687 "MatrixModule.cs"
        int csharp2cuda_temp_202 = (first)->columns;
#line 687 "MatrixModule.cs"
        int csharp2cuda_temp_203 = (second)->columns;
#line 687 "MatrixModule.cs"
        int columns = csharp2cuda_i32_mul(csharp2cuda_temp_202, csharp2cuda_temp_203);
#line 688 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 688 "MatrixModule.cs"
            mathblocks_matrix_shape(output, rows, columns);
        }
#line 689 "MatrixModule.cs"
        __syncthreads();
#line 690 "MatrixModule.cs"
        {
#line 690 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 690 "MatrixModule.cs"
                bool csharp2cuda_temp_206 = (output)->valid;
#line 690 "MatrixModule.cs"
                bool csharp2cuda_temp_207;
#line 690 "MatrixModule.cs"
                if (csharp2cuda_temp_206)
                {
#line 690 "MatrixModule.cs"
                    csharp2cuda_temp_207 = ((flat) < (csharp2cuda_i32_mul(rows, columns)));
                }
                else
                {
#line 690 "MatrixModule.cs"
                    csharp2cuda_temp_207 = false;
                }
                if (!(csharp2cuda_temp_207))
                    break;
#line 691 "MatrixModule.cs"
                {
#line 692 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, columns);
#line 693 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, columns));
#line 694 "MatrixModule.cs"
                    int csharp2cuda_temp_208 = (second)->rows;
#line 694 "MatrixModule.cs"
                    int left_row = csharp2cuda_i32_div(row, csharp2cuda_temp_208);
#line 695 "MatrixModule.cs"
                    int csharp2cuda_temp_209 = (second)->rows;
#line 695 "MatrixModule.cs"
                    int right_row = csharp2cuda_i32_sub(row, csharp2cuda_i32_mul(left_row, csharp2cuda_temp_209));
#line 696 "MatrixModule.cs"
                    int csharp2cuda_temp_210 = (second)->columns;
#line 696 "MatrixModule.cs"
                    int left_column = csharp2cuda_i32_div(column, csharp2cuda_temp_210);
#line 697 "MatrixModule.cs"
                    int csharp2cuda_temp_211 = (second)->columns;
#line 697 "MatrixModule.cs"
                    int right_column = csharp2cuda_i32_sub(column, csharp2cuda_i32_mul(left_column, csharp2cuda_temp_211));
#line 698 "MatrixModule.cs"
#line 698 "MatrixModule.cs"
                    double* csharp2cuda_temp_212 = &((result)[flat]);
#line 698 "MatrixModule.cs"
                    int csharp2cuda_temp_213 = (first)->columns;
#line 698 "MatrixModule.cs"
                    double csharp2cuda_temp_214 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left_row, csharp2cuda_temp_213), left_column)];
#line 699 "MatrixModule.cs"
                    int csharp2cuda_temp_215 = (second)->columns;
#line 699 "MatrixModule.cs"
                    double csharp2cuda_temp_216 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right_row, csharp2cuda_temp_215), right_column)];
                    (*(csharp2cuda_temp_212) = __dmul_rn(csharp2cuda_temp_214, csharp2cuda_temp_216));
#line 700 "MatrixModule.cs"
#line 700 "MatrixModule.cs"
                    double csharp2cuda_temp_217 = (result)[flat];
                    if ((!(isfinite(csharp2cuda_temp_217))))
                    {
#line 700 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 690 "MatrixModule.cs"
                int* csharp2cuda_temp_204 = &(flat);
#line 690 "MatrixModule.cs"
                int csharp2cuda_temp_205 = *(csharp2cuda_temp_204);
                (*(csharp2cuda_temp_204) = csharp2cuda_i32_add(csharp2cuda_temp_205, blockDim.x));
            }
        }
#line 702 "MatrixModule.cs"
        return;
    }
#line 705 "MatrixModule.cs"
    if (((opcode) == (14)))
#line 706 "MatrixModule.cs"
    {
#line 707 "MatrixModule.cs"
        if (((thread) == (0)))
#line 708 "MatrixModule.cs"
        {
#line 709 "MatrixModule.cs"
#line 709 "MatrixModule.cs"
            int csharp2cuda_temp_218 = (first)->rows;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_218);
#line 710 "MatrixModule.cs"
#line 710 "MatrixModule.cs"
            int csharp2cuda_temp_219 = (first)->columns;
#line 710 "MatrixModule.cs"
            int csharp2cuda_temp_220 = (second)->count;
            if (((csharp2cuda_temp_219) != (csharp2cuda_temp_220)))
            {
#line 710 "MatrixModule.cs"
#line 710 "MatrixModule.cs"
                int* csharp2cuda_temp_221 = &((output)->valid);
                (*(csharp2cuda_temp_221) = 0);
            }
        }
#line 712 "MatrixModule.cs"
        __syncthreads();
#line 713 "MatrixModule.cs"
        {
#line 713 "MatrixModule.cs"
            int row = thread;
            while (true)
            {
#line 713 "MatrixModule.cs"
                bool csharp2cuda_temp_224 = (output)->valid;
#line 713 "MatrixModule.cs"
                bool csharp2cuda_temp_225;
#line 713 "MatrixModule.cs"
                if (csharp2cuda_temp_224)
                {
#line 713 "MatrixModule.cs"
                    int csharp2cuda_temp_226 = (first)->rows;
#line 713 "MatrixModule.cs"
                    csharp2cuda_temp_225 = ((row) < (csharp2cuda_temp_226));
                }
                else
                {
#line 713 "MatrixModule.cs"
                    csharp2cuda_temp_225 = false;
                }
                if (!(csharp2cuda_temp_225))
                    break;
#line 714 "MatrixModule.cs"
                {
#line 715 "MatrixModule.cs"
                    double sum = 0.0;
#line 716 "MatrixModule.cs"
                    {
#line 716 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 716 "MatrixModule.cs"
                            int csharp2cuda_temp_228 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_228))))
                                break;
#line 717 "MatrixModule.cs"
#line 717 "MatrixModule.cs"
                            double* csharp2cuda_temp_229 = &(sum);
#line 717 "MatrixModule.cs"
                            double csharp2cuda_temp_230 = *(csharp2cuda_temp_229);
#line 717 "MatrixModule.cs"
                            int csharp2cuda_temp_231 = (first)->columns;
#line 717 "MatrixModule.cs"
                            double csharp2cuda_temp_232 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_231), column)];
#line 717 "MatrixModule.cs"
                            double csharp2cuda_temp_233 = (b)[column];
                            (*(csharp2cuda_temp_229) = __dadd_rn(csharp2cuda_temp_230, __dmul_rn(csharp2cuda_temp_232, csharp2cuda_temp_233)));
#line 716 "MatrixModule.cs"
                            int* csharp2cuda_temp_227 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_227));
                        }
                    }
#line 718 "MatrixModule.cs"
#line 718 "MatrixModule.cs"
                    double* csharp2cuda_temp_234 = &((result)[row]);
                    (*(csharp2cuda_temp_234) = sum);
#line 719 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 719 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 713 "MatrixModule.cs"
                int* csharp2cuda_temp_222 = &(row);
#line 713 "MatrixModule.cs"
                int csharp2cuda_temp_223 = *(csharp2cuda_temp_222);
                (*(csharp2cuda_temp_222) = csharp2cuda_i32_add(csharp2cuda_temp_223, blockDim.x));
            }
        }
#line 721 "MatrixModule.cs"
        return;
    }
#line 724 "MatrixModule.cs"
    if (((opcode) == (15)))
#line 725 "MatrixModule.cs"
    {
#line 726 "MatrixModule.cs"
        if (((thread) == (0)))
#line 727 "MatrixModule.cs"
        {
#line 728 "MatrixModule.cs"
#line 728 "MatrixModule.cs"
            int csharp2cuda_temp_235 = (first)->rows;
#line 728 "MatrixModule.cs"
            int csharp2cuda_temp_236 = (second)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_235, csharp2cuda_temp_236);
#line 729 "MatrixModule.cs"
#line 729 "MatrixModule.cs"
            int csharp2cuda_temp_237 = (first)->columns;
#line 729 "MatrixModule.cs"
            int csharp2cuda_temp_238 = (second)->rows;
            if (((csharp2cuda_temp_237) != (csharp2cuda_temp_238)))
            {
#line 729 "MatrixModule.cs"
#line 729 "MatrixModule.cs"
                int* csharp2cuda_temp_239 = &((output)->valid);
                (*(csharp2cuda_temp_239) = 0);
            }
        }
#line 731 "MatrixModule.cs"
        __syncthreads();
#line 732 "MatrixModule.cs"
        {
#line 732 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 732 "MatrixModule.cs"
                bool csharp2cuda_temp_242 = (output)->valid;
#line 732 "MatrixModule.cs"
                bool csharp2cuda_temp_243;
#line 732 "MatrixModule.cs"
                if (csharp2cuda_temp_242)
                {
#line 732 "MatrixModule.cs"
                    int csharp2cuda_temp_244 = (output)->count;
#line 732 "MatrixModule.cs"
                    csharp2cuda_temp_243 = ((flat) < (csharp2cuda_temp_244));
                }
                else
                {
#line 732 "MatrixModule.cs"
                    csharp2cuda_temp_243 = false;
                }
                if (!(csharp2cuda_temp_243))
                    break;
#line 733 "MatrixModule.cs"
                {
#line 734 "MatrixModule.cs"
                    int csharp2cuda_temp_245 = (second)->columns;
#line 734 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_245);
#line 735 "MatrixModule.cs"
                    int csharp2cuda_temp_246 = (second)->columns;
#line 735 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_246));
#line 736 "MatrixModule.cs"
                    double sum = 0.0;
#line 737 "MatrixModule.cs"
                    {
#line 737 "MatrixModule.cs"
                        int inner = 0;
                        while (true)
                        {
#line 737 "MatrixModule.cs"
                            int csharp2cuda_temp_248 = (first)->columns;
                            if (!(((inner) < (csharp2cuda_temp_248))))
                                break;
#line 738 "MatrixModule.cs"
#line 738 "MatrixModule.cs"
                            double* csharp2cuda_temp_249 = &(sum);
#line 738 "MatrixModule.cs"
                            double csharp2cuda_temp_250 = *(csharp2cuda_temp_249);
#line 738 "MatrixModule.cs"
                            int csharp2cuda_temp_251 = (first)->columns;
#line 738 "MatrixModule.cs"
                            double csharp2cuda_temp_252 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, csharp2cuda_temp_251), inner)];
#line 738 "MatrixModule.cs"
                            int csharp2cuda_temp_253 = (second)->columns;
#line 738 "MatrixModule.cs"
                            double csharp2cuda_temp_254 = (b)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_253), column)];
                            (*(csharp2cuda_temp_249) = __dadd_rn(csharp2cuda_temp_250, __dmul_rn(csharp2cuda_temp_252, csharp2cuda_temp_254)));
#line 737 "MatrixModule.cs"
                            int* csharp2cuda_temp_247 = &(inner);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_247));
                        }
                    }
#line 739 "MatrixModule.cs"
#line 739 "MatrixModule.cs"
                    double* csharp2cuda_temp_255 = &((result)[flat]);
                    (*(csharp2cuda_temp_255) = sum);
#line 740 "MatrixModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 740 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 732 "MatrixModule.cs"
                int* csharp2cuda_temp_240 = &(flat);
#line 732 "MatrixModule.cs"
                int csharp2cuda_temp_241 = *(csharp2cuda_temp_240);
                (*(csharp2cuda_temp_240) = csharp2cuda_i32_add(csharp2cuda_temp_241, blockDim.x));
            }
        }
#line 742 "MatrixModule.cs"
        return;
    }
#line 745 "MatrixModule.cs"
    if (((opcode) == (16)))
#line 746 "MatrixModule.cs"
    {
#line 747 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 747 "MatrixModule.cs"
#line 747 "MatrixModule.cs"
            int csharp2cuda_temp_256 = (first)->count;
#line 747 "MatrixModule.cs"
            int csharp2cuda_temp_257 = (second)->count;
            mathblocks_matrix_shape(output, csharp2cuda_temp_256, csharp2cuda_temp_257);
        }
#line 748 "MatrixModule.cs"
        __syncthreads();
#line 749 "MatrixModule.cs"
        {
#line 749 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 749 "MatrixModule.cs"
                bool csharp2cuda_temp_260 = (output)->valid;
#line 749 "MatrixModule.cs"
                bool csharp2cuda_temp_261;
#line 749 "MatrixModule.cs"
                if (csharp2cuda_temp_260)
                {
#line 749 "MatrixModule.cs"
                    int csharp2cuda_temp_262 = (output)->count;
#line 749 "MatrixModule.cs"
                    csharp2cuda_temp_261 = ((flat) < (csharp2cuda_temp_262));
                }
                else
                {
#line 749 "MatrixModule.cs"
                    csharp2cuda_temp_261 = false;
                }
                if (!(csharp2cuda_temp_261))
                    break;
#line 750 "MatrixModule.cs"
                {
#line 751 "MatrixModule.cs"
                    int csharp2cuda_temp_263 = (second)->count;
#line 751 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_263);
#line 752 "MatrixModule.cs"
                    int csharp2cuda_temp_264 = (second)->count;
#line 752 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_264));
#line 753 "MatrixModule.cs"
#line 753 "MatrixModule.cs"
                    double* csharp2cuda_temp_265 = &((result)[flat]);
#line 753 "MatrixModule.cs"
                    double csharp2cuda_temp_266 = (a)[row];
#line 753 "MatrixModule.cs"
                    double csharp2cuda_temp_267 = (b)[column];
                    (*(csharp2cuda_temp_265) = __dmul_rn(csharp2cuda_temp_266, csharp2cuda_temp_267));
#line 754 "MatrixModule.cs"
#line 754 "MatrixModule.cs"
                    double csharp2cuda_temp_268 = (result)[flat];
                    if ((!(isfinite(csharp2cuda_temp_268))))
                    {
#line 754 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 749 "MatrixModule.cs"
                int* csharp2cuda_temp_258 = &(flat);
#line 749 "MatrixModule.cs"
                int csharp2cuda_temp_259 = *(csharp2cuda_temp_258);
                (*(csharp2cuda_temp_258) = csharp2cuda_i32_add(csharp2cuda_temp_259, blockDim.x));
            }
        }
#line 756 "MatrixModule.cs"
        return;
    }
#line 759 "MatrixModule.cs"
    if (((opcode) == (17)))
#line 760 "MatrixModule.cs"
    {
#line 761 "MatrixModule.cs"
        int rows = 0;
#line 762 "MatrixModule.cs"
        int columns = 0;
#line 763 "MatrixModule.cs"
        double csharp2cuda_temp_269 = (second)->scalar_value;
#line 763 "MatrixModule.cs"
        int* csharp2cuda_temp_270 = &(rows);
#line 763 "MatrixModule.cs"
        bool valid_rows = mathblocks_nonnegative_integer(csharp2cuda_temp_269, csharp2cuda_temp_270);
#line 764 "MatrixModule.cs"
        double csharp2cuda_temp_271 = (third)->scalar_value;
#line 764 "MatrixModule.cs"
        int* csharp2cuda_temp_272 = &(columns);
#line 764 "MatrixModule.cs"
        bool valid_columns = mathblocks_nonnegative_integer(csharp2cuda_temp_271, csharp2cuda_temp_272);
#line 765 "MatrixModule.cs"
        if (((thread) == (0)))
#line 766 "MatrixModule.cs"
        {
#line 767 "MatrixModule.cs"
            mathblocks_matrix_shape(output, rows, columns);
#line 768 "MatrixModule.cs"
#line 768 "MatrixModule.cs"
            bool csharp2cuda_temp_273;
#line 768 "MatrixModule.cs"
            if (!((!(valid_rows))))
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_273 = (!(valid_columns));
            }
            else
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_273 = true;
            }
#line 768 "MatrixModule.cs"
            bool csharp2cuda_temp_274;
#line 768 "MatrixModule.cs"
            if (!(csharp2cuda_temp_273))
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_274 = ((rows) <= (0));
            }
            else
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_274 = true;
            }
#line 768 "MatrixModule.cs"
            bool csharp2cuda_temp_275;
#line 768 "MatrixModule.cs"
            if (!(csharp2cuda_temp_274))
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_275 = ((columns) <= (0));
            }
            else
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_275 = true;
            }
#line 768 "MatrixModule.cs"
            bool csharp2cuda_temp_276;
#line 768 "MatrixModule.cs"
            if (!(csharp2cuda_temp_275))
            {
#line 769 "MatrixModule.cs"
                int csharp2cuda_temp_277 = (first)->count;
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_276 = ((csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)))) != (((long long)(csharp2cuda_temp_277))));
            }
            else
            {
#line 768 "MatrixModule.cs"
                csharp2cuda_temp_276 = true;
            }
            if (csharp2cuda_temp_276)
#line 770 "MatrixModule.cs"
            {
#line 771 "MatrixModule.cs"
#line 771 "MatrixModule.cs"
                int* csharp2cuda_temp_278 = &((output)->valid);
                (*(csharp2cuda_temp_278) = 0);
            }
        }
#line 774 "MatrixModule.cs"
        __syncthreads();
#line 775 "MatrixModule.cs"
        {
#line 775 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 775 "MatrixModule.cs"
                bool csharp2cuda_temp_281 = (output)->valid;
#line 775 "MatrixModule.cs"
                bool csharp2cuda_temp_282;
#line 775 "MatrixModule.cs"
                if (csharp2cuda_temp_281)
                {
#line 775 "MatrixModule.cs"
                    int csharp2cuda_temp_283 = (first)->count;
#line 775 "MatrixModule.cs"
                    csharp2cuda_temp_282 = ((index) < (csharp2cuda_temp_283));
                }
                else
                {
#line 775 "MatrixModule.cs"
                    csharp2cuda_temp_282 = false;
                }
                if (!(csharp2cuda_temp_282))
                    break;
#line 776 "MatrixModule.cs"
#line 776 "MatrixModule.cs"
                double* csharp2cuda_temp_284 = &((result)[index]);
#line 776 "MatrixModule.cs"
                double csharp2cuda_temp_285 = (a)[index];
                (*(csharp2cuda_temp_284) = csharp2cuda_temp_285);
#line 775 "MatrixModule.cs"
                int* csharp2cuda_temp_279 = &(index);
#line 775 "MatrixModule.cs"
                int csharp2cuda_temp_280 = *(csharp2cuda_temp_279);
                (*(csharp2cuda_temp_279) = csharp2cuda_i32_add(csharp2cuda_temp_280, blockDim.x));
            }
        }
#line 777 "MatrixModule.cs"
        return;
    }
#line 780 "MatrixModule.cs"
    if (((opcode) == (20)))
#line 781 "MatrixModule.cs"
    {
#line 782 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 782 "MatrixModule.cs"
#line 782 "MatrixModule.cs"
            int csharp2cuda_temp_286 = (first)->rows;
#line 782 "MatrixModule.cs"
            int csharp2cuda_temp_287 = (first)->columns;
            mathblocks_matrix_shape(output, csharp2cuda_temp_286, csharp2cuda_temp_287);
        }
#line 783 "MatrixModule.cs"
        __syncthreads();
#line 784 "MatrixModule.cs"
        {
#line 784 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 784 "MatrixModule.cs"
                bool csharp2cuda_temp_290 = (output)->valid;
#line 784 "MatrixModule.cs"
                bool csharp2cuda_temp_291;
#line 784 "MatrixModule.cs"
                if (csharp2cuda_temp_290)
                {
#line 784 "MatrixModule.cs"
                    int csharp2cuda_temp_292 = (first)->count;
#line 784 "MatrixModule.cs"
                    csharp2cuda_temp_291 = ((index) < (csharp2cuda_temp_292));
                }
                else
                {
#line 784 "MatrixModule.cs"
                    csharp2cuda_temp_291 = false;
                }
                if (!(csharp2cuda_temp_291))
                    break;
#line 785 "MatrixModule.cs"
                {
#line 786 "MatrixModule.cs"
#line 786 "MatrixModule.cs"
                    double* csharp2cuda_temp_293 = &((result)[index]);
#line 786 "MatrixModule.cs"
                    double csharp2cuda_temp_294 = (a)[index];
#line 786 "MatrixModule.cs"
                    double csharp2cuda_temp_295 = (second)->scalar_value;
                    (*(csharp2cuda_temp_293) = __dmul_rn(csharp2cuda_temp_294, csharp2cuda_temp_295));
#line 787 "MatrixModule.cs"
#line 787 "MatrixModule.cs"
                    double csharp2cuda_temp_296 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_296))))
                    {
#line 787 "MatrixModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 784 "MatrixModule.cs"
                int* csharp2cuda_temp_288 = &(index);
#line 784 "MatrixModule.cs"
                int csharp2cuda_temp_289 = *(csharp2cuda_temp_288);
                (*(csharp2cuda_temp_288) = csharp2cuda_i32_add(csharp2cuda_temp_289, blockDim.x));
            }
        }
#line 789 "MatrixModule.cs"
        return;
    }
#line 792 "MatrixModule.cs"
    if (((opcode) == (21)))
#line 793 "MatrixModule.cs"
    {
#line 794 "MatrixModule.cs"
        if (((thread) == (0)))
#line 795 "MatrixModule.cs"
        {
#line 796 "MatrixModule.cs"
#line 796 "MatrixModule.cs"
            int csharp2cuda_temp_297 = (first)->count;
            mathblocks_matrix_shape(output, 2, csharp2cuda_temp_297);
#line 797 "MatrixModule.cs"
#line 797 "MatrixModule.cs"
            int csharp2cuda_temp_298 = (first)->count;
#line 797 "MatrixModule.cs"
            int csharp2cuda_temp_299 = (second)->count;
            if (((csharp2cuda_temp_298) != (csharp2cuda_temp_299)))
            {
#line 797 "MatrixModule.cs"
#line 797 "MatrixModule.cs"
                int* csharp2cuda_temp_300 = &((output)->valid);
                (*(csharp2cuda_temp_300) = 0);
            }
        }
#line 799 "MatrixModule.cs"
        __syncthreads();
#line 800 "MatrixModule.cs"
        {
#line 800 "MatrixModule.cs"
            int index = thread;
            while (true)
            {
#line 800 "MatrixModule.cs"
                bool csharp2cuda_temp_303 = (output)->valid;
#line 800 "MatrixModule.cs"
                bool csharp2cuda_temp_304;
#line 800 "MatrixModule.cs"
                if (csharp2cuda_temp_303)
                {
#line 800 "MatrixModule.cs"
                    int csharp2cuda_temp_305 = (first)->count;
#line 800 "MatrixModule.cs"
                    csharp2cuda_temp_304 = ((index) < (csharp2cuda_temp_305));
                }
                else
                {
#line 800 "MatrixModule.cs"
                    csharp2cuda_temp_304 = false;
                }
                if (!(csharp2cuda_temp_304))
                    break;
#line 801 "MatrixModule.cs"
                {
#line 802 "MatrixModule.cs"
#line 802 "MatrixModule.cs"
                    double* csharp2cuda_temp_306 = &((result)[index]);
#line 802 "MatrixModule.cs"
                    double csharp2cuda_temp_307 = (a)[index];
                    (*(csharp2cuda_temp_306) = csharp2cuda_temp_307);
#line 803 "MatrixModule.cs"
#line 803 "MatrixModule.cs"
                    int csharp2cuda_temp_308 = (first)->count;
#line 803 "MatrixModule.cs"
                    double* csharp2cuda_temp_309 = &((result)[csharp2cuda_i32_add(csharp2cuda_temp_308, index)]);
#line 803 "MatrixModule.cs"
                    double csharp2cuda_temp_310 = (b)[index];
                    (*(csharp2cuda_temp_309) = csharp2cuda_temp_310);
                }
#line 800 "MatrixModule.cs"
                int* csharp2cuda_temp_301 = &(index);
#line 800 "MatrixModule.cs"
                int csharp2cuda_temp_302 = *(csharp2cuda_temp_301);
                (*(csharp2cuda_temp_301) = csharp2cuda_i32_add(csharp2cuda_temp_302, blockDim.x));
            }
        }
#line 805 "MatrixModule.cs"
        return;
    }
#line 808 "MatrixModule.cs"
    if (((opcode) == (24)))
#line 809 "MatrixModule.cs"
    {
#line 810 "MatrixModule.cs"
        if (((thread) == (0)))
#line 811 "MatrixModule.cs"
        {
#line 812 "MatrixModule.cs"
#line 812 "MatrixModule.cs"
            int csharp2cuda_temp_311 = (first)->rows;
#line 812 "MatrixModule.cs"
            int csharp2cuda_temp_312 = (first)->columns;
            if (((csharp2cuda_temp_311) != (csharp2cuda_temp_312)))
#line 813 "MatrixModule.cs"
            {
#line 814 "MatrixModule.cs"
#line 814 "MatrixModule.cs"
                int* csharp2cuda_temp_313 = &((output)->valid);
                (*(csharp2cuda_temp_313) = 0);
#line 815 "MatrixModule.cs"
                return;
            }
#line 817 "MatrixModule.cs"
            double trace = 0.0;
#line 818 "MatrixModule.cs"
            {
#line 818 "MatrixModule.cs"
                int index = 0;
                while (true)
                {
#line 818 "MatrixModule.cs"
                    int csharp2cuda_temp_315 = (first)->rows;
                    if (!(((index) < (csharp2cuda_temp_315))))
                        break;
#line 819 "MatrixModule.cs"
#line 819 "MatrixModule.cs"
                    double* csharp2cuda_temp_316 = &(trace);
#line 819 "MatrixModule.cs"
                    double csharp2cuda_temp_317 = *(csharp2cuda_temp_316);
#line 819 "MatrixModule.cs"
                    int csharp2cuda_temp_318 = (first)->columns;
#line 819 "MatrixModule.cs"
                    double csharp2cuda_temp_319 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, csharp2cuda_temp_318), index)];
                    (*(csharp2cuda_temp_316) = __dadd_rn(csharp2cuda_temp_317, csharp2cuda_temp_319));
#line 818 "MatrixModule.cs"
                    int* csharp2cuda_temp_314 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_314));
                }
            }
#line 820 "MatrixModule.cs"
#line 820 "MatrixModule.cs"
            double* csharp2cuda_temp_320 = &((output)->scalar_value);
            (*(csharp2cuda_temp_320) = trace);
#line 821 "MatrixModule.cs"
            if ((!(isfinite(trace))))
            {
#line 821 "MatrixModule.cs"
#line 821 "MatrixModule.cs"
                int* csharp2cuda_temp_321 = &((output)->valid);
                (*(csharp2cuda_temp_321) = 0);
            }
        }
#line 823 "MatrixModule.cs"
        return;
    }
#line 826 "MatrixModule.cs"
    if (((opcode) == (25)))
#line 827 "MatrixModule.cs"
    {
#line 828 "MatrixModule.cs"
        if (((thread) == (0)))
        {
#line 828 "MatrixModule.cs"
#line 828 "MatrixModule.cs"
            int csharp2cuda_temp_322 = (first)->columns;
#line 828 "MatrixModule.cs"
            int csharp2cuda_temp_323 = (first)->rows;
            mathblocks_matrix_shape(output, csharp2cuda_temp_322, csharp2cuda_temp_323);
        }
#line 829 "MatrixModule.cs"
        __syncthreads();
#line 830 "MatrixModule.cs"
        {
#line 830 "MatrixModule.cs"
            int flat = thread;
            while (true)
            {
#line 830 "MatrixModule.cs"
                bool csharp2cuda_temp_326 = (output)->valid;
#line 830 "MatrixModule.cs"
                bool csharp2cuda_temp_327;
#line 830 "MatrixModule.cs"
                if (csharp2cuda_temp_326)
                {
#line 830 "MatrixModule.cs"
                    int csharp2cuda_temp_328 = (output)->count;
#line 830 "MatrixModule.cs"
                    csharp2cuda_temp_327 = ((flat) < (csharp2cuda_temp_328));
                }
                else
                {
#line 830 "MatrixModule.cs"
                    csharp2cuda_temp_327 = false;
                }
                if (!(csharp2cuda_temp_327))
                    break;
#line 831 "MatrixModule.cs"
                {
#line 832 "MatrixModule.cs"
                    int csharp2cuda_temp_329 = (first)->rows;
#line 832 "MatrixModule.cs"
                    int row = csharp2cuda_i32_div(flat, csharp2cuda_temp_329);
#line 833 "MatrixModule.cs"
                    int csharp2cuda_temp_330 = (first)->rows;
#line 833 "MatrixModule.cs"
                    int column = csharp2cuda_i32_sub(flat, csharp2cuda_i32_mul(row, csharp2cuda_temp_330));
#line 834 "MatrixModule.cs"
#line 834 "MatrixModule.cs"
                    double* csharp2cuda_temp_331 = &((result)[flat]);
#line 834 "MatrixModule.cs"
                    int csharp2cuda_temp_332 = (first)->columns;
#line 834 "MatrixModule.cs"
                    double csharp2cuda_temp_333 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, csharp2cuda_temp_332), row)];
                    (*(csharp2cuda_temp_331) = csharp2cuda_temp_333);
                }
#line 830 "MatrixModule.cs"
                int* csharp2cuda_temp_324 = &(flat);
#line 830 "MatrixModule.cs"
                int csharp2cuda_temp_325 = *(csharp2cuda_temp_324);
                (*(csharp2cuda_temp_324) = csharp2cuda_i32_add(csharp2cuda_temp_325, blockDim.x));
            }
        }
#line 836 "MatrixModule.cs"
        return;
    }
#line 839 "MatrixModule.cs"
    if (((thread) != (0)))
    {
#line 840 "MatrixModule.cs"
        return;
    }
#line 842 "MatrixModule.cs"
    if (((opcode) == (26)))
#line 843 "MatrixModule.cs"
    {
#line 844 "MatrixModule.cs"
#line 844 "MatrixModule.cs"
        int csharp2cuda_temp_334 = (first)->rows;
#line 844 "MatrixModule.cs"
        int csharp2cuda_temp_335 = (first)->columns;
#line 844 "MatrixModule.cs"
        bool csharp2cuda_temp_336;
#line 844 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_334) != (csharp2cuda_temp_335))))
        {
#line 844 "MatrixModule.cs"
            csharp2cuda_temp_336 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 844 "MatrixModule.cs"
            csharp2cuda_temp_336 = true;
        }
        if (csharp2cuda_temp_336)
#line 845 "MatrixModule.cs"
        {
#line 846 "MatrixModule.cs"
#line 846 "MatrixModule.cs"
            int* csharp2cuda_temp_337 = &((output)->valid);
            (*(csharp2cuda_temp_337) = 0);
#line 847 "MatrixModule.cs"
            return;
        }
#line 849 "MatrixModule.cs"
#line 849 "MatrixModule.cs"
        double* csharp2cuda_temp_338 = &((output)->scalar_value);
#line 849 "MatrixModule.cs"
        int csharp2cuda_temp_339 = (first)->rows;
#line 849 "MatrixModule.cs"
        double csharp2cuda_temp_340 = mathblocks_matrix_determinant(a, csharp2cuda_temp_339, scratch);
        (*(csharp2cuda_temp_338) = csharp2cuda_temp_340);
#line 850 "MatrixModule.cs"
#line 850 "MatrixModule.cs"
        double csharp2cuda_temp_341 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_341))))
        {
#line 850 "MatrixModule.cs"
#line 850 "MatrixModule.cs"
            int* csharp2cuda_temp_342 = &((output)->valid);
            (*(csharp2cuda_temp_342) = 0);
        }
#line 851 "MatrixModule.cs"
        return;
    }
#line 854 "MatrixModule.cs"
    if (((opcode) == (27)))
#line 855 "MatrixModule.cs"
    {
#line 856 "MatrixModule.cs"
        int size = (first)->rows;
#line 857 "MatrixModule.cs"
        int count = (first)->count;
#line 858 "MatrixModule.cs"
#line 858 "MatrixModule.cs"
        int csharp2cuda_temp_343 = (first)->columns;
#line 858 "MatrixModule.cs"
        bool csharp2cuda_temp_344;
#line 858 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_343))))
        {
#line 858 "MatrixModule.cs"
            csharp2cuda_temp_344 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 858 "MatrixModule.cs"
            csharp2cuda_temp_344 = true;
        }
        if (csharp2cuda_temp_344)
#line 859 "MatrixModule.cs"
        {
#line 860 "MatrixModule.cs"
#line 860 "MatrixModule.cs"
            int* csharp2cuda_temp_345 = &((output)->valid);
            (*(csharp2cuda_temp_345) = 0);
#line 861 "MatrixModule.cs"
            return;
        }
#line 863 "MatrixModule.cs"
        mathblocks_matrix_shape(output, size, size);
#line 864 "MatrixModule.cs"
        double norm = 0.0;
#line 865 "MatrixModule.cs"
        {
#line 865 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 866 "MatrixModule.cs"
                {
#line 867 "MatrixModule.cs"
                    double row_sum = 0.0;
#line 868 "MatrixModule.cs"
                    {
#line 868 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 869 "MatrixModule.cs"
#line 869 "MatrixModule.cs"
                            double* csharp2cuda_temp_348 = &(row_sum);
#line 869 "MatrixModule.cs"
                            double csharp2cuda_temp_349 = *(csharp2cuda_temp_348);
#line 869 "MatrixModule.cs"
                            double csharp2cuda_temp_350 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
                            (*(csharp2cuda_temp_348) = __dadd_rn(csharp2cuda_temp_349, fabs(csharp2cuda_temp_350)));
#line 868 "MatrixModule.cs"
                            int* csharp2cuda_temp_347 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_347));
                        }
                    }
#line 870 "MatrixModule.cs"
                    if (((row_sum) > (norm)))
                    {
#line 870 "MatrixModule.cs"
#line 870 "MatrixModule.cs"
                        double* csharp2cuda_temp_351 = &(norm);
                        (*(csharp2cuda_temp_351) = row_sum);
                    }
                }
#line 865 "MatrixModule.cs"
                int* csharp2cuda_temp_346 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_346));
            }
        }
#line 872 "MatrixModule.cs"
        int csharp2cuda_temp_352;
#line 872 "MatrixModule.cs"
        if (((norm) > (1.0)))
        {
#line 872 "MatrixModule.cs"
            csharp2cuda_temp_352 = csharp2cuda_f64_to_i32(ceil(mathblocks_binary_logarithm(norm)));
        }
        else
        {
#line 872 "MatrixModule.cs"
            csharp2cuda_temp_352 = 0;
        }
#line 872 "MatrixModule.cs"
        int scaling = csharp2cuda_temp_352;
#line 873 "MatrixModule.cs"
        if (((scaling) < (0)))
        {
#line 873 "MatrixModule.cs"
#line 873 "MatrixModule.cs"
            int* csharp2cuda_temp_353 = &(scaling);
            (*(csharp2cuda_temp_353) = 0);
        }
#line 874 "MatrixModule.cs"
        double scale = mathblocks_power(2.0, ((double)(csharp2cuda_i32_neg(scaling))));
#line 875 "MatrixModule.cs"
        double* scaled = scratch;
#line 876 "MatrixModule.cs"
        double* term = csharp2cuda_pointer_add(scratch, count);
#line 877 "MatrixModule.cs"
        double* temporary = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(count, 2));
#line 878 "MatrixModule.cs"
        {
#line 878 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 879 "MatrixModule.cs"
                {
#line 880 "MatrixModule.cs"
#line 880 "MatrixModule.cs"
                    double* csharp2cuda_temp_355 = &((scaled)[index]);
#line 880 "MatrixModule.cs"
                    double csharp2cuda_temp_356 = (a)[index];
                    (*(csharp2cuda_temp_355) = __dmul_rn(csharp2cuda_temp_356, scale));
#line 881 "MatrixModule.cs"
#line 881 "MatrixModule.cs"
                    double* csharp2cuda_temp_357 = &((result)[index]);
                    (*(csharp2cuda_temp_357) = 0.0);
#line 882 "MatrixModule.cs"
#line 882 "MatrixModule.cs"
                    double* csharp2cuda_temp_358 = &((term)[index]);
                    (*(csharp2cuda_temp_358) = 0.0);
                }
#line 878 "MatrixModule.cs"
                int* csharp2cuda_temp_354 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_354));
            }
        }
#line 884 "MatrixModule.cs"
        {
#line 884 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 885 "MatrixModule.cs"
                {
#line 886 "MatrixModule.cs"
#line 886 "MatrixModule.cs"
                    double* csharp2cuda_temp_360 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)]);
                    (*(csharp2cuda_temp_360) = 1.0);
#line 887 "MatrixModule.cs"
#line 887 "MatrixModule.cs"
                    double* csharp2cuda_temp_361 = &((term)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)]);
                    (*(csharp2cuda_temp_361) = 1.0);
                }
#line 884 "MatrixModule.cs"
                int* csharp2cuda_temp_359 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_359));
            }
        }
#line 889 "MatrixModule.cs"
        {
#line 889 "MatrixModule.cs"
            int order = 1;
            while (true)
            {
                if (!(((order) <= (48))))
                    break;
#line 890 "MatrixModule.cs"
                {
#line 891 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(term, scaled, size, temporary);
#line 892 "MatrixModule.cs"
                    double order_scale = __ddiv_rn(1.0, ((double)(order)));
#line 893 "MatrixModule.cs"
                    {
#line 893 "MatrixModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 894 "MatrixModule.cs"
                            {
#line 895 "MatrixModule.cs"
#line 895 "MatrixModule.cs"
                                double* csharp2cuda_temp_364 = &((term)[index]);
#line 895 "MatrixModule.cs"
                                double csharp2cuda_temp_365 = (temporary)[index];
                                (*(csharp2cuda_temp_364) = __dmul_rn(csharp2cuda_temp_365, order_scale));
#line 896 "MatrixModule.cs"
#line 896 "MatrixModule.cs"
                                double* csharp2cuda_temp_366 = &((result)[index]);
#line 896 "MatrixModule.cs"
                                double csharp2cuda_temp_367 = *(csharp2cuda_temp_366);
#line 896 "MatrixModule.cs"
                                double csharp2cuda_temp_368 = (term)[index];
                                (*(csharp2cuda_temp_366) = __dadd_rn(csharp2cuda_temp_367, csharp2cuda_temp_368));
                            }
#line 893 "MatrixModule.cs"
                            int* csharp2cuda_temp_363 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_363));
                        }
                    }
                }
#line 889 "MatrixModule.cs"
                int* csharp2cuda_temp_362 = &(order);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_362));
            }
        }
#line 899 "MatrixModule.cs"
        {
#line 899 "MatrixModule.cs"
            int iteration = 0;
            while (true)
            {
                if (!(((iteration) < (scaling))))
                    break;
#line 900 "MatrixModule.cs"
                {
#line 901 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(result, result, size, temporary);
#line 902 "MatrixModule.cs"
                    mathblocks_matrix_copy(temporary, result, count);
                }
#line 899 "MatrixModule.cs"
                int* csharp2cuda_temp_369 = &(iteration);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_369));
            }
        }
#line 904 "MatrixModule.cs"
        {
#line 904 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 905 "MatrixModule.cs"
#line 905 "MatrixModule.cs"
                double csharp2cuda_temp_371 = (result)[index];
                if ((!(isfinite(csharp2cuda_temp_371))))
                {
#line 905 "MatrixModule.cs"
#line 905 "MatrixModule.cs"
                    int* csharp2cuda_temp_372 = &((output)->valid);
                    (*(csharp2cuda_temp_372) = 0);
                }
#line 904 "MatrixModule.cs"
                int* csharp2cuda_temp_370 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_370));
            }
        }
#line 906 "MatrixModule.cs"
        return;
    }
#line 909 "MatrixModule.cs"
    if (((opcode) == (28)))
#line 910 "MatrixModule.cs"
    {
#line 911 "MatrixModule.cs"
        int exponent = 0;
#line 912 "MatrixModule.cs"
#line 912 "MatrixModule.cs"
        int csharp2cuda_temp_373 = (first)->rows;
#line 912 "MatrixModule.cs"
        int csharp2cuda_temp_374 = (first)->columns;
#line 912 "MatrixModule.cs"
        bool csharp2cuda_temp_375;
#line 912 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_373) != (csharp2cuda_temp_374))))
        {
#line 913 "MatrixModule.cs"
            double csharp2cuda_temp_376 = (second)->scalar_value;
#line 913 "MatrixModule.cs"
            int* csharp2cuda_temp_377 = &(exponent);
#line 913 "MatrixModule.cs"
            bool csharp2cuda_temp_378 = mathblocks_nonnegative_integer(csharp2cuda_temp_376, csharp2cuda_temp_377);
#line 912 "MatrixModule.cs"
            csharp2cuda_temp_375 = (!(csharp2cuda_temp_378));
        }
        else
        {
#line 912 "MatrixModule.cs"
            csharp2cuda_temp_375 = true;
        }
#line 912 "MatrixModule.cs"
        bool csharp2cuda_temp_379;
#line 912 "MatrixModule.cs"
        if (!(csharp2cuda_temp_375))
        {
#line 912 "MatrixModule.cs"
            csharp2cuda_temp_379 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 912 "MatrixModule.cs"
            csharp2cuda_temp_379 = true;
        }
        if (csharp2cuda_temp_379)
#line 915 "MatrixModule.cs"
        {
#line 916 "MatrixModule.cs"
#line 916 "MatrixModule.cs"
            int* csharp2cuda_temp_380 = &((output)->valid);
            (*(csharp2cuda_temp_380) = 0);
#line 917 "MatrixModule.cs"
            return;
        }
#line 919 "MatrixModule.cs"
        int size = (first)->rows;
#line 920 "MatrixModule.cs"
        int count = (first)->count;
#line 921 "MatrixModule.cs"
        mathblocks_matrix_shape(output, size, size);
#line 922 "MatrixModule.cs"
        double* power = scratch;
#line 923 "MatrixModule.cs"
        double* temporary = csharp2cuda_pointer_add(scratch, count);
#line 924 "MatrixModule.cs"
        mathblocks_matrix_copy(a, power, count);
#line 925 "MatrixModule.cs"
        {
#line 925 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 926 "MatrixModule.cs"
#line 926 "MatrixModule.cs"
                double* csharp2cuda_temp_382 = &((result)[index]);
                (*(csharp2cuda_temp_382) = 0.0);
#line 925 "MatrixModule.cs"
                int* csharp2cuda_temp_381 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_381));
            }
        }
#line 927 "MatrixModule.cs"
        {
#line 927 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 928 "MatrixModule.cs"
#line 928 "MatrixModule.cs"
                double* csharp2cuda_temp_384 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)]);
                (*(csharp2cuda_temp_384) = 1.0);
#line 927 "MatrixModule.cs"
                int* csharp2cuda_temp_383 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_383));
            }
        }
#line 929 "MatrixModule.cs"
        while (true)
        {
            if (!(((exponent) > (0))))
                break;
#line 930 "MatrixModule.cs"
            {
#line 931 "MatrixModule.cs"
                if (((csharp2cuda_i32_and(exponent, 1)) != (0)))
#line 932 "MatrixModule.cs"
                {
#line 933 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(result, power, size, temporary);
#line 934 "MatrixModule.cs"
                    mathblocks_matrix_copy(temporary, result, count);
                }
#line 936 "MatrixModule.cs"
#line 936 "MatrixModule.cs"
                int* csharp2cuda_temp_385 = &(exponent);
#line 936 "MatrixModule.cs"
                int csharp2cuda_temp_386 = *(csharp2cuda_temp_385);
                (*(csharp2cuda_temp_385) = csharp2cuda_i32_shr(csharp2cuda_temp_386, 1));
#line 937 "MatrixModule.cs"
                if (((exponent) > (0)))
#line 938 "MatrixModule.cs"
                {
#line 939 "MatrixModule.cs"
                    mathblocks_matrix_multiply_square(power, power, size, temporary);
#line 940 "MatrixModule.cs"
                    mathblocks_matrix_copy(temporary, power, count);
                }
            }
        }
#line 943 "MatrixModule.cs"
        {
#line 943 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 944 "MatrixModule.cs"
#line 944 "MatrixModule.cs"
                double csharp2cuda_temp_388 = (result)[index];
                if ((!(isfinite(csharp2cuda_temp_388))))
                {
#line 944 "MatrixModule.cs"
#line 944 "MatrixModule.cs"
                    int* csharp2cuda_temp_389 = &((output)->valid);
                    (*(csharp2cuda_temp_389) = 0);
                }
#line 943 "MatrixModule.cs"
                int* csharp2cuda_temp_387 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_387));
            }
        }
#line 945 "MatrixModule.cs"
        return;
    }
#line 948 "MatrixModule.cs"
    if (((opcode) == (29)))
#line 949 "MatrixModule.cs"
    {
#line 950 "MatrixModule.cs"
        int size = (first)->rows;
#line 951 "MatrixModule.cs"
#line 951 "MatrixModule.cs"
        int csharp2cuda_temp_390 = (first)->columns;
#line 951 "MatrixModule.cs"
        bool csharp2cuda_temp_391;
#line 951 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_390))))
        {
#line 951 "MatrixModule.cs"
            csharp2cuda_temp_391 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 951 "MatrixModule.cs"
            csharp2cuda_temp_391 = true;
        }
        if (csharp2cuda_temp_391)
#line 952 "MatrixModule.cs"
        {
#line 953 "MatrixModule.cs"
#line 953 "MatrixModule.cs"
            int* csharp2cuda_temp_392 = &((output)->valid);
            (*(csharp2cuda_temp_392) = 0);
#line 954 "MatrixModule.cs"
            return;
        }
#line 956 "MatrixModule.cs"
        mathblocks_matrix_shape(output, size, size);
#line 957 "MatrixModule.cs"
        double* augmented = scratch;
#line 958 "MatrixModule.cs"
        double* solution = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(size, csharp2cuda_i32_add(size, 1)));
#line 959 "MatrixModule.cs"
        {
#line 959 "MatrixModule.cs"
            int column = 0;
            while (true)
            {
                if (!(((column) < (size))))
                    break;
#line 960 "MatrixModule.cs"
                {
#line 961 "MatrixModule.cs"
#line 961 "MatrixModule.cs"
                    bool csharp2cuda_temp_394 = mathblocks_matrix_try_solve_basis(a, size, column, augmented, solution);
                    if ((!(csharp2cuda_temp_394)))
#line 962 "MatrixModule.cs"
                    {
#line 963 "MatrixModule.cs"
#line 963 "MatrixModule.cs"
                        int* csharp2cuda_temp_395 = &((output)->valid);
                        (*(csharp2cuda_temp_395) = 0);
#line 964 "MatrixModule.cs"
                        return;
                    }
#line 966 "MatrixModule.cs"
                    {
#line 966 "MatrixModule.cs"
                        int row = 0;
                        while (true)
                        {
                            if (!(((row) < (size))))
                                break;
#line 967 "MatrixModule.cs"
#line 967 "MatrixModule.cs"
                            double* csharp2cuda_temp_397 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
#line 967 "MatrixModule.cs"
                            double csharp2cuda_temp_398 = (solution)[row];
                            (*(csharp2cuda_temp_397) = csharp2cuda_temp_398);
#line 966 "MatrixModule.cs"
                            int* csharp2cuda_temp_396 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_396));
                        }
                    }
                }
#line 959 "MatrixModule.cs"
                int* csharp2cuda_temp_393 = &(column);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_393));
            }
        }
#line 969 "MatrixModule.cs"
        return;
    }
#line 972 "MatrixModule.cs"
    if (((opcode) == (30)))
#line 973 "MatrixModule.cs"
    {
#line 974 "MatrixModule.cs"
#line 974 "MatrixModule.cs"
        int* csharp2cuda_temp_399 = &((output)->boolean_value);
#line 974 "MatrixModule.cs"
        int csharp2cuda_temp_400 = (first)->rows;
#line 974 "MatrixModule.cs"
        int csharp2cuda_temp_401 = (first)->columns;
#line 974 "MatrixModule.cs"
        bool csharp2cuda_temp_402;
#line 974 "MatrixModule.cs"
        if (((csharp2cuda_temp_400) == (csharp2cuda_temp_401)))
        {
#line 974 "MatrixModule.cs"
            csharp2cuda_temp_402 = ((((void*)(scratch))) != (((void*)(nullptr))));
        }
        else
        {
#line 974 "MatrixModule.cs"
            csharp2cuda_temp_402 = false;
        }
#line 974 "MatrixModule.cs"
        bool csharp2cuda_temp_403;
#line 974 "MatrixModule.cs"
        if (csharp2cuda_temp_402)
        {
#line 975 "MatrixModule.cs"
            int csharp2cuda_temp_404 = (first)->rows;
#line 974 "MatrixModule.cs"
            csharp2cuda_temp_403 = mathblocks_matrix_is_positive_definite(a, csharp2cuda_temp_404, scratch);
        }
        else
        {
#line 974 "MatrixModule.cs"
            csharp2cuda_temp_403 = false;
        }
        (*(csharp2cuda_temp_399) = csharp2cuda_temp_403);
#line 976 "MatrixModule.cs"
        return;
    }
#line 979 "MatrixModule.cs"
    if (((opcode) == (31)))
#line 980 "MatrixModule.cs"
    {
#line 981 "MatrixModule.cs"
#line 981 "MatrixModule.cs"
        int* csharp2cuda_temp_405 = &((output)->boolean_value);
#line 981 "MatrixModule.cs"
        int csharp2cuda_temp_406 = (first)->rows;
#line 981 "MatrixModule.cs"
        int csharp2cuda_temp_407 = (first)->columns;
#line 981 "MatrixModule.cs"
        int csharp2cuda_temp_408 = mathblocks_matrix_is_symmetric(a, csharp2cuda_temp_406, csharp2cuda_temp_407);
        (*(csharp2cuda_temp_405) = csharp2cuda_temp_408);
#line 982 "MatrixModule.cs"
        return;
    }
#line 985 "MatrixModule.cs"
    if (((opcode) == (32)))
#line 986 "MatrixModule.cs"
    {
#line 987 "MatrixModule.cs"
#line 987 "MatrixModule.cs"
        int csharp2cuda_temp_409 = (first)->rows;
#line 987 "MatrixModule.cs"
        bool csharp2cuda_temp_410;
#line 987 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_409) > (8))))
        {
#line 987 "MatrixModule.cs"
            int csharp2cuda_temp_411 = (first)->columns;
#line 987 "MatrixModule.cs"
            csharp2cuda_temp_410 = ((csharp2cuda_temp_411) > (8));
        }
        else
        {
#line 987 "MatrixModule.cs"
            csharp2cuda_temp_410 = true;
        }
#line 987 "MatrixModule.cs"
        bool csharp2cuda_temp_412;
#line 987 "MatrixModule.cs"
        if (!(csharp2cuda_temp_410))
        {
#line 987 "MatrixModule.cs"
            csharp2cuda_temp_412 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 987 "MatrixModule.cs"
            csharp2cuda_temp_412 = true;
        }
        if (csharp2cuda_temp_412)
#line 988 "MatrixModule.cs"
        {
#line 989 "MatrixModule.cs"
#line 989 "MatrixModule.cs"
            int* csharp2cuda_temp_413 = &((output)->valid);
            (*(csharp2cuda_temp_413) = 0);
#line 990 "MatrixModule.cs"
            return;
        }
#line 992 "MatrixModule.cs"
        double* submatrix = scratch;
#line 993 "MatrixModule.cs"
        int csharp2cuda_temp_414 = (first)->count;
#line 993 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_414);
#line 994 "MatrixModule.cs"
#line 994 "MatrixModule.cs"
        int* csharp2cuda_temp_415 = &((output)->boolean_value);
        (*(csharp2cuda_temp_415) = 1);
#line 995 "MatrixModule.cs"
        {
#line 995 "MatrixModule.cs"
            int order = 1;
            while (true)
            {
#line 995 "MatrixModule.cs"
                bool csharp2cuda_temp_417 = (output)->boolean_value;
#line 995 "MatrixModule.cs"
                bool csharp2cuda_temp_418;
#line 995 "MatrixModule.cs"
                if (csharp2cuda_temp_417)
                {
#line 996 "MatrixModule.cs"
                    int csharp2cuda_temp_419 = (first)->rows;
#line 996 "MatrixModule.cs"
                    int csharp2cuda_temp_420 = (first)->columns;
#line 996 "MatrixModule.cs"
                    int csharp2cuda_temp_421;
#line 996 "MatrixModule.cs"
                    if (((csharp2cuda_temp_419) < (csharp2cuda_temp_420)))
                    {
#line 996 "MatrixModule.cs"
                        csharp2cuda_temp_421 = (first)->rows;
                    }
                    else
                    {
#line 996 "MatrixModule.cs"
                        csharp2cuda_temp_421 = (first)->columns;
                    }
#line 995 "MatrixModule.cs"
                    csharp2cuda_temp_418 = ((order) <= (csharp2cuda_temp_421));
                }
                else
                {
#line 995 "MatrixModule.cs"
                    csharp2cuda_temp_418 = false;
                }
                if (!(csharp2cuda_temp_418))
                    break;
#line 997 "MatrixModule.cs"
                {
#line 998 "MatrixModule.cs"
                    int csharp2cuda_temp_422 = (first)->rows;
#line 998 "MatrixModule.cs"
                    int row_limit = csharp2cuda_i32_shl(1, csharp2cuda_temp_422);
#line 999 "MatrixModule.cs"
                    int csharp2cuda_temp_423 = (first)->columns;
#line 999 "MatrixModule.cs"
                    int column_limit = csharp2cuda_i32_shl(1, csharp2cuda_temp_423);
#line 1000 "MatrixModule.cs"
                    {
#line 1000 "MatrixModule.cs"
                        int row_mask = 1;
                        while (true)
                        {
#line 1000 "MatrixModule.cs"
                            bool csharp2cuda_temp_425 = (output)->boolean_value;
#line 1000 "MatrixModule.cs"
                            bool csharp2cuda_temp_426;
#line 1000 "MatrixModule.cs"
                            if (csharp2cuda_temp_425)
                            {
#line 1000 "MatrixModule.cs"
                                csharp2cuda_temp_426 = ((row_mask) < (row_limit));
                            }
                            else
                            {
#line 1000 "MatrixModule.cs"
                                csharp2cuda_temp_426 = false;
                            }
                            if (!(csharp2cuda_temp_426))
                                break;
#line 1001 "MatrixModule.cs"
                            {
#line 1002 "MatrixModule.cs"
                                if (((mathblocks_pop_count(row_mask)) != (order)))
                                {
#line 1003 "MatrixModule.cs"
                                    goto csharp2cuda_for_continue_41;
                                }
#line 1004 "MatrixModule.cs"
                                {
#line 1004 "MatrixModule.cs"
                                    int column_mask = 1;
                                    while (true)
                                    {
                                        if (!(((column_mask) < (column_limit))))
                                            break;
#line 1005 "MatrixModule.cs"
                                        {
#line 1006 "MatrixModule.cs"
                                            if (((mathblocks_pop_count(column_mask)) != (order)))
                                            {
#line 1007 "MatrixModule.cs"
                                                goto csharp2cuda_for_continue_40;
                                            }
#line 1008 "MatrixModule.cs"
#line 1010 "MatrixModule.cs"
                                            int csharp2cuda_temp_428 = (first)->columns;
                                            mathblocks_matrix_submatrix_from_masks(a, csharp2cuda_temp_428, row_mask, column_mask, order, submatrix);
#line 1015 "MatrixModule.cs"
#line 1015 "MatrixModule.cs"
                                            double csharp2cuda_temp_429 = mathblocks_matrix_determinant(submatrix, order, work);
                                            if (((csharp2cuda_temp_429) < (0.0)))
#line 1016 "MatrixModule.cs"
                                            {
#line 1017 "MatrixModule.cs"
#line 1017 "MatrixModule.cs"
                                                int* csharp2cuda_temp_430 = &((output)->boolean_value);
                                                (*(csharp2cuda_temp_430) = 0);
#line 1018 "MatrixModule.cs"
                                                break;
                                            }
                                        }
                                        csharp2cuda_for_continue_40:
#line 1004 "MatrixModule.cs"
                                        int* csharp2cuda_temp_427 = &(column_mask);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_427));
                                    }
                                }
                            }
                            csharp2cuda_for_continue_41:
#line 1000 "MatrixModule.cs"
                            int* csharp2cuda_temp_424 = &(row_mask);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_424));
                        }
                    }
                }
#line 996 "MatrixModule.cs"
                int* csharp2cuda_temp_416 = &(order);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_416));
            }
        }
#line 1023 "MatrixModule.cs"
        return;
    }
#line 1026 "MatrixModule.cs"
#line 1026 "MatrixModule.cs"
    bool csharp2cuda_temp_431;
#line 1026 "MatrixModule.cs"
    if (!(((opcode) == (33))))
    {
#line 1026 "MatrixModule.cs"
        csharp2cuda_temp_431 = ((opcode) == (40));
    }
    else
    {
#line 1026 "MatrixModule.cs"
        csharp2cuda_temp_431 = true;
    }
#line 1026 "MatrixModule.cs"
    bool csharp2cuda_temp_432;
#line 1026 "MatrixModule.cs"
    if (!(csharp2cuda_temp_431))
    {
#line 1026 "MatrixModule.cs"
        csharp2cuda_temp_432 = ((opcode) == (43));
    }
    else
    {
#line 1026 "MatrixModule.cs"
        csharp2cuda_temp_432 = true;
    }
    if (csharp2cuda_temp_432)
#line 1027 "MatrixModule.cs"
    {
#line 1028 "MatrixModule.cs"
        int size = (first)->rows;
#line 1029 "MatrixModule.cs"
#line 1029 "MatrixModule.cs"
        int csharp2cuda_temp_433 = (first)->columns;
#line 1029 "MatrixModule.cs"
        bool csharp2cuda_temp_434;
#line 1029 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_433))))
        {
#line 1029 "MatrixModule.cs"
            csharp2cuda_temp_434 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1029 "MatrixModule.cs"
            csharp2cuda_temp_434 = true;
        }
        if (csharp2cuda_temp_434)
#line 1030 "MatrixModule.cs"
        {
#line 1031 "MatrixModule.cs"
#line 1031 "MatrixModule.cs"
            int* csharp2cuda_temp_435 = &((output)->valid);
            (*(csharp2cuda_temp_435) = 0);
#line 1032 "MatrixModule.cs"
            return;
        }
#line 1034 "MatrixModule.cs"
        double* csharp2cuda_temp_436;
#line 1034 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1034 "MatrixModule.cs"
            csharp2cuda_temp_436 = result;
        }
        else
        {
#line 1034 "MatrixModule.cs"
            int csharp2cuda_temp_437 = (first)->count;
#line 1034 "MatrixModule.cs"
            csharp2cuda_temp_436 = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_437);
        }
#line 1034 "MatrixModule.cs"
        double* eigenvalues = csharp2cuda_temp_436;
#line 1035 "MatrixModule.cs"
#line 1035 "MatrixModule.cs"
        bool csharp2cuda_temp_438;
#line 1035 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1035 "MatrixModule.cs"
            bool csharp2cuda_temp_439 = mathblocks_matrix_is_symmetric(a, size, size);
#line 1035 "MatrixModule.cs"
            csharp2cuda_temp_438 = (!(csharp2cuda_temp_439));
        }
        else
        {
#line 1035 "MatrixModule.cs"
            csharp2cuda_temp_438 = false;
        }
        if (csharp2cuda_temp_438)
#line 1036 "MatrixModule.cs"
        {
#line 1037 "MatrixModule.cs"
#line 1037 "MatrixModule.cs"
            int* csharp2cuda_temp_440 = &((output)->valid);
            (*(csharp2cuda_temp_440) = 0);
#line 1038 "MatrixModule.cs"
            return;
        }
#line 1040 "MatrixModule.cs"
        if (((opcode) == (43)))
        {
#line 1040 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, size);
        }
#line 1041 "MatrixModule.cs"
        mathblocks_matrix_symmetric_eigenvalues(a, size, scratch, eigenvalues);
#line 1042 "MatrixModule.cs"
        if (((opcode) == (33)))
        {
#line 1042 "MatrixModule.cs"
#line 1042 "MatrixModule.cs"
            double* csharp2cuda_temp_441 = &((output)->scalar_value);
#line 1042 "MatrixModule.cs"
            double csharp2cuda_temp_442 = (eigenvalues)[csharp2cuda_i32_sub(size, 1)];
            (*(csharp2cuda_temp_441) = csharp2cuda_temp_442);
        }
        else
        {
#line 1043 "MatrixModule.cs"
            if (((opcode) == (40)))
            {
#line 1043 "MatrixModule.cs"
#line 1043 "MatrixModule.cs"
                double* csharp2cuda_temp_443 = &((output)->scalar_value);
#line 1043 "MatrixModule.cs"
                double csharp2cuda_temp_444 = (eigenvalues)[0];
                (*(csharp2cuda_temp_443) = csharp2cuda_temp_444);
            }
        }
#line 1044 "MatrixModule.cs"
        {
#line 1044 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1045 "MatrixModule.cs"
#line 1045 "MatrixModule.cs"
                double csharp2cuda_temp_446 = (eigenvalues)[index];
                if ((!(isfinite(csharp2cuda_temp_446))))
                {
#line 1045 "MatrixModule.cs"
#line 1045 "MatrixModule.cs"
                    int* csharp2cuda_temp_447 = &((output)->valid);
                    (*(csharp2cuda_temp_447) = 0);
                }
#line 1044 "MatrixModule.cs"
                int* csharp2cuda_temp_445 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_445));
            }
        }
#line 1046 "MatrixModule.cs"
        return;
    }
#line 1049 "MatrixModule.cs"
    if (((opcode) == (34)))
#line 1050 "MatrixModule.cs"
    {
#line 1051 "MatrixModule.cs"
#line 1051 "MatrixModule.cs"
        int csharp2cuda_temp_448 = (first)->rows;
#line 1051 "MatrixModule.cs"
        int csharp2cuda_temp_449 = (first)->columns;
#line 1051 "MatrixModule.cs"
        bool csharp2cuda_temp_450;
#line 1051 "MatrixModule.cs"
        if (!(((csharp2cuda_temp_448) > (csharp2cuda_temp_449))))
        {
#line 1051 "MatrixModule.cs"
            int csharp2cuda_temp_451 = (first)->columns;
#line 1051 "MatrixModule.cs"
            csharp2cuda_temp_450 = ((csharp2cuda_temp_451) > (20));
        }
        else
        {
#line 1051 "MatrixModule.cs"
            csharp2cuda_temp_450 = true;
        }
#line 1051 "MatrixModule.cs"
        bool csharp2cuda_temp_452;
#line 1051 "MatrixModule.cs"
        if (!(csharp2cuda_temp_450))
        {
#line 1051 "MatrixModule.cs"
            csharp2cuda_temp_452 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1051 "MatrixModule.cs"
            csharp2cuda_temp_452 = true;
        }
        if (csharp2cuda_temp_452)
#line 1052 "MatrixModule.cs"
        {
#line 1053 "MatrixModule.cs"
#line 1053 "MatrixModule.cs"
            int* csharp2cuda_temp_453 = &((output)->valid);
            (*(csharp2cuda_temp_453) = 0);
#line 1054 "MatrixModule.cs"
            return;
        }
#line 1056 "MatrixModule.cs"
        double* submatrix = scratch;
#line 1057 "MatrixModule.cs"
        int csharp2cuda_temp_454 = (first)->count;
#line 1057 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_454);
#line 1058 "MatrixModule.cs"
        int csharp2cuda_temp_455 = (first)->rows;
#line 1058 "MatrixModule.cs"
        int row_mask = csharp2cuda_i32_sub(csharp2cuda_i32_shl(1, csharp2cuda_temp_455), 1);
#line 1059 "MatrixModule.cs"
        int csharp2cuda_temp_456 = (first)->columns;
#line 1059 "MatrixModule.cs"
        int limit = csharp2cuda_i32_shl(1, csharp2cuda_temp_456);
#line 1060 "MatrixModule.cs"
        int output_index = 0;
#line 1061 "MatrixModule.cs"
        {
#line 1061 "MatrixModule.cs"
            int column_mask = 1;
            while (true)
            {
                if (!(((column_mask) < (limit))))
                    break;
#line 1062 "MatrixModule.cs"
                {
#line 1063 "MatrixModule.cs"
#line 1063 "MatrixModule.cs"
                    int csharp2cuda_temp_458 = (first)->rows;
                    if (((mathblocks_pop_count(column_mask)) != (csharp2cuda_temp_458)))
                    {
#line 1064 "MatrixModule.cs"
                        goto csharp2cuda_for_continue_44;
                    }
#line 1065 "MatrixModule.cs"
#line 1067 "MatrixModule.cs"
                    int csharp2cuda_temp_459 = (first)->columns;
#line 1070 "MatrixModule.cs"
                    int csharp2cuda_temp_460 = (first)->rows;
                    mathblocks_matrix_submatrix_from_masks(a, csharp2cuda_temp_459, row_mask, column_mask, csharp2cuda_temp_460, submatrix);
#line 1072 "MatrixModule.cs"
#line 1072 "MatrixModule.cs"
                    int* csharp2cuda_temp_461 = &(output_index);
#line 1072 "MatrixModule.cs"
                    int csharp2cuda_temp_462 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_461));
#line 1072 "MatrixModule.cs"
                    double* csharp2cuda_temp_463 = &((result)[csharp2cuda_temp_462]);
#line 1074 "MatrixModule.cs"
                    int csharp2cuda_temp_464 = (first)->rows;
#line 1072 "MatrixModule.cs"
                    double csharp2cuda_temp_465 = mathblocks_matrix_determinant(submatrix, csharp2cuda_temp_464, work);
                    (*(csharp2cuda_temp_463) = csharp2cuda_temp_465);
                }
                csharp2cuda_for_continue_44:
#line 1061 "MatrixModule.cs"
                int* csharp2cuda_temp_457 = &(column_mask);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_457));
            }
        }
#line 1077 "MatrixModule.cs"
        mathblocks_set_vector_shape(output, output_index);
#line 1078 "MatrixModule.cs"
        return;
    }
#line 1081 "MatrixModule.cs"
#line 1081 "MatrixModule.cs"
    bool csharp2cuda_temp_466;
#line 1081 "MatrixModule.cs"
    if (!(((opcode) == (35))))
    {
#line 1081 "MatrixModule.cs"
        csharp2cuda_temp_466 = ((opcode) == (36));
    }
    else
    {
#line 1081 "MatrixModule.cs"
        csharp2cuda_temp_466 = true;
    }
    if (csharp2cuda_temp_466)
#line 1082 "MatrixModule.cs"
    {
#line 1083 "MatrixModule.cs"
        int iterations = 0;
#line 1084 "MatrixModule.cs"
        int size = (first)->rows;
#line 1085 "MatrixModule.cs"
#line 1085 "MatrixModule.cs"
        int csharp2cuda_temp_467 = (first)->columns;
#line 1085 "MatrixModule.cs"
        bool csharp2cuda_temp_468;
#line 1085 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_467))))
        {
#line 1086 "MatrixModule.cs"
            double csharp2cuda_temp_469 = (second)->scalar_value;
#line 1086 "MatrixModule.cs"
            int* csharp2cuda_temp_470 = &(iterations);
#line 1086 "MatrixModule.cs"
            bool csharp2cuda_temp_471 = mathblocks_nonnegative_integer(csharp2cuda_temp_469, csharp2cuda_temp_470);
#line 1085 "MatrixModule.cs"
            csharp2cuda_temp_468 = (!(csharp2cuda_temp_471));
        }
        else
        {
#line 1085 "MatrixModule.cs"
            csharp2cuda_temp_468 = true;
        }
#line 1085 "MatrixModule.cs"
        bool csharp2cuda_temp_472;
#line 1085 "MatrixModule.cs"
        if (!(csharp2cuda_temp_468))
        {
#line 1085 "MatrixModule.cs"
            csharp2cuda_temp_472 = ((iterations) <= (0));
        }
        else
        {
#line 1085 "MatrixModule.cs"
            csharp2cuda_temp_472 = true;
        }
#line 1085 "MatrixModule.cs"
        bool csharp2cuda_temp_473;
#line 1085 "MatrixModule.cs"
        if (!(csharp2cuda_temp_472))
        {
#line 1085 "MatrixModule.cs"
            csharp2cuda_temp_473 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1085 "MatrixModule.cs"
            csharp2cuda_temp_473 = true;
        }
        if (csharp2cuda_temp_473)
#line 1088 "MatrixModule.cs"
        {
#line 1089 "MatrixModule.cs"
#line 1089 "MatrixModule.cs"
            int* csharp2cuda_temp_474 = &((output)->valid);
            (*(csharp2cuda_temp_474) = 0);
#line 1090 "MatrixModule.cs"
            return;
        }
#line 1092 "MatrixModule.cs"
        {
#line 1092 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
#line 1092 "MatrixModule.cs"
                int csharp2cuda_temp_476 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_476))))
                    break;
#line 1093 "MatrixModule.cs"
#line 1093 "MatrixModule.cs"
                double csharp2cuda_temp_477 = (a)[index];
                if (((csharp2cuda_temp_477) < (0.0)))
                {
#line 1093 "MatrixModule.cs"
#line 1093 "MatrixModule.cs"
                    int* csharp2cuda_temp_478 = &((output)->valid);
                    (*(csharp2cuda_temp_478) = 0);
                }
#line 1092 "MatrixModule.cs"
                int* csharp2cuda_temp_475 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_475));
            }
        }
#line 1094 "MatrixModule.cs"
#line 1094 "MatrixModule.cs"
        bool csharp2cuda_temp_479 = (output)->valid;
        if ((!(csharp2cuda_temp_479)))
        {
#line 1095 "MatrixModule.cs"
            return;
        }
#line 1096 "MatrixModule.cs"
        double* csharp2cuda_temp_480;
#line 1096 "MatrixModule.cs"
        if (((opcode) == (36)))
        {
#line 1096 "MatrixModule.cs"
            csharp2cuda_temp_480 = result;
        }
        else
        {
#line 1096 "MatrixModule.cs"
            csharp2cuda_temp_480 = scratch;
        }
#line 1096 "MatrixModule.cs"
        double* vector = csharp2cuda_temp_480;
#line 1097 "MatrixModule.cs"
        double* csharp2cuda_temp_481;
#line 1097 "MatrixModule.cs"
        if (((opcode) == (36)))
        {
#line 1097 "MatrixModule.cs"
            csharp2cuda_temp_481 = scratch;
        }
        else
        {
#line 1097 "MatrixModule.cs"
            csharp2cuda_temp_481 = csharp2cuda_pointer_add(scratch, size);
        }
#line 1097 "MatrixModule.cs"
        double* next = csharp2cuda_temp_481;
#line 1098 "MatrixModule.cs"
        double* csharp2cuda_temp_482;
#line 1098 "MatrixModule.cs"
        if (((opcode) == (36)))
        {
#line 1098 "MatrixModule.cs"
            csharp2cuda_temp_482 = csharp2cuda_pointer_add(scratch, size);
        }
        else
        {
#line 1098 "MatrixModule.cs"
            csharp2cuda_temp_482 = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(size, 2));
        }
#line 1098 "MatrixModule.cs"
        double* products = csharp2cuda_temp_482;
#line 1099 "MatrixModule.cs"
        {
#line 1099 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1100 "MatrixModule.cs"
#line 1100 "MatrixModule.cs"
                double* csharp2cuda_temp_484 = &((vector)[index]);
#line 1100 "MatrixModule.cs"
                double csharp2cuda_temp_485 = __ddiv_rn(1.0, ((double)(size)));
                (*(csharp2cuda_temp_484) = csharp2cuda_temp_485);
#line 1099 "MatrixModule.cs"
                int* csharp2cuda_temp_483 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_483));
            }
        }
#line 1101 "MatrixModule.cs"
        {
#line 1101 "MatrixModule.cs"
            int iteration = 0;
            while (true)
            {
                if (!(((iteration) < (iterations))))
                    break;
#line 1102 "MatrixModule.cs"
                {
#line 1103 "MatrixModule.cs"
                    {
#line 1103 "MatrixModule.cs"
                        int row = 0;
                        while (true)
                        {
                            if (!(((row) < (size))))
                                break;
#line 1104 "MatrixModule.cs"
                            {
#line 1105 "MatrixModule.cs"
                                double sum = 0.0;
#line 1106 "MatrixModule.cs"
                                {
#line 1106 "MatrixModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (size))))
                                            break;
#line 1107 "MatrixModule.cs"
#line 1107 "MatrixModule.cs"
                                        double* csharp2cuda_temp_489 = &(sum);
#line 1107 "MatrixModule.cs"
                                        double csharp2cuda_temp_490 = *(csharp2cuda_temp_489);
#line 1107 "MatrixModule.cs"
                                        double csharp2cuda_temp_491 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 1107 "MatrixModule.cs"
                                        double csharp2cuda_temp_492 = (vector)[column];
                                        (*(csharp2cuda_temp_489) = __dadd_rn(csharp2cuda_temp_490, __dmul_rn(csharp2cuda_temp_491, csharp2cuda_temp_492)));
#line 1106 "MatrixModule.cs"
                                        int* csharp2cuda_temp_488 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_488));
                                    }
                                }
#line 1108 "MatrixModule.cs"
#line 1108 "MatrixModule.cs"
                                double* csharp2cuda_temp_493 = &((next)[row]);
#line 1108 "MatrixModule.cs"
                                double csharp2cuda_temp_494 = (vector)[row];
                                (*(csharp2cuda_temp_493) = __dadd_rn(sum, csharp2cuda_temp_494));
                            }
#line 1103 "MatrixModule.cs"
                            int* csharp2cuda_temp_487 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_487));
                        }
                    }
#line 1110 "MatrixModule.cs"
                    double norm = mathblocks_compensated_sum(next, size);
#line 1111 "MatrixModule.cs"
                    {
#line 1111 "MatrixModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (size))))
                                break;
#line 1112 "MatrixModule.cs"
#line 1112 "MatrixModule.cs"
                            double* csharp2cuda_temp_496 = &((vector)[index]);
#line 1112 "MatrixModule.cs"
                            double csharp2cuda_temp_497 = (next)[index];
#line 1112 "MatrixModule.cs"
                            double csharp2cuda_temp_498 = __ddiv_rn(csharp2cuda_temp_497, norm);
                            (*(csharp2cuda_temp_496) = csharp2cuda_temp_498);
#line 1111 "MatrixModule.cs"
                            int* csharp2cuda_temp_495 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_495));
                        }
                    }
                }
#line 1101 "MatrixModule.cs"
                int* csharp2cuda_temp_486 = &(iteration);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_486));
            }
        }
#line 1114 "MatrixModule.cs"
        if (((opcode) == (36)))
#line 1115 "MatrixModule.cs"
        {
#line 1116 "MatrixModule.cs"
            mathblocks_set_vector_shape(output, size);
#line 1117 "MatrixModule.cs"
            return;
        }
#line 1119 "MatrixModule.cs"
        {
#line 1119 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 1120 "MatrixModule.cs"
                {
#line 1121 "MatrixModule.cs"
                    double sum = 0.0;
#line 1122 "MatrixModule.cs"
                    {
#line 1122 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 1123 "MatrixModule.cs"
#line 1123 "MatrixModule.cs"
                            double* csharp2cuda_temp_501 = &(sum);
#line 1123 "MatrixModule.cs"
                            double csharp2cuda_temp_502 = *(csharp2cuda_temp_501);
#line 1123 "MatrixModule.cs"
                            double csharp2cuda_temp_503 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 1123 "MatrixModule.cs"
                            double csharp2cuda_temp_504 = (vector)[column];
                            (*(csharp2cuda_temp_501) = __dadd_rn(csharp2cuda_temp_502, __dmul_rn(csharp2cuda_temp_503, csharp2cuda_temp_504)));
#line 1122 "MatrixModule.cs"
                            int* csharp2cuda_temp_500 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_500));
                        }
                    }
#line 1124 "MatrixModule.cs"
#line 1124 "MatrixModule.cs"
                    double* csharp2cuda_temp_505 = &((next)[row]);
                    (*(csharp2cuda_temp_505) = sum);
                }
#line 1119 "MatrixModule.cs"
                int* csharp2cuda_temp_499 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_499));
            }
        }
#line 1126 "MatrixModule.cs"
        {
#line 1126 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1127 "MatrixModule.cs"
#line 1127 "MatrixModule.cs"
                double* csharp2cuda_temp_507 = &((products)[index]);
#line 1127 "MatrixModule.cs"
                double csharp2cuda_temp_508 = (vector)[index];
#line 1127 "MatrixModule.cs"
                double csharp2cuda_temp_509 = (next)[index];
                (*(csharp2cuda_temp_507) = __dmul_rn(csharp2cuda_temp_508, csharp2cuda_temp_509));
#line 1126 "MatrixModule.cs"
                int* csharp2cuda_temp_506 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_506));
            }
        }
#line 1128 "MatrixModule.cs"
        double numerator = mathblocks_compensated_sum(products, size);
#line 1129 "MatrixModule.cs"
        {
#line 1129 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (size))))
                    break;
#line 1130 "MatrixModule.cs"
#line 1130 "MatrixModule.cs"
                double* csharp2cuda_temp_511 = &((products)[index]);
#line 1130 "MatrixModule.cs"
                double csharp2cuda_temp_512 = (vector)[index];
#line 1130 "MatrixModule.cs"
                double csharp2cuda_temp_513 = (vector)[index];
                (*(csharp2cuda_temp_511) = __dmul_rn(csharp2cuda_temp_512, csharp2cuda_temp_513));
#line 1129 "MatrixModule.cs"
                int* csharp2cuda_temp_510 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_510));
            }
        }
#line 1131 "MatrixModule.cs"
        double denominator = mathblocks_compensated_sum(products, size);
#line 1132 "MatrixModule.cs"
#line 1132 "MatrixModule.cs"
        double* csharp2cuda_temp_514 = &((output)->scalar_value);
#line 1132 "MatrixModule.cs"
        double csharp2cuda_temp_515 = __ddiv_rn(numerator, denominator);
        (*(csharp2cuda_temp_514) = csharp2cuda_temp_515);
#line 1133 "MatrixModule.cs"
#line 1133 "MatrixModule.cs"
        double csharp2cuda_temp_516 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_516))))
        {
#line 1133 "MatrixModule.cs"
#line 1133 "MatrixModule.cs"
            int* csharp2cuda_temp_517 = &((output)->valid);
            (*(csharp2cuda_temp_517) = 0);
        }
#line 1134 "MatrixModule.cs"
        return;
    }
#line 1137 "MatrixModule.cs"
    if (((opcode) == (37)))
#line 1138 "MatrixModule.cs"
    {
#line 1139 "MatrixModule.cs"
        int size = (first)->rows;
#line 1140 "MatrixModule.cs"
#line 1140 "MatrixModule.cs"
        int csharp2cuda_temp_518 = (first)->columns;
#line 1140 "MatrixModule.cs"
        bool csharp2cuda_temp_519;
#line 1140 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_518))))
        {
#line 1140 "MatrixModule.cs"
            csharp2cuda_temp_519 = ((size) > (20));
        }
        else
        {
#line 1140 "MatrixModule.cs"
            csharp2cuda_temp_519 = true;
        }
#line 1140 "MatrixModule.cs"
        bool csharp2cuda_temp_520;
#line 1140 "MatrixModule.cs"
        if (!(csharp2cuda_temp_519))
        {
#line 1140 "MatrixModule.cs"
            csharp2cuda_temp_520 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1140 "MatrixModule.cs"
            csharp2cuda_temp_520 = true;
        }
        if (csharp2cuda_temp_520)
#line 1141 "MatrixModule.cs"
        {
#line 1142 "MatrixModule.cs"
#line 1142 "MatrixModule.cs"
            int* csharp2cuda_temp_521 = &((output)->valid);
            (*(csharp2cuda_temp_521) = 0);
#line 1143 "MatrixModule.cs"
            return;
        }
#line 1145 "MatrixModule.cs"
        int limit = csharp2cuda_i32_shl(1, size);
#line 1146 "MatrixModule.cs"
        mathblocks_set_vector_shape(output, csharp2cuda_i32_sub(limit, 1));
#line 1147 "MatrixModule.cs"
        double* submatrix = scratch;
#line 1148 "MatrixModule.cs"
        int csharp2cuda_temp_522 = (first)->count;
#line 1148 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_522);
#line 1149 "MatrixModule.cs"
        {
#line 1149 "MatrixModule.cs"
            int mask = 1;
            while (true)
            {
                if (!(((mask) < (limit))))
                    break;
#line 1150 "MatrixModule.cs"
                {
#line 1151 "MatrixModule.cs"
                    int order = mathblocks_pop_count(mask);
#line 1152 "MatrixModule.cs"
                    mathblocks_matrix_submatrix_from_masks(a, size, mask, mask, order, submatrix);
#line 1159 "MatrixModule.cs"
#line 1159 "MatrixModule.cs"
                    double* csharp2cuda_temp_524 = &((result)[csharp2cuda_i32_sub(mask, 1)]);
#line 1159 "MatrixModule.cs"
                    double csharp2cuda_temp_525 = mathblocks_matrix_determinant(submatrix, order, work);
                    (*(csharp2cuda_temp_524) = csharp2cuda_temp_525);
                }
#line 1149 "MatrixModule.cs"
                int* csharp2cuda_temp_523 = &(mask);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_523));
            }
        }
#line 1161 "MatrixModule.cs"
        return;
    }
#line 1164 "MatrixModule.cs"
    if (((opcode) == (38)))
#line 1165 "MatrixModule.cs"
    {
#line 1166 "MatrixModule.cs"
        if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 1167 "MatrixModule.cs"
        {
#line 1168 "MatrixModule.cs"
#line 1168 "MatrixModule.cs"
            int* csharp2cuda_temp_526 = &((output)->valid);
            (*(csharp2cuda_temp_526) = 0);
#line 1169 "MatrixModule.cs"
            return;
        }
#line 1171 "MatrixModule.cs"
#line 1171 "MatrixModule.cs"
        double* csharp2cuda_temp_527 = &((output)->scalar_value);
#line 1173 "MatrixModule.cs"
        int csharp2cuda_temp_528 = (first)->rows;
#line 1174 "MatrixModule.cs"
        int csharp2cuda_temp_529 = (first)->columns;
#line 1171 "MatrixModule.cs"
        int csharp2cuda_temp_530 = mathblocks_matrix_rank(a, csharp2cuda_temp_528, csharp2cuda_temp_529, scratch);
        (*(csharp2cuda_temp_527) = ((double)(csharp2cuda_temp_530)));
#line 1176 "MatrixModule.cs"
        return;
    }
#line 1179 "MatrixModule.cs"
    if (((opcode) == (39)))
#line 1180 "MatrixModule.cs"
    {
#line 1181 "MatrixModule.cs"
        int retained = 0;
#line 1182 "MatrixModule.cs"
        int size = (first)->rows;
#line 1183 "MatrixModule.cs"
#line 1183 "MatrixModule.cs"
        int csharp2cuda_temp_531 = (first)->columns;
#line 1183 "MatrixModule.cs"
        bool csharp2cuda_temp_532;
#line 1183 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_531))))
        {
#line 1184 "MatrixModule.cs"
            double csharp2cuda_temp_533 = (second)->scalar_value;
#line 1184 "MatrixModule.cs"
            int* csharp2cuda_temp_534 = &(retained);
#line 1184 "MatrixModule.cs"
            bool csharp2cuda_temp_535 = mathblocks_nonnegative_integer(csharp2cuda_temp_533, csharp2cuda_temp_534);
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_532 = (!(csharp2cuda_temp_535));
        }
        else
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_532 = true;
        }
#line 1183 "MatrixModule.cs"
        bool csharp2cuda_temp_536;
#line 1183 "MatrixModule.cs"
        if (!(csharp2cuda_temp_532))
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_536 = ((retained) <= (0));
        }
        else
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_536 = true;
        }
#line 1183 "MatrixModule.cs"
        bool csharp2cuda_temp_537;
#line 1183 "MatrixModule.cs"
        if (!(csharp2cuda_temp_536))
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_537 = ((retained) >= (size));
        }
        else
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_537 = true;
        }
#line 1183 "MatrixModule.cs"
        bool csharp2cuda_temp_538;
#line 1183 "MatrixModule.cs"
        if (!(csharp2cuda_temp_537))
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_538 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1183 "MatrixModule.cs"
            csharp2cuda_temp_538 = true;
        }
        if (csharp2cuda_temp_538)
#line 1186 "MatrixModule.cs"
        {
#line 1187 "MatrixModule.cs"
#line 1187 "MatrixModule.cs"
            int* csharp2cuda_temp_539 = &((output)->valid);
            (*(csharp2cuda_temp_539) = 0);
#line 1188 "MatrixModule.cs"
            return;
        }
#line 1190 "MatrixModule.cs"
        int eliminated = csharp2cuda_i32_sub(size, retained);
#line 1191 "MatrixModule.cs"
        double* leading = scratch;
#line 1192 "MatrixModule.cs"
        double* upper = csharp2cuda_pointer_add(leading, csharp2cuda_i32_mul(retained, retained));
#line 1193 "MatrixModule.cs"
        double* lower = csharp2cuda_pointer_add(upper, csharp2cuda_i32_mul(retained, eliminated));
#line 1194 "MatrixModule.cs"
        double* trailing = csharp2cuda_pointer_add(lower, csharp2cuda_i32_mul(eliminated, retained));
#line 1195 "MatrixModule.cs"
        double* inverse = csharp2cuda_pointer_add(trailing, csharp2cuda_i32_mul(eliminated, eliminated));
#line 1196 "MatrixModule.cs"
        double* augmented = csharp2cuda_pointer_add(inverse, csharp2cuda_i32_mul(eliminated, eliminated));
#line 1197 "MatrixModule.cs"
        double* solution = csharp2cuda_pointer_add(augmented, csharp2cuda_i32_mul(eliminated, csharp2cuda_i32_add(eliminated, 1)));
#line 1198 "MatrixModule.cs"
        double* upper_inverse = csharp2cuda_pointer_add(solution, eliminated);
#line 1199 "MatrixModule.cs"
        double* product = csharp2cuda_pointer_add(upper_inverse, csharp2cuda_i32_mul(retained, eliminated));
#line 1200 "MatrixModule.cs"
        {
#line 1200 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 1201 "MatrixModule.cs"
                {
#line 1202 "MatrixModule.cs"
                    {
#line 1202 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 1203 "MatrixModule.cs"
                            {
#line 1204 "MatrixModule.cs"
                                double value = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 1205 "MatrixModule.cs"
#line 1205 "MatrixModule.cs"
                                bool csharp2cuda_temp_542;
#line 1205 "MatrixModule.cs"
                                if (((row) < (retained)))
                                {
#line 1205 "MatrixModule.cs"
                                    csharp2cuda_temp_542 = ((column) < (retained));
                                }
                                else
                                {
#line 1205 "MatrixModule.cs"
                                    csharp2cuda_temp_542 = false;
                                }
                                if (csharp2cuda_temp_542)
                                {
#line 1206 "MatrixModule.cs"
#line 1206 "MatrixModule.cs"
                                    double* csharp2cuda_temp_543 = &((leading)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, retained), column)]);
                                    (*(csharp2cuda_temp_543) = value);
                                }
                                else
                                {
#line 1207 "MatrixModule.cs"
                                    if (((row) < (retained)))
                                    {
#line 1208 "MatrixModule.cs"
#line 1208 "MatrixModule.cs"
                                        double* csharp2cuda_temp_544 = &((upper)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), column), retained)]);
                                        (*(csharp2cuda_temp_544) = value);
                                    }
                                    else
                                    {
#line 1209 "MatrixModule.cs"
                                        if (((column) < (retained)))
                                        {
#line 1210 "MatrixModule.cs"
#line 1210 "MatrixModule.cs"
                                            double* csharp2cuda_temp_545 = &((lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, retained), retained), column)]);
                                            (*(csharp2cuda_temp_545) = value);
                                        }
                                        else
                                        {
#line 1212 "MatrixModule.cs"
#line 1212 "MatrixModule.cs"
                                            double* csharp2cuda_temp_546 = &((trailing)[csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, retained), eliminated), column), retained)]);
                                            (*(csharp2cuda_temp_546) = value);
                                        }
                                    }
                                }
                            }
#line 1202 "MatrixModule.cs"
                            int* csharp2cuda_temp_541 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_541));
                        }
                    }
                }
#line 1200 "MatrixModule.cs"
                int* csharp2cuda_temp_540 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_540));
            }
        }
#line 1215 "MatrixModule.cs"
        {
#line 1215 "MatrixModule.cs"
            int column = 0;
            while (true)
            {
                if (!(((column) < (eliminated))))
                    break;
#line 1216 "MatrixModule.cs"
                {
#line 1217 "MatrixModule.cs"
#line 1217 "MatrixModule.cs"
                    bool csharp2cuda_temp_548 = mathblocks_matrix_try_solve_basis(trailing, eliminated, column, augmented, solution);
                    if ((!(csharp2cuda_temp_548)))
#line 1223 "MatrixModule.cs"
                    {
#line 1224 "MatrixModule.cs"
#line 1224 "MatrixModule.cs"
                        int* csharp2cuda_temp_549 = &((output)->valid);
                        (*(csharp2cuda_temp_549) = 0);
#line 1225 "MatrixModule.cs"
                        return;
                    }
#line 1227 "MatrixModule.cs"
                    {
#line 1227 "MatrixModule.cs"
                        int row = 0;
                        while (true)
                        {
                            if (!(((row) < (eliminated))))
                                break;
#line 1228 "MatrixModule.cs"
#line 1228 "MatrixModule.cs"
                            double* csharp2cuda_temp_551 = &((inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), column)]);
#line 1228 "MatrixModule.cs"
                            double csharp2cuda_temp_552 = (solution)[row];
                            (*(csharp2cuda_temp_551) = csharp2cuda_temp_552);
#line 1227 "MatrixModule.cs"
                            int* csharp2cuda_temp_550 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_550));
                        }
                    }
                }
#line 1215 "MatrixModule.cs"
                int* csharp2cuda_temp_547 = &(column);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_547));
            }
        }
#line 1230 "MatrixModule.cs"
        {
#line 1230 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (retained))))
                    break;
#line 1231 "MatrixModule.cs"
                {
#line 1232 "MatrixModule.cs"
                    {
#line 1232 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (eliminated))))
                                break;
#line 1233 "MatrixModule.cs"
                            {
#line 1234 "MatrixModule.cs"
                                double sum = 0.0;
#line 1235 "MatrixModule.cs"
                                {
#line 1235 "MatrixModule.cs"
                                    int inner = 0;
                                    while (true)
                                    {
                                        if (!(((inner) < (eliminated))))
                                            break;
#line 1236 "MatrixModule.cs"
#line 1236 "MatrixModule.cs"
                                        double* csharp2cuda_temp_556 = &(sum);
#line 1236 "MatrixModule.cs"
                                        double csharp2cuda_temp_557 = *(csharp2cuda_temp_556);
#line 1236 "MatrixModule.cs"
                                        double csharp2cuda_temp_558 = (upper)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), inner)];
#line 1237 "MatrixModule.cs"
                                        double csharp2cuda_temp_559 = (inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, eliminated), column)];
                                        (*(csharp2cuda_temp_556) = __dadd_rn(csharp2cuda_temp_557, __dmul_rn(csharp2cuda_temp_558, csharp2cuda_temp_559)));
#line 1235 "MatrixModule.cs"
                                        int* csharp2cuda_temp_555 = &(inner);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_555));
                                    }
                                }
#line 1238 "MatrixModule.cs"
#line 1238 "MatrixModule.cs"
                                double* csharp2cuda_temp_560 = &((upper_inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), column)]);
                                (*(csharp2cuda_temp_560) = sum);
                            }
#line 1232 "MatrixModule.cs"
                            int* csharp2cuda_temp_554 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_554));
                        }
                    }
                }
#line 1230 "MatrixModule.cs"
                int* csharp2cuda_temp_553 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_553));
            }
        }
#line 1241 "MatrixModule.cs"
        {
#line 1241 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (retained))))
                    break;
#line 1242 "MatrixModule.cs"
                {
#line 1243 "MatrixModule.cs"
                    {
#line 1243 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (retained))))
                                break;
#line 1244 "MatrixModule.cs"
                            {
#line 1245 "MatrixModule.cs"
                                double sum = 0.0;
#line 1246 "MatrixModule.cs"
                                {
#line 1246 "MatrixModule.cs"
                                    int inner = 0;
                                    while (true)
                                    {
                                        if (!(((inner) < (eliminated))))
                                            break;
#line 1247 "MatrixModule.cs"
#line 1247 "MatrixModule.cs"
                                        double* csharp2cuda_temp_564 = &(sum);
#line 1247 "MatrixModule.cs"
                                        double csharp2cuda_temp_565 = *(csharp2cuda_temp_564);
#line 1247 "MatrixModule.cs"
                                        double csharp2cuda_temp_566 = (upper_inverse)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, eliminated), inner)];
#line 1248 "MatrixModule.cs"
                                        double csharp2cuda_temp_567 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, retained), column)];
                                        (*(csharp2cuda_temp_564) = __dadd_rn(csharp2cuda_temp_565, __dmul_rn(csharp2cuda_temp_566, csharp2cuda_temp_567)));
#line 1246 "MatrixModule.cs"
                                        int* csharp2cuda_temp_563 = &(inner);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_563));
                                    }
                                }
#line 1249 "MatrixModule.cs"
#line 1249 "MatrixModule.cs"
                                double* csharp2cuda_temp_568 = &((product)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, retained), column)]);
                                (*(csharp2cuda_temp_568) = sum);
                            }
#line 1243 "MatrixModule.cs"
                            int* csharp2cuda_temp_562 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_562));
                        }
                    }
                }
#line 1241 "MatrixModule.cs"
                int* csharp2cuda_temp_561 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_561));
            }
        }
#line 1252 "MatrixModule.cs"
        mathblocks_matrix_shape(output, retained, retained);
#line 1253 "MatrixModule.cs"
        {
#line 1253 "MatrixModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (csharp2cuda_i32_mul(retained, retained)))))
                    break;
#line 1254 "MatrixModule.cs"
                {
#line 1255 "MatrixModule.cs"
#line 1255 "MatrixModule.cs"
                    double* csharp2cuda_temp_570 = &((result)[index]);
#line 1255 "MatrixModule.cs"
                    double csharp2cuda_temp_571 = (leading)[index];
#line 1255 "MatrixModule.cs"
                    double csharp2cuda_temp_572 = (product)[index];
                    (*(csharp2cuda_temp_570) = __dsub_rn(csharp2cuda_temp_571, csharp2cuda_temp_572));
#line 1256 "MatrixModule.cs"
#line 1256 "MatrixModule.cs"
                    double csharp2cuda_temp_573 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_573))))
                    {
#line 1256 "MatrixModule.cs"
#line 1256 "MatrixModule.cs"
                        int* csharp2cuda_temp_574 = &((output)->valid);
                        (*(csharp2cuda_temp_574) = 0);
                    }
                }
#line 1253 "MatrixModule.cs"
                int* csharp2cuda_temp_569 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_569));
            }
        }
#line 1258 "MatrixModule.cs"
        return;
    }
#line 1261 "MatrixModule.cs"
    if (((opcode) == (41)))
#line 1262 "MatrixModule.cs"
    {
#line 1263 "MatrixModule.cs"
        int size = (first)->rows;
#line 1264 "MatrixModule.cs"
#line 1264 "MatrixModule.cs"
        int csharp2cuda_temp_575 = (first)->columns;
#line 1264 "MatrixModule.cs"
        bool csharp2cuda_temp_576;
#line 1264 "MatrixModule.cs"
        if (!(((size) != (csharp2cuda_temp_575))))
        {
#line 1264 "MatrixModule.cs"
            int csharp2cuda_temp_577 = (second)->count;
#line 1264 "MatrixModule.cs"
            csharp2cuda_temp_576 = ((csharp2cuda_temp_577) != (size));
        }
        else
        {
#line 1264 "MatrixModule.cs"
            csharp2cuda_temp_576 = true;
        }
#line 1264 "MatrixModule.cs"
        bool csharp2cuda_temp_578;
#line 1264 "MatrixModule.cs"
        if (!(csharp2cuda_temp_576))
        {
#line 1264 "MatrixModule.cs"
            csharp2cuda_temp_578 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1264 "MatrixModule.cs"
            csharp2cuda_temp_578 = true;
        }
        if (csharp2cuda_temp_578)
#line 1265 "MatrixModule.cs"
        {
#line 1266 "MatrixModule.cs"
#line 1266 "MatrixModule.cs"
            int* csharp2cuda_temp_579 = &((output)->valid);
            (*(csharp2cuda_temp_579) = 0);
#line 1267 "MatrixModule.cs"
            return;
        }
#line 1269 "MatrixModule.cs"
        mathblocks_set_vector_shape(output, size);
#line 1270 "MatrixModule.cs"
#line 1270 "MatrixModule.cs"
        bool csharp2cuda_temp_580 = mathblocks_matrix_try_solve(a, b, size, scratch, result);
        if ((!(csharp2cuda_temp_580)))
        {
#line 1271 "MatrixModule.cs"
#line 1271 "MatrixModule.cs"
            int* csharp2cuda_temp_581 = &((output)->valid);
            (*(csharp2cuda_temp_581) = 0);
        }
#line 1272 "MatrixModule.cs"
        return;
    }
#line 1275 "MatrixModule.cs"
    if (((opcode) == (42)))
#line 1276 "MatrixModule.cs"
    {
#line 1277 "MatrixModule.cs"
        int iterations = 0;
#line 1278 "MatrixModule.cs"
#line 1278 "MatrixModule.cs"
        double csharp2cuda_temp_582 = (second)->scalar_value;
#line 1278 "MatrixModule.cs"
        int* csharp2cuda_temp_583 = &(iterations);
#line 1278 "MatrixModule.cs"
        bool csharp2cuda_temp_584 = mathblocks_nonnegative_integer(csharp2cuda_temp_582, csharp2cuda_temp_583);
#line 1278 "MatrixModule.cs"
        bool csharp2cuda_temp_585;
#line 1278 "MatrixModule.cs"
        if (!((!(csharp2cuda_temp_584))))
        {
#line 1278 "MatrixModule.cs"
            csharp2cuda_temp_585 = ((iterations) <= (0));
        }
        else
        {
#line 1278 "MatrixModule.cs"
            csharp2cuda_temp_585 = true;
        }
#line 1278 "MatrixModule.cs"
        bool csharp2cuda_temp_586;
#line 1278 "MatrixModule.cs"
        if (!(csharp2cuda_temp_585))
        {
#line 1278 "MatrixModule.cs"
            csharp2cuda_temp_586 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 1278 "MatrixModule.cs"
            csharp2cuda_temp_586 = true;
        }
        if (csharp2cuda_temp_586)
#line 1280 "MatrixModule.cs"
        {
#line 1281 "MatrixModule.cs"
#line 1281 "MatrixModule.cs"
            int* csharp2cuda_temp_587 = &((output)->valid);
            (*(csharp2cuda_temp_587) = 0);
#line 1282 "MatrixModule.cs"
            return;
        }
#line 1284 "MatrixModule.cs"
        int size = (first)->columns;
#line 1285 "MatrixModule.cs"
        double* gram = scratch;
#line 1286 "MatrixModule.cs"
        double* work = csharp2cuda_pointer_add(gram, csharp2cuda_i32_mul(size, size));
#line 1287 "MatrixModule.cs"
        double* eigenvalues = csharp2cuda_pointer_add(work, csharp2cuda_i32_mul(size, size));
#line 1288 "MatrixModule.cs"
        {
#line 1288 "MatrixModule.cs"
            int row = 0;
            while (true)
            {
                if (!(((row) < (size))))
                    break;
#line 1289 "MatrixModule.cs"
                {
#line 1290 "MatrixModule.cs"
                    {
#line 1290 "MatrixModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (size))))
                                break;
#line 1291 "MatrixModule.cs"
                            {
#line 1292 "MatrixModule.cs"
                                double sum = 0.0;
#line 1293 "MatrixModule.cs"
                                {
#line 1293 "MatrixModule.cs"
                                    int inner = 0;
                                    while (true)
                                    {
#line 1293 "MatrixModule.cs"
                                        int csharp2cuda_temp_591 = (first)->rows;
                                        if (!(((inner) < (csharp2cuda_temp_591))))
                                            break;
#line 1294 "MatrixModule.cs"
#line 1294 "MatrixModule.cs"
                                        double* csharp2cuda_temp_592 = &(sum);
#line 1294 "MatrixModule.cs"
                                        double csharp2cuda_temp_593 = *(csharp2cuda_temp_592);
#line 1294 "MatrixModule.cs"
                                        int csharp2cuda_temp_594 = (first)->columns;
#line 1294 "MatrixModule.cs"
                                        double csharp2cuda_temp_595 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_594), row)];
#line 1295 "MatrixModule.cs"
                                        int csharp2cuda_temp_596 = (first)->columns;
#line 1295 "MatrixModule.cs"
                                        double csharp2cuda_temp_597 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, csharp2cuda_temp_596), column)];
                                        (*(csharp2cuda_temp_592) = __dadd_rn(csharp2cuda_temp_593, __dmul_rn(csharp2cuda_temp_595, csharp2cuda_temp_597)));
#line 1293 "MatrixModule.cs"
                                        int* csharp2cuda_temp_590 = &(inner);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_590));
                                    }
                                }
#line 1296 "MatrixModule.cs"
#line 1296 "MatrixModule.cs"
                                double* csharp2cuda_temp_598 = &((gram)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
                                (*(csharp2cuda_temp_598) = sum);
                            }
#line 1290 "MatrixModule.cs"
                            int* csharp2cuda_temp_589 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_589));
                        }
                    }
                }
#line 1288 "MatrixModule.cs"
                int* csharp2cuda_temp_588 = &(row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_588));
            }
        }
#line 1299 "MatrixModule.cs"
        mathblocks_matrix_symmetric_eigenvalues(gram, size, work, eigenvalues);
#line 1300 "MatrixModule.cs"
        double largest = (eigenvalues)[csharp2cuda_i32_sub(size, 1)];
#line 1301 "MatrixModule.cs"
        if (((largest) < (0.0)))
        {
#line 1301 "MatrixModule.cs"
#line 1301 "MatrixModule.cs"
            double* csharp2cuda_temp_599 = &(largest);
            (*(csharp2cuda_temp_599) = 0.0);
        }
#line 1302 "MatrixModule.cs"
#line 1302 "MatrixModule.cs"
        double* csharp2cuda_temp_600 = &((output)->scalar_value);
        (*(csharp2cuda_temp_600) = mathblocks_square_root(largest));
#line 1303 "MatrixModule.cs"
#line 1303 "MatrixModule.cs"
        double csharp2cuda_temp_601 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_601))))
        {
#line 1303 "MatrixModule.cs"
#line 1303 "MatrixModule.cs"
            int* csharp2cuda_temp_602 = &((output)->valid);
            (*(csharp2cuda_temp_602) = 0);
        }
    }
}

#line 241 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_positive_definite(
    const double* values,
    int size,
    double* lower)
#line 246 "MatrixModule.cs"
{
#line 247 "MatrixModule.cs"
#line 247 "MatrixModule.cs"
    bool csharp2cuda_temp_0 = mathblocks_matrix_is_symmetric(values, size, size);
    if ((!(csharp2cuda_temp_0)))
    {
#line 248 "MatrixModule.cs"
        return false;
    }
#line 249 "MatrixModule.cs"
    {
#line 249 "MatrixModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (csharp2cuda_i32_mul(size, size)))))
                break;
#line 250 "MatrixModule.cs"
#line 250 "MatrixModule.cs"
            double* csharp2cuda_temp_2 = &((lower)[index]);
            (*(csharp2cuda_temp_2) = 0.0);
#line 249 "MatrixModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 251 "MatrixModule.cs"
    {
#line 251 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 252 "MatrixModule.cs"
            {
#line 253 "MatrixModule.cs"
                {
#line 253 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) <= (row))))
                            break;
#line 254 "MatrixModule.cs"
                        {
#line 255 "MatrixModule.cs"
                            double sum = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 256 "MatrixModule.cs"
                            {
#line 256 "MatrixModule.cs"
                                int inner = 0;
                                while (true)
                                {
                                    if (!(((inner) < (column))))
                                        break;
#line 257 "MatrixModule.cs"
#line 257 "MatrixModule.cs"
                                    double* csharp2cuda_temp_6 = &(sum);
#line 257 "MatrixModule.cs"
                                    double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
#line 257 "MatrixModule.cs"
                                    double csharp2cuda_temp_8 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), inner)];
#line 257 "MatrixModule.cs"
                                    double csharp2cuda_temp_9 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, size), inner)];
                                    (*(csharp2cuda_temp_6) = __dsub_rn(csharp2cuda_temp_7, __dmul_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 256 "MatrixModule.cs"
                                    int* csharp2cuda_temp_5 = &(inner);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
                                }
                            }
#line 258 "MatrixModule.cs"
                            if (((row) == (column)))
#line 259 "MatrixModule.cs"
                            {
#line 260 "MatrixModule.cs"
                                if (((sum) <= (0.0)))
                                {
#line 261 "MatrixModule.cs"
                                    return false;
                                }
#line 262 "MatrixModule.cs"
#line 262 "MatrixModule.cs"
                                double* csharp2cuda_temp_10 = &((lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
                                (*(csharp2cuda_temp_10) = mathblocks_square_root(sum));
                            }
                            else
#line 265 "MatrixModule.cs"
                            {
#line 266 "MatrixModule.cs"
#line 266 "MatrixModule.cs"
                                double* csharp2cuda_temp_11 = &((lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
#line 266 "MatrixModule.cs"
                                double csharp2cuda_temp_12 = (lower)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, size), column)];
#line 266 "MatrixModule.cs"
                                double csharp2cuda_temp_13 = __ddiv_rn(sum, csharp2cuda_temp_12);
                                (*(csharp2cuda_temp_11) = csharp2cuda_temp_13);
                            }
                        }
#line 253 "MatrixModule.cs"
                        int* csharp2cuda_temp_4 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                    }
                }
            }
#line 251 "MatrixModule.cs"
            int* csharp2cuda_temp_3 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
#line 270 "MatrixModule.cs"
    return true;
}

#line 229 "MatrixModule.cs"
__device__ bool mathblocks_matrix_is_symmetric(const double* values, int rows, int columns)
#line 231 "MatrixModule.cs"
{
#line 232 "MatrixModule.cs"
    if (((rows) != (columns)))
    {
#line 233 "MatrixModule.cs"
        return false;
    }
#line 234 "MatrixModule.cs"
    {
#line 234 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (rows))))
                break;
#line 235 "MatrixModule.cs"
            {
#line 235 "MatrixModule.cs"
                int column = csharp2cuda_i32_add(row, 1);
                while (true)
                {
                    if (!(((column) < (columns))))
                        break;
#line 236 "MatrixModule.cs"
#line 236 "MatrixModule.cs"
                    double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 236 "MatrixModule.cs"
                    double csharp2cuda_temp_3 = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(column, columns), row)];
                    if (((csharp2cuda_temp_2) != (csharp2cuda_temp_3)))
                    {
#line 237 "MatrixModule.cs"
                        return false;
                    }
#line 235 "MatrixModule.cs"
                    int* csharp2cuda_temp_1 = &(column);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 234 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 238 "MatrixModule.cs"
    return true;
}

#line 378 "MatrixModule.cs"
__device__ void mathblocks_matrix_multiply_square(
    const double* left,
    const double* right,
    int size,
    double* destination)
#line 384 "MatrixModule.cs"
{
#line 385 "MatrixModule.cs"
    {
#line 385 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 386 "MatrixModule.cs"
            {
#line 387 "MatrixModule.cs"
                {
#line 387 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (size))))
                            break;
#line 388 "MatrixModule.cs"
                        {
#line 389 "MatrixModule.cs"
                            double sum = 0.0;
#line 390 "MatrixModule.cs"
                            {
#line 390 "MatrixModule.cs"
                                int inner = 0;
                                while (true)
                                {
                                    if (!(((inner) < (size))))
                                        break;
#line 391 "MatrixModule.cs"
#line 391 "MatrixModule.cs"
                                    double* csharp2cuda_temp_3 = &(sum);
#line 391 "MatrixModule.cs"
                                    double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 391 "MatrixModule.cs"
                                    double csharp2cuda_temp_5 = (left)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), inner)];
#line 391 "MatrixModule.cs"
                                    double csharp2cuda_temp_6 = (right)[csharp2cuda_i32_add(csharp2cuda_i32_mul(inner, size), column)];
                                    (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(csharp2cuda_temp_5, csharp2cuda_temp_6)));
#line 390 "MatrixModule.cs"
                                    int* csharp2cuda_temp_2 = &(inner);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                                }
                            }
#line 392 "MatrixModule.cs"
#line 392 "MatrixModule.cs"
                            double* csharp2cuda_temp_7 = &((destination)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)]);
                            (*(csharp2cuda_temp_7) = sum);
                        }
#line 387 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 385 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 344 "MatrixModule.cs"
__device__ int mathblocks_matrix_rank(const double* source, int rows, int columns, double* work)
#line 346 "MatrixModule.cs"
{
#line 347 "MatrixModule.cs"
    mathblocks_matrix_copy(source, work, csharp2cuda_i32_mul(rows, columns));
#line 348 "MatrixModule.cs"
    int rank = 0;
#line 349 "MatrixModule.cs"
    int pivot_column = 0;
#line 350 "MatrixModule.cs"
    while (true)
    {
#line 350 "MatrixModule.cs"
        bool csharp2cuda_temp_0;
#line 350 "MatrixModule.cs"
        if (((rank) < (rows)))
        {
#line 350 "MatrixModule.cs"
            csharp2cuda_temp_0 = ((pivot_column) < (columns));
        }
        else
        {
#line 350 "MatrixModule.cs"
            csharp2cuda_temp_0 = false;
        }
        if (!(csharp2cuda_temp_0))
            break;
#line 351 "MatrixModule.cs"
        {
#line 352 "MatrixModule.cs"
            int pivot_row = rank;
#line 353 "MatrixModule.cs"
            {
#line 353 "MatrixModule.cs"
                int row = csharp2cuda_i32_add(rank, 1);
                while (true)
                {
                    if (!(((row) < (rows))))
                        break;
#line 354 "MatrixModule.cs"
#line 354 "MatrixModule.cs"
                    double csharp2cuda_temp_2 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot_column)];
#line 355 "MatrixModule.cs"
                    double csharp2cuda_temp_3 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot_column)];
                    if (((fabs(csharp2cuda_temp_2)) > (fabs(csharp2cuda_temp_3))))
#line 356 "MatrixModule.cs"
                    {
#line 357 "MatrixModule.cs"
#line 357 "MatrixModule.cs"
                        int* csharp2cuda_temp_4 = &(pivot_row);
                        (*(csharp2cuda_temp_4) = row);
                    }
#line 353 "MatrixModule.cs"
                    int* csharp2cuda_temp_1 = &(row);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 359 "MatrixModule.cs"
#line 359 "MatrixModule.cs"
            double csharp2cuda_temp_5 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot_column)];
            if (((csharp2cuda_temp_5) == (0.0)))
#line 360 "MatrixModule.cs"
            {
#line 361 "MatrixModule.cs"
#line 361 "MatrixModule.cs"
                int* csharp2cuda_temp_6 = &(pivot_column);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
#line 362 "MatrixModule.cs"
                continue;
            }
#line 364 "MatrixModule.cs"
            mathblocks_matrix_swap_rows(work, columns, rank, pivot_row);
#line 365 "MatrixModule.cs"
            double pivot = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(rank, columns), pivot_column)];
#line 366 "MatrixModule.cs"
            {
#line 366 "MatrixModule.cs"
                int row = csharp2cuda_i32_add(rank, 1);
                while (true)
                {
                    if (!(((row) < (rows))))
                        break;
#line 367 "MatrixModule.cs"
                    {
#line 368 "MatrixModule.cs"
                        double csharp2cuda_temp_8 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot_column)];
#line 368 "MatrixModule.cs"
                        double scale = __ddiv_rn(csharp2cuda_temp_8, pivot);
#line 369 "MatrixModule.cs"
                        {
#line 369 "MatrixModule.cs"
                            int column = pivot_column;
                            while (true)
                            {
                                if (!(((column) < (columns))))
                                    break;
#line 370 "MatrixModule.cs"
#line 370 "MatrixModule.cs"
                                double* csharp2cuda_temp_10 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 370 "MatrixModule.cs"
                                double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
#line 370 "MatrixModule.cs"
                                double csharp2cuda_temp_12 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(rank, columns), column)];
                                (*(csharp2cuda_temp_10) = __dsub_rn(csharp2cuda_temp_11, __dmul_rn(scale, csharp2cuda_temp_12)));
#line 369 "MatrixModule.cs"
                                int* csharp2cuda_temp_9 = &(column);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
                            }
                        }
                    }
#line 366 "MatrixModule.cs"
                    int* csharp2cuda_temp_7 = &(row);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                }
            }
#line 372 "MatrixModule.cs"
#line 372 "MatrixModule.cs"
            int* csharp2cuda_temp_13 = &(rank);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 373 "MatrixModule.cs"
#line 373 "MatrixModule.cs"
            int* csharp2cuda_temp_14 = &(pivot_column);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
#line 375 "MatrixModule.cs"
    return rank;
}

#line 53 "MatrixModule.cs"
__device__ void mathblocks_matrix_shape(MathBlockSlot* output, int rows, int columns)
#line 55 "MatrixModule.cs"
{
#line 56 "MatrixModule.cs"
    long long count = csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)));
#line 57 "MatrixModule.cs"
#line 57 "MatrixModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = rows);
#line 58 "MatrixModule.cs"
#line 58 "MatrixModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = columns);
#line 59 "MatrixModule.cs"
#line 59 "MatrixModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
#line 59 "MatrixModule.cs"
    int csharp2cuda_temp_3;
#line 59 "MatrixModule.cs"
    if (((count) > (2147483647LL)))
    {
#line 59 "MatrixModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_neg(1);
    }
    else
    {
#line 59 "MatrixModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_from_bits(count);
    }
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 60 "MatrixModule.cs"
#line 60 "MatrixModule.cs"
    bool csharp2cuda_temp_4;
#line 60 "MatrixModule.cs"
    if (!(((rows) <= (0))))
    {
#line 60 "MatrixModule.cs"
        csharp2cuda_temp_4 = ((columns) <= (0));
    }
    else
    {
#line 60 "MatrixModule.cs"
        csharp2cuda_temp_4 = true;
    }
#line 60 "MatrixModule.cs"
    bool csharp2cuda_temp_5;
#line 60 "MatrixModule.cs"
    if (!(csharp2cuda_temp_4))
    {
#line 60 "MatrixModule.cs"
        int csharp2cuda_temp_6 = (output)->capacity;
#line 60 "MatrixModule.cs"
        csharp2cuda_temp_5 = ((count) > (((long long)(csharp2cuda_temp_6))));
    }
    else
    {
#line 60 "MatrixModule.cs"
        csharp2cuda_temp_5 = true;
    }
    if (csharp2cuda_temp_5)
    {
#line 61 "MatrixModule.cs"
#line 61 "MatrixModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
        (*(csharp2cuda_temp_7) = 0);
    }
}

#line 409 "MatrixModule.cs"
__device__ void mathblocks_matrix_submatrix_from_masks(
    const double* source,
    int source_columns,
    int row_mask,
    int column_mask,
    int order,
    double* destination)
#line 417 "MatrixModule.cs"
{
#line 418 "MatrixModule.cs"
    int output_row = 0;
#line 419 "MatrixModule.cs"
    {
#line 419 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (31))))
                break;
#line 420 "MatrixModule.cs"
            {
#line 421 "MatrixModule.cs"
                if (((csharp2cuda_i32_and(row_mask, csharp2cuda_i32_shl(1, row))) == (0)))
                {
#line 422 "MatrixModule.cs"
                    goto csharp2cuda_for_continue_1;
                }
#line 423 "MatrixModule.cs"
                int output_column = 0;
#line 424 "MatrixModule.cs"
                {
#line 424 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (31))))
                            break;
#line 425 "MatrixModule.cs"
                        {
#line 426 "MatrixModule.cs"
                            if (((csharp2cuda_i32_and(column_mask, csharp2cuda_i32_shl(1, column))) == (0)))
                            {
#line 427 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_0;
                            }
#line 428 "MatrixModule.cs"
#line 428 "MatrixModule.cs"
                            double* csharp2cuda_temp_2 = &((destination)[csharp2cuda_i32_add(csharp2cuda_i32_mul(output_row, order), output_column)]);
#line 429 "MatrixModule.cs"
                            double csharp2cuda_temp_3 = (source)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, source_columns), column)];
                            (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 430 "MatrixModule.cs"
#line 430 "MatrixModule.cs"
                            int* csharp2cuda_temp_4 = &(output_column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                        }
                        csharp2cuda_for_continue_0:
#line 424 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 432 "MatrixModule.cs"
#line 432 "MatrixModule.cs"
                int* csharp2cuda_temp_5 = &(output_row);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
            }
            csharp2cuda_for_continue_1:
#line 419 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 79 "MatrixModule.cs"
__device__ void mathblocks_matrix_swap_rows(
    double* values,
    int columns,
    int left,
    int right)
#line 85 "MatrixModule.cs"
{
#line 86 "MatrixModule.cs"
    if (((left) == (right)))
    {
#line 87 "MatrixModule.cs"
        return;
    }
#line 88 "MatrixModule.cs"
    {
#line 88 "MatrixModule.cs"
        int column = 0;
        while (true)
        {
            if (!(((column) < (columns))))
                break;
#line 89 "MatrixModule.cs"
            {
#line 90 "MatrixModule.cs"
                double temporary = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), column)];
#line 91 "MatrixModule.cs"
#line 91 "MatrixModule.cs"
                double* csharp2cuda_temp_1 = &((values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), column)]);
#line 91 "MatrixModule.cs"
                double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), column)];
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 92 "MatrixModule.cs"
#line 92 "MatrixModule.cs"
                double* csharp2cuda_temp_3 = &((values)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), column)]);
                (*(csharp2cuda_temp_3) = temporary);
            }
#line 88 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(column);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 273 "MatrixModule.cs"
__device__ void mathblocks_matrix_symmetric_eigenvalues(
    const double* source,
    int size,
    double* work,
    double* eigenvalues)
#line 279 "MatrixModule.cs"
{
#line 280 "MatrixModule.cs"
    mathblocks_matrix_copy(source, work, csharp2cuda_i32_mul(size, size));
#line 281 "MatrixModule.cs"
    {
#line 281 "MatrixModule.cs"
        int iteration = 0;
        while (true)
        {
            if (!(((iteration) < (csharp2cuda_i32_mul(csharp2cuda_i32_mul(64, size), size)))))
                break;
#line 282 "MatrixModule.cs"
            {
#line 283 "MatrixModule.cs"
                int pivot_row = 0;
#line 284 "MatrixModule.cs"
                int pivot_column = 0;
#line 285 "MatrixModule.cs"
                double largest = 0.0;
#line 286 "MatrixModule.cs"
                {
#line 286 "MatrixModule.cs"
                    int row = 0;
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 287 "MatrixModule.cs"
                        {
#line 288 "MatrixModule.cs"
                            {
#line 288 "MatrixModule.cs"
                                int column = csharp2cuda_i32_add(row, 1);
                                while (true)
                                {
                                    if (!(((column) < (size))))
                                        break;
#line 289 "MatrixModule.cs"
                                    {
#line 290 "MatrixModule.cs"
                                        double csharp2cuda_temp_3 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
#line 290 "MatrixModule.cs"
                                        double magnitude = fabs(csharp2cuda_temp_3);
#line 291 "MatrixModule.cs"
                                        if (((magnitude) <= (largest)))
                                        {
#line 292 "MatrixModule.cs"
                                            goto csharp2cuda_for_continue_0;
                                        }
#line 293 "MatrixModule.cs"
#line 293 "MatrixModule.cs"
                                        double* csharp2cuda_temp_4 = &(largest);
                                        (*(csharp2cuda_temp_4) = magnitude);
#line 294 "MatrixModule.cs"
#line 294 "MatrixModule.cs"
                                        int* csharp2cuda_temp_5 = &(pivot_row);
                                        (*(csharp2cuda_temp_5) = row);
#line 295 "MatrixModule.cs"
#line 295 "MatrixModule.cs"
                                        int* csharp2cuda_temp_6 = &(pivot_column);
                                        (*(csharp2cuda_temp_6) = column);
                                    }
                                    csharp2cuda_for_continue_0:
#line 288 "MatrixModule.cs"
                                    int* csharp2cuda_temp_2 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                                }
                            }
                        }
#line 286 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 298 "MatrixModule.cs"
                if (((largest) == (0.0)))
                {
#line 299 "MatrixModule.cs"
                    break;
                }
#line 301 "MatrixModule.cs"
                double csharp2cuda_temp_7 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_column)];
#line 302 "MatrixModule.cs"
                double csharp2cuda_temp_8 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_column)];
#line 303 "MatrixModule.cs"
                double csharp2cuda_temp_9 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_row)];
#line 300 "MatrixModule.cs"
                double angle = __dmul_rn(0.5, mathblocks_arc_tangent_2(__dmul_rn(2.0, csharp2cuda_temp_7), __dsub_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 304 "MatrixModule.cs"
                double cosine = mathblocks_cosine(angle);
#line 305 "MatrixModule.cs"
                double sine = mathblocks_sine(angle);
#line 306 "MatrixModule.cs"
                double aa = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_row)];
#line 307 "MatrixModule.cs"
                double bb = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_column)];
#line 308 "MatrixModule.cs"
                double ab = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_column)];
#line 309 "MatrixModule.cs"
#line 309 "MatrixModule.cs"
                double* csharp2cuda_temp_10 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_row)]);
                (*(csharp2cuda_temp_10) = __dadd_rn(__dsub_rn(__dmul_rn(__dmul_rn(cosine, cosine), aa), __dmul_rn(__dmul_rn(__dmul_rn(2.0, sine), cosine), ab)), __dmul_rn(__dmul_rn(sine, sine), bb)));
#line 311 "MatrixModule.cs"
#line 311 "MatrixModule.cs"
                double* csharp2cuda_temp_11 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_column)]);
                (*(csharp2cuda_temp_11) = __dadd_rn(__dadd_rn(__dmul_rn(__dmul_rn(sine, sine), aa), __dmul_rn(__dmul_rn(__dmul_rn(2.0, sine), cosine), ab)), __dmul_rn(__dmul_rn(cosine, cosine), bb)));
#line 313 "MatrixModule.cs"
#line 313 "MatrixModule.cs"
                double* csharp2cuda_temp_12 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), pivot_column)]);
                (*(csharp2cuda_temp_12) = 0.0);
#line 314 "MatrixModule.cs"
#line 314 "MatrixModule.cs"
                double* csharp2cuda_temp_13 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), pivot_row)]);
                (*(csharp2cuda_temp_13) = 0.0);
#line 315 "MatrixModule.cs"
                {
#line 315 "MatrixModule.cs"
                    int other = 0;
                    while (true)
                    {
                        if (!(((other) < (size))))
                            break;
#line 316 "MatrixModule.cs"
                        {
#line 317 "MatrixModule.cs"
#line 317 "MatrixModule.cs"
                            bool csharp2cuda_temp_15;
#line 317 "MatrixModule.cs"
                            if (!(((other) == (pivot_row))))
                            {
#line 317 "MatrixModule.cs"
                                csharp2cuda_temp_15 = ((other) == (pivot_column));
                            }
                            else
                            {
#line 317 "MatrixModule.cs"
                                csharp2cuda_temp_15 = true;
                            }
                            if (csharp2cuda_temp_15)
                            {
#line 318 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_2;
                            }
#line 319 "MatrixModule.cs"
                            double first = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_row)];
#line 320 "MatrixModule.cs"
                            double second = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_column)];
#line 321 "MatrixModule.cs"
                            double first_value = __dsub_rn(__dmul_rn(cosine, first), __dmul_rn(sine, second));
#line 322 "MatrixModule.cs"
                            double second_value = __dadd_rn(__dmul_rn(sine, first), __dmul_rn(cosine, second));
#line 323 "MatrixModule.cs"
#line 323 "MatrixModule.cs"
                            double* csharp2cuda_temp_16 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_row)]);
                            (*(csharp2cuda_temp_16) = first_value);
#line 324 "MatrixModule.cs"
#line 324 "MatrixModule.cs"
                            double* csharp2cuda_temp_17 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, size), other)]);
                            (*(csharp2cuda_temp_17) = first_value);
#line 325 "MatrixModule.cs"
#line 325 "MatrixModule.cs"
                            double* csharp2cuda_temp_18 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(other, size), pivot_column)]);
                            (*(csharp2cuda_temp_18) = second_value);
#line 326 "MatrixModule.cs"
#line 326 "MatrixModule.cs"
                            double* csharp2cuda_temp_19 = &((work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_column, size), other)]);
                            (*(csharp2cuda_temp_19) = second_value);
                        }
                        csharp2cuda_for_continue_2:
#line 315 "MatrixModule.cs"
                        int* csharp2cuda_temp_14 = &(other);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
                    }
                }
            }
#line 281 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 329 "MatrixModule.cs"
    {
#line 329 "MatrixModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (size))))
                break;
#line 330 "MatrixModule.cs"
#line 330 "MatrixModule.cs"
            double* csharp2cuda_temp_21 = &((eigenvalues)[index]);
#line 330 "MatrixModule.cs"
            double csharp2cuda_temp_22 = (work)[csharp2cuda_i32_add(csharp2cuda_i32_mul(index, size), index)];
            (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 329 "MatrixModule.cs"
            int* csharp2cuda_temp_20 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
        }
    }
#line 331 "MatrixModule.cs"
    {
#line 331 "MatrixModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (size))))
                break;
#line 332 "MatrixModule.cs"
            {
#line 333 "MatrixModule.cs"
                double value = (eigenvalues)[index];
#line 334 "MatrixModule.cs"
                int position = index;
#line 335 "MatrixModule.cs"
                while (true)
                {
#line 335 "MatrixModule.cs"
                    bool csharp2cuda_temp_24;
#line 335 "MatrixModule.cs"
                    if (((position) > (0)))
                    {
#line 335 "MatrixModule.cs"
                        double csharp2cuda_temp_25 = (eigenvalues)[csharp2cuda_i32_sub(position, 1)];
#line 335 "MatrixModule.cs"
                        csharp2cuda_temp_24 = ((csharp2cuda_temp_25) > (value));
                    }
                    else
                    {
#line 335 "MatrixModule.cs"
                        csharp2cuda_temp_24 = false;
                    }
                    if (!(csharp2cuda_temp_24))
                        break;
#line 336 "MatrixModule.cs"
                    {
#line 337 "MatrixModule.cs"
#line 337 "MatrixModule.cs"
                        double* csharp2cuda_temp_26 = &((eigenvalues)[position]);
#line 337 "MatrixModule.cs"
                        double csharp2cuda_temp_27 = (eigenvalues)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_26) = csharp2cuda_temp_27);
#line 338 "MatrixModule.cs"
#line 338 "MatrixModule.cs"
                        int* csharp2cuda_temp_28 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_28));
                    }
                }
#line 340 "MatrixModule.cs"
#line 340 "MatrixModule.cs"
                double* csharp2cuda_temp_29 = &((eigenvalues)[position]);
                (*(csharp2cuda_temp_29) = value);
            }
#line 331 "MatrixModule.cs"
            int* csharp2cuda_temp_23 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_23));
        }
    }
}

#line 129 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve(
    const double* matrix,
    const double* right,
    int size,
    double* augmented,
    double* solution)
#line 136 "MatrixModule.cs"
{
#line 137 "MatrixModule.cs"
    int columns = csharp2cuda_i32_add(size, 1);
#line 138 "MatrixModule.cs"
    {
#line 138 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 139 "MatrixModule.cs"
            {
#line 140 "MatrixModule.cs"
                {
#line 140 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (size))))
                            break;
#line 141 "MatrixModule.cs"
#line 141 "MatrixModule.cs"
                        double* csharp2cuda_temp_2 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 141 "MatrixModule.cs"
                        double csharp2cuda_temp_3 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
                        (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 140 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 142 "MatrixModule.cs"
#line 142 "MatrixModule.cs"
                double* csharp2cuda_temp_4 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)]);
#line 142 "MatrixModule.cs"
                double csharp2cuda_temp_5 = (right)[row];
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 138 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 144 "MatrixModule.cs"
    {
#line 144 "MatrixModule.cs"
        int pivot = 0;
        while (true)
        {
            if (!(((pivot) < (size))))
                break;
#line 145 "MatrixModule.cs"
            {
#line 146 "MatrixModule.cs"
                int pivot_row = pivot;
#line 147 "MatrixModule.cs"
                {
#line 147 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 148 "MatrixModule.cs"
#line 148 "MatrixModule.cs"
                        double csharp2cuda_temp_8 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 149 "MatrixModule.cs"
                        double csharp2cuda_temp_9 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                        if (((fabs(csharp2cuda_temp_8)) > (fabs(csharp2cuda_temp_9))))
#line 150 "MatrixModule.cs"
                        {
#line 151 "MatrixModule.cs"
#line 151 "MatrixModule.cs"
                            int* csharp2cuda_temp_10 = &(pivot_row);
                            (*(csharp2cuda_temp_10) = row);
                        }
#line 147 "MatrixModule.cs"
                        int* csharp2cuda_temp_7 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                    }
                }
#line 153 "MatrixModule.cs"
#line 153 "MatrixModule.cs"
                double csharp2cuda_temp_11 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                if (((csharp2cuda_temp_11) == (0.0)))
                {
#line 154 "MatrixModule.cs"
                    return false;
                }
#line 155 "MatrixModule.cs"
                if (((pivot_row) != (pivot)))
                {
#line 156 "MatrixModule.cs"
                    mathblocks_matrix_swap_rows(augmented, columns, pivot, pivot_row);
                }
#line 157 "MatrixModule.cs"
                double diagonal = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), pivot)];
#line 158 "MatrixModule.cs"
                {
#line 158 "MatrixModule.cs"
                    int column = pivot;
                    while (true)
                    {
                        if (!(((column) <= (size))))
                            break;
#line 159 "MatrixModule.cs"
#line 159 "MatrixModule.cs"
                        double* csharp2cuda_temp_13 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)]);
#line 159 "MatrixModule.cs"
                        double csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                        (*(csharp2cuda_temp_13) = __ddiv_rn(csharp2cuda_temp_14, diagonal));
#line 158 "MatrixModule.cs"
                        int* csharp2cuda_temp_12 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
                    }
                }
#line 160 "MatrixModule.cs"
                {
#line 160 "MatrixModule.cs"
                    int row = 0;
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 161 "MatrixModule.cs"
                        {
#line 162 "MatrixModule.cs"
                            if (((row) == (pivot)))
                            {
#line 163 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_5;
                            }
#line 164 "MatrixModule.cs"
                            double scale = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 165 "MatrixModule.cs"
                            {
#line 165 "MatrixModule.cs"
                                int column = pivot;
                                while (true)
                                {
                                    if (!(((column) <= (size))))
                                        break;
#line 166 "MatrixModule.cs"
#line 166 "MatrixModule.cs"
                                    double* csharp2cuda_temp_17 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 166 "MatrixModule.cs"
                                    double csharp2cuda_temp_18 = *(csharp2cuda_temp_17);
#line 167 "MatrixModule.cs"
                                    double csharp2cuda_temp_19 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)];
                                    (*(csharp2cuda_temp_17) = __dsub_rn(csharp2cuda_temp_18, __dmul_rn(scale, csharp2cuda_temp_19)));
#line 165 "MatrixModule.cs"
                                    int* csharp2cuda_temp_16 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                }
                            }
                        }
                        csharp2cuda_for_continue_5:
#line 160 "MatrixModule.cs"
                        int* csharp2cuda_temp_15 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                    }
                }
            }
#line 144 "MatrixModule.cs"
            int* csharp2cuda_temp_6 = &(pivot);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 170 "MatrixModule.cs"
    {
#line 170 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 171 "MatrixModule.cs"
            {
#line 172 "MatrixModule.cs"
#line 172 "MatrixModule.cs"
                double* csharp2cuda_temp_21 = &((solution)[row]);
#line 172 "MatrixModule.cs"
                double csharp2cuda_temp_22 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)];
                (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 173 "MatrixModule.cs"
#line 173 "MatrixModule.cs"
                double csharp2cuda_temp_23 = (solution)[row];
                if ((!(isfinite(csharp2cuda_temp_23))))
                {
#line 174 "MatrixModule.cs"
                    return false;
                }
            }
#line 170 "MatrixModule.cs"
            int* csharp2cuda_temp_20 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
        }
    }
#line 176 "MatrixModule.cs"
    return true;
}

#line 179 "MatrixModule.cs"
__device__ bool mathblocks_matrix_try_solve_basis(
    const double* matrix,
    int size,
    int basis,
    double* augmented,
    double* solution)
#line 186 "MatrixModule.cs"
{
#line 187 "MatrixModule.cs"
    int columns = csharp2cuda_i32_add(size, 1);
#line 188 "MatrixModule.cs"
    {
#line 188 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 189 "MatrixModule.cs"
            {
#line 190 "MatrixModule.cs"
                {
#line 190 "MatrixModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (size))))
                            break;
#line 191 "MatrixModule.cs"
#line 191 "MatrixModule.cs"
                        double* csharp2cuda_temp_2 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 191 "MatrixModule.cs"
                        double csharp2cuda_temp_3 = (matrix)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, size), column)];
                        (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 190 "MatrixModule.cs"
                        int* csharp2cuda_temp_1 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 192 "MatrixModule.cs"
#line 192 "MatrixModule.cs"
                double* csharp2cuda_temp_4 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)]);
#line 192 "MatrixModule.cs"
                double csharp2cuda_temp_5;
#line 192 "MatrixModule.cs"
                if (((row) == (basis)))
                {
#line 192 "MatrixModule.cs"
                    csharp2cuda_temp_5 = 1.0;
                }
                else
                {
#line 192 "MatrixModule.cs"
                    csharp2cuda_temp_5 = 0.0;
                }
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 188 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 194 "MatrixModule.cs"
    {
#line 194 "MatrixModule.cs"
        int pivot = 0;
        while (true)
        {
            if (!(((pivot) < (size))))
                break;
#line 195 "MatrixModule.cs"
            {
#line 196 "MatrixModule.cs"
                int pivot_row = pivot;
#line 197 "MatrixModule.cs"
                {
#line 197 "MatrixModule.cs"
                    int row = csharp2cuda_i32_add(pivot, 1);
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 198 "MatrixModule.cs"
#line 198 "MatrixModule.cs"
                        double csharp2cuda_temp_8 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 199 "MatrixModule.cs"
                        double csharp2cuda_temp_9 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                        if (((fabs(csharp2cuda_temp_8)) > (fabs(csharp2cuda_temp_9))))
#line 200 "MatrixModule.cs"
                        {
#line 201 "MatrixModule.cs"
#line 201 "MatrixModule.cs"
                            int* csharp2cuda_temp_10 = &(pivot_row);
                            (*(csharp2cuda_temp_10) = row);
                        }
#line 197 "MatrixModule.cs"
                        int* csharp2cuda_temp_7 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                    }
                }
#line 203 "MatrixModule.cs"
#line 203 "MatrixModule.cs"
                double csharp2cuda_temp_11 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot_row, columns), pivot)];
                if (((csharp2cuda_temp_11) == (0.0)))
                {
#line 204 "MatrixModule.cs"
                    return false;
                }
#line 205 "MatrixModule.cs"
                if (((pivot_row) != (pivot)))
                {
#line 206 "MatrixModule.cs"
                    mathblocks_matrix_swap_rows(augmented, columns, pivot, pivot_row);
                }
#line 207 "MatrixModule.cs"
                double diagonal = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), pivot)];
#line 208 "MatrixModule.cs"
                {
#line 208 "MatrixModule.cs"
                    int column = pivot;
                    while (true)
                    {
                        if (!(((column) <= (size))))
                            break;
#line 209 "MatrixModule.cs"
#line 209 "MatrixModule.cs"
                        double* csharp2cuda_temp_13 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)]);
#line 209 "MatrixModule.cs"
                        double csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                        (*(csharp2cuda_temp_13) = __ddiv_rn(csharp2cuda_temp_14, diagonal));
#line 208 "MatrixModule.cs"
                        int* csharp2cuda_temp_12 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_12));
                    }
                }
#line 210 "MatrixModule.cs"
                {
#line 210 "MatrixModule.cs"
                    int row = 0;
                    while (true)
                    {
                        if (!(((row) < (size))))
                            break;
#line 211 "MatrixModule.cs"
                        {
#line 212 "MatrixModule.cs"
                            if (((row) == (pivot)))
                            {
#line 213 "MatrixModule.cs"
                                goto csharp2cuda_for_continue_5;
                            }
#line 214 "MatrixModule.cs"
                            double scale = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), pivot)];
#line 215 "MatrixModule.cs"
                            {
#line 215 "MatrixModule.cs"
                                int column = pivot;
                                while (true)
                                {
                                    if (!(((column) <= (size))))
                                        break;
#line 216 "MatrixModule.cs"
#line 216 "MatrixModule.cs"
                                    double* csharp2cuda_temp_17 = &((augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)]);
#line 216 "MatrixModule.cs"
                                    double csharp2cuda_temp_18 = *(csharp2cuda_temp_17);
#line 217 "MatrixModule.cs"
                                    double csharp2cuda_temp_19 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(pivot, columns), column)];
                                    (*(csharp2cuda_temp_17) = __dsub_rn(csharp2cuda_temp_18, __dmul_rn(scale, csharp2cuda_temp_19)));
#line 215 "MatrixModule.cs"
                                    int* csharp2cuda_temp_16 = &(column);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                }
                            }
                        }
                        csharp2cuda_for_continue_5:
#line 210 "MatrixModule.cs"
                        int* csharp2cuda_temp_15 = &(row);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                    }
                }
            }
#line 194 "MatrixModule.cs"
            int* csharp2cuda_temp_6 = &(pivot);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_6));
        }
    }
#line 220 "MatrixModule.cs"
    {
#line 220 "MatrixModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (size))))
                break;
#line 221 "MatrixModule.cs"
            {
#line 222 "MatrixModule.cs"
#line 222 "MatrixModule.cs"
                double* csharp2cuda_temp_21 = &((solution)[row]);
#line 222 "MatrixModule.cs"
                double csharp2cuda_temp_22 = (augmented)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), size)];
                (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 223 "MatrixModule.cs"
#line 223 "MatrixModule.cs"
                double csharp2cuda_temp_23 = (solution)[row];
                if ((!(isfinite(csharp2cuda_temp_23))))
                {
#line 224 "MatrixModule.cs"
                    return false;
                }
            }
#line 220 "MatrixModule.cs"
            int* csharp2cuda_temp_20 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_20));
        }
    }
#line 226 "MatrixModule.cs"
    return true;
}

#line 397 "MatrixModule.cs"
__device__ int mathblocks_pop_count(int value)
#line 399 "MatrixModule.cs"
{
#line 400 "MatrixModule.cs"
    int count = 0;
#line 401 "MatrixModule.cs"
    while (true)
    {
        if (!(((value) != (0))))
            break;
#line 402 "MatrixModule.cs"
        {
#line 403 "MatrixModule.cs"
#line 403 "MatrixModule.cs"
            int* csharp2cuda_temp_0 = &(count);
#line 403 "MatrixModule.cs"
            int csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
            (*(csharp2cuda_temp_0) = csharp2cuda_i32_add(csharp2cuda_temp_1, csharp2cuda_i32_and(value, 1)));
#line 404 "MatrixModule.cs"
#line 404 "MatrixModule.cs"
            int* csharp2cuda_temp_2 = &(value);
#line 404 "MatrixModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_shr(csharp2cuda_temp_3, 1));
        }
    }
#line 406 "MatrixModule.cs"
    return count;
}