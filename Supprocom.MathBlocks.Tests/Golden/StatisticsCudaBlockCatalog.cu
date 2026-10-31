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

#line 170 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means);

#line 348 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output);

#line 217 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_kendall_value(
    const double* left_values,
    const double* right_values,
    int count,
    double* value);

#line 46 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count);

#line 142 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count);

#line 197 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_moment_value(
    const double* values,
    int count,
    double order_value,
    bool central,
    double* value);

#line 313 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_averages(
    const double* values,
    int count,
    double* averages);

#line 328 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_slopes(
    const double* x,
    const double* y,
    int count,
    double* slopes);

#line 81 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count);

#line 67 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count);

#line 52 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count);

#line 149 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result);

#line 255 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_shape_moment_value(
    const double* values,
    int count,
    bool kurtosis,
    double* value);

#line 92 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result);

#line 111 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_in_place(double* values, int count);

#line 127 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability);

#line 282 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_weighted_value(
    const double* values,
    const double* weights,
    int count,
    bool variance,
    double* value);

#line 170 "StatisticsModule.cs"
__device__ void mathblocks_statistics_center_distance(
    const double* values,
    int count,
    double* result,
    double* row_means)
#line 176 "StatisticsModule.cs"
{
#line 177 "StatisticsModule.cs"
    double total_mean = 0.0;
#line 178 "StatisticsModule.cs"
    {
#line 178 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 179 "StatisticsModule.cs"
            {
#line 180 "StatisticsModule.cs"
#line 180 "StatisticsModule.cs"
                double* csharp2cuda_temp_1 = &((row_means)[row]);
                (*(csharp2cuda_temp_1) = 0.0);
#line 181 "StatisticsModule.cs"
                {
#line 181 "StatisticsModule.cs"
                    int column = 0;
                    while (true)
                    {
                        if (!(((column) < (count))))
                            break;
#line 182 "StatisticsModule.cs"
                        {
#line 183 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[row];
#line 183 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (values)[column];
#line 183 "StatisticsModule.cs"
                            double distance = fabs(__dsub_rn(csharp2cuda_temp_3, csharp2cuda_temp_4));
#line 184 "StatisticsModule.cs"
#line 184 "StatisticsModule.cs"
                            double* csharp2cuda_temp_5 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
                            (*(csharp2cuda_temp_5) = distance);
#line 185 "StatisticsModule.cs"
#line 185 "StatisticsModule.cs"
                            double* csharp2cuda_temp_6 = &((row_means)[row]);
#line 185 "StatisticsModule.cs"
                            double csharp2cuda_temp_7 = *(csharp2cuda_temp_6);
                            (*(csharp2cuda_temp_6) = __dadd_rn(csharp2cuda_temp_7, distance));
#line 186 "StatisticsModule.cs"
#line 186 "StatisticsModule.cs"
                            double* csharp2cuda_temp_8 = &(total_mean);
#line 186 "StatisticsModule.cs"
                            double csharp2cuda_temp_9 = *(csharp2cuda_temp_8);
                            (*(csharp2cuda_temp_8) = __dadd_rn(csharp2cuda_temp_9, distance));
                        }
#line 181 "StatisticsModule.cs"
                        int* csharp2cuda_temp_2 = &(column);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
                    }
                }
#line 188 "StatisticsModule.cs"
#line 188 "StatisticsModule.cs"
                double* csharp2cuda_temp_10 = &((row_means)[row]);
#line 188 "StatisticsModule.cs"
                double csharp2cuda_temp_11 = *(csharp2cuda_temp_10);
                (*(csharp2cuda_temp_10) = __ddiv_rn(csharp2cuda_temp_11, ((double)(count))));
            }
#line 178 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 190 "StatisticsModule.cs"
#line 190 "StatisticsModule.cs"
    double* csharp2cuda_temp_12 = &(total_mean);
#line 190 "StatisticsModule.cs"
    double csharp2cuda_temp_13 = *(csharp2cuda_temp_12);
    (*(csharp2cuda_temp_12) = __ddiv_rn(csharp2cuda_temp_13, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 191 "StatisticsModule.cs"
    {
#line 191 "StatisticsModule.cs"
        int row = 0;
        while (true)
        {
            if (!(((row) < (count))))
                break;
#line 192 "StatisticsModule.cs"
            {
#line 192 "StatisticsModule.cs"
                int column = 0;
                while (true)
                {
                    if (!(((column) < (count))))
                        break;
#line 193 "StatisticsModule.cs"
#line 193 "StatisticsModule.cs"
                    double* csharp2cuda_temp_16 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, count), column)]);
#line 193 "StatisticsModule.cs"
                    double csharp2cuda_temp_17 = *(csharp2cuda_temp_16);
#line 194 "StatisticsModule.cs"
                    double csharp2cuda_temp_18 = (row_means)[row];
#line 194 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (row_means)[column];
                    (*(csharp2cuda_temp_16) = __dsub_rn(csharp2cuda_temp_17, __dsub_rn(__dadd_rn(csharp2cuda_temp_18, csharp2cuda_temp_19), total_mean)));
#line 192 "StatisticsModule.cs"
                    int* csharp2cuda_temp_15 = &(column);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_15));
                }
            }
#line 191 "StatisticsModule.cs"
            int* csharp2cuda_temp_14 = &(row);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_14));
        }
    }
}

#line 348 "StatisticsModule.cs"
__device__ void mathblocks_statistics_dispatch(
    int opcode,
    MathBlockSlot** inputs,
    int input_count,
    MathBlockSlot* output)
