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

#line 197 "ProbabilityModule.cs"
__device__ double mathblocks_probability_beta_fraction(double x, double left, double right);

#line 110 "ProbabilityModule.cs"
__device__ double mathblocks_probability_binomial(int n, int k);

#line 256 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value);

#line 385 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 123 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_distribution(const double* values, int count);

#line 133 "ProbabilityModule.cs"
__device__ double mathblocks_probability_entropy(const double* values, int count);

#line 237 "ProbabilityModule.cs"
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

#line 184 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma(double value);

#line 157 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma_core(double value);

#line 269 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_ordered_entropy_value(
    const double* values,
    int count,
    double order,
    bool renyi,
    double* value);

#line 299 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_scalar_value(int opcode, double a, double b, double c, double* value);

#line 197 "ProbabilityModule.cs"
__device__ double mathblocks_probability_beta_fraction(double x, double left, double right)
#line 199 "ProbabilityModule.cs"
{
#line 200 "ProbabilityModule.cs"
    const int maximum_iterations = 256;
#line 201 "ProbabilityModule.cs"
    const double tolerance = 3E-14;
#line 202 "ProbabilityModule.cs"
    const double minimum = 1E-300;
#line 203 "ProbabilityModule.cs"
    double qab = __dadd_rn(left, right);
#line 204 "ProbabilityModule.cs"
    double qap = __dadd_rn(left, 1.0);
#line 205 "ProbabilityModule.cs"
    double qam = __dsub_rn(left, 1.0);
#line 206 "ProbabilityModule.cs"
    double c = 1.0;
#line 207 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = __ddiv_rn(__dmul_rn(qab, x), qap);
#line 207 "ProbabilityModule.cs"
    double d = __dsub_rn(1.0, csharp2cuda_temp_0);
#line 208 "ProbabilityModule.cs"
    if (((fabs(d)) < (minimum)))
    {
#line 208 "ProbabilityModule.cs"
#line 208 "ProbabilityModule.cs"
        double* csharp2cuda_temp_1 = &(d);
        (*(csharp2cuda_temp_1) = minimum);
    }
#line 209 "ProbabilityModule.cs"
#line 209 "ProbabilityModule.cs"
    double* csharp2cuda_temp_2 = &(d);
#line 209 "ProbabilityModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(1.0, d);
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 210 "ProbabilityModule.cs"
    double result = d;
#line 211 "ProbabilityModule.cs"
    {
#line 211 "ProbabilityModule.cs"
        int iteration = 1;
        while (true)
        {
            if (!(((iteration) <= (maximum_iterations))))
                break;
#line 212 "ProbabilityModule.cs"
            {
#line 213 "ProbabilityModule.cs"
                double doubled = __dmul_rn(2.0, ((double)(iteration)));
#line 214 "ProbabilityModule.cs"
                double coefficient = __ddiv_rn(__dmul_rn(__dmul_rn(((double)(iteration)), __dsub_rn(right, ((double)(iteration)))), x), __dmul_rn(__dadd_rn(qam, doubled), __dadd_rn(left, doubled)));
#line 216 "ProbabilityModule.cs"
#line 216 "ProbabilityModule.cs"
                double* csharp2cuda_temp_5 = &(d);
                (*(csharp2cuda_temp_5) = __dadd_rn(1.0, __dmul_rn(coefficient, d)));
#line 217 "ProbabilityModule.cs"
                if (((fabs(d)) < (minimum)))
                {
#line 217 "ProbabilityModule.cs"
#line 217 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_6 = &(d);
                    (*(csharp2cuda_temp_6) = minimum);
                }
#line 218 "ProbabilityModule.cs"
#line 218 "ProbabilityModule.cs"
                double* csharp2cuda_temp_7 = &(c);
#line 218 "ProbabilityModule.cs"
                double csharp2cuda_temp_8 = __ddiv_rn(coefficient, c);
                (*(csharp2cuda_temp_7) = __dadd_rn(1.0, csharp2cuda_temp_8));
#line 219 "ProbabilityModule.cs"
                if (((fabs(c)) < (minimum)))
                {
#line 219 "ProbabilityModule.cs"
#line 219 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_9 = &(c);
                    (*(csharp2cuda_temp_9) = minimum);
                }
#line 220 "ProbabilityModule.cs"
#line 220 "ProbabilityModule.cs"
                double* csharp2cuda_temp_10 = &(d);
#line 220 "ProbabilityModule.cs"
                double csharp2cuda_temp_11 = __ddiv_rn(1.0, d);
                (*(csharp2cuda_temp_10) = csharp2cuda_temp_11);
#line 221 "ProbabilityModule.cs"
#line 221 "ProbabilityModule.cs"
                double* csharp2cuda_temp_12 = &(result);
#line 221 "ProbabilityModule.cs"
                double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
                (*(csharp2cuda_temp_12) = __dmul_rn(csharp2cuda_temp_13, __dmul_rn(d, c)));
#line 222 "ProbabilityModule.cs"
#line 222 "ProbabilityModule.cs"
                double* csharp2cuda_temp_14 = &(coefficient);
#line 222 "ProbabilityModule.cs"
                double csharp2cuda_temp_15 = __ddiv_rn(__dmul_rn(__dmul_rn((-(__dadd_rn(left, ((double)(iteration))))), __dadd_rn(qab, ((double)(iteration)))), x), __dmul_rn(__dadd_rn(left, doubled), __dadd_rn(qap, doubled)));
                (*(csharp2cuda_temp_14) = csharp2cuda_temp_15);
#line 224 "ProbabilityModule.cs"
#line 224 "ProbabilityModule.cs"
                double* csharp2cuda_temp_16 = &(d);
                (*(csharp2cuda_temp_16) = __dadd_rn(1.0, __dmul_rn(coefficient, d)));
#line 225 "ProbabilityModule.cs"
                if (((fabs(d)) < (minimum)))
                {
#line 225 "ProbabilityModule.cs"
#line 225 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_17 = &(d);
                    (*(csharp2cuda_temp_17) = minimum);
                }
#line 226 "ProbabilityModule.cs"
#line 226 "ProbabilityModule.cs"
                double* csharp2cuda_temp_18 = &(c);
#line 226 "ProbabilityModule.cs"
                double csharp2cuda_temp_19 = __ddiv_rn(coefficient, c);
                (*(csharp2cuda_temp_18) = __dadd_rn(1.0, csharp2cuda_temp_19));
#line 227 "ProbabilityModule.cs"
                if (((fabs(c)) < (minimum)))
                {
#line 227 "ProbabilityModule.cs"
#line 227 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_20 = &(c);
                    (*(csharp2cuda_temp_20) = minimum);
                }
#line 228 "ProbabilityModule.cs"
#line 228 "ProbabilityModule.cs"
                double* csharp2cuda_temp_21 = &(d);
#line 228 "ProbabilityModule.cs"
                double csharp2cuda_temp_22 = __ddiv_rn(1.0, d);
                (*(csharp2cuda_temp_21) = csharp2cuda_temp_22);
#line 229 "ProbabilityModule.cs"
                double delta = __dmul_rn(d, c);
#line 230 "ProbabilityModule.cs"
#line 230 "ProbabilityModule.cs"
                double* csharp2cuda_temp_23 = &(result);
#line 230 "ProbabilityModule.cs"
                double csharp2cuda_temp_24 = *(csharp2cuda_temp_23);
                (*(csharp2cuda_temp_23) = __dmul_rn(csharp2cuda_temp_24, delta));
#line 231 "ProbabilityModule.cs"
                if (((fabs(__dsub_rn(delta, 1.0))) <= (tolerance)))
                {
#line 232 "ProbabilityModule.cs"
                    break;
                }
            }
#line 211 "ProbabilityModule.cs"
            int* csharp2cuda_temp_4 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 234 "ProbabilityModule.cs"
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

#line 256 "ProbabilityModule.cs"
__device__ MathBlockComplexValue mathblocks_probability_complex_cube_root(
    MathBlockComplexValue value)
#line 259 "ProbabilityModule.cs"
{
#line 260 "ProbabilityModule.cs"
#line 260 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = (value).real;
#line 260 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 260 "ProbabilityModule.cs"
    if (((csharp2cuda_temp_0) == (0.0)))
    {
#line 260 "ProbabilityModule.cs"
        double csharp2cuda_temp_2 = (value).imaginary;
#line 260 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) == (0.0));
    }
    else
    {
#line 260 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 261 "ProbabilityModule.cs"
        return mathblocks_complex_make(0.0, 0.0);
    }
#line 262 "ProbabilityModule.cs"
#line 264 "ProbabilityModule.cs"
    double csharp2cuda_temp_3 = __ddiv_rn(mathblocks_complex_phase(value), 3.0);
    return mathblocks_complex_from_polar(mathblocks_cube_root(mathblocks_complex_magnitude(value)), csharp2cuda_temp_3);
}

#line 385 "ProbabilityModule.cs"
__device__ void mathblocks_probability_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 391 "ProbabilityModule.cs"
{
#line 392 "ProbabilityModule.cs"
    int thread = threadIdx.x;
#line 393 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 393 "ProbabilityModule.cs"
    if (((input_count) > (0)))
    {
#line 393 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 393 "ProbabilityModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 393 "ProbabilityModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 394 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 394 "ProbabilityModule.cs"
    if (((input_count) > (1)))
    {
#line 394 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 394 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 394 "ProbabilityModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 395 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 395 "ProbabilityModule.cs"
    if (((input_count) > (2)))
    {
#line 395 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 395 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 395 "ProbabilityModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 396 "ProbabilityModule.cs"
    MathBlockSlot* csharp2cuda_temp_3;
#line 396 "ProbabilityModule.cs"
    if (((input_count) > (3)))
    {
#line 396 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = (inputs)[3];
    }
    else
    {
#line 396 "ProbabilityModule.cs"
        csharp2cuda_temp_3 = ((MathBlockSlot*)(nullptr));
    }
#line 396 "ProbabilityModule.cs"
    const MathBlockSlot* fourth = csharp2cuda_temp_3;
#line 397 "ProbabilityModule.cs"
    if (((thread) == (0)))
#line 398 "ProbabilityModule.cs"
    {
#line 399 "ProbabilityModule.cs"
#line 399 "ProbabilityModule.cs"
        double* csharp2cuda_temp_4 = &((output)->scalar_value);
        (*(csharp2cuda_temp_4) = 0.0);
#line 400 "ProbabilityModule.cs"
#line 400 "ProbabilityModule.cs"
        int* csharp2cuda_temp_5 = &((output)->boolean_value);
        (*(csharp2cuda_temp_5) = 0);
#line 401 "ProbabilityModule.cs"
#line 401 "ProbabilityModule.cs"
        int* csharp2cuda_temp_6 = &((output)->rows);
        (*(csharp2cuda_temp_6) = 0);
#line 402 "ProbabilityModule.cs"
#line 402 "ProbabilityModule.cs"
        int* csharp2cuda_temp_7 = &((output)->columns);
        (*(csharp2cuda_temp_7) = 0);
#line 403 "ProbabilityModule.cs"
#line 403 "ProbabilityModule.cs"
        int* csharp2cuda_temp_8 = &((output)->count);
        (*(csharp2cuda_temp_8) = 0);
#line 404 "ProbabilityModule.cs"
#line 404 "ProbabilityModule.cs"
        int* csharp2cuda_temp_9 = &((output)->valid);
        (*(csharp2cuda_temp_9) = 1);
#line 405 "ProbabilityModule.cs"
        {
#line 405 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 406 "ProbabilityModule.cs"
#line 406 "ProbabilityModule.cs"
                MathBlockSlot* csharp2cuda_temp_11 = (inputs)[index];
#line 406 "ProbabilityModule.cs"
                bool csharp2cuda_temp_12;
#line 406 "ProbabilityModule.cs"
                if (!(((((void*)(csharp2cuda_temp_11))) == (((void*)(nullptr))))))
                {
#line 406 "ProbabilityModule.cs"
                    MathBlockSlot* csharp2cuda_temp_13 = (inputs)[index];
#line 406 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_14 = (csharp2cuda_temp_13)->valid;
#line 406 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = (!(csharp2cuda_temp_14));
                }
                else
                {
#line 406 "ProbabilityModule.cs"
                    csharp2cuda_temp_12 = true;
                }
                if (csharp2cuda_temp_12)
                {
#line 406 "ProbabilityModule.cs"
#line 406 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_15 = &((output)->valid);
                    (*(csharp2cuda_temp_15) = 0);
                }
#line 405 "ProbabilityModule.cs"
                int* csharp2cuda_temp_10 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_10));
            }
        }
    }
#line 408 "ProbabilityModule.cs"
    __syncthreads();
#line 409 "ProbabilityModule.cs"
#line 409 "ProbabilityModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 410 "ProbabilityModule.cs"
        return;
    }
#line 412 "ProbabilityModule.cs"
    double* csharp2cuda_temp_17;
#line 412 "ProbabilityModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 412 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 412 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 412 "ProbabilityModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 412 "ProbabilityModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 413 "ProbabilityModule.cs"
    double* csharp2cuda_temp_19;
#line 413 "ProbabilityModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 413 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 413 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 413 "ProbabilityModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 413 "ProbabilityModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 414 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_21 = (output)->data_pointer;
#line 414 "ProbabilityModule.cs"
    double* result = ((double*)(csharp2cuda_temp_21));
#line 415 "ProbabilityModule.cs"
    unsigned long long csharp2cuda_temp_22 = (output)->scratch_pointer;
#line 415 "ProbabilityModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_22));
#line 417 "ProbabilityModule.cs"
    if (((opcode) == (3)))
#line 418 "ProbabilityModule.cs"
    {
#line 419 "ProbabilityModule.cs"
        if (((thread) == (0)))
#line 420 "ProbabilityModule.cs"
        {
#line 421 "ProbabilityModule.cs"
#line 421 "ProbabilityModule.cs"
            int csharp2cuda_temp_23 = (first)->count;
            if (((csharp2cuda_temp_23) > (20)))
#line 422 "ProbabilityModule.cs"
            {
#line 423 "ProbabilityModule.cs"
#line 423 "ProbabilityModule.cs"
                int* csharp2cuda_temp_24 = &((output)->valid);
                (*(csharp2cuda_temp_24) = 0);
#line 424 "ProbabilityModule.cs"
                return;
            }
#line 426 "ProbabilityModule.cs"
#line 426 "ProbabilityModule.cs"
            int csharp2cuda_temp_25 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_i32_shl(1, csharp2cuda_temp_25), 1));
        }
#line 428 "ProbabilityModule.cs"
        __syncthreads();
#line 429 "ProbabilityModule.cs"
        {
#line 429 "ProbabilityModule.cs"
            int mask = csharp2cuda_i32_add(thread, 1);
            while (true)
            {
#line 429 "ProbabilityModule.cs"
                bool csharp2cuda_temp_28 = (output)->valid;
#line 429 "ProbabilityModule.cs"
                bool csharp2cuda_temp_29;
#line 429 "ProbabilityModule.cs"
                if (csharp2cuda_temp_28)
                {
#line 429 "ProbabilityModule.cs"
                    int csharp2cuda_temp_30 = (output)->count;
#line 429 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = ((mask) <= (csharp2cuda_temp_30));
                }
                else
                {
#line 429 "ProbabilityModule.cs"
                    csharp2cuda_temp_29 = false;
                }
                if (!(csharp2cuda_temp_29))
                    break;
#line 430 "ProbabilityModule.cs"
                {
#line 431 "ProbabilityModule.cs"
                    double sum = 0.0;
#line 432 "ProbabilityModule.cs"
                    {
#line 432 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 432 "ProbabilityModule.cs"
                            int csharp2cuda_temp_32 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_32))))
                                break;
#line 433 "ProbabilityModule.cs"
                            if (((csharp2cuda_i32_and(mask, csharp2cuda_i32_shl(1, index))) != (0)))
                            {
#line 433 "ProbabilityModule.cs"
#line 433 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_33 = &(sum);
#line 433 "ProbabilityModule.cs"
                                double csharp2cuda_temp_34 = *(csharp2cuda_temp_33);
#line 433 "ProbabilityModule.cs"
                                double csharp2cuda_temp_35 = (a)[index];
                                (*(csharp2cuda_temp_33) = __dadd_rn(csharp2cuda_temp_34, csharp2cuda_temp_35));
                            }
#line 432 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_31 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                        }
                    }
#line 434 "ProbabilityModule.cs"
#line 434 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_36 = &((result)[csharp2cuda_i32_sub(mask, 1)]);
                    (*(csharp2cuda_temp_36) = sum);
#line 435 "ProbabilityModule.cs"
                    if ((!(isfinite(sum))))
                    {
#line 435 "ProbabilityModule.cs"
                        atomicExch(&((output)->valid), 0);
                    }
                }
