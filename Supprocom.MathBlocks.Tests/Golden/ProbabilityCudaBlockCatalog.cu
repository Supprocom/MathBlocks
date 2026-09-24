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

#ifndef CSHARP2CUDA_ARRAY_VIEWS_0_3
#define CSHARP2CUDA_ARRAY_VIEWS_0_3
template <typename T>
struct csharp2cuda_readonly_array_view
{
    const T* data;
    int length;
    bool is_null;

    __device__ csharp2cuda_readonly_array_view()
        : data(nullptr), length(0), is_null(false)
    {
    }

    __device__ csharp2cuda_readonly_array_view(const T* address, int count)
        : data(address), length(count), is_null(false)
    {
        if (count < 0 || (address == nullptr && count != 0))
            asm volatile("trap;");
    }

    __device__ csharp2cuda_readonly_array_view(
        const T* address,
        int count,
        bool null_state)
        : data(address), length(count), is_null(null_state)
    {
        if (count < 0) asm volatile("trap;");
    }

    __device__ int get_length() const
    {
        if (is_null) asm volatile("trap;");
        return length;
    }

    __device__ bool is_empty() const
    {
        return get_length() == 0;
    }

    __device__ const T& operator[](int index) const
    {
        if (is_null || (unsigned int)index >= (unsigned int)length)
            asm volatile("trap;");
        return data[index];
    }

    __device__ csharp2cuda_readonly_array_view<T> slice(int start) const
    {
        if (is_null || (unsigned int)start > (unsigned int)length)
            asm volatile("trap;");
        return csharp2cuda_readonly_array_view<T>(
            data == nullptr ? nullptr : data + start,
            length - start);
    }

    __device__ csharp2cuda_readonly_array_view<T> slice(int start, int count) const
    {
        if (is_null ||
            (unsigned int)start > (unsigned int)length ||
            (unsigned int)count > (unsigned int)(length - start))
            asm volatile("trap;");
        return csharp2cuda_readonly_array_view<T>(
            data == nullptr ? nullptr : data + start,
            count);
    }

    template <typename TDestination>
    __device__ void copy_to(TDestination destination) const
    {
        if (!try_copy_to(destination)) asm volatile("trap;");
    }

    template <typename TDestination>
    __device__ bool try_copy_to(TDestination destination) const
    {
        if (is_null || destination.is_null) asm volatile("trap;");
        if (destination.length < length)
            return false;
        unsigned long long source_address = (unsigned long long)data;
        unsigned long long destination_address =
            (unsigned long long)destination.data;
        unsigned long long byte_length =
            (unsigned long long)length * (unsigned long long)sizeof(T);
        if (destination_address > source_address &&
            destination_address < source_address + byte_length)
        {
            for (int index = length; index-- > 0;)
                destination.data[index] = data[index];
        }
        else
        {
            for (int index = 0; index < length; index++)
                destination.data[index] = data[index];
        }
        return true;
    }
};

template <typename T>
struct csharp2cuda_array_view
{
    T* data;
    int length;
    bool is_null;

    __device__ csharp2cuda_array_view()
        : data(nullptr), length(0), is_null(false)
    {
    }

    __device__ csharp2cuda_array_view(T* address, int count)
        : data(address), length(count), is_null(false)
    {
        if (count < 0 || (address == nullptr && count != 0))
            asm volatile("trap;");
    }

    __device__ csharp2cuda_array_view(T* address, int count, bool null_state)
        : data(address), length(count), is_null(null_state)
    {
        if (count < 0) asm volatile("trap;");
    }

    __device__ int get_length() const
    {
        if (is_null) asm volatile("trap;");
        return length;
    }

    __device__ bool is_empty() const
    {
        return get_length() == 0;
    }

    __device__ T& operator[](int index) const
    {
        if (is_null || (unsigned int)index >= (unsigned int)length)
            asm volatile("trap;");
        return data[index];
    }

    __device__ csharp2cuda_array_view<T> slice(int start) const
    {
        if (is_null || (unsigned int)start > (unsigned int)length)
            asm volatile("trap;");
        return csharp2cuda_array_view<T>(
            data == nullptr ? nullptr : data + start,
            length - start);
    }

    __device__ csharp2cuda_array_view<T> slice(int start, int count) const
    {
        if (is_null ||
            (unsigned int)start > (unsigned int)length ||
            (unsigned int)count > (unsigned int)(length - start))
            asm volatile("trap;");
        return csharp2cuda_array_view<T>(
            data == nullptr ? nullptr : data + start,
            count);
    }

    __device__ csharp2cuda_array_view<T> as_span() const
    {
        return is_null
            ? csharp2cuda_array_view<T>(nullptr, 0, false)
            : csharp2cuda_array_view<T>(data, length, false);
    }

    __device__ void clear() const
    {
        if (is_null) asm volatile("trap;");
        for (int index = 0; index < length; index++)
            data[index] = T{};
    }

    __device__ void fill(T value) const
    {
        if (is_null) asm volatile("trap;");
        for (int index = 0; index < length; index++)
            data[index] = value;
    }

    __device__ void copy_to(csharp2cuda_array_view<T> destination) const
    {
        if (!try_copy_to(destination)) asm volatile("trap;");
    }

    __device__ bool try_copy_to(csharp2cuda_array_view<T> destination) const
    {
        if (is_null || destination.is_null) asm volatile("trap;");
        if (destination.length < length)
            return false;
        unsigned long long source_address = (unsigned long long)data;
        unsigned long long destination_address =
            (unsigned long long)destination.data;
        unsigned long long byte_length =
            (unsigned long long)length * (unsigned long long)sizeof(T);
        if (destination_address > source_address &&
            destination_address < source_address + byte_length)
        {
            for (int index = length; index-- > 0;)
                destination.data[index] = data[index];
        }
        else
        {
            for (int index = 0; index < length; index++)
                destination.data[index] = data[index];
        }
        return true;
    }

    __device__ operator csharp2cuda_readonly_array_view<T>() const
    {
        return csharp2cuda_readonly_array_view<T>(data, length, is_null);
    }
};

template <typename TSourceView, typename T>
static __device__ __forceinline__ csharp2cuda_array_view<T>
csharp2cuda_copy_array(
    TSourceView source,
    T* destination,
    int capacity)
{
    if (source.is_null || source.length < 0 || source.length > capacity)
        asm volatile("trap;");
    for (int index = 0; index < source.length; index++)
        destination[index] = source.data[index];
    return csharp2cuda_array_view<T>(destination, source.length, false);
}
#endif

#line 195 "ProbabilityModule.cs"
__device__ double mathblocks_probability_beta_fraction(double x, double left, double right);

#line 110 "ProbabilityModule.cs"
__device__ double mathblocks_probability_binomial(int n, int k);

#line 254 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value);

#line 265 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 123 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const double* values, int count);

#line 133 "ProbabilityModule.cs"
__device__ double mathblocks_probability_entropy(const double* values, int count);

#line 235 "ProbabilityModule.cs"
__device__ double mathblocks_probability_incomplete_beta(
    double x,
    double left,
    double right);

#line 101 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_integer(double value, int* result);

#line 143 "ProbabilityModule.cs"
__device__ double mathblocks_probability_kl(
    const double* probabilities,
    const double* reference,
    int count);

#line 182 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma(double value);

#line 157 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma_core(double value);

