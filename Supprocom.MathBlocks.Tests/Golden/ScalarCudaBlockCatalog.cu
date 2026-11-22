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

#line 418 "ScalarModule.cs"
__device__ float mathblocks_arc_cosine(float value);

#line 641 "ScalarModule.cs"
__device__ float mathblocks_arc_sine(float value);

#line 368 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent(float value);

#line 400 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent_2(float y, float x);

#line 211 "ScalarModule.cs"
__device__ float mathblocks_binary_logarithm(float value);

#line 323 "ScalarModule.cs"
__device__ float mathblocks_cosine(float value);

#line 257 "ScalarModule.cs"
__device__ float mathblocks_cube_root(float value);

#line 260 "ScalarModule.cs"
__device__ float mathblocks_cube_root_steps(float value, int newton_steps);

#line 439 "ScalarModule.cs"
__device__ float mathblocks_error_function(float value);

#line 143 "ScalarModule.cs"
__device__ float mathblocks_exponential(float value);

#line 222 "ScalarModule.cs"
__device__ float mathblocks_integer_power(float value, long long exponent);

#line 428 "ScalarModule.cs"
__device__ float mathblocks_inverse_hyperbolic_sine(float value);

#line 202 "ScalarModule.cs"
__device__ float mathblocks_log_one_plus(float value);

#line 104 "ScalarModule.cs"
__device__ float mathblocks_modulo(float value, float modulus);

#line 165 "ScalarModule.cs"
__device__ float mathblocks_natural_logarithm(float value);

#line 42 "ScalarModule.cs"
__device__ float mathblocks_positive_infinity();

#line 244 "ScalarModule.cs"
__device__ float mathblocks_power(float value, float exponent);

#line 48 "ScalarModule.cs"
__device__ float mathblocks_quiet_nan();

#line 570 "ScalarModule.cs"
__device__ void mathblocks_scalar_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 462 "ScalarModule.cs"
__device__ bool mathblocks_scalar_value(int opcode, float a, float b, float c, float* value);

#line 68 "ScalarModule.cs"
__device__ float mathblocks_scale_binary(float value, int exponent);

#line 272 "ScalarModule.cs"
__device__ float mathblocks_sine(float value);

#line 54 "ScalarModule.cs"
__device__ float mathblocks_square_root(float value);

#line 418 "ScalarModule.cs"
__device__ float mathblocks_arc_cosine(float value)
#line 420 "ScalarModule.cs"
{
#line 421 "ScalarModule.cs"
#line 421 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 421 "ScalarModule.cs"
    if (!(((value) < ((-(1.0f))))))
    {
#line 421 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((value) > (1.0f));
    }
    else
    {
#line 421 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 422 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 423 "ScalarModule.cs"
    return mathblocks_arc_tangent_2(mathblocks_square_root(__fmul_rn(__fsub_rn(1.0f, value), __fadd_rn(1.0f, value))), value);
}

#line 641 "ScalarModule.cs"
__device__ float mathblocks_arc_sine(float value)
#line 643 "ScalarModule.cs"
{
#line 644 "ScalarModule.cs"
#line 644 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 644 "ScalarModule.cs"
    if (!(((value) < ((-(1.0f))))))
    {
#line 644 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((value) > (1.0f));
    }
    else
    {
#line 644 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 644 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 644 "ScalarModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 644 "ScalarModule.cs"
        csharp2cuda_temp_1 = isnan(value);
    }
    else
    {
#line 644 "ScalarModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 645 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 646 "ScalarModule.cs"
    return mathblocks_arc_tangent_2(value, mathblocks_square_root(__fmul_rn(__fsub_rn(1.0f, value), __fadd_rn(1.0f, value))));
}

#line 368 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent(float value)
#line 370 "ScalarModule.cs"
{
#line 372 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 373 "ScalarModule.cs"
        return value;
    }
#line 374 "ScalarModule.cs"
    float csharp2cuda_temp_0;
#line 374 "ScalarModule.cs"
    if (((value) < (0.0f)))
    {
#line 374 "ScalarModule.cs"
        csharp2cuda_temp_0 = (-(1.0f));
    }
    else
    {
#line 374 "ScalarModule.cs"
        csharp2cuda_temp_0 = 1.0f;
    }
#line 374 "ScalarModule.cs"
    float sign = csharp2cuda_temp_0;
#line 375 "ScalarModule.cs"
    float x = fabsf(value);
#line 376 "ScalarModule.cs"
    float offset = 0.0f;
#line 377 "ScalarModule.cs"
    if (((x) > (2.4142137f)))
#line 378 "ScalarModule.cs"
    {
#line 379 "ScalarModule.cs"
#line 379 "ScalarModule.cs"
        float* csharp2cuda_temp_1 = &(offset);
#line 379 "ScalarModule.cs"
        float csharp2cuda_temp_2 = __fdiv_rn(3.1415927f, 2.0f);
        (*(csharp2cuda_temp_1) = csharp2cuda_temp_2);
#line 380 "ScalarModule.cs"
#line 380 "ScalarModule.cs"
        float* csharp2cuda_temp_3 = &(x);
#line 380 "ScalarModule.cs"
        float csharp2cuda_temp_4 = __fdiv_rn((-(1.0f)), x);
        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
    }
    else
    {
#line 382 "ScalarModule.cs"
        if (((x) > (0.41421357f)))
#line 383 "ScalarModule.cs"
        {
#line 384 "ScalarModule.cs"
#line 384 "ScalarModule.cs"
            float* csharp2cuda_temp_5 = &(offset);
#line 384 "ScalarModule.cs"
            float csharp2cuda_temp_6 = __fdiv_rn(3.1415927f, 4.0f);
            (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 385 "ScalarModule.cs"
#line 385 "ScalarModule.cs"
            float* csharp2cuda_temp_7 = &(x);
#line 385 "ScalarModule.cs"
            float csharp2cuda_temp_8 = __fdiv_rn(__fsub_rn(x, 1.0f), __fadd_rn(x, 1.0f));
            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
        }
    }
#line 388 "ScalarModule.cs"
    float z = __fmul_rn(x, x);
#line 389 "ScalarModule.cs"
    float numerator = __fsub_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fsub_rn(__fmul_rn((-(0.87506086f)), z), 16.157537f), z), 75.00856f), z), 122.886665f), z), 64.85022f);
#line 393 "ScalarModule.cs"
    float denominator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(z, 24.858465f), z), 165.02701f), z), 432.88107f), z), 485.3904f), z), 194.55066f);
#line 397 "ScalarModule.cs"
#line 397 "ScalarModule.cs"
    float csharp2cuda_temp_9 = __fdiv_rn(__fmul_rn(__fmul_rn(x, z), numerator), denominator);
    return __fmul_rn(sign, __fadd_rn(__fadd_rn(offset, x), csharp2cuda_temp_9));
}

#line 400 "ScalarModule.cs"
__device__ float mathblocks_arc_tangent_2(float y, float x)
#line 402 "ScalarModule.cs"
{
#line 403 "ScalarModule.cs"
    const float pi = 3.1415927f;
#line 404 "ScalarModule.cs"
    if (((x) > (0.0f)))
    {
#line 405 "ScalarModule.cs"
#line 405 "ScalarModule.cs"
        float csharp2cuda_temp_0 = __fdiv_rn(y, x);
        return mathblocks_arc_tangent(csharp2cuda_temp_0);
    }
#line 406 "ScalarModule.cs"
    if (((x) < (0.0f)))
    {
#line 407 "ScalarModule.cs"
#line 407 "ScalarModule.cs"
        float csharp2cuda_temp_1;
#line 407 "ScalarModule.cs"
        if ((!(signbit(((double)(y))))))
        {
#line 408 "ScalarModule.cs"
            float csharp2cuda_temp_2 = __fdiv_rn(y, x);
#line 407 "ScalarModule.cs"
            csharp2cuda_temp_1 = __fadd_rn(mathblocks_arc_tangent(csharp2cuda_temp_2), pi);
        }
        else
        {
#line 409 "ScalarModule.cs"
            float csharp2cuda_temp_3 = __fdiv_rn(y, x);
#line 407 "ScalarModule.cs"
            csharp2cuda_temp_1 = __fsub_rn(mathblocks_arc_tangent(csharp2cuda_temp_3), pi);
        }
        return csharp2cuda_temp_1;
    }
#line 410 "ScalarModule.cs"
    if (((y) > (0.0f)))
    {
#line 411 "ScalarModule.cs"
        return __fdiv_rn(pi, 2.0f);
    }
#line 412 "ScalarModule.cs"
    if (((y) < (0.0f)))
    {
#line 413 "ScalarModule.cs"
        return __fdiv_rn((-(pi)), 2.0f);
    }
#line 415 "ScalarModule.cs"
#line 415 "ScalarModule.cs"
    float csharp2cuda_temp_4;
#line 415 "ScalarModule.cs"
    if (signbit(((double)(x))))
    {
#line 415 "ScalarModule.cs"
        csharp2cuda_temp_4 = copysignf(pi, y);
    }
    else
    {
#line 415 "ScalarModule.cs"
        csharp2cuda_temp_4 = y;
    }
    return csharp2cuda_temp_4;
}