#line 429 "ProbabilityModule.cs"
                int* csharp2cuda_temp_26 = &(mask);
#line 429 "ProbabilityModule.cs"
                int csharp2cuda_temp_27 = *(csharp2cuda_temp_26);
                (*(csharp2cuda_temp_26) = csharp2cuda_i32_add(csharp2cuda_temp_27, blockDim.x));
            }
        }
#line 437 "ProbabilityModule.cs"
        return;
    }
#line 440 "ProbabilityModule.cs"
    if (((opcode) == (19)))
#line 441 "ProbabilityModule.cs"
    {
#line 442 "ProbabilityModule.cs"
        int csharp2cuda_temp_37 = (first)->count;
#line 442 "ProbabilityModule.cs"
        int csharp2cuda_temp_38;
#line 442 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_37) <= (1)))
        {
#line 442 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = 1;
        }
        else
        {
#line 442 "ProbabilityModule.cs"
            int csharp2cuda_temp_39 = (first)->count;
#line 442 "ProbabilityModule.cs"
            csharp2cuda_temp_38 = csharp2cuda_i32_sub(csharp2cuda_temp_39, 1);
        }
#line 442 "ProbabilityModule.cs"
        int count = csharp2cuda_temp_38;
#line 443 "ProbabilityModule.cs"
        if (((thread) == (0)))
        {
#line 443 "ProbabilityModule.cs"
            mathblocks_set_vector_shape(output, count);
        }
#line 444 "ProbabilityModule.cs"
        __syncthreads();
#line 445 "ProbabilityModule.cs"
#line 445 "ProbabilityModule.cs"
        int csharp2cuda_temp_40 = (first)->count;
        if (((csharp2cuda_temp_40) <= (1)))
#line 446 "ProbabilityModule.cs"
        {
#line 447 "ProbabilityModule.cs"
            if (((thread) == (0)))
            {
#line 447 "ProbabilityModule.cs"
#line 447 "ProbabilityModule.cs"
                double* csharp2cuda_temp_41 = &((result)[0]);
                (*(csharp2cuda_temp_41) = 0.0);
            }
        }
        else
#line 450 "ProbabilityModule.cs"
        {
#line 451 "ProbabilityModule.cs"
            {
#line 451 "ProbabilityModule.cs"
                int index = csharp2cuda_i32_add(thread, 1);
                while (true)
                {
#line 451 "ProbabilityModule.cs"
                    int csharp2cuda_temp_44 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_44))))
                        break;
#line 452 "ProbabilityModule.cs"
                    {
#line 453 "ProbabilityModule.cs"
#line 453 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_45 = &((result)[csharp2cuda_i32_sub(index, 1)]);
#line 453 "ProbabilityModule.cs"
                        double csharp2cuda_temp_46 = (a)[index];
                        (*(csharp2cuda_temp_45) = __dmul_rn(((double)(index)), csharp2cuda_temp_46));
#line 454 "ProbabilityModule.cs"
#line 454 "ProbabilityModule.cs"
                        double csharp2cuda_temp_47 = (result)[csharp2cuda_i32_sub(index, 1)];
                        if ((!(isfinite(csharp2cuda_temp_47))))
                        {
#line 454 "ProbabilityModule.cs"
                            atomicExch(&((output)->valid), 0);
                        }
                    }
#line 451 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_42 = &(index);
#line 451 "ProbabilityModule.cs"
                    int csharp2cuda_temp_43 = *(csharp2cuda_temp_42);
                    (*(csharp2cuda_temp_42) = csharp2cuda_i32_add(csharp2cuda_temp_43, blockDim.x));
                }
            }
        }
#line 457 "ProbabilityModule.cs"
        return;
    }
#line 460 "ProbabilityModule.cs"
#line 460 "ProbabilityModule.cs"
    bool csharp2cuda_temp_48;
#line 460 "ProbabilityModule.cs"
    if (!(((opcode) == (24))))
    {
#line 460 "ProbabilityModule.cs"
        csharp2cuda_temp_48 = ((opcode) == (27));
    }
    else
    {
#line 460 "ProbabilityModule.cs"
        csharp2cuda_temp_48 = true;
    }
    if (csharp2cuda_temp_48)
#line 461 "ProbabilityModule.cs"
    {
#line 462 "ProbabilityModule.cs"
        if (((thread) == (0)))
#line 463 "ProbabilityModule.cs"
        {
#line 464 "ProbabilityModule.cs"
#line 464 "ProbabilityModule.cs"
            int csharp2cuda_temp_49 = (first)->count;
            if (((csharp2cuda_temp_49) <= (0)))
#line 465 "ProbabilityModule.cs"
            {
#line 466 "ProbabilityModule.cs"
#line 466 "ProbabilityModule.cs"
                int* csharp2cuda_temp_50 = &((output)->valid);
                (*(csharp2cuda_temp_50) = 0);
#line 467 "ProbabilityModule.cs"
                return;
            }
#line 469 "ProbabilityModule.cs"
            {
#line 469 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 469 "ProbabilityModule.cs"
                    int csharp2cuda_temp_52 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_52))))
                        break;
#line 470 "ProbabilityModule.cs"
#line 470 "ProbabilityModule.cs"
                    double csharp2cuda_temp_53 = (a)[index];
                    if (((csharp2cuda_temp_53) < (0.0)))
                    {
#line 470 "ProbabilityModule.cs"
#line 470 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_54 = &((output)->valid);
                        (*(csharp2cuda_temp_54) = 0);
                    }
#line 469 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_51 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                }
            }
#line 471 "ProbabilityModule.cs"
#line 471 "ProbabilityModule.cs"
            int csharp2cuda_temp_55 = (first)->count;
            mathblocks_set_vector_shape(output, csharp2cuda_temp_55);
#line 472 "ProbabilityModule.cs"
            if (((opcode) == (24)))
#line 473 "ProbabilityModule.cs"
            {
#line 474 "ProbabilityModule.cs"
                int csharp2cuda_temp_56 = (first)->count;
#line 474 "ProbabilityModule.cs"
                double total = mathblocks_compensated_sum(a, csharp2cuda_temp_56);
#line 475 "ProbabilityModule.cs"
                {
#line 475 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 475 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_58 = (output)->valid;
#line 475 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_59;
#line 475 "ProbabilityModule.cs"
                        if (csharp2cuda_temp_58)
                        {
#line 475 "ProbabilityModule.cs"
                            int csharp2cuda_temp_60 = (first)->count;
#line 475 "ProbabilityModule.cs"
                            csharp2cuda_temp_59 = ((index) < (csharp2cuda_temp_60));
                        }
                        else
                        {
#line 475 "ProbabilityModule.cs"
                            csharp2cuda_temp_59 = false;
                        }
                        if (!(csharp2cuda_temp_59))
                            break;
#line 476 "ProbabilityModule.cs"
#line 476 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_61 = &((result)[index]);
#line 476 "ProbabilityModule.cs"
                        double csharp2cuda_temp_62 = (a)[index];
#line 476 "ProbabilityModule.cs"
                        double csharp2cuda_temp_63 = __ddiv_rn(1.0, total);
                        (*(csharp2cuda_temp_61) = __dmul_rn(csharp2cuda_temp_62, csharp2cuda_temp_63));
#line 475 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_57 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_57));
                    }
                }
            }
            else
#line 479 "ProbabilityModule.cs"
            {
#line 480 "ProbabilityModule.cs"
                double maximum = (a)[0];
#line 481 "ProbabilityModule.cs"
                {
#line 481 "ProbabilityModule.cs"
                    int index = 1;
                    while (true)
                    {
#line 481 "ProbabilityModule.cs"
                        int csharp2cuda_temp_65 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_65))))
                            break;
#line 482 "ProbabilityModule.cs"
#line 482 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_66 = &(maximum);
#line 482 "ProbabilityModule.cs"
                        double csharp2cuda_temp_67 = (a)[index];
                        (*(csharp2cuda_temp_66) = mathblocks_maximum(maximum, csharp2cuda_temp_67));
#line 481 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_64 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                    }
                }
#line 483 "ProbabilityModule.cs"
                {
#line 483 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 483 "ProbabilityModule.cs"
                        int csharp2cuda_temp_69 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_69))))
                            break;
#line 484 "ProbabilityModule.cs"
#line 484 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_70 = &((result)[index]);
#line 484 "ProbabilityModule.cs"
                        double csharp2cuda_temp_71 = (a)[index];
                        (*(csharp2cuda_temp_70) = mathblocks_exponential(__dsub_rn(csharp2cuda_temp_71, maximum)));
#line 483 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_68 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_68));
                    }
                }
#line 485 "ProbabilityModule.cs"
                int csharp2cuda_temp_72 = (first)->count;
#line 485 "ProbabilityModule.cs"
                double total = mathblocks_compensated_sum(result, csharp2cuda_temp_72);
#line 486 "ProbabilityModule.cs"
                double scale = __ddiv_rn(1.0, total);
#line 487 "ProbabilityModule.cs"
                {
#line 487 "ProbabilityModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 487 "ProbabilityModule.cs"
                        int csharp2cuda_temp_74 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_74))))
                            break;
#line 488 "ProbabilityModule.cs"
#line 488 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_75 = &((result)[index]);
#line 488 "ProbabilityModule.cs"
                        double csharp2cuda_temp_76 = *(csharp2cuda_temp_75);
                        (*(csharp2cuda_temp_75) = __dmul_rn(csharp2cuda_temp_76, scale));
