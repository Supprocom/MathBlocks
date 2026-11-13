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

#line 38 "SequencePathModule.cs"
struct MathBlockSequencePathRun
{
    int start;
    int length;
    double value;
};

#line 478 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const double* values,
    int count,
    bool relative,
    double* value);

#line 444 "SequencePathModule.cs"
__device__ double mathblocks_sequence_first_passage_value(
    const double* values,
    int count,
    double threshold,
    bool at_or_above);

#line 278 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 207 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum);

#line 301 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum);

#line 243 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 219 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum);

#line 193 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions);

#line 92 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value);

#line 463 "SequencePathModule.cs"
__device__ double mathblocks_sequence_longest_run_value(
    const int* values,
    int count);

#line 81 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(double value);

#line 567 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 45 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(double value, int* result);

#line 98 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const double* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output);

#line 344 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks);

#line 525 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const double* values,
    int count,
    double threshold,
    double* value);

#line 399 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const double* values,
    int count,
    int width,
    double* result,
    int* deque,
    bool minimum);

#line 426 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const double* values,
    int count,
    int width,
    double* result);

#line 64 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns);

#line 51 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count);

#line 545 "SequencePathModule.cs"
__device__ double mathblocks_sequence_sign_change_value(
    const double* values,
    int count,
    bool differenced);

#line 503 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const double* values,
    int count,
    double order,
    bool absolute,
    double* value);

#line 478 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_decline_value(
    const double* values,
    int count,
    bool relative,
    double* value)
#line 484 "SequencePathModule.cs"
{
#line 485 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 486 "SequencePathModule.cs"
        return false;
    }
#line 487 "SequencePathModule.cs"
    double maximum = (values)[0];
#line 488 "SequencePathModule.cs"
    double decline = 0.0;
#line 489 "SequencePathModule.cs"
    {
#line 489 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 490 "SequencePathModule.cs"
            {
#line 492 "SequencePathModule.cs"
#line 492 "SequencePathModule.cs"
                double* csharp2cuda_temp_1 = &(maximum);
#line 492 "SequencePathModule.cs"
                double csharp2cuda_temp_2 = (values)[index];
                (*(csharp2cuda_temp_1) = mathblocks_maximum(maximum, csharp2cuda_temp_2));
#line 493 "SequencePathModule.cs"
                double csharp2cuda_temp_3;
#line 493 "SequencePathModule.cs"
                if ((!(relative)))
                {
#line 494 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[index];
#line 493 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = __dsub_rn(maximum, csharp2cuda_temp_4);
                }
                else
                {
#line 495 "SequencePathModule.cs"
                    double csharp2cuda_temp_5 = (values)[index];
#line 493 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = __ddiv_rn(__dsub_rn(maximum, csharp2cuda_temp_5), maximum);
                }
#line 493 "SequencePathModule.cs"
                double candidate = csharp2cuda_temp_3;
#line 496 "SequencePathModule.cs"
#line 496 "SequencePathModule.cs"
                double* csharp2cuda_temp_6 = &(decline);
                (*(csharp2cuda_temp_6) = mathblocks_maximum(decline, candidate));
            }
#line 489 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 498 "SequencePathModule.cs"
#line 498 "SequencePathModule.cs"
    double* csharp2cuda_temp_7 = value;
    (*(csharp2cuda_temp_7) = decline);
#line 499 "SequencePathModule.cs"
    return isfinite(decline);
}

#line 444 "SequencePathModule.cs"
__device__ double mathblocks_sequence_first_passage_value(
    const double* values,
    int count,
    double threshold,
    bool at_or_above)
#line 450 "SequencePathModule.cs"
{
#line 451 "SequencePathModule.cs"
    int result_index = -1;
#line 452 "SequencePathModule.cs"
    {
#line 452 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 453 "SequencePathModule.cs"
            {
#line 454 "SequencePathModule.cs"
#line 454 "SequencePathModule.cs"
                bool csharp2cuda_temp_1;
#line 454 "SequencePathModule.cs"
                if (at_or_above)
                {
#line 454 "SequencePathModule.cs"
                    double csharp2cuda_temp_2 = (values)[index];
#line 454 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_2) >= (threshold));
                }
                else
                {
#line 454 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[index];
#line 454 "SequencePathModule.cs"
                    csharp2cuda_temp_1 = ((csharp2cuda_temp_3) <= (threshold));
                }
                if (csharp2cuda_temp_1)
#line 455 "SequencePathModule.cs"
                {
#line 456 "SequencePathModule.cs"
#line 456 "SequencePathModule.cs"
                    int* csharp2cuda_temp_4 = &(result_index);
                    (*(csharp2cuda_temp_4) = index);
#line 457 "SequencePathModule.cs"
                    break;
                }
            }
#line 452 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 460 "SequencePathModule.cs"
    return ((double)(result_index));
}

#line 278 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_insert(
    int* heap,
    int* count,
    int item,
    int kind,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 288 "SequencePathModule.cs"
{
#line 289 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 289 "SequencePathModule.cs"
    int position = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
#line 290 "SequencePathModule.cs"
#line 290 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((heap)[position]);
    (*(csharp2cuda_temp_1) = item);
#line 291 "SequencePathModule.cs"
#line 291 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((positions)[item]);
    (*(csharp2cuda_temp_2) = position);
#line 292 "SequencePathModule.cs"
#line 292 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((kinds)[item]);
    (*(csharp2cuda_temp_3) = kind);
#line 293 "SequencePathModule.cs"
    mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
}

#line 207 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_heap_precedes(
    int left,
    int right,
    const int* ranks,
    bool maximum)
#line 213 "SequencePathModule.cs"
{
#line 214 "SequencePathModule.cs"
#line 214 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 214 "SequencePathModule.cs"
    if (maximum)
    {
#line 215 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = (ranks)[left];
#line 215 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = (ranks)[right];
#line 214 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_1) > (csharp2cuda_temp_2));
    }
    else
    {
#line 216 "SequencePathModule.cs"
        int csharp2cuda_temp_3 = (ranks)[left];
#line 216 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (ranks)[right];
#line 214 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_temp_3) < (csharp2cuda_temp_4));
    }
    return csharp2cuda_temp_0;
}

#line 301 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_remove(
    int* heap,
    int* count,
    int item,
    int* positions,
    int* kinds,
    const int* ranks,
    bool maximum)
#line 310 "SequencePathModule.cs"
{
#line 311 "SequencePathModule.cs"
    int position = (positions)[item];
#line 312 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = count;
#line 312 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = csharp2cuda_i32_pre_decrement(*(csharp2cuda_temp_0));
#line 312 "SequencePathModule.cs"
    int replacement = (heap)[csharp2cuda_temp_1];
#line 313 "SequencePathModule.cs"
#line 313 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((kinds)[item]);
    (*(csharp2cuda_temp_2) = csharp2cuda_i32_neg(1));
#line 314 "SequencePathModule.cs"
#line 314 "SequencePathModule.cs"
    int* csharp2cuda_temp_3 = &((positions)[item]);
    (*(csharp2cuda_temp_3) = csharp2cuda_i32_neg(1));
#line 315 "SequencePathModule.cs"
#line 315 "SequencePathModule.cs"
    int csharp2cuda_temp_4 = *(count);
    if (((position) >= (csharp2cuda_temp_4)))
    {
#line 316 "SequencePathModule.cs"
        return;
    }
#line 317 "SequencePathModule.cs"
#line 317 "SequencePathModule.cs"
    int* csharp2cuda_temp_5 = &((heap)[position]);
    (*(csharp2cuda_temp_5) = replacement);
#line 318 "SequencePathModule.cs"
#line 318 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[replacement]);
    (*(csharp2cuda_temp_6) = position);
#line 319 "SequencePathModule.cs"
#line 319 "SequencePathModule.cs"
    bool csharp2cuda_temp_7;
#line 319 "SequencePathModule.cs"
    if (((position) > (0)))
    {
#line 320 "SequencePathModule.cs"
        int csharp2cuda_temp_8 = (heap)[position];
#line 321 "SequencePathModule.cs"
        int csharp2cuda_temp_9 = (heap)[csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1)];
#line 319 "SequencePathModule.cs"
        csharp2cuda_temp_7 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_8, csharp2cuda_temp_9, ranks, maximum);
    }
    else
    {
#line 319 "SequencePathModule.cs"
        csharp2cuda_temp_7 = false;
    }
    if (csharp2cuda_temp_7)
#line 324 "SequencePathModule.cs"
    {
#line 325 "SequencePathModule.cs"
        mathblocks_sequence_heap_sift_up(heap, position, positions, ranks, maximum);
    }
    else
#line 333 "SequencePathModule.cs"
    {
#line 334 "SequencePathModule.cs"
#line 336 "SequencePathModule.cs"
        int csharp2cuda_temp_10 = *(count);
        mathblocks_sequence_heap_sift_down(heap, csharp2cuda_temp_10, position, positions, ranks, maximum);
    }
}

#line 243 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_down(
    int* heap,
    int count,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 251 "SequencePathModule.cs"
{
#line 252 "SequencePathModule.cs"
    while (true)
    {
        if (!(true))
            break;
#line 253 "SequencePathModule.cs"
        {
#line 254 "SequencePathModule.cs"
            int left = csharp2cuda_i32_add(csharp2cuda_i32_mul(position, 2), 1);
#line 255 "SequencePathModule.cs"
            if (((left) >= (count)))
            {
#line 256 "SequencePathModule.cs"
                return;
            }
#line 257 "SequencePathModule.cs"
            int right = csharp2cuda_i32_add(left, 1);
#line 258 "SequencePathModule.cs"
            bool csharp2cuda_temp_0;
#line 258 "SequencePathModule.cs"
            if (((right) < (count)))
            {
#line 259 "SequencePathModule.cs"
                int csharp2cuda_temp_1 = (heap)[right];
#line 260 "SequencePathModule.cs"
                int csharp2cuda_temp_2 = (heap)[left];
#line 258 "SequencePathModule.cs"
                csharp2cuda_temp_0 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_1, csharp2cuda_temp_2, ranks, maximum);
            }
            else
            {
#line 258 "SequencePathModule.cs"
                csharp2cuda_temp_0 = false;
            }
#line 258 "SequencePathModule.cs"
            int csharp2cuda_temp_3;
#line 258 "SequencePathModule.cs"
            if (csharp2cuda_temp_0)
            {
#line 258 "SequencePathModule.cs"
                csharp2cuda_temp_3 = right;
            }
            else
            {
#line 258 "SequencePathModule.cs"
                csharp2cuda_temp_3 = left;
            }
#line 258 "SequencePathModule.cs"
            int selected = csharp2cuda_temp_3;
#line 265 "SequencePathModule.cs"
#line 266 "SequencePathModule.cs"
            int csharp2cuda_temp_4 = (heap)[selected];
#line 267 "SequencePathModule.cs"
            int csharp2cuda_temp_5 = (heap)[position];
#line 265 "SequencePathModule.cs"
            bool csharp2cuda_temp_6 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_4, csharp2cuda_temp_5, ranks, maximum);
            if ((!(csharp2cuda_temp_6)))
#line 270 "SequencePathModule.cs"
            {
#line 271 "SequencePathModule.cs"
                return;
            }
#line 273 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, selected, positions);
#line 274 "SequencePathModule.cs"
#line 274 "SequencePathModule.cs"
            int* csharp2cuda_temp_7 = &(position);
            (*(csharp2cuda_temp_7) = selected);
        }
    }
}

#line 219 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_sift_up(
    int* heap,
    int position,
    int* positions,
    const int* ranks,
    bool maximum)
#line 226 "SequencePathModule.cs"
{
#line 227 "SequencePathModule.cs"
    while (true)
    {
        if (!(((position) > (0))))
            break;
#line 228 "SequencePathModule.cs"
        {
#line 229 "SequencePathModule.cs"
            int parent = csharp2cuda_i32_shr(csharp2cuda_i32_sub(position, 1), 1);
#line 230 "SequencePathModule.cs"
#line 231 "SequencePathModule.cs"
            int csharp2cuda_temp_0 = (heap)[position];
#line 232 "SequencePathModule.cs"
            int csharp2cuda_temp_1 = (heap)[parent];
#line 230 "SequencePathModule.cs"
            bool csharp2cuda_temp_2 = mathblocks_sequence_heap_precedes(csharp2cuda_temp_0, csharp2cuda_temp_1, ranks, maximum);
            if ((!(csharp2cuda_temp_2)))
#line 235 "SequencePathModule.cs"
            {
#line 236 "SequencePathModule.cs"
                break;
            }
#line 238 "SequencePathModule.cs"
            mathblocks_sequence_heap_swap(heap, position, parent, positions);
#line 239 "SequencePathModule.cs"
#line 239 "SequencePathModule.cs"
            int* csharp2cuda_temp_3 = &(position);
            (*(csharp2cuda_temp_3) = parent);
        }
    }
}

#line 193 "SequencePathModule.cs"
__device__ void mathblocks_sequence_heap_swap(
    int* heap,
    int left,
    int right,
    int* positions)
#line 199 "SequencePathModule.cs"
{
#line 200 "SequencePathModule.cs"
    int value = (heap)[left];
#line 201 "SequencePathModule.cs"
#line 201 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((heap)[left]);
#line 201 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (heap)[right];
    (*(csharp2cuda_temp_0) = csharp2cuda_temp_1);
#line 202 "SequencePathModule.cs"
#line 202 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((heap)[right]);
    (*(csharp2cuda_temp_2) = value);
#line 203 "SequencePathModule.cs"
#line 203 "SequencePathModule.cs"
    int csharp2cuda_temp_3 = (heap)[left];
#line 203 "SequencePathModule.cs"
    int* csharp2cuda_temp_4 = &((positions)[csharp2cuda_temp_3]);
    (*(csharp2cuda_temp_4) = left);
#line 204 "SequencePathModule.cs"
#line 204 "SequencePathModule.cs"
    int csharp2cuda_temp_5 = (heap)[right];
#line 204 "SequencePathModule.cs"
    int* csharp2cuda_temp_6 = &((positions)[csharp2cuda_temp_5]);
    (*(csharp2cuda_temp_6) = right);
}

#line 92 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_is_power_of_two(int value)
#line 94 "SequencePathModule.cs"
{
#line 95 "SequencePathModule.cs"
#line 95 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 95 "SequencePathModule.cs"
    if (((value) > (0)))
    {
#line 95 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((csharp2cuda_i32_and(value, csharp2cuda_i32_sub(value, 1))) == (0));
    }
    else
    {
#line 95 "SequencePathModule.cs"
        csharp2cuda_temp_0 = false;
    }
    return csharp2cuda_temp_0;
}

#line 463 "SequencePathModule.cs"
__device__ double mathblocks_sequence_longest_run_value(
    const int* values,
    int count)
#line 467 "SequencePathModule.cs"
{
#line 468 "SequencePathModule.cs"
    int maximum = 0;
#line 469 "SequencePathModule.cs"
    int current = 0;
#line 470 "SequencePathModule.cs"
    {
#line 470 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 471 "SequencePathModule.cs"
            {
#line 472 "SequencePathModule.cs"
#line 472 "SequencePathModule.cs"
                int* csharp2cuda_temp_1 = &(current);
#line 472 "SequencePathModule.cs"
                bool csharp2cuda_temp_2 = (values)[index];
#line 472 "SequencePathModule.cs"
                int csharp2cuda_temp_3;
#line 472 "SequencePathModule.cs"
                if (csharp2cuda_temp_2)
                {
#line 472 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = csharp2cuda_i32_add(current, 1);
                }
                else
                {
#line 472 "SequencePathModule.cs"
                    csharp2cuda_temp_3 = 0;
                }
                (*(csharp2cuda_temp_1) = csharp2cuda_temp_3);
#line 473 "SequencePathModule.cs"
#line 473 "SequencePathModule.cs"
                int* csharp2cuda_temp_4 = &(maximum);
#line 473 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 473 "SequencePathModule.cs"
                if (((maximum) > (current)))
                {
#line 473 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = maximum;
                }
                else
                {
#line 473 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = current;
                }
                (*(csharp2cuda_temp_4) = csharp2cuda_temp_5);
            }
#line 470 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 475 "SequencePathModule.cs"
    return ((double)(maximum));
}

#line 81 "SequencePathModule.cs"
__device__ unsigned long long mathblocks_sequence_order_key(double value)
#line 83 "SequencePathModule.cs"
{
#line 84 "SequencePathModule.cs"
    unsigned long long bits = ((unsigned long long)(__double_as_longlong(value)));
#line 85 "SequencePathModule.cs"
    if (((value) == (0.0)))
    {
#line 86 "SequencePathModule.cs"
#line 86 "SequencePathModule.cs"
        unsigned long long* csharp2cuda_temp_0 = &(bits);
        (*(csharp2cuda_temp_0) = 0ull);
    }
#line 87 "SequencePathModule.cs"
#line 87 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_1;
#line 87 "SequencePathModule.cs"
    if (((((bits) & (9223372036854775808ull))) != (0ull)))
    {
#line 87 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (~(bits));
    }
    else
    {
#line 87 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((bits) ^ (9223372036854775808ull));
    }
    return csharp2cuda_temp_1;
}

#line 567 "SequencePathModule.cs"
__device__ void mathblocks_sequence_path_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 573 "SequencePathModule.cs"
{
#line 574 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 575 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 575 "SequencePathModule.cs"
    if (((input_count) > (0)))
    {
#line 575 "SequencePathModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 575 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 575 "SequencePathModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 576 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 576 "SequencePathModule.cs"
    if (((input_count) > (1)))
    {
#line 576 "SequencePathModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 576 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 576 "SequencePathModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 577 "SequencePathModule.cs"
    MathBlockSlot* csharp2cuda_temp_2;
#line 577 "SequencePathModule.cs"
    if (((input_count) > (2)))
    {
#line 577 "SequencePathModule.cs"
        csharp2cuda_temp_2 = (inputs)[2];
    }
    else
    {
#line 577 "SequencePathModule.cs"
        csharp2cuda_temp_2 = ((MathBlockSlot*)(nullptr));
    }
#line 577 "SequencePathModule.cs"
    const MathBlockSlot* third = csharp2cuda_temp_2;
#line 578 "SequencePathModule.cs"
    if (((thread) == (0)))
#line 579 "SequencePathModule.cs"
    {
#line 580 "SequencePathModule.cs"
#line 580 "SequencePathModule.cs"
        double* csharp2cuda_temp_3 = &((output)->scalar_value);
        (*(csharp2cuda_temp_3) = 0.0);
#line 581 "SequencePathModule.cs"
#line 581 "SequencePathModule.cs"
        int* csharp2cuda_temp_4 = &((output)->boolean_value);
        (*(csharp2cuda_temp_4) = 0);
#line 582 "SequencePathModule.cs"
#line 582 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->rows);
        (*(csharp2cuda_temp_5) = 0);
#line 583 "SequencePathModule.cs"
#line 583 "SequencePathModule.cs"
        int* csharp2cuda_temp_6 = &((output)->columns);
        (*(csharp2cuda_temp_6) = 0);
#line 584 "SequencePathModule.cs"
#line 584 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->count);
        (*(csharp2cuda_temp_7) = 0);
#line 585 "SequencePathModule.cs"
#line 585 "SequencePathModule.cs"
        int* csharp2cuda_temp_8 = &((output)->valid);
#line 585 "SequencePathModule.cs"
        bool csharp2cuda_temp_9;
#line 585 "SequencePathModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 585 "SequencePathModule.cs"
            csharp2cuda_temp_9 = (first)->valid;
        }
        else
        {
#line 585 "SequencePathModule.cs"
            csharp2cuda_temp_9 = true;
        }
        (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 586 "SequencePathModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 587 "SequencePathModule.cs"
#line 587 "SequencePathModule.cs"
            int* csharp2cuda_temp_10 = &((output)->valid);
#line 587 "SequencePathModule.cs"
            bool csharp2cuda_temp_11 = (output)->valid;
#line 587 "SequencePathModule.cs"
            bool csharp2cuda_temp_12;
#line 587 "SequencePathModule.cs"
            if (csharp2cuda_temp_11)
            {
#line 587 "SequencePathModule.cs"
                csharp2cuda_temp_12 = (second)->valid;
            }
            else
            {
#line 587 "SequencePathModule.cs"
                csharp2cuda_temp_12 = false;
            }
            (*(csharp2cuda_temp_10) = csharp2cuda_temp_12);
        }
#line 588 "SequencePathModule.cs"
        if (((((void*)(third))) != (((void*)(nullptr)))))
        {
#line 589 "SequencePathModule.cs"
#line 589 "SequencePathModule.cs"
            int* csharp2cuda_temp_13 = &((output)->valid);
#line 589 "SequencePathModule.cs"
            bool csharp2cuda_temp_14 = (output)->valid;
#line 589 "SequencePathModule.cs"
            bool csharp2cuda_temp_15;
#line 589 "SequencePathModule.cs"
            if (csharp2cuda_temp_14)
            {
#line 589 "SequencePathModule.cs"
                csharp2cuda_temp_15 = (third)->valid;
            }
            else
            {
#line 589 "SequencePathModule.cs"
                csharp2cuda_temp_15 = false;
            }
            (*(csharp2cuda_temp_13) = csharp2cuda_temp_15);
        }
    }
#line 591 "SequencePathModule.cs"
    __syncthreads();
#line 592 "SequencePathModule.cs"
#line 592 "SequencePathModule.cs"
    bool csharp2cuda_temp_16 = (output)->valid;
    if ((!(csharp2cuda_temp_16)))
    {
#line 593 "SequencePathModule.cs"
        return;
    }
#line 595 "SequencePathModule.cs"
    double* csharp2cuda_temp_17;
#line 595 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 595 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((double*)(nullptr));
    }
    else
    {
#line 595 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_18 = (first)->data_pointer;
#line 595 "SequencePathModule.cs"
        csharp2cuda_temp_17 = ((double*)(csharp2cuda_temp_18));
    }
#line 595 "SequencePathModule.cs"
    const double* a = csharp2cuda_temp_17;
#line 596 "SequencePathModule.cs"
    double* csharp2cuda_temp_19;
#line 596 "SequencePathModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 596 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((double*)(nullptr));
    }
    else
    {
#line 596 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_20 = (second)->data_pointer;
#line 596 "SequencePathModule.cs"
        csharp2cuda_temp_19 = ((double*)(csharp2cuda_temp_20));
    }
#line 596 "SequencePathModule.cs"
    const double* b = csharp2cuda_temp_19;
#line 597 "SequencePathModule.cs"
    int* csharp2cuda_temp_21;
#line 597 "SequencePathModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 597 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(nullptr));
    }
    else
    {
#line 597 "SequencePathModule.cs"
        unsigned long long csharp2cuda_temp_22 = (first)->data_pointer;
#line 597 "SequencePathModule.cs"
        csharp2cuda_temp_21 = ((int*)(csharp2cuda_temp_22));
    }
#line 597 "SequencePathModule.cs"
    const int* boolean_a = csharp2cuda_temp_21;
#line 598 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_23 = (output)->data_pointer;
#line 598 "SequencePathModule.cs"
    double* result = ((double*)(csharp2cuda_temp_23));
#line 599 "SequencePathModule.cs"
    unsigned long long csharp2cuda_temp_24 = (output)->scratch_pointer;
#line 599 "SequencePathModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_24));
#line 605 "SequencePathModule.cs"
    if (((opcode) == (0)))
#line 606 "SequencePathModule.cs"
    {
#line 607 "SequencePathModule.cs"
        int csharp2cuda_temp_25 = (first)->count;
#line 607 "SequencePathModule.cs"
        int csharp2cuda_temp_26 = (second)->count;
#line 607 "SequencePathModule.cs"
        int convolution_count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_25, csharp2cuda_temp_26), 1);
