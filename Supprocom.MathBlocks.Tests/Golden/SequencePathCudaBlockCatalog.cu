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

struct MathBlockSequencePathRun;

#line 41 "SequencePathModule.cs"
struct MathBlockSequencePathRun
{
    int start;
    int length;
    float value;
};

#line 481 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const float* values,
    int count,
    bool relative,
    float* value);

#line 447 "SequencePathModule.cs"
__device__ float mathblocks_sequence_first_passage_value(
    const float* values,
    int count,
    float threshold,
    bool at_or_above);

#line 281 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 210 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum);

#line 304 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 246 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 222 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 196 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions);

#line 95 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value);

#line 466 "SequencePathModule.cs"
__device__ float mathblocks_sequence_longest_run_value(
    const int* values,
    int count);

#line 571 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_offset(float value, int* result);

#line 581 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_offset_reachable(
    const float* counts,
    int count,
    int row,
    long long offset);

#line 599 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_offset_row(
    int kind,
    const float* values,
    const int* values_valid,
    const float* counts,
    int count,
    int row,
    int start,
    int end,
    float no_match,
    float* result);

#line 672 "SequencePathModule.cs"
__device__ void mathblocks_sequence_offsets(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 84 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(float value);

#line 745 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 48 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(float value, int* result);

#line 101 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const float* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output);

#line 347 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks);

#line 528 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const float* values,
    int count,
    float threshold,
    float* value);

#line 402 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const float* values,
    int count,
    int width,
    float* result,
    int* deque,
    bool minimum);

#line 429 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const float* values,
    int count,
    int width,
    float* result);

#line 67 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns);

#line 54 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count);

#line 548 "SequencePathModule.cs"
__device__ float mathblocks_sequence_sign_change_value(
    const float* values,
    int count,
    bool differenced);

#line 506 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const float* values,
    int count,
    float order,
    bool absolute,
    float* value);

#line 481 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const float* values,
    int count,
    bool relative,
    float* value)
#line 487 "SequencePathModule.cs"
{
#line 488 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 489 "SequencePathModule.cs"
        return false;
    }
#line 490 "SequencePathModule.cs"
    float maximum = (values)[0];
#line 491 "SequencePathModule.cs"
    float decline = 0.0f;
#line 492 "SequencePathModule.cs"
    {
#line 492 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 493 "SequencePathModule.cs"
            {
#line 495 "SequencePathModule.cs"
#line 495 "SequencePathModule.cs"
                float* csharp2cuda_temp_1 = &(maximum);
#line 495 "SequencePathModule.cs"
                float csharp2cuda_temp_2 = (values)[index];
                (*(csharp2cuda_temp_1) = mathblocks_maximum(maximum, csharp2cuda_temp_2));
#line 496 "SequencePathModule.cs"
                float csharp2cuda_temp_3;
#line 496 "SequencePathModule.cs"
                if ((!(relative)))
                {
#line 497 "SequencePathModule.cs"
                    float csharp2cuda_temp_4 = (values)[index];
#line 496 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = __fsub_rn(maximum, csharp2cuda_temp_4);
                }
                else
                {
#line 498 "SequencePathModule.cs"
                    float csharp2cuda_temp_5 = (values)[index];
#line 496 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = __fdiv_rn(__fsub_rn(maximum, csharp2cuda_temp_5), maximum);
                }
#line 496 "SequencePathModule.cs"
                float candidate = csharp2cuda_temp_3;
#line 499 "SequencePathModule.cs"
#line 499 "SequencePathModule.cs"
                float* csharp2cuda_temp_6 = &(decline);
                (*(csharp2cuda_temp_6) = mathblocks_maximum(decline, candidate));
            }
#line 492 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 501 "SequencePathModule.cs"
#line 501 "SequencePathModule.cs"
    float* csharp2cuda_temp_7 = value;
    (*(csharp2cuda_temp_7) = decline);
#line 502 "SequencePathModule.cs"
    return isfinite(decline);
}

#line 447 "SequencePathModule.cs"
__device__ float mathblocks_sequence_first_passage_value(
    const float* values,
    int count,
    float threshold,
    bool at_or_above)
#line 453 "SequencePathModule.cs"
{
#line 454 "SequencePathModule.cs"
    int result_index = -1;
#line 455 "SequencePathModule.cs"
    {
#line 455 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 456 "SequencePathModule.cs"
            {
#line 457 "SequencePathModule.cs"
#line 457 "SequencePathModule.cs"
                bool csharp2cuda_temp_1;
#line 457 "SequencePathModule.cs"
                if (at_or_above)
                {
#line 457 "SequencePathModule.cs"
                    float csharp2cuda_temp_2 = (values)[index];
#line 457 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_2) >= (threshold));
                }
                else
                {
#line 457 "SequencePathModule.cs"
                    float csharp2cuda_temp_3 = (values)[index];
#line 457 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_3) <= (threshold));
                }
                if (csharp2cuda_temp_1)
#line 458 "SequencePathModule.cs"
                {
#line 459 "SequencePathModule.cs"
#line 459 "SequencePathModule.cs"
                    int* csharp2cuda_temp_4 = &(result_index);
                    (*(csharp2cuda_temp_4) = index);
#line 460 "SequencePathModule.cs"
                    break;
                }
            }
#line 455 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 463 "SequencePathModule.cs"
    return ((float)(result_index));
}

#line 281 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 291 "SequencePathModule.cs"
{
#line 292 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 292 "SequencePathModule.cs"
    int position = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
#line 293 "SequencePathModule.cs"
#line 293 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((heap)[position]);
    (*(csharp2cuda_temp_1) = item);
#line 294 "SequencePathModule.cs"
#line 294 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((positions)[item]);
    (*(csharp2cuda_temp_2) = position);
#line 295 "SequencePathModule.cs"
#line 295 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((kinds)[item]);
    (*(csharp2cuda_temp_3) = kind);
#line 296 "SequencePathModule.cs"
    mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
}

#line 210 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum)
#line 216 "SequencePathModule.cs"
{
#line 217 "SequencePathModule.cs"
#line 217 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 217 "SequencePathModule.cs"
    if (maximum)
    {
#line 218 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = (ranks)[left];
#line 218 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = (ranks)[right];
#line 217 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_1) > (csharp2cuda_temp_2));
    }
    else
    {
#line 219 "SequencePathModule.cs"
        int csharp2cuda_temp_3 = (ranks)[left];
#line 219 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (ranks)[right];
#line 217 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_3) < (csharp2cuda_temp_4));
    }
    return csharp2cuda_temp_0;
}

#line 304 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 313 "SequencePathModule.cs"
{
#line 314 "SequencePathModule.cs"
    int position = (positions)[item];
#line 315 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 315 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = csharp2cuda_i32_pre_decrement(*(csharp2cuda_temp_0));
#line 315 "SequencePathModule.cs"
    int replacement = (heap)[csharp2cuda_temp_1];
#line 316 "SequencePathModule.cs"
#line 316 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((kinds)[item]);
    (*(csharp2cuda_temp_2) = csharp2cuda_i32_neg(1));
#line 317 "SequencePathModule.cs"
#line 317 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((positions)[item]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_neg(1));
#line 318 "SequencePathModule.cs"
#line 318 "SequencePathModule.cs"
    int csharp2cuda_temp_4 = *(count);
    if (((position) >= (csharp2cuda_temp_4)))
    {
#line 319 "SequencePathModule.cs"
        return;
    }
#line 320 "SequencePathModule.cs"
#line 320 "SequencePathModule.cs"
    int* csharp2cuda_temp_5 = &((heap)[position]);
    (*(csharp2cuda_temp_5) = replacement);
#line 321 "SequencePathModule.cs"
#line 321 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[replacement]);
    (*(csharp2cuda_temp_6) = position);
#line 322 "SequencePathModule.cs"
#line 322 "SequencePathModule.cs"
    bool csharp2cuda_temp_7;
#line 322 "SequencePathModule.cs"
    if (((position) > (0)))
    {
#line 323 "SequencePathModule.cs"
        int csharp2cuda_temp_8 = (heap)[position];
#line 324 "SequencePathModule.cs"
        int csharp2cuda_temp_9 = (heap)[csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1)];
#line 322 "SequencePathModule.cs"
        csharp2cuda_temp_7 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_8, csharp2cuda_temp_9, ranks, maximum);
    }
    else
    {
#line 322 "SequencePathModule.cs"
        csharp2cuda_temp_7 = false;
    }
    if (csharp2cuda_temp_7)
#line 327 "SequencePathModule.cs"
    {
#line 328 "SequencePathModule.cs"
        mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
    }
    else
#line 336 "SequencePathModule.cs"
    {
#line 337 "SequencePathModule.cs"
#line 339 "SequencePathModule.cs"
        int csharp2cuda_temp_10 = *(count);
        mathblocks_sequence_heap_sift_down(heap, csharp2cuda_temp_10, position, positions, ranks, maximum);
    }
}

#line 246 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 254 "SequencePathModule.cs"
{
#line 255 "SequencePathModule.cs"
    while (true)
    {
        if (!(true))
            break;
#line 256 "SequencePathModule.cs"
        {
#line 257 "SequencePathModule.cs"
            int left = csharp2cuda_i32_add(csharp2cuda_i32_mul(position, 2), 1);
#line 258 "SequencePathModule.cs"
            if (((left) >= (count)))
            {
#line 259 "SequencePathModule.cs"
                return;
            }
#line 260 "SequencePathModule.cs"
            int right = csharp2cuda_i32_add(left, 1);
#line 261 "SequencePathModule.cs"
            bool csharp2cuda_temp_0;
#line 261 "SequencePathModule.cs"
            if (((right) < (count)))
            {
#line 262 "SequencePathModule.cs"
                int csharp2cuda_temp_1 = (heap)[right];
#line 263 "SequencePathModule.cs"
                int csharp2cuda_temp_2 = (heap)[left];
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_0 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_1, csharp2cuda_temp_2, ranks, maximum);
            }
            else
            {
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_0 = false;
            }
#line 261 "SequencePathModule.cs"
            int csharp2cuda_temp_3;
#line 261 "SequencePathModule.cs"
            if (csharp2cuda_temp_0)
            {
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_3 = right;
            }
            else
            {
#line 261 "SequencePathModule.cs"
                csharp2cuda_temp_3 = left;
            }
#line 261 "SequencePathModule.cs"
            int selected = csharp2cuda_temp_3;
#line 268 "SequencePathModule.cs"
#line 269 "SequencePathModule.cs"
            int csharp2cuda_temp_4 = (heap)[selected];
#line 270 "SequencePathModule.cs"
            int csharp2cuda_temp_5 = (heap)[position];
#line 268 "SequencePathModule.cs"
            bool csharp2cuda_temp_6 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_4, csharp2cuda_temp_5, ranks, maximum);
            if ((!(csharp2cuda_temp_6)))
#line 273 "SequencePathModule.cs"
            {
#line 274 "SequencePathModule.cs"
                return;
            }
#line 276 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, selected, positions);
#line 277 "SequencePathModule.cs"
#line 277 "SequencePathModule.cs"
            int* csharp2cuda_temp_7 = &(position);
            (*(csharp2cuda_temp_7) = selected);
        }
    }
}

#line 222 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 229 "SequencePathModule.cs"
{
#line 230 "SequencePathModule.cs"
    while (true)
    {
        if (!(((position) > (0))))
            break;
#line 231 "SequencePathModule.cs"
        {
#line 232 "SequencePathModule.cs"
            int parent = csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1);
#line 233 "SequencePathModule.cs"
#line 234 "SequencePathModule.cs"
            int csharp2cuda_temp_0 = (heap)[position];
#line 235 "SequencePathModule.cs"
            int csharp2cuda_temp_1 = (heap)[parent];
#line 233 "SequencePathModule.cs"
            bool csharp2cuda_temp_2 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_0, csharp2cuda_temp_1, ranks, maximum);
            if ((!(csharp2cuda_temp_2)))
#line 238 "SequencePathModule.cs"
            {
#line 239 "SequencePathModule.cs"
                break;
            }
#line 241 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, parent, positions);
#line 242 "SequencePathModule.cs"
#line 242 "SequencePathModule.cs"
            int* csharp2cuda_temp_3 = &(position);
            (*(csharp2cuda_temp_3) = parent);
        }
    }
}

#line 196 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions)
#line 202 "SequencePathModule.cs"
{
#line 203 "SequencePathModule.cs"
    int value = (heap)[left];
#line 204 "SequencePathModule.cs"
#line 204 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((heap)[left]);
#line 204 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (heap)[right];
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 205 "SequencePathModule.cs"
#line 205 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((heap)[right]);
    (*(csharp2cuda_temp_2) = value);
#line 206 "SequencePathModule.cs"
#line 206 "SequencePathModule.cs"
    int csharp2cuda_temp_3 = (heap)[left];
#line 206 "SequencePathModule.cs"
    int* csharp2cuda_temp_4 = &((positions)[csharp2cuda_temp_3]);
    (*(csharp2cuda_temp_4) = left);
#line 207 "SequencePathModule.cs"
#line 207 "SequencePathModule.cs"
    int csharp2cuda_temp_5 = (heap)[right];
#line 207 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[csharp2cuda_temp_5]);
    (*(csharp2cuda_temp_6) = right);
}

#line 95 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value)
#line 97 "SequencePathModule.cs"
{
#line 98 "SequencePathModule.cs"
#line 98 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 98 "SequencePathModule.cs"
    if (((value) > (0)))
    {
#line 98 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 98 "SequencePathModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 466 "SequencePathModule.cs"
__device__ float mathblocks_sequence_longest_run_value(
    const int* values,
    int count)
#line 470 "SequencePathModule.cs"
{
#line 471 "SequencePathModule.cs"
    int maximum = 0;
#line 472 "SequencePathModule.cs"
    int current = 0;
#line 473 "SequencePathModule.cs"
    {
#line 473 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 474 "SequencePathModule.cs"
            {
#line 475 "SequencePathModule.cs"
#line 475 "SequencePathModule.cs"
                int* csharp2cuda_temp_1 = &(current);
#line 475 "SequencePathModule.cs"
                bool csharp2cuda_temp_2 = (values)[index];
#line 475 "SequencePathModule.cs"
                int csharp2cuda_temp_3;
#line 475 "SequencePathModule.cs"
                if (csharp2cuda_temp_2)
                {
#line 475 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = csharp2cuda_i32_add(current, 1);
                }
                else
                {
#line 475 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = 0;
                }
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 476 "SequencePathModule.cs"
#line 476 "SequencePathModule.cs"
                int* csharp2cuda_temp_4 = &(maximum);
#line 476 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 476 "SequencePathModule.cs"
                if (((maximum) > (current)))
                {
#line 476 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = maximum;
                }
                else
                {
#line 476 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = current;
                }
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 473 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 478 "SequencePathModule.cs"
    return ((float)(maximum));
}

#line 571 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_offset(float value, int* result)
#line 573 "SequencePathModule.cs"
{
#line 574 "SequencePathModule.cs"
#line 574 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 574 "SequencePathModule.cs"
    if (!(((value) != (truncf(value)))))
    {
#line 574 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((value) > (2.1474836E+09f));
    }
    else
    {
#line 574 "SequencePathModule.cs"
        csharp2cuda_temp_0 = true;
    }
#line 574 "SequencePathModule.cs"
    bool csharp2cuda_temp_1;
#line 574 "SequencePathModule.cs"
    if (!(csharp2cuda_temp_0))
    {
#line 574 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((value) < ((-(2.1474836E+09f))));
    }
    else
    {
#line 574 "SequencePathModule.cs"
        csharp2cuda_temp_1 = true;
    }
    if (csharp2cuda_temp_1)
    {
#line 575 "SequencePathModule.cs"
        return false;
    }
#line 576 "SequencePathModule.cs"
#line 576 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = result;
    (*(csharp2cuda_temp_2) = csharp2cuda_f64_to_i32(value));
#line 577 "SequencePathModule.cs"
    return true;
}

#line 581 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_offset_reachable(
    const float* counts,
    int count,
    int row,
    long long offset)
#line 587 "SequencePathModule.cs"
{
#line 588 "SequencePathModule.cs"
    long long target = csharp2cuda_i64_add(((long long)(row)), offset);
#line 589 "SequencePathModule.cs"
#line 589 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 589 "SequencePathModule.cs"
    if (!(((target) < (((long long)(0))))))
    {
#line 589 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((target) >= (((long long)(count))));
    }
    else
    {
#line 589 "SequencePathModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 590 "SequencePathModule.cs"
        return false;
    }
#line 591 "SequencePathModule.cs"
    if (((offset) < (((long long)(0)))))
    {
#line 592 "SequencePathModule.cs"
#line 592 "SequencePathModule.cs"
        float csharp2cuda_temp_1 = (counts)[row];
        return ((csharp2cuda_temp_1) >= (((float)(csharp2cuda_i64_neg(offset)))));
    }
#line 593 "SequencePathModule.cs"
#line 593 "SequencePathModule.cs"
    float csharp2cuda_temp_2 = (counts)[csharp2cuda_i32_from_bits(target)];
    return ((csharp2cuda_temp_2) >= (((float)(offset))));
}

#line 599 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_offset_row(
    int kind,
    const float* values,
    const int* values_valid,
    const float* counts,
    int count,
    int row,
    int start,
    int end,
    float no_match,
    float* result)
#line 611 "SequencePathModule.cs"
{
#line 612 "SequencePathModule.cs"
#line 612 "SequencePathModule.cs"
    float* csharp2cuda_temp_0 = result;
    (*(csharp2cuda_temp_0) = 0.0f);
#line 613 "SequencePathModule.cs"
    if (((kind) == (0)))
#line 614 "SequencePathModule.cs"
    {
#line 615 "SequencePathModule.cs"
        {
#line 615 "SequencePathModule.cs"
            long long offset = ((long long)(start));
            while (true)
            {
                if (!(((offset) <= (((long long)(end))))))
                    break;
#line 616 "SequencePathModule.cs"
                {
#line 617 "SequencePathModule.cs"
#line 617 "SequencePathModule.cs"
                    bool csharp2cuda_temp_2 = mathblocks_sequence_offset_reachable(counts, count, row, offset);
                    if ((!(csharp2cuda_temp_2)))
                    {
#line 618 "SequencePathModule.cs"
                        return false;
                    }
#line 619 "SequencePathModule.cs"
                    int target = csharp2cuda_i32_from_bits(csharp2cuda_i64_add(((long long)(row)), offset));
#line 620 "SequencePathModule.cs"
#line 620 "SequencePathModule.cs"
                    bool csharp2cuda_temp_3 = (values_valid)[target];
                    if ((!(csharp2cuda_temp_3)))
                    {
#line 621 "SequencePathModule.cs"
                        return false;
                    }
#line 622 "SequencePathModule.cs"
#line 622 "SequencePathModule.cs"
                    float csharp2cuda_temp_4 = (values)[target];
                    if (((csharp2cuda_temp_4) != (0.0f)))
#line 623 "SequencePathModule.cs"
                    {
#line 624 "SequencePathModule.cs"
#line 624 "SequencePathModule.cs"
                        float* csharp2cuda_temp_5 = result;
                        (*(csharp2cuda_temp_5) = ((float)(offset)));
#line 625 "SequencePathModule.cs"
                        return true;
                    }
                }
#line 615 "SequencePathModule.cs"
                long long* csharp2cuda_temp_1 = &(offset);
                csharp2cuda_i64_post_increment(*(csharp2cuda_temp_1));
            }
        }
#line 628 "SequencePathModule.cs"
#line 628 "SequencePathModule.cs"
        float* csharp2cuda_temp_6 = result;
        (*(csharp2cuda_temp_6) = no_match);
#line 629 "SequencePathModule.cs"
        return true;
    }
#line 631 "SequencePathModule.cs"
    long long before = 0LL;
#line 632 "SequencePathModule.cs"
    if (((start) < (0)))
    {
#line 633 "SequencePathModule.cs"
#line 633 "SequencePathModule.cs"
        long long* csharp2cuda_temp_7 = &(before);
        (*(csharp2cuda_temp_7) = csharp2cuda_i64_neg(((long long)(start))));
    }
#line 634 "SequencePathModule.cs"
    long long after = 0LL;
#line 635 "SequencePathModule.cs"
    if (((end) > (0)))
    {
#line 636 "SequencePathModule.cs"
#line 636 "SequencePathModule.cs"
        long long* csharp2cuda_temp_8 = &(after);
        (*(csharp2cuda_temp_8) = ((long long)(end)));
    }
#line 637 "SequencePathModule.cs"
#line 637 "SequencePathModule.cs"
    bool csharp2cuda_temp_9;
#line 637 "SequencePathModule.cs"
    if (!(((csharp2cuda_i64_add(((long long)(row)), ((long long)(start)))) < (((long long)(0))))))
    {
#line 637 "SequencePathModule.cs"
        float csharp2cuda_temp_10 = (counts)[row];
#line 637 "SequencePathModule.cs"
        csharp2cuda_temp_9 = ((csharp2cuda_temp_10) < (((float)(before))));
    }
    else
    {
#line 637 "SequencePathModule.cs"
        csharp2cuda_temp_9 = true;
    }
    if (csharp2cuda_temp_9)
    {
#line 638 "SequencePathModule.cs"
        return false;
    }
#line 639 "SequencePathModule.cs"
    long long last = csharp2cuda_i64_add(((long long)(row)), after);
#line 640 "SequencePathModule.cs"
#line 640 "SequencePathModule.cs"
    bool csharp2cuda_temp_11;
#line 640 "SequencePathModule.cs"
    if (!(((last) >= (((long long)(count))))))
    {
#line 640 "SequencePathModule.cs"
        float csharp2cuda_temp_12 = (counts)[csharp2cuda_i32_from_bits(last)];
#line 640 "SequencePathModule.cs"
        csharp2cuda_temp_11 = ((csharp2cuda_temp_12) < (((float)(after))));
    }
    else
    {
#line 640 "SequencePathModule.cs"
        csharp2cuda_temp_11 = true;
    }
    if (csharp2cuda_temp_11)
    {
#line 641 "SequencePathModule.cs"
        return false;
    }
#line 642 "SequencePathModule.cs"
    long long first = csharp2cuda_i64_add(((long long)(row)), ((long long)(start)));
#line 643 "SequencePathModule.cs"
    float accumulator = 0.0f;
#line 644 "SequencePathModule.cs"
    {
#line 644 "SequencePathModule.cs"
        long long index = first;
        while (true)
        {
            if (!(((index) <= (csharp2cuda_i64_add(((long long)(row)), ((long long)(end)))))))
                break;
#line 645 "SequencePathModule.cs"
            {
#line 646 "SequencePathModule.cs"
#line 646 "SequencePathModule.cs"
                bool csharp2cuda_temp_14 = (values_valid)[csharp2cuda_i32_from_bits(index)];
                if ((!(csharp2cuda_temp_14)))
                {
#line 647 "SequencePathModule.cs"
                    return false;
                }
#line 648 "SequencePathModule.cs"
                if (((kind) == (1)))
#line 649 "SequencePathModule.cs"
                {
#line 650 "SequencePathModule.cs"
#line 650 "SequencePathModule.cs"
                    float* csharp2cuda_temp_15 = &(accumulator);
#line 650 "SequencePathModule.cs"
                    float csharp2cuda_temp_16 = *(csharp2cuda_temp_15);
#line 650 "SequencePathModule.cs"
                    float csharp2cuda_temp_17 = (values)[csharp2cuda_i32_from_bits(index)];
                    (*(csharp2cuda_temp_15) = __fadd_rn(csharp2cuda_temp_16, csharp2cuda_temp_17));
#line 651 "SequencePathModule.cs"
                    if ((!(isfinite(accumulator))))
                    {
#line 652 "SequencePathModule.cs"
                        return false;
                    }
                }
                else
                {
#line 654 "SequencePathModule.cs"
                    if (((index) == (first)))
#line 655 "SequencePathModule.cs"
                    {
#line 656 "SequencePathModule.cs"
#line 656 "SequencePathModule.cs"
                        float* csharp2cuda_temp_18 = &(accumulator);
#line 656 "SequencePathModule.cs"
                        float csharp2cuda_temp_19 = (values)[csharp2cuda_i32_from_bits(index)];
                        (*(csharp2cuda_temp_18) = csharp2cuda_temp_19);
                    }
                    else
#line 659 "SequencePathModule.cs"
                    {
#line 660 "SequencePathModule.cs"
#line 660 "SequencePathModule.cs"
                        float* csharp2cuda_temp_20 = &(accumulator);
#line 660 "SequencePathModule.cs"
                        float csharp2cuda_temp_21 = (values)[csharp2cuda_i32_from_bits(index)];
                        (*(csharp2cuda_temp_20) = csharp2cuda_f32_maximum(accumulator, csharp2cuda_temp_21));
                    }
                }
            }
#line 644 "SequencePathModule.cs"
            long long* csharp2cuda_temp_13 = &(index);
            csharp2cuda_i64_post_increment(*(csharp2cuda_temp_13));
        }
    }
#line 663 "SequencePathModule.cs"
#line 663 "SequencePathModule.cs"
    float* csharp2cuda_temp_22 = result;
    (*(csharp2cuda_temp_22) = accumulator);
#line 664 "SequencePathModule.cs"
    return true;
}

#line 672 "SequencePathModule.cs"
__device__ void mathblocks_sequence_offsets(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 678 "SequencePathModule.cs"
{
#line 679 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 680 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_0 = (inputs)[0];
#line 680 "SequencePathModule.cs"
    const MathBlockSlot* series = csharp2cuda_temp_0;
#line 681 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_1 = (inputs)[1];
#line 681 "SequencePathModule.cs"
    const MathBlockSlot* flags = csharp2cuda_temp_1;
#line 682 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_2 = (inputs)[2];
#line 682 "SequencePathModule.cs"
    const MathBlockSlot* counts_slot = csharp2cuda_temp_2;
#line 683 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_3 = (inputs)[3];
#line 683 "SequencePathModule.cs"
    const MathBlockSlot* start_slot = csharp2cuda_temp_3;
#line 684 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_4 = (inputs)[4];
#line 684 "SequencePathModule.cs"
    const MathBlockSlot* end_slot = csharp2cuda_temp_4;
#line 685 "SequencePathModule.cs"
    int kind = csharp2cuda_i32_div(csharp2cuda_i32_sub(opcode, 37), 2);
#line 686 "SequencePathModule.cs"
    bool validity = ((csharp2cuda_i32_and(opcode, 1)) == (0));
#line 687 "SequencePathModule.cs"
    int start = 0;
#line 688 "SequencePathModule.cs"
    int end = 0;
#line 689 "SequencePathModule.cs"
    float csharp2cuda_temp_5 = (start_slot)->scalar_value;
#line 689 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &(start);
#line 689 "SequencePathModule.cs"
    bool offsets_valid = mathblocks_sequence_offset(csharp2cuda_temp_5, csharp2cuda_temp_6);
#line 690 "SequencePathModule.cs"
    if (offsets_valid)
    {
#line 691 "SequencePathModule.cs"
#line 691 "SequencePathModule.cs"
        bool* csharp2cuda_temp_7 = &(offsets_valid);
#line 691 "SequencePathModule.cs"
        float csharp2cuda_temp_8 = (end_slot)->scalar_value;
#line 691 "SequencePathModule.cs"
        int* csharp2cuda_temp_9 = &(end);
#line 691 "SequencePathModule.cs"
        bool csharp2cuda_temp_10 = mathblocks_sequence_offset(csharp2cuda_temp_8, csharp2cuda_temp_9);
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_10);
    }
#line 692 "SequencePathModule.cs"
    if (offsets_valid)
    {
#line 693 "SequencePathModule.cs"
#line 693 "SequencePathModule.cs"
        bool* csharp2cuda_temp_11 = &(offsets_valid);
        (*(csharp2cuda_temp_11) = ((start) <= (end)));
    }
#line 694 "SequencePathModule.cs"
    if (((thread) == (0)))
#line 695 "SequencePathModule.cs"
    {
#line 696 "SequencePathModule.cs"
#line 696 "SequencePathModule.cs"
        int* csharp2cuda_temp_12 = &((output)->valid);
#line 696 "SequencePathModule.cs"
        bool csharp2cuda_temp_13 = (series)->valid;
#line 696 "SequencePathModule.cs"
        bool csharp2cuda_temp_14;
#line 696 "SequencePathModule.cs"
        if (csharp2cuda_temp_13)
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_14 = (flags)->valid;
        }
        else
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_14 = false;
        }
#line 696 "SequencePathModule.cs"
        bool csharp2cuda_temp_15;
#line 696 "SequencePathModule.cs"
        if (csharp2cuda_temp_14)
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_15 = (counts_slot)->valid;
        }
        else
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_15 = false;
        }
#line 696 "SequencePathModule.cs"
        bool csharp2cuda_temp_16;
#line 696 "SequencePathModule.cs"
        if (csharp2cuda_temp_15)
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_16 = (start_slot)->valid;
        }
        else
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_16 = false;
        }
#line 696 "SequencePathModule.cs"
        bool csharp2cuda_temp_17;
#line 696 "SequencePathModule.cs"
        if (csharp2cuda_temp_16)
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_17 = (end_slot)->valid;
        }
        else
        {
#line 696 "SequencePathModule.cs"
            csharp2cuda_temp_17 = false;
        }
        (*(csharp2cuda_temp_12) = csharp2cuda_temp_17);