#line 354 "StatisticsModule.cs"
{
#line 355 "StatisticsModule.cs"
    int thread = threadIdx.x;
#line 356 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_0;
#line 356 "StatisticsModule.cs"
    if (((input_count) > (0)))
    {
#line 356 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (inputs)[0];
    }
    else
    {
#line 356 "StatisticsModule.cs"
        csharp2cuda_temp_0 = ((MathBlockSlot*)(nullptr));
    }
#line 356 "StatisticsModule.cs"
    const MathBlockSlot* first = csharp2cuda_temp_0;
#line 357 "StatisticsModule.cs"
    MathBlockSlot* csharp2cuda_temp_1;
#line 357 "StatisticsModule.cs"
    if (((input_count) > (1)))
    {
#line 357 "StatisticsModule.cs"
        csharp2cuda_temp_1 = (inputs)[1];
    }
    else
    {
#line 357 "StatisticsModule.cs"
        csharp2cuda_temp_1 = ((MathBlockSlot*)(nullptr));
    }
#line 357 "StatisticsModule.cs"
    const MathBlockSlot* second = csharp2cuda_temp_1;
#line 358 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 359 "StatisticsModule.cs"
    {
#line 360 "StatisticsModule.cs"
#line 360 "StatisticsModule.cs"
        double* csharp2cuda_temp_2 = &((output)->scalar_value);
        (*(csharp2cuda_temp_2) = 0.0);
#line 361 "StatisticsModule.cs"
#line 361 "StatisticsModule.cs"
        int* csharp2cuda_temp_3 = &((output)->boolean_value);
        (*(csharp2cuda_temp_3) = 0);
#line 362 "StatisticsModule.cs"
#line 362 "StatisticsModule.cs"
        int* csharp2cuda_temp_4 = &((output)->rows);
        (*(csharp2cuda_temp_4) = 0);
#line 363 "StatisticsModule.cs"
#line 363 "StatisticsModule.cs"
        int* csharp2cuda_temp_5 = &((output)->columns);
        (*(csharp2cuda_temp_5) = 0);
#line 364 "StatisticsModule.cs"
#line 364 "StatisticsModule.cs"
        int* csharp2cuda_temp_6 = &((output)->count);
        (*(csharp2cuda_temp_6) = 0);
#line 365 "StatisticsModule.cs"
#line 365 "StatisticsModule.cs"
        int* csharp2cuda_temp_7 = &((output)->valid);
#line 365 "StatisticsModule.cs"
        bool csharp2cuda_temp_8;
#line 365 "StatisticsModule.cs"
        if (!(((((void*)(first))) == (((void*)(nullptr))))))
        {
#line 365 "StatisticsModule.cs"
            csharp2cuda_temp_8 = (first)->valid;
        }
        else
        {
#line 365 "StatisticsModule.cs"
            csharp2cuda_temp_8 = true;
        }
        (*(csharp2cuda_temp_7) = csharp2cuda_temp_8);
#line 366 "StatisticsModule.cs"
        if (((((void*)(second))) != (((void*)(nullptr)))))
        {
#line 367 "StatisticsModule.cs"
#line 367 "StatisticsModule.cs"
            int* csharp2cuda_temp_9 = &((output)->valid);
#line 367 "StatisticsModule.cs"
            bool csharp2cuda_temp_10 = (output)->valid;
#line 367 "StatisticsModule.cs"
            bool csharp2cuda_temp_11;
#line 367 "StatisticsModule.cs"
            if (csharp2cuda_temp_10)
            {
#line 367 "StatisticsModule.cs"
                csharp2cuda_temp_11 = (second)->valid;
            }
            else
            {
#line 367 "StatisticsModule.cs"
                csharp2cuda_temp_11 = false;
            }
            (*(csharp2cuda_temp_9) = csharp2cuda_temp_11);
        }
    }
#line 369 "StatisticsModule.cs"
    __syncthreads();
#line 370 "StatisticsModule.cs"
#line 370 "StatisticsModule.cs"
    bool csharp2cuda_temp_12 = (output)->valid;
    if ((!(csharp2cuda_temp_12)))
    {
#line 371 "StatisticsModule.cs"
        return;
    }
#line 373 "StatisticsModule.cs"
    double* csharp2cuda_temp_13;
#line 373 "StatisticsModule.cs"
    if (((((void*)(first))) == (((void*)(nullptr)))))
    {
#line 373 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(nullptr));
    }
    else
    {
#line 373 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_14 = (first)->data_pointer;
#line 373 "StatisticsModule.cs"
        csharp2cuda_temp_13 = ((double*)(csharp2cuda_temp_14));
    }
#line 373 "StatisticsModule.cs"
    const double* a = csharp2cuda_temp_13;
#line 374 "StatisticsModule.cs"
    double* csharp2cuda_temp_15;
#line 374 "StatisticsModule.cs"
    if (((((void*)(second))) == (((void*)(nullptr)))))
    {
#line 374 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(nullptr));
    }
    else
    {
#line 374 "StatisticsModule.cs"
        unsigned long long csharp2cuda_temp_16 = (second)->data_pointer;
#line 374 "StatisticsModule.cs"
        csharp2cuda_temp_15 = ((double*)(csharp2cuda_temp_16));
    }
#line 374 "StatisticsModule.cs"
    const double* b = csharp2cuda_temp_15;
#line 375 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_17 = (output)->data_pointer;
#line 375 "StatisticsModule.cs"
    double* result = ((double*)(csharp2cuda_temp_17));
#line 376 "StatisticsModule.cs"
    unsigned long long csharp2cuda_temp_18 = (output)->scratch_pointer;
#line 376 "StatisticsModule.cs"
    double* scratch = ((double*)(csharp2cuda_temp_18));
#line 378 "StatisticsModule.cs"
    if (((thread) == (0)))
#line 379 "StatisticsModule.cs"
    {
#line 380 "StatisticsModule.cs"
        switch (opcode)
        {
#line 382 "StatisticsModule.cs"
            case 0:
#line 383 "StatisticsModule.cs"
                {
#line 384 "StatisticsModule.cs"
                    int lag = 0;
#line 385 "StatisticsModule.cs"
#line 385 "StatisticsModule.cs"
                    double csharp2cuda_temp_19 = (second)->scalar_value;
#line 385 "StatisticsModule.cs"
                    int* csharp2cuda_temp_20 = &(lag);
#line 385 "StatisticsModule.cs"
                    bool csharp2cuda_temp_21 = mathblocks_sequence_positive_integer(csharp2cuda_temp_19, csharp2cuda_temp_20);
#line 385 "StatisticsModule.cs"
                    bool csharp2cuda_temp_22;
#line 385 "StatisticsModule.cs"
                    if (!((!(csharp2cuda_temp_21))))
                    {
#line 385 "StatisticsModule.cs"
                        int csharp2cuda_temp_23 = (first)->count;
#line 385 "StatisticsModule.cs"
                        csharp2cuda_temp_22 = ((lag) >= (csharp2cuda_temp_23));
                    }
                    else
                    {
#line 385 "StatisticsModule.cs"
                        csharp2cuda_temp_22 = true;
                    }
                    if (csharp2cuda_temp_22)
#line 386 "StatisticsModule.cs"
                    {
#line 387 "StatisticsModule.cs"
#line 387 "StatisticsModule.cs"
                        int* csharp2cuda_temp_24 = &((output)->valid);
                        (*(csharp2cuda_temp_24) = 0);
#line 388 "StatisticsModule.cs"
                        break;
                    }
#line 390 "StatisticsModule.cs"
                    int csharp2cuda_temp_25 = (first)->count;
#line 390 "StatisticsModule.cs"
                    int count = csharp2cuda_i32_sub(csharp2cuda_temp_25, lag);
#line 391 "StatisticsModule.cs"
#line 391 "StatisticsModule.cs"
                    double* csharp2cuda_temp_26 = &((output)->scalar_value);
#line 391 "StatisticsModule.cs"
                    double csharp2cuda_temp_27 = mathblocks_statistics_pearson(a, csharp2cuda_pointer_add(a, lag), count);
                    (*(csharp2cuda_temp_26) = csharp2cuda_temp_27);
#line 392 "StatisticsModule.cs"
                    break;
                }
#line 394 "StatisticsModule.cs"
            case 1:
            case 18:
#line 396 "StatisticsModule.cs"
#line 398 "StatisticsModule.cs"
                int csharp2cuda_temp_28 = (first)->count;
#line 399 "StatisticsModule.cs"
                double csharp2cuda_temp_29 = (second)->scalar_value;
#line 401 "StatisticsModule.cs"
                double* csharp2cuda_temp_30 = &((output)->scalar_value);
#line 396 "StatisticsModule.cs"
                bool csharp2cuda_temp_31 = mathblocks_statistics_moment_value(a, csharp2cuda_temp_28, csharp2cuda_temp_29, ((opcode) == (1)), csharp2cuda_temp_30);
                if ((!(csharp2cuda_temp_31)))
                {
#line 402 "StatisticsModule.cs"
#line 402 "StatisticsModule.cs"
                    int* csharp2cuda_temp_32 = &((output)->valid);
                    (*(csharp2cuda_temp_32) = 0);
                }
#line 403 "StatisticsModule.cs"
                break;
#line 404 "StatisticsModule.cs"
            case 2:
#line 405 "StatisticsModule.cs"
                {
#line 406 "StatisticsModule.cs"
                    int rows = (first)->rows;
#line 407 "StatisticsModule.cs"
                    int columns = (first)->columns;
#line 408 "StatisticsModule.cs"
                    mathblocks_sequence_set_matrix_shape(output, columns, columns);
#line 409 "StatisticsModule.cs"
#line 409 "StatisticsModule.cs"
                    bool csharp2cuda_temp_33;
#line 409 "StatisticsModule.cs"
                    if (!(((rows) <= (0))))
                    {
#line 409 "StatisticsModule.cs"
                        csharp2cuda_temp_33 = ((columns) <= (0));
                    }
                    else
                    {
#line 409 "StatisticsModule.cs"
                        csharp2cuda_temp_33 = true;
                    }
#line 409 "StatisticsModule.cs"
                    bool csharp2cuda_temp_34;
#line 409 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_33))
                    {
#line 409 "StatisticsModule.cs"
                        csharp2cuda_temp_34 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 409 "StatisticsModule.cs"
                        csharp2cuda_temp_34 = true;
                    }
                    if (csharp2cuda_temp_34)
#line 410 "StatisticsModule.cs"
                    {
#line 411 "StatisticsModule.cs"
#line 411 "StatisticsModule.cs"
                        int* csharp2cuda_temp_35 = &((output)->valid);
                        (*(csharp2cuda_temp_35) = 0);
#line 412 "StatisticsModule.cs"
                        break;
                    }
#line 414 "StatisticsModule.cs"
                    {
#line 414 "StatisticsModule.cs"
                        int column = 0;
                        while (true)
                        {
                            if (!(((column) < (columns))))
                                break;
#line 415 "StatisticsModule.cs"
                            {
#line 416 "StatisticsModule.cs"
#line 416 "StatisticsModule.cs"
                                double* csharp2cuda_temp_37 = &((scratch)[column]);
                                (*(csharp2cuda_temp_37) = 0.0);
#line 417 "StatisticsModule.cs"
                                {
#line 417 "StatisticsModule.cs"
                                    int row = 0;
                                    while (true)
                                    {
                                        if (!(((row) < (rows))))
                                            break;
#line 418 "StatisticsModule.cs"
#line 418 "StatisticsModule.cs"
                                        double* csharp2cuda_temp_39 = &((scratch)[column]);
#line 418 "StatisticsModule.cs"
                                        double csharp2cuda_temp_40 = *(csharp2cuda_temp_39);
#line 418 "StatisticsModule.cs"
                                        double csharp2cuda_temp_41 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), column)];
#line 418 "StatisticsModule.cs"
                                        double csharp2cuda_temp_42 = __ddiv_rn(csharp2cuda_temp_41, ((double)(rows)));
                                        (*(csharp2cuda_temp_39) = __dadd_rn(csharp2cuda_temp_40, csharp2cuda_temp_42));
#line 417 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_38 = &(row);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_38));
                                    }
                                }
                            }
#line 414 "StatisticsModule.cs"
                            int* csharp2cuda_temp_36 = &(column);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_36));
                        }
                    }
#line 420 "StatisticsModule.cs"
                    {
#line 420 "StatisticsModule.cs"
                        int left = 0;
                        while (true)
                        {
                            if (!(((left) < (columns))))
                                break;
#line 421 "StatisticsModule.cs"
                            {
#line 422 "StatisticsModule.cs"
                                {
#line 422 "StatisticsModule.cs"
                                    int right = left;
                                    while (true)
                                    {
                                        if (!(((right) < (columns))))
                                            break;
#line 423 "StatisticsModule.cs"
                                        {
#line 424 "StatisticsModule.cs"
                                            double sum = 0.0;
#line 425 "StatisticsModule.cs"
                                            {
#line 425 "StatisticsModule.cs"
                                                int row = 0;
                                                while (true)
                                                {
                                                    if (!(((row) < (rows))))
                                                        break;
#line 426 "StatisticsModule.cs"
                                                    {
#line 427 "StatisticsModule.cs"
#line 427 "StatisticsModule.cs"
                                                        double* csharp2cuda_temp_46 = &(sum);
#line 427 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_47 = *(csharp2cuda_temp_46);
#line 427 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_48 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), left)];
#line 427 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_49 = (scratch)[left];
#line 428 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_50 = (a)[csharp2cuda_i32_add(csharp2cuda_i32_mul(row, columns), right)];
#line 428 "StatisticsModule.cs"
                                                        double csharp2cuda_temp_51 = (scratch)[right];
                                                        (*(csharp2cuda_temp_46) = __dadd_rn(csharp2cuda_temp_47, __dmul_rn(__dsub_rn(csharp2cuda_temp_48, csharp2cuda_temp_49), __dsub_rn(csharp2cuda_temp_50, csharp2cuda_temp_51))));
                                                    }
#line 425 "StatisticsModule.cs"
                                                    int* csharp2cuda_temp_45 = &(row);
                                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_45));
                                                }
                                            }
#line 430 "StatisticsModule.cs"
                                            double covariance = __ddiv_rn(sum, ((double)(rows)));
#line 431 "StatisticsModule.cs"
#line 431 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_52 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(left, columns), right)]);
                                            (*(csharp2cuda_temp_52) = covariance);
#line 432 "StatisticsModule.cs"
#line 432 "StatisticsModule.cs"
                                            double* csharp2cuda_temp_53 = &((result)[csharp2cuda_i32_add(csharp2cuda_i32_mul(right, columns), left)]);
                                            (*(csharp2cuda_temp_53) = covariance);
#line 433 "StatisticsModule.cs"
                                            if ((!(isfinite(covariance))))
                                            {
#line 433 "StatisticsModule.cs"
#line 433 "StatisticsModule.cs"
                                                int* csharp2cuda_temp_54 = &((output)->valid);
                                                (*(csharp2cuda_temp_54) = 0);
                                            }
                                        }
#line 422 "StatisticsModule.cs"
                                        int* csharp2cuda_temp_44 = &(right);
                                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_44));
                                    }
                                }
                            }
#line 420 "StatisticsModule.cs"
                            int* csharp2cuda_temp_43 = &(left);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_43));
                        }
                    }
#line 436 "StatisticsModule.cs"
                    break;
                }
#line 438 "StatisticsModule.cs"
            case 3:
#line 439 "StatisticsModule.cs"
                {
#line 440 "StatisticsModule.cs"
                    int count = (first)->count;
#line 441 "StatisticsModule.cs"
#line 441 "StatisticsModule.cs"
                    bool csharp2cuda_temp_55;
#line 441 "StatisticsModule.cs"
                    if (!(((count) <= (0))))
                    {
#line 441 "StatisticsModule.cs"
                        int csharp2cuda_temp_56 = (second)->count;
#line 441 "StatisticsModule.cs"
                        csharp2cuda_temp_55 = ((count) != (csharp2cuda_temp_56));
                    }
                    else
                    {
#line 441 "StatisticsModule.cs"
                        csharp2cuda_temp_55 = true;
                    }
#line 441 "StatisticsModule.cs"
                    bool csharp2cuda_temp_57;
#line 441 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_55))
                    {
#line 441 "StatisticsModule.cs"
                        csharp2cuda_temp_57 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 441 "StatisticsModule.cs"
                        csharp2cuda_temp_57 = true;
                    }
                    if (csharp2cuda_temp_57)
#line 442 "StatisticsModule.cs"
                    {
#line 443 "StatisticsModule.cs"
#line 443 "StatisticsModule.cs"
                        int* csharp2cuda_temp_58 = &((output)->valid);
                        (*(csharp2cuda_temp_58) = 0);
#line 444 "StatisticsModule.cs"
                        break;
                    }
#line 446 "StatisticsModule.cs"
                    double* left_distances = scratch;
#line 447 "StatisticsModule.cs"
                    double* right_distances = csharp2cuda_pointer_add(scratch, csharp2cuda_i32_mul(count, count));
#line 448 "StatisticsModule.cs"
                    double* row_means = csharp2cuda_pointer_add(right_distances, csharp2cuda_i32_mul(count, count));
#line 449 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(a, count, left_distances, row_means);
#line 450 "StatisticsModule.cs"
                    mathblocks_statistics_center_distance(b, count, right_distances, row_means);
#line 451 "StatisticsModule.cs"
                    double covariance_square = 0.0;
#line 452 "StatisticsModule.cs"
                    double left_variance_square = 0.0;
#line 453 "StatisticsModule.cs"
                    double right_variance_square = 0.0;
#line 454 "StatisticsModule.cs"
                    {
#line 454 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
                            if (!(((index) < (csharp2cuda_i32_mul(count, count)))))
                                break;
#line 455 "StatisticsModule.cs"
                            {
#line 456 "StatisticsModule.cs"
#line 456 "StatisticsModule.cs"
                                double* csharp2cuda_temp_60 = &(covariance_square);
#line 456 "StatisticsModule.cs"
                                double csharp2cuda_temp_61 = *(csharp2cuda_temp_60);
#line 456 "StatisticsModule.cs"
                                double csharp2cuda_temp_62 = (left_distances)[index];
#line 456 "StatisticsModule.cs"
                                double csharp2cuda_temp_63 = (right_distances)[index];
                                (*(csharp2cuda_temp_60) = __dadd_rn(csharp2cuda_temp_61, __dmul_rn(csharp2cuda_temp_62, csharp2cuda_temp_63)));
#line 457 "StatisticsModule.cs"
#line 457 "StatisticsModule.cs"
                                double* csharp2cuda_temp_64 = &(left_variance_square);
#line 457 "StatisticsModule.cs"
                                double csharp2cuda_temp_65 = *(csharp2cuda_temp_64);
#line 457 "StatisticsModule.cs"
                                double csharp2cuda_temp_66 = (left_distances)[index];
#line 457 "StatisticsModule.cs"
                                double csharp2cuda_temp_67 = (left_distances)[index];
                                (*(csharp2cuda_temp_64) = __dadd_rn(csharp2cuda_temp_65, __dmul_rn(csharp2cuda_temp_66, csharp2cuda_temp_67)));
#line 458 "StatisticsModule.cs"
#line 458 "StatisticsModule.cs"
                                double* csharp2cuda_temp_68 = &(right_variance_square);
#line 458 "StatisticsModule.cs"
                                double csharp2cuda_temp_69 = *(csharp2cuda_temp_68);
#line 458 "StatisticsModule.cs"
                                double csharp2cuda_temp_70 = (right_distances)[index];
#line 458 "StatisticsModule.cs"
                                double csharp2cuda_temp_71 = (right_distances)[index];
                                (*(csharp2cuda_temp_68) = __dadd_rn(csharp2cuda_temp_69, __dmul_rn(csharp2cuda_temp_70, csharp2cuda_temp_71)));
                            }
#line 454 "StatisticsModule.cs"
                            int* csharp2cuda_temp_59 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_59));
                        }
                    }
#line 460 "StatisticsModule.cs"
#line 460 "StatisticsModule.cs"
                    double* csharp2cuda_temp_72 = &(covariance_square);
#line 460 "StatisticsModule.cs"
                    double csharp2cuda_temp_73 = *(csharp2cuda_temp_72);
                    (*(csharp2cuda_temp_72) = __ddiv_rn(csharp2cuda_temp_73, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 461 "StatisticsModule.cs"
#line 461 "StatisticsModule.cs"
                    double* csharp2cuda_temp_74 = &(left_variance_square);
#line 461 "StatisticsModule.cs"
                    double csharp2cuda_temp_75 = *(csharp2cuda_temp_74);
                    (*(csharp2cuda_temp_74) = __ddiv_rn(csharp2cuda_temp_75, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 462 "StatisticsModule.cs"
#line 462 "StatisticsModule.cs"
                    double* csharp2cuda_temp_76 = &(right_variance_square);
#line 462 "StatisticsModule.cs"
                    double csharp2cuda_temp_77 = *(csharp2cuda_temp_76);
                    (*(csharp2cuda_temp_76) = __ddiv_rn(csharp2cuda_temp_77, ((double)(csharp2cuda_i32_mul(count, count)))));
#line 463 "StatisticsModule.cs"
#line 463 "StatisticsModule.cs"
                    double* csharp2cuda_temp_78 = &((output)->scalar_value);
#line 464 "StatisticsModule.cs"
                    double csharp2cuda_temp_79 = __ddiv_rn(covariance_square, mathblocks_square_root(__dmul_rn(left_variance_square, right_variance_square)));
                    (*(csharp2cuda_temp_78) = mathblocks_square_root(csharp2cuda_temp_79));
#line 466 "StatisticsModule.cs"
                    break;
                }
#line 468 "StatisticsModule.cs"
            case 4:
#line 469 "StatisticsModule.cs"
                {
#line 470 "StatisticsModule.cs"
#line 470 "StatisticsModule.cs"
                    int csharp2cuda_temp_80 = (second)->count;
                    mathblocks_sequence_set_vector_shape(output, csharp2cuda_i32_add(csharp2cuda_temp_80, 1));
#line 471 "StatisticsModule.cs"
                    {
#line 471 "StatisticsModule.cs"
                        int index = 1;
                        while (true)
                        {
#line 471 "StatisticsModule.cs"
                            int csharp2cuda_temp_82 = (second)->count;
                            if (!(((index) < (csharp2cuda_temp_82))))
                                break;
#line 472 "StatisticsModule.cs"
                            {
#line 473 "StatisticsModule.cs"
#line 473 "StatisticsModule.cs"
                                double csharp2cuda_temp_83 = (b)[index];
#line 473 "StatisticsModule.cs"
                                double csharp2cuda_temp_84 = (b)[csharp2cuda_i32_sub(index, 1)];
                                if (((csharp2cuda_temp_83) <= (csharp2cuda_temp_84)))
#line 474 "StatisticsModule.cs"
                                {
#line 475 "StatisticsModule.cs"
#line 475 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_85 = &((output)->valid);
                                    (*(csharp2cuda_temp_85) = 0);
#line 476 "StatisticsModule.cs"
                                    break;
                                }
                            }
#line 471 "StatisticsModule.cs"
                            int* csharp2cuda_temp_81 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_81));
                        }
                    }
#line 479 "StatisticsModule.cs"
                    {
#line 479 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 479 "StatisticsModule.cs"
                            bool csharp2cuda_temp_87 = (output)->valid;
#line 479 "StatisticsModule.cs"
                            bool csharp2cuda_temp_88;
#line 479 "StatisticsModule.cs"
                            if (csharp2cuda_temp_87)
                            {
#line 479 "StatisticsModule.cs"
                                int csharp2cuda_temp_89 = (output)->count;
#line 479 "StatisticsModule.cs"
                                csharp2cuda_temp_88 = ((index) < (csharp2cuda_temp_89));
                            }
                            else
                            {
#line 479 "StatisticsModule.cs"
                                csharp2cuda_temp_88 = false;
                            }
                            if (!(csharp2cuda_temp_88))
                                break;
#line 480 "StatisticsModule.cs"
#line 480 "StatisticsModule.cs"
                            double* csharp2cuda_temp_90 = &((result)[index]);
                            (*(csharp2cuda_temp_90) = 0.0);
#line 479 "StatisticsModule.cs"
                            int* csharp2cuda_temp_86 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_86));
                        }
                    }
#line 481 "StatisticsModule.cs"
                    {
#line 481 "StatisticsModule.cs"
                        int value_index = 0;
                        while (true)
                        {
#line 481 "StatisticsModule.cs"
                            bool csharp2cuda_temp_92 = (output)->valid;
#line 481 "StatisticsModule.cs"
                            bool csharp2cuda_temp_93;
#line 481 "StatisticsModule.cs"
                            if (csharp2cuda_temp_92)
                            {
#line 481 "StatisticsModule.cs"
                                int csharp2cuda_temp_94 = (first)->count;
#line 481 "StatisticsModule.cs"
                                csharp2cuda_temp_93 = ((value_index) < (csharp2cuda_temp_94));
                            }
                            else
                            {
#line 481 "StatisticsModule.cs"
                                csharp2cuda_temp_93 = false;
                            }
                            if (!(csharp2cuda_temp_93))
                                break;
#line 482 "StatisticsModule.cs"
                            {
#line 483 "StatisticsModule.cs"
                                int lower = 0;
#line 484 "StatisticsModule.cs"
                                int upper = (second)->count;
#line 485 "StatisticsModule.cs"
                                while (true)
                                {
                                    if (!(((lower) < (upper))))
                                        break;
#line 486 "StatisticsModule.cs"
                                    {
#line 487 "StatisticsModule.cs"
                                        int csharp2cuda_temp_95 = csharp2cuda_i32_div(csharp2cuda_i32_sub(upper, lower), 2);
#line 487 "StatisticsModule.cs"
                                        int middle = csharp2cuda_i32_add(lower, csharp2cuda_temp_95);
#line 488 "StatisticsModule.cs"
#line 488 "StatisticsModule.cs"
                                        double csharp2cuda_temp_96 = (a)[value_index];
#line 488 "StatisticsModule.cs"
                                        double csharp2cuda_temp_97 = (b)[middle];
                                        if (((csharp2cuda_temp_96) <= (csharp2cuda_temp_97)))
                                        {
#line 489 "StatisticsModule.cs"
#line 489 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_98 = &(upper);
                                            (*(csharp2cuda_temp_98) = middle);
                                        }
                                        else
                                        {
#line 491 "StatisticsModule.cs"
#line 491 "StatisticsModule.cs"
                                            int* csharp2cuda_temp_99 = &(lower);
                                            (*(csharp2cuda_temp_99) = csharp2cuda_i32_add(middle, 1));
                                        }
                                    }
                                }
#line 493 "StatisticsModule.cs"
#line 493 "StatisticsModule.cs"
                                double* csharp2cuda_temp_100 = &((result)[lower]);
#line 493 "StatisticsModule.cs"
                                double csharp2cuda_temp_101 = *(csharp2cuda_temp_100);
                                (*(csharp2cuda_temp_100) = __dadd_rn(csharp2cuda_temp_101, 1.0));
                            }
#line 481 "StatisticsModule.cs"
                            int* csharp2cuda_temp_91 = &(value_index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_91));
                        }
                    }
#line 495 "StatisticsModule.cs"
                    break;
                }
#line 497 "StatisticsModule.cs"
            case 5:
#line 498 "StatisticsModule.cs"
                {
#line 499 "StatisticsModule.cs"
#line 499 "StatisticsModule.cs"
                    int csharp2cuda_temp_102 = (first)->count;
#line 499 "StatisticsModule.cs"
                    bool csharp2cuda_temp_103;
#line 499 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_102) <= (0))))
                    {
#line 499 "StatisticsModule.cs"
                        csharp2cuda_temp_103 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 499 "StatisticsModule.cs"
                        csharp2cuda_temp_103 = true;
                    }
                    if (csharp2cuda_temp_103)
#line 500 "StatisticsModule.cs"
                    {
#line 501 "StatisticsModule.cs"
#line 501 "StatisticsModule.cs"
                        int* csharp2cuda_temp_104 = &((output)->valid);
                        (*(csharp2cuda_temp_104) = 0);
#line 502 "StatisticsModule.cs"
                        break;
                    }
#line 504 "StatisticsModule.cs"
#line 504 "StatisticsModule.cs"
                    int csharp2cuda_temp_105 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_105, scratch);
#line 505 "StatisticsModule.cs"
#line 505 "StatisticsModule.cs"
                    double* csharp2cuda_temp_106 = &((output)->scalar_value);
#line 506 "StatisticsModule.cs"
                    int csharp2cuda_temp_107 = (first)->count;
#line 506 "StatisticsModule.cs"
                    double csharp2cuda_temp_108 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_107, 0.75);
#line 507 "StatisticsModule.cs"
                    int csharp2cuda_temp_109 = (first)->count;