#line 195 "ProbabilityModule.cs"
__device__ double mathblocks_probability_beta_fraction(double x, double left, double right)
#line 197 "ProbabilityModule.cs"
{
#line 198 "ProbabilityModule.cs"
    const int maximum_iterations = 256;
#line 199 "ProbabilityModule.cs"
    const double tolerance = 3E-14;
#line 200 "ProbabilityModule.cs"
    const double minimum = 1E-300;
#line 201 "ProbabilityModule.cs"
    double qab = __dadd_rn(left, right);
#line 202 "ProbabilityModule.cs"
    double qap = __dadd_rn(left, 1.0);
#line 203 "ProbabilityModule.cs"
    double qam = __dsub_rn(left, 1.0);
#line 204 "ProbabilityModule.cs"
    double c = 1.0;
#line 205 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = __ddiv_rn(__dmul_rn(qab, x), qap);
#line 205 "ProbabilityModule.cs"
    double d = __dsub_rn(1.0, csharp2cuda_temp_0);
#line 206 "ProbabilityModule.cs"
    if (((fabs(d)) < (minimum)))
    {
#line 206 "ProbabilityModule.cs"
#line 206 "ProbabilityModule.cs"
        double* csharp2cuda_temp_1 = &(d);
        (*(csharp2cuda_temp_1) = minimum);
    }
#line 207 "ProbabilityModule.cs"
#line 207 "ProbabilityModule.cs"
    double* csharp2cuda_temp_2 = &(d);
#line 207 "ProbabilityModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(1.0, d);
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 208 "ProbabilityModule.cs"
    double result = d;
#line 209 "ProbabilityModule.cs"
    {
#line 209 "ProbabilityModule.cs"
        int iteration = 1;
        while (true)
        {
            if (!(((iteration) <= (maximum_iterations))))
                break;
#line 210 "ProbabilityModule.cs"
            {
#line 211 "ProbabilityModule.cs"
                double doubled = __dmul_rn(2.0, ((double)(iteration)));
#line 212 "ProbabilityModule.cs"
                double coefficient = __ddiv_rn(__dmul_rn(__dmul_rn(((double)(iteration)), __dsub_rn(right, ((double)(iteration)))), x), __dmul_rn(__dadd_rn(qam, doubled), __dadd_rn(left, doubled)));
#line 214 "ProbabilityModule.cs"
#line 214 "ProbabilityModule.cs"
                double* csharp2cuda_temp_5 = &(d);
                (*(csharp2cuda_temp_5) = __dadd_rn(1.0, __dmul_rn(coefficient, d)));
#line 215 "ProbabilityModule.cs"
                if (((fabs(d)) < (minimum)))
                {
#line 215 "ProbabilityModule.cs"
#line 215 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_6 = &(d);
                    (*(csharp2cuda_temp_6) = minimum);
                }
#line 216 "ProbabilityModule.cs"
#line 216 "ProbabilityModule.cs"
                double* csharp2cuda_temp_7 = &(c);
#line 216 "ProbabilityModule.cs"
                double csharp2cuda_temp_8 = __ddiv_rn(coefficient, c);
                (*(csharp2cuda_temp_7) = __dadd_rn(1.0, csharp2cuda_temp_8));
#line 217 "ProbabilityModule.cs"
                if (((fabs(c)) < (minimum)))
                {
#line 217 "ProbabilityModule.cs"
#line 217 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_9 = &(c);
                    (*(csharp2cuda_temp_9) = minimum);
                }
#line 218 "ProbabilityModule.cs"
#line 218 "ProbabilityModule.cs"
                double* csharp2cuda_temp_10 = &(d);
#line 218 "ProbabilityModule.cs"
                double csharp2cuda_temp_11 = __ddiv_rn(1.0, d);
                (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
#line 219 "ProbabilityModule.cs"
#line 219 "ProbabilityModule.cs"
                double* csharp2cuda_temp_12 = &(result);
#line 219 "ProbabilityModule.cs"
                double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                (*(csharp2cuda_temp_12) = __dmul_rn(csharp2cuda_temp_13, __dmul_rn(d, c)));
#line 220 "ProbabilityModule.cs"
#line 220 "ProbabilityModule.cs"
                double* csharp2cuda_temp_14 = &(coefficient);
#line 220 "ProbabilityModule.cs"
                double csharp2cuda_temp_15 = __ddiv_rn(__dmul_rn(__dmul_rn((-(__dadd_rn(left, ((double)(iteration))))), __dadd_rn(qab, ((double)(iteration)))), x), __dmul_rn(__dadd_rn(left, doubled), __dadd_rn(qap, doubled)));
                (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
#line 222 "ProbabilityModule.cs"
#line 222 "ProbabilityModule.cs"
                double* csharp2cuda_temp_16 = &(d);
                (*(csharp2cuda_temp_16) = __dadd_rn(1.0, __dmul_rn(coefficient, d)));
#line 223 "ProbabilityModule.cs"
                if (((fabs(d)) < (minimum)))
                {
#line 223 "ProbabilityModule.cs"
#line 223 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_17 = &(d);
                    (*(csharp2cuda_temp_17) = minimum);
                }
#line 224 "ProbabilityModule.cs"
#line 224 "ProbabilityModule.cs"
                double* csharp2cuda_temp_18 = &(c);
#line 224 "ProbabilityModule.cs"
                double csharp2cuda_temp_19 = __ddiv_rn(coefficient, c);
                (*(csharp2cuda_temp_18) = __dadd_rn(1.0, csharp2cuda_temp_19));
#line 225 "ProbabilityModule.cs"
                if (((fabs(c)) < (minimum)))
                {
#line 225 "ProbabilityModule.cs"
#line 225 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_20 = &(c);
                    (*(csharp2cuda_temp_20) = minimum);
                }
#line 226 "ProbabilityModule.cs"
#line 226 "ProbabilityModule.cs"
                double* csharp2cuda_temp_21 = &(d);
#line 226 "ProbabilityModule.cs"
                double csharp2cuda_temp_22 = __ddiv_rn(1.0, d);
                (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 227 "ProbabilityModule.cs"
                double delta = __dmul_rn(d, c);
#line 228 "ProbabilityModule.cs"
#line 228 "ProbabilityModule.cs"
                double* csharp2cuda_temp_23 = &(result);
#line 228 "ProbabilityModule.cs"
                double csharp2cuda_temp_24 = *(csharp2cuda_temp_23);
                (*(csharp2cuda_temp_23) = __dmul_rn(csharp2cuda_temp_24, delta));
#line 229 "ProbabilityModule.cs"
                if (((fabs(__dsub_rn(delta, 1.0))) <= (tolerance)))
                {
#line 230 "ProbabilityModule.cs"
                    break;
                }
            }
#line 209 "ProbabilityModule.cs"
            int* csharp2cuda_temp_4 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 232 "ProbabilityModule.cs"
    return result;
}

#line 110 "ProbabilityModule.cs"
__device__ double mathblocks_probability_binomial(int n, int k)
#line 112 "ProbabilityModule.cs"
{
#line 113 "ProbabilityModule.cs"
#line 113 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 113 "ProbabilityModule.cs"
    if (!(((k) < (0))))
    {
#line 113 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((k) > (n));
    }
    else
    {
#line 113 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 114 "ProbabilityModule.cs"
        return 0.0;
    }
#line 115 "ProbabilityModule.cs"
    if (((k) > (csharp2cuda_i32_sub(n, k))))
    {
#line 116 "ProbabilityModule.cs"
#line 116 "ProbabilityModule.cs"
        int* csharp2cuda_temp_1 = &(k);
        (*(csharp2cuda_temp_1) = csharp2cuda_i32_sub(n, k));
    }
#line 117 "ProbabilityModule.cs"
    double result = 1.0;
#line 118 "ProbabilityModule.cs"
    {
#line 118 "ProbabilityModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) <= (k))))
                break;
#line 119 "ProbabilityModule.cs"
#line 119 "ProbabilityModule.cs"
            double* csharp2cuda_temp_3 = &(result);
#line 119 "ProbabilityModule.cs"
            double csharp2cuda_temp_4 = __ddiv_rn(__dmul_rn(result, ((double)(csharp2cuda_i32_add(csharp2cuda_i32_sub(n, k), index)))), ((double)(index)));
            (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 118 "ProbabilityModule.cs"
            int* csharp2cuda_temp_2 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
        }
    }
#line 120 "ProbabilityModule.cs"
    return result;
}

#line 254 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value)
#line 257 "ProbabilityModule.cs"
{
#line 258 "ProbabilityModule.cs"
#line 258 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 258 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 258 "ProbabilityModule.cs"
    if (((csharp2cuda_temp_0) == (0.0)))
    {
#line 258 "ProbabilityModule.cs"
        double csharp2cuda_temp_2 = (value).imaginary;
#line 258 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) == (0.0));
    }
    else
    {
#line 258 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 259 "ProbabilityModule.cs"
        return mathblocks_complex_make(0.0, 0.0);
    }
#line 260 "ProbabilityModule.cs"
#line 262 "ProbabilityModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(mathblocks_complex_phase(value), 3.0);
    return mathblocks_complex_from_polar(mathblocks_cube_root(mathblocks_complex_magnitude(value)), csharp2cuda_temp_3);
}

#line 265 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 271 "ProbabilityModule.cs"
{
#line 272 "ProbabilityModule.cs"
    int thread = threadIdx.x;
#line 273 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 273 "ProbabilityModule.cs"
    if (((input_count) > (0)))
    {
#line 273 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 273 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 273 "ProbabilityModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 274 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 274 "ProbabilityModule.cs"
    if (((input_count) > (1)))
    {
#line 274 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 274 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 274 "ProbabilityModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 275 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 275 "ProbabilityModule.cs"
    if (((input_count) > (2)))
    {
#line 275 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 275 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 275 "ProbabilityModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 276 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 276 "ProbabilityModule.cs"
    if (((input_count) > (3)))
    {
#line 276 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 276 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 276 "ProbabilityModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 277 "ProbabilityModule.cs"
    if (((thread) == (0)))
#line 278 "ProbabilityModule.cs"
    {
#line 279 "ProbabilityModule.cs"
#line 279 "ProbabilityModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 280 "ProbabilityModule.cs"
#line 280 "ProbabilityModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 281 "ProbabilityModule.cs"
#line 281 "ProbabilityModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 282 "ProbabilityModule.cs"
#line 282 "ProbabilityModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 283 "ProbabilityModule.cs"
#line 283 "ProbabilityModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 284 "ProbabilityModule.cs"
#line 284 "ProbabilityModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 285 "ProbabilityModule.cs"
        {
#line 285 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 286 "ProbabilityModule.cs"
#line 286 "ProbabilityModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 286 "ProbabilityModule.cs"
                bool csharp2cuda_temp_12;
#line 286 "ProbabilityModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 286 "ProbabilityModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 286 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 286 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 286 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 286 "ProbabilityModule.cs"
#line 286 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 285 "ProbabilityModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 288 "ProbabilityModule.cs"
    __syncthreads();
#line 289 "ProbabilityModule.cs"
#line 289 "ProbabilityModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 290 "ProbabilityModule.cs"
        return;
    }
#line 292 "ProbabilityModule.cs"
    double* csharp2cuda_temp_17;
#line 292 "ProbabilityModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 292 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 292 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 292 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 292 "ProbabilityModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 293 "ProbabilityModule.cs"
    double* csharp2cuda_temp_19;
#line 293 "ProbabilityModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 293 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 293 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 293 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 293 "ProbabilityModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 294 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_21 = (output)->data_pointer;
#line 294 "ProbabilityModule.cs"
    double* result = ((double*)(csharp2cuda_temp_21));
#line 295 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_22 = (output)->scratch_pointer;
#line 295 "ProbabilityModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_22));
#line 297 "ProbabilityModule.cs"
    if (((opcode) == (3)))
#line 298 "ProbabilityModule.cs"
    {
#line 299 "ProbabilityModule.cs"
        if (((thread) == (0)))
#line 300 "ProbabilityModule.cs"
        {
#line 301 "ProbabilityModule.cs"
#line 301 "ProbabilityModule.cs"
            int csharp2cuda_temp_23 = (first)->count;
            if (((csharp2cuda_temp_23) > (20)))
#line 302 "ProbabilityModule.cs"
            {
#line 303 "ProbabilityModule.cs"
#line 303 "ProbabilityModule.cs"
                int* csharp2cuda_temp_24 = &((output)->valid);
                (*(csharp2cuda_temp_24) = 0);
#line 304 "ProbabilityModule.cs"
                return;
            }
#line 306 "ProbabilityModule.cs"
#line 306 "ProbabilityModule.cs"
            int csharp2cuda_temp_25 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_i32_shl(1, csharp2cuda_temp_25), 1));
        }
#line 308 "ProbabilityModule.cs"
        __syncthreads();
#line 309 "ProbabilityModule.cs"
        {
#line 309 "ProbabilityModule.cs"
            int mask = csharp2cuda_i32_add(thread, 1);
            while (true)
            {
#line 309 "ProbabilityModule.cs"
                bool csharp2cuda_temp_28 = (output)->valid;
#line 309 "ProbabilityModule.cs"
                bool csharp2cuda_temp_29;
#line 309 "ProbabilityModule.cs"
                if (csharp2cuda_temp_28)
                {
#line 309 "ProbabilityModule.cs"
                    int csharp2cuda_temp_30 = (output)->count;
#line 309 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = ((mask) <= (csharp2cuda_temp_30));
                }
                else
                {
#line 309 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = false;
                }
                if (!(csharp2cuda_temp_29))
                    break;
#line 310 "ProbabilityModule.cs"
                {
#line 311 "ProbabilityModule.cs"
                    double sum = 0.0;
#line 312 "ProbabilityModule.cs"
                    {
#line 312 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 312 "ProbabilityModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 313 "ProbabilityModule.cs"
                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, index))) != (0)))
                            {
#line 313 "ProbabilityModule.cs"
#line 313 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_33 = &(sum);
#line 313 "ProbabilityModule.cs"
                                double csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
#line 313 "ProbabilityModule.cs"
                                double csharp2cuda_temp_35 = (a)[index];
                                (*(csharp2cuda_temp_33) = __dadd_rn(csharp2cuda_temp_34, csharp2cuda_temp_35));
                            }
#line 312 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 314 "ProbabilityModule.cs"
#line 314 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_36 = &((result)[csharp2cuda_i32_sub(mask, 1)]);
                    (*(csharp2cuda_temp_36) = sum);
                }
#line 309 "ProbabilityModule.cs"
                int* csharp2cuda_temp_26 = &(mask);
#line 309 "ProbabilityModule.cs"
                int csharp2cuda_temp_27 = *(csharp2cuda_temp_26);
                (*(csharp2cuda_temp_26) = csharp2cuda_i32_add(csharp2cuda_temp_27, blockDim.x));
            }
        }
#line 316 "ProbabilityModule.cs"
        return;
    }
#line 319 "ProbabilityModule.cs"
    if (((opcode) == (19)))
#line 320 "ProbabilityModule.cs"
    {
#line 321 "ProbabilityModule.cs"
        int csharp2cuda_temp_37 = (first)->count;
#line 321 "ProbabilityModule.cs"
        int csharp2cuda_temp_38;
#line 321 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_37) <= (1)))
        {
#line 321 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = 1;
        }
        else
        {
#line 321 "ProbabilityModule.cs"
            int csharp2cuda_temp_39 = (first)->count;
#line 321 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = csharp2cuda_i32_sub(csharp2cuda_temp_39, 1);
        }
#line 321 "ProbabilityModule.cs"
        int count = csharp2cuda_temp_38;
#line 322 "ProbabilityModule.cs"
        if (((thread) == (0)))
        {
#line 322 "ProbabilityModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 323 "ProbabilityModule.cs"
        __syncthreads();
#line 324 "ProbabilityModule.cs"
#line 324 "ProbabilityModule.cs"
        int csharp2cuda_temp_40 = (first)->count;
        if (((csharp2cuda_temp_40) <= (1)))
#line 325 "ProbabilityModule.cs"
        {
#line 326 "ProbabilityModule.cs"
            if (((thread) == (0)))
            {
#line 326 "ProbabilityModule.cs"
#line 326 "ProbabilityModule.cs"
                double* csharp2cuda_temp_41 = &((result)[0]);
                (*(csharp2cuda_temp_41) = 0.0);
            }
        }
        else
#line 329 "ProbabilityModule.cs"
        {
#line 330 "ProbabilityModule.cs"
            {
#line 330 "ProbabilityModule.cs"
                int index = csharp2cuda_i32_add(thread, 1);
                while (true)
                {
#line 330 "ProbabilityModule.cs"
                    int csharp2cuda_temp_44 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_44))))
                        break;
#line 331 "ProbabilityModule.cs"
#line 331 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_45 = &((result)[csharp2cuda_i32_sub(index, 1)]);
#line 331 "ProbabilityModule.cs"
                    double csharp2cuda_temp_46 = (a)[index];
                    (*(csharp2cuda_temp_45) = __dmul_rn(((double)(index)), csharp2cuda_temp_46));
#line 330 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_42 = &(index);
#line 330 "ProbabilityModule.cs"
                    int csharp2cuda_temp_43 = *(csharp2cuda_temp_42);
                    (*(csharp2cuda_temp_42) = csharp2cuda_i32_add(csharp2cuda_temp_43, blockDim.x));
                }
            }
        }
#line 333 "ProbabilityModule.cs"
        return;
    }
#line 336 "ProbabilityModule.cs"
#line 336 "ProbabilityModule.cs"
    bool csharp2cuda_temp_47;
#line 336 "ProbabilityModule.cs"
    if (!(((opcode) == (24))))
    {
#line 336 "ProbabilityModule.cs"
        csharp2cuda_temp_47 = ((opcode) == (27));
    }
    else
    {
#line 336 "ProbabilityModule.cs"
        csharp2cuda_temp_47 = true;
    }
    if (csharp2cuda_temp_47)
#line 337 "ProbabilityModule.cs"
    {
#line 338 "ProbabilityModule.cs"
        if (((thread) == (0)))
#line 339 "ProbabilityModule.cs"
        {
#line 340 "ProbabilityModule.cs"
#line 340 "ProbabilityModule.cs"
            int csharp2cuda_temp_48 = (first)->count;
            if (((csharp2cuda_temp_48) <= (0)))
#line 341 "ProbabilityModule.cs"
            {
#line 342 "ProbabilityModule.cs"
#line 342 "ProbabilityModule.cs"
                int* csharp2cuda_temp_49 = &((output)->valid);
                (*(csharp2cuda_temp_49) = 0);
#line 343 "ProbabilityModule.cs"
                return;
            }
#line 345 "ProbabilityModule.cs"
            {
#line 345 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 345 "ProbabilityModule.cs"
                    int csharp2cuda_temp_51 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_51))))
                        break;
#line 346 "ProbabilityModule.cs"
#line 346 "ProbabilityModule.cs"
                    double csharp2cuda_temp_52 = (a)[index];
                    if (((csharp2cuda_temp_52) < (0.0)))
                    {
#line 346 "ProbabilityModule.cs"
#line 346 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_53 = &((output)->valid);
                        (*(csharp2cuda_temp_53) = 0);
                    }
#line 345 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_50 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_50));
                }
            }
#line 347 "ProbabilityModule.cs"
#line 347 "ProbabilityModule.cs"
            int csharp2cuda_temp_54 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_54);
#line 348 "ProbabilityModule.cs"
            if (((opcode) == (24)))