#line 697 "SequencePathModule.cs"
        {
#line 697 "SequencePathModule.cs"
            int index = 5;
            while (true)
            {
                if (!(((index) < (input_count))))
                    break;
#line 698 "SequencePathModule.cs"
                {
#line 699 "SequencePathModule.cs"
                    MathBlockSlot* csharp2cuda_temp_19 = (inputs)[index];
#line 699 "SequencePathModule.cs"
                    const MathBlockSlot* extra = csharp2cuda_temp_19;
#line 700 "SequencePathModule.cs"
#line 700 "SequencePathModule.cs"
                    int* csharp2cuda_temp_20 = &((output)->valid);
#line 700 "SequencePathModule.cs"
                    bool csharp2cuda_temp_21 = (output)->valid;
#line 700 "SequencePathModule.cs"
                    bool csharp2cuda_temp_22;
#line 700 "SequencePathModule.cs"
                    if (csharp2cuda_temp_21)
                    {
#line 700 "SequencePathModule.cs"
                        csharp2cuda_temp_22 = (extra)->valid;
                    }
                    else
                    {
#line 700 "SequencePathModule.cs"
                        csharp2cuda_temp_22 = false;
                    }
                    (*(csharp2cuda_temp_20) = csharp2cuda_temp_22);
                }
#line 697 "SequencePathModule.cs"
                int* csharp2cuda_temp_18 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
            }
        }
#line 702 "SequencePathModule.cs"
#line 702 "SequencePathModule.cs"
        int csharp2cuda_temp_23 = (series)->count;
        mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_23);
#line 703 "SequencePathModule.cs"
#line 703 "SequencePathModule.cs"
        int csharp2cuda_temp_24 = (flags)->count;
#line 703 "SequencePathModule.cs"
        int csharp2cuda_temp_25 = (series)->count;
#line 703 "SequencePathModule.cs"
        bool csharp2cuda_temp_26;
#line 703 "SequencePathModule.cs"
        if (!(((csharp2cuda_temp_24) != (csharp2cuda_temp_25))))
        {
#line 703 "SequencePathModule.cs"
            int csharp2cuda_temp_27 = (counts_slot)->count;
#line 703 "SequencePathModule.cs"
            int csharp2cuda_temp_28 = (series)->count;
#line 703 "SequencePathModule.cs"
            csharp2cuda_temp_26 = ((csharp2cuda_temp_27) != (csharp2cuda_temp_28));
        }
        else
        {
#line 703 "SequencePathModule.cs"
            csharp2cuda_temp_26 = true;
        }
#line 703 "SequencePathModule.cs"
        bool csharp2cuda_temp_29;
#line 703 "SequencePathModule.cs"
        if (!(csharp2cuda_temp_26))
        {
#line 703 "SequencePathModule.cs"
            csharp2cuda_temp_29 = (!(offsets_valid));
        }
        else
        {
#line 703 "SequencePathModule.cs"
            csharp2cuda_temp_29 = true;
        }
        if (csharp2cuda_temp_29)
        {
#line 704 "SequencePathModule.cs"
#line 704 "SequencePathModule.cs"
            int* csharp2cuda_temp_30 = &((output)->valid);
            (*(csharp2cuda_temp_30) = 0);
        }
    }
#line 706 "SequencePathModule.cs"
    __syncthreads();
#line 707 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_31 = (series)->data_pointer;
#line 707 "SequencePathModule.cs"
    const float* values = ((float*)(csharp2cuda_temp_31));
#line 708 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_32 = (flags)->data_pointer;
#line 708 "SequencePathModule.cs"
    const int* values_valid = ((int*)(csharp2cuda_temp_32));
#line 709 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_33 = (counts_slot)->data_pointer;
#line 709 "SequencePathModule.cs"
    const float* counts = ((float*)(csharp2cuda_temp_33));
#line 710 "SequencePathModule.cs"
    {
#line 710 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
#line 710 "SequencePathModule.cs"
            bool csharp2cuda_temp_36 = (output)->valid;
#line 710 "SequencePathModule.cs"
            bool csharp2cuda_temp_37;
#line 710 "SequencePathModule.cs"
            if (csharp2cuda_temp_36)
            {
#line 710 "SequencePathModule.cs"
                int csharp2cuda_temp_38 = (series)->count;
#line 710 "SequencePathModule.cs"
                csharp2cuda_temp_37 = ((index) < (csharp2cuda_temp_38));
            }
            else
            {
#line 710 "SequencePathModule.cs"
                csharp2cuda_temp_37 = false;
            }
            if (!(csharp2cuda_temp_37))
                break;
#line 711 "SequencePathModule.cs"
            {
#line 712 "SequencePathModule.cs"
#line 712 "SequencePathModule.cs"
                float csharp2cuda_temp_39 = (counts)[index];
#line 712 "SequencePathModule.cs"
                bool csharp2cuda_temp_40;
#line 712 "SequencePathModule.cs"
                if (!((!(((csharp2cuda_temp_39) >= (0.0f))))))
                {
#line 712 "SequencePathModule.cs"
                    float csharp2cuda_temp_41 = (counts)[index];
#line 712 "SequencePathModule.cs"
                    float csharp2cuda_temp_42 = (counts)[index];
#line 712 "SequencePathModule.cs"
                    csharp2cuda_temp_40 = ((csharp2cuda_temp_41) != (truncf(csharp2cuda_temp_42)));
                }
                else
                {
#line 712 "SequencePathModule.cs"
                    csharp2cuda_temp_40 = true;
                }
                if (csharp2cuda_temp_40)
                {
#line 713 "SequencePathModule.cs"
                    atomicExch(&((output)->valid), 0);
                }
            }
#line 710 "SequencePathModule.cs"
            int* csharp2cuda_temp_34 = &(index);
#line 710 "SequencePathModule.cs"
            int csharp2cuda_temp_35 = *(csharp2cuda_temp_34);
            (*(csharp2cuda_temp_34) = csharp2cuda_i32_add(csharp2cuda_temp_35, blockDim.x));
        }
    }
#line 715 "SequencePathModule.cs"
    __syncthreads();
#line 716 "SequencePathModule.cs"
#line 716 "SequencePathModule.cs"
    bool csharp2cuda_temp_43 = (output)->valid;
    if ((!(csharp2cuda_temp_43)))
    {
#line 717 "SequencePathModule.cs"
        return;
    }
#line 719 "SequencePathModule.cs"
    float no_match = 0.0f;
#line 720 "SequencePathModule.cs"
    float fill = 0.0f;
#line 721 "SequencePathModule.cs"
    if ((!(validity)))
#line 722 "SequencePathModule.cs"
    {
#line 723 "SequencePathModule.cs"
        MathBlockSlot* csharp2cuda_temp_44 = (inputs)[csharp2cuda_i32_sub(input_count, 1)];
#line 723 "SequencePathModule.cs"
        const MathBlockSlot* fill_slot = csharp2cuda_temp_44;
#line 724 "SequencePathModule.cs"
#line 724 "SequencePathModule.cs"
        float* csharp2cuda_temp_45 = &(fill);
#line 724 "SequencePathModule.cs"
        float csharp2cuda_temp_46 = (fill_slot)->scalar_value;
        (*(csharp2cuda_temp_45) = csharp2cuda_temp_46);
#line 725 "SequencePathModule.cs"
        if (((kind) == (0)))
#line 726 "SequencePathModule.cs"
        {
#line 727 "SequencePathModule.cs"
            MathBlockSlot* csharp2cuda_temp_47 = (inputs)[5];
#line 727 "SequencePathModule.cs"
            const MathBlockSlot* no_match_slot = csharp2cuda_temp_47;
#line 728 "SequencePathModule.cs"
#line 728 "SequencePathModule.cs"
            float* csharp2cuda_temp_48 = &(no_match);
#line 728 "SequencePathModule.cs"
            float csharp2cuda_temp_49 = (no_match_slot)->scalar_value;
            (*(csharp2cuda_temp_48) = csharp2cuda_temp_49);
        }
    }
#line 731 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_50 = (output)->data_pointer;
#line 731 "SequencePathModule.cs"
    float* result = ((float*)(csharp2cuda_temp_50));
#line 732 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_51 = (output)->data_pointer;
#line 732 "SequencePathModule.cs"
    int* boolean_result = ((int*)(csharp2cuda_temp_51));
#line 733 "SequencePathModule.cs"
    {
#line 733 "SequencePathModule.cs"
        int row = thread;
        while (true)
        {
#line 733 "SequencePathModule.cs"
            int csharp2cuda_temp_54 = (series)->count;
            if (!(((row) < (csharp2cuda_temp_54))))
                break;
#line 734 "SequencePathModule.cs"
            {
#line 735 "SequencePathModule.cs"
                float value = 0.0f;
#line 737 "SequencePathModule.cs"
                int csharp2cuda_temp_55 = (series)->count;
#line 737 "SequencePathModule.cs"
                float* csharp2cuda_temp_56 = &(value);
#line 736 "SequencePathModule.cs"
                bool row_valid = mathblocks_sequence_offset_row(kind, values, values_valid, counts, csharp2cuda_temp_55, row, start, end, no_match, csharp2cuda_temp_56);
#line 738 "SequencePathModule.cs"
                if (validity)
                {
#line 739 "SequencePathModule.cs"
#line 739 "SequencePathModule.cs"
                    int* csharp2cuda_temp_57 = &((boolean_result)[row]);
                    (*(csharp2cuda_temp_57) = row_valid);
                }
                else
                {
#line 741 "SequencePathModule.cs"
#line 741 "SequencePathModule.cs"
                    float* csharp2cuda_temp_58 = &((result)[row]);
#line 741 "SequencePathModule.cs"
                    float csharp2cuda_temp_59;
#line 741 "SequencePathModule.cs"
                    if (row_valid)
                    {
#line 741 "SequencePathModule.cs"
                        csharp2cuda_temp_59 = value;
                    }
                    else
                    {
#line 741 "SequencePathModule.cs"
                        csharp2cuda_temp_59 = fill;
                    }
                    (*(csharp2cuda_temp_58) = csharp2cuda_temp_59);
                }
            }
#line 733 "SequencePathModule.cs"
            int* csharp2cuda_temp_52 = &(row);
#line 733 "SequencePathModule.cs"
            int csharp2cuda_temp_53 = *(csharp2cuda_temp_52);
            (*(csharp2cuda_temp_52) = csharp2cuda_i32_add(csharp2cuda_temp_53, blockDim.x));
        }
    }
}

#line 84 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(float value)
#line 86 "SequencePathModule.cs"
{
#line 87 "SequencePathModule.cs"
    unsigned long long bits = ((unsigned long long)(__float_as_int(value)));
#line 88 "SequencePathModule.cs"
    if (((value) == (0.0f)))
    {
#line 89 "SequencePathModule.cs"
#line 89 "SequencePathModule.cs"
        unsigned long long* csharp2cuda_temp_0 = &(bits);
        (*(csharp2cuda_temp_0) = 0ull);
    }
#line 90 "SequencePathModule.cs"
#line 90 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 90 "SequencePathModule.cs"
    if (((((bits) & (9223372036854775808ull))) != (0ull)))
    {
#line 90 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (~(bits));
    }
    else
    {
#line 90 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((bits) ^ (9223372036854775808ull));
    }
    return csharp2cuda_temp_1;
}

#line 745 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 751 "SequencePathModule.cs"
{
#line 752 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 753 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 753 "SequencePathModule.cs"
    if (((input_count) > (0)))
    {
#line 753 "SequencePathModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 753 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 753 "SequencePathModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 754 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 754 "SequencePathModule.cs"
    if (((input_count) > (1)))
    {
#line 754 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 754 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 754 "SequencePathModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 755 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 755 "SequencePathModule.cs"
    if (((input_count) > (2)))
    {
#line 755 "SequencePathModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 755 "SequencePathModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 755 "SequencePathModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 756 "SequencePathModule.cs"
    if (((thread) == (0)))
#line 757 "SequencePathModule.cs"
    {
#line 758 "SequencePathModule.cs"
#line 758 "SequencePathModule.cs"
        float* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0f);
#line 759 "SequencePathModule.cs"
#line 759 "SequencePathModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 760 "SequencePathModule.cs"
#line 760 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 761 "SequencePathModule.cs"
#line 761 "SequencePathModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 762 "SequencePathModule.cs"
#line 762 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 763 "SequencePathModule.cs"
#line 763 "SequencePathModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 763 "SequencePathModule.cs"
        bool csharp2cuda_temp_9;
#line 763 "SequencePathModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 763 "SequencePathModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 763 "SequencePathModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 764 "SequencePathModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 765 "SequencePathModule.cs"
#line 765 "SequencePathModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 765 "SequencePathModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 765 "SequencePathModule.cs"
            bool csharp2cuda_temp_12;
#line 765 "SequencePathModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 765 "SequencePathModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 765 "SequencePathModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 766 "SequencePathModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 767 "SequencePathModule.cs"
#line 767 "SequencePathModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 767 "SequencePathModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 767 "SequencePathModule.cs"
            bool csharp2cuda_temp_15;
#line 767 "SequencePathModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 767 "SequencePathModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 767 "SequencePathModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 769 "SequencePathModule.cs"
    __syncthreads();
#line 770 "SequencePathModule.cs"
#line 770 "SequencePathModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 771 "SequencePathModule.cs"
        return;
    }
#line 773 "SequencePathModule.cs"
    float* csharp2cuda_temp_17;
#line 773 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 773 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((float*)(nullptr));
    }
    else
    {
#line 773 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 773 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((float*)(csharp2cuda_temp_18));
    }
#line 773 "SequencePathModule.cs"
    const float* a = csharp2cuda_temp_17;
#line 774 "SequencePathModule.cs"
    float* csharp2cuda_temp_19;
#line 774 "SequencePathModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 774 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((float*)(nullptr));
    }
    else
    {
#line 774 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 774 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((float*)(csharp2cuda_temp_20));
    }
#line 774 "SequencePathModule.cs"
    const float* b = csharp2cuda_temp_19;
#line 775 "SequencePathModule.cs"
    int* csharp2cuda_temp_21;
#line 775 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 775 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 775 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_22 = (first)->data_pointer;
#line 775 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 775 "SequencePathModule.cs"
    const int* boolean_a = csharp2cuda_temp_21;
#line 776 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 776 "SequencePathModule.cs"
    float* result = ((float*)(csharp2cuda_temp_23));
#line 777 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 777 "SequencePathModule.cs"
    float* scratch = ((float*)(csharp2cuda_temp_24));
#line 783 "SequencePathModule.cs"
    if (((opcode) == (0)))
#line 784 "SequencePathModule.cs"
    {
#line 785 "SequencePathModule.cs"
        int csharp2cuda_temp_25 = (first)->count;
#line 785 "SequencePathModule.cs"
        int csharp2cuda_temp_26 = (second)->count;
#line 785 "SequencePathModule.cs"
        int convolution_count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_25, csharp2cuda_temp_26), 1);
#line 786 "SequencePathModule.cs"
#line 786 "SequencePathModule.cs"
        int csharp2cuda_temp_27 = (first)->count;
#line 786 "SequencePathModule.cs"
        bool csharp2cuda_temp_28;
#line 786 "SequencePathModule.cs"
        if (((csharp2cuda_temp_27) > (0)))
        {
#line 786 "SequencePathModule.cs"
            int csharp2cuda_temp_29 = (second)->count;
#line 786 "SequencePathModule.cs"
            csharp2cuda_temp_28 = ((csharp2cuda_temp_29) > (0));
        }
        else
        {
#line 786 "SequencePathModule.cs"
            csharp2cuda_temp_28 = false;
        }
#line 786 "SequencePathModule.cs"
        bool csharp2cuda_temp_30;
#line 786 "SequencePathModule.cs"
        if (csharp2cuda_temp_28)
        {
#line 786 "SequencePathModule.cs"
            int csharp2cuda_temp_31 = (output)->capacity;
#line 786 "SequencePathModule.cs"
            csharp2cuda_temp_30 = ((convolution_count) <= (csharp2cuda_temp_31));
        }
        else
        {
#line 786 "SequencePathModule.cs"
            csharp2cuda_temp_30 = false;
        }
        if (csharp2cuda_temp_30)
#line 787 "SequencePathModule.cs"
        {
#line 788 "SequencePathModule.cs"
            {
#line 788 "SequencePathModule.cs"
                int output_index = thread;
                while (true)
                {
                    if (!(((output_index) < (convolution_count))))
                        break;
#line 789 "SequencePathModule.cs"
                    {
#line 790 "SequencePathModule.cs"
                        int csharp2cuda_temp_34 = (second)->count;
#line 790 "SequencePathModule.cs"
                        int low = csharp2cuda_i32_sub(output_index, csharp2cuda_i32_sub(csharp2cuda_temp_34, 1));
#line 791 "SequencePathModule.cs"
                        int csharp2cuda_temp_35;
#line 791 "SequencePathModule.cs"
                        if (((low) > (0)))
                        {
#line 791 "SequencePathModule.cs"
                            csharp2cuda_temp_35 = low;
                        }
                        else
                        {
#line 791 "SequencePathModule.cs"
                            csharp2cuda_temp_35 = 0;
                        }
#line 791 "SequencePathModule.cs"
                        int left_start = csharp2cuda_temp_35;
#line 792 "SequencePathModule.cs"
                        int csharp2cuda_temp_36 = (first)->count;
#line 792 "SequencePathModule.cs"
                        int csharp2cuda_temp_37;
#line 792 "SequencePathModule.cs"
                        if (((output_index) < (csharp2cuda_i32_sub(csharp2cuda_temp_36, 1))))
                        {
#line 792 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = output_index;
                        }
                        else
                        {
#line 792 "SequencePathModule.cs"
                            int csharp2cuda_temp_38 = (first)->count;
#line 792 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = csharp2cuda_i32_sub(csharp2cuda_temp_38, 1);
                        }
#line 792 "SequencePathModule.cs"
                        int left_end = csharp2cuda_temp_37;
#line 793 "SequencePathModule.cs"
                        float sum = 0.0f;
#line 794 "SequencePathModule.cs"
                        {
#line 794 "SequencePathModule.cs"
                            int left = left_start;
                            while (true)
                            {
                                if (!(((left) <= (left_end))))
                                    break;
#line 795 "SequencePathModule.cs"
#line 795 "SequencePathModule.cs"
                                float* csharp2cuda_temp_40 = &(sum);
#line 795 "SequencePathModule.cs"
                                float csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
#line 795 "SequencePathModule.cs"
                                float csharp2cuda_temp_42 = (a)[left];
#line 795 "SequencePathModule.cs"
                                float csharp2cuda_temp_43 = (b)[csharp2cuda_i32_sub(output_index, left)];
                                (*(csharp2cuda_temp_40) = __fadd_rn(csharp2cuda_temp_41, __fmul_rn(csharp2cuda_temp_42, csharp2cuda_temp_43)));
#line 794 "SequencePathModule.cs"
                                int* csharp2cuda_temp_39 = &(left);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_39));
                            }
                        }
#line 796 "SequencePathModule.cs"
#line 796 "SequencePathModule.cs"
                        float* csharp2cuda_temp_44 = &((result)[output_index]);
                        (*(csharp2cuda_temp_44) = sum);
                    }
#line 788 "SequencePathModule.cs"
                    int* csharp2cuda_temp_32 = &(output_index);
#line 788 "SequencePathModule.cs"
                    int csharp2cuda_temp_33 = *(csharp2cuda_temp_32);
                    (*(csharp2cuda_temp_32) = csharp2cuda_i32_add(csharp2cuda_temp_33, blockDim.x));
                }
            }
        }
#line 799 "SequencePathModule.cs"
        __syncthreads();
    }
#line 802 "SequencePathModule.cs"
    switch (opcode)
    {
#line 804 "SequencePathModule.cs"
        case 0:
#line 805 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 806 "SequencePathModule.cs"
            {
#line 807 "SequencePathModule.cs"
                int csharp2cuda_temp_45 = (first)->count;
#line 807 "SequencePathModule.cs"
                int csharp2cuda_temp_46 = (second)->count;
#line 807 "SequencePathModule.cs"
                int count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_45, csharp2cuda_temp_46), 1);
#line 808 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 809 "SequencePathModule.cs"
#line 809 "SequencePathModule.cs"
                int csharp2cuda_temp_47 = (first)->count;
#line 809 "SequencePathModule.cs"
                bool csharp2cuda_temp_48;
#line 809 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_47) <= (0))))
                {
#line 809 "SequencePathModule.cs"
                    int csharp2cuda_temp_49 = (second)->count;
#line 809 "SequencePathModule.cs"
                    csharp2cuda_temp_48 = ((csharp2cuda_temp_49) <= (0));
                }
                else
                {
#line 809 "SequencePathModule.cs"
                    csharp2cuda_temp_48 = true;
                }
                if (csharp2cuda_temp_48)
                {
#line 810 "SequencePathModule.cs"
#line 810 "SequencePathModule.cs"
                    int* csharp2cuda_temp_50 = &((output)->valid);
                    (*(csharp2cuda_temp_50) = 0);
                }
#line 814 "SequencePathModule.cs"
                bool finite = true;
#line 815 "SequencePathModule.cs"
                {
#line 815 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 815 "SequencePathModule.cs"
                        bool csharp2cuda_temp_52 = (output)->valid;
#line 815 "SequencePathModule.cs"
                        bool csharp2cuda_temp_53;
#line 815 "SequencePathModule.cs"
                        if (csharp2cuda_temp_52)
                        {
#line 815 "SequencePathModule.cs"
                            csharp2cuda_temp_53 = ((index) < (count));
                        }
                        else
                        {
#line 815 "SequencePathModule.cs"
                            csharp2cuda_temp_53 = false;
                        }
                        if (!(csharp2cuda_temp_53))
                            break;
#line 816 "SequencePathModule.cs"
#line 816 "SequencePathModule.cs"
                        float csharp2cuda_temp_54 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_54))))
                        {
#line 817 "SequencePathModule.cs"
#line 817 "SequencePathModule.cs"
                            bool* csharp2cuda_temp_55 = &(finite);
                            (*(csharp2cuda_temp_55) = false);
                        }
#line 815 "SequencePathModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 818 "SequencePathModule.cs"
                if (finite)
                {
#line 819 "SequencePathModule.cs"
                    break;
                }
#line 820 "SequencePathModule.cs"
                {
#line 820 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 820 "SequencePathModule.cs"
                        bool csharp2cuda_temp_57 = (output)->valid;
#line 820 "SequencePathModule.cs"
                        bool csharp2cuda_temp_58;
#line 820 "SequencePathModule.cs"
                        if (csharp2cuda_temp_57)
                        {
#line 820 "SequencePathModule.cs"
                            csharp2cuda_temp_58 = ((index) < (count));
                        }
                        else
                        {
#line 820 "SequencePathModule.cs"
                            csharp2cuda_temp_58 = false;
                        }
                        if (!(csharp2cuda_temp_58))
                            break;
#line 821 "SequencePathModule.cs"
#line 821 "SequencePathModule.cs"
                        float* csharp2cuda_temp_59 = &((result)[index]);
                        (*(csharp2cuda_temp_59) = 0.0f);
#line 820 "SequencePathModule.cs"
                        int* csharp2cuda_temp_56 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_56));
                    }
                }
#line 822 "SequencePathModule.cs"
                {
#line 822 "SequencePathModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 822 "SequencePathModule.cs"
                        bool csharp2cuda_temp_61 = (output)->valid;
#line 822 "SequencePathModule.cs"
                        bool csharp2cuda_temp_62;
#line 822 "SequencePathModule.cs"
                        if (csharp2cuda_temp_61)
                        {
#line 822 "SequencePathModule.cs"
                            int csharp2cuda_temp_63 = (first)->count;
#line 822 "SequencePathModule.cs"
                            csharp2cuda_temp_62 = ((left) < (csharp2cuda_temp_63));
                        }
                        else
                        {
#line 822 "SequencePathModule.cs"
                            csharp2cuda_temp_62 = false;
                        }
                        if (!(csharp2cuda_temp_62))
                            break;
#line 823 "SequencePathModule.cs"
                        {
#line 824 "SequencePathModule.cs"
                            {
#line 824 "SequencePathModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 824 "SequencePathModule.cs"
                                    int csharp2cuda_temp_65 = (second)->count;
                                    if (!(((right) < (csharp2cuda_temp_65))))
                                        break;
#line 825 "SequencePathModule.cs"
                                    {
#line 826 "SequencePathModule.cs"
#line 826 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_66 = &((result)[csharp2cuda_i32_add(left, right)]);
#line 826 "SequencePathModule.cs"
                                        float csharp2cuda_temp_67 = *(csharp2cuda_temp_66);
#line 826 "SequencePathModule.cs"
                                        float csharp2cuda_temp_68 = (a)[left];
#line 826 "SequencePathModule.cs"
                                        float csharp2cuda_temp_69 = (b)[right];
                                        (*(csharp2cuda_temp_66) = __fadd_rn(csharp2cuda_temp_67, __fmul_rn(csharp2cuda_temp_68, csharp2cuda_temp_69)));
#line 827 "SequencePathModule.cs"
#line 827 "SequencePathModule.cs"
                                        float csharp2cuda_temp_70 = (result)[csharp2cuda_i32_add(left, right)];
                                        if ((!(isfinite(csharp2cuda_temp_70))))
                                        {
#line 828 "SequencePathModule.cs"
#line 828 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_71 = &((output)->valid);
                                            (*(csharp2cuda_temp_71) = 0);
                                        }
                                    }
#line 824 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_64 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                                }
                            }
                        }
#line 822 "SequencePathModule.cs"
                        int* csharp2cuda_temp_60 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_60));
                    }
                }
            }
#line 832 "SequencePathModule.cs"
            break;
#line 833 "SequencePathModule.cs"
        case 1:
#line 834 "SequencePathModule.cs"
            {
#line 835 "SequencePathModule.cs"
                int lag = 0;
#line 836 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 837 "SequencePathModule.cs"
                {
#line 838 "SequencePathModule.cs"
#line 838 "SequencePathModule.cs"
                    float csharp2cuda_temp_72 = (second)->scalar_value;
#line 838 "SequencePathModule.cs"
                    int* csharp2cuda_temp_73 = &(lag);
#line 838 "SequencePathModule.cs"
                    bool csharp2cuda_temp_74 = mathblocks_sequence_positive_integer(csharp2cuda_temp_72, csharp2cuda_temp_73);
#line 838 "SequencePathModule.cs"
                    bool csharp2cuda_temp_75;
#line 838 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_74))))
                    {
#line 838 "SequencePathModule.cs"
                        int csharp2cuda_temp_76 = (first)->count;
#line 838 "SequencePathModule.cs"
                        csharp2cuda_temp_75 = ((lag) >= (csharp2cuda_temp_76));
                    }
                    else
                    {
#line 838 "SequencePathModule.cs"
                        csharp2cuda_temp_75 = true;
                    }
                    if (csharp2cuda_temp_75)
                    {
#line 839 "SequencePathModule.cs"
#line 839 "SequencePathModule.cs"
                        int* csharp2cuda_temp_77 = &((output)->valid);
                        (*(csharp2cuda_temp_77) = 0);
                    }
                    else
                    {
#line 841 "SequencePathModule.cs"
#line 841 "SequencePathModule.cs"
                        int csharp2cuda_temp_78 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_temp_78, lag));
                    }
#line 842 "SequencePathModule.cs"
#line 842 "SequencePathModule.cs"
                    float* csharp2cuda_temp_79 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_79) = ((float)(lag)));
                }
#line 844 "SequencePathModule.cs"
                __syncthreads();
#line 845 "SequencePathModule.cs"
#line 845 "SequencePathModule.cs"
                int* csharp2cuda_temp_80 = &(lag);
#line 845 "SequencePathModule.cs"
                float csharp2cuda_temp_81 = (output)->scalar_value;
                (*(csharp2cuda_temp_80) = csharp2cuda_f64_to_i32(csharp2cuda_temp_81));
#line 846 "SequencePathModule.cs"
                {
#line 846 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 846 "SequencePathModule.cs"
                        bool csharp2cuda_temp_84 = (output)->valid;
#line 846 "SequencePathModule.cs"
                        bool csharp2cuda_temp_85;
#line 846 "SequencePathModule.cs"
                        if (csharp2cuda_temp_84)
                        {
#line 846 "SequencePathModule.cs"
                            int csharp2cuda_temp_86 = (output)->count;
#line 846 "SequencePathModule.cs"
                            csharp2cuda_temp_85 = ((index) < (csharp2cuda_temp_86));
                        }
                        else
                        {
#line 846 "SequencePathModule.cs"
                            csharp2cuda_temp_85 = false;
                        }
                        if (!(csharp2cuda_temp_85))
                            break;
#line 847 "SequencePathModule.cs"
                        {
#line 848 "SequencePathModule.cs"
#line 848 "SequencePathModule.cs"
                            float* csharp2cuda_temp_87 = &((result)[index]);
#line 848 "SequencePathModule.cs"
                            float csharp2cuda_temp_88 = (a)[csharp2cuda_i32_add(index, lag)];
#line 848 "SequencePathModule.cs"
                            float csharp2cuda_temp_89 = (a)[index];
                            (*(csharp2cuda_temp_87) = __fsub_rn(csharp2cuda_temp_88, csharp2cuda_temp_89));
#line 849 "SequencePathModule.cs"
#line 849 "SequencePathModule.cs"
                            float csharp2cuda_temp_90 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_90))))
                            {
#line 849 "SequencePathModule.cs"
                                atomicExch(&((output)->valid), 0);
                            }
                        }
#line 846 "SequencePathModule.cs"
                        int* csharp2cuda_temp_82 = &(index);