#line 487 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_73 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_73));
                    }
                }
            }
#line 490 "ProbabilityModule.cs"
            {
#line 490 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 490 "ProbabilityModule.cs"
                    int csharp2cuda_temp_78 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_78))))
                        break;
#line 491 "ProbabilityModule.cs"
#line 491 "ProbabilityModule.cs"
                    double csharp2cuda_temp_79 = (result)[index];
                    if ((!(isfinite(csharp2cuda_temp_79))))
                    {
#line 491 "ProbabilityModule.cs"
#line 491 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_80 = &((output)->valid);
                        (*(csharp2cuda_temp_80) = 0);
                    }
#line 490 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_77 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_77));
                }
            }
        }
#line 493 "ProbabilityModule.cs"
        return;
    }
#line 496 "ProbabilityModule.cs"
    if (((thread) != (0)))
    {
#line 497 "ProbabilityModule.cs"
        return;
    }
#line 499 "ProbabilityModule.cs"
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_81;
#line 499 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = ((opcode) == (1));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_81 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_82;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_81))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_82 = ((opcode) == (2));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_82 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_83;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_82))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_83 = ((opcode) == (23));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_83 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_84;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_83))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_84 = ((opcode) == (25));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_84 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_85;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_84))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_85 = ((opcode) == (26));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_85 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_86;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_85))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_86 = ((opcode) == (28));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_86 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_87;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_86))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_87 = ((opcode) == (29));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_87 = true;
    }
#line 499 "ProbabilityModule.cs"
    bool csharp2cuda_temp_88;
#line 499 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_87))
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_88 = ((opcode) == (30));
    }
    else
    {
#line 499 "ProbabilityModule.cs"
        csharp2cuda_temp_88 = true;
    }
    if (csharp2cuda_temp_88)
#line 501 "ProbabilityModule.cs"
    {
#line 502 "ProbabilityModule.cs"
        double value = 0.0;
#line 505 "ProbabilityModule.cs"
        double csharp2cuda_temp_89;
#line 505 "ProbabilityModule.cs"
        if (((((void*)(first))) == (((void*)(nullptr)))))
        {
#line 505 "ProbabilityModule.cs"
            csharp2cuda_temp_89 = 0.0;
        }
        else
        {
#line 505 "ProbabilityModule.cs"
            csharp2cuda_temp_89 = (first)->scalar_value;
        }
#line 506 "ProbabilityModule.cs"
        double csharp2cuda_temp_90;
#line 506 "ProbabilityModule.cs"
        if (((((void*)(second))) == (((void*)(nullptr)))))
        {
#line 506 "ProbabilityModule.cs"
            csharp2cuda_temp_90 = 0.0;
        }
        else
        {
#line 506 "ProbabilityModule.cs"
            csharp2cuda_temp_90 = (second)->scalar_value;
        }
#line 507 "ProbabilityModule.cs"
        double csharp2cuda_temp_91;
#line 507 "ProbabilityModule.cs"
        if (((((void*)(third))) == (((void*)(nullptr)))))
        {
#line 507 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = 0.0;
        }
        else
        {
#line 507 "ProbabilityModule.cs"
            csharp2cuda_temp_91 = (third)->scalar_value;
        }
#line 508 "ProbabilityModule.cs"
        double* csharp2cuda_temp_92 = &(value);
#line 503 "ProbabilityModule.cs"
        bool valid = mathblocks_probability_scalar_value(opcode, csharp2cuda_temp_89, csharp2cuda_temp_90, csharp2cuda_temp_91, csharp2cuda_temp_92);
#line 509 "ProbabilityModule.cs"
#line 509 "ProbabilityModule.cs"
        double* csharp2cuda_temp_93 = &((output)->scalar_value);
        (*(csharp2cuda_temp_93) = value);
#line 510 "ProbabilityModule.cs"
        if ((!(valid)))
        {
#line 510 "ProbabilityModule.cs"
#line 510 "ProbabilityModule.cs"
            int* csharp2cuda_temp_94 = &((output)->valid);
            (*(csharp2cuda_temp_94) = 0);
        }
#line 511 "ProbabilityModule.cs"
        return;
    }
#line 514 "ProbabilityModule.cs"
#line 514 "ProbabilityModule.cs"
    bool csharp2cuda_temp_95;
#line 514 "ProbabilityModule.cs"
    if (((opcode) >= (4)))
    {
#line 514 "ProbabilityModule.cs"
        csharp2cuda_temp_95 = ((opcode) <= (16));
    }
    else
    {
#line 514 "ProbabilityModule.cs"
        csharp2cuda_temp_95 = false;
    }
    if (csharp2cuda_temp_95)
#line 515 "ProbabilityModule.cs"
    {
#line 516 "ProbabilityModule.cs"
        bool csharp2cuda_temp_96;
#line 516 "ProbabilityModule.cs"
        if (((opcode) == (12)))
        {
#line 517 "ProbabilityModule.cs"
            int csharp2cuda_temp_97 = (first)->count;
#line 516 "ProbabilityModule.cs"
            csharp2cuda_temp_96 = mathblocks_probability_distribution(a, csharp2cuda_temp_97);
        }
        else
        {
#line 518 "ProbabilityModule.cs"
            int csharp2cuda_temp_98 = (first)->count;
#line 516 "ProbabilityModule.cs"
            csharp2cuda_temp_96 = mathblocks_probability_distribution(a, csharp2cuda_temp_98);
        }
#line 516 "ProbabilityModule.cs"
        bool first_distribution = csharp2cuda_temp_96;
#line 519 "ProbabilityModule.cs"
        bool csharp2cuda_temp_99;
#line 519 "ProbabilityModule.cs"
        if (!(((opcode) == (4))))
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_99 = ((opcode) == (7));
        }
        else
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_99 = true;
        }
#line 519 "ProbabilityModule.cs"
        bool csharp2cuda_temp_100;
#line 519 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_99))
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_100 = ((opcode) == (9));
        }
        else
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_100 = true;
        }
#line 519 "ProbabilityModule.cs"
        bool csharp2cuda_temp_101;
#line 519 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_100))
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_101 = ((opcode) == (10));
        }
        else
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_101 = true;
        }
#line 519 "ProbabilityModule.cs"
        bool csharp2cuda_temp_102;
#line 519 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_101))
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_102 = ((opcode) == (11));
        }
        else
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_102 = true;
        }
#line 519 "ProbabilityModule.cs"
        bool csharp2cuda_temp_103;
#line 519 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_102))
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_103 = ((opcode) == (15));
        }
        else
        {
#line 519 "ProbabilityModule.cs"
            csharp2cuda_temp_103 = true;
        }
#line 519 "ProbabilityModule.cs"
        bool pair = csharp2cuda_temp_103;
#line 521 "ProbabilityModule.cs"
#line 521 "ProbabilityModule.cs"
        bool csharp2cuda_temp_104;
#line 521 "ProbabilityModule.cs"
        if (!((!(first_distribution))))
        {
#line 521 "ProbabilityModule.cs"
            bool csharp2cuda_temp_105;
#line 521 "ProbabilityModule.cs"
            if (pair)
            {
#line 522 "ProbabilityModule.cs"
                int csharp2cuda_temp_106 = (first)->count;
#line 522 "ProbabilityModule.cs"
                int csharp2cuda_temp_107 = (second)->count;
#line 522 "ProbabilityModule.cs"
                bool csharp2cuda_temp_108;
#line 522 "ProbabilityModule.cs"
                if (!(((csharp2cuda_temp_106) != (csharp2cuda_temp_107))))
                {
#line 522 "ProbabilityModule.cs"
                    int csharp2cuda_temp_109 = (second)->count;
#line 522 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_110 = mathblocks_probability_distribution(b, csharp2cuda_temp_109);
#line 522 "ProbabilityModule.cs"
                    csharp2cuda_temp_108 = (!(csharp2cuda_temp_110));
                }
                else
                {
#line 522 "ProbabilityModule.cs"
                    csharp2cuda_temp_108 = true;
                }
#line 521 "ProbabilityModule.cs"
                csharp2cuda_temp_105 = csharp2cuda_temp_108;
            }
            else
            {
#line 521 "ProbabilityModule.cs"
                csharp2cuda_temp_105 = false;
            }
#line 521 "ProbabilityModule.cs"
            csharp2cuda_temp_104 = csharp2cuda_temp_105;
        }
        else
        {
#line 521 "ProbabilityModule.cs"
            csharp2cuda_temp_104 = true;
        }
        if (csharp2cuda_temp_104)
#line 523 "ProbabilityModule.cs"
        {
#line 524 "ProbabilityModule.cs"
#line 524 "ProbabilityModule.cs"
            int* csharp2cuda_temp_111 = &((output)->valid);
            (*(csharp2cuda_temp_111) = 0);
#line 525 "ProbabilityModule.cs"
            return;
        }
#line 527 "ProbabilityModule.cs"
        double value = 0.0;
#line 528 "ProbabilityModule.cs"
        if (((opcode) == (4)))
#line 529 "ProbabilityModule.cs"
        {
#line 530 "ProbabilityModule.cs"
            {
#line 530 "ProbabilityModule.cs"
                int index = 0;
                while (true)
                {
#line 530 "ProbabilityModule.cs"
                    int csharp2cuda_temp_113 = (first)->count;
                    if (!(((index) < (csharp2cuda_temp_113))))
                        break;
#line 531 "ProbabilityModule.cs"
#line 531 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_114 = &(value);
#line 531 "ProbabilityModule.cs"
                    double csharp2cuda_temp_115 = *(csharp2cuda_temp_114);
#line 531 "ProbabilityModule.cs"
                    double csharp2cuda_temp_116 = (a)[index];
#line 531 "ProbabilityModule.cs"
                    double csharp2cuda_temp_117 = (b)[index];
                    (*(csharp2cuda_temp_114) = __dadd_rn(csharp2cuda_temp_115, mathblocks_square_root(__dmul_rn(csharp2cuda_temp_116, csharp2cuda_temp_117))));
#line 530 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_112 = &(index);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_112));
                }
            }
        }
        else
        {
#line 533 "ProbabilityModule.cs"
            if (((opcode) == (5)))
#line 534 "ProbabilityModule.cs"
            {
#line 535 "ProbabilityModule.cs"
#line 535 "ProbabilityModule.cs"
                double* csharp2cuda_temp_118 = &(value);
#line 535 "ProbabilityModule.cs"
                int csharp2cuda_temp_119 = (first)->count;
#line 535 "ProbabilityModule.cs"
                double csharp2cuda_temp_120 = mathblocks_probability_entropy(a, csharp2cuda_temp_119);
#line 535 "ProbabilityModule.cs"
                double csharp2cuda_temp_121 = __ddiv_rn(csharp2cuda_temp_120, mathblocks_natural_logarithm(2.0));
                (*(csharp2cuda_temp_118) = csharp2cuda_temp_121);
            }
            else
            {
#line 538 "ProbabilityModule.cs"
                if (((opcode) == (6)))
#line 539 "ProbabilityModule.cs"
                {
#line 540 "ProbabilityModule.cs"
                    int first_count = 0;
#line 541 "ProbabilityModule.cs"
                    int second_count = 0;
#line 542 "ProbabilityModule.cs"
                    int condition_count = 0;
#line 543 "ProbabilityModule.cs"
#line 543 "ProbabilityModule.cs"
                    double csharp2cuda_temp_122 = (second)->scalar_value;
#line 543 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_123 = &(first_count);
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_124 = mathblocks_probability_integer(csharp2cuda_temp_122, csharp2cuda_temp_123);
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_125;
#line 543 "ProbabilityModule.cs"
                    if (!((!(csharp2cuda_temp_124))))
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_125 = ((first_count) <= (0));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_125 = true;
                    }
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_126;
#line 543 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_125))
                    {
#line 544 "ProbabilityModule.cs"
                        double csharp2cuda_temp_127 = (third)->scalar_value;
#line 544 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_128 = &(second_count);
#line 544 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_129 = mathblocks_probability_integer(csharp2cuda_temp_127, csharp2cuda_temp_128);
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_126 = (!(csharp2cuda_temp_129));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_126 = true;
                    }
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_130;
#line 543 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_126))
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_130 = ((second_count) <= (0));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_130 = true;
                    }
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_131;
#line 543 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_130))
                    {
#line 545 "ProbabilityModule.cs"
                        double csharp2cuda_temp_132 = (fourth)->scalar_value;
#line 545 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_133 = &(condition_count);
#line 545 "ProbabilityModule.cs"
                        bool csharp2cuda_temp_134 = mathblocks_probability_integer(csharp2cuda_temp_132, csharp2cuda_temp_133);
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_131 = (!(csharp2cuda_temp_134));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_131 = true;
                    }
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_135;
#line 543 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_131))
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_135 = ((condition_count) <= (0));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_135 = true;
                    }
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_136;
#line 543 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_135))
                    {
#line 546 "ProbabilityModule.cs"
                        int csharp2cuda_temp_137 = (first)->count;
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = ((csharp2cuda_i64_mul(csharp2cuda_i64_mul(((long long)(first_count)), ((long long)(second_count))), ((long long)(condition_count)))) != (((long long)(csharp2cuda_temp_137))));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_136 = true;
                    }