#line 349 "ProbabilityModule.cs"
            {
#line 350 "ProbabilityModule.cs"
                int csharp2cuda_temp_55 = (first)->count;
#line 350 "ProbabilityModule.cs"
                double total = mathblocks_compensated_sum(a, csharp2cuda_temp_55);
#line 351 "ProbabilityModule.cs"
                {
#line 351 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 351 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_57 = (output)->valid;
#line 351 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_58;
#line 351 "ProbabilityModule.cs"
                        if (csharp2cuda_temp_57)
                        {
#line 351 "ProbabilityModule.cs"
                            int csharp2cuda_temp_59 = (first)->count;
#line 351 "ProbabilityModule.cs"
                            csharp2cuda_temp_58 = ((index) < (csharp2cuda_temp_59));
                        }
                        else
                        {
#line 351 "ProbabilityModule.cs"
                            csharp2cuda_temp_58 = false;
                        }
                        if (!(csharp2cuda_temp_58))
                            break;
#line 352 "ProbabilityModule.cs"
#line 352 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_60 = &((result)[index]);
#line 352 "ProbabilityModule.cs"
                        double csharp2cuda_temp_61 = (a)[index];
#line 352 "ProbabilityModule.cs"
                        double csharp2cuda_temp_62 = __ddiv_rn(1.0, total);
                        (*(csharp2cuda_temp_60) = __dmul_rn(csharp2cuda_temp_61, csharp2cuda_temp_62));
#line 351 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_56 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_56));
                    }
                }
            }
            else
#line 355 "ProbabilityModule.cs"
            {
#line 356 "ProbabilityModule.cs"
                double maximum = (a)[0];
#line 357 "ProbabilityModule.cs"
                {
#line 357 "ProbabilityModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 357 "ProbabilityModule.cs"
                        int csharp2cuda_temp_64 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_64))))
                            break;
#line 358 "ProbabilityModule.cs"
#line 358 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_65 = &(maximum);
#line 358 "ProbabilityModule.cs"
                        double csharp2cuda_temp_66 = (a)[index];
                        (*(csharp2cuda_temp_65) = mathblocks_maximum(maximum, csharp2cuda_temp_66));
#line 357 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_63 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_63));
                    }
                }
#line 359 "ProbabilityModule.cs"
                {
#line 359 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 359 "ProbabilityModule.cs"
                        int csharp2cuda_temp_68 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_68))))
                            break;
#line 360 "ProbabilityModule.cs"
#line 360 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_69 = &((result)[index]);
#line 360 "ProbabilityModule.cs"
                        double csharp2cuda_temp_70 = (a)[index];
                        (*(csharp2cuda_temp_69) = mathblocks_exponential(__dsub_rn(csharp2cuda_temp_70, maximum)));
#line 359 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_67 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_67));
                    }
                }
#line 361 "ProbabilityModule.cs"
                int csharp2cuda_temp_71 = (first)->count;
#line 361 "ProbabilityModule.cs"
                double total = mathblocks_compensated_sum(result, csharp2cuda_temp_71);
#line 362 "ProbabilityModule.cs"
                double scale = __ddiv_rn(1.0, total);
#line 363 "ProbabilityModule.cs"
                {
#line 363 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 363 "ProbabilityModule.cs"
                        int csharp2cuda_temp_73 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_73))))
                            break;
#line 364 "ProbabilityModule.cs"
#line 364 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_74 = &((result)[index]);
#line 364 "ProbabilityModule.cs"
                        double csharp2cuda_temp_75 = *(csharp2cuda_temp_74);
                        (*(csharp2cuda_temp_74) = __dmul_rn(csharp2cuda_temp_75, scale));
#line 363 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_72 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_72));
                    }
                }
            }
#line 366 "ProbabilityModule.cs"
            {
#line 366 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 366 "ProbabilityModule.cs"
                    int csharp2cuda_temp_77 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_77))))
                        break;
#line 367 "ProbabilityModule.cs"
#line 367 "ProbabilityModule.cs"
                    double csharp2cuda_temp_78 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_78))))
                    {
#line 367 "ProbabilityModule.cs"
#line 367 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_79 = &((output)->valid);
                        (*(csharp2cuda_temp_79) = 0);
                    }
#line 366 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_76 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_76));
                }
            }
        }
#line 369 "ProbabilityModule.cs"
        return;
    }
#line 372 "ProbabilityModule.cs"
    if (((thread) != (0)))
    {
#line 373 "ProbabilityModule.cs"
        return;
    }
#line 375 "ProbabilityModule.cs"
#line 375 "ProbabilityModule.cs"
    bool csharp2cuda_temp_80;
#line 375 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 375 "ProbabilityModule.cs"
        csharp2cuda_temp_80 = ((opcode) == (1));
    }
    else
    {
#line 375 "ProbabilityModule.cs"
        csharp2cuda_temp_80 = true;
    }
#line 375 "ProbabilityModule.cs"
    bool csharp2cuda_temp_81;
#line 375 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_80))
    {
#line 375 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = ((opcode) == (2));
    }
    else
    {
#line 375 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = true;
    }
    if (csharp2cuda_temp_81)
#line 376 "ProbabilityModule.cs"
    {
#line 377 "ProbabilityModule.cs"
        int first_integer = 0;
#line 378 "ProbabilityModule.cs"
        int second_integer = 0;
#line 379 "ProbabilityModule.cs"
#line 379 "ProbabilityModule.cs"
        double csharp2cuda_temp_82 = (first)->scalar_value;
#line 379 "ProbabilityModule.cs"
        int* csharp2cuda_temp_83 = &(first_integer);
#line 379 "ProbabilityModule.cs"
        bool csharp2cuda_temp_84 = mathblocks_probability_integer(csharp2cuda_temp_82, csharp2cuda_temp_83);
#line 379 "ProbabilityModule.cs"
        bool csharp2cuda_temp_85;
#line 379 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_84))))
        {
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_85 = ((first_integer) < (0));
        }
        else
        {
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_85 = true;
        }
#line 379 "ProbabilityModule.cs"
        bool csharp2cuda_temp_86;
#line 379 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_85))
        {
#line 380 "ProbabilityModule.cs"
            bool csharp2cuda_temp_87;
#line 380 "ProbabilityModule.cs"
            if (((opcode) != (2)))
            {
#line 380 "ProbabilityModule.cs"
                double csharp2cuda_temp_88 = (second)->scalar_value;
#line 380 "ProbabilityModule.cs"
                int* csharp2cuda_temp_89 = &(second_integer);
#line 380 "ProbabilityModule.cs"
                bool csharp2cuda_temp_90 = mathblocks_probability_integer(csharp2cuda_temp_88, csharp2cuda_temp_89);
#line 380 "ProbabilityModule.cs"
                csharp2cuda_temp_87 = (!(csharp2cuda_temp_90));
            }
            else
            {
#line 380 "ProbabilityModule.cs"
                csharp2cuda_temp_87 = false;
            }
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_86 = csharp2cuda_temp_87;
        }
        else
        {
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_86 = true;
        }
#line 379 "ProbabilityModule.cs"
        bool csharp2cuda_temp_91;
#line 379 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_86))
        {
#line 381 "ProbabilityModule.cs"
            bool csharp2cuda_temp_92;
#line 381 "ProbabilityModule.cs"
            if (((opcode) == (2)))
            {
#line 381 "ProbabilityModule.cs"
                csharp2cuda_temp_92 = ((first_integer) > (170));
            }
            else
            {
#line 381 "ProbabilityModule.cs"
                csharp2cuda_temp_92 = false;
            }
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = csharp2cuda_temp_92;
        }
        else
        {
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = true;
        }
#line 379 "ProbabilityModule.cs"
        bool csharp2cuda_temp_93;
#line 379 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_91))
        {
#line 382 "ProbabilityModule.cs"
            bool csharp2cuda_temp_94;
#line 382 "ProbabilityModule.cs"
            if (((opcode) == (0)))
            {
#line 382 "ProbabilityModule.cs"
                bool csharp2cuda_temp_95;
#line 382 "ProbabilityModule.cs"
                if (!(((first_integer) <= (second_integer))))
                {
#line 382 "ProbabilityModule.cs"
                    csharp2cuda_temp_95 = ((second_integer) < (0));
                }
                else
                {
#line 382 "ProbabilityModule.cs"
                    csharp2cuda_temp_95 = true;
                }
#line 382 "ProbabilityModule.cs"
                csharp2cuda_temp_94 = csharp2cuda_temp_95;
            }
            else
            {
#line 382 "ProbabilityModule.cs"
                csharp2cuda_temp_94 = false;
            }
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_93 = csharp2cuda_temp_94;
        }
        else
        {
#line 379 "ProbabilityModule.cs"
            csharp2cuda_temp_93 = true;
        }
        if (csharp2cuda_temp_93)
#line 383 "ProbabilityModule.cs"
        {
#line 384 "ProbabilityModule.cs"
#line 384 "ProbabilityModule.cs"
            int* csharp2cuda_temp_96 = &((output)->valid);
            (*(csharp2cuda_temp_96) = 0);
#line 385 "ProbabilityModule.cs"
            return;
        }
#line 387 "ProbabilityModule.cs"
        if (((opcode) == (0)))
#line 388 "ProbabilityModule.cs"
        {
#line 389 "ProbabilityModule.cs"
#line 389 "ProbabilityModule.cs"
            double* csharp2cuda_temp_97 = &((output)->scalar_value);
#line 389 "ProbabilityModule.cs"
            double csharp2cuda_temp_98 = __ddiv_rn(((double)(csharp2cuda_i32_sub(first_integer, second_integer))), ((double)(csharp2cuda_i32_add(first_integer, second_integer))));
            (*(csharp2cuda_temp_97) = __dmul_rn(csharp2cuda_temp_98, mathblocks_probability_binomial(csharp2cuda_i32_add(first_integer, second_integer), second_integer)));
        }
        else
        {
#line 393 "ProbabilityModule.cs"
            if (((opcode) == (1)))
#line 394 "ProbabilityModule.cs"
            {
#line 395 "ProbabilityModule.cs"
#line 395 "ProbabilityModule.cs"
                double* csharp2cuda_temp_99 = &((output)->scalar_value);
                (*(csharp2cuda_temp_99) = mathblocks_probability_binomial(first_integer, second_integer));
            }
            else
#line 398 "ProbabilityModule.cs"
            {
#line 399 "ProbabilityModule.cs"
                double factorial = 1.0;
#line 400 "ProbabilityModule.cs"
                {
#line 400 "ProbabilityModule.cs"
                    int index = 2;
                    while (true)
                    {
                        if (!(((index) <= (first_integer))))
                            break;
#line 400 "ProbabilityModule.cs"
#line 400 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_101 = &(factorial);
#line 400 "ProbabilityModule.cs"
                        double csharp2cuda_temp_102 = *(csharp2cuda_temp_101);
                        (*(csharp2cuda_temp_101) = __dmul_rn(csharp2cuda_temp_102, ((double)(index))));
#line 400 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_100 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_100));
                    }
                }
#line 401 "ProbabilityModule.cs"
#line 401 "ProbabilityModule.cs"
                double* csharp2cuda_temp_103 = &((output)->scalar_value);
                (*(csharp2cuda_temp_103) = factorial);
            }
        }
#line 403 "ProbabilityModule.cs"
#line 403 "ProbabilityModule.cs"
        double csharp2cuda_temp_104 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_104))))
        {
#line 403 "ProbabilityModule.cs"
#line 403 "ProbabilityModule.cs"
            int* csharp2cuda_temp_105 = &((output)->valid);
            (*(csharp2cuda_temp_105) = 0);
        }
#line 404 "ProbabilityModule.cs"
        return;
    }
#line 407 "ProbabilityModule.cs"
#line 407 "ProbabilityModule.cs"
    bool csharp2cuda_temp_106;
#line 407 "ProbabilityModule.cs"
    if (((opcode) >= (4)))
    {
#line 407 "ProbabilityModule.cs"
        csharp2cuda_temp_106 = ((opcode) <= (16));
    }
    else
    {
#line 407 "ProbabilityModule.cs"
        csharp2cuda_temp_106 = false;
    }
    if (csharp2cuda_temp_106)
#line 408 "ProbabilityModule.cs"
    {
#line 409 "ProbabilityModule.cs"
        bool csharp2cuda_temp_107;
#line 409 "ProbabilityModule.cs"
        if (((opcode) == (12)))
        {
#line 410 "ProbabilityModule.cs"
            int csharp2cuda_temp_108 = (first)->count;
#line 409 "ProbabilityModule.cs"
            csharp2cuda_temp_107 = mathblocks_probability_distribution(a, csharp2cuda_temp_108);
        }
        else
        {
#line 411 "ProbabilityModule.cs"
            int csharp2cuda_temp_109 = (first)->count;
#line 409 "ProbabilityModule.cs"
            csharp2cuda_temp_107 = mathblocks_probability_distribution(a, csharp2cuda_temp_109);
        }
#line 409 "ProbabilityModule.cs"
        bool first_distribution = csharp2cuda_temp_107;
#line 412 "ProbabilityModule.cs"
        bool csharp2cuda_temp_110;
#line 412 "ProbabilityModule.cs"
        if (!(((opcode) == (4))))
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_110 = ((opcode) == (7));
        }
        else
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_110 = true;
        }
#line 412 "ProbabilityModule.cs"
        bool csharp2cuda_temp_111;
#line 412 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_110))
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_111 = ((opcode) == (9));
        }
        else
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_111 = true;
        }
#line 412 "ProbabilityModule.cs"
        bool csharp2cuda_temp_112;
#line 412 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_111))
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_112 = ((opcode) == (10));
        }
        else
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_112 = true;
        }
#line 412 "ProbabilityModule.cs"
        bool csharp2cuda_temp_113;
#line 412 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_112))
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_113 = ((opcode) == (11));
        }
        else
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_113 = true;
        }
#line 412 "ProbabilityModule.cs"
        bool csharp2cuda_temp_114;