#line 846 "SequencePathModule.cs"
                        int csharp2cuda_temp_83 = *(csharp2cuda_temp_82);
                        (*(csharp2cuda_temp_82) = csharp2cuda_i32_add(csharp2cuda_temp_83, blockDim.x));
                    }
                }
#line 851 "SequencePathModule.cs"
                break;
            }
#line 853 "SequencePathModule.cs"
        case 2:
#line 854 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 855 "SequencePathModule.cs"
            {
#line 856 "SequencePathModule.cs"
                float alpha = (second)->scalar_value;
#line 857 "SequencePathModule.cs"
#line 857 "SequencePathModule.cs"
                int csharp2cuda_temp_91 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_91);
#line 858 "SequencePathModule.cs"
#line 858 "SequencePathModule.cs"
                int csharp2cuda_temp_92 = (first)->count;
#line 858 "SequencePathModule.cs"
                bool csharp2cuda_temp_93;
#line 858 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_92) <= (0))))
                {
#line 858 "SequencePathModule.cs"
                    bool csharp2cuda_temp_94;
#line 858 "SequencePathModule.cs"
                    if (((alpha) > (0.0f)))
                    {
#line 858 "SequencePathModule.cs"
                        csharp2cuda_temp_94 = ((alpha) <= (1.0f));
                    }
                    else
                    {
#line 858 "SequencePathModule.cs"
                        csharp2cuda_temp_94 = false;
                    }
#line 858 "SequencePathModule.cs"
                    csharp2cuda_temp_93 = (!(csharp2cuda_temp_94));
                }
                else
                {
#line 858 "SequencePathModule.cs"
                    csharp2cuda_temp_93 = true;
                }
                if (csharp2cuda_temp_93)
                {
#line 859 "SequencePathModule.cs"
#line 859 "SequencePathModule.cs"
                    int* csharp2cuda_temp_95 = &((output)->valid);
                    (*(csharp2cuda_temp_95) = 0);
                }
#line 860 "SequencePathModule.cs"
                if ((output)->valid)
#line 861 "SequencePathModule.cs"
                {
#line 862 "SequencePathModule.cs"
#line 862 "SequencePathModule.cs"
                    float* csharp2cuda_temp_96 = &((result)[0]);
#line 862 "SequencePathModule.cs"
                    float csharp2cuda_temp_97 = (a)[0];
                    (*(csharp2cuda_temp_96) = csharp2cuda_temp_97);
#line 863 "SequencePathModule.cs"
                    {
#line 863 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 863 "SequencePathModule.cs"
                            int csharp2cuda_temp_99 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_99))))
                                break;
#line 864 "SequencePathModule.cs"
                            {
#line 865 "SequencePathModule.cs"
#line 865 "SequencePathModule.cs"
                                float* csharp2cuda_temp_100 = &((result)[index]);
#line 865 "SequencePathModule.cs"
                                float csharp2cuda_temp_101 = (a)[index];
#line 865 "SequencePathModule.cs"
                                float csharp2cuda_temp_102 = (result)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_100) = __fadd_rn(__fmul_rn(alpha, csharp2cuda_temp_101), __fmul_rn(__fsub_rn(1.0f, alpha), csharp2cuda_temp_102)));
#line 866 "SequencePathModule.cs"
#line 866 "SequencePathModule.cs"
                                float csharp2cuda_temp_103 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_103))))
                                {
#line 867 "SequencePathModule.cs"
#line 867 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_104 = &((output)->valid);
                                    (*(csharp2cuda_temp_104) = 0);
                                }
                            }
#line 863 "SequencePathModule.cs"
                            int* csharp2cuda_temp_98 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_98));
                        }
                    }
                }
            }
#line 871 "SequencePathModule.cs"
            break;
#line 872 "SequencePathModule.cs"
        case 3:
        case 6:
#line 874 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 875 "SequencePathModule.cs"
            {
#line 876 "SequencePathModule.cs"
                int width = 0;
#line 877 "SequencePathModule.cs"
#line 877 "SequencePathModule.cs"
                float csharp2cuda_temp_105 = (second)->scalar_value;
#line 877 "SequencePathModule.cs"
                int* csharp2cuda_temp_106 = &(width);
#line 877 "SequencePathModule.cs"
                bool csharp2cuda_temp_107 = mathblocks_sequence_positive_integer(csharp2cuda_temp_105, csharp2cuda_temp_106);
#line 877 "SequencePathModule.cs"
                bool csharp2cuda_temp_108;
#line 877 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_107))))
                {
#line 878 "SequencePathModule.cs"
                    int csharp2cuda_temp_109 = (first)->count;
#line 877 "SequencePathModule.cs"
                    csharp2cuda_temp_108 = ((width) > (csharp2cuda_temp_109));
                }
                else
                {
#line 877 "SequencePathModule.cs"
                    csharp2cuda_temp_108 = true;
                }
#line 877 "SequencePathModule.cs"
                bool csharp2cuda_temp_110;
#line 877 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_108))
                {
#line 877 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 877 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = true;
                }
                if (csharp2cuda_temp_110)
#line 879 "SequencePathModule.cs"
                {
#line 880 "SequencePathModule.cs"
#line 880 "SequencePathModule.cs"
                    int* csharp2cuda_temp_111 = &((output)->valid);
                    (*(csharp2cuda_temp_111) = 0);
                }
                else
#line 883 "SequencePathModule.cs"
                {
#line 884 "SequencePathModule.cs"
#line 884 "SequencePathModule.cs"
                    int csharp2cuda_temp_112 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_112, width), 1));
#line 885 "SequencePathModule.cs"
                    int* deque = ((int*)(scratch));
#line 886 "SequencePathModule.cs"
                    int head = 0;
#line 887 "SequencePathModule.cs"
                    int tail = 0;
#line 888 "SequencePathModule.cs"
                    {
#line 888 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 888 "SequencePathModule.cs"
                            int csharp2cuda_temp_114 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_114))))
                                break;
#line 889 "SequencePathModule.cs"
                            {
#line 890 "SequencePathModule.cs"
                                while (true)
                                {
#line 890 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_115;
#line 890 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 890 "SequencePathModule.cs"
                                        int csharp2cuda_temp_116 = (deque)[head];
#line 890 "SequencePathModule.cs"
                                        csharp2cuda_temp_115 = ((csharp2cuda_temp_116) <= (csharp2cuda_i32_sub(index, width)));
                                    }
                                    else
                                    {
#line 890 "SequencePathModule.cs"
                                        csharp2cuda_temp_115 = false;
                                    }
                                    if (!(csharp2cuda_temp_115))
                                        break;
#line 891 "SequencePathModule.cs"
#line 891 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_117 = &(head);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_117));
                                }
#line 892 "SequencePathModule.cs"
                                while (true)
                                {
#line 892 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_118;
#line 892 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 892 "SequencePathModule.cs"
                                        bool csharp2cuda_temp_119;
#line 892 "SequencePathModule.cs"
                                        if (((opcode) == (6)))
                                        {
#line 893 "SequencePathModule.cs"
                                            int csharp2cuda_temp_120 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 893 "SequencePathModule.cs"
                                            float csharp2cuda_temp_121 = (a)[csharp2cuda_temp_120];
#line 893 "SequencePathModule.cs"
                                            float csharp2cuda_temp_122 = (a)[index];
#line 892 "SequencePathModule.cs"
                                            csharp2cuda_temp_119 = ((csharp2cuda_temp_121) >= (csharp2cuda_temp_122));
                                        }
                                        else
                                        {
#line 894 "SequencePathModule.cs"
                                            int csharp2cuda_temp_123 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 894 "SequencePathModule.cs"
                                            float csharp2cuda_temp_124 = (a)[csharp2cuda_temp_123];
#line 894 "SequencePathModule.cs"
                                            float csharp2cuda_temp_125 = (a)[index];
#line 892 "SequencePathModule.cs"
                                            csharp2cuda_temp_119 = ((csharp2cuda_temp_124) <= (csharp2cuda_temp_125));
                                        }
#line 892 "SequencePathModule.cs"
                                        csharp2cuda_temp_118 = csharp2cuda_temp_119;
                                    }
                                    else
                                    {
#line 892 "SequencePathModule.cs"
                                        csharp2cuda_temp_118 = false;
                                    }
                                    if (!(csharp2cuda_temp_118))
                                        break;
#line 895 "SequencePathModule.cs"
                                    {
#line 896 "SequencePathModule.cs"
#line 896 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_126 = &(tail);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_126));
                                    }
                                }
#line 898 "SequencePathModule.cs"
#line 898 "SequencePathModule.cs"
                                int* csharp2cuda_temp_127 = &(tail);
#line 898 "SequencePathModule.cs"
                                int csharp2cuda_temp_128 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_127));
#line 898 "SequencePathModule.cs"
                                int* csharp2cuda_temp_129 = &((deque)[csharp2cuda_temp_128]);
                                (*(csharp2cuda_temp_129) = index);
#line 899 "SequencePathModule.cs"
                                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                                {
#line 900 "SequencePathModule.cs"
#line 900 "SequencePathModule.cs"
                                    float* csharp2cuda_temp_130 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 900 "SequencePathModule.cs"
                                    int csharp2cuda_temp_131 = (deque)[head];
#line 900 "SequencePathModule.cs"
                                    float csharp2cuda_temp_132 = (a)[csharp2cuda_temp_131];
                                    (*(csharp2cuda_temp_130) = csharp2cuda_temp_132);
                                }
                            }
#line 888 "SequencePathModule.cs"
                            int* csharp2cuda_temp_113 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                        }
                    }
                }
            }
#line 904 "SequencePathModule.cs"
            break;
#line 905 "SequencePathModule.cs"
        case 4:
        case 9:
#line 907 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 908 "SequencePathModule.cs"
            {
#line 909 "SequencePathModule.cs"
                int width = 0;
#line 910 "SequencePathModule.cs"
#line 910 "SequencePathModule.cs"
                float csharp2cuda_temp_133 = (second)->scalar_value;
#line 910 "SequencePathModule.cs"
                int* csharp2cuda_temp_134 = &(width);
#line 910 "SequencePathModule.cs"
                bool csharp2cuda_temp_135 = mathblocks_sequence_positive_integer(csharp2cuda_temp_133, csharp2cuda_temp_134);
#line 910 "SequencePathModule.cs"
                bool csharp2cuda_temp_136;
#line 910 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_135))))
                {
#line 910 "SequencePathModule.cs"
                    int csharp2cuda_temp_137 = (first)->count;
#line 910 "SequencePathModule.cs"
                    csharp2cuda_temp_136 = ((width) > (csharp2cuda_temp_137));
                }
                else
                {
#line 910 "SequencePathModule.cs"
                    csharp2cuda_temp_136 = true;
                }
                if (csharp2cuda_temp_136)
#line 911 "SequencePathModule.cs"
                {
#line 912 "SequencePathModule.cs"
#line 912 "SequencePathModule.cs"
                    int* csharp2cuda_temp_138 = &((output)->valid);
                    (*(csharp2cuda_temp_138) = 0);
                }
                else
#line 915 "SequencePathModule.cs"
                {
#line 916 "SequencePathModule.cs"
#line 916 "SequencePathModule.cs"
                    int csharp2cuda_temp_139 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_139, width), 1));
#line 917 "SequencePathModule.cs"
#line 917 "SequencePathModule.cs"
                    int csharp2cuda_temp_140 = (first)->count;
                    mathblocks_sequence_rolling_sum(a, csharp2cuda_temp_140, width, result);
#line 918 "SequencePathModule.cs"
                    if (((opcode) == (4)))
#line 919 "SequencePathModule.cs"
                    {
#line 920 "SequencePathModule.cs"
                        float scale = __fdiv_rn(1.0f, ((float)(width)));
#line 921 "SequencePathModule.cs"
                        {
#line 921 "SequencePathModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 921 "SequencePathModule.cs"
                                int csharp2cuda_temp_142 = (output)->count;
                                if (!(((index) < (csharp2cuda_temp_142))))
                                    break;
#line 922 "SequencePathModule.cs"
#line 922 "SequencePathModule.cs"
                                float* csharp2cuda_temp_143 = &((result)[index]);
#line 922 "SequencePathModule.cs"
                                float csharp2cuda_temp_144 = *(csharp2cuda_temp_143);
                                (*(csharp2cuda_temp_143) = __fmul_rn(csharp2cuda_temp_144, scale));
#line 921 "SequencePathModule.cs"
                                int* csharp2cuda_temp_141 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                            }
                        }
                    }
#line 924 "SequencePathModule.cs"
                    {
#line 924 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 924 "SequencePathModule.cs"
                            int csharp2cuda_temp_146 = (output)->count;
                            if (!(((index) < (csharp2cuda_temp_146))))
                                break;
#line 925 "SequencePathModule.cs"
#line 925 "SequencePathModule.cs"
                            float csharp2cuda_temp_147 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_147))))
                            {
#line 925 "SequencePathModule.cs"
#line 925 "SequencePathModule.cs"
                                int* csharp2cuda_temp_148 = &((output)->valid);
                                (*(csharp2cuda_temp_148) = 0);
                            }
#line 924 "SequencePathModule.cs"
                            int* csharp2cuda_temp_145 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_145));
                        }
                    }
                }
            }
#line 928 "SequencePathModule.cs"
            break;
#line 929 "SequencePathModule.cs"
        case 5:
        case 7:
#line 931 "SequencePathModule.cs"
            {
#line 932 "SequencePathModule.cs"
                int width = 0;
#line 933 "SequencePathModule.cs"
                float probability = 0.0f;
#line 934 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 935 "SequencePathModule.cs"
                {
#line 936 "SequencePathModule.cs"
#line 936 "SequencePathModule.cs"
                    float* csharp2cuda_temp_149 = &(probability);
#line 936 "SequencePathModule.cs"
                    float csharp2cuda_temp_150;
#line 936 "SequencePathModule.cs"
                    if (((opcode) == (5)))
                    {
#line 936 "SequencePathModule.cs"
                        csharp2cuda_temp_150 = 0.5f;
                    }
                    else
                    {
#line 936 "SequencePathModule.cs"
                        csharp2cuda_temp_150 = (third)->scalar_value;
                    }
                    (*(csharp2cuda_temp_149) = csharp2cuda_temp_150);
#line 937 "SequencePathModule.cs"
#line 937 "SequencePathModule.cs"
                    float csharp2cuda_temp_151 = (second)->scalar_value;
#line 937 "SequencePathModule.cs"
                    int* csharp2cuda_temp_152 = &(width);
#line 937 "SequencePathModule.cs"
                    bool csharp2cuda_temp_153 = mathblocks_sequence_positive_integer(csharp2cuda_temp_151, csharp2cuda_temp_152);
#line 937 "SequencePathModule.cs"
                    bool csharp2cuda_temp_154;
#line 937 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_153))))
                    {
#line 938 "SequencePathModule.cs"
                        int csharp2cuda_temp_155 = (first)->count;
#line 937 "SequencePathModule.cs"
                        csharp2cuda_temp_154 = ((width) > (csharp2cuda_temp_155));
                    }
                    else
                    {
#line 937 "SequencePathModule.cs"
                        csharp2cuda_temp_154 = true;
                    }
#line 937 "SequencePathModule.cs"
                    bool csharp2cuda_temp_156;
#line 937 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_154))
                    {
#line 938 "SequencePathModule.cs"
                        bool csharp2cuda_temp_157;
#line 938 "SequencePathModule.cs"
                        if (((probability) >= (0.0f)))
                        {
#line 938 "SequencePathModule.cs"
                            csharp2cuda_temp_157 = ((probability) <= (1.0f));
                        }
                        else
                        {
#line 938 "SequencePathModule.cs"
                            csharp2cuda_temp_157 = false;
                        }
#line 937 "SequencePathModule.cs"
                        csharp2cuda_temp_156 = (!(csharp2cuda_temp_157));
                    }
                    else
                    {
#line 937 "SequencePathModule.cs"
                        csharp2cuda_temp_156 = true;
                    }
#line 937 "SequencePathModule.cs"
                    bool csharp2cuda_temp_158;
#line 937 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_156))
                    {
#line 939 "SequencePathModule.cs"
                        bool csharp2cuda_temp_159;
#line 939 "SequencePathModule.cs"
                        if (((width) > (1)))
                        {
#line 939 "SequencePathModule.cs"
                            csharp2cuda_temp_159 = ((((void*)(scratch))) == (((void*)(nullptr))));
                        }
                        else
                        {
#line 939 "SequencePathModule.cs"
                            csharp2cuda_temp_159 = false;
                        }
#line 937 "SequencePathModule.cs"
                        csharp2cuda_temp_158 = csharp2cuda_temp_159;
                    }
                    else
                    {
#line 937 "SequencePathModule.cs"
                        csharp2cuda_temp_158 = true;
                    }
                    if (csharp2cuda_temp_158)
#line 940 "SequencePathModule.cs"
                    {
#line 941 "SequencePathModule.cs"
#line 941 "SequencePathModule.cs"
                        int* csharp2cuda_temp_160 = &((output)->valid);
                        (*(csharp2cuda_temp_160) = 0);
                    }
                    else
#line 944 "SequencePathModule.cs"
                    {
#line 945 "SequencePathModule.cs"
#line 945 "SequencePathModule.cs"
                        int csharp2cuda_temp_161 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_161, width), 1));
                    }
#line 947 "SequencePathModule.cs"
#line 947 "SequencePathModule.cs"
                    float* csharp2cuda_temp_162 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_162) = probability);
#line 948 "SequencePathModule.cs"
#line 948 "SequencePathModule.cs"
                    int* csharp2cuda_temp_163 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_163) = width);
                }
#line 950 "SequencePathModule.cs"
                __syncthreads();
#line 951 "SequencePathModule.cs"
#line 951 "SequencePathModule.cs"
                int* csharp2cuda_temp_164 = &(width);
#line 951 "SequencePathModule.cs"
                int csharp2cuda_temp_165 = (output)->boolean_value;
                (*(csharp2cuda_temp_164) = csharp2cuda_temp_165);
#line 952 "SequencePathModule.cs"
#line 952 "SequencePathModule.cs"
                float* csharp2cuda_temp_166 = &(probability);
#line 952 "SequencePathModule.cs"
                float csharp2cuda_temp_167 = (output)->scalar_value;
                (*(csharp2cuda_temp_166) = csharp2cuda_temp_167);
#line 954 "SequencePathModule.cs"
                __syncthreads();
#line 955 "SequencePathModule.cs"
#line 955 "SequencePathModule.cs"
                bool csharp2cuda_temp_168 = (output)->valid;
                if ((!(csharp2cuda_temp_168)))
                {
#line 956 "SequencePathModule.cs"
                    break;
                }
#line 957 "SequencePathModule.cs"
                if (((width) == (1)))
#line 958 "SequencePathModule.cs"
                {
#line 959 "SequencePathModule.cs"
                    {
#line 959 "SequencePathModule.cs"
                        int index = thread;
                        while (true)
                        {
#line 959 "SequencePathModule.cs"
                            int csharp2cuda_temp_171 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_171))))
                                break;
#line 960 "SequencePathModule.cs"
#line 960 "SequencePathModule.cs"
                            float* csharp2cuda_temp_172 = &((result)[index]);
#line 960 "SequencePathModule.cs"
                            float csharp2cuda_temp_173 = (a)[index];
                            (*(csharp2cuda_temp_172) = csharp2cuda_temp_173);
#line 959 "SequencePathModule.cs"
                            int* csharp2cuda_temp_169 = &(index);
#line 959 "SequencePathModule.cs"
                            int csharp2cuda_temp_170 = *(csharp2cuda_temp_169);
                            (*(csharp2cuda_temp_169) = csharp2cuda_i32_add(csharp2cuda_temp_170, blockDim.x));
                        }
                    }
#line 961 "SequencePathModule.cs"
                    __syncthreads();
#line 962 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 963 "SequencePathModule.cs"
                    {
#line 964 "SequencePathModule.cs"
#line 964 "SequencePathModule.cs"
                        float* csharp2cuda_temp_174 = &((output)->scalar_value);
#line 964 "SequencePathModule.cs"
                        int csharp2cuda_temp_175 = (first)->count;
                        (*(csharp2cuda_temp_174) = ((float)(csharp2cuda_temp_175)));
#line 965 "SequencePathModule.cs"
#line 965 "SequencePathModule.cs"
                        int* csharp2cuda_temp_176 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_176) = 0);
                    }
#line 967 "SequencePathModule.cs"
                    break;
                }
#line 969 "SequencePathModule.cs"
#line 969 "SequencePathModule.cs"
                bool csharp2cuda_temp_177;
#line 969 "SequencePathModule.cs"
                if (!(((probability) == (0.0f))))
                {
#line 969 "SequencePathModule.cs"
                    csharp2cuda_temp_177 = ((probability) == (1.0f));
                }
                else
                {
#line 969 "SequencePathModule.cs"
                    csharp2cuda_temp_177 = true;
                }
                if (csharp2cuda_temp_177)
#line 970 "SequencePathModule.cs"
                {
#line 971 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 972 "SequencePathModule.cs"
                    {
#line 973 "SequencePathModule.cs"
#line 975 "SequencePathModule.cs"
                        int csharp2cuda_temp_178 = (first)->count;
                        mathblocks_sequence_rolling_extreme(a, csharp2cuda_temp_178, width, result, ((int*)(scratch)), ((probability) == (0.0f)));
#line 980 "SequencePathModule.cs"
#line 980 "SequencePathModule.cs"
                        float* csharp2cuda_temp_179 = &((output)->scalar_value);
#line 981 "SequencePathModule.cs"
                        int csharp2cuda_temp_180 = (first)->count;
#line 981 "SequencePathModule.cs"
                        int csharp2cuda_temp_181 = (output)->count;
                        (*(csharp2cuda_temp_179) = ((float)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_180)), ((long long)(3))), ((long long)(csharp2cuda_temp_181))))));
#line 982 "SequencePathModule.cs"
#line 982 "SequencePathModule.cs"
                        int* csharp2cuda_temp_182 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_182) = 0);
                    }
#line 984 "SequencePathModule.cs"
                    __syncthreads();
#line 985 "SequencePathModule.cs"
                    break;
                }
#line 988 "SequencePathModule.cs"
                unsigned char* order_scratch = ((unsigned char*)(scratch));
#line 989 "SequencePathModule.cs"
#line 991 "SequencePathModule.cs"
                int csharp2cuda_temp_183 = (first)->count;
                mathblocks_sequence_prepare_order_ranks(a, csharp2cuda_temp_183, order_scratch, output);
#line 994 "SequencePathModule.cs"
#line 994 "SequencePathModule.cs"
                bool csharp2cuda_temp_184 = (output)->valid;
                if ((!(csharp2cuda_temp_184)))
                {
#line 995 "SequencePathModule.cs"
                    break;
                }
#line 996 "SequencePathModule.cs"
                unsigned long long* first_keys = ((unsigned long long*)(order_scratch));
#line 997 "SequencePathModule.cs"
                int csharp2cuda_temp_185 = (first)->count;
#line 997 "SequencePathModule.cs"
                unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, csharp2cuda_temp_185);
#line 998 "SequencePathModule.cs"
                int csharp2cuda_temp_186 = (first)->count;
#line 998 "SequencePathModule.cs"
                int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, csharp2cuda_temp_186)));
#line 999 "SequencePathModule.cs"
                int csharp2cuda_temp_187 = (first)->count;
#line 999 "SequencePathModule.cs"
                int* second_indexes = csharp2cuda_pointer_add(first_indexes, csharp2cuda_temp_187);
#line 1000 "SequencePathModule.cs"
                int csharp2cuda_temp_188 = (first)->count;
#line 1000 "SequencePathModule.cs"
                int* ranks = csharp2cuda_pointer_add(second_indexes, csharp2cuda_temp_188);
#line 1001 "SequencePathModule.cs"
                int csharp2cuda_temp_189 = (first)->count;
#line 1001 "SequencePathModule.cs"
                int* lower_heap = csharp2cuda_pointer_add(ranks, csharp2cuda_temp_189);
#line 1002 "SequencePathModule.cs"
                int* upper_heap = csharp2cuda_pointer_add(lower_heap, width);
#line 1003 "SequencePathModule.cs"
                int* positions = csharp2cuda_pointer_add(upper_heap, width);
#line 1004 "SequencePathModule.cs"
                int csharp2cuda_temp_190 = (first)->count;
#line 1004 "SequencePathModule.cs"
                int* kinds = csharp2cuda_pointer_add(positions, csharp2cuda_temp_190);
#line 1005 "SequencePathModule.cs"
                float quantile_position = __fmul_rn(probability, ((float)(csharp2cuda_i32_sub(width, 1))));
#line 1006 "SequencePathModule.cs"
                int lower_index = csharp2cuda_f64_to_i32(floorf(quantile_position));
#line 1007 "SequencePathModule.cs"
                int upper_index = csharp2cuda_f64_to_i32(ceilf(quantile_position));
#line 1008 "SequencePathModule.cs"
                float weight = __fsub_rn(quantile_position, ((float)(lower_index)));
#line 1010 "SequencePathModule.cs"
#line 1010 "SequencePathModule.cs"
                int csharp2cuda_temp_191 = (output)->count;
                if (((csharp2cuda_temp_191) == (1)))
#line 1011 "SequencePathModule.cs"
                {
#line 1012 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 1013 "SequencePathModule.cs"
                    {
#line 1014 "SequencePathModule.cs"
                        int csharp2cuda_temp_192 = (first_indexes)[lower_index];
#line 1014 "SequencePathModule.cs"
                        float lower_value = (a)[csharp2cuda_temp_192];
#line 1015 "SequencePathModule.cs"
                        int csharp2cuda_temp_193 = (first_indexes)[upper_index];
#line 1015 "SequencePathModule.cs"
                        float upper_value = (a)[csharp2cuda_temp_193];
#line 1016 "SequencePathModule.cs"
#line 1016 "SequencePathModule.cs"
                        float* csharp2cuda_temp_194 = &((result)[0]);
                        (*(csharp2cuda_temp_194) = __fadd_rn(__fmul_rn(lower_value, __fsub_rn(1.0f, weight)), __fmul_rn(upper_value, weight)));
#line 1017 "SequencePathModule.cs"
#line 1017 "SequencePathModule.cs"
                        int* csharp2cuda_temp_195 = &((output)->valid);
#line 1017 "SequencePathModule.cs"
                        float csharp2cuda_temp_196 = (result)[0];
                        (*(csharp2cuda_temp_195) = isfinite(csharp2cuda_temp_196));
#line 1018 "SequencePathModule.cs"
#line 1018 "SequencePathModule.cs"
                        float* csharp2cuda_temp_197 = &((output)->scalar_value);
#line 1018 "SequencePathModule.cs"
                        int csharp2cuda_temp_198 = (first)->count;
                        (*(csharp2cuda_temp_197) = ((float)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_198)), ((long long)(64))), ((long long)(2))))));
#line 1019 "SequencePathModule.cs"
#line 1019 "SequencePathModule.cs"
                        int* csharp2cuda_temp_199 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_199) = 64);
                    }
#line 1021 "SequencePathModule.cs"
                    __syncthreads();
#line 1022 "SequencePathModule.cs"
                    break;
                }
#line 1025 "SequencePathModule.cs"
                {
#line 1025 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 1025 "SequencePathModule.cs"
                        int csharp2cuda_temp_202 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_202))))
                            break;
#line 1026 "SequencePathModule.cs"
                        {
#line 1027 "SequencePathModule.cs"
#line 1027 "SequencePathModule.cs"
                            int* csharp2cuda_temp_203 = &((positions)[index]);
                            (*(csharp2cuda_temp_203) = csharp2cuda_i32_neg(1));
#line 1028 "SequencePathModule.cs"
#line 1028 "SequencePathModule.cs"
                            int* csharp2cuda_temp_204 = &((kinds)[index]);
                            (*(csharp2cuda_temp_204) = csharp2cuda_i32_neg(1));
                        }
#line 1025 "SequencePathModule.cs"
                        int* csharp2cuda_temp_200 = &(index);
#line 1025 "SequencePathModule.cs"
                        int csharp2cuda_temp_201 = *(csharp2cuda_temp_200);
                        (*(csharp2cuda_temp_200) = csharp2cuda_i32_add(csharp2cuda_temp_201, blockDim.x));
                    }
                }
#line 1030 "SequencePathModule.cs"
                __syncthreads();