#line 608 "SequencePathModule.cs"
#line 608 "SequencePathModule.cs"
        int csharp2cuda_temp_27 = (first)->count;
#line 608 "SequencePathModule.cs"
        bool csharp2cuda_temp_28;
#line 608 "SequencePathModule.cs"
        if (((csharp2cuda_temp_27) > (0)))
        {
#line 608 "SequencePathModule.cs"
            int csharp2cuda_temp_29 = (second)->count;
#line 608 "SequencePathModule.cs"
            csharp2cuda_temp_28 = ((csharp2cuda_temp_29) > (0));
        }
        else
        {
#line 608 "SequencePathModule.cs"
            csharp2cuda_temp_28 = false;
        }
#line 608 "SequencePathModule.cs"
        bool csharp2cuda_temp_30;
#line 608 "SequencePathModule.cs"
        if (csharp2cuda_temp_28)
        {
#line 608 "SequencePathModule.cs"
            int csharp2cuda_temp_31 = (output)->capacity;
#line 608 "SequencePathModule.cs"
            csharp2cuda_temp_30 = ((convolution_count) <= (csharp2cuda_temp_31));
        }
        else
        {
#line 608 "SequencePathModule.cs"
            csharp2cuda_temp_30 = false;
        }
        if (csharp2cuda_temp_30)
#line 609 "SequencePathModule.cs"
        {
#line 610 "SequencePathModule.cs"
            {
#line 610 "SequencePathModule.cs"
                int output_index = thread;
                while (true)
                {
                    if (!(((output_index) < (convolution_count))))
                        break;
#line 611 "SequencePathModule.cs"
                    {
#line 612 "SequencePathModule.cs"
                        int csharp2cuda_temp_34 = (second)->count;
#line 612 "SequencePathModule.cs"
                        int low = csharp2cuda_i32_sub(output_index, csharp2cuda_i32_sub(csharp2cuda_temp_34, 1));
#line 613 "SequencePathModule.cs"
                        int csharp2cuda_temp_35;
#line 613 "SequencePathModule.cs"
                        if (((low) > (0)))
                        {
#line 613 "SequencePathModule.cs"
                            csharp2cuda_temp_35 = low;
                        }
                        else
                        {
#line 613 "SequencePathModule.cs"
                            csharp2cuda_temp_35 = 0;
                        }
#line 613 "SequencePathModule.cs"
                        int left_start = csharp2cuda_temp_35;
#line 614 "SequencePathModule.cs"
                        int csharp2cuda_temp_36 = (first)->count;
#line 614 "SequencePathModule.cs"
                        int csharp2cuda_temp_37;
#line 614 "SequencePathModule.cs"
                        if (((output_index) < (csharp2cuda_i32_sub(csharp2cuda_temp_36, 1))))
                        {
#line 614 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = output_index;
                        }
                        else
                        {
#line 614 "SequencePathModule.cs"
                            int csharp2cuda_temp_38 = (first)->count;
#line 614 "SequencePathModule.cs"
                            csharp2cuda_temp_37 = csharp2cuda_i32_sub(csharp2cuda_temp_38, 1);
                        }
#line 614 "SequencePathModule.cs"
                        int left_end = csharp2cuda_temp_37;
#line 615 "SequencePathModule.cs"
                        double sum = 0.0;
#line 616 "SequencePathModule.cs"
                        {
#line 616 "SequencePathModule.cs"
                            int left = left_start;
                            while (true)
                            {
                                if (!(((left) <= (left_end))))
                                    break;
#line 617 "SequencePathModule.cs"
#line 617 "SequencePathModule.cs"
                                double* csharp2cuda_temp_40 = &(sum);
#line 617 "SequencePathModule.cs"
                                double csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
#line 617 "SequencePathModule.cs"
                                double csharp2cuda_temp_42 = (a)[left];
#line 617 "SequencePathModule.cs"
                                double csharp2cuda_temp_43 = (b)[csharp2cuda_i32_sub(output_index, left)];
                                (*(csharp2cuda_temp_40) = __dadd_rn(csharp2cuda_temp_41, __dmul_rn(csharp2cuda_temp_42, csharp2cuda_temp_43)));
#line 616 "SequencePathModule.cs"
                                int* csharp2cuda_temp_39 = &(left);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_39));
                            }
                        }
#line 618 "SequencePathModule.cs"
#line 618 "SequencePathModule.cs"
                        double* csharp2cuda_temp_44 = &((result)[output_index]);
                        (*(csharp2cuda_temp_44) = sum);
                    }
#line 610 "SequencePathModule.cs"
                    int* csharp2cuda_temp_32 = &(output_index);
#line 610 "SequencePathModule.cs"
                    int csharp2cuda_temp_33 = *(csharp2cuda_temp_32);
                    (*(csharp2cuda_temp_32) = csharp2cuda_i32_add(csharp2cuda_temp_33, blockDim.x));
                }
            }
        }
#line 621 "SequencePathModule.cs"
        __syncthreads();
    }
#line 624 "SequencePathModule.cs"
    switch (opcode)
    {
#line 626 "SequencePathModule.cs"
        case 0:
#line 627 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 628 "SequencePathModule.cs"
            {
#line 629 "SequencePathModule.cs"
                int csharp2cuda_temp_45 = (first)->count;
#line 629 "SequencePathModule.cs"
                int csharp2cuda_temp_46 = (second)->count;
#line 629 "SequencePathModule.cs"
                int count = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_45, csharp2cuda_temp_46), 1);
#line 630 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 631 "SequencePathModule.cs"
#line 631 "SequencePathModule.cs"
                int csharp2cuda_temp_47 = (first)->count;
#line 631 "SequencePathModule.cs"
                bool csharp2cuda_temp_48;
#line 631 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_47) <= (0))))
                {
#line 631 "SequencePathModule.cs"
                    int csharp2cuda_temp_49 = (second)->count;
#line 631 "SequencePathModule.cs"
                    csharp2cuda_temp_48 = ((csharp2cuda_temp_49) <= (0));
                }
                else
                {
#line 631 "SequencePathModule.cs"
                    csharp2cuda_temp_48 = true;
                }
                if (csharp2cuda_temp_48)
                {
#line 632 "SequencePathModule.cs"
#line 632 "SequencePathModule.cs"
                    int* csharp2cuda_temp_50 = &((output)->valid);
                    (*(csharp2cuda_temp_50) = 0);
                }
#line 636 "SequencePathModule.cs"
                bool finite = true;
#line 637 "SequencePathModule.cs"
                {
#line 637 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 637 "SequencePathModule.cs"
                        bool csharp2cuda_temp_52 = (output)->valid;
#line 637 "SequencePathModule.cs"
                        bool csharp2cuda_temp_53;
#line 637 "SequencePathModule.cs"
                        if (csharp2cuda_temp_52)
                        {
#line 637 "SequencePathModule.cs"
                            csharp2cuda_temp_53 = ((index) < (count));
                        }
                        else
                        {
#line 637 "SequencePathModule.cs"
                            csharp2cuda_temp_53 = false;
                        }
                        if (!(csharp2cuda_temp_53))
                            break;
#line 638 "SequencePathModule.cs"
#line 638 "SequencePathModule.cs"
                        double csharp2cuda_temp_54 = (result)[index];
                        if ((!(isfinite(csharp2cuda_temp_54))))
                        {
#line 639 "SequencePathModule.cs"
#line 639 "SequencePathModule.cs"
                            bool* csharp2cuda_temp_55 = &(finite);
                            (*(csharp2cuda_temp_55) = false);
                        }
#line 637 "SequencePathModule.cs"
                        int* csharp2cuda_temp_51 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_51));
                    }
                }
#line 640 "SequencePathModule.cs"
                if (finite)
                {
#line 641 "SequencePathModule.cs"
                    break;
                }
#line 642 "SequencePathModule.cs"
                {
#line 642 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 642 "SequencePathModule.cs"
                        bool csharp2cuda_temp_57 = (output)->valid;
#line 642 "SequencePathModule.cs"
                        bool csharp2cuda_temp_58;
#line 642 "SequencePathModule.cs"
                        if (csharp2cuda_temp_57)
                        {
#line 642 "SequencePathModule.cs"
                            csharp2cuda_temp_58 = ((index) < (count));
                        }
                        else
                        {
#line 642 "SequencePathModule.cs"
                            csharp2cuda_temp_58 = false;
                        }
                        if (!(csharp2cuda_temp_58))
                            break;
#line 643 "SequencePathModule.cs"
#line 643 "SequencePathModule.cs"
                        double* csharp2cuda_temp_59 = &((result)[index]);
                        (*(csharp2cuda_temp_59) = 0.0);
#line 642 "SequencePathModule.cs"
                        int* csharp2cuda_temp_56 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_56));
                    }
                }
#line 644 "SequencePathModule.cs"
                {
#line 644 "SequencePathModule.cs"
                    int left = 0;
                    while (true)
                    {
#line 644 "SequencePathModule.cs"
                        bool csharp2cuda_temp_61 = (output)->valid;
#line 644 "SequencePathModule.cs"
                        bool csharp2cuda_temp_62;
#line 644 "SequencePathModule.cs"
                        if (csharp2cuda_temp_61)
                        {
#line 644 "SequencePathModule.cs"
                            int csharp2cuda_temp_63 = (first)->count;
#line 644 "SequencePathModule.cs"
                            csharp2cuda_temp_62 = ((left) < (csharp2cuda_temp_63));
                        }
                        else
                        {
#line 644 "SequencePathModule.cs"
                            csharp2cuda_temp_62 = false;
                        }
                        if (!(csharp2cuda_temp_62))
                            break;
#line 645 "SequencePathModule.cs"
                        {
#line 646 "SequencePathModule.cs"
                            {
#line 646 "SequencePathModule.cs"
                                int right = 0;
                                while (true)
                                {
#line 646 "SequencePathModule.cs"
                                    int csharp2cuda_temp_65 = (second)->count;
                                    if (!(((right) < (csharp2cuda_temp_65))))
                                        break;
#line 647 "SequencePathModule.cs"
                                    {
#line 648 "SequencePathModule.cs"
#line 648 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_66 = &((result)[csharp2cuda_i32_add(left, right)]);
#line 648 "SequencePathModule.cs"
                                        double csharp2cuda_temp_67 = *(csharp2cuda_temp_66);
#line 648 "SequencePathModule.cs"
                                        double csharp2cuda_temp_68 = (a)[left];
#line 648 "SequencePathModule.cs"
                                        double csharp2cuda_temp_69 = (b)[right];
                                        (*(csharp2cuda_temp_66) = __dadd_rn(csharp2cuda_temp_67, __dmul_rn(csharp2cuda_temp_68, csharp2cuda_temp_69)));
#line 649 "SequencePathModule.cs"
#line 649 "SequencePathModule.cs"
                                        double csharp2cuda_temp_70 = (result)[csharp2cuda_i32_add(left, right)];
                                        if ((!(isfinite(csharp2cuda_temp_70))))
                                        {
#line 650 "SequencePathModule.cs"
#line 650 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_71 = &((output)->valid);
                                            (*(csharp2cuda_temp_71) = 0);
                                        }
                                    }
#line 646 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_64 = &(right);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_64));
                                }
                            }
                        }
#line 644 "SequencePathModule.cs"
                        int* csharp2cuda_temp_60 = &(left);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_60));
                    }
                }
            }
#line 654 "SequencePathModule.cs"
            break;
#line 655 "SequencePathModule.cs"
        case 1:
#line 656 "SequencePathModule.cs"
            {
#line 657 "SequencePathModule.cs"
                int lag = 0;
#line 658 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 659 "SequencePathModule.cs"
                {
#line 660 "SequencePathModule.cs"
#line 660 "SequencePathModule.cs"
                    double csharp2cuda_temp_72 = (second)->scalar_value;
#line 660 "SequencePathModule.cs"
                    int* csharp2cuda_temp_73 = &(lag);
#line 660 "SequencePathModule.cs"
                    bool csharp2cuda_temp_74 = mathblocks_sequence_positive_integer(csharp2cuda_temp_72, csharp2cuda_temp_73);
#line 660 "SequencePathModule.cs"
                    bool csharp2cuda_temp_75;
#line 660 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_74))))
                    {
#line 660 "SequencePathModule.cs"
                        int csharp2cuda_temp_76 = (first)->count;
#line 660 "SequencePathModule.cs"
                        csharp2cuda_temp_75 = ((lag) >= (csharp2cuda_temp_76));
                    }
                    else
                    {
#line 660 "SequencePathModule.cs"
                        csharp2cuda_temp_75 = true;
                    }
                    if (csharp2cuda_temp_75)
                    {
#line 661 "SequencePathModule.cs"
#line 661 "SequencePathModule.cs"
                        int* csharp2cuda_temp_77 = &((output)->valid);
                        (*(csharp2cuda_temp_77) = 0);
                    }
                    else
                    {
#line 663 "SequencePathModule.cs"
#line 663 "SequencePathModule.cs"
                        int csharp2cuda_temp_78 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_sub(csharp2cuda_temp_78, lag));
                    }
#line 664 "SequencePathModule.cs"
#line 664 "SequencePathModule.cs"
                    double* csharp2cuda_temp_79 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_79) = ((double)(lag)));
                }
#line 666 "SequencePathModule.cs"
                __syncthreads();
#line 667 "SequencePathModule.cs"
#line 667 "SequencePathModule.cs"
                int* csharp2cuda_temp_80 = &(lag);
#line 667 "SequencePathModule.cs"
                double csharp2cuda_temp_81 = (output)->scalar_value;
                (*(csharp2cuda_temp_80) = csharp2cuda_f64_to_i32(csharp2cuda_temp_81));
#line 668 "SequencePathModule.cs"
                {
#line 668 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 668 "SequencePathModule.cs"
                        bool csharp2cuda_temp_84 = (output)->valid;
#line 668 "SequencePathModule.cs"
                        bool csharp2cuda_temp_85;
#line 668 "SequencePathModule.cs"
                        if (csharp2cuda_temp_84)
                        {
#line 668 "SequencePathModule.cs"
                            int csharp2cuda_temp_86 = (output)->count;
#line 668 "SequencePathModule.cs"
                            csharp2cuda_temp_85 = ((index) < (csharp2cuda_temp_86));
                        }
                        else
                        {
#line 668 "SequencePathModule.cs"
                            csharp2cuda_temp_85 = false;
                        }
                        if (!(csharp2cuda_temp_85))
                            break;
#line 669 "SequencePathModule.cs"
                        {
#line 670 "SequencePathModule.cs"
#line 670 "SequencePathModule.cs"
                            double* csharp2cuda_temp_87 = &((result)[index]);
#line 670 "SequencePathModule.cs"
                            double csharp2cuda_temp_88 = (a)[csharp2cuda_i32_add(index, lag)];
#line 670 "SequencePathModule.cs"
                            double csharp2cuda_temp_89 = (a)[index];
                            (*(csharp2cuda_temp_87) = __dsub_rn(csharp2cuda_temp_88, csharp2cuda_temp_89));
#line 671 "SequencePathModule.cs"
#line 671 "SequencePathModule.cs"
                            double csharp2cuda_temp_90 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_90))))
                            {
#line 671 "SequencePathModule.cs"
                                atomicExch(&((output)->valid), 0);
                            }
                        }
#line 668 "SequencePathModule.cs"
                        int* csharp2cuda_temp_82 = &(index);
#line 668 "SequencePathModule.cs"
                        int csharp2cuda_temp_83 = *(csharp2cuda_temp_82);
                        (*(csharp2cuda_temp_82) = csharp2cuda_i32_add(csharp2cuda_temp_83, blockDim.x));
                    }
                }
#line 673 "SequencePathModule.cs"
                break;
            }
#line 675 "SequencePathModule.cs"
        case 2:
#line 676 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 677 "SequencePathModule.cs"
            {
#line 678 "SequencePathModule.cs"
                double alpha = (second)->scalar_value;
#line 679 "SequencePathModule.cs"
#line 679 "SequencePathModule.cs"
                int csharp2cuda_temp_91 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_91);
#line 680 "SequencePathModule.cs"
#line 680 "SequencePathModule.cs"
                int csharp2cuda_temp_92 = (first)->count;
#line 680 "SequencePathModule.cs"
                bool csharp2cuda_temp_93;
#line 680 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_92) <= (0))))
                {
#line 680 "SequencePathModule.cs"
                    bool csharp2cuda_temp_94;
#line 680 "SequencePathModule.cs"
                    if (((alpha) > (0.0)))
                    {
#line 680 "SequencePathModule.cs"
                        csharp2cuda_temp_94 = ((alpha) <= (1.0));
                    }
                    else
                    {
#line 680 "SequencePathModule.cs"
                        csharp2cuda_temp_94 = false;
                    }
#line 680 "SequencePathModule.cs"
                    csharp2cuda_temp_93 = (!(csharp2cuda_temp_94));
                }
                else
                {
#line 680 "SequencePathModule.cs"
                    csharp2cuda_temp_93 = true;
                }
                if (csharp2cuda_temp_93)
                {
#line 681 "SequencePathModule.cs"
#line 681 "SequencePathModule.cs"
                    int* csharp2cuda_temp_95 = &((output)->valid);
                    (*(csharp2cuda_temp_95) = 0);
                }
#line 682 "SequencePathModule.cs"
                if ((output)->valid)
#line 683 "SequencePathModule.cs"
                {
#line 684 "SequencePathModule.cs"
#line 684 "SequencePathModule.cs"
                    double* csharp2cuda_temp_96 = &((result)[0]);
#line 684 "SequencePathModule.cs"
                    double csharp2cuda_temp_97 = (a)[0];
                    (*(csharp2cuda_temp_96) = csharp2cuda_temp_97);
#line 685 "SequencePathModule.cs"
                    {
#line 685 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 685 "SequencePathModule.cs"
                            int csharp2cuda_temp_99 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_99))))
                                break;
#line 686 "SequencePathModule.cs"
                            {
#line 687 "SequencePathModule.cs"
#line 687 "SequencePathModule.cs"
                                double* csharp2cuda_temp_100 = &((result)[index]);
#line 687 "SequencePathModule.cs"
                                double csharp2cuda_temp_101 = (a)[index];
#line 687 "SequencePathModule.cs"
                                double csharp2cuda_temp_102 = (result)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_100) = __dadd_rn(__dmul_rn(alpha, csharp2cuda_temp_101), __dmul_rn(__dsub_rn(1.0, alpha), csharp2cuda_temp_102)));
#line 688 "SequencePathModule.cs"
#line 688 "SequencePathModule.cs"
                                double csharp2cuda_temp_103 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_103))))
                                {
#line 689 "SequencePathModule.cs"
#line 689 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_104 = &((output)->valid);
                                    (*(csharp2cuda_temp_104) = 0);
                                }
                            }
#line 685 "SequencePathModule.cs"
                            int* csharp2cuda_temp_98 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_98));
                        }
                    }
                }
            }
#line 693 "SequencePathModule.cs"
            break;
#line 694 "SequencePathModule.cs"
        case 3:
        case 6:
#line 696 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 697 "SequencePathModule.cs"
            {
#line 698 "SequencePathModule.cs"
                int width = 0;
#line 699 "SequencePathModule.cs"
#line 699 "SequencePathModule.cs"
                double csharp2cuda_temp_105 = (second)->scalar_value;
#line 699 "SequencePathModule.cs"
                int* csharp2cuda_temp_106 = &(width);
#line 699 "SequencePathModule.cs"
                bool csharp2cuda_temp_107 = mathblocks_sequence_positive_integer(csharp2cuda_temp_105, csharp2cuda_temp_106);
#line 699 "SequencePathModule.cs"
                bool csharp2cuda_temp_108;
#line 699 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_107))))
                {
#line 700 "SequencePathModule.cs"
                    int csharp2cuda_temp_109 = (first)->count;
#line 699 "SequencePathModule.cs"
                    csharp2cuda_temp_108 = ((width) > (csharp2cuda_temp_109));
                }
                else
                {
#line 699 "SequencePathModule.cs"
                    csharp2cuda_temp_108 = true;
                }
#line 699 "SequencePathModule.cs"
                bool csharp2cuda_temp_110;
#line 699 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_108))
                {
#line 699 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 699 "SequencePathModule.cs"
                    csharp2cuda_temp_110 = true;
                }
                if (csharp2cuda_temp_110)
#line 701 "SequencePathModule.cs"
                {
#line 702 "SequencePathModule.cs"
#line 702 "SequencePathModule.cs"
                    int* csharp2cuda_temp_111 = &((output)->valid);
                    (*(csharp2cuda_temp_111) = 0);
                }
                else
#line 705 "SequencePathModule.cs"
                {
#line 706 "SequencePathModule.cs"
#line 706 "SequencePathModule.cs"
                    int csharp2cuda_temp_112 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_112, width), 1));
#line 707 "SequencePathModule.cs"
                    int* deque = ((int*)(scratch));
#line 708 "SequencePathModule.cs"
                    int head = 0;
#line 709 "SequencePathModule.cs"
                    int tail = 0;
#line 710 "SequencePathModule.cs"
                    {
#line 710 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 710 "SequencePathModule.cs"
                            int csharp2cuda_temp_114 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_114))))
                                break;
#line 711 "SequencePathModule.cs"
                            {
#line 712 "SequencePathModule.cs"
                                while (true)
                                {
#line 712 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_115;
#line 712 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 712 "SequencePathModule.cs"
                                        int csharp2cuda_temp_116 = (deque)[head];
#line 712 "SequencePathModule.cs"
                                        csharp2cuda_temp_115 = ((csharp2cuda_temp_116) <= (csharp2cuda_i32_sub(index, width)));
                                    }
                                    else
                                    {
#line 712 "SequencePathModule.cs"
                                        csharp2cuda_temp_115 = false;
                                    }
                                    if (!(csharp2cuda_temp_115))
                                        break;
#line 713 "SequencePathModule.cs"
#line 713 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_117 = &(head);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_117));
                                }
#line 714 "SequencePathModule.cs"
                                while (true)
                                {
#line 714 "SequencePathModule.cs"
                                    bool csharp2cuda_temp_118;
#line 714 "SequencePathModule.cs"
                                    if (((head) < (tail)))
                                    {
#line 714 "SequencePathModule.cs"
                                        bool csharp2cuda_temp_119;
#line 714 "SequencePathModule.cs"
                                        if (((opcode) == (6)))
                                        {
#line 715 "SequencePathModule.cs"
                                            int csharp2cuda_temp_120 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 715 "SequencePathModule.cs"
                                            double csharp2cuda_temp_121 = (a)[csharp2cuda_temp_120];
#line 715 "SequencePathModule.cs"
                                            double csharp2cuda_temp_122 = (a)[index];
#line 714 "SequencePathModule.cs"
                                            csharp2cuda_temp_119 = ((csharp2cuda_temp_121) >= (csharp2cuda_temp_122));
                                        }
                                        else
                                        {
#line 716 "SequencePathModule.cs"
                                            int csharp2cuda_temp_123 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 716 "SequencePathModule.cs"
                                            double csharp2cuda_temp_124 = (a)[csharp2cuda_temp_123];
#line 716 "SequencePathModule.cs"
                                            double csharp2cuda_temp_125 = (a)[index];
#line 714 "SequencePathModule.cs"
                                            csharp2cuda_temp_119 = ((csharp2cuda_temp_124) <= (csharp2cuda_temp_125));
                                        }
#line 714 "SequencePathModule.cs"
                                        csharp2cuda_temp_118 = csharp2cuda_temp_119;
                                    }
                                    else
                                    {
#line 714 "SequencePathModule.cs"
                                        csharp2cuda_temp_118 = false;
                                    }
                                    if (!(csharp2cuda_temp_118))
                                        break;
#line 717 "SequencePathModule.cs"
                                    {
#line 718 "SequencePathModule.cs"
#line 718 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_126 = &(tail);
                                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_126));
                                    }
                                }