#line 507 "StatisticsModule.cs"
                    double csharp2cuda_temp_110 = mathblocks_statistics_sorted_quantile(scratch, csharp2cuda_temp_109, 0.25);
                    (*(csharp2cuda_temp_106) = __dsub_rn(csharp2cuda_temp_108, csharp2cuda_temp_110));
#line 508 "StatisticsModule.cs"
                    break;
                }
#line 510 "StatisticsModule.cs"
            case 6:
#line 511 "StatisticsModule.cs"
#line 511 "StatisticsModule.cs"
                int csharp2cuda_temp_111 = (first)->count;
#line 511 "StatisticsModule.cs"
                int csharp2cuda_temp_112 = (second)->count;
#line 511 "StatisticsModule.cs"
                bool csharp2cuda_temp_113;
#line 511 "StatisticsModule.cs"
                if (!(((csharp2cuda_temp_111) != (csharp2cuda_temp_112))))
                {
#line 512 "StatisticsModule.cs"
                    int csharp2cuda_temp_114 = (first)->count;
#line 512 "StatisticsModule.cs"
                    double* csharp2cuda_temp_115 = &((output)->scalar_value);
#line 512 "StatisticsModule.cs"
                    bool csharp2cuda_temp_116 = mathblocks_statistics_kendall_value(a, b, csharp2cuda_temp_114, csharp2cuda_temp_115);
#line 511 "StatisticsModule.cs"
                    csharp2cuda_temp_113 = (!(csharp2cuda_temp_116));
                }
                else
                {
#line 511 "StatisticsModule.cs"
                    csharp2cuda_temp_113 = true;
                }
                if (csharp2cuda_temp_113)
                {
#line 513 "StatisticsModule.cs"
#line 513 "StatisticsModule.cs"
                    int* csharp2cuda_temp_117 = &((output)->valid);
                    (*(csharp2cuda_temp_117) = 0);
                }
#line 514 "StatisticsModule.cs"
                break;
#line 515 "StatisticsModule.cs"
            case 7:
            case 8:
            case 9:
            case 11:
            case 12:
            case 20:
#line 521 "StatisticsModule.cs"
                {
#line 522 "StatisticsModule.cs"
#line 522 "StatisticsModule.cs"
                    int csharp2cuda_temp_118 = (first)->count;
#line 522 "StatisticsModule.cs"
                    bool csharp2cuda_temp_119;
#line 522 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_118) <= (0))))
                    {
#line 522 "StatisticsModule.cs"
                        int csharp2cuda_temp_120 = (first)->count;
#line 522 "StatisticsModule.cs"
                        int csharp2cuda_temp_121 = (second)->count;
#line 522 "StatisticsModule.cs"
                        csharp2cuda_temp_119 = ((csharp2cuda_temp_120) != (csharp2cuda_temp_121));
                    }
                    else
                    {
#line 522 "StatisticsModule.cs"
                        csharp2cuda_temp_119 = true;
                    }
                    if (csharp2cuda_temp_119)
#line 523 "StatisticsModule.cs"
                    {
#line 524 "StatisticsModule.cs"
#line 524 "StatisticsModule.cs"
                        int* csharp2cuda_temp_122 = &((output)->valid);
                        (*(csharp2cuda_temp_122) = 0);
#line 525 "StatisticsModule.cs"
                        break;
                    }
#line 527 "StatisticsModule.cs"
                    int csharp2cuda_temp_123 = (first)->count;
#line 527 "StatisticsModule.cs"
                    double covariance = mathblocks_statistics_population_covariance(a, b, csharp2cuda_temp_123);
#line 528 "StatisticsModule.cs"
#line 528 "StatisticsModule.cs"
                    bool csharp2cuda_temp_124;
#line 528 "StatisticsModule.cs"
                    if (!(((opcode) == (12))))
                    {
#line 528 "StatisticsModule.cs"
                        csharp2cuda_temp_124 = ((opcode) == (20));
                    }
                    else
                    {
#line 528 "StatisticsModule.cs"
                        csharp2cuda_temp_124 = true;
                    }
                    if (csharp2cuda_temp_124)
#line 529 "StatisticsModule.cs"
                    {
#line 530 "StatisticsModule.cs"
#line 530 "StatisticsModule.cs"
                        double* csharp2cuda_temp_125 = &((output)->scalar_value);
#line 530 "StatisticsModule.cs"
                        double csharp2cuda_temp_126;
#line 530 "StatisticsModule.cs"
                        if (((opcode) == (12)))
                        {
#line 530 "StatisticsModule.cs"
                            csharp2cuda_temp_126 = covariance;
                        }
                        else
                        {
#line 532 "StatisticsModule.cs"
                            int csharp2cuda_temp_127 = (first)->count;
#line 532 "StatisticsModule.cs"
                            int csharp2cuda_temp_128 = (first)->count;
#line 530 "StatisticsModule.cs"
                            csharp2cuda_temp_126 = __ddiv_rn(__dmul_rn(covariance, ((double)(csharp2cuda_temp_127))), __dsub_rn(((double)(csharp2cuda_temp_128)), 1.0));
                        }
                        (*(csharp2cuda_temp_125) = csharp2cuda_temp_126);
                    }
                    else
                    {
#line 534 "StatisticsModule.cs"
                        if (((opcode) == (9)))
#line 535 "StatisticsModule.cs"
                        {
#line 536 "StatisticsModule.cs"
#line 536 "StatisticsModule.cs"
                            double* csharp2cuda_temp_129 = &((output)->scalar_value);
#line 537 "StatisticsModule.cs"
                            int csharp2cuda_temp_130 = (first)->count;
#line 537 "StatisticsModule.cs"
                            double csharp2cuda_temp_131 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_130);
#line 536 "StatisticsModule.cs"
                            double csharp2cuda_temp_132 = __ddiv_rn(covariance, csharp2cuda_temp_131);
                            (*(csharp2cuda_temp_129) = csharp2cuda_temp_132);
                        }
                        else
                        {
#line 539 "StatisticsModule.cs"
                            if (((opcode) == (7)))
#line 540 "StatisticsModule.cs"
                            {
#line 542 "StatisticsModule.cs"
                                int csharp2cuda_temp_133 = (first)->count;
#line 542 "StatisticsModule.cs"
                                double csharp2cuda_temp_134 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_133);
#line 541 "StatisticsModule.cs"
                                double slope = __ddiv_rn(covariance, csharp2cuda_temp_134);
#line 543 "StatisticsModule.cs"
#line 543 "StatisticsModule.cs"
                                double* csharp2cuda_temp_135 = &((output)->scalar_value);
#line 543 "StatisticsModule.cs"
                                int csharp2cuda_temp_136 = (first)->count;
#line 543 "StatisticsModule.cs"
                                double csharp2cuda_temp_137 = mathblocks_statistics_mean(b, csharp2cuda_temp_136);
#line 544 "StatisticsModule.cs"
                                int csharp2cuda_temp_138 = (first)->count;
#line 544 "StatisticsModule.cs"
                                double csharp2cuda_temp_139 = mathblocks_statistics_mean(a, csharp2cuda_temp_138);
                                (*(csharp2cuda_temp_135) = __dsub_rn(csharp2cuda_temp_137, __dmul_rn(slope, csharp2cuda_temp_139)));
                            }
                            else
#line 547 "StatisticsModule.cs"
                            {
#line 549 "StatisticsModule.cs"
                                int csharp2cuda_temp_140 = (first)->count;
#line 549 "StatisticsModule.cs"
                                double csharp2cuda_temp_141 = mathblocks_statistics_population_variance(a, csharp2cuda_temp_140);
#line 550 "StatisticsModule.cs"
                                int csharp2cuda_temp_142 = (first)->count;
#line 550 "StatisticsModule.cs"
                                double csharp2cuda_temp_143 = mathblocks_statistics_population_variance(b, csharp2cuda_temp_142);
#line 548 "StatisticsModule.cs"
                                double correlation = __ddiv_rn(covariance, __dmul_rn(mathblocks_square_root(csharp2cuda_temp_141), mathblocks_square_root(csharp2cuda_temp_143)));
#line 551 "StatisticsModule.cs"
#line 551 "StatisticsModule.cs"
                                double* csharp2cuda_temp_144 = &((output)->scalar_value);
#line 551 "StatisticsModule.cs"
                                double csharp2cuda_temp_145;
#line 551 "StatisticsModule.cs"
                                if (((opcode) == (8)))
                                {
#line 551 "StatisticsModule.cs"
                                    csharp2cuda_temp_145 = __dmul_rn(correlation, correlation);
                                }
                                else
                                {
#line 551 "StatisticsModule.cs"
                                    csharp2cuda_temp_145 = correlation;
                                }
                                (*(csharp2cuda_temp_144) = csharp2cuda_temp_145);
                            }
                        }
                    }
#line 553 "StatisticsModule.cs"
                    break;
                }
#line 555 "StatisticsModule.cs"
            case 10:
#line 556 "StatisticsModule.cs"
                {
#line 557 "StatisticsModule.cs"
#line 557 "StatisticsModule.cs"
                    int csharp2cuda_temp_146 = (first)->count;
#line 557 "StatisticsModule.cs"
                    bool csharp2cuda_temp_147;
#line 557 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_146) <= (0))))
                    {
#line 557 "StatisticsModule.cs"
                        csharp2cuda_temp_147 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 557 "StatisticsModule.cs"
                        csharp2cuda_temp_147 = true;
                    }
                    if (csharp2cuda_temp_147)
#line 558 "StatisticsModule.cs"
                    {
#line 559 "StatisticsModule.cs"
#line 559 "StatisticsModule.cs"
                        int* csharp2cuda_temp_148 = &((output)->valid);
                        (*(csharp2cuda_temp_148) = 0);
#line 560 "StatisticsModule.cs"
                        break;
                    }
#line 562 "StatisticsModule.cs"
                    double* sorted = scratch;
#line 563 "StatisticsModule.cs"
                    int csharp2cuda_temp_149 = (first)->count;
#line 563 "StatisticsModule.cs"
                    double* deviations = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_149);
#line 564 "StatisticsModule.cs"
#line 564 "StatisticsModule.cs"
                    int csharp2cuda_temp_150 = (first)->count;
                    mathblocks_statistics_sort_copy(a, csharp2cuda_temp_150, sorted);
#line 565 "StatisticsModule.cs"
                    int csharp2cuda_temp_151 = (first)->count;
#line 565 "StatisticsModule.cs"
                    double median = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_151, 0.5);
#line 566 "StatisticsModule.cs"
                    {
#line 566 "StatisticsModule.cs"
                        int index = 0;
                        while (true)
                        {
#line 566 "StatisticsModule.cs"
                            int csharp2cuda_temp_153 = (first)->count;
                            if (!(((index) < (csharp2cuda_temp_153))))
                                break;
#line 567 "StatisticsModule.cs"
#line 567 "StatisticsModule.cs"
                            double* csharp2cuda_temp_154 = &((deviations)[index]);
#line 567 "StatisticsModule.cs"
                            double csharp2cuda_temp_155 = (a)[index];
                            (*(csharp2cuda_temp_154) = fabs(__dsub_rn(csharp2cuda_temp_155, median)));
#line 566 "StatisticsModule.cs"
                            int* csharp2cuda_temp_152 = &(index);
                            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_152));
                        }
                    }
#line 568 "StatisticsModule.cs"
#line 568 "StatisticsModule.cs"
                    int csharp2cuda_temp_156 = (first)->count;
                    mathblocks_statistics_sort_copy(deviations, csharp2cuda_temp_156, sorted);