#line 211 "ScalarModule.cs"
__device__ float mathblocks_binary_logarithm(float value)
#line 213 "ScalarModule.cs"
{
#line 214 "ScalarModule.cs"
    unsigned int bits = ((unsigned int)(__float_as_int(value)));
#line 215 "ScalarModule.cs"
    int exponent = csharp2cuda_i32_from_bits(((csharp2cuda_u32_shr(bits, 23)) & (255u)));
#line 216 "ScalarModule.cs"
    unsigned int fraction = ((bits) & (8388607u));
#line 217 "ScalarModule.cs"
#line 217 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 217 "ScalarModule.cs"
    if (((exponent) > (0)))
    {
#line 217 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((exponent) < (255));
    }
    else
    {
#line 217 "ScalarModule.cs"
        csharp2cuda_temp_0 = false;
    }
#line 217 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 217 "ScalarModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 217 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((fraction) == (0u));
    }
    else
    {
#line 217 "ScalarModule.cs"
        csharp2cuda_temp_1 = false;
    }
    if (csharp2cuda_temp_1)
    {
#line 218 "ScalarModule.cs"
        return ((float)(csharp2cuda_i32_sub(exponent, 127)));
    }
#line 219 "ScalarModule.cs"
    return __fdiv_rn(mathblocks_natural_logarithm(value), 0.6931472f);
}

#line 323 "ScalarModule.cs"
__device__ float mathblocks_cosine(float value)
#line 325 "ScalarModule.cs"
{
#line 326 "ScalarModule.cs"
    float x = fabsf(value);
#line 327 "ScalarModule.cs"
    float sign = 1.0f;
#line 328 "ScalarModule.cs"
    float csharp2cuda_temp_0 = __fdiv_rn(x, 0.7853982f);
#line 328 "ScalarModule.cs"
    float octant_value = floorf(csharp2cuda_temp_0);
#line 329 "ScalarModule.cs"
    int octant = csharp2cuda_f64_to_i32(__fsub_rn(octant_value, __fmul_rn(floorf(__fmul_rn(octant_value, 0.125f)), 8.0f)));
#line 330 "ScalarModule.cs"
    if (((csharp2cuda_i32_and(octant, 1)) != (0)))
#line 331 "ScalarModule.cs"
    {
#line 332 "ScalarModule.cs"
#line 332 "ScalarModule.cs"
        int* csharp2cuda_temp_1 = &(octant);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
#line 333 "ScalarModule.cs"
#line 333 "ScalarModule.cs"
        float* csharp2cuda_temp_2 = &(octant_value);
        (*(csharp2cuda_temp_2))++;
    }
#line 335 "ScalarModule.cs"
#line 335 "ScalarModule.cs"
    int* csharp2cuda_temp_3 = &(octant);
#line 335 "ScalarModule.cs"
    int csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_and(csharp2cuda_temp_4, 7));
#line 336 "ScalarModule.cs"
    if (((octant) > (3)))
#line 337 "ScalarModule.cs"
    {
#line 338 "ScalarModule.cs"
#line 338 "ScalarModule.cs"
        int* csharp2cuda_temp_5 = &(octant);
#line 338 "ScalarModule.cs"
        int csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
        (*(csharp2cuda_temp_5) = csharp2cuda_i32_sub(csharp2cuda_temp_6, 4));
#line 339 "ScalarModule.cs"
#line 339 "ScalarModule.cs"
        float* csharp2cuda_temp_7 = &(sign);
        (*(csharp2cuda_temp_7) = (-(sign)));
    }
#line 341 "ScalarModule.cs"
    if (((octant) > (1)))
    {
#line 342 "ScalarModule.cs"
#line 342 "ScalarModule.cs"
        float* csharp2cuda_temp_8 = &(sign);
        (*(csharp2cuda_temp_8) = (-(sign)));
    }
#line 343 "ScalarModule.cs"
    float reduced = __fsub_rn(__fsub_rn(__fsub_rn(x, __fmul_rn(octant_value, 0.78515625f)), __fmul_rn(octant_value, 0.00024187565f)), __fmul_rn(octant_value, 3.774895E-08f));
#line 346 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 347 "ScalarModule.cs"
#line 347 "ScalarModule.cs"
    bool csharp2cuda_temp_9;
#line 347 "ScalarModule.cs"
    if (!(((octant) == (1))))
    {
#line 347 "ScalarModule.cs"
        csharp2cuda_temp_9 = ((octant) == (2));
    }
    else
    {
#line 347 "ScalarModule.cs"
        csharp2cuda_temp_9 = true;
    }
    if (csharp2cuda_temp_9)
#line 348 "ScalarModule.cs"
    {
#line 349 "ScalarModule.cs"
        float sine_polynomial = __fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(1.589623E-10f, square), 2.5050747E-08f), square), 2.7557314E-06f), square), 0.0001984127f), square), 0.008333334f), square), 0.16666667f);
#line 356 "ScalarModule.cs"
        return __fmul_rn(sign, __fadd_rn(reduced, __fmul_rn(__fmul_rn(reduced, square), sine_polynomial)));
    }
#line 358 "ScalarModule.cs"
    float polynomial = __fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn((-(1.13585365E-11f)), square), 2.0875701E-09f), square), 2.7557314E-07f), square), 2.4801588E-05f), square), 0.0013888889f), square), 0.041666668f);
#line 365 "ScalarModule.cs"
    return __fmul_rn(sign, __fadd_rn(__fsub_rn(1.0f, __fmul_rn(0.5f, square)), __fmul_rn(__fmul_rn(square, square), polynomial)));
}

#line 257 "ScalarModule.cs"
__device__ float mathblocks_cube_root(float value)
#line 257 "ScalarModule.cs"
{
#line 258 "ScalarModule.cs"
    return mathblocks_cube_root_steps(value, 3);
}

#line 260 "ScalarModule.cs"
__device__ float mathblocks_cube_root_steps(float value, int newton_steps)
#line 262 "ScalarModule.cs"
{
#line 263 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 264 "ScalarModule.cs"
        return value;
    }
#line 265 "ScalarModule.cs"
    float magnitude = fabsf(value);
#line 266 "ScalarModule.cs"
    float csharp2cuda_temp_0 = __fdiv_rn(mathblocks_natural_logarithm(magnitude), 3.0f);
#line 266 "ScalarModule.cs"
    float estimate = mathblocks_exponential(csharp2cuda_temp_0);
#line 267 "ScalarModule.cs"
    {
#line 267 "ScalarModule.cs"
        int iteration = 0;
        while (true)
        {
            if (!(((iteration) < (newton_steps))))
                break;
#line 268 "ScalarModule.cs"
#line 268 "ScalarModule.cs"
            float* csharp2cuda_temp_2 = &(estimate);
#line 268 "ScalarModule.cs"
            float csharp2cuda_temp_3 = __fdiv_rn(magnitude, __fmul_rn(estimate, estimate));
#line 268 "ScalarModule.cs"
            float csharp2cuda_temp_4 = __fdiv_rn(__fadd_rn(__fmul_rn(2.0f, estimate), csharp2cuda_temp_3), 3.0f);
            (*(csharp2cuda_temp_2) = csharp2cuda_temp_4);
#line 267 "ScalarModule.cs"
            int* csharp2cuda_temp_1 = &(iteration);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 269 "ScalarModule.cs"
    return copysignf(estimate, value);
}

#line 439 "ScalarModule.cs"
__device__ float mathblocks_error_function(float value)
#line 441 "ScalarModule.cs"
{
#line 443 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 444 "ScalarModule.cs"
        return value;
    }
#line 445 "ScalarModule.cs"
    float magnitude = fabsf(value);
#line 446 "ScalarModule.cs"
    float t = __fdiv_rn(1.0f, __fadd_rn(1.0f, __fmul_rn(0.5f, magnitude)));
#line 447 "ScalarModule.cs"
    float tau = __fmul_rn(t, mathblocks_exponential(__fadd_rn(__fsub_rn(__fmul_rn((-(magnitude)), magnitude), 1.2655122f), __fmul_rn(t, __fadd_rn(1.0000237f, __fmul_rn(t, __fadd_rn(0.37409195f, __fmul_rn(t, __fadd_rn(0.09678418f, __fmul_rn(t, __fadd_rn((-(0.18628806f)), __fmul_rn(t, __fadd_rn(0.27886808f, __fmul_rn(t, __fadd_rn((-(1.135204f)), __fmul_rn(t, __fadd_rn(1.4885159f, __fmul_rn(t, __fadd_rn((-(0.82215226f)), __fmul_rn(t, 0.17087276f))))))))))))))))))));
#line 457 "ScalarModule.cs"
    return copysignf(__fsub_rn(1.0f, tau), value);
}

#line 143 "ScalarModule.cs"
__device__ float mathblocks_exponential(float value)
#line 145 "ScalarModule.cs"
{
#line 146 "ScalarModule.cs"
    if (((value) > (88.72284f)))
    {
#line 147 "ScalarModule.cs"
        return mathblocks_positive_infinity();
    }
#line 148 "ScalarModule.cs"
    if (((value) < ((-(103.972084f)))))
    {
#line 149 "ScalarModule.cs"
        return 0.0f;
    }
#line 151 "ScalarModule.cs"
    float exponent_value = floorf(__fadd_rn(__fmul_rn(1.442695f, value), 0.5f));
#line 152 "ScalarModule.cs"
    int exponent = csharp2cuda_f64_to_i32(exponent_value);
#line 153 "ScalarModule.cs"
    float reduced = __fsub_rn(value, __fmul_rn(exponent_value, 0.6933594f));
#line 154 "ScalarModule.cs"
#line 154 "ScalarModule.cs"
    float* csharp2cuda_temp_0 = &(reduced);
#line 154 "ScalarModule.cs"
    float csharp2cuda_temp_1 = *(csharp2cuda_temp_0);
    (*(csharp2cuda_temp_0) = __fsub_rn(csharp2cuda_temp_1, __fmul_rn(exponent_value, (-(0.00021219444f)))));
#line 155 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 156 "ScalarModule.cs"
    float numerator = __fmul_rn(reduced, __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(0.0001261772f, square), 0.03029944f), square), 1.0f));