#line 543 "ProbabilityModule.cs"
                    bool csharp2cuda_temp_138;
#line 543 "ProbabilityModule.cs"
                    if (!(csharp2cuda_temp_136))
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_138 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 543 "ProbabilityModule.cs"
                        csharp2cuda_temp_138 = true;
                    }
                    if (csharp2cuda_temp_138)
#line 547 "ProbabilityModule.cs"
                    {
#line 548 "ProbabilityModule.cs"
#line 548 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_139 = &((output)->valid);
                        (*(csharp2cuda_temp_139) = 0);
#line 549 "ProbabilityModule.cs"
                        return;
                    }
#line 551 "ProbabilityModule.cs"
                    int first_condition_count = csharp2cuda_i32_mul(first_count, condition_count);
#line 552 "ProbabilityModule.cs"
                    int second_condition_count = csharp2cuda_i32_mul(second_count, condition_count);
#line 553 "ProbabilityModule.cs"
                    double* first_condition = scratch;
#line 554 "ProbabilityModule.cs"
                    double* second_condition = csharp2cuda_pointer_add(first_condition, first_condition_count);
#line 555 "ProbabilityModule.cs"
                    double* condition = csharp2cuda_pointer_add(second_condition, second_condition_count);
#line 556 "ProbabilityModule.cs"
                    {
#line 556 "ProbabilityModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_add(csharp2cuda_i32_add(first_condition_count, second_condition_count), condition_count)))))
                                break;
#line 557 "ProbabilityModule.cs"
#line 557 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_141 = &((scratch)[index]);
                            (*(csharp2cuda_temp_141) = 0.0);
#line 556 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_140 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_140));
                        }
                    }
#line 558 "ProbabilityModule.cs"
                    {
#line 558 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 559 "ProbabilityModule.cs"
                            {
#line 559 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 560 "ProbabilityModule.cs"
                                    {
#line 560 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 561 "ProbabilityModule.cs"
                                            {
#line 562 "ProbabilityModule.cs"
                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 564 "ProbabilityModule.cs"
#line 564 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_145 = &((first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)]);
#line 564 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_146 = *(csharp2cuda_temp_145);
                                                (*(csharp2cuda_temp_145) = __dadd_rn(csharp2cuda_temp_146, probability));
#line 565 "ProbabilityModule.cs"
#line 565 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_147 = &((second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)]);
#line 565 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_148 = *(csharp2cuda_temp_147);
                                                (*(csharp2cuda_temp_147) = __dadd_rn(csharp2cuda_temp_148, probability));
#line 566 "ProbabilityModule.cs"
#line 566 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_149 = &((condition)[state]);
#line 566 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_150 = *(csharp2cuda_temp_149);
                                                (*(csharp2cuda_temp_149) = __dadd_rn(csharp2cuda_temp_150, probability));
                                            }
#line 560 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_144 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_144));
                                        }
                                    }
#line 559 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_143 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_143));
                                }
                            }
#line 558 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_142 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_142));
                        }
                    }
#line 568 "ProbabilityModule.cs"
                    {
#line 568 "ProbabilityModule.cs"
                        int first_index = 0;
                        while (true)
                        {
                            if (!(((first_index) < (first_count))))
                                break;
#line 569 "ProbabilityModule.cs"
                            {
#line 569 "ProbabilityModule.cs"
                                int second_index = 0;
                                while (true)
                                {
                                    if (!(((second_index) < (second_count))))
                                        break;
#line 570 "ProbabilityModule.cs"
                                    {
#line 570 "ProbabilityModule.cs"
                                        int state = 0;
                                        while (true)
                                        {
                                            if (!(((state) < (condition_count))))
                                                break;
#line 571 "ProbabilityModule.cs"
                                            {
#line 572 "ProbabilityModule.cs"
                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, second_count), second_index), condition_count), state)];
#line 574 "ProbabilityModule.cs"
                                                if (((probability) == (0.0)))
                                                {
#line 574 "ProbabilityModule.cs"
                                                    goto csharp2cuda_for_continue_15;
                                                }
#line 575 "ProbabilityModule.cs"
#line 575 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_154 = &(value);
#line 575 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_155 = *(csharp2cuda_temp_154);
#line 576 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_156 = (condition)[state];
#line 577 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_157 = (first_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(first_index, condition_count), state)];
#line 578 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_158 = (second_condition)[csharp2cuda_i32_add(csharp2cuda_i32_mul(second_index, condition_count), state)];
#line 576 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_159 = __ddiv_rn(__dmul_rn(probability, csharp2cuda_temp_156), __dmul_rn(csharp2cuda_temp_157, csharp2cuda_temp_158));
                                                (*(csharp2cuda_temp_154) = __dadd_rn(csharp2cuda_temp_155, __dmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_159))));
                                            }
                                            csharp2cuda_for_continue_15:
#line 570 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_153 = &(state);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_153));
                                        }
                                    }
#line 569 "ProbabilityModule.cs"
                                    int* csharp2cuda_temp_152 = &(second_index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_152));
                                }
                            }
#line 568 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_151 = &(first_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_151));
                        }
                    }
                }
                else
                {
#line 581 "ProbabilityModule.cs"
                    if (((opcode) == (7)))
#line 582 "ProbabilityModule.cs"
                    {
#line 583 "ProbabilityModule.cs"
                        {
#line 583 "ProbabilityModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 583 "ProbabilityModule.cs"
                                int csharp2cuda_temp_161 = (first)->count;
                                if (!(((index) < (csharp2cuda_temp_161))))
                                    break;
#line 584 "ProbabilityModule.cs"
                                {
#line 585 "ProbabilityModule.cs"
#line 585 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_162 = (a)[index];
#line 585 "ProbabilityModule.cs"
                                    bool csharp2cuda_temp_163;
#line 585 "ProbabilityModule.cs"
                                    if (((csharp2cuda_temp_162) > (0.0)))
                                    {
#line 585 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_164 = (b)[index];
#line 585 "ProbabilityModule.cs"
                                        csharp2cuda_temp_163 = ((csharp2cuda_temp_164) == (0.0));
                                    }
                                    else
                                    {
#line 585 "ProbabilityModule.cs"
                                        csharp2cuda_temp_163 = false;
                                    }
                                    if (csharp2cuda_temp_163)
#line 586 "ProbabilityModule.cs"
                                    {
#line 587 "ProbabilityModule.cs"
#line 587 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_165 = &((output)->valid);
                                        (*(csharp2cuda_temp_165) = 0);
#line 588 "ProbabilityModule.cs"
                                        return;
                                    }
#line 590 "ProbabilityModule.cs"
#line 590 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_166 = (a)[index];
                                    if (((csharp2cuda_temp_166) > (0.0)))
                                    {
#line 591 "ProbabilityModule.cs"
#line 591 "ProbabilityModule.cs"
                                        double* csharp2cuda_temp_167 = &(value);
#line 591 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_168 = *(csharp2cuda_temp_167);
#line 591 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_169 = (a)[index];
#line 591 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_170 = (b)[index];
                                        (*(csharp2cuda_temp_167) = __dsub_rn(csharp2cuda_temp_168, __dmul_rn(csharp2cuda_temp_169, mathblocks_natural_logarithm(csharp2cuda_temp_170))));
                                    }
                                }
#line 583 "ProbabilityModule.cs"
                                int* csharp2cuda_temp_160 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_160));
                            }
                        }
                    }
                    else
                    {
#line 594 "ProbabilityModule.cs"
                        if (((opcode) == (8)))
#line 595 "ProbabilityModule.cs"
                        {
#line 596 "ProbabilityModule.cs"
#line 596 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_171 = &(value);
#line 596 "ProbabilityModule.cs"
                            int csharp2cuda_temp_172 = (first)->count;
                            (*(csharp2cuda_temp_171) = __dsub_rn(1.0, mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_172)));
                        }
                        else
                        {
#line 598 "ProbabilityModule.cs"
                            if (((opcode) == (9)))
#line 599 "ProbabilityModule.cs"
                            {
#line 600 "ProbabilityModule.cs"
                                {
#line 600 "ProbabilityModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
#line 600 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_174 = (first)->count;
                                        if (!(((index) < (csharp2cuda_temp_174))))
                                            break;
#line 601 "ProbabilityModule.cs"
                                        {
#line 602 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_175 = (a)[index];
#line 602 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_176 = (b)[index];
#line 602 "ProbabilityModule.cs"
                                            double difference = __dsub_rn(mathblocks_square_root(csharp2cuda_temp_175), mathblocks_square_root(csharp2cuda_temp_176));
#line 603 "ProbabilityModule.cs"
#line 603 "ProbabilityModule.cs"
                                            double* csharp2cuda_temp_177 = &(value);
#line 603 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_178 = *(csharp2cuda_temp_177);
                                            (*(csharp2cuda_temp_177) = __dadd_rn(csharp2cuda_temp_178, __dmul_rn(difference, difference)));
                                        }
#line 600 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_173 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_173));
                                    }
                                }
#line 605 "ProbabilityModule.cs"
#line 605 "ProbabilityModule.cs"
                                double* csharp2cuda_temp_179 = &(value);
#line 605 "ProbabilityModule.cs"
                                double csharp2cuda_temp_180 = __ddiv_rn(value, 2.0);
                                (*(csharp2cuda_temp_179) = mathblocks_square_root(csharp2cuda_temp_180));
                            }
                            else
                            {
#line 607 "ProbabilityModule.cs"
                                if (((opcode) == (10)))
#line 608 "ProbabilityModule.cs"
                                {
#line 609 "ProbabilityModule.cs"
                                    if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 610 "ProbabilityModule.cs"
                                    {
#line 611 "ProbabilityModule.cs"
#line 611 "ProbabilityModule.cs"
                                        int* csharp2cuda_temp_181 = &((output)->valid);
                                        (*(csharp2cuda_temp_181) = 0);
#line 612 "ProbabilityModule.cs"
                                        return;
                                    }
#line 614 "ProbabilityModule.cs"
                                    {
#line 614 "ProbabilityModule.cs"
                                        int index = 0;
                                        while (true)
                                        {
#line 614 "ProbabilityModule.cs"
                                            int csharp2cuda_temp_183 = (first)->count;
                                            if (!(((index) < (csharp2cuda_temp_183))))
                                                break;
#line 615 "ProbabilityModule.cs"
#line 615 "ProbabilityModule.cs"
                                            double* csharp2cuda_temp_184 = &((scratch)[index]);
#line 615 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_185 = (a)[index];
#line 615 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_186 = (b)[index];
#line 615 "ProbabilityModule.cs"
                                            double csharp2cuda_temp_187 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_185, csharp2cuda_temp_186), 2.0);
                                            (*(csharp2cuda_temp_184) = csharp2cuda_temp_187);
#line 614 "ProbabilityModule.cs"
                                            int* csharp2cuda_temp_182 = &(index);
                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_182));
                                        }
                                    }
#line 616 "ProbabilityModule.cs"
#line 616 "ProbabilityModule.cs"
                                    double* csharp2cuda_temp_188 = &(value);
#line 616 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_189 = (first)->count;
#line 616 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_190 = mathblocks_probability_kl(a, scratch, csharp2cuda_temp_189);
#line 617 "ProbabilityModule.cs"
                                    int csharp2cuda_temp_191 = (first)->count;
#line 617 "ProbabilityModule.cs"
                                    double csharp2cuda_temp_192 = mathblocks_probability_kl(b, scratch, csharp2cuda_temp_191);
                                    (*(csharp2cuda_temp_188) = __dmul_rn(0.5, __dadd_rn(csharp2cuda_temp_190, csharp2cuda_temp_192)));
                                }
                                else
                                {
#line 619 "ProbabilityModule.cs"
                                    if (((opcode) == (11)))
#line 620 "ProbabilityModule.cs"
                                    {
#line 621 "ProbabilityModule.cs"
                                        {
#line 621 "ProbabilityModule.cs"
                                            int index = 0;
                                            while (true)
                                            {
#line 621 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_194 = (first)->count;
                                                if (!(((index) < (csharp2cuda_temp_194))))
                                                    break;
#line 622 "ProbabilityModule.cs"
#line 622 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_195 = (a)[index];
#line 622 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_196;
#line 622 "ProbabilityModule.cs"
                                                if (((csharp2cuda_temp_195) > (0.0)))
                                                {
#line 622 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_197 = (b)[index];
#line 622 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_196 = ((csharp2cuda_temp_197) == (0.0));
                                                }
                                                else
                                                {
#line 622 "ProbabilityModule.cs"
                                                    csharp2cuda_temp_196 = false;
                                                }
                                                if (csharp2cuda_temp_196)
#line 623 "ProbabilityModule.cs"
                                                {
#line 624 "ProbabilityModule.cs"
#line 624 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_198 = &((output)->valid);
                                                    (*(csharp2cuda_temp_198) = 0);
#line 625 "ProbabilityModule.cs"
                                                    return;
                                                }
#line 621 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_193 = &(index);
                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_193));
                                            }
                                        }