#line 1031 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 1032 "SequencePathModule.cs"
                {
#line 1033 "SequencePathModule.cs"
                    int lower_count = 0;
#line 1034 "SequencePathModule.cs"
                    int upper_count = 0;
#line 1035 "SequencePathModule.cs"
                    int target_lower_count = csharp2cuda_i32_add(lower_index, 1);
#line 1036 "SequencePathModule.cs"
                    {
#line 1036 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (width))))
                                break;
#line 1037 "SequencePathModule.cs"
                            {
#line 1038 "SequencePathModule.cs"
#line 1038 "SequencePathModule.cs"
                                bool csharp2cuda_temp_206;
#line 1038 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
                                {
#line 1038 "SequencePathModule.cs"
                                    csharp2cuda_temp_206 = ((upper_count) == (0));
                                }
                                else
                                {
#line 1038 "SequencePathModule.cs"
                                    csharp2cuda_temp_206 = false;
                                }
                                if (csharp2cuda_temp_206)
#line 1039 "SequencePathModule.cs"
                                {
#line 1040 "SequencePathModule.cs"
#line 1042 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_207 = &(lower_count);
                                    mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_207, index, 0, positions, kinds, ranks, true);
                                }
                                else
                                {
#line 1050 "SequencePathModule.cs"
                                    if (((lower_count) == (0)))
#line 1051 "SequencePathModule.cs"
                                    {
#line 1052 "SequencePathModule.cs"
#line 1054 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_208 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_208, index, 1, positions, kinds, ranks, false);
                                    }
                                    else
                                    {
#line 1062 "SequencePathModule.cs"
#line 1062 "SequencePathModule.cs"
                                        int csharp2cuda_temp_209 = (ranks)[index];
#line 1062 "SequencePathModule.cs"
                                        int csharp2cuda_temp_210 = (lower_heap)[0];
#line 1062 "SequencePathModule.cs"
                                        int csharp2cuda_temp_211 = (ranks)[csharp2cuda_temp_210];
                                        if (((csharp2cuda_temp_209) <= (csharp2cuda_temp_211)))
#line 1063 "SequencePathModule.cs"
                                        {
#line 1064 "SequencePathModule.cs"
#line 1066 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_212 = &(lower_count);
                                            mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_212, index, 0, positions, kinds, ranks, true);
                                        }
                                        else
#line 1075 "SequencePathModule.cs"
                                        {
#line 1076 "SequencePathModule.cs"
#line 1078 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_213 = &(upper_count);
                                            mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_213, index, 1, positions, kinds, ranks, false);
                                        }
                                    }
                                }
#line 1086 "SequencePathModule.cs"
                                int csharp2cuda_temp_214;
#line 1086 "SequencePathModule.cs"
                                if (((target_lower_count) < (csharp2cuda_i32_add(index, 1))))
                                {
#line 1086 "SequencePathModule.cs"
                                    csharp2cuda_temp_214 = target_lower_count;
                                }
                                else
                                {
#line 1086 "SequencePathModule.cs"
                                    csharp2cuda_temp_214 = csharp2cuda_i32_add(index, 1);
                                }
#line 1086 "SequencePathModule.cs"
                                int active_target = csharp2cuda_temp_214;
#line 1089 "SequencePathModule.cs"
#line 1091 "SequencePathModule.cs"
                                int* csharp2cuda_temp_215 = &(lower_count);
#line 1093 "SequencePathModule.cs"
                                int* csharp2cuda_temp_216 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_215, upper_heap, csharp2cuda_temp_216, active_target, positions, kinds, ranks);
                            }
#line 1036 "SequencePathModule.cs"
                            int* csharp2cuda_temp_205 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                        }
                    }
#line 1099 "SequencePathModule.cs"
                    {
#line 1099 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 1099 "SequencePathModule.cs"
                            int csharp2cuda_temp_218 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_218))))
                                break;
#line 1100 "SequencePathModule.cs"
                            {
#line 1101 "SequencePathModule.cs"
                                int csharp2cuda_temp_219 = (lower_heap)[0];
#line 1101 "SequencePathModule.cs"
                                float lower_value = (a)[csharp2cuda_temp_219];
#line 1102 "SequencePathModule.cs"
                                float csharp2cuda_temp_220;
#line 1102 "SequencePathModule.cs"
                                if (((lower_index) == (upper_index)))
                                {
#line 1102 "SequencePathModule.cs"
                                    csharp2cuda_temp_220 = lower_value;
                                }
                                else
                                {
#line 1104 "SequencePathModule.cs"
                                    int csharp2cuda_temp_221 = (upper_heap)[0];
#line 1102 "SequencePathModule.cs"
                                    csharp2cuda_temp_220 = (a)[csharp2cuda_temp_221];
                                }
#line 1102 "SequencePathModule.cs"
                                float upper_value = csharp2cuda_temp_220;
#line 1105 "SequencePathModule.cs"
#line 1105 "SequencePathModule.cs"
                                float* csharp2cuda_temp_222 = &((result)[start]);
                                (*(csharp2cuda_temp_222) = __fadd_rn(__fmul_rn(lower_value, __fsub_rn(1.0f, weight)), __fmul_rn(upper_value, weight)));
#line 1106 "SequencePathModule.cs"
#line 1106 "SequencePathModule.cs"
                                float csharp2cuda_temp_223 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_223))))
#line 1107 "SequencePathModule.cs"
                                {
#line 1108 "SequencePathModule.cs"
#line 1108 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_224 = &((output)->valid);
                                    (*(csharp2cuda_temp_224) = 0);
#line 1109 "SequencePathModule.cs"
                                    break;
                                }
#line 1111 "SequencePathModule.cs"
#line 1111 "SequencePathModule.cs"
                                int csharp2cuda_temp_225 = (output)->count;
                                if (((csharp2cuda_i32_add(start, 1)) == (csharp2cuda_temp_225)))
                                {
#line 1112 "SequencePathModule.cs"
                                    break;
                                }
#line 1113 "SequencePathModule.cs"
                                int outgoing = start;
#line 1114 "SequencePathModule.cs"
                                int incoming = csharp2cuda_i32_add(start, width);
#line 1115 "SequencePathModule.cs"
#line 1115 "SequencePathModule.cs"
                                int csharp2cuda_temp_226 = (kinds)[outgoing];
                                if (((csharp2cuda_temp_226) == (0)))
#line 1116 "SequencePathModule.cs"
                                {
#line 1117 "SequencePathModule.cs"
#line 1119 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_227 = &(lower_count);
                                    mathblocks_sequence_heap_remove(lower_heap, csharp2cuda_temp_227, outgoing, positions, kinds, ranks, true);
                                }
                                else
#line 1127 "SequencePathModule.cs"
                                {
#line 1128 "SequencePathModule.cs"
#line 1130 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_228 = &(upper_count);
                                    mathblocks_sequence_heap_remove(upper_heap, csharp2cuda_temp_228, outgoing, positions, kinds, ranks, false);
                                }
#line 1137 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
#line 1138 "SequencePathModule.cs"
                                {
#line 1139 "SequencePathModule.cs"
#line 1141 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_229 = &(upper_count);
                                    mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_229, incoming, 1, positions, kinds, ranks, false);
                                }
                                else
                                {
#line 1149 "SequencePathModule.cs"
#line 1149 "SequencePathModule.cs"
                                    int csharp2cuda_temp_230 = (ranks)[incoming];
#line 1149 "SequencePathModule.cs"
                                    int csharp2cuda_temp_231 = (lower_heap)[0];
#line 1149 "SequencePathModule.cs"
                                    int csharp2cuda_temp_232 = (ranks)[csharp2cuda_temp_231];
                                    if (((csharp2cuda_temp_230) <= (csharp2cuda_temp_232)))
#line 1150 "SequencePathModule.cs"
                                    {
#line 1151 "SequencePathModule.cs"
#line 1153 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_233 = &(lower_count);
                                        mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_233, incoming, 0, positions, kinds, ranks, true);
                                    }
                                    else
#line 1162 "SequencePathModule.cs"
                                    {
#line 1163 "SequencePathModule.cs"
#line 1165 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_234 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_234, incoming, 1, positions, kinds, ranks, false);
                                    }
                                }
#line 1173 "SequencePathModule.cs"
#line 1175 "SequencePathModule.cs"
                                int* csharp2cuda_temp_235 = &(lower_count);
#line 1177 "SequencePathModule.cs"
                                int* csharp2cuda_temp_236 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_235, upper_heap, csharp2cuda_temp_236, target_lower_count, positions, kinds, ranks);
                            }
#line 1099 "SequencePathModule.cs"
                            int* csharp2cuda_temp_217 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                        }
                    }
#line 1183 "SequencePathModule.cs"
                    int heap_height = 1;
#line 1184 "SequencePathModule.cs"
                    {
#line 1184 "SequencePathModule.cs"
                        int value = width;
                        while (true)
                        {
                            if (!(((value) > (1))))
                                break;
#line 1185 "SequencePathModule.cs"
#line 1185 "SequencePathModule.cs"
                            int* csharp2cuda_temp_238 = &(heap_height);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_238));
#line 1184 "SequencePathModule.cs"
                            int* csharp2cuda_temp_237 = &(value);
                            (*(csharp2cuda_temp_237) = csharp2cuda_i32_shr(csharp2cuda_i32_add(value, 1), 1));
                        }
                    }
#line 1187 "SequencePathModule.cs"
                    int csharp2cuda_temp_239 = (first)->count;
#line 1186 "SequencePathModule.cs"
                    long long heap_bound = csharp2cuda_i64_mul(csharp2cuda_i64_add(((long long)(width)), csharp2cuda_i64_mul(2LL, ((long long)(csharp2cuda_i32_sub(csharp2cuda_temp_239, width))))), ((long long)(heap_height)));
#line 1188 "SequencePathModule.cs"
                    int csharp2cuda_temp_240 = (output)->count;
#line 1188 "SequencePathModule.cs"
                    long long selection_bound = csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_240)), ((long long)(2)));
#line 1189 "SequencePathModule.cs"
#line 1189 "SequencePathModule.cs"
                    float* csharp2cuda_temp_241 = &((output)->scalar_value);
#line 1190 "SequencePathModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
                    (*(csharp2cuda_temp_241) = ((float)(csharp2cuda_i64_add(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_242)), ((long long)(64))), heap_bound), selection_bound))));
#line 1191 "SequencePathModule.cs"
#line 1191 "SequencePathModule.cs"
                    int* csharp2cuda_temp_243 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_243) = 64);
                }
#line 1193 "SequencePathModule.cs"
                __syncthreads();
#line 1194 "SequencePathModule.cs"
                break;
            }
#line 1196 "SequencePathModule.cs"
        case 8:
        case 10:
#line 1198 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1199 "SequencePathModule.cs"
            {
#line 1200 "SequencePathModule.cs"
                int width = 0;
#line 1201 "SequencePathModule.cs"
#line 1201 "SequencePathModule.cs"
                float csharp2cuda_temp_244 = (second)->scalar_value;
#line 1201 "SequencePathModule.cs"
                int* csharp2cuda_temp_245 = &(width);
#line 1201 "SequencePathModule.cs"
                bool csharp2cuda_temp_246 = mathblocks_sequence_positive_integer(csharp2cuda_temp_244, csharp2cuda_temp_245);
#line 1201 "SequencePathModule.cs"
                bool csharp2cuda_temp_247;
#line 1201 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_246))))
                {
#line 1201 "SequencePathModule.cs"
                    int csharp2cuda_temp_248 = (first)->count;
#line 1201 "SequencePathModule.cs"
                    csharp2cuda_temp_247 = ((width) > (csharp2cuda_temp_248));
                }
                else
                {
#line 1201 "SequencePathModule.cs"
                    csharp2cuda_temp_247 = true;
                }
                if (csharp2cuda_temp_247)
#line 1202 "SequencePathModule.cs"
                {
#line 1203 "SequencePathModule.cs"
#line 1203 "SequencePathModule.cs"
                    int* csharp2cuda_temp_249 = &((output)->valid);
                    (*(csharp2cuda_temp_249) = 0);
                }
                else
#line 1206 "SequencePathModule.cs"
                {
#line 1207 "SequencePathModule.cs"
#line 1207 "SequencePathModule.cs"
                    int csharp2cuda_temp_250 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_250, width), 1));
#line 1208 "SequencePathModule.cs"
                    {
#line 1208 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 1208 "SequencePathModule.cs"
                            int csharp2cuda_temp_252 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_252))))
                                break;
#line 1209 "SequencePathModule.cs"
                            {
#line 1210 "SequencePathModule.cs"
                                float mean = 0.0f;
#line 1211 "SequencePathModule.cs"
                                {
#line 1211 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 1212 "SequencePathModule.cs"
#line 1212 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_254 = &(mean);
#line 1212 "SequencePathModule.cs"
                                        float csharp2cuda_temp_255 = *(csharp2cuda_temp_254);
#line 1212 "SequencePathModule.cs"
                                        float csharp2cuda_temp_256 = (a)[csharp2cuda_i32_add(start, index)];
                                        (*(csharp2cuda_temp_254) = __fadd_rn(csharp2cuda_temp_255, csharp2cuda_temp_256));
#line 1211 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_253 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                                    }
                                }
#line 1213 "SequencePathModule.cs"
#line 1213 "SequencePathModule.cs"
                                float* csharp2cuda_temp_257 = &(mean);
#line 1213 "SequencePathModule.cs"
                                float csharp2cuda_temp_258 = *(csharp2cuda_temp_257);
                                (*(csharp2cuda_temp_257) = __fdiv_rn(csharp2cuda_temp_258, ((float)(width))));
#line 1214 "SequencePathModule.cs"
                                float sum_squares = 0.0f;
#line 1215 "SequencePathModule.cs"
                                {
#line 1215 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 1216 "SequencePathModule.cs"
                                        {
#line 1217 "SequencePathModule.cs"
                                            float csharp2cuda_temp_260 = (a)[csharp2cuda_i32_add(start, index)];
#line 1217 "SequencePathModule.cs"
                                            float difference = __fsub_rn(csharp2cuda_temp_260, mean);
#line 1218 "SequencePathModule.cs"
#line 1218 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_261 = &(sum_squares);
#line 1218 "SequencePathModule.cs"
                                            float csharp2cuda_temp_262 = *(csharp2cuda_temp_261);
                                            (*(csharp2cuda_temp_261) = __fadd_rn(csharp2cuda_temp_262, __fmul_rn(difference, difference)));
                                        }
#line 1215 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_259 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_259));
                                    }
                                }
#line 1220 "SequencePathModule.cs"
                                float csharp2cuda_temp_263 = __fdiv_rn(sum_squares, ((float)(width)));
#line 1220 "SequencePathModule.cs"
                                float deviation = mathblocks_square_root(csharp2cuda_temp_263);
#line 1221 "SequencePathModule.cs"
#line 1221 "SequencePathModule.cs"
                                float* csharp2cuda_temp_264 = &((result)[start]);
#line 1221 "SequencePathModule.cs"
                                float csharp2cuda_temp_265;
#line 1221 "SequencePathModule.cs"
                                if (((opcode) == (8)))
                                {
#line 1221 "SequencePathModule.cs"
                                    csharp2cuda_temp_265 = deviation;
                                }
                                else
                                {
#line 1221 "SequencePathModule.cs"
                                    csharp2cuda_temp_265 = __fmul_rn(deviation, deviation);
                                }
                                (*(csharp2cuda_temp_264) = csharp2cuda_temp_265);
#line 1222 "SequencePathModule.cs"
#line 1222 "SequencePathModule.cs"
                                float csharp2cuda_temp_266 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_266))))
                                {
#line 1223 "SequencePathModule.cs"
#line 1223 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_267 = &((output)->valid);
                                    (*(csharp2cuda_temp_267) = 0);
                                }
                            }
#line 1208 "SequencePathModule.cs"
                            int* csharp2cuda_temp_251 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_251));
                        }
                    }
                }
            }
#line 1227 "SequencePathModule.cs"
            break;
#line 1228 "SequencePathModule.cs"
        case 11:
#line 1229 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1230 "SequencePathModule.cs"
            {
#line 1231 "SequencePathModule.cs"
#line 1231 "SequencePathModule.cs"
                int csharp2cuda_temp_268 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_268);
#line 1232 "SequencePathModule.cs"
#line 1232 "SequencePathModule.cs"
                int csharp2cuda_temp_269 = (first)->count;
#line 1232 "SequencePathModule.cs"
                bool csharp2cuda_temp_270;
#line 1232 "SequencePathModule.cs"
                if (!((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_269)))))
                {
#line 1232 "SequencePathModule.cs"
                    csharp2cuda_temp_270 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1232 "SequencePathModule.cs"
                    csharp2cuda_temp_270 = true;
                }
                if (csharp2cuda_temp_270)
#line 1233 "SequencePathModule.cs"
                {
#line 1234 "SequencePathModule.cs"
#line 1234 "SequencePathModule.cs"
                    int* csharp2cuda_temp_271 = &((output)->valid);
                    (*(csharp2cuda_temp_271) = 0);
                }
                else
#line 1237 "SequencePathModule.cs"
                {
#line 1238 "SequencePathModule.cs"
                    {
#line 1238 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1238 "SequencePathModule.cs"
                            int csharp2cuda_temp_273 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_273))))
                                break;
#line 1239 "SequencePathModule.cs"
#line 1239 "SequencePathModule.cs"
                            float* csharp2cuda_temp_274 = &((result)[index]);
#line 1239 "SequencePathModule.cs"
                            float csharp2cuda_temp_275 = (a)[index];
                            (*(csharp2cuda_temp_274) = csharp2cuda_temp_275);
#line 1238 "SequencePathModule.cs"
                            int* csharp2cuda_temp_272 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_272));
                        }
                    }
#line 1240 "SequencePathModule.cs"
                    int length = (first)->count;
#line 1241 "SequencePathModule.cs"
                    float scale = __fdiv_rn(1.0f, mathblocks_square_root(2.0f));
#line 1242 "SequencePathModule.cs"
                    while (true)
                    {
                        if (!(((length) > (1))))
                            break;
#line 1243 "SequencePathModule.cs"
                        {
#line 1244 "SequencePathModule.cs"
                            int half = csharp2cuda_i32_div(length, 2);
#line 1245 "SequencePathModule.cs"
                            {
#line 1245 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (half))))
                                        break;
#line 1246 "SequencePathModule.cs"
                                    {
#line 1247 "SequencePathModule.cs"
#line 1247 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_277 = &((scratch)[index]);
#line 1247 "SequencePathModule.cs"
                                        float csharp2cuda_temp_278 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1247 "SequencePathModule.cs"
                                        float csharp2cuda_temp_279 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_277) = __fmul_rn(__fadd_rn(csharp2cuda_temp_278, csharp2cuda_temp_279), scale));
#line 1248 "SequencePathModule.cs"
#line 1248 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_280 = &((scratch)[csharp2cuda_i32_add(half, index)]);
#line 1248 "SequencePathModule.cs"
                                        float csharp2cuda_temp_281 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1248 "SequencePathModule.cs"
                                        float csharp2cuda_temp_282 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_280) = __fmul_rn(__fsub_rn(csharp2cuda_temp_281, csharp2cuda_temp_282), scale));
                                    }
#line 1245 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_276 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_276));
                                }
                            }
#line 1250 "SequencePathModule.cs"
                            {
#line 1250 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 1251 "SequencePathModule.cs"
#line 1251 "SequencePathModule.cs"
                                    float* csharp2cuda_temp_284 = &((result)[index]);
#line 1251 "SequencePathModule.cs"
                                    float csharp2cuda_temp_285 = (scratch)[index];
                                    (*(csharp2cuda_temp_284) = csharp2cuda_temp_285);
#line 1250 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_283 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_283));
                                }
                            }
#line 1252 "SequencePathModule.cs"
#line 1252 "SequencePathModule.cs"
                            int* csharp2cuda_temp_286 = &(length);
                            (*(csharp2cuda_temp_286) = half);
                        }
                    }
#line 1254 "SequencePathModule.cs"
                    {
#line 1254 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1254 "SequencePathModule.cs"
                            int csharp2cuda_temp_288 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_288))))
                                break;
#line 1255 "SequencePathModule.cs"
#line 1255 "SequencePathModule.cs"
                            float csharp2cuda_temp_289 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_289))))
                            {
#line 1255 "SequencePathModule.cs"
#line 1255 "SequencePathModule.cs"
                                int* csharp2cuda_temp_290 = &((output)->valid);
                                (*(csharp2cuda_temp_290) = 0);
                            }
#line 1254 "SequencePathModule.cs"
                            int* csharp2cuda_temp_287 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_287));
                        }
                    }
                }
            }
#line 1258 "SequencePathModule.cs"
            break;
#line 1259 "SequencePathModule.cs"
        case 12:
#line 1260 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1261 "SequencePathModule.cs"
            {
#line 1262 "SequencePathModule.cs"
#line 1262 "SequencePathModule.cs"
                int csharp2cuda_temp_291 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_291);
#line 1263 "SequencePathModule.cs"
#line 1263 "SequencePathModule.cs"
                int csharp2cuda_temp_292 = (first)->count;
                if ((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_292))))
#line 1264 "SequencePathModule.cs"
                {
#line 1265 "SequencePathModule.cs"
#line 1265 "SequencePathModule.cs"
                    int* csharp2cuda_temp_293 = &((output)->valid);
                    (*(csharp2cuda_temp_293) = 0);
                }
                else
#line 1268 "SequencePathModule.cs"
                {
#line 1269 "SequencePathModule.cs"
                    {
#line 1269 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1269 "SequencePathModule.cs"
                            int csharp2cuda_temp_295 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_295))))
                                break;
#line 1270 "SequencePathModule.cs"
#line 1270 "SequencePathModule.cs"
                            float* csharp2cuda_temp_296 = &((result)[index]);
#line 1270 "SequencePathModule.cs"
                            float csharp2cuda_temp_297 = (a)[index];
                            (*(csharp2cuda_temp_296) = csharp2cuda_temp_297);
#line 1269 "SequencePathModule.cs"
                            int* csharp2cuda_temp_294 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_294));
                        }
                    }
#line 1271 "SequencePathModule.cs"
                    {
#line 1271 "SequencePathModule.cs"
                        int width = 1;
                        while (true)
                        {
#line 1271 "SequencePathModule.cs"
                            int csharp2cuda_temp_300 = (first)->count;
                            if (!(((width) < (csharp2cuda_temp_300))))
                                break;
#line 1272 "SequencePathModule.cs"
                            {
#line 1273 "SequencePathModule.cs"
                                {
#line 1273 "SequencePathModule.cs"
                                    int start = 0;
                                    while (true)
                                    {
#line 1273 "SequencePathModule.cs"
                                        int csharp2cuda_temp_303 = (first)->count;
                                        if (!(((start) < (csharp2cuda_temp_303))))
                                            break;
#line 1274 "SequencePathModule.cs"
                                        {
#line 1275 "SequencePathModule.cs"
                                            {
#line 1275 "SequencePathModule.cs"
                                                int offset = 0;
                                                while (true)
                                                {
                                                    if (!(((offset) < (width))))
                                                        break;
#line 1276 "SequencePathModule.cs"
                                                    {
#line 1277 "SequencePathModule.cs"
                                                        float left = (result)[csharp2cuda_i32_add(start, offset)];
#line 1278 "SequencePathModule.cs"
                                                        float right = (result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)];
#line 1279 "SequencePathModule.cs"
#line 1279 "SequencePathModule.cs"
                                                        float* csharp2cuda_temp_305 = &((result)[csharp2cuda_i32_add(start, offset)]);
                                                        (*(csharp2cuda_temp_305) = __fadd_rn(left, right));
#line 1280 "SequencePathModule.cs"
#line 1280 "SequencePathModule.cs"
                                                        float* csharp2cuda_temp_306 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)]);
                                                        (*(csharp2cuda_temp_306) = __fsub_rn(left, right));
                                                    }
#line 1275 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_304 = &(offset);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_304));
                                                }
                                            }
                                        }
#line 1273 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_301 = &(start);
#line 1273 "SequencePathModule.cs"
                                        int csharp2cuda_temp_302 = *(csharp2cuda_temp_301);
                                        (*(csharp2cuda_temp_301) = csharp2cuda_i32_add(csharp2cuda_temp_302, csharp2cuda_i32_mul(2, width)));
                                    }
                                }
                            }
#line 1271 "SequencePathModule.cs"
                            int* csharp2cuda_temp_298 = &(width);
#line 1271 "SequencePathModule.cs"
                            int csharp2cuda_temp_299 = *(csharp2cuda_temp_298);
                            (*(csharp2cuda_temp_298) = csharp2cuda_i32_mul(csharp2cuda_temp_299, 2));
                        }
                    }
#line 1284 "SequencePathModule.cs"
                    int csharp2cuda_temp_307 = (first)->count;
#line 1284 "SequencePathModule.cs"
                    float scale = __fdiv_rn(1.0f, mathblocks_square_root(((float)(csharp2cuda_temp_307))));
#line 1285 "SequencePathModule.cs"
                    {
#line 1285 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1285 "SequencePathModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_309))))
                                break;
#line 1286 "SequencePathModule.cs"
                            {
#line 1287 "SequencePathModule.cs"
#line 1287 "SequencePathModule.cs"
                                float* csharp2cuda_temp_310 = &((result)[index]);
#line 1287 "SequencePathModule.cs"
                                float csharp2cuda_temp_311 = *(csharp2cuda_temp_310);
                                (*(csharp2cuda_temp_310) = __fmul_rn(csharp2cuda_temp_311, scale));
#line 1288 "SequencePathModule.cs"
#line 1288 "SequencePathModule.cs"
                                float csharp2cuda_temp_312 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_312))))
                                {
#line 1288 "SequencePathModule.cs"
#line 1288 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_313 = &((output)->valid);
                                    (*(csharp2cuda_temp_313) = 0);
                                }
                            }
#line 1285 "SequencePathModule.cs"
                            int* csharp2cuda_temp_308 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
                }
            }
#line 1292 "SequencePathModule.cs"
            break;
#line 1293 "SequencePathModule.cs"
        case 13:
#line 1294 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1295 "SequencePathModule.cs"
            {
#line 1296 "SequencePathModule.cs"
#line 1296 "SequencePathModule.cs"
                int csharp2cuda_temp_314 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_314);
#line 1297 "SequencePathModule.cs"
                float sum = 0.0f;
#line 1298 "SequencePathModule.cs"
                {
#line 1298 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 1298 "SequencePathModule.cs"
                        int csharp2cuda_temp_316 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_316))))
                            break;
#line 1299 "SequencePathModule.cs"
                        {
#line 1300 "SequencePathModule.cs"
#line 1300 "SequencePathModule.cs"
                            float* csharp2cuda_temp_317 = &(sum);
#line 1300 "SequencePathModule.cs"
                            float csharp2cuda_temp_318 = *(csharp2cuda_temp_317);
#line 1300 "SequencePathModule.cs"
                            float csharp2cuda_temp_319 = (a)[index];
#line 1300 "SequencePathModule.cs"
                            float csharp2cuda_temp_320 = (second)->scalar_value;
                            (*(csharp2cuda_temp_317) = __fadd_rn(csharp2cuda_temp_318, __fsub_rn(csharp2cuda_temp_319, csharp2cuda_temp_320)));
#line 1301 "SequencePathModule.cs"
#line 1301 "SequencePathModule.cs"
                            float* csharp2cuda_temp_321 = &((result)[index]);
                            (*(csharp2cuda_temp_321) = sum);
#line 1302 "SequencePathModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 1303 "SequencePathModule.cs"
#line 1303 "SequencePathModule.cs"
                                int* csharp2cuda_temp_322 = &((output)->valid);
                                (*(csharp2cuda_temp_322) = 0);
                            }
                        }
#line 1298 "SequencePathModule.cs"
                        int* csharp2cuda_temp_315 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_315));
                    }
                }
            }
#line 1306 "SequencePathModule.cs"
            break;
#line 1307 "SequencePathModule.cs"
        case 14:
#line 1308 "SequencePathModule.cs"
            {
#line 1309 "SequencePathModule.cs"
                int rows_count = (first)->count;
#line 1310 "SequencePathModule.cs"
                int columns_count = (second)->count;
#line 1311 "SequencePathModule.cs"
#line 1311 "SequencePathModule.cs"
                bool csharp2cuda_temp_323;
#line 1311 "SequencePathModule.cs"
                if (!(((rows_count) <= (0))))
                {
#line 1311 "SequencePathModule.cs"
                    csharp2cuda_temp_323 = ((columns_count) <= (0));
                }
                else
                {
#line 1311 "SequencePathModule.cs"
                    csharp2cuda_temp_323 = true;
                }
#line 1311 "SequencePathModule.cs"
                bool csharp2cuda_temp_324;
#line 1311 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_323))
                {
#line 1311 "SequencePathModule.cs"
                    csharp2cuda_temp_324 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1311 "SequencePathModule.cs"
                    csharp2cuda_temp_324 = true;
                }
                if (csharp2cuda_temp_324)
#line 1312 "SequencePathModule.cs"
                {
#line 1313 "SequencePathModule.cs"
                    __syncthreads();
#line 1314 "SequencePathModule.cs"
                    if (((thread) == (0)))
                    {
#line 1315 "SequencePathModule.cs"
#line 1315 "SequencePathModule.cs"
                        int* csharp2cuda_temp_325 = &((output)->valid);
                        (*(csharp2cuda_temp_325) = 0);
                    }
#line 1316 "SequencePathModule.cs"
                    break;
                }
#line 1319 "SequencePathModule.cs"
                float* diagonal_even = scratch;
#line 1320 "SequencePathModule.cs"
                float* diagonal_odd = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_add(columns_count, 1));