#line 412 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_113))
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_114 = ((opcode) == (15));
        }
        else
        {
#line 412 "ProbabilityModule.cs"
            csharp2cuda_temp_114 = true;
        }
#line 412 "ProbabilityModule.cs"
        bool pair = csharp2cuda_temp_114;
#line 414 "ProbabilityModule.cs"
#line 414 "ProbabilityModule.cs"
        bool csharp2cuda_temp_115;
#line 414 "ProbabilityModule.cs"
        if (!((!(first_distribution))))
        {
#line 414 "ProbabilityModule.cs"
            bool csharp2cuda_temp_116;
#line 414 "ProbabilityModule.cs"
            if (pair)
            {
#line 415 "ProbabilityModule.cs"
                int csharp2cuda_temp_117 = (first)->count;
#line 415 "ProbabilityModule.cs"
                int csharp2cuda_temp_118 = (second)->count;
#line 415 "ProbabilityModule.cs"
                bool csharp2cuda_temp_119;
#line 415 "ProbabilityModule.cs"
                if (!(((csharp2cuda_temp_117) != (csharp2cuda_temp_118))))
                {
#line 415 "ProbabilityModule.cs"
                    int csharp2cuda_temp_120 = (second)->count;
#line 415 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_121 = mathblocks_probability_distribution(b, csharp2cuda_temp_120);
#line 415 "ProbabilityModule.cs"
                    csharp2cuda_temp_119 = (!(csharp2cuda_temp_121));
                }
                else
                {
#line 415 "ProbabilityModule.cs"
                    csharp2cuda_temp_119 = true;
                }
#line 414 "ProbabilityModule.cs"
                csharp2cuda_temp_116 = csharp2cuda_temp_119;
            }
            else
            {
#line 414 "ProbabilityModule.cs"
                csharp2cuda_temp_116 = false;
            }
#line 414 "ProbabilityModule.cs"
            csharp2cuda_temp_115 = csharp2cuda_temp_116;
        }
        else
        {
#line 414 "ProbabilityModule.cs"
            csharp2cuda_temp_115 = true;
        }
        if (csharp2cuda_temp_115)
#line 416 "ProbabilityModule.cs"
        {
#line 417 "ProbabilityModule.cs"
#line 417 "ProbabilityModule.cs"
            int* csharp2cuda_temp_122 = &((output)->valid);
            (*(csharp2cuda_temp_122) = 0);
#line 418 "ProbabilityModule.cs"
            return;
        }
#line 420 "ProbabilityModule.cs"
        double value = 0.0;
#line 421 "ProbabilityModule.cs"
        if (((opcode) == (4)))
#line 422 "ProbabilityModule.cs"
        {
#line 423 "ProbabilityModule.cs"
            {
#line 423 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 423 "ProbabilityModule.cs"
                    int csharp2cuda_temp_124 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_124))))
                        break;
#line 424 "ProbabilityModule.cs"
#line 424 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_125 = &(value);
#line 424 "ProbabilityModule.cs"
                    double csharp2cuda_temp_126 = *(csharp2cuda_temp_125);
#line 424 "ProbabilityModule.cs"
                    double csharp2cuda_temp_127 = (a)[index];
#line 424 "ProbabilityModule.cs"
                    double csharp2cuda_temp_128 = (b)[index];
                    (*(csharp2cuda_temp_125) = __dadd_rn(csharp2cuda_temp_126, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_127, csharp2cuda_temp_128))));
#line 423 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_123 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_123));
                }
            }
        }
        else
        {
#line 426 "ProbabilityModule.cs"
            if (((opcode) == (5)))
#line 427 "ProbabilityModule.cs"
            {
#line 428 "ProbabilityModule.cs"
#line 428 "ProbabilityModule.cs"
                double* csharp2cuda_temp_129 = &(value);
#line 428 "ProbabilityModule.cs"
                int csharp2cuda_temp_130 = (first)->count;
#line 428 "ProbabilityModule.cs"
                double csharp2cuda_temp_131 = mathblocks_probability_entropy(a, csharp2cuda_temp_130);
#line 428 "ProbabilityModule.cs"
                double csharp2cuda_temp_132 = __ddiv_rn(csharp2cuda_temp_131, mathblocks_natural_logarithm(2.0));
                (*(csharp2cuda_temp_129) = csharp2cuda_temp_132);
            }
            else
            {
#line 431 "ProbabilityModule.cs"
                if (((opcode) == (6)))
#line 432 "ProbabilityModule.cs"
                {
#line 433 "ProbabilityModule.cs"
                    int first_count = 0;
#line 434 "ProbabilityModule.cs"
                    int second_count = 0;
#line 435 "ProbabilityModule.cs"
                    int condition_count = 0;
#line 436 "ProbabilityModule.cs"
#line 436 "ProbabilityModule.cs"
                    double csharp2cuda_temp_133 = (second)->scalar_value;
#line 436 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_134 = &(first_count);
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_135 = mathblocks_probability_integer(csharp2cuda_temp_133, csharp2cuda_temp_134);
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_136;
#line 436 "ProbabilityModule.cs"
                    if (!((!(csharp2cuda_temp_135))))
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = ((first_count) <= (0));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = true;
                    }
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_137;
#line 436 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_136))
                    {
#line 437 "ProbabilityModule.cs"
                        double csharp2cuda_temp_138 = (third)->scalar_value;
#line 437 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_139 = &(second_count);
#line 437 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_140 = mathblocks_probability_integer(csharp2cuda_temp_138, csharp2cuda_temp_139);
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_137 = (!(csharp2cuda_temp_140));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_137 = true;
                    }
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_141;
#line 436 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_137))
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_141 = ((second_count) <= (0));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_141 = true;
                    }
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_142;
#line 436 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_141))
                    {
#line 438 "ProbabilityModule.cs"
                        double csharp2cuda_temp_143 = (fourth)->scalar_value;
#line 438 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_144 = &(condition_count);
#line 438 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_145 = mathblocks_probability_integer(csharp2cuda_temp_143, csharp2cuda_temp_144);
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_142 = (!(csharp2cuda_temp_145));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_142 = true;
                    }
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_146;
#line 436 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_142))
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_146 = ((condition_count) <= (0));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_146 = true;
                    }
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_147;
#line 436 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_146))
                    {
#line 439 "ProbabilityModule.cs"
                        int csharp2cuda_temp_148 = (first)->count;
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_147 = ((csharp2cuda_i64_mul(csharp2cuda_i64_mul(((long long)(first_count)), ((long long)(second_count))), ((long long)(condition_count)))) != (((long long)(csharp2cuda_temp_148))));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_147 = true;
                    }
#line 436 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_149;
#line 436 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_147))
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_149 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 436 "ProbabilityModule.cs"
                        csharp2cuda_temp_149 = true;
                    }
                    if (csharp2cuda_temp_149)
#line 440 "ProbabilityModule.cs"
                    {
#line 441 "ProbabilityModule.cs"
#line 441 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_150 = &((output)->valid);
                        (*(csharp2cuda_temp_150) = 0);
#line 442 "ProbabilityModule.cs"
                        return;
                    }
#line 444 "ProbabilityModule.cs"
                    int first_condition_count = csharp2cuda_i32_mul(first_count, condition_count);
#line 445 "ProbabilityModule.cs"
                    int second_condition_count = csharp2cuda_i32_mul(second_count, condition_count);
#line 446 "ProbabilityModule.cs"
                    double* first_condition = scratch;
#line 447 "ProbabilityModule.cs"
                    double* second_condition = csharp2cuda_pointer_add(first_condition, first_condition_count);
#line 448 "ProbabilityModule.cs"
                    double* condition = csharp2cuda_pointer_add(second_condition, second_condition_count);
#line 449 "ProbabilityModule.cs"
                    {
#line 449 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_add(csharp2cuda_i32_add(first_condition_count, second_condition_count), condition_count)))))
                                break;
#line 450 "ProbabilityModule.cs"
#line 450 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_152 = &((scratch)[index]);
                            (*(csharp2cuda_temp_152) = 0.0);
#line 449 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_151 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_151));
                        }
                    }
#line 451 "ProbabilityModule.cs"
                    {
#line 451 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 452 "ProbabilityModule.cs"
                            {
#line 452 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 453 "ProbabilityModule.cs"
                                    {
#line 453 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 454 "ProbabilityModule.cs"
                                            {
#line 455 "ProbabilityModule.cs"
                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 457 "ProbabilityModule.cs"
#line 457 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_156 = &((first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)]);
#line 457 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_157 = *(csharp2cuda_temp_156);
                                                (*(csharp2cuda_temp_156) = __dadd_rn(csharp2cuda_temp_157, probability));
#line 458 "ProbabilityModule.cs"
#line 458 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_158 = &((second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)]);
#line 458 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_159 = *(csharp2cuda_temp_158);
                                                (*(csharp2cuda_temp_158) = __dadd_rn(csharp2cuda_temp_159, probability));
#line 459 "ProbabilityModule.cs"
#line 459 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_160 = &((condition)[state]);
#line 459 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_161 = *(csharp2cuda_temp_160);
                                                (*(csharp2cuda_temp_160) = __dadd_rn(csharp2cuda_temp_161, probability));
                                            }
#line 453 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_155 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_155));
                                        }
                                    }
#line 452 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_154 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_154));
                                }
                            }
#line 451 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_153 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                        }
                    }
#line 461 "ProbabilityModule.cs"
                    {
#line 461 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 462 "ProbabilityModule.cs"
                            {
#line 462 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 463 "ProbabilityModule.cs"
                                    {
#line 463 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 464 "ProbabilityModule.cs"
                                            {
#line 465 "ProbabilityModule.cs"
                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 467 "ProbabilityModule.cs"
                                                if (((probability) == (0.0)))
                                                {
#line 467 "ProbabilityModule.cs"
                                                    goto csharp2cuda_for_continue_16;
                                                }
#line 468 "ProbabilityModule.cs"
#line 468 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_165 = &(value);
#line 468 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_166 = *(csharp2cuda_temp_165);
#line 469 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_167 = (condition)[state];
#line 470 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_168 = (first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)];
#line 471 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_169 = (second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)];
#line 469 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_170 = __ddiv_rn(__dmul_rn(probability, csharp2cuda_temp_167), __dmul_rn(csharp2cuda_temp_168, csharp2cuda_temp_169));
                                                (*(csharp2cuda_temp_165) = __dadd_rn(csharp2cuda_temp_166, __dmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_170))));
                                            }
                                            csharp2cuda_for_continue_16:
#line 463 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_164 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_164));
                                        }
                                    }
#line 462 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_163 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_163));
                                }
                            }
#line 461 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_162 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_162));
                        }
                    }
                }
                else
                {
#line 474 "ProbabilityModule.cs"
                    if (((opcode) == (7)))
#line 475 "ProbabilityModule.cs"
                    {
#line 476 "ProbabilityModule.cs"
                        {
#line 476 "ProbabilityModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 476 "ProbabilityModule.cs"
                                int csharp2cuda_temp_172 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_172))))
                                    break;
#line 477 "ProbabilityModule.cs"
                                {
#line 478 "ProbabilityModule.cs"
#line 478 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_173 = (a)[index];
#line 478 "ProbabilityModule.cs"
                                    bool csharp2cuda_temp_174;
#line 478 "ProbabilityModule.cs"
                                    if (((csharp2cuda_temp_173) > (0.0)))
                                    {
#line 478 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_175 = (b)[index];
#line 478 "ProbabilityModule.cs"
                                        csharp2cuda_temp_174 = ((csharp2cuda_temp_175) == (0.0));
                                    }
                                    else
                                    {
#line 478 "ProbabilityModule.cs"
                                        csharp2cuda_temp_174 = false;
                                    }
                                    if (csharp2cuda_temp_174)
#line 479 "ProbabilityModule.cs"
                                    {
#line 480 "ProbabilityModule.cs"
#line 480 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_176 = &((output)->valid);
                                        (*(csharp2cuda_temp_176) = 0);
#line 481 "ProbabilityModule.cs"
                                        return;
                                    }
#line 483 "ProbabilityModule.cs"
#line 483 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_177 = (a)[index];
                                    if (((csharp2cuda_temp_177) > (0.0)))
                                    {
#line 484 "ProbabilityModule.cs"
#line 484 "ProbabilityModule.cs"
                                        double* csharp2cuda_temp_178 = &(value);
#line 484 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_179 = *(csharp2cuda_temp_178);
#line 484 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_180 = (a)[index];
#line 484 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_181 = (b)[index];
                                        (*(csharp2cuda_temp_178) = __dsub_rn(csharp2cuda_temp_179, __dmul_rn(csharp2cuda_temp_180, mathblocks_natural_logarithm(csharp2cuda_temp_181))));
                                    }
                                }