#line 627 "ProbabilityModule.cs"
#line 627 "ProbabilityModule.cs"
                                        double* csharp2cuda_temp_199 = &(value);
#line 627 "ProbabilityModule.cs"
                                        int csharp2cuda_temp_200 = (first)->count;
#line 627 "ProbabilityModule.cs"
                                        double csharp2cuda_temp_201 = mathblocks_probability_kl(a, b, csharp2cuda_temp_200);
                                        (*(csharp2cuda_temp_199) = csharp2cuda_temp_201);
                                    }
                                    else
                                    {
#line 629 "ProbabilityModule.cs"
                                        if (((opcode) == (12)))
#line 630 "ProbabilityModule.cs"
                                        {
#line 631 "ProbabilityModule.cs"
                                            int rows = (first)->rows;
#line 632 "ProbabilityModule.cs"
                                            int columns = (first)->columns;
#line 633 "ProbabilityModule.cs"
                                            if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 634 "ProbabilityModule.cs"
                                            {
#line 635 "ProbabilityModule.cs"
#line 635 "ProbabilityModule.cs"
                                                int* csharp2cuda_temp_202 = &((output)->valid);
                                                (*(csharp2cuda_temp_202) = 0);
#line 636 "ProbabilityModule.cs"
                                                return;
                                            }
#line 638 "ProbabilityModule.cs"
                                            double* row_totals = scratch;
#line 639 "ProbabilityModule.cs"
                                            double* column_totals = csharp2cuda_pointer_add(scratch, rows);
#line 640 "ProbabilityModule.cs"
                                            {
#line 640 "ProbabilityModule.cs"
                                                int index = 0;
                                                while (true)
                                                {
                                                    if (!(((index) < (csharp2cuda_i32_add(rows, columns)))))
                                                        break;
#line 640 "ProbabilityModule.cs"
#line 640 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_204 = &((scratch)[index]);
                                                    (*(csharp2cuda_temp_204) = 0.0);
#line 640 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_203 = &(index);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_203));
                                                }
                                            }
#line 641 "ProbabilityModule.cs"
                                            {
#line 641 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 642 "ProbabilityModule.cs"
                                                    {
#line 642 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 643 "ProbabilityModule.cs"
                                                            {
#line 644 "ProbabilityModule.cs"
                                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 645 "ProbabilityModule.cs"
#line 645 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_207 = &((row_totals)[row]);
#line 645 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_208 = *(csharp2cuda_temp_207);
                                                                (*(csharp2cuda_temp_207) = __dadd_rn(csharp2cuda_temp_208, probability));
#line 646 "ProbabilityModule.cs"
#line 646 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_209 = &((column_totals)[column]);
#line 646 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_210 = *(csharp2cuda_temp_209);
                                                                (*(csharp2cuda_temp_209) = __dadd_rn(csharp2cuda_temp_210, probability));
                                                            }
#line 642 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_206 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_206));
                                                        }
                                                    }
#line 641 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_205 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                                                }
                                            }
#line 648 "ProbabilityModule.cs"
                                            {
#line 648 "ProbabilityModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 649 "ProbabilityModule.cs"
                                                    {
#line 649 "ProbabilityModule.cs"
                                                        int column = 0;
                                                        while (true)
                                                        {
                                                            if (!(((column) < (columns))))
                                                                break;
#line 650 "ProbabilityModule.cs"
                                                            {
#line 651 "ProbabilityModule.cs"
                                                                double probability = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 652 "ProbabilityModule.cs"
                                                                if (((probability) > (0.0)))
                                                                {
#line 653 "ProbabilityModule.cs"
#line 653 "ProbabilityModule.cs"
                                                                    double* csharp2cuda_temp_213 = &(value);
#line 653 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_214 = *(csharp2cuda_temp_213);
#line 654 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_215 = (row_totals)[row];
#line 654 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_216 = (column_totals)[column];
#line 654 "ProbabilityModule.cs"
                                                                    double csharp2cuda_temp_217 = __ddiv_rn(probability, __dmul_rn(csharp2cuda_temp_215, csharp2cuda_temp_216));
                                                                    (*(csharp2cuda_temp_213) = __dadd_rn(csharp2cuda_temp_214, __dmul_rn(probability, mathblocks_natural_logarithm(csharp2cuda_temp_217))));
                                                                }
                                                            }
#line 649 "ProbabilityModule.cs"
                                                            int* csharp2cuda_temp_212 = &(column);
                                                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_212));
                                                        }
                                                    }
#line 648 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_211 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_211));
                                                }
                                            }
                                        }
                                        else
                                        {
#line 657 "ProbabilityModule.cs"
#line 657 "ProbabilityModule.cs"
                                            bool csharp2cuda_temp_218;
#line 657 "ProbabilityModule.cs"
                                            if (!(((opcode) == (13))))
                                            {
#line 657 "ProbabilityModule.cs"
                                                csharp2cuda_temp_218 = ((opcode) == (16));
                                            }
                                            else
                                            {
#line 657 "ProbabilityModule.cs"
                                                csharp2cuda_temp_218 = true;
                                            }
                                            if (csharp2cuda_temp_218)
#line 658 "ProbabilityModule.cs"
                                            {
#line 659 "ProbabilityModule.cs"
#line 661 "ProbabilityModule.cs"
                                                int csharp2cuda_temp_219 = (first)->count;
#line 662 "ProbabilityModule.cs"
                                                double csharp2cuda_temp_220 = (second)->scalar_value;
#line 664 "ProbabilityModule.cs"
                                                double* csharp2cuda_temp_221 = &(value);
#line 659 "ProbabilityModule.cs"
                                                bool csharp2cuda_temp_222 = mathblocks_probability_ordered_entropy_value(a, csharp2cuda_temp_219, csharp2cuda_temp_220, ((opcode) == (13)), csharp2cuda_temp_221);
                                                if ((!(csharp2cuda_temp_222)))
#line 665 "ProbabilityModule.cs"
                                                {
#line 666 "ProbabilityModule.cs"
#line 666 "ProbabilityModule.cs"
                                                    int* csharp2cuda_temp_223 = &((output)->valid);
                                                    (*(csharp2cuda_temp_223) = 0);
#line 667 "ProbabilityModule.cs"
                                                    return;
                                                }
                                            }
                                            else
                                            {
#line 670 "ProbabilityModule.cs"
                                                if (((opcode) == (14)))
#line 671 "ProbabilityModule.cs"
                                                {
#line 672 "ProbabilityModule.cs"
#line 672 "ProbabilityModule.cs"
                                                    double* csharp2cuda_temp_224 = &(value);
#line 672 "ProbabilityModule.cs"
                                                    int csharp2cuda_temp_225 = (first)->count;
#line 672 "ProbabilityModule.cs"
                                                    double csharp2cuda_temp_226 = mathblocks_probability_entropy(a, csharp2cuda_temp_225);
                                                    (*(csharp2cuda_temp_224) = csharp2cuda_temp_226);
                                                }
                                                else
                                                {
#line 674 "ProbabilityModule.cs"
                                                    if (((opcode) == (15)))
#line 675 "ProbabilityModule.cs"
                                                    {
#line 676 "ProbabilityModule.cs"
                                                        {
#line 676 "ProbabilityModule.cs"
                                                            int index = 0;
                                                            while (true)
                                                            {
#line 676 "ProbabilityModule.cs"
                                                                int csharp2cuda_temp_228 = (first)->count;
                                                                if (!(((index) < (csharp2cuda_temp_228))))
                                                                    break;
#line 677 "ProbabilityModule.cs"
#line 677 "ProbabilityModule.cs"
                                                                double* csharp2cuda_temp_229 = &(value);
#line 677 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_230 = *(csharp2cuda_temp_229);
#line 677 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_231 = (a)[index];
#line 677 "ProbabilityModule.cs"
                                                                double csharp2cuda_temp_232 = (b)[index];
                                                                (*(csharp2cuda_temp_229) = __dadd_rn(csharp2cuda_temp_230, fabs(__dsub_rn(csharp2cuda_temp_231, csharp2cuda_temp_232))));
#line 676 "ProbabilityModule.cs"
                                                                int* csharp2cuda_temp_227 = &(index);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_227));
                                                            }
                                                        }
#line 678 "ProbabilityModule.cs"
#line 678 "ProbabilityModule.cs"
                                                        double* csharp2cuda_temp_233 = &(value);
#line 678 "ProbabilityModule.cs"
                                                        double csharp2cuda_temp_234 = *(csharp2cuda_temp_233);
                                                        (*(csharp2cuda_temp_233) = __ddiv_rn(csharp2cuda_temp_234, 2.0));
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
#line 680 "ProbabilityModule.cs"
#line 680 "ProbabilityModule.cs"
        double* csharp2cuda_temp_235 = &((output)->scalar_value);
        (*(csharp2cuda_temp_235) = value);
#line 681 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 681 "ProbabilityModule.cs"
#line 681 "ProbabilityModule.cs"
            int* csharp2cuda_temp_236 = &((output)->valid);
            (*(csharp2cuda_temp_236) = 0);
        }
#line 682 "ProbabilityModule.cs"
        return;
    }
#line 685 "ProbabilityModule.cs"
    if (((opcode) == (17)))
#line 686 "ProbabilityModule.cs"
    {
#line 687 "ProbabilityModule.cs"
        double parameter = (second)->scalar_value;
#line 688 "ProbabilityModule.cs"
#line 688 "ProbabilityModule.cs"
        int csharp2cuda_temp_237 = (first)->count;
#line 688 "ProbabilityModule.cs"
        bool csharp2cuda_temp_238;
#line 688 "ProbabilityModule.cs"
        if (!(((csharp2cuda_temp_237) <= (0))))
        {
#line 688 "ProbabilityModule.cs"
            csharp2cuda_temp_238 = ((parameter) < (0.0));
        }
        else
        {
#line 688 "ProbabilityModule.cs"
            csharp2cuda_temp_238 = true;
        }
#line 688 "ProbabilityModule.cs"
        bool csharp2cuda_temp_239;
#line 688 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_238))
        {
#line 688 "ProbabilityModule.cs"
            csharp2cuda_temp_239 = ((parameter) > (1.0));
        }
        else
        {
#line 688 "ProbabilityModule.cs"
            csharp2cuda_temp_239 = true;
        }
        if (csharp2cuda_temp_239)
#line 689 "ProbabilityModule.cs"
        {
#line 690 "ProbabilityModule.cs"
#line 690 "ProbabilityModule.cs"
            int* csharp2cuda_temp_240 = &((output)->valid);
            (*(csharp2cuda_temp_240) = 0);
#line 691 "ProbabilityModule.cs"
            return;
        }
#line 693 "ProbabilityModule.cs"
        int csharp2cuda_temp_241 = (first)->count;
#line 693 "ProbabilityModule.cs"
        int degree = csharp2cuda_i32_sub(csharp2cuda_temp_241, 1);
#line 694 "ProbabilityModule.cs"
        double value = 0.0;
#line 695 "ProbabilityModule.cs"
        {
#line 695 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (degree))))
                    break;
#line 696 "ProbabilityModule.cs"
#line 696 "ProbabilityModule.cs"
                double* csharp2cuda_temp_243 = &(value);
#line 696 "ProbabilityModule.cs"
                double csharp2cuda_temp_244 = *(csharp2cuda_temp_243);
#line 696 "ProbabilityModule.cs"
                double csharp2cuda_temp_245 = (a)[index];
                (*(csharp2cuda_temp_243) = __dadd_rn(csharp2cuda_temp_244, __dmul_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_245, mathblocks_probability_binomial(degree, index)), mathblocks_power(parameter, ((double)(index)))), mathblocks_power(__dsub_rn(1.0, parameter), ((double)(csharp2cuda_i32_sub(degree, index)))))));
#line 695 "ProbabilityModule.cs"
                int* csharp2cuda_temp_242 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_242));
            }
        }
#line 699 "ProbabilityModule.cs"
#line 699 "ProbabilityModule.cs"
        double* csharp2cuda_temp_246 = &((output)->scalar_value);
        (*(csharp2cuda_temp_246) = value);
#line 700 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 700 "ProbabilityModule.cs"
#line 700 "ProbabilityModule.cs"
            int* csharp2cuda_temp_247 = &((output)->valid);
            (*(csharp2cuda_temp_247) = 0);
        }
#line 701 "ProbabilityModule.cs"
        return;
    }
#line 704 "ProbabilityModule.cs"
    if (((opcode) == (18)))