#line 1321 "SequencePathModule.cs"
                {
#line 1321 "SequencePathModule.cs"
                    int diagonal = 2;
                    while (true)
                    {
                        if (!(((diagonal) <= (csharp2cuda_i32_add(rows_count, columns_count)))))
                            break;
#line 1322 "SequencePathModule.cs"
                        {
#line 1323 "SequencePathModule.cs"
                            float* csharp2cuda_temp_327;
#line 1323 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_and(diagonal, 1)) == (0)))
                            {
#line 1323 "SequencePathModule.cs"
                                csharp2cuda_temp_327 = diagonal_even;
                            }
                            else
                            {
#line 1323 "SequencePathModule.cs"
                                csharp2cuda_temp_327 = diagonal_odd;
                            }
#line 1323 "SequencePathModule.cs"
                            float* older = csharp2cuda_temp_327;
#line 1324 "SequencePathModule.cs"
                            float* csharp2cuda_temp_328;
#line 1324 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_and(diagonal, 1)) == (0)))
                            {
#line 1324 "SequencePathModule.cs"
                                csharp2cuda_temp_328 = diagonal_odd;
                            }
                            else
                            {
#line 1324 "SequencePathModule.cs"
                                csharp2cuda_temp_328 = diagonal_even;
                            }
#line 1324 "SequencePathModule.cs"
                            float* newer = csharp2cuda_temp_328;
#line 1325 "SequencePathModule.cs"
                            int csharp2cuda_temp_329;
#line 1325 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_sub(diagonal, rows_count)) > (1)))
                            {
#line 1325 "SequencePathModule.cs"
                                csharp2cuda_temp_329 = csharp2cuda_i32_sub(diagonal, rows_count);
                            }
                            else
                            {
#line 1325 "SequencePathModule.cs"
                                csharp2cuda_temp_329 = 1;
                            }
#line 1325 "SequencePathModule.cs"
                            int low = csharp2cuda_temp_329;
#line 1326 "SequencePathModule.cs"
                            int csharp2cuda_temp_330;
#line 1326 "SequencePathModule.cs"
                            if (((columns_count) < (csharp2cuda_i32_sub(diagonal, 1))))
                            {
#line 1326 "SequencePathModule.cs"
                                csharp2cuda_temp_330 = columns_count;
                            }
                            else
                            {
#line 1326 "SequencePathModule.cs"
                                csharp2cuda_temp_330 = csharp2cuda_i32_sub(diagonal, 1);
                            }
#line 1326 "SequencePathModule.cs"
                            int high = csharp2cuda_temp_330;
#line 1327 "SequencePathModule.cs"
                            {
#line 1327 "SequencePathModule.cs"
                                int top = high;
                                while (true)
                                {
                                    if (!(((top) >= (low))))
                                        break;
#line 1328 "SequencePathModule.cs"
                                    {
#line 1329 "SequencePathModule.cs"
                                        int right = csharp2cuda_i32_sub(top, thread);
#line 1330 "SequencePathModule.cs"
                                        bool active = ((right) >= (low));
#line 1331 "SequencePathModule.cs"
                                        float value = 0.0f;
#line 1332 "SequencePathModule.cs"
                                        if (active)
#line 1333 "SequencePathModule.cs"
                                        {
#line 1334 "SequencePathModule.cs"
                                            int left = csharp2cuda_i32_sub(diagonal, right);
#line 1335 "SequencePathModule.cs"
                                            float csharp2cuda_temp_333;
#line 1335 "SequencePathModule.cs"
                                            if (((left) == (1)))
                                            {
#line 1335 "SequencePathModule.cs"
                                                csharp2cuda_temp_333 = mathblocks_positive_infinity();
                                            }
                                            else
                                            {
#line 1335 "SequencePathModule.cs"
                                                csharp2cuda_temp_333 = (newer)[right];
                                            }
#line 1335 "SequencePathModule.cs"
                                            float above = csharp2cuda_temp_333;
#line 1336 "SequencePathModule.cs"
                                            float csharp2cuda_temp_334;
#line 1336 "SequencePathModule.cs"
                                            if (((right) == (1)))
                                            {
#line 1336 "SequencePathModule.cs"
                                                csharp2cuda_temp_334 = mathblocks_positive_infinity();
                                            }
                                            else
                                            {
#line 1336 "SequencePathModule.cs"
                                                csharp2cuda_temp_334 = (newer)[csharp2cuda_i32_sub(right, 1)];
                                            }
#line 1336 "SequencePathModule.cs"
                                            float before = csharp2cuda_temp_334;
#line 1337 "SequencePathModule.cs"
                                            bool csharp2cuda_temp_335;
#line 1337 "SequencePathModule.cs"
                                            if (!(((left) == (1))))
                                            {
#line 1337 "SequencePathModule.cs"
                                                csharp2cuda_temp_335 = ((right) == (1));
                                            }
                                            else
                                            {
#line 1337 "SequencePathModule.cs"
                                                csharp2cuda_temp_335 = true;
                                            }
#line 1337 "SequencePathModule.cs"
                                            float csharp2cuda_temp_336;
#line 1337 "SequencePathModule.cs"
                                            if (csharp2cuda_temp_335)
                                            {
#line 1338 "SequencePathModule.cs"
                                                bool csharp2cuda_temp_337;
#line 1338 "SequencePathModule.cs"
                                                if (((left) == (1)))
                                                {
#line 1338 "SequencePathModule.cs"
                                                    csharp2cuda_temp_337 = ((right) == (1));
                                                }
                                                else
                                                {
#line 1338 "SequencePathModule.cs"
                                                    csharp2cuda_temp_337 = false;
                                                }
#line 1338 "SequencePathModule.cs"
                                                float csharp2cuda_temp_338;
#line 1338 "SequencePathModule.cs"
                                                if (csharp2cuda_temp_337)
                                                {
#line 1338 "SequencePathModule.cs"
                                                    csharp2cuda_temp_338 = 0.0f;
                                                }
                                                else
                                                {
#line 1338 "SequencePathModule.cs"
                                                    csharp2cuda_temp_338 = mathblocks_positive_infinity();
                                                }
#line 1337 "SequencePathModule.cs"
                                                csharp2cuda_temp_336 = csharp2cuda_temp_338;
                                            }
                                            else
                                            {
#line 1337 "SequencePathModule.cs"
                                                csharp2cuda_temp_336 = (older)[csharp2cuda_i32_sub(right, 1)];
                                            }
#line 1337 "SequencePathModule.cs"
                                            float corner = csharp2cuda_temp_336;
#line 1340 "SequencePathModule.cs"
                                            float csharp2cuda_temp_339;
#line 1340 "SequencePathModule.cs"
                                            if (((above) < (before)))
                                            {
#line 1340 "SequencePathModule.cs"
                                                csharp2cuda_temp_339 = above;
                                            }
                                            else
                                            {
#line 1340 "SequencePathModule.cs"
                                                csharp2cuda_temp_339 = before;
                                            }
#line 1340 "SequencePathModule.cs"
                                            float minimum = csharp2cuda_temp_339;
#line 1341 "SequencePathModule.cs"
#line 1341 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_340 = &(minimum);
#line 1341 "SequencePathModule.cs"
                                            float csharp2cuda_temp_341;
#line 1341 "SequencePathModule.cs"
                                            if (((minimum) < (corner)))
                                            {
#line 1341 "SequencePathModule.cs"
                                                csharp2cuda_temp_341 = minimum;
                                            }
                                            else
                                            {
#line 1341 "SequencePathModule.cs"
                                                csharp2cuda_temp_341 = corner;
                                            }
                                            (*(csharp2cuda_temp_340) = csharp2cuda_temp_341);
#line 1342 "SequencePathModule.cs"
#line 1342 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_342 = &(value);
#line 1342 "SequencePathModule.cs"
                                            float csharp2cuda_temp_343 = (a)[csharp2cuda_i32_sub(left, 1)];
#line 1342 "SequencePathModule.cs"
                                            float csharp2cuda_temp_344 = (b)[csharp2cuda_i32_sub(right, 1)];
                                            (*(csharp2cuda_temp_342) = __fadd_rn(fabsf(__fsub_rn(csharp2cuda_temp_343, csharp2cuda_temp_344)), minimum));
                                        }
#line 1344 "SequencePathModule.cs"
                                        __syncthreads();
#line 1345 "SequencePathModule.cs"
                                        if (active)
                                        {
#line 1346 "SequencePathModule.cs"
#line 1346 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_345 = &((older)[right]);
                                            (*(csharp2cuda_temp_345) = value);
                                        }
#line 1347 "SequencePathModule.cs"
                                        __syncthreads();
                                    }
#line 1327 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_331 = &(top);
#line 1327 "SequencePathModule.cs"
                                    int csharp2cuda_temp_332 = *(csharp2cuda_temp_331);
                                    (*(csharp2cuda_temp_331) = csharp2cuda_i32_sub(csharp2cuda_temp_332, blockDim.x));
                                }
                            }
                        }
#line 1321 "SequencePathModule.cs"
                        int* csharp2cuda_temp_326 = &(diagonal);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_326));
                    }
                }
#line 1351 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 1352 "SequencePathModule.cs"
                {
#line 1353 "SequencePathModule.cs"
                    float* csharp2cuda_temp_346;
#line 1353 "SequencePathModule.cs"
                    if (((csharp2cuda_i32_and(csharp2cuda_i32_add(rows_count, columns_count), 1)) == (0)))
                    {
#line 1353 "SequencePathModule.cs"
                        csharp2cuda_temp_346 = diagonal_even;
                    }
                    else
                    {
#line 1353 "SequencePathModule.cs"
                        csharp2cuda_temp_346 = diagonal_odd;
                    }
#line 1353 "SequencePathModule.cs"
                    float* last = csharp2cuda_temp_346;
#line 1354 "SequencePathModule.cs"
#line 1354 "SequencePathModule.cs"
                    float* csharp2cuda_temp_347 = &((output)->scalar_value);
#line 1354 "SequencePathModule.cs"
                    float csharp2cuda_temp_348 = (last)[columns_count];
                    (*(csharp2cuda_temp_347) = csharp2cuda_temp_348);
#line 1355 "SequencePathModule.cs"
#line 1355 "SequencePathModule.cs"
                    float csharp2cuda_temp_349 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_349))))
                    {
#line 1356 "SequencePathModule.cs"
#line 1356 "SequencePathModule.cs"
                        int* csharp2cuda_temp_350 = &((output)->valid);
                        (*(csharp2cuda_temp_350) = 0);
                    }
                }
            }
#line 1359 "SequencePathModule.cs"
            break;
#line 1360 "SequencePathModule.cs"
        case 15:
#line 1361 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1362 "SequencePathModule.cs"
            {
#line 1363 "SequencePathModule.cs"
#line 1363 "SequencePathModule.cs"
                float* csharp2cuda_temp_351 = &((output)->scalar_value);
#line 1365 "SequencePathModule.cs"
                int csharp2cuda_temp_352 = (first)->count;
#line 1366 "SequencePathModule.cs"
                float csharp2cuda_temp_353 = (second)->scalar_value;
#line 1367 "SequencePathModule.cs"
                int csharp2cuda_temp_354 = (third)->boolean_value;
#line 1363 "SequencePathModule.cs"
                float csharp2cuda_temp_355 = mathblocks_sequence_first_passage_value(a, csharp2cuda_temp_352, csharp2cuda_temp_353, ((csharp2cuda_temp_354) != (0)));
                (*(csharp2cuda_temp_351) = csharp2cuda_temp_355);
            }
#line 1369 "SequencePathModule.cs"
            break;
#line 1370 "SequencePathModule.cs"
        case 16:
#line 1371 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1372 "SequencePathModule.cs"
            {
#line 1373 "SequencePathModule.cs"
                float lower = (second)->scalar_value;
#line 1374 "SequencePathModule.cs"
                float upper = (third)->scalar_value;
#line 1375 "SequencePathModule.cs"
#line 1375 "SequencePathModule.cs"
                int csharp2cuda_temp_356 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_356);
#line 1376 "SequencePathModule.cs"
                if ((!(((lower) < (upper)))))
#line 1377 "SequencePathModule.cs"
                {
#line 1378 "SequencePathModule.cs"
#line 1378 "SequencePathModule.cs"
                    int* csharp2cuda_temp_357 = &((output)->valid);
                    (*(csharp2cuda_temp_357) = 0);
                }
                else
#line 1381 "SequencePathModule.cs"
                {
#line 1382 "SequencePathModule.cs"
                    float state = 0.0f;
#line 1383 "SequencePathModule.cs"
                    {
#line 1383 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1383 "SequencePathModule.cs"
                            int csharp2cuda_temp_359 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_359))))
                                break;
#line 1384 "SequencePathModule.cs"
                            {
#line 1385 "SequencePathModule.cs"
#line 1385 "SequencePathModule.cs"
                                float csharp2cuda_temp_360 = (a)[index];
                                if (((csharp2cuda_temp_360) >= (upper)))
                                {
#line 1386 "SequencePathModule.cs"
#line 1386 "SequencePathModule.cs"
                                    float* csharp2cuda_temp_361 = &(state);
                                    (*(csharp2cuda_temp_361) = 1.0f);
                                }
                                else
                                {
#line 1387 "SequencePathModule.cs"
#line 1387 "SequencePathModule.cs"
                                    float csharp2cuda_temp_362 = (a)[index];
                                    if (((csharp2cuda_temp_362) <= (lower)))
                                    {
#line 1388 "SequencePathModule.cs"
#line 1388 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_363 = &(state);
                                        (*(csharp2cuda_temp_363) = (-(1.0f)));
                                    }
                                }
#line 1389 "SequencePathModule.cs"
#line 1389 "SequencePathModule.cs"
                                float* csharp2cuda_temp_364 = &((result)[index]);
                                (*(csharp2cuda_temp_364) = state);
                            }
#line 1383 "SequencePathModule.cs"
                            int* csharp2cuda_temp_358 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_358));
                        }
                    }
                }
            }
#line 1393 "SequencePathModule.cs"
            break;
#line 1394 "SequencePathModule.cs"
        case 17:
#line 1395 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1396 "SequencePathModule.cs"
            {
#line 1397 "SequencePathModule.cs"
                int csharp2cuda_temp_365 = (first)->count;
#line 1397 "SequencePathModule.cs"
                int csharp2cuda_temp_366;
#line 1397 "SequencePathModule.cs"
                if (((csharp2cuda_temp_365) == (0)))
                {
#line 1397 "SequencePathModule.cs"
                    csharp2cuda_temp_366 = 0;
                }
                else
                {
#line 1397 "SequencePathModule.cs"
                    int csharp2cuda_temp_367 = (first)->count;
#line 1397 "SequencePathModule.cs"
                    csharp2cuda_temp_366 = csharp2cuda_i32_sub(csharp2cuda_i32_mul(2, csharp2cuda_temp_367), 1);
                }
#line 1397 "SequencePathModule.cs"
                int rows = csharp2cuda_temp_366;
#line 1398 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, rows, 2);
#line 1399 "SequencePathModule.cs"
#line 1399 "SequencePathModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
                if (((csharp2cuda_temp_368) <= (0)))
#line 1400 "SequencePathModule.cs"
                {
#line 1401 "SequencePathModule.cs"
#line 1401 "SequencePathModule.cs"
                    int* csharp2cuda_temp_369 = &((output)->valid);
                    (*(csharp2cuda_temp_369) = 0);
                }
                else
#line 1404 "SequencePathModule.cs"
                {
#line 1405 "SequencePathModule.cs"
#line 1405 "SequencePathModule.cs"
                    float* csharp2cuda_temp_370 = &((result)[0]);
#line 1405 "SequencePathModule.cs"
                    float csharp2cuda_temp_371 = (a)[0];
                    (*(csharp2cuda_temp_370) = csharp2cuda_temp_371);
#line 1406 "SequencePathModule.cs"
#line 1406 "SequencePathModule.cs"
                    float* csharp2cuda_temp_372 = &((result)[1]);
#line 1406 "SequencePathModule.cs"
                    float csharp2cuda_temp_373 = (a)[0];
                    (*(csharp2cuda_temp_372) = csharp2cuda_temp_373);
#line 1407 "SequencePathModule.cs"
                    int row = 0;
#line 1408 "SequencePathModule.cs"
                    {
#line 1408 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1408 "SequencePathModule.cs"
                            int csharp2cuda_temp_375 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_375))))
                                break;
#line 1409 "SequencePathModule.cs"
                            {
#line 1410 "SequencePathModule.cs"
#line 1410 "SequencePathModule.cs"
                                int* csharp2cuda_temp_376 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
#line 1411 "SequencePathModule.cs"
#line 1411 "SequencePathModule.cs"
                                float* csharp2cuda_temp_377 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1411 "SequencePathModule.cs"
                                float csharp2cuda_temp_378 = (a)[index];
                                (*(csharp2cuda_temp_377) = csharp2cuda_temp_378);
#line 1412 "SequencePathModule.cs"
#line 1412 "SequencePathModule.cs"
                                float* csharp2cuda_temp_379 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1412 "SequencePathModule.cs"
                                float csharp2cuda_temp_380 = (a)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_379) = csharp2cuda_temp_380);
#line 1413 "SequencePathModule.cs"
#line 1413 "SequencePathModule.cs"
                                int* csharp2cuda_temp_381 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_381));
#line 1414 "SequencePathModule.cs"
#line 1414 "SequencePathModule.cs"
                                float* csharp2cuda_temp_382 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1414 "SequencePathModule.cs"
                                float csharp2cuda_temp_383 = (a)[index];
                                (*(csharp2cuda_temp_382) = csharp2cuda_temp_383);
#line 1415 "SequencePathModule.cs"
#line 1415 "SequencePathModule.cs"
                                float* csharp2cuda_temp_384 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1415 "SequencePathModule.cs"
                                float csharp2cuda_temp_385 = (a)[index];
                                (*(csharp2cuda_temp_384) = csharp2cuda_temp_385);
                            }
#line 1408 "SequencePathModule.cs"
                            int* csharp2cuda_temp_374 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_374));
                        }
                    }
                }
            }
#line 1419 "SequencePathModule.cs"
            break;
#line 1420 "SequencePathModule.cs"
        case 18:
#line 1421 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1422 "SequencePathModule.cs"
#line 1422 "SequencePathModule.cs"
                float* csharp2cuda_temp_386 = &((output)->scalar_value);
#line 1422 "SequencePathModule.cs"
                int csharp2cuda_temp_387 = (first)->count;
#line 1422 "SequencePathModule.cs"
                float csharp2cuda_temp_388 = mathblocks_sequence_longest_run_value(boolean_a, csharp2cuda_temp_387);
                (*(csharp2cuda_temp_386) = csharp2cuda_temp_388);
            }
#line 1423 "SequencePathModule.cs"
            break;
#line 1424 "SequencePathModule.cs"
        case 19:
        case 20:
#line 1426 "SequencePathModule.cs"
#line 1426 "SequencePathModule.cs"
            bool csharp2cuda_temp_389;
#line 1426 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1427 "SequencePathModule.cs"
                int csharp2cuda_temp_390 = (first)->count;
#line 1427 "SequencePathModule.cs"
                float* csharp2cuda_temp_391 = &((output)->scalar_value);
#line 1427 "SequencePathModule.cs"
                bool csharp2cuda_temp_392 = mathblocks_sequence_decline_value(a, csharp2cuda_temp_390, ((opcode) == (20)), csharp2cuda_temp_391);
#line 1426 "SequencePathModule.cs"
                csharp2cuda_temp_389 = (!(csharp2cuda_temp_392));
            }
            else
            {
#line 1426 "SequencePathModule.cs"
                csharp2cuda_temp_389 = false;
            }
            if (csharp2cuda_temp_389)
            {
#line 1428 "SequencePathModule.cs"
#line 1428 "SequencePathModule.cs"
                int* csharp2cuda_temp_393 = &((output)->valid);
                (*(csharp2cuda_temp_393) = 0);
            }
#line 1429 "SequencePathModule.cs"
            break;
#line 1430 "SequencePathModule.cs"
        case 21:
        case 22:
        case 29:
#line 1433 "SequencePathModule.cs"
#line 1433 "SequencePathModule.cs"
            bool csharp2cuda_temp_394;
#line 1433 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1436 "SequencePathModule.cs"
                int csharp2cuda_temp_395 = (first)->count;
#line 1437 "SequencePathModule.cs"
                float csharp2cuda_temp_396;
#line 1437 "SequencePathModule.cs"
                if (((opcode) == (22)))
                {
#line 1437 "SequencePathModule.cs"
                    csharp2cuda_temp_396 = 2.0f;
                }
                else
                {
#line 1437 "SequencePathModule.cs"
                    float csharp2cuda_temp_397;
#line 1437 "SequencePathModule.cs"
                    if (((((void*)(second))) == (((void*)(nullptr)))))
                    {
#line 1437 "SequencePathModule.cs"
                        csharp2cuda_temp_397 = 1.0f;
                    }
                    else
                    {
#line 1437 "SequencePathModule.cs"
                        csharp2cuda_temp_397 = (second)->scalar_value;
                    }
#line 1437 "SequencePathModule.cs"
                    csharp2cuda_temp_396 = csharp2cuda_temp_397;
                }
#line 1439 "SequencePathModule.cs"
                float* csharp2cuda_temp_398 = &((output)->scalar_value);
#line 1434 "SequencePathModule.cs"
                bool csharp2cuda_temp_399 = mathblocks_sequence_variation_value(a, csharp2cuda_temp_395, csharp2cuda_temp_396, ((opcode) == (29)), csharp2cuda_temp_398);
#line 1433 "SequencePathModule.cs"
                csharp2cuda_temp_394 = (!(csharp2cuda_temp_399));
            }
            else
            {
#line 1433 "SequencePathModule.cs"
                csharp2cuda_temp_394 = false;
            }
            if (csharp2cuda_temp_394)
            {
#line 1440 "SequencePathModule.cs"
#line 1440 "SequencePathModule.cs"
                int* csharp2cuda_temp_400 = &((output)->valid);
                (*(csharp2cuda_temp_400) = 0);
            }
#line 1441 "SequencePathModule.cs"
            break;
#line 1442 "SequencePathModule.cs"
        case 23:
#line 1443 "SequencePathModule.cs"
#line 1443 "SequencePathModule.cs"
            bool csharp2cuda_temp_401;
#line 1443 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1446 "SequencePathModule.cs"
                int csharp2cuda_temp_402 = (first)->count;
#line 1447 "SequencePathModule.cs"
                float csharp2cuda_temp_403 = (second)->scalar_value;
#line 1448 "SequencePathModule.cs"
                float* csharp2cuda_temp_404 = &((output)->scalar_value);
#line 1444 "SequencePathModule.cs"
                bool csharp2cuda_temp_405 = mathblocks_sequence_recurrence_value(a, csharp2cuda_temp_402, csharp2cuda_temp_403, csharp2cuda_temp_404);
#line 1443 "SequencePathModule.cs"
                csharp2cuda_temp_401 = (!(csharp2cuda_temp_405));
            }
            else
            {
#line 1443 "SequencePathModule.cs"
                csharp2cuda_temp_401 = false;
            }
            if (csharp2cuda_temp_401)
            {
#line 1449 "SequencePathModule.cs"
#line 1449 "SequencePathModule.cs"
                int* csharp2cuda_temp_406 = &((output)->valid);
                (*(csharp2cuda_temp_406) = 0);
            }
#line 1450 "SequencePathModule.cs"
            break;
#line 1451 "SequencePathModule.cs"
        case 24:
#line 1452 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1453 "SequencePathModule.cs"
            {
#line 1454 "SequencePathModule.cs"
#line 1454 "SequencePathModule.cs"
                int csharp2cuda_temp_407 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_407);
#line 1455 "SequencePathModule.cs"
#line 1455 "SequencePathModule.cs"
                int csharp2cuda_temp_408 = (first)->count;
                if (((csharp2cuda_temp_408) <= (0)))
#line 1456 "SequencePathModule.cs"
                {
#line 1457 "SequencePathModule.cs"
#line 1457 "SequencePathModule.cs"
                    int* csharp2cuda_temp_409 = &((output)->valid);
                    (*(csharp2cuda_temp_409) = 0);
                }
                else
#line 1460 "SequencePathModule.cs"
                {
#line 1461 "SequencePathModule.cs"
                    float cumulative = 0.0f;
#line 1462 "SequencePathModule.cs"
                    float minimum = 0.0f;
#line 1463 "SequencePathModule.cs"
                    {
#line 1463 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1463 "SequencePathModule.cs"
                            int csharp2cuda_temp_411 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_411))))
                                break;
#line 1464 "SequencePathModule.cs"
                            {
#line 1465 "SequencePathModule.cs"
#line 1465 "SequencePathModule.cs"
                                float* csharp2cuda_temp_412 = &(cumulative);
#line 1465 "SequencePathModule.cs"
                                float csharp2cuda_temp_413 = *(csharp2cuda_temp_412);
#line 1465 "SequencePathModule.cs"
                                float csharp2cuda_temp_414 = (a)[index];
                                (*(csharp2cuda_temp_412) = __fadd_rn(csharp2cuda_temp_413, csharp2cuda_temp_414));
#line 1466 "SequencePathModule.cs"
#line 1466 "SequencePathModule.cs"
                                float* csharp2cuda_temp_415 = &(minimum);
#line 1466 "SequencePathModule.cs"
                                float csharp2cuda_temp_416;
#line 1466 "SequencePathModule.cs"
                                if (((minimum) < (cumulative)))
                                {
#line 1466 "SequencePathModule.cs"
                                    csharp2cuda_temp_416 = minimum;
                                }
                                else
                                {
#line 1466 "SequencePathModule.cs"
                                    csharp2cuda_temp_416 = cumulative;
                                }
                                (*(csharp2cuda_temp_415) = csharp2cuda_temp_416);
#line 1467 "SequencePathModule.cs"
#line 1467 "SequencePathModule.cs"
                                float* csharp2cuda_temp_417 = &((result)[index]);
                                (*(csharp2cuda_temp_417) = __fsub_rn(cumulative, minimum));
#line 1468 "SequencePathModule.cs"
#line 1468 "SequencePathModule.cs"
                                float csharp2cuda_temp_418 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_418))))
                                {
#line 1469 "SequencePathModule.cs"
#line 1469 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_419 = &((output)->valid);
                                    (*(csharp2cuda_temp_419) = 0);
                                }
                            }
#line 1463 "SequencePathModule.cs"
                            int* csharp2cuda_temp_410 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_410));
                        }
                    }
                }
            }
#line 1473 "SequencePathModule.cs"
            break;
#line 1474 "SequencePathModule.cs"
        case 25:
#line 1475 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1476 "SequencePathModule.cs"
            {
#line 1477 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_420 = (output)->data_pointer;
#line 1477 "SequencePathModule.cs"
                MathBlockSequencePathRun* runs = ((MathBlockSequencePathRun*)(csharp2cuda_temp_420));
#line 1478 "SequencePathModule.cs"
#line 1478 "SequencePathModule.cs"
                int csharp2cuda_temp_421 = (first)->count;
                if (((csharp2cuda_temp_421) == (0)))
#line 1479 "SequencePathModule.cs"
                {
#line 1480 "SequencePathModule.cs"
#line 1480 "SequencePathModule.cs"
                    int* csharp2cuda_temp_422 = &((output)->count);
                    (*(csharp2cuda_temp_422) = 0);
#line 1481 "SequencePathModule.cs"
#line 1481 "SequencePathModule.cs"
                    int* csharp2cuda_temp_423 = &((output)->rows);
                    (*(csharp2cuda_temp_423) = 0);
                }
                else
#line 1484 "SequencePathModule.cs"
                {
#line 1485 "SequencePathModule.cs"
                    int start = 0;
#line 1486 "SequencePathModule.cs"
                    int count = 0;
#line 1487 "SequencePathModule.cs"
                    {
#line 1487 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1487 "SequencePathModule.cs"
                            int csharp2cuda_temp_425 = (first)->count;
                            if (!(((index) <= (csharp2cuda_temp_425))))
                                break;
#line 1488 "SequencePathModule.cs"
                            {
#line 1489 "SequencePathModule.cs"
#line 1489 "SequencePathModule.cs"
                                int csharp2cuda_temp_426 = (first)->count;
#line 1489 "SequencePathModule.cs"
                                bool csharp2cuda_temp_427;
#line 1489 "SequencePathModule.cs"
                                if (((index) < (csharp2cuda_temp_426)))
                                {
#line 1489 "SequencePathModule.cs"
                                    float csharp2cuda_temp_428 = (a)[index];
#line 1489 "SequencePathModule.cs"
                                    float csharp2cuda_temp_429 = (a)[start];
#line 1489 "SequencePathModule.cs"
                                    csharp2cuda_temp_427 = ((csharp2cuda_temp_428) == (csharp2cuda_temp_429));
                                }
                                else
                                {
#line 1489 "SequencePathModule.cs"
                                    csharp2cuda_temp_427 = false;
                                }
                                if (csharp2cuda_temp_427)
                                {
#line 1490 "SequencePathModule.cs"
                                    goto csharp2cuda_for_continue_34;
                                }
#line 1491 "SequencePathModule.cs"
#line 1491 "SequencePathModule.cs"
                                int csharp2cuda_temp_430 = (output)->capacity;
                                if (((count) >= (csharp2cuda_temp_430)))
#line 1492 "SequencePathModule.cs"
                                {
#line 1493 "SequencePathModule.cs"
#line 1493 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_431 = &((output)->count);
#line 1493 "SequencePathModule.cs"
                                    int csharp2cuda_temp_432 = (output)->capacity;
#line 1493 "SequencePathModule.cs"
                                    int csharp2cuda_temp_433;
#line 1493 "SequencePathModule.cs"
                                    if (((csharp2cuda_temp_432) == (2147483647)))
                                    {
#line 1493 "SequencePathModule.cs"
                                        csharp2cuda_temp_433 = csharp2cuda_i32_neg(1);
                                    }
                                    else
                                    {
#line 1495 "SequencePathModule.cs"
                                        int csharp2cuda_temp_434 = (output)->capacity;
#line 1493 "SequencePathModule.cs"
                                        csharp2cuda_temp_433 = csharp2cuda_i32_add(csharp2cuda_temp_434, 1);
                                    }
                                    (*(csharp2cuda_temp_431) = csharp2cuda_temp_433);
#line 1496 "SequencePathModule.cs"
#line 1496 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_435 = &((output)->rows);
#line 1496 "SequencePathModule.cs"
                                    int csharp2cuda_temp_436 = (output)->count;
                                    (*(csharp2cuda_temp_435) = csharp2cuda_temp_436);
#line 1497 "SequencePathModule.cs"
#line 1497 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_437 = &((output)->valid);
                                    (*(csharp2cuda_temp_437) = 0);
#line 1498 "SequencePathModule.cs"
                                    break;
                                }
#line 1500 "SequencePathModule.cs"
#line 1500 "SequencePathModule.cs"
                                int* csharp2cuda_temp_438 = &(((runs)[count]).start);
                                (*(csharp2cuda_temp_438) = start);
#line 1501 "SequencePathModule.cs"
#line 1501 "SequencePathModule.cs"
                                int* csharp2cuda_temp_439 = &(((runs)[count]).length);
                                (*(csharp2cuda_temp_439) = csharp2cuda_i32_sub(index, start));
#line 1502 "SequencePathModule.cs"
#line 1502 "SequencePathModule.cs"
                                float* csharp2cuda_temp_440 = &(((runs)[count]).value);
#line 1502 "SequencePathModule.cs"
                                float csharp2cuda_temp_441 = (a)[start];
                                (*(csharp2cuda_temp_440) = csharp2cuda_temp_441);
#line 1503 "SequencePathModule.cs"
#line 1503 "SequencePathModule.cs"
                                int* csharp2cuda_temp_442 = &(count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_442));
#line 1504 "SequencePathModule.cs"
#line 1504 "SequencePathModule.cs"
                                int* csharp2cuda_temp_443 = &(start);
                                (*(csharp2cuda_temp_443) = index);
                            }
                            csharp2cuda_for_continue_34:
#line 1487 "SequencePathModule.cs"
                            int* csharp2cuda_temp_424 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_424));
                        }
                    }