#line 720 "SequencePathModule.cs"
#line 720 "SequencePathModule.cs"
                                int* csharp2cuda_temp_127 = &(tail);
#line 720 "SequencePathModule.cs"
                                int csharp2cuda_temp_128 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_127));
#line 720 "SequencePathModule.cs"
                                int* csharp2cuda_temp_129 = &((deque)[csharp2cuda_temp_128]);
                                (*(csharp2cuda_temp_129) = index);
#line 721 "SequencePathModule.cs"
                                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                                {
#line 722 "SequencePathModule.cs"
#line 722 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_130 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 722 "SequencePathModule.cs"
                                    int csharp2cuda_temp_131 = (deque)[head];
#line 722 "SequencePathModule.cs"
                                    double csharp2cuda_temp_132 = (a)[csharp2cuda_temp_131];
                                    (*(csharp2cuda_temp_130) = csharp2cuda_temp_132);
                                }
                            }
#line 710 "SequencePathModule.cs"
                            int* csharp2cuda_temp_113 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_113));
                        }
                    }
                }
            }
#line 726 "SequencePathModule.cs"
            break;
#line 727 "SequencePathModule.cs"
        case 4:
        case 9:
#line 729 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 730 "SequencePathModule.cs"
            {
#line 731 "SequencePathModule.cs"
                int width = 0;
#line 732 "SequencePathModule.cs"
#line 732 "SequencePathModule.cs"
                double csharp2cuda_temp_133 = (second)->scalar_value;
#line 732 "SequencePathModule.cs"
                int* csharp2cuda_temp_134 = &(width);
#line 732 "SequencePathModule.cs"
                bool csharp2cuda_temp_135 = mathblocks_sequence_positive_integer(csharp2cuda_temp_133, csharp2cuda_temp_134);
#line 732 "SequencePathModule.cs"
                bool csharp2cuda_temp_136;
#line 732 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_135))))
                {
#line 732 "SequencePathModule.cs"
                    int csharp2cuda_temp_137 = (first)->count;
#line 732 "SequencePathModule.cs"
                    csharp2cuda_temp_136 = ((width) > (csharp2cuda_temp_137));
                }
                else
                {
#line 732 "SequencePathModule.cs"
                    csharp2cuda_temp_136 = true;
                }
                if (csharp2cuda_temp_136)
#line 733 "SequencePathModule.cs"
                {
#line 734 "SequencePathModule.cs"
#line 734 "SequencePathModule.cs"
                    int* csharp2cuda_temp_138 = &((output)->valid);
                    (*(csharp2cuda_temp_138) = 0);
                }
                else
#line 737 "SequencePathModule.cs"
                {
#line 738 "SequencePathModule.cs"
#line 738 "SequencePathModule.cs"
                    int csharp2cuda_temp_139 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_139, width), 1));
#line 739 "SequencePathModule.cs"
#line 739 "SequencePathModule.cs"
                    int csharp2cuda_temp_140 = (first)->count;
                    mathblocks_sequence_rolling_sum(a, csharp2cuda_temp_140, width, result);
#line 740 "SequencePathModule.cs"
                    if (((opcode) == (4)))
#line 741 "SequencePathModule.cs"
                    {
#line 742 "SequencePathModule.cs"
                        double scale = __ddiv_rn(1.0, ((double)(width)));
#line 743 "SequencePathModule.cs"
                        {
#line 743 "SequencePathModule.cs"
                            int index = 0;
                            while (true)
                            {
#line 743 "SequencePathModule.cs"
                                int csharp2cuda_temp_142 = (output)->count;
                                if (!(((index) < (csharp2cuda_temp_142))))
                                    break;
#line 744 "SequencePathModule.cs"
#line 744 "SequencePathModule.cs"
                                double* csharp2cuda_temp_143 = &((result)[index]);
#line 744 "SequencePathModule.cs"
                                double csharp2cuda_temp_144 = *(csharp2cuda_temp_143);
                                (*(csharp2cuda_temp_143) = __dmul_rn(csharp2cuda_temp_144, scale));
#line 743 "SequencePathModule.cs"
                                int* csharp2cuda_temp_141 = &(index);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_141));
                            }
                        }
                    }
#line 746 "SequencePathModule.cs"
                    {
#line 746 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 746 "SequencePathModule.cs"
                            int csharp2cuda_temp_146 = (output)->count;
                            if (!(((index) < (csharp2cuda_temp_146))))
                                break;
#line 747 "SequencePathModule.cs"
#line 747 "SequencePathModule.cs"
                            double csharp2cuda_temp_147 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_147))))
                            {
#line 747 "SequencePathModule.cs"
#line 747 "SequencePathModule.cs"
                                int* csharp2cuda_temp_148 = &((output)->valid);
                                (*(csharp2cuda_temp_148) = 0);
                            }
#line 746 "SequencePathModule.cs"
                            int* csharp2cuda_temp_145 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_145));
                        }
                    }
                }
            }
#line 750 "SequencePathModule.cs"
            break;
#line 751 "SequencePathModule.cs"
        case 5:
        case 7:
#line 753 "SequencePathModule.cs"
            {
#line 754 "SequencePathModule.cs"
                int width = 0;
#line 755 "SequencePathModule.cs"
                double probability = 0.0;
#line 756 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 757 "SequencePathModule.cs"
                {
#line 758 "SequencePathModule.cs"
#line 758 "SequencePathModule.cs"
                    double* csharp2cuda_temp_149 = &(probability);
#line 758 "SequencePathModule.cs"
                    double csharp2cuda_temp_150;
#line 758 "SequencePathModule.cs"
                    if (((opcode) == (5)))
                    {
#line 758 "SequencePathModule.cs"
                        csharp2cuda_temp_150 = 0.5;
                    }
                    else
                    {
#line 758 "SequencePathModule.cs"
                        csharp2cuda_temp_150 = (third)->scalar_value;
                    }
                    (*(csharp2cuda_temp_149) = csharp2cuda_temp_150);
#line 759 "SequencePathModule.cs"
#line 759 "SequencePathModule.cs"
                    double csharp2cuda_temp_151 = (second)->scalar_value;
#line 759 "SequencePathModule.cs"
                    int* csharp2cuda_temp_152 = &(width);
#line 759 "SequencePathModule.cs"
                    bool csharp2cuda_temp_153 = mathblocks_sequence_positive_integer(csharp2cuda_temp_151, csharp2cuda_temp_152);
#line 759 "SequencePathModule.cs"
                    bool csharp2cuda_temp_154;
#line 759 "SequencePathModule.cs"
                    if (!((!(csharp2cuda_temp_153))))
                    {
#line 760 "SequencePathModule.cs"
                        int csharp2cuda_temp_155 = (first)->count;
#line 759 "SequencePathModule.cs"
                        csharp2cuda_temp_154 = ((width) > (csharp2cuda_temp_155));
                    }
                    else
                    {
#line 759 "SequencePathModule.cs"
                        csharp2cuda_temp_154 = true;
                    }
#line 759 "SequencePathModule.cs"
                    bool csharp2cuda_temp_156;
#line 759 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_154))
                    {
#line 760 "SequencePathModule.cs"
                        bool csharp2cuda_temp_157;
#line 760 "SequencePathModule.cs"
                        if (((probability) >= (0.0)))
                        {
#line 760 "SequencePathModule.cs"
                            csharp2cuda_temp_157 = ((probability) <= (1.0));
                        }
                        else
                        {
#line 760 "SequencePathModule.cs"
                            csharp2cuda_temp_157 = false;
                        }
#line 759 "SequencePathModule.cs"
                        csharp2cuda_temp_156 = (!(csharp2cuda_temp_157));
                    }
                    else
                    {
#line 759 "SequencePathModule.cs"
                        csharp2cuda_temp_156 = true;
                    }
#line 759 "SequencePathModule.cs"
                    bool csharp2cuda_temp_158;
#line 759 "SequencePathModule.cs"
                    if (!(csharp2cuda_temp_156))
                    {
#line 761 "SequencePathModule.cs"
                        bool csharp2cuda_temp_159;
#line 761 "SequencePathModule.cs"
                        if (((width) > (1)))
                        {
#line 761 "SequencePathModule.cs"
                            csharp2cuda_temp_159 = ((((void*)(scratch))) == (((void*)(nullptr))));
                        }
                        else
                        {
#line 761 "SequencePathModule.cs"
                            csharp2cuda_temp_159 = false;
                        }
#line 759 "SequencePathModule.cs"
                        csharp2cuda_temp_158 = csharp2cuda_temp_159;
                    }
                    else
                    {
#line 759 "SequencePathModule.cs"
                        csharp2cuda_temp_158 = true;
                    }
                    if (csharp2cuda_temp_158)
#line 762 "SequencePathModule.cs"
                    {
#line 763 "SequencePathModule.cs"
#line 763 "SequencePathModule.cs"
                        int* csharp2cuda_temp_160 = &((output)->valid);
                        (*(csharp2cuda_temp_160) = 0);
                    }
                    else
#line 766 "SequencePathModule.cs"
                    {
#line 767 "SequencePathModule.cs"
#line 767 "SequencePathModule.cs"
                        int csharp2cuda_temp_161 = (first)->count;
                        mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_161, width), 1));
                    }
#line 769 "SequencePathModule.cs"
#line 769 "SequencePathModule.cs"
                    double* csharp2cuda_temp_162 = &((output)->scalar_value);
                    (*(csharp2cuda_temp_162) = probability);
#line 770 "SequencePathModule.cs"
#line 770 "SequencePathModule.cs"
                    int* csharp2cuda_temp_163 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_163) = width);
                }
#line 772 "SequencePathModule.cs"
                __syncthreads();
#line 773 "SequencePathModule.cs"
#line 773 "SequencePathModule.cs"
                int* csharp2cuda_temp_164 = &(width);
#line 773 "SequencePathModule.cs"
                int csharp2cuda_temp_165 = (output)->boolean_value;
                (*(csharp2cuda_temp_164) = csharp2cuda_temp_165);
#line 774 "SequencePathModule.cs"
#line 774 "SequencePathModule.cs"
                double* csharp2cuda_temp_166 = &(probability);
#line 774 "SequencePathModule.cs"
                double csharp2cuda_temp_167 = (output)->scalar_value;
                (*(csharp2cuda_temp_166) = csharp2cuda_temp_167);
#line 776 "SequencePathModule.cs"
                __syncthreads();
#line 777 "SequencePathModule.cs"
#line 777 "SequencePathModule.cs"
                bool csharp2cuda_temp_168 = (output)->valid;
                if ((!(csharp2cuda_temp_168)))
                {
#line 778 "SequencePathModule.cs"
                    break;
                }
#line 779 "SequencePathModule.cs"
                if (((width) == (1)))
#line 780 "SequencePathModule.cs"
                {
#line 781 "SequencePathModule.cs"
                    {
#line 781 "SequencePathModule.cs"
                        int index = thread;
                        while (true)
                        {
#line 781 "SequencePathModule.cs"
                            int csharp2cuda_temp_171 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_171))))
                                break;
#line 782 "SequencePathModule.cs"
#line 782 "SequencePathModule.cs"
                            double* csharp2cuda_temp_172 = &((result)[index]);
#line 782 "SequencePathModule.cs"
                            double csharp2cuda_temp_173 = (a)[index];
                            (*(csharp2cuda_temp_172) = csharp2cuda_temp_173);
#line 781 "SequencePathModule.cs"
                            int* csharp2cuda_temp_169 = &(index);
#line 781 "SequencePathModule.cs"
                            int csharp2cuda_temp_170 = *(csharp2cuda_temp_169);
                            (*(csharp2cuda_temp_169) = csharp2cuda_i32_add(csharp2cuda_temp_170, blockDim.x));
                        }
                    }
#line 783 "SequencePathModule.cs"
                    __syncthreads();
#line 784 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 785 "SequencePathModule.cs"
                    {
#line 786 "SequencePathModule.cs"
#line 786 "SequencePathModule.cs"
                        double* csharp2cuda_temp_174 = &((output)->scalar_value);
#line 786 "SequencePathModule.cs"
                        int csharp2cuda_temp_175 = (first)->count;
                        (*(csharp2cuda_temp_174) = ((double)(csharp2cuda_temp_175)));
#line 787 "SequencePathModule.cs"
#line 787 "SequencePathModule.cs"
                        int* csharp2cuda_temp_176 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_176) = 0);
                    }
#line 789 "SequencePathModule.cs"
                    break;
                }
#line 791 "SequencePathModule.cs"
#line 791 "SequencePathModule.cs"
                bool csharp2cuda_temp_177;
#line 791 "SequencePathModule.cs"
                if (!(((probability) == (0.0))))
                {
#line 791 "SequencePathModule.cs"
                    csharp2cuda_temp_177 = ((probability) == (1.0));
                }
                else
                {
#line 791 "SequencePathModule.cs"
                    csharp2cuda_temp_177 = true;
                }
                if (csharp2cuda_temp_177)
#line 792 "SequencePathModule.cs"
                {
#line 793 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 794 "SequencePathModule.cs"
                    {
#line 795 "SequencePathModule.cs"
#line 797 "SequencePathModule.cs"
                        int csharp2cuda_temp_178 = (first)->count;
                        mathblocks_sequence_rolling_extreme(a, csharp2cuda_temp_178, width, result, ((int*)(scratch)), ((probability) == (0.0)));
#line 802 "SequencePathModule.cs"
#line 802 "SequencePathModule.cs"
                        double* csharp2cuda_temp_179 = &((output)->scalar_value);
#line 803 "SequencePathModule.cs"
                        int csharp2cuda_temp_180 = (first)->count;
#line 803 "SequencePathModule.cs"
                        int csharp2cuda_temp_181 = (output)->count;
                        (*(csharp2cuda_temp_179) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_180)), ((long long)(3))), ((long long)(csharp2cuda_temp_181))))));
#line 804 "SequencePathModule.cs"
#line 804 "SequencePathModule.cs"
                        int* csharp2cuda_temp_182 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_182) = 0);
                    }
#line 806 "SequencePathModule.cs"
                    __syncthreads();
#line 807 "SequencePathModule.cs"
                    break;
                }
#line 810 "SequencePathModule.cs"
                unsigned char* order_scratch = ((unsigned char*)(scratch));
#line 811 "SequencePathModule.cs"
#line 813 "SequencePathModule.cs"
                int csharp2cuda_temp_183 = (first)->count;
                mathblocks_sequence_prepare_order_ranks(a, csharp2cuda_temp_183, order_scratch, output);
#line 816 "SequencePathModule.cs"
#line 816 "SequencePathModule.cs"
                bool csharp2cuda_temp_184 = (output)->valid;
                if ((!(csharp2cuda_temp_184)))
                {
#line 817 "SequencePathModule.cs"
                    break;
                }
#line 818 "SequencePathModule.cs"
                unsigned long long* first_keys = ((unsigned long long*)(order_scratch));
#line 819 "SequencePathModule.cs"
                int csharp2cuda_temp_185 = (first)->count;
#line 819 "SequencePathModule.cs"
                unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, csharp2cuda_temp_185);
#line 820 "SequencePathModule.cs"
                int csharp2cuda_temp_186 = (first)->count;
#line 820 "SequencePathModule.cs"
                int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, csharp2cuda_temp_186)));
#line 821 "SequencePathModule.cs"
                int csharp2cuda_temp_187 = (first)->count;
#line 821 "SequencePathModule.cs"
                int* second_indexes = csharp2cuda_pointer_add(first_indexes, csharp2cuda_temp_187);
#line 822 "SequencePathModule.cs"
                int csharp2cuda_temp_188 = (first)->count;
#line 822 "SequencePathModule.cs"
                int* ranks = csharp2cuda_pointer_add(second_indexes, csharp2cuda_temp_188);
#line 823 "SequencePathModule.cs"
                int csharp2cuda_temp_189 = (first)->count;
#line 823 "SequencePathModule.cs"
                int* lower_heap = csharp2cuda_pointer_add(ranks, csharp2cuda_temp_189);
#line 824 "SequencePathModule.cs"
                int* upper_heap = csharp2cuda_pointer_add(lower_heap, width);
#line 825 "SequencePathModule.cs"
                int* positions = csharp2cuda_pointer_add(upper_heap, width);
#line 826 "SequencePathModule.cs"
                int csharp2cuda_temp_190 = (first)->count;
#line 826 "SequencePathModule.cs"
                int* kinds = csharp2cuda_pointer_add(positions, csharp2cuda_temp_190);
#line 827 "SequencePathModule.cs"
                double quantile_position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(width, 1))));
#line 828 "SequencePathModule.cs"
                int lower_index = csharp2cuda_f64_to_i32(floor(quantile_position));
#line 829 "SequencePathModule.cs"
                int upper_index = csharp2cuda_f64_to_i32(ceil(quantile_position));
#line 830 "SequencePathModule.cs"
                double weight = __dsub_rn(quantile_position, ((double)(lower_index)));
#line 832 "SequencePathModule.cs"
#line 832 "SequencePathModule.cs"
                int csharp2cuda_temp_191 = (output)->count;
                if (((csharp2cuda_temp_191) == (1)))
#line 833 "SequencePathModule.cs"
                {
#line 834 "SequencePathModule.cs"
                    if (((thread) == (0)))
#line 835 "SequencePathModule.cs"
                    {
#line 836 "SequencePathModule.cs"
                        int csharp2cuda_temp_192 = (first_indexes)[lower_index];
#line 836 "SequencePathModule.cs"
                        double lower_value = (a)[csharp2cuda_temp_192];
#line 837 "SequencePathModule.cs"
                        int csharp2cuda_temp_193 = (first_indexes)[upper_index];
#line 837 "SequencePathModule.cs"
                        double upper_value = (a)[csharp2cuda_temp_193];
#line 838 "SequencePathModule.cs"
#line 838 "SequencePathModule.cs"
                        double* csharp2cuda_temp_194 = &((result)[0]);
                        (*(csharp2cuda_temp_194) = __dadd_rn(__dmul_rn(lower_value, __dsub_rn(1.0, weight)), __dmul_rn(upper_value, weight)));
#line 839 "SequencePathModule.cs"
#line 839 "SequencePathModule.cs"
                        int* csharp2cuda_temp_195 = &((output)->valid);
#line 839 "SequencePathModule.cs"
                        double csharp2cuda_temp_196 = (result)[0];
                        (*(csharp2cuda_temp_195) = isfinite(csharp2cuda_temp_196));
#line 840 "SequencePathModule.cs"
#line 840 "SequencePathModule.cs"
                        double* csharp2cuda_temp_197 = &((output)->scalar_value);
#line 840 "SequencePathModule.cs"
                        int csharp2cuda_temp_198 = (first)->count;
                        (*(csharp2cuda_temp_197) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_198)), ((long long)(64))), ((long long)(2))))));
#line 841 "SequencePathModule.cs"
#line 841 "SequencePathModule.cs"
                        int* csharp2cuda_temp_199 = &((output)->boolean_value);
                        (*(csharp2cuda_temp_199) = 64);
                    }
#line 843 "SequencePathModule.cs"
                    __syncthreads();
#line 844 "SequencePathModule.cs"
                    break;
                }
#line 847 "SequencePathModule.cs"
                {
#line 847 "SequencePathModule.cs"
                    int index = thread;
                    while (true)
                    {
#line 847 "SequencePathModule.cs"
                        int csharp2cuda_temp_202 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_202))))
                            break;
#line 848 "SequencePathModule.cs"
                        {
#line 849 "SequencePathModule.cs"
#line 849 "SequencePathModule.cs"
                            int* csharp2cuda_temp_203 = &((positions)[index]);
                            (*(csharp2cuda_temp_203) = csharp2cuda_i32_neg(1));
#line 850 "SequencePathModule.cs"
#line 850 "SequencePathModule.cs"
                            int* csharp2cuda_temp_204 = &((kinds)[index]);
                            (*(csharp2cuda_temp_204) = csharp2cuda_i32_neg(1));
                        }
#line 847 "SequencePathModule.cs"
                        int* csharp2cuda_temp_200 = &(index);
#line 847 "SequencePathModule.cs"
                        int csharp2cuda_temp_201 = *(csharp2cuda_temp_200);
                        (*(csharp2cuda_temp_200) = csharp2cuda_i32_add(csharp2cuda_temp_201, blockDim.x));
                    }
                }
#line 852 "SequencePathModule.cs"
                __syncthreads();
#line 853 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 854 "SequencePathModule.cs"
                {
#line 855 "SequencePathModule.cs"
                    int lower_count = 0;
#line 856 "SequencePathModule.cs"
                    int upper_count = 0;
#line 857 "SequencePathModule.cs"
                    int target_lower_count = csharp2cuda_i32_add(lower_index, 1);
#line 858 "SequencePathModule.cs"
                    {
#line 858 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (width))))
                                break;
#line 859 "SequencePathModule.cs"
                            {
#line 860 "SequencePathModule.cs"
#line 860 "SequencePathModule.cs"
                                bool csharp2cuda_temp_206;
#line 860 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
                                {
#line 860 "SequencePathModule.cs"
                                    csharp2cuda_temp_206 = ((upper_count) == (0));
                                }
                                else
                                {
#line 860 "SequencePathModule.cs"
                                    csharp2cuda_temp_206 = false;
                                }
                                if (csharp2cuda_temp_206)
#line 861 "SequencePathModule.cs"
                                {
#line 862 "SequencePathModule.cs"
#line 864 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_207 = &(lower_count);
                                    mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_207, index, 0, positions, kinds, ranks, true);
                                }
                                else
                                {
#line 872 "SequencePathModule.cs"
                                    if (((lower_count) == (0)))
#line 873 "SequencePathModule.cs"
                                    {
#line 874 "SequencePathModule.cs"
#line 876 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_208 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_208, index, 1, positions, kinds, ranks, false);
                                    }
                                    else
                                    {
#line 884 "SequencePathModule.cs"
#line 884 "SequencePathModule.cs"
                                        int csharp2cuda_temp_209 = (ranks)[index];
#line 884 "SequencePathModule.cs"
                                        int csharp2cuda_temp_210 = (lower_heap)[0];
#line 884 "SequencePathModule.cs"
                                        int csharp2cuda_temp_211 = (ranks)[csharp2cuda_temp_210];
                                        if (((csharp2cuda_temp_209) <= (csharp2cuda_temp_211)))
#line 885 "SequencePathModule.cs"
                                        {
#line 886 "SequencePathModule.cs"
#line 888 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_212 = &(lower_count);
                                            mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_212, index, 0, positions, kinds, ranks, true);
                                        }
                                        else
#line 897 "SequencePathModule.cs"
                                        {
#line 898 "SequencePathModule.cs"
#line 900 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_213 = &(upper_count);
                                            mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_213, index, 1, positions, kinds, ranks, false);
                                        }
                                    }
                                }
#line 908 "SequencePathModule.cs"
                                int csharp2cuda_temp_214;
#line 908 "SequencePathModule.cs"
                                if (((target_lower_count) < (csharp2cuda_i32_add(index, 1))))
                                {
#line 908 "SequencePathModule.cs"
                                    csharp2cuda_temp_214 = target_lower_count;
                                }
                                else
                                {
#line 908 "SequencePathModule.cs"
                                    csharp2cuda_temp_214 = csharp2cuda_i32_add(index, 1);
                                }
#line 908 "SequencePathModule.cs"
                                int active_target = csharp2cuda_temp_214;
#line 911 "SequencePathModule.cs"
#line 913 "SequencePathModule.cs"
                                int* csharp2cuda_temp_215 = &(lower_count);
#line 915 "SequencePathModule.cs"
                                int* csharp2cuda_temp_216 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_215, upper_heap, csharp2cuda_temp_216, active_target, positions, kinds, ranks);
                            }