#line 705 "ProbabilityModule.cs"
    {
#line 706 "ProbabilityModule.cs"
#line 706 "ProbabilityModule.cs"
        int csharp2cuda_temp_248 = (first)->count;
        if (((csharp2cuda_temp_248) != (4)))
#line 707 "ProbabilityModule.cs"
        {
#line 708 "ProbabilityModule.cs"
#line 708 "ProbabilityModule.cs"
            int* csharp2cuda_temp_249 = &((output)->valid);
            (*(csharp2cuda_temp_249) = 0);
#line 709 "ProbabilityModule.cs"
            return;
        }
#line 711 "ProbabilityModule.cs"
        unsigned long long csharp2cuda_temp_250 = (output)->data_pointer;
#line 711 "ProbabilityModule.cs"
        MathBlockComplexValue* roots = ((MathBlockComplexValue*)(csharp2cuda_temp_250));
#line 712 "ProbabilityModule.cs"
        mathblocks_complex_shape(output, 3);
#line 713 "ProbabilityModule.cs"
        double constant = (a)[0];
#line 714 "ProbabilityModule.cs"
        double linear = (a)[1];
#line 715 "ProbabilityModule.cs"
        double quadratic = (a)[2];
#line 716 "ProbabilityModule.cs"
        double leading = (a)[3];
#line 717 "ProbabilityModule.cs"
        if (((leading) == (0.0)))
#line 718 "ProbabilityModule.cs"
        {
#line 719 "ProbabilityModule.cs"
#line 719 "ProbabilityModule.cs"
            int* csharp2cuda_temp_251 = &((output)->valid);
            (*(csharp2cuda_temp_251) = 0);
#line 720 "ProbabilityModule.cs"
            return;
        }
#line 722 "ProbabilityModule.cs"
        double normalized_a = __ddiv_rn(quadratic, leading);
#line 723 "ProbabilityModule.cs"
        double normalized_b = __ddiv_rn(linear, leading);
#line 724 "ProbabilityModule.cs"
        double normalized_c = __ddiv_rn(constant, leading);
#line 725 "ProbabilityModule.cs"
        double csharp2cuda_temp_252 = __ddiv_rn(__dmul_rn(normalized_a, normalized_a), 3.0);
#line 725 "ProbabilityModule.cs"
        double p = __dsub_rn(normalized_b, csharp2cuda_temp_252);
#line 726 "ProbabilityModule.cs"
        double csharp2cuda_temp_253 = __ddiv_rn(__dmul_rn(__dmul_rn(__dmul_rn(2.0, normalized_a), normalized_a), normalized_a), 27.0);
#line 727 "ProbabilityModule.cs"
        double csharp2cuda_temp_254 = __ddiv_rn(__dmul_rn(normalized_a, normalized_b), 3.0);
#line 726 "ProbabilityModule.cs"
        double q = __dadd_rn(__dsub_rn(csharp2cuda_temp_253, csharp2cuda_temp_254), normalized_c);
#line 729 "ProbabilityModule.cs"
        double csharp2cuda_temp_255 = __ddiv_rn(__dmul_rn(q, q), 4.0);
#line 729 "ProbabilityModule.cs"
        double csharp2cuda_temp_256 = __ddiv_rn(__dmul_rn(__dmul_rn(p, p), p), 27.0);
#line 728 "ProbabilityModule.cs"
        MathBlockComplexValue square_root = mathblocks_complex_square_root(mathblocks_complex_make(__dadd_rn(csharp2cuda_temp_255, csharp2cuda_temp_256), 0.0));
#line 731 "ProbabilityModule.cs"
        double csharp2cuda_temp_257 = __ddiv_rn((-(q)), 2.0);
#line 730 "ProbabilityModule.cs"
        MathBlockComplexValue u = mathblocks_probability_complex_cube_root(mathblocks_complex_add(mathblocks_complex_make(csharp2cuda_temp_257, 0.0), square_root));
#line 732 "ProbabilityModule.cs"
        double csharp2cuda_temp_258 = (u).real;
#line 732 "ProbabilityModule.cs"
        bool csharp2cuda_temp_259;
#line 732 "ProbabilityModule.cs"
        if (((csharp2cuda_temp_258) == (0.0)))
        {
#line 732 "ProbabilityModule.cs"
            double csharp2cuda_temp_260 = (u).imaginary;
#line 732 "ProbabilityModule.cs"
            csharp2cuda_temp_259 = ((csharp2cuda_temp_260) == (0.0));
        }
        else
        {
#line 732 "ProbabilityModule.cs"
            csharp2cuda_temp_259 = false;
        }
#line 732 "ProbabilityModule.cs"
        MathBlockComplexValue csharp2cuda_temp_261;
#line 732 "ProbabilityModule.cs"
        if (csharp2cuda_temp_259)
        {
#line 734 "ProbabilityModule.cs"
            double csharp2cuda_temp_262 = __ddiv_rn((-(q)), 2.0);
#line 732 "ProbabilityModule.cs"
            csharp2cuda_temp_261 = mathblocks_probability_complex_cube_root(mathblocks_complex_subtract(mathblocks_complex_make(csharp2cuda_temp_262, 0.0), square_root));
        }
        else
        {
#line 732 "ProbabilityModule.cs"
            csharp2cuda_temp_261 = mathblocks_complex_divide(mathblocks_complex_make((-(p)), 0.0), mathblocks_complex_multiply(mathblocks_complex_make(3.0, 0.0), u));
        }
#line 732 "ProbabilityModule.cs"
        MathBlockComplexValue v = csharp2cuda_temp_261;
#line 740 "ProbabilityModule.cs"
        double csharp2cuda_temp_263 = __ddiv_rn(mathblocks_square_root(3.0), 2.0);
#line 738 "ProbabilityModule.cs"
        MathBlockComplexValue omega = mathblocks_complex_make((-(0.5)), csharp2cuda_temp_263);
#line 741 "ProbabilityModule.cs"
#line 741 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_264 = &((roots)[0]);
#line 743 "ProbabilityModule.cs"
        double csharp2cuda_temp_265 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_264) = mathblocks_complex_subtract(mathblocks_complex_add(u, v), mathblocks_complex_make(csharp2cuda_temp_265, 0.0)));
#line 744 "ProbabilityModule.cs"
#line 744 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_266 = &((roots)[1]);
#line 748 "ProbabilityModule.cs"
        double csharp2cuda_temp_267 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_266) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(omega, u), mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), v)), mathblocks_complex_make(csharp2cuda_temp_267, 0.0)));
#line 749 "ProbabilityModule.cs"
#line 749 "ProbabilityModule.cs"
        MathBlockComplexValue* csharp2cuda_temp_268 = &((roots)[2]);
#line 753 "ProbabilityModule.cs"
        double csharp2cuda_temp_269 = __ddiv_rn(normalized_a, 3.0);
        (*(csharp2cuda_temp_268) = mathblocks_complex_subtract(mathblocks_complex_add(mathblocks_complex_multiply(mathblocks_complex_conjugate(omega), u), mathblocks_complex_multiply(omega, v)), mathblocks_complex_make(csharp2cuda_temp_269, 0.0)));
#line 754 "ProbabilityModule.cs"
        {
#line 754 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (3))))
                    break;
#line 755 "ProbabilityModule.cs"
#line 755 "ProbabilityModule.cs"
                MathBlockComplexValue csharp2cuda_temp_271 = (roots)[index];
                if ((!(mathblocks_complex_finite(csharp2cuda_temp_271))))
                {
#line 755 "ProbabilityModule.cs"
#line 755 "ProbabilityModule.cs"
                    int* csharp2cuda_temp_272 = &((output)->valid);
                    (*(csharp2cuda_temp_272) = 0);
                }
#line 754 "ProbabilityModule.cs"
                int* csharp2cuda_temp_270 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_270));
            }
        }
#line 756 "ProbabilityModule.cs"
        return;
    }
#line 759 "ProbabilityModule.cs"
    if (((opcode) == (20)))
#line 760 "ProbabilityModule.cs"
    {
#line 761 "ProbabilityModule.cs"
        int order = 0;
#line 762 "ProbabilityModule.cs"
#line 762 "ProbabilityModule.cs"
        double csharp2cuda_temp_273 = (second)->scalar_value;
#line 762 "ProbabilityModule.cs"
        int* csharp2cuda_temp_274 = &(order);
#line 762 "ProbabilityModule.cs"
        bool csharp2cuda_temp_275 = mathblocks_probability_integer(csharp2cuda_temp_273, csharp2cuda_temp_274);
#line 762 "ProbabilityModule.cs"
        bool csharp2cuda_temp_276;
#line 762 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_275))))
        {
#line 762 "ProbabilityModule.cs"
            csharp2cuda_temp_276 = ((order) < (0));
        }
        else
        {
#line 762 "ProbabilityModule.cs"
            csharp2cuda_temp_276 = true;
        }
#line 762 "ProbabilityModule.cs"
        bool csharp2cuda_temp_277;
#line 762 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_276))
        {
#line 763 "ProbabilityModule.cs"
            int csharp2cuda_temp_278 = (first)->count;
#line 762 "ProbabilityModule.cs"
            csharp2cuda_temp_277 = ((order) > (csharp2cuda_temp_278));
        }
        else
        {
#line 762 "ProbabilityModule.cs"
            csharp2cuda_temp_277 = true;
        }
#line 762 "ProbabilityModule.cs"
        bool csharp2cuda_temp_279;
#line 762 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_277))
        {
#line 762 "ProbabilityModule.cs"
            csharp2cuda_temp_279 = ((((void*)(scratch))) == (((void*)(nullptr))));
        }
        else
        {
#line 762 "ProbabilityModule.cs"
            csharp2cuda_temp_279 = true;
        }
        if (csharp2cuda_temp_279)
#line 764 "ProbabilityModule.cs"
        {
#line 765 "ProbabilityModule.cs"
#line 765 "ProbabilityModule.cs"
            int* csharp2cuda_temp_280 = &((output)->valid);
            (*(csharp2cuda_temp_280) = 0);
#line 766 "ProbabilityModule.cs"
            return;
        }
#line 768 "ProbabilityModule.cs"
        {
#line 768 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) <= (order))))
                    break;
#line 768 "ProbabilityModule.cs"
#line 768 "ProbabilityModule.cs"
                double* csharp2cuda_temp_282 = &((scratch)[index]);
                (*(csharp2cuda_temp_282) = 0.0);
#line 768 "ProbabilityModule.cs"
                int* csharp2cuda_temp_281 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_281));
            }
        }
#line 769 "ProbabilityModule.cs"
#line 769 "ProbabilityModule.cs"
        double* csharp2cuda_temp_283 = &((scratch)[0]);
        (*(csharp2cuda_temp_283) = 1.0);
#line 770 "ProbabilityModule.cs"
        {
#line 770 "ProbabilityModule.cs"
            int value_index = 0;
            while (true)
            {
#line 770 "ProbabilityModule.cs"
                int csharp2cuda_temp_285 = (first)->count;
                if (!(((value_index) < (csharp2cuda_temp_285))))
                    break;
#line 771 "ProbabilityModule.cs"
                {
#line 772 "ProbabilityModule.cs"
                    int csharp2cuda_temp_286;
#line 772 "ProbabilityModule.cs"
                    if (((order) < (csharp2cuda_i32_add(value_index, 1))))
                    {
#line 772 "ProbabilityModule.cs"
                        csharp2cuda_temp_286 = order;
                    }
                    else
                    {
#line 772 "ProbabilityModule.cs"
                        csharp2cuda_temp_286 = csharp2cuda_i32_add(value_index, 1);
                    }
#line 772 "ProbabilityModule.cs"
                    int maximum = csharp2cuda_temp_286;
#line 773 "ProbabilityModule.cs"
                    {
#line 773 "ProbabilityModule.cs"
                        int degree = maximum;
                        while (true)
                        {
                            if (!(((degree) >= (1))))
                                break;
#line 774 "ProbabilityModule.cs"
#line 774 "ProbabilityModule.cs"
                            double* csharp2cuda_temp_288 = &((scratch)[degree]);
#line 774 "ProbabilityModule.cs"
                            double csharp2cuda_temp_289 = *(csharp2cuda_temp_288);
#line 774 "ProbabilityModule.cs"
                            double csharp2cuda_temp_290 = (a)[value_index];
#line 774 "ProbabilityModule.cs"
                            double csharp2cuda_temp_291 = (scratch)[csharp2cuda_i32_sub(degree, 1)];
                            (*(csharp2cuda_temp_288) = __dadd_rn(csharp2cuda_temp_289, __dmul_rn(csharp2cuda_temp_290, csharp2cuda_temp_291)));
#line 773 "ProbabilityModule.cs"
                            int* csharp2cuda_temp_287 = &(degree);
                            csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_287));
                        }
                    }
                }
#line 770 "ProbabilityModule.cs"
                int* csharp2cuda_temp_284 = &(value_index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_284));
            }
        }
#line 776 "ProbabilityModule.cs"
#line 776 "ProbabilityModule.cs"
        double* csharp2cuda_temp_292 = &((output)->scalar_value);
#line 776 "ProbabilityModule.cs"
        double csharp2cuda_temp_293 = (scratch)[order];
        (*(csharp2cuda_temp_292) = csharp2cuda_temp_293);
#line 777 "ProbabilityModule.cs"
#line 777 "ProbabilityModule.cs"
        double csharp2cuda_temp_294 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_294))))
        {
#line 777 "ProbabilityModule.cs"
#line 777 "ProbabilityModule.cs"
            int* csharp2cuda_temp_295 = &((output)->valid);
            (*(csharp2cuda_temp_295) = 0);
        }
#line 778 "ProbabilityModule.cs"
        return;
    }
#line 781 "ProbabilityModule.cs"
    if (((opcode) == (21)))