#line 1506 "SequencePathModule.cs"
                    if ((output)->valid)
#line 1507 "SequencePathModule.cs"
                    {
#line 1508 "SequencePathModule.cs"
#line 1508 "SequencePathModule.cs"
                        int* csharp2cuda_temp_444 = &((output)->count);
                        (*(csharp2cuda_temp_444) = count);
#line 1509 "SequencePathModule.cs"
#line 1509 "SequencePathModule.cs"
                        int* csharp2cuda_temp_445 = &((output)->rows);
                        (*(csharp2cuda_temp_445) = count);
                    }
                }
            }
#line 1513 "SequencePathModule.cs"
            break;
#line 1514 "SequencePathModule.cs"
        case 26:
#line 1515 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1516 "SequencePathModule.cs"
            {
#line 1517 "SequencePathModule.cs"
#line 1517 "SequencePathModule.cs"
                int csharp2cuda_temp_446 = (first)->columns;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_446);
#line 1518 "SequencePathModule.cs"
#line 1518 "SequencePathModule.cs"
                int csharp2cuda_temp_447 = (first)->rows;
                if (((csharp2cuda_temp_447) <= (0)))
#line 1519 "SequencePathModule.cs"
                {
#line 1520 "SequencePathModule.cs"
#line 1520 "SequencePathModule.cs"
                    int* csharp2cuda_temp_448 = &((output)->valid);
                    (*(csharp2cuda_temp_448) = 0);
                }
                else
#line 1523 "SequencePathModule.cs"
                {
#line 1524 "SequencePathModule.cs"
                    {
#line 1524 "SequencePathModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 1524 "SequencePathModule.cs"
                            int csharp2cuda_temp_450 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_450))))
                                break;
#line 1525 "SequencePathModule.cs"
                            {
#line 1526 "SequencePathModule.cs"
#line 1526 "SequencePathModule.cs"
                                float* csharp2cuda_temp_451 = &((result)[column]);
#line 1526 "SequencePathModule.cs"
                                int csharp2cuda_temp_452 = (first)->rows;
#line 1526 "SequencePathModule.cs"
                                int csharp2cuda_temp_453 = (first)->columns;
#line 1526 "SequencePathModule.cs"
                                float csharp2cuda_temp_454 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(csharp2cuda_temp_452, 1), csharp2cuda_temp_453), column)];
#line 1526 "SequencePathModule.cs"
                                float csharp2cuda_temp_455 = (a)[column];
                                (*(csharp2cuda_temp_451) = __fsub_rn(csharp2cuda_temp_454, csharp2cuda_temp_455));
#line 1527 "SequencePathModule.cs"
#line 1527 "SequencePathModule.cs"
                                float csharp2cuda_temp_456 = (result)[column];
                                if ((!(isfinite(csharp2cuda_temp_456))))
                                {
#line 1527 "SequencePathModule.cs"
#line 1527 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_457 = &((output)->valid);
                                    (*(csharp2cuda_temp_457) = 0);
                                }
                            }
#line 1524 "SequencePathModule.cs"
                            int* csharp2cuda_temp_449 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_449));
                        }
                    }
                }
            }
#line 1531 "SequencePathModule.cs"
            break;
#line 1532 "SequencePathModule.cs"
        case 27:
#line 1533 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1534 "SequencePathModule.cs"
            {
#line 1535 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1536 "SequencePathModule.cs"
                int count = csharp2cuda_i32_mul(csharp2cuda_i32_mul(dimension, dimension), dimension);
#line 1537 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 1538 "SequencePathModule.cs"
#line 1538 "SequencePathModule.cs"
                int csharp2cuda_temp_458 = (first)->rows;
#line 1538 "SequencePathModule.cs"
                bool csharp2cuda_temp_459;
#line 1538 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_458) < (1))))
                {
#line 1538 "SequencePathModule.cs"
                    csharp2cuda_temp_459 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1538 "SequencePathModule.cs"
                    csharp2cuda_temp_459 = true;
                }
                if (csharp2cuda_temp_459)
#line 1539 "SequencePathModule.cs"
                {
#line 1540 "SequencePathModule.cs"
#line 1540 "SequencePathModule.cs"
                    int* csharp2cuda_temp_460 = &((output)->valid);
                    (*(csharp2cuda_temp_460) = 0);
                }
                else
#line 1543 "SequencePathModule.cs"
                {
#line 1544 "SequencePathModule.cs"
                    float* level_one = scratch;
#line 1545 "SequencePathModule.cs"
                    float* level_two = csharp2cuda_pointer_add(scratch, dimension);
#line 1546 "SequencePathModule.cs"
                    float* increment = csharp2cuda_pointer_add(level_two, csharp2cuda_i32_mul(dimension, dimension));
#line 1547 "SequencePathModule.cs"
                    {
#line 1547 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1548 "SequencePathModule.cs"
#line 1548 "SequencePathModule.cs"
                            float* csharp2cuda_temp_462 = &((level_one)[index]);
                            (*(csharp2cuda_temp_462) = 0.0f);
#line 1547 "SequencePathModule.cs"
                            int* csharp2cuda_temp_461 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_461));
                        }
                    }
#line 1549 "SequencePathModule.cs"
                    {
#line 1549 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1550 "SequencePathModule.cs"
#line 1550 "SequencePathModule.cs"
                            float* csharp2cuda_temp_464 = &((level_two)[index]);
                            (*(csharp2cuda_temp_464) = 0.0f);
#line 1549 "SequencePathModule.cs"
                            int* csharp2cuda_temp_463 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_463));
                        }
                    }
#line 1551 "SequencePathModule.cs"
                    {
#line 1551 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1552 "SequencePathModule.cs"
#line 1552 "SequencePathModule.cs"
                            float* csharp2cuda_temp_466 = &((result)[index]);
                            (*(csharp2cuda_temp_466) = 0.0f);
#line 1551 "SequencePathModule.cs"
                            int* csharp2cuda_temp_465 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_465));
                        }
                    }
#line 1553 "SequencePathModule.cs"
                    {
#line 1553 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1553 "SequencePathModule.cs"
                            int csharp2cuda_temp_468 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_468))))
                                break;
#line 1554 "SequencePathModule.cs"
                            {
#line 1555 "SequencePathModule.cs"
                                {
#line 1555 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (dimension))))
                                            break;
#line 1556 "SequencePathModule.cs"
#line 1556 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_470 = &((increment)[index]);
#line 1556 "SequencePathModule.cs"
                                        float csharp2cuda_temp_471 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), index)];
#line 1556 "SequencePathModule.cs"
                                        float csharp2cuda_temp_472 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), index)];
                                        (*(csharp2cuda_temp_470) = __fsub_rn(csharp2cuda_temp_471, csharp2cuda_temp_472));
#line 1555 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_469 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_469));
                                    }
                                }
#line 1557 "SequencePathModule.cs"
                                {
#line 1557 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1558 "SequencePathModule.cs"
                                        {
#line 1559 "SequencePathModule.cs"
                                            {
#line 1559 "SequencePathModule.cs"
                                                int middle = 0;
                                                while (true)
                                                {
                                                    if (!(((middle) < (dimension))))
                                                        break;
#line 1560 "SequencePathModule.cs"
                                                    {
#line 1561 "SequencePathModule.cs"
                                                        {
#line 1561 "SequencePathModule.cs"
                                                            int right = 0;
                                                            while (true)
                                                            {
                                                                if (!(((right) < (dimension))))
                                                                    break;
#line 1562 "SequencePathModule.cs"
                                                                {
#line 1563 "SequencePathModule.cs"
                                                                    int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle), dimension), right);
#line 1564 "SequencePathModule.cs"
#line 1564 "SequencePathModule.cs"
                                                                    float* csharp2cuda_temp_476 = &((result)[target]);
#line 1564 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_477 = *(csharp2cuda_temp_476);
#line 1565 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_478 = (level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)];
#line 1565 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_479 = (increment)[right];
#line 1566 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_480 = (level_one)[left];
#line 1566 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_481 = (increment)[middle];
#line 1566 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_482 = (increment)[right];
#line 1566 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_483 = __fdiv_rn(__fmul_rn(__fmul_rn(csharp2cuda_temp_480, csharp2cuda_temp_481), csharp2cuda_temp_482), 2.0f);
#line 1567 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_484 = (increment)[left];
#line 1567 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_485 = (increment)[middle];
#line 1567 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_486 = (increment)[right];
#line 1567 "SequencePathModule.cs"
                                                                    float csharp2cuda_temp_487 = __fdiv_rn(__fmul_rn(__fmul_rn(csharp2cuda_temp_484, csharp2cuda_temp_485), csharp2cuda_temp_486), 6.0f);
                                                                    (*(csharp2cuda_temp_476) = __fadd_rn(csharp2cuda_temp_477, __fadd_rn(__fadd_rn(__fmul_rn(csharp2cuda_temp_478, csharp2cuda_temp_479), csharp2cuda_temp_483), csharp2cuda_temp_487)));
                                                                }
#line 1561 "SequencePathModule.cs"
                                                                int* csharp2cuda_temp_475 = &(right);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_475));
                                                            }
                                                        }
#line 1569 "SequencePathModule.cs"
#line 1569 "SequencePathModule.cs"
                                                        float* csharp2cuda_temp_488 = &((level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)]);
#line 1569 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_489 = *(csharp2cuda_temp_488);
#line 1570 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_490 = (level_one)[left];
#line 1570 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_491 = (increment)[middle];
#line 1571 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_492 = (increment)[left];
#line 1571 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_493 = (increment)[middle];
#line 1571 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_494 = __fdiv_rn(__fmul_rn(csharp2cuda_temp_492, csharp2cuda_temp_493), 2.0f);
                                                        (*(csharp2cuda_temp_488) = __fadd_rn(csharp2cuda_temp_489, __fadd_rn(__fmul_rn(csharp2cuda_temp_490, csharp2cuda_temp_491), csharp2cuda_temp_494)));
                                                    }
#line 1559 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_474 = &(middle);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_474));
                                                }
                                            }
#line 1573 "SequencePathModule.cs"
#line 1573 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_495 = &((level_one)[left]);
#line 1573 "SequencePathModule.cs"
                                            float csharp2cuda_temp_496 = *(csharp2cuda_temp_495);
#line 1573 "SequencePathModule.cs"
                                            float csharp2cuda_temp_497 = (increment)[left];
                                            (*(csharp2cuda_temp_495) = __fadd_rn(csharp2cuda_temp_496, csharp2cuda_temp_497));
                                        }
#line 1557 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_473 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
                                    }
                                }
                            }
#line 1553 "SequencePathModule.cs"
                            int* csharp2cuda_temp_467 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_467));
                        }
                    }
#line 1576 "SequencePathModule.cs"
                    {
#line 1576 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1577 "SequencePathModule.cs"
#line 1577 "SequencePathModule.cs"
                            float csharp2cuda_temp_499 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_499))))
                            {
#line 1577 "SequencePathModule.cs"
#line 1577 "SequencePathModule.cs"
                                int* csharp2cuda_temp_500 = &((output)->valid);
                                (*(csharp2cuda_temp_500) = 0);
                            }
#line 1576 "SequencePathModule.cs"
                            int* csharp2cuda_temp_498 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_498));
                        }
                    }
                }
            }
#line 1580 "SequencePathModule.cs"
            break;
#line 1581 "SequencePathModule.cs"
        case 28:
#line 1582 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1583 "SequencePathModule.cs"
            {
#line 1584 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1585 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, dimension, dimension);
#line 1586 "SequencePathModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 1587 "SequencePathModule.cs"
                {
#line 1588 "SequencePathModule.cs"
#line 1588 "SequencePathModule.cs"
                    int* csharp2cuda_temp_501 = &((output)->valid);
                    (*(csharp2cuda_temp_501) = 0);
                }
                else
#line 1591 "SequencePathModule.cs"
                {
#line 1592 "SequencePathModule.cs"
                    float* cumulative = scratch;
#line 1593 "SequencePathModule.cs"
                    float* increment = csharp2cuda_pointer_add(scratch, dimension);
#line 1594 "SequencePathModule.cs"
                    {
#line 1594 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1595 "SequencePathModule.cs"
#line 1595 "SequencePathModule.cs"
                            float* csharp2cuda_temp_503 = &((cumulative)[index]);
                            (*(csharp2cuda_temp_503) = 0.0f);
#line 1594 "SequencePathModule.cs"
                            int* csharp2cuda_temp_502 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_502));
                        }
                    }
#line 1596 "SequencePathModule.cs"
                    {
#line 1596 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1597 "SequencePathModule.cs"
#line 1597 "SequencePathModule.cs"
                            float* csharp2cuda_temp_505 = &((result)[index]);
                            (*(csharp2cuda_temp_505) = 0.0f);
#line 1596 "SequencePathModule.cs"
                            int* csharp2cuda_temp_504 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_504));
                        }
                    }
#line 1598 "SequencePathModule.cs"
                    {
#line 1598 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1598 "SequencePathModule.cs"
                            int csharp2cuda_temp_507 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_507))))
                                break;
#line 1599 "SequencePathModule.cs"
                            {
#line 1600 "SequencePathModule.cs"
                                {
#line 1600 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1601 "SequencePathModule.cs"
#line 1601 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_509 = &((increment)[column]);
#line 1601 "SequencePathModule.cs"
                                        float csharp2cuda_temp_510 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), column)];
#line 1601 "SequencePathModule.cs"
                                        float csharp2cuda_temp_511 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), column)];
                                        (*(csharp2cuda_temp_509) = __fsub_rn(csharp2cuda_temp_510, csharp2cuda_temp_511));
#line 1600 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_508 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_508));
                                    }
                                }
#line 1602 "SequencePathModule.cs"
                                {
#line 1602 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1603 "SequencePathModule.cs"
                                        {
#line 1604 "SequencePathModule.cs"
                                            {
#line 1604 "SequencePathModule.cs"
                                                int right = 0;
                                                while (true)
                                                {
                                                    if (!(((right) < (dimension))))
                                                        break;
#line 1605 "SequencePathModule.cs"
                                                    {
#line 1606 "SequencePathModule.cs"
#line 1606 "SequencePathModule.cs"
                                                        float* csharp2cuda_temp_514 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), right)]);
#line 1606 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_515 = *(csharp2cuda_temp_514);
#line 1607 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_516 = (cumulative)[left];
#line 1607 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_517 = (increment)[right];
#line 1608 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_518 = (increment)[left];
#line 1608 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_519 = (increment)[right];
                                                        (*(csharp2cuda_temp_514) = __fadd_rn(csharp2cuda_temp_515, __fadd_rn(__fmul_rn(csharp2cuda_temp_516, csharp2cuda_temp_517), __fmul_rn(__fmul_rn(0.5f, csharp2cuda_temp_518), csharp2cuda_temp_519))));
                                                    }
#line 1604 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_513 = &(right);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_513));
                                                }
                                            }
                                        }
#line 1602 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_512 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_512));
                                    }
                                }
#line 1611 "SequencePathModule.cs"
                                {
#line 1611 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1612 "SequencePathModule.cs"
#line 1612 "SequencePathModule.cs"
                                        float* csharp2cuda_temp_521 = &((cumulative)[column]);
#line 1612 "SequencePathModule.cs"
                                        float csharp2cuda_temp_522 = *(csharp2cuda_temp_521);
#line 1612 "SequencePathModule.cs"
                                        float csharp2cuda_temp_523 = (increment)[column];
                                        (*(csharp2cuda_temp_521) = __fadd_rn(csharp2cuda_temp_522, csharp2cuda_temp_523));
#line 1611 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_520 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_520));
                                    }
                                }
                            }
#line 1598 "SequencePathModule.cs"
                            int* csharp2cuda_temp_506 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_506));
                        }
                    }
#line 1614 "SequencePathModule.cs"
                    {
#line 1614 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1615 "SequencePathModule.cs"
#line 1615 "SequencePathModule.cs"
                            float csharp2cuda_temp_525 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_525))))
                            {
#line 1615 "SequencePathModule.cs"
#line 1615 "SequencePathModule.cs"
                                int* csharp2cuda_temp_526 = &((output)->valid);
                                (*(csharp2cuda_temp_526) = 0);
                            }
#line 1614 "SequencePathModule.cs"
                            int* csharp2cuda_temp_524 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_524));
                        }
                    }
                }
            }
#line 1618 "SequencePathModule.cs"
            break;
#line 1619 "SequencePathModule.cs"
        case 30:
        case 31:
#line 1621 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1622 "SequencePathModule.cs"
#line 1622 "SequencePathModule.cs"
                float* csharp2cuda_temp_527 = &((output)->scalar_value);
#line 1622 "SequencePathModule.cs"
                int csharp2cuda_temp_528 = (first)->count;
#line 1622 "SequencePathModule.cs"
                float csharp2cuda_temp_529 = mathblocks_sequence_sign_change_value(a, csharp2cuda_temp_528, ((opcode) == (30)));
                (*(csharp2cuda_temp_527) = csharp2cuda_temp_529);
            }
#line 1623 "SequencePathModule.cs"
            break;
#line 1624 "SequencePathModule.cs"
        case 32:
#line 1625 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1626 "SequencePathModule.cs"
            {
#line 1627 "SequencePathModule.cs"
                int state_count = 0;
#line 1628 "SequencePathModule.cs"
#line 1628 "SequencePathModule.cs"
                float csharp2cuda_temp_530 = (second)->scalar_value;
#line 1628 "SequencePathModule.cs"
                int* csharp2cuda_temp_531 = &(state_count);
#line 1628 "SequencePathModule.cs"
                bool csharp2cuda_temp_532 = mathblocks_sequence_positive_integer(csharp2cuda_temp_530, csharp2cuda_temp_531);
#line 1628 "SequencePathModule.cs"
                bool csharp2cuda_temp_533;
#line 1628 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_532))))
                {
#line 1628 "SequencePathModule.cs"
                    csharp2cuda_temp_533 = ((state_count) > (mathblocks_limit_state_count()));
                }
                else
                {
#line 1628 "SequencePathModule.cs"
                    csharp2cuda_temp_533 = true;
                }
                if (csharp2cuda_temp_533)
#line 1629 "SequencePathModule.cs"
                {
#line 1630 "SequencePathModule.cs"
#line 1630 "SequencePathModule.cs"
                    int* csharp2cuda_temp_534 = &((output)->valid);
                    (*(csharp2cuda_temp_534) = 0);
                }
                else
#line 1633 "SequencePathModule.cs"
                {
#line 1634 "SequencePathModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, state_count, state_count);
#line 1635 "SequencePathModule.cs"
                    {
#line 1635 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1635 "SequencePathModule.cs"
                            bool csharp2cuda_temp_536 = (output)->valid;
#line 1635 "SequencePathModule.cs"
                            bool csharp2cuda_temp_537;
#line 1635 "SequencePathModule.cs"
                            if (csharp2cuda_temp_536)
                            {
#line 1635 "SequencePathModule.cs"
                                int csharp2cuda_temp_538 = (output)->count;
#line 1635 "SequencePathModule.cs"
                                csharp2cuda_temp_537 = ((index) < (csharp2cuda_temp_538));
                            }
                            else
                            {
#line 1635 "SequencePathModule.cs"
                                csharp2cuda_temp_537 = false;
                            }
                            if (!(csharp2cuda_temp_537))
                                break;
#line 1636 "SequencePathModule.cs"
#line 1636 "SequencePathModule.cs"
                            float* csharp2cuda_temp_539 = &((result)[index]);
                            (*(csharp2cuda_temp_539) = 0.0f);
#line 1635 "SequencePathModule.cs"
                            int* csharp2cuda_temp_535 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_535));
                        }
                    }
#line 1637 "SequencePathModule.cs"
                    {
#line 1637 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1637 "SequencePathModule.cs"
                            bool csharp2cuda_temp_541 = (output)->valid;
#line 1637 "SequencePathModule.cs"
                            bool csharp2cuda_temp_542;
#line 1637 "SequencePathModule.cs"
                            if (csharp2cuda_temp_541)
                            {
#line 1637 "SequencePathModule.cs"
                                int csharp2cuda_temp_543 = (first)->count;
#line 1637 "SequencePathModule.cs"
                                csharp2cuda_temp_542 = ((index) < (csharp2cuda_temp_543));
                            }
                            else
                            {
#line 1637 "SequencePathModule.cs"
                                csharp2cuda_temp_542 = false;
                            }
                            if (!(csharp2cuda_temp_542))
                                break;
#line 1638 "SequencePathModule.cs"
                            {
#line 1639 "SequencePathModule.cs"
                                int state = 0;
#line 1640 "SequencePathModule.cs"
#line 1640 "SequencePathModule.cs"
                                float csharp2cuda_temp_544 = (a)[index];
#line 1640 "SequencePathModule.cs"
                                int* csharp2cuda_temp_545 = &(state);
#line 1640 "SequencePathModule.cs"
                                bool csharp2cuda_temp_546 = mathblocks_nonnegative_integer(csharp2cuda_temp_544, csharp2cuda_temp_545);
#line 1640 "SequencePathModule.cs"
                                bool csharp2cuda_temp_547;
#line 1640 "SequencePathModule.cs"
                                if (!((!(csharp2cuda_temp_546))))
                                {
#line 1640 "SequencePathModule.cs"
                                    csharp2cuda_temp_547 = ((state) >= (state_count));
                                }
                                else
                                {
#line 1640 "SequencePathModule.cs"
                                    csharp2cuda_temp_547 = true;
                                }
                                if (csharp2cuda_temp_547)
                                {
#line 1641 "SequencePathModule.cs"
#line 1641 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_548 = &((output)->valid);
                                    (*(csharp2cuda_temp_548) = 0);
                                }
                            }
#line 1637 "SequencePathModule.cs"
                            int* csharp2cuda_temp_540 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_540));
                        }
                    }
#line 1643 "SequencePathModule.cs"
                    {
#line 1643 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1643 "SequencePathModule.cs"
                            bool csharp2cuda_temp_550 = (output)->valid;
#line 1643 "SequencePathModule.cs"
                            bool csharp2cuda_temp_551;
#line 1643 "SequencePathModule.cs"
                            if (csharp2cuda_temp_550)
                            {
#line 1643 "SequencePathModule.cs"
                                int csharp2cuda_temp_552 = (first)->count;
#line 1643 "SequencePathModule.cs"
                                csharp2cuda_temp_551 = ((index) < (csharp2cuda_temp_552));
                            }
                            else
                            {
#line 1643 "SequencePathModule.cs"
                                csharp2cuda_temp_551 = false;
                            }
                            if (!(csharp2cuda_temp_551))
                                break;
#line 1644 "SequencePathModule.cs"
#line 1644 "SequencePathModule.cs"
                            float csharp2cuda_temp_553 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 1644 "SequencePathModule.cs"
                            float csharp2cuda_temp_554 = (a)[index];
#line 1644 "SequencePathModule.cs"
                            float* csharp2cuda_temp_555 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_f64_to_i32(csharp2cuda_temp_553), state_count), csharp2cuda_f64_to_i32(csharp2cuda_temp_554))]);
#line 1644 "SequencePathModule.cs"
                            float csharp2cuda_temp_556 = *(csharp2cuda_temp_555);
                            (*(csharp2cuda_temp_555) = __fadd_rn(csharp2cuda_temp_556, 1.0f));
#line 1643 "SequencePathModule.cs"
                            int* csharp2cuda_temp_549 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_549));
                        }
                    }
                }
            }
#line 1647 "SequencePathModule.cs"
            break;
#line 1654 "SequencePathModule.cs"
        case 33:
        case 34:
        case 35:
        case 36:
#line 1658 "SequencePathModule.cs"
            {
#line 1659 "SequencePathModule.cs"
                bool shift_forward = ((opcode) < (35));
#line 1660 "SequencePathModule.cs"
                int csharp2cuda_temp_557 = csharp2cuda_i32_rem(opcode, 2);
#line 1660 "SequencePathModule.cs"
                bool shift_sibling = ((csharp2cuda_temp_557) == (0));
#line 1661 "SequencePathModule.cs"
                MathBlockSlot* csharp2cuda_temp_558;
#line 1661 "SequencePathModule.cs"
                if (((input_count) > (3)))
                {
#line 1661 "SequencePathModule.cs"
                    csharp2cuda_temp_558 = (inputs)[3];
                }
                else
                {
#line 1661 "SequencePathModule.cs"
                    csharp2cuda_temp_558 = ((MathBlockSlot*)(nullptr));
                }
#line 1661 "SequencePathModule.cs"
                const MathBlockSlot* shift_offset_input = csharp2cuda_temp_558;
#line 1662 "SequencePathModule.cs"
                MathBlockSlot* csharp2cuda_temp_559;
#line 1662 "SequencePathModule.cs"
                if (((input_count) > (4)))
                {
#line 1662 "SequencePathModule.cs"
                    csharp2cuda_temp_559 = (inputs)[4];
                }
                else
                {
#line 1662 "SequencePathModule.cs"
                    csharp2cuda_temp_559 = ((MathBlockSlot*)(nullptr));
                }
#line 1662 "SequencePathModule.cs"
                const MathBlockSlot* shift_fill_input = csharp2cuda_temp_559;
#line 1663 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_560 = (second)->data_pointer;
#line 1663 "SequencePathModule.cs"
                const int* shift_flags = ((int*)(csharp2cuda_temp_560));
#line 1664 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_561 = (third)->data_pointer;
#line 1664 "SequencePathModule.cs"
                const float* shift_counts = ((float*)(csharp2cuda_temp_561));
#line 1665 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_562 = (output)->data_pointer;
#line 1665 "SequencePathModule.cs"
                int* shift_boolean = ((int*)(csharp2cuda_temp_562));
#line 1666 "SequencePathModule.cs"
                int shift_rows = (first)->count;
#line 1667 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 1668 "SequencePathModule.cs"
                {
#line 1669 "SequencePathModule.cs"
                    mathblocks_sequence_set_vector_shape(output, shift_rows);
#line 1670 "SequencePathModule.cs"
                    float csharp2cuda_temp_563;
#line 1670 "SequencePathModule.cs"
                    if (((((void*)(shift_offset_input))) == (((void*)(nullptr)))))
                    {
#line 1670 "SequencePathModule.cs"
                        csharp2cuda_temp_563 = 0.0f;
                    }
                    else
                    {
#line 1670 "SequencePathModule.cs"
                        csharp2cuda_temp_563 = (shift_offset_input)->scalar_value;
                    }
#line 1670 "SequencePathModule.cs"
                    float shift_offset_value = csharp2cuda_temp_563;
#line 1671 "SequencePathModule.cs"
#line 1671 "SequencePathModule.cs"
                    int csharp2cuda_temp_564;
#line 1671 "SequencePathModule.cs"
                    if (shift_sibling)
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_564 = 4;
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_564 = 5;
                    }
#line 1671 "SequencePathModule.cs"
                    bool csharp2cuda_temp_565;
#line 1671 "SequencePathModule.cs"
                    if (!(((input_count) != (csharp2cuda_temp_564))))
                    {
#line 1671 "SequencePathModule.cs"
                        bool csharp2cuda_temp_566 = (shift_offset_input)->valid;
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_565 = (!(csharp2cuda_temp_566));
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_565 = true;
                    }
#line 1671 "SequencePathModule.cs"
                    bool csharp2cuda_temp_567;
#line 1671 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_565))
                    {
#line 1671 "SequencePathModule.cs"
                        bool csharp2cuda_temp_568;
#line 1671 "SequencePathModule.cs"
                        if ((!(shift_sibling)))
                        {
#line 1671 "SequencePathModule.cs"
                            bool csharp2cuda_temp_569 = (shift_fill_input)->valid;
#line 1671 "SequencePathModule.cs"
                            csharp2cuda_temp_568 = (!(csharp2cuda_temp_569));
                        }
                        else
                        {
#line 1671 "SequencePathModule.cs"
                            csharp2cuda_temp_568 = false;
                        }
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_567 = csharp2cuda_temp_568;
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_567 = true;
                    }
#line 1671 "SequencePathModule.cs"
                    bool csharp2cuda_temp_570;
#line 1671 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_567))
                    {
#line 1672 "SequencePathModule.cs"
                        int csharp2cuda_temp_571 = (second)->count;
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_570 = ((csharp2cuda_temp_571) != (shift_rows));
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_570 = true;
                    }
#line 1671 "SequencePathModule.cs"
                    bool csharp2cuda_temp_572;
#line 1671 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_570))
                    {
#line 1672 "SequencePathModule.cs"
                        int csharp2cuda_temp_573 = (third)->count;
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_572 = ((csharp2cuda_temp_573) != (shift_rows));
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_572 = true;
                    }
#line 1671 "SequencePathModule.cs"
                    bool csharp2cuda_temp_574;
#line 1671 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_572))
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_574 = (!(((shift_offset_value) >= (1.0f))));
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_574 = true;
                    }