#line 858 "SequencePathModule.cs"
                            int* csharp2cuda_temp_205 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_205));
                        }
                    }
#line 921 "SequencePathModule.cs"
                    {
#line 921 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 921 "SequencePathModule.cs"
                            int csharp2cuda_temp_218 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_218))))
                                break;
#line 922 "SequencePathModule.cs"
                            {
#line 923 "SequencePathModule.cs"
                                int csharp2cuda_temp_219 = (lower_heap)[0];
#line 923 "SequencePathModule.cs"
                                double lower_value = (a)[csharp2cuda_temp_219];
#line 924 "SequencePathModule.cs"
                                double csharp2cuda_temp_220;
#line 924 "SequencePathModule.cs"
                                if (((lower_index) == (upper_index)))
                                {
#line 924 "SequencePathModule.cs"
                                    csharp2cuda_temp_220 = lower_value;
                                }
                                else
                                {
#line 926 "SequencePathModule.cs"
                                    int csharp2cuda_temp_221 = (upper_heap)[0];
#line 924 "SequencePathModule.cs"
                                    csharp2cuda_temp_220 = (a)[csharp2cuda_temp_221];
                                }
#line 924 "SequencePathModule.cs"
                                double upper_value = csharp2cuda_temp_220;
#line 927 "SequencePathModule.cs"
#line 927 "SequencePathModule.cs"
                                double* csharp2cuda_temp_222 = &((result)[start]);
                                (*(csharp2cuda_temp_222) = __dadd_rn(__dmul_rn(lower_value, __dsub_rn(1.0, weight)), __dmul_rn(upper_value, weight)));
#line 928 "SequencePathModule.cs"
#line 928 "SequencePathModule.cs"
                                double csharp2cuda_temp_223 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_223))))
#line 929 "SequencePathModule.cs"
                                {
#line 930 "SequencePathModule.cs"
#line 930 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_224 = &((output)->valid);
                                    (*(csharp2cuda_temp_224) = 0);
#line 931 "SequencePathModule.cs"
                                    break;
                                }
#line 933 "SequencePathModule.cs"
#line 933 "SequencePathModule.cs"
                                int csharp2cuda_temp_225 = (output)->count;
                                if (((csharp2cuda_i32_add(start, 1)) == (csharp2cuda_temp_225)))
                                {
#line 934 "SequencePathModule.cs"
                                    break;
                                }
#line 935 "SequencePathModule.cs"
                                int outgoing = start;
#line 936 "SequencePathModule.cs"
                                int incoming = csharp2cuda_i32_add(start, width);
#line 937 "SequencePathModule.cs"
#line 937 "SequencePathModule.cs"
                                int csharp2cuda_temp_226 = (kinds)[outgoing];
                                if (((csharp2cuda_temp_226) == (0)))
#line 938 "SequencePathModule.cs"
                                {
#line 939 "SequencePathModule.cs"
#line 941 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_227 = &(lower_count);
                                    mathblocks_sequence_heap_remove(lower_heap, csharp2cuda_temp_227, outgoing, positions, kinds, ranks, true);
                                }
                                else
#line 949 "SequencePathModule.cs"
                                {
#line 950 "SequencePathModule.cs"
#line 952 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_228 = &(upper_count);
                                    mathblocks_sequence_heap_remove(upper_heap, csharp2cuda_temp_228, outgoing, positions, kinds, ranks, false);
                                }
#line 959 "SequencePathModule.cs"
                                if (((lower_count) == (0)))
#line 960 "SequencePathModule.cs"
                                {
#line 961 "SequencePathModule.cs"
#line 963 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_229 = &(upper_count);
                                    mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_229, incoming, 1, positions, kinds, ranks, false);
                                }
                                else
                                {
#line 971 "SequencePathModule.cs"
#line 971 "SequencePathModule.cs"
                                    int csharp2cuda_temp_230 = (ranks)[incoming];
#line 971 "SequencePathModule.cs"
                                    int csharp2cuda_temp_231 = (lower_heap)[0];
#line 971 "SequencePathModule.cs"
                                    int csharp2cuda_temp_232 = (ranks)[csharp2cuda_temp_231];
                                    if (((csharp2cuda_temp_230) <= (csharp2cuda_temp_232)))
#line 972 "SequencePathModule.cs"
                                    {
#line 973 "SequencePathModule.cs"
#line 975 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_233 = &(lower_count);
                                        mathblocks_sequence_heap_insert(lower_heap, csharp2cuda_temp_233, incoming, 0, positions, kinds, ranks, true);
                                    }
                                    else
#line 984 "SequencePathModule.cs"
                                    {
#line 985 "SequencePathModule.cs"
#line 987 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_234 = &(upper_count);
                                        mathblocks_sequence_heap_insert(upper_heap, csharp2cuda_temp_234, incoming, 1, positions, kinds, ranks, false);
                                    }
                                }
#line 995 "SequencePathModule.cs"
#line 997 "SequencePathModule.cs"
                                int* csharp2cuda_temp_235 = &(lower_count);
#line 999 "SequencePathModule.cs"
                                int* csharp2cuda_temp_236 = &(upper_count);
                                mathblocks_sequence_rebalance_heaps(lower_heap, csharp2cuda_temp_235, upper_heap, csharp2cuda_temp_236, target_lower_count, positions, kinds, ranks);
                            }
#line 921 "SequencePathModule.cs"
                            int* csharp2cuda_temp_217 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_217));
                        }
                    }
#line 1005 "SequencePathModule.cs"
                    int heap_height = 1;
#line 1006 "SequencePathModule.cs"
                    {
#line 1006 "SequencePathModule.cs"
                        int value = width;
                        while (true)
                        {
                            if (!(((value) > (1))))
                                break;
#line 1007 "SequencePathModule.cs"
#line 1007 "SequencePathModule.cs"
                            int* csharp2cuda_temp_238 = &(heap_height);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_238));
#line 1006 "SequencePathModule.cs"
                            int* csharp2cuda_temp_237 = &(value);
                            (*(csharp2cuda_temp_237) = csharp2cuda_i32_shr(csharp2cuda_i32_add(value, 1), 1));
                        }
                    }
#line 1009 "SequencePathModule.cs"
                    int csharp2cuda_temp_239 = (first)->count;
#line 1008 "SequencePathModule.cs"
                    long long heap_bound = csharp2cuda_i64_mul(csharp2cuda_i64_add(((long long)(width)), csharp2cuda_i64_mul(2LL, ((long long)(csharp2cuda_i32_sub(csharp2cuda_temp_239, width))))), ((long long)(heap_height)));
#line 1010 "SequencePathModule.cs"
                    int csharp2cuda_temp_240 = (output)->count;
#line 1010 "SequencePathModule.cs"
                    long long selection_bound = csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_240)), ((long long)(2)));
#line 1011 "SequencePathModule.cs"
#line 1011 "SequencePathModule.cs"
                    double* csharp2cuda_temp_241 = &((output)->scalar_value);
#line 1012 "SequencePathModule.cs"
                    int csharp2cuda_temp_242 = (first)->count;
                    (*(csharp2cuda_temp_241) = ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(csharp2cuda_i64_mul(((long long)(csharp2cuda_temp_242)), ((long long)(64))), heap_bound), selection_bound))));
#line 1013 "SequencePathModule.cs"
#line 1013 "SequencePathModule.cs"
                    int* csharp2cuda_temp_243 = &((output)->boolean_value);
                    (*(csharp2cuda_temp_243) = 64);
                }
#line 1015 "SequencePathModule.cs"
                __syncthreads();
#line 1016 "SequencePathModule.cs"
                break;
            }
#line 1018 "SequencePathModule.cs"
        case 8:
        case 10:
#line 1020 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1021 "SequencePathModule.cs"
            {
#line 1022 "SequencePathModule.cs"
                int width = 0;
#line 1023 "SequencePathModule.cs"
#line 1023 "SequencePathModule.cs"
                double csharp2cuda_temp_244 = (second)->scalar_value;
#line 1023 "SequencePathModule.cs"
                int* csharp2cuda_temp_245 = &(width);
#line 1023 "SequencePathModule.cs"
                bool csharp2cuda_temp_246 = mathblocks_sequence_positive_integer(csharp2cuda_temp_244, csharp2cuda_temp_245);
#line 1023 "SequencePathModule.cs"
                bool csharp2cuda_temp_247;
#line 1023 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_246))))
                {
#line 1023 "SequencePathModule.cs"
                    int csharp2cuda_temp_248 = (first)->count;
#line 1023 "SequencePathModule.cs"
                    csharp2cuda_temp_247 = ((width) > (csharp2cuda_temp_248));
                }
                else
                {
#line 1023 "SequencePathModule.cs"
                    csharp2cuda_temp_247 = true;
                }
                if (csharp2cuda_temp_247)
#line 1024 "SequencePathModule.cs"
                {
#line 1025 "SequencePathModule.cs"
#line 1025 "SequencePathModule.cs"
                    int* csharp2cuda_temp_249 = &((output)->valid);
                    (*(csharp2cuda_temp_249) = 0);
                }
                else
#line 1028 "SequencePathModule.cs"
                {
#line 1029 "SequencePathModule.cs"
#line 1029 "SequencePathModule.cs"
                    int csharp2cuda_temp_250 = (first)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_i32_sub(csharp2cuda_temp_250, width), 1));
#line 1030 "SequencePathModule.cs"
                    {
#line 1030 "SequencePathModule.cs"
                        int start = 0;
                        while (true)
                        {
#line 1030 "SequencePathModule.cs"
                            int csharp2cuda_temp_252 = (output)->count;
                            if (!(((start) < (csharp2cuda_temp_252))))
                                break;
#line 1031 "SequencePathModule.cs"
                            {
#line 1032 "SequencePathModule.cs"
                                double mean = 0.0;
#line 1033 "SequencePathModule.cs"
                                {
#line 1033 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 1034 "SequencePathModule.cs"
#line 1034 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_254 = &(mean);
#line 1034 "SequencePathModule.cs"
                                        double csharp2cuda_temp_255 = *(csharp2cuda_temp_254);
#line 1034 "SequencePathModule.cs"
                                        double csharp2cuda_temp_256 = (a)[csharp2cuda_i32_add(start, index)];
                                        (*(csharp2cuda_temp_254) = __dadd_rn(csharp2cuda_temp_255, csharp2cuda_temp_256));
#line 1033 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_253 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_253));
                                    }
                                }
#line 1035 "SequencePathModule.cs"
#line 1035 "SequencePathModule.cs"
                                double* csharp2cuda_temp_257 = &(mean);
#line 1035 "SequencePathModule.cs"
                                double csharp2cuda_temp_258 = *(csharp2cuda_temp_257);
                                (*(csharp2cuda_temp_257) = __ddiv_rn(csharp2cuda_temp_258, ((double)(width))));
#line 1036 "SequencePathModule.cs"
                                double sum_squares = 0.0;
#line 1037 "SequencePathModule.cs"
                                {
#line 1037 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (width))))
                                            break;
#line 1038 "SequencePathModule.cs"
                                        {
#line 1039 "SequencePathModule.cs"
                                            double csharp2cuda_temp_260 = (a)[csharp2cuda_i32_add(start, index)];
#line 1039 "SequencePathModule.cs"
                                            double difference = __dsub_rn(csharp2cuda_temp_260, mean);
#line 1040 "SequencePathModule.cs"
#line 1040 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_261 = &(sum_squares);
#line 1040 "SequencePathModule.cs"
                                            double csharp2cuda_temp_262 = *(csharp2cuda_temp_261);
                                            (*(csharp2cuda_temp_261) = __dadd_rn(csharp2cuda_temp_262, __dmul_rn(difference, difference)));
                                        }
#line 1037 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_259 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_259));
                                    }
                                }
#line 1042 "SequencePathModule.cs"
                                double csharp2cuda_temp_263 = __ddiv_rn(sum_squares, ((double)(width)));
#line 1042 "SequencePathModule.cs"
                                double deviation = mathblocks_square_root(csharp2cuda_temp_263);
#line 1043 "SequencePathModule.cs"
#line 1043 "SequencePathModule.cs"
                                double* csharp2cuda_temp_264 = &((result)[start]);
#line 1043 "SequencePathModule.cs"
                                double csharp2cuda_temp_265;
#line 1043 "SequencePathModule.cs"
                                if (((opcode) == (8)))
                                {
#line 1043 "SequencePathModule.cs"
                                    csharp2cuda_temp_265 = deviation;
                                }
                                else
                                {
#line 1043 "SequencePathModule.cs"
                                    csharp2cuda_temp_265 = __dmul_rn(deviation, deviation);
                                }
                                (*(csharp2cuda_temp_264) = csharp2cuda_temp_265);
#line 1044 "SequencePathModule.cs"
#line 1044 "SequencePathModule.cs"
                                double csharp2cuda_temp_266 = (result)[start];
                                if ((!(isfinite(csharp2cuda_temp_266))))
                                {
#line 1045 "SequencePathModule.cs"
#line 1045 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_267 = &((output)->valid);
                                    (*(csharp2cuda_temp_267) = 0);
                                }
                            }
#line 1030 "SequencePathModule.cs"
                            int* csharp2cuda_temp_251 = &(start);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_251));
                        }
                    }
                }
            }
#line 1049 "SequencePathModule.cs"
            break;
#line 1050 "SequencePathModule.cs"
        case 11:
#line 1051 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1052 "SequencePathModule.cs"
            {
#line 1053 "SequencePathModule.cs"
#line 1053 "SequencePathModule.cs"
                int csharp2cuda_temp_268 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_268);
#line 1054 "SequencePathModule.cs"
#line 1054 "SequencePathModule.cs"
                int csharp2cuda_temp_269 = (first)->count;
#line 1054 "SequencePathModule.cs"
                bool csharp2cuda_temp_270;
#line 1054 "SequencePathModule.cs"
                if (!((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_269)))))
                {
#line 1054 "SequencePathModule.cs"
                    csharp2cuda_temp_270 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1054 "SequencePathModule.cs"
                    csharp2cuda_temp_270 = true;
                }
                if (csharp2cuda_temp_270)
#line 1055 "SequencePathModule.cs"
                {
#line 1056 "SequencePathModule.cs"
#line 1056 "SequencePathModule.cs"
                    int* csharp2cuda_temp_271 = &((output)->valid);
                    (*(csharp2cuda_temp_271) = 0);
                }
                else
#line 1059 "SequencePathModule.cs"
                {
#line 1060 "SequencePathModule.cs"
                    {
#line 1060 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1060 "SequencePathModule.cs"
                            int csharp2cuda_temp_273 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_273))))
                                break;
#line 1061 "SequencePathModule.cs"
#line 1061 "SequencePathModule.cs"
                            double* csharp2cuda_temp_274 = &((result)[index]);
#line 1061 "SequencePathModule.cs"
                            double csharp2cuda_temp_275 = (a)[index];
                            (*(csharp2cuda_temp_274) = csharp2cuda_temp_275);
#line 1060 "SequencePathModule.cs"
                            int* csharp2cuda_temp_272 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_272));
                        }
                    }
#line 1062 "SequencePathModule.cs"
                    int length = (first)->count;
#line 1063 "SequencePathModule.cs"
                    double scale = __ddiv_rn(1.0, mathblocks_square_root(2.0));
#line 1064 "SequencePathModule.cs"
                    while (true)
                    {
                        if (!(((length) > (1))))
                            break;
#line 1065 "SequencePathModule.cs"
                        {
#line 1066 "SequencePathModule.cs"
                            int half = csharp2cuda_i32_div(length, 2);
#line 1067 "SequencePathModule.cs"
                            {
#line 1067 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (half))))
                                        break;
#line 1068 "SequencePathModule.cs"
                                    {
#line 1069 "SequencePathModule.cs"
#line 1069 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_277 = &((scratch)[index]);
#line 1069 "SequencePathModule.cs"
                                        double csharp2cuda_temp_278 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1069 "SequencePathModule.cs"
                                        double csharp2cuda_temp_279 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_277) = __dmul_rn(__dadd_rn(csharp2cuda_temp_278, csharp2cuda_temp_279), scale));
#line 1070 "SequencePathModule.cs"
#line 1070 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_280 = &((scratch)[csharp2cuda_i32_add(half, index)]);
#line 1070 "SequencePathModule.cs"
                                        double csharp2cuda_temp_281 = (result)[csharp2cuda_i32_mul(2, index)];
#line 1070 "SequencePathModule.cs"
                                        double csharp2cuda_temp_282 = (result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(2, index), 1)];
                                        (*(csharp2cuda_temp_280) = __dmul_rn(__dsub_rn(csharp2cuda_temp_281, csharp2cuda_temp_282), scale));
                                    }
#line 1067 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_276 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_276));
                                }
                            }
#line 1072 "SequencePathModule.cs"
                            {
#line 1072 "SequencePathModule.cs"
                                int index = 0;
                                while (true)
                                {
                                    if (!(((index) < (length))))
                                        break;
#line 1073 "SequencePathModule.cs"
#line 1073 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_284 = &((result)[index]);
#line 1073 "SequencePathModule.cs"
                                    double csharp2cuda_temp_285 = (scratch)[index];
                                    (*(csharp2cuda_temp_284) = csharp2cuda_temp_285);
#line 1072 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_283 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_283));
                                }
                            }
#line 1074 "SequencePathModule.cs"
#line 1074 "SequencePathModule.cs"
                            int* csharp2cuda_temp_286 = &(length);
                            (*(csharp2cuda_temp_286) = half);
                        }
                    }
#line 1076 "SequencePathModule.cs"
                    {
#line 1076 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1076 "SequencePathModule.cs"
                            int csharp2cuda_temp_288 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_288))))
                                break;
#line 1077 "SequencePathModule.cs"
#line 1077 "SequencePathModule.cs"
                            double csharp2cuda_temp_289 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_289))))
                            {
#line 1077 "SequencePathModule.cs"
#line 1077 "SequencePathModule.cs"
                                int* csharp2cuda_temp_290 = &((output)->valid);
                                (*(csharp2cuda_temp_290) = 0);
                            }
#line 1076 "SequencePathModule.cs"
                            int* csharp2cuda_temp_287 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_287));
                        }
                    }
                }
            }
#line 1080 "SequencePathModule.cs"
            break;
#line 1081 "SequencePathModule.cs"
        case 12:
#line 1082 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1083 "SequencePathModule.cs"
            {
#line 1084 "SequencePathModule.cs"
#line 1084 "SequencePathModule.cs"
                int csharp2cuda_temp_291 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_291);
#line 1085 "SequencePathModule.cs"
#line 1085 "SequencePathModule.cs"
                int csharp2cuda_temp_292 = (first)->count;
                if ((!(mathblocks_sequence_is_power_of_two(csharp2cuda_temp_292))))
#line 1086 "SequencePathModule.cs"
                {
#line 1087 "SequencePathModule.cs"
#line 1087 "SequencePathModule.cs"
                    int* csharp2cuda_temp_293 = &((output)->valid);
                    (*(csharp2cuda_temp_293) = 0);
                }
                else
#line 1090 "SequencePathModule.cs"
                {
#line 1091 "SequencePathModule.cs"
                    {
#line 1091 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1091 "SequencePathModule.cs"
                            int csharp2cuda_temp_295 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_295))))
                                break;
#line 1092 "SequencePathModule.cs"
#line 1092 "SequencePathModule.cs"
                            double* csharp2cuda_temp_296 = &((result)[index]);
#line 1092 "SequencePathModule.cs"
                            double csharp2cuda_temp_297 = (a)[index];
                            (*(csharp2cuda_temp_296) = csharp2cuda_temp_297);
#line 1091 "SequencePathModule.cs"
                            int* csharp2cuda_temp_294 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_294));
                        }
                    }
#line 1093 "SequencePathModule.cs"
                    {
#line 1093 "SequencePathModule.cs"
                        int width = 1;
                        while (true)
                        {
#line 1093 "SequencePathModule.cs"
                            int csharp2cuda_temp_300 = (first)->count;
                            if (!(((width) < (csharp2cuda_temp_300))))
                                break;
#line 1094 "SequencePathModule.cs"
                            {
#line 1095 "SequencePathModule.cs"
                                {
#line 1095 "SequencePathModule.cs"
                                    int start = 0;
                                    while (true)
                                    {
#line 1095 "SequencePathModule.cs"
                                        int csharp2cuda_temp_303 = (first)->count;
                                        if (!(((start) < (csharp2cuda_temp_303))))
                                            break;
#line 1096 "SequencePathModule.cs"
                                        {
#line 1097 "SequencePathModule.cs"
                                            {
#line 1097 "SequencePathModule.cs"
                                                int offset = 0;
                                                while (true)
                                                {
                                                    if (!(((offset) < (width))))
                                                        break;
#line 1098 "SequencePathModule.cs"
                                                    {
#line 1099 "SequencePathModule.cs"
                                                        double left = (result)[csharp2cuda_i32_add(start, offset)];
#line 1100 "SequencePathModule.cs"
                                                        double right = (result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)];
#line 1101 "SequencePathModule.cs"
#line 1101 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_305 = &((result)[csharp2cuda_i32_add(start, offset)]);
                                                        (*(csharp2cuda_temp_305) = __dadd_rn(left, right));
#line 1102 "SequencePathModule.cs"
#line 1102 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_306 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_add(start, width), offset)]);
                                                        (*(csharp2cuda_temp_306) = __dsub_rn(left, right));
                                                    }
#line 1097 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_304 = &(offset);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_304));
                                                }
                                            }
                                        }
#line 1095 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_301 = &(start);
#line 1095 "SequencePathModule.cs"
                                        int csharp2cuda_temp_302 = *(csharp2cuda_temp_301);
                                        (*(csharp2cuda_temp_301) = csharp2cuda_i32_add(csharp2cuda_temp_302, csharp2cuda_i32_mul(2, width)));
                                    }
                                }
                            }
#line 1093 "SequencePathModule.cs"
                            int* csharp2cuda_temp_298 = &(width);
#line 1093 "SequencePathModule.cs"
                            int csharp2cuda_temp_299 = *(csharp2cuda_temp_298);
                            (*(csharp2cuda_temp_298) = csharp2cuda_i32_mul(csharp2cuda_temp_299, 2));
                        }
                    }
#line 1106 "SequencePathModule.cs"
                    int csharp2cuda_temp_307 = (first)->count;
#line 1106 "SequencePathModule.cs"
                    double scale = __ddiv_rn(1.0, mathblocks_square_root(((double)(csharp2cuda_temp_307))));
#line 1107 "SequencePathModule.cs"
                    {
#line 1107 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1107 "SequencePathModule.cs"
                            int csharp2cuda_temp_309 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_309))))
                                break;
#line 1108 "SequencePathModule.cs"
                            {
#line 1109 "SequencePathModule.cs"
#line 1109 "SequencePathModule.cs"
                                double* csharp2cuda_temp_310 = &((result)[index]);
#line 1109 "SequencePathModule.cs"
                                double csharp2cuda_temp_311 = *(csharp2cuda_temp_310);
                                (*(csharp2cuda_temp_310) = __dmul_rn(csharp2cuda_temp_311, scale));
#line 1110 "SequencePathModule.cs"
#line 1110 "SequencePathModule.cs"
                                double csharp2cuda_temp_312 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_312))))
                                {
#line 1110 "SequencePathModule.cs"
#line 1110 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_313 = &((output)->valid);
                                    (*(csharp2cuda_temp_313) = 0);
                                }
                            }
#line 1107 "SequencePathModule.cs"
                            int* csharp2cuda_temp_308 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_308));
                        }
                    }
                }
            }
#line 1114 "SequencePathModule.cs"
            break;
#line 1115 "SequencePathModule.cs"
        case 13:
#line 1116 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1117 "SequencePathModule.cs"
            {
#line 1118 "SequencePathModule.cs"
#line 1118 "SequencePathModule.cs"
                int csharp2cuda_temp_314 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_314);
#line 1119 "SequencePathModule.cs"
                double sum = 0.0;
#line 1120 "SequencePathModule.cs"
                {
#line 1120 "SequencePathModule.cs"
                    int index = 0;
                    while (true)
                    {
#line 1120 "SequencePathModule.cs"
                        int csharp2cuda_temp_316 = (first)->count;
                        if (!(((index) < (csharp2cuda_temp_316))))
                            break;
#line 1121 "SequencePathModule.cs"
                        {
#line 1122 "SequencePathModule.cs"
#line 1122 "SequencePathModule.cs"
                            double* csharp2cuda_temp_317 = &(sum);
#line 1122 "SequencePathModule.cs"
                            double csharp2cuda_temp_318 = *(csharp2cuda_temp_317);
#line 1122 "SequencePathModule.cs"
                            double csharp2cuda_temp_319 = (a)[index];
#line 1122 "SequencePathModule.cs"
                            double csharp2cuda_temp_320 = (second)->scalar_value;
                            (*(csharp2cuda_temp_317) = __dadd_rn(csharp2cuda_temp_318, __dsub_rn(csharp2cuda_temp_319, csharp2cuda_temp_320)));
#line 1123 "SequencePathModule.cs"
#line 1123 "SequencePathModule.cs"
                            double* csharp2cuda_temp_321 = &((result)[index]);
                            (*(csharp2cuda_temp_321) = sum);
#line 1124 "SequencePathModule.cs"
                            if ((!(isfinite(sum))))
                            {
#line 1125 "SequencePathModule.cs"
#line 1125 "SequencePathModule.cs"
                                int* csharp2cuda_temp_322 = &((output)->valid);
                                (*(csharp2cuda_temp_322) = 0);
                            }
                        }
#line 1120 "SequencePathModule.cs"
                        int* csharp2cuda_temp_315 = &(index);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_315));
                    }
                }
            }
#line 1128 "SequencePathModule.cs"
            break;
#line 1129 "SequencePathModule.cs"
        case 14:
#line 1130 "SequencePathModule.cs"
            {
#line 1131 "SequencePathModule.cs"
                int rows_count = (first)->count;
#line 1132 "SequencePathModule.cs"
                int columns_count = (second)->count;
#line 1133 "SequencePathModule.cs"
#line 1133 "SequencePathModule.cs"
                bool csharp2cuda_temp_323;
#line 1133 "SequencePathModule.cs"
                if (!(((rows_count) <= (0))))
                {
#line 1133 "SequencePathModule.cs"
                    csharp2cuda_temp_323 = ((columns_count) <= (0));
                }
                else
                {
#line 1133 "SequencePathModule.cs"
                    csharp2cuda_temp_323 = true;
                }
#line 1133 "SequencePathModule.cs"
                bool csharp2cuda_temp_324;
#line 1133 "SequencePathModule.cs"
                if (!(csharp2cuda_temp_323))
                {
#line 1133 "SequencePathModule.cs"
                    csharp2cuda_temp_324 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1133 "SequencePathModule.cs"
                    csharp2cuda_temp_324 = true;
                }
                if (csharp2cuda_temp_324)
#line 1134 "SequencePathModule.cs"
                {
#line 1135 "SequencePathModule.cs"
                    __syncthreads();
#line 1136 "SequencePathModule.cs"
                    if (((thread) == (0)))
                    {
#line 1137 "SequencePathModule.cs"
#line 1137 "SequencePathModule.cs"
                        int* csharp2cuda_temp_325 = &((output)->valid);
                        (*(csharp2cuda_temp_325) = 0);
                    }
#line 1138 "SequencePathModule.cs"
                    break;
                }
#line 1141 "SequencePathModule.cs"
                double* diagonal_even = scratch;
#line 1142 "SequencePathModule.cs"
                double* diagonal_odd = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_add(columns_count, 1));
#line 1143 "SequencePathModule.cs"
                {
#line 1143 "SequencePathModule.cs"
                    int diagonal = 2;
                    while (true)
                    {
                        if (!(((diagonal) <= (csharp2cuda_i32_add(rows_count, columns_count)))))
                            break;
#line 1144 "SequencePathModule.cs"
                        {
#line 1145 "SequencePathModule.cs"
                            double* csharp2cuda_temp_327;
#line 1145 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_and(diagonal, 1)) == (0)))
                            {
#line 1145 "SequencePathModule.cs"
                                csharp2cuda_temp_327 = diagonal_even;
                            }
                            else
                            {
#line 1145 "SequencePathModule.cs"
                                csharp2cuda_temp_327 = diagonal_odd;
                            }
#line 1145 "SequencePathModule.cs"
                            double* older = csharp2cuda_temp_327;
#line 1146 "SequencePathModule.cs"
                            double* csharp2cuda_temp_328;
#line 1146 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_and(diagonal, 1)) == (0)))
                            {
#line 1146 "SequencePathModule.cs"
                                csharp2cuda_temp_328 = diagonal_odd;
                            }
                            else
                            {
#line 1146 "SequencePathModule.cs"
                                csharp2cuda_temp_328 = diagonal_even;
                            }
#line 1146 "SequencePathModule.cs"
                            double* newer = csharp2cuda_temp_328;
#line 1147 "SequencePathModule.cs"
                            int csharp2cuda_temp_329;
#line 1147 "SequencePathModule.cs"
                            if (((csharp2cuda_i32_sub(diagonal, rows_count)) > (1)))
                            {
#line 1147 "SequencePathModule.cs"
                                csharp2cuda_temp_329 = csharp2cuda_i32_sub(diagonal, rows_count);
                            }
                            else
                            {
#line 1147 "SequencePathModule.cs"
                                csharp2cuda_temp_329 = 1;
                            }
#line 1147 "SequencePathModule.cs"
                            int low = csharp2cuda_temp_329;
#line 1148 "SequencePathModule.cs"
                            int csharp2cuda_temp_330;
#line 1148 "SequencePathModule.cs"
                            if (((columns_count) < (csharp2cuda_i32_sub(diagonal, 1))))
                            {
#line 1148 "SequencePathModule.cs"
                                csharp2cuda_temp_330 = columns_count;
                            }
                            else
                            {
#line 1148 "SequencePathModule.cs"
                                csharp2cuda_temp_330 = csharp2cuda_i32_sub(diagonal, 1);
                            }
#line 1148 "SequencePathModule.cs"
                            int high = csharp2cuda_temp_330;
#line 1149 "SequencePathModule.cs"
                            {
#line 1149 "SequencePathModule.cs"
                                int top = high;
                                while (true)
                                {
                                    if (!(((top) >= (low))))
                                        break;
#line 1150 "SequencePathModule.cs"
                                    {
#line 1151 "SequencePathModule.cs"
                                        int right = csharp2cuda_i32_sub(top, thread);
#line 1152 "SequencePathModule.cs"
                                        bool active = ((right) >= (low));
#line 1153 "SequencePathModule.cs"
                                        double value = 0.0;
#line 1154 "SequencePathModule.cs"
                                        if (active)
#line 1155 "SequencePathModule.cs"
                                        {
#line 1156 "SequencePathModule.cs"
                                            int left = csharp2cuda_i32_sub(diagonal, right);
#line 1157 "SequencePathModule.cs"
                                            double csharp2cuda_temp_333;
#line 1157 "SequencePathModule.cs"
                                            if (((left) == (1)))
                                            {
#line 1157 "SequencePathModule.cs"
                                                csharp2cuda_temp_333 = mathblocks_positive_infinity();
                                            }
                                            else
                                            {
#line 1157 "SequencePathModule.cs"
                                                csharp2cuda_temp_333 = (newer)[right];
                                            }
#line 1157 "SequencePathModule.cs"
                                            double above = csharp2cuda_temp_333;
#line 1158 "SequencePathModule.cs"
                                            double csharp2cuda_temp_334;
#line 1158 "SequencePathModule.cs"
                                            if (((right) == (1)))
                                            {
#line 1158 "SequencePathModule.cs"
                                                csharp2cuda_temp_334 = mathblocks_positive_infinity();
                                            }
                                            else
                                            {
#line 1158 "SequencePathModule.cs"
                                                csharp2cuda_temp_334 = (newer)[csharp2cuda_i32_sub(right, 1)];
                                            }
#line 1158 "SequencePathModule.cs"
                                            double before = csharp2cuda_temp_334;
#line 1159 "SequencePathModule.cs"
                                            bool csharp2cuda_temp_335;
#line 1159 "SequencePathModule.cs"
                                            if (!(((left) == (1))))
                                            {
#line 1159 "SequencePathModule.cs"
                                                csharp2cuda_temp_335 = ((right) == (1));
                                            }
                                            else
                                            {
#line 1159 "SequencePathModule.cs"
                                                csharp2cuda_temp_335 = true;
                                            }
#line 1159 "SequencePathModule.cs"
                                            double csharp2cuda_temp_336;
#line 1159 "SequencePathModule.cs"
                                            if (csharp2cuda_temp_335)
                                            {
#line 1160 "SequencePathModule.cs"
                                                bool csharp2cuda_temp_337;
#line 1160 "SequencePathModule.cs"
                                                if (((left) == (1)))
                                                {
#line 1160 "SequencePathModule.cs"
                                                    csharp2cuda_temp_337 = ((right) == (1));
                                                }
                                                else
                                                {
#line 1160 "SequencePathModule.cs"
                                                    csharp2cuda_temp_337 = false;
                                                }
#line 1160 "SequencePathModule.cs"
                                                double csharp2cuda_temp_338;
#line 1160 "SequencePathModule.cs"
                                                if (csharp2cuda_temp_337)
                                                {
#line 1160 "SequencePathModule.cs"
                                                    csharp2cuda_temp_338 = 0.0;
                                                }
                                                else
                                                {
#line 1160 "SequencePathModule.cs"
                                                    csharp2cuda_temp_338 = mathblocks_positive_infinity();
                                                }
#line 1159 "SequencePathModule.cs"
                                                csharp2cuda_temp_336 = csharp2cuda_temp_338;
                                            }
                                            else
                                            {
#line 1159 "SequencePathModule.cs"
                                                csharp2cuda_temp_336 = (older)[csharp2cuda_i32_sub(right, 1)];
                                            }
#line 1159 "SequencePathModule.cs"
                                            double corner = csharp2cuda_temp_336;
#line 1162 "SequencePathModule.cs"
                                            double csharp2cuda_temp_339;
#line 1162 "SequencePathModule.cs"
                                            if (((above) < (before)))
                                            {
#line 1162 "SequencePathModule.cs"
                                                csharp2cuda_temp_339 = above;
                                            }
                                            else
                                            {
#line 1162 "SequencePathModule.cs"
                                                csharp2cuda_temp_339 = before;
                                            }
#line 1162 "SequencePathModule.cs"
                                            double minimum = csharp2cuda_temp_339;
#line 1163 "SequencePathModule.cs"
#line 1163 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_340 = &(minimum);
#line 1163 "SequencePathModule.cs"
                                            double csharp2cuda_temp_341;
#line 1163 "SequencePathModule.cs"
                                            if (((minimum) < (corner)))
                                            {
#line 1163 "SequencePathModule.cs"
                                                csharp2cuda_temp_341 = minimum;
                                            }
                                            else
                                            {
#line 1163 "SequencePathModule.cs"
                                                csharp2cuda_temp_341 = corner;
                                            }
                                            (*(csharp2cuda_temp_340) = csharp2cuda_temp_341);
#line 1164 "SequencePathModule.cs"
#line 1164 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_342 = &(value);
#line 1164 "SequencePathModule.cs"
                                            double csharp2cuda_temp_343 = (a)[csharp2cuda_i32_sub(left, 1)];
#line 1164 "SequencePathModule.cs"
                                            double csharp2cuda_temp_344 = (b)[csharp2cuda_i32_sub(right, 1)];
                                            (*(csharp2cuda_temp_342) = __dadd_rn(fabs(__dsub_rn(csharp2cuda_temp_343, csharp2cuda_temp_344)), minimum));
                                        }
#line 1166 "SequencePathModule.cs"
                                        __syncthreads();
#line 1167 "SequencePathModule.cs"
                                        if (active)
                                        {
#line 1168 "SequencePathModule.cs"
#line 1168 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_345 = &((older)[right]);
                                            (*(csharp2cuda_temp_345) = value);
                                        }
#line 1169 "SequencePathModule.cs"
                                        __syncthreads();
                                    }
#line 1149 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_331 = &(top);
#line 1149 "SequencePathModule.cs"
                                    int csharp2cuda_temp_332 = *(csharp2cuda_temp_331);
                                    (*(csharp2cuda_temp_331) = csharp2cuda_i32_sub(csharp2cuda_temp_332, blockDim.x));
                                }
                            }
                        }
#line 1143 "SequencePathModule.cs"
                        int* csharp2cuda_temp_326 = &(diagonal);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_326));
                    }
                }
#line 1173 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 1174 "SequencePathModule.cs"
                {
#line 1175 "SequencePathModule.cs"
                    double* csharp2cuda_temp_346;
#line 1175 "SequencePathModule.cs"
                    if (((csharp2cuda_i32_and(csharp2cuda_i32_add(rows_count, columns_count), 1)) == (0)))
                    {
#line 1175 "SequencePathModule.cs"
                        csharp2cuda_temp_346 = diagonal_even;
                    }
                    else
                    {
#line 1175 "SequencePathModule.cs"
                        csharp2cuda_temp_346 = diagonal_odd;
                    }
#line 1175 "SequencePathModule.cs"
                    double* last = csharp2cuda_temp_346;
#line 1176 "SequencePathModule.cs"
#line 1176 "SequencePathModule.cs"
                    double* csharp2cuda_temp_347 = &((output)->scalar_value);
#line 1176 "SequencePathModule.cs"
                    double csharp2cuda_temp_348 = (last)[columns_count];
                    (*(csharp2cuda_temp_347) = csharp2cuda_temp_348);
#line 1177 "SequencePathModule.cs"
#line 1177 "SequencePathModule.cs"
                    double csharp2cuda_temp_349 = (output)->scalar_value;
                    if ((!(isfinite(csharp2cuda_temp_349))))
                    {
#line 1178 "SequencePathModule.cs"
#line 1178 "SequencePathModule.cs"
                        int* csharp2cuda_temp_350 = &((output)->valid);
                        (*(csharp2cuda_temp_350) = 0);
                    }
                }
            }
#line 1181 "SequencePathModule.cs"
            break;
#line 1182 "SequencePathModule.cs"
        case 15:
#line 1183 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1184 "SequencePathModule.cs"
            {
#line 1185 "SequencePathModule.cs"
#line 1185 "SequencePathModule.cs"
                double* csharp2cuda_temp_351 = &((output)->scalar_value);
#line 1187 "SequencePathModule.cs"
                int csharp2cuda_temp_352 = (first)->count;
#line 1188 "SequencePathModule.cs"
                double csharp2cuda_temp_353 = (second)->scalar_value;
#line 1189 "SequencePathModule.cs"
                int csharp2cuda_temp_354 = (third)->boolean_value;
#line 1185 "SequencePathModule.cs"
                double csharp2cuda_temp_355 = mathblocks_sequence_first_passage_value(a, csharp2cuda_temp_352, csharp2cuda_temp_353, ((csharp2cuda_temp_354) != (0)));
                (*(csharp2cuda_temp_351) = csharp2cuda_temp_355);
            }
#line 1191 "SequencePathModule.cs"
            break;
#line 1192 "SequencePathModule.cs"
        case 16:
#line 1193 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1194 "SequencePathModule.cs"
            {
#line 1195 "SequencePathModule.cs"
                double lower = (second)->scalar_value;
#line 1196 "SequencePathModule.cs"
                double upper = (third)->scalar_value;
#line 1197 "SequencePathModule.cs"
#line 1197 "SequencePathModule.cs"
                int csharp2cuda_temp_356 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_356);
#line 1198 "SequencePathModule.cs"
                if ((!(((lower) < (upper)))))
#line 1199 "SequencePathModule.cs"
                {
#line 1200 "SequencePathModule.cs"
#line 1200 "SequencePathModule.cs"
                    int* csharp2cuda_temp_357 = &((output)->valid);
                    (*(csharp2cuda_temp_357) = 0);
                }
                else
#line 1203 "SequencePathModule.cs"
                {
#line 1204 "SequencePathModule.cs"
                    double state = 0.0;
#line 1205 "SequencePathModule.cs"
                    {
#line 1205 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1205 "SequencePathModule.cs"
                            int csharp2cuda_temp_359 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_359))))
                                break;
#line 1206 "SequencePathModule.cs"
                            {
#line 1207 "SequencePathModule.cs"
#line 1207 "SequencePathModule.cs"
                                double csharp2cuda_temp_360 = (a)[index];
                                if (((csharp2cuda_temp_360) >= (upper)))
                                {
#line 1208 "SequencePathModule.cs"
#line 1208 "SequencePathModule.cs"
                                    double* csharp2cuda_temp_361 = &(state);
                                    (*(csharp2cuda_temp_361) = 1.0);
                                }
                                else
                                {
#line 1209 "SequencePathModule.cs"
#line 1209 "SequencePathModule.cs"
                                    double csharp2cuda_temp_362 = (a)[index];
                                    if (((csharp2cuda_temp_362) <= (lower)))
                                    {
#line 1210 "SequencePathModule.cs"
#line 1210 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_363 = &(state);
                                        (*(csharp2cuda_temp_363) = (-(1.0)));
                                    }
                                }
#line 1211 "SequencePathModule.cs"
#line 1211 "SequencePathModule.cs"
                                double* csharp2cuda_temp_364 = &((result)[index]);
                                (*(csharp2cuda_temp_364) = state);
                            }
#line 1205 "SequencePathModule.cs"
                            int* csharp2cuda_temp_358 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_358));
                        }
                    }
                }
            }
#line 1215 "SequencePathModule.cs"
            break;
#line 1216 "SequencePathModule.cs"
        case 17:
#line 1217 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1218 "SequencePathModule.cs"
            {
#line 1219 "SequencePathModule.cs"
                int csharp2cuda_temp_365 = (first)->count;
#line 1219 "SequencePathModule.cs"
                int csharp2cuda_temp_366;
#line 1219 "SequencePathModule.cs"
                if (((csharp2cuda_temp_365) == (0)))
                {
#line 1219 "SequencePathModule.cs"
                    csharp2cuda_temp_366 = 0;
                }
                else
                {
#line 1219 "SequencePathModule.cs"
                    int csharp2cuda_temp_367 = (first)->count;
#line 1219 "SequencePathModule.cs"
                    csharp2cuda_temp_366 = csharp2cuda_i32_sub(csharp2cuda_i32_mul(2, csharp2cuda_temp_367), 1);
                }
#line 1219 "SequencePathModule.cs"
                int rows = csharp2cuda_temp_366;
#line 1220 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, rows, 2);
#line 1221 "SequencePathModule.cs"
#line 1221 "SequencePathModule.cs"
                int csharp2cuda_temp_368 = (first)->count;
                if (((csharp2cuda_temp_368) <= (0)))
#line 1222 "SequencePathModule.cs"
                {
#line 1223 "SequencePathModule.cs"
#line 1223 "SequencePathModule.cs"
                    int* csharp2cuda_temp_369 = &((output)->valid);
                    (*(csharp2cuda_temp_369) = 0);
                }
                else
#line 1226 "SequencePathModule.cs"
                {
#line 1227 "SequencePathModule.cs"
#line 1227 "SequencePathModule.cs"
                    double* csharp2cuda_temp_370 = &((result)[0]);
#line 1227 "SequencePathModule.cs"
                    double csharp2cuda_temp_371 = (a)[0];
                    (*(csharp2cuda_temp_370) = csharp2cuda_temp_371);
#line 1228 "SequencePathModule.cs"
#line 1228 "SequencePathModule.cs"
                    double* csharp2cuda_temp_372 = &((result)[1]);
#line 1228 "SequencePathModule.cs"
                    double csharp2cuda_temp_373 = (a)[0];
                    (*(csharp2cuda_temp_372) = csharp2cuda_temp_373);
#line 1229 "SequencePathModule.cs"
                    int row = 0;
#line 1230 "SequencePathModule.cs"
                    {
#line 1230 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1230 "SequencePathModule.cs"
                            int csharp2cuda_temp_375 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_375))))
                                break;
#line 1231 "SequencePathModule.cs"
                            {
#line 1232 "SequencePathModule.cs"
#line 1232 "SequencePathModule.cs"
                                int* csharp2cuda_temp_376 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_376));
#line 1233 "SequencePathModule.cs"
#line 1233 "SequencePathModule.cs"
                                double* csharp2cuda_temp_377 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1233 "SequencePathModule.cs"
                                double csharp2cuda_temp_378 = (a)[index];
                                (*(csharp2cuda_temp_377) = csharp2cuda_temp_378);
#line 1234 "SequencePathModule.cs"
#line 1234 "SequencePathModule.cs"
                                double* csharp2cuda_temp_379 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1234 "SequencePathModule.cs"
                                double csharp2cuda_temp_380 = (a)[csharp2cuda_i32_sub(index, 1)];
                                (*(csharp2cuda_temp_379) = csharp2cuda_temp_380);
#line 1235 "SequencePathModule.cs"
#line 1235 "SequencePathModule.cs"
                                int* csharp2cuda_temp_381 = &(row);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_381));
#line 1236 "SequencePathModule.cs"
#line 1236 "SequencePathModule.cs"
                                double* csharp2cuda_temp_382 = &((result)[csharp2cuda_i32_mul(row, 2)]);
#line 1236 "SequencePathModule.cs"
                                double csharp2cuda_temp_383 = (a)[index];
                                (*(csharp2cuda_temp_382) = csharp2cuda_temp_383);
#line 1237 "SequencePathModule.cs"
#line 1237 "SequencePathModule.cs"
                                double* csharp2cuda_temp_384 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, 2), 1)]);
#line 1237 "SequencePathModule.cs"
                                double csharp2cuda_temp_385 = (a)[index];
                                (*(csharp2cuda_temp_384) = csharp2cuda_temp_385);
                            }
#line 1230 "SequencePathModule.cs"
                            int* csharp2cuda_temp_374 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_374));
                        }
                    }
                }
            }
#line 1241 "SequencePathModule.cs"
            break;
#line 1242 "SequencePathModule.cs"
        case 18:
#line 1243 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1244 "SequencePathModule.cs"
#line 1244 "SequencePathModule.cs"
                double* csharp2cuda_temp_386 = &((output)->scalar_value);
#line 1244 "SequencePathModule.cs"
                int csharp2cuda_temp_387 = (first)->count;
#line 1244 "SequencePathModule.cs"
                double csharp2cuda_temp_388 = mathblocks_sequence_longest_run_value(boolean_a, csharp2cuda_temp_387);
                (*(csharp2cuda_temp_386) = csharp2cuda_temp_388);
            }
#line 1245 "SequencePathModule.cs"
            break;
#line 1246 "SequencePathModule.cs"
        case 19:
        case 20:
#line 1248 "SequencePathModule.cs"
#line 1248 "SequencePathModule.cs"
            bool csharp2cuda_temp_389;
#line 1248 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1249 "SequencePathModule.cs"
                int csharp2cuda_temp_390 = (first)->count;
#line 1249 "SequencePathModule.cs"
                double* csharp2cuda_temp_391 = &((output)->scalar_value);
#line 1249 "SequencePathModule.cs"
                bool csharp2cuda_temp_392 = mathblocks_sequence_decline_value(a, csharp2cuda_temp_390, ((opcode) == (20)), csharp2cuda_temp_391);
#line 1248 "SequencePathModule.cs"
                csharp2cuda_temp_389 = (!(csharp2cuda_temp_392));
            }
            else
            {
#line 1248 "SequencePathModule.cs"
                csharp2cuda_temp_389 = false;
            }
            if (csharp2cuda_temp_389)
            {
#line 1250 "SequencePathModule.cs"
#line 1250 "SequencePathModule.cs"
                int* csharp2cuda_temp_393 = &((output)->valid);
                (*(csharp2cuda_temp_393) = 0);
            }
#line 1251 "SequencePathModule.cs"
            break;
#line 1252 "SequencePathModule.cs"
        case 21:
        case 22:
        case 29:
#line 1255 "SequencePathModule.cs"
#line 1255 "SequencePathModule.cs"
            bool csharp2cuda_temp_394;
#line 1255 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1258 "SequencePathModule.cs"
                int csharp2cuda_temp_395 = (first)->count;
#line 1259 "SequencePathModule.cs"
                double csharp2cuda_temp_396;
#line 1259 "SequencePathModule.cs"
                if (((opcode) == (22)))
                {
#line 1259 "SequencePathModule.cs"
                    csharp2cuda_temp_396 = 2.0;
                }
                else
                {
#line 1259 "SequencePathModule.cs"
                    double csharp2cuda_temp_397;
#line 1259 "SequencePathModule.cs"
                    if (((((void*)(second))) == (((void*)(nullptr)))))
                    {
#line 1259 "SequencePathModule.cs"
                        csharp2cuda_temp_397 = 1.0;
                    }
                    else
                    {
#line 1259 "SequencePathModule.cs"
                        csharp2cuda_temp_397 = (second)->scalar_value;
                    }
#line 1259 "SequencePathModule.cs"
                    csharp2cuda_temp_396 = csharp2cuda_temp_397;
                }
#line 1261 "SequencePathModule.cs"
                double* csharp2cuda_temp_398 = &((output)->scalar_value);
#line 1256 "SequencePathModule.cs"
                bool csharp2cuda_temp_399 = mathblocks_sequence_variation_value(a, csharp2cuda_temp_395, csharp2cuda_temp_396, ((opcode) == (29)), csharp2cuda_temp_398);
#line 1255 "SequencePathModule.cs"
                csharp2cuda_temp_394 = (!(csharp2cuda_temp_399));
            }
            else
            {
#line 1255 "SequencePathModule.cs"
                csharp2cuda_temp_394 = false;
            }
            if (csharp2cuda_temp_394)
            {
#line 1262 "SequencePathModule.cs"
#line 1262 "SequencePathModule.cs"
                int* csharp2cuda_temp_400 = &((output)->valid);
                (*(csharp2cuda_temp_400) = 0);
            }
#line 1263 "SequencePathModule.cs"
            break;
#line 1264 "SequencePathModule.cs"
        case 23:
#line 1265 "SequencePathModule.cs"
#line 1265 "SequencePathModule.cs"
            bool csharp2cuda_temp_401;
#line 1265 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1268 "SequencePathModule.cs"
                int csharp2cuda_temp_402 = (first)->count;
#line 1269 "SequencePathModule.cs"
                double csharp2cuda_temp_403 = (second)->scalar_value;
#line 1270 "SequencePathModule.cs"
                double* csharp2cuda_temp_404 = &((output)->scalar_value);
#line 1266 "SequencePathModule.cs"
                bool csharp2cuda_temp_405 = mathblocks_sequence_recurrence_value(a, csharp2cuda_temp_402, csharp2cuda_temp_403, csharp2cuda_temp_404);
#line 1265 "SequencePathModule.cs"
                csharp2cuda_temp_401 = (!(csharp2cuda_temp_405));
            }
            else
            {
#line 1265 "SequencePathModule.cs"
                csharp2cuda_temp_401 = false;
            }
            if (csharp2cuda_temp_401)
            {
#line 1271 "SequencePathModule.cs"
#line 1271 "SequencePathModule.cs"
                int* csharp2cuda_temp_406 = &((output)->valid);
                (*(csharp2cuda_temp_406) = 0);
            }
#line 1272 "SequencePathModule.cs"
            break;
#line 1273 "SequencePathModule.cs"
        case 24:
#line 1274 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1275 "SequencePathModule.cs"
            {
#line 1276 "SequencePathModule.cs"
#line 1276 "SequencePathModule.cs"
                int csharp2cuda_temp_407 = (first)->count;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_407);
#line 1277 "SequencePathModule.cs"
#line 1277 "SequencePathModule.cs"
                int csharp2cuda_temp_408 = (first)->count;
                if (((csharp2cuda_temp_408) <= (0)))
#line 1278 "SequencePathModule.cs"
                {
#line 1279 "SequencePathModule.cs"
#line 1279 "SequencePathModule.cs"
                    int* csharp2cuda_temp_409 = &((output)->valid);
                    (*(csharp2cuda_temp_409) = 0);
                }
                else
#line 1282 "SequencePathModule.cs"
                {
#line 1283 "SequencePathModule.cs"
                    double cumulative = 0.0;
#line 1284 "SequencePathModule.cs"
                    double minimum = 0.0;
#line 1285 "SequencePathModule.cs"
                    {
#line 1285 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1285 "SequencePathModule.cs"
                            int csharp2cuda_temp_411 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_411))))
                                break;
#line 1286 "SequencePathModule.cs"
                            {
#line 1287 "SequencePathModule.cs"
#line 1287 "SequencePathModule.cs"
                                double* csharp2cuda_temp_412 = &(cumulative);
#line 1287 "SequencePathModule.cs"
                                double csharp2cuda_temp_413 = *(csharp2cuda_temp_412);
#line 1287 "SequencePathModule.cs"
                                double csharp2cuda_temp_414 = (a)[index];
                                (*(csharp2cuda_temp_412) = __dadd_rn(csharp2cuda_temp_413, csharp2cuda_temp_414));
#line 1288 "SequencePathModule.cs"
#line 1288 "SequencePathModule.cs"
                                double* csharp2cuda_temp_415 = &(minimum);
#line 1288 "SequencePathModule.cs"
                                double csharp2cuda_temp_416;
#line 1288 "SequencePathModule.cs"
                                if (((minimum) < (cumulative)))
                                {
#line 1288 "SequencePathModule.cs"
                                    csharp2cuda_temp_416 = minimum;
                                }
                                else
                                {
#line 1288 "SequencePathModule.cs"
                                    csharp2cuda_temp_416 = cumulative;
                                }
                                (*(csharp2cuda_temp_415) = csharp2cuda_temp_416);
#line 1289 "SequencePathModule.cs"
#line 1289 "SequencePathModule.cs"
                                double* csharp2cuda_temp_417 = &((result)[index]);
                                (*(csharp2cuda_temp_417) = __dsub_rn(cumulative, minimum));
#line 1290 "SequencePathModule.cs"
#line 1290 "SequencePathModule.cs"
                                double csharp2cuda_temp_418 = (result)[index];
                                if ((!(isfinite(csharp2cuda_temp_418))))
                                {
#line 1291 "SequencePathModule.cs"
#line 1291 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_419 = &((output)->valid);
                                    (*(csharp2cuda_temp_419) = 0);
                                }
                            }
#line 1285 "SequencePathModule.cs"
                            int* csharp2cuda_temp_410 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_410));
                        }
                    }
                }
            }
#line 1295 "SequencePathModule.cs"
            break;
#line 1296 "SequencePathModule.cs"
        case 25:
#line 1297 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1298 "SequencePathModule.cs"
            {
#line 1299 "SequencePathModule.cs"
                unsigned long long csharp2cuda_temp_420 = (output)->data_pointer;
#line 1299 "SequencePathModule.cs"
                MathBlockSequencePathRun* runs = ((MathBlockSequencePathRun*)(csharp2cuda_temp_420));
#line 1300 "SequencePathModule.cs"
#line 1300 "SequencePathModule.cs"
                int csharp2cuda_temp_421 = (first)->count;
                if (((csharp2cuda_temp_421) == (0)))
#line 1301 "SequencePathModule.cs"
                {
#line 1302 "SequencePathModule.cs"
#line 1302 "SequencePathModule.cs"
                    int* csharp2cuda_temp_422 = &((output)->count);
                    (*(csharp2cuda_temp_422) = 0);
#line 1303 "SequencePathModule.cs"
#line 1303 "SequencePathModule.cs"
                    int* csharp2cuda_temp_423 = &((output)->rows);
                    (*(csharp2cuda_temp_423) = 0);
                }
                else
#line 1306 "SequencePathModule.cs"
                {
#line 1307 "SequencePathModule.cs"
                    int start = 0;
#line 1308 "SequencePathModule.cs"
                    int count = 0;
#line 1309 "SequencePathModule.cs"
                    {
#line 1309 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1309 "SequencePathModule.cs"
                            int csharp2cuda_temp_425 = (first)->count;
                            if (!(((index) <= (csharp2cuda_temp_425))))
                                break;
#line 1310 "SequencePathModule.cs"
                            {
#line 1311 "SequencePathModule.cs"
#line 1311 "SequencePathModule.cs"
                                int csharp2cuda_temp_426 = (first)->count;
#line 1311 "SequencePathModule.cs"
                                bool csharp2cuda_temp_427;
#line 1311 "SequencePathModule.cs"
                                if (((index) < (csharp2cuda_temp_426)))
                                {
#line 1311 "SequencePathModule.cs"
                                    double csharp2cuda_temp_428 = (a)[index];
#line 1311 "SequencePathModule.cs"
                                    double csharp2cuda_temp_429 = (a)[start];
#line 1311 "SequencePathModule.cs"
                                    csharp2cuda_temp_427 = ((csharp2cuda_temp_428) == (csharp2cuda_temp_429));
                                }
                                else
                                {
#line 1311 "SequencePathModule.cs"
                                    csharp2cuda_temp_427 = false;
                                }
                                if (csharp2cuda_temp_427)
                                {
#line 1312 "SequencePathModule.cs"
                                    goto csharp2cuda_for_continue_34;
                                }
#line 1313 "SequencePathModule.cs"
#line 1313 "SequencePathModule.cs"
                                int csharp2cuda_temp_430 = (output)->capacity;
                                if (((count) >= (csharp2cuda_temp_430)))
#line 1314 "SequencePathModule.cs"
                                {
#line 1315 "SequencePathModule.cs"
#line 1315 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_431 = &((output)->count);
#line 1315 "SequencePathModule.cs"
                                    int csharp2cuda_temp_432 = (output)->capacity;
#line 1315 "SequencePathModule.cs"
                                    int csharp2cuda_temp_433;
#line 1315 "SequencePathModule.cs"
                                    if (((csharp2cuda_temp_432) == (2147483647)))
                                    {
#line 1315 "SequencePathModule.cs"
                                        csharp2cuda_temp_433 = csharp2cuda_i32_neg(1);
                                    }
                                    else
                                    {
#line 1317 "SequencePathModule.cs"
                                        int csharp2cuda_temp_434 = (output)->capacity;
#line 1315 "SequencePathModule.cs"
                                        csharp2cuda_temp_433 = csharp2cuda_i32_add(csharp2cuda_temp_434, 1);
                                    }
                                    (*(csharp2cuda_temp_431) = csharp2cuda_temp_433);
#line 1318 "SequencePathModule.cs"
#line 1318 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_435 = &((output)->rows);
#line 1318 "SequencePathModule.cs"
                                    int csharp2cuda_temp_436 = (output)->count;
                                    (*(csharp2cuda_temp_435) = csharp2cuda_temp_436);
#line 1319 "SequencePathModule.cs"
#line 1319 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_437 = &((output)->valid);
                                    (*(csharp2cuda_temp_437) = 0);
#line 1320 "SequencePathModule.cs"
                                    break;
                                }
#line 1322 "SequencePathModule.cs"
#line 1322 "SequencePathModule.cs"
                                int* csharp2cuda_temp_438 = &(((runs)[count]).start);
                                (*(csharp2cuda_temp_438) = start);
#line 1323 "SequencePathModule.cs"
#line 1323 "SequencePathModule.cs"
                                int* csharp2cuda_temp_439 = &(((runs)[count]).length);
                                (*(csharp2cuda_temp_439) = csharp2cuda_i32_sub(index, start));
#line 1324 "SequencePathModule.cs"
#line 1324 "SequencePathModule.cs"
                                double* csharp2cuda_temp_440 = &(((runs)[count]).value);
#line 1324 "SequencePathModule.cs"
                                double csharp2cuda_temp_441 = (a)[start];
                                (*(csharp2cuda_temp_440) = csharp2cuda_temp_441);
#line 1325 "SequencePathModule.cs"
#line 1325 "SequencePathModule.cs"
                                int* csharp2cuda_temp_442 = &(count);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_442));
#line 1326 "SequencePathModule.cs"
#line 1326 "SequencePathModule.cs"
                                int* csharp2cuda_temp_443 = &(start);
                                (*(csharp2cuda_temp_443) = index);
                            }
                            csharp2cuda_for_continue_34:
#line 1309 "SequencePathModule.cs"
                            int* csharp2cuda_temp_424 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_424));
                        }
                    }
#line 1328 "SequencePathModule.cs"
                    if ((output)->valid)
#line 1329 "SequencePathModule.cs"
                    {
#line 1330 "SequencePathModule.cs"
#line 1330 "SequencePathModule.cs"
                        int* csharp2cuda_temp_444 = &((output)->count);
                        (*(csharp2cuda_temp_444) = count);
#line 1331 "SequencePathModule.cs"
#line 1331 "SequencePathModule.cs"
                        int* csharp2cuda_temp_445 = &((output)->rows);
                        (*(csharp2cuda_temp_445) = count);
                    }
                }
            }
#line 1335 "SequencePathModule.cs"
            break;
#line 1336 "SequencePathModule.cs"
        case 26:
#line 1337 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1338 "SequencePathModule.cs"
            {
#line 1339 "SequencePathModule.cs"
#line 1339 "SequencePathModule.cs"
                int csharp2cuda_temp_446 = (first)->columns;
                mathblocks_sequence_set_vector_shape(output, csharp2cuda_temp_446);
#line 1340 "SequencePathModule.cs"
#line 1340 "SequencePathModule.cs"
                int csharp2cuda_temp_447 = (first)->rows;
                if (((csharp2cuda_temp_447) <= (0)))
#line 1341 "SequencePathModule.cs"
                {
#line 1342 "SequencePathModule.cs"
#line 1342 "SequencePathModule.cs"
                    int* csharp2cuda_temp_448 = &((output)->valid);
                    (*(csharp2cuda_temp_448) = 0);
                }
                else
#line 1345 "SequencePathModule.cs"
                {
#line 1346 "SequencePathModule.cs"
                    {
#line 1346 "SequencePathModule.cs"
                        int column = 0;
                        while (true)
                        {
#line 1346 "SequencePathModule.cs"
                            int csharp2cuda_temp_450 = (first)->columns;
                            if (!(((column) < (csharp2cuda_temp_450))))
                                break;
#line 1347 "SequencePathModule.cs"
                            {
#line 1348 "SequencePathModule.cs"
#line 1348 "SequencePathModule.cs"
                                double* csharp2cuda_temp_451 = &((result)[column]);
#line 1348 "SequencePathModule.cs"
                                int csharp2cuda_temp_452 = (first)->rows;
#line 1348 "SequencePathModule.cs"
                                int csharp2cuda_temp_453 = (first)->columns;
#line 1348 "SequencePathModule.cs"
                                double csharp2cuda_temp_454 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(csharp2cuda_temp_452, 1), csharp2cuda_temp_453), column)];
#line 1348 "SequencePathModule.cs"
                                double csharp2cuda_temp_455 = (a)[column];
                                (*(csharp2cuda_temp_451) = __dsub_rn(csharp2cuda_temp_454, csharp2cuda_temp_455));
#line 1349 "SequencePathModule.cs"
#line 1349 "SequencePathModule.cs"
                                double csharp2cuda_temp_456 = (result)[column];
                                if ((!(isfinite(csharp2cuda_temp_456))))
                                {
#line 1349 "SequencePathModule.cs"
#line 1349 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_457 = &((output)->valid);
                                    (*(csharp2cuda_temp_457) = 0);
                                }
                            }
#line 1346 "SequencePathModule.cs"
                            int* csharp2cuda_temp_449 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_449));
                        }
                    }
                }
            }
#line 1353 "SequencePathModule.cs"
            break;
#line 1354 "SequencePathModule.cs"
        case 27:
#line 1355 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1356 "SequencePathModule.cs"
            {
#line 1357 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1358 "SequencePathModule.cs"
                int count = csharp2cuda_i32_mul(csharp2cuda_i32_mul(dimension, dimension), dimension);
#line 1359 "SequencePathModule.cs"
                mathblocks_sequence_set_vector_shape(output, count);
#line 1360 "SequencePathModule.cs"
#line 1360 "SequencePathModule.cs"
                int csharp2cuda_temp_458 = (first)->rows;
#line 1360 "SequencePathModule.cs"
                bool csharp2cuda_temp_459;
#line 1360 "SequencePathModule.cs"
                if (!(((csharp2cuda_temp_458) < (1))))
                {
#line 1360 "SequencePathModule.cs"
                    csharp2cuda_temp_459 = ((((void*)(scratch))) == (((void*)(nullptr))));
                }
                else
                {
#line 1360 "SequencePathModule.cs"
                    csharp2cuda_temp_459 = true;
                }
                if (csharp2cuda_temp_459)
#line 1361 "SequencePathModule.cs"
                {
#line 1362 "SequencePathModule.cs"
#line 1362 "SequencePathModule.cs"
                    int* csharp2cuda_temp_460 = &((output)->valid);
                    (*(csharp2cuda_temp_460) = 0);
                }
                else
#line 1365 "SequencePathModule.cs"
                {
#line 1366 "SequencePathModule.cs"
                    double* level_one = scratch;
#line 1367 "SequencePathModule.cs"
                    double* level_two = csharp2cuda_pointer_add(scratch, dimension);
#line 1368 "SequencePathModule.cs"
                    double* increment = csharp2cuda_pointer_add(level_two, csharp2cuda_i32_mul(dimension, dimension));
#line 1369 "SequencePathModule.cs"
                    {
#line 1369 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1370 "SequencePathModule.cs"
#line 1370 "SequencePathModule.cs"
                            double* csharp2cuda_temp_462 = &((level_one)[index]);
                            (*(csharp2cuda_temp_462) = 0.0);
#line 1369 "SequencePathModule.cs"
                            int* csharp2cuda_temp_461 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_461));
                        }
                    }
#line 1371 "SequencePathModule.cs"
                    {
#line 1371 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1372 "SequencePathModule.cs"
#line 1372 "SequencePathModule.cs"
                            double* csharp2cuda_temp_464 = &((level_two)[index]);
                            (*(csharp2cuda_temp_464) = 0.0);
#line 1371 "SequencePathModule.cs"
                            int* csharp2cuda_temp_463 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_463));
                        }
                    }
#line 1373 "SequencePathModule.cs"
                    {
#line 1373 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1374 "SequencePathModule.cs"
#line 1374 "SequencePathModule.cs"
                            double* csharp2cuda_temp_466 = &((result)[index]);
                            (*(csharp2cuda_temp_466) = 0.0);
#line 1373 "SequencePathModule.cs"
                            int* csharp2cuda_temp_465 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_465));
                        }
                    }
#line 1375 "SequencePathModule.cs"
                    {
#line 1375 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1375 "SequencePathModule.cs"
                            int csharp2cuda_temp_468 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_468))))
                                break;
#line 1376 "SequencePathModule.cs"
                            {
#line 1377 "SequencePathModule.cs"
                                {
#line 1377 "SequencePathModule.cs"
                                    int index = 0;
                                    while (true)
                                    {
                                        if (!(((index) < (dimension))))
                                            break;
#line 1378 "SequencePathModule.cs"
#line 1378 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_470 = &((increment)[index]);
#line 1378 "SequencePathModule.cs"
                                        double csharp2cuda_temp_471 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), index)];
#line 1378 "SequencePathModule.cs"
                                        double csharp2cuda_temp_472 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), index)];
                                        (*(csharp2cuda_temp_470) = __dsub_rn(csharp2cuda_temp_471, csharp2cuda_temp_472));
#line 1377 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_469 = &(index);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_469));
                                    }
                                }
#line 1379 "SequencePathModule.cs"
                                {
#line 1379 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1380 "SequencePathModule.cs"
                                        {
#line 1381 "SequencePathModule.cs"
                                            {
#line 1381 "SequencePathModule.cs"
                                                int middle = 0;
                                                while (true)
                                                {
                                                    if (!(((middle) < (dimension))))
                                                        break;
#line 1382 "SequencePathModule.cs"
                                                    {
#line 1383 "SequencePathModule.cs"
                                                        {
#line 1383 "SequencePathModule.cs"
                                                            int right = 0;
                                                            while (true)
                                                            {
                                                                if (!(((right) < (dimension))))
                                                                    break;
#line 1384 "SequencePathModule.cs"
                                                                {
#line 1385 "SequencePathModule.cs"
                                                                    int target = csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle), dimension), right);
#line 1386 "SequencePathModule.cs"
#line 1386 "SequencePathModule.cs"
                                                                    double* csharp2cuda_temp_476 = &((result)[target]);
#line 1386 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_477 = *(csharp2cuda_temp_476);
#line 1387 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_478 = (level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)];
#line 1387 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_479 = (increment)[right];
#line 1388 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_480 = (level_one)[left];
#line 1388 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_481 = (increment)[middle];
#line 1388 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_482 = (increment)[right];
#line 1388 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_483 = __ddiv_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_480, csharp2cuda_temp_481), csharp2cuda_temp_482), 2.0);
#line 1389 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_484 = (increment)[left];
#line 1389 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_485 = (increment)[middle];
#line 1389 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_486 = (increment)[right];
#line 1389 "SequencePathModule.cs"
                                                                    double csharp2cuda_temp_487 = __ddiv_rn(__dmul_rn(__dmul_rn(csharp2cuda_temp_484, csharp2cuda_temp_485), csharp2cuda_temp_486), 6.0);
                                                                    (*(csharp2cuda_temp_476) = __dadd_rn(csharp2cuda_temp_477, __dadd_rn(__dadd_rn(__dmul_rn(csharp2cuda_temp_478, csharp2cuda_temp_479), csharp2cuda_temp_483), csharp2cuda_temp_487)));
                                                                }
#line 1383 "SequencePathModule.cs"
                                                                int* csharp2cuda_temp_475 = &(right);
                                                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_475));
                                                            }
                                                        }
#line 1391 "SequencePathModule.cs"
#line 1391 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_488 = &((level_two)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), middle)]);
#line 1391 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_489 = *(csharp2cuda_temp_488);
#line 1392 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_490 = (level_one)[left];
#line 1392 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_491 = (increment)[middle];
#line 1393 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_492 = (increment)[left];
#line 1393 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_493 = (increment)[middle];
#line 1393 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_494 = __ddiv_rn(__dmul_rn(csharp2cuda_temp_492, csharp2cuda_temp_493), 2.0);
                                                        (*(csharp2cuda_temp_488) = __dadd_rn(csharp2cuda_temp_489, __dadd_rn(__dmul_rn(csharp2cuda_temp_490, csharp2cuda_temp_491), csharp2cuda_temp_494)));
                                                    }
#line 1381 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_474 = &(middle);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_474));
                                                }
                                            }
#line 1395 "SequencePathModule.cs"
#line 1395 "SequencePathModule.cs"
                                            double* csharp2cuda_temp_495 = &((level_one)[left]);
#line 1395 "SequencePathModule.cs"
                                            double csharp2cuda_temp_496 = *(csharp2cuda_temp_495);
#line 1395 "SequencePathModule.cs"
                                            double csharp2cuda_temp_497 = (increment)[left];
                                            (*(csharp2cuda_temp_495) = __dadd_rn(csharp2cuda_temp_496, csharp2cuda_temp_497));
                                        }
#line 1379 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_473 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_473));
                                    }
                                }
                            }
#line 1375 "SequencePathModule.cs"
                            int* csharp2cuda_temp_467 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_467));
                        }
                    }
#line 1398 "SequencePathModule.cs"
                    {
#line 1398 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (count))))
                                break;
#line 1399 "SequencePathModule.cs"
#line 1399 "SequencePathModule.cs"
                            double csharp2cuda_temp_499 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_499))))
                            {
#line 1399 "SequencePathModule.cs"
#line 1399 "SequencePathModule.cs"
                                int* csharp2cuda_temp_500 = &((output)->valid);
                                (*(csharp2cuda_temp_500) = 0);
                            }
#line 1398 "SequencePathModule.cs"
                            int* csharp2cuda_temp_498 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_498));
                        }
                    }
                }
            }
#line 1402 "SequencePathModule.cs"
            break;
#line 1403 "SequencePathModule.cs"
        case 28:
#line 1404 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1405 "SequencePathModule.cs"
            {
#line 1406 "SequencePathModule.cs"
                int dimension = (first)->columns;
#line 1407 "SequencePathModule.cs"
                mathblocks_sequence_set_matrix_shape(output, dimension, dimension);
#line 1408 "SequencePathModule.cs"
                if (((((void*)(scratch))) == (((void*)(nullptr)))))
#line 1409 "SequencePathModule.cs"
                {
#line 1410 "SequencePathModule.cs"
#line 1410 "SequencePathModule.cs"
                    int* csharp2cuda_temp_501 = &((output)->valid);
                    (*(csharp2cuda_temp_501) = 0);
                }
                else
#line 1413 "SequencePathModule.cs"
                {
#line 1414 "SequencePathModule.cs"
                    double* cumulative = scratch;
#line 1415 "SequencePathModule.cs"
                    double* increment = csharp2cuda_pointer_add(scratch, dimension);
#line 1416 "SequencePathModule.cs"
                    {
#line 1416 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (dimension))))
                                break;
#line 1417 "SequencePathModule.cs"
#line 1417 "SequencePathModule.cs"
                            double* csharp2cuda_temp_503 = &((cumulative)[index]);
                            (*(csharp2cuda_temp_503) = 0.0);
#line 1416 "SequencePathModule.cs"
                            int* csharp2cuda_temp_502 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_502));
                        }
                    }
#line 1418 "SequencePathModule.cs"
                    {
#line 1418 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1419 "SequencePathModule.cs"
#line 1419 "SequencePathModule.cs"
                            double* csharp2cuda_temp_505 = &((result)[index]);
                            (*(csharp2cuda_temp_505) = 0.0);
#line 1418 "SequencePathModule.cs"
                            int* csharp2cuda_temp_504 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_504));
                        }
                    }
#line 1420 "SequencePathModule.cs"
                    {
#line 1420 "SequencePathModule.cs"
                        int row = 1;
                        while (true)
                        {
#line 1420 "SequencePathModule.cs"
                            int csharp2cuda_temp_507 = (first)->rows;
                            if (!(((row) < (csharp2cuda_temp_507))))
                                break;
#line 1421 "SequencePathModule.cs"
                            {
#line 1422 "SequencePathModule.cs"
                                {
#line 1422 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1423 "SequencePathModule.cs"
#line 1423 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_509 = &((increment)[column]);
#line 1423 "SequencePathModule.cs"
                                        double csharp2cuda_temp_510 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, dimension), column)];
#line 1423 "SequencePathModule.cs"
                                        double csharp2cuda_temp_511 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_i32_sub(row, 1), dimension), column)];
                                        (*(csharp2cuda_temp_509) = __dsub_rn(csharp2cuda_temp_510, csharp2cuda_temp_511));
#line 1422 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_508 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_508));
                                    }
                                }
#line 1424 "SequencePathModule.cs"
                                {
#line 1424 "SequencePathModule.cs"
                                    int left = 0;
                                    while (true)
                                    {
                                        if (!(((left) < (dimension))))
                                            break;
#line 1425 "SequencePathModule.cs"
                                        {
#line 1426 "SequencePathModule.cs"
                                            {
#line 1426 "SequencePathModule.cs"
                                                int right = 0;
                                                while (true)
                                                {
                                                    if (!(((right) < (dimension))))
                                                        break;
#line 1427 "SequencePathModule.cs"
                                                    {
#line 1428 "SequencePathModule.cs"
#line 1428 "SequencePathModule.cs"
                                                        double* csharp2cuda_temp_514 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, dimension), right)]);
#line 1428 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_515 = *(csharp2cuda_temp_514);
#line 1429 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_516 = (cumulative)[left];
#line 1429 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_517 = (increment)[right];
#line 1430 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_518 = (increment)[left];
#line 1430 "SequencePathModule.cs"
                                                        double csharp2cuda_temp_519 = (increment)[right];
                                                        (*(csharp2cuda_temp_514) = __dadd_rn(csharp2cuda_temp_515, __dadd_rn(__dmul_rn(csharp2cuda_temp_516, csharp2cuda_temp_517), __dmul_rn(__dmul_rn(0.5, csharp2cuda_temp_518), csharp2cuda_temp_519))));
                                                    }
#line 1426 "SequencePathModule.cs"
                                                    int* csharp2cuda_temp_513 = &(right);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_513));
                                                }
                                            }
                                        }
#line 1424 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_512 = &(left);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_512));
                                    }
                                }
#line 1433 "SequencePathModule.cs"
                                {
#line 1433 "SequencePathModule.cs"
                                    int column = 0;
                                    while (true)
                                    {
                                        if (!(((column) < (dimension))))
                                            break;
#line 1434 "SequencePathModule.cs"
#line 1434 "SequencePathModule.cs"
                                        double* csharp2cuda_temp_521 = &((cumulative)[column]);
#line 1434 "SequencePathModule.cs"
                                        double csharp2cuda_temp_522 = *(csharp2cuda_temp_521);
#line 1434 "SequencePathModule.cs"
                                        double csharp2cuda_temp_523 = (increment)[column];
                                        (*(csharp2cuda_temp_521) = __dadd_rn(csharp2cuda_temp_522, csharp2cuda_temp_523));
#line 1433 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_520 = &(column);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_520));
                                    }
                                }
                            }
#line 1420 "SequencePathModule.cs"
                            int* csharp2cuda_temp_506 = &(row);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_506));
                        }
                    }
#line 1436 "SequencePathModule.cs"
                    {
#line 1436 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(dimension, dimension)))))
                                break;
#line 1437 "SequencePathModule.cs"
#line 1437 "SequencePathModule.cs"
                            double csharp2cuda_temp_525 = (result)[index];
                            if ((!(isfinite(csharp2cuda_temp_525))))
                            {
#line 1437 "SequencePathModule.cs"
#line 1437 "SequencePathModule.cs"
                                int* csharp2cuda_temp_526 = &((output)->valid);
                                (*(csharp2cuda_temp_526) = 0);
                            }
#line 1436 "SequencePathModule.cs"
                            int* csharp2cuda_temp_524 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_524));
                        }
                    }
                }
            }
#line 1440 "SequencePathModule.cs"
            break;
#line 1441 "SequencePathModule.cs"
        case 30:
        case 31:
#line 1443 "SequencePathModule.cs"
            if (((thread) == (0)))
            {
#line 1444 "SequencePathModule.cs"
#line 1444 "SequencePathModule.cs"
                double* csharp2cuda_temp_527 = &((output)->scalar_value);
#line 1444 "SequencePathModule.cs"
                int csharp2cuda_temp_528 = (first)->count;
#line 1444 "SequencePathModule.cs"
                double csharp2cuda_temp_529 = mathblocks_sequence_sign_change_value(a, csharp2cuda_temp_528, ((opcode) == (30)));
                (*(csharp2cuda_temp_527) = csharp2cuda_temp_529);
            }
#line 1445 "SequencePathModule.cs"
            break;
#line 1446 "SequencePathModule.cs"
        case 32:
#line 1447 "SequencePathModule.cs"
            if (((thread) == (0)))
#line 1448 "SequencePathModule.cs"
            {
#line 1449 "SequencePathModule.cs"
                int state_count = 0;
#line 1450 "SequencePathModule.cs"
#line 1450 "SequencePathModule.cs"
                double csharp2cuda_temp_530 = (second)->scalar_value;
#line 1450 "SequencePathModule.cs"
                int* csharp2cuda_temp_531 = &(state_count);
#line 1450 "SequencePathModule.cs"
                bool csharp2cuda_temp_532 = mathblocks_sequence_positive_integer(csharp2cuda_temp_530, csharp2cuda_temp_531);
#line 1450 "SequencePathModule.cs"
                bool csharp2cuda_temp_533;
#line 1450 "SequencePathModule.cs"
                if (!((!(csharp2cuda_temp_532))))
                {
#line 1450 "SequencePathModule.cs"
                    csharp2cuda_temp_533 = ((state_count) > (4096));
                }
                else
                {
#line 1450 "SequencePathModule.cs"
                    csharp2cuda_temp_533 = true;
                }
                if (csharp2cuda_temp_533)
#line 1451 "SequencePathModule.cs"
                {
#line 1452 "SequencePathModule.cs"
#line 1452 "SequencePathModule.cs"
                    int* csharp2cuda_temp_534 = &((output)->valid);
                    (*(csharp2cuda_temp_534) = 0);
                }
                else
#line 1455 "SequencePathModule.cs"
                {
#line 1456 "SequencePathModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, state_count, state_count);
#line 1457 "SequencePathModule.cs"
                    {
#line 1457 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1457 "SequencePathModule.cs"
                            bool csharp2cuda_temp_536 = (output)->valid;
#line 1457 "SequencePathModule.cs"
                            bool csharp2cuda_temp_537;
#line 1457 "SequencePathModule.cs"
                            if (csharp2cuda_temp_536)
                            {
#line 1457 "SequencePathModule.cs"
                                int csharp2cuda_temp_538 = (output)->count;
#line 1457 "SequencePathModule.cs"
                                csharp2cuda_temp_537 = ((index) < (csharp2cuda_temp_538));
                            }
                            else
                            {
#line 1457 "SequencePathModule.cs"
                                csharp2cuda_temp_537 = false;
                            }
                            if (!(csharp2cuda_temp_537))
                                break;
#line 1458 "SequencePathModule.cs"
#line 1458 "SequencePathModule.cs"
                            double* csharp2cuda_temp_539 = &((result)[index]);
                            (*(csharp2cuda_temp_539) = 0.0);
#line 1457 "SequencePathModule.cs"
                            int* csharp2cuda_temp_535 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_535));
                        }
                    }
#line 1459 "SequencePathModule.cs"
                    {
#line 1459 "SequencePathModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 1459 "SequencePathModule.cs"
                            bool csharp2cuda_temp_541 = (output)->valid;
#line 1459 "SequencePathModule.cs"
                            bool csharp2cuda_temp_542;
#line 1459 "SequencePathModule.cs"
                            if (csharp2cuda_temp_541)
                            {
#line 1459 "SequencePathModule.cs"
                                int csharp2cuda_temp_543 = (first)->count;
#line 1459 "SequencePathModule.cs"
                                csharp2cuda_temp_542 = ((index) < (csharp2cuda_temp_543));
                            }
                            else
                            {
#line 1459 "SequencePathModule.cs"
                                csharp2cuda_temp_542 = false;
                            }
                            if (!(csharp2cuda_temp_542))
                                break;
#line 1460 "SequencePathModule.cs"
                            {
#line 1461 "SequencePathModule.cs"
                                int state = 0;
#line 1462 "SequencePathModule.cs"
#line 1462 "SequencePathModule.cs"
                                double csharp2cuda_temp_544 = (a)[index];
#line 1462 "SequencePathModule.cs"
                                int* csharp2cuda_temp_545 = &(state);
#line 1462 "SequencePathModule.cs"
                                bool csharp2cuda_temp_546 = mathblocks_nonnegative_integer(csharp2cuda_temp_544, csharp2cuda_temp_545);
#line 1462 "SequencePathModule.cs"
                                bool csharp2cuda_temp_547;
#line 1462 "SequencePathModule.cs"
                                if (!((!(csharp2cuda_temp_546))))
                                {
#line 1462 "SequencePathModule.cs"
                                    csharp2cuda_temp_547 = ((state) >= (state_count));
                                }
                                else
                                {
#line 1462 "SequencePathModule.cs"
                                    csharp2cuda_temp_547 = true;
                                }
                                if (csharp2cuda_temp_547)
                                {
#line 1463 "SequencePathModule.cs"
#line 1463 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_548 = &((output)->valid);
                                    (*(csharp2cuda_temp_548) = 0);
                                }
                            }
#line 1459 "SequencePathModule.cs"
                            int* csharp2cuda_temp_540 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_540));
                        }
                    }
#line 1465 "SequencePathModule.cs"
                    {
#line 1465 "SequencePathModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 1465 "SequencePathModule.cs"
                            bool csharp2cuda_temp_550 = (output)->valid;
#line 1465 "SequencePathModule.cs"
                            bool csharp2cuda_temp_551;
#line 1465 "SequencePathModule.cs"
                            if (csharp2cuda_temp_550)
                            {
#line 1465 "SequencePathModule.cs"
                                int csharp2cuda_temp_552 = (first)->count;
#line 1465 "SequencePathModule.cs"
                                csharp2cuda_temp_551 = ((index) < (csharp2cuda_temp_552));
                            }
                            else
                            {
#line 1465 "SequencePathModule.cs"
                                csharp2cuda_temp_551 = false;
                            }
                            if (!(csharp2cuda_temp_551))
                                break;
#line 1466 "SequencePathModule.cs"
#line 1466 "SequencePathModule.cs"
                            double csharp2cuda_temp_553 = (a)[csharp2cuda_i32_sub(index, 1)];
#line 1466 "SequencePathModule.cs"
                            double csharp2cuda_temp_554 = (a)[index];
#line 1466 "SequencePathModule.cs"
                            double* csharp2cuda_temp_555 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(csharp2cuda_f64_to_i32(csharp2cuda_temp_553), state_count), csharp2cuda_f64_to_i32(csharp2cuda_temp_554))]);
#line 1466 "SequencePathModule.cs"
                            double csharp2cuda_temp_556 = *(csharp2cuda_temp_555);
                            (*(csharp2cuda_temp_555) = __dadd_rn(csharp2cuda_temp_556, 1.0));
#line 1465 "SequencePathModule.cs"
                            int* csharp2cuda_temp_549 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_549));
                        }
                    }
                }
            }
#line 1469 "SequencePathModule.cs"
            break;
    }
}

#line 45 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_positive_integer(double value, int* result)
#line 47 "SequencePathModule.cs"
{
#line 48 "SequencePathModule.cs"
#line 48 "SequencePathModule.cs"
    bool csharp2cuda_temp_0 = mathblocks_nonnegative_integer(value, result);
#line 48 "SequencePathModule.cs"
    bool csharp2cuda_temp_1;
#line 48 "SequencePathModule.cs"
    if (csharp2cuda_temp_0)
    {
#line 48 "SequencePathModule.cs"
        int csharp2cuda_temp_2 = *(result);
#line 48 "SequencePathModule.cs"
        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (0));
    }
    else
    {
#line 48 "SequencePathModule.cs"
        csharp2cuda_temp_1 = false;
    }
    return csharp2cuda_temp_1;
}

#line 98 "SequencePathModule.cs"
__device__ void mathblocks_sequence_prepare_order_ranks(
    const double* values,
    int count,
    unsigned char* scratch,
    MathBlockSlot* output)
#line 104 "SequencePathModule.cs"
{
#line 105 "SequencePathModule.cs"
    int thread = threadIdx.x;
#line 106 "SequencePathModule.cs"
    unsigned long long* first_keys = ((unsigned long long*)(scratch));
#line 107 "SequencePathModule.cs"
    unsigned long long* second_keys = csharp2cuda_pointer_add(first_keys, count);
#line 108 "SequencePathModule.cs"
    int* first_indexes = ((int*)(csharp2cuda_pointer_add(second_keys, count)));
#line 109 "SequencePathModule.cs"
    int* second_indexes = csharp2cuda_pointer_add(first_indexes, count);
#line 110 "SequencePathModule.cs"
    int* ranks = csharp2cuda_pointer_add(second_indexes, count);
#line 111 "SequencePathModule.cs"
    int* lower_heap = csharp2cuda_pointer_add(ranks, count);
#line 112 "SequencePathModule.cs"
    int csharp2cuda_temp_0 = (output)->boolean_value;
#line 112 "SequencePathModule.cs"
    int* upper_heap = csharp2cuda_pointer_add(lower_heap, csharp2cuda_temp_0);
#line 113 "SequencePathModule.cs"
    int csharp2cuda_temp_1 = (output)->boolean_value;
#line 113 "SequencePathModule.cs"
    int* positions = csharp2cuda_pointer_add(upper_heap, csharp2cuda_temp_1);
#line 114 "SequencePathModule.cs"
    int* kinds = csharp2cuda_pointer_add(positions, count);
#line 118 "SequencePathModule.cs"
    const int virtual_lanes = 128;
#line 119 "SequencePathModule.cs"
    int* zero_counts = csharp2cuda_pointer_add(kinds, count);
#line 120 "SequencePathModule.cs"
    int* zero_prefix = csharp2cuda_pointer_add(zero_counts, virtual_lanes);
#line 122 "SequencePathModule.cs"
    {
#line 122 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 123 "SequencePathModule.cs"
            {
#line 124 "SequencePathModule.cs"
#line 124 "SequencePathModule.cs"
                double csharp2cuda_temp_4 = (values)[index];
                if ((!(isfinite(csharp2cuda_temp_4))))
                {
#line 125 "SequencePathModule.cs"
                    atomicExch(&((output)->valid), 0);
                }
#line 126 "SequencePathModule.cs"
#line 126 "SequencePathModule.cs"
                unsigned long long* csharp2cuda_temp_5 = &((first_keys)[index]);
#line 126 "SequencePathModule.cs"
                double csharp2cuda_temp_6 = (values)[index];
                (*(csharp2cuda_temp_5) = mathblocks_sequence_order_key(csharp2cuda_temp_6));
#line 127 "SequencePathModule.cs"
#line 127 "SequencePathModule.cs"
                int* csharp2cuda_temp_7 = &((first_indexes)[index]);
                (*(csharp2cuda_temp_7) = index);
            }
#line 122 "SequencePathModule.cs"
            int* csharp2cuda_temp_2 = &(index);
#line 122 "SequencePathModule.cs"
            int csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
            (*(csharp2cuda_temp_2) = csharp2cuda_i32_add(csharp2cuda_temp_3, blockDim.x));
        }
    }
#line 129 "SequencePathModule.cs"
    __syncthreads();
#line 130 "SequencePathModule.cs"
#line 130 "SequencePathModule.cs"
    bool csharp2cuda_temp_8 = (output)->valid;
    if ((!(csharp2cuda_temp_8)))
    {
#line 131 "SequencePathModule.cs"
        return;
    }
#line 133 "SequencePathModule.cs"
    unsigned long long* source_keys = first_keys;
#line 134 "SequencePathModule.cs"
    unsigned long long* destination_keys = second_keys;
#line 135 "SequencePathModule.cs"
    int* source_indexes = first_indexes;
#line 136 "SequencePathModule.cs"
    int* destination_indexes = second_indexes;
#line 137 "SequencePathModule.cs"
    {
#line 137 "SequencePathModule.cs"
        int bit = 0;
        while (true)
        {
            if (!(((bit) < (64))))
                break;
#line 138 "SequencePathModule.cs"
            {
#line 139 "SequencePathModule.cs"
                {
#line 139 "SequencePathModule.cs"
                    int lane = thread;
                    while (true)
                    {
                        if (!(((lane) < (virtual_lanes))))
                            break;
#line 140 "SequencePathModule.cs"
                        {
#line 141 "SequencePathModule.cs"
                            long long csharp2cuda_temp_12 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(lane))), ((long long)(virtual_lanes)));
#line 141 "SequencePathModule.cs"
                            int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_12);
#line 142 "SequencePathModule.cs"
                            long long csharp2cuda_temp_13 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(lane, 1)))), ((long long)(virtual_lanes)));
#line 142 "SequencePathModule.cs"
                            int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_13);
#line 143 "SequencePathModule.cs"
                            int zeros = 0;
#line 144 "SequencePathModule.cs"
                            {
#line 144 "SequencePathModule.cs"
                                int index = begin;
                                while (true)
                                {
                                    if (!(((index) < (end))))
                                        break;
#line 145 "SequencePathModule.cs"
#line 145 "SequencePathModule.cs"
                                    unsigned long long csharp2cuda_temp_15 = (source_keys)[index];
                                    if (((((csharp2cuda_u64_shr(csharp2cuda_temp_15, bit)) & (1ull))) == (0ull)))
                                    {
#line 146 "SequencePathModule.cs"
#line 146 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_16 = &(zeros);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_16));
                                    }
#line 144 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_14 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
                                }
                            }
#line 147 "SequencePathModule.cs"
#line 147 "SequencePathModule.cs"
                            int* csharp2cuda_temp_17 = &((zero_counts)[lane]);
                            (*(csharp2cuda_temp_17) = zeros);
                        }
#line 139 "SequencePathModule.cs"
                        int* csharp2cuda_temp_10 = &(lane);
#line 139 "SequencePathModule.cs"
                        int csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                        (*(csharp2cuda_temp_10) = csharp2cuda_i32_add(csharp2cuda_temp_11, blockDim.x));
                    }
                }
#line 149 "SequencePathModule.cs"
                __syncthreads();
#line 150 "SequencePathModule.cs"
                if (((thread) == (0)))
#line 151 "SequencePathModule.cs"
                {
#line 152 "SequencePathModule.cs"
                    int prefix = 0;
#line 153 "SequencePathModule.cs"
                    {
#line 153 "SequencePathModule.cs"
                        int lane = 0;
                        while (true)
                        {
                            if (!(((lane) < (virtual_lanes))))
                                break;
#line 154 "SequencePathModule.cs"
                            {
#line 155 "SequencePathModule.cs"
#line 155 "SequencePathModule.cs"
                                int* csharp2cuda_temp_19 = &((zero_prefix)[lane]);
                                (*(csharp2cuda_temp_19) = prefix);
#line 156 "SequencePathModule.cs"
#line 156 "SequencePathModule.cs"
                                int* csharp2cuda_temp_20 = &(prefix);
#line 156 "SequencePathModule.cs"
                                int csharp2cuda_temp_21 = *(csharp2cuda_temp_20);
#line 156 "SequencePathModule.cs"
                                int csharp2cuda_temp_22 = (zero_counts)[lane];
                                (*(csharp2cuda_temp_20) = csharp2cuda_i32_add(csharp2cuda_temp_21, csharp2cuda_temp_22));
                            }
#line 153 "SequencePathModule.cs"
                            int* csharp2cuda_temp_18 = &(lane);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_18));
                        }
                    }
#line 158 "SequencePathModule.cs"
#line 158 "SequencePathModule.cs"
                    int* csharp2cuda_temp_23 = &((output)->columns);
                    (*(csharp2cuda_temp_23) = prefix);
                }
#line 160 "SequencePathModule.cs"
                __syncthreads();
#line 161 "SequencePathModule.cs"
                {
#line 161 "SequencePathModule.cs"
                    int lane = thread;
                    while (true)
                    {
                        if (!(((lane) < (virtual_lanes))))
                            break;
#line 162 "SequencePathModule.cs"
                        {
#line 163 "SequencePathModule.cs"
                            long long csharp2cuda_temp_26 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(lane))), ((long long)(virtual_lanes)));
#line 163 "SequencePathModule.cs"
                            int begin = csharp2cuda_i32_from_bits(csharp2cuda_temp_26);
#line 164 "SequencePathModule.cs"
                            long long csharp2cuda_temp_27 = csharp2cuda_i64_div(csharp2cuda_i64_mul(((long long)(count)), ((long long)(csharp2cuda_i32_add(lane, 1)))), ((long long)(virtual_lanes)));
#line 164 "SequencePathModule.cs"
                            int end = csharp2cuda_i32_from_bits(csharp2cuda_temp_27);
#line 165 "SequencePathModule.cs"
                            int zero_destination = (zero_prefix)[lane];
#line 166 "SequencePathModule.cs"
                            int csharp2cuda_temp_28 = (output)->columns;
#line 166 "SequencePathModule.cs"
                            int one_destination = csharp2cuda_i32_sub(csharp2cuda_i32_add(csharp2cuda_temp_28, begin), zero_destination);
#line 167 "SequencePathModule.cs"
                            {
#line 167 "SequencePathModule.cs"
                                int index = begin;
                                while (true)
                                {
                                    if (!(((index) < (end))))
                                        break;
#line 168 "SequencePathModule.cs"
                                    {
#line 169 "SequencePathModule.cs"
                                        unsigned long long key = (source_keys)[index];
#line 170 "SequencePathModule.cs"
                                        int csharp2cuda_temp_30;
#line 170 "SequencePathModule.cs"
                                        if (((((csharp2cuda_u64_shr(key, bit)) & (1ull))) == (0ull)))
                                        {
#line 171 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_31 = &(zero_destination);
#line 170 "SequencePathModule.cs"
                                            csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_31));
                                        }
                                        else
                                        {
#line 172 "SequencePathModule.cs"
                                            int* csharp2cuda_temp_32 = &(one_destination);
#line 170 "SequencePathModule.cs"
                                            csharp2cuda_temp_30 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_32));
                                        }
#line 170 "SequencePathModule.cs"
                                        int destination = csharp2cuda_temp_30;
#line 173 "SequencePathModule.cs"
#line 173 "SequencePathModule.cs"
                                        unsigned long long* csharp2cuda_temp_33 = &((destination_keys)[destination]);
                                        (*(csharp2cuda_temp_33) = key);
#line 174 "SequencePathModule.cs"
#line 174 "SequencePathModule.cs"
                                        int* csharp2cuda_temp_34 = &((destination_indexes)[destination]);
#line 174 "SequencePathModule.cs"
                                        int csharp2cuda_temp_35 = (source_indexes)[index];
                                        (*(csharp2cuda_temp_34) = csharp2cuda_temp_35);
                                    }
#line 167 "SequencePathModule.cs"
                                    int* csharp2cuda_temp_29 = &(index);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_29));
                                }
                            }
                        }
#line 161 "SequencePathModule.cs"
                        int* csharp2cuda_temp_24 = &(lane);
#line 161 "SequencePathModule.cs"
                        int csharp2cuda_temp_25 = *(csharp2cuda_temp_24);
                        (*(csharp2cuda_temp_24) = csharp2cuda_i32_add(csharp2cuda_temp_25, blockDim.x));
                    }
                }
#line 177 "SequencePathModule.cs"
                __syncthreads();
#line 178 "SequencePathModule.cs"
                unsigned long long* key_swap = source_keys;
#line 179 "SequencePathModule.cs"
#line 179 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_36 = &(source_keys);
                (*(csharp2cuda_temp_36) = destination_keys);
#line 180 "SequencePathModule.cs"
#line 180 "SequencePathModule.cs"
                unsigned long long** csharp2cuda_temp_37 = &(destination_keys);
                (*(csharp2cuda_temp_37) = key_swap);
#line 181 "SequencePathModule.cs"
                int* index_swap = source_indexes;
#line 182 "SequencePathModule.cs"
#line 182 "SequencePathModule.cs"
                int** csharp2cuda_temp_38 = &(source_indexes);
                (*(csharp2cuda_temp_38) = destination_indexes);
#line 183 "SequencePathModule.cs"
#line 183 "SequencePathModule.cs"
                int** csharp2cuda_temp_39 = &(destination_indexes);
                (*(csharp2cuda_temp_39) = index_swap);
            }
#line 137 "SequencePathModule.cs"
            int* csharp2cuda_temp_9 = &(bit);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_9));
        }
    }
#line 185 "SequencePathModule.cs"
    {
#line 185 "SequencePathModule.cs"
        int index = thread;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 186 "SequencePathModule.cs"
#line 186 "SequencePathModule.cs"
            int csharp2cuda_temp_42 = (source_indexes)[index];
#line 186 "SequencePathModule.cs"
            int* csharp2cuda_temp_43 = &((ranks)[csharp2cuda_temp_42]);
            (*(csharp2cuda_temp_43) = index);
#line 185 "SequencePathModule.cs"
            int* csharp2cuda_temp_40 = &(index);
#line 185 "SequencePathModule.cs"
            int csharp2cuda_temp_41 = *(csharp2cuda_temp_40);
            (*(csharp2cuda_temp_40) = csharp2cuda_i32_add(csharp2cuda_temp_41, blockDim.x));
        }
    }
#line 187 "SequencePathModule.cs"
    __syncthreads();
#line 188 "SequencePathModule.cs"
    if (((thread) == (0)))
    {
#line 189 "SequencePathModule.cs"
#line 189 "SequencePathModule.cs"
        int* csharp2cuda_temp_44 = &((output)->columns);
        (*(csharp2cuda_temp_44) = 0);
    }
#line 190 "SequencePathModule.cs"
    __syncthreads();
}

#line 344 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rebalance_heaps(
    int* lower_heap,
    int* lower_count,
    int* upper_heap,
    int* upper_count,
    int target_lower_count,
    int* positions,
    int* kinds,
    const int* ranks)
#line 354 "SequencePathModule.cs"
{
#line 355 "SequencePathModule.cs"
    while (true)
    {
#line 355 "SequencePathModule.cs"
        int csharp2cuda_temp_0 = *(lower_count);
        if (!(((csharp2cuda_temp_0) > (target_lower_count))))
            break;
#line 356 "SequencePathModule.cs"
        {
#line 357 "SequencePathModule.cs"
            int item = (lower_heap)[0];
#line 358 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(lower_heap, lower_count, item, positions, kinds, ranks, true);
#line 366 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(upper_heap, upper_count, item, 1, positions, kinds, ranks, false);
        }
    }
#line 376 "SequencePathModule.cs"
    while (true)
    {
#line 376 "SequencePathModule.cs"
        int csharp2cuda_temp_1 = *(lower_count);
        if (!(((csharp2cuda_temp_1) < (target_lower_count))))
            break;
#line 377 "SequencePathModule.cs"
        {
#line 378 "SequencePathModule.cs"
            int item = (upper_heap)[0];
#line 379 "SequencePathModule.cs"
            mathblocks_sequence_heap_remove(upper_heap, upper_count, item, positions, kinds, ranks, false);
#line 387 "SequencePathModule.cs"
            mathblocks_sequence_heap_insert(lower_heap, lower_count, item, 0, positions, kinds, ranks, true);
        }
    }
}

#line 525 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_recurrence_value(
    const double* values,
    int count,
    double threshold,
    double* value)
#line 531 "SequencePathModule.cs"
{
#line 532 "SequencePathModule.cs"
#line 532 "SequencePathModule.cs"
    bool csharp2cuda_temp_0;
#line 532 "SequencePathModule.cs"
    if (!(((count) <= (0))))
    {
#line 532 "SequencePathModule.cs"
        csharp2cuda_temp_0 = ((threshold) < (0.0));
    }
    else
    {
#line 532 "SequencePathModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 533 "SequencePathModule.cs"
        return false;
    }
#line 534 "SequencePathModule.cs"
    long long recurrent = ((long long)(0));
#line 535 "SequencePathModule.cs"
    long long total = csharp2cuda_i64_mul(((long long)(count)), ((long long)(count)));
#line 536 "SequencePathModule.cs"
    {
#line 536 "SequencePathModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 537 "SequencePathModule.cs"
            {
#line 537 "SequencePathModule.cs"
                int right = 0;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 538 "SequencePathModule.cs"
#line 538 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[left];
#line 538 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[right];
                    if (((fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4))) <= (threshold)))
                    {
#line 539 "SequencePathModule.cs"
#line 539 "SequencePathModule.cs"
                        long long* csharp2cuda_temp_5 = &(recurrent);
                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_5));
                    }
#line 537 "SequencePathModule.cs"
                    int* csharp2cuda_temp_2 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                }
            }
#line 536 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 540 "SequencePathModule.cs"
#line 540 "SequencePathModule.cs"
    double* csharp2cuda_temp_6 = value;
#line 540 "SequencePathModule.cs"
    double csharp2cuda_temp_7 = __ddiv_rn(((double)(recurrent)), ((double)(total)));
    (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
#line 541 "SequencePathModule.cs"
    return true;
}

#line 399 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_extreme(
    const double* values,
    int count,
    int width,
    double* result,
    int* deque,
    bool minimum)
#line 407 "SequencePathModule.cs"
{
#line 408 "SequencePathModule.cs"
    int head = 0;
#line 409 "SequencePathModule.cs"
    int tail = 0;
#line 410 "SequencePathModule.cs"
    {
#line 410 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 411 "SequencePathModule.cs"
            {
#line 412 "SequencePathModule.cs"
                while (true)
                {
#line 412 "SequencePathModule.cs"
                    bool csharp2cuda_temp_1;
#line 412 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 412 "SequencePathModule.cs"
                        int csharp2cuda_temp_2 = (deque)[head];
#line 412 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) <= (csharp2cuda_i32_sub(index, width)));
                    }
                    else
                    {
#line 412 "SequencePathModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 413 "SequencePathModule.cs"
#line 413 "SequencePathModule.cs"
                    int* csharp2cuda_temp_3 = &(head);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_3));
                }
#line 414 "SequencePathModule.cs"
                while (true)
                {
#line 414 "SequencePathModule.cs"
                    bool csharp2cuda_temp_4;
#line 414 "SequencePathModule.cs"
                    if (((head) < (tail)))
                    {
#line 414 "SequencePathModule.cs"
                        bool csharp2cuda_temp_5;
#line 414 "SequencePathModule.cs"
                        if (minimum)
                        {
#line 415 "SequencePathModule.cs"
                            int csharp2cuda_temp_6 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 415 "SequencePathModule.cs"
                            double csharp2cuda_temp_7 = (values)[csharp2cuda_temp_6];
#line 415 "SequencePathModule.cs"
                            double csharp2cuda_temp_8 = (values)[index];
#line 414 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_7) > (csharp2cuda_temp_8));
                        }
                        else
                        {
#line 416 "SequencePathModule.cs"
                            int csharp2cuda_temp_9 = (deque)[csharp2cuda_i32_sub(tail, 1)];
#line 416 "SequencePathModule.cs"
                            double csharp2cuda_temp_10 = (values)[csharp2cuda_temp_9];
#line 416 "SequencePathModule.cs"
                            double csharp2cuda_temp_11 = (values)[index];
#line 414 "SequencePathModule.cs"
                            csharp2cuda_temp_5 = ((csharp2cuda_temp_10) < (csharp2cuda_temp_11));
                        }
#line 414 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = csharp2cuda_temp_5;
                    }
                    else
                    {
#line 414 "SequencePathModule.cs"
                        csharp2cuda_temp_4 = false;
                    }
                    if (!(csharp2cuda_temp_4))
                        break;
#line 417 "SequencePathModule.cs"
                    {
#line 418 "SequencePathModule.cs"
#line 418 "SequencePathModule.cs"
                        int* csharp2cuda_temp_12 = &(tail);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_12));
                    }
                }
#line 420 "SequencePathModule.cs"
#line 420 "SequencePathModule.cs"
                int* csharp2cuda_temp_13 = &(tail);
#line 420 "SequencePathModule.cs"
                int csharp2cuda_temp_14 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_13));
#line 420 "SequencePathModule.cs"
                int* csharp2cuda_temp_15 = &((deque)[csharp2cuda_temp_14]);
                (*(csharp2cuda_temp_15) = index);
#line 421 "SequencePathModule.cs"
                if (((index) >= (csharp2cuda_i32_sub(width, 1))))
                {
#line 422 "SequencePathModule.cs"
#line 422 "SequencePathModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
#line 422 "SequencePathModule.cs"
                    int csharp2cuda_temp_17 = (deque)[head];
#line 422 "SequencePathModule.cs"
                    double csharp2cuda_temp_18 = (values)[csharp2cuda_temp_17];
                    (*(csharp2cuda_temp_16) = csharp2cuda_temp_18);
                }
            }
#line 410 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 426 "SequencePathModule.cs"
__device__ void mathblocks_sequence_rolling_sum(
    const double* values,
    int count,
    int width,
    double* result)
#line 432 "SequencePathModule.cs"
{
#line 433 "SequencePathModule.cs"
    double sum = 0.0;
#line 434 "SequencePathModule.cs"
    {
#line 434 "SequencePathModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (width))))
                break;
#line 435 "SequencePathModule.cs"
#line 435 "SequencePathModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 435 "SequencePathModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 435 "SequencePathModule.cs"
            double csharp2cuda_temp_3 = (values)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, csharp2cuda_temp_3));
#line 434 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 436 "SequencePathModule.cs"
#line 436 "SequencePathModule.cs"
    double* csharp2cuda_temp_4 = &((result)[0]);
    (*(csharp2cuda_temp_4) = sum);
#line 437 "SequencePathModule.cs"
    {
#line 437 "SequencePathModule.cs"
        int index = width;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 438 "SequencePathModule.cs"
            {
#line 439 "SequencePathModule.cs"
#line 439 "SequencePathModule.cs"
                double* csharp2cuda_temp_6 = &(sum);
#line 439 "SequencePathModule.cs"
                double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
#line 439 "SequencePathModule.cs"
                double csharp2cuda_temp_8 = (values)[index];
#line 439 "SequencePathModule.cs"
                double csharp2cuda_temp_9 = (values)[csharp2cuda_i32_sub(index, width)];
                (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, __dsub_rn(csharp2cuda_temp_8, csharp2cuda_temp_9)));
#line 440 "SequencePathModule.cs"
#line 440 "SequencePathModule.cs"
                double* csharp2cuda_temp_10 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_sub(index, width), 1)]);
                (*(csharp2cuda_temp_10) = sum);
            }
#line 437 "SequencePathModule.cs"
            int* csharp2cuda_temp_5 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_5));
        }
    }
}

#line 64 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_matrix_shape(
    MathBlockSlot* output,
    int rows,
    int columns)
#line 69 "SequencePathModule.cs"
{
#line 70 "SequencePathModule.cs"
    long long count = csharp2cuda_i64_mul(((long long)(rows)), ((long long)(columns)));
#line 71 "SequencePathModule.cs"
#line 71 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = rows);
#line 72 "SequencePathModule.cs"
#line 72 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = columns);
#line 73 "SequencePathModule.cs"
#line 73 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
#line 73 "SequencePathModule.cs"
    int csharp2cuda_temp_3;
#line 73 "SequencePathModule.cs"
    if (((count) > (2147483647LL)))
    {
#line 73 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_neg(1);
    }
    else
    {
#line 73 "SequencePathModule.cs"
        csharp2cuda_temp_3 = csharp2cuda_i32_from_bits(count);
    }
    (*(csharp2cuda_temp_2) = csharp2cuda_temp_3);
#line 74 "SequencePathModule.cs"
#line 74 "SequencePathModule.cs"
    bool csharp2cuda_temp_4;
#line 74 "SequencePathModule.cs"
    if (!(((rows) < (0))))
    {
#line 74 "SequencePathModule.cs"
        csharp2cuda_temp_4 = ((columns) < (0));
    }
    else
    {
#line 74 "SequencePathModule.cs"
        csharp2cuda_temp_4 = true;
    }
#line 74 "SequencePathModule.cs"
    bool csharp2cuda_temp_5;
#line 74 "SequencePathModule.cs"
    if (!(csharp2cuda_temp_4))
    {
#line 74 "SequencePathModule.cs"
        int csharp2cuda_temp_6 = (output)->capacity;
#line 74 "SequencePathModule.cs"
        csharp2cuda_temp_5 = ((count) > (((long long)(csharp2cuda_temp_6))));
    }
    else
    {
#line 74 "SequencePathModule.cs"
        csharp2cuda_temp_5 = true;
    }
    if (csharp2cuda_temp_5)
#line 75 "SequencePathModule.cs"
    {
#line 76 "SequencePathModule.cs"
#line 76 "SequencePathModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
        (*(csharp2cuda_temp_7) = 0);
#line 77 "SequencePathModule.cs"
        return;
    }
}

#line 51 "SequencePathModule.cs"
__device__ void mathblocks_sequence_set_vector_shape(MathBlockSlot* output, int count)
#line 53 "SequencePathModule.cs"
{
#line 54 "SequencePathModule.cs"
#line 54 "SequencePathModule.cs"
    int* csharp2cuda_temp_0 = &((output)->rows);
    (*(csharp2cuda_temp_0) = count);
#line 55 "SequencePathModule.cs"
#line 55 "SequencePathModule.cs"
    int* csharp2cuda_temp_1 = &((output)->columns);
    (*(csharp2cuda_temp_1) = 0);
#line 56 "SequencePathModule.cs"
#line 56 "SequencePathModule.cs"
    int* csharp2cuda_temp_2 = &((output)->count);
    (*(csharp2cuda_temp_2) = count);
#line 57 "SequencePathModule.cs"
#line 57 "SequencePathModule.cs"
    bool csharp2cuda_temp_3;
#line 57 "SequencePathModule.cs"
    if (!(((count) < (0))))
    {
#line 57 "SequencePathModule.cs"
        int csharp2cuda_temp_4 = (output)->capacity;
#line 57 "SequencePathModule.cs"
        csharp2cuda_temp_3 = ((count) > (csharp2cuda_temp_4));
    }
    else
    {
#line 57 "SequencePathModule.cs"
        csharp2cuda_temp_3 = true;
    }
    if (csharp2cuda_temp_3)
#line 58 "SequencePathModule.cs"
    {
#line 59 "SequencePathModule.cs"
#line 59 "SequencePathModule.cs"
        int* csharp2cuda_temp_5 = &((output)->valid);
        (*(csharp2cuda_temp_5) = 0);
#line 60 "SequencePathModule.cs"
        return;
    }
}

#line 545 "SequencePathModule.cs"
__device__ double mathblocks_sequence_sign_change_value(
    const double* values,
    int count,
    bool differenced)
#line 550 "SequencePathModule.cs"
{
#line 551 "SequencePathModule.cs"
    int changes = 0;
#line 552 "SequencePathModule.cs"
    int previous = 0;
#line 553 "SequencePathModule.cs"
    int csharp2cuda_temp_0;
#line 553 "SequencePathModule.cs"
    if (differenced)
    {
#line 553 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 1;
    }
    else
    {
#line 553 "SequencePathModule.cs"
        csharp2cuda_temp_0 = 0;
    }
#line 553 "SequencePathModule.cs"
    int start = csharp2cuda_temp_0;
#line 554 "SequencePathModule.cs"
    {
#line 554 "SequencePathModule.cs"
        int index = start;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 555 "SequencePathModule.cs"
            {
#line 556 "SequencePathModule.cs"
                double csharp2cuda_temp_2;
#line 556 "SequencePathModule.cs"
                if (differenced)
                {
#line 556 "SequencePathModule.cs"
                    double csharp2cuda_temp_3 = (values)[index];
#line 556 "SequencePathModule.cs"
                    double csharp2cuda_temp_4 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 556 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = __dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4);
                }
                else
                {
#line 556 "SequencePathModule.cs"
                    csharp2cuda_temp_2 = (values)[index];
                }
#line 556 "SequencePathModule.cs"
                double difference = csharp2cuda_temp_2;
#line 557 "SequencePathModule.cs"
                int csharp2cuda_temp_5;
#line 557 "SequencePathModule.cs"
                if (((difference) > (0.0)))
                {
#line 557 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = 1;
                }
                else
                {
#line 557 "SequencePathModule.cs"
                    int csharp2cuda_temp_6;
#line 557 "SequencePathModule.cs"
                    if (((difference) < (0.0)))
                    {
#line 557 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = csharp2cuda_i32_neg(1);
                    }
                    else
                    {
#line 557 "SequencePathModule.cs"
                        csharp2cuda_temp_6 = 0;
                    }
#line 557 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = csharp2cuda_temp_6;
                }
#line 557 "SequencePathModule.cs"
                int current = csharp2cuda_temp_5;
#line 558 "SequencePathModule.cs"
                if (((current) == (0)))
                {
#line 559 "SequencePathModule.cs"
                    goto csharp2cuda_for_continue_0;
                }
#line 560 "SequencePathModule.cs"
#line 560 "SequencePathModule.cs"
                bool csharp2cuda_temp_7;
#line 560 "SequencePathModule.cs"
                if (((previous) != (0)))
                {
#line 560 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = ((current) != (previous));
                }
                else
                {
#line 560 "SequencePathModule.cs"
                    csharp2cuda_temp_7 = false;
                }
                if (csharp2cuda_temp_7)
                {
#line 561 "SequencePathModule.cs"
#line 561 "SequencePathModule.cs"
                    int* csharp2cuda_temp_8 = &(changes);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_8));
                }
#line 562 "SequencePathModule.cs"
#line 562 "SequencePathModule.cs"
                int* csharp2cuda_temp_9 = &(previous);
                (*(csharp2cuda_temp_9) = current);
            }
            csharp2cuda_for_continue_0:
#line 554 "SequencePathModule.cs"
            int* csharp2cuda_temp_1 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
        }
    }
#line 564 "SequencePathModule.cs"
    return ((double)(changes));
}

#line 503 "SequencePathModule.cs"
__device__ bool mathblocks_sequence_variation_value(
    const double* values,
    int count,
    double order,
    bool absolute,
    double* value)
#line 510 "SequencePathModule.cs"
{
#line 511 "SequencePathModule.cs"
    if (((count) <= (0)))
    {
#line 512 "SequencePathModule.cs"
        return false;
    }
#line 513 "SequencePathModule.cs"
    if ((!(((order) > (0.0)))))
    {
#line 514 "SequencePathModule.cs"
        return false;
    }
#line 515 "SequencePathModule.cs"
    double total = 0.0;
#line 516 "SequencePathModule.cs"
    {
#line 516 "SequencePathModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 517 "SequencePathModule.cs"
            {
#line 518 "SequencePathModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 518 "SequencePathModule.cs"
                double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_sub(index, 1)];
#line 518 "SequencePathModule.cs"
                double change = fabs(__dsub_rn(csharp2cuda_temp_1, csharp2cuda_temp_2));
#line 519 "SequencePathModule.cs"
#line 519 "SequencePathModule.cs"
                double* csharp2cuda_temp_3 = &(total);
#line 519 "SequencePathModule.cs"
                double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 519 "SequencePathModule.cs"
                double csharp2cuda_temp_5;
#line 519 "SequencePathModule.cs"
                if (absolute)
                {
#line 519 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = change;
                }
                else
                {
#line 519 "SequencePathModule.cs"
                    csharp2cuda_temp_5 = mathblocks_power(change, order);
                }
                (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, csharp2cuda_temp_5));
            }
#line 516 "SequencePathModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 521 "SequencePathModule.cs"
#line 521 "SequencePathModule.cs"
    double* csharp2cuda_temp_6 = value;
    (*(csharp2cuda_temp_6) = total);
#line 522 "SequencePathModule.cs"
    return isfinite(total);
}