#line 782 "ProbabilityModule.cs"
    {
#line 783 "ProbabilityModule.cs"
        double value = 0.0;
#line 784 "ProbabilityModule.cs"
        {
#line 784 "ProbabilityModule.cs"
            int csharp2cuda_temp_296 = (first)->count;
#line 784 "ProbabilityModule.cs"
            int index = csharp2cuda_i32_sub(csharp2cuda_temp_296, 1);
            while (true)
            {
                if (!(((index) >= (0))))
                    break;
#line 785 "ProbabilityModule.cs"
#line 785 "ProbabilityModule.cs"
                double* csharp2cuda_temp_298 = &(value);
#line 785 "ProbabilityModule.cs"
                double csharp2cuda_temp_299 = (second)->scalar_value;
#line 785 "ProbabilityModule.cs"
                double csharp2cuda_temp_300 = (a)[index];
                (*(csharp2cuda_temp_298) = __dadd_rn(__dmul_rn(value, csharp2cuda_temp_299), csharp2cuda_temp_300));
#line 784 "ProbabilityModule.cs"
                int* csharp2cuda_temp_297 = &(index);
                csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_297));
            }
        }
#line 786 "ProbabilityModule.cs"
#line 786 "ProbabilityModule.cs"
        double* csharp2cuda_temp_301 = &((output)->scalar_value);
        (*(csharp2cuda_temp_301) = value);
#line 787 "ProbabilityModule.cs"
        if ((!(isfinite(value))))
        {
#line 787 "ProbabilityModule.cs"
#line 787 "ProbabilityModule.cs"
            int* csharp2cuda_temp_302 = &((output)->valid);
            (*(csharp2cuda_temp_302) = 0);
        }
#line 788 "ProbabilityModule.cs"
        return;
    }
#line 791 "ProbabilityModule.cs"
    if (((opcode) == (22)))
#line 792 "ProbabilityModule.cs"
    {
#line 793 "ProbabilityModule.cs"
#line 793 "ProbabilityModule.cs"
        int csharp2cuda_temp_303 = (first)->count;
        if (((csharp2cuda_temp_303) <= (0)))
#line 794 "ProbabilityModule.cs"
        {
#line 795 "ProbabilityModule.cs"
#line 795 "ProbabilityModule.cs"
            int* csharp2cuda_temp_304 = &((output)->valid);
            (*(csharp2cuda_temp_304) = 0);
#line 796 "ProbabilityModule.cs"
            return;
        }
#line 798 "ProbabilityModule.cs"
        double maximum = (a)[0];
#line 799 "ProbabilityModule.cs"
        {
#line 799 "ProbabilityModule.cs"
            int index = 1;
            while (true)
            {
#line 799 "ProbabilityModule.cs"
                int csharp2cuda_temp_306 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_306))))
                    break;
#line 800 "ProbabilityModule.cs"
#line 800 "ProbabilityModule.cs"
                double* csharp2cuda_temp_307 = &(maximum);
#line 800 "ProbabilityModule.cs"
                double csharp2cuda_temp_308 = (a)[index];
                (*(csharp2cuda_temp_307) = mathblocks_maximum(maximum, csharp2cuda_temp_308));
#line 799 "ProbabilityModule.cs"
                int* csharp2cuda_temp_305 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_305));
            }
        }
#line 801 "ProbabilityModule.cs"
        double sum = 0.0;
#line 802 "ProbabilityModule.cs"
        {
#line 802 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
#line 802 "ProbabilityModule.cs"
                int csharp2cuda_temp_310 = (first)->count;
                if (!(((index) < (csharp2cuda_temp_310))))
                    break;
#line 803 "ProbabilityModule.cs"
#line 803 "ProbabilityModule.cs"
                double* csharp2cuda_temp_311 = &(sum);
#line 803 "ProbabilityModule.cs"
                double csharp2cuda_temp_312 = *(csharp2cuda_temp_311);
#line 803 "ProbabilityModule.cs"
                double csharp2cuda_temp_313 = (a)[index];
                (*(csharp2cuda_temp_311) = __dadd_rn(csharp2cuda_temp_312, mathblocks_exponential(__dsub_rn(csharp2cuda_temp_313, maximum))));
#line 802 "ProbabilityModule.cs"
                int* csharp2cuda_temp_309 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_309));
            }
        }
#line 804 "ProbabilityModule.cs"
#line 804 "ProbabilityModule.cs"
        double* csharp2cuda_temp_314 = &((output)->scalar_value);
        (*(csharp2cuda_temp_314) = __dadd_rn(maximum, mathblocks_natural_logarithm(sum)));
#line 805 "ProbabilityModule.cs"
#line 805 "ProbabilityModule.cs"
        double csharp2cuda_temp_315 = (output)->scalar_value;
        if ((!(isfinite(csharp2cuda_temp_315))))
        {
#line 805 "ProbabilityModule.cs"
#line 805 "ProbabilityModule.cs"
            int* csharp2cuda_temp_316 = &((output)->valid);
            (*(csharp2cuda_temp_316) = 0);
        }
#line 806 "ProbabilityModule.cs"
        return;
    }
#line 809 "ProbabilityModule.cs"
#line 809 "ProbabilityModule.cs"
    int* csharp2cuda_temp_317 = &((output)->valid);
    (*(csharp2cuda_temp_317) = 0);
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

#line 237 "ProbabilityModule.cs"
__device__ double mathblocks_probability_incomplete_beta(
    double x,
    double left,
    double right)
#line 242 "ProbabilityModule.cs"
{
#line 243 "ProbabilityModule.cs"
    if (((x) == (0.0)))
    {
#line 243 "ProbabilityModule.cs"
        return 0.0;
    }
#line 244 "ProbabilityModule.cs"
    if (((x) == (1.0)))
    {
#line 244 "ProbabilityModule.cs"
        return 1.0;
    }
#line 245 "ProbabilityModule.cs"
    double front = mathblocks_exponential(__dadd_rn(__dadd_rn(__dsub_rn(__dsub_rn(mathblocks_probability_log_gamma(__dadd_rn(left, right)), mathblocks_probability_log_gamma(left)), mathblocks_probability_log_gamma(right)), __dmul_rn(left, mathblocks_natural_logarithm(x))), __dmul_rn(right, mathblocks_log_one_plus((-(x))))));
#line 251 "ProbabilityModule.cs"
#line 251 "ProbabilityModule.cs"
    double csharp2cuda_temp_0 = __ddiv_rn(__dadd_rn(left, 1.0), __dadd_rn(__dadd_rn(left, right), 2.0));
#line 251 "ProbabilityModule.cs"
    double csharp2cuda_temp_1;
#line 251 "ProbabilityModule.cs"
    if (((x) < (csharp2cuda_temp_0)))
    {
#line 251 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = __ddiv_rn(__dmul_rn(front, mathblocks_probability_beta_fraction(x, left, right)), left);
    }
    else
    {
#line 253 "ProbabilityModule.cs"
        double csharp2cuda_temp_2 = __ddiv_rn(__dmul_rn(front, mathblocks_probability_beta_fraction(__dsub_rn(1.0, x), right, left)), right);
#line 251 "ProbabilityModule.cs"
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

#line 184 "ProbabilityModule.cs"
__device__ double mathblocks_probability_log_gamma(double value)
#line 186 "ProbabilityModule.cs"
{
#line 187 "ProbabilityModule.cs"
    if (((value) < (0.5)))
#line 188 "ProbabilityModule.cs"
    {
#line 189 "ProbabilityModule.cs"
        return __dsub_rn(__dsub_rn(mathblocks_natural_logarithm(3.141592653589793), mathblocks_natural_logarithm(mathblocks_sine(__dmul_rn(3.141592653589793, value)))), mathblocks_probability_log_gamma_core(__dsub_rn(1.0, value)));
    }
#line 194 "ProbabilityModule.cs"
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
#line 176 "ProbabilityModule.cs"
    double shifted = __dadd_rn(value, 8.0);
#line 177 "ProbabilityModule.cs"
    double t = __dsub_rn(shifted, 0.5);
#line 178 "ProbabilityModule.cs"
    return __dadd_rn(__dsub_rn(__dadd_rn(__dmul_rn(0.5, mathblocks_natural_logarithm(__dmul_rn(2.0, 3.141592653589793))), __dmul_rn(__dadd_rn(value, 0.5), mathblocks_natural_logarithm(t))), t), mathblocks_natural_logarithm(sum));
}

#line 269 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_ordered_entropy_value(
    const double* values,
    int count,
    double order,
    bool renyi,
    double* value)
#line 276 "ProbabilityModule.cs"
{
#line 277 "ProbabilityModule.cs"
    if (((order) <= (0.0)))
    {
#line 278 "ProbabilityModule.cs"
        return false;
    }
#line 279 "ProbabilityModule.cs"
    if (((order) == (1.0)))
#line 280 "ProbabilityModule.cs"
    {
#line 281 "ProbabilityModule.cs"
#line 281 "ProbabilityModule.cs"
        double* csharp2cuda_temp_0 = value;
#line 281 "ProbabilityModule.cs"
        double csharp2cuda_temp_1 = mathblocks_probability_entropy(values, count);
        (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
    }
    else
#line 284 "ProbabilityModule.cs"
    {
#line 285 "ProbabilityModule.cs"
        double sum = 0.0;
#line 286 "ProbabilityModule.cs"
        {
#line 286 "ProbabilityModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 287 "ProbabilityModule.cs"
#line 287 "ProbabilityModule.cs"
                double* csharp2cuda_temp_3 = &(sum);
#line 287 "ProbabilityModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 287 "ProbabilityModule.cs"
                double csharp2cuda_temp_5 = (values)[index];
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, mathblocks_power(csharp2cuda_temp_5, order)));
#line 286 "ProbabilityModule.cs"
                int* csharp2cuda_temp_2 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
            }
        }
#line 288 "ProbabilityModule.cs"
#line 288 "ProbabilityModule.cs"
        double* csharp2cuda_temp_6 = value;
#line 288 "ProbabilityModule.cs"
        double csharp2cuda_temp_7;
#line 288 "ProbabilityModule.cs"
        if (renyi)
        {
#line 288 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = __ddiv_rn(mathblocks_natural_logarithm(sum), __dsub_rn(1.0, order));
        }
        else
        {
#line 288 "ProbabilityModule.cs"
            csharp2cuda_temp_7 = __ddiv_rn(__dsub_rn(1.0, sum), __dsub_rn(order, 1.0));
        }
        (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
    }
#line 292 "ProbabilityModule.cs"
    return true;
}