#line 1671 "SequencePathModule.cs"
                    bool csharp2cuda_temp_575;
#line 1671 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_574))
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_575 = ((shift_offset_value) != (truncf(shift_offset_value)));
                    }
                    else
                    {
#line 1671 "SequencePathModule.cs"
                        csharp2cuda_temp_575 = true;
                    }
                    if (csharp2cuda_temp_575)
                    {
#line 1674 "SequencePathModule.cs"
#line 1674 "SequencePathModule.cs"
                        int* csharp2cuda_temp_576 = &((output)->valid);
                        (*(csharp2cuda_temp_576) = 0);
                    }
#line 1675 "SequencePathModule.cs"
#line 1675 "SequencePathModule.cs"
                    float* csharp2cuda_temp_577 = &((output)->scalar_value);
#line 1675 "SequencePathModule.cs"
                    float csharp2cuda_temp_578;
#line 1675 "SequencePathModule.cs"
                    if (((shift_offset_value) < (((float)(shift_rows)))))
                    {
#line 1675 "SequencePathModule.cs"
                        csharp2cuda_temp_578 = shift_offset_value;
                    }
                    else
                    {
#line 1675 "SequencePathModule.cs"
                        csharp2cuda_temp_578 = ((float)(shift_rows));
                    }
                    (*(csharp2cuda_temp_577) = csharp2cuda_temp_578);
                }
#line 1677 "SequencePathModule.cs"
                __syncthreads();
#line 1678 "SequencePathModule.cs"
                {
#line 1678 "SequencePathModule.cs"
                    int shift_index = thread;
                    while (true)
                    {
#line 1678 "SequencePathModule.cs"
                        bool csharp2cuda_temp_581 = (output)->valid;
#line 1678 "SequencePathModule.cs"
                        bool csharp2cuda_temp_582;
#line 1678 "SequencePathModule.cs"
                        if (csharp2cuda_temp_581)
                        {
#line 1678 "SequencePathModule.cs"
                            csharp2cuda_temp_582 = ((shift_index) < (shift_rows));
                        }
                        else
                        {
#line 1678 "SequencePathModule.cs"
                            csharp2cuda_temp_582 = false;
                        }
                        if (!(csharp2cuda_temp_582))
                            break;
#line 1679 "SequencePathModule.cs"
                        {
#line 1680 "SequencePathModule.cs"
                            float shift_count_value = (shift_counts)[shift_index];
#line 1681 "SequencePathModule.cs"
#line 1681 "SequencePathModule.cs"
                            bool csharp2cuda_temp_583;
#line 1681 "SequencePathModule.cs"
                            if (!((!(((shift_count_value) >= (0.0f))))))
                            {
#line 1681 "SequencePathModule.cs"
                                csharp2cuda_temp_583 = ((shift_count_value) != (truncf(shift_count_value)));
                            }
                            else
                            {
#line 1681 "SequencePathModule.cs"
                                csharp2cuda_temp_583 = true;
                            }
#line 1681 "SequencePathModule.cs"
                            bool csharp2cuda_temp_584;
#line 1681 "SequencePathModule.cs"
                            if (!(csharp2cuda_temp_583))
                            {
#line 1681 "SequencePathModule.cs"
                                csharp2cuda_temp_584 = (!(isfinite(shift_count_value)));
                            }
                            else
                            {
#line 1681 "SequencePathModule.cs"
                                csharp2cuda_temp_584 = true;
                            }
                            if (csharp2cuda_temp_584)
                            {
#line 1682 "SequencePathModule.cs"
                                atomicExch(&((output)->valid), 0);
                            }
                        }
#line 1678 "SequencePathModule.cs"
                        int* csharp2cuda_temp_579 = &(shift_index);
#line 1678 "SequencePathModule.cs"
                        int csharp2cuda_temp_580 = *(csharp2cuda_temp_579);
                        (*(csharp2cuda_temp_579) = csharp2cuda_i32_add(csharp2cuda_temp_580, blockDim.x));
                    }
                }
#line 1684 "SequencePathModule.cs"
                __syncthreads();
#line 1685 "SequencePathModule.cs"
                float csharp2cuda_temp_585 = (output)->scalar_value;
#line 1685 "SequencePathModule.cs"
                int shift_offset = csharp2cuda_f64_to_i32(csharp2cuda_temp_585);
#line 1686 "SequencePathModule.cs"
                float shift_fill = 0.0f;
#line 1687 "SequencePathModule.cs"
#line 1687 "SequencePathModule.cs"
                bool csharp2cuda_temp_586 = (output)->valid;
#line 1687 "SequencePathModule.cs"
                bool csharp2cuda_temp_587;
#line 1687 "SequencePathModule.cs"
                if (csharp2cuda_temp_586)
                {
#line 1687 "SequencePathModule.cs"
                    csharp2cuda_temp_587 = (!(shift_sibling));
                }
                else
                {
#line 1687 "SequencePathModule.cs"
                    csharp2cuda_temp_587 = false;
                }
                if (csharp2cuda_temp_587)
                {
#line 1688 "SequencePathModule.cs"
#line 1688 "SequencePathModule.cs"
                    float* csharp2cuda_temp_588 = &(shift_fill);
#line 1688 "SequencePathModule.cs"
                    float csharp2cuda_temp_589 = (shift_fill_input)->scalar_value;
                    (*(csharp2cuda_temp_588) = csharp2cuda_temp_589);
                }
#line 1689 "SequencePathModule.cs"
                {
#line 1689 "SequencePathModule.cs"
                    int shift_index = thread;
                    while (true)
                    {
#line 1689 "SequencePathModule.cs"
                        bool csharp2cuda_temp_592 = (output)->valid;
#line 1689 "SequencePathModule.cs"
                        bool csharp2cuda_temp_593;
#line 1689 "SequencePathModule.cs"
                        if (csharp2cuda_temp_592)
                        {
#line 1689 "SequencePathModule.cs"
                            csharp2cuda_temp_593 = ((shift_index) < (shift_rows));
                        }
                        else
                        {
#line 1689 "SequencePathModule.cs"
                            csharp2cuda_temp_593 = false;
                        }
                        if (!(csharp2cuda_temp_593))
                            break;
#line 1690 "SequencePathModule.cs"
                        {
#line 1691 "SequencePathModule.cs"
                            bool shift_available = false;
#line 1692 "SequencePathModule.cs"
                            int shift_source = 0;
#line 1693 "SequencePathModule.cs"
                            if (shift_forward)
#line 1694 "SequencePathModule.cs"
                            {
#line 1695 "SequencePathModule.cs"
                                if (((shift_index) < (csharp2cuda_i32_sub(shift_rows, shift_offset))))
#line 1696 "SequencePathModule.cs"
                                {
#line 1697 "SequencePathModule.cs"
#line 1697 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_594 = &(shift_source);
                                    (*(csharp2cuda_temp_594) = csharp2cuda_i32_add(shift_index, shift_offset));
#line 1698 "SequencePathModule.cs"
#line 1698 "SequencePathModule.cs"
                                    bool* csharp2cuda_temp_595 = &(shift_available);
#line 1698 "SequencePathModule.cs"
                                    float csharp2cuda_temp_596 = (shift_counts)[shift_source];
#line 1698 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_597;
#line 1698 "SequencePathModule.cs"
                                    if (((csharp2cuda_temp_596) >= (((float)(shift_offset)))))
                                    {
#line 1698 "SequencePathModule.cs"
                                        csharp2cuda_temp_597 = (shift_flags)[shift_source];
                                    }
                                    else
                                    {
#line 1698 "SequencePathModule.cs"
                                        csharp2cuda_temp_597 = false;
                                    }
                                    (*(csharp2cuda_temp_595) = csharp2cuda_temp_597);
                                }
                            }
                            else
                            {
#line 1701 "SequencePathModule.cs"
                                if (((shift_index) >= (shift_offset)))
#line 1702 "SequencePathModule.cs"
                                {
#line 1703 "SequencePathModule.cs"
#line 1703 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_598 = &(shift_source);
                                    (*(csharp2cuda_temp_598) = csharp2cuda_i32_sub(shift_index, shift_offset));
#line 1704 "SequencePathModule.cs"
#line 1704 "SequencePathModule.cs"
                                    bool* csharp2cuda_temp_599 = &(shift_available);
#line 1704 "SequencePathModule.cs"
                                    float csharp2cuda_temp_600 = (shift_counts)[shift_index];
#line 1704 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_601;
#line 1704 "SequencePathModule.cs"
                                    if (((csharp2cuda_temp_600) >= (((float)(shift_offset)))))
                                    {
#line 1704 "SequencePathModule.cs"
                                        csharp2cuda_temp_601 = (shift_flags)[shift_source];
                                    }
                                    else
                                    {
#line 1704 "SequencePathModule.cs"
                                        csharp2cuda_temp_601 = false;
                                    }
                                    (*(csharp2cuda_temp_599) = csharp2cuda_temp_601);
                                }
                            }
#line 1706 "SequencePathModule.cs"
                            if (shift_sibling)
                            {
#line 1707 "SequencePathModule.cs"
#line 1707 "SequencePathModule.cs"
                                int* csharp2cuda_temp_602 = &((shift_boolean)[shift_index]);
                                (*(csharp2cuda_temp_602) = shift_available);
                            }
                            else
                            {
#line 1709 "SequencePathModule.cs"
#line 1709 "SequencePathModule.cs"
                                float* csharp2cuda_temp_603 = &((result)[shift_index]);
#line 1709 "SequencePathModule.cs"
                                float csharp2cuda_temp_604;
#line 1709 "SequencePathModule.cs"
                                if (shift_available)
                                {
#line 1709 "SequencePathModule.cs"
                                    csharp2cuda_temp_604 = (a)[shift_source];
                                }
                                else
                                {
#line 1709 "SequencePathModule.cs"
                                    csharp2cuda_temp_604 = shift_fill;
                                }
                                (*(csharp2cuda_temp_603) = csharp2cuda_temp_604);
                            }
                        }
#line 1689 "SequencePathModule.cs"
                        int* csharp2cuda_temp_590 = &(shift_index);
#line 1689 "SequencePathModule.cs"
                        int csharp2cuda_temp_591 = *(csharp2cuda_temp_590);
                        (*(csharp2cuda_temp_590) = csharp2cuda_i32_add(csharp2cuda_temp_591, blockDim.x));
                    }
                }
#line 1711 "SequencePathModule.cs"
                break;
            }
#line 1713 "SequencePathModule.cs"
        case 37:
        case 38:
        case 39:
        case 40:
        case 41:
        case 42:
#line 1719 "SequencePathModule.cs"
            mathblocks_sequence_offsets(opcode, inputs, input_count, output);
#line 1720 "SequencePathModule.cs"
            break;
#line 1728 "SequencePathModule.cs"
        case 43:
        case 44:
#line 1730 "SequencePathModule.cs"
            {
#line 1731 "SequencePathModule.cs"
                MathBlockSlot* csharp2cuda_temp_605;
#line 1731 "SequencePathModule.cs"
                if (((input_count) > (3)))
                {
#line 1731 "SequencePathModule.cs"
                    csharp2cuda_temp_605 = (inputs)[3];
                }
                else
                {
#line 1731 "SequencePathModule.cs"
                    csharp2cuda_temp_605 = ((MathBlockSlot*)(nullptr));
                }
#line 1731 "SequencePathModule.cs"
                const MathBlockSlot* start_slot = csharp2cuda_temp_605;
#line 1732 "SequencePathModule.cs"
                MathBlockSlot* csharp2cuda_temp_606;
#line 1732 "SequencePathModule.cs"
                if (((input_count) > (4)))
                {
#line 1732 "SequencePathModule.cs"
                    csharp2cuda_temp_606 = (inputs)[4];
                }
                else
                {
#line 1732 "SequencePathModule.cs"
                    csharp2cuda_temp_606 = ((MathBlockSlot*)(nullptr));
                }
#line 1732 "SequencePathModule.cs"
                const MathBlockSlot* end_slot = csharp2cuda_temp_606;
#line 1733 "SequencePathModule.cs"
                MathBlockSlot* csharp2cuda_temp_607;
#line 1733 "SequencePathModule.cs"
                if (((input_count) > (5)))
                {
#line 1733 "SequencePathModule.cs"
                    csharp2cuda_temp_607 = (inputs)[5];
                }
                else
                {
#line 1733 "SequencePathModule.cs"
                    csharp2cuda_temp_607 = ((MathBlockSlot*)(nullptr));
                }
#line 1733 "SequencePathModule.cs"
                const MathBlockSlot* fill_slot = csharp2cuda_temp_607;
#line 1734 "SequencePathModule.cs"
                int* csharp2cuda_temp_608;
#line 1734 "SequencePathModule.cs"
                if (((((void*)(second))) == (((void*)(nullptr)))))
                {
#line 1734 "SequencePathModule.cs"
                    csharp2cuda_temp_608 = ((int*)(nullptr));
                }
                else
                {
#line 1734 "SequencePathModule.cs"
                    unsigned long long csharp2cuda_temp_609 = (second)->data_pointer;
#line 1734 "SequencePathModule.cs"
                    csharp2cuda_temp_608 = ((int*)(csharp2cuda_temp_609));
                }
#line 1734 "SequencePathModule.cs"
                const int* available = csharp2cuda_temp_608;
#line 1735 "SequencePathModule.cs"
                float* csharp2cuda_temp_610;
#line 1735 "SequencePathModule.cs"
                if (((((void*)(third))) == (((void*)(nullptr)))))
                {
#line 1735 "SequencePathModule.cs"
                    csharp2cuda_temp_610 = ((float*)(nullptr));
                }
                else
                {
#line 1735 "SequencePathModule.cs"
                    unsigned long long csharp2cuda_temp_611 = (third)->data_pointer;
#line 1735 "SequencePathModule.cs"
                    csharp2cuda_temp_610 = ((float*)(csharp2cuda_temp_611));
                }
#line 1735 "SequencePathModule.cs"
                const float* counts = csharp2cuda_temp_610;
#line 1736 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_612 = (output)->data_pointer;
#line 1736 "SequencePathModule.cs"
                int* flags = ((int*)(csharp2cuda_temp_612));
#line 1737 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 1738 "SequencePathModule.cs"
                {
#line 1739 "SequencePathModule.cs"
                    int count = (first)->count;
#line 1740 "SequencePathModule.cs"
                    float start = (start_slot)->scalar_value;
#line 1741 "SequencePathModule.cs"
                    float end = (end_slot)->scalar_value;
#line 1742 "SequencePathModule.cs"
                    float fill = 0.0f;
#line 1743 "SequencePathModule.cs"
                    if (((opcode) == (43)))
                    {
#line 1744 "SequencePathModule.cs"
#line 1744 "SequencePathModule.cs"
                        float* csharp2cuda_temp_613 = &(fill);
#line 1744 "SequencePathModule.cs"
                        float csharp2cuda_temp_614 = (fill_slot)->scalar_value;
                        (*(csharp2cuda_temp_613) = csharp2cuda_temp_614);
                    }
#line 1745 "SequencePathModule.cs"
                    mathblocks_sequence_set_vector_shape(output, count);
#line 1746 "SequencePathModule.cs"
#line 1746 "SequencePathModule.cs"
                    bool csharp2cuda_temp_615 = (start_slot)->valid;
#line 1746 "SequencePathModule.cs"
                    bool csharp2cuda_temp_616;
#line 1746 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_615))))
                    {
#line 1746 "SequencePathModule.cs"
                        bool csharp2cuda_temp_617 = (end_slot)->valid;
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_616 = (!(csharp2cuda_temp_617));
                    }
                    else
                    {
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_616 = true;
                    }
#line 1746 "SequencePathModule.cs"
                    bool csharp2cuda_temp_618;
#line 1746 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_616))
                    {
#line 1746 "SequencePathModule.cs"
                        bool csharp2cuda_temp_619;
#line 1746 "SequencePathModule.cs"
                        if (((opcode) == (43)))
                        {
#line 1746 "SequencePathModule.cs"
                            bool csharp2cuda_temp_620 = (fill_slot)->valid;
#line 1746 "SequencePathModule.cs"
                            csharp2cuda_temp_619 = (!(csharp2cuda_temp_620));
                        }
                        else
                        {
#line 1746 "SequencePathModule.cs"
                            csharp2cuda_temp_619 = false;
                        }
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_618 = csharp2cuda_temp_619;
                    }
                    else
                    {
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_618 = true;
                    }
#line 1746 "SequencePathModule.cs"
                    bool csharp2cuda_temp_621;
#line 1746 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_618))
                    {
#line 1747 "SequencePathModule.cs"
                        int csharp2cuda_temp_622 = (second)->count;
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_621 = ((csharp2cuda_temp_622) != (count));
                    }
                    else
                    {
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_621 = true;
                    }
#line 1746 "SequencePathModule.cs"
                    bool csharp2cuda_temp_623;
#line 1746 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_621))
                    {
#line 1747 "SequencePathModule.cs"
                        int csharp2cuda_temp_624 = (third)->count;
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_623 = ((csharp2cuda_temp_624) != (count));
                    }
                    else
                    {
#line 1746 "SequencePathModule.cs"
                        csharp2cuda_temp_623 = true;
                    }
                    if (csharp2cuda_temp_623)
#line 1748 "SequencePathModule.cs"
                    {
#line 1749 "SequencePathModule.cs"
#line 1749 "SequencePathModule.cs"
                        int* csharp2cuda_temp_625 = &((output)->valid);
                        (*(csharp2cuda_temp_625) = 0);
                    }
#line 1751 "SequencePathModule.cs"
#line 1751 "SequencePathModule.cs"
                    bool csharp2cuda_temp_626;
#line 1751 "SequencePathModule.cs"
                    if (!((!(isfinite(start)))))
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_626 = (!(isfinite(end)));
                    }
                    else
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_626 = true;
                    }
#line 1751 "SequencePathModule.cs"
                    bool csharp2cuda_temp_627;
#line 1751 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_626))
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_627 = ((start) != (floorf(start)));
                    }
                    else
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_627 = true;
                    }
#line 1751 "SequencePathModule.cs"
                    bool csharp2cuda_temp_628;
#line 1751 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_627))
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_628 = ((end) != (floorf(end)));
                    }
                    else
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_628 = true;
                    }
#line 1751 "SequencePathModule.cs"
                    bool csharp2cuda_temp_629;
#line 1751 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_628))
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_629 = ((start) > (end));
                    }
                    else
                    {
#line 1751 "SequencePathModule.cs"
                        csharp2cuda_temp_629 = true;
                    }
                    if (csharp2cuda_temp_629)
#line 1753 "SequencePathModule.cs"
                    {
#line 1754 "SequencePathModule.cs"
#line 1754 "SequencePathModule.cs"
                        int* csharp2cuda_temp_630 = &((output)->valid);
                        (*(csharp2cuda_temp_630) = 0);
                    }
#line 1756 "SequencePathModule.cs"
                    {
#line 1756 "SequencePathModule.cs"
                        int row = 0;
                        while (true)
                        {
#line 1756 "SequencePathModule.cs"
                            bool csharp2cuda_temp_632 = (output)->valid;
#line 1756 "SequencePathModule.cs"
                            bool csharp2cuda_temp_633;
#line 1756 "SequencePathModule.cs"
                            if (csharp2cuda_temp_632)
                            {
#line 1756 "SequencePathModule.cs"
                                csharp2cuda_temp_633 = ((row) < (count));
                            }
                            else
                            {
#line 1756 "SequencePathModule.cs"
                                csharp2cuda_temp_633 = false;
                            }
                            if (!(csharp2cuda_temp_633))
                                break;
#line 1757 "SequencePathModule.cs"
#line 1757 "SequencePathModule.cs"
                            float csharp2cuda_temp_634 = (counts)[row];
#line 1757 "SequencePathModule.cs"
                            bool csharp2cuda_temp_635;
#line 1757 "SequencePathModule.cs"
                            if (!((!(isfinite(csharp2cuda_temp_634)))))
                            {
#line 1757 "SequencePathModule.cs"
                                float csharp2cuda_temp_636 = (counts)[row];
#line 1757 "SequencePathModule.cs"
                                csharp2cuda_temp_635 = ((csharp2cuda_temp_636) < (0.0f));
                            }
                            else
                            {
#line 1757 "SequencePathModule.cs"
                                csharp2cuda_temp_635 = true;
                            }
#line 1757 "SequencePathModule.cs"
                            bool csharp2cuda_temp_637;
#line 1757 "SequencePathModule.cs"
                            if (!(csharp2cuda_temp_635))
                            {
#line 1757 "SequencePathModule.cs"
                                float csharp2cuda_temp_638 = (counts)[row];
#line 1757 "SequencePathModule.cs"
                                float csharp2cuda_temp_639 = (counts)[row];
#line 1757 "SequencePathModule.cs"
                                csharp2cuda_temp_637 = ((csharp2cuda_temp_638) != (floorf(csharp2cuda_temp_639)));
                            }
                            else
                            {
#line 1757 "SequencePathModule.cs"
                                csharp2cuda_temp_637 = true;
                            }
                            if (csharp2cuda_temp_637)
                            {
#line 1758 "SequencePathModule.cs"
#line 1758 "SequencePathModule.cs"
                                int* csharp2cuda_temp_640 = &((output)->valid);
                                (*(csharp2cuda_temp_640) = 0);
                            }
#line 1756 "SequencePathModule.cs"
                            int* csharp2cuda_temp_631 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_631));
                        }
                    }
#line 1759 "SequencePathModule.cs"
                    int segment_start = 0;
#line 1760 "SequencePathModule.cs"
                    while (true)
                    {
#line 1760 "SequencePathModule.cs"
                        bool csharp2cuda_temp_641 = (output)->valid;
#line 1760 "SequencePathModule.cs"
                        bool csharp2cuda_temp_642;
#line 1760 "SequencePathModule.cs"
                        if (csharp2cuda_temp_641)
                        {
#line 1760 "SequencePathModule.cs"
                            csharp2cuda_temp_642 = ((segment_start) < (count));
                        }
                        else
                        {
#line 1760 "SequencePathModule.cs"
                            csharp2cuda_temp_642 = false;
                        }
                        if (!(csharp2cuda_temp_642))
                            break;
#line 1761 "SequencePathModule.cs"
                        {
#line 1762 "SequencePathModule.cs"
                            int segment_end = csharp2cuda_i32_add(segment_start, 1);
#line 1763 "SequencePathModule.cs"
                            while (true)
                            {
#line 1763 "SequencePathModule.cs"
                                bool csharp2cuda_temp_643;
#line 1763 "SequencePathModule.cs"
                                if (((segment_end) < (count)))
                                {
#line 1763 "SequencePathModule.cs"
                                    float csharp2cuda_temp_644 = (counts)[segment_end];
#line 1763 "SequencePathModule.cs"
                                    csharp2cuda_temp_643 = ((csharp2cuda_temp_644) != (0.0f));
                                }
                                else
                                {
#line 1763 "SequencePathModule.cs"
                                    csharp2cuda_temp_643 = false;
                                }
                                if (!(csharp2cuda_temp_643))
                                    break;
#line 1764 "SequencePathModule.cs"
#line 1764 "SequencePathModule.cs"
                                int* csharp2cuda_temp_645 = &(segment_end);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_645));
                            }
#line 1765 "SequencePathModule.cs"
                            int low_position = segment_start;
#line 1766 "SequencePathModule.cs"
                            float low_sum = 0.0f;
#line 1767 "SequencePathModule.cs"
                            int low_missing = 0;
#line 1768 "SequencePathModule.cs"
                            int high_position = segment_start;
#line 1769 "SequencePathModule.cs"
                            float high_sum = 0.0f;
#line 1770 "SequencePathModule.cs"
                            int high_missing = 0;
#line 1771 "SequencePathModule.cs"
                            {
#line 1771 "SequencePathModule.cs"
                                int row = segment_start;
                                while (true)
                                {
                                    if (!(((row) < (segment_end))))
                                        break;
#line 1772 "SequencePathModule.cs"
                                    {
#line 1773 "SequencePathModule.cs"
                                        float low = __fadd_rn(((float)(row)), start);
#line 1774 "SequencePathModule.cs"
                                        float high = __fadd_rn(((float)(row)), end);
#line 1775 "SequencePathModule.cs"
                                        bool row_valid = false;
#line 1776 "SequencePathModule.cs"
                                        float difference = 0.0f;
#line 1777 "SequencePathModule.cs"
#line 1777 "SequencePathModule.cs"
                                        bool csharp2cuda_temp_647;
#line 1777 "SequencePathModule.cs"
                                        if (((low) >= (((float)(segment_start)))))
                                        {
#line 1777 "SequencePathModule.cs"
                                            csharp2cuda_temp_647 = ((high) < (((float)(segment_end))));
                                        }
                                        else
                                        {
#line 1777 "SequencePathModule.cs"
                                            csharp2cuda_temp_647 = false;
                                        }
                                        if (csharp2cuda_temp_647)
#line 1778 "SequencePathModule.cs"
                                        {
#line 1779 "SequencePathModule.cs"
                                            int low_target = csharp2cuda_f64_to_i32(low);
#line 1780 "SequencePathModule.cs"
                                            int high_target = csharp2cuda_i32_add(csharp2cuda_f64_to_i32(high), 1);
#line 1781 "SequencePathModule.cs"
                                            while (true)
                                            {
                                                if (!(((low_position) < (low_target))))
                                                    break;
#line 1782 "SequencePathModule.cs"
                                                {
#line 1783 "SequencePathModule.cs"
#line 1783 "SequencePathModule.cs"
                                                    int csharp2cuda_temp_648 = (available)[low_position];
                                                    if (((csharp2cuda_temp_648) != (0)))
                                                    {
#line 1784 "SequencePathModule.cs"
#line 1784 "SequencePathModule.cs"
                                                        float* csharp2cuda_temp_649 = &(low_sum);
#line 1784 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_650 = *(csharp2cuda_temp_649);
#line 1784 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_651 = (a)[low_position];
                                                        (*(csharp2cuda_temp_649) = __fadd_rn(csharp2cuda_temp_650, csharp2cuda_temp_651));
                                                    }
                                                    else
                                                    {
#line 1786 "SequencePathModule.cs"
#line 1786 "SequencePathModule.cs"
                                                        int* csharp2cuda_temp_652 = &(low_missing);
                                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_652));
                                                    }
#line 1787 "SequencePathModule.cs"
#line 1787 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_653 = &(low_position);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_653));
                                                }
                                            }
#line 1789 "SequencePathModule.cs"
                                            while (true)
                                            {
                                                if (!(((high_position) < (high_target))))
                                                    break;
#line 1790 "SequencePathModule.cs"
                                                {
#line 1791 "SequencePathModule.cs"
#line 1791 "SequencePathModule.cs"
                                                    int csharp2cuda_temp_654 = (available)[high_position];
                                                    if (((csharp2cuda_temp_654) != (0)))
                                                    {
#line 1792 "SequencePathModule.cs"
#line 1792 "SequencePathModule.cs"
                                                        float* csharp2cuda_temp_655 = &(high_sum);
#line 1792 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_656 = *(csharp2cuda_temp_655);
#line 1792 "SequencePathModule.cs"
                                                        float csharp2cuda_temp_657 = (a)[high_position];
                                                        (*(csharp2cuda_temp_655) = __fadd_rn(csharp2cuda_temp_656, csharp2cuda_temp_657));
                                                    }
                                                    else
                                                    {
#line 1794 "SequencePathModule.cs"
#line 1794 "SequencePathModule.cs"
                                                        int* csharp2cuda_temp_658 = &(high_missing);
                                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_658));
                                                    }
#line 1795 "SequencePathModule.cs"
#line 1795 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_659 = &(high_position);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_659));
                                                }
                                            }
#line 1797 "SequencePathModule.cs"
#line 1797 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_660 = &(difference);
                                            (*(csharp2cuda_temp_660) = __fsub_rn(high_sum, low_sum));
#line 1798 "SequencePathModule.cs"
#line 1798 "SequencePathModule.cs"
                                            bool* csharp2cuda_temp_661 = &(row_valid);
#line 1798 "SequencePathModule.cs"
                                            bool csharp2cuda_temp_662;
#line 1798 "SequencePathModule.cs"
                                            if (((low_missing) == (high_missing)))
                                            {
#line 1798 "SequencePathModule.cs"
                                                csharp2cuda_temp_662 = isfinite(difference);
                                            }
                                            else
                                            {
#line 1798 "SequencePathModule.cs"
                                                csharp2cuda_temp_662 = false;
                                            }
                                            (*(csharp2cuda_temp_661) = csharp2cuda_temp_662);
                                        }