#line 158 "ScalarModule.cs"
    float denominator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(3.001985E-06f, square), 0.0025244835f), square), 0.22726555f), square), 2.0f);
#line 161 "ScalarModule.cs"
    float csharp2cuda_temp_2 = __fdiv_rn(__fmul_rn(2.0f, numerator), __fsub_rn(denominator, numerator));
#line 161 "ScalarModule.cs"
    float result = __fadd_rn(1.0f, csharp2cuda_temp_2);
#line 162 "ScalarModule.cs"
    return mathblocks_scale_binary(result, exponent);
}

#line 222 "ScalarModule.cs"
__device__ float mathblocks_integer_power(float value, long long exponent)
#line 224 "ScalarModule.cs"
{
#line 225 "ScalarModule.cs"
    if (((exponent) == (((long long)(0)))))
    {
#line 226 "ScalarModule.cs"
        return 1.0f;
    }
#line 227 "ScalarModule.cs"
    bool negative = ((exponent) < (((long long)(0))));
#line 228 "ScalarModule.cs"
    unsigned long long csharp2cuda_temp_0;
#line 228 "ScalarModule.cs"
    if (negative)
    {
#line 228 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((((unsigned long long)(csharp2cuda_i64_neg(csharp2cuda_i64_add(exponent, ((long long)(1))))))) + (1ull));
    }
    else
    {
#line 228 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((unsigned long long)(exponent));
    }
#line 228 "ScalarModule.cs"
    unsigned long long remaining = csharp2cuda_temp_0;
#line 231 "ScalarModule.cs"
    float power_base = value;
#line 232 "ScalarModule.cs"
    float result = 1.0f;
#line 233 "ScalarModule.cs"
    while (true)
    {
        if (!(((remaining) != (0ull))))
            break;
#line 234 "ScalarModule.cs"
        {
#line 235 "ScalarModule.cs"
            if (((((remaining) & (1ull))) != (0ull)))
            {
#line 236 "ScalarModule.cs"
#line 236 "ScalarModule.cs"
                float* csharp2cuda_temp_1 = &(result);
#line 236 "ScalarModule.cs"
                float csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
                (*(csharp2cuda_temp_1) = __fmul_rn(csharp2cuda_temp_2, power_base));
            }
#line 237 "ScalarModule.cs"
#line 237 "ScalarModule.cs"
            unsigned long long* csharp2cuda_temp_3 = &(remaining);
#line 237 "ScalarModule.cs"
            unsigned long long csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
            (*(csharp2cuda_temp_3) = csharp2cuda_u64_shr(csharp2cuda_temp_4, 1));
#line 238 "ScalarModule.cs"
            if (((remaining) != (0ull)))
            {
#line 239 "ScalarModule.cs"
#line 239 "ScalarModule.cs"
                float* csharp2cuda_temp_5 = &(power_base);
#line 239 "ScalarModule.cs"
                float csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
                (*(csharp2cuda_temp_5) = __fmul_rn(csharp2cuda_temp_6, power_base));
            }
        }
    }
#line 241 "ScalarModule.cs"
#line 241 "ScalarModule.cs"
    float csharp2cuda_temp_7;
#line 241 "ScalarModule.cs"
    if (negative)
    {
#line 241 "ScalarModule.cs"
        csharp2cuda_temp_7 = __fdiv_rn(1.0f, result);
    }
    else
    {
#line 241 "ScalarModule.cs"
        csharp2cuda_temp_7 = result;
    }
    return csharp2cuda_temp_7;
}

#line 428 "ScalarModule.cs"
__device__ float mathblocks_inverse_hyperbolic_sine(float value)
#line 430 "ScalarModule.cs"
{
#line 431 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 432 "ScalarModule.cs"
        return value;
    }
#line 433 "ScalarModule.cs"
    float magnitude = fabsf(value);
#line 434 "ScalarModule.cs"
    return copysignf(mathblocks_natural_logarithm(__fadd_rn(magnitude, mathblocks_square_root(__fadd_rn(__fmul_rn(magnitude, magnitude), 1.0f)))), value);
}

#line 202 "ScalarModule.cs"
__device__ float mathblocks_log_one_plus(float value)
#line 204 "ScalarModule.cs"
{
#line 205 "ScalarModule.cs"
    float sum = __fadd_rn(1.0f, value);
#line 206 "ScalarModule.cs"
#line 206 "ScalarModule.cs"
    float csharp2cuda_temp_0;
#line 206 "ScalarModule.cs"
    if (((sum) == (1.0f)))
    {
#line 206 "ScalarModule.cs"
        csharp2cuda_temp_0 = value;
    }
    else
    {
#line 208 "ScalarModule.cs"
        float csharp2cuda_temp_1 = __fdiv_rn(__fsub_rn(__fsub_rn(sum, 1.0f), value), sum);
#line 206 "ScalarModule.cs"
        csharp2cuda_temp_0 = __fsub_rn(mathblocks_natural_logarithm(sum), csharp2cuda_temp_1);
    }
    return csharp2cuda_temp_0;
}

#line 104 "ScalarModule.cs"
__device__ float mathblocks_modulo(float value, float modulus)
#line 106 "ScalarModule.cs"
{
#line 107 "ScalarModule.cs"
    unsigned int valueBits = ((unsigned int)(__float_as_int(value)));
#line 108 "ScalarModule.cs"
    unsigned int modulusBits = ((unsigned int)(__float_as_int(modulus)));
#line 109 "ScalarModule.cs"
    unsigned int sign = ((valueBits) & (2147483648u));
#line 110 "ScalarModule.cs"
    unsigned int magnitude = ((valueBits) & (2147483647u));
#line 111 "ScalarModule.cs"
    unsigned int divisor = ((modulusBits) & (2147483647u));
#line 112 "ScalarModule.cs"
#line 112 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 112 "ScalarModule.cs"
    if (!(((divisor) == (0u))))
    {
#line 112 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((magnitude) >= (2139095040u));
    }
    else
    {
#line 112 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 112 "ScalarModule.cs"
    bool csharp2cuda_temp_1;
#line 112 "ScalarModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 112 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((divisor) > (2139095040u));
    }
    else
    {
#line 112 "ScalarModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 113 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 114 "ScalarModule.cs"
    if (((magnitude) < (divisor)))
    {
#line 115 "ScalarModule.cs"
        return value;
    }
#line 117 "ScalarModule.cs"
    int valueExponent = csharp2cuda_i32_from_bits(csharp2cuda_u32_shr(magnitude, 23));
#line 118 "ScalarModule.cs"
    int modulusExponent = csharp2cuda_i32_from_bits(csharp2cuda_u32_shr(divisor, 23));
#line 119 "ScalarModule.cs"
    unsigned long long remainder = ((unsigned long long)(((magnitude) & (8388607u))));
#line 120 "ScalarModule.cs"
    unsigned long long step = ((unsigned long long)(((divisor) & (8388607u))));
#line 121 "ScalarModule.cs"
    if (((valueExponent) == (0)))
    {
#line 122 "ScalarModule.cs"
#line 122 "ScalarModule.cs"
        int* csharp2cuda_temp_2 = &(valueExponent);
        (*(csharp2cuda_temp_2) = 1);
    }
    else
    {
#line 124 "ScalarModule.cs"
#line 124 "ScalarModule.cs"
        unsigned long long* csharp2cuda_temp_3 = &(remainder);
#line 124 "ScalarModule.cs"
        unsigned long long csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
        (*(csharp2cuda_temp_3) = ((csharp2cuda_temp_4) | (((unsigned long long)(8388608u)))));
    }
#line 125 "ScalarModule.cs"
    if (((modulusExponent) == (0)))
    {
#line 126 "ScalarModule.cs"
#line 126 "ScalarModule.cs"
        int* csharp2cuda_temp_5 = &(modulusExponent);
        (*(csharp2cuda_temp_5) = 1);
    }
    else
    {
#line 128 "ScalarModule.cs"
#line 128 "ScalarModule.cs"
        unsigned long long* csharp2cuda_temp_6 = &(step);
#line 128 "ScalarModule.cs"
        unsigned long long csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
        (*(csharp2cuda_temp_6) = ((csharp2cuda_temp_7) | (((unsigned long long)(8388608u)))));
    }
#line 130 "ScalarModule.cs"
    int shift = csharp2cuda_i32_sub(valueExponent, modulusExponent);
#line 131 "ScalarModule.cs"
#line 131 "ScalarModule.cs"
    unsigned long long* csharp2cuda_temp_8 = &(remainder);
#line 131 "ScalarModule.cs"
    unsigned long long csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
    (*(csharp2cuda_temp_8) = csharp2cuda_u64_rem(csharp2cuda_temp_9, step));
#line 132 "ScalarModule.cs"
    while (true)
    {
        if (!(((shift) > (0))))
            break;
#line 133 "ScalarModule.cs"
        {
#line 134 "ScalarModule.cs"
            int csharp2cuda_temp_10;
#line 134 "ScalarModule.cs"
            if (((shift) < (40)))
            {
#line 134 "ScalarModule.cs"
                csharp2cuda_temp_10 = shift;
            }
            else
            {
#line 134 "ScalarModule.cs"
                csharp2cuda_temp_10 = 40;
            }
#line 134 "ScalarModule.cs"
            int count = csharp2cuda_temp_10;
#line 135 "ScalarModule.cs"
#line 135 "ScalarModule.cs"
            unsigned long long* csharp2cuda_temp_11 = &(remainder);
#line 135 "ScalarModule.cs"
            unsigned long long csharp2cuda_temp_12 = csharp2cuda_u64_rem(csharp2cuda_u64_shl(remainder, count), step);
            (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 136 "ScalarModule.cs"
#line 136 "ScalarModule.cs"
            int* csharp2cuda_temp_13 = &(shift);
#line 136 "ScalarModule.cs"
            int csharp2cuda_temp_14 = *(csharp2cuda_temp_13);
            (*(csharp2cuda_temp_13) = csharp2cuda_i32_sub(csharp2cuda_temp_14, count));
        }
    }
#line 139 "ScalarModule.cs"
    float scaled = mathblocks_scale_binary(((float)(remainder)), csharp2cuda_i32_sub(modulusExponent, 150));
#line 140 "ScalarModule.cs"
    return __int_as_float(csharp2cuda_i32_from_bits(((((unsigned int)(__float_as_int(scaled)))) | (sign))));
}

#line 165 "ScalarModule.cs"
__device__ float mathblocks_natural_logarithm(float value)
#line 167 "ScalarModule.cs"
{
#line 168 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 169 "ScalarModule.cs"
        return (-(mathblocks_positive_infinity()));
    }
#line 170 "ScalarModule.cs"
#line 170 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 170 "ScalarModule.cs"
    if (!(((value) < (0.0f))))
    {
#line 170 "ScalarModule.cs"
        csharp2cuda_temp_0 = isnan(value);
    }
    else
    {
#line 170 "ScalarModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 171 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 172 "ScalarModule.cs"
    if (isinf(value))
    {
#line 173 "ScalarModule.cs"
        return mathblocks_positive_infinity();
    }
#line 175 "ScalarModule.cs"
    int exponent = csharp2cuda_i32_add(ilogbf(value), 1);
#line 176 "ScalarModule.cs"
    float reduced = mathblocks_scale_binary(value, csharp2cuda_i32_neg(exponent));
#line 177 "ScalarModule.cs"
    if (((reduced) < (0.70710677f)))
#line 178 "ScalarModule.cs"
    {
#line 179 "ScalarModule.cs"
#line 179 "ScalarModule.cs"
        int* csharp2cuda_temp_1 = &(exponent);
        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_1));
#line 180 "ScalarModule.cs"
#line 180 "ScalarModule.cs"
        float* csharp2cuda_temp_2 = &(reduced);
        (*(csharp2cuda_temp_2) = __fsub_rn(__fmul_rn(2.0f, reduced), 1.0f));
    }
    else
#line 183 "ScalarModule.cs"
    {
#line 184 "ScalarModule.cs"
#line 184 "ScalarModule.cs"
        float* csharp2cuda_temp_3 = &(reduced);
#line 184 "ScalarModule.cs"
        float csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
        (*(csharp2cuda_temp_3) = __fsub_rn(csharp2cuda_temp_4, 1.0f));
    }
#line 187 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 188 "ScalarModule.cs"
    float numerator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(0.00010187567f, reduced), 0.497495f), reduced), 4.705791f), reduced), 14.498922f), reduced), 17.936869f), reduced), 7.7083874f);