#line 476 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_171 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_171));
                            }
                        }
                    }
                    else
                    {
#line 487 "ProbabilityModule.cs"
                        if (((opcode) == (8)))
#line 488 "ProbabilityModule.cs"
                        {
#line 489 "ProbabilityModule.cs"
#line 489 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_182 = &(value);
#line 489 "ProbabilityModule.cs"
                            int csharp2cuda_temp_183 = (first)->count;
                            (*(csharp2cuda_temp_182) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_183)));
                        }
                        else
                        {
#line 491 "ProbabilityModule.cs"
                            if (((opcode) == (9)))
#line 492 "ProbabilityModule.cs"
                            {
#line 493 "ProbabilityModule.cs"
                                {
#line 493 "ProbabilityModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 493 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_185 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_185))))
                                            break;
#line 494 "ProbabilityModule.cs"
                                        {
#line 495 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_186 = (a)[index];
#line 495 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_187 = (b)[index];
#line 495 "ProbabilityModule.cs"
                                            double difference = __dsub_rn(mathblocks_square_root(csharp2cuda_temp_186), mathblocks_square_root(csharp2cuda_temp_187));
#line 496 "ProbabilityModule.cs"
#line 496 "ProbabilityModule.cs"
                                            double* csharp2cuda_temp_188 = &(value);
#line 496 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_189 = *(csharp2cuda_temp_188);
                                            (*(csharp2cuda_temp_188) = __dadd_rn(csharp2cuda_temp_189, __dmul_rn(difference, difference)));
                                        }
#line 493 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_184 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_184));
                                    }
                                }
#line 498 "ProbabilityModule.cs"
#line 498 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_190 = &(value);
#line 498 "ProbabilityModule.cs"
                                double csharp2cuda_temp_191 = __ddiv_rn(value, 2.0);
                                (*(csharp2cuda_temp_190) = mathblocks_square_root(csharp2cuda_temp_191));
                            }
                            else
                            {
#line 500 "ProbabilityModule.cs"
                                if (((opcode) == (10)))
#line 501 "ProbabilityModule.cs"
                                {
#line 502 "ProbabilityModule.cs"
                                    if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 503 "ProbabilityModule.cs"
                                    {
#line 504 "ProbabilityModule.cs"
#line 504 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_192 = &((output)->valid);
                                        (*(csharp2cuda_temp_192) = 0);
#line 505 "ProbabilityModule.cs"
                                        return;
                                    }
#line 507 "ProbabilityModule.cs"
                                    {
#line 507 "ProbabilityModule.cs"
                                        int index = 0;
                                        while (true)
                                        {
#line 507 "ProbabilityModule.cs"
                                            int csharp2cuda_temp_194 = (first)->count;
                                            if (!(((index) < (csharp2cuda_temp_194))))
                                                break;
#line 508 "ProbabilityModule.cs"
#line 508 "ProbabilityModule.cs"
                                            double* csharp2cuda_temp_195 = &((scratch)[index]);
#line 508 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_196 = (a)[index];
#line 508 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_197 = (b)[index];
#line 508 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_198 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_196, csharp2cuda_temp_197), 2.0);
                                            (*(csharp2cuda_temp_195) = csharp2cuda_temp_198);
#line 507 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_193 = &(index);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_193));
                                        }
                                    }
#line 509 "ProbabilityModule.cs"
#line 509 "ProbabilityModule.cs"
                                    double* csharp2cuda_temp_199 = &(value);
#line 509 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_200 = (first)->count;
#line 509 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_201 = mathblocks_probability_kl(a, scratch, csharp2cuda_temp_200);
#line 510 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_202 = (first)->count;
#line 510 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_203 = mathblocks_probability_kl(b, scratch, csharp2cuda_temp_202);
                                    (*(csharp2cuda_temp_199) = __dmul_rn(0.5, __dadd_rn(csharp2cuda_temp_201, csharp2cuda_temp_203)));
                                }
                                else
                                {
#line 512 "ProbabilityModule.cs"
                                    if (((opcode) == (11)))
#line 513 "ProbabilityModule.cs"
                                    {
#line 514 "ProbabilityModule.cs"
                                        {
#line 514 "ProbabilityModule.cs"
                                            int index = 0;
                                            while (true)
                                            {
#line 514 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_205 = (first)->count;
                                                if (!(((index) < (csharp2cuda_temp_205))))
                                                    break;
#line 515 "ProbabilityModule.cs"
#line 515 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_206 = (a)[index];
#line 515 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_207;
#line 515 "ProbabilityModule.cs"
                                                if (((csharp2cuda_temp_206) > (0.0)))
                                                {
#line 515 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_208 = (b)[index];
#line 515 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_207 = ((csharp2cuda_temp_208) == (0.0));
                                                }
                                                else
                                                {
#line 515 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_207 = false;
                                                }
                                                if (csharp2cuda_temp_207)
#line 516 "ProbabilityModule.cs"
                                                {
#line 517 "ProbabilityModule.cs"
#line 517 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_209 = &((output)->valid);
                                                    (*(csharp2cuda_temp_209) = 0);
#line 518 "ProbabilityModule.cs"
                                                    return;
                                                }
#line 514 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_204 = &(index);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_204));
                                            }
                                        }
#line 520 "ProbabilityModule.cs"
#line 520 "ProbabilityModule.cs"
                                        double* csharp2cuda_temp_210 = &(value);
#line 520 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_211 = (first)->count;
#line 520 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_212 = mathblocks_probability_kl(a, b, csharp2cuda_temp_211);
                                        (*(csharp2cuda_temp_210) = csharp2cuda_temp_212);
                                    }
                                    else
                                    {
#line 522 "ProbabilityModule.cs"
                                        if (((opcode) == (12)))
#line 523 "ProbabilityModule.cs"
                                        {
#line 524 "ProbabilityModule.cs"
                                            int rows = (first)->rows;
#line 525 "ProbabilityModule.cs"
                                            int columns = (first)->columns;
#line 526 "ProbabilityModule.cs"
                                            if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 527 "ProbabilityModule.cs"
                                            {
#line 528 "ProbabilityModule.cs"
#line 528 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_213 = &((output)->valid);
                                                (*(csharp2cuda_temp_213) = 0);
#line 529 "ProbabilityModule.cs"
                                                return;
                                            }
#line 531 "ProbabilityModule.cs"
                                            double* row_totals = scratch;
#line 532 "ProbabilityModule.cs"
                                            double* column_totals = csharp2cuda_pointer_add(scratch, rows);
#line 533 "ProbabilityModule.cs"
                                            {
#line 533 "ProbabilityModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
                                                    if (!(((index) < (csharp2cuda_i32_add(rows, columns)))))
                                                        break;
#line 533 "ProbabilityModule.cs"
#line 533 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_215 = &((scratch)[index]);
                                                    (*(csharp2cuda_temp_215) = 0.0);
#line 533 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_214 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_214));
                                                }
                                            }
#line 534 "ProbabilityModule.cs"
                                            {
#line 534 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 535 "ProbabilityModule.cs"
                                                    {
#line 535 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 536 "ProbabilityModule.cs"
                                                            {
#line 537 "ProbabilityModule.cs"
                                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 538 "ProbabilityModule.cs"
#line 538 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_218 = &((row_totals)[row]);
#line 538 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_219 = *(csharp2cuda_temp_218);
                                                                (*(csharp2cuda_temp_218) = __dadd_rn(csharp2cuda_temp_219, probability));
#line 539 "ProbabilityModule.cs"
#line 539 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_220 = &((column_totals)[column]);
#line 539 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_221 = *(csharp2cuda_temp_220);
                                                                (*(csharp2cuda_temp_220) = __dadd_rn(csharp2cuda_temp_221, probability));
                                                            }
#line 535 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_217 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                                                        }
                                                    }
#line 534 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_216 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_216));
                                                }
                                            }
#line 541 "ProbabilityModule.cs"
                                            {
#line 541 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 542 "ProbabilityModule.cs"
                                                    {
#line 542 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 543 "ProbabilityModule.cs"
                                                            {
#line 544 "ProbabilityModule.cs"
                                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 545 "ProbabilityModule.cs"
                                                                if (((probability) > (0.0)))
                                                                {
#line 546 "ProbabilityModule.cs"
#line 546 "ProbabilityModule.cs"
                                                                    double* csharp2cuda_temp_224 = &(value);
#line 546 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_225 = *(csharp2cuda_temp_224);
#line 547 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_226 = (row_totals)[row];
#line 547 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_227 = (column_totals)[column];
#line 547 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_228 = __ddiv_rn(probability, __dmul_rn(csharp2cuda_temp_226, csharp2cuda_temp_227));
                                                                    (*(csharp2cuda_temp_224) = __dadd_rn(csharp2cuda_temp_225, __dmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_228))));
                                                                }
                                                            }
#line 542 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_223 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_223));
                                                        }
                                                    }
#line 541 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_222 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_222));
                                                }
                                            }
                                        }
                                        else
                                        {
#line 550 "ProbabilityModule.cs"
#line 550 "ProbabilityModule.cs"
                                            bool csharp2cuda_temp_229;
#line 550 "ProbabilityModule.cs"
                                            if (!(((opcode) == (13))))
                                            {
#line 550 "ProbabilityModule.cs"
                                                csharp2cuda_temp_229 = ((opcode) == (16));
                                            }
                                            else
                                            {
#line 550 "ProbabilityModule.cs"
                                                csharp2cuda_temp_229 = true;
                                            }
                                            if (csharp2cuda_temp_229)
#line 551 "ProbabilityModule.cs"
                                            {
#line 552 "ProbabilityModule.cs"
                                                double order = (second)->scalar_value;
#line 553 "ProbabilityModule.cs"
                                                if (((order) <= (0.0)))
#line 554 "ProbabilityModule.cs"
                                                {
#line 555 "ProbabilityModule.cs"
#line 555 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_230 = &((output)->valid);
                                                    (*(csharp2cuda_temp_230) = 0);
#line 556 "ProbabilityModule.cs"
                                                    return;
                                                }
#line 558 "ProbabilityModule.cs"
                                                if (((order) == (1.0)))
#line 559 "ProbabilityModule.cs"
                                                {
#line 560 "ProbabilityModule.cs"
#line 560 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_231 = &(value);
#line 560 "ProbabilityModule.cs"
                                                    int csharp2cuda_temp_232 = (first)->count;
#line 560 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_233 = mathblocks_probability_entropy(a, csharp2cuda_temp_232);
                                                    (*(csharp2cuda_temp_231) = csharp2cuda_temp_233);
                                                }
                                                else
#line 563 "ProbabilityModule.cs"
                                                {
#line 564 "ProbabilityModule.cs"
                                                    double sum = 0.0;
#line 565 "ProbabilityModule.cs"
                                                    {
#line 565 "ProbabilityModule.cs"
                                                        int index = 0;
                                                        while (true)
                                                        {
#line 565 "ProbabilityModule.cs"
                                                            int csharp2cuda_temp_235 = (first)->count;
                                                            if (!(((index) < (csharp2cuda_temp_235))))
                                                                break;
#line 566 "ProbabilityModule.cs"
#line 566 "ProbabilityModule.cs"
                                                            double* csharp2cuda_temp_236 = &(sum);
#line 566 "ProbabilityModule.cs"
                                                            double csharp2cuda_temp_237 = *(csharp2cuda_temp_236);
#line 566 "ProbabilityModule.cs"
                                                            double csharp2cuda_temp_238 = (a)[index];
                                                            (*(csharp2cuda_temp_236) = __dadd_rn(csharp2cuda_temp_237, mathblocks_power(csharp2cuda_temp_238, order)));
#line 565 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_234 = &(index);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_234));
                                                        }
                                                    }
#line 567 "ProbabilityModule.cs"
#line 567 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_239 = &(value);
#line 567 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_240;
#line 567 "ProbabilityModule.cs"
                                                    if (((opcode) == (13)))
                                                    {
#line 567 "ProbabilityModule.cs"
                                                        csharp2cuda_temp_240 = __ddiv_rn(mathblocks_natural_logarithm(sum), __dsub_rn(1.0, order));
                                                    }
                                                    else
                                                    {
#line 567 "ProbabilityModule.cs"
                                                        csharp2cuda_temp_240 = __ddiv_rn(__dsub_rn(1.0, sum), __dsub_rn(order, 1.0));
                                                    }
                                                    (*(csharp2cuda_temp_239) = csharp2cuda_temp_240);
                                                }
                                            }
                                            else
                                            {
#line 572 "ProbabilityModule.cs"
                                                if (((opcode) == (14)))
#line 573 "ProbabilityModule.cs"
                                                {
#line 574 "ProbabilityModule.cs"
#line 574 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_241 = &(value);
#line 574 "ProbabilityModule.cs"
                                                    int csharp2cuda_temp_242 = (first)->count;
#line 574 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_243 = mathblocks_probability_entropy(a, csharp2cuda_temp_242);
                                                    (*(csharp2cuda_temp_241) = csharp2cuda_temp_243);
                                                }
                                                else
                                                {
#line 576 "ProbabilityModule.cs"
                                                    if (((opcode) == (15)))
#line 577 "ProbabilityModule.cs"
                                                    {
#line 578 "ProbabilityModule.cs"
                                                        {
#line 578 "ProbabilityModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
#line 578 "ProbabilityModule.cs"
                                                                int csharp2cuda_temp_245 = (first)->count;
                                                                if (!(((index) < (csharp2cuda_temp_245))))
                                                                    break;
#line 579 "ProbabilityModule.cs"
#line 579 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_246 = &(value);
#line 579 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_247 = *(csharp2cuda_temp_246);
#line 579 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_248 = (a)[index];
#line 579 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_249 = (b)[index];
                                                                (*(csharp2cuda_temp_246) = __dadd_rn(csharp2cuda_temp_247, fabs(__dsub_rn(csharp2cuda_temp_248, csharp2cuda_temp_249))));
#line 578 "ProbabilityModule.cs"
                                                                int* csharp2cuda_temp_244 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_244));
                                                            }
                                                        }
#line 580 "ProbabilityModule.cs"
#line 580 "ProbabilityModule.cs"
                                                        double* csharp2cuda_temp_250 = &(value);
#line 580 "ProbabilityModule.cs"
                                                        double csharp2cuda_temp_251 = *(csharp2cuda_temp_250);
                                                        (*(csharp2cuda_temp_250) = __ddiv_rn(csharp2cuda_temp_251, 2.0));
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
#line 582 "ProbabilityModule.cs"
#line 582 "ProbabilityModule.cs"
        double* csharp2cuda_temp_252 = &((output)->scalar_value);
        (*(csharp2cuda_temp_252) = value);
#line 583 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 583 "ProbabilityModule.cs"
#line 583 "ProbabilityModule.cs"
            int* csharp2cuda_temp_253 = &((output)->valid);
            (*(csharp2cuda_temp_253) = 0);
        }