#line 1800 "SequencePathModule.cs"
                                        if (((opcode) == (44)))
                                        {
#line 1801 "SequencePathModule.cs"
#line 1801 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_663 = &((flags)[row]);
#line 1801 "SequencePathModule.cs"
                                            int csharp2cuda_temp_664;
#line 1801 "SequencePathModule.cs"
                                            if (row_valid)
                                            {
#line 1801 "SequencePathModule.cs"
                                                csharp2cuda_temp_664 = 1;
                                            }
                                            else
                                            {
#line 1801 "SequencePathModule.cs"
                                                csharp2cuda_temp_664 = 0;
                                            }
                                            (*(csharp2cuda_temp_663) = csharp2cuda_temp_664);
                                        }
                                        else
                                        {
#line 1803 "SequencePathModule.cs"
#line 1803 "SequencePathModule.cs"
                                            float* csharp2cuda_temp_665 = &((result)[row]);
#line 1803 "SequencePathModule.cs"
                                            float csharp2cuda_temp_666;
#line 1803 "SequencePathModule.cs"
                                            if (row_valid)
                                            {
#line 1803 "SequencePathModule.cs"
                                                csharp2cuda_temp_666 = difference;
                                            }
                                            else
                                            {
#line 1803 "SequencePathModule.cs"
                                                csharp2cuda_temp_666 = fill;
                                            }
                                            (*(csharp2cuda_temp_665) = csharp2cuda_temp_666);
                                        }
                                    }
#line 1771 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_646 = &(row);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_646));
                                }
                            }
#line 1805 "SequencePathModule.cs"
#line 1805 "SequencePathModule.cs"
                            int* csharp2cuda_temp_667 = &(segment_start);
                            (*(csharp2cuda_temp_667) = segment_end);
                        }
                    }
                }
#line 1808 "SequencePathModule.cs"
                break;
            }
    }
}

#line 48 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(float value, int* result)
#line 50 "SequencePathModule.cs"
{
#line 51 "SequencePathModule.cs"
#line 51 "SequencePathModule.cs"
    bool csharp2cuda_temp_0 = mathblocks_nonnegative_integer(value, result);
#line 51 "SequencePathModule.cs"
    bool csharp2cuda_temp_1;
#line 51 "SequencePathModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 51 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = *(result);
#line 51 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (0));
    }
    else
    {
#line 51 "SequencePathModule.cs"
        csharp2cuda_temp_1 = false;
    }
    return csharp2cuda_temp_1;
}

#line 101 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const float* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output)
#line 107 "SequencePathModule.cs"
{
#line 108 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 109 "SequencePathModule.cs"
    unsigned long long* first_keys = ((unsigned long long*)(scratch));
#line 110 "SequencePathModule.cs"
    unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, count);
#line 111 "SequencePathModule.cs"
    int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, count)));
#line 112 "SequencePathModule.cs"
    int* second_indexes = csharp2cuda_pointer_add(first_indexes, count);
#line 113 "SequencePathModule.cs"
    int* ranks = csharp2cuda_pointer_add(second_indexes, count);
#line 114 "SequencePathModule.cs"
    int* lower_heap = csharp2cuda_pointer_add(ranks, count);
#line 115 "SequencePathModule.cs"
    int csharp2cuda_temp_0 = (output)->boolean_value;
#line 115 "SequencePathModule.cs"
    int* upper_heap = csharp2cuda_pointer_add(lower_heap, csharp2cuda_temp_0);
#line 116 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (output)->boolean_value;
#line 116 "SequencePathModule.cs"
    int* positions = csharp2cuda_pointer_add(upper_heap, csharp2cuda_temp_1);
#line 117 "SequencePathModule.cs"
    int* kinds = csharp2cuda_pointer_add(positions, count);
#line 121 "SequencePathModule.cs"
    const int virtual_lanes = 128;
#line 122 "SequencePathModule.cs"
    int* zero_counts = csharp2cuda_pointer_add(kinds, count);
#line 123 "SequencePathModule.cs"
    int* zero_prefix = csharp2cuda_pointer_add(zero_counts, virtual_lanes);
#line 125 "SequencePathModule.cs"
    {
#line 125 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 126 "SequencePathModule.cs"
            {
#line 127 "SequencePathModule.cs"
#line 127 "SequencePathModule.cs"
                float csharp2cuda_temp_4 = (values)[index];
                if ((!(isfinite(csharp2cuda_temp_4))))
                {
#line 128 "SequencePathModule.cs"
                    atomicExch(&((output)->valid), 0);
                }
#line 129 "SequencePathModule.cs"
#line 129 "SequencePathModule.cs"
                unsigned long long* csharp2cuda_temp_5 = &((first_keys)[index]);
#line 129 "SequencePathModule.cs"
                float csharp2cuda_temp_6 = (values)[index];
                (*(csharp2cuda_temp_5) = mathblocks_sequence_order_key(csharp2cuda_temp_6));
#line 130 "SequencePathModule.cs"
#line 130 "SequencePathModule.cs"
                int* csharp2cuda_temp_7 = &((first_indexes)[index]);
                (*(csharp2cuda_temp_7) = index);
            }
#line 125 "SequencePathModule.cs"
            int* csharp2cuda_temp_2 = &(index);
#line 125 "SequencePathModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, blockDim.x));
        }
    }
#line 132 "SequencePathModule.cs"
    __syncthreads();
#line 133 "SequencePathModule.cs"
#line 133 "SequencePathModule.cs"
    bool csharp2cuda_temp_8 = (output)->valid;
    if ((!(csharp2cuda_temp_8)))
    {
#line 134 "SequencePathModule.cs"
        return;
    }
#line 136 "SequencePathModule.cs"
    unsigned long long* source_keys = first_keys;
#line 137 "SequencePathModule.cs"
    unsigned long long* destination_keys = second_keys;
#line 138 "SequencePathModule.cs"
    int* source_indexes = first_indexes;
#line 139 "SequencePathModule.cs"
    int* destination_indexes = second_indexes;
#line 140 "SequencePathModule.cs"
    {
#line 140 "SequencePathModule.cs"
        int bit = 0;
        while (true)
        {
            if (!(((bit) < (64))))
                break;
#line 141 "SequencePathModule.cs"
            {
#line 142 "SequencePathModule.cs"
                {
#line 142 "SequencePathModule.cs"
                    int lane = thread;
                    while (true)
                    {
                        if (!(((lane) < (virtual_lanes))))
                            break;
#line 143 "SequencePathModule.cs"
                        {
#line 144 "SequencePathModule.cs"
                            long long csharp2cuda_temp_12 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(lane))), ((long long)(virtual_lanes)));
#line 144 "SequencePathModule.cs"
                            int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_12);
#line 145 "SequencePathModule.cs"
                            long long csharp2cuda_temp_13 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(lane, 1)))), ((long long)(virtual_lanes)));
#line 145 "SequencePathModule.cs"
                            int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_13);
#line 146 "SequencePathModule.cs"
                            int zeros = 0;
#line 147 "SequencePathModule.cs"
                            {
#line 147 "SequencePathModule.cs"
                                int index = begin;
                                while (true)
                                {
                                    if (!(((index) < (end))))
                                        break;
#line 148 "SequencePathModule.cs"
#line 148 "SequencePathModule.cs"
                                    unsigned long long csharp2cuda_temp_15 = (source_keys)[index];
                                    if (((((csharp2cuda_u64_shr(csharp2cuda_temp_15, bit)) & (1ull))) == (0ull)))
                                    {
#line 149 "SequencePathModule.cs"
#line 149 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_16 = &(zeros);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                    }
#line 147 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_14 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
                                }
                            }
#line 150 "SequencePathModule.cs"
#line 150 "SequencePathModule.cs"
                            int* csharp2cuda_temp_17 = &((zero_counts)[lane]);
                            (*(csharp2cuda_temp_17) = zeros);
                        }
#line 142 "SequencePathModule.cs"
                        int* csharp2cuda_temp_10 = &(lane);
#line 142 "SequencePathModule.cs"
                        int csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                        (*(csharp2cuda_temp_10) = csharp2cuda_i32_add(csharp2cuda_temp_11, blockDim.x));
                    }
                }
#line 152 "SequencePathModule.cs"
                __syncthreads();
#line 153 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 154 "SequencePathModule.cs"
                {
#line 155 "SequencePathModule.cs"
                    int prefix = 0;
#line 156 "SequencePathModule.cs"
                    {
#line 156 "SequencePathModule.cs"
                        int lane = 0;
                        while (true)
                        {
                            if (!(((lane) < (virtual_lanes))))
                                break;
#line 157 "SequencePathModule.cs"
                            {
#line 158 "SequencePathModule.cs"
#line 158 "SequencePathModule.cs"
                                int* csharp2cuda_temp_19 = &((zero_prefix)[lane]);
                                (*(csharp2cuda_temp_19) = prefix);
#line 159 "SequencePathModule.cs"
#line 159 "SequencePathModule.cs"
                                int* csharp2cuda_temp_20 = &(prefix);
#line 159 "SequencePathModule.cs"
                                int csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
#line 159 "SequencePathModule.cs"
                                int csharp2cuda_temp_22 = (zero_counts)[lane];
                                (*(csharp2cuda_temp_20) = csharp2cuda_i32_add(csharp2cuda_temp_21, csharp2cuda_temp_22));
                            }
#line 156 "SequencePathModule.cs"
                            int* csharp2cuda_temp_18 = &(lane);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
                        }
                    }
#line 161 "SequencePathModule.cs"
#line 161 "SequencePathModule.cs"
                    int* csharp2cuda_temp_23 = &((output)->columns);
                    (*(csharp2cuda_temp_23) = prefix);
                }
#line 163 "SequencePathModule.cs"
                __syncthreads();
#line 164 "SequencePathModule.cs"
                {
#line 164 "SequencePathModule.cs"
                    int lane = thread;
                    while (true)
                    {
                        if (!(((lane) < (virtual_lanes))))
                            break;
#line 165 "SequencePathModule.cs"
                        {
#line 166 "SequencePathModule.cs"
                            long long csharp2cuda_temp_26 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(lane))), ((long long)(virtual_lanes)));
#line 166 "SequencePathModule.cs"
                            int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_26);
#line 167 "SequencePathModule.cs"
                            long long csharp2cuda_temp_27 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(lane, 1)))), ((long long)(virtual_lanes)));
#line 167 "SequencePathModule.cs"
                            int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_27);
#line 168 "SequencePathModule.cs"
                            int zero_destination = (zero_prefix)[lane];
#line 169 "SequencePathModule.cs"
                            int csharp2cuda_temp_28 = (output)->columns;
#line 169 "SequencePathModule.cs"
                            int one_destination = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_28, begin), zero_destination);
#line 170 "SequencePathModule.cs"
                            {
#line 170 "SequencePathModule.cs"
                                int index = begin;
                                while (true)
                                {
                                    if (!(((index) < (end))))
                                        break;
#line 171 "SequencePathModule.cs"
                                    {
#line 172 "SequencePathModule.cs"
                                        unsigned long long key = (source_keys)[index];
#line 173 "SequencePathModule.cs"
                                        int csharp2cuda_temp_30;
#line 173 "SequencePathModule.cs"
                                        if (((((csharp2cuda_u64_shr(key, bit)) & (1ull))) == (0ull)))
                                        {
#line 174 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_31 = &(zero_destination);
#line 173 "SequencePathModule.cs"
                                            csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                                        }
                                        else
                                        {
#line 175 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_32 = &(one_destination);
#line 173 "SequencePathModule.cs"
                                            csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_32));
                                        }
#line 173 "SequencePathModule.cs"
                                        int destination = csharp2cuda_temp_30;
#line 176 "SequencePathModule.cs"
#line 176 "SequencePathModule.cs"
                                        unsigned long long* csharp2cuda_temp_33 = &((destination_keys)[destination]);
                                        (*(csharp2cuda_temp_33) = key);
#line 177 "SequencePathModule.cs"
#line 177 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_34 = &((destination_indexes)[destination]);
#line 177 "SequencePathModule.cs"
                                        int csharp2cuda_temp_35 = (source_indexes)[index];
                                        (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
                                    }
#line 170 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_29 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
                                }
                            }
                        }
#line 164 "SequencePathModule.cs"
                        int* csharp2cuda_temp_24 = &(lane);
#line 164 "SequencePathModule.cs"
                        int csharp2cuda_temp_25 = *(csharp2cuda_temp_24);
                        (*(csharp2cuda_temp_24) = csharp2cuda_i32_add(csharp2cuda_temp_25, blockDim.x));
                    }
                }
#line 180 "SequencePathModule.cs"
                __syncthreads();
#line 181 "SequencePathModule.cs"
                unsigned long long* key_swap = source_keys;
#line 182 "SequencePathModule.cs"
#line 182 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_36 = &(source_keys);
                (*(csharp2cuda_temp_36) = destination_keys);
#line 183 "SequencePathModule.cs"
#line 183 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_37 = &(destination_keys);
                (*(csharp2cuda_temp_37) = key_swap);
#line 184 "SequencePathModule.cs"
                int* index_swap = source_indexes;
#line 185 "SequencePathModule.cs"
#line 185 "SequencePathModule.cs"
                int** csharp2cuda_temp_38 = &(source_indexes);
                (*(csharp2cuda_temp_38) = destination_indexes);
#line 186 "SequencePathModule.cs"
#line 186 "SequencePathModule.cs"
                int** csharp2cuda_temp_39 = &(destination_indexes);
                (*(csharp2cuda_temp_39) = index_swap);
            }
#line 140 "SequencePathModule.cs"
            int* csharp2cuda_temp_9 = &(bit);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
        }
    }
#line 188 "SequencePathModule.cs"
    {
#line 188 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 189 "SequencePathModule.cs"
#line 189 "SequencePathModule.cs"
            int csharp2cuda_temp_42 = (source_indexes)[index];
#line 189 "SequencePathModule.cs"
            int* csharp2cuda_temp_43 = &((ranks)[csharp2cuda_temp_42]);
            (*(csharp2cuda_temp_43) = index);
#line 188 "SequencePathModule.cs"
            int* csharp2cuda_temp_40 = &(index);
#line 188 "SequencePathModule.cs"
            int csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
            (*(csharp2cuda_temp_40) = csharp2cuda_i32_add(csharp2cuda_temp_41, blockDim.x));
        }
    }
#line 190 "SequencePathModule.cs"
    __syncthreads();
#line 191 "SequencePathModule.cs"
    if (((thread) == (0)))
    {
#line 192 "SequencePathModule.cs"
#line 192 "SequencePathModule.cs"
        int* csharp2cuda_temp_44 = &((output)->columns);
        (*(csharp2cuda_temp_44) = 0);
    }
#line 193 "SequencePathModule.cs"
    __syncthreads();
}

#line 347 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks)
#line 357 "SequencePathModule.cs"
{
#line 358 "SequencePathModule.cs"
    while (true)
    {
#line 358 "SequencePathModule.cs"
        int csharp2cuda_temp_0 = *(lower_count);
        if (!(((csharp2cuda_temp_0) > (target_lower_count))))
            break;
#line 359 "SequencePathModule.cs"
        {
#line 360 "SequencePathModule.cs"
            int item = (lower_heap)[0];
#line 361 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(lower_heap, lower_count, item, positions, kinds, ranks, true);
#line 369 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(upper_heap, upper_count, item, 1, positions, kinds, ranks, false);
        }
    }
#line 379 "SequencePathModule.cs"
    while (true)
    {
#line 379 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = *(lower_count);
        if (!(((csharp2cuda_temp_1) < (target_lower_count))))
            break;
#line 380 "SequencePathModule.cs"
        {
#line 381 "SequencePathModule.cs"
            int item = (upper_heap)[0];
#line 382 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(upper_heap, upper_count, item, positions, kinds, ranks, false);
#line 390 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(lower_heap, lower_count, item, 0, positions, kinds, ranks, true);
        }
    }
}

#line 528 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const float* values,
    int count,
    float threshold,
    float* value)
#line 534 "SequencePathModule.cs"
{
#line 535 "SequencePathModule.cs"
#line 535 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 535 "SequencePathModule.cs"
    if (!(((count) <= (0))))
    {
#line 535 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((threshold) < (0.0f));
    }
    else
    {
#line 535 "SequencePathModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 536 "SequencePathModule.cs"
        return false;
    }
#line 537 "SequencePathModule.cs"
    long long recurrent = ((long long)(0));
#line 538 "SequencePathModule.cs"
    long long total = csharp2cuda_i64_mul(((long long)(count)), ((long long)(count)));
#line 539 "SequencePathModule.cs"
    {
#line 539 "SequencePathModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 540 "SequencePathModule.cs"
            {
#line 540 "SequencePathModule.cs"
                int right = 0;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 541 "SequencePathModule.cs"
#line 541 "SequencePathModule.cs"
                    float csharp2cuda_temp_3 = (values)[left];
#line 541 "SequencePathModule.cs"
                    float csharp2cuda_temp_4 = (values)[right];
                    if (((fabsf(__fsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4))) <= (threshold)))
                    {
#line 542 "SequencePathModule.cs"
#line 542 "SequencePathModule.cs"
                        long long* csharp2cuda_temp_5 = &(recurrent);
                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_5));
                    }
#line 540 "SequencePathModule.cs"
                    int* csharp2cuda_temp_2 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                }
            }
#line 539 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 543 "SequencePathModule.cs"
#line 543 "SequencePathModule.cs"
    float* csharp2cuda_temp_6 = value;
#line 543 "SequencePathModule.cs"
    float csharp2cuda_temp_7 = __fdiv_rn(((float)(recurrent)), ((float)(total)));
    (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
#line 544 "SequencePathModule.cs"
    return true;
}

#line 402 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const float* values,
    int count,
    int width,
    float* result,
    int* deque,
    bool minimum)
#line 410 "SequencePathModule.cs"
{
#line 411 "SequencePathModule.cs"
    int head = 0;
#line 412 "SequencePathModule.cs"
    int tail = 0;
#line 413 "SequencePathModule.cs"
    {
#line 413 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 414 "SequencePathModule.cs"
            {
#line 415 "SequencePathModule.cs"
                while (true)
                {
#line 415 "SequencePathModule.cs"
                    bool csharp2cuda_temp_1;
#line 415 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 415 "SequencePathModule.cs"
                        int csharp2cuda_temp_2 = (deque)[head];
#line 415 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) <= (csharp2cuda_i32_sub(index, width)));
                    }
                    else
                    {
#line 415 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 416 "SequencePathModule.cs"
#line 416 "SequencePathModule.cs"
                    int* csharp2cuda_temp_3 = &(head);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
#line 417 "SequencePathModule.cs"
                while (true)
                {
#line 417 "SequencePathModule.cs"
                    bool csharp2cuda_temp_4;
#line 417 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 417 "SequencePathModule.cs"
                        bool csharp2cuda_temp_5;
#line 417 "SequencePathModule.cs"
                        if (minimum)
                        {
#line 418 "SequencePathModule.cs"
                            int csharp2cuda_temp_6 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 418 "SequencePathModule.cs"
                            float csharp2cuda_temp_7 = (values)[csharp2cuda_temp_6];
#line 418 "SequencePathModule.cs"
                            float csharp2cuda_temp_8 = (values)[index];
#line 417 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_7) > (csharp2cuda_temp_8));
                        }
                        else
                        {
#line 419 "SequencePathModule.cs"
                            int csharp2cuda_temp_9 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 419 "SequencePathModule.cs"
                            float csharp2cuda_temp_10 = (values)[csharp2cuda_temp_9];
#line 419 "SequencePathModule.cs"
                            float csharp2cuda_temp_11 = (values)[index];
#line 417 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_10) < (csharp2cuda_temp_11));
                        }
#line 417 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = csharp2cuda_temp_5;
                    }
                    else
                    {
#line 417 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = false;
                    }
                    if (!(csharp2cuda_temp_4))
                        break;
#line 420 "SequencePathModule.cs"
                    {
#line 421 "SequencePathModule.cs"
#line 421 "SequencePathModule.cs"
                        int* csharp2cuda_temp_12 = &(tail);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_12));
                    }
                }
#line 423 "SequencePathModule.cs"
#line 423 "SequencePathModule.cs"
                int* csharp2cuda_temp_13 = &(tail);
#line 423 "SequencePathModule.cs"
                int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 423 "SequencePathModule.cs"
                int* csharp2cuda_temp_15 = &((deque)[csharp2cuda_temp_14]);
                (*(csharp2cuda_temp_15) = index);
#line 424 "SequencePathModule.cs"
                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 425 "SequencePathModule.cs"
#line 425 "SequencePathModule.cs"
                    float* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 425 "SequencePathModule.cs"
                    int csharp2cuda_temp_17 = (deque)[head];
#line 425 "SequencePathModule.cs"
                    float csharp2cuda_temp_18 = (values)[csharp2cuda_temp_17];
                    (*(csharp2cuda_temp_16) = csharp2cuda_temp_18);
                }
            }
#line 413 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 429 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const float* values,
    int count,
    int width,
    float* result)
#line 435 "SequencePathModule.cs"
{
#line 436 "SequencePathModule.cs"
    float sum = 0.0f;
#line 437 "SequencePathModule.cs"
    {
#line 437 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (width))))
                break;
#line 438 "SequencePathModule.cs"
#line 438 "SequencePathModule.cs"
            float* csharp2cuda_temp_1 = &(sum);
#line 438 "SequencePathModule.cs"
            float csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 438 "SequencePathModule.cs"
            float csharp2cuda_temp_3 = (values)[index];
            (*(csharp2cuda_temp_1) = __fadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 437 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 439 "SequencePathModule.cs"
#line 439 "SequencePathModule.cs"
    float* csharp2cuda_temp_4 = &((result)[0]);
    (*(csharp2cuda_temp_4) = sum);
#line 440 "SequencePathModule.cs"
    {
#line 440 "SequencePathModule.cs"
        int index = width;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 441 "SequencePathModule.cs"
            {
#line 442 "SequencePathModule.cs"
#line 442 "SequencePathModule.cs"
                float* csharp2cuda_temp_6 = &(sum);
#line 442 "SequencePathModule.cs"
                float csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
#line 442 "SequencePathModule.cs"
                float csharp2cuda_temp_8 = (values)[index];
#line 442 "SequencePathModule.cs"
                float csharp2cuda_temp_9 = (values)[csharp2cuda_i32_sub(index, width)];
                (*(csharp2cuda_temp_6) = __fadd_rn(csharp2cuda_temp_7, __fsub_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 443 "SequencePathModule.cs"
#line 443 "SequencePathModule.cs"
                float* csharp2cuda_temp_10 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
                (*(csharp2cuda_temp_10) = sum);
            }
#line 440 "SequencePathModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
}

#line 67 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns)
#line 72 "SequencePathModule.cs"
{
#line 73 "SequencePathModule.cs"
    long long count = csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)));
#line 74 "SequencePathModule.cs"
#line 74 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = rows);
#line 75 "SequencePathModule.cs"
#line 75 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = columns);
#line 76 "SequencePathModule.cs"
#line 76 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
#line 76 "SequencePathModule.cs"
    int csharp2cuda_temp_3;
#line 76 "SequencePathModule.cs"
    if (((count) > (2147483647LL)))
    {
#line 76 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_neg(1);
    }
    else
    {
#line 76 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_from_bits(count);
    }
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 77 "SequencePathModule.cs"
#line 77 "SequencePathModule.cs"
    bool csharp2cuda_temp_4;
#line 77 "SequencePathModule.cs"
    if (!(((rows) < (0))))
    {
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_4 = ((columns) < (0));
    }
    else
    {
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_4 = true;
    }
#line 77 "SequencePathModule.cs"
    bool csharp2cuda_temp_5;
#line 77 "SequencePathModule.cs"
    if (!(csharp2cuda_temp_4))
    {
#line 77 "SequencePathModule.cs"
        int csharp2cuda_temp_6 = (output)->capacity;
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_5 = ((count) > (((long long)(csharp2cuda_temp_6))));
    }
    else
    {
#line 77 "SequencePathModule.cs"
        csharp2cuda_temp_5 = true;
    }
    if (csharp2cuda_temp_5)
#line 78 "SequencePathModule.cs"
    {
#line 79 "SequencePathModule.cs"
#line 79 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
        (*(csharp2cuda_temp_7) = 0);
#line 80 "SequencePathModule.cs"
        return;
    }
}

#line 54 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count)
#line 56 "SequencePathModule.cs"
{
#line 57 "SequencePathModule.cs"
#line 57 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 58 "SequencePathModule.cs"
#line 58 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 59 "SequencePathModule.cs"
#line 59 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 60 "SequencePathModule.cs"
#line 60 "SequencePathModule.cs"
    bool csharp2cuda_temp_3;
#line 60 "SequencePathModule.cs"
    if (!(((count) < (0))))
    {
#line 60 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 60 "SequencePathModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 60 "SequencePathModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 61 "SequencePathModule.cs"
    {
#line 62 "SequencePathModule.cs"
#line 62 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 63 "SequencePathModule.cs"
        return;
    }
}

#line 548 "SequencePathModule.cs"
__device__ float mathblocks_sequence_sign_change_value(
    const float* values,
    int count,
    bool differenced)
#line 553 "SequencePathModule.cs"
{
#line 554 "SequencePathModule.cs"
    int changes = 0;
#line 555 "SequencePathModule.cs"
    int previous = 0;
#line 556 "SequencePathModule.cs"
    int csharp2cuda_temp_0;
#line 556 "SequencePathModule.cs"
    if (differenced)
    {
#line 556 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 1;
    }
    else
    {
#line 556 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 0;
    }
#line 556 "SequencePathModule.cs"
    int start = csharp2cuda_temp_0;
#line 557 "SequencePathModule.cs"
    {
#line 557 "SequencePathModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 558 "SequencePathModule.cs"
            {
#line 559 "SequencePathModule.cs"
                float csharp2cuda_temp_2;
#line 559 "SequencePathModule.cs"
                if (differenced)
                {
#line 559 "SequencePathModule.cs"
                    float csharp2cuda_temp_3 = (values)[index];
#line 559 "SequencePathModule.cs"
                    float csharp2cuda_temp_4 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 559 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = __fsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4);
                }
                else
                {
#line 559 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = (values)[index];
                }
#line 559 "SequencePathModule.cs"
                float difference = csharp2cuda_temp_2;
#line 560 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 560 "SequencePathModule.cs"
                if (((difference) > (0.0f)))
                {
#line 560 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = 1;
                }
                else
                {
#line 560 "SequencePathModule.cs"
                    int csharp2cuda_temp_6;
#line 560 "SequencePathModule.cs"
                    if (((difference) < (0.0f)))
                    {
#line 560 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = csharp2cuda_i32_neg(1);
                    }
                    else
                    {
#line 560 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = 0;
                    }
#line 560 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = csharp2cuda_temp_6;
                }
#line 560 "SequencePathModule.cs"
                int current = csharp2cuda_temp_5;
#line 561 "SequencePathModule.cs"
                if (((current) == (0)))
                {
#line 562 "SequencePathModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 563 "SequencePathModule.cs"
#line 563 "SequencePathModule.cs"
                bool csharp2cuda_temp_7;
#line 563 "SequencePathModule.cs"
                if (((previous) != (0)))
                {
#line 563 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = ((current) != (previous));
                }
                else
                {
#line 563 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = false;
                }
                if (csharp2cuda_temp_7)
                {
#line 564 "SequencePathModule.cs"
#line 564 "SequencePathModule.cs"
                    int* csharp2cuda_temp_8 = &(changes);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_8));
                }
#line 565 "SequencePathModule.cs"
#line 565 "SequencePathModule.cs"
                int* csharp2cuda_temp_9 = &(previous);
                (*(csharp2cuda_temp_9) = current);
            }
            csharp2cuda_for_continue_0:
#line 557 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 567 "SequencePathModule.cs"
    return ((float)(changes));
}

#line 506 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const float* values,
    int count,
    float order,
    bool absolute,
    float* value)
#line 513 "SequencePathModule.cs"
{
#line 514 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 515 "SequencePathModule.cs"
        return false;
    }
#line 516 "SequencePathModule.cs"
    if ((!(((order) > (0.0f)))))
    {
#line 517 "SequencePathModule.cs"
        return false;
    }
#line 518 "SequencePathModule.cs"
    float total = 0.0f;
#line 519 "SequencePathModule.cs"
    {
#line 519 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 520 "SequencePathModule.cs"
            {
#line 521 "SequencePathModule.cs"
                float csharp2cuda_temp_1 = (values)[index];
#line 521 "SequencePathModule.cs"
                float csharp2cuda_temp_2 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 521 "SequencePathModule.cs"
                float change = fabsf(__fsub_rn(csharp2cuda_temp_1, csharp2cuda_temp_2));
#line 522 "SequencePathModule.cs"
#line 522 "SequencePathModule.cs"
                float* csharp2cuda_temp_3 = &(total);
#line 522 "SequencePathModule.cs"
                float csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 522 "SequencePathModule.cs"
                float csharp2cuda_temp_5;
#line 522 "SequencePathModule.cs"
                if (absolute)
                {
#line 522 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = change;
                }
                else
                {
#line 522 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = mathblocks_power(change, order);
                }
                (*(csharp2cuda_temp_3) = __fadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
            }
#line 519 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 524 "SequencePathModule.cs"
#line 524 "SequencePathModule.cs"
    float* csharp2cuda_temp_6 = value;
    (*(csharp2cuda_temp_6) = total);
#line 525 "SequencePathModule.cs"
    return isfinite(total);
}