#line 569 "StatisticsModule.cs"
#line 569 "StatisticsModule.cs"
                    double* csharp2cuda_temp_157 = &((output)->scalar_value);
#line 569 "StatisticsModule.cs"
                    int csharp2cuda_temp_158 = (first)->count;
#line 569 "StatisticsModule.cs"
                    double csharp2cuda_temp_159 = mathblocks_statistics_sorted_quantile(sorted, csharp2cuda_temp_158, 0.5);
                    (*(csharp2cuda_temp_157) = csharp2cuda_temp_159);
#line 570 "StatisticsModule.cs"
                    break;
                }
#line 572 "StatisticsModule.cs"
            case 13:
            case 14:
#line 574 "StatisticsModule.cs"
#line 576 "StatisticsModule.cs"
                int csharp2cuda_temp_160 = (first)->count;
#line 578 "StatisticsModule.cs"
                double* csharp2cuda_temp_161 = &((output)->scalar_value);
#line 574 "StatisticsModule.cs"
                bool csharp2cuda_temp_162 = mathblocks_statistics_shape_moment_value(a, csharp2cuda_temp_160, ((opcode) == (13)), csharp2cuda_temp_161);
                if ((!(csharp2cuda_temp_162)))
                {
#line 579 "StatisticsModule.cs"
#line 579 "StatisticsModule.cs"
                    int* csharp2cuda_temp_163 = &((output)->valid);
                    (*(csharp2cuda_temp_163) = 0);
                }
#line 580 "StatisticsModule.cs"
                break;
#line 581 "StatisticsModule.cs"
            case 15:
            case 16:
            case 21:
            case 22:
#line 585 "StatisticsModule.cs"
                {
#line 586 "StatisticsModule.cs"
#line 586 "StatisticsModule.cs"
                    int csharp2cuda_temp_164 = (first)->count;
                    if (((csharp2cuda_temp_164) <= (0)))
#line 587 "StatisticsModule.cs"
                    {
#line 588 "StatisticsModule.cs"
#line 588 "StatisticsModule.cs"
                        int* csharp2cuda_temp_165 = &((output)->valid);
                        (*(csharp2cuda_temp_165) = 0);
#line 589 "StatisticsModule.cs"
                        break;
                    }
#line 591 "StatisticsModule.cs"
                    int csharp2cuda_temp_166 = (first)->count;
#line 591 "StatisticsModule.cs"
                    double variance = mathblocks_statistics_population_variance(a, csharp2cuda_temp_166);
#line 592 "StatisticsModule.cs"
#line 592 "StatisticsModule.cs"
                    bool csharp2cuda_temp_167;
#line 592 "StatisticsModule.cs"
                    if (!(((opcode) == (21))))
                    {
#line 592 "StatisticsModule.cs"
                        csharp2cuda_temp_167 = ((opcode) == (22));
                    }
                    else
                    {
#line 592 "StatisticsModule.cs"
                        csharp2cuda_temp_167 = true;
                    }
                    if (csharp2cuda_temp_167)
                    {
#line 593 "StatisticsModule.cs"
#line 593 "StatisticsModule.cs"
                        double* csharp2cuda_temp_168 = &(variance);
#line 593 "StatisticsModule.cs"
                        int csharp2cuda_temp_169 = (first)->count;
#line 593 "StatisticsModule.cs"
                        int csharp2cuda_temp_170 = (first)->count;
#line 593 "StatisticsModule.cs"
                        double csharp2cuda_temp_171 = __ddiv_rn(__dmul_rn(variance, ((double)(csharp2cuda_temp_169))), __dsub_rn(((double)(csharp2cuda_temp_170)), 1.0));
                        (*(csharp2cuda_temp_168) = csharp2cuda_temp_171);
                    }
#line 594 "StatisticsModule.cs"
#line 594 "StatisticsModule.cs"
                    double* csharp2cuda_temp_172 = &((output)->scalar_value);
#line 594 "StatisticsModule.cs"
                    bool csharp2cuda_temp_173;
#line 594 "StatisticsModule.cs"
                    if (!(((opcode) == (15))))
                    {
#line 594 "StatisticsModule.cs"
                        csharp2cuda_temp_173 = ((opcode) == (21));
                    }
                    else
                    {
#line 594 "StatisticsModule.cs"
                        csharp2cuda_temp_173 = true;
                    }
#line 594 "StatisticsModule.cs"
                    double csharp2cuda_temp_174;
#line 594 "StatisticsModule.cs"
                    if (csharp2cuda_temp_173)
                    {
#line 594 "StatisticsModule.cs"
                        csharp2cuda_temp_174 = mathblocks_square_root(variance);
                    }
                    else
                    {
#line 594 "StatisticsModule.cs"
                        csharp2cuda_temp_174 = variance;
                    }
                    (*(csharp2cuda_temp_172) = csharp2cuda_temp_174);
#line 597 "StatisticsModule.cs"
                    break;
                }
#line 599 "StatisticsModule.cs"
            case 17:
#line 600 "StatisticsModule.cs"
                {
#line 601 "StatisticsModule.cs"
#line 601 "StatisticsModule.cs"
                    int csharp2cuda_temp_175 = (first)->count;
#line 601 "StatisticsModule.cs"
                    bool csharp2cuda_temp_176;
#line 601 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_175) <= (0))))
                    {
#line 601 "StatisticsModule.cs"
                        csharp2cuda_temp_176 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 601 "StatisticsModule.cs"
                        csharp2cuda_temp_176 = true;
                    }
                    if (csharp2cuda_temp_176)
#line 602 "StatisticsModule.cs"
                    {
#line 603 "StatisticsModule.cs"
#line 603 "StatisticsModule.cs"
                        int* csharp2cuda_temp_177 = &((output)->valid);
                        (*(csharp2cuda_temp_177) = 0);
#line 604 "StatisticsModule.cs"
                        break;
                    }
#line 606 "StatisticsModule.cs"
                    int csharp2cuda_temp_178 = (first)->count;
#line 606 "StatisticsModule.cs"
                    int count = mathblocks_statistics_pair_averages(a, csharp2cuda_temp_178, scratch);
#line 607 "StatisticsModule.cs"
#line 607 "StatisticsModule.cs"
                    double* csharp2cuda_temp_179 = &((output)->scalar_value);
#line 607 "StatisticsModule.cs"
                    double csharp2cuda_temp_180 = mathblocks_statistics_median(scratch, count);
                    (*(csharp2cuda_temp_179) = csharp2cuda_temp_180);
#line 608 "StatisticsModule.cs"
                    break;
                }
#line 610 "StatisticsModule.cs"
            case 19:
#line 611 "StatisticsModule.cs"
#line 611 "StatisticsModule.cs"
                double* csharp2cuda_temp_181 = &((output)->scalar_value);
#line 612 "StatisticsModule.cs"
                int csharp2cuda_temp_182 = (first)->count;
#line 612 "StatisticsModule.cs"
                int csharp2cuda_temp_183 = (first)->count;
#line 612 "StatisticsModule.cs"
                double csharp2cuda_temp_184 = __ddiv_rn(mathblocks_compensated_product_sum(a, a, csharp2cuda_temp_182), ((double)(csharp2cuda_temp_183)));
                (*(csharp2cuda_temp_181) = mathblocks_square_root(csharp2cuda_temp_184));
#line 613 "StatisticsModule.cs"
                break;
#line 614 "StatisticsModule.cs"
            case 23:
#line 615 "StatisticsModule.cs"
                {
#line 616 "StatisticsModule.cs"
#line 616 "StatisticsModule.cs"
                    int csharp2cuda_temp_185 = (first)->count;
#line 616 "StatisticsModule.cs"
                    bool csharp2cuda_temp_186;
#line 616 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_185) <= (0))))
                    {
#line 616 "StatisticsModule.cs"
                        int csharp2cuda_temp_187 = (first)->count;
#line 616 "StatisticsModule.cs"
                        int csharp2cuda_temp_188 = (second)->count;
#line 616 "StatisticsModule.cs"
                        csharp2cuda_temp_186 = ((csharp2cuda_temp_187) != (csharp2cuda_temp_188));
                    }
                    else
                    {
#line 616 "StatisticsModule.cs"
                        csharp2cuda_temp_186 = true;
                    }
#line 616 "StatisticsModule.cs"
                    bool csharp2cuda_temp_189;
#line 616 "StatisticsModule.cs"
                    if (!(csharp2cuda_temp_186))
                    {
#line 616 "StatisticsModule.cs"
                        csharp2cuda_temp_189 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 616 "StatisticsModule.cs"
                        csharp2cuda_temp_189 = true;
                    }
                    if (csharp2cuda_temp_189)
#line 617 "StatisticsModule.cs"
                    {
#line 618 "StatisticsModule.cs"
#line 618 "StatisticsModule.cs"
                        int* csharp2cuda_temp_190 = &((output)->valid);
                        (*(csharp2cuda_temp_190) = 0);
#line 619 "StatisticsModule.cs"
                        break;
                    }
#line 621 "StatisticsModule.cs"
                    double* left_ranks = scratch;
#line 622 "StatisticsModule.cs"
                    int csharp2cuda_temp_191 = (first)->count;
#line 622 "StatisticsModule.cs"
                    double* right_ranks = csharp2cuda_pointer_add(scratch, csharp2cuda_temp_191);
#line 623 "StatisticsModule.cs"
#line 623 "StatisticsModule.cs"
                    int csharp2cuda_temp_192 = (first)->count;
                    mathblocks_statistics_rank(a, csharp2cuda_temp_192, left_ranks);
#line 624 "StatisticsModule.cs"
#line 624 "StatisticsModule.cs"
                    int csharp2cuda_temp_193 = (first)->count;
                    mathblocks_statistics_rank(b, csharp2cuda_temp_193, right_ranks);
#line 625 "StatisticsModule.cs"
#line 625 "StatisticsModule.cs"
                    double* csharp2cuda_temp_194 = &((output)->scalar_value);
#line 628 "StatisticsModule.cs"
                    int csharp2cuda_temp_195 = (first)->count;
#line 625 "StatisticsModule.cs"
                    double csharp2cuda_temp_196 = mathblocks_statistics_pearson(left_ranks, right_ranks, csharp2cuda_temp_195);
                    (*(csharp2cuda_temp_194) = csharp2cuda_temp_196);
#line 629 "StatisticsModule.cs"
                    break;
                }
#line 631 "StatisticsModule.cs"
            case 24:
#line 632 "StatisticsModule.cs"
                {
#line 633 "StatisticsModule.cs"
#line 633 "StatisticsModule.cs"
                    int csharp2cuda_temp_197 = (first)->count;
#line 633 "StatisticsModule.cs"
                    int csharp2cuda_temp_198 = (second)->count;
#line 633 "StatisticsModule.cs"
                    bool csharp2cuda_temp_199;
#line 633 "StatisticsModule.cs"
                    if (!(((csharp2cuda_temp_197) != (csharp2cuda_temp_198))))
                    {
#line 633 "StatisticsModule.cs"
                        csharp2cuda_temp_199 = ((((void*)(scratch))) == (((void*)(nullptr))));
                    }
                    else
                    {
#line 633 "StatisticsModule.cs"
                        csharp2cuda_temp_199 = true;
                    }
                    if (csharp2cuda_temp_199)
#line 634 "StatisticsModule.cs"
                    {
#line 635 "StatisticsModule.cs"
#line 635 "StatisticsModule.cs"
                        int* csharp2cuda_temp_200 = &((output)->valid);
                        (*(csharp2cuda_temp_200) = 0);
#line 636 "StatisticsModule.cs"
                        break;
                    }
#line 638 "StatisticsModule.cs"
                    int csharp2cuda_temp_201 = (first)->count;
#line 638 "StatisticsModule.cs"
                    int count = mathblocks_statistics_pair_slopes(a, b, csharp2cuda_temp_201, scratch);
#line 639 "StatisticsModule.cs"
                    if (((count) == (0)))
                    {
#line 640 "StatisticsModule.cs"
#line 640 "StatisticsModule.cs"
                        int* csharp2cuda_temp_202 = &((output)->valid);
                        (*(csharp2cuda_temp_202) = 0);
                    }
                    else
                    {
#line 642 "StatisticsModule.cs"
#line 642 "StatisticsModule.cs"
                        double* csharp2cuda_temp_203 = &((output)->scalar_value);
#line 642 "StatisticsModule.cs"
                        double csharp2cuda_temp_204 = mathblocks_statistics_median(scratch, count);
                        (*(csharp2cuda_temp_203) = csharp2cuda_temp_204);
                    }
#line 643 "StatisticsModule.cs"
                    break;
                }