#line 584 "ProbabilityModule.cs"
        return;
    }
#line 587 "ProbabilityModule.cs"
    if (((opcode) == (17)))
#line 588 "ProbabilityModule.cs"
    {
#line 589 "ProbabilityModule.cs"
        double parameter = (second)->scalar_value;
#line 590 "ProbabilityModule.cs"
#line 590 "ProbabilityModule.cs"
        int csharp2cuda_temp_254 = (first)->count;
#line 590 "ProbabilityModule.cs"
        bool csharp2cuda_temp_255;
#line 590 "ProbabilityModule.cs"
        if (!(((csharp2cuda_temp_254) <= (0))))
        {
#line 590 "ProbabilityModule.cs"
            csharp2cuda_temp_255 = ((parameter) < (0.0));
        }
        else
        {
#line 590 "ProbabilityModule.cs"
            csharp2cuda_temp_255 = true;
        }
#line 590 "ProbabilityModule.cs"
        bool csharp2cuda_temp_256;
#line 590 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_255))
        {
#line 590 "ProbabilityModule.cs"
            csharp2cuda_temp_256 = ((parameter) > (1.0));
        }
        else
        {
#line 590 "ProbabilityModule.cs"
            csharp2cuda_temp_256 = true;
        }
        if (csharp2cuda_temp_256)
#line 591 "ProbabilityModule.cs"
        {
#line 592 "ProbabilityModule.cs"
#line 592 "ProbabilityModule.cs"
            int* csharp2cuda_temp_257 = &((output)->valid);
            (*(csharp2cuda_temp_257) = 0);
#line 593 "ProbabilityModule.cs"
            return;
        }
#line 595 "ProbabilityModule.cs"
        int csharp2cuda_temp_258 = (first)->count;
#line 595 "ProbabilityModule.cs"
        int degree = csharp2cuda_i32_sub(csharp2cuda_temp_258, 1);
#line 596 "ProbabilityModule.cs"
        double value = 0.0;
#line 597 "ProbabilityModule.cs"
        {
#line 597 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (degree))))
                    break;
#line 598 "ProbabilityModule.cs"
#line 598 "ProbabilityModule.cs"
                double* csharp2cuda_temp_260 = &(value);
#line 598 "ProbabilityModule.cs"
                double csharp2cuda_temp_261 = *(csharp2cuda_temp_260);
#line 598 "ProbabilityModule.cs"
                double csharp2cuda_temp_262 = (a)[index];
                (*(csharp2cuda_temp_260) = __dadd_rn(csharp2cuda_temp_261, __dmul_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_262, mathblocks_probability_binomial(degree, index)), mathblocks_power(parameter, ((double)(index)))), mathblocks_power(__dsub_rn(1.0, parameter), ((double)(csharp2cuda_i32_sub(degree, index)))))));
#line 597 "ProbabilityModule.cs"
                int* csharp2cuda_temp_259 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_259));
            }
        }
#line 601 "ProbabilityModule.cs"
#line 601 "ProbabilityModule.cs"
        double* csharp2cuda_temp_263 = &((output)->scalar_value);
        (*(csharp2cuda_temp_263) = value);
#line 602 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 602 "ProbabilityModule.cs"
#line 602 "ProbabilityModule.cs"
            int* csharp2cuda_temp_264 = &((output)->valid);
            (*(csharp2cuda_temp_264) = 0);
        }
#line 603 "ProbabilityModule.cs"
        return;
    }
#line 606 "ProbabilityModule.cs"
    if (((opcode) == (18)))
#line 607 "ProbabilityModule.cs"
    {
#line 608 "ProbabilityModule.cs"
#line 608 "ProbabilityModule.cs"
        int csharp2cuda_temp_265 = (first)->count;
        if (((csharp2cuda_temp_265) != (4)))
#line 609 "ProbabilityModule.cs"
        {
#line 610 "ProbabilityModule.cs"
#line 610 "ProbabilityModule.cs"
            int* csharp2cuda_temp_266 = &((output)->valid);
            (*(csharp2cuda_temp_266) = 0);
#line 611 "ProbabilityModule.cs"
            return;
        }
#line 613 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_267 = (output)->data_pointer;
#line 613 "ProbabilityModule.cs"
        MathBlockComplexValue* roots = ((MathBlockComplexValue*)(csharp2cuda_temp_267));
#line 614 "ProbabilityModule.cs"
        mathblocks_complex_shape(output, 3);
#line 615 "ProbabilityModule.cs"
        double constant = (a)[0];
#line 616 "ProbabilityModule.cs"
        double linear = (a)[1];
#line 617 "ProbabilityModule.cs"
        double quadratic = (a)[2];
#line 618 "ProbabilityModule.cs"
        double leading = (a)[3];
#line 619 "ProbabilityModule.cs"
        if (((leading) == (0.0)))
#line 620 "ProbabilityModule.cs"
        {
#line 621 "ProbabilityModule.cs"
#line 621 "ProbabilityModule.cs"
            int* csharp2cuda_temp_268 = &((output)->valid);
            (*(csharp2cuda_temp_268) = 0);
#line 622 "ProbabilityModule.cs"
            return;
        }
#line 624 "ProbabilityModule.cs"
        double normalized_a = __ddiv_rn(quadratic, leading);
#line 625 "ProbabilityModule.cs"
        double normalized_b = __ddiv_rn(linear, leading);
#line 626 "ProbabilityModule.cs"
        double normalized_c = __ddiv_rn(constant, leading);
#line 627 "ProbabilityModule.cs"
        double csharp2cuda_temp_269 = __ddiv_rn(__dmul_rn(normalized_a, normalized_a), 3.0);
#line 627 "ProbabilityModule.cs"
        double p = __dsub_rn(normalized_b, csharp2cuda_temp_269);
#line 628 "ProbabilityModule.cs"
        double csharp2cuda_temp_270 = __ddiv_rn(__dmul_rn(__dmul_rn(__dmul_rn(2.0, normalized_a), normalized_a), normalized_a), 27.0);
#line 629 "ProbabilityModule.cs"
        double csharp2cuda_temp_271 = __ddiv_rn(__dmul_rn(normalized_a, normalized_b), 3.0);
#line 628 "ProbabilityModule.cs"
        double q = __dadd_rn(__dsub_rn(csharp2cuda_temp_270, csharp2cuda_temp_271), normalized_c);
#line 631 "ProbabilityModule.cs"
        double csharp2cuda_temp_272 = __ddiv_rn(__dmul_rn(q, q), 4.0);
#line 631 "ProbabilityModule.cs"
        double csharp2cuda_temp_273 = __ddiv_rn(__dmul_rn(__dmul_rn(p, p), p), 27.0);
#line 630 "ProbabilityModule.cs"
        MathBlockComplexValue square_root = mathblocks_complex_square_root(mathblocks_complex_make(__dadd_rn(csharp2cuda_temp_272, csharp2cuda_temp_273), 0.0));
#line 633 "ProbabilityModule.cs"
        double csharp2cuda_temp_274 = __ddiv_rn((-(q)), 2.0);
#line 632 "ProbabilityModule.cs"
        MathBlockComplexValue u = mathblocks_probability_complex_cube_root(mathblocks_complex_add(mathblocks_complex_make(csharp2cuda_temp_274, 0.0), square_root));
#line 634 "ProbabilityModule.cs"
        double csharp2cuda_temp_275 = (u).real;
#line 634 "ProbabilityModule.cs"
        bool csharp2cuda_temp_276;
#line 634 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_275) == (0.0)))
        {
#line 634 "ProbabilityModule.cs"
            double csharp2cuda_temp_277 = (u).imaginary;
#line 634 "ProbabilityModule.cs"
            csharp2cuda_temp_276 = ((csharp2cuda_temp_277) == (0.0));
        }
        else
        {
#line 634 "ProbabilityModule.cs"
            csharp2cuda_temp_276 = false;
        }
#line 634 "ProbabilityModule.cs"
        MathBlockComplexValue csharp2cuda_temp_278;
#line 634 "ProbabilityModule.cs"
        if (csharp2cuda_temp_276)
        {
#line 636 "ProbabilityModule.cs"
            double csharp2cuda_temp_279 = __ddiv_rn((-(q)), 2.0);
#line 634 "ProbabilityModule.cs"
            csharp2cuda_temp_278 = mathblocks_probability_complex_cube_root(mathblocks_complex_subtract(mathblocks_complex_make(csharp2cuda_temp_279, 0.0), square_root));
        }
        else
        {
#line 634 "ProbabilityModule.cs"
            csharp2cuda_temp_278 = mathblocks_complex_divide(mathblocks_complex_make((-(p)), 0.0), mathblocks_complex_multiply(mathblocks_complex_make(3.0, 0.0), u));
        }
#line 634 "ProbabilityModule.cs"
        MathBlockComplexValue v = csharp2cuda_temp_278;
#line 642 "ProbabilityModule.cs"
        double csharp2cuda_temp_280 = __ddiv_rn(mathblocks_square_root(3.0), 2.0);
#line 640 "ProbabilityModule.cs"
        MathBlockComplexValue omega = mathblocks_complex_make((-(0.5)), csharp2cuda_temp_280);
#line 643 "ProbabilityModule.cs"
#line 643 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_281 = &((roots)[0]);
#line 645 "ProbabilityModule.cs"
        double csharp2cuda_temp_282 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_281) = mathblocks_complex_subtract(mathblocks_complex_add(u, v), mathblocks_complex_make(csharp2cuda_temp_282, 0.0)));
#line 646 "ProbabilityModule.cs"
#line 646 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_283 = &((roots)[1]);
#line 650 "ProbabilityModule.cs"
        double csharp2cuda_temp_284 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_283) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(omega, u), mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), v)), mathblocks_complex_make(csharp2cuda_temp_284, 0.0)));
#line 651 "ProbabilityModule.cs"
#line 651 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_285 = &((roots)[2]);
#line 655 "ProbabilityModule.cs"
        double csharp2cuda_temp_286 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_285) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), u), mathblocks_complex_multiply(omega, v)), mathblocks_complex_make(csharp2cuda_temp_286, 0.0)));
#line 656 "ProbabilityModule.cs"
        {
#line 656 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (3))))
                    break;
#line 657 "ProbabilityModule.cs"
#line 657 "ProbabilityModule.cs"
                MathBlockComplexValue csharp2cuda_temp_288 = (roots)[index];
                if ((!(mathblocks_complex_finite(csharp2cuda_temp_288))))
                {
#line 657 "ProbabilityModule.cs"
#line 657 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_289 = &((output)->valid);
                    (*(csharp2cuda_temp_289) = 0);
                }
#line 656 "ProbabilityModule.cs"
                int* csharp2cuda_temp_287 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_287));
            }
        }
#line 658 "ProbabilityModule.cs"
        return;
    }
#line 661 "ProbabilityModule.cs"
    if (((opcode) == (20)))
#line 662 "ProbabilityModule.cs"
    {
#line 663 "ProbabilityModule.cs"
        int order = 0;
#line 664 "ProbabilityModule.cs"
#line 664 "ProbabilityModule.cs"
        double csharp2cuda_temp_290 = (second)->scalar_value;
#line 664 "ProbabilityModule.cs"
        int* csharp2cuda_temp_291 = &(order);
#line 664 "ProbabilityModule.cs"
        bool csharp2cuda_temp_292 = mathblocks_probability_integer(csharp2cuda_temp_290, csharp2cuda_temp_291);
#line 664 "ProbabilityModule.cs"
        bool csharp2cuda_temp_293;
#line 664 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_292))))
        {
#line 664 "ProbabilityModule.cs"
            csharp2cuda_temp_293 = ((order) < (0));
        }
        else
        {
#line 664 "ProbabilityModule.cs"
            csharp2cuda_temp_293 = true;
        }
#line 664 "ProbabilityModule.cs"
        bool csharp2cuda_temp_294;
#line 664 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_293))
        {
#line 665 "ProbabilityModule.cs"
            int csharp2cuda_temp_295 = (first)->count;
#line 664 "ProbabilityModule.cs"
            csharp2cuda_temp_294 = ((order) > (csharp2cuda_temp_295));
        }
        else
        {
#line 664 "ProbabilityModule.cs"
            csharp2cuda_temp_294 = true;
        }
#line 664 "ProbabilityModule.cs"
        bool csharp2cuda_temp_296;
#line 664 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_294))
        {
#line 664 "ProbabilityModule.cs"
            csharp2cuda_temp_296 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 664 "ProbabilityModule.cs"
            csharp2cuda_temp_296 = true;
        }
        if (csharp2cuda_temp_296)
#line 666 "ProbabilityModule.cs"
        {
#line 667 "ProbabilityModule.cs"
#line 667 "ProbabilityModule.cs"
            int* csharp2cuda_temp_297 = &((output)->valid);
            (*(csharp2cuda_temp_297) = 0);
#line 668 "ProbabilityModule.cs"
            return;
        }
#line 670 "ProbabilityModule.cs"
        {
#line 670 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (order))))
                    break;
#line 670 "ProbabilityModule.cs"
#line 670 "ProbabilityModule.cs"
                double* csharp2cuda_temp_299 = &((scratch)[index]);
                (*(csharp2cuda_temp_299) = 0.0);
#line 670 "ProbabilityModule.cs"
                int* csharp2cuda_temp_298 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_298));
            }
        }