#line 192 "ScalarModule.cs"
    float denominator = __fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fadd_rn(reduced, 11.287358f), reduced), 45.227913f), reduced), 82.987526f), reduced), 71.15447f), reduced), 23.125162f);
#line 196 "ScalarModule.cs"
    float csharp2cuda_temp_5 = __fdiv_rn(__fmul_rn(square, numerator), denominator);
#line 196 "ScalarModule.cs"
    float correction = __fmul_rn(reduced, csharp2cuda_temp_5);
#line 197 "ScalarModule.cs"
#line 197 "ScalarModule.cs"
    float* csharp2cuda_temp_6 = &(correction);
#line 197 "ScalarModule.cs"
    float csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
    (*(csharp2cuda_temp_6) = __fsub_rn(csharp2cuda_temp_7, __fmul_rn(((float)(exponent)), 0.00021219444f)));
#line 198 "ScalarModule.cs"
#line 198 "ScalarModule.cs"
    float* csharp2cuda_temp_8 = &(correction);
#line 198 "ScalarModule.cs"
    float csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
    (*(csharp2cuda_temp_8) = __fsub_rn(csharp2cuda_temp_9, __fmul_rn(0.5f, square)));
#line 199 "ScalarModule.cs"
    return __fadd_rn(__fadd_rn(reduced, correction), __fmul_rn(((float)(exponent)), 0.6933594f));
}

#line 42 "ScalarModule.cs"
__device__ float mathblocks_positive_infinity()
#line 44 "ScalarModule.cs"
{
#line 45 "ScalarModule.cs"
    return __int_as_float(2139095040);
}

#line 244 "ScalarModule.cs"
__device__ float mathblocks_power(float value, float exponent)
#line 246 "ScalarModule.cs"
{
#line 247 "ScalarModule.cs"
#line 247 "ScalarModule.cs"
    bool csharp2cuda_temp_0;
#line 247 "ScalarModule.cs"
    if (((exponent) == (truncf(exponent))))
    {
#line 247 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((fabsf(exponent)) <= (9.223372E+18f));
    }
    else
    {
#line 247 "ScalarModule.cs"
        csharp2cuda_temp_0 = false;
    }
    if (csharp2cuda_temp_0)
    {
#line 248 "ScalarModule.cs"
        return mathblocks_integer_power(value, csharp2cuda_f64_to_i64(exponent));
    }
#line 249 "ScalarModule.cs"
    if (((value) < (0.0f)))
    {
#line 250 "ScalarModule.cs"
        return mathblocks_quiet_nan();
    }
#line 251 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 252 "ScalarModule.cs"
#line 252 "ScalarModule.cs"
        float csharp2cuda_temp_1;
#line 252 "ScalarModule.cs"
        if (((exponent) > (0.0f)))
        {
#line 252 "ScalarModule.cs"
            csharp2cuda_temp_1 = 0.0f;
        }
        else
        {
#line 252 "ScalarModule.cs"
            csharp2cuda_temp_1 = mathblocks_positive_infinity();
        }
        return csharp2cuda_temp_1;
    }
#line 253 "ScalarModule.cs"
    return mathblocks_exponential(__fmul_rn(exponent, mathblocks_natural_logarithm(value)));
}

#line 48 "ScalarModule.cs"
__device__ float mathblocks_quiet_nan()
#line 50 "ScalarModule.cs"
{
#line 51 "ScalarModule.cs"
    return __int_as_float(2143289344);
}