#line 645 "StatisticsModule.cs"
            case 25:
            case 26:
#line 647 "StatisticsModule.cs"
#line 647 "StatisticsModule.cs"
                int csharp2cuda_temp_205 = (first)->count;
#line 647 "StatisticsModule.cs"
                int csharp2cuda_temp_206 = (second)->count;
#line 647 "StatisticsModule.cs"
                bool csharp2cuda_temp_207;
#line 647 "StatisticsModule.cs"
                if (!(((csharp2cuda_temp_205) != (csharp2cuda_temp_206))))
                {
#line 651 "StatisticsModule.cs"
                    int csharp2cuda_temp_208 = (first)->count;
#line 653 "StatisticsModule.cs"
                    double* csharp2cuda_temp_209 = &((output)->scalar_value);
#line 648 "StatisticsModule.cs"
                    bool csharp2cuda_temp_210 = mathblocks_statistics_weighted_value(a, b, csharp2cuda_temp_208, ((opcode) == (26)), csharp2cuda_temp_209);
#line 647 "StatisticsModule.cs"
                    csharp2cuda_temp_207 = (!(csharp2cuda_temp_210));
                }
                else
                {
#line 647 "StatisticsModule.cs"
                    csharp2cuda_temp_207 = true;
                }
                if (csharp2cuda_temp_207)
                {
#line 654 "StatisticsModule.cs"
#line 654 "StatisticsModule.cs"
                    int* csharp2cuda_temp_211 = &((output)->valid);
                    (*(csharp2cuda_temp_211) = 0);
                }
#line 655 "StatisticsModule.cs"
                break;
        }
#line 657 "StatisticsModule.cs"
#line 657 "StatisticsModule.cs"
        bool csharp2cuda_temp_212 = (output)->valid;
#line 657 "StatisticsModule.cs"
        bool csharp2cuda_temp_213;
#line 657 "StatisticsModule.cs"
        if (csharp2cuda_temp_212)
        {
#line 657 "StatisticsModule.cs"
            csharp2cuda_temp_213 = ((opcode) != (2));
        }
        else
        {
#line 657 "StatisticsModule.cs"
            csharp2cuda_temp_213 = false;
        }
#line 657 "StatisticsModule.cs"
        bool csharp2cuda_temp_214;
#line 657 "StatisticsModule.cs"
        if (csharp2cuda_temp_213)
        {
#line 657 "StatisticsModule.cs"
            csharp2cuda_temp_214 = ((opcode) != (4));
        }
        else
        {
#line 657 "StatisticsModule.cs"
            csharp2cuda_temp_214 = false;
        }
#line 657 "StatisticsModule.cs"
        bool csharp2cuda_temp_215;
#line 657 "StatisticsModule.cs"
        if (csharp2cuda_temp_214)
        {
#line 657 "StatisticsModule.cs"
            double csharp2cuda_temp_216 = (output)->scalar_value;
#line 657 "StatisticsModule.cs"
            csharp2cuda_temp_215 = (!(isfinite(csharp2cuda_temp_216)));
        }
        else
        {
#line 657 "StatisticsModule.cs"
            csharp2cuda_temp_215 = false;
        }
        if (csharp2cuda_temp_215)
        {
#line 658 "StatisticsModule.cs"
#line 658 "StatisticsModule.cs"
            int* csharp2cuda_temp_217 = &((output)->valid);
            (*(csharp2cuda_temp_217) = 0);
        }
    }
}

#line 217 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_kendall_value(
    const double* left_values,
    const double* right_values,
    int count,
    double* value)
#line 223 "StatisticsModule.cs"
{
#line 224 "StatisticsModule.cs"
    long long concordant = ((long long)(0));
#line 225 "StatisticsModule.cs"
    long long discordant = ((long long)(0));
#line 226 "StatisticsModule.cs"
    long long left_ties = ((long long)(0));
#line 227 "StatisticsModule.cs"
    long long right_ties = ((long long)(0));
#line 228 "StatisticsModule.cs"
    {
#line 228 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 229 "StatisticsModule.cs"
            {
#line 230 "StatisticsModule.cs"
                {
#line 230 "StatisticsModule.cs"
                    int right = csharp2cuda_i32_add(left, 1);
                    while (true)
                    {
                        if (!(((right) < (count))))
                            break;
#line 231 "StatisticsModule.cs"
                        {
#line 232 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (left_values)[left];
#line 232 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (left_values)[right];
#line 232 "StatisticsModule.cs"
                            double left_difference = __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 233 "StatisticsModule.cs"
                            double csharp2cuda_temp_4 = (right_values)[left];
#line 233 "StatisticsModule.cs"
                            double csharp2cuda_temp_5 = (right_values)[right];
#line 233 "StatisticsModule.cs"
                            double right_difference = __dsub_rn(csharp2cuda_temp_4, csharp2cuda_temp_5);
#line 234 "StatisticsModule.cs"
                            int csharp2cuda_temp_6;
#line 234 "StatisticsModule.cs"
                            if (((left_difference) > (0.0)))
                            {
#line 234 "StatisticsModule.cs"
                                csharp2cuda_temp_6 = 1;
                            }
                            else
                            {
#line 234 "StatisticsModule.cs"
                                int csharp2cuda_temp_7;
#line 234 "StatisticsModule.cs"
                                if (((left_difference) < (0.0)))
                                {
#line 234 "StatisticsModule.cs"
                                    csharp2cuda_temp_7 = csharp2cuda_i32_neg(1);
                                }
                                else
                                {
#line 234 "StatisticsModule.cs"
                                    csharp2cuda_temp_7 = 0;
                                }
#line 234 "StatisticsModule.cs"
                                csharp2cuda_temp_6 = csharp2cuda_temp_7;
                            }
#line 234 "StatisticsModule.cs"
                            int left_sign = csharp2cuda_temp_6;
#line 235 "StatisticsModule.cs"
                            int csharp2cuda_temp_8;
#line 235 "StatisticsModule.cs"
                            if (((right_difference) > (0.0)))
                            {
#line 235 "StatisticsModule.cs"
                                csharp2cuda_temp_8 = 1;
                            }
                            else
                            {
#line 235 "StatisticsModule.cs"
                                int csharp2cuda_temp_9;
#line 235 "StatisticsModule.cs"
                                if (((right_difference) < (0.0)))
                                {
#line 235 "StatisticsModule.cs"
                                    csharp2cuda_temp_9 = csharp2cuda_i32_neg(1);
                                }
                                else
                                {
#line 235 "StatisticsModule.cs"
                                    csharp2cuda_temp_9 = 0;
                                }
#line 235 "StatisticsModule.cs"
                                csharp2cuda_temp_8 = csharp2cuda_temp_9;
                            }
#line 235 "StatisticsModule.cs"
                            int right_sign = csharp2cuda_temp_8;
#line 236 "StatisticsModule.cs"
#line 236 "StatisticsModule.cs"
                            bool csharp2cuda_temp_10;
#line 236 "StatisticsModule.cs"
                            if (((left_sign) == (0)))
                            {
#line 236 "StatisticsModule.cs"
                                csharp2cuda_temp_10 = ((right_sign) == (0));
                            }
                            else
                            {
#line 236 "StatisticsModule.cs"
                                csharp2cuda_temp_10 = false;
                            }
                            if (csharp2cuda_temp_10)
                            {
#line 237 "StatisticsModule.cs"
                                goto csharp2cuda_for_continue_0;
                            }
#line 238 "StatisticsModule.cs"
                            if (((left_sign) == (0)))
                            {
#line 239 "StatisticsModule.cs"
#line 239 "StatisticsModule.cs"
                                long long* csharp2cuda_temp_11 = &(left_ties);
                                csharp2cuda_i64_post_increment(*(csharp2cuda_temp_11));
                            }
                            else
                            {
#line 240 "StatisticsModule.cs"
                                if (((right_sign) == (0)))
                                {
#line 241 "StatisticsModule.cs"
#line 241 "StatisticsModule.cs"
                                    long long* csharp2cuda_temp_12 = &(right_ties);
                                    csharp2cuda_i64_post_increment(*(csharp2cuda_temp_12));
                                }
                                else
                                {
#line 242 "StatisticsModule.cs"
                                    if (((left_sign) == (right_sign)))
                                    {
#line 243 "StatisticsModule.cs"
#line 243 "StatisticsModule.cs"
                                        long long* csharp2cuda_temp_13 = &(concordant);
                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_13));
                                    }
                                    else
                                    {
#line 245 "StatisticsModule.cs"
#line 245 "StatisticsModule.cs"
                                        long long* csharp2cuda_temp_14 = &(discordant);
                                        csharp2cuda_i64_post_increment(*(csharp2cuda_temp_14));
                                    }
                                }
                            }
                        }
                        csharp2cuda_for_continue_0:
#line 230 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(right);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 228 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 248 "StatisticsModule.cs"
#line 248 "StatisticsModule.cs"
    double* csharp2cuda_temp_15 = value;
#line 248 "StatisticsModule.cs"
    double csharp2cuda_temp_16 = __ddiv_rn(((double)(csharp2cuda_i64_sub(concordant, discordant))), mathblocks_square_root(__dmul_rn(((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), left_ties))), ((double)(csharp2cuda_i64_add(csharp2cuda_i64_add(concordant, discordant), right_ties))))));
    (*(csharp2cuda_temp_15) = csharp2cuda_temp_16);
#line 252 "StatisticsModule.cs"
#line 252 "StatisticsModule.cs"
    double csharp2cuda_temp_17 = *(value);
    return isfinite(csharp2cuda_temp_17);
}

#line 46 "StatisticsModule.cs"
__device__ double mathblocks_statistics_mean(const double* values, int count)
#line 48 "StatisticsModule.cs"
{
#line 49 "StatisticsModule.cs"
    return __ddiv_rn(mathblocks_compensated_sum(values, count), ((double)(count)));
}

#line 142 "StatisticsModule.cs"
__device__ double mathblocks_statistics_median(double* values, int count)
#line 144 "StatisticsModule.cs"
{
#line 145 "StatisticsModule.cs"
    mathblocks_statistics_sort_in_place(values, count);
#line 146 "StatisticsModule.cs"
    return mathblocks_statistics_sorted_quantile(values, count, 0.5);
}

#line 197 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_moment_value(
    const double* values,
    int count,
    double order_value,
    bool central,
    double* value)