#line 671 "ProbabilityModule.cs"
#line 671 "ProbabilityModule.cs"
        double* csharp2cuda_temp_300 = &((scratch)[0]);
        (*(csharp2cuda_temp_300) = 1.0);
#line 672 "ProbabilityModule.cs"
        {
#line 672 "ProbabilityModule.cs"
            int value_index = 0;
            while (true)
            {
#line 672 "ProbabilityModule.cs"
                int csharp2cuda_temp_302 = (first)->count;
                if (!(((value_index) < (csharp2cuda_temp_302))))
                    break;
#line 673 "ProbabilityModule.cs"
                {
#line 674 "ProbabilityModule.cs"
                    int csharp2cuda_temp_303;
#line 674 "ProbabilityModule.cs"
                    if (((order) < (csharp2cuda_i32_add(value_index, 1))))
                    {
#line 674 "ProbabilityModule.cs"
                        csharp2cuda_temp_303 = order;
                    }
                    else
                    {
#line 674 "ProbabilityModule.cs"
                        csharp2cuda_temp_303 = csharp2cuda_i32_add(value_index, 1);
                    }
#line 674 "ProbabilityModule.cs"
                    int maximum = csharp2cuda_temp_303;
#line 675 "ProbabilityModule.cs"
                    {
#line 675 "ProbabilityModule.cs"
                        int degree = maximum;
                        while (true)
                        {
                            if (!(((degree) >= (1))))
                                break;
#line 676 "ProbabilityModule.cs"
#line 676 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_305 = &((scratch)[degree]);
#line 676 "ProbabilityModule.cs"
                            double csharp2cuda_temp_306 = *(csharp2cuda_temp_305);
#line 676 "ProbabilityModule.cs"
                            double csharp2cuda_temp_307 = (a)[value_index];
#line 676 "ProbabilityModule.cs"
                            double csharp2cuda_temp_308 = (scratch)[csharp2cuda_i32_sub(degree, 1)];
                            (*(csharp2cuda_temp_305) = __dadd_rn(csharp2cuda_temp_306, __dmul_rn(csharp2cuda_temp_307, csharp2cuda_temp_308)));
#line 675 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_304 = &(degree);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_304));
                        }
                    }
                }
#line 672 "ProbabilityModule.cs"
                int* csharp2cuda_temp_301 = &(value_index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_301));
            }
        }
#line 678 "ProbabilityModule.cs"
#line 678 "ProbabilityModule.cs"
        double* csharp2cuda_temp_309 = &((output)->scalar_value);
#line 678 "ProbabilityModule.cs"
        double csharp2cuda_temp_310 = (scratch)[order];
        (*(csharp2cuda_temp_309) = csharp2cuda_temp_310);
#line 679 "ProbabilityModule.cs"
        return;
    }
#line 682 "ProbabilityModule.cs"
    if (((opcode) == (21)))
#line 683 "ProbabilityModule.cs"
    {
#line 684 "ProbabilityModule.cs"
        double value = 0.0;
#line 685 "ProbabilityModule.cs"
        {
#line 685 "ProbabilityModule.cs"
            int csharp2cuda_temp_311 = (first)->count;
#line 685 "ProbabilityModule.cs"
            int index = csharp2cuda_i32_sub(csharp2cuda_temp_311, 1);
            while (true)
            {
                if (!(((index) >= (0))))
                    break;
#line 686 "ProbabilityModule.cs"
#line 686 "ProbabilityModule.cs"
                double* csharp2cuda_temp_313 = &(value);
#line 686 "ProbabilityModule.cs"
                double csharp2cuda_temp_314 = (second)->scalar_value;
#line 686 "ProbabilityModule.cs"
                double csharp2cuda_temp_315 = (a)[index];
                (*(csharp2cuda_temp_313) = __dadd_rn(__dmul_rn(value, csharp2cuda_temp_314), csharp2cuda_temp_315));
#line 685 "ProbabilityModule.cs"
                int* csharp2cuda_temp_312 = &(index);
                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_312));
            }
        }
#line 687 "ProbabilityModule.cs"
#line 687 "ProbabilityModule.cs"
        double* csharp2cuda_temp_316 = &((output)->scalar_value);
        (*(csharp2cuda_temp_316) = value);
#line 688 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 688 "ProbabilityModule.cs"
#line 688 "ProbabilityModule.cs"
            int* csharp2cuda_temp_317 = &((output)->valid);
            (*(csharp2cuda_temp_317) = 0);
        }
#line 689 "ProbabilityModule.cs"
        return;
    }
#line 692 "ProbabilityModule.cs"
    if (((opcode) == (22)))
#line 693 "ProbabilityModule.cs"
    {
#line 694 "ProbabilityModule.cs"
#line 694 "ProbabilityModule.cs"
        int csharp2cuda_temp_318 = (first)->count;
        if (((csharp2cuda_temp_318) <= (0)))
#line 695 "ProbabilityModule.cs"
        {
#line 696 "ProbabilityModule.cs"
#line 696 "ProbabilityModule.cs"
            int* csharp2cuda_temp_319 = &((output)->valid);
            (*(csharp2cuda_temp_319) = 0);
#line 697 "ProbabilityModule.cs"
            return;
        }
#line 699 "ProbabilityModule.cs"
        double maximum = (a)[0];
#line 700 "ProbabilityModule.cs"
        {
#line 700 "ProbabilityModule.cs"
            int index = 1;
            while (true)
            {
#line 700 "ProbabilityModule.cs"
                int csharp2cuda_temp_321 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_321))))
                    break;
#line 701 "ProbabilityModule.cs"
#line 701 "ProbabilityModule.cs"
                double* csharp2cuda_temp_322 = &(maximum);
#line 701 "ProbabilityModule.cs"
                double csharp2cuda_temp_323 = (a)[index];
                (*(csharp2cuda_temp_322) = mathblocks_maximum(maximum, csharp2cuda_temp_323));
#line 700 "ProbabilityModule.cs"
                int* csharp2cuda_temp_320 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_320));
            }
        }
#line 702 "ProbabilityModule.cs"
        double sum = 0.0;
#line 703 "ProbabilityModule.cs"
        {
#line 703 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
#line 703 "ProbabilityModule.cs"
                int csharp2cuda_temp_325 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_325))))
                    break;
#line 704 "ProbabilityModule.cs"
#line 704 "ProbabilityModule.cs"
                double* csharp2cuda_temp_326 = &(sum);
#line 704 "ProbabilityModule.cs"
                double csharp2cuda_temp_327 = *(csharp2cuda_temp_326);
#line 704 "ProbabilityModule.cs"
                double csharp2cuda_temp_328 = (a)[index];
                (*(csharp2cuda_temp_326) = __dadd_rn(csharp2cuda_temp_327, mathblocks_exponential(__dsub_rn(csharp2cuda_temp_328, maximum))));
#line 703 "ProbabilityModule.cs"
                int* csharp2cuda_temp_324 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_324));
            }
        }
#line 705 "ProbabilityModule.cs"
#line 705 "ProbabilityModule.cs"
        double* csharp2cuda_temp_329 = &((output)->scalar_value);
        (*(csharp2cuda_temp_329) = __dadd_rn(maximum, mathblocks_natural_logarithm(sum)));
#line 706 "ProbabilityModule.cs"
#line 706 "ProbabilityModule.cs"
        double csharp2cuda_temp_330 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_330))))
        {
#line 706 "ProbabilityModule.cs"
#line 706 "ProbabilityModule.cs"
            int* csharp2cuda_temp_331 = &((output)->valid);
            (*(csharp2cuda_temp_331) = 0);
        }
#line 707 "ProbabilityModule.cs"
        return;
    }
#line 710 "ProbabilityModule.cs"
    if (((opcode) == (23)))
#line 711 "ProbabilityModule.cs"
    {
#line 712 "ProbabilityModule.cs"
#line 712 "ProbabilityModule.cs"
        double* csharp2cuda_temp_332 = &((output)->scalar_value);
#line 713 "ProbabilityModule.cs"
        double csharp2cuda_temp_333 = (first)->scalar_value;
#line 713 "ProbabilityModule.cs"
        double csharp2cuda_temp_334 = __ddiv_rn(csharp2cuda_temp_333, mathblocks_square_root(2.0));
        (*(csharp2cuda_temp_332) = __dmul_rn(0.5, __dadd_rn(1.0, mathblocks_error_function(csharp2cuda_temp_334))));
#line 714 "ProbabilityModule.cs"
#line 714 "ProbabilityModule.cs"
        double csharp2cuda_temp_335 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_335))))
        {
#line 714 "ProbabilityModule.cs"
#line 714 "ProbabilityModule.cs"
            int* csharp2cuda_temp_336 = &((output)->valid);
            (*(csharp2cuda_temp_336) = 0);
        }
#line 715 "ProbabilityModule.cs"
        return;
    }
#line 718 "ProbabilityModule.cs"
#line 718 "ProbabilityModule.cs"
    bool csharp2cuda_temp_337;
#line 718 "ProbabilityModule.cs"
    if (!(((opcode) == (25))))
    {
#line 718 "ProbabilityModule.cs"
        csharp2cuda_temp_337 = ((opcode) == (26));
    }
    else
    {
#line 718 "ProbabilityModule.cs"
        csharp2cuda_temp_337 = true;
    }
    if (csharp2cuda_temp_337)
#line 719 "ProbabilityModule.cs"
    {
#line 720 "ProbabilityModule.cs"
        int count = 0;
#line 721 "ProbabilityModule.cs"
        double rate = (first)->scalar_value;
#line 722 "ProbabilityModule.cs"
#line 722 "ProbabilityModule.cs"
        double csharp2cuda_temp_338 = (second)->scalar_value;
#line 722 "ProbabilityModule.cs"
        int* csharp2cuda_temp_339 = &(count);
#line 722 "ProbabilityModule.cs"
        bool csharp2cuda_temp_340 = mathblocks_probability_integer(csharp2cuda_temp_338, csharp2cuda_temp_339);
#line 722 "ProbabilityModule.cs"
        bool csharp2cuda_temp_341;
#line 722 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_340))))
        {
#line 722 "ProbabilityModule.cs"
            csharp2cuda_temp_341 = ((count) < (0));
        }
        else
        {
#line 722 "ProbabilityModule.cs"
            csharp2cuda_temp_341 = true;
        }
#line 722 "ProbabilityModule.cs"
        bool csharp2cuda_temp_342;
#line 722 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_341))
        {
#line 722 "ProbabilityModule.cs"
            csharp2cuda_temp_342 = ((rate) < (0.0));
        }
        else
        {
#line 722 "ProbabilityModule.cs"
            csharp2cuda_temp_342 = true;
        }
        if (csharp2cuda_temp_342)
#line 723 "ProbabilityModule.cs"
        {
#line 724 "ProbabilityModule.cs"
#line 724 "ProbabilityModule.cs"
            int* csharp2cuda_temp_343 = &((output)->valid);
            (*(csharp2cuda_temp_343) = 0);
#line 725 "ProbabilityModule.cs"
            return;
        }
#line 727 "ProbabilityModule.cs"
        double value = 0.0;
#line 728 "ProbabilityModule.cs"
        int csharp2cuda_temp_344;
#line 728 "ProbabilityModule.cs"
        if (((opcode) == (25)))
        {
#line 728 "ProbabilityModule.cs"
            csharp2cuda_temp_344 = 0;
        }
        else
        {
#line 728 "ProbabilityModule.cs"
            csharp2cuda_temp_344 = count;
        }
#line 728 "ProbabilityModule.cs"
        int start = csharp2cuda_temp_344;
#line 729 "ProbabilityModule.cs"
        int end = count;
#line 730 "ProbabilityModule.cs"
        {
#line 730 "ProbabilityModule.cs"
            int index = start;
            while (true)
            {
                if (!(((index) <= (end))))
                    break;
#line 731 "ProbabilityModule.cs"
                {
#line 732 "ProbabilityModule.cs"
                    double csharp2cuda_temp_346;
#line 732 "ProbabilityModule.cs"
                    if (((rate) == (0.0)))
                    {
#line 733 "ProbabilityModule.cs"
                        double csharp2cuda_temp_347;
#line 733 "ProbabilityModule.cs"
                        if (((index) == (0)))
                        {
#line 733 "ProbabilityModule.cs"
                            csharp2cuda_temp_347 = 1.0;
                        }
                        else
                        {
#line 733 "ProbabilityModule.cs"
                            csharp2cuda_temp_347 = 0.0;
                        }
#line 732 "ProbabilityModule.cs"
                        csharp2cuda_temp_346 = csharp2cuda_temp_347;
                    }
                    else
                    {
#line 732 "ProbabilityModule.cs"
                        csharp2cuda_temp_346 = mathblocks_exponential(__dsub_rn(__dadd_rn((-(rate)), __dmul_rn(((double)(index)), mathblocks_natural_logarithm(rate))), mathblocks_probability_log_gamma(__dadd_rn(((double)(index)), 1.0))));
                    }
#line 732 "ProbabilityModule.cs"
                    double probability = csharp2cuda_temp_346;
#line 737 "ProbabilityModule.cs"
#line 737 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_348 = &(value);
#line 737 "ProbabilityModule.cs"
                    double csharp2cuda_temp_349 = *(csharp2cuda_temp_348);
                    (*(csharp2cuda_temp_348) = __dadd_rn(csharp2cuda_temp_349, probability));
                }
#line 730 "ProbabilityModule.cs"
                int* csharp2cuda_temp_345 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_345));
            }
        }