#line 570 "ScalarModule.cs"
__device__ void mathblocks_scalar_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 576 "ScalarModule.cs"
{
#line 577 "ScalarModule.cs"
    if (((threadIdx.x) != (0)))
    {
#line 578 "ScalarModule.cs"
        return;
    }
#line 580 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 580 "ScalarModule.cs"
    if (((input_count) > (0)))
    {
#line 580 "ScalarModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 580 "ScalarModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 580 "ScalarModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 581 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 581 "ScalarModule.cs"
    if (((input_count) > (1)))
    {
#line 581 "ScalarModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 581 "ScalarModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 581 "ScalarModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 582 "ScalarModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 582 "ScalarModule.cs"
    if (((input_count) > (2)))
    {
#line 582 "ScalarModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 582 "ScalarModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 582 "ScalarModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 584 "ScalarModule.cs"
#line 584 "ScalarModule.cs"
    float* csharp2cuda_temp_3 = &((output)->scalar_value);
    (*(csharp2cuda_temp_3) = 0.0f);
#line 585 "ScalarModule.cs"
#line 585 "ScalarModule.cs"
    int* csharp2cuda_temp_4 = &((output)->boolean_value);
    (*(csharp2cuda_temp_4) = 0);
#line 586 "ScalarModule.cs"
#line 586 "ScalarModule.cs"
    int* csharp2cuda_temp_5 = &((output)->valid);
#line 586 "ScalarModule.cs"
    bool csharp2cuda_temp_6;
#line 586 "ScalarModule.cs"
    if (!(((((void*)(first))) == (((void*)(nullptr))))))
    {
#line 586 "ScalarModule.cs"
        csharp2cuda_temp_6 = (first)->valid;
    }
    else
    {
#line 586 "ScalarModule.cs"
        csharp2cuda_temp_6 = true;
    }
    (*(csharp2cuda_temp_5) = csharp2cuda_temp_6);
#line 587 "ScalarModule.cs"
    if (((((void*)(second))) != (((void*)(nullptr)))))
    {
#line 588 "ScalarModule.cs"
#line 588 "ScalarModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 588 "ScalarModule.cs"
        bool csharp2cuda_temp_8 = (output)->valid;
#line 588 "ScalarModule.cs"
        bool csharp2cuda_temp_9;
#line 588 "ScalarModule.cs"
        if (csharp2cuda_temp_8)
        {
#line 588 "ScalarModule.cs"
            csharp2cuda_temp_9 = (second)->valid;
        }
        else
        {
#line 588 "ScalarModule.cs"
            csharp2cuda_temp_9 = false;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_9);
    }
#line 589 "ScalarModule.cs"
    if (((((void*)(third))) != (((void*)(nullptr)))))
    {
#line 590 "ScalarModule.cs"
#line 590 "ScalarModule.cs"
        int* csharp2cuda_temp_10 = &((output)->valid);
#line 590 "ScalarModule.cs"
        bool csharp2cuda_temp_11 = (output)->valid;
#line 590 "ScalarModule.cs"
        bool csharp2cuda_temp_12;
#line 590 "ScalarModule.cs"
        if (csharp2cuda_temp_11)
        {
#line 590 "ScalarModule.cs"
            csharp2cuda_temp_12 = (third)->valid;
        }
        else
        {
#line 590 "ScalarModule.cs"
            csharp2cuda_temp_12 = false;
        }
        (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
    }
#line 591 "ScalarModule.cs"
#line 591 "ScalarModule.cs"
    bool csharp2cuda_temp_13 = (output)->valid;
    if ((!(csharp2cuda_temp_13)))
    {
#line 592 "ScalarModule.cs"
        return;
    }
#line 594 "ScalarModule.cs"
    float csharp2cuda_temp_14;
#line 594 "ScalarModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 594 "ScalarModule.cs"
        csharp2cuda_temp_14 = 0.0f;
    }
    else
    {
#line 594 "ScalarModule.cs"
        csharp2cuda_temp_14 = (first)->scalar_value;
    }
#line 594 "ScalarModule.cs"
    float a = csharp2cuda_temp_14;
#line 595 "ScalarModule.cs"
    float csharp2cuda_temp_15;
#line 595 "ScalarModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 595 "ScalarModule.cs"
        csharp2cuda_temp_15 = 0.0f;
    }
    else
    {
#line 595 "ScalarModule.cs"
        csharp2cuda_temp_15 = (second)->scalar_value;
    }
#line 595 "ScalarModule.cs"
    float b = csharp2cuda_temp_15;
#line 596 "ScalarModule.cs"
    float csharp2cuda_temp_16;
#line 596 "ScalarModule.cs"
    if (((((void*)(third))) == (((void*)(nullptr)))))
    {
#line 596 "ScalarModule.cs"
        csharp2cuda_temp_16 = 0.0f;
    }
    else
    {
#line 596 "ScalarModule.cs"
        csharp2cuda_temp_16 = (third)->scalar_value;
    }
#line 596 "ScalarModule.cs"
    float c = csharp2cuda_temp_16;
#line 597 "ScalarModule.cs"
#line 597 "ScalarModule.cs"
    bool csharp2cuda_temp_17;
#line 597 "ScalarModule.cs"
    if (((opcode) >= (0)))
    {
#line 597 "ScalarModule.cs"
        csharp2cuda_temp_17 = ((opcode) <= (43));
    }
    else
    {
#line 597 "ScalarModule.cs"
        csharp2cuda_temp_17 = false;
    }
    if (csharp2cuda_temp_17)
#line 598 "ScalarModule.cs"
    {
#line 599 "ScalarModule.cs"
        float value = 0.0f;
#line 600 "ScalarModule.cs"
#line 600 "ScalarModule.cs"
        int* csharp2cuda_temp_18 = &((output)->valid);
#line 600 "ScalarModule.cs"
        float* csharp2cuda_temp_19 = &(value);
#line 600 "ScalarModule.cs"
        int csharp2cuda_temp_20 = mathblocks_scalar_value(opcode, a, b, c, csharp2cuda_temp_19);
        (*(csharp2cuda_temp_18) = csharp2cuda_temp_20);
#line 601 "ScalarModule.cs"
#line 601 "ScalarModule.cs"
        float* csharp2cuda_temp_21 = &((output)->scalar_value);
        (*(csharp2cuda_temp_21) = value);
#line 602 "ScalarModule.cs"
        return;
    }
#line 605 "ScalarModule.cs"
    bool scalar_output = true;
#line 606 "ScalarModule.cs"
    switch (opcode)
    {
#line 608 "ScalarModule.cs"
        case 44:
#line 608 "ScalarModule.cs"
#line 608 "ScalarModule.cs"
            int* csharp2cuda_temp_22 = &((output)->boolean_value);
            (*(csharp2cuda_temp_22) = ((a) == (b)));
#line 608 "ScalarModule.cs"
#line 608 "ScalarModule.cs"
            bool* csharp2cuda_temp_23 = &(scalar_output);
            (*(csharp2cuda_temp_23) = false);
#line 608 "ScalarModule.cs"
            break;
#line 609 "ScalarModule.cs"
        case 45:
#line 609 "ScalarModule.cs"
#line 609 "ScalarModule.cs"
            int* csharp2cuda_temp_24 = &((output)->boolean_value);
            (*(csharp2cuda_temp_24) = ((a) != (b)));
#line 609 "ScalarModule.cs"
#line 609 "ScalarModule.cs"
            bool* csharp2cuda_temp_25 = &(scalar_output);
            (*(csharp2cuda_temp_25) = false);
#line 609 "ScalarModule.cs"
            break;
#line 610 "ScalarModule.cs"
        case 46:
#line 610 "ScalarModule.cs"
#line 610 "ScalarModule.cs"
            int* csharp2cuda_temp_26 = &((output)->boolean_value);
            (*(csharp2cuda_temp_26) = ((a) < (b)));
#line 610 "ScalarModule.cs"
#line 610 "ScalarModule.cs"
            bool* csharp2cuda_temp_27 = &(scalar_output);
            (*(csharp2cuda_temp_27) = false);
#line 610 "ScalarModule.cs"
            break;
#line 611 "ScalarModule.cs"
        case 47:
#line 611 "ScalarModule.cs"
#line 611 "ScalarModule.cs"
            int* csharp2cuda_temp_28 = &((output)->boolean_value);
            (*(csharp2cuda_temp_28) = ((a) <= (b)));
#line 611 "ScalarModule.cs"
#line 611 "ScalarModule.cs"
            bool* csharp2cuda_temp_29 = &(scalar_output);
            (*(csharp2cuda_temp_29) = false);
#line 611 "ScalarModule.cs"
            break;
#line 612 "ScalarModule.cs"
        case 48:
#line 612 "ScalarModule.cs"
#line 612 "ScalarModule.cs"
            int* csharp2cuda_temp_30 = &((output)->boolean_value);
            (*(csharp2cuda_temp_30) = ((a) > (b)));
#line 612 "ScalarModule.cs"
#line 612 "ScalarModule.cs"
            bool* csharp2cuda_temp_31 = &(scalar_output);
            (*(csharp2cuda_temp_31) = false);
#line 612 "ScalarModule.cs"
            break;
#line 613 "ScalarModule.cs"
        case 49:
#line 613 "ScalarModule.cs"
#line 613 "ScalarModule.cs"
            int* csharp2cuda_temp_32 = &((output)->boolean_value);
            (*(csharp2cuda_temp_32) = ((a) >= (b)));
#line 613 "ScalarModule.cs"
#line 613 "ScalarModule.cs"
            bool* csharp2cuda_temp_33 = &(scalar_output);
            (*(csharp2cuda_temp_33) = false);
#line 613 "ScalarModule.cs"
            break;
#line 614 "ScalarModule.cs"
        case 50:
#line 615 "ScalarModule.cs"
#line 615 "ScalarModule.cs"
            int* csharp2cuda_temp_34 = &((output)->boolean_value);
#line 615 "ScalarModule.cs"
            bool csharp2cuda_temp_35 = (first)->boolean_value;
#line 615 "ScalarModule.cs"
            bool csharp2cuda_temp_36;
#line 615 "ScalarModule.cs"
            if (csharp2cuda_temp_35)
            {
#line 615 "ScalarModule.cs"
                csharp2cuda_temp_36 = (second)->boolean_value;
            }
            else
            {
#line 615 "ScalarModule.cs"
                csharp2cuda_temp_36 = false;
            }
            (*(csharp2cuda_temp_34) = csharp2cuda_temp_36);
#line 616 "ScalarModule.cs"
#line 616 "ScalarModule.cs"
            bool* csharp2cuda_temp_37 = &(scalar_output);
            (*(csharp2cuda_temp_37) = false);
#line 617 "ScalarModule.cs"
            break;
#line 618 "ScalarModule.cs"
        case 51:
#line 619 "ScalarModule.cs"
#line 619 "ScalarModule.cs"
            int* csharp2cuda_temp_38 = &((output)->boolean_value);
#line 619 "ScalarModule.cs"
            bool csharp2cuda_temp_39 = (first)->boolean_value;
#line 619 "ScalarModule.cs"
            bool csharp2cuda_temp_40;
#line 619 "ScalarModule.cs"
            if (!(csharp2cuda_temp_39))
            {
#line 619 "ScalarModule.cs"
                csharp2cuda_temp_40 = (second)->boolean_value;
            }
            else
            {
#line 619 "ScalarModule.cs"
                csharp2cuda_temp_40 = true;
            }
            (*(csharp2cuda_temp_38) = csharp2cuda_temp_40);
#line 620 "ScalarModule.cs"
#line 620 "ScalarModule.cs"
            bool* csharp2cuda_temp_41 = &(scalar_output);
            (*(csharp2cuda_temp_41) = false);
#line 621 "ScalarModule.cs"
            break;
#line 622 "ScalarModule.cs"
        case 52:
#line 623 "ScalarModule.cs"
#line 623 "ScalarModule.cs"
            int* csharp2cuda_temp_42 = &((output)->boolean_value);
#line 623 "ScalarModule.cs"
            int csharp2cuda_temp_43 = (first)->boolean_value;
#line 623 "ScalarModule.cs"
            int csharp2cuda_temp_44 = (second)->boolean_value;
            (*(csharp2cuda_temp_42) = ((csharp2cuda_temp_43) != (csharp2cuda_temp_44)));
#line 624 "ScalarModule.cs"
#line 624 "ScalarModule.cs"
            bool* csharp2cuda_temp_45 = &(scalar_output);
            (*(csharp2cuda_temp_45) = false);
#line 625 "ScalarModule.cs"
            break;
#line 626 "ScalarModule.cs"
        case 53:
#line 627 "ScalarModule.cs"
#line 627 "ScalarModule.cs"
            int* csharp2cuda_temp_46 = &((output)->boolean_value);
#line 627 "ScalarModule.cs"
            bool csharp2cuda_temp_47 = (first)->boolean_value;
            (*(csharp2cuda_temp_46) = (!(csharp2cuda_temp_47)));
#line 628 "ScalarModule.cs"
#line 628 "ScalarModule.cs"
            bool* csharp2cuda_temp_48 = &(scalar_output);
            (*(csharp2cuda_temp_48) = false);
#line 629 "ScalarModule.cs"
            break;
#line 630 "ScalarModule.cs"
        case 54:
#line 631 "ScalarModule.cs"
#line 631 "ScalarModule.cs"
            float* csharp2cuda_temp_49 = &((output)->scalar_value);
#line 631 "ScalarModule.cs"
            bool csharp2cuda_temp_50 = (first)->boolean_value;
#line 631 "ScalarModule.cs"
            float csharp2cuda_temp_51;
#line 631 "ScalarModule.cs"
            if (csharp2cuda_temp_50)
            {
#line 631 "ScalarModule.cs"
                csharp2cuda_temp_51 = (second)->scalar_value;
            }
            else
            {
#line 631 "ScalarModule.cs"
                csharp2cuda_temp_51 = (third)->scalar_value;
            }
            (*(csharp2cuda_temp_49) = csharp2cuda_temp_51);
#line 632 "ScalarModule.cs"
            break;
#line 633 "ScalarModule.cs"
        default:
#line 633 "ScalarModule.cs"
#line 633 "ScalarModule.cs"
            int* csharp2cuda_temp_52 = &((output)->valid);
            (*(csharp2cuda_temp_52) = 0);
#line 633 "ScalarModule.cs"
            return;
    }
#line 636 "ScalarModule.cs"
#line 636 "ScalarModule.cs"
    bool csharp2cuda_temp_53;
#line 636 "ScalarModule.cs"
    if (scalar_output)
    {
#line 636 "ScalarModule.cs"
        float csharp2cuda_temp_54 = (output)->scalar_value;
#line 636 "ScalarModule.cs"
        csharp2cuda_temp_53 = (!(isfinite(csharp2cuda_temp_54)));
    }
    else
    {
#line 636 "ScalarModule.cs"
        csharp2cuda_temp_53 = false;
    }
    if (csharp2cuda_temp_53)
    {
#line 637 "ScalarModule.cs"
#line 637 "ScalarModule.cs"
        int* csharp2cuda_temp_55 = &((output)->valid);
        (*(csharp2cuda_temp_55) = 0);
    }
}

#line 462 "ScalarModule.cs"
__device__ bool mathblocks_scalar_value(int opcode, float a, float b, float c, float* value)
#line 464 "ScalarModule.cs"
{
#line 465 "ScalarModule.cs"
    float result = 0.0f;
#line 466 "ScalarModule.cs"
    switch (opcode)
    {
#line 468 "ScalarModule.cs"
        case 0:
#line 468 "ScalarModule.cs"
#line 468 "ScalarModule.cs"
            float* csharp2cuda_temp_0 = &(result);
            (*(csharp2cuda_temp_0) = mathblocks_row_value_add(a, b));
#line 468 "ScalarModule.cs"
            break;
#line 469 "ScalarModule.cs"
        case 1:
#line 469 "ScalarModule.cs"
#line 469 "ScalarModule.cs"
            float* csharp2cuda_temp_1 = &(result);
            (*(csharp2cuda_temp_1) = mathblocks_row_value_subtract(a, b));
#line 469 "ScalarModule.cs"
            break;
#line 470 "ScalarModule.cs"
        case 2:
#line 470 "ScalarModule.cs"
#line 470 "ScalarModule.cs"
            float* csharp2cuda_temp_2 = &(result);
            (*(csharp2cuda_temp_2) = mathblocks_row_value_multiply(a, b));
#line 470 "ScalarModule.cs"
            break;
#line 471 "ScalarModule.cs"
        case 3:
#line 471 "ScalarModule.cs"
#line 471 "ScalarModule.cs"
            float* csharp2cuda_temp_3 = &(result);
            (*(csharp2cuda_temp_3) = mathblocks_row_value_divide(a, b));
#line 471 "ScalarModule.cs"
            break;
#line 472 "ScalarModule.cs"
        case 4:
#line 472 "ScalarModule.cs"
#line 472 "ScalarModule.cs"
            float* csharp2cuda_temp_4 = &(result);
            (*(csharp2cuda_temp_4) = (-(a)));
#line 472 "ScalarModule.cs"
            break;
#line 473 "ScalarModule.cs"
        case 5:
#line 473 "ScalarModule.cs"
#line 473 "ScalarModule.cs"
            float* csharp2cuda_temp_5 = &(result);
            (*(csharp2cuda_temp_5) = mathblocks_row_value_absolute(a));
#line 473 "ScalarModule.cs"
            break;
#line 474 "ScalarModule.cs"
        case 6:
#line 474 "ScalarModule.cs"
#line 474 "ScalarModule.cs"
            float* csharp2cuda_temp_6 = &(result);
            (*(csharp2cuda_temp_6) = ((float)(csharp2cuda_i32_sub(((((a) > (0.0f))) ? 1 : 0), ((((a) < (0.0f))) ? 1 : 0)))));
#line 474 "ScalarModule.cs"
            break;
#line 475 "ScalarModule.cs"
        case 7:
#line 475 "ScalarModule.cs"
#line 475 "ScalarModule.cs"
            float* csharp2cuda_temp_7 = &(result);
#line 475 "ScalarModule.cs"
            float csharp2cuda_temp_8;
#line 475 "ScalarModule.cs"
            if (((a) > (0.0f)))
            {
#line 475 "ScalarModule.cs"
                csharp2cuda_temp_8 = a;
            }
            else
            {
#line 475 "ScalarModule.cs"
                csharp2cuda_temp_8 = 0.0f;
            }
            (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 475 "ScalarModule.cs"
            break;
#line 476 "ScalarModule.cs"
        case 8:
#line 476 "ScalarModule.cs"
#line 476 "ScalarModule.cs"
            float* csharp2cuda_temp_9 = &(result);
            (*(csharp2cuda_temp_9) = csharp2cuda_f32_minimum(a, b));
#line 476 "ScalarModule.cs"
            break;
#line 477 "ScalarModule.cs"
        case 9:
#line 477 "ScalarModule.cs"
#line 477 "ScalarModule.cs"
            float* csharp2cuda_temp_10 = &(result);
            (*(csharp2cuda_temp_10) = csharp2cuda_f32_maximum(a, b));
#line 477 "ScalarModule.cs"
            break;
#line 478 "ScalarModule.cs"
        case 10:
#line 481 "ScalarModule.cs"
            if (((b) > (c)))
#line 482 "ScalarModule.cs"
            {
#line 483 "ScalarModule.cs"
#line 483 "ScalarModule.cs"
                float* csharp2cuda_temp_11 = value;
                (*(csharp2cuda_temp_11) = 0.0f);
#line 484 "ScalarModule.cs"
                return false;
            }
#line 486 "ScalarModule.cs"
#line 486 "ScalarModule.cs"
            float* csharp2cuda_temp_12 = &(result);
#line 486 "ScalarModule.cs"
            float csharp2cuda_temp_13;
#line 486 "ScalarModule.cs"
            if (((a) < (b)))
            {
#line 486 "ScalarModule.cs"
                csharp2cuda_temp_13 = b;
            }
            else
            {
#line 486 "ScalarModule.cs"
                float csharp2cuda_temp_14;
#line 486 "ScalarModule.cs"
                if (((a) > (c)))
                {
#line 486 "ScalarModule.cs"
                    csharp2cuda_temp_14 = c;
                }
                else
                {
#line 486 "ScalarModule.cs"
                    csharp2cuda_temp_14 = a;
                }
#line 486 "ScalarModule.cs"
                csharp2cuda_temp_13 = csharp2cuda_temp_14;
            }
            (*(csharp2cuda_temp_12) = csharp2cuda_temp_13);
#line 487 "ScalarModule.cs"
            break;
#line 488 "ScalarModule.cs"
        case 11:
#line 488 "ScalarModule.cs"
#line 488 "ScalarModule.cs"
            float* csharp2cuda_temp_15 = &(result);
#line 488 "ScalarModule.cs"
            float csharp2cuda_temp_16 = __fdiv_rn(1.0f, a);
            (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 488 "ScalarModule.cs"
            break;
#line 489 "ScalarModule.cs"
        case 12:
#line 489 "ScalarModule.cs"
#line 489 "ScalarModule.cs"
            float* csharp2cuda_temp_17 = &(result);
            (*(csharp2cuda_temp_17) = __fmul_rn(a, a));
#line 489 "ScalarModule.cs"
            break;
#line 490 "ScalarModule.cs"
        case 13:
#line 490 "ScalarModule.cs"
#line 490 "ScalarModule.cs"
            float* csharp2cuda_temp_18 = &(result);
            (*(csharp2cuda_temp_18) = __fmul_rn(__fmul_rn(a, a), a));
#line 490 "ScalarModule.cs"
            break;
#line 491 "ScalarModule.cs"
        case 14:
#line 491 "ScalarModule.cs"
#line 491 "ScalarModule.cs"
            float* csharp2cuda_temp_19 = &(result);
            (*(csharp2cuda_temp_19) = mathblocks_square_root(a));
#line 491 "ScalarModule.cs"
            break;
#line 492 "ScalarModule.cs"
        case 15:
#line 492 "ScalarModule.cs"
#line 492 "ScalarModule.cs"
            float* csharp2cuda_temp_20 = &(result);
            (*(csharp2cuda_temp_20) = mathblocks_cube_root_steps(a, mathblocks_limit_cube_root_newton_steps()));
#line 492 "ScalarModule.cs"
            break;
#line 493 "ScalarModule.cs"
        case 16:
#line 493 "ScalarModule.cs"
#line 493 "ScalarModule.cs"
            float* csharp2cuda_temp_21 = &(result);
            (*(csharp2cuda_temp_21) = mathblocks_power(a, b));
#line 493 "ScalarModule.cs"
            break;
#line 494 "ScalarModule.cs"
        case 17:
#line 494 "ScalarModule.cs"
#line 494 "ScalarModule.cs"
            float* csharp2cuda_temp_22 = &(result);
            (*(csharp2cuda_temp_22) = mathblocks_exponential(a));
#line 494 "ScalarModule.cs"
            break;
#line 495 "ScalarModule.cs"
        case 18:
#line 495 "ScalarModule.cs"
#line 495 "ScalarModule.cs"
            float* csharp2cuda_temp_23 = &(result);
            (*(csharp2cuda_temp_23) = mathblocks_natural_logarithm(a));
#line 495 "ScalarModule.cs"
            break;
#line 496 "ScalarModule.cs"
        case 19:
#line 496 "ScalarModule.cs"
#line 496 "ScalarModule.cs"
            float* csharp2cuda_temp_24 = &(result);
            (*(csharp2cuda_temp_24) = mathblocks_binary_logarithm(a));
#line 496 "ScalarModule.cs"
            break;
#line 497 "ScalarModule.cs"
        case 20:
#line 498 "ScalarModule.cs"
#line 498 "ScalarModule.cs"
            float* csharp2cuda_temp_25 = &(result);
#line 498 "ScalarModule.cs"
            float csharp2cuda_temp_26 = __fdiv_rn(mathblocks_natural_logarithm(a), 2.3025851f);
            (*(csharp2cuda_temp_25) = csharp2cuda_temp_26);
#line 499 "ScalarModule.cs"
            break;
#line 500 "ScalarModule.cs"
        case 21:
#line 500 "ScalarModule.cs"
#line 500 "ScalarModule.cs"
            float* csharp2cuda_temp_27 = &(result);
            (*(csharp2cuda_temp_27) = mathblocks_sine(a));
#line 500 "ScalarModule.cs"
            break;
#line 501 "ScalarModule.cs"
        case 22:
#line 501 "ScalarModule.cs"
#line 501 "ScalarModule.cs"
            float* csharp2cuda_temp_28 = &(result);
            (*(csharp2cuda_temp_28) = mathblocks_cosine(a));
#line 501 "ScalarModule.cs"
            break;
#line 502 "ScalarModule.cs"
        case 23:
#line 502 "ScalarModule.cs"
#line 502 "ScalarModule.cs"
            float* csharp2cuda_temp_29 = &(result);
#line 502 "ScalarModule.cs"
            float csharp2cuda_temp_30 = __fdiv_rn(mathblocks_sine(a), mathblocks_cosine(a));
            (*(csharp2cuda_temp_29) = csharp2cuda_temp_30);
#line 502 "ScalarModule.cs"
            break;
#line 503 "ScalarModule.cs"
        case 24:
#line 503 "ScalarModule.cs"
#line 503 "ScalarModule.cs"
            float* csharp2cuda_temp_31 = &(result);
            (*(csharp2cuda_temp_31) = mathblocks_arc_sine(a));
#line 503 "ScalarModule.cs"
            break;
#line 504 "ScalarModule.cs"
        case 25:
#line 504 "ScalarModule.cs"
#line 504 "ScalarModule.cs"
            float* csharp2cuda_temp_32 = &(result);
            (*(csharp2cuda_temp_32) = mathblocks_arc_cosine(a));
#line 504 "ScalarModule.cs"
            break;
#line 505 "ScalarModule.cs"
        case 26:
#line 505 "ScalarModule.cs"
#line 505 "ScalarModule.cs"
            float* csharp2cuda_temp_33 = &(result);
            (*(csharp2cuda_temp_33) = mathblocks_arc_tangent(a));
#line 505 "ScalarModule.cs"
            break;
#line 506 "ScalarModule.cs"
        case 27:
#line 506 "ScalarModule.cs"
#line 506 "ScalarModule.cs"
            float* csharp2cuda_temp_34 = &(result);
            (*(csharp2cuda_temp_34) = mathblocks_arc_tangent_2(a, b));
#line 506 "ScalarModule.cs"
            break;
#line 507 "ScalarModule.cs"
        case 28:
#line 508 "ScalarModule.cs"
            {
#line 509 "ScalarModule.cs"
                if (((a) == (0.0f)))
#line 510 "ScalarModule.cs"
                {
#line 511 "ScalarModule.cs"
#line 511 "ScalarModule.cs"
                    float* csharp2cuda_temp_35 = &(result);
                    (*(csharp2cuda_temp_35) = a);
#line 512 "ScalarModule.cs"
                    break;
                }
#line 514 "ScalarModule.cs"
                float positive = mathblocks_exponential(a);
#line 515 "ScalarModule.cs"
                float negative = mathblocks_exponential((-(a)));
#line 516 "ScalarModule.cs"
#line 516 "ScalarModule.cs"
                float* csharp2cuda_temp_36 = &(result);
#line 516 "ScalarModule.cs"
                float csharp2cuda_temp_37 = __fdiv_rn(__fsub_rn(positive, negative), 2.0f);
                (*(csharp2cuda_temp_36) = csharp2cuda_temp_37);
#line 517 "ScalarModule.cs"
                break;
            }
#line 519 "ScalarModule.cs"
        case 29:
#line 520 "ScalarModule.cs"
            {
#line 521 "ScalarModule.cs"
                float positive = mathblocks_exponential(a);
#line 522 "ScalarModule.cs"
                float negative = mathblocks_exponential((-(a)));
#line 523 "ScalarModule.cs"
#line 523 "ScalarModule.cs"
                float* csharp2cuda_temp_38 = &(result);
#line 523 "ScalarModule.cs"
                float csharp2cuda_temp_39 = __fdiv_rn(__fadd_rn(positive, negative), 2.0f);
                (*(csharp2cuda_temp_38) = csharp2cuda_temp_39);
#line 524 "ScalarModule.cs"
                break;
            }
#line 526 "ScalarModule.cs"
        case 30:
#line 527 "ScalarModule.cs"
            {
#line 528 "ScalarModule.cs"
                if (((a) == (0.0f)))
#line 529 "ScalarModule.cs"
                {
#line 530 "ScalarModule.cs"
#line 530 "ScalarModule.cs"
                    float* csharp2cuda_temp_40 = &(result);
                    (*(csharp2cuda_temp_40) = a);
#line 531 "ScalarModule.cs"
                    break;
                }
#line 533 "ScalarModule.cs"
                float positive = mathblocks_exponential(a);
#line 534 "ScalarModule.cs"
                float negative = mathblocks_exponential((-(a)));
#line 535 "ScalarModule.cs"
#line 535 "ScalarModule.cs"
                float* csharp2cuda_temp_41 = &(result);
#line 535 "ScalarModule.cs"
                float csharp2cuda_temp_42 = __fdiv_rn(__fsub_rn(positive, negative), __fadd_rn(positive, negative));
                (*(csharp2cuda_temp_41) = csharp2cuda_temp_42);
#line 536 "ScalarModule.cs"
                break;
            }
#line 538 "ScalarModule.cs"
        case 31:
#line 538 "ScalarModule.cs"
#line 538 "ScalarModule.cs"
            float* csharp2cuda_temp_43 = &(result);
            (*(csharp2cuda_temp_43) = mathblocks_inverse_hyperbolic_sine(a));
#line 538 "ScalarModule.cs"
            break;
#line 539 "ScalarModule.cs"
        case 32:
#line 540 "ScalarModule.cs"
#line 540 "ScalarModule.cs"
            float* csharp2cuda_temp_44 = &(result);
            (*(csharp2cuda_temp_44) = mathblocks_natural_logarithm(__fadd_rn(a, mathblocks_square_root(__fsub_rn(__fmul_rn(a, a), 1.0f)))));
#line 542 "ScalarModule.cs"
            break;
#line 543 "ScalarModule.cs"
        case 33:
#line 543 "ScalarModule.cs"
#line 543 "ScalarModule.cs"
            float* csharp2cuda_temp_45 = &(result);
#line 543 "ScalarModule.cs"
            float csharp2cuda_temp_46 = __fdiv_rn(__fmul_rn(2.0f, a), __fsub_rn(1.0f, a));
            (*(csharp2cuda_temp_45) = __fmul_rn(0.5f, mathblocks_log_one_plus(csharp2cuda_temp_46)));
#line 543 "ScalarModule.cs"
            break;
#line 544 "ScalarModule.cs"
        case 34:
#line 544 "ScalarModule.cs"
#line 544 "ScalarModule.cs"
            float* csharp2cuda_temp_47 = &(result);
            (*(csharp2cuda_temp_47) = floorf(a));
#line 544 "ScalarModule.cs"
            break;
#line 545 "ScalarModule.cs"
        case 35:
#line 545 "ScalarModule.cs"
#line 545 "ScalarModule.cs"
            float* csharp2cuda_temp_48 = &(result);
            (*(csharp2cuda_temp_48) = ceilf(a));
#line 545 "ScalarModule.cs"
            break;
#line 546 "ScalarModule.cs"
        case 36:
#line 546 "ScalarModule.cs"
#line 546 "ScalarModule.cs"
            float* csharp2cuda_temp_49 = &(result);
            (*(csharp2cuda_temp_49) = nearbyintf(a));
#line 546 "ScalarModule.cs"
            break;
#line 547 "ScalarModule.cs"
        case 37:
#line 547 "ScalarModule.cs"
#line 547 "ScalarModule.cs"
            float* csharp2cuda_temp_50 = &(result);
            (*(csharp2cuda_temp_50) = truncf(a));
#line 547 "ScalarModule.cs"
            break;
#line 548 "ScalarModule.cs"
        case 38:
#line 548 "ScalarModule.cs"
#line 548 "ScalarModule.cs"
            float* csharp2cuda_temp_51 = &(result);
            (*(csharp2cuda_temp_51) = mathblocks_modulo(a, b));
#line 548 "ScalarModule.cs"
            break;
#line 549 "ScalarModule.cs"
        case 39:
#line 550 "ScalarModule.cs"
#line 550 "ScalarModule.cs"
            float* csharp2cuda_temp_52 = &(result);
#line 550 "ScalarModule.cs"
            float csharp2cuda_temp_53;
#line 550 "ScalarModule.cs"
            if (((a) >= (0.0f)))
            {
#line 550 "ScalarModule.cs"
                csharp2cuda_temp_53 = __fdiv_rn(1.0f, __fadd_rn(1.0f, mathblocks_exponential((-(a)))));
            }
            else
            {
#line 550 "ScalarModule.cs"
                csharp2cuda_temp_53 = __fdiv_rn(mathblocks_exponential(a), __fadd_rn(1.0f, mathblocks_exponential(a)));
            }
            (*(csharp2cuda_temp_52) = csharp2cuda_temp_53);
#line 553 "ScalarModule.cs"
            break;
#line 554 "ScalarModule.cs"
        case 40:
#line 555 "ScalarModule.cs"
#line 555 "ScalarModule.cs"
            float* csharp2cuda_temp_54 = &(result);
#line 555 "ScalarModule.cs"
            float csharp2cuda_temp_55 = __fdiv_rn(a, __fsub_rn(1.0f, a));
            (*(csharp2cuda_temp_54) = mathblocks_natural_logarithm(csharp2cuda_temp_55));
#line 556 "ScalarModule.cs"
            break;
#line 557 "ScalarModule.cs"
        case 41:
#line 558 "ScalarModule.cs"
#line 558 "ScalarModule.cs"
            float* csharp2cuda_temp_56 = &(result);
            (*(csharp2cuda_temp_56) = __fadd_rn(csharp2cuda_f32_maximum(a, 0.0f), mathblocks_log_one_plus(mathblocks_exponential((-(fabsf(a)))))));
#line 560 "ScalarModule.cs"
            break;
#line 561 "ScalarModule.cs"
        case 42:
#line 561 "ScalarModule.cs"
#line 561 "ScalarModule.cs"
            float* csharp2cuda_temp_57 = &(result);
            (*(csharp2cuda_temp_57) = mathblocks_log_one_plus(a));
#line 561 "ScalarModule.cs"
            break;
#line 562 "ScalarModule.cs"
        case 43:
#line 562 "ScalarModule.cs"
#line 562 "ScalarModule.cs"
            float* csharp2cuda_temp_58 = &(result);
            (*(csharp2cuda_temp_58) = mathblocks_error_function(a));
#line 562 "ScalarModule.cs"
            break;
#line 563 "ScalarModule.cs"
        default:
#line 563 "ScalarModule.cs"
#line 563 "ScalarModule.cs"
            float* csharp2cuda_temp_59 = value;
            (*(csharp2cuda_temp_59) = 0.0f);
#line 563 "ScalarModule.cs"
            return false;
    }
#line 566 "ScalarModule.cs"
#line 566 "ScalarModule.cs"
    float* csharp2cuda_temp_60 = value;
    (*(csharp2cuda_temp_60) = result);
#line 567 "ScalarModule.cs"
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

#line 272 "ScalarModule.cs"
__device__ float mathblocks_sine(float value)
#line 274 "ScalarModule.cs"
{
#line 276 "ScalarModule.cs"
    if (((value) == (0.0f)))
    {
#line 277 "ScalarModule.cs"
        return value;
    }
#line 278 "ScalarModule.cs"
    float sign = 1.0f;
#line 279 "ScalarModule.cs"
    float x = value;
#line 280 "ScalarModule.cs"
    if (((x) < (0.0f)))
#line 281 "ScalarModule.cs"
    {
#line 282 "ScalarModule.cs"
#line 282 "ScalarModule.cs"
        float* csharp2cuda_temp_0 = &(sign);
        (*(csharp2cuda_temp_0) = (-(1.0f)));
#line 283 "ScalarModule.cs"
#line 283 "ScalarModule.cs"
        float* csharp2cuda_temp_1 = &(x);
        (*(csharp2cuda_temp_1) = (-(x)));
    }
#line 285 "ScalarModule.cs"
    float csharp2cuda_temp_2 = __fdiv_rn(x, 0.7853982f);
#line 285 "ScalarModule.cs"
    float octant_value = floorf(csharp2cuda_temp_2);
#line 286 "ScalarModule.cs"
    int octant = csharp2cuda_f64_to_i32(__fsub_rn(octant_value, __fmul_rn(floorf(__fmul_rn(octant_value, 0.125f)), 8.0f)));
#line 287 "ScalarModule.cs"
    if (((csharp2cuda_i32_and(octant, 1)) != (0)))
#line 288 "ScalarModule.cs"
    {
#line 289 "ScalarModule.cs"
#line 289 "ScalarModule.cs"
        int* csharp2cuda_temp_3 = &(octant);
        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
#line 290 "ScalarModule.cs"
#line 290 "ScalarModule.cs"
        float* csharp2cuda_temp_4 = &(octant_value);
        (*(csharp2cuda_temp_4))++;
    }
#line 292 "ScalarModule.cs"
#line 292 "ScalarModule.cs"
    int* csharp2cuda_temp_5 = &(octant);
#line 292 "ScalarModule.cs"
    int csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
    (*(csharp2cuda_temp_5) = csharp2cuda_i32_and(csharp2cuda_temp_6, 7));
#line 293 "ScalarModule.cs"
    if (((octant) > (3)))
#line 294 "ScalarModule.cs"
    {
#line 295 "ScalarModule.cs"
#line 295 "ScalarModule.cs"
        float* csharp2cuda_temp_7 = &(sign);
        (*(csharp2cuda_temp_7) = (-(sign)));
#line 296 "ScalarModule.cs"
#line 296 "ScalarModule.cs"
        int* csharp2cuda_temp_8 = &(octant);
#line 296 "ScalarModule.cs"
        int csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
        (*(csharp2cuda_temp_8) = csharp2cuda_i32_sub(csharp2cuda_temp_9, 4));
    }
#line 298 "ScalarModule.cs"
    float reduced = __fsub_rn(__fsub_rn(__fsub_rn(x, __fmul_rn(octant_value, 0.78515625f)), __fmul_rn(octant_value, 0.00024187565f)), __fmul_rn(octant_value, 3.774895E-08f));
#line 301 "ScalarModule.cs"
    float square = __fmul_rn(reduced, reduced);
#line 302 "ScalarModule.cs"
#line 302 "ScalarModule.cs"
    bool csharp2cuda_temp_10;
#line 302 "ScalarModule.cs"
    if (!(((octant) == (1))))
    {
#line 302 "ScalarModule.cs"
        csharp2cuda_temp_10 = ((octant) == (2));
    }
    else
    {
#line 302 "ScalarModule.cs"
        csharp2cuda_temp_10 = true;
    }
    if (csharp2cuda_temp_10)
#line 303 "ScalarModule.cs"
    {
#line 304 "ScalarModule.cs"
        float polynomial = __fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn((-(1.13585365E-11f)), square), 2.0875701E-09f), square), 2.7557314E-07f), square), 2.4801588E-05f), square), 0.0013888889f), square), 0.041666668f);
#line 311 "ScalarModule.cs"
        return __fmul_rn(sign, __fadd_rn(__fsub_rn(1.0f, __fmul_rn(0.5f, square)), __fmul_rn(__fmul_rn(square, square), polynomial)));
    }
#line 313 "ScalarModule.cs"
    float sine_polynomial = __fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(__fadd_rn(__fmul_rn(__fsub_rn(__fmul_rn(1.589623E-10f, square), 2.5050747E-08f), square), 2.7557314E-06f), square), 0.0001984127f), square), 0.008333334f), square), 0.16666667f);
#line 320 "ScalarModule.cs"
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