#line 204 "StatisticsModule.cs"
{
#line 205 "StatisticsModule.cs"
    int order = 0;
#line 206 "StatisticsModule.cs"
#line 206 "StatisticsModule.cs"
    bool csharp2cuda_temp_0;
#line 206 "StatisticsModule.cs"
    if (!(((count) <= (0))))
    {
#line 207 "StatisticsModule.cs"
        int* csharp2cuda_temp_1 = &(order);
#line 207 "StatisticsModule.cs"
        bool csharp2cuda_temp_2 = mathblocks_nonnegative_integer(order_value, csharp2cuda_temp_1);
#line 206 "StatisticsModule.cs"
        csharp2cuda_temp_0 = (!(csharp2cuda_temp_2));
    }
    else
    {
#line 206 "StatisticsModule.cs"
        csharp2cuda_temp_0 = true;
    }
    if (csharp2cuda_temp_0)
    {
#line 208 "StatisticsModule.cs"
        return false;
    }
#line 209 "StatisticsModule.cs"
    double csharp2cuda_temp_3;
#line 209 "StatisticsModule.cs"
    if (central)
    {
#line 209 "StatisticsModule.cs"
        csharp2cuda_temp_3 = mathblocks_statistics_mean(values, count);
    }
    else
    {
#line 209 "StatisticsModule.cs"
        csharp2cuda_temp_3 = 0.0;
    }
#line 209 "StatisticsModule.cs"
    double mean = csharp2cuda_temp_3;
#line 210 "StatisticsModule.cs"
    double sum = 0.0;
#line 211 "StatisticsModule.cs"
    {
#line 211 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 212 "StatisticsModule.cs"
#line 212 "StatisticsModule.cs"
            double* csharp2cuda_temp_5 = &(sum);
#line 212 "StatisticsModule.cs"
            double csharp2cuda_temp_6 = *(csharp2cuda_temp_5);
#line 212 "StatisticsModule.cs"
            double csharp2cuda_temp_7 = (values)[index];
            (*(csharp2cuda_temp_5) = __dadd_rn(csharp2cuda_temp_6, mathblocks_power(__dsub_rn(csharp2cuda_temp_7, mean), ((double)(order)))));
#line 211 "StatisticsModule.cs"
            int* csharp2cuda_temp_4 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
        }
    }
#line 213 "StatisticsModule.cs"
#line 213 "StatisticsModule.cs"
    double* csharp2cuda_temp_8 = value;
#line 213 "StatisticsModule.cs"
    double csharp2cuda_temp_9 = __ddiv_rn(sum, ((double)(count)));
    (*(csharp2cuda_temp_8) = csharp2cuda_temp_9);
#line 214 "StatisticsModule.cs"
#line 214 "StatisticsModule.cs"
    double csharp2cuda_temp_10 = *(value);
    return isfinite(csharp2cuda_temp_10);
}

#line 313 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_averages(
    const double* values,
    int count,
    double* averages)
#line 318 "StatisticsModule.cs"
{
#line 319 "StatisticsModule.cs"
    int average_count = 0;
#line 320 "StatisticsModule.cs"
    {
#line 320 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 321 "StatisticsModule.cs"
            {
#line 321 "StatisticsModule.cs"
                int right = left;
                while (true)
                {
                    if (!(((right) < (count))))
                        break;
#line 322 "StatisticsModule.cs"
#line 322 "StatisticsModule.cs"
                    int* csharp2cuda_temp_2 = &(average_count);
#line 322 "StatisticsModule.cs"
                    int csharp2cuda_temp_3 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_2));
#line 322 "StatisticsModule.cs"
                    double* csharp2cuda_temp_4 = &((averages)[csharp2cuda_temp_3]);
#line 322 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (values)[left];
#line 322 "StatisticsModule.cs"
                    double csharp2cuda_temp_6 = (values)[right];
#line 322 "StatisticsModule.cs"
                    double csharp2cuda_temp_7 = __ddiv_rn(__dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_6), 2.0);
                    (*(csharp2cuda_temp_4) = csharp2cuda_temp_7);
#line 321 "StatisticsModule.cs"
                    int* csharp2cuda_temp_1 = &(right);
                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                }
            }
#line 320 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 323 "StatisticsModule.cs"
    return average_count;
}

#line 328 "StatisticsModule.cs"
__device__ int mathblocks_statistics_pair_slopes(
    const double* x,
    const double* y,
    int count,
    double* slopes)
#line 334 "StatisticsModule.cs"
{
#line 335 "StatisticsModule.cs"
    int slope_count = 0;
#line 336 "StatisticsModule.cs"
    {
#line 336 "StatisticsModule.cs"
        int left = 0;
        while (true)
        {
            if (!(((left) < (count))))
                break;
#line 337 "StatisticsModule.cs"
            {
#line 338 "StatisticsModule.cs"
                {
#line 338 "StatisticsModule.cs"
                    int right = csharp2cuda_i32_add(left, 1);
                    while (true)
                    {
                        if (!(((right) < (count))))
                            break;
#line 339 "StatisticsModule.cs"
                        {
#line 340 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (x)[right];
#line 340 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (x)[left];
#line 340 "StatisticsModule.cs"
                            double difference = __dsub_rn(csharp2cuda_temp_2, csharp2cuda_temp_3);
#line 341 "StatisticsModule.cs"
                            if (((difference) != (0.0)))
                            {
#line 342 "StatisticsModule.cs"
#line 342 "StatisticsModule.cs"
                                int* csharp2cuda_temp_4 = &(slope_count);
#line 342 "StatisticsModule.cs"
                                int csharp2cuda_temp_5 = csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
#line 342 "StatisticsModule.cs"
                                double* csharp2cuda_temp_6 = &((slopes)[csharp2cuda_temp_5]);
#line 342 "StatisticsModule.cs"
                                double csharp2cuda_temp_7 = (y)[right];
#line 342 "StatisticsModule.cs"
                                double csharp2cuda_temp_8 = (y)[left];
#line 342 "StatisticsModule.cs"
                                double csharp2cuda_temp_9 = __ddiv_rn(__dsub_rn(csharp2cuda_temp_7, csharp2cuda_temp_8), difference);
                                (*(csharp2cuda_temp_6) = csharp2cuda_temp_9);
                            }
                        }
#line 338 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(right);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
            }
#line 336 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(left);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 345 "StatisticsModule.cs"
    return slope_count;
}

#line 81 "StatisticsModule.cs"
__device__ double mathblocks_statistics_pearson(
    const double* left,
    const double* right,
    int count)
#line 86 "StatisticsModule.cs"
{
#line 87 "StatisticsModule.cs"
#line 87 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = mathblocks_statistics_population_covariance(left, right, count);
#line 88 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = mathblocks_statistics_population_variance(left, count);
#line 89 "StatisticsModule.cs"
    double csharp2cuda_temp_2 = mathblocks_statistics_population_variance(right, count);
    return __ddiv_rn(csharp2cuda_temp_0, __dmul_rn(mathblocks_square_root(csharp2cuda_temp_1), mathblocks_square_root(csharp2cuda_temp_2)));
}

#line 67 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_covariance(
    const double* left,
    const double* right,
    int count)
#line 72 "StatisticsModule.cs"
{
#line 73 "StatisticsModule.cs"
    double left_mean = mathblocks_statistics_mean(left, count);
#line 74 "StatisticsModule.cs"
    double right_mean = mathblocks_statistics_mean(right, count);
#line 75 "StatisticsModule.cs"
    double sum = 0.0;
#line 76 "StatisticsModule.cs"
    {
#line 76 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 77 "StatisticsModule.cs"
#line 77 "StatisticsModule.cs"
            double* csharp2cuda_temp_1 = &(sum);
#line 77 "StatisticsModule.cs"
            double csharp2cuda_temp_2 = *(csharp2cuda_temp_1);
#line 77 "StatisticsModule.cs"
            double csharp2cuda_temp_3 = (left)[index];
#line 77 "StatisticsModule.cs"
            double csharp2cuda_temp_4 = (right)[index];
            (*(csharp2cuda_temp_1) = __dadd_rn(csharp2cuda_temp_2, __dmul_rn(__dsub_rn(csharp2cuda_temp_3, left_mean), __dsub_rn(csharp2cuda_temp_4, right_mean))));
#line 76 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 78 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 52 "StatisticsModule.cs"
__device__ double mathblocks_statistics_population_variance(
    const double* values,
    int count)
#line 56 "StatisticsModule.cs"
{
#line 57 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 58 "StatisticsModule.cs"
    double sum = 0.0;
#line 59 "StatisticsModule.cs"
    {
#line 59 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 60 "StatisticsModule.cs"
            {
#line 61 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 61 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 62 "StatisticsModule.cs"
#line 62 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(sum);
#line 62 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, __dmul_rn(difference, difference)));
            }
#line 59 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 64 "StatisticsModule.cs"
    return __ddiv_rn(sum, ((double)(count)));
}

#line 149 "StatisticsModule.cs"
__device__ void mathblocks_statistics_rank(
    const double* values,
    int count,
    double* result)
#line 154 "StatisticsModule.cs"
{
#line 155 "StatisticsModule.cs"
    {
#line 155 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 156 "StatisticsModule.cs"
            {
#line 157 "StatisticsModule.cs"
                int lower = 0;
#line 158 "StatisticsModule.cs"
                int equal = 0;
#line 159 "StatisticsModule.cs"
                {
#line 159 "StatisticsModule.cs"
                    int candidate = 0;
                    while (true)
                    {
                        if (!(((candidate) < (count))))
                            break;
#line 160 "StatisticsModule.cs"
                        {
#line 161 "StatisticsModule.cs"
#line 161 "StatisticsModule.cs"
                            double csharp2cuda_temp_2 = (values)[candidate];
#line 161 "StatisticsModule.cs"
                            double csharp2cuda_temp_3 = (values)[index];
                            if (((csharp2cuda_temp_2) < (csharp2cuda_temp_3)))
                            {
#line 162 "StatisticsModule.cs"
#line 162 "StatisticsModule.cs"
                                int* csharp2cuda_temp_4 = &(lower);
                                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_4));
                            }
                            else
                            {
#line 163 "StatisticsModule.cs"
#line 163 "StatisticsModule.cs"
                                double csharp2cuda_temp_5 = (values)[candidate];
#line 163 "StatisticsModule.cs"
                                double csharp2cuda_temp_6 = (values)[index];
                                if (((csharp2cuda_temp_5) == (csharp2cuda_temp_6)))
                                {
#line 164 "StatisticsModule.cs"
#line 164 "StatisticsModule.cs"
                                    int* csharp2cuda_temp_7 = &(equal);
                                    csharp2cuda_i32_post_increment(*(csharp2cuda_temp_7));
                                }
                            }
                        }
#line 159 "StatisticsModule.cs"
                        int* csharp2cuda_temp_1 = &(candidate);
                        csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
                    }
                }
#line 166 "StatisticsModule.cs"
#line 166 "StatisticsModule.cs"
                double* csharp2cuda_temp_8 = &((result)[index]);
#line 166 "StatisticsModule.cs"
                double csharp2cuda_temp_9 = __ddiv_rn(__dadd_rn(((double)(equal)), 1.0), 2.0);
                (*(csharp2cuda_temp_8) = __dadd_rn(((double)(lower)), csharp2cuda_temp_9));
            }
#line 155 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 255 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_shape_moment_value(
    const double* values,
    int count,
    bool kurtosis,
    double* value)
#line 261 "StatisticsModule.cs"
{
#line 262 "StatisticsModule.cs"
    if (((count) <= (0)))
    {
#line 263 "StatisticsModule.cs"
        return false;
    }
#line 264 "StatisticsModule.cs"
    double mean = mathblocks_statistics_mean(values, count);
#line 265 "StatisticsModule.cs"
    double second_moment = 0.0;
#line 266 "StatisticsModule.cs"
    double higher_moment = 0.0;
#line 267 "StatisticsModule.cs"
    {
#line 267 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 268 "StatisticsModule.cs"
            {
#line 269 "StatisticsModule.cs"
                double csharp2cuda_temp_1 = (values)[index];
#line 269 "StatisticsModule.cs"
                double difference = __dsub_rn(csharp2cuda_temp_1, mean);
#line 270 "StatisticsModule.cs"
                double square = __dmul_rn(difference, difference);
#line 271 "StatisticsModule.cs"
#line 271 "StatisticsModule.cs"
                double* csharp2cuda_temp_2 = &(second_moment);
#line 271 "StatisticsModule.cs"
                double csharp2cuda_temp_3 = *(csharp2cuda_temp_2);
                (*(csharp2cuda_temp_2) = __dadd_rn(csharp2cuda_temp_3, square));
#line 272 "StatisticsModule.cs"
#line 272 "StatisticsModule.cs"
                double* csharp2cuda_temp_4 = &(higher_moment);
#line 272 "StatisticsModule.cs"
                double csharp2cuda_temp_5 = *(csharp2cuda_temp_4);
#line 272 "StatisticsModule.cs"
                double csharp2cuda_temp_6;
#line 272 "StatisticsModule.cs"
                if (kurtosis)
                {
#line 272 "StatisticsModule.cs"
                    csharp2cuda_temp_6 = __dmul_rn(square, square);
                }
                else
                {
#line 272 "StatisticsModule.cs"
                    csharp2cuda_temp_6 = __dmul_rn(square, difference);
                }
                (*(csharp2cuda_temp_4) = __dadd_rn(csharp2cuda_temp_5, csharp2cuda_temp_6));
            }
#line 267 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
#line 274 "StatisticsModule.cs"
#line 274 "StatisticsModule.cs"
    double* csharp2cuda_temp_7 = &(second_moment);
#line 274 "StatisticsModule.cs"
    double csharp2cuda_temp_8 = *(csharp2cuda_temp_7);
    (*(csharp2cuda_temp_7) = __ddiv_rn(csharp2cuda_temp_8, ((double)(count))));
#line 275 "StatisticsModule.cs"
#line 275 "StatisticsModule.cs"
    double* csharp2cuda_temp_9 = &(higher_moment);
#line 275 "StatisticsModule.cs"
    double csharp2cuda_temp_10 = *(csharp2cuda_temp_9);
    (*(csharp2cuda_temp_9) = __ddiv_rn(csharp2cuda_temp_10, ((double)(count))));
#line 276 "StatisticsModule.cs"
#line 276 "StatisticsModule.cs"
    double* csharp2cuda_temp_11 = value;
#line 276 "StatisticsModule.cs"
    double csharp2cuda_temp_12;
#line 276 "StatisticsModule.cs"
    if (kurtosis)
    {
#line 277 "StatisticsModule.cs"
        double csharp2cuda_temp_13 = __ddiv_rn(higher_moment, __dmul_rn(second_moment, second_moment));
#line 276 "StatisticsModule.cs"
        csharp2cuda_temp_12 = __dsub_rn(csharp2cuda_temp_13, 3.0);
    }
    else
    {
#line 276 "StatisticsModule.cs"
        csharp2cuda_temp_12 = __ddiv_rn(higher_moment, mathblocks_power(second_moment, 1.5));
    }
    (*(csharp2cuda_temp_11) = csharp2cuda_temp_12);
#line 279 "StatisticsModule.cs"
#line 279 "StatisticsModule.cs"
    double csharp2cuda_temp_14 = *(value);
    return isfinite(csharp2cuda_temp_14);
}

#line 92 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_copy(
    const double* values,
    int count,
    double* result)
#line 97 "StatisticsModule.cs"
{
#line 98 "StatisticsModule.cs"
    {
#line 98 "StatisticsModule.cs"
        int index = 0;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 99 "StatisticsModule.cs"
            {
#line 100 "StatisticsModule.cs"
                double value = (values)[index];
#line 101 "StatisticsModule.cs"
                int position = index;
#line 102 "StatisticsModule.cs"
                while (true)
                {
#line 102 "StatisticsModule.cs"
                    bool csharp2cuda_temp_1;
#line 102 "StatisticsModule.cs"
                    if (((position) > (0)))
                    {
#line 102 "StatisticsModule.cs"
                        double csharp2cuda_temp_2 = (result)[csharp2cuda_i32_sub(position, 1)];
#line 102 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (value));
                    }
                    else
                    {
#line 102 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 103 "StatisticsModule.cs"
                    {
#line 104 "StatisticsModule.cs"
#line 104 "StatisticsModule.cs"
                        double* csharp2cuda_temp_3 = &((result)[position]);
#line 104 "StatisticsModule.cs"
                        double csharp2cuda_temp_4 = (result)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 105 "StatisticsModule.cs"
#line 105 "StatisticsModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 107 "StatisticsModule.cs"
#line 107 "StatisticsModule.cs"
                double* csharp2cuda_temp_6 = &((result)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 98 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 111 "StatisticsModule.cs"
__device__ void mathblocks_statistics_sort_in_place(double* values, int count)
#line 113 "StatisticsModule.cs"
{
#line 114 "StatisticsModule.cs"
    {
#line 114 "StatisticsModule.cs"
        int index = 1;
        while (true)
        {
            if (!(((index) < (count))))
                break;
#line 115 "StatisticsModule.cs"
            {
#line 116 "StatisticsModule.cs"
                double value = (values)[index];
#line 117 "StatisticsModule.cs"
                int position = index;
#line 118 "StatisticsModule.cs"
                while (true)
                {
#line 118 "StatisticsModule.cs"
                    bool csharp2cuda_temp_1;
#line 118 "StatisticsModule.cs"
                    if (((position) > (0)))
                    {
#line 118 "StatisticsModule.cs"
                        double csharp2cuda_temp_2 = (values)[csharp2cuda_i32_sub(position, 1)];
#line 118 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = ((csharp2cuda_temp_2) > (value));
                    }
                    else
                    {
#line 118 "StatisticsModule.cs"
                        csharp2cuda_temp_1 = false;
                    }
                    if (!(csharp2cuda_temp_1))
                        break;
#line 119 "StatisticsModule.cs"
                    {
#line 120 "StatisticsModule.cs"
#line 120 "StatisticsModule.cs"
                        double* csharp2cuda_temp_3 = &((values)[position]);
#line 120 "StatisticsModule.cs"
                        double csharp2cuda_temp_4 = (values)[csharp2cuda_i32_sub(position, 1)];
                        (*(csharp2cuda_temp_3) = csharp2cuda_temp_4);
#line 121 "StatisticsModule.cs"
#line 121 "StatisticsModule.cs"
                        int* csharp2cuda_temp_5 = &(position);
                        csharp2cuda_i32_post_decrement(*(csharp2cuda_temp_5));
                    }
                }
#line 123 "StatisticsModule.cs"
#line 123 "StatisticsModule.cs"
                double* csharp2cuda_temp_6 = &((values)[position]);
                (*(csharp2cuda_temp_6) = value);
            }
#line 114 "StatisticsModule.cs"
            int* csharp2cuda_temp_0 = &(index);
            csharp2cuda_i32_post_increment(*(csharp2cuda_temp_0));
        }
    }
}

#line 127 "StatisticsModule.cs"
__device__ double mathblocks_statistics_sorted_quantile(
    const double* sorted,
    int count,
    double probability)
#line 132 "StatisticsModule.cs"
{
#line 133 "StatisticsModule.cs"
    if (((count) == (1)))
    {
#line 134 "StatisticsModule.cs"
        return (sorted)[0];
    }
#line 135 "StatisticsModule.cs"
    double position = __dmul_rn(probability, ((double)(csharp2cuda_i32_sub(count, 1))));
#line 136 "StatisticsModule.cs"
    int lower = csharp2cuda_f64_to_i32(floor(position));
#line 137 "StatisticsModule.cs"
    int upper = csharp2cuda_f64_to_i32(ceil(position));
#line 138 "StatisticsModule.cs"
    double weight = __dsub_rn(position, ((double)(lower)));
#line 139 "StatisticsModule.cs"
#line 139 "StatisticsModule.cs"
    double csharp2cuda_temp_0 = (sorted)[lower];
#line 139 "StatisticsModule.cs"
    double csharp2cuda_temp_1 = (sorted)[upper];
    return __dadd_rn(__dmul_rn(csharp2cuda_temp_0, __dsub_rn(1.0, weight)), __dmul_rn(csharp2cuda_temp_1, weight));
}

#line 282 "StatisticsModule.cs"
__device__ bool mathblocks_statistics_weighted_value(
    const double* values,
    const double* weights,
    int count,
    bool variance,
    double* value)
#line 289 "StatisticsModule.cs"
{
#line 290 "StatisticsModule.cs"
    if (((count) <= (0)))
    {
#line 291 "StatisticsModule.cs"
        return false;
    }
#line 292 "StatisticsModule.cs"
    double weight_sum = mathblocks_compensated_sum(weights, count);
#line 293 "StatisticsModule.cs"
    double mean = __ddiv_rn(mathblocks_compensated_product_sum(values, weights, count), weight_sum);
#line 294 "StatisticsModule.cs"
    if ((!(variance)))
#line 295 "StatisticsModule.cs"
    {
#line 296 "StatisticsModule.cs"
#line 296 "StatisticsModule.cs"
        double* csharp2cuda_temp_0 = value;
        (*(csharp2cuda_temp_0) = mean);
    }
    else
#line 299 "StatisticsModule.cs"
    {
#line 300 "StatisticsModule.cs"
        double numerator = 0.0;
#line 301 "StatisticsModule.cs"
        {
#line 301 "StatisticsModule.cs"
            int index = 0;
            while (true)
            {
                if (!(((index) < (count))))
                    break;
#line 302 "StatisticsModule.cs"
                {
#line 303 "StatisticsModule.cs"
                    double csharp2cuda_temp_2 = (values)[index];
#line 303 "StatisticsModule.cs"
                    double difference = __dsub_rn(csharp2cuda_temp_2, mean);
#line 304 "StatisticsModule.cs"
#line 304 "StatisticsModule.cs"
                    double* csharp2cuda_temp_3 = &(numerator);
#line 304 "StatisticsModule.cs"
                    double csharp2cuda_temp_4 = *(csharp2cuda_temp_3);
#line 304 "StatisticsModule.cs"
                    double csharp2cuda_temp_5 = (weights)[index];
                    (*(csharp2cuda_temp_3) = __dadd_rn(csharp2cuda_temp_4, __dmul_rn(__dmul_rn(csharp2cuda_temp_5, difference), difference)));
                }
#line 301 "StatisticsModule.cs"
                int* csharp2cuda_temp_1 = &(index);
                csharp2cuda_i32_post_increment(*(csharp2cuda_temp_1));
            }
        }
#line 306 "StatisticsModule.cs"
#line 306 "StatisticsModule.cs"
        double* csharp2cuda_temp_6 = value;
#line 306 "StatisticsModule.cs"
        double csharp2cuda_temp_7 = __ddiv_rn(numerator, weight_sum);
        (*(csharp2cuda_temp_6) = csharp2cuda_temp_7);
    }
#line 308 "StatisticsModule.cs"
#line 308 "StatisticsModule.cs"
    double csharp2cuda_temp_8 = *(value);
    return isfinite(csharp2cuda_temp_8);
}