#line 739 "ProbabilityModule.cs"
#line 739 "ProbabilityModule.cs"
        double* csharp2cuda_temp_350 = &((output)->scalar_value);
        (*(csharp2cuda_temp_350) = value);
#line 740 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 740 "ProbabilityModule.cs"
#line 740 "ProbabilityModule.cs"
            int* csharp2cuda_temp_351 = &((output)->valid);
            (*(csharp2cuda_temp_351) = 0);
        }
#line 741 "ProbabilityModule.cs"
        return;
    }
#line 744 "ProbabilityModule.cs"
    if (((opcode) == (28)))
#line 745 "ProbabilityModule.cs"
    {
#line 746 "ProbabilityModule.cs"
#line 746 "ProbabilityModule.cs"
        double* csharp2cuda_temp_352 = &((output)->scalar_value);
#line 747 "ProbabilityModule.cs"
        double csharp2cuda_temp_353 = (first)->scalar_value;
#line 748 "ProbabilityModule.cs"
        double csharp2cuda_temp_354 = (second)->scalar_value;
#line 749 "ProbabilityModule.cs"
        double csharp2cuda_temp_355 = (first)->scalar_value;
#line 749 "ProbabilityModule.cs"
        double csharp2cuda_temp_356 = (second)->scalar_value;
        (*(csharp2cuda_temp_352) = mathblocks_exponential(__dsub_rn(__dadd_rn(mathblocks_probability_log_gamma(csharp2cuda_temp_353), mathblocks_probability_log_gamma(csharp2cuda_temp_354)), mathblocks_probability_log_gamma(__dadd_rn(csharp2cuda_temp_355, csharp2cuda_temp_356)))));
    }
    else
    {
#line 751 "ProbabilityModule.cs"
        if (((opcode) == (29)))
#line 752 "ProbabilityModule.cs"
        {
#line 753 "ProbabilityModule.cs"
#line 753 "ProbabilityModule.cs"
            double* csharp2cuda_temp_357 = &((output)->scalar_value);
#line 753 "ProbabilityModule.cs"
            double csharp2cuda_temp_358 = (first)->scalar_value;
            (*(csharp2cuda_temp_357) = mathblocks_probability_log_gamma(csharp2cuda_temp_358));
        }
        else
        {
#line 755 "ProbabilityModule.cs"
            if (((opcode) == (30)))
#line 756 "ProbabilityModule.cs"
            {
#line 757 "ProbabilityModule.cs"
                double x = (first)->scalar_value;
#line 758 "ProbabilityModule.cs"
                double left = (second)->scalar_value;
#line 759 "ProbabilityModule.cs"
                double right = (third)->scalar_value;
#line 760 "ProbabilityModule.cs"
#line 760 "ProbabilityModule.cs"
                bool csharp2cuda_temp_359;
#line 760 "ProbabilityModule.cs"
                if (!(((x) < (0.0))))
                {
#line 760 "ProbabilityModule.cs"
                    csharp2cuda_temp_359 = ((x) > (1.0));
                }
                else
                {
#line 760 "ProbabilityModule.cs"
                    csharp2cuda_temp_359 = true;
                }
#line 760 "ProbabilityModule.cs"
                bool csharp2cuda_temp_360;
#line 760 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_359))
                {
#line 760 "ProbabilityModule.cs"
                    csharp2cuda_temp_360 = ((left) <= (0.0));
                }
                else
                {
#line 760 "ProbabilityModule.cs"
                    csharp2cuda_temp_360 = true;
                }
#line 760 "ProbabilityModule.cs"
                bool csharp2cuda_temp_361;
#line 760 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_360))
                {
#line 760 "ProbabilityModule.cs"
                    csharp2cuda_temp_361 = ((right) <= (0.0));
                }
                else
                {
#line 760 "ProbabilityModule.cs"
                    csharp2cuda_temp_361 = true;
                }
                if (csharp2cuda_temp_361)
#line 761 "ProbabilityModule.cs"
                {
#line 762 "ProbabilityModule.cs"
#line 762 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_362 = &((output)->valid);
                    (*(csharp2cuda_temp_362) = 0);
#line 763 "ProbabilityModule.cs"
                    return;
                }
#line 765 "ProbabilityModule.cs"
#line 765 "ProbabilityModule.cs"
                double* csharp2cuda_temp_363 = &((output)->scalar_value);
                (*(csharp2cuda_temp_363) = mathblocks_probability_incomplete_beta(x, left, right));
            }
        }
    }
#line 767 "ProbabilityModule.cs"
#line 767 "ProbabilityModule.cs"
    double csharp2cuda_temp_364 = (output)->scalar_value;
    if ((!(isfinite(csharp2cuda_temp_364))))
    {
#line 767 "ProbabilityModule.cs"
#line 767 "ProbabilityModule.cs"
        int* csharp2cuda_temp_365 = &((output)->valid);
        (*(csharp2cuda_temp_365) = 0);
    }
}

#line 123 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const double* values, int count)
#line 125 "ProbabilityModule.cs"
{
#line 126 "ProbabilityModule.cs"
    if (((count) <= (0)))
    {
#line 127 "ProbabilityModule.cs"
        return false;
    }
#line 128 "ProbabilityModule.cs"
    {
#line 128 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 129 "ProbabilityModule.cs"
#line 129 "ProbabilityModule.cs"
            double csharp2cuda_temp_1 = (values)[index];
            if (((csharp2cuda_temp_1) < (0.0)))
            {
#line 129 "ProbabilityModule.cs"
                return false;
            }
#line 128 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 130 "ProbabilityModule.cs"
    return ((fabs(__dsub_rn(mathblocks_compensated_sum(values, count), 1.0))) <= (1E-10));
}

#line 133 "ProbabilityModule.cs"
__device__ double mathblocks_probability_entropy(const double* values, int count)
#line 135 "ProbabilityModule.cs"
{
#line 136 "ProbabilityModule.cs"
    double entropy = 0.0;
#line 137 "ProbabilityModule.cs"
    {
#line 137 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 138 "ProbabilityModule.cs"
#line 138 "ProbabilityModule.cs"
            double csharp2cuda_temp_1 = (values)[index];
            if (((csharp2cuda_temp_1) > (0.0)))
            {
#line 139 "ProbabilityModule.cs"
#line 139 "ProbabilityModule.cs"
                double* csharp2cuda_temp_2 = &(entropy);
#line 139 "ProbabilityModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 139 "ProbabilityModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
#line 139 "ProbabilityModule.cs"
                double csharp2cuda_temp_5 = (values)[index];
                (*(csharp2cuda_temp_2) = __dsub_rn(csharp2cuda_temp_3, __dmul_rn(csharp2cuda_temp_4, mathblocks_natural_logarithm(csharp2cuda_temp_5))));
            }
#line 137 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 140 "ProbabilityModule.cs"
    return entropy;
}

#line 235 "ProbabilityModule.cs"
__device__ double mathblocks_probability_incomplete_beta(
    double x,
    double left,
    double right)
#line 240 "ProbabilityModule.cs"
{
#line 241 "ProbabilityModule.cs"
    if (((x) == (0.0)))
    {
#line 241 "ProbabilityModule.cs"
        return 0.0;
    }
#line 242 "ProbabilityModule.cs"
    if (((x) == (1.0)))
    {
#line 242 "ProbabilityModule.cs"
        return 1.0;
    }
#line 243 "ProbabilityModule.cs"
    double front = mathblocks_exponential(__dadd_rn(__dadd_rn(__dsub_rn(__dsub_rn(mathblocks_probability_log_gamma(__dadd_rn(left, right)), mathblocks_probability_log_gamma(left)), mathblocks_probability_log_gamma(right)), __dmul_rn(left, mathblocks_natural_logarithm(x))), __dmul_rn(right, mathblocks_log_one_plus((-(x))))));
#line 249 "ProbabilityModule.cs"
#line 249 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = __ddiv_rn(__dadd_rn(left, 1.0), __dadd_rn(__dadd_rn(left, right), 2.0));
#line 249 "ProbabilityModule.cs"
    double csharp2cuda_temp_1;
#line 249 "ProbabilityModule.cs"
    if (((x) < (csharp2cuda_temp_0)))
    {
#line 249 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = __ddiv_rn(__dmul_rn(front, mathblocks_probability_beta_fraction(x, left, right)), left);
    }
    else
    {
#line 251 "ProbabilityModule.cs"
        double csharp2cuda_temp_2 = __ddiv_rn(__dmul_rn(front, mathblocks_probability_beta_fraction(__dsub_rn(1.0, x), right, left)), right);
#line 249 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = __dsub_rn(1.0, csharp2cuda_temp_2);
    }
    return csharp2cuda_temp_1;
}

#line 101 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_integer(double value, int* result)
#line 103 "ProbabilityModule.cs"
{
#line 104 "ProbabilityModule.cs"
#line 104 "ProbabilityModule.cs"
    bool csharp2cuda_temp_0;
#line 104 "ProbabilityModule.cs"
    if (!(((value) < ((-(2147483648.0))))))
    {
#line 104 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((value) > (2147483647.0));
    }
    else
    {
#line 104 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 104 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 104 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 104 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((value) != (trunc(value)));
    }
    else
    {
#line 104 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 105 "ProbabilityModule.cs"
        return false;
    }
#line 106 "ProbabilityModule.cs"
#line 106 "ProbabilityModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 107 "ProbabilityModule.cs"
    return true;
}

#line 143 "ProbabilityModule.cs"
__device__ double mathblocks_probability_kl(
    const double* probabilities,
    const double* reference,
    int count)
#line 148 "ProbabilityModule.cs"
{
#line 149 "ProbabilityModule.cs"
    double result = 0.0;
#line 150 "ProbabilityModule.cs"
    {
#line 150 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 151 "ProbabilityModule.cs"
#line 151 "ProbabilityModule.cs"
            double csharp2cuda_temp_1 = (probabilities)[index];
            if (((csharp2cuda_temp_1) > (0.0)))
            {
#line 152 "ProbabilityModule.cs"
#line 152 "ProbabilityModule.cs"
                double* csharp2cuda_temp_2 = &(result);
#line 152 "ProbabilityModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
#line 152 "ProbabilityModule.cs"
                double csharp2cuda_temp_4 = (probabilities)[index];
#line 153 "ProbabilityModule.cs"
                double csharp2cuda_temp_5 = (probabilities)[index];
#line 153 "ProbabilityModule.cs"
                double csharp2cuda_temp_6 = (reference)[index];
#line 153 "ProbabilityModule.cs"
                double csharp2cuda_temp_7 = __ddiv_rn(csharp2cuda_temp_5, csharp2cuda_temp_6);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, __dmul_rn(csharp2cuda_temp_4, mathblocks_natural_logarithm(csharp2cuda_temp_7))));
            }
#line 150 "ProbabilityModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 154 "ProbabilityModule.cs"
    return result;
}

#line 182 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma(double value)
#line 184 "ProbabilityModule.cs"
{
#line 185 "ProbabilityModule.cs"
    if (((value) < (0.5)))
#line 186 "ProbabilityModule.cs"
    {
#line 187 "ProbabilityModule.cs"
        return __dsub_rn(__dsub_rn(mathblocks_natural_logarithm(3.141592653589793), mathblocks_natural_logarithm(mathblocks_sine(__dmul_rn(3.141592653589793, value)))), mathblocks_probability_log_gamma_core(__dsub_rn(1.0, value)));
    }
#line 192 "ProbabilityModule.cs"
    return mathblocks_probability_log_gamma_core(value);
}

#line 157 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma_core(double value)
#line 159 "ProbabilityModule.cs"
{
#line 160 "ProbabilityModule.cs"
    const double csharp2cuda_temp_0_storage[8] = { 676.5203681218851, -1259.1392167224028, 771.3234287776531, -176.6150291621406, 12.507343278686905, -0.13857109526572012, 9.984369578019572E-06, 1.5056327351493116E-07 };
    csharp2cuda_readonly_array_view<double> coefficients(csharp2cuda_temp_0_storage, 8, false);
#line 171 "ProbabilityModule.cs"
#line 171 "ProbabilityModule.cs"
    double* csharp2cuda_temp_1 = &(value);
#line 171 "ProbabilityModule.cs"
    double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
    (*(csharp2cuda_temp_1) = __dsub_rn(csharp2cuda_temp_2, 1.0));
#line 172 "ProbabilityModule.cs"
    double sum = 0.9999999999998099;
#line 173 "ProbabilityModule.cs"
    {
#line 173 "ProbabilityModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (8))))
                break;
#line 174 "ProbabilityModule.cs"
#line 174 "ProbabilityModule.cs"
            double* csharp2cuda_temp_4 = &(sum);
#line 174 "ProbabilityModule.cs"
            double csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
#line 174 "ProbabilityModule.cs"
            double csharp2cuda_temp_6 = (coefficients)[index];
#line 174 "ProbabilityModule.cs"
            double csharp2cuda_temp_7 = __ddiv_rn(csharp2cuda_temp_6, __dadd_rn(__dadd_rn(value, ((double)(index))), 1.0));
            (*(csharp2cuda_temp_4) = __dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_7));
#line 173 "ProbabilityModule.cs"
            int* csharp2cuda_temp_3 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
        }
    }
#line 175 "ProbabilityModule.cs"
    double t = __dadd_rn(value, 7.5);
#line 176 "ProbabilityModule.cs"
    return __dadd_rn(__dsub_rn(__dadd_rn(__dmul_rn(0.5, mathblocks_natural_logarithm(__dmul_rn(2.0, 3.141592653589793))), __dmul_rn(__dadd_rn(value, 0.5), mathblocks_natural_logarithm(t))), t), mathblocks_natural_logarithm(sum));
}