#line 299 "ProbabilityModule.cs"
__device__ bool mathblocks_probability_scalar_value(int opcode, double a, double b, double c, double* value)
#line 301 "ProbabilityModule.cs"
{
#line 302 "ProbabilityModule.cs"
#line 302 "ProbabilityModule.cs"
    double* csharp2cuda_temp_0 = value;
    (*(csharp2cuda_temp_0) = 0.0);
#line 303 "ProbabilityModule.cs"
#line 303 "ProbabilityModule.cs"
    bool csharp2cuda_temp_1;
#line 303 "ProbabilityModule.cs"
    if (!(((opcode) == (0))))
    {
#line 303 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = ((opcode) == (1));
    }
    else
    {
#line 303 "ProbabilityModule.cs"
        csharp2cuda_temp_1 = true;
    }
#line 303 "ProbabilityModule.cs"
    bool csharp2cuda_temp_2;
#line 303 "ProbabilityModule.cs"
    if (!(csharp2cuda_temp_1))
    {
#line 303 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = ((opcode) == (2));
    }
    else
    {
#line 303 "ProbabilityModule.cs"
        csharp2cuda_temp_2 = true;
    }
    if (csharp2cuda_temp_2)
#line 304 "ProbabilityModule.cs"
    {
#line 305 "ProbabilityModule.cs"
        int first_integer = 0;
#line 306 "ProbabilityModule.cs"
        int second_integer = 0;
#line 307 "ProbabilityModule.cs"
#line 307 "ProbabilityModule.cs"
        int* csharp2cuda_temp_3 = &(first_integer);
#line 307 "ProbabilityModule.cs"
        bool csharp2cuda_temp_4 = mathblocks_probability_integer(a, csharp2cuda_temp_3);
#line 307 "ProbabilityModule.cs"
        bool csharp2cuda_temp_5;
#line 307 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_4))))
        {
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_5 = ((first_integer) < (0));
        }
        else
        {
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_5 = true;
        }
#line 307 "ProbabilityModule.cs"
        bool csharp2cuda_temp_6;
#line 307 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_5))
        {
#line 308 "ProbabilityModule.cs"
            bool csharp2cuda_temp_7;
#line 308 "ProbabilityModule.cs"
            if (((opcode) != (2)))
            {
#line 308 "ProbabilityModule.cs"
                int* csharp2cuda_temp_8 = &(second_integer);
#line 308 "ProbabilityModule.cs"
                bool csharp2cuda_temp_9 = mathblocks_probability_integer(b, csharp2cuda_temp_8);
#line 308 "ProbabilityModule.cs"
                csharp2cuda_temp_7 = (!(csharp2cuda_temp_9));
            }
            else
            {
#line 308 "ProbabilityModule.cs"
                csharp2cuda_temp_7 = false;
            }
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_6 = csharp2cuda_temp_7;
        }
        else
        {
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_6 = true;
        }
#line 307 "ProbabilityModule.cs"
        bool csharp2cuda_temp_10;
#line 307 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_6))
        {
#line 309 "ProbabilityModule.cs"
            bool csharp2cuda_temp_11;
#line 309 "ProbabilityModule.cs"
            if (((opcode) == (2)))
            {
#line 309 "ProbabilityModule.cs"
                csharp2cuda_temp_11 = ((first_integer) > (170));
            }
            else
            {
#line 309 "ProbabilityModule.cs"
                csharp2cuda_temp_11 = false;
            }
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_10 = csharp2cuda_temp_11;
        }
        else
        {
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_10 = true;
        }
#line 307 "ProbabilityModule.cs"
        bool csharp2cuda_temp_12;
#line 307 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_10))
        {
#line 310 "ProbabilityModule.cs"
            bool csharp2cuda_temp_13;
#line 310 "ProbabilityModule.cs"
            if (((opcode) == (0)))
            {
#line 310 "ProbabilityModule.cs"
                bool csharp2cuda_temp_14;
#line 310 "ProbabilityModule.cs"
                if (!(((first_integer) <= (second_integer))))
                {
#line 310 "ProbabilityModule.cs"
                    csharp2cuda_temp_14 = ((second_integer) < (0));
                }
                else
                {
#line 310 "ProbabilityModule.cs"
                    csharp2cuda_temp_14 = true;
                }
#line 310 "ProbabilityModule.cs"
                csharp2cuda_temp_13 = csharp2cuda_temp_14;
            }
            else
            {
#line 310 "ProbabilityModule.cs"
                csharp2cuda_temp_13 = false;
            }
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_12 = csharp2cuda_temp_13;
        }
        else
        {
#line 307 "ProbabilityModule.cs"
            csharp2cuda_temp_12 = true;
        }
        if (csharp2cuda_temp_12)
#line 311 "ProbabilityModule.cs"
        {
#line 312 "ProbabilityModule.cs"
            return false;
        }
#line 314 "ProbabilityModule.cs"
        if (((opcode) == (0)))
#line 315 "ProbabilityModule.cs"
        {
#line 316 "ProbabilityModule.cs"
#line 316 "ProbabilityModule.cs"
            double* csharp2cuda_temp_15 = value;
#line 316 "ProbabilityModule.cs"
            double csharp2cuda_temp_16 = __ddiv_rn(((double)(csharp2cuda_i32_sub(first_integer, second_integer))), ((double)(csharp2cuda_i32_add(first_integer, second_integer))));
            (*(csharp2cuda_temp_15) = __dmul_rn(csharp2cuda_temp_16, mathblocks_probability_binomial(csharp2cuda_i32_add(first_integer, second_integer), second_integer)));
        }
        else
        {
#line 320 "ProbabilityModule.cs"
            if (((opcode) == (1)))
#line 321 "ProbabilityModule.cs"
            {
#line 322 "ProbabilityModule.cs"
#line 322 "ProbabilityModule.cs"
                double* csharp2cuda_temp_17 = value;
                (*(csharp2cuda_temp_17) = mathblocks_probability_binomial(first_integer, second_integer));
            }
            else
#line 325 "ProbabilityModule.cs"
            {
#line 326 "ProbabilityModule.cs"
                double factorial = 1.0;
#line 327 "ProbabilityModule.cs"
                {
#line 327 "ProbabilityModule.cs"
                    int index = 2;
                    while (true)
                    {
                        if (!(((index) <= (first_integer))))
                            break;
#line 327 "ProbabilityModule.cs"
#line 327 "ProbabilityModule.cs"
                        double* csharp2cuda_temp_19 = &(factorial);
#line 327 "ProbabilityModule.cs"
                        double csharp2cuda_temp_20 = *(csharp2cuda_temp_19);
                        (*(csharp2cuda_temp_19) = __dmul_rn(csharp2cuda_temp_20, ((double)(index))));
#line 327 "ProbabilityModule.cs"
                        int* csharp2cuda_temp_18 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
                    }
                }
#line 328 "ProbabilityModule.cs"
#line 328 "ProbabilityModule.cs"
                double* csharp2cuda_temp_21 = value;
                (*(csharp2cuda_temp_21) = factorial);
            }
        }
#line 330 "ProbabilityModule.cs"
#line 330 "ProbabilityModule.cs"
        double csharp2cuda_temp_22 = *(value);
        return isfinite(csharp2cuda_temp_22);
    }
#line 333 "ProbabilityModule.cs"
    if (((opcode) == (23)))
#line 334 "ProbabilityModule.cs"
    {
#line 335 "ProbabilityModule.cs"
#line 335 "ProbabilityModule.cs"
        double* csharp2cuda_temp_23 = value;
#line 335 "ProbabilityModule.cs"
        double csharp2cuda_temp_24 = __ddiv_rn(a, mathblocks_square_root(2.0));
        (*(csharp2cuda_temp_23) = __dmul_rn(0.5, __dadd_rn(1.0, mathblocks_error_function(csharp2cuda_temp_24))));
#line 336 "ProbabilityModule.cs"
#line 336 "ProbabilityModule.cs"
        double csharp2cuda_temp_25 = *(value);
        return isfinite(csharp2cuda_temp_25);
    }
#line 339 "ProbabilityModule.cs"
#line 339 "ProbabilityModule.cs"
    bool csharp2cuda_temp_26;
#line 339 "ProbabilityModule.cs"
    if (!(((opcode) == (25))))
    {
#line 339 "ProbabilityModule.cs"
        csharp2cuda_temp_26 = ((opcode) == (26));
    }
    else
    {
#line 339 "ProbabilityModule.cs"
        csharp2cuda_temp_26 = true;
    }
    if (csharp2cuda_temp_26)
#line 340 "ProbabilityModule.cs"
    {
#line 341 "ProbabilityModule.cs"
        int count = 0;
#line 342 "ProbabilityModule.cs"
        double rate = a;
#line 343 "ProbabilityModule.cs"
#line 343 "ProbabilityModule.cs"
        int* csharp2cuda_temp_27 = &(count);
#line 343 "ProbabilityModule.cs"
        bool csharp2cuda_temp_28 = mathblocks_probability_integer(b, csharp2cuda_temp_27);
#line 343 "ProbabilityModule.cs"
        bool csharp2cuda_temp_29;
#line 343 "ProbabilityModule.cs"
        if (!((!(csharp2cuda_temp_28))))
        {
#line 343 "ProbabilityModule.cs"
            csharp2cuda_temp_29 = ((count) < (0));
        }
        else
        {
#line 343 "ProbabilityModule.cs"
            csharp2cuda_temp_29 = true;
        }
#line 343 "ProbabilityModule.cs"
        bool csharp2cuda_temp_30;
#line 343 "ProbabilityModule.cs"
        if (!(csharp2cuda_temp_29))
        {
#line 343 "ProbabilityModule.cs"
            csharp2cuda_temp_30 = ((rate) < (0.0));
        }
        else
        {
#line 343 "ProbabilityModule.cs"
            csharp2cuda_temp_30 = true;
        }
        if (csharp2cuda_temp_30)
        {
#line 344 "ProbabilityModule.cs"
            return false;
        }
#line 345 "ProbabilityModule.cs"
        double sum = 0.0;
#line 346 "ProbabilityModule.cs"
        int csharp2cuda_temp_31;
#line 346 "ProbabilityModule.cs"
        if (((opcode) == (25)))
        {
#line 346 "ProbabilityModule.cs"
            csharp2cuda_temp_31 = 0;
        }
        else
        {
#line 346 "ProbabilityModule.cs"
            csharp2cuda_temp_31 = count;
        }
#line 346 "ProbabilityModule.cs"
        int start = csharp2cuda_temp_31;
#line 347 "ProbabilityModule.cs"
        int end = count;
#line 348 "ProbabilityModule.cs"
        {
#line 348 "ProbabilityModule.cs"
            int index = start;
            while (true)
            {
                if (!(((index) <= (end))))
                    break;
#line 349 "ProbabilityModule.cs"
                {
#line 350 "ProbabilityModule.cs"
                    double csharp2cuda_temp_33;
#line 350 "ProbabilityModule.cs"
                    if (((rate) == (0.0)))
                    {
#line 351 "ProbabilityModule.cs"
                        double csharp2cuda_temp_34;
#line 351 "ProbabilityModule.cs"
                        if (((index) == (0)))
                        {
#line 351 "ProbabilityModule.cs"
                            csharp2cuda_temp_34 = 1.0;
                        }
                        else
                        {
#line 351 "ProbabilityModule.cs"
                            csharp2cuda_temp_34 = 0.0;
                        }
#line 350 "ProbabilityModule.cs"
                        csharp2cuda_temp_33 = csharp2cuda_temp_34;
                    }
                    else
                    {
#line 350 "ProbabilityModule.cs"
                        csharp2cuda_temp_33 = mathblocks_exponential(__dsub_rn(__dadd_rn((-(rate)), __dmul_rn(((double)(index)), mathblocks_natural_logarithm(rate))), mathblocks_probability_log_gamma(__dadd_rn(((double)(index)), 1.0))));
                    }
#line 350 "ProbabilityModule.cs"
                    double probability = csharp2cuda_temp_33;
#line 355 "ProbabilityModule.cs"
#line 355 "ProbabilityModule.cs"
                    double* csharp2cuda_temp_35 = &(sum);
#line 355 "ProbabilityModule.cs"
                    double csharp2cuda_temp_36 = *(csharp2cuda_temp_35);
                    (*(csharp2cuda_temp_35) = __dadd_rn(csharp2cuda_temp_36, probability));
                }
#line 348 "ProbabilityModule.cs"
                int* csharp2cuda_temp_32 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_32));
            }
        }
#line 357 "ProbabilityModule.cs"
#line 357 "ProbabilityModule.cs"
        double* csharp2cuda_temp_37 = value;
        (*(csharp2cuda_temp_37) = sum);
#line 358 "ProbabilityModule.cs"
        return isfinite(sum);
    }
#line 361 "ProbabilityModule.cs"
    if (((opcode) == (28)))
#line 362 "ProbabilityModule.cs"
    {
#line 363 "ProbabilityModule.cs"
#line 363 "ProbabilityModule.cs"
        double* csharp2cuda_temp_38 = value;
        (*(csharp2cuda_temp_38) = mathblocks_exponential(__dsub_rn(__dadd_rn(mathblocks_probability_log_gamma(a), mathblocks_probability_log_gamma(b)), mathblocks_probability_log_gamma(__dadd_rn(a, b)))));
    }
    else
    {
#line 368 "ProbabilityModule.cs"
        if (((opcode) == (29)))
#line 369 "ProbabilityModule.cs"
        {
#line 370 "ProbabilityModule.cs"
#line 370 "ProbabilityModule.cs"
            double* csharp2cuda_temp_39 = value;
            (*(csharp2cuda_temp_39) = mathblocks_probability_log_gamma(a));
        }
        else
        {
#line 372 "ProbabilityModule.cs"
            if (((opcode) == (30)))
#line 373 "ProbabilityModule.cs"
            {
#line 374 "ProbabilityModule.cs"
#line 374 "ProbabilityModule.cs"
                bool csharp2cuda_temp_40;
#line 374 "ProbabilityModule.cs"
                if (!(((a) < (0.0))))
                {
#line 374 "ProbabilityModule.cs"
                    csharp2cuda_temp_40 = ((a) > (1.0));
                }
                else
                {
#line 374 "ProbabilityModule.cs"
                    csharp2cuda_temp_40 = true;
                }
#line 374 "ProbabilityModule.cs"
                bool csharp2cuda_temp_41;
#line 374 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_40))
                {
#line 374 "ProbabilityModule.cs"
                    csharp2cuda_temp_41 = ((b) <= (0.0));
                }
                else
                {
#line 374 "ProbabilityModule.cs"
                    csharp2cuda_temp_41 = true;
                }
#line 374 "ProbabilityModule.cs"
                bool csharp2cuda_temp_42;
#line 374 "ProbabilityModule.cs"
                if (!(csharp2cuda_temp_41))
                {
#line 374 "ProbabilityModule.cs"
                    csharp2cuda_temp_42 = ((c) <= (0.0));
                }
                else
                {
#line 374 "ProbabilityModule.cs"
                    csharp2cuda_temp_42 = true;
                }
                if (csharp2cuda_temp_42)
                {
#line 375 "ProbabilityModule.cs"
                    return false;
                }
#line 376 "ProbabilityModule.cs"
#line 376 "ProbabilityModule.cs"
                double* csharp2cuda_temp_43 = value;
                (*(csharp2cuda_temp_43) = mathblocks_probability_incomplete_beta(a, b, c));
            }
            else
#line 379 "ProbabilityModule.cs"
            {
#line 380 "ProbabilityModule.cs"
                return false;
            }
        }
    }
#line 382 "ProbabilityModule.cs"
#line 382 "ProbabilityModule.cs"
    double csharp2cuda_temp_44 = *(value);
    return isfinite(csharp2cuda_temp_44);
}