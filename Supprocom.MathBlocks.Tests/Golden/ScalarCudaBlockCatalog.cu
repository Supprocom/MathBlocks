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

struct MathBlockSlot;

#line 29 "ScalarModule.cs"
struct MathBlockSlot
{
    float scalar_value;
    unsigned long long data_pointer;
    unsigned long long scratch_pointer;
    int boolean_value;
    int valid;
    int rows;
    int columns;
    int count;
    int capacity;
};

#line 376 "ScalarModule.cs"
__device__ float mathblocks_arc_cosine(float value);

#line 599 "ScalarModule.cs"
__device__ float mathblocks_arc_sine(float value);

#line 326 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent(float value);

#line 358 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent_2(float y, float x);

#line 169 "ScalarModule.cs"
__device__ float mathblocks_binary_logarithm(float value);

#line 281 "ScalarModule.cs"
__device__ float mathblocks_cosine(float value);

#line 215 "ScalarModule.cs"
__device__ float mathblocks_cube_root(float value);

#line 218 "ScalarModule.cs"
__device__ float mathblocks_cube_root_steps(float value, int newton_steps);

#line 397 "ScalarModule.cs"
__device__ float mathblocks_error_function(float value);

#line 101 "ScalarModule.cs"
__device__ float mathblocks_exponential(float value);

#line 180 "ScalarModule.cs"
__device__ float mathblocks_integer_power(float value, long long exponent);

#line 386 "ScalarModule.cs"
__device__ float mathblocks_inverse_hyperbolic_sine(float value);

#line 160 "ScalarModule.cs"
__device__ float mathblocks_log_one_plus(float value);

#line 123 "ScalarModule.cs"
__device__ float mathblocks_natural_logarithm(float value);

#line 42 "ScalarModule.cs"
__device__ float mathblocks_positive_infinity();

#line 202 "ScalarModule.cs"
__device__ float mathblocks_power(float value, float exponent);

#line 48 "ScalarModule.cs"
__device__ float mathblocks_quiet_nan();

#line 528 "ScalarModule.cs"
__device__ void mathblocks_scalar_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 420 "ScalarModule.cs"
__device__ bool mathblocks_scalar_value(int opcode, float a, float b, float c, float* value);

#line 68 "ScalarModule.cs"
__device__ float mathblocks_scale_binary(float value, int exponent);

#line 230 "ScalarModule.cs"
__device__ float mathblocks_sine(float value);

#line 54 "ScalarModule.cs"
__device__ float mathblocks_square_root(float value);

#line 376 "ScalarModule.cs"
__device__ float mathblocks_arc_cosine(float value)
#line 378 "ScalarModule.cs"
{
#line 379 "ScalarModule.cs"
#line 379 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 379 "ScalarModule.cs"
    if (!(((value) < ((-(1.0f))))))
    {
#line 379 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((value) > (1.0f));
    }
    else
    {
#line 379 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 380 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 381 "ScalarModule.cs"
    return mathblocks_arc_tangent_2(mathblocks_square_root(__fmul_rn(__fsub_rn(1.0f, value), __fadd_rn(1.0f, value))), value);
}

#line 599 "ScalarModule.cs"
__device__ float mathblocks_arc_sine(float value)
#line 601 "ScalarModule.cs"
{
#line 602 "ScalarModule.cs"
#line 602 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 602 "ScalarModule.cs"
    if (!(((value) < ((-(1.0f))))))
    {
#line 602 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((value) > (1.0f));
    }
    else
    {
#line 602 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 602 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 602 "ScalarModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 602 "ScalarModule.cs"
        csharp2cuda_temp_1 = isnan(value);
    }
    else
    {
#line 602 "ScalarModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 603 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 604 "ScalarModule.cs"
    return mathblocks_arc_tangent_2(value, mathblocks_square_root(__fmul_rn(__fsub_rn(1.0f, value), __fadd_rn(1.0f, value))));
}

#line 326 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent(float value)
#line 328 "ScalarModule.cs"
{
#line 330 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 331 "ScalarModule.cs"
        return value;
    }
#line 332 "ScalarModule.cs"
    float csharp2cuda_temp_0;
#line 332 "ScalarModule.cs"
    if (((value) < (0.0f)))
    {
#line 332 "ScalarModule.cs"
        csharp2cuda_temp_0 = (-(1.0f));
    }
    else
    {
#line 332 "ScalarModule.cs"
        csharp2cuda_temp_0 = 1.0f;
    }
#line 332 "ScalarModule.cs"
    float sign = csharp2cuda_temp_0;
#line 333 "ScalarModule.cs"
    float x = fabsf(value);
#line 334 "ScalarModule.cs"
    float offset = 0.0f;
#line 335 "ScalarModule.cs"
    if (((x) > (2.4142137f)))
#line 336 "ScalarModule.cs"
    {
#line 337 "ScalarModule.cs"
#line 337 "ScalarModule.cs"
        float* csharp2cuda_temp_1 = &(offset);
#line 337 "ScalarModule.cs"
        float csharp2cuda_temp_2 = __fdiv_rn(3.1415927f, 2.0f);
        (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 338 "ScalarModule.cs"
#line 338 "ScalarModule.cs"
        float* csharp2cuda_temp_3 = &(x);
#line 338 "ScalarModule.cs"
        float csharp2cuda_temp_4 = __fdiv_rn((-(1.0f)), x);
        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
    }
    else
    {
#line 340 "ScalarModule.cs"
        if (((x) > (0.41421357f)))
#line 341 "ScalarModule.cs"
        {
#line 342 "ScalarModule.cs"
#line 342 "ScalarModule.cs"
            float* csharp2cuda_temp_5 = &(offset);
#line 342 "ScalarModule.cs"
            float csharp2cuda_temp_6 = __fdiv_rn(3.1415927f, 4.0f);
            (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 343 "ScalarModule.cs"
#line 343 "ScalarModule.cs"
            float* csharp2cuda_temp_7 = &(x);
#line 343 "ScalarModule.cs"
            float csharp2cuda_temp_8 = __fdiv_rn(__fsub_rn(x, 1.0f), __fadd_rn(x, 1.0f));
            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
        }
    }
#line 346 "ScalarModule.cs"
    float z = __fmul_rn(x, x);
#line 347 "ScalarModule.cs"
    float numerator = __fsub_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fsub_rn(__fmul_rn((-(0.87506086f)), z), 16.157537f), z), 75.00856f), z), 122.886665f), z), 64.85022f);
#line 351 "ScalarModule.cs"
    float denominator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(z, 24.858465f), z), 165.02701f), z), 432.88107f), z), 485.3904f), z), 194.55066f);
#line 355 "ScalarModule.cs"
#line 355 "ScalarModule.cs"
    float csharp2cuda_temp_9 = __fdiv_rn(__fmul_rn(__fmul_rn(x, z), numerator), denominator);
    return __fmul_rn(sign, __fadd_rn(__fadd_rn(offset, x), csharp2cuda_temp_9));
}

#line 358 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent_2(float y, float x)
#line 360 "ScalarModule.cs"
{
#line 361 "ScalarModule.cs"
    const float pi = 3.1415927f;
#line 362 "ScalarModule.cs"
    if (((x) > (0.0f)))
    {
#line 363 "ScalarModule.cs"
#line 363 "ScalarModule.cs"
        float csharp2cuda_temp_0 = __fdiv_rn(y, x);
        return mathblocks_arc_tangent(csharp2cuda_temp_0);
    }
#line 364 "ScalarModule.cs"
    if (((x) < (0.0f)))
    {
#line 365 "ScalarModule.cs"
#line 365 "ScalarModule.cs"
        float csharp2cuda_temp_1;
#line 365 "ScalarModule.cs"
        if ((!(signbit(((double)(y))))))
        {
#line 366 "ScalarModule.cs"
            float csharp2cuda_temp_2 = __fdiv_rn(y, x);
#line 365 "ScalarModule.cs"
            csharp2cuda_temp_1 = __fadd_rn(mathblocks_arc_tangent(csharp2cuda_temp_2), pi);
        }
        else
        {
#line 367 "ScalarModule.cs"
            float csharp2cuda_temp_3 = __fdiv_rn(y, x);
#line 365 "ScalarModule.cs"
            csharp2cuda_temp_1 = __fsub_rn(mathblocks_arc_tangent(csharp2cuda_temp_3), pi);
        }
        return csharp2cuda_temp_1;
    }
#line 368 "ScalarModule.cs"
    if (((y) > (0.0f)))
    {
#line 369 "ScalarModule.cs"
        return __fdiv_rn(pi, 2.0f);
    }
#line 370 "ScalarModule.cs"
    if (((y) < (0.0f)))
    {
#line 371 "ScalarModule.cs"
        return __fdiv_rn((-(pi)), 2.0f);
    }
#line 373 "ScalarModule.cs"
#line 373 "ScalarModule.cs"
    float csharp2cuda_temp_4;
#line 373 "ScalarModule.cs"
    if (signbit(((double)(x))))
    {
#line 373 "ScalarModule.cs"
        csharp2cuda_temp_4 = copysignf(pi, y);
    }
    else
    {
#line 373 "ScalarModule.cs"
        csharp2cuda_temp_4 = y;
    }
    return csharp2cuda_temp_4;
}

#line 169 "ScalarModule.cs"
__device__ float mathblocks_binary_logarithm(float value)
#line 171 "ScalarModule.cs"
{
#line 172 "ScalarModule.cs"
    unsigned int bits = ((unsigned int)(__float_as_int(value)));
#line 173 "ScalarModule.cs"
    int exponent = csharp2cuda_i32_from_bits(((csharp2cuda_u32_shr(bits, 23)) & (255u)));
#line 174 "ScalarModule.cs"
    unsigned int fraction = ((bits) & (8388607u));
#line 175 "ScalarModule.cs"
#line 175 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 175 "ScalarModule.cs"
    if (((exponent) > (0)))
    {
#line 175 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((exponent) < (255));
    }
    else
    {
#line 175 "ScalarModule.cs"
        csharp2cuda_temp_0 = false;
    }
#line 175 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 175 "ScalarModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 175 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((fraction) == (0u));
    }
    else
    {
#line 175 "ScalarModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 176 "ScalarModule.cs"
        return ((float)(csharp2cuda_i32_sub(exponent, 127)));
    }
#line 177 "ScalarModule.cs"
    return __fdiv_rn(mathblocks_natural_logarithm(value), 0.6931472f);
}

#line 281 "ScalarModule.cs"
__device__ float mathblocks_cosine(float value)
#line 283 "ScalarModule.cs"
{
#line 284 "ScalarModule.cs"
    float x = fabsf(value);
#line 285 "ScalarModule.cs"
    float sign = 1.0f;
#line 286 "ScalarModule.cs"
    float csharp2cuda_temp_0 = __fdiv_rn(x, 0.7853982f);
#line 286 "ScalarModule.cs"
    float octant_value = floorf(csharp2cuda_temp_0);
#line 287 "ScalarModule.cs"
    int octant = csharp2cuda_f64_to_i32(__fsub_rn(octant_value, __fmul_rn(floorf(__fmul_rn(octant_value, 0.125f)), 8.0f)));
#line 288 "ScalarModule.cs"
    if (((csharp2cuda_i32_and(octant, 1)) != (0)))
#line 289 "ScalarModule.cs"
    {
#line 290 "ScalarModule.cs"
#line 290 "ScalarModule.cs"
        int* csharp2cuda_temp_1 = &(octant);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
#line 291 "ScalarModule.cs"
#line 291 "ScalarModule.cs"
        float* csharp2cuda_temp_2 = &(octant_value);
        (*(csharp2cuda_temp_2))++;
    }
#line 293 "ScalarModule.cs"
#line 293 "ScalarModule.cs"
    int* csharp2cuda_temp_3 = &(octant);
#line 293 "ScalarModule.cs"
    int csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_and(csharp2cuda_temp_4, 7));
#line 294 "ScalarModule.cs"
    if (((octant) > (3)))
#line 295 "ScalarModule.cs"
    {
#line 296 "ScalarModule.cs"
#line 296 "ScalarModule.cs"
        int* csharp2cuda_temp_5 = &(octant);
#line 296 "ScalarModule.cs"
        int csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
        (*(csharp2cuda_temp_5) = csharp2cuda_i32_sub(csharp2cuda_temp_6, 4));
#line 297 "ScalarModule.cs"
#line 297 "ScalarModule.cs"
        float* csharp2cuda_temp_7 = &(sign);
        (*(csharp2cuda_temp_7) = (-(sign)));
    }
#line 299 "ScalarModule.cs"
    if (((octant) > (1)))
    {
#line 300 "ScalarModule.cs"
#line 300 "ScalarModule.cs"
        float* csharp2cuda_temp_8 = &(sign);
        (*(csharp2cuda_temp_8) = (-(sign)));
    }
#line 301 "ScalarModule.cs"
    float reduced = __fsub_rn(__fsub_rn(__fsub_rn(x, __fmul_rn(octant_value, 0.78515625f)), __fmul_rn(octant_value, 0.00024187565f)), __fmul_rn(octant_value, 3.774895E-08f));
#line 304 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 305 "ScalarModule.cs"
#line 305 "ScalarModule.cs"
    bool csharp2cuda_temp_9;
#line 305 "ScalarModule.cs"
    if (!(((octant) == (1))))
    {
#line 305 "ScalarModule.cs"
        csharp2cuda_temp_9 = ((octant) == (2));
    }
    else
    {
#line 305 "ScalarModule.cs"
        csharp2cuda_temp_9 = true;
    }
    if (csharp2cuda_temp_9)
#line 306 "ScalarModule.cs"
    {
#line 307 "ScalarModule.cs"
        float sine_polynomial = __fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(1.589623E-10f, square), 2.5050747E-08f), square), 2.7557314E-06f), square), 0.0001984127f), square), 0.008333334f), square), 0.16666667f);
#line 314 "ScalarModule.cs"
        return __fmul_rn(sign, __fadd_rn(reduced, __fmul_rn(__fmul_rn(reduced, square), sine_polynomial)));
    }
#line 316 "ScalarModule.cs"
    float polynomial = __fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn((-(1.13585365E-11f)), square), 2.0875701E-09f), square), 2.7557314E-07f), square), 2.4801588E-05f), square), 0.0013888889f), square), 0.041666668f);
#line 323 "ScalarModule.cs"
    return __fmul_rn(sign, __fadd_rn(__fsub_rn(1.0f, __fmul_rn(0.5f, square)), __fmul_rn(__fmul_rn(square, square), polynomial)));
}

#line 215 "ScalarModule.cs"
__device__ float mathblocks_cube_root(float value)
#line 215 "ScalarModule.cs"
{
#line 216 "ScalarModule.cs"
    return mathblocks_cube_root_steps(value, 3);
}

#line 218 "ScalarModule.cs"
__device__ float mathblocks_cube_root_steps(float value, int newton_steps)
#line 220 "ScalarModule.cs"
{
#line 221 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 222 "ScalarModule.cs"
        return value;
    }
#line 223 "ScalarModule.cs"
    float magnitude = fabsf(value);
#line 224 "ScalarModule.cs"
    float csharp2cuda_temp_0 = __fdiv_rn(mathblocks_natural_logarithm(magnitude), 3.0f);
#line 224 "ScalarModule.cs"
    float estimate = mathblocks_exponential(csharp2cuda_temp_0);
#line 225 "ScalarModule.cs"
    {
#line 225 "ScalarModule.cs"
        int iteration = 0;
        while (true)
        {
            if (!(((iteration) < (newton_steps))))
                break;
#line 226 "ScalarModule.cs"
#line 226 "ScalarModule.cs"
            float* csharp2cuda_temp_2 = &(estimate);
#line 226 "ScalarModule.cs"
            float csharp2cuda_temp_3 = __fdiv_rn(magnitude, __fmul_rn(estimate, estimate));
#line 226 "ScalarModule.cs"
            float csharp2cuda_temp_4 = __fdiv_rn(__fadd_rn(__fmul_rn(2.0f, estimate), csharp2cuda_temp_3), 3.0f);
            (*(csharp2cuda_temp_2) = csharp2cuda_temp_4);
#line 225 "ScalarModule.cs"
            int* csharp2cuda_temp_1 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 227 "ScalarModule.cs"
    return copysignf(estimate, value);
}

#line 397 "ScalarModule.cs"
__device__ float mathblocks_error_function(float value)
#line 399 "ScalarModule.cs"
{
#line 401 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 402 "ScalarModule.cs"
        return value;
    }
#line 403 "ScalarModule.cs"
    float magnitude = fabsf(value);
#line 404 "ScalarModule.cs"
    float t = __fdiv_rn(1.0f, __fadd_rn(1.0f, __fmul_rn(0.5f, magnitude)));
#line 405 "ScalarModule.cs"
    float tau = __fmul_rn(t, mathblocks_exponential(__fadd_rn(__fsub_rn(__fmul_rn((-(magnitude)), magnitude), 1.2655122f), __fmul_rn(t, __fadd_rn(1.0000237f, __fmul_rn(t, __fadd_rn(0.37409195f, __fmul_rn(t, __fadd_rn(0.09678418f, __fmul_rn(t, __fadd_rn((-(0.18628806f)), __fmul_rn(t, __fadd_rn(0.27886808f, __fmul_rn(t, __fadd_rn((-(1.135204f)), __fmul_rn(t, __fadd_rn(1.4885159f, __fmul_rn(t, __fadd_rn((-(0.82215226f)), __fmul_rn(t, 0.17087276f))))))))))))))))))));
#line 415 "ScalarModule.cs"
    return copysignf(__fsub_rn(1.0f, tau), value);
}

#line 101 "ScalarModule.cs"
__device__ float mathblocks_exponential(float value)
#line 103 "ScalarModule.cs"
{
#line 104 "ScalarModule.cs"
    if (((value) > (88.72284f)))
    {
#line 105 "ScalarModule.cs"
        return mathblocks_positive_infinity();
    }
#line 106 "ScalarModule.cs"
    if (((value) < ((-(103.972084f)))))
    {
#line 107 "ScalarModule.cs"
        return 0.0f;
    }
#line 109 "ScalarModule.cs"
    float exponent_value = floorf(__fadd_rn(__fmul_rn(1.442695f, value), 0.5f));
#line 110 "ScalarModule.cs"
    int exponent = csharp2cuda_f64_to_i32(exponent_value);
#line 111 "ScalarModule.cs"
    float reduced = __fsub_rn(value, __fmul_rn(exponent_value, 0.6933594f));
#line 112 "ScalarModule.cs"
#line 112 "ScalarModule.cs"
    float* csharp2cuda_temp_0 = &(reduced);
#line 112 "ScalarModule.cs"
    float csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
    (*(csharp2cuda_temp_0) = __fsub_rn(csharp2cuda_temp_1, __fmul_rn(exponent_value, (-(0.00021219444f)))));
#line 113 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 114 "ScalarModule.cs"
    float numerator = __fmul_rn(reduced, __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(0.0001261772f, square), 0.03029944f), square), 1.0f));
#line 116 "ScalarModule.cs"
    float denominator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(3.001985E-06f, square), 0.0025244835f), square), 0.22726555f), square), 2.0f);
#line 119 "ScalarModule.cs"
    float csharp2cuda_temp_2 = __fdiv_rn(__fmul_rn(2.0f, numerator), __fsub_rn(denominator, numerator));
#line 119 "ScalarModule.cs"
    float result = __fadd_rn(1.0f, csharp2cuda_temp_2);
#line 120 "ScalarModule.cs"
    return mathblocks_scale_binary(result, exponent);
}

#line 180 "ScalarModule.cs"
__device__ float mathblocks_integer_power(float value, long long exponent)
#line 182 "ScalarModule.cs"
{
#line 183 "ScalarModule.cs"
    if (((exponent) == (((long long)(0)))))
    {
#line 184 "ScalarModule.cs"
        return 1.0f;
    }
#line 185 "ScalarModule.cs"
    bool negative = ((exponent) < (((long long)(0))));
#line 186 "ScalarModule.cs"
    unsigned long long csharp2cuda_temp_0;
#line 186 "ScalarModule.cs"
    if (negative)
    {
#line 186 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((((unsigned long long)(csharp2cuda_i64_neg(csharp2cuda_i64_add(exponent, ((long long)(1))))))) + (1ull));
    }
    else
    {
#line 186 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((unsigned long long)(exponent));
    }
#line 186 "ScalarModule.cs"
    unsigned long long remaining = csharp2cuda_temp_0;
#line 189 "ScalarModule.cs"
    float power_base = value;
#line 190 "ScalarModule.cs"
    float result = 1.0f;
#line 191 "ScalarModule.cs"
    while (true)
    {
        if (!(((remaining) != (0ull))))
            break;
#line 192 "ScalarModule.cs"
        {
#line 193 "ScalarModule.cs"
            if (((((remaining) & (1ull))) != (0ull)))
            {
#line 194 "ScalarModule.cs"
#line 194 "ScalarModule.cs"
                float* csharp2cuda_temp_1 = &(result);
#line 194 "ScalarModule.cs"
                float csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
                (*(csharp2cuda_temp_1) = __fmul_rn(csharp2cuda_temp_2, power_base));
            }
#line 195 "ScalarModule.cs"
#line 195 "ScalarModule.cs"
            unsigned long long* csharp2cuda_temp_3 = &(remaining);
#line 195 "ScalarModule.cs"
            unsigned long long csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
            (*(csharp2cuda_temp_3) = csharp2cuda_u64_shr(csharp2cuda_temp_4, 1));
#line 196 "ScalarModule.cs"
            if (((remaining) != (0ull)))
            {
#line 197 "ScalarModule.cs"
#line 197 "ScalarModule.cs"
                float* csharp2cuda_temp_5 = &(power_base);
#line 197 "ScalarModule.cs"
                float csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                (*(csharp2cuda_temp_5) = __fmul_rn(csharp2cuda_temp_6, power_base));
            }
        }
    }
#line 199 "ScalarModule.cs"
#line 199 "ScalarModule.cs"
    float csharp2cuda_temp_7;
#line 199 "ScalarModule.cs"
    if (negative)
    {
#line 199 "ScalarModule.cs"
        csharp2cuda_temp_7 = __fdiv_rn(1.0f, result);
    }
    else
    {
#line 199 "ScalarModule.cs"
        csharp2cuda_temp_7 = result;
    }
    return csharp2cuda_temp_7;
}

#line 386 "ScalarModule.cs"
__device__ float mathblocks_inverse_hyperbolic_sine(float value)
#line 388 "ScalarModule.cs"
{
#line 389 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 390 "ScalarModule.cs"
        return value;
    }
#line 391 "ScalarModule.cs"
    float magnitude = fabsf(value);
#line 392 "ScalarModule.cs"
    return copysignf(mathblocks_natural_logarithm(__fadd_rn(magnitude, mathblocks_square_root(__fadd_rn(__fmul_rn(magnitude, magnitude), 1.0f)))), value);
}

#line 160 "ScalarModule.cs"
__device__ float mathblocks_log_one_plus(float value)
#line 162 "ScalarModule.cs"
{
#line 163 "ScalarModule.cs"
    float sum = __fadd_rn(1.0f, value);
#line 164 "ScalarModule.cs"
#line 164 "ScalarModule.cs"
    float csharp2cuda_temp_0;
#line 164 "ScalarModule.cs"
    if (((sum) == (1.0f)))
    {
#line 164 "ScalarModule.cs"
        csharp2cuda_temp_0 = value;
    }
    else
    {
#line 166 "ScalarModule.cs"
        float csharp2cuda_temp_1 = __fdiv_rn(__fsub_rn(__fsub_rn(sum, 1.0f), value), sum);
#line 164 "ScalarModule.cs"
        csharp2cuda_temp_0 = __fsub_rn(mathblocks_natural_logarithm(sum), csharp2cuda_temp_1);
    }
    return csharp2cuda_temp_0;
}

#line 123 "ScalarModule.cs"
__device__ float mathblocks_natural_logarithm(float value)
#line 125 "ScalarModule.cs"
{
#line 126 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 127 "ScalarModule.cs"
        return (-(mathblocks_positive_infinity()));
    }
#line 128 "ScalarModule.cs"
#line 128 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 128 "ScalarModule.cs"
    if (!(((value) < (0.0f))))
    {
#line 128 "ScalarModule.cs"
        csharp2cuda_temp_0 = isnan(value);
    }
    else
    {
#line 128 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 129 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 130 "ScalarModule.cs"
    if (isinf(value))
    {
#line 131 "ScalarModule.cs"
        return mathblocks_positive_infinity();
    }
#line 133 "ScalarModule.cs"
    int exponent = csharp2cuda_i32_add(ilogbf(value), 1);
#line 134 "ScalarModule.cs"
    float reduced = mathblocks_scale_binary(value, csharp2cuda_i32_neg(exponent));
#line 135 "ScalarModule.cs"
    if (((reduced) < (0.70710677f)))
#line 136 "ScalarModule.cs"
    {
#line 137 "ScalarModule.cs"
#line 137 "ScalarModule.cs"
        int* csharp2cuda_temp_1 = &(exponent);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_1));
#line 138 "ScalarModule.cs"
#line 138 "ScalarModule.cs"
        float* csharp2cuda_temp_2 = &(reduced);
        (*(csharp2cuda_temp_2) = __fsub_rn(__fmul_rn(2.0f, reduced), 1.0f));
    }
    else
#line 141 "ScalarModule.cs"
    {
#line 142 "ScalarModule.cs"
#line 142 "ScalarModule.cs"
        float* csharp2cuda_temp_3 = &(reduced);
#line 142 "ScalarModule.cs"
        float csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
        (*(csharp2cuda_temp_3) = __fsub_rn(csharp2cuda_temp_4, 1.0f));
    }
#line 145 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 146 "ScalarModule.cs"
    float numerator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(0.00010187567f, reduced), 0.497495f), reduced), 4.705791f), reduced), 14.498922f), reduced), 17.936869f), reduced), 7.7083874f);
#line 150 "ScalarModule.cs"
    float denominator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(reduced, 11.287358f), reduced), 45.227913f), reduced), 82.987526f), reduced), 71.15447f), reduced), 23.125162f);
#line 154 "ScalarModule.cs"
    float csharp2cuda_temp_5 = __fdiv_rn(__fmul_rn(square, numerator), denominator);
#line 154 "ScalarModule.cs"
    float correction = __fmul_rn(reduced, csharp2cuda_temp_5);
#line 155 "ScalarModule.cs"
#line 155 "ScalarModule.cs"
    float* csharp2cuda_temp_6 = &(correction);
#line 155 "ScalarModule.cs"
    float csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
    (*(csharp2cuda_temp_6) = __fsub_rn(csharp2cuda_temp_7, __fmul_rn(((float)(exponent)), 0.00021219444f)));
#line 156 "ScalarModule.cs"
#line 156 "ScalarModule.cs"
    float* csharp2cuda_temp_8 = &(correction);
#line 156 "ScalarModule.cs"
    float csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
    (*(csharp2cuda_temp_8) = __fsub_rn(csharp2cuda_temp_9, __fmul_rn(0.5f, square)));
#line 157 "ScalarModule.cs"
    return __fadd_rn(__fadd_rn(reduced, correction), __fmul_rn(((float)(exponent)), 0.6933594f));
}

#line 42 "ScalarModule.cs"
__device__ float mathblocks_positive_infinity()
#line 44 "ScalarModule.cs"
{
#line 45 "ScalarModule.cs"
    return __int_as_float(2139095040);
}

#line 202 "ScalarModule.cs"
__device__ float mathblocks_power(float value, float exponent)
#line 204 "ScalarModule.cs"
{
#line 205 "ScalarModule.cs"
#line 205 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 205 "ScalarModule.cs"
    if (((exponent) == (truncf(exponent))))
    {
#line 205 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((fabsf(exponent)) <= (9.223372E+18f));
    }
    else
    {
#line 205 "ScalarModule.cs"
        csharp2cuda_temp_0 = false;
    }
    if (csharp2cuda_temp_0)
    {
#line 206 "ScalarModule.cs"
        return mathblocks_integer_power(value, csharp2cuda_f64_to_i64(exponent));
    }
#line 207 "ScalarModule.cs"
    if (((value) < (0.0f)))
    {
#line 208 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 209 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 210 "ScalarModule.cs"
#line 210 "ScalarModule.cs"
        float csharp2cuda_temp_1;
#line 210 "ScalarModule.cs"
        if (((exponent) > (0.0f)))
        {
#line 210 "ScalarModule.cs"
            csharp2cuda_temp_1 = 0.0f;
        }
        else
        {
#line 210 "ScalarModule.cs"
            csharp2cuda_temp_1 = mathblocks_positive_infinity();
        }
        return csharp2cuda_temp_1;
    }
#line 211 "ScalarModule.cs"
    return mathblocks_exponential(__fmul_rn(exponent, mathblocks_natural_logarithm(value)));
}

#line 48 "ScalarModule.cs"
__device__ float mathblocks_quiet_nan()
#line 50 "ScalarModule.cs"
{
#line 51 "ScalarModule.cs"
    return __int_as_float(2143289344);
}

#line 528 "ScalarModule.cs"
__device__ void mathblocks_scalar_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 534 "ScalarModule.cs"
{
#line 535 "ScalarModule.cs"
    if (((threadIdx.x) != (0)))
    {
#line 536 "ScalarModule.cs"
        return;
    }
#line 538 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 538 "ScalarModule.cs"
    if (((input_count) > (0)))
    {
#line 538 "ScalarModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 538 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 538 "ScalarModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 539 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 539 "ScalarModule.cs"
    if (((input_count) > (1)))
    {
#line 539 "ScalarModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 539 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 539 "ScalarModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 540 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 540 "ScalarModule.cs"
    if (((input_count) > (2)))
    {
#line 540 "ScalarModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 540 "ScalarModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 540 "ScalarModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 542 "ScalarModule.cs"
#line 542 "ScalarModule.cs"
    float* csharp2cuda_temp_3 = &((output)->scalar_value);
    (*(csharp2cuda_temp_3) = 0.0f);
#line 543 "ScalarModule.cs"
#line 543 "ScalarModule.cs"
    int* csharp2cuda_temp_4 = &((output)->boolean_value);
    (*(csharp2cuda_temp_4) = 0);
#line 544 "ScalarModule.cs"
#line 544 "ScalarModule.cs"
    int* csharp2cuda_temp_5 = &((output)->valid);
#line 544 "ScalarModule.cs"
    bool csharp2cuda_temp_6;
#line 544 "ScalarModule.cs"
    if (!(((((void*)(first))) == (((void*)(nullptr))))))
    {
#line 544 "ScalarModule.cs"
        csharp2cuda_temp_6 = (first)->valid;
    }
    else
    {
#line 544 "ScalarModule.cs"
        csharp2cuda_temp_6 = true;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 545 "ScalarModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 546 "ScalarModule.cs"
#line 546 "ScalarModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 546 "ScalarModule.cs"
        bool csharp2cuda_temp_8 = (output)->valid;
#line 546 "ScalarModule.cs"
        bool csharp2cuda_temp_9;
#line 546 "ScalarModule.cs"
        if (csharp2cuda_temp_8)
        {
#line 546 "ScalarModule.cs"
            csharp2cuda_temp_9 = (second)->valid;
        }
        else
        {
#line 546 "ScalarModule.cs"
            csharp2cuda_temp_9 = false;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_9);
    }
#line 547 "ScalarModule.cs"
    if (((((void*)(third))) != (((void*)(nullptr)))))
    {
#line 548 "ScalarModule.cs"
#line 548 "ScalarModule.cs"
        int* csharp2cuda_temp_10 = &((output)->valid);
#line 548 "ScalarModule.cs"
        bool csharp2cuda_temp_11 = (output)->valid;
#line 548 "ScalarModule.cs"
        bool csharp2cuda_temp_12;
#line 548 "ScalarModule.cs"
        if (csharp2cuda_temp_11)
        {
#line 548 "ScalarModule.cs"
            csharp2cuda_temp_12 = (third)->valid;
        }
        else
        {
#line 548 "ScalarModule.cs"
            csharp2cuda_temp_12 = false;
        }
        (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
    }
#line 549 "ScalarModule.cs"
#line 549 "ScalarModule.cs"
    bool csharp2cuda_temp_13 = (output)->valid;
    if ((!(csharp2cuda_temp_13)))
    {
#line 550 "ScalarModule.cs"
        return;
    }
#line 552 "ScalarModule.cs"
    float csharp2cuda_temp_14;
#line 552 "ScalarModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 552 "ScalarModule.cs"
        csharp2cuda_temp_14 = 0.0f;
    }
    else
    {
#line 552 "ScalarModule.cs"
        csharp2cuda_temp_14 = (first)->scalar_value;
    }
#line 552 "ScalarModule.cs"
    float a = csharp2cuda_temp_14;
#line 553 "ScalarModule.cs"
    float csharp2cuda_temp_15;
#line 553 "ScalarModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 553 "ScalarModule.cs"
        csharp2cuda_temp_15 = 0.0f;
    }
    else
    {
#line 553 "ScalarModule.cs"
        csharp2cuda_temp_15 = (second)->scalar_value;
    }
#line 553 "ScalarModule.cs"
    float b = csharp2cuda_temp_15;
#line 554 "ScalarModule.cs"
    float csharp2cuda_temp_16;
#line 554 "ScalarModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 554 "ScalarModule.cs"
        csharp2cuda_temp_16 = 0.0f;
    }
    else
    {
#line 554 "ScalarModule.cs"
        csharp2cuda_temp_16 = (third)->scalar_value;
    }
#line 554 "ScalarModule.cs"
    float c = csharp2cuda_temp_16;
#line 555 "ScalarModule.cs"
#line 555 "ScalarModule.cs"
    bool csharp2cuda_temp_17;
#line 555 "ScalarModule.cs"
    if (((opcode) >= (0)))
    {
#line 555 "ScalarModule.cs"
        csharp2cuda_temp_17 = ((opcode) <= (43));
    }
    else
    {
#line 555 "ScalarModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
#line 556 "ScalarModule.cs"
    {
#line 557 "ScalarModule.cs"
        float value = 0.0f;
#line 558 "ScalarModule.cs"
#line 558 "ScalarModule.cs"
        int* csharp2cuda_temp_18 = &((output)->valid);
#line 558 "ScalarModule.cs"
        float* csharp2cuda_temp_19 = &(value);
#line 558 "ScalarModule.cs"
        int csharp2cuda_temp_20 = mathblocks_scalar_value(opcode, a, b, c, csharp2cuda_temp_19);
        (*(csharp2cuda_temp_18) = csharp2cuda_temp_20);
#line 559 "ScalarModule.cs"
#line 559 "ScalarModule.cs"
        float* csharp2cuda_temp_21 = &((output)->scalar_value);
        (*(csharp2cuda_temp_21) = value);
#line 560 "ScalarModule.cs"
        return;
    }
#line 563 "ScalarModule.cs"
    bool scalar_output = true;
#line 564 "ScalarModule.cs"
    switch (opcode)
    {
#line 566 "ScalarModule.cs"
        case 44:
#line 566 "ScalarModule.cs"
#line 566 "ScalarModule.cs"
            int* csharp2cuda_temp_22 = &((output)->boolean_value);
            (*(csharp2cuda_temp_22) = ((a) == (b)));
#line 566 "ScalarModule.cs"
#line 566 "ScalarModule.cs"
            bool* csharp2cuda_temp_23 = &(scalar_output);
            (*(csharp2cuda_temp_23) = false);
#line 566 "ScalarModule.cs"
            break;
#line 567 "ScalarModule.cs"
        case 45:
#line 567 "ScalarModule.cs"
#line 567 "ScalarModule.cs"
            int* csharp2cuda_temp_24 = &((output)->boolean_value);
            (*(csharp2cuda_temp_24) = ((a) != (b)));
#line 567 "ScalarModule.cs"
#line 567 "ScalarModule.cs"
            bool* csharp2cuda_temp_25 = &(scalar_output);
            (*(csharp2cuda_temp_25) = false);
#line 567 "ScalarModule.cs"
            break;
#line 568 "ScalarModule.cs"
        case 46:
#line 568 "ScalarModule.cs"
#line 568 "ScalarModule.cs"
            int* csharp2cuda_temp_26 = &((output)->boolean_value);
            (*(csharp2cuda_temp_26) = ((a) < (b)));
#line 568 "ScalarModule.cs"
#line 568 "ScalarModule.cs"
            bool* csharp2cuda_temp_27 = &(scalar_output);
            (*(csharp2cuda_temp_27) = false);
#line 568 "ScalarModule.cs"
            break;
#line 569 "ScalarModule.cs"
        case 47:
#line 569 "ScalarModule.cs"
#line 569 "ScalarModule.cs"
            int* csharp2cuda_temp_28 = &((output)->boolean_value);
            (*(csharp2cuda_temp_28) = ((a) <= (b)));
#line 569 "ScalarModule.cs"
#line 569 "ScalarModule.cs"
            bool* csharp2cuda_temp_29 = &(scalar_output);
            (*(csharp2cuda_temp_29) = false);
#line 569 "ScalarModule.cs"
            break;
#line 570 "ScalarModule.cs"
        case 48:
#line 570 "ScalarModule.cs"
#line 570 "ScalarModule.cs"
            int* csharp2cuda_temp_30 = &((output)->boolean_value);
            (*(csharp2cuda_temp_30) = ((a) > (b)));
#line 570 "ScalarModule.cs"
#line 570 "ScalarModule.cs"
            bool* csharp2cuda_temp_31 = &(scalar_output);
            (*(csharp2cuda_temp_31) = false);
#line 570 "ScalarModule.cs"
            break;
#line 571 "ScalarModule.cs"
        case 49:
#line 571 "ScalarModule.cs"
#line 571 "ScalarModule.cs"
            int* csharp2cuda_temp_32 = &((output)->boolean_value);
            (*(csharp2cuda_temp_32) = ((a) >= (b)));
#line 571 "ScalarModule.cs"
#line 571 "ScalarModule.cs"
            bool* csharp2cuda_temp_33 = &(scalar_output);
            (*(csharp2cuda_temp_33) = false);
#line 571 "ScalarModule.cs"
            break;
#line 572 "ScalarModule.cs"
        case 50:
#line 573 "ScalarModule.cs"
#line 573 "ScalarModule.cs"
            int* csharp2cuda_temp_34 = &((output)->boolean_value);
#line 573 "ScalarModule.cs"
            bool csharp2cuda_temp_35 = (first)->boolean_value;
#line 573 "ScalarModule.cs"
            bool csharp2cuda_temp_36;
#line 573 "ScalarModule.cs"
            if (csharp2cuda_temp_35)
            {
#line 573 "ScalarModule.cs"
                csharp2cuda_temp_36 = (second)->boolean_value;
            }
            else
            {
#line 573 "ScalarModule.cs"
                csharp2cuda_temp_36 = false;
            }
            (*(csharp2cuda_temp_34) = csharp2cuda_temp_36);
#line 574 "ScalarModule.cs"
#line 574 "ScalarModule.cs"
            bool* csharp2cuda_temp_37 = &(scalar_output);
            (*(csharp2cuda_temp_37) = false);
#line 575 "ScalarModule.cs"
            break;
#line 576 "ScalarModule.cs"
        case 51:
#line 577 "ScalarModule.cs"
#line 577 "ScalarModule.cs"
            int* csharp2cuda_temp_38 = &((output)->boolean_value);
#line 577 "ScalarModule.cs"
            bool csharp2cuda_temp_39 = (first)->boolean_value;
#line 577 "ScalarModule.cs"
            bool csharp2cuda_temp_40;
#line 577 "ScalarModule.cs"
            if (!(csharp2cuda_temp_39))
            {
#line 577 "ScalarModule.cs"
                csharp2cuda_temp_40 = (second)->boolean_value;
            }
            else
            {
#line 577 "ScalarModule.cs"
                csharp2cuda_temp_40 = true;
            }
            (*(csharp2cuda_temp_38) = csharp2cuda_temp_40);
#line 578 "ScalarModule.cs"
#line 578 "ScalarModule.cs"
            bool* csharp2cuda_temp_41 = &(scalar_output);
            (*(csharp2cuda_temp_41) = false);
#line 579 "ScalarModule.cs"
            break;
#line 580 "ScalarModule.cs"
        case 52:
#line 581 "ScalarModule.cs"
#line 581 "ScalarModule.cs"
            int* csharp2cuda_temp_42 = &((output)->boolean_value);
#line 581 "ScalarModule.cs"
            int csharp2cuda_temp_43 = (first)->boolean_value;
#line 581 "ScalarModule.cs"
            int csharp2cuda_temp_44 = (second)->boolean_value;
            (*(csharp2cuda_temp_42) = ((csharp2cuda_temp_43) != (csharp2cuda_temp_44)));
#line 582 "ScalarModule.cs"
#line 582 "ScalarModule.cs"
            bool* csharp2cuda_temp_45 = &(scalar_output);
            (*(csharp2cuda_temp_45) = false);
#line 583 "ScalarModule.cs"
            break;
#line 584 "ScalarModule.cs"
        case 53:
#line 585 "ScalarModule.cs"
#line 585 "ScalarModule.cs"
            int* csharp2cuda_temp_46 = &((output)->boolean_value);
#line 585 "ScalarModule.cs"
            bool csharp2cuda_temp_47 = (first)->boolean_value;
            (*(csharp2cuda_temp_46) = (!(csharp2cuda_temp_47)));
#line 586 "ScalarModule.cs"
#line 586 "ScalarModule.cs"
            bool* csharp2cuda_temp_48 = &(scalar_output);
            (*(csharp2cuda_temp_48) = false);
#line 587 "ScalarModule.cs"
            break;
#line 588 "ScalarModule.cs"
        case 54:
#line 589 "ScalarModule.cs"
#line 589 "ScalarModule.cs"
            float* csharp2cuda_temp_49 = &((output)->scalar_value);
#line 589 "ScalarModule.cs"
            bool csharp2cuda_temp_50 = (first)->boolean_value;
#line 589 "ScalarModule.cs"
            float csharp2cuda_temp_51;
#line 589 "ScalarModule.cs"
            if (csharp2cuda_temp_50)
            {
#line 589 "ScalarModule.cs"
                csharp2cuda_temp_51 = (second)->scalar_value;
            }
            else
            {
#line 589 "ScalarModule.cs"
                csharp2cuda_temp_51 = (third)->scalar_value;
            }
            (*(csharp2cuda_temp_49) = csharp2cuda_temp_51);
#line 590 "ScalarModule.cs"
            break;
#line 591 "ScalarModule.cs"
        default:
#line 591 "ScalarModule.cs"
#line 591 "ScalarModule.cs"
            int* csharp2cuda_temp_52 = &((output)->valid);
            (*(csharp2cuda_temp_52) = 0);
#line 591 "ScalarModule.cs"
            return;
    }
#line 594 "ScalarModule.cs"
#line 594 "ScalarModule.cs"
    bool csharp2cuda_temp_53;
#line 594 "ScalarModule.cs"
    if (scalar_output)
    {
#line 594 "ScalarModule.cs"
        float csharp2cuda_temp_54 = (output)->scalar_value;
#line 594 "ScalarModule.cs"
        csharp2cuda_temp_53 = (!(isfinite(csharp2cuda_temp_54)));
    }
    else
    {
#line 594 "ScalarModule.cs"
        csharp2cuda_temp_53 = false;
    }
    if (csharp2cuda_temp_53)
    {
#line 595 "ScalarModule.cs"
#line 595 "ScalarModule.cs"
        int* csharp2cuda_temp_55 = &((output)->valid);
        (*(csharp2cuda_temp_55) = 0);
    }
}

#line 420 "ScalarModule.cs"
__device__ bool mathblocks_scalar_value(int opcode, float a, float b, float c, float* value)
#line 422 "ScalarModule.cs"
{
#line 423 "ScalarModule.cs"
    float result = 0.0f;
#line 424 "ScalarModule.cs"
    switch (opcode)
    {
#line 426 "ScalarModule.cs"
        case 0:
#line 426 "ScalarModule.cs"
#line 426 "ScalarModule.cs"
            float* csharp2cuda_temp_0 = &(result);
            (*(csharp2cuda_temp_0) = mathblocks_row_value_add(a, b));
#line 426 "ScalarModule.cs"
            break;
#line 427 "ScalarModule.cs"
        case 1:
#line 427 "ScalarModule.cs"
#line 427 "ScalarModule.cs"
            float* csharp2cuda_temp_1 = &(result);
            (*(csharp2cuda_temp_1) = mathblocks_row_value_subtract(a, b));
#line 427 "ScalarModule.cs"
            break;
#line 428 "ScalarModule.cs"
        case 2:
#line 428 "ScalarModule.cs"
#line 428 "ScalarModule.cs"
            float* csharp2cuda_temp_2 = &(result);
            (*(csharp2cuda_temp_2) = mathblocks_row_value_multiply(a, b));
#line 428 "ScalarModule.cs"
            break;
#line 429 "ScalarModule.cs"
        case 3:
#line 429 "ScalarModule.cs"
#line 429 "ScalarModule.cs"
            float* csharp2cuda_temp_3 = &(result);
            (*(csharp2cuda_temp_3) = mathblocks_row_value_divide(a, b));
#line 429 "ScalarModule.cs"
            break;
#line 430 "ScalarModule.cs"
        case 4:
#line 430 "ScalarModule.cs"
#line 430 "ScalarModule.cs"
            float* csharp2cuda_temp_4 = &(result);
            (*(csharp2cuda_temp_4) = (-(a)));
#line 430 "ScalarModule.cs"
            break;
#line 431 "ScalarModule.cs"
        case 5:
#line 431 "ScalarModule.cs"
#line 431 "ScalarModule.cs"
            float* csharp2cuda_temp_5 = &(result);
            (*(csharp2cuda_temp_5) = mathblocks_row_value_absolute(a));
#line 431 "ScalarModule.cs"
            break;
#line 432 "ScalarModule.cs"
        case 6:
#line 432 "ScalarModule.cs"
#line 432 "ScalarModule.cs"
            float* csharp2cuda_temp_6 = &(result);
            (*(csharp2cuda_temp_6) = ((float)(csharp2cuda_i32_sub(((((a) > (0.0f))) ? 1 : 0), ((((a) < (0.0f))) ? 1 : 0)))));
#line 432 "ScalarModule.cs"
            break;
#line 433 "ScalarModule.cs"
        case 7:
#line 433 "ScalarModule.cs"
#line 433 "ScalarModule.cs"
            float* csharp2cuda_temp_7 = &(result);
#line 433 "ScalarModule.cs"
            float csharp2cuda_temp_8;
#line 433 "ScalarModule.cs"
            if (((a) > (0.0f)))
            {
#line 433 "ScalarModule.cs"
                csharp2cuda_temp_8 = a;
            }
            else
            {
#line 433 "ScalarModule.cs"
                csharp2cuda_temp_8 = 0.0f;
            }
            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 433 "ScalarModule.cs"
            break;
#line 434 "ScalarModule.cs"
        case 8:
#line 434 "ScalarModule.cs"
#line 434 "ScalarModule.cs"
            float* csharp2cuda_temp_9 = &(result);
            (*(csharp2cuda_temp_9) = csharp2cuda_f32_minimum(a, b));
#line 434 "ScalarModule.cs"
            break;
#line 435 "ScalarModule.cs"
        case 9:
#line 435 "ScalarModule.cs"
#line 435 "ScalarModule.cs"
            float* csharp2cuda_temp_10 = &(result);
            (*(csharp2cuda_temp_10) = csharp2cuda_f32_maximum(a, b));
#line 435 "ScalarModule.cs"
            break;
#line 436 "ScalarModule.cs"
        case 10:
#line 439 "ScalarModule.cs"
            if (((b) > (c)))
#line 440 "ScalarModule.cs"
            {
#line 441 "ScalarModule.cs"
#line 441 "ScalarModule.cs"
                float* csharp2cuda_temp_11 = value;
                (*(csharp2cuda_temp_11) = 0.0f);
#line 442 "ScalarModule.cs"
                return false;
            }
#line 444 "ScalarModule.cs"
#line 444 "ScalarModule.cs"
            float* csharp2cuda_temp_12 = &(result);
#line 444 "ScalarModule.cs"
            float csharp2cuda_temp_13;
#line 444 "ScalarModule.cs"
            if (((a) < (b)))
            {
#line 444 "ScalarModule.cs"
                csharp2cuda_temp_13 = b;
            }
            else
            {
#line 444 "ScalarModule.cs"
                float csharp2cuda_temp_14;
#line 444 "ScalarModule.cs"
                if (((a) > (c)))
                {
#line 444 "ScalarModule.cs"
                    csharp2cuda_temp_14 = c;
                }
                else
                {
#line 444 "ScalarModule.cs"
                    csharp2cuda_temp_14 = a;
                }
#line 444 "ScalarModule.cs"
                csharp2cuda_temp_13 = csharp2cuda_temp_14;
            }
            (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 445 "ScalarModule.cs"
            break;
#line 446 "ScalarModule.cs"
        case 11:
#line 446 "ScalarModule.cs"
#line 446 "ScalarModule.cs"
            float* csharp2cuda_temp_15 = &(result);
#line 446 "ScalarModule.cs"
            float csharp2cuda_temp_16 = __fdiv_rn(1.0f, a);
            (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 446 "ScalarModule.cs"
            break;
#line 447 "ScalarModule.cs"
        case 12:
#line 447 "ScalarModule.cs"
#line 447 "ScalarModule.cs"
            float* csharp2cuda_temp_17 = &(result);
            (*(csharp2cuda_temp_17) = __fmul_rn(a, a));
#line 447 "ScalarModule.cs"
            break;
#line 448 "ScalarModule.cs"
        case 13:
#line 448 "ScalarModule.cs"
#line 448 "ScalarModule.cs"
            float* csharp2cuda_temp_18 = &(result);
            (*(csharp2cuda_temp_18) = __fmul_rn(__fmul_rn(a, a), a));
#line 448 "ScalarModule.cs"
            break;
#line 449 "ScalarModule.cs"
        case 14:
#line 449 "ScalarModule.cs"
#line 449 "ScalarModule.cs"
            float* csharp2cuda_temp_19 = &(result);
            (*(csharp2cuda_temp_19) = mathblocks_square_root(a));
#line 449 "ScalarModule.cs"
            break;
#line 450 "ScalarModule.cs"
        case 15:
#line 450 "ScalarModule.cs"
#line 450 "ScalarModule.cs"
            float* csharp2cuda_temp_20 = &(result);
            (*(csharp2cuda_temp_20) = mathblocks_cube_root_steps(a, mathblocks_limit_cube_root_newton_steps()));
#line 450 "ScalarModule.cs"
            break;
#line 451 "ScalarModule.cs"
        case 16:
#line 451 "ScalarModule.cs"
#line 451 "ScalarModule.cs"
            float* csharp2cuda_temp_21 = &(result);
            (*(csharp2cuda_temp_21) = mathblocks_power(a, b));
#line 451 "ScalarModule.cs"
            break;
#line 452 "ScalarModule.cs"
        case 17:
#line 452 "ScalarModule.cs"
#line 452 "ScalarModule.cs"
            float* csharp2cuda_temp_22 = &(result);
            (*(csharp2cuda_temp_22) = mathblocks_exponential(a));
#line 452 "ScalarModule.cs"
            break;
#line 453 "ScalarModule.cs"
        case 18:
#line 453 "ScalarModule.cs"
#line 453 "ScalarModule.cs"
            float* csharp2cuda_temp_23 = &(result);
            (*(csharp2cuda_temp_23) = mathblocks_natural_logarithm(a));
#line 453 "ScalarModule.cs"
            break;
#line 454 "ScalarModule.cs"
        case 19:
#line 454 "ScalarModule.cs"
#line 454 "ScalarModule.cs"
            float* csharp2cuda_temp_24 = &(result);
            (*(csharp2cuda_temp_24) = mathblocks_binary_logarithm(a));
#line 454 "ScalarModule.cs"
            break;
#line 455 "ScalarModule.cs"
        case 20:
#line 456 "ScalarModule.cs"
#line 456 "ScalarModule.cs"
            float* csharp2cuda_temp_25 = &(result);
#line 456 "ScalarModule.cs"
            float csharp2cuda_temp_26 = __fdiv_rn(mathblocks_natural_logarithm(a), 2.3025851f);
            (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 457 "ScalarModule.cs"
            break;
#line 458 "ScalarModule.cs"
        case 21:
#line 458 "ScalarModule.cs"
#line 458 "ScalarModule.cs"
            float* csharp2cuda_temp_27 = &(result);
            (*(csharp2cuda_temp_27) = mathblocks_sine(a));
#line 458 "ScalarModule.cs"
            break;
#line 459 "ScalarModule.cs"
        case 22:
#line 459 "ScalarModule.cs"
#line 459 "ScalarModule.cs"
            float* csharp2cuda_temp_28 = &(result);
            (*(csharp2cuda_temp_28) = mathblocks_cosine(a));
#line 459 "ScalarModule.cs"
            break;
#line 460 "ScalarModule.cs"
        case 23:
#line 460 "ScalarModule.cs"
#line 460 "ScalarModule.cs"
            float* csharp2cuda_temp_29 = &(result);
#line 460 "ScalarModule.cs"
            float csharp2cuda_temp_30 = __fdiv_rn(mathblocks_sine(a), mathblocks_cosine(a));
            (*(csharp2cuda_temp_29) = csharp2cuda_temp_30);
#line 460 "ScalarModule.cs"
            break;
#line 461 "ScalarModule.cs"
        case 24:
#line 461 "ScalarModule.cs"
#line 461 "ScalarModule.cs"
            float* csharp2cuda_temp_31 = &(result);
            (*(csharp2cuda_temp_31) = mathblocks_arc_sine(a));
#line 461 "ScalarModule.cs"
            break;
#line 462 "ScalarModule.cs"
        case 25:
#line 462 "ScalarModule.cs"
#line 462 "ScalarModule.cs"
            float* csharp2cuda_temp_32 = &(result);
            (*(csharp2cuda_temp_32) = mathblocks_arc_cosine(a));
#line 462 "ScalarModule.cs"
            break;
#line 463 "ScalarModule.cs"
        case 26:
#line 463 "ScalarModule.cs"
#line 463 "ScalarModule.cs"
            float* csharp2cuda_temp_33 = &(result);
            (*(csharp2cuda_temp_33) = mathblocks_arc_tangent(a));
#line 463 "ScalarModule.cs"
            break;
#line 464 "ScalarModule.cs"
        case 27:
#line 464 "ScalarModule.cs"
#line 464 "ScalarModule.cs"
            float* csharp2cuda_temp_34 = &(result);
            (*(csharp2cuda_temp_34) = mathblocks_arc_tangent_2(a, b));
#line 464 "ScalarModule.cs"
            break;
#line 465 "ScalarModule.cs"
        case 28:
#line 466 "ScalarModule.cs"
            {
#line 467 "ScalarModule.cs"
                if (((a) == (0.0f)))
#line 468 "ScalarModule.cs"
                {
#line 469 "ScalarModule.cs"
#line 469 "ScalarModule.cs"
                    float* csharp2cuda_temp_35 = &(result);
                    (*(csharp2cuda_temp_35) = a);
#line 470 "ScalarModule.cs"
                    break;
                }
#line 472 "ScalarModule.cs"
                float positive = mathblocks_exponential(a);
#line 473 "ScalarModule.cs"
                float negative = mathblocks_exponential((-(a)));
#line 474 "ScalarModule.cs"
#line 474 "ScalarModule.cs"
                float* csharp2cuda_temp_36 = &(result);
#line 474 "ScalarModule.cs"
                float csharp2cuda_temp_37 = __fdiv_rn(__fsub_rn(positive, negative), 2.0f);
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 475 "ScalarModule.cs"
                break;
            }
#line 477 "ScalarModule.cs"
        case 29:
#line 478 "ScalarModule.cs"
            {
#line 479 "ScalarModule.cs"
                float positive = mathblocks_exponential(a);
#line 480 "ScalarModule.cs"
                float negative = mathblocks_exponential((-(a)));
#line 481 "ScalarModule.cs"
#line 481 "ScalarModule.cs"
                float* csharp2cuda_temp_38 = &(result);
#line 481 "ScalarModule.cs"
                float csharp2cuda_temp_39 = __fdiv_rn(__fadd_rn(positive, negative), 2.0f);
                (*(csharp2cuda_temp_38) = csharp2cuda_temp_39);
#line 482 "ScalarModule.cs"
                break;
            }
#line 484 "ScalarModule.cs"
        case 30:
#line 485 "ScalarModule.cs"
            {
#line 486 "ScalarModule.cs"
                if (((a) == (0.0f)))
#line 487 "ScalarModule.cs"
                {
#line 488 "ScalarModule.cs"
#line 488 "ScalarModule.cs"
                    float* csharp2cuda_temp_40 = &(result);
                    (*(csharp2cuda_temp_40) = a);
#line 489 "ScalarModule.cs"
                    break;
                }
#line 491 "ScalarModule.cs"
                float positive = mathblocks_exponential(a);
#line 492 "ScalarModule.cs"
                float negative = mathblocks_exponential((-(a)));
#line 493 "ScalarModule.cs"
#line 493 "ScalarModule.cs"
                float* csharp2cuda_temp_41 = &(result);
#line 493 "ScalarModule.cs"
                float csharp2cuda_temp_42 = __fdiv_rn(__fsub_rn(positive, negative), __fadd_rn(positive, negative));
                (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 494 "ScalarModule.cs"
                break;
            }
#line 496 "ScalarModule.cs"
        case 31:
#line 496 "ScalarModule.cs"
#line 496 "ScalarModule.cs"
            float* csharp2cuda_temp_43 = &(result);
            (*(csharp2cuda_temp_43) = mathblocks_inverse_hyperbolic_sine(a));
#line 496 "ScalarModule.cs"
            break;
#line 497 "ScalarModule.cs"
        case 32:
#line 498 "ScalarModule.cs"
#line 498 "ScalarModule.cs"
            float* csharp2cuda_temp_44 = &(result);
            (*(csharp2cuda_temp_44) = mathblocks_natural_logarithm(__fadd_rn(a, mathblocks_square_root(__fsub_rn(__fmul_rn(a, a), 1.0f)))));
#line 500 "ScalarModule.cs"
            break;
#line 501 "ScalarModule.cs"
        case 33:
#line 501 "ScalarModule.cs"
#line 501 "ScalarModule.cs"
            float* csharp2cuda_temp_45 = &(result);
#line 501 "ScalarModule.cs"
            float csharp2cuda_temp_46 = __fdiv_rn(__fmul_rn(2.0f, a), __fsub_rn(1.0f, a));
            (*(csharp2cuda_temp_45) = __fmul_rn(0.5f, mathblocks_log_one_plus(csharp2cuda_temp_46)));
#line 501 "ScalarModule.cs"
            break;
#line 502 "ScalarModule.cs"
        case 34:
#line 502 "ScalarModule.cs"
#line 502 "ScalarModule.cs"
            float* csharp2cuda_temp_47 = &(result);
            (*(csharp2cuda_temp_47) = floorf(a));
#line 502 "ScalarModule.cs"
            break;
#line 503 "ScalarModule.cs"
        case 35:
#line 503 "ScalarModule.cs"
#line 503 "ScalarModule.cs"
            float* csharp2cuda_temp_48 = &(result);
            (*(csharp2cuda_temp_48) = ceilf(a));
#line 503 "ScalarModule.cs"
            break;
#line 504 "ScalarModule.cs"
        case 36:
#line 504 "ScalarModule.cs"
#line 504 "ScalarModule.cs"
            float* csharp2cuda_temp_49 = &(result);
            (*(csharp2cuda_temp_49) = nearbyintf(a));
#line 504 "ScalarModule.cs"
            break;
#line 505 "ScalarModule.cs"
        case 37:
#line 505 "ScalarModule.cs"
#line 505 "ScalarModule.cs"
            float* csharp2cuda_temp_50 = &(result);
            (*(csharp2cuda_temp_50) = truncf(a));
#line 505 "ScalarModule.cs"
            break;
#line 506 "ScalarModule.cs"
        case 38:
#line 506 "ScalarModule.cs"
#line 506 "ScalarModule.cs"
            float* csharp2cuda_temp_51 = &(result);
#line 506 "ScalarModule.cs"
            float csharp2cuda_temp_52 = fmodf(a, b);
            (*(csharp2cuda_temp_51) = csharp2cuda_temp_52);
#line 506 "ScalarModule.cs"
            break;
#line 507 "ScalarModule.cs"
        case 39:
#line 508 "ScalarModule.cs"
#line 508 "ScalarModule.cs"
            float* csharp2cuda_temp_53 = &(result);
#line 508 "ScalarModule.cs"
            float csharp2cuda_temp_54;
#line 508 "ScalarModule.cs"
            if (((a) >= (0.0f)))
            {
#line 508 "ScalarModule.cs"
                csharp2cuda_temp_54 = __fdiv_rn(1.0f, __fadd_rn(1.0f, mathblocks_exponential((-(a)))));
            }
            else
            {
#line 508 "ScalarModule.cs"
                csharp2cuda_temp_54 = __fdiv_rn(mathblocks_exponential(a), __fadd_rn(1.0f, mathblocks_exponential(a)));
            }
            (*(csharp2cuda_temp_53) = csharp2cuda_temp_54);
#line 511 "ScalarModule.cs"
            break;
#line 512 "ScalarModule.cs"
        case 40:
#line 513 "ScalarModule.cs"
#line 513 "ScalarModule.cs"
            float* csharp2cuda_temp_55 = &(result);
#line 513 "ScalarModule.cs"
            float csharp2cuda_temp_56 = __fdiv_rn(a, __fsub_rn(1.0f, a));
            (*(csharp2cuda_temp_55) = mathblocks_natural_logarithm(csharp2cuda_temp_56));
#line 514 "ScalarModule.cs"
            break;
#line 515 "ScalarModule.cs"
        case 41:
#line 516 "ScalarModule.cs"
#line 516 "ScalarModule.cs"
            float* csharp2cuda_temp_57 = &(result);
            (*(csharp2cuda_temp_57) = __fadd_rn(csharp2cuda_f32_maximum(a, 0.0f), mathblocks_log_one_plus(mathblocks_exponential((-(fabsf(a)))))));
#line 518 "ScalarModule.cs"
            break;
#line 519 "ScalarModule.cs"
        case 42:
#line 519 "ScalarModule.cs"
#line 519 "ScalarModule.cs"
            float* csharp2cuda_temp_58 = &(result);
            (*(csharp2cuda_temp_58) = mathblocks_log_one_plus(a));
#line 519 "ScalarModule.cs"
            break;
#line 520 "ScalarModule.cs"
        case 43:
#line 520 "ScalarModule.cs"
#line 520 "ScalarModule.cs"
            float* csharp2cuda_temp_59 = &(result);
            (*(csharp2cuda_temp_59) = mathblocks_error_function(a));
#line 520 "ScalarModule.cs"
            break;
#line 521 "ScalarModule.cs"
        default:
#line 521 "ScalarModule.cs"
#line 521 "ScalarModule.cs"
            float* csharp2cuda_temp_60 = value;
            (*(csharp2cuda_temp_60) = 0.0f);
#line 521 "ScalarModule.cs"
            return false;
    }
#line 524 "ScalarModule.cs"
#line 524 "ScalarModule.cs"
    float* csharp2cuda_temp_61 = value;
    (*(csharp2cuda_temp_61) = result);
#line 525 "ScalarModule.cs"
    return isfinite(result);
}

#line 68 "ScalarModule.cs"
__device__ float mathblocks_scale_binary(float value, int exponent)
#line 70 "ScalarModule.cs"
{
#line 71 "ScalarModule.cs"
    float scaled = value;
#line 72 "ScalarModule.cs"
    int remaining = exponent;
#line 73 "ScalarModule.cs"
    if (((remaining) > (127)))
#line 74 "ScalarModule.cs"
    {
#line 75 "ScalarModule.cs"
#line 75 "ScalarModule.cs"
        float* csharp2cuda_temp_0 = &(scaled);
#line 75 "ScalarModule.cs"
        float csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
        (*(csharp2cuda_temp_0) = __fmul_rn(csharp2cuda_temp_1, 1.7014118E+38f));
#line 76 "ScalarModule.cs"
#line 76 "ScalarModule.cs"
        int* csharp2cuda_temp_2 = &(remaining);
#line 76 "ScalarModule.cs"
        int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
        (*(csharp2cuda_temp_2) = csharp2cuda_i32_sub(csharp2cuda_temp_3, 127));
#line 77 "ScalarModule.cs"
        if (((remaining) > (127)))
#line 78 "ScalarModule.cs"
        {
#line 79 "ScalarModule.cs"
#line 79 "ScalarModule.cs"
            float* csharp2cuda_temp_4 = &(scaled);
#line 79 "ScalarModule.cs"
            float csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
            (*(csharp2cuda_temp_4) = __fmul_rn(csharp2cuda_temp_5, 1.7014118E+38f));
#line 80 "ScalarModule.cs"
#line 80 "ScalarModule.cs"
            int* csharp2cuda_temp_6 = &(remaining);
#line 80 "ScalarModule.cs"
            int csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
            (*(csharp2cuda_temp_6) = csharp2cuda_i32_sub(csharp2cuda_temp_7, 127));
#line 81 "ScalarModule.cs"
            if (((remaining) > (127)))
            {
#line 82 "ScalarModule.cs"
#line 82 "ScalarModule.cs"
                int* csharp2cuda_temp_8 = &(remaining);
                (*(csharp2cuda_temp_8) = 127);
            }
        }
    }
    else
    {
#line 85 "ScalarModule.cs"
        if (((remaining) < (csharp2cuda_i32_neg(126))))
#line 86 "ScalarModule.cs"
        {
#line 87 "ScalarModule.cs"
#line 87 "ScalarModule.cs"
            float* csharp2cuda_temp_9 = &(scaled);
#line 87 "ScalarModule.cs"
            float csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
            (*(csharp2cuda_temp_9) = __fmul_rn(csharp2cuda_temp_10, 1.9721523E-31f));
#line 88 "ScalarModule.cs"
#line 88 "ScalarModule.cs"
            int* csharp2cuda_temp_11 = &(remaining);
#line 88 "ScalarModule.cs"
            int csharp2cuda_temp_12 = *(csharp2cuda_temp_11);
            (*(csharp2cuda_temp_11) = csharp2cuda_i32_add(csharp2cuda_temp_12, 102));
#line 89 "ScalarModule.cs"
            if (((remaining) < (csharp2cuda_i32_neg(126))))
#line 90 "ScalarModule.cs"
            {
#line 91 "ScalarModule.cs"
#line 91 "ScalarModule.cs"
                float* csharp2cuda_temp_13 = &(scaled);
#line 91 "ScalarModule.cs"
                float csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
                (*(csharp2cuda_temp_13) = __fmul_rn(csharp2cuda_temp_14, 1.9721523E-31f));
#line 92 "ScalarModule.cs"
#line 92 "ScalarModule.cs"
                int* csharp2cuda_temp_15 = &(remaining);
#line 92 "ScalarModule.cs"
                int csharp2cuda_temp_16 = *(csharp2cuda_temp_15);
                (*(csharp2cuda_temp_15) = csharp2cuda_i32_add(csharp2cuda_temp_16, 102));
#line 93 "ScalarModule.cs"
                if (((remaining) < (csharp2cuda_i32_neg(126))))
                {
#line 94 "ScalarModule.cs"
#line 94 "ScalarModule.cs"
                    int* csharp2cuda_temp_17 = &(remaining);
                    (*(csharp2cuda_temp_17) = csharp2cuda_i32_neg(126));
                }
            }
        }
    }
#line 98 "ScalarModule.cs"
    return __fmul_rn(scaled, __int_as_float(csharp2cuda_i32_shl(csharp2cuda_i32_add(remaining, 127), 23)));
}

#line 230 "ScalarModule.cs"
__device__ float mathblocks_sine(float value)
#line 232 "ScalarModule.cs"
{
#line 234 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 235 "ScalarModule.cs"
        return value;
    }
#line 236 "ScalarModule.cs"
    float sign = 1.0f;
#line 237 "ScalarModule.cs"
    float x = value;
#line 238 "ScalarModule.cs"
    if (((x) < (0.0f)))
#line 239 "ScalarModule.cs"
    {
#line 240 "ScalarModule.cs"
#line 240 "ScalarModule.cs"
        float* csharp2cuda_temp_0 = &(sign);
        (*(csharp2cuda_temp_0) = (-(1.0f)));
#line 241 "ScalarModule.cs"
#line 241 "ScalarModule.cs"
        float* csharp2cuda_temp_1 = &(x);
        (*(csharp2cuda_temp_1) = (-(x)));
    }
#line 243 "ScalarModule.cs"
    float csharp2cuda_temp_2 = __fdiv_rn(x, 0.7853982f);
#line 243 "ScalarModule.cs"
    float octant_value = floorf(csharp2cuda_temp_2);
#line 244 "ScalarModule.cs"
    int octant = csharp2cuda_f64_to_i32(__fsub_rn(octant_value, __fmul_rn(floorf(__fmul_rn(octant_value, 0.125f)), 8.0f)));
#line 245 "ScalarModule.cs"
    if (((csharp2cuda_i32_and(octant, 1)) != (0)))
#line 246 "ScalarModule.cs"
    {
#line 247 "ScalarModule.cs"
#line 247 "ScalarModule.cs"
        int* csharp2cuda_temp_3 = &(octant);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
#line 248 "ScalarModule.cs"
#line 248 "ScalarModule.cs"
        float* csharp2cuda_temp_4 = &(octant_value);
        (*(csharp2cuda_temp_4))++;
    }
#line 250 "ScalarModule.cs"
#line 250 "ScalarModule.cs"
    int* csharp2cuda_temp_5 = &(octant);
#line 250 "ScalarModule.cs"
    int csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
    (*(csharp2cuda_temp_5) = csharp2cuda_i32_and(csharp2cuda_temp_6, 7));
#line 251 "ScalarModule.cs"
    if (((octant) > (3)))
#line 252 "ScalarModule.cs"
    {
#line 253 "ScalarModule.cs"
#line 253 "ScalarModule.cs"
        float* csharp2cuda_temp_7 = &(sign);
        (*(csharp2cuda_temp_7) = (-(sign)));
#line 254 "ScalarModule.cs"
#line 254 "ScalarModule.cs"
        int* csharp2cuda_temp_8 = &(octant);
#line 254 "ScalarModule.cs"
        int csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
        (*(csharp2cuda_temp_8) = csharp2cuda_i32_sub(csharp2cuda_temp_9, 4));
    }
#line 256 "ScalarModule.cs"
    float reduced = __fsub_rn(__fsub_rn(__fsub_rn(x, __fmul_rn(octant_value, 0.78515625f)), __fmul_rn(octant_value, 0.00024187565f)), __fmul_rn(octant_value, 3.774895E-08f));
#line 259 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 260 "ScalarModule.cs"
#line 260 "ScalarModule.cs"
    bool csharp2cuda_temp_10;
#line 260 "ScalarModule.cs"
    if (!(((octant) == (1))))
    {
#line 260 "ScalarModule.cs"
        csharp2cuda_temp_10 = ((octant) == (2));
    }
    else
    {
#line 260 "ScalarModule.cs"
        csharp2cuda_temp_10 = true;
    }
    if (csharp2cuda_temp_10)
#line 261 "ScalarModule.cs"
    {
#line 262 "ScalarModule.cs"
        float polynomial = __fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn((-(1.13585365E-11f)), square), 2.0875701E-09f), square), 2.7557314E-07f), square), 2.4801588E-05f), square), 0.0013888889f), square), 0.041666668f);
#line 269 "ScalarModule.cs"
        return __fmul_rn(sign, __fadd_rn(__fsub_rn(1.0f, __fmul_rn(0.5f, square)), __fmul_rn(__fmul_rn(square, square), polynomial)));
    }
#line 271 "ScalarModule.cs"
    float sine_polynomial = __fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(1.589623E-10f, square), 2.5050747E-08f), square), 2.7557314E-06f), square), 0.0001984127f), square), 0.008333334f), square), 0.16666667f);
#line 278 "ScalarModule.cs"
    return __fmul_rn(sign, __fadd_rn(reduced, __fmul_rn(__fmul_rn(reduced, square), sine_polynomial)));
}

#line 54 "ScalarModule.cs"
__device__ float mathblocks_square_root(float value)
#line 56 "ScalarModule.cs"
{
#line 57 "ScalarModule.cs"
#line 57 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 57 "ScalarModule.cs"
    if (!(((value) == (0.0f))))
    {
#line 57 "ScalarModule.cs"
        bool csharp2cuda_temp_1;
#line 57 "ScalarModule.cs"
        if (isinf(value))
        {
#line 57 "ScalarModule.cs"
            csharp2cuda_temp_1 = ((value) > (0.0f));
        }
        else
        {
#line 57 "ScalarModule.cs"
            csharp2cuda_temp_1 = false;
        }
#line 57 "ScalarModule.cs"
        csharp2cuda_temp_0 = csharp2cuda_temp_1;
    }
    else
    {
#line 57 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 58 "ScalarModule.cs"
        return value;
    }
#line 59 "ScalarModule.cs"
#line 59 "ScalarModule.cs"
    bool csharp2cuda_temp_2;
#line 59 "ScalarModule.cs"
    if (!(((value) < (0.0f))))
    {
#line 59 "ScalarModule.cs"
        csharp2cuda_temp_2 = isnan(value);
    }
    else
    {
#line 59 "ScalarModule.cs"
        csharp2cuda_temp_2 = true;
    }
    if (csharp2cuda_temp_2)
    {
#line 60 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 62 "ScalarModule.cs"
    return sqrtf